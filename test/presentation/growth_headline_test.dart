import 'package:flutter_test/flutter_test.dart';

import 'package:roots/domain/model/growth_delta.dart';
import 'package:roots/presentation/home/growth_headline.dart';

GrowthDelta delta({
  int height = 0,
  int branches = 0,
  int leaves = 0,
  int decorations = 0,
}) {
  return GrowthDelta(
    heightIncrease: height,
    branchIncrease: branches,
    leafIncrease: leaves,
    decorationIncrease: decorations,
    spreadFactor: 0.5,
    prefersVertical: false,
    prefersSpiral: false,
    paletteId: 'v1.calm',
    morphologyId: 'v1.balanced',
  );
}

void main() {
  group('growthHeadline derives only from the stored delta (ADR 0006 #7)', () {
    test('leaves lead when present, with honest plurals', () {
      expect(
        growthHeadline(delta(leaves: 1, branches: 2, height: 10)),
        'A new leaf is part of it now.',
      );
      expect(
        growthHeadline(delta(leaves: 4, height: 10)),
        '4 new leaves are part of it now.',
      );
    });

    test('branches speak when there are no leaves', () {
      expect(
        growthHeadline(delta(branches: 1, decorations: 2, height: 10)),
        'A new branch is part of it now.',
      );
      expect(
        growthHeadline(delta(branches: 3)),
        '3 new branches are part of it now.',
      );
    });

    test('decorations speak when there are no leaves or branches', () {
      expect(
        growthHeadline(delta(decorations: 1, height: 8)),
        'A new decoration adorns it now.',
      );
      expect(
        growthHeadline(delta(decorations: 2)),
        '2 new decorations adorn it now.',
      );
    });

    test('height-only days are still honestly celebrated', () {
      expect(
        growthHeadline(delta(height: 12)),
        'It stands a little taller now.',
      );
    });

    test('an all-zero delta never invents growth', () {
      expect(growthHeadline(delta()), 'Today is part of its story now.');
    });
  });
}
