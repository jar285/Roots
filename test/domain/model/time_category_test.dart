import 'package:flutter_test/flutter_test.dart';

import 'package:roots/domain/model/time_category.dart';

void main() {
  group('TimeCategory.fromHour', () {
    // Spec Appendix A.1: morning 05:00–11:59, afternoon 12:00–16:59,
    // evening 17:00–20:59, night 21:00–04:59. Exhaustive over all 24 hours.
    const expectations = <int, TimeCategory>{
      0: TimeCategory.night,
      1: TimeCategory.night,
      2: TimeCategory.night,
      3: TimeCategory.night,
      4: TimeCategory.night,
      5: TimeCategory.morning,
      6: TimeCategory.morning,
      7: TimeCategory.morning,
      8: TimeCategory.morning,
      9: TimeCategory.morning,
      10: TimeCategory.morning,
      11: TimeCategory.morning,
      12: TimeCategory.afternoon,
      13: TimeCategory.afternoon,
      14: TimeCategory.afternoon,
      15: TimeCategory.afternoon,
      16: TimeCategory.afternoon,
      17: TimeCategory.evening,
      18: TimeCategory.evening,
      19: TimeCategory.evening,
      20: TimeCategory.evening,
      21: TimeCategory.night,
      22: TimeCategory.night,
      23: TimeCategory.night,
    };

    for (final entry in expectations.entries) {
      test('hour ${entry.key} is ${entry.value.name}', () {
        expect(TimeCategory.fromHour(entry.key), entry.value);
      });
    }

    test('rejects out-of-range hours', () {
      expect(() => TimeCategory.fromHour(-1), throwsArgumentError);
      expect(() => TimeCategory.fromHour(24), throwsArgumentError);
    });
  });
}
