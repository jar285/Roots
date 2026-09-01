import '../model/growth_delta.dart';
import '../model/mood.dart';
import '../model/time_category.dart';
import '../rng/seeded_prng.dart';

/// Algorithm-version-1 growth rules (spec Appendix A.3, ADR 0002).
///
/// Pure: the resolved delta is a function of (timeCategory, mood, seed).
/// The pipeline is base → time modifier → mood modifier → normalization.
/// Only the silly mood consumes the seed, in a locked call order.
class GrowthRules {
  const GrowthRules._();

  static GrowthDelta resolve({
    required TimeCategory timeCategory,
    required Mood mood,
    required int seed,
  }) {
    // Base (spec A.3).
    var height = 10;
    var branches = 1;
    var leaves = 2;
    var decorations = 0;
    var spread = 0.5;
    var vertical = false;
    var spiral = false;

    // Time modifier: may set decorations/spread, add counts, set flags.
    switch (timeCategory) {
      case TimeCategory.morning:
        height += 5;
        decorations = 1;
        vertical = true;
      case TimeCategory.afternoon:
        branches += 1;
        leaves += 2;
        spread = 0.7;
      case TimeCategory.evening:
        decorations = 2;
        spread = 0.4;
      case TimeCategory.night:
        decorations = 1;
        spread = 0.6;
        spiral = true;
    }

    // Mood modifier: adds counts; a mood-defined spread replaces the time
    // spread (derived from the spec's own worked examples — ADR 0002).
    switch (mood) {
      case Mood.happy:
        leaves += 2;
        decorations += 1;
      case Mood.mysterious:
        branches += 1;
        spiral = true;
      case Mood.energetic:
        height += 8;
        branches += 2;
        spread = 0.8;
      case Mood.calm:
        leaves += 1;
        spread = 0.3;
      case Mood.silly:
        // Locked seeded call order (ADR 0002): height, branches, leaves,
        // decorations, then spread. Counts are additions; spread is set.
        final prng = SeededPrng(seed);
        height += prng.nextInt(15);
        branches += prng.nextInt(3);
        leaves += prng.nextInt(4);
        decorations += prng.nextInt(2);
        spread = prng.nextDouble();
    }

    return GrowthDelta.normalized(
      heightIncrease: height,
      branchIncrease: branches,
      leafIncrease: leaves,
      decorationIncrease: decorations,
      spreadFactor: spread,
      prefersVertical: vertical,
      prefersSpiral: spiral,
      paletteId: 'v1.${mood.name}',
      morphologyId: morphologyId(
        vertical: vertical,
        spiral: spiral,
        spread: spread,
      ),
    );
  }

  /// Deterministic precedence: vertical > spiral > spread buckets
  /// (≤ 0.4 compact, ≥ 0.6 broad, otherwise balanced). ADR 0002.
  static String morphologyId({
    required bool vertical,
    required bool spiral,
    required double spread,
  }) {
    if (vertical) return 'v1.vertical';
    if (spiral) return 'v1.spiral';
    if (spread <= 0.4) return 'v1.compact';
    if (spread >= 0.6) return 'v1.broad';
    return 'v1.balanced';
  }
}
