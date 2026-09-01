import '../domain/model/check_in_moment.dart';

/// One injected clock reading (spec §3 guarantee 10): localDate, offset, and
/// time category are all derived from a single [CheckInMoment].
abstract interface class Clock {
  CheckInMoment now();
}
