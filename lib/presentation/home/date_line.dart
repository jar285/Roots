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
