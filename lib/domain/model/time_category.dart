/// Time-of-day category derived from the local hour at confirmation.
///
/// Spec Appendix A.1: morning 05:00–11:59, afternoon 12:00–16:59,
/// evening 17:00–20:59, night 21:00–04:59.
enum TimeCategory {
  morning,
  afternoon,
  evening,
  night;

  static TimeCategory fromHour(int hour) {
    if (hour < 0 || hour > 23) {
      throw ArgumentError.value(hour, 'hour', 'must be 0–23');
    }
    if (hour >= 5 && hour <= 11) return TimeCategory.morning;
    if (hour >= 12 && hour <= 16) return TimeCategory.afternoon;
    if (hour >= 17 && hour <= 20) return TimeCategory.evening;
    return TimeCategory.night;
  }
}
