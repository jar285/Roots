# Reviewer guide

This guide grows sprint by sprint toward the spec's thirty-minute review path
(design spec §13). It never claims a step that is not yet possible.

## Current state (after Sprint 3)

1. Read spec §1–3 for the product contract:
   [2026-08-21-plant-selfie-design.md](../superpowers/specs/2026-08-21-plant-selfie-design.md).
2. From a clean checkout, run:

       flutter pub get
       dart format --output=none --set-exit-if-changed lib test
       flutter analyze
       flutter test

   All four must pass with only the Flutter 3.38.5 SDK installed — no Xcode, no Android
   SDK, no backend, no network beyond pub.dev. The suite includes the deterministic
   domain (the spec A.3 worked examples verbatim, replay structural equality, historical
   style retention, caps/maturity, the unknown-algorithm-version error) and the storage
   layer (repository contract, SQLite-enforced daily uniqueness — including a raw-insert
   bypass test — competing-write resolution, corruption detection, reopen durability,
   and the v1 schema-fixture validation).
3. `flutter test test/domain/pacing_harness_test.dart` prints the growth stats for
   30/90/180/365 simulated daily check-ins (the spec's maturity validation gate; visual
   review happens at Sprint 5).
4. With full Xcode installed, the deterministic reviewer journey runs end-to-end on the
   macOS target — real SQLite, real managed-media directory, simulated camera, and a
   relaunch reconstruction check:

       flutter test integration_test -d macos

5. `flutter run -d macos` launches the real app: empty Home → TAKE TODAY'S SELFIE
   (simulated capture) → mood → confirmation → the grown plant; quit and relaunch to
   watch the plant reconstruct from stored events. Same-day re-entry shows REVIEW
   TODAY'S CHECK-IN and replaces today's event instead of adding growth. The plant
   rendering is a Sprint 3 placeholder; the real painter arrives in Sprint 5.

## Not yet reviewable
- History, event detail, deletion, Start Over, media reconciliation — Sprint 4.
- Painter, historical styling, accessibility, goldens — Sprint 5.
- Real mobile camera and permissions — Sprint 6.
- Patrol journey and release evidence — Sprint 7.

Each sprint's QA report in [../reports/](../reports/) lists exactly what was verified and
how, and what was not.
