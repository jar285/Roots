# Sprint QA Report

## Sprint

Sprint 2 — canonical local storage. Intended outcome: Drift/SQLite schema for
`growth_events` and `app_metadata`, the one-event-per-installation-per-local-date rule
enforced by the database, a CompanionRepository contract with transactional
insert / same-day update / read / delete, installation identity, and migration-fixture
machinery from schema v1.

## Spec slice

Design spec §5.3 (persistence), §4.5 (daily correction semantics), §4.6 (deletion),
A.8 (persistence schema); development philosophy Sprint 2 ("repository contract tests;
competing-write test proves uniqueness; migration fixtures reach the current schema").
Invariants at risk: #3 one active event per local date, #4 reconfirming updates rather
than adds, and the Lampson rule that the guarantee lives in storage, not the UI.

## Changes

- `lib/contracts/`: CompanionRepository (installationId, upsertDailyCheckIn,
  eventForDate, allEvents, deleteEvent), DailyCheckInDraft (nullable selfie = keep
  existing photo), CorruptEventDataException, IdSource.
- `lib/infrastructure/drift/`: table definitions with the **unique
  (installation_id, local_date) index**, generated code, and
  DriftCompanionRepository — transactional upsert preserving id/createdAtUtc, canonical
  SQL ordering, strict enum/JSON validation on every read (ADR 0003).
- `lib/infrastructure/uuid_id_source.dart`: production UUID v4 id source.
- `drift_schemas/drift_schema_v1.json`: committed v1 snapshot (the oldest shipped
  fixture) + generated verifier helpers + schema validation test.
- Domain: GrowthEvent gained value equality (needed for exact round-trip proofs).
- Semantic decisions recorded first in ADR 0003.

## Evidence

All repository behavior was written as tests before the implementation existed
(observed failing/compile-failing first), including the shared contract suite that any
future in-memory fake must also pass (Liskov):

- `flutter test` → **96 tests, all passed**; `flutter analyze` → no issues;
  `dart format --set-exit-if-changed` → clean. (2026-09-01)
- Contract suite (16 cases): lazy stable installation id stamped onto events; create
  from one confirmation reading (createdAt = updatedAt = checkedInAt); create requires
  a selfie name; same-day correction preserves id + createdAtUtc and replaces the rest;
  null selfie keeps the existing photo; **5 competing submissions resolve to exactly one
  event**; canonical read order regardless of insert order; exact value-equality
  round-trip; delete reports found/not-found and frees the date for a fresh check-in
  with a new id.
- SQLite-level: a raw duplicate insert **bypassing the repository** is rejected by the
  unique index; the same date under a different installation id is allowed; corrupt
  `mood` and corrupt `growth_delta` JSON surface as CorruptEventDataException naming
  the event and field.
- Durability: a file-backed database reopened by a fresh repository instance returns
  the same installation id and identical events.
- Schema: SchemaVerifier creates a database from the committed v1 fixture and validates
  it against the runtime schema (passes).

## Failure paths

Missing selfie on first create → ArgumentError; unknown enum value / malformed or
mistyped delta JSON → typed CorruptEventDataException (never coerced); duplicate day →
resolved to an update inside the transaction, and rejected by SQLite if the repository
is bypassed; deleting a nonexistent id → false, not an exception.

## Architecture check

Dependency direction holds: domain untouched by Drift (purity guard still passing);
contracts sit between application-to-be and infrastructure; the repository is one deep
module hiding schema, transactions, mapping, and validation. No caches, no persisted
PlantState, no speculative methods (Start Over arrives with Sprint 4's tests).

## Privacy and accessibility

No UI this sprint. The repository never logs; photo file names stay inside the
database and API. Timestamps are stored as UTC milliseconds — no local-time leakage.

## Variance

- **Toolchain quirk recorded**: `dart run build_runner build` must use `--force-jit` in
  this repo — the camera plugin's `objective_c` dependency declares native build hooks,
  and `dart compile aot-snapshot` (build_runner's default AOT path) refuses to compile
  build scripts when hooks are present. Documented in CLAUDE.md.
- The schema-verifier test is fixture machinery (guard); it validates generated
  snapshots rather than red→green behavior and is not claimed as TDD evidence.

## Not verified

- Behavior under real app lifecycles (backgrounding, kill mid-transaction) — SQLite's
  journal covers this by design; observed evidence arrives with Sprint 3+ integration
  journeys.
- Media files, reconciliation, Start Over — Sprint 4 scope by plan.

## Carry forward

- Sprint 3 (simulated vertical slice) can now wire LoadCompanion/SaveDailyCheckIn use
  cases over this repository; an in-memory fake repository must run the same contract
  suite.
- Start Over (with installation-id rotation) lands in Sprint 4 alongside media
  lifecycle; the repository will grow exactly the operations those tests demand.

## Diminishing returns

No repository streams/watch queries yet (no UI consumer exists); no generic DAO layer;
no soft deletes or audit tables — all would be speculation today.
