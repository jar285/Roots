import '../contracts/clock.dart';
import '../contracts/companion_repository.dart';
import '../domain/model/growth_event.dart';
import '../domain/projection/plant_projector.dart';

/// The companion as the UI needs it: the projected plant, today's event (if
/// any), and which local date "today" is.
class LoadedCompanion {
  const LoadedCompanion({
    required this.plant,
    required this.todayEvent,
    required this.todayLocalDate,
  });

  final PlantState plant;
  final GrowthEvent? todayEvent;
  final String todayLocalDate;

  bool get hasCheckedInToday => todayEvent != null;
}

/// A stored event references an algorithm this build does not know
/// (spec §4.4). Recoverable: the UI explains it instead of guessing.
class UnknownAlgorithmVersionException implements Exception {
  const UnknownAlgorithmVersionException({
    required this.algorithmVersion,
    required this.eventId,
  });

  final int algorithmVersion;
  final String eventId;

  @override
  String toString() =>
      'UnknownAlgorithmVersionException(version $algorithmVersion, '
      'event $eventId)';
}

/// Loads all events and deterministically projects the plant (spec §4.4).
class LoadCompanion {
  const LoadCompanion({
    required this.repository,
    required this.registry,
    required this.clock,
  });

  final CompanionRepository repository;
  final ProjectorRegistry registry;
  final Clock clock;

  Future<LoadedCompanion> call() async {
    final events = await repository.allEvents();
    final today = clock.now().localDate;

    switch (registry.project(events)) {
      case ProjectionSuccess(:final plantState):
        return LoadedCompanion(
          plant: plantState,
          todayEvent: events.where((e) => e.localDate == today).firstOrNull,
          todayLocalDate: today,
        );
      case UnknownAlgorithmVersion(:final algorithmVersion, :final eventId):
        throw UnknownAlgorithmVersionException(
          algorithmVersion: algorithmVersion,
          eventId: eventId,
        );
    }
  }
}
