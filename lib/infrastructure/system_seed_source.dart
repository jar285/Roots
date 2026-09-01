import 'dart:math' as math;

import '../contracts/seed_source.dart';

/// Production seed source. Nondeterministic by design — the seed VALUE is
/// random, but once stored on the event it replays via the repo-owned PRNG.
class SystemSeedSource implements SeedSource {
  SystemSeedSource() : _random = math.Random();

  final math.Random _random;

  @override
  int nextSeed() => _random.nextInt(1 << 31);
}
