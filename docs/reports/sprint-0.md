# Sprint QA Report

## Sprint

Sprint 0 — repository and decision baseline. Intended outcome: confirmed targets and
toolchain, pinned versions, working standard commands, preserved documentation, recorded
decisions and environment gaps.

## Spec slice

Development philosophy "Sprint 0: repository and decision baseline" (outcome + evidence),
design spec §10 standard commands, §7 tool selection, and the setup bar. Invariants at
risk: "Phase 1 can be built, run, and reviewed with no backend"; truthful reporting.

## Changes

- Git repository initialized; the four approved documents committed alone and unchanged
  as the root commit (`5b5c37c`), before any scaffolding.
- Flutter 3.38.5 scaffold for ios/android/macos as package `roots` (org placeholder
  `app.roots`); demo counter replaced by a minimal shell + smoke widget test.
- Exact dependency pins (see ADR 0001), committed lockfile.
- CLAUDE.md, README, ADR template, ADR 0001, reviewer guide.

## Evidence

- Command: `git log --oneline` / `git diff HEAD -- docs/` after scaffold
  - Result: docs-first root commit exists; diff empty (docs byte-identical)
  - Scope: documentation preservation
- Command: `flutter pub get` (repo and fresh clone)
  - Result: "Got dependencies" against exact pins; drift cluster resolved at 2.31.x
  - Scope: dependency selection and reproducibility
- Command: `dart format --output=none --set-exit-if-changed lib test`
  - Result: "Formatted 2 files (0 changed)" — exit 0
  - Scope: formatting baseline
- Command: `flutter analyze`
  - Result: "No issues found!"
  - Scope: static analysis baseline (flutter_lints 6.0.0)
- Command: `flutter test`
  - Result: "All tests passed!" (1 smoke widget test) — also proves tests run with no
    Xcode installed
  - Scope: test harness baseline
- Observation: clean-checkout validation — `git clone` to a scratch directory, then all
  four commands from the fresh clone
  - Result: all passed identically
  - Scope: setup-from-clean-checkout requirement

## Failure paths

None in product scope this sprint (no product behavior exists). Environment failure
paths exercised: version solving with the newest drift_dev failed against Dart 3.10.4;
resolved by jointly solving the drift cluster at 2.31.x and recording it (ADR 0001).

## Architecture check

Source of truth untouched (no persistence yet). Directory layering documented in
CLAUDE.md; no speculative code, services, or deferred-phase scaffolding added.
`cupertino_icons` removed as unused.

## Privacy and accessibility

No product surfaces yet. Privacy-affecting decision recorded: database and managed media
will be excluded from OS backups (user-confirmed; config lands Sprint 6). README privacy
copy matches that decision.

## Variance

- `dart format`/command list covers `lib test` only until `integration_test/` exists
  (Sprint 3) — spec §10 allows "not applicable, with reason".
- Org placeholder `app.roots` until a real bundle id is chosen (before Sprint 6).

## Not verified

- `flutter run -d macos` — **not verified: Xcode is not installed** (Command Line Tools
  only). Disk was freed to 60 GiB for the user's Xcode install; the run check moves to
  the Sprint 3 gate at the latest.
- `flutter test integration_test` — not applicable: directory deliberately absent until
  Sprint 3.
- `patrol test` — not applicable until Sprint 7.
- Android build — not applicable this sprint; toolchain gaps recorded in ADR 0001.

## Carry forward

- User: install full Xcode; then `sudo xcode-select --switch …` + `runFirstLaunch`.
- Sprint 1 ADR: normalization semantics, maturity definition, palette/morphology id
  derivation, repo-owned PRNG (proposals already recorded in the approved plan).
- Before Sprint 6: Android SDK update; real bundle id; backup-exclusion platform config.

## Diminishing returns

No CI, no FVM, no custom lint rules, no domain package split — each deferred until
evidence demands it.
