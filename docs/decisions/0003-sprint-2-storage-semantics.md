# ADR 0003: Sprint 2 storage semantics

**Date:** 2026-09-01
**Status:** accepted

## Decision

Fix the storage-layer semantics for the canonical GrowthEvent store (spec §5.3, A.8)
before implementation.

1. **Installation identity** is created lazily by the repository: the first call that
   needs it generates a UUID v4 (via the injected IdSource), persists it in
   `app_metadata`, and every later call returns the same value — inside a transaction so
   two concurrent first calls cannot mint two identities. (Timing approved in the
   alignment plan.)
2. **Daily uniqueness is a schema guarantee**: `growth_events` carries a unique index on
   `(installation_id, local_date)`. The repository's upsert runs in a transaction, but
   the index is the guarantee (Lampson: the UI and even the repository merely cooperate
   with it).
3. **Upsert semantics** (spec §4.5): one intentional operation,
   `upsertDailyCheckIn(draft)`. No row for (installation, localDate) → insert with a new
   event id; existing row → update in place preserving `id` and `created_at_utc`,
   replacing checkedInAtUtc, offset, timeCategory, mood, seed, algorithmVersion, and
   delta. `selfieFileName` is nullable on the draft: null means keep the existing
   filename (required on first create — ArgumentError otherwise).
4. **Audit fields derive from the confirmation reading**: on insert,
   `created_at_utc = updated_at_utc = draft.checkedInAtUtc`; on update only
   `updated_at_utc` moves. No separate Clock dependency in the repository.
5. **Timestamps are stored as UTC milliseconds since epoch** (INTEGER columns, mapped
   manually) — exact round-trips, no silent second-precision truncation.
6. **Enums are stored as text names, GrowthDelta as a JSON text column**, both decoded
   with strict validation (spec A.8): any unknown enum value, missing key, or wrong type
   surfaces as a typed `CorruptEventDataException` naming the event — never a silent
   default.
7. **Hard delete frees the date**: deleting today's event allows a new check-in for the
   same date (a new event id). No tombstones in Phase 1.
8. **Reads are ordered by the canonical projection order** (`local_date`,
   `checked_in_at_utc`, `id`) in SQL; the projector still sorts defensively.
9. **Schema snapshots from v1**: the drift schema is exported
   (`dart run drift_dev schema dump`) into `drift_schemas/` and committed as the oldest
   shipped fixture; a SchemaVerifier test validates the runtime schema against it. Every
   future schema version adds a dump and a migration test from every older fixture.
10. **Shared contract tests**: repository behavior tests are written as a reusable suite
    run against the Drift implementation now, so a future in-memory fake (Sprint 3)
    must pass the identical suite (Liskov substitutability).

## Context

Sprint 2 of the approved plan: "Drift schema and migrations; one event per installation
and local date; repository insert, same-day update, read, and delete; stable ordering."

## Alternatives rejected

- Drift's default DateTime storage (second-precision or text): implicit truncation or
  format coupling; explicit millisecond integers are exact and boring.
- Splitting GrowthDelta into nine columns: heavier schema churn for data that is always
  read and written whole; JSON with strict validation keeps the schema stable.
- Soft-delete tombstones: Phase 1 has no sync; they would be speculative state.
- `drift`'s generated enum converters: spec A.8 demands explicit validation with a
  recoverable error type; manual mappers make that visible and testable.

## Consequences

The database is the uniqueness authority; corrupt rows are detectable, named, and
recoverable rather than silently coerced; migration testing is mechanical from v1
onward. Reopen any of this via a new ADR — in particular if Phase 1B sync ever needs
tombstones or server-assigned identity.
