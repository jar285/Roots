import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../contracts/camera_source.dart';
import '../../domain/model/mood.dart';

/// The wizard's draft: what the user has chosen so far, nothing more.
/// Cleared when a flow starts or finishes — it never outlives the ritual.
class CheckInDraft {
  const CheckInDraft({this.photo, this.mood});

  final CapturedPhoto? photo;
  final Mood? mood;

  CheckInDraft copyWith({CapturedPhoto? photo, Mood? mood}) {
    return CheckInDraft(photo: photo ?? this.photo, mood: mood ?? this.mood);
  }
}

class CheckInFlow extends Notifier<CheckInDraft> {
  @override
  CheckInDraft build() => const CheckInDraft();

  void start() => state = const CheckInDraft();

  void setPhoto(CapturedPhoto photo) => state = state.copyWith(photo: photo);

  void setMood(Mood mood) => state = state.copyWith(mood: mood);
}

final checkInFlowProvider = NotifierProvider<CheckInFlow, CheckInDraft>(
  CheckInFlow.new,
);
