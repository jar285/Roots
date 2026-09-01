import '../contracts/clock.dart';
import '../domain/model/check_in_moment.dart';

/// Production clock: one reading of the device's current instant and its
/// current UTC offset — the daily rule follows the device's local calendar.
class SystemClock implements Clock {
  const SystemClock();

  @override
  CheckInMoment now() {
    final local = DateTime.now();
    return CheckInMoment(
      utcInstant: local.toUtc(),
      offsetMinutes: local.timeZoneOffset.inMinutes,
    );
  }
}
