import '../model/growth_event.dart';

/// Canonical projection order (spec §4.4): localDate ascending, then
/// checkedInAtUtc ascending, then id ascending as a stable tie-breaker.
int compareForProjection(GrowthEvent a, GrowthEvent b) {
  final byDate = a.localDate.compareTo(b.localDate);
  if (byDate != 0) return byDate;
  final byInstant = a.checkedInAtUtc.compareTo(b.checkedInAtUtc);
  if (byInstant != 0) return byInstant;
  return a.id.compareTo(b.id);
}

/// Returns a new list in canonical projection order; the input is untouched.
List<GrowthEvent> inProjectionOrder(Iterable<GrowthEvent> events) {
  return [...events]..sort(compareForProjection);
}
