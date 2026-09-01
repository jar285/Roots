import 'package:flutter_test/flutter_test.dart';

import 'package:roots/domain/model/growth_delta.dart';

void main() {
  group('GrowthDelta', () {
    test('supports value equality', () {
      const a = GrowthDelta(
        heightIncrease: 15,
        branchIncrease: 1,
        leafIncrease: 4,
        decorationIncrease: 2,
        spreadFactor: 0.5,
        prefersVertical: true,
        prefersSpiral: false,
        paletteId: 'v1.happy',
        morphologyId: 'v1.vertical',
      );
      const b = GrowthDelta(
        heightIncrease: 15,
        branchIncrease: 1,
        leafIncrease: 4,
        decorationIncrease: 2,
        spreadFactor: 0.5,
        prefersVertical: true,
        prefersSpiral: false,
        paletteId: 'v1.happy',
        morphologyId: 'v1.vertical',
      );

      expect(a, b);
      expect(a.hashCode, b.hashCode);
      expect(a, isNot(b.copyWith(heightIncrease: 16)));
    });

    test('normalized clamps counts to zero or more and spread to [0, 1]', () {
      // ADR 0002: delta-level normalization at creation.
      final delta = GrowthDelta.normalized(
        heightIncrease: -5,
        branchIncrease: -1,
        leafIncrease: 3,
        decorationIncrease: -2,
        spreadFactor: 1.7,
        prefersVertical: false,
        prefersSpiral: false,
        paletteId: 'v1.calm',
        morphologyId: 'v1.balanced',
      );

      expect(delta.heightIncrease, 0);
      expect(delta.branchIncrease, 0);
      expect(delta.leafIncrease, 3);
      expect(delta.decorationIncrease, 0);
      expect(delta.spreadFactor, 1.0);

      final low = GrowthDelta.normalized(
        heightIncrease: 10,
        branchIncrease: 1,
        leafIncrease: 2,
        decorationIncrease: 0,
        spreadFactor: -0.3,
        prefersVertical: false,
        prefersSpiral: false,
        paletteId: 'v1.calm',
        morphologyId: 'v1.balanced',
      );
      expect(low.spreadFactor, 0.0);
    });
  });
}
