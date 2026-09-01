import 'package:flutter_test/flutter_test.dart';

import 'package:roots/domain/model/check_in_moment.dart';
import 'package:roots/domain/model/time_category.dart';

void main() {
  group('CheckInMoment', () {
    test('derives local date and hour from one UTC instant plus offset', () {
      final moment = CheckInMoment(
        utcInstant: DateTime.utc(2026, 9, 1, 14, 30),
        offsetMinutes: 0,
      );

      expect(moment.localDate, '2026-09-01');
      expect(moment.localHour, 14);
      expect(moment.timeCategory, TimeCategory.afternoon);
    });

    test('positive offset can roll the local date forward past midnight', () {
      final moment = CheckInMoment(
        utcInstant: DateTime.utc(2026, 9, 1, 23, 30),
        offsetMinutes: 120, // UTC+2
      );

      expect(moment.localDate, '2026-09-02');
      expect(moment.localHour, 1);
      expect(moment.timeCategory, TimeCategory.night);
    });

    test('negative offset can roll the local date backward across a year', () {
      final moment = CheckInMoment(
        utcInstant: DateTime.utc(2026, 1, 1, 1, 0),
        offsetMinutes: -120, // UTC-2
      );

      expect(moment.localDate, '2025-12-31');
      expect(moment.localHour, 23);
      expect(moment.timeCategory, TimeCategory.night);
    });

    test('half-hour offsets are respected', () {
      final moment = CheckInMoment(
        utcInstant: DateTime.utc(2026, 6, 15, 0, 45),
        offsetMinutes: 330, // UTC+5:30
      );

      expect(moment.localDate, '2026-06-15');
      expect(moment.localHour, 6);
      expect(moment.timeCategory, TimeCategory.morning);
    });

    test('local date is zero-padded ISO yyyy-MM-dd', () {
      final moment = CheckInMoment(
        utcInstant: DateTime.utc(2026, 3, 7, 9, 0),
        offsetMinutes: 0,
      );

      expect(moment.localDate, '2026-03-07');
    });

    test('rejects a non-UTC instant', () {
      expect(
        () => CheckInMoment(
          utcInstant: DateTime(2026, 9, 1, 14, 30),
          offsetMinutes: 0,
        ),
        throwsArgumentError,
      );
    });
  });
}
