import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../domain/model/growth_event.dart';
import '../app_providers.dart';
import '../check_in/check_in_flow.dart';
import '../theme/app_theme.dart';
import 'history_screen.dart';

/// Event detail answers: what did this day contribute, and can I remove it?
class EventDetailScreen extends ConsumerWidget {
  const EventDetailScreen({super.key, required this.eventId});

  final String eventId;

  String _contributionCopy(GrowthEvent event) {
    final delta = event.growthDelta;
    String plural(int n, String word) => '$n $word${n == 1 ? '' : 's'}';
    return 'This day contributed +${delta.heightIncrease} height, '
        '${plural(delta.branchIncrease, 'branch')}, '
        '${plural(delta.leafIncrease, 'leaf')} and '
        '${plural(delta.decorationIncrease, 'decoration')} to your plant.';
  }

  Future<void> _confirmDelete(
    BuildContext context,
    WidgetRef ref,
    GrowthEvent event,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppTokens.surfaceRaised,
        title: const Text('DELETE THIS CHECK-IN?'),
        content: Text(
          'This removes the check-in from ${event.localDate} and its '
          'contribution to your plant.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('CANCEL'),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            style: TextButton.styleFrom(foregroundColor: AppTokens.destructive),
            child: const Text('DELETE'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    // Row first, then photo; a failed file removal is swept by the next
    // reconciliation and needs no user-facing noise (UI/UX philosophy).
    await ref.read(deleteGrowthEventProvider)(event.id);
    ref.invalidate(companionProvider);
    ref.invalidate(historyProvider);
    if (context.mounted) context.go('/history');
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final history = ref.watch(historyProvider);
    final today = switch (ref.watch(companionProvider)) {
      AsyncData(:final value) => value.todayLocalDate,
      _ => null,
    };

    final event = switch (history) {
      AsyncData(:final value) =>
        value.where((e) => e.id == eventId).firstOrNull,
      _ => null,
    };

    return Scaffold(
      appBar: AppBar(
        title: const Text('CHECK-IN'),
        backgroundColor: AppTokens.background,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          tooltip: 'Back',
          onPressed: () => context.go('/history'),
        ),
      ),
      body: SafeArea(
        child: event == null
            ? const Center(child: CircularProgressIndicator())
            : Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(
                    maxWidth: AppTokens.contentMaxWidth,
                  ),
                  child: ListView(
                    padding: const EdgeInsets.all(AppTokens.spacing * 6),
                    children: [
                      Center(child: EventThumbnail(event: event, size: 220)),
                      const SizedBox(height: AppTokens.spacing * 3),
                      _MissingPhotoNote(event: event),
                      const SizedBox(height: AppTokens.spacing * 4),
                      Text(
                        event.localDate,
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: AppTokens.spacing * 2),
                      Text(
                        '${event.mood.label} — '
                        '${event.mood.supportingCopy.toLowerCase()} · '
                        '${event.timeCategory.name}',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      const SizedBox(height: AppTokens.spacing * 4),
                      Text(
                        _contributionCopy(event),
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppTokens.textSecondary,
                        ),
                      ),
                      const SizedBox(height: AppTokens.spacing * 8),
                      if (event.localDate == today) ...[
                        FilledButton(
                          onPressed: () {
                            ref.read(checkInFlowProvider.notifier).start();
                            context.go('/check-in/capture');
                          },
                          child: const Text('REVIEW TODAY\'S CHECK-IN'),
                        ),
                        const SizedBox(height: AppTokens.spacing * 2),
                      ],
                      TextButton(
                        onPressed: () => _confirmDelete(context, ref, event),
                        style: TextButton.styleFrom(
                          foregroundColor: AppTokens.destructive,
                        ),
                        child: const Text('DELETE THIS CHECK-IN'),
                      ),
                    ],
                  ),
                ),
              ),
      ),
    );
  }
}

class _MissingPhotoNote extends ConsumerWidget {
  const _MissingPhotoNote({required this.event});

  final GrowthEvent event;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return FutureBuilder(
      future: ref
          .watch(mediaStoreProvider)
          .readManagedPhoto(event.selfieFileName),
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done ||
            snapshot.data != null) {
          return const SizedBox.shrink();
        }
        return Text(
          'Photo unavailable. Your check-in and growth are still here.',
          textAlign: TextAlign.center,
          style: Theme.of(
            context,
          ).textTheme.bodySmall?.copyWith(color: AppTokens.textSecondary),
        );
      },
    );
  }
}
