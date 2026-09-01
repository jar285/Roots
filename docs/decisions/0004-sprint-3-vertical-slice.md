# ADR 0004: Sprint 3 vertical-slice decisions

**Date:** 2026-09-01
**Status:** accepted

## Decision

1. **Event id is resolved before commit** (`DailyCheckInDraft.proposedEventId`): spec
   A.9 fixes managed photo filenames to "event id + extension", and spec §5.4 commits
   the event *referencing the final filename* before promotion — so the id must exist
   before the row does. The application layer resolves it (today's existing id, else a
   fresh id from IdSource) and passes it on the draft; the repository uses it on create
   and ignores it on update (the stored id always wins).
2. **Sprint 3 media shortcut (recorded debt):** ManagedMediaStore starts with a direct
   final-name write (`<eventId>.jpg`) and no staging pipeline. Staging names, atomic
   promotion, remove-old-only-after-durable, and launch reconciliation are Sprint 4's
   named outcome; until then an interrupted save can orphan at most one final-named
   file, which Sprint 4's reconciliation will sweep. Repayment trigger: Sprint 4 starts.
3. **All platforms use SimulatedCameraSource until Sprint 6.** It produces a small
   deterministic placeholder JPEG (seeded by the local date), so journeys are
   reproducible and no camera hardware or permission exists anywhere yet.
4. **No PrepareDailyCheckIn use case yet.** LoadCompanion already returns today's event
   and the projected plant; a separate preparation use case would be a pass-through
   (Ousterhout). It gets created in Sprint 6 when permission orchestration gives it a
   real job.
5. **Application layer stays Riverpod-free.** Use cases are plain classes
   (LoadCompanion, SaveDailyCheckIn); Riverpod providers construct them and own async
   state (loading/data/error) per spec §5.2. The check-in wizard's draft (photo + mood)
   is flow-scoped state that dies with the flow.
6. **Plant rendering is a deterministic placeholder** (pot, stem trunk scaled by
   height, simple element marks) with one concise Semantics summary node. The full
   event-styled painter, motion, and goldens are Sprint 5's outcome — the placeholder
   only proves reconstruction visibly.
7. **integration_test joins the toolchain now** (per ADR 0001): the deterministic
   journey runs on the macOS reviewer target; format/analyze commands grow the
   `integration_test` directory.
8. **Database and media locations:** the SQLite file is `plant_selfie.sqlite` (spec
   A.2) under the app's support directory via drift_flutter; managed photos live in
   `<app documents>/plant_selfie_media/`. Adapters take injected directories so tests
   never touch real app storage; only `main.dart` calls path_provider.

## Context

Development philosophy Sprint 3: "Home through capture simulation, mood, confirmation,
persistence, and reconstructed plant; before-today and completed-today states; app
relaunch behavior" — widget tests for primary states plus a deterministic integration
journey, no backend or camera hardware.

## Alternatives rejected

- Repository-generated ids with post-commit file rename: contradicts spec §5.4's
  commit-references-final-name order and complicates Sprint 4's staging design.
- Building the full staging pipeline now: belongs to Sprint 4's outcome and would delay
  the first demonstrable product moment without adding reviewable behavior this sprint.
- A provider per value / use case interfaces: shallow wrappers; spec §5.2 explicitly
  warns against them.

## Consequences

The first end-to-end product moment exists on the reviewer surface; Sprint 4 hardens
media exactly where the recorded debt says; Sprint 6 swaps the camera adapter behind an
existing contract without touching the flow.
