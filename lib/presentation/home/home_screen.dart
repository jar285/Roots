import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../application/load_companion.dart';
import '../app_providers.dart';
import '../check_in/check_in_flow.dart';
import '../plant/plant_view.dart';
import '../theme/app_theme.dart';
import '../theme/mood_glyph.dart';
import 'growth_headline.dart';

/// Home answers: what has my plant become, and what can I do today?
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final companion = ref.watch(companionProvider);

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: AppTokens.contentMaxWidth,
            ),
            child: Padding(
              padding: const EdgeInsets.all(AppTokens.spacing * 6),
              child: switch (companion) {
                AsyncData(:final value) => _CompanionBody(companion: value),
                AsyncError(:final error) => _LoadError(error: error),
                _ => const Center(child: CircularProgressIndicator()),
              },
            ),
          ),
        ),
      ),
    );
  }
}

class _CompanionBody extends ConsumerWidget {
  const _CompanionBody({required this.companion});

  final LoadedCompanion companion;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isEmpty = companion.plant.eventCount == 0;
    final completedToday = companion.hasCheckedInToday;
    final todayEvent = companion.todayEvent;
    final textTheme = Theme.of(context).textTheme;

    // Consume the one-shot reveal flag (reset outside build).
    final justSaved = ref.read(justSavedProvider);
    if (justSaved) {
      Future.microtask(() => ref.read(justSavedProvider.notifier).consume());
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            TextButton(
              onPressed: () => context.go('/history'),
              child: const Text('HISTORY'),
            ),
            TextButton(
              onPressed: () => context.go('/settings'),
              child: const Text('SETTINGS'),
            ),
          ],
        ),
        Expanded(
          child: PlantView(plant: companion.plant, animate: justSaved),
        ),
        const SizedBox(height: AppTokens.spacing * 4),
        if (isEmpty) ...[
          Text(
            'GROW SOMETHING PERSONAL',
            textAlign: TextAlign.center,
            style: textTheme.titleLarge?.copyWith(letterSpacing: 2),
          ),
          const SizedBox(height: AppTokens.spacing * 2),
          Text(
            'One private check-in can add to your plant each day.',
            textAlign: TextAlign.center,
            style: textTheme.bodyMedium?.copyWith(
              color: AppTokens.textSecondary,
            ),
          ),
        ] else if (companion.plant.isMature && completedToday) ...[
          Text(
            'YOUR PLANT IS FULLY GROWN',
            textAlign: TextAlign.center,
            style: textTheme.titleLarge?.copyWith(letterSpacing: 2),
          ),
          const SizedBox(height: AppTokens.spacing * 2),
          Text(
            'Today\'s reflection has been saved to its story.',
            textAlign: TextAlign.center,
            style: textTheme.bodyMedium?.copyWith(
              color: AppTokens.textSecondary,
            ),
          ),
        ] else if (completedToday && todayEvent != null) ...[
          // Design 3 completed state (ADR 0006 #7): delta-derived headline,
          // calm status, no-pressure support.
          Center(
            child: MoodTag(
              mood: todayEvent.mood,
              text: 'Today · ${todayEvent.mood.label} · saved',
            ),
          ),
          const SizedBox(height: AppTokens.spacing * 2),
          Text(
            growthHeadline(todayEvent.growthDelta),
            textAlign: TextAlign.center,
            style: textTheme.titleLarge?.copyWith(letterSpacing: 1),
          ),
          const SizedBox(height: AppTokens.spacing * 2),
          Text(
            'Come back tomorrow, or don\'t. It keeps.',
            textAlign: TextAlign.center,
            style: textTheme.bodySmall?.copyWith(
              color: AppTokens.textSecondary,
            ),
          ),
        ] else ...[
          Text(
            'Ready for today\'s reflection.',
            textAlign: TextAlign.center,
            style: textTheme.bodyLarge,
          ),
        ],
        const SizedBox(height: AppTokens.spacing * 4),
        FilledButton(
          onPressed: () {
            ref.read(checkInFlowProvider.notifier).start();
            context.go('/check-in/capture');
          },
          child: Text(
            completedToday
                ? 'REVIEW TODAY\'S CHECK-IN'
                : 'TAKE TODAY\'S SELFIE',
          ),
        ),
        const SizedBox(height: AppTokens.spacing * 3),
        Text(
          'Your selfie stays on this device.',
          textAlign: TextAlign.center,
          style: textTheme.bodySmall?.copyWith(color: AppTokens.textSecondary),
        ),
      ],
    );
  }
}

class _LoadError extends ConsumerWidget {
  const _LoadError({required this.error});

  final Object error;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final message = error is UnknownAlgorithmVersionException
        ? 'One of your check-ins was recorded by a newer version of this '
              'app. Update the app to see your full plant.'
        : 'Something went wrong loading your plant. Your check-ins are '
              'still safe on this device.';

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(message, textAlign: TextAlign.center),
        const SizedBox(height: AppTokens.spacing * 4),
        FilledButton(
          onPressed: () => ref.invalidate(companionProvider),
          child: const Text('TRY AGAIN'),
        ),
      ],
    );
  }
}
