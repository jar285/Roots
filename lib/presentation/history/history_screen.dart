import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../domain/model/growth_event.dart';
import '../app_providers.dart';
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
      appBar: AppBar(backgroundColor: AppTokens.background),
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
    return Padding(
      padding: const EdgeInsets.only(bottom: AppTokens.spacing * 2),
      child: Material(
        color: AppTokens.surface,
        borderRadius: BorderRadius.circular(AppTokens.radius),
        child: InkWell(
          borderRadius: BorderRadius.circular(AppTokens.radius),
          onTap: () => context.go('/history/${event.id}'),
          child: Row(
            children: [
              // Mood-accent edge strip (Design 3 card, ADR 0006 #5).
              Container(
                width: 4,
                height: 72,
                decoration: BoxDecoration(
                  color: event.mood.accent,
                  borderRadius: const BorderRadius.horizontal(
                    left: Radius.circular(AppTokens.radius),
                  ),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(AppTokens.spacing * 3),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Design 3: mood leads in bold with its glyph.
                            Row(
                              children: [
                                MoodGlyph(mood: event.mood, size: 15),
                                const SizedBox(width: AppTokens.spacing * 2),
                                Text(
                                  event.mood.label,
                                  style: Theme.of(context).textTheme.bodyLarge
                                      ?.copyWith(fontWeight: FontWeight.w700),
                                ),
                              ],
                            ),
                            const SizedBox(height: AppTokens.spacing),
                            Text(
                              '${event.localDate} · '
                              '${event.timeCategory.name}',
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(color: AppTokens.textSecondary),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: AppTokens.spacing * 3),
                      EventThumbnail(event: event, size: 56),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
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
