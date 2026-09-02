import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../application/load_companion.dart';
import '../app_providers.dart';
import '../check_in/check_in_flow.dart';
import '../plant/plant_view.dart';
import '../theme/app_theme.dart';
import '../theme/mood_glyph.dart';
import 'date_line.dart';
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

    void startFlow() {
      ref.read(checkInFlowProvider.notifier).start();
      context.go('/check-in/capture');
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            clampedDisplay(child: const Text('ROOTS', style: wordmarkStyle)),
            const Spacer(),
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
        const SizedBox(height: AppTokens.spacing * 2),
        Expanded(
          child: PlantView(plant: companion.plant, animate: justSaved),
        ),
        const SizedBox(height: AppTokens.spacing * 5),
        // Design 3: eyebrow + heavy left-aligned display headline + support.
        if (isEmpty) ...[
          clampedDisplay(
            child: Text(
              dateLine(companion.todayLocalDate),
              style: eyebrowStyle,
            ),
          ),
          const SizedBox(height: AppTokens.spacing * 2),
          clampedDisplay(
            child: const Text('GROW SOMETHING PERSONAL', style: displayStyle),
          ),
          const SizedBox(height: AppTokens.spacing * 2),
          Text(
            'One private check-in can add to your plant each day.',
            style: textTheme.bodyMedium?.copyWith(
              color: AppTokens.textSecondary,
            ),
          ),
        ] else if (companion.plant.isMature && completedToday) ...[
          clampedDisplay(
            child: Text(
              dateLine(companion.todayLocalDate),
              style: eyebrowStyle,
            ),
          ),
          const SizedBox(height: AppTokens.spacing * 2),
          clampedDisplay(
            child: const Text('YOUR PLANT IS FULLY GROWN', style: displayStyle),
          ),
          const SizedBox(height: AppTokens.spacing * 2),
          Text(
            'Today\'s reflection has been saved to its story.',
            style: textTheme.bodyMedium?.copyWith(
              color: AppTokens.textSecondary,
            ),
          ),
        ] else if (completedToday && todayEvent != null) ...[
          // Delta-derived headline (ADR 0006 #7): never claims growth the
          // stored delta lacks.
          MoodTag(
            mood: todayEvent.mood,
            text: 'Today · ${todayEvent.mood.label} · saved',
          ),
          const SizedBox(height: AppTokens.spacing * 2),
          clampedDisplay(
            child: Text(
              growthHeadline(todayEvent.growthDelta).toUpperCase(),
              style: displayStyle,
            ),
          ),
          const SizedBox(height: AppTokens.spacing * 2),
          Text(
            'Come back tomorrow, or don\'t. It keeps.',
            style: textTheme.bodySmall?.copyWith(
              color: AppTokens.textSecondary,
            ),
          ),
        ] else ...[
          clampedDisplay(
            child: Text(
              dateLine(companion.todayLocalDate),
              style: eyebrowStyle,
            ),
          ),
          const SizedBox(height: AppTokens.spacing * 2),
          clampedDisplay(
            child: const Text(
              'READY FOR TODAY\'S REFLECTION',
              style: displayStyle,
            ),
          ),
        ],
        const SizedBox(height: AppTokens.spacing * 5),
        if (completedToday)
          OutlinedButton(
            onPressed: startFlow,
            child: const Text('REVIEW TODAY\'S CHECK-IN'),
          )
        else
          FilledButton(
            onPressed: startFlow,
            child: const Text('TAKE TODAY\'S SELFIE'),
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
