/// The resolved growth contribution of one check-in (spec §4.2).
///
/// Persisted alongside its inputs so past events stay explainable and are
/// protected from future algorithm changes.
class GrowthDelta {
  const GrowthDelta({
    required this.heightIncrease,
    required this.branchIncrease,
    required this.leafIncrease,
    required this.decorationIncrease,
    required this.spreadFactor,
    required this.prefersVertical,
    required this.prefersSpiral,
    required this.paletteId,
    required this.morphologyId,
  });

  /// Delta-level normalization at creation (ADR 0002): counts clamped to
  /// zero or more, spread clamped to [0.0, 1.0]. Global plant caps are a
  /// projection concern, not a delta concern.
  factory GrowthDelta.normalized({
    required int heightIncrease,
    required int branchIncrease,
    required int leafIncrease,
    required int decorationIncrease,
    required double spreadFactor,
    required bool prefersVertical,
    required bool prefersSpiral,
    required String paletteId,
    required String morphologyId,
  }) {
    return GrowthDelta(
      heightIncrease: heightIncrease < 0 ? 0 : heightIncrease,
      branchIncrease: branchIncrease < 0 ? 0 : branchIncrease,
      leafIncrease: leafIncrease < 0 ? 0 : leafIncrease,
      decorationIncrease: decorationIncrease < 0 ? 0 : decorationIncrease,
      spreadFactor: spreadFactor.clamp(0.0, 1.0),
      prefersVertical: prefersVertical,
      prefersSpiral: prefersSpiral,
      paletteId: paletteId,
      morphologyId: morphologyId,
    );
  }

  final int heightIncrease;
  final int branchIncrease;
  final int leafIncrease;
  final int decorationIncrease;
  final double spreadFactor;
  final bool prefersVertical;
  final bool prefersSpiral;
  final String paletteId;
  final String morphologyId;

  GrowthDelta copyWith({
    int? heightIncrease,
    int? branchIncrease,
    int? leafIncrease,
    int? decorationIncrease,
    double? spreadFactor,
    bool? prefersVertical,
    bool? prefersSpiral,
    String? paletteId,
    String? morphologyId,
  }) {
    return GrowthDelta(
      heightIncrease: heightIncrease ?? this.heightIncrease,
      branchIncrease: branchIncrease ?? this.branchIncrease,
      leafIncrease: leafIncrease ?? this.leafIncrease,
      decorationIncrease: decorationIncrease ?? this.decorationIncrease,
      spreadFactor: spreadFactor ?? this.spreadFactor,
      prefersVertical: prefersVertical ?? this.prefersVertical,
      prefersSpiral: prefersSpiral ?? this.prefersSpiral,
      paletteId: paletteId ?? this.paletteId,
      morphologyId: morphologyId ?? this.morphologyId,
    );
  }

  @override
  bool operator ==(Object other) {
    return other is GrowthDelta &&
        other.heightIncrease == heightIncrease &&
        other.branchIncrease == branchIncrease &&
        other.leafIncrease == leafIncrease &&
        other.decorationIncrease == decorationIncrease &&
        other.spreadFactor == spreadFactor &&
        other.prefersVertical == prefersVertical &&
        other.prefersSpiral == prefersSpiral &&
        other.paletteId == paletteId &&
        other.morphologyId == morphologyId;
  }

  @override
  int get hashCode => Object.hash(
    heightIncrease,
    branchIncrease,
    leafIncrease,
    decorationIncrease,
    spreadFactor,
    prefersVertical,
    prefersSpiral,
    paletteId,
    morphologyId,
  );

  @override
  String toString() =>
      'GrowthDelta(h+$heightIncrease b+$branchIncrease l+$leafIncrease '
      'd+$decorationIncrease spread $spreadFactor '
      '${prefersVertical ? 'vertical ' : ''}${prefersSpiral ? 'spiral ' : ''}'
      '$paletteId $morphologyId)';
}
