import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../domain/model/mood.dart';
import 'app_theme.dart';

/// The mood shape system (ADR 0006 #3): every mood has a distinct glyph drawn
/// in its accent, always shown beside its label — mood is never communicated
/// by color alone. Decorative to screen readers; the label text speaks.
class MoodGlyph extends StatelessWidget {
  const MoodGlyph({super.key, required this.mood, this.size = 14});

  final Mood mood;
  final double size;

  @override
  Widget build(BuildContext context) {
    return ExcludeSemantics(
      child: CustomPaint(
        size: Size.square(size),
        painter: _MoodGlyphPainter(mood: mood),
      ),
    );
  }
}

class _MoodGlyphPainter extends CustomPainter {
  const _MoodGlyphPainter({required this.mood});

  final Mood mood;

  @override
  void paint(Canvas canvas, Size size) {
    final accent = mood.accent;
    final center = size.center(Offset.zero);
    final r = size.shortestSide / 2 - 1;

    switch (mood) {
      case Mood.happy: // open circle
        canvas.drawCircle(
          center,
          r,
          Paint()
            ..color = accent
            ..style = PaintingStyle.stroke
            ..strokeWidth = 2,
        );
      case Mood.mysterious: // open diamond
        final path = Path()
          ..moveTo(center.dx, center.dy - r)
          ..lineTo(center.dx + r, center.dy)
          ..lineTo(center.dx, center.dy + r)
          ..lineTo(center.dx - r, center.dy)
          ..close();
        canvas.drawPath(
          path,
          Paint()
            ..color = accent
            ..style = PaintingStyle.stroke
            ..strokeWidth = 2,
        );
      case Mood.energetic: // filled triangle
        final path = Path()
          ..moveTo(center.dx, center.dy - r)
          ..lineTo(center.dx + r, center.dy + r)
          ..lineTo(center.dx - r, center.dy + r)
          ..close();
        canvas.drawPath(path, Paint()..color = accent);
      case Mood.calm: // filled leaf
        final rect = Rect.fromCenter(
          center: center,
          width: r * 1.6,
          height: r * 2.2,
        );
        canvas.save();
        canvas.translate(center.dx, center.dy);
        canvas.rotate(math.pi / 5);
        canvas.translate(-center.dx, -center.dy);
        canvas.drawPath(
          Path()..addRRect(
            RRect.fromRectAndCorners(
              rect,
              topLeft: Radius.circular(r * 1.6),
              bottomRight: Radius.circular(r * 1.6),
              topRight: const Radius.circular(2),
              bottomLeft: const Radius.circular(2),
            ),
          ),
          Paint()..color = accent,
        );
        canvas.restore();
      case Mood.silly: // open square
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromCircle(center: center, radius: r * 0.9),
            const Radius.circular(3),
          ),
          Paint()
            ..color = accent
            ..style = PaintingStyle.stroke
            ..strokeWidth = 2,
        );
    }
  }

  @override
  bool shouldRepaint(_MoodGlyphPainter oldDelegate) => oldDelegate.mood != mood;
}

/// The glyph beside its label — the standard way a mood appears in rows and
/// status lines.
class MoodTag extends StatelessWidget {
  const MoodTag({super.key, required this.mood, required this.text});

  final Mood mood;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        MoodGlyph(mood: mood),
        const SizedBox(width: AppTokens.spacing * 2),
        Flexible(
          child: Text(
            text,
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: AppTokens.textSecondary),
          ),
        ),
      ],
    );
  }
}
