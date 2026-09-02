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
}
