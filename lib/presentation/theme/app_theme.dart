import 'package:flutter/material.dart';

import '../../domain/model/mood.dart';

/// Dark organic retro tokens (spec A.5, UI/UX philosophy). One ThemeData,
/// one token layer — no second design system.
abstract final class AppTokens {
  static const Color background = Color(0xFF10151C);
  static const Color surface = Color(0xFF18212B);
  static const Color surfaceRaised = Color(0xFF202C38);
  static const Color textPrimary = Color(0xFFF4F7F8);
  static const Color textSecondary = Color(0xFFAEBBC6);
  static const Color plantGreen = Color(0xFF70D6A0);
  static const Color focus = Color(0xFF4CC9F0);
  static const Color warning = Color(0xFFFFD166);
  static const Color destructive = Color(0xFFFF6B6B);

  static const double spacing = 4;
  static const double radius = 12;
  static const double minTouchTarget = 48;
  static const double contentMaxWidth = 720;
}

/// Mood presentation data (spec A.4). Label and supporting copy always
/// accompany the accent — color is never the only signal.
extension MoodDisplay on Mood {
  String get label => switch (this) {
    Mood.happy => 'Happy',
    Mood.mysterious => 'Mysterious',
    Mood.energetic => 'Energetic',
    Mood.calm => 'Calm',
    Mood.silly => 'Silly',
  };

  String get supportingCopy => switch (this) {
    Mood.happy => 'Bright and open',
    Mood.mysterious => 'Quietly strange',
    Mood.energetic => 'Ready to move',
    Mood.calm => 'Slow and steady',
    Mood.silly => 'Playfully unpredictable',
  };

  Color get accent => switch (this) {
    Mood.happy => const Color(0xFFFFD166),
    Mood.mysterious => const Color(0xFF9B5DE5),
    Mood.energetic => const Color(0xFFF15BB5),
    Mood.calm => const Color(0xFF70D6A0),
    Mood.silly => const Color(0xFF4CC9F0),
  };
}

/// Accent for an event-scoped palette id (`v1.<mood>`); unknown ids fall
/// back to the botanical baseline so old data never fails to render.
Color paletteAccent(String paletteId) {
  final name = paletteId.split('.').last;
  final mood = Mood.values.asNameMap()[name];
  return mood?.accent ?? AppTokens.plantGreen;
}

/// Design 3 typographic voice: short ritual headlines are big, heavy, and
/// left-aligned; eyebrows are small letterspaced caps. Body copy everywhere
/// else stays sentence case (UI/UX philosophy).
const TextStyle displayStyle = TextStyle(
  fontSize: 30,
  fontWeight: FontWeight.w800,
  height: 1.12,
  letterSpacing: 0.3,
  color: AppTokens.textPrimary,
);

const TextStyle eyebrowStyle = TextStyle(
  fontSize: 12,
  fontWeight: FontWeight.w600,
  letterSpacing: 2.4,
  color: AppTokens.textSecondary,
);

const TextStyle wordmarkStyle = TextStyle(
  fontSize: 13,
  fontWeight: FontWeight.w700,
  letterSpacing: 4,
  color: AppTokens.textPrimary,
);

/// Display headlines are already large; they scale up to 1.4× so 200% body
/// text never pushes the ritual off screen (WCAG 1.4.4 targets body text —
/// controls and copy keep the full user scale).
Widget clampedDisplay({required Widget child}) {
  return Builder(
    builder: (context) =>
        MediaQuery.withClampedTextScaling(maxScaleFactor: 1.4, child: child),
  );
}

ThemeData buildAppTheme() {
  final base = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: AppTokens.background,
    colorScheme: const ColorScheme.dark(
      surface: AppTokens.surface,
      onSurface: AppTokens.textPrimary,
      primary: AppTokens.plantGreen,
      onPrimary: AppTokens.background,
      secondary: AppTokens.focus,
      error: AppTokens.destructive,
    ),
  );

  return base.copyWith(
    textTheme: base.textTheme.apply(
      bodyColor: AppTokens.textPrimary,
      displayColor: AppTokens.textPrimary,
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        minimumSize: const Size.fromHeight(AppTokens.minTouchTarget + 6),
        shape: const StadiumBorder(),
        textStyle: base.textTheme.labelLarge?.copyWith(
          fontWeight: FontWeight.w700,
          letterSpacing: 1.4,
        ),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        minimumSize: const Size.fromHeight(AppTokens.minTouchTarget + 6),
        shape: const StadiumBorder(),
        foregroundColor: AppTokens.textPrimary,
        side: BorderSide(
          color: AppTokens.textPrimary.withValues(alpha: 0.55),
          width: 1.2,
        ),
        textStyle: base.textTheme.labelLarge?.copyWith(
          fontWeight: FontWeight.w700,
          letterSpacing: 1.4,
        ),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        minimumSize: const Size(
          AppTokens.minTouchTarget,
          AppTokens.minTouchTarget,
        ),
        foregroundColor: AppTokens.textSecondary,
        textStyle: base.textTheme.labelLarge?.copyWith(
          fontWeight: FontWeight.w600,
          letterSpacing: 1.4,
          fontSize: 12,
        ),
      ),
    ),
  );
}
