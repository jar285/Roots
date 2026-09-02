import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../domain/model/plant_state.dart';
import '../../domain/rules/growth_constants.dart';
import '../theme/app_theme.dart';
import 'plant_layout.dart';

/// The plant on its greenhouse-arch stage (ADR 0006 #1): a rounded arch with
/// a soft glow frames the deterministic organic plant. One concise semantics
/// summary speaks for the whole canvas.
///
/// [animate] runs the growth reveal (≤ 800 ms ease-out, spec motion rules);
/// reduced motion pins the reveal to the final state instantly. Animation
/// only reveals already-computed geometry — it never alters it (spec A.10).
class PlantView extends StatefulWidget {
  const PlantView({super.key, required this.plant, this.animate = false});

  final PlantState plant;
  final bool animate;

  @override
  State<PlantView> createState() => _PlantViewState();
}

class _PlantViewState extends State<PlantView>
    with SingleTickerProviderStateMixin {
  late final AnimationController _reveal = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 600),
    value: 1.0,
  );

  bool _revealDecided = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_revealDecided) return;
    _revealDecided = true;
    final reduceMotion = MediaQuery.disableAnimationsOf(context);
    if (widget.animate && !reduceMotion) {
      _reveal.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _reveal.dispose();
    super.dispose();
  }

  String get _summary {
    final plant = widget.plant;
    final checkIns = plant.eventCount == 1
        ? '1 check-in'
        : '${plant.eventCount} check-ins';
    final maturity = plant.isMature ? ', fully grown' : '';
    return 'Your plant: $checkIns, height ${plant.effectiveHeight} '
        'of ${GrowthConstants.maxHeight}$maturity.';
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: _summary,
      child: ExcludeSemantics(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final archRadius = constraints.maxWidth / 2;
            return Container(
              decoration: BoxDecoration(
                color: AppTokens.surface,
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(archRadius),
                  bottom: const Radius.circular(AppTokens.radius),
                ),
                // BoxDecoration ignores `color` when a gradient is set, so
                // both stops must be opaque: a green-tinted surface at the
                // center fading to plain surface (no see-through donut).
                gradient: RadialGradient(
                  center: const Alignment(0, 0.3),
                  radius: 0.9,
                  stops: const [0.0, 0.6],
                  colors: [
                    Color.alphaBlend(
                      AppTokens.plantGreen.withValues(alpha: 0.10),
                      AppTokens.surface,
                    ),
                    AppTokens.surface,
                  ],
                ),
              ),
              clipBehavior: Clip.antiAlias,
              child: AnimatedBuilder(
                animation: _reveal,
                builder: (context, _) => CustomPaint(
                  painter: OrganicPlantPainter(
                    plant: widget.plant,
                    progress: Curves.easeOut.transform(_reveal.value),
                  ),
                  size: Size.infinite,
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

/// Thin renderer of [PlantLayout] in the spec A.10 drawing order:
/// ground and pot, trunk, branches, leaves, decorations, mature flourish.
/// Same PlantState and viewport ⇒ same final frame.
class OrganicPlantPainter extends CustomPainter {
  OrganicPlantPainter({required this.plant, this.progress = 1.0});

  final PlantState plant;
  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    final layout = PlantLayout.compute(plant, size);

    _paintGroundAndPot(canvas, layout);
    _paintTrunk(canvas, layout);
    _paintBranches(canvas, layout);
    _paintLeaves(canvas, layout.leaves);
    _paintDecorations(canvas, layout.decorations);
    if (layout.mature && progress >= 1.0) {
      _paintMatureFlourish(canvas, layout);
    }
  }

  bool _revealed(int index, int total) {
    if (total == 0) return false;
    return (index + 1) / total <= progress + 1e-9;
  }

  void _paintGroundAndPot(Canvas canvas, PlantLayout layout) {
    final base = layout.trunkBase;
    canvas.drawLine(
      Offset(base.dx - 70, base.dy + 14),
      Offset(base.dx + 70, base.dy + 14),
      Paint()
        ..color = AppTokens.surfaceRaised
        ..strokeWidth = 2,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset(base.dx, base.dy + 4),
          width: 92,
          height: 22,
        ),
        const Radius.circular(8),
      ),
      Paint()..color = AppTokens.surfaceRaised,
    );
  }

  void _paintTrunk(Canvas canvas, PlantLayout layout) {
    final points = layout.trunkPath;
    final visible = math.max(2, (points.length * progress).ceil());
    final path = Path()..moveTo(points.first.dx, points.first.dy);
    for (var i = 1; i < visible && i < points.length; i++) {
      path.lineTo(points[i].dx, points[i].dy);
    }
    canvas.drawPath(
      path,
      Paint()
        ..color = AppTokens.plantGreen
        ..style = PaintingStyle.stroke
        ..strokeWidth = layout.trunkThickness
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round,
    );
  }

  void _paintBranches(Canvas canvas, PlantLayout layout) {
    final branches = layout.branches;
    for (var i = 0; i < branches.length; i++) {
      if (!_revealed(i, branches.length)) continue;
      final branch = branches[i];
      canvas.drawPath(
        Path()
          ..moveTo(branch.start.dx, branch.start.dy)
          ..quadraticBezierTo(
            branch.control.dx,
            branch.control.dy,
            branch.tip.dx,
            branch.tip.dy,
          ),
        Paint()
          ..color = branch.color.withValues(alpha: 0.9)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.6
          ..strokeCap = StrokeCap.round,
      );
      canvas.drawCircle(branch.tip, 3.0, Paint()..color = branch.color);
    }
  }

  void _paintLeaves(Canvas canvas, List<PlacedElement> leaves) {
    for (var i = 0; i < leaves.length; i++) {
      if (!_revealed(i, leaves.length)) continue;
      final leaf = leaves[i];
      // Petiole from the stem it grows on (connected organism).
      canvas.drawLine(
        leaf.anchor,
        leaf.center,
        Paint()
          ..color = AppTokens.plantGreen.withValues(alpha: 0.5)
          ..strokeWidth = 1.5
          ..strokeCap = StrokeCap.round,
      );
      canvas.save();
      canvas.translate(leaf.center.dx, leaf.center.dy);
      canvas.rotate(leaf.rotation);
      final r = leaf.size;
      canvas.drawPath(
        Path()..addRRect(
          RRect.fromRectAndCorners(
            Rect.fromCenter(center: Offset.zero, width: r * 2, height: r * 1.2),
            topRight: Radius.circular(r * 2),
            bottomLeft: Radius.circular(r * 2),
            topLeft: const Radius.circular(2),
            bottomRight: const Radius.circular(2),
          ),
        ),
        Paint()..color = leaf.color,
      );
      canvas.restore();
    }
  }

  void _paintDecorations(Canvas canvas, List<PlacedElement> decorations) {
    for (var i = 0; i < decorations.length; i++) {
      if (!_revealed(i, decorations.length)) continue;
      final decoration = decorations[i];
      canvas.drawLine(
        decoration.anchor,
        decoration.center,
        Paint()
          ..color = decoration.color.withValues(alpha: 0.4)
          ..strokeWidth = 1.2
          ..strokeCap = StrokeCap.round,
      );
      canvas.drawCircle(
        decoration.center,
        decoration.size,
        Paint()..color = decoration.color,
      );
    }
  }

  void _paintMatureFlourish(Canvas canvas, PlantLayout layout) {
    canvas.drawCircle(
      layout.trunkTop,
      26,
      Paint()
        ..color = AppTokens.warning.withValues(alpha: 0.25)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3,
    );
    canvas.drawCircle(
      layout.trunkTop,
      34,
      Paint()
        ..color = AppTokens.warning.withValues(alpha: 0.12)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );
  }

  @override
  bool shouldRepaint(OrganicPlantPainter oldDelegate) =>
      oldDelegate.plant != plant || oldDelegate.progress != progress;
}
