import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../contracts/camera_source.dart';
import '../../domain/model/mood.dart';

/// The wizard's draft: what the user has chosen so far, nothing more.
/// Cleared when a flow starts or finishes — it never outlives the ritual.
///
/// [keepExistingPhoto] is the same-day review choice to leave the stored
/// photo untouched (spec §4.5); it and [photo] are mutually exclusive.
class CheckInDraft {
  const CheckInDraft({this.photo, this.mood, this.keepExistingPhoto = false});

  final CapturedPhoto? photo;
  final Mood? mood;
  final bool keepExistingPhoto;

  CheckInDraft copyWith({
    CapturedPhoto? photo,
    Mood? mood,
    bool? keepExistingPhoto,
  }) {
    return CheckInDraft(
      photo: photo ?? this.photo,
      mood: mood ?? this.mood,
      keepExistingPhoto: keepExistingPhoto ?? this.keepExistingPhoto,
    );
  }
}

class CheckInFlow extends Notifier<CheckInDraft> {
  @override
  CheckInDraft build() => const CheckInDraft();

  void start() => state = const CheckInDraft();

  void setPhoto(CapturedPhoto photo) =>
      state = CheckInDraft(photo: photo, mood: state.mood);

  void keepExistingPhoto() =>
      state = CheckInDraft(mood: state.mood, keepExistingPhoto: true);

  void setMood(Mood mood) => state = state.copyWith(mood: mood);
}

final checkInFlowProvider = NotifierProvider<CheckInFlow, CheckInDraft>(
  CheckInFlow.new,
);
