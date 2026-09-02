import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../domain/model/mood.dart';
import '../theme/app_theme.dart';
import '../theme/mood_glyph.dart';
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
                    child: GridView.count(
                      crossAxisCount: 2,
                      mainAxisSpacing: AppTokens.spacing * 3,
                      crossAxisSpacing: AppTokens.spacing * 3,
                      childAspectRatio: 1.7,
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

    // Announces label, supporting phrase, and selection (UI/UX philosophy);
    // the card shows glyph + label (Design 3 grid, ADR 0006 #4).
    return Semantics(
      label: '${mood.label}. ${mood.supportingCopy}.',
      selected: selected,
      button: true,
      child: Material(
        color: selected ? AppTokens.surfaceRaised : AppTokens.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTokens.radius),
          side: selected
              ? const BorderSide(color: AppTokens.plantGreen, width: 2)
              : BorderSide.none,
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(AppTokens.radius),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(AppTokens.spacing * 4),
            child: Stack(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    MoodGlyph(mood: mood, size: 18),
                    const Spacer(),
                    ExcludeSemantics(
                      child: Text(mood.label, style: textTheme.bodyLarge),
                    ),
                  ],
                ),
                if (selected)
                  const Align(
                    alignment: Alignment.topRight,
                    child: Icon(Icons.check, color: AppTokens.plantGreen),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
