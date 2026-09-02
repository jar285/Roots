import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../app_providers.dart';
import '../theme/app_theme.dart';
import 'check_in_flow.dart';

/// The photo this check-in will keep: the freshly captured draft, or — when
/// the user chose to keep it on a same-day review — the stored managed photo.
/// Shared by the mood stage and the confirmation preview.
class DraftPhotoView extends ConsumerWidget {
  const DraftPhotoView({super.key, this.fit = BoxFit.cover});

  final BoxFit fit;

  Widget _image(Uint8List bytes) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppTokens.radius),
      child: Image.memory(
        bytes,
        fit: fit,
        width: double.infinity,
        height: double.infinity,
        gaplessPlayback: true,
        errorBuilder: (_, _, _) =>
            const Center(child: Icon(Icons.image_not_supported)),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final draft = ref.watch(checkInFlowProvider);
    final photo = draft.photo;
    if (photo != null) return _image(photo.bytes);
    if (!draft.keepExistingPhoto) return const SizedBox.shrink();

    final todayEvent = switch (ref.watch(companionProvider)) {
      AsyncData(:final value) => value.todayEvent,
      _ => null,
    };
    if (todayEvent == null) return const SizedBox.shrink();

    return FutureBuilder(
      future: ref
          .watch(mediaStoreProvider)
          .readManagedPhoto(todayEvent.selfieFileName),
      builder: (context, snapshot) {
        final bytes = snapshot.data;
        if (bytes == null) return const SizedBox.shrink();
        return _image(bytes);
      },
    );
  }
}
