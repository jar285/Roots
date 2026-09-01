import 'package:flutter_test/flutter_test.dart';

import 'package:roots/domain/model/growth_delta.dart';
import 'package:roots/domain/model/growth_event.dart';
import 'package:roots/domain/model/mood.dart';
import 'package:roots/domain/model/time_category.dart';

GrowthEvent build({String id = 'e1', int seed = 7}) {
  return GrowthEvent(
    id: id,
    installationId: 'install-1',
    localDate: '2026-09-01',
    checkedInAtUtc: DateTime.utc(2026, 9, 1, 8, 30),
    timezoneOffsetMinutes: -240,
    timeCategory: TimeCategory.morning,
    mood: Mood.happy,
    selfieFileName: '$id.jpg',
    randomSeed: seed,
    algorithmVersion: 1,
    growthDelta: const GrowthDelta(
      heightIncrease: 15,
      branchIncrease: 1,
      leafIncrease: 4,
      decorationIncrease: 2,
      spreadFactor: 0.5,
      prefersVertical: true,
      prefersSpiral: false,
      paletteId: 'v1.happy',
      morphologyId: 'v1.vertical',
    ),
    createdAtUtc: DateTime.utc(2026, 9, 1, 8, 30),
    updatedAtUtc: DateTime.utc(2026, 9, 1, 8, 30),
  );
}

void main() {
  group('GrowthEvent value equality', () {
    test('identical field values are equal with equal hash codes', () {
      expect(build(), build());
      expect(build().hashCode, build().hashCode);
    });

    test('any differing field breaks equality', () {
      expect(build(id: 'other'), isNot(build()));
      expect(build(seed: 8), isNot(build()));
    });
  });
}
