import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;

import 'package:roots/domain/model/check_in_moment.dart';
import 'package:roots/infrastructure/simulated_camera_source.dart';

import '../support/fakes.dart';

void main() {
  CheckInMoment moment(int day) => CheckInMoment(
    utcInstant: DateTime.utc(2026, 9, day, 12),
    offsetMinutes: 0,
  );

  test(
    'produces a decodable placeholder photo within the 800px edge limit',
    () async {
      final camera = SimulatedCameraSource(clock: FixedClock(moment(1)));

      final photo = await camera.capture();

      expect(photo, isNotNull);
      final decoded = img.decodeImage(photo!.bytes);
      expect(decoded, isNotNull);
      expect(decoded!.width, lessThanOrEqualTo(800));
      expect(decoded.height, lessThanOrEqualTo(800));
    },
  );

  test('is deterministic for the same local date', () async {
    final camera = SimulatedCameraSource(clock: FixedClock(moment(1)));

    final first = await camera.capture();
    final second = await camera.capture();

    expect(first!.bytes, second!.bytes);
  });

  test('different local dates produce different placeholders', () async {
    final day1 = await SimulatedCameraSource(
      clock: FixedClock(moment(1)),
    ).capture();
    final day2 = await SimulatedCameraSource(
      clock: FixedClock(moment(2)),
    ).capture();

    expect(day1!.bytes, isNot(day2!.bytes));
  });
}
