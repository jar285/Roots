# ADR 0001: Sprint 0 repository and toolchain baseline

**Date:** 2026-09-01
**Status:** accepted

## Decision

Initialize the greenfield Phase 1 repository as a single Flutter package named `roots`
targeting iOS, Android, and macOS, pinned to the locally installed Flutter 3.38.5
stable / Dart 3.10.4 toolchain, with exact dependency pins and the approved documentation
committed unchanged before any scaffolding.

## Context

The approved Phase 1 contract (design spec, development philosophy, UI/UX philosophy,
power words) predates any code. Sprint 0's outcome per the development philosophy:
confirm targets and toolchain, pin versions, establish commands, record deviations.

Decisions folded into this baseline:

1. **Toolchain pin: Flutter 3.38.5 stable / Dart 3.10.4.** The installed, verified
   version. It is Homebrew-managed, so `brew upgrade` could move it; the README asserts
   the expected version and `pubspec.yaml` constrains the Dart SDK to `>=3.10.4 <3.11.0`
   so drift is detected rather than silent. No FVM until version drift actually bites.
2. **Identifiers: package `roots`, org placeholder `app.roots`** (user-confirmed
   2026-09-01). Display strings say "Plant Selfie"; the database file stays
   `plant_selfie.sqlite` per spec Appendix A. The real bundle id must be chosen before
   Sprint 6 device work. Codename-stable naming avoids a mass rename when the public
   product name lands.
3. **Platforms: ios, android, macos only.** No web/windows/linux directories — macOS is
   the reviewer surface named by the spec; the others imply support the product does not
   promise. Generated minimums: iOS 13.0, Android `flutter.minSdkVersion` (API 24 on this
   Flutter), macOS 10.15 — Flutter defaults kept; revisit only with evidence.
4. **Exact dependency pins** (resolved 2026-09-01 against Dart 3.10.4):
   flutter_riverpod 3.3.2, go_router 17.5.0, drift 2.31.0, drift_flutter 0.2.8,
   path_provider 2.1.6, camera 0.12.0+2, image 4.9.2, uuid 4.6.0; dev: drift_dev 2.31.0,
   build_runner 2.15.1, flutter_lints 6.0.0. Note: drift ≥ 2.32 requires Dart > 3.10
   (its analyzer dependency), so the drift cluster stays at 2.31.x until Flutter is
   deliberately upgraded. `cupertino_icons` (scaffold default) removed as unused.
5. **`integration_test` deferred to Sprint 3, `patrol` to Sprint 7.** Until those
   surfaces exist, the standard commands referencing them are reported "not applicable,
   with reason" per spec §10. Format/analyze commands cover `lib test` only until an
   `integration_test/` directory exists.
6. **OS backups: excluded** (user-confirmed 2026-09-01). The SQLite database and managed
   media directory will be excluded from iCloud/Google auto-backup so the privacy copy
   "Your selfie stays on this device" is literally true. Cost accepted: device loss loses
   the plant until Phase 1B continuity. Platform configuration lands in Sprint 6; copy in
   Sprint 3.
7. **Single package, layered `lib/`** (domain / application / contracts / infrastructure
   / presentation) rather than a local domain package. Domain purity ("no Flutter, Drift,
   dart:io, dart:ui imports") is enforced by a unit test from Sprint 1. Promote domain to
   a separate package only if erosion is observed, via a new ADR.

## Environment facts recorded at baseline (evidence: `flutter doctor -v`, 2026-09-01)

- **Xcode absent** (Command Line Tools only): iOS/macOS builds and the macOS reviewer
  run are blocked until the user installs full Xcode. Hard gate before Sprint 3.
  `flutter test`/`analyze`/`format`/`create` verified working without it.
- Disk was freed from 8.9 GiB to 60 GiB available (user-approved cleanup) to unblock the
  Xcode install.
- **Android toolchain stale** (no cmdline-tools, licenses unaccepted, ANDROID_HOME unset;
  obsolete API-30 components removed): must be updated before Sprint 6, not earlier.

## Alternatives rejected

- *Upgrade Flutter first*: adds risk with no Phase 1 need; the installed stable toolchain
  passes all checks.
- *Melos/monorepo or a separate domain package now*: speculative structure; the import
  test provides the guarantee at near-zero cost.
- *Scaffolding web/desktop-all platforms*: implies unsupported product surfaces.
- *Caret version ranges*: the spec requires reproducible setup; exact pins plus the
  committed lockfile make clean-checkout builds deterministic.

## Consequences

Reproducible clean-checkout setup on this toolchain; honest, dated record of environment
gaps; drift upgrades become deliberate; the repo carries no deferred-phase scaffolding.
Reopen the toolchain pin when a dependency or platform requirement demands a newer Dart
SDK, via a new ADR.
