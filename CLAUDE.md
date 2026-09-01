# Roots — agent instructions

Roots is the working codename. The product is **Plant Selfie**: a private, accountless,
offline-first daily companion. One selfie + one self-reported mood per local calendar day
adds one deterministic contribution to a personal plant. Do not rename the product; the
public name is undecided.

## Read these before changing behavior, in this order

1. [docs/superpowers/specs/2026-08-21-plant-selfie-design.md](docs/superpowers/specs/2026-08-21-plant-selfie-design.md) — product and system contract
2. [docs/_architecture/development-philosophy.md](docs/_architecture/development-philosophy.md) — execution, sprints, QA
3. [docs/_architecture/ui-ux-design-philosophy.md](docs/_architecture/ui-ux-design-philosophy.md) — when presentation changes
4. [docs/_architecture/power-words.md](docs/_architecture/power-words.md) — review lenses, only as needed

Those four files are the approved contract. Never edit them casually; a deliberate
amendment requires a decision record in `docs/decisions/`.

## Invariants (spec §3 — the short list)

- GrowthEvent rows are the only source of truth; PlantState is a deterministic in-memory
  projection of ordered events and is never persisted in Phase 1.
- At most one active event per (installationId, localDate), enforced by SQLite, not UI.
- Same-day reconfirmation updates the existing event; it never adds growth.
- Every random-looking choice replays from the event's stored seed + algorithmVersion;
  unknown versions surface as recoverable errors.
- Historical elements keep the style assigned by their source event.
- Deletion and Start Over clear every managed representation in scope; Start Over rotates
  the installation id. Missing media never breaks reconstruction.
- Clock, ids, seeds, camera, storage, and file operations are injectable in tests.
- Phase 1 builds, runs, tests, and reviews with no backend.

## Deferred — do not scaffold in Phase 1

Authentication, Django/JWT, cloud sync, remote accounts, social features, facial emotion
inference, push notifications, microservices, event buses, persisted PlantState snapshots,
plugin systems, generative AI, analytics SDKs.

## Architecture map

Dependency direction is inward: presentation → application → domain, with
infrastructure adapters implementing `lib/contracts/` interfaces.

- `lib/domain/` — pure Dart. No `package:flutter/`, `package:drift/`, `dart:io`,
  or `dart:ui` imports (a test enforces this).
- `lib/application/` — use cases (LoadCompanion, SaveDailyCheckIn, …).
- `lib/contracts/` — CompanionRepository, ManagedMediaStore, CameraSource, Clock,
  IdSource, SeedSource.
- `lib/infrastructure/` — Drift, media, and camera adapters.
- `lib/presentation/` — screens, theme, PlantPainter (immutable PlantState in, pixels out).

## Toolchain (pinned)

Flutter 3.38.5 stable / Dart 3.10.4. Dependencies are pinned exactly in `pubspec.yaml`;
upgrades are deliberate decisions recorded in `docs/decisions/`, never side effects.
Note: newest drift requires Dart > 3.10; drift stays at 2.31.x until Flutter is
deliberately upgraded.

## Standard commands

    flutter pub get
    dart format --output=none --set-exit-if-changed lib test
    flutter analyze
    flutter test

`flutter test integration_test` becomes applicable at Sprint 3; `patrol test` at Sprint 7.
Until then, reports mark them "not applicable, with reason".

Drift codegen (after editing `lib/infrastructure/drift/companion_database.dart`):

    dart run build_runner build --delete-conflicting-outputs --force-jit

`--force-jit` is required: the camera plugin's `objective_c` dependency declares native
build hooks, and build_runner's default AOT compilation refuses to run with hooks
present. When the schema version changes, also dump a new fixture and regenerate the
verifier helpers, then extend the migration tests:

    dart run drift_dev schema dump lib/infrastructure/drift/companion_database.dart drift_schemas/
    dart run drift_dev schema generate drift_schemas/ test/infrastructure/drift/generated/

## Working rules

- Follow the sprint workflow in the development philosophy: quote the spec slice, state
  the contract, write the failing proof first, implement, run proportional QA, and write
  a QA report to `docs/reports/` distinguishing verified / partially verified / not
  verified. Never report an unrun check as passing.
- Decision records live in `docs/decisions/` (template: `0000-template.md`).
- Reviewer instructions live in `docs/review/reviewer-guide.md`.
- macOS is a reviewer/simulation surface, not a product target; iOS and Android are the
  product surfaces. Desktop camera support is not promised.
- Treat errors, deletion, privacy, and accessibility as product behavior.
