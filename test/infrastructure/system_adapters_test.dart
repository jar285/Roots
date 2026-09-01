import 'package:flutter_test/flutter_test.dart';

import 'package:roots/infrastructure/system_clock.dart';
import 'package:roots/infrastructure/system_seed_source.dart';

void main() {
  test('SystemClock reads one UTC instant with the device offset', () {
    final before = DateTime.now().toUtc();
    final moment = const SystemClock().now();
    final after = DateTime.now().toUtc();

    expect(moment.utcInstant.isUtc, isTrue);
    expect(
      moment.utcInstant.isBefore(before.subtract(const Duration(seconds: 5))),
      isFalse,
    );
    expect(
      moment.utcInstant.isAfter(after.add(const Duration(seconds: 5))),
      isFalse,
    );
    expect(moment.offsetMinutes, DateTime.now().timeZoneOffset.inMinutes);
  });

  test('SystemSeedSource produces varying non-negative seeds', () {
    final source = SystemSeedSource();
    final seeds = {for (var i = 0; i < 50; i++) source.nextSeed()};

    expect(seeds.length, greaterThan(1));
    expect(seeds.every((s) => s >= 0), isTrue);
  });
}
