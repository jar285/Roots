import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../app_providers.dart';
import '../theme/app_theme.dart';

/// Settings holds privacy context and the local-data controls. Start Over
/// lives in a clearly separated destructive section (spec §6.6) and is never
/// disguised as logout.
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  Future<void> _confirmStartOver(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppTokens.surfaceRaised,
        title: const Text('START OVER?'),
        content: const Text(
          'This permanently removes your plant history and managed selfies '
          'from this installation. The plant returns to its seed state. '
          'This cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('CANCEL'),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            style: TextButton.styleFrom(foregroundColor: AppTokens.destructive),
            child: const Text('ERASE EVERYTHING'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    await ref.read(startOverProvider)();
    ref.invalidate(companionProvider);
    ref.invalidate(historyProvider);
    if (context.mounted) context.go('/');
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('SETTINGS'),
        backgroundColor: AppTokens.background,
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: AppTokens.contentMaxWidth,
            ),
            child: ListView(
              padding: const EdgeInsets.all(AppTokens.spacing * 6),
              children: [
                Text('Privacy', style: textTheme.titleMedium),
                const SizedBox(height: AppTokens.spacing * 2),
                Text(
                  'Your selfies and check-ins stay on this device. There is '
                  'no account, no cloud copy, and no analytics. Mood is '
                  'always your own choice — never inferred from a photo.',
                  style: textTheme.bodySmall?.copyWith(
                    color: AppTokens.textSecondary,
                  ),
                ),
                const SizedBox(height: AppTokens.spacing * 10),
                Text('Local Data', style: textTheme.titleMedium),
                const SizedBox(height: AppTokens.spacing * 2),
                Text(
                  'Deleting a single check-in is available from its page in '
                  'History. Starting over erases everything and gives this '
                  'installation a fresh identity.',
                  style: textTheme.bodySmall?.copyWith(
                    color: AppTokens.textSecondary,
                  ),
                ),
                const SizedBox(height: AppTokens.spacing * 6),
                Container(
                  padding: const EdgeInsets.all(AppTokens.spacing * 4),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: AppTokens.destructive.withValues(alpha: 0.4),
                    ),
                    borderRadius: BorderRadius.circular(AppTokens.radius),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        'This removes all local data for good.',
                        textAlign: TextAlign.center,
                        style: textTheme.bodySmall?.copyWith(
                          color: AppTokens.textSecondary,
                        ),
                      ),
                      const SizedBox(height: AppTokens.spacing * 3),
                      TextButton(
                        onPressed: () => _confirmStartOver(context, ref),
                        style: TextButton.styleFrom(
                          foregroundColor: AppTokens.destructive,
                          minimumSize: const Size.fromHeight(
                            AppTokens.minTouchTarget,
                          ),
                        ),
                        child: const Text('START OVER'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
