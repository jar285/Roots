/// Source of the random seed stored on each event. Production may be
/// nondeterministic; tests inject fixed values (spec §3 guarantee 10).
abstract interface class SeedSource {
  int nextSeed();
}
