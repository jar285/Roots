/// The Design 3 date eyebrow: "WEDNESDAY 2 SEPTEMBER" from an ISO
/// `yyyy-MM-dd` local date. English-only in Phase 1 (no intl dependency —
/// ADR 0007 #1); falls back to the raw string if parsing fails.
String dateLine(String isoLocalDate) {
  const weekdays = [
    'MONDAY',
    'TUESDAY',
    'WEDNESDAY',
    'THURSDAY',
    'FRIDAY',
    'SATURDAY',
    'SUNDAY',
  ];
  const months = [
    'JANUARY',
    'FEBRUARY',
    'MARCH',
    'APRIL',
    'MAY',
    'JUNE',
    'JULY',
    'AUGUST',
    'SEPTEMBER',
    'OCTOBER',
    'NOVEMBER',
    'DECEMBER',
  ];

  final parsed = DateTime.tryParse(isoLocalDate);
  if (parsed == null) return isoLocalDate.toUpperCase();
  return '${weekdays[parsed.weekday - 1]} ${parsed.day} '
      '${months[parsed.month - 1]}';
}

/// Compact history-row date (Design 3): `TODAY · 2 SEPT`, `TUE 1 SEPT`,
/// `THU 25 DEC 2025` when the year differs from today's. English-only in
/// Phase 1; falls back to the raw string if parsing fails.
String compactDate(String isoLocalDate, {required String todayIso}) {
  const weekdays = ['MON', 'TUE', 'WED', 'THU', 'FRI', 'SAT', 'SUN'];
  const months = [
    'JAN',
    'FEB',
    'MAR',
    'APR',
    'MAY',
    'JUNE',
    'JULY',
    'AUG',
    'SEPT',
    'OCT',
    'NOV',
    'DEC',
  ];

  final parsed = DateTime.tryParse(isoLocalDate);
  if (parsed == null) return isoLocalDate.toUpperCase();

  final dayMonth = '${parsed.day} ${months[parsed.month - 1]}';
  if (isoLocalDate == todayIso) return 'TODAY · $dayMonth';

  final todayYear = DateTime.tryParse(todayIso)?.year;
  final yearSuffix = (todayYear != null && parsed.year != todayYear)
      ? ' ${parsed.year}'
      : '';
  return '${weekdays[parsed.weekday - 1]} $dayMonth$yearSuffix';
}
