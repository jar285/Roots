import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../contracts/camera_source.dart';
import '../app_providers.dart';
import '../theme/app_theme.dart';
import 'check_in_flow.dart';

/// Capture answers: is this the photo I want to keep locally?
/// Until Sprint 6 every platform uses the simulated source (ADR 0004 #3).
class CaptureScreen extends ConsumerStatefulWidget {
  const CaptureScreen({super.key});

  @override
  ConsumerState<CaptureScreen> createState() => _CaptureScreenState();
}

class _CaptureScreenState extends ConsumerState<CaptureScreen> {
  CapturedPhoto? _photo;
  bool _capturing = false;

  @override
  void initState() {
    super.initState();
    _capture();
  }

  Future<void> _capture() async {
    setState(() => _capturing = true);
    final photo = await ref.read(cameraSourceProvider).capture();
    if (!mounted) return;
    setState(() {
      _photo = photo;
      _capturing = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final photo = _photo;

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
                    'SIMULATED CAMERA',
                    textAlign: TextAlign.center,
                    style: Theme.of(
                      context,
                    ).textTheme.titleMedium?.copyWith(letterSpacing: 2),
                  ),
                  const SizedBox(height: AppTokens.spacing * 4),
                  Expanded(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: AppTokens.surface,
                        borderRadius: BorderRadius.circular(AppTokens.radius),
                      ),
                      child: photo == null
                          ? const Center(child: CircularProgressIndicator())
                          : ClipRRect(
                              borderRadius: BorderRadius.circular(
                                AppTokens.radius,
                              ),
                              child: Image.memory(
                                photo.bytes,
                                fit: BoxFit.cover,
                                width: double.infinity,
                                gaplessPlayback: true,
                                errorBuilder: (_, _, _) => const Center(
                                  child: Icon(Icons.image_not_supported),
                                ),
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(height: AppTokens.spacing * 4),
                  FilledButton(
                    onPressed: photo == null
                        ? null
                        : () {
                            ref
                                .read(checkInFlowProvider.notifier)
                                .setPhoto(photo);
                            context.go('/check-in/mood');
                          },
                    child: const Text('USE THIS PHOTO'),
                  ),
                  const SizedBox(height: AppTokens.spacing * 2),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      TextButton(
                        onPressed: _capturing ? null : _capture,
                        child: const Text('RETAKE'),
                      ),
                      const SizedBox(width: AppTokens.spacing * 4),
                      TextButton(
                        onPressed: () => context.go('/'),
                        child: const Text('CANCEL'),
                      ),
                    ],
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
