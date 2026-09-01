import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../domain/model/mood.dart';
import '../theme/app_theme.dart';
import 'check_in_flow.dart';

/// Mood answers: how do I describe how I feel? Always self-report —
/// label, supporting phrase, and selection state, never color alone.
class MoodScreen extends ConsumerWidget {
  const MoodScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final draft = ref.watch(checkInFlowProvider);

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: AppTokens.contentMaxWidth,
            ),
            child: Padding(
              padding: const EdgeInsets.all(AppTokens.spacing * 6),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'HOW ARE YOU FEELING?',
                    textAlign: TextAlign.center,
                    style: Theme.of(
                      context,
                    ).textTheme.titleLarge?.copyWith(letterSpacing: 2),
                  ),
                  const SizedBox(height: AppTokens.spacing * 4),
                  Expanded(
                    child: ListView(
                      children: [
                        for (final mood in Mood.values)
                          _MoodOption(
                            mood: mood,
                            selected: draft.mood == mood,
                            onTap: () => ref
                                .read(checkInFlowProvider.notifier)
                                .setMood(mood),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppTokens.spacing * 4),
                  FilledButton(
                    onPressed: draft.mood == null
                        ? null
                        : () => context.go('/check-in/confirm'),
                    child: const Text('CONTINUE'),
                  ),
                  const SizedBox(height: AppTokens.spacing * 2),
                  TextButton(
                    onPressed: () => context.go('/check-in/capture'),
                    child: const Text('BACK'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _MoodOption extends StatelessWidget {
  const _MoodOption({
    required this.mood,
    required this.selected,
    required this.onTap,
  });

  final Mood mood;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Semantics(
      selected: selected,
      button: true,
      child: Padding(
        padding: const EdgeInsets.only(bottom: AppTokens.spacing * 2),
        child: Material(
          color: selected ? AppTokens.surfaceRaised : AppTokens.surface,
          borderRadius: BorderRadius.circular(AppTokens.radius),
          child: InkWell(
            borderRadius: BorderRadius.circular(AppTokens.radius),
            onTap: onTap,
            child: Container(
              constraints: const BoxConstraints(
                minHeight: AppTokens.minTouchTarget + 8,
              ),
              padding: const EdgeInsets.symmetric(
                horizontal: AppTokens.spacing * 4,
                vertical: AppTokens.spacing * 3,
              ),
              child: Row(
                children: [
                  Container(
                    width: 14,
                    height: 14,
                    decoration: BoxDecoration(
                      color: mood.accent,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: AppTokens.spacing * 4),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(mood.label, style: textTheme.bodyLarge),
                        Text(
                          mood.supportingCopy,
                          style: textTheme.bodySmall?.copyWith(
                            color: AppTokens.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (selected) const Icon(Icons.check, color: AppTokens.focus),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
