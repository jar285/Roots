import 'package:flutter_test/flutter_test.dart';

import 'package:roots/domain/model/growth_delta.dart';
import 'package:roots/domain/model/growth_event.dart';
import 'package:roots/domain/model/mood.dart';
import 'package:roots/domain/model/time_category.dart';
import 'package:roots/domain/projection/event_order.dart';

GrowthEvent event({
  required String id,
  required String localDate,
  DateTime? checkedInAtUtc,
}) {
  final instant = checkedInAtUtc ?? DateTime.utc(2026, 9, 1, 12);
  return GrowthEvent(
    id: id,
    installationId: 'install-1',
    localDate: localDate,
    checkedInAtUtc: instant,
    timezoneOffsetMinutes: 0,
    timeCategory: TimeCategory.afternoon,
    mood: Mood.calm,
    selfieFileName: '$id.jpg',
    randomSeed: 1,
    algorithmVersion: 1,
    growthDelta: const GrowthDelta(
      heightIncrease: 10,
      branchIncrease: 1,
      leafIncrease: 2,
      decorationIncrease: 0,
      spreadFactor: 0.5,
      prefersVertical: false,
      prefersSpiral: false,
      paletteId: 'v1.calm',
      morphologyId: 'v1.balanced',
    ),
    createdAtUtc: instant,
    updatedAtUtc: instant,
  );
}

void main() {
  group('projection ordering (spec §4.4)', () {
    test('orders by localDate ascending first', () {
      final later = event(id: 'a', localDate: '2026-09-02');
      final earlier = event(
        id: 'b',
        localDate: '2026-09-01',
        // Later instant on the earlier date must not win.
        checkedInAtUtc: DateTime.utc(2026, 9, 2, 23),
      );

      final ordered = inProjectionOrder([later, earlier]);

      expect(ordered.map((e) => e.id), ['b', 'a']);
    });

    test('breaks localDate ties by checkedInAtUtc ascending', () {
      final second = event(
        id: 'a',
        localDate: '2026-09-01',
        checkedInAtUtc: DateTime.utc(2026, 9, 1, 18),
      );
      final first = event(
        id: 'b',
        localDate: '2026-09-01',
        checkedInAtUtc: DateTime.utc(2026, 9, 1, 9),
      );

      final ordered = inProjectionOrder([second, first]);

      expect(ordered.map((e) => e.id), ['b', 'a']);
    });

    test('breaks full ties by id ascending', () {
      final instant = DateTime.utc(2026, 9, 1, 9);
      final z = event(
        id: 'z',
        localDate: '2026-09-01',
        checkedInAtUtc: instant,
      );
      final a = event(
        id: 'a',
        localDate: '2026-09-01',
        checkedInAtUtc: instant,
      );

      final ordered = inProjectionOrder([z, a]);

      expect(ordered.map((e) => e.id), ['a', 'z']);
    });

    test('any input permutation produces the same canonical order', () {
      final events = [
        event(id: 'c', localDate: '2026-09-03'),
        event(
          id: 'a',
          localDate: '2026-09-01',
          checkedInAtUtc: DateTime.utc(2026, 9, 1, 8),
        ),
        event(
          id: 'b',
          localDate: '2026-09-01',
          checkedInAtUtc: DateTime.utc(2026, 9, 1, 20),
        ),
        event(id: 'd', localDate: '2026-09-04'),
      ];
      final canonical = inProjectionOrder(events).map((e) => e.id).toList();

      for (var i = 0; i < 10; i++) {
        final shuffled = [...events]..shuffle();
        expect(
          inProjectionOrder(shuffled).map((e) => e.id).toList(),
          canonical,
        );
      }
    });

    test('does not mutate its input', () {
      final events = [
        event(id: 'b', localDate: '2026-09-02'),
        event(id: 'a', localDate: '2026-09-01'),
      ];

      inProjectionOrder(events);

      expect(events.map((e) => e.id), ['b', 'a']);
    });
  });
}
