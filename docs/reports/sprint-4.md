# Sprint QA Report

## Sprint

Sprint 4 — correction and data control. Intended outcome: review today's event
(including keeping the existing photo), event deletion, Start Over, and managed-media
staging with launch reconciliation — with database, installation-identity, and file
assertions after every destructive path.

## Spec slice

Design spec §4.5 (photo replacement durability), §4.6 (deletion, Start Over), §5.4
(media boundary: validate → resize → encode → stage → commit → promote → reconcile),
§6.5/§6.6 (history, event detail, Start Over placement), A.7 copy, A.9 managed photo
lifecycle. Invariants at risk: #7 deletion removes media and contribution, #8 Start
Over wipes everything and rotates identity, #9 missing media never breaks
reconstruction. This sprint repays the media debt recorded in ADR 0004 #2.

## Changes

- **ManagedMediaStore full contract (A.9)**: prepare (validate + resize ≤ 800 px +
  JPEG q85 + staged write), atomic promote, staged/final removal, read-with-null-for-
  missing, removeAll, inventory. Staged names carry the confirmation timestamp so
  reconciliation can distinguish committed-but-unpromoted saves from abandoned ones
  (ADR 0005 #1).
- **ReconcileManagedMedia**, run at every launch by the composition root: promotes
  committed-but-unpromoted photos, removes abandoned staged files, sweeps orphan
  finals; idempotent; returns privacy-safe counts.
- **SaveDailyCheckIn** now follows §5.4's order (stage → commit → promote) and accepts
  a null photo on a same-day review to keep the stored one.
- **DeleteGrowthEvent** (row first, then idempotent file removal; named cleanup
  outcomes) and **StartOver** (one repository transaction wipes events and rotates the
  installation id, then best-effort media wipe). `CompanionRepository.startOver`
  contract-tested on Drift and the in-memory fake.
- **UI**: History (newest first: date, mood label + accent, time category,
  thumbnail/placeholder; calm empty state), event detail (friendly contribution
  explanation, missing-photo copy, REVIEW for today only, delete with a dialog naming
  the date and scope), Settings (privacy copy, Local Data section, destructive Start
  Over with the A.7 confirmation), Home secondary HISTORY/SETTINGS actions, and KEEP
  CURRENT PHOTO on same-day review.

## Evidence

All behavior test-first; **174 tests passing**, `flutter analyze` no issues,
`dart format --set-exit-if-changed lib test integration_test` clean (2026-09-01).

- Media store (12): processing (800 px edge preserved-aspect resize, no upscaling,
  JPEG output), typed rejection of undecodable bytes with nothing written, staging
  isolated from finals until atomic promotion, replacement-over-promotion, hostile
  name/id rejection, idempotent removal, inventory ignoring stray junk, full wipe.
- Reconciliation (5, against the real filesystem store): abandoned save removed;
  **a real interrupted save** (promotion fails after commit) leaves the committed
  event photo-less, and one reconcile pass restores it; an abandoned same-day edit is
  discarded while the committed photo stays byte-identical; orphan finals swept;
  healthy stores untouched and the pass is idempotent.
- Data control (6): delete removes row + photo with named cleanup outcomes
  (removed / alreadyMissing / failed-but-event-gone); unknown ids touch nothing;
  Start Over clears events and media, rotates identity, reports a failed media wipe,
  and the fresh companion accepts a previously used date.
- Repository contract grew startOver (3 cases × both implementations).
- Widget tests (8 new): history order and row content; empty-history copy; detail
  contribution + missing-photo copy; delete dialog names the date, cancel is safe,
  confirm rebuilds; Start Over dialog scope copy, full reset, **identity rotation
  asserted through the UI**; keep-current-photo appears only when editing today and
  preserves the stored bytes and filename.
- Integration journey re-run on the macOS target with the staged pipeline
  (`flutter test integration_test -d macos`): **All tests passed** (exit 0) —
  the real-infrastructure daily loop, managed photo on disk, and relaunch
  reconstruction all hold after the media rework.

## Failure paths

Interrupted saves at every media step converge after one reconciliation; save failure
in the UI keeps input and offers RETRY; deletion cleanup failure is silent-by-design
(the user cannot act; the orphan is swept) per the UI/UX philosophy; corrupt photos
render placeholders with the A.7 copy; Start Over media failure still rotates identity
and reports honestly.

## Architecture check

Domain untouched (purity guard green). The media store remains one deep module owning
paths, processing, staging, and validation; use cases stay single-operation; no
snapshots, tombstones, or soft deletes crept in.

## Privacy and accessibility

Deletion and Start Over are observable and verified at database, identity, file, and
UI levels (spec §11 "make deletion observable and testable"). Managed paths are
validated before every file operation (A.9). Reconciliation reports counts only —
never paths or image data. Destructive dialogs name their scope in words, use
placement + wording + color (never color alone), and confirm before acting.

## Variance

- The Start Over confirm button reads ERASE EVERYTHING (scope-naming, calmer than a
  bare "OK"); titles and support copy follow A.7 verbatim.
- Image processing runs on the calling isolate; moving it to a background isolate is
  Sprint 6's low-end-device work (ADR 0005 #3, spec risk table).

## Not verified

- Delete/Start Over behavior against the *Drift* store through the *UI* in one motion —
  the UI is proven over the in-memory fake (same contract suite) and the Drift store is
  proven at the use-case/repository level; the macOS integration journey covers the
  save path end-to-end on Drift. A full destructive-path integration journey joins
  Sprint 7's release evidence.
- Screen-reader walkthrough of the new screens and 200% text scaling — Sprint 5.

## Carry forward

- Sprint 5: real PlantPainter with event-styled history, motion + reduced motion,
  goldens, semantics/contrast/text-scale verification — **and the open art-direction
  decision** (user asked about glassmorphism / game-style art; both are rejected
  directions in the approved UI/UX philosophy — changing course needs a deliberate
  ADR at Sprint 5 kickoff).
- Sprint 6: background-isolate image processing + low-end profiling; real camera.

## Diminishing returns

No pagination for history (years of daily events is ~hundreds of small rows — measure
first); no undo for deletion (the spec offers confirmation, not a trash can); no
reconciliation scheduling beyond launch (the only writer is the app itself).
