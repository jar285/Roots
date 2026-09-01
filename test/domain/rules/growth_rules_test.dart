import 'package:flutter_test/flutter_test.dart';

import 'package:roots/domain/model/mood.dart';
import 'package:roots/domain/model/time_category.dart';
import 'package:roots/domain/rng/seeded_prng.dart';
import 'package:roots/domain/rules/growth_rules.dart';

void main() {
  group('GrowthRules.resolve — spec Appendix A.3 worked examples', () {
    // (time, mood) -> height, branches, leaves, decorations, spread,
    // vertical, spiral — copied verbatim from the spec table.
    final cases = [
      (TimeCategory.morning, Mood.happy, 15, 1, 4, 2, 0.5, true, false),
      (TimeCategory.morning, Mood.energetic, 23, 3, 2, 1, 0.8, true, false),
      (TimeCategory.afternoon, Mood.calm, 10, 2, 5, 0, 0.3, false, false),
      (TimeCategory.evening, Mood.happy, 10, 1, 4, 3, 0.4, false, false),
      (TimeCategory.night, Mood.mysterious, 10, 2, 2, 1, 0.6, false, true),
    ];

    for (final c in cases) {
      test('${c.$1.name} + ${c.$2.name}', () {
        final delta = GrowthRules.resolve(
          timeCategory: c.$1,
          mood: c.$2,
          seed: 12345,
        );

        expect(delta.heightIncrease, c.$3, reason: 'height');
        expect(delta.branchIncrease, c.$4, reason: 'branches');
        expect(delta.leafIncrease, c.$5, reason: 'leaves');
        expect(delta.decorationIncrease, c.$6, reason: 'decorations');
        expect(delta.spreadFactor, closeTo(c.$7, 1e-9), reason: 'spread');
        expect(delta.prefersVertical, c.$8, reason: 'vertical');
        expect(delta.prefersSpiral, c.$9, reason: 'spiral');
      });
    }
  });

  group('GrowthRules.resolve — silly mood (ADR 0002 semantics)', () {
    test(
      'matches the locked seeded call order on top of the time modifier',
      () {
        const seed = 424242;
        final delta = GrowthRules.resolve(
          timeCategory: TimeCategory.afternoon,
          mood: Mood.silly,
          seed: seed,
        );

        // Reference roll in the locked order: height nextInt(15),
        // branches nextInt(3), leaves nextInt(4), decorations nextInt(2),
        // spread nextDouble() — additions on afternoon's base
        // (h 10, b 2, l 4, d 0), spread replaced by the roll.
        final reference = SeededPrng(seed);
        final expectedHeight = 10 + reference.nextInt(15);
        final expectedBranches = 2 + reference.nextInt(3);
        final expectedLeaves = 4 + reference.nextInt(4);
        final expectedDecorations = 0 + reference.nextInt(2);
        final expectedSpread = reference.nextDouble();

        expect(delta.heightIncrease, expectedHeight);
        expect(delta.branchIncrease, expectedBranches);
        expect(delta.leafIncrease, expectedLeaves);
        expect(delta.decorationIncrease, expectedDecorations);
        expect(delta.spreadFactor, closeTo(expectedSpread, 1e-12));
      },
    );

    test('same seed resolves the same delta; different seeds may differ', () {
      final a = GrowthRules.resolve(
        timeCategory: TimeCategory.night,
        mood: Mood.silly,
        seed: 7,
      );
      final b = GrowthRules.resolve(
        timeCategory: TimeCategory.night,
        mood: Mood.silly,
        seed: 7,
      );
      expect(a, b);

      final deltas = List.generate(
        20,
        (i) => GrowthRules.resolve(
          timeCategory: TimeCategory.night,
          mood: Mood.silly,
          seed: 1000 + i,
        ),
      );
      expect(deltas.toSet().length, greaterThan(1));
    });

    test('non-silly moods ignore the seed entirely', () {
      final a = GrowthRules.resolve(
        timeCategory: TimeCategory.morning,
        mood: Mood.calm,
        seed: 1,
      );
      final b = GrowthRules.resolve(
        timeCategory: TimeCategory.morning,
        mood: Mood.calm,
        seed: 999999,
      );
      expect(a, b);
    });
  });

  group('GrowthRules identifiers (ADR 0002)', () {
    test('palette id derives from the mood', () {
      for (final mood in Mood.values) {
        final delta = GrowthRules.resolve(
          timeCategory: TimeCategory.afternoon,
          mood: mood,
          seed: 3,
        );
        expect(delta.paletteId, 'v1.${mood.name}');
      }
    });

    test('morphology id follows vertical > spiral > spread precedence', () {
      expect(
        GrowthRules.morphologyId(vertical: true, spiral: true, spread: 0.9),
        'v1.vertical',
      );
      expect(
        GrowthRules.morphologyId(vertical: false, spiral: true, spread: 0.9),
        'v1.spiral',
      );
      expect(
        GrowthRules.morphologyId(vertical: false, spiral: false, spread: 0.4),
        'v1.compact',
      );
      expect(
        GrowthRules.morphologyId(vertical: false, spiral: false, spread: 0.6),
        'v1.broad',
      );
      expect(
        GrowthRules.morphologyId(vertical: false, spiral: false, spread: 0.5),
        'v1.balanced',
      );
    });

    test('resolve wires morphology from the resolved delta', () {
      final vertical = GrowthRules.resolve(
        timeCategory: TimeCategory.morning,
        mood: Mood.happy,
        seed: 3,
      );
      expect(vertical.morphologyId, 'v1.vertical');

      final spiral = GrowthRules.resolve(
        timeCategory: TimeCategory.night,
        mood: Mood.mysterious,
        seed: 3,
      );
      expect(spiral.morphologyId, 'v1.spiral');

      final compact = GrowthRules.resolve(
        timeCategory: TimeCategory.afternoon,
        mood: Mood.calm,
        seed: 3,
      );
      expect(compact.morphologyId, 'v1.compact');

      final broad = GrowthRules.resolve(
        timeCategory: TimeCategory.afternoon,
        mood: Mood.energetic,
        seed: 3,
      );
      expect(broad.morphologyId, 'v1.broad');
    });
  });
}
