import 'dart:typed_data';

/// Owns the private managed-photo lifecycle (spec §5.4, A.9).
///
/// Sprint 3 scope: save processed bytes under the event-id-based final name.
/// Staging, atomic promotion, enumeration, and reconciliation join in
/// Sprint 4 (recorded debt, ADR 0004 #2).
abstract interface class ManagedMediaStore {
  /// Persists processed photo bytes for [eventId] and returns the managed
  /// file name (`<eventId>.<ext>`). Overwrites any previous photo for the
  /// same event (same-day replacement reuses the event id).
  Future<String> saveProcessedPhoto({
    required String eventId,
    required Uint8List bytes,
  });
}
