import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:roots/presentation/theme/app_theme.dart';

/// WCAG relative luminance.
double _luminance(Color color) {
  double channel(double c) =>
      c <= 0.03928 ? c / 12.92 : math.pow((c + 0.055) / 1.055, 2.4).toDouble();
  return 0.2126 * channel(color.r) +
      0.7152 * channel(color.g) +
      0.0722 * channel(color.b);
}

double contrastRatio(Color a, Color b) {
  final la = _luminance(a);
  final lb = _luminance(b);
  final lighter = math.max(la, lb);
  final darker = math.min(la, lb);
  return (lighter + 0.05) / (darker + 0.05);
}

void main() {
  group('WCAG AA contrast on the token pairs actually rendered together '
      '(spec A.5: verified from component pairs)', () {
    final textPairs = <String, (Color, Color)>{
      'primary text on background': (
        AppTokens.textPrimary,
        AppTokens.background,
      ),
      'primary text on surface': (AppTokens.textPrimary, AppTokens.surface),
      'primary text on raised surface': (
        AppTokens.textPrimary,
        AppTokens.surfaceRaised,
      ),
      'secondary text on background': (
        AppTokens.textSecondary,
        AppTokens.background,
      ),
      'secondary text on surface': (AppTokens.textSecondary, AppTokens.surface),
      'button label on plant green (filled CTA)': (
        AppTokens.background,
        AppTokens.plantGreen,
      ),
      'destructive text on background': (
        AppTokens.destructive,
        AppTokens.background,
      ),
      'destructive text on raised surface (dialogs)': (
        AppTokens.destructive,
        AppTokens.surfaceRaised,
      ),
      'warning text on background': (AppTokens.warning, AppTokens.background),
      'focus accent on raised surface': (
        AppTokens.focus,
        AppTokens.surfaceRaised,
      ),
    };

    for (final entry in textPairs.entries) {
      test('${entry.key} is at least 4.5:1', () {
        final ratio = contrastRatio(entry.value.$1, entry.value.$2);
        expect(
          ratio,
          greaterThanOrEqualTo(4.5),
          reason: '${entry.key}: ${ratio.toStringAsFixed(2)}:1 fails WCAG AA',
        );
      });
    }
  });
}
