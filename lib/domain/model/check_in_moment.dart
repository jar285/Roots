import 'time_category.dart';

/// One clock reading taken when the user confirms a check-in (spec §4.1).
///
/// `localDate`, the category hour, and the stored timezone offset are all
/// derived from this single UTC instant plus the device's offset at that
/// moment, so the daily rule follows the device's current local calendar.
class CheckInMoment {
  CheckInMoment({required this.utcInstant, required this.offsetMinutes}) {
    if (!utcInstant.isUtc) {
      throw ArgumentError.value(
        utcInstant,
        'utcInstant',
        'must be a UTC DateTime',
      );
    }
  }

  final DateTime utcInstant;
  final int offsetMinutes;

  DateTime get _local => utcInstant.add(Duration(minutes: offsetMinutes));

  /// ISO `yyyy-MM-dd` for the device-local calendar day.
  String get localDate {
    final l = _local;
    final month = l.month.toString().padLeft(2, '0');
    final day = l.day.toString().padLeft(2, '0');
    return '${l.year}-$month-$day';
  }

  int get localHour => _local.hour;

  TimeCategory get timeCategory => TimeCategory.fromHour(localHour);
}
