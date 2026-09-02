import 'dart:math' as math;
import 'dart:ui';

import '../../domain/model/plant_state.dart';
import '../../domain/rules/growth_constants.dart';
import '../theme/app_theme.dart';

enum PlantElementKind { branch, leaf, decoration }

/// One drawable element with resolved geometry and its event's identity.
class PlacedElement {
  const PlacedElement({
    required this.kind,
    required this.center,
    required this.size,
    required this.rotation,
    required this.color,
    required this.sourceEventId,
  });

  final PlantElementKind kind;
  final Offset center;
  final double size;

  /// Radians; leaves point away from the trunk.
  final double rotation;
  final Color color;
  final String sourceEventId;

  @override
  bool operator ==(Object other) {
    return other is PlacedElement &&
        other.kind == kind &&
        other.center == center &&
        other.size == size &&
        other.rotation == rotation &&
        other.color == color &&
        other.sourceEventId == sourceEventId;
  }

  @override
  int get hashCode =>
      Object.hash(kind, center, size, rotation, color, sourceEventId);
}

/// Pure projection of PlantState into geometry (ADR 0007 #2): no randomness,
/// no clock, no progress — the same state and canvas always place the same
/// elements (spec A.10). The painter only draws what this computes.
class PlantLayout {
  const PlantLayout({
    required this.trunkBase,
    required this.trunkTop,
    required this.trunkThickness,
    required this.branches,
    required this.leaves,
    required this.decorations,
    required this.mature,
  });

  final Offset trunkBase;
  final Offset trunkTop;
  final double trunkThickness;
  final List<PlacedElement> branches;
  final List<PlacedElement> leaves;
  final List<PlacedElement> decorations;
  final bool mature;

  static PlantLayout compute(PlantState state, Size size) {
    final centerX = size.width / 2;
    final groundY = size.height * 0.92;
    final usableHeight = size.height * 0.72;
    final trunkLength =
        usableHeight * (state.effectiveHeight / GrowthConstants.maxHeight);
    final base = Offset(centerX, groundY);
    final top = Offset(centerX, groundY - trunkLength);

    // Deterministic index wobble — repo-owned math, no RNG (spec A.10).
    double wobble(int i) => ((i * 37) % 17) / 17.0;

    double spreadFor(String morphologyId) => switch (morphologyId) {
      'v1.vertical' => 0.35,
      'v1.compact' => 0.55,
      'v1.spiral' => 0.8,
      'v1.broad' => 1.0,
      _ => 0.72, // balanced and any future id: safe middle
    };

    final maxReach = size.width * 0.30;

    // Young plants have proportionally small elements; everything grows
    // toward full size with the trunk (deterministic in state alone).
    final growthScale =
        0.55 + 0.45 * (state.effectiveHeight / GrowthConstants.maxHeight);

    List<PlacedElement> place(
      List<PlantElement> elements,
      PlantElementKind kind, {
      required double baseReach,
      required double elementSize,
    }) {
      final placed = <PlacedElement>[];
      final n = elements.length;
      for (var i = 0; i < n; i++) {
        final element = elements[i];
        final t = (i + 1) / (n + 1);
        final y = groundY - trunkLength * t - 6;
        final side = i.isEven ? 1.0 : -1.0;
        final reach =
            (baseReach + wobble(i) * baseReach * 0.6) *
            spreadFor(element.morphologyId) *
            growthScale;
        final dx = (side * reach).clamp(-maxReach, maxReach);
        final scaledSize = elementSize * growthScale;
        final x = (centerX + dx).clamp(scaledSize, size.width - scaledSize);
        final outward = side > 0 ? 0.0 : math.pi;
        final tilt = (0.35 + wobble(i) * 0.5) * -side;
        placed.add(
          PlacedElement(
            kind: kind,
            center: Offset(x, y.clamp(scaledSize, size.height)),
            size: scaledSize,
            rotation: outward + tilt,
            color: paletteAccent(element.paletteId),
            sourceEventId: element.sourceEventId,
          ),
        );
      }
      return placed;
    }

    return PlantLayout(
      trunkBase: base,
      trunkTop: top,
      trunkThickness:
          5 + 3 * (state.effectiveHeight / GrowthConstants.maxHeight),
      branches: place(
        state.branches,
        PlantElementKind.branch,
        baseReach: size.width * 0.16,
        elementSize: 26,
      ),
      leaves: place(
        state.leaves,
        PlantElementKind.leaf,
        baseReach: size.width * 0.12,
        elementSize: 14,
      ),
      decorations: place(
        state.decorations,
        PlantElementKind.decoration,
        baseReach: size.width * 0.2,
        elementSize: 5,
      ),
      mature: state.isMature,
    );
  }
}
