import '../model/growth_event.dart';
import '../model/plant_state.dart';
import '../rules/growth_constants.dart';
import 'event_order.dart';

export '../model/plant_state.dart';

/// Outcome of projecting events into a PlantState.
sealed class ProjectionResult {
  const ProjectionResult();
}

final class ProjectionSuccess extends ProjectionResult {
  const ProjectionSuccess(this.plantState);

  final PlantState plantState;
}

/// A stored event names an algorithm this build does not know. Recoverable
/// data error (spec §4.4): it is never silently interpreted by the newest
/// algorithm.
final class UnknownAlgorithmVersion extends ProjectionResult {
  const UnknownAlgorithmVersion({
    required this.algorithmVersion,
    required this.eventId,
  });

  final int algorithmVersion;
  final String eventId;
}

/// A versioned projector applies one event's stored delta to the state
/// being built. Registered per algorithmVersion; old versions are preserved
/// so historical events keep their original behavior.
abstract interface class PlantProjector {
  void apply(PlantBuilder builder, GrowthEvent event);
}

/// Mutable accumulator used only during a single projection run.
class PlantBuilder {
  int height = GrowthConstants.seedHeight;
  final List<PlantElement> branches = [];
  final List<PlantElement> leaves = [];
  final List<PlantElement> decorations = [];
  int eventCount = 0;
  String? newestEventDate;

  PlantState build() {
    return PlantState(
      effectiveHeight: height,
      branches: branches,
      leaves: leaves,
      decorations: decorations,
      eventCount: eventCount,
      newestEventDate: newestEventDate,
    );
  }
}

/// Chooses the projector registered for each event's algorithmVersion and
/// folds the canonically ordered events into one PlantState (spec §4.4).
class ProjectorRegistry {
  ProjectorRegistry(Map<int, PlantProjector> projectors)
    : _byVersion = Map.unmodifiable(projectors);

  /// The registry shipped with this build: algorithm version 1.
  factory ProjectorRegistry.standard() {
    return ProjectorRegistry({
      GrowthConstants.initialAlgorithmVersion: const _V1Projector(),
    });
  }

  final Map<int, PlantProjector> _byVersion;

  ProjectionResult project(Iterable<GrowthEvent> events) {
    final builder = PlantBuilder();
    for (final event in inProjectionOrder(events)) {
      final projector = _byVersion[event.algorithmVersion];
      if (projector == null) {
        return UnknownAlgorithmVersion(
          algorithmVersion: event.algorithmVersion,
          eventId: event.id,
        );
      }
      projector.apply(builder, event);
      builder.eventCount += 1;
      builder.newestEventDate = event.localDate;
    }
    return ProjectionSuccess(builder.build());
  }
}

class _V1Projector implements PlantProjector {
  const _V1Projector();

  @override
  void apply(PlantBuilder builder, GrowthEvent event) {
    final delta = event.growthDelta;

    final headroom = GrowthConstants.maxHeight - builder.height;
    builder.height += delta.heightIncrease.clamp(0, headroom);

    _addElements(
      builder.branches,
      GrowthConstants.maxBranches,
      delta.branchIncrease,
      event,
    );
    _addElements(
      builder.leaves,
      GrowthConstants.maxLeaves,
      delta.leafIncrease,
      event,
    );
    _addElements(
      builder.decorations,
      GrowthConstants.maxDecorations,
      delta.decorationIncrease,
      event,
    );
  }

  void _addElements(
    List<PlantElement> target,
    int cap,
    int count,
    GrowthEvent event,
  ) {
    for (var i = 0; i < count && target.length < cap; i++) {
      target.add(
        PlantElement(
          sourceEventId: event.id,
          paletteId: event.growthDelta.paletteId,
          morphologyId: event.growthDelta.morphologyId,
        ),
      );
    }
  }
}
