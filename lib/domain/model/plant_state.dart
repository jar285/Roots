import '../rules/growth_constants.dart';

/// One drawable element of the plant, permanently tied to the event that
/// created it (spec §4.3, A.6): applying a new mood never repaints history.
class PlantElement {
  const PlantElement({
    required this.sourceEventId,
    required this.paletteId,
    required this.morphologyId,
  });

  final String sourceEventId;
  final String paletteId;
  final String morphologyId;

  @override
  bool operator ==(Object other) {
    return other is PlantElement &&
        other.sourceEventId == sourceEventId &&
        other.paletteId == paletteId &&
        other.morphologyId == morphologyId;
  }

  @override
  int get hashCode => Object.hash(sourceEventId, paletteId, morphologyId);

  @override
  String toString() =>
      'PlantElement($sourceEventId, $paletteId, $morphologyId)';
}

/// Derived, never independently edited (spec §4.3). Replaying the same
/// ordered events must produce structurally equal PlantState values.
class PlantState {
  PlantState({
    required this.effectiveHeight,
    required List<PlantElement> branches,
    required List<PlantElement> leaves,
    required List<PlantElement> decorations,
    required this.eventCount,
    required this.newestEventDate,
  }) : branches = List.unmodifiable(branches),
       leaves = List.unmodifiable(leaves),
       decorations = List.unmodifiable(decorations);

  final int effectiveHeight;
  final List<PlantElement> branches;
  final List<PlantElement> leaves;
  final List<PlantElement> decorations;
  final int eventCount;

  /// ISO `yyyy-MM-dd` of the newest projected event; null when empty.
  final String? newestEventDate;

  /// Mature means every global cap is reached (ADR 0002). Later events still
  /// record history; they add no geometry past the caps.
  bool get isMature =>
      effectiveHeight >= GrowthConstants.maxHeight &&
      branches.length >= GrowthConstants.maxBranches &&
      leaves.length >= GrowthConstants.maxLeaves &&
      decorations.length >= GrowthConstants.maxDecorations;

  static bool _sameElements(List<PlantElement> a, List<PlantElement> b) {
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }

  @override
  bool operator ==(Object other) {
    return other is PlantState &&
        other.effectiveHeight == effectiveHeight &&
        other.eventCount == eventCount &&
        other.newestEventDate == newestEventDate &&
        _sameElements(other.branches, branches) &&
        _sameElements(other.leaves, leaves) &&
        _sameElements(other.decorations, decorations);
  }

  @override
  int get hashCode => Object.hash(
    effectiveHeight,
    eventCount,
    newestEventDate,
    Object.hashAll(branches),
    Object.hashAll(leaves),
    Object.hashAll(decorations),
  );
}
