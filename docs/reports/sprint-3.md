# Sprint QA Report

## Sprint

Sprint 3 — simulated vertical slice. Intended outcome: Home through capture simulation,
mood, confirmation, persistence, and the reconstructed plant; before-today and
completed-today states; app relaunch behavior — no backend, no camera hardware.

## Spec slice

Design spec §6 (user journeys 6.1–6.4), §5.2 (Riverpod state ownership), §8 (product
and design rules 1, 2, 5, 9), A.7 (UI copy), §9 acceptance criteria: "a fresh install
reaches Home without network or authentication", "one confirmed event produces one
deterministic plant contribution", "a second submission on the same local date updates
the existing event", "restarting the app reproduces the same plant from stored events".
Invariants at risk: #3/#4 (daily rule and same-day update through a real UI), #11 (no
backend).

## Changes

- `lib/application/`: LoadCompanion (projection + today status + typed
  UnknownAlgorithmVersionException) and SaveDailyCheckIn (one clock reading → rules →
  managed photo named by event id → transactional upsert). Plain classes, Riverpod-free.
- `lib/contracts/`: Clock, SeedSource, CameraSource, ManagedMediaStore;
  DailyCheckInDraft gained `proposedEventId` (ADR 0004 #1, contract-tested on both
  repository implementations).
- `lib/infrastructure/`: FsManagedMediaStore (injected directory, event-id validation
  per A.9), SimulatedCameraSource (deterministic per local date, repo-owned seed fold),
  SystemClock, SystemSeedSource.
- `lib/presentation/`: token theme (A.5) + mood display data (A.4); Home with explicit
  loading/data/error states and empty/ready/completed/mature content; capture, mood,
  and confirmation screens; flow-scoped draft state; placeholder PlantView with one
  concise semantics summary. `lib/app.dart` (router per instance) + `lib/main.dart`
  composition root — the only file touching path_provider.
- `test/support/`: InMemoryCompanionRepository (passes the full repository contract
  suite), fakes, pumpApp helper. `integration_test/` joined the toolchain (ADR 0001).

## Evidence

All behavior test-first (failing/compile-failing observed before implementation):

- `flutter test` → **139 tests, all passed**; `flutter analyze` → no issues;
  `dart format --set-exit-if-changed lib test integration_test` → clean. (2026-09-01)
- Contract suite grew to 14 cases ×2 implementations: proposed id honored on create,
  ignored on update.
- Use cases (8): one clock reading feeds localDate/offset/category; delta equals
  GrowthRules.resolve exactly; photo named `<eventId>.jpg`; same-day second save
  updates the same event and reuses the managed name; unknown algorithm version
  surfaces typed.
- Adapters (7 + 2): filesystem store writes/overwrites under the injected directory,
  creates it on demand, rejects hostile event ids; simulated camera is decodable,
  ≤ 800 px, deterministic per date, distinct across dates.
- Widget tests (11): empty Home shows the A.7 copy and privacy note; before-today vs
  completed-today actions switch (TAKE TODAY'S SELFIE ↔ REVIEW TODAY'S CHECK-IN);
  capture offers use/retake/cancel and cancelling lands on a stable Home with no
  event; CONTINUE is disabled until a mood is chosen; confirmation states the privacy
  promise; the full journey grows the plant, stores one event + one managed photo;
  reviewing today shows the replacement copy and updates the same event id; the plant
  exposes one semantics summary node.
- **Integration journey on the macOS reviewer target**
  (`flutter test integration_test -d macos`): real SQLite file + real managed-media
  directory + simulated camera; empty Home → capture → mood → confirm → completed Home
  with one contribution and one managed photo on disk; then a relaunch against the same
  database file reconstructs the identical state. Result: **All tests passed** (exit 0).
  Build output: `✓ Built build/macos/Build/Products/Debug/roots.app`.

## Failure paths

Load errors render a calm error state with TRY AGAIN (specific copy for
UnknownAlgorithmVersionException); camera cancel returns Home with no event and no
error toast; save failure keeps the photo/mood, states "nothing was added yet", and
offers RETRY; the save button disables while saving (UI hint — the transaction + unique
index remain the guarantee).

## Architecture check

Dependency direction holds (domain purity guard still green); use cases are deep
single-operation modules; providers are feature-scoped with throwing defaults so a
missing override fails loudly; the draft never outlives the wizard; PlantView is
immutable-state-in, pixels-out.

## Privacy and accessibility

App opens straight to the companion — no account, no network, no permission prompts
(nothing to ask: capture is simulated). Photos land only in the injected private
directory. Mood options carry label + supporting phrase + selection state (never color
alone); primary buttons meet the 48 px minimum; the plant canvas is one semantic node.
No logging of paths, moods, or image data anywhere.

## Variance

- Same-day review re-runs the full flow (new simulated photo + mood) with explicit
  replacement copy; "keep existing photo" arrives with Sprint 4's event-detail work.
- Confirmation previews the contribution generically ("one new contribution…") — the
  numeric preview needs a resolve-at-confirm design decision, deferred.
- Edit-mode confirmation uses REVIEW TODAY'S CHECK-IN / UPDATE TODAY'S GROWTH — copy
  variance consistent with A.7's review action.
- PlantView is a deliberate placeholder (ADR 0004 #6); Sprint 5 owns the real painter.

## Not verified

- Save-failure UI path has no automated test yet (fakes don't fail); implemented but
  exercised only by code review. Sprint 4's correction work adds failing-adapter tests.
- History screen, event detail, deletion UI — Sprint 4 scope.
- Reduced-motion behavior: no non-essential motion exists yet to reduce; Sprint 5
  verifies it properly.
- 200% text scaling and golden baselines — Sprint 5.

## Carry forward

- Sprint 4 repays the media debt (staging, promotion, reconciliation, remove-old-after-
  durable) and adds history/detail/delete/Start Over + failing-adapter UI tests.
- Product decision open for Sprint 5 kickoff: the user asked about art-style directions
  (e.g. glassmorphism, game-style photoreal). The approved UI/UX philosophy locks Phase
  1 to dark organic retro and explicitly rejects glassmorphism/photoreal; changing it
  is a deliberate contract amendment via ADR before Sprint 5's painter work.

## Diminishing returns

No golden tests yet (visuals are placeholder — pinning them would freeze throwaway
pixels); no route guards for deep-linking into a half-empty wizard (unreachable in
product navigation); no provider for every value.
