/// Source of stable local identifiers (event ids, installation ids).
///
/// Injectable so tests are deterministic (spec §3 guarantee 10).
abstract interface class IdSource {
  String nextId();
}
