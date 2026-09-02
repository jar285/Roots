# ADR 0008: Sprint 6 mobile camera boundary

**Date:** 2026-09-02
**Status:** accepted

## Decision

1. **Real bundle identifier: `com.jesusrosario.roots`** (user-confirmed 2026-09-02).
   This is a personal project, not organizational work; the id derives from the user's
   own domain (jesusrosario.com). Applied to iOS, Android, and macOS targets, replacing
   the `app.roots.roots` placeholder from ADR 0001. The Dart package stays `roots` and
   display strings stay "Plant Selfie".
2. **`permission_handler` is an earned dependency** (user-approved). The spec's denial
   recovery (A.7: "Enable it in Settings") and the UI/UX philosophy's "Open Settings
   when the platform supports it" require deep-linking to the OS settings page, which
   neither Flutter nor the `camera` package provides. Alternatives rejected: a bespoke
   Swift+Kotlin platform channel (native code we maintain, untestable in the Dart
   suite) and shipping copy without the button (leaves a required recovery path
   unmet). Pinned exactly, like every other dependency.
3. **`CameraSource` returns a typed outcome instead of a nullable photo.** A sealed
   `CaptureResult` distinguishes `CapturePhoto`, `CaptureCancelled`,
   `CapturePermissionDenied` (with `permanentlyDenied`), and `CameraUnavailable`.
   Failure behavior is product behavior (development philosophy #6): the UI cannot
   offer the right recovery if denial, cancellation, and absence collapse into `null`.
4. **Error→outcome mapping is a pure function** (`captureResultForError`) so the
   mobile adapter's most failure-prone logic is unit-tested without a device; the
   adapter itself stays a thin shell over `camera` + `permission_handler`.
5. **Image processing moves to a background isolate** (`Isolate.run` inside
   `FsManagedMediaStore`), repaying the debt recorded in ADR 0005 #3. Decode, resize,
   and JPEG encode are CPU-bound and must not block the UI isolate on low-end devices
   (spec risk table). The store's contract, determinism, and `InvalidPhotoException`
   behavior are unchanged; only the thread of execution moves.
6. **Backup exclusion is implemented natively, without a package** (ADR 0001 #6's
   promise): iOS marks the app-support and managed-media directories with
   `isExcludedFromBackup` in `AppDelegate.swift`; Android sets
   `android:allowBackup="false"` and `android:fullBackupContent="false"`. This keeps
   "Your selfie stays on this device" literally true.
7. **Android ships as code, not as verified device behavior** (user-approved). The
   Android toolchain is unusable on this machine (no cmdline-tools, platform 30 only,
   JDK 19 where Gradle needs 17/21). The adapter, manifest permission, and backup
   config are written and unit-tested; the Android *device walkthrough* is explicitly
   **not verified** and carries to a follow-up sprint. iOS is the verified target this
   sprint.
8. **The simulated source stays the default on macOS** and is also the fallback when a
   device reports no camera, so the reviewer path and automated journeys keep working
   unchanged (spec §2).

## Context

Sprint 6's outcome per the development philosophy: "real capture, retake, permission,
cancel, and processing flows on supported mobile targets", with evidence "adapter tests
where practical; device or simulator walkthrough; photos are processed into managed
private storage; original temporary captures are not retained".

Environment facts (verified 2026-09-02): Xcode 26.3 green with iOS 26.2 simulators
available; a physical iPhone is visible but only over the network (needs a cable and
Developer Mode for deployment); the iOS **simulator has no camera**, so it can prove
the unavailable/denial paths and the app's build, but not real capture.

## Consequences

Denial, cancellation, and camera absence each get a named, tested recovery path; the
UI isolate stays responsive during processing; privacy copy stays honest; and the one
thing that genuinely needs hardware (real capture on a device) is the only item left
unproven — reported as such rather than claimed.
