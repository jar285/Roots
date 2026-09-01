# 🌱 Roots

**Plant Selfie** *(working title — "Roots" is the codename)* — a private, calm daily
companion. Once a day you take one selfie, say how you feel, and watch one small,
deterministic contribution grow a personal plant. Over weeks the plant becomes a visual
history of your reflections: every branch, leaf, and decoration traceable to the day and
mood that created it.

> One private daily check-in adds a visible piece to a plant that remembers its history.

- **Accountless & offline-first** — the app opens straight into your companion. No
  sign-up, no server, no network required.
- **Self-reported mood** — you choose from five moods. The app never infers emotion
  from your face.
- **No pressure mechanics** — no streaks, no decay, no guilt. Missing a day costs
  nothing.
- **Real data control** — edit today's check-in, delete any day, or Start Over
  completely. Deletion is a tested product feature, not a promise.
- **Private by architecture** — photos live only in the app's private storage and are
  excluded from OS backups in Phase 1.

## How it works

Each confirmed check-in is stored as one canonical **GrowthEvent** — at most one per
local calendar day, enforced by a unique SQLite index, not UI discipline. The plant you
see is never stored: it is a **deterministic projection** replayed from the ordered
events, so restarting the app always reconstructs the identical plant. Every
random-looking flourish comes from the event's stored seed, every event records the
algorithm version that shaped it, and history keeps the colors it was born with — 
changing today's mood never repaints last month.

```
        confirm check-in                     replay (deterministic)
  ┌──────────────────────────┐            ┌──────────────────────────┐
  │ selfie + mood + one      │   append   │ ordered GrowthEvents     │
  │ clock reading            ├──────────► │ (SQLite via Drift)       │
  └──────────────────────────┘            └───────────┬──────────────┘
                                                      │ versioned projector
                                                      ▼
                                          ┌──────────────────────────┐
                                          │ PlantState (in memory)   │
                                          │ → painted plant          │
                                          └──────────────────────────┘
```

## Status

Phase 1 is being built in evidence-driven sprints
([development philosophy](docs/_architecture/development-philosophy.md)); every sprint
ships with an ADR and a QA report that separates verified from not verified.

| Sprint | Outcome | State |
|---|---|---|
| 0 | Repository, pinned toolchain, standard commands | ✅ [report](docs/reports/sprint-0.md) |
| 1 | Deterministic domain: growth rules, seeded RNG, versioned projection | ✅ [report](docs/reports/sprint-1.md) |
| 2 | Canonical storage: Drift schema, daily uniqueness, repository contract | ✅ [report](docs/reports/sprint-2.md) |
| 3 | Simulated vertical slice on macOS (Home → confirm → grown plant) | 🔜 |
| 4 | Same-day correction, deletion, Start Over, media reconciliation | 🔜 |
| 5 | Plant painter, historical styling, accessibility, goldens | 🔜 |
| 6 | Real mobile camera & permissions | 🔜 |
| 7 | Release journey (Patrol, clean-checkout proof) | 🔜 |

**Targets:** iOS and Android are the product surfaces. macOS is a deterministic
simulation/reviewer surface (simulated camera — desktop camera support is not a product
promise).

## Getting started

Prerequisites:

- **Flutter 3.38.5 stable** (Dart 3.10.4) — verify with `flutter --version`; dependency
  pins target this toolchain ([ADR 0001](docs/decisions/0001-sprint-0-baseline.md)).
- **Tests, analysis, formatting need nothing else** — no Xcode, no Android SDK, no
  backend.
- To *run* the macOS reviewer build or build for iOS: full Xcode (licensed, first-launch
  completed).
- To build for Android (Sprint 6+): Android SDK with platform 35+, accepted licenses,
  JDK 17/21.

Everyday commands:

```bash
flutter pub get
dart format --output=none --set-exit-if-changed lib test
flutter analyze
flutter test                       # 96 tests: domain + storage
flutter run -d macos               # reviewer shell (requires Xcode)
```

After changing the database schema:

```bash
dart run build_runner build --delete-conflicting-outputs --force-jit
```

(`--force-jit` is required — see [CLAUDE.md](CLAUDE.md) for why, plus the schema-fixture
workflow.)

## Repository layout

```
lib/
  domain/          pure Dart rules & projection — no Flutter/Drift/IO imports (test-enforced)
  application/     use cases (from Sprint 3)
  contracts/       CompanionRepository, IdSource, … — the seams adapters implement
  infrastructure/  Drift database & repository, UUID id source; media/camera arrive later
  presentation/    screens, theme, plant painter (from Sprint 3)
test/              mirrors lib/; includes the reusable repository contract suite
drift_schemas/     committed schema fixtures (v1 = oldest shipped)
docs/
  superpowers/specs/   the approved Phase 1 design spec
  _architecture/       development, UI/UX, and review-lens philosophies
  decisions/           ADRs — every deliberate choice, with alternatives
  reports/             sprint QA reports — evidence, not claims
  review/              reviewer guide toward the spec's 30-minute path
```

The four documents under `docs/superpowers/specs/` and `docs/_architecture/` are the
**approved product contract** — committed unchanged as the repository's root commit and
never edited casually.

## Reviewing

Start with the [reviewer guide](docs/review/reviewer-guide.md). The short version: clone,
run the four commands above, and read the sprint reports — each one states exactly what
was verified, how, and what wasn't. The pacing harness
(`flutter test test/domain/pacing_harness_test.dart`) prints how the plant grows over
30/90/180/365 simulated days.

## Privacy

Your selfie stays on this device. Photos are processed locally, stored only in the app's
private documents area, excluded from OS backups in Phase 1, and never uploaded —
there is no server. Mood is always your own words, never an inference. Individual
deletion and Start Over are verified at the database, file, and UI levels as they land.

## What this deliberately is not

A streak tracker, a social network, an emotion-recognition system, a cloud service, or a
showcase of speculative architecture. The
[design spec](docs/superpowers/specs/2026-08-21-plant-selfie-design.md) defers accounts,
sync, notifications, and AI until the local product has proven its worth — and the
codebase contains no scaffolding for any of them.
