import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../app_providers.dart';
import '../theme/app_theme.dart';
import 'check_in_flow.dart';

/// Confirmation answers: what will be saved and changed? It never shows
/// completed growth before persistence succeeds.
class ConfirmationScreen extends ConsumerStatefulWidget {
  const ConfirmationScreen({super.key});

  @override
  ConsumerState<ConfirmationScreen> createState() => _ConfirmationScreenState();
}

class _ConfirmationScreenState extends ConsumerState<ConfirmationScreen> {
  bool _saving = false;
  bool _saveFailed = false;

  Future<void> _save() async {
    final draft = ref.read(checkInFlowProvider);
    final photo = draft.photo;
    final mood = draft.mood;
    if (photo == null || mood == null) return;

    setState(() {
      _saving = true;
      _saveFailed = false;
    });
    try {
      await ref.read(saveDailyCheckInProvider)(mood: mood, photo: photo.bytes);
      ref.invalidate(companionProvider);
      if (mounted) context.go('/');
    } catch (_) {
      if (mounted) {
        setState(() {
          _saving = false;
          _saveFailed = true;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final draft = ref.watch(checkInFlowProvider);
    final editingToday = switch (ref.watch(companionProvider)) {
      AsyncData(:final value) => value.hasCheckedInToday,
      _ => false,
    };
    final textTheme = Theme.of(context).textTheme;
    final mood = draft.mood;
    final photo = draft.photo;

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
                    editingToday
                        ? 'REVIEW TODAY\'S CHECK-IN'
                        : 'ADD TODAY\'S GROWTH?',
                    textAlign: TextAlign.center,
                    style: textTheme.titleLarge?.copyWith(letterSpacing: 2),
                  ),
                  const SizedBox(height: AppTokens.spacing * 4),
                  Expanded(
                    child: photo == null
                        ? const SizedBox.shrink()
                        : ClipRRect(
                            borderRadius: BorderRadius.circular(
                              AppTokens.radius,
                            ),
                            child: Image.memory(
                              photo.bytes,
                              fit: BoxFit.cover,
                              width: double.infinity,
                              errorBuilder: (_, _, _) => const Center(
                                child: Icon(Icons.image_not_supported),
                              ),
                            ),
                          ),
                  ),
                  const SizedBox(height: AppTokens.spacing * 4),
                  if (mood != null)
                    Text(
                      'Feeling ${mood.label.toLowerCase()} — '
                      '${mood.supportingCopy.toLowerCase()}.',
                      textAlign: TextAlign.center,
                      style: textTheme.bodyLarge,
                    ),
                  const SizedBox(height: AppTokens.spacing * 2),
                  Text(
                    editingToday
                        ? 'Saving updates today\'s existing check-in. '
                              'Your plant keeps one contribution for today.'
                        : 'One new contribution will be added to your plant.',
                    textAlign: TextAlign.center,
                    style: textTheme.bodySmall?.copyWith(
                      color: AppTokens.textSecondary,
                    ),
                  ),
                  const SizedBox(height: AppTokens.spacing * 2),
                  Text(
                    'Your selfie stays on this device.',
                    textAlign: TextAlign.center,
                    style: textTheme.bodySmall?.copyWith(
                      color: AppTokens.textSecondary,
                    ),
                  ),
                  if (_saveFailed) ...[
                    const SizedBox(height: AppTokens.spacing * 2),
                    Text(
                      'That didn\'t save — nothing was added yet. '
                      'Your photo and mood are still here.',
                      textAlign: TextAlign.center,
                      style: textTheme.bodySmall?.copyWith(
                        color: AppTokens.warning,
                      ),
                    ),
                  ],
                  const SizedBox(height: AppTokens.spacing * 4),
                  FilledButton(
                    onPressed: (_saving || photo == null || mood == null)
                        ? null
                        : _save,
                    child: _saving
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Text(
                            _saveFailed
                                ? 'RETRY'
                                : editingToday
                                ? 'UPDATE TODAY\'S GROWTH'
                                : 'ADD TODAY\'S GROWTH',
                          ),
                  ),
                  const SizedBox(height: AppTokens.spacing * 2),
                  TextButton(
                    onPressed: _saving
                        ? null
                        : () => context.go('/check-in/mood'),
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
