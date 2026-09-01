import 'growth_delta.dart';
import 'mood.dart';
import 'time_category.dart';

/// The canonical record of one daily check-in (spec §4.1).
///
/// GrowthEvent rows are the source of truth; everything else is derived.
/// Inputs and the resolved [growthDelta] are both stored so past events stay
/// explainable and immune to future algorithm changes.
class GrowthEvent {
  const GrowthEvent({
    required this.id,
    required this.installationId,
    required this.localDate,
    required this.checkedInAtUtc,
    required this.timezoneOffsetMinutes,
    required this.timeCategory,
    required this.mood,
    required this.selfieFileName,
    required this.randomSeed,
    required this.algorithmVersion,
    required this.growthDelta,
    required this.createdAtUtc,
    required this.updatedAtUtc,
  });

  final String id;
  final String installationId;

  /// ISO `yyyy-MM-dd`; unique per installation (enforced by storage).
  final String localDate;
  final DateTime checkedInAtUtc;
  final int timezoneOffsetMinutes;
  final TimeCategory timeCategory;
  final Mood mood;
  final String selfieFileName;
  final int randomSeed;
  final int algorithmVersion;
  final GrowthDelta growthDelta;
  final DateTime createdAtUtc;
  final DateTime updatedAtUtc;

  @override
  bool operator ==(Object other) {
    return other is GrowthEvent &&
        other.id == id &&
        other.installationId == installationId &&
        other.localDate == localDate &&
        other.checkedInAtUtc == checkedInAtUtc &&
        other.timezoneOffsetMinutes == timezoneOffsetMinutes &&
        other.timeCategory == timeCategory &&
        other.mood == mood &&
        other.selfieFileName == selfieFileName &&
        other.randomSeed == randomSeed &&
        other.algorithmVersion == algorithmVersion &&
        other.growthDelta == growthDelta &&
        other.createdAtUtc == createdAtUtc &&
        other.updatedAtUtc == updatedAtUtc;
  }

  @override
  int get hashCode => Object.hash(
    id,
    installationId,
    localDate,
    checkedInAtUtc,
    timezoneOffsetMinutes,
    timeCategory,
    mood,
    selfieFileName,
    randomSeed,
    algorithmVersion,
    growthDelta,
    createdAtUtc,
    updatedAtUtc,
  );
}
