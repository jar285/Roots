import 'package:flutter_test/flutter_test.dart';

import 'package:roots/domain/model/growth_event.dart';
import 'package:roots/domain/model/mood.dart';
import 'package:roots/domain/model/time_category.dart';
import 'package:roots/domain/projection/plant_projector.dart';
import 'package:roots/domain/rules/growth_constants.dart';
import 'package:roots/domain/rules/growth_rules.dart';

/// Pacing harness for the spec's maturity validation gate ("simulate and
/// visually review 30, 90, 180, and 365 daily events before locking
/// tuning"). This produces the numbers; the visual review happens at
/// Sprint 5. Deterministic: day N always yields the same event.
GrowthEvent dailyEvent(int dayIndex) {
  final date = DateTime.utc(2026, 1, 1).add(Duration(days: dayIndex));
  final month = date.month.toString().padLeft(2, '0');
  final day = date.day.toString().padLeft(2, '0');
  final localDate = '${date.year}-$month-$day';

  final timeCategory = TimeCategory.values[dayIndex % 4];
  final mood = Mood.values[dayIndex % 5];
  final seed = 1000 + dayIndex;

  final instant = DateTime.utc(date.year, date.month, date.day, 12);
  return GrowthEvent(
    id: 'day-${dayIndex.toString().padLeft(3, '0')}',
    installationId: 'pacing-install',
    localDate: localDate,
    checkedInAtUtc: instant,
    timezoneOffsetMinutes: 0,
    timeCategory: timeCategory,
    mood: mood,
    selfieFileName: 'day-$dayIndex.jpg',
    randomSeed: seed,
    algorithmVersion: 1,
    growthDelta: GrowthRules.resolve(
      timeCategory: timeCategory,
      mood: mood,
      seed: seed,
    ),
    createdAtUtc: instant,
    updatedAtUtc: instant,
  );
}

void main() {
  final registry = ProjectorRegistry.standard();

  PlantState project(List<GrowthEvent> events) {
    final result = registry.project(events);
    expect(result, isA<ProjectionSuccess>());
    return (result as ProjectionSuccess).plantState;
  }

  test('daily use for a year: caps hold, maturity is reached, replay is '
      'stable — stats recorded for the validation gate', () {
    final events = <GrowthEvent>[];
    int? maturityDay;

    for (var day = 0; day < 365; day++) {
      events.add(dailyEvent(day));
      final state = project(events);

      expect(
        state.effectiveHeight,
        lessThanOrEqualTo(GrowthConstants.maxHeight),
      );
      expect(
        state.branches.length,
        lessThanOrEqualTo(GrowthConstants.maxBranches),
      );
      expect(state.leaves.length, lessThanOrEqualTo(GrowthConstants.maxLeaves));
      expect(
        state.decorations.length,
        lessThanOrEqualTo(GrowthConstants.maxDecorations),
      );
      expect(state.eventCount, day + 1);

      if (maturityDay == null && state.isMature) {
        maturityDay = day + 1;
      }

      if (const [30, 90, 180, 365].contains(day + 1)) {
        // ignore: avoid_print — harness output is the deliverable.
        print(
          'day ${day + 1}: height ${state.effectiveHeight}, '
          'branches ${state.branches.length}, '
          'leaves ${state.leaves.length}, '
          'decorations ${state.decorations.length}, '
          'mature ${state.isMature}',
        );
      }
    }

    // ignore: avoid_print
    print('maturity reached on day: $maturityDay');

    expect(
      maturityDay,
      isNotNull,
      reason: 'a year of daily use must reach maturity',
    );

    // Replay stability at scale: a fresh projection of the same year is
    // structurally identical.
    expect(project(events), project(events));
  });

  test('30 days of daily use is not yet mature', () {
    final events = List.generate(30, dailyEvent);
    expect(project(events).isMature, isFalse);
  });
}
