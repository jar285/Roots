# Sprint QA Report

## Sprint

Sprint 1 — deterministic domain. Intended outcome: time categorization, mood and growth
rules, seeded silly behavior, caps and maturity, event ordering, versioned plant
projection, and historical style retention — pure Dart, proven by table-driven and
boundary tests, with no Flutter widget, Drift, camera, filesystem, or backend involvement.

## Spec slice

Design spec §4 (domain model), §4.4 (projection order, unknown versions), §4.7
(maturity), Appendix A.1–A.3/A.6 (constants, growth tables, worked examples, retention),
§9 "one confirmed event produces one deterministic plant contribution", "restarting
reproduces the same plant", "changing a later event does not repaint earlier growth".
Invariants at risk: #2 deterministic projection, #5 seeded randomness with algorithm
version, #6 historical style retention, #10 injectable nondeterminism.

## Changes

New `lib/domain/` (pure Dart): `model/` (Mood, TimeCategory, GrowthDelta, GrowthEvent,
PlantState + PlantElement, CheckInMoment), `rng/` (SeededPrng — repo-owned xorshift32,
ADR 0002), `rules/` (GrowthConstants, GrowthRules v1 pipeline), `projection/`
(canonical event ordering, PlantBuilder, versioned ProjectorRegistry with sealed
ProjectionResult). Mirrored `test/domain/` — 73 domain tests (74 total with the
Sprint 0 smoke test). Semantic decisions recorded in ADR 0002 before implementation.

## Evidence

Each production slice followed red → green (failing run observed before implementation):

- Time categorization: RED (unit missing) → GREEN, exhaustive 24-hour table + range
  guard (25 tests).
- SeededPrng: RED → GREEN, replay/bounds/coverage/zero-seed/validation properties.
- GrowthDelta + GrowthRules: RED → GREEN. **All five spec A.3 worked examples pass
  verbatim**; silly mood matches the locked seeded call order on top of the time
  modifier; non-silly moods ignore the seed; palette/morphology ids per ADR 0002;
  normalization clamps proven.
- CheckInMoment: RED → GREEN, midnight-forward, year-backward, half-hour offsets,
  ISO padding, UTC-only guard.
- Event ordering: RED → GREEN, each tie-breaker + permutation stability + input
  non-mutation.
- Projector: RED → GREEN, 13 tests — empty seed state, element sourcing, replay
  structural equality across permutations, style retention under later add/replace/
  delete, caps (including partial application at a cap boundary), maturity requires all
  four caps, post-maturity history without geometry, unknown algorithmVersion as a
  typed recoverable error.

Full verification (2026-09-01):

- `dart format --output=none --set-exit-if-changed lib test` → clean (after a real
  format pass; the check is part of the standard commands).
- `flutter analyze` → "No issues found!"
- `flutter test` → **74 tests, all passed**, ~4 s.

Pacing harness output (deterministic time/mood rotation, spec validation-gate numbers):

    day 30:  height 420, branches 20, leaves 50, decorations 38, mature false
    day 90:  height 500, branches 20, leaves 50, decorations 40, mature true
    day 180: unchanged at caps
    day 365: unchanged at caps
    maturity reached on day: 36

## Failure paths

Unknown algorithm version returns `UnknownAlgorithmVersion(version, eventId)` — never a
silent reinterpretation. Out-of-range hours, non-UTC instants, and non-positive PRNG
bounds throw ArgumentError at the boundary.

## Architecture check

Source of truth unchanged: events in, derived PlantState out; the projector holds no
state between runs. `lib/domain` has zero package dependencies; the purity guard test
(regex self-checked, scans every domain file) enforces the no-Flutter/Drift/IO invariant.
No providers, repositories, or speculative seams added.

## Privacy and accessibility

Not applicable this slice (no UI, IO, or logging). No domain type logs or exposes photo
paths.

## Variance

- The domain purity guard and the pacing harness are guard/characterization tests over
  code proven by the TDD slices above; they passed on first run **by design** and are
  not claimed as red→green evidence.
- Silly spread *sets* the factor (other silly fields add) — ADR 0002, derived from the
  spec's mood-spread pattern.

## Not verified

- Visual pacing review (the spec's gate says *visually* review 30/90/180/365) — numbers
  are recorded above; rendering does not exist until Sprint 5. The gate stays open.
- Persistence semantics (daily uniqueness, upsert, migrations) — Sprint 2 scope.
- Any behavior on a real device or the macOS harness — Xcode still pending.

## Carry forward

- **Pacing data point for the Sprint 5 gate**: branch/leaf caps are reached in roughly
  two weeks of daily use and full maturity on day 36. If the product wants a longer
  growth arc, that is a constants-tuning decision to take at the gate — not silently.
- Sprint 2: Drift schema, installation-id creation timing, migration fixtures (ADR 0001
  / plan).

## Diminishing returns

No benchmark suite: the harness already projects a 365-event year incrementally
(≈ 66k event applications) inside a ~4 s total test run, so snapshot caching remains
unjustified — consistent with the spec's "measure before optimizing" gate. No shared
test-fixture package; two small local event builders are clearer than a premature
helper library.
