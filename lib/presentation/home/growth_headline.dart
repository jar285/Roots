import '../../domain/model/growth_delta.dart';

/// Completed-today headline derived strictly from the stored delta
/// (ADR 0006 #7): copy never claims growth the delta did not contain.
/// Priority: leaves, branches, decorations, height, then a generic line.
String growthHeadline(GrowthDelta delta) {
  if (delta.leafIncrease == 1) return 'A new leaf is part of it now.';
  if (delta.leafIncrease > 1) {
    return '${delta.leafIncrease} new leaves are part of it now.';
  }
  if (delta.branchIncrease == 1) return 'A new branch is part of it now.';
  if (delta.branchIncrease > 1) {
    return '${delta.branchIncrease} new branches are part of it now.';
  }
  if (delta.decorationIncrease == 1) return 'A new decoration adorns it now.';
  if (delta.decorationIncrease > 1) {
    return '${delta.decorationIncrease} new decorations adorn it now.';
  }
  if (delta.heightIncrease > 0) return 'It stands a little taller now.';
  return 'Today is part of its story now.';
}
