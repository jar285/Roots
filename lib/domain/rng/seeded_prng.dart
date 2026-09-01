/// Deterministic 32-bit xorshift generator owned by this repository.
///
/// A stored `randomSeed` must reproduce the original roll across Dart SDK
/// versions and platforms, so the algorithm is fixed here rather than
/// delegated to `dart:math` (ADR 0002). Replay never re-rolls — deltas are
/// persisted resolved — the seed exists for explainability and tests.
class SeededPrng {
  SeededPrng(int seed) : _state = _normalize(seed);

  static const int _mask32 = 0xFFFFFFFF;

  // xorshift32 has a fixed point at zero; remap a zero (or zero after
  // masking) seed to an arbitrary fixed odd constant.
  static const int _zeroSeedSubstitute = 0x9E3779B9;

  int _state;

  static int _normalize(int seed) {
    final masked = seed & _mask32;
    return masked == 0 ? _zeroSeedSubstitute : masked;
  }

  int _nextRaw() {
    var x = _state;
    x = (x ^ (x << 13)) & _mask32;
    x = (x ^ (x >>> 17)) & _mask32;
    x = (x ^ (x << 5)) & _mask32;
    _state = x;
    return x;
  }

  /// Returns an integer in `[0, max)`.
  int nextInt(int max) {
    if (max <= 0) {
      throw ArgumentError.value(max, 'max', 'must be positive');
    }
    return _nextRaw() % max;
  }

  /// Returns a double in `[0.0, 1.0)`.
  double nextDouble() => _nextRaw() / (_mask32 + 1);
}
