import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../domain/model/growth_event.dart';
import '../app_providers.dart';
import '../home/date_line.dart';
import '../theme/app_theme.dart';
import '../theme/mood_glyph.dart';

/// History answers: what have I recorded? A personal archive, newest first —
/// never a metric dashboard (spec §6.5).
class HistoryScreen extends ConsumerWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final history = ref.watch(historyProvider);

    return Scaffold(
      // context.go() replaces the stack, so back must be explicit.
      appBar: AppBar(
        backgroundColor: AppTokens.background,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          tooltip: 'Back',
          onPressed: () => context.go('/'),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: AppTokens.contentMaxWidth,
            ),
            child: switch (history) {
              AsyncData(:final value) when value.isEmpty => const Center(
                child: Padding(
                  padding: EdgeInsets.all(AppTokens.spacing * 6),
                  child: Text(
                    'Completed check-ins will appear here.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: AppTokens.textSecondary),
                  ),
                ),
              ),
              AsyncData(:final value) => ListView.builder(
                padding: const EdgeInsets.all(AppTokens.spacing * 4),
                itemCount: value.length + 1,
                itemBuilder: (context, index) {
                  if (index == 0) {
                    final count = value.length == 1
                        ? '1 CHECK-IN'
                        : '${value.length} CHECK-INS';
                    return Padding(
                      padding: const EdgeInsets.only(
                        bottom: AppTokens.spacing * 5,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          clampedDisplay(
                            child: const Text('HISTORY', style: displayStyle),
                          ),
                          const SizedBox(height: AppTokens.spacing * 2),
                          clampedDisplay(
                            child: Text(
                              '$count · KEPT ON THIS DEVICE',
                              style: eyebrowStyle,
                            ),
                          ),
                        ],
                      ),
                    );
                  }
                  return _HistoryRow(event: value[index - 1]);
                },
              ),
              AsyncError() => Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('Something went wrong loading your history.'),
                    const SizedBox(height: AppTokens.spacing * 4),
                    FilledButton(
                      onPressed: () => ref.invalidate(historyProvider),
                      child: const Text('TRY AGAIN'),
                    ),
                  ],
                ),
              ),
              _ => const Center(child: CircularProgressIndicator()),
            },
          ),
        ),
      ),
    );
  }
}

class _HistoryRow extends ConsumerWidget {
  const _HistoryRow({required this.event});

  final GrowthEvent event;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final todayIso = switch (ref.watch(companionProvider)) {
      AsyncData(:final value) => value.todayLocalDate,
      _ => ref.read(clockProvider).now().localDate,
    };
    final metadata =
        '${compactDate(event.localDate, todayIso: todayIso)} · '
        '${event.timeCategory.name.toUpperCase()}';

    return Padding(
      padding: const EdgeInsets.only(bottom: AppTokens.spacing * 2),
      child: Material(
        color: AppTokens.surface,
        borderRadius: BorderRadius.circular(AppTokens.radius),
        child: InkWell(
          borderRadius: BorderRadius.circular(AppTokens.radius),
          onTap: () => context.go('/history/${event.id}'),
          // Row-level photo lookup so a missing photo can be explained
          // inline (spec A.7), matching Design 3's expanded row.
          child: FutureBuilder(
            future: ref
                .watch(mediaStoreProvider)
                .readManagedPhoto(event.selfieFileName),
            builder: (context, snapshot) {
              final bytes = snapshot.data;
              final missing =
                  snapshot.connectionState == ConnectionState.done &&
                  bytes == null;

              return IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Mood-accent edge strip (Design 3 card, ADR 0006 #5).
                    Container(
                      width: 4,
                      decoration: BoxDecoration(
                        color: event.mood.accent,
                        borderRadius: const BorderRadius.horizontal(
                          left: Radius.circular(AppTokens.radius),
                        ),
                      ),
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppTokens.spacing * 3,
                          vertical: AppTokens.spacing * 2.5,
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Design 3: mood leads in bold + glyph.
                                  Row(
                                    children: [
                                      MoodGlyph(mood: event.mood, size: 15),
                                      const SizedBox(
                                        width: AppTokens.spacing * 2,
                                      ),
                                      Text(
                                        event.mood.label,
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyLarge
                                            ?.copyWith(
                                              fontWeight: FontWeight.w700,
                                            ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: AppTokens.spacing),
                                  Text(
                                    metadata,
                                    style: eyebrowStyle.copyWith(
                                      fontSize: 10.5,
                                      letterSpacing: 1.6,
                                    ),
                                  ),
                                  if (missing) ...[
                                    const SizedBox(
                                      height: AppTokens.spacing * 2,
                                    ),
                                    Text(
                                      'Photo unavailable. Your check-in and '
                                      'growth are still here.',
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodySmall
                                          ?.copyWith(
                                            color: AppTokens.textSecondary,
                                          ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                            const SizedBox(width: AppTokens.spacing * 3),
                            SizedBox(
                              width: 48,
                              height: 48,
                              child: bytes != null
                                  ? ClipRRect(
                                      borderRadius: BorderRadius.circular(
                                        AppTokens.radius / 2,
                                      ),
                                      child: Image.memory(
                                        bytes,
                                        fit: BoxFit.cover,
                                        gaplessPlayback: true,
                                        errorBuilder: (_, _, _) =>
                                            const _DashedPlaceholder(),
                                      ),
                                    )
                                  : const _DashedPlaceholder(),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

/// Design 3's missing-photo thumbnail: a quiet dashed frame with a slash.
class _DashedPlaceholder extends StatelessWidget {
  const _DashedPlaceholder();

  @override
  Widget build(BuildContext context) {
    return CustomPaint(painter: _DashedBorderPainter());
  }
}

class _DashedBorderPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppTokens.textSecondary.withValues(alpha: 0.45)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;
    final rrect = RRect.fromRectAndRadius(
      Offset.zero & size,
      Radius.circular(AppTokens.radius / 2),
    );

    final path = Path()..addRRect(rrect);
    for (final metric in path.computeMetrics()) {
      var distance = 0.0;
      while (distance < metric.length) {
        canvas.drawPath(metric.extractPath(distance, distance + 4), paint);
        distance += 8;
      }
    }

    canvas.drawLine(
      Offset(size.width * 0.3, size.height * 0.7),
      Offset(size.width * 0.7, size.height * 0.3),
      paint,
    );
  }

  @override
  bool shouldRepaint(_DashedBorderPainter oldDelegate) => false;
}

/// Thumbnail or the neutral missing-photo placeholder — absence never hides
/// the check-in (spec §9 resilience).
class EventThumbnail extends ConsumerWidget {
  const EventThumbnail({super.key, required this.event, required this.size});

  final GrowthEvent event;
  final double size;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mediaStore = ref.watch(mediaStoreProvider);

    return ClipRRect(
      borderRadius: BorderRadius.circular(AppTokens.radius / 2),
      child: SizedBox(
        width: size,
        height: size,
        child: FutureBuilder(
          future: mediaStore.readManagedPhoto(event.selfieFileName),
          builder: (context, snapshot) {
            final bytes = snapshot.data;
            if (bytes == null) {
              return const ColoredBox(
                color: AppTokens.surfaceRaised,
                child: Icon(
                  Icons.local_florist_outlined,
                  color: AppTokens.textSecondary,
                ),
              );
            }
            return Image.memory(
              bytes,
              fit: BoxFit.cover,
              gaplessPlayback: true,
              errorBuilder: (_, _, _) => const ColoredBox(
                color: AppTokens.surfaceRaised,
                child: Icon(
                  Icons.local_florist_outlined,
                  color: AppTokens.textSecondary,
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
