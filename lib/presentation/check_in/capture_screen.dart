import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../contracts/camera_source.dart';
import '../app_providers.dart';
import '../theme/app_theme.dart';
import 'check_in_flow.dart';

/// Capture answers: is this the photo I want to keep locally?
///
/// Every capture outcome has a named recovery path (spec §8.9, A.7 copy):
/// a photo to use or retake, a cancellation that returns home quietly,
/// a denial that explains itself, and absent hardware that says so.
class CaptureScreen extends ConsumerStatefulWidget {
  const CaptureScreen({super.key});

  @override
  ConsumerState<CaptureScreen> createState() => _CaptureScreenState();
}

class _CaptureScreenState extends ConsumerState<CaptureScreen> {
  CaptureResult? _outcome;
  bool _capturing = false;

  @override
  void initState() {
    super.initState();
    _capture();
  }

  Future<void> _capture() async {
    setState(() => _capturing = true);
    final result = await ref.read(cameraSourceProvider).capture();
    if (!mounted) return;

    // Cancellation returns to the previous stable state with no event and no
    // error toast (spec §8 "camera cancelled").
    if (result is CaptureCancelled) {
      context.go('/');
      return;
    }
    setState(() {
      _outcome = result;
      _capturing = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final outcome = _outcome;
    final editingToday = switch (ref.watch(companionProvider)) {
      AsyncData(:final value) => value.hasCheckedInToday,
      _ => false,
    };

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: AppTokens.contentMaxWidth,
            ),
            child: Padding(
              padding: const EdgeInsets.all(AppTokens.spacing * 6),
              child: switch (outcome) {
                CapturePhoto(:final photo) => _PhotoReview(
                  photo: photo,
                  editingToday: editingToday,
                  onRetake: _capturing ? null : _capture,
                ),
                CapturePermissionDenied(:final permanentlyDenied) =>
                  _RecoveryPanel(
                    title: 'CAMERA ACCESS NEEDED',
                    message:
                        'Camera access is off. Enable it in Settings, or use '
                        'the reviewer simulation where available.',
                    onOpenSettings: permanentlyDenied
                        ? () => ref
                              .read(appSettingsLauncherProvider)
                              .openAppSettingsPage()
                        : null,
                    onTryAgain: _capturing ? null : _capture,
                  ),
                CameraUnavailable() => _RecoveryPanel(
                  title: 'NO CAMERA FOUND',
                  message: 'No camera is available on this device.',
                  onTryAgain: _capturing ? null : _capture,
                ),
                _ => const Center(child: CircularProgressIndicator()),
              },
            ),
          ),
        ),
      ),
    );
  }
}

class _PhotoReview extends ConsumerWidget {
  const _PhotoReview({
    required this.photo,
    required this.editingToday,
    required this.onRetake,
  });

  final CapturedPhoto photo;
  final bool editingToday;
  final VoidCallback? onRetake;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        clampedDisplay(
          child: Text(
            'TODAY\'S SELFIE',
            style: displayStyle.copyWith(fontSize: 24),
          ),
        ),
        const SizedBox(height: AppTokens.spacing * 4),
        Expanded(
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: AppTokens.surface,
              borderRadius: BorderRadius.circular(AppTokens.radiusLarge),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(AppTokens.radiusLarge),
              child: Image.memory(
                photo.bytes,
                fit: BoxFit.cover,
                width: double.infinity,
                gaplessPlayback: true,
                errorBuilder: (_, _, _) =>
                    const Center(child: Icon(Icons.image_not_supported)),
              ),
            ),
          ),
        ),
        const SizedBox(height: AppTokens.spacing * 4),
        FilledButton(
          onPressed: () {
            ref.read(checkInFlowProvider.notifier).setPhoto(photo);
            context.go('/check-in/mood');
          },
          child: const Text('USE THIS PHOTO'),
        ),
        if (editingToday) ...[
          const SizedBox(height: AppTokens.spacing * 2),
          TextButton(
            onPressed: () {
              ref.read(checkInFlowProvider.notifier).keepExistingPhoto();
              context.go('/check-in/mood');
            },
            child: const Text('KEEP CURRENT PHOTO'),
          ),
        ],
        const SizedBox(height: AppTokens.spacing * 2),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextButton(onPressed: onRetake, child: const Text('RETAKE')),
            const SizedBox(width: AppTokens.spacing * 4),
            TextButton(
              onPressed: () => context.go('/'),
              child: const Text('CANCEL'),
            ),
          ],
        ),
      ],
    );
  }
}

/// A calm, recoverable failure state: what happened, and what to do next.
class _RecoveryPanel extends StatelessWidget {
  const _RecoveryPanel({
    required this.title,
    required this.message,
    required this.onTryAgain,
    this.onOpenSettings,
  });

  final String title;
  final String message;
  final VoidCallback? onTryAgain;
  final VoidCallback? onOpenSettings;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        clampedDisplay(
          child: Text(title, style: displayStyle.copyWith(fontSize: 24)),
        ),
        const SizedBox(height: AppTokens.spacing * 3),
        Text(
          message,
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(color: AppTokens.textSecondary),
        ),
        const SizedBox(height: AppTokens.spacing * 6),
        if (onOpenSettings != null) ...[
          FilledButton(
            onPressed: onOpenSettings,
            child: const Text('OPEN SETTINGS'),
          ),
          const SizedBox(height: AppTokens.spacing * 2),
          OutlinedButton(onPressed: onTryAgain, child: const Text('TRY AGAIN')),
        ] else
          FilledButton(onPressed: onTryAgain, child: const Text('TRY AGAIN')),
        const SizedBox(height: AppTokens.spacing * 2),
        TextButton(
          onPressed: () => context.go('/'),
          child: const Text('CANCEL'),
        ),
      ],
    );
  }
}
