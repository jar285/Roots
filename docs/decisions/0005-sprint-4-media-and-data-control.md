# ADR 0005: Sprint 4 media lifecycle and data-control semantics

**Date:** 2026-09-01
**Status:** accepted

## Decision

1. **Staged files live in a `staging/` subdirectory** of the managed media directory,
   named `<eventId>.<updatedAtUtcMs>.jpg`. The embedded timestamp is the discriminator
   reconciliation needs: a staged file is promoted only when an event exists whose
   `updatedAtUtc` equals the tag (that exact confirmation committed); otherwise the
   staged file belongs to an abandoned save and is removed. This resolves the ambiguous
   same-day-edit interruption (event exists either way) exactly, not heuristically.
2. **Promotion is an atomic same-volume rename** of the staged file over the final name
   `<eventId>.jpg`. On a same-day photo replacement this satisfies spec §4.5's "the old
   managed photo is removed only after the replacement is durable" — the rename IS the
   removal, and it happens after the database commit.
3. **The media store owns photo processing** (spec §5.4 steps 2–4):
   `prepareCapturedPhoto` validates the bytes decode as an image, resizes to a maximum
   800-pixel edge, encodes JPEG at quality 85, and writes the staged file. Undecodable
   bytes throw a typed `InvalidPhotoException`; nothing is written. Processing runs on
   the calling isolate for now — moving it to a background isolate is Sprint 6's
   low-end-device work (spec risk table).
4. **Reconciliation** (`ReconcileManagedMedia`, run at every launch by the composition
   root) enumerates staged and final files and repairs the three interruption states:
   staged with a matching committed event → promote; staged without one → remove; final
   file referenced by no event → remove. It returns counts for a privacy-safe
   diagnostic and is idempotent.
5. **Keep-existing-photo on same-day review**: `SaveDailyCheckIn`'s photo becomes
   optional. Null photo + existing event → no media work, draft keeps the stored
   filename (repository semantics from ADR 0003). Null photo + no existing event is a
   programming error (StateError).
6. **Deletion order**: transactional row delete first, then idempotent file removal.
   The outcome names the cleanup state (removed / already missing / failed) — a failed
   removal leaves an orphan that the next reconciliation sweeps; per the UI/UX
   philosophy the event disappears immediately and no message is shown unless the user
   can act.
7. **Start Over order**: one repository transaction deletes all events and replaces the
   installation id (new UUID from IdSource), then managed media is removed best-effort
   (any stragglers are unreferenced orphans for reconciliation). The repository grows
   `startOver(nextInstallationId)`, contract-tested on both implementations.
8. **History reads are repository reads** (newest first by reversing canonical order);
   thumbnails come from `readManagedPhoto`, which returns null for missing files so the
   UI renders the spec's neutral placeholder ("Photo unavailable. Your check-in and
   growth are still here.").

## Context

Development philosophy Sprint 4: "review today's event; same-day replacement; event
deletion; Start Over; managed-media staging and reconciliation" with database,
installation-identity, and file assertions after every destructive path, plus
missing-photo and interrupted-write tests. This repays the direct-write shortcut
recorded in ADR 0004 #2.

## Alternatives rejected

- Promote-only-when-final-missing: silently drops the new photo when an edit crashed
  after commit but before promotion (event/photo mismatch); the timestamp tag decides
  every case exactly.
- Media work inside the database transaction: impossible — filesystem and SQLite cannot
  share atomicity (spec §5.4); reconciliation is the honest bridge.
- Soft-deleting events or keeping a trash: speculative state with no Phase 1 user need.

## Consequences

Every interruption point around a save or delete converges to a consistent state after
one reconciliation pass; deletion and Start Over are observable at database, identity,
file, and UI levels; the Sprint 3 media debt is repaid on schedule.
