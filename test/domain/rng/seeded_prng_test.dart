import 'package:flutter_test/flutter_test.dart';

import 'package:roots/domain/rng/seeded_prng.dart';

void main() {
  group('SeededPrng', () {
    test('same seed replays the same sequence', () {
      final a = SeededPrng(20260901);
      final b = SeededPrng(20260901);

      final fromA = [
        a.nextInt(15),
        a.nextInt(3),
        a.nextInt(4),
        a.nextInt(2),
        a.nextDouble(),
      ];
      final fromB = [
        b.nextInt(15),
        b.nextInt(3),
        b.nextInt(4),
        b.nextInt(2),
        b.nextDouble(),
      ];

      expect(fromA, fromB);
    });

    test('different seeds produce different sequences', () {
      final a = SeededPrng(1);
      final b = SeededPrng(2);

      final fromA = List.generate(8, (_) => a.nextInt(1 << 20));
      final fromB = List.generate(8, (_) => b.nextInt(1 << 20));

      expect(fromA, isNot(fromB));
    });

    test('nextInt stays within [0, max) across many draws', () {
      final prng = SeededPrng(42);
      for (var i = 0; i < 10000; i++) {
        final v = prng.nextInt(15);
        expect(v, inInclusiveRange(0, 14));
      }
    });

    test('nextInt eventually produces every value in a small range', () {
      final prng = SeededPrng(7);
      final seen = <int>{};
      for (var i = 0; i < 1000; i++) {
        seen.add(prng.nextInt(3));
      }
      expect(seen, {0, 1, 2});
    });

    test('nextDouble stays within [0, 1) across many draws', () {
      final prng = SeededPrng(99);
      for (var i = 0; i < 10000; i++) {
        final v = prng.nextDouble();
        expect(v, greaterThanOrEqualTo(0.0));
        expect(v, lessThan(1.0));
      }
    });

    test('seed zero is usable and deterministic', () {
      final a = SeededPrng(0);
      final b = SeededPrng(0);

      final first = a.nextInt(1 << 20);
      expect(first, b.nextInt(1 << 20));
      // xorshift has a zero fixed point; a zero seed must still move.
      expect(
        List.generate(4, (_) => a.nextInt(1 << 20)).toSet().length,
        greaterThan(1),
      );
    });

    test('nextInt rejects non-positive max', () {
      final prng = SeededPrng(5);
      expect(() => prng.nextInt(0), throwsArgumentError);
      expect(() => prng.nextInt(-3), throwsArgumentError);
    });
  });
}
