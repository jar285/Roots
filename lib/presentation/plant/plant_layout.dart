import 'dart:math' as math;
import 'dart:ui';

import '../../domain/model/plant_state.dart';
import '../../domain/rules/growth_constants.dart';
import '../theme/app_theme.dart';

enum PlantElementKind { leaf, decoration }

/// A curved stem sprouting from the trunk (quadratic: start → control → tip),
/// permanently tied to its source event.
class PlacedBranch {
  const PlacedBranch({
    required this.start,
    required this.control,
    required this.tip,
    required this.color,
    required this.sourceEventId,
  });

  final Offset start;
  final Offset control;
  final Offset tip;
  final Color color;
  final String sourceEventId;

  /// Point on the quadratic curve at parameter [t].
  Offset pointAt(double t) {
    final a = Offset.lerp(start, control, t)!;
    final b = Offset.lerp(control, tip, t)!;
    return Offset.lerp(a, b, t)!;
  }

  /// Curve tangent angle at parameter [t].
  double angleAt(double t) {
    final derivative =
        (control - start) * (2 * (1 - t)) + (tip - control) * (2 * t);
    return math.atan2(derivative.dy, derivative.dx);
  }

  @override
  bool operator ==(Object other) {
    return other is PlacedBranch &&
        other.start == start &&
        other.control == control &&
        other.tip == tip &&
        other.color == color &&
        other.sourceEventId == sourceEventId;
  }

  @override
  int get hashCode => Object.hash(start, control, tip, color, sourceEventId);
}

/// A leaf or decoration with resolved geometry, its stem [anchor] (the point
/// it grows from, on the trunk or a branch), and its event identity.
class PlacedElement {
  const PlacedElement({
    required this.kind,
    required this.center,
    required this.anchor,
    required this.size,
    required this.rotation,
    required this.color,
    required this.sourceEventId,
  });

  final PlantElementKind kind;
  final Offset center;
  final Offset anchor;
  final double size;
  final double rotation;
  final Color color;
  final String sourceEventId;

  @override
  bool operator ==(Object other) {
    return other is PlacedElement &&
        other.kind == kind &&
        other.center == center &&
        other.anchor == anchor &&
        other.size == size &&
        other.rotation == rotation &&
        other.color == color &&
        other.sourceEventId == sourceEventId;
  }

  @override
  int get hashCode =>
      Object.hash(kind, center, anchor, size, rotation, color, sourceEventId);
}

/// Pure projection of PlantState into connected-organism geometry
/// (ADR 0007 #2, Sprint 5.1): no randomness, no clock, no progress — the same
/// state and canvas always place the same stems and elements (spec A.10).
/// Branches sprout from the trunk curve; every leaf and decoration anchors to
/// the trunk or a branch.
class PlantLayout {
  const PlantLayout({
    required this.trunkPath,
    required this.trunkThickness,
    required this.branches,
    required this.leaves,
    required this.decorations,
    required this.mature,
  });

  /// Polyline samples of the trunk curve, base first.
  final List<Offset> trunkPath;
  final double trunkThickness;
  final List<PlacedBranch> branches;
  final List<PlacedElement> leaves;
  final List<PlacedElement> decorations;
  final bool mature;

  Offset get trunkBase => trunkPath.first;
  Offset get trunkTop => trunkPath.last;

  static const int _trunkSamples = 24;

  static PlantLayout compute(PlantState state, Size size) {
    final centerX = size.width / 2;
    final groundY = size.height * 0.92;
    final usableHeight = size.height * 0.72;
    final trunkLength =
        usableHeight * (state.effectiveHeight / GrowthConstants.maxHeight);
    final growthScale =
        0.55 + 0.45 * (state.effectiveHeight / GrowthConstants.maxHeight);

    // Deterministic index wobble — repo-owned math, no RNG (spec A.10).
    double wobble(int i) => ((i * 37) % 17) / 17.0;

    double spreadFor(String morphologyId) => switch (morphologyId) {
      'v1.vertical' => 0.35,
      'v1.compact' => 0.55,
      'v1.spiral' => 0.8,
      'v1.broad' => 1.0,
      _ => 0.72, // balanced and any future id: safe middle
    };

    // Trunk: a gentle deterministic sway sampled as a polyline.
    final sway = math.min(20.0, trunkLength * 0.10);
    Offset trunkPointAt(double t) {
      final x = centerX + sway * math.sin(t * math.pi * 1.35) * (1 - t * 0.3);
      return Offset(x, groundY - trunkLength * t);
    }

    final trunkPath = [
      for (var i = 0; i <= _trunkSamples; i++) trunkPointAt(i / _trunkSamples),
    ];

    double clampX(double x, double margin) =>
        x.clamp(margin, size.width - margin);
    double clampY(double y, double margin) =>
        y.clamp(margin, size.height - margin);

    // Branches sprout along the upper trunk, alternating sides, arcing up.
    final branchCount = state.branches.length;
    final branches = <PlacedBranch>[];
    for (var i = 0; i < branchCount; i++) {
      final element = state.branches[i];
      final spread = spreadFor(element.morphologyId);
      final t = 0.28 + 0.62 * (i + 1) / (branchCount + 1);
      final start = trunkPointAt(t);
      final side = i.isEven ? 1.0 : -1.0;
      final length =
          (size.width * 0.13 + wobble(i) * size.width * 0.08) *
          spread *
          growthScale;
      final rise = length * (0.45 + wobble(i + 3) * 0.3);
      final tip = Offset(
        clampX(start.dx + side * length, 10),
        clampY(start.dy - rise, 10),
      );
      final control = Offset(
        clampX(start.dx + side * length * 0.45, 8),
        clampY(start.dy - rise * 0.15, 8),
      );
      branches.add(
        PlacedBranch(
          start: start,
          control: control,
          tip: tip,
          color: paletteAccent(element.paletteId),
          sourceEventId: element.sourceEventId,
        ),
      );
    }

    // Leaves and decorations grow from the trunk or a branch, round-robin,
    // positioned along their parent curve with tangent-following rotation.
    List<PlacedElement> place(
      List<PlantElement> elements,
      PlantElementKind kind, {
      required double baseSize,
      required double uMin,
      required double uSpan,
    }) {
      final placed = <PlacedElement>[];
      final parents = branchCount + 1; // slot 0 = trunk, then branches
      for (var i = 0; i < elements.length; i++) {
        final element = elements[i];
        final spread = spreadFor(element.morphologyId);
        final elementSize = baseSize * growthScale;
        final parentSlot = i % parents;
        final u = uMin + uSpan * wobble(i + 1);
        final side = (i ~/ parents).isEven ? 1.0 : -1.0;

        Offset anchor;
        double tangentAngle;
        if (parentSlot == 0 || branches.isEmpty) {
          final t = 0.18 + 0.74 * u;
          anchor = trunkPointAt(t);
          tangentAngle = -math.pi / 2; // trunk runs upward
        } else {
          final branch = branches[parentSlot - 1];
          anchor = branch.pointAt(0.35 + 0.6 * u);
          tangentAngle = branch.angleAt(0.35 + 0.6 * u);
        }

        // The element sits just off its stem, angled away from it.
        final outAngle = tangentAngle + side * math.pi / 2.4;
        final offset = elementSize * (0.9 + 0.4 * wobble(i + 5)) * spread;
        final center = Offset(
          clampX(anchor.dx + math.cos(outAngle) * offset, elementSize),
          clampY(anchor.dy + math.sin(outAngle) * offset, elementSize),
        );
        placed.add(
          PlacedElement(
            kind: kind,
            center: center,
            anchor: anchor,
            size: elementSize,
            rotation: outAngle,
            color: paletteAccent(element.paletteId),
            sourceEventId: element.sourceEventId,
          ),
        );
      }
      return placed;
    }

    return PlantLayout(
      trunkPath: trunkPath,
      trunkThickness:
          5 + 3 * (state.effectiveHeight / GrowthConstants.maxHeight),
      branches: branches,
      leaves: place(
        state.leaves,
        PlantElementKind.leaf,
        baseSize: 13,
        uMin: 0.05,
        uSpan: 0.9,
      ),
      decorations: place(
        state.decorations,
        PlantElementKind.decoration,
        baseSize: 4.5,
        uMin: 0.5,
        uSpan: 0.5,
      ),
      mature: state.isMature,
    );
  }
}
