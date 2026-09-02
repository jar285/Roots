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

    _paintGroundAndPot(canvas, size, layout);
    _paintTrunk(canvas, layout);
    _paintElements(canvas, layout.branches, trunkX: layout.trunkBase.dx);
    _paintElements(canvas, layout.leaves, trunkX: layout.trunkBase.dx);
    _paintElements(canvas, layout.decorations, trunkX: layout.trunkBase.dx);
    if (layout.mature && progress >= 1.0) {
      _paintMatureFlourish(canvas, layout);
    }
  }

  bool _revealed(int index, int total) {
    if (total == 0) return false;
    return (index + 1) / total <= progress + 1e-9;
  }

  void _paintGroundAndPot(Canvas canvas, Size size, PlantLayout layout) {
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
    final base = layout.trunkBase;
    final fullLength = base.dy - layout.trunkTop.dy;
    final revealedTop = Offset(base.dx, base.dy - fullLength * progress);

    // A gentle deterministic S-curve keeps the stem organic.
    final bend = math.min(22.0, fullLength * 0.11);
    final path = Path()
      ..moveTo(base.dx, base.dy)
      ..cubicTo(
        base.dx - bend,
        base.dy - (base.dy - revealedTop.dy) * 0.35,
        base.dx + bend,
        base.dy - (base.dy - revealedTop.dy) * 0.7,
        revealedTop.dx,
        revealedTop.dy,
      );
    canvas.drawPath(
      path,
      Paint()
        ..color = AppTokens.plantGreen
        ..style = PaintingStyle.stroke
        ..strokeWidth = layout.trunkThickness
        ..strokeCap = StrokeCap.round,
    );
  }

  void _paintElements(
    Canvas canvas,
    List<PlacedElement> elements, {
    required double trunkX,
  }) {
    for (var i = 0; i < elements.length; i++) {
      if (!_revealed(i, elements.length)) continue;
      final element = elements[i];
      switch (element.kind) {
        case PlantElementKind.branch:
          _paintBranch(canvas, element, trunkX);
        case PlantElementKind.leaf:
          // A fine petiole ties each leaf to the stem so the plant reads as
          // one organism (Design 3 QA pass).
          canvas.drawLine(
            Offset(trunkX, element.center.dy + element.size * 0.3),
            element.center,
            Paint()
              ..color = AppTokens.plantGreen.withValues(alpha: 0.45)
              ..strokeWidth = 1.6
              ..strokeCap = StrokeCap.round,
          );
          _paintLeaf(canvas, element);
        case PlantElementKind.decoration:
          canvas.drawCircle(
            element.center,
            element.size,
            Paint()..color = element.color,
          );
      }
    }
  }

  void _paintBranch(Canvas canvas, PlacedElement element, double trunkX) {
    // Branches grow out of the trunk toward their placed tip, so they read
    // as part of one plant rather than floating marks.
    final start = Offset(trunkX, element.center.dy + element.size * 0.35);
    final paint = Paint()
      ..color = element.color.withValues(alpha: 0.9)
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    canvas.drawPath(
      Path()
        ..moveTo(start.dx, start.dy)
        ..quadraticBezierTo(
          (start.dx + element.center.dx) / 2,
          element.center.dy + element.size * 0.15,
          element.center.dx,
          element.center.dy,
        ),
      paint,
    );
    canvas.drawCircle(element.center, 3.2, Paint()..color = element.color);
  }

  void _paintLeaf(Canvas canvas, PlacedElement element) {
    canvas.save();
    canvas.translate(element.center.dx, element.center.dy);
    canvas.rotate(element.rotation);
    final r = element.size;
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
      Paint()..color = element.color,
    );
    canvas.restore();
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
