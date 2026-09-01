# Roots (Plant Selfie)

A private, calm daily companion. Once per local calendar day you take one selfie, report
your own mood, and watch one deterministic contribution grow a personal plant. The plant
is a visual history of your reflections — not a score, streak, or diagnosis. Accountless,
offline-first, and backend-free in Phase 1.

**Roots** is the working codename; **Plant Selfie** is the working product name. The
approved product, delivery, and design contract lives in [docs/](docs/) — start with the
[Phase 1 design spec](docs/superpowers/specs/2026-08-21-plant-selfie-design.md).

## Status

Sprint 0 (repository and decision baseline). No product screens yet; `lib/main.dart` is a
minimal shell proving the toolchain. See [docs/reports/](docs/reports/) for sprint QA
reports and [docs/decisions/](docs/decisions/) for decision records.

## Targets

- **iOS and Android** — the product surfaces (real camera capture).
- **macOS desktop** — a deterministic simulation/reviewer surface only (simulated camera).
  Desktop camera support is not a product promise.

## Setup from a clean checkout

Prerequisites:

- Flutter **3.38.5 stable** (Dart 3.10.4). Verify with `flutter --version`; this repo pins
  dependencies against that toolchain (see `docs/decisions/0001-sprint-0-baseline.md`).
- To *run* the app on macOS or iOS: full Xcode (not just Command Line Tools), then
  `sudo xcode-select --switch /Applications/Xcode.app/Contents/Developer` and
  `sudo xcodebuild -runFirstLaunch`.
- To *build for Android* (not needed until Sprint 6): Android SDK with cmdline-tools,
  platform 35+, accepted licenses, and JDK 17/21 for Gradle.
- Tests, analysis, and formatting need none of the above — only the Flutter SDK.

Commands:

    flutter pub get
    dart format --output=none --set-exit-if-changed lib test
    flutter analyze
    flutter test

Run the reviewer build (requires Xcode):

    flutter run -d macos

## Repository layout

    lib/domain/          pure Dart rules and projection (no Flutter/Drift/IO imports)
    lib/application/     use cases
    lib/contracts/       repository, media, camera, clock, id, and seed interfaces
    lib/infrastructure/  Drift, media, and camera adapters
    lib/presentation/    screens, theme, plant painter
    test/                mirrors lib/
    docs/                approved contract, decisions, sprint reports, reviewer guide

## Privacy

Selfies stay on this device: they are stored only in the app's private documents area and
are excluded from OS backups in Phase 1. There is no account, no server, no analytics, and
mood is always self-reported — never inferred from the photo.

## Reviewing

See [docs/review/reviewer-guide.md](docs/review/reviewer-guide.md) for the 30-minute
review path.
