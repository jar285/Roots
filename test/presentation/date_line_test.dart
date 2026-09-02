import 'package:flutter_test/flutter_test.dart';

import 'package:roots/presentation/home/date_line.dart';

void main() {
  test('formats an ISO local date as the Design 3 eyebrow', () {
    expect(dateLine('2026-09-01'), 'TUESDAY 1 SEPTEMBER');
    expect(dateLine('2026-09-02'), 'WEDNESDAY 2 SEPTEMBER');
    expect(dateLine('2026-12-25'), 'FRIDAY 25 DECEMBER');
    expect(dateLine('2027-01-03'), 'SUNDAY 3 JANUARY');
  });

  test('falls back to the raw date when parsing fails', () {
    expect(dateLine('not-a-date'), 'NOT-A-DATE');
  });

  group('compactDate (Design 3 history rows)', () {
    const today = '2026-09-02';

    test('today reads as TODAY with its compact date', () {
      expect(compactDate('2026-09-02', todayIso: today), 'TODAY · 2 SEPT');
    });

    test('other days this year read as weekday + compact date', () {
      expect(compactDate('2026-09-01', todayIso: today), 'TUE 1 SEPT');
      expect(compactDate('2026-08-28', todayIso: today), 'FRI 28 AUG');
    });

    test('a different year is stated explicitly', () {
      expect(compactDate('2025-12-25', todayIso: today), 'THU 25 DEC 2025');
    });

    test('falls back to the raw date when parsing fails', () {
      expect(compactDate('garbage', todayIso: today), 'GARBAGE');
    });
  });
}
