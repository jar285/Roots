# Plant Selfie Phase 1 Design Spec

**Original date:** 2026-08-21
**Revised:** 2026-09-01
**Status:** Revised target spec for a greenfield Phase 1 (accountless local-first companion)
**Audience:** Product, design, Flutter engineering, QA, and AI coding agents

## 1. Product thesis

Plant Selfie turns a small daily reflection into a visible, private plant that grows over time.

The smallest complete loop is:

1. Open the app.
2. Take or simulate today's selfie.
3. Choose a mood.
4. Confirm the check-in.
5. See one deterministic contribution added to the plant.
6. Revisit, correct, or delete the event later.

The plant is not a score, diagnosis, streak, or punishment mechanism. It is a personal record. The user reports their own mood; the app never infers emotion from a face.

Phase 1 succeeds when this loop is delightful, reliable, explainable, and reviewable without an account or backend.

## 2. Phase boundaries

### Phase 1: local companion

- Flutter app for iOS and Android.
- One private companion per app installation.
- Accountless, offline-first launch and daily use.
- Camera capture on supported mobile devices.
- A simulation path for macOS, automated tests, and reviewers without a camera.
- One growth-producing check-in per local calendar day.
- Same-day review and correction.
- Event history with individual deletion.
- Explicit Start Over flow for all local data.
- Deterministic plant reconstruction from canonical events.
- Accessible dark retro interface with reduced-motion support.

### Phase 1B: optional continuity

Only pursue this phase after the local experience is proven and users ask for continuity across installs or devices.

- Optional account creation.
- Backup and restore.
- Cross-device sync.
- Conflict resolution.
- Remote deletion verification.

Authentication is not a Phase 1 runtime dependency. A backend must provide a clear user benefit before it is introduced.

### Out of scope for Phase 1

- Emotion recognition or biometric analysis.
- Social feeds, sharing, leaderboards, or streak competition.
- Cloud accounts, remote profiles, or multi-device sync.
- Multiple plants or people within one installation.
- Plant health penalties, dying plants, or shame-based copy.
- Push notifications.
- Generative AI.
- Persisted plant snapshots or distributed event systems.
- Desktop camera support as a product promise.

## 3. System guarantees

The following statements are architectural invariants:

1. Growth events are the source of truth.
2. Plant state is a deterministic in-memory projection of ordered events.
3. A local date has at most one active growth event per installation.
4. Reconfirming the same local date updates that event; it does not add more growth.
5. Every random-looking choice comes from the event's stored seed and algorithm version.
6. Historical growth retains the style assigned by its source event.
7. Deleting an event removes its media and contribution after projection rebuild.
8. Start Over removes all local events and managed media, then creates a fresh installation identity after explicit confirmation.
9. Missing or corrupt media never prevents history or plant reconstruction.
10. Time, identifiers, randomness, storage, camera input, and file operations are replaceable in tests.
11. Phase 1 can be built, run, and reviewed with no backend.

If implementation and this section disagree, either the implementation changes or this document is deliberately amended with a decision record.

## 4. Domain model

### 4.1 GrowthEvent

A GrowthEvent is the canonical record of one daily check-in.

| Field | Type | Purpose |
|---|---|---|
| id | UUID/string | Stable event identity |
| installationId | UUID/string | Namespaces data to this installation |
| localDate | YYYY-MM-DD | Enforces the daily rule |
| checkedInAtUtc | timestamp | Confirmation time and ordering context |
| timezoneOffsetMinutes | integer | Explains how localDate was derived |
| timeCategory | enum | morning, afternoon, evening, or night |
| mood | enum | happy, mysterious, energetic, calm, or silly |
| selfieFileName | string | Safe filename inside the managed media directory |
| randomSeed | integer | Replays stochastic choices |
| algorithmVersion | integer | Preserves old rendering behavior |
| growthDelta | value object | Resolved growth contribution |
| createdAtUtc | timestamp | Creation audit field |
| updatedAtUtc | timestamp | Correction audit field |

Uniqueness is enforced on installationId plus localDate. localDate, timezoneOffsetMinutes, and timeCategory are derived from one checkedInAtUtc clock reading when the user confirms.

The database stores resolved growthDelta as well as inputs. This makes past events explainable and protects them from accidental changes to future algorithms.

### 4.2 GrowthDelta

GrowthDelta contains:

- height increase;
- branch increase;
- leaf increase;
- decoration increase;
- spread factor;
- prefers vertical growth;
- prefers spiral growth;
- event palette identifier;
- event morphology identifier.

All values are normalized and capped before persistence.

### 4.3 PlantState

PlantState is derived, not independently edited.

It contains:

- effective height;
- ordered branch elements;
- ordered leaf elements;
- ordered decorations;
- maturity state;
- event count;
- the date of the newest event.

Every rendered element includes sourceEventId and the event-specific visual attributes needed to draw it. Applying a new mood does not repaint earlier elements.

### 4.4 Projection

Projection uses this order:

1. localDate ascending;
2. checkedInAtUtc ascending;
3. id ascending as a stable tie-breaker.

For each event, choose the projector registered for algorithmVersion, apply the stored growthDelta, and enforce global caps. Replaying the same ordered event set must produce structurally equal PlantState values.

Unknown algorithm versions are surfaced as a recoverable data error. They are never silently interpreted by the newest algorithm.

### 4.5 Daily correction semantics

If no event exists for today, confirmation creates one.

If an event already exists for today, the UI says the user is editing today's check-in. Confirmation replaces checkedInAtUtc, timezone offset, time category, mood, seed, and delta while preserving id and createdAtUtc. If a new photo was prepared, it also replaces selfieFileName; otherwise the existing photo remains. The old managed photo is removed only after the replacement is durable.

A rapid double submission must resolve to one event through a database transaction and unique constraint, not UI timing alone.

### 4.6 Deletion semantics

Deleting one event:

1. asks for confirmation;
2. deletes the database event transactionally;
3. removes its managed photo;
4. rebuilds PlantState from the remaining events;
5. reports a recoverable cleanup warning if the file was already missing or could not be removed.

Start Over:

1. names exactly what will be removed;
2. requires explicit confirmation;
3. clears all local events and managed photos;
4. replaces the installation id so the new companion is not linked to the reset history;
5. recreates an empty plant;
6. is tested at repository, file, and UI levels.

No fake logout is used as a data-reset mechanism.

### 4.7 Maturity

Geometry is bounded:

- maximum height: 500;
- maximum branches: 20;
- maximum leaves: 50;
- maximum decorations: 40.

When all relevant caps are reached, later days still create history events and show a mature-plant acknowledgement. They do not add persistent geometry beyond the caps. The experience celebrates continued reflection without suggesting failure or loss.

## 5. Architecture

### 5.1 Module boundaries

The intended dependency direction is inward:

    presentation -> application -> domain
                         |
                         v
                    repositories
                         ^
                         |
                infrastructure adapters

Suggested modules:

- domain
  - GrowthEvent, GrowthDelta, PlantState, Mood, TimeCategory
  - GrowthRules and versioned PlantProjector
- application
  - LoadCompanion
  - PrepareDailyCheckIn
  - SaveDailyCheckIn
  - DeleteGrowthEvent
  - StartOver
  - ReconcileManagedMedia
- data contracts
  - CompanionRepository
  - ManagedMediaStore
  - CameraSource
  - Clock
  - IdSource
  - SeedSource
- infrastructure
  - DriftCompanionRepository
  - AppDocumentsMediaStore
  - MobileCameraSource
  - SimulatedCameraSource
- presentation
  - Home
  - Capture
  - Mood
  - Confirmation
  - History
  - Event detail/edit
  - Settings and Start Over
  - PlantPainter

The domain has no Flutter, Drift, camera, file-system, or HTTP imports.

### 5.2 State ownership

Riverpod owns asynchronous application state and exposes explicit loading, data, empty, and error states. Widgets request use cases; they do not query Drift or mutate files.

Keep providers feature-scoped and intentional. Do not create a provider for every value. A route may own temporary UI state when no other feature needs it.

### 5.3 Persistence

Use Drift over SQLite for Phase 1 because the daily uniqueness rule, transactional updates, deletion, and schema migration are product requirements. Keep Drift behind CompanionRepository so the domain and tests do not depend on the database.

Do not persist PlantState in Phase 1. Measure projection with realistic event volumes first. Add a cache or snapshot only if profiling shows a user-visible problem, and treat it as disposable derived data.

Required schema versions and migrations are tested from the oldest shipped fixture to the newest schema.

### 5.4 Media boundary

Selfies are private managed files, not opaque paths supplied by the UI.

Save flow:

1. capture to a temporary location;
2. validate that the file exists and is an accepted image;
3. resize to a maximum 800-pixel edge and encode at quality 85;
4. write to a managed staging name;
5. commit the event referencing the final managed filename;
6. atomically promote the staged file;
7. reconcile orphaned staged or final files after interruption.

Repository and media operations cannot share a filesystem/database transaction, so reconciliation is a first-class use case. History renders a neutral missing-photo placeholder when a file is unavailable.

Do not store image bytes in SQLite. Do not retain the original capture after a processed managed copy succeeds.

## 6. User journeys

### 6.1 First launch

1. App opens directly to the companion.
2. A short, skippable explanation says the plant grows from one private daily check-in.
3. Empty plant, privacy note, and primary action are visible.
4. No account wall appears.

### 6.2 First check-in

1. User taps TAKE TODAY'S SELFIE.
2. On mobile, the app explains camera access immediately before the permission request.
3. User captures or retakes a photo. A reviewer may choose the simulation path.
4. User selects one self-reported mood.
5. Confirmation previews today's contribution and privacy state.
6. Save commits one event and returns Home to the grown plant.

### 6.3 Return before today's check-in

Home shows:

- the existing plant;
- a calm prompt for today's reflection;
- the primary capture action;
- access to history and settings.

There is no streak counter, overdue warning, or plant decay.

### 6.4 Return after today's check-in

Home shows today's check-in as complete and changes the primary action to REVIEW TODAY'S CHECK-IN. The user can edit mood/photo or leave it as recorded. Repeated visits do not add growth.

### 6.5 History and correction

History is newest first and shows date, mood, time category, and photo or placeholder. Event detail explains that this entry contributed specific growth. The user may edit today's event or delete any event.

Editing a past date is out of scope for Phase 1. Deletion remains available because user control is not optional.

### 6.6 Start Over

Settings includes Start Over in a clearly separated destructive section. The confirmation explains that plant history and locally managed photos will be permanently removed from this installation.

## 7. Tools and rationale

### Product

- Flutter and Dart for one mobile codebase and a macOS reviewer harness.
- Material 3 as the accessible component foundation.
- Riverpod for explicit asynchronous state ownership.
- go_router for named, testable navigation.
- Drift and SQLite for constraints, transactions, and migrations.
- camera for supported mobile capture.
- path_provider for the application documents boundary.
- image for deterministic local resizing and encoding.
- uuid for stable local identities.

Pin exact compatible versions in project metadata and lockfiles. The spec names responsibilities, not versions that will become stale.

### Quality

- flutter_test for domain, application, repository, painter, and widget tests.
- golden tests for high-value visual states.
- integration_test for the simulated deterministic journey.
- Patrol for the real mobile permission and camera boundary where supported.
- Injectable fakes for clock, ids, seed source, camera, repository, and managed media.

### Deferred continuity

If Phase 1B is approved, select the backend and authentication approach from current supported releases. Do not scaffold Django, JWT, or remote identity during Phase 1 merely in anticipation of that decision.

## 8. Product and design rules

1. The main action is obvious without instruction.
2. Mood selection is self-report, never inference.
3. Photos remain local in Phase 1.
4. The interface never punishes a missed day.
5. One daily event is enforced below the UI.
6. Historical contributions keep their visual identity.
7. Destructive actions state their scope and require confirmation.
8. Motion explains state change and respects reduced-motion settings.
9. Camera denial, cancellation, missing files, and storage failures have usable recovery paths.
10. Mobile is the product surface; desktop simulation is a review surface.

The detailed visual contract lives in the [UI/UX Design Philosophy](../../_architecture/ui-ux-design-philosophy.md).

## 9. Acceptance criteria

### Core behavior

- A fresh install reaches Home without network or authentication.
- One confirmed event produces one deterministic plant contribution.
- A second submission on the same local date updates the existing event.
- Concurrent same-day submissions cannot create duplicates.
- Restarting the app reproduces the same plant from stored events.
- Changing a later event does not repaint earlier growth.
- Deleting an event removes its projected contribution.
- Start Over removes events and managed media and replaces the installation identity.
- Reaching maturity does not block future history entries.

### Time correctness

- Local date, timezone offset, and time category are derived from one injected clock reading at confirmation.
- Timezone offset is stored with the event.
- Tests cover midnight boundaries, timezone changes, and daylight-saving transitions.
- The daily rule follows the device's current local calendar by design.

### Resilience and privacy

- The app works in airplane mode.
- Camera denial offers Settings and simulation/retry guidance as appropriate.
- Missing photo files show a placeholder without hiding event metadata.
- Interrupted media writes are reconciled on launch.
- Logs and analytics contain no image bytes, local media paths, or mood history.
- Delete and Start Over verification covers database rows, installation identity where applicable, staged files, final files, and derived in-memory state.

### Accessibility

- Primary flows are operable with screen readers.
- Text and meaningful controls meet WCAG AA contrast targets.
- Touch targets are at least 48 by 48 logical pixels.
- Text remains usable at 200 percent scaling.
- Mood choices are not communicated by color alone.
- Reduced motion removes non-essential growth animation.

## 10. Testing and delivery

### Build order

1. Pure time categorization, growth rules, caps, and versioned projection.
2. Drift schema, uniqueness constraint, repository contract, and migration tests.
3. Simulated camera vertical slice from Home through confirmation.
4. Same-day correction, event deletion, Start Over, and media reconciliation.
5. Plant painter, historical styling, accessibility, and goldens.
6. Mobile camera and permission adapter.
7. Integration and Patrol journeys on supported targets.

Each slice ends in a runnable, reviewable state.

### Test portfolio

Unit tests:

- time category boundaries;
- growth delta matrix;
- seeded silly mood;
- cap behavior and maturity;
- stable projection ordering;
- historical palette retention;
- unknown algorithm version;
- daily upsert semantics.

Repository and file tests:

- uniqueness under competing writes;
- insert, update, delete, and ordered reads;
- migration fixtures;
- staged media promotion;
- orphan reconciliation;
- missing-file deletion;
- full reset verification.

Widget and golden tests:

- empty Home;
- before-today and completed-today Home;
- mood selection and validation;
- camera denial and cancellation;
- history with present and missing photos;
- delete and Start Over confirmations;
- mature plant;
- large text and reduced motion.

End-to-end:

- simulated journey runs deterministically on the reviewer target;
- real mobile journey validates permission, capture, persistence, relaunch, edit, and deletion.

### Standard commands

    flutter pub get
    dart format --output=none --set-exit-if-changed lib test integration_test
    flutter analyze
    flutter test
    flutter test integration_test
    patrol test

If a directory or tool has not been introduced yet, the sprint report marks the command not applicable with a reason. It must not report an unrun check as passing.

## 11. Security and privacy

Phase 1 has no server and no remote identity.

- Request camera permission only in context.
- Store processed images only in the application's private documents area.
- Do not place managed selfies in a shared gallery unless the user explicitly exports them in a future phase.
- Do not infer sensitive traits or emotional state from image content.
- Do not log photo paths, image data, or personal reflection history.
- Treat local backups, device compromise, and OS-level storage as platform risks; do not claim end-to-end encryption.
- Make deletion observable and testable.
- Document any crash-reporting or analytics SDK before addition and scrub private fields.

If sync is introduced later, threat-model identity, authorization, transport, server retention, cache invalidation, conflict resolution, export, and verified deletion before implementation.

## 12. Definition of done

Phase 1 is done when:

- the local daily loop is complete on the supported mobile targets;
- the simulated reviewer loop runs without backend or camera hardware;
- all system guarantees are covered by automated tests at the appropriate boundary;
- installation-to-date uniqueness is enforced by SQLite;
- projection is deterministic across relaunches;
- media interruption and missing-file behavior are verified;
- individual deletion and Start Over clear every managed representation in scope, including identity rotation for Start Over;
- accessibility checks cover the critical flow;
- setup instructions reproduce a working build from a clean checkout;
- architecture and sprint reports distinguish evidence from assumptions;
- no deferred auth, sync, social, or AI work has leaked into the Phase 1 critical path.

## 13. Thirty-minute review path

1. Read Sections 1 through 3 for the product contract.
2. Run the unit and repository tests.
3. Launch the macOS simulation harness.
4. Create today's check-in and observe deterministic growth.
5. Relaunch and confirm identical reconstruction.
6. Edit today's mood and verify the event is replaced, not duplicated.
7. Delete the event and verify the plant rebuilds.
8. Run Start Over and inspect database, installation-identity, and managed-media assertions.
9. Review one mobile Patrol result for the real camera boundary.

## Decision record

| Decision | Choice | Reason |
|---|---|---|
| Phase 1 identity | One installation, no account | Removes a gate before user value exists |
| Source of truth | Canonical GrowthEvent rows | Supports replay, correction, deletion, and auditability |
| Plant persistence | Derived in memory | Avoids duplicate mutable state |
| Local database | Drift over SQLite | Provides transactions, uniqueness, and migrations |
| Photo storage | Managed private files | Keeps large blobs out of SQLite and makes lifecycle explicit |
| Daily policy | One event per current local date | Simple, testable, and timezone-aware |
| Mood | Explicit user selection | Honest and privacy-preserving |
| Historical style | Event-specific | Makes the plant a visual record rather than a global theme |
| Desktop | Simulation/reviewer harness | Avoids claiming unsupported camera parity |
| Backend | Deferred to Phase 1B | Must be justified by continuity needs |

## Open risks and validation gates

These are not invitations to widen scope. They are the assumptions most likely to require evidence:

| Risk | Current decision | Validation gate |
|---|---|---|
| Plant matures too quickly or slowly | Use the harvested caps and growth table | Simulate and visually review 30, 90, 180, and 365 daily events before locking tuning |
| Travel or clock changes surprise the daily rule | Use the device's current local calendar and store offset context | Test timezone crossings, midnight, daylight-saving changes, and manual clock changes; document observed behavior |
| Deleting an early event reflows later geometry | Rebuild from remaining ordered events; preserve source identity and style, not exact pixel positions | Review deletion examples and ensure UI copy never promises pixel-level preservation |
| Image processing strains low-end devices | Resize locally to an 800-pixel maximum edge | Profile peak memory and confirmation latency on the lowest supported device class |
| Crash between database and file operations leaves debris | Use recognizable staging names plus launch reconciliation | Fault-inject after every media save/delete step and inspect database, staged, and final files |
| Uninstall or OS backup behavior exceeds app control | Promise only app-managed local behavior | Verify platform backup configuration and keep copy narrower than the platform can guarantee |
| Replay or painting becomes slow with years of history | Keep PlantState derived and uncached | Benchmark realistic multi-year histories before approving snapshots |
| Mobile automation does not cover camera hardware uniformly | Separate deterministic simulation from focused device checks | Maintain a support matrix and one manual/device proof per release target |

If a gate fails, record the evidence and amend the relevant decision. Do not silently add a workaround that creates a second source of truth.

## Appendix A. Harvested product constants

These constants retain the strongest concrete details from the original concept. They are inputs to tests and design review, not permission to duplicate business rules across layers.

### A.1 Time of day

Use one local timestamp from the injected clock:

| Category | Local hour |
|---|---|
| morning | 05:00 through 11:59 |
| afternoon | 12:00 through 16:59 |
| evening | 17:00 through 20:59 |
| night | 21:00 through 04:59 |

### A.2 Storage, media, and render constants

| Constant | Value |
|---|---|
| Database file | plant_selfie.sqlite |
| Event table | growth_events |
| Metadata table | app_metadata |
| Seed height | 20 |
| Maximum height | 500 |
| Maximum branches | 20 |
| Maximum leaves | 50 |
| Maximum decorations | 40 |
| Selfie maximum edge | 800 pixels |
| JPEG quality | 85 |
| Initial algorithm version | 1 |

Managed photo filenames use the stable event id plus an extension chosen by the encoder. Temporary and staged names must be recognizable to reconciliation.

### A.3 Growth parameters

Start each calculation with:

| Property | Default |
|---|---|
| height increase | 10 |
| branch increase | 1 |
| leaf increase | 2 |
| decoration increase | 0 |
| spread factor | 0.5 |
| vertical | false |
| spiral | false |

Apply time modifiers:

| Time | Modifier |
|---|---|
| morning | height +5, decorations set to 1, vertical true |
| afternoon | branches +1, leaves +2, spread 0.7 |
| evening | decorations set to 2, spread 0.4 |
| night | decorations set to 1, spread 0.6, spiral true |

Then apply mood modifiers:

| Mood | Modifier |
|---|---|
| happy | leaves +2, decorations +1 |
| mysterious | branches +1, spiral true |
| energetic | height +8, branches +2, spread 0.8 |
| calm | leaves +1, spread 0.3 |
| silly | seeded additions: height nextInt(15), branches nextInt(3), leaves nextInt(4), decorations nextInt(2), spread nextDouble() |

Normalize values, apply caps during projection, and persist the resolved delta.

Worked examples:

| Time plus mood | Height | Branches | Leaves | Decorations | Spread | Vertical | Spiral |
|---|---:|---:|---:|---:|---:|---|---|
| morning + happy | 15 | 1 | 4 | 2 | 0.5 | true | false |
| morning + energetic | 23 | 3 | 2 | 1 | 0.8 | true | false |
| afternoon + calm | 10 | 2 | 5 | 0 | 0.3 | false | false |
| evening + happy | 10 | 1 | 4 | 3 | 0.4 | false | false |
| night + mysterious | 10 | 2 | 2 | 1 | 0.6 | false | true |

### A.4 Mood copy and base colors

| Mood | Supporting copy | Base accent |
|---|---|---|
| happy | Bright and open | #FFD166 |
| mysterious | Quietly strange | #9B5DE5 |
| energetic | Ready to move | #F15BB5 |
| calm | Slow and steady | #70D6A0 |
| silly | Playfully unpredictable | #4CC9F0 |

Mood labels and supporting copy require text or icon treatment; color alone is never the state indicator.

### A.5 Theme tokens

| Token | Value |
|---|---|
| background | #10151C |
| surface | #18212B |
| surface raised | #202C38 |
| primary text | #F4F7F8 |
| secondary text | #AEBBC6 |
| plant green | #70D6A0 |
| focus | #4CC9F0 |
| warning | #FFD166 |
| destructive | #FF6B6B |
| minimum corner radius | 12 |
| base spacing unit | 4 |
| primary content max width | 720 |

Final contrast is verified from rendered component pairs, not assumed from token values.

### A.6 Event palettes

Each event resolves a palette identifier. New geometry receives that palette and sourceEventId. Existing geometry is not recolored.

Painter tests must prove:

- changing today's mood changes only today's contribution;
- deleting an event removes only elements sourced from that event;
- replay produces the same element sequence and colors;
- empty and mature states remain legible.

### A.7 UI copy

Preferred copy:

- Empty Home title: GROW SOMETHING PERSONAL
- Empty Home support: One private check-in can add to your plant each day.
- Primary action before check-in: TAKE TODAY'S SELFIE
- Primary action after check-in: REVIEW TODAY'S CHECK-IN
- Mood title: HOW ARE YOU FEELING?
- Confirmation title: ADD TODAY'S GROWTH?
- Privacy note: Your selfie stays on this device.
- Camera denial: Camera access is off. Enable it in Settings, or use the reviewer simulation where available.
- Missing photo: Photo unavailable. Your check-in and growth are still here.
- Mature state: YOUR PLANT IS FULLY GROWN
- Mature support: Today's reflection has been saved to its story.
- Delete event title: DELETE THIS CHECK-IN?
- Start Over title: START OVER?
- Start Over support: This permanently removes your plant history and managed selfies from this installation.

Copy must remain calm, direct, and free of guilt, streak pressure, or false privacy claims.

### A.8 Persistence schema

growth_events requires:

- primary key on id;
- unique index on installation_id plus local_date;
- non-null checked_in_at_utc, timezone_offset_minutes, time_category, mood, selfie_file_name, random_seed, algorithm_version, growth_delta, created_at_utc, and updated_at_utc;
- validation when converting stored enums and growth data into domain values.

app_metadata stores installation id and current schema/application metadata. It does not store a second copy of plant state. Start Over replaces the installation id after event and media cleanup.

### A.9 Managed photo lifecycle

The managed media adapter provides:

- prepare captured file;
- promote staged file;
- resolve a safe managed path;
- remove one managed file idempotently;
- enumerate managed and staged files for reconciliation;
- remove all managed media.

Paths read from storage are validated to remain inside the managed directory before file operations.

### A.10 Painter contract

PlantPainter receives only immutable PlantState plus animation progress. It performs no storage reads, randomness, date logic, or state mutation.

Stable drawing order:

1. ground and pot;
2. trunk and stems;
3. branches;
4. leaves;
5. decorations;
6. mature-state flourish, when applicable.

The same PlantState and viewport produce the same final frame. Animation may reveal geometry, but it may not alter the stored result.
