import 'package:flutter_test/flutter_test.dart';

import 'package:roots/domain/model/growth_delta.dart';
import 'package:roots/domain/model/growth_event.dart';
import 'package:roots/domain/model/mood.dart';
import 'package:roots/domain/model/time_category.dart';
import 'package:roots/domain/projection/plant_projector.dart';
import 'package:roots/domain/rules/growth_constants.dart';
import 'package:roots/domain/rules/growth_rules.dart';

GrowthDelta delta({
  int height = 10,
  int branches = 1,
  int leaves = 2,
  int decorations = 0,
  String paletteId = 'v1.calm',
  String morphologyId = 'v1.balanced',
}) {
  return GrowthDelta(
    heightIncrease: height,
    branchIncrease: branches,
    leafIncrease: leaves,
    decorationIncrease: decorations,
    spreadFactor: 0.5,
    prefersVertical: false,
    prefersSpiral: false,
    paletteId: paletteId,
    morphologyId: morphologyId,
  );
}

GrowthEvent event({
  required String id,
  required String localDate,
  required GrowthDelta growthDelta,
  int algorithmVersion = 1,
  Mood mood = Mood.calm,
}) {
  final instant = DateTime.utc(2026, 9, 1, 12);
  return GrowthEvent(
    id: id,
    installationId: 'install-1',
    localDate: localDate,
    checkedInAtUtc: instant,
    timezoneOffsetMinutes: 0,
    timeCategory: TimeCategory.afternoon,
    mood: mood,
    selfieFileName: '$id.jpg',
    randomSeed: 1,
    algorithmVersion: algorithmVersion,
    growthDelta: growthDelta,
    createdAtUtc: instant,
    updatedAtUtc: instant,
  );
}

void main() {
  final registry = ProjectorRegistry.standard();

  PlantState projectOrFail(Iterable<GrowthEvent> events) {
    final result = registry.project(events);
    expect(result, isA<ProjectionSuccess>());
    return (result as ProjectionSuccess).plantState;
  }

  group('empty companion', () {
    test('projects the seed state', () {
      final state = projectOrFail(const []);

      expect(state.effectiveHeight, GrowthConstants.seedHeight);
      expect(state.branches, isEmpty);
      expect(state.leaves, isEmpty);
      expect(state.decorations, isEmpty);
      expect(state.eventCount, 0);
      expect(state.newestEventDate, isNull);
      expect(state.isMature, isFalse);
    });
  });

  group('single event', () {
    test('applies the stored delta and sources every element', () {
      final morningHappy = GrowthRules.resolve(
        timeCategory: TimeCategory.morning,
        mood: Mood.happy,
        seed: 5,
      );
      final state = projectOrFail([
        event(id: 'e1', localDate: '2026-09-01', growthDelta: morningHappy),
      ]);

      expect(state.effectiveHeight, GrowthConstants.seedHeight + 15);
      expect(state.branches, hasLength(1));
      expect(state.leaves, hasLength(4));
      expect(state.decorations, hasLength(2));
      expect(state.eventCount, 1);
      expect(state.newestEventDate, '2026-09-01');

      for (final element in [
        ...state.branches,
        ...state.leaves,
        ...state.decorations,
      ]) {
        expect(element.sourceEventId, 'e1');
        expect(element.paletteId, 'v1.happy');
        expect(element.morphologyId, 'v1.vertical');
      }
    });
  });

  group('deterministic replay (spec §4.4)', () {
    test(
      'same events in any input order project structurally equal states',
      () {
        final events = [
          event(
            id: 'a',
            localDate: '2026-09-01',
            growthDelta: delta(paletteId: 'v1.happy'),
          ),
          event(
            id: 'b',
            localDate: '2026-09-02',
            growthDelta: delta(paletteId: 'v1.silly', branches: 2),
          ),
          event(
            id: 'c',
            localDate: '2026-09-03',
            growthDelta: delta(paletteId: 'v1.calm', decorations: 2),
          ),
        ];

        final canonical = projectOrFail(events);
        final reversed = projectOrFail(events.reversed.toList());
        final shuffled = projectOrFail([events[1], events[2], events[0]]);

        expect(reversed, canonical);
        expect(shuffled, canonical);
        expect(reversed.hashCode, canonical.hashCode);
      },
    );

    test('different event sets project unequal states', () {
      final base = projectOrFail([
        event(id: 'a', localDate: '2026-09-01', growthDelta: delta()),
      ]);
      final other = projectOrFail([
        event(id: 'a', localDate: '2026-09-01', growthDelta: delta(height: 11)),
      ]);

      expect(other, isNot(base));
    });
  });

  group('historical style retention (spec A.6)', () {
    final first = event(
      id: 'day1',
      localDate: '2026-09-01',
      growthDelta: delta(paletteId: 'v1.happy', morphologyId: 'v1.vertical'),
    );

    test('a later event never restyles earlier elements', () {
      final alone = projectOrFail([first]);

      final withSecond = projectOrFail([
        first,
        event(
          id: 'day2',
          localDate: '2026-09-02',
          growthDelta: delta(paletteId: 'v1.energetic'),
        ),
      ]);

      final day1Leaves = withSecond.leaves
          .where((e) => e.sourceEventId == 'day1')
          .toList();
      expect(day1Leaves, alone.leaves);
      for (final element in day1Leaves) {
        expect(element.paletteId, 'v1.happy');
      }
    });

    test('replacing a later event leaves earlier contributions identical', () {
      final secondAsCalm = event(
        id: 'day2',
        localDate: '2026-09-02',
        growthDelta: delta(paletteId: 'v1.calm'),
      );
      final secondAsSilly = event(
        id: 'day2',
        localDate: '2026-09-02',
        growthDelta: delta(paletteId: 'v1.silly', leaves: 3),
      );

      final before = projectOrFail([first, secondAsCalm]);
      final after = projectOrFail([first, secondAsSilly]);

      List<PlantElement> day1Of(PlantState s) => [
        ...s.branches,
        ...s.leaves,
        ...s.decorations,
      ].where((e) => e.sourceEventId == 'day1').toList();

      expect(day1Of(after), day1Of(before));
    });

    test('deleting an event removes exactly its sourced elements', () {
      final second = event(
        id: 'day2',
        localDate: '2026-09-02',
        growthDelta: delta(paletteId: 'v1.mysterious', decorations: 1),
      );

      final both = projectOrFail([first, second]);
      final afterDeletion = projectOrFail([first]);

      expect(both.leaves.where((e) => e.sourceEventId == 'day2'), isNotEmpty);
      expect(
        [
          ...afterDeletion.branches,
          ...afterDeletion.leaves,
          ...afterDeletion.decorations,
        ].where((e) => e.sourceEventId == 'day2'),
        isEmpty,
      );
      expect(afterDeletion, projectOrFail([first]));
    });
  });

  group('caps and maturity (spec §4.7)', () {
    test('geometry is capped at the global maxima', () {
      final oversized = event(
        id: 'huge',
        localDate: '2026-09-01',
        growthDelta: delta(
          height: 9999,
          branches: 999,
          leaves: 999,
          decorations: 999,
        ),
      );

      final state = projectOrFail([oversized]);

      expect(state.effectiveHeight, GrowthConstants.maxHeight);
      expect(state.branches, hasLength(GrowthConstants.maxBranches));
      expect(state.leaves, hasLength(GrowthConstants.maxLeaves));
      expect(state.decorations, hasLength(GrowthConstants.maxDecorations));
      expect(state.isMature, isTrue);
    });

    test('a delta crossing a cap is applied partially up to the cap', () {
      final nearCap = event(
        id: 'near',
        localDate: '2026-09-01',
        growthDelta: delta(leaves: GrowthConstants.maxLeaves - 1),
      );
      final crossing = event(
        id: 'cross',
        localDate: '2026-09-02',
        growthDelta: delta(leaves: 4),
      );

      final state = projectOrFail([nearCap, crossing]);

      expect(state.leaves, hasLength(GrowthConstants.maxLeaves));
      expect(
        state.leaves.where((e) => e.sourceEventId == 'cross'),
        hasLength(1),
      );
    });

    test('maturity requires all four caps', () {
      final tallOnly = event(
        id: 'tall',
        localDate: '2026-09-01',
        growthDelta: delta(height: 9999),
      );

      expect(projectOrFail([tallOnly]).isMature, isFalse);
    });

    test('post-maturity events still count as history without geometry', () {
      final maturing = event(
        id: 'mature',
        localDate: '2026-09-01',
        growthDelta: delta(
          height: 9999,
          branches: 999,
          leaves: 999,
          decorations: 999,
        ),
      );
      final later = event(
        id: 'later',
        localDate: '2026-09-02',
        growthDelta: delta(paletteId: 'v1.happy'),
      );

      final matureState = projectOrFail([maturing]);
      final afterLater = projectOrFail([maturing, later]);

      expect(afterLater.eventCount, 2);
      expect(afterLater.newestEventDate, '2026-09-02');
      expect(afterLater.isMature, isTrue);
      expect(afterLater.effectiveHeight, matureState.effectiveHeight);
      expect(afterLater.branches, matureState.branches);
      expect(afterLater.leaves, matureState.leaves);
      expect(afterLater.decorations, matureState.decorations);
    });
  });

  group('algorithm versioning (spec §4.4)', () {
    test(
      'an unknown version surfaces as a recoverable error, never a guess',
      () {
        final future = event(
          id: 'future',
          localDate: '2026-09-02',
          growthDelta: delta(),
          algorithmVersion: 99,
        );

        final result = registry.project([
          event(id: 'ok', localDate: '2026-09-01', growthDelta: delta()),
          future,
        ]);

        expect(result, isA<UnknownAlgorithmVersion>());
        final failure = result as UnknownAlgorithmVersion;
        expect(failure.algorithmVersion, 99);
        expect(failure.eventId, 'future');
      },
    );

    test('version 1 is registered as the initial algorithm', () {
      expect(GrowthConstants.initialAlgorithmVersion, 1);
      final result = registry.project([
        event(id: 'ok', localDate: '2026-09-01', growthDelta: delta()),
      ]);
      expect(result, isA<ProjectionSuccess>());
    });
  });
}
