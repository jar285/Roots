import 'package:flutter/material.dart';

import '../../domain/model/plant_state.dart';
import '../../domain/rules/growth_constants.dart';
import '../theme/app_theme.dart';

/// Sprint 3 placeholder rendering: deterministic, immutable-state-in,
/// pixels-out, with one concise semantics summary. The full event-styled
/// painter, motion, and goldens are Sprint 5's outcome (ADR 0004 #6).
class PlantView extends StatelessWidget {
  const PlantView({super.key, required this.plant});

  final PlantState plant;

  String get _summary {
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
        child: CustomPaint(
          painter: _PlaceholderPlantPainter(plant: plant),
          size: Size.infinite,
        ),
      ),
    );
  }
}

class _PlaceholderPlantPainter extends CustomPainter {
  _PlaceholderPlantPainter({required this.plant});

  final PlantState plant;

  @override
  void paint(Canvas canvas, Size size) {
    final centerX = size.width / 2;
    final ground = size.height - 24;

    // Pot.
    final potPaint = Paint()..color = AppTokens.surfaceRaised;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset(centerX, ground - 14),
          width: 88,
          height: 28,
        ),
        const Radius.circular(8),
      ),
      potPaint,
    );

    // Trunk scaled by effective height.
    final maxTrunk = size.height * 0.7;
    final trunkHeight =
        maxTrunk * (plant.effectiveHeight / GrowthConstants.maxHeight);
    final top = ground - 28 - trunkHeight;
    final trunkPaint = Paint()
      ..color = AppTokens.plantGreen
      ..strokeWidth = 6
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(
      Offset(centerX, ground - 28),
      Offset(centerX, top),
      trunkPaint,
    );

    // Elements as deterministic marks alternating around the trunk, each in
    // its event's palette accent — history keeps its colors (spec A.6).
    void drawMarks(
      List<PlantElement> elements, {
      required double radius,
      required double spacing,
      required double offset,
    }) {
      for (var i = 0; i < elements.length; i++) {
        final side = i.isEven ? 1 : -1;
        final y = ground - 40 - (i * spacing) % (trunkHeight + 1);
        final x = centerX + side * offset;
        canvas.drawCircle(
          Offset(x, y),
          radius,
          Paint()..color = paletteAccent(elements[i].paletteId),
        );
      }
    }

    drawMarks(plant.branches, radius: 5, spacing: 26, offset: 26);
    drawMarks(plant.leaves, radius: 3, spacing: 11, offset: 14);
    drawMarks(plant.decorations, radius: 4, spacing: 31, offset: 38);
  }

  @override
  bool shouldRepaint(_PlaceholderPlantPainter oldDelegate) =>
      oldDelegate.plant != plant;
}
