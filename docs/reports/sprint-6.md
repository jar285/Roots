# Sprint QA Report

**Date:** 2026-09-02

## Sprint

Sprint 6 — mobile camera boundary. Intended outcome: real capture, retake, permission,
cancel, and processing flows on supported mobile targets; photos processed into managed
private storage; original temporary captures not retained.

## Spec slice

Design spec §5.1 (CameraSource / MobileCameraSource), §5.4 (media processing steps),
§6.2 (camera permission explained immediately before the OS request), §8.9 (camera
denial, cancellation, missing files, storage failures have usable recovery paths),
§9 resilience criteria, §11 privacy (request in context; no unprocessed originals
retained), A.7 denial copy; the spec's risk table item "image processing strains
low-end devices"; development philosophy Sprint 6 outcome and evidence list.
Decisions recorded first in ADR 0008.

## Changes

- **`CameraSource` now returns a sealed `CaptureResult`** — `CapturePhoto`,
  `CaptureCancelled`, `CapturePermissionDenied(permanentlyDenied)`,
  `CameraUnavailable(reason)` — replacing a nullable photo, so each outcome gets its
  own named recovery (ADR 0008 #3).
- **`MobileCameraSource`**: requests camera permission in context, prefers the front
  camera, captures once with audio disabled, hands bytes to the media boundary, and
  **deletes the OS temp file** so the processed managed copy is the only retained
  image (spec §5.4/§11). Its failure mapping is the pure, unit-tested
  `captureResultForError`.
- **Capture screen reworked** around the outcomes: photo review (USE THIS PHOTO /
  KEEP CURRENT PHOTO when editing today / RETAKE / CANCEL); denial with the A.7 copy
  verbatim plus OPEN SETTINGS (only when the OS will not prompt again), TRY AGAIN,
  CANCEL; camera-absent guidance with TRY AGAIN / CANCEL; cancellation returns Home
  quietly with no event and no error toast.
- **Image processing moved to a background isolate** (`Isolate.run` around a top-level
  pure `processPhotoBytes`), repaying ADR 0005 #3. Decode/resize/encode no longer run
  on the UI isolate; `InvalidPhotoException` semantics are preserved across the
  isolate boundary.
- **`permission_handler` 13.0.1** added as an earned, pinned dependency behind an
  injected `AppSettingsLauncher` seam (ADR 0008 #2).
- **Real bundle identifier `com.jesusrosario.roots`** applied to iOS, Android, and
  macOS; the Kotlin `MainActivity` was relocated to the matching package directory
  (a git rename, reported here).
- **Platform configuration**: iOS `NSCameraUsageDescription` (states the photo stays
  on the device); Android `CAMERA` permission with `android.hardware.camera` marked
  not required (recovery paths keep the app usable without one) and the app label
  corrected to "Plant Selfie".
- **Backup exclusion delivered** (ADR 0001 #6's outstanding promise): iOS
  `AppDelegate.swift` marks the documents directory (which holds the database and its
  journal siblings), the managed-media directory, and application support as
  `isExcludedFromBackup`; Android sets `allowBackup="false"` and
  `fullBackupContent="false"`. No package required.

## Evidence — commands actually run (2026-09-02)

- `flutter test` → **236 tests, all passed** (was 226; +10 net new).
- `flutter analyze` → No issues found. `dart format --set-exit-if-changed` → clean.
- Failing-first coverage added this sprint:
  - `captureResultForError` (4 tests): iOS/Android denial codes → permission outcome;
    permanent vs. first-time denial flagged correctly; missing hardware → unavailable;
    **unknown errors still produce a named outcome, never a crash**.
  - Capture recovery widget tests (6): denial shows the A.7 copy with Settings/Try
    Again/Cancel; a first-time denial deliberately omits Settings (no repeated OS
    prompts); denial saves no event and Cancel returns to a stable Home; **Try Again
    re-attempts and proceeds once granted**; an unavailable camera explains itself and
    stays recoverable; cancellation returns Home with no event and no error state.
  - Simulated-source and journey suites migrated to the typed outcome and still green
    (the reviewer path is unchanged).
- Media store suite green **with processing on a background isolate** — including the
  800 px resize, no-upscale, typed rejection of undecodable bytes, staging/promotion,
  and reconciliation tests.
- `flutter build ios --simulator --debug` → **`✓ Built build/ios/iphonesimulator/
  Runner.app`** for `com.jesusrosario.roots`: the real bundle id, camera plugin,
  permission_handler, and the native backup-exclusion code all compile and link.
- macOS integration journey: unchanged from Sprint 5.1 (simulated source is still the
  default there); re-run recorded in that addendum.

## Evidence — real iOS runtime (observed, 2026-09-02)

- Installed and launched the built app on the iPhone 17 Pro simulator (iOS 26.2) via
  `simctl install` + `simctl launch` (PID reported), then captured a screenshot:
  **the app opens straight to the companion** with the arch stage, wordmark, quiet
  icons, date eyebrow, GROW SOMETHING PERSONAL headline, green CTA, and the privacy
  footnote — no account wall, no network.
- **Backup exclusion verified against the live container**, not merely compiled:
  `xattr` on the app's data container shows
  `com.apple.metadata:com_apple_backup_excludeItem` on both `Documents` (which holds
  `plant_selfie.sqlite`) and `Documents/plant_selfie_media`.

### Bug found by that verification

The first implementation excluded Application Support (empty) and the media directory,
but **drift stores the database in `Documents/` on iOS** — so the check-in database was
still backup-eligible. Marking individual files would also have left SQLite's later
`-wal`/`-shm` siblings unprotected, since the attribute is per-item. Fixed by
excluding the whole `Documents` directory (every file this app writes there is private
local data), then rebuilt, relaunched, and re-verified with `xattr`.

## Not verified

- **Real capture on a physical device is NOT verified.** A physical iPhone is visible
  to this machine only over the network; deployment needs a cable and Developer Mode.
  The permission prompt, real shutter, retake, and the deleted-temp-file behavior
  therefore remain unproven on hardware. This is the sprint's one genuine gap.
- **Android device behavior is NOT verified** (user-approved deferral, ADR 0008 #7):
  the toolchain on this machine lacks cmdline-tools, has only platform 30, and runs
  JDK 19 where Gradle needs 17/21. The adapter, manifest, and backup config ship as
  unit-tested code; no Android build was attempted, so no Android claim is made.
- **Backup exclusion on a physical device / real iCloud backup is not verified.** The
  exclusion attribute is confirmed on the live simulator container (above); confirming
  that an actual iCloud backup omits the data would require a device backup inspection.
- **Low-end device profiling not performed.** Processing was moved off the UI isolate
  (the structural fix the spec's risk table asks for), but peak memory and
  confirmation latency on the lowest supported device class still need measurement on
  hardware.

## Failure paths

Denial (both prompt states), cancellation, absent camera, undecodable bytes, and
unexpected platform errors all resolve to named, recoverable outcomes. `takePicture`
failures are caught and mapped; the temp-file delete is best-effort and never fails a
successful capture.

## Architecture check

Domain and persistence untouched; purity guard green. The camera adapter stays a thin
shell behind the existing contract, with its volatile logic extracted as a pure
function. The settings launcher is injected rather than called statically, so the UI
stays testable. No second design system, no new state management.

## Privacy and accessibility

Permission is requested only when the user taps the daily action (§11). The iOS usage
string states the photo stays on the device. No unprocessed original is retained. The
denial and unavailable panels use themed Material buttons with ≥48 px targets and
plain-language copy; the display headline is scale-clamped like the rest of the app.

## Variance

- Denial copy is the A.7 string verbatim, including its "reviewer simulation where
  available" clause, even though the mobile build does not expose simulation — the
  approved copy was not rewritten unilaterally. **Flagged for the user**: if that
  clause should be conditional on the reviewer build, it is a small copy ADR.
- `permission_handler` is the sprint's only new dependency, recorded as earned.

## Carry forward

- Physical-device walkthrough (iOS): cable + Developer Mode, then verify prompt,
  capture, retake, managed-file creation, and temp-file deletion.
- Android: toolchain setup, then build + device walkthrough.
- Low-end profiling and the RepaintBoundary measurement deferred from ADR 0007 #5.
- Sprint 7: Patrol journey, clean-checkout rerun, release evidence.

## Diminishing returns

No in-app camera preview widget (the OS capture flow is simpler and avoids duplicating
platform UI); no resolution/flash controls (not in the ritual); no analytics on
permission outcomes (privacy).
