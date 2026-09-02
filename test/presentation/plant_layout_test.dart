import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:roots/domain/model/plant_state.dart';
import 'package:roots/domain/rules/growth_constants.dart';
import 'package:roots/presentation/plant/plant_layout.dart';
import 'package:roots/presentation/theme/app_theme.dart';

PlantState state({
  int height = 200,
  int branches = 3,
  int leaves = 8,
  int decorations = 2,
  String morphology = 'v1.balanced',
  String palette = 'v1.happy',
}) {
  PlantElement element(String kind, int i) => PlantElement(
    sourceEventId: '$kind-$i',
    paletteId: palette,
    morphologyId: morphology,
  );
  return PlantState(
    effectiveHeight: height,
    branches: [for (var i = 0; i < branches; i++) element('b', i)],
    leaves: [for (var i = 0; i < leaves; i++) element('l', i)],
    decorations: [for (var i = 0; i < decorations; i++) element('d', i)],
    eventCount: 5,
    newestEventDate: '2026-09-01',
  );
}

const canvas = Size(390, 600);

void main() {
  group('PlantLayout.compute is a pure projection of PlantState', () {
    test('identical inputs produce structurally identical layouts', () {
      final a = PlantLayout.compute(state(), canvas);
      final b = PlantLayout.compute(state(), canvas);

      expect(a.trunkBase, b.trunkBase);
      expect(a.trunkTop, b.trunkTop);
      expect(a.branches, b.branches);
      expect(a.leaves, b.leaves);
      expect(a.decorations, b.decorations);
      expect(a.mature, b.mature);
    });

    test('every element keeps its source identity and event palette color', () {
      final layout = PlantLayout.compute(state(palette: 'v1.silly'), canvas);

      expect(layout.branches, hasLength(3));
      expect(layout.leaves, hasLength(8));
      expect(layout.decorations, hasLength(2));
      expect(layout.leaves.first.sourceEventId, 'l-0');
      for (final placed in [
        ...layout.branches,
        ...layout.leaves,
        ...layout.decorations,
      ]) {
        expect(placed.color, paletteAccent('v1.silly'));
      }
    });

    test('trunk length is proportional to effective height', () {
      final short = PlantLayout.compute(state(height: 100), canvas);
      final tall = PlantLayout.compute(state(height: 400), canvas);

      double lengthOf(PlantLayout l) => l.trunkBase.dy - l.trunkTop.dy;

      expect(lengthOf(tall), greaterThan(lengthOf(short)));
      expect(
        lengthOf(tall) / lengthOf(short),
        closeTo(4.0, 0.01),
        reason: 'linear in effectiveHeight',
      );
      final full = PlantLayout.compute(
        state(height: GrowthConstants.maxHeight),
        canvas,
      );
      expect(lengthOf(full), lessThan(canvas.height));
    });

    test('all placed elements stay inside the canvas', () {
      for (final morphology in [
        'v1.vertical',
        'v1.spiral',
        'v1.compact',
        'v1.broad',
        'v1.balanced',
      ]) {
        final layout = PlantLayout.compute(
          state(
            height: GrowthConstants.maxHeight,
            branches: GrowthConstants.maxBranches,
            leaves: GrowthConstants.maxLeaves,
            decorations: GrowthConstants.maxDecorations,
            morphology: morphology,
          ),
          canvas,
        );
        for (final placed in [
          ...layout.branches,
          ...layout.leaves,
          ...layout.decorations,
        ]) {
          expect(
            placed.center.dx,
            inInclusiveRange(0, canvas.width),
            reason: '$morphology dx',
          );
          expect(
            placed.center.dy,
            inInclusiveRange(0, canvas.height),
            reason: '$morphology dy',
          );
        }
      }
    });

    test('vertical morphology hugs the trunk; broad reaches wider', () {
      double meanSpread(String morphology) {
        final layout = PlantLayout.compute(
          state(leaves: 12, morphology: morphology),
          canvas,
        );
        final trunkX = layout.trunkBase.dx;
        final total = layout.leaves
            .map((e) => (e.center.dx - trunkX).abs())
            .reduce((a, b) => a + b);
        return total / layout.leaves.length;
      }

      expect(meanSpread('v1.vertical'), lessThan(meanSpread('v1.balanced')));
      expect(meanSpread('v1.balanced'), lessThan(meanSpread('v1.broad')));
    });

    test('maturity is passed through for the flourish', () {
      final mature = PlantLayout.compute(
        state(
          height: GrowthConstants.maxHeight,
          branches: GrowthConstants.maxBranches,
          leaves: GrowthConstants.maxLeaves,
          decorations: GrowthConstants.maxDecorations,
        ),
        canvas,
      );
      expect(mature.mature, isTrue);
      expect(PlantLayout.compute(state(), canvas).mature, isFalse);
    });

    test('the empty seed plant has a visible sprout and no elements', () {
      final layout = PlantLayout.compute(
        PlantState(
          effectiveHeight: GrowthConstants.seedHeight,
          branches: const [],
          leaves: const [],
          decorations: const [],
          eventCount: 0,
          newestEventDate: null,
        ),
        canvas,
      );

      expect(layout.trunkBase.dy - layout.trunkTop.dy, greaterThan(0));
      expect(layout.branches, isEmpty);
      expect(layout.leaves, isEmpty);
      expect(layout.decorations, isEmpty);
    });
  });
}
