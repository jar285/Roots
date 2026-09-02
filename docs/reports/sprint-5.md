# Sprint QA Report

## Sprint

Sprint 5 — painter and experience quality. Intended outcome: deterministic
PlantPainter with event-specific visual history, the mature state, the Greenhouse-arch
interface (ADR 0006), motion with reduced-motion behavior, and the accessibility passes
(semantics, contrast, 200% text) — protected by high-value goldens.

## Spec slice

Design spec A.10 (painter contract and drawing order), A.6 (event palettes, painter
proofs), §8.8 (motion respects reduced motion), §9 accessibility criteria, §4.7 mature
state; UI/UX philosophy motion timings and reduced-motion rules; the maturity pacing
validation gate ("simulate and visually review 30/90/180/365 daily events").
Framework/system-design/pattern choices were reviewed through the Power Words lenses
**before implementation** — the seven named invocations live in ADR 0007.

## Changes

- **PlantLayout** (`lib/presentation/plant/plant_layout.dart`): a pure projection of
  PlantState into geometry — trunk metrics plus placed elements carrying sourceEventId,
  event palette color, morphology-driven spread, and deterministic index-based wobble
  (no randomness, no clock, no progress). The Parnas/Ousterhout move from ADR 0007 #2.
- **OrganicPlantPainter + arch stage** (`plant_view.dart`): thin renderer of the layout
  in the A.10 order (ground/pot → trunk → branches → leaves → decorations → mature
  flourish); branches grow out of the trunk to bud tips; the greenhouse arch with a
  contained glow frames the plant; growth reveal ≤ 600 ms ease-out driven by a one-shot
  `justSaved` flag so motion fires only when growth happened; reduced motion pins the
  reveal to the final state.
- **Mood glyph system** (`mood_glyph.dart`): ○ ◇ ▲ leaf ▢ drawn in mood accents,
  used in the mood grid, history rows, and the completed-today status (ADR 0006 #3).
- **Design-3 completed state**: delta-derived headline via `growthHeadline`
  (never claims growth the delta lacks), "Today · {Mood} · saved" status, and
  "Come back tomorrow, or don't. It keeps." support copy. Mood selection became the
  2-column glyph card grid; history cards gained mood-accent edge strips.
- New verification layers: golden baselines, computed WCAG contrast test, 200% text
  scale tests, direct reveal/reduced-motion tests.

## Evidence

**209 tests passing**, `flutter analyze` no issues, `dart format` clean (2026-09-01).
Test-first throughout (failing runs observed before each implementation slice; goldens
and the contrast/scale suites are verification layers, created green by design and
documented as such):

- growthHeadline (5): leaf/branch/decoration priority, honest plurals, zero-delta
  fallback.
- PlantLayout (7): structural determinism; identity + palette-color retention; trunk
  length linear in effectiveHeight; **all elements in-bounds at maximum caps for every
  morphology**; vertical < balanced < broad spread ordering; maturity passthrough;
  seed-state sprout.
- PlantView (3): reveal schedules frames when motion is allowed and settles; **reduced
  motion schedules no reveal frames and shows the final state instantly**; static
  renders idle.
- Journey tests updated to the new copy: the deterministic delta produces the exact
  headline ("6 new leaves are part of it now." for the afternoon+happy fixture), and
  the same journey completes under reduced motion.
- **Contrast (10)**: computed WCAG ratios for every token pair actually rendered
  together (text on background/surface/raised, CTA label on plant green, destructive
  on dialogs, warning, focus) — all ≥ 4.5:1.
- **200% text scale (3)**: empty Home, completed Home, and mood selection render with
  no overflow exceptions and their primary actions visible.
- **Goldens (6)** in `test/presentation/goldens/`: empty Home, completed Home, and the
  plant after 30/90/180/365 simulated days — the pacing gate's visual artifacts.
- macOS integration journey re-run with the new interface
  (`flutter test integration_test -d macos`): **All tests passed** (exit 0) — the
  real-infrastructure daily loop, the delta-derived completed headline, and relaunch
  reconstruction all hold on the arch UI.

### Maturity pacing gate (spec risk table)

The four pacing goldens are the visual review artifacts; day 30 is dense but not yet
mature (height 420/500, decorations 38/40), maturity lands day 36, and days 90–365
render the identical capped plant with the flourish. Rendered pixels were inspected
during this sprint (arch, connected branches, color history legible at all four
checkpoints). **Gate disposition: constants stay as harvested unless the user objects
after viewing `test/presentation/goldens/plant_day_*.png`** — a retune would be a new
ADR, not a silent change.

## Failure paths

Nothing new fails; the reveal cannot alter the projected result by construction
(progress only gates how much of the precomputed layout is drawn), and an unknown
palette id falls back to plant green rather than failing to render old data.

## Architecture check

No new dependencies (ADR 0007 #1 upheld — pubspec untouched). Domain untouched; purity
guard green. PlantLayout is presentation-layer pure logic; the painter reads no
storage, clock, or randomness (A.10). RepaintBoundary deliberately not added —
measurement first (ADR 0007 #5, trigger recorded for Sprint 6).

## Privacy and accessibility

Mood is never color-alone anywhere it appears (glyph + label). The plant canvas stays
one concise semantics node; saving progress announces "Saving"; mood cards announce
label + supporting phrase + selected state. Contrast proven by computation on the
rendered pairs; large-text proven by tests. Manual VoiceOver walk on the macOS build:
**not yet performed** — recorded below.

## Variance

- Completed-state headline/status/support replace A.7's "mature support" only in the
  non-mature case; the mature state keeps A.7's YOUR PLANT IS FULLY GROWN verbatim.
- Mood grid drops the visible supporting phrase (it moved into the semantics label) —
  philosophy requires announcing it, not displaying it in the picker.
- Golden baselines are macOS-rendered; they pin this machine's rasterization.

## Not verified

- Manual VoiceOver/screen-reader walkthrough and focus-order feel on the macOS build —
  scheduled as the reviewer's manual step; automated semantics assertions cover labels
  and selection states.
- Paint performance at multi-year histories on low-end hardware — Sprint 6's
  measurement (with the recorded RepaintBoundary trigger).

## Carry forward

- Sprint 6: real mobile camera + permissions, image processing on a background
  isolate, low-end profiling, Android toolchain update, real bundle id, backup
  exclusion config.
- User to eyeball the four pacing goldens and confirm the growth arc feels right
  (gate stays open until then; constants unchanged).

## QA/QC addendum (2026-09-01, user-requested design conformance pass)

**Finding (user + agent agreed):** the first Sprint 5 pass built Design 3's structure
(arch, glyphs, palette, copy) but flattened its typographic voice into centered
Material defaults — and the Ahem-font goldens could never have caught it. Fixes, all
test-first where behavior changed:

- **Typographic voice**: heavy left-aligned display headlines (w800/30), letterspaced
  eyebrows, ROOTS wordmark, pill (stadium) buttons via `labelLarge`-derived styles that
  keep Material's font pipeline; the completed headline renders in caps.
- **Composition**: date eyebrow ("WEDNESDAY 2 SEPTEMBER", English-only helper with unit
  tests); completed state uses an **outlined** REVIEW pill (green fill reserved for the
  primary daily action); History gained its display header + "N CHECK-INS · KEPT ON
  THIS DEVICE" and Design 3 rows (mood-led bold + glyph, date·time beneath, thumbnail
  right, accent strip).
- **Plant organics**: leaves sized up and tied to the stem with fine petioles; curvier
  trunk; growth-scaled element sizes so seedlings look like seedlings.
- **Two rendering defects found by inspection**: the arch glow rendered as a see-through
  donut (BoxDecoration ignores `color` under `gradient` — both stops are now opaque
  blends) and button labels dropped the font pipeline.
- **A real accessibility catch**: the 200%-scale tests failed against the new display
  type — fixed by clamping display-family text at 1.4× (body/controls keep full 2×,
  WCAG 1.4.4) and letting mood cards grow with the text scale instead of clipping.
- **New permanent tool**: `test/presentation/design_preview_test.dart` renders key
  screens **with real fonts** to `build/design_previews/*.png` — the review artifacts
  Ahem goldens can't provide. Rendered pixels of Home (empty/completed) and History
  were inspected against `Roots - Design 3.png` this pass.

Post-addendum verification: **212 tests passing**, analyze/format clean, goldens
re-baselined, macOS integration journey re-passed.

## Sprint 5.1 conformance addendum (2026-09-02)

Bounded, presentation-only pass to make the rendered interface materially faithful to
`docs/_architecture/Roots - Design 3.png`. The reference was treated as a conceptual
mockup, not a specification.

### Conflict resolutions (contract over mockup)

| Mockup | Resolution |
|---|---|
| Home headline "ADD TODAY'S GROWTH" | **Rejected** — ADR 0007 #6 reserves growth language for confirmation/completed. Approved copy kept verbatim. |
| Grown plant on the pre-check-in frame | Empty companion **stays a seed**; no growth constants touched. The new before-today preview shows real growth from real events. |
| No back on the mood sheet | Explicit **BACK kept** (recovery paths are product behavior). |
| Single header icon | User-approved **two quiet icons** (history + settings) with 48px targets, tooltips, and semantic labels — both destinations stay visible. |
| History rows omit time category | **Kept** (spec §6.5) inside the compact metadata line. |
| Mood cards omit supporting phrase | Already announced via Semantics; display unchanged. |
| Device chrome, status bar, captions | Out of scope. |

### Changes

- **New `stage_sheet.dart`**: `StagePanelLayout` (a two-mode `CustomMultiChildLayout`:
  panel-intrinsic for Home, stage-fraction for Mood; single-pass, no fixed sizes) and
  `RitualPanel` (rounded top corners, sheet handle; scrolls rather than overflows when
  the layout caps it).
- **Home**: greenhouse stage overlapped by a full-width raised ritual panel (28px
  overlap so the pot tucks behind it); wordmark + two quiet icon buttons; every
  existing state and approved copy preserved, including the delta-derived headline.
- **Mood**: photo stage (draft selfie, or the managed photo during keep-existing
  review, via the extracted shared `DraftPhotoView` that confirmation now reuses) over
  a raised sheet with title, privacy line, glyph grid, CONTINUE and BACK. Selected
  cards gained a green-tinted fill so the border reads on the raised surface.
- **Plant**: `PlantLayout` reworked into an *attached organism* — swayed trunk
  polyline, curved `PlacedBranch` stems sprouting from the trunk, and leaves and
  decorations anchored to the trunk or a branch with tangent-following rotation and
  petioles. Determinism, sourceEventId, event palettes, morphology spread, caps,
  bounds, drawing order, and reduced-motion behavior all preserved; domain untouched.
- **History**: explicit back affordances on History and Event Detail — a real bug fix,
  since `context.go()` replaces the stack and AppBars can never infer one; compact
  human dates (`TODAY · 2 SEPT`, `TUE 1 SEPT`, year when it differs) + uppercase time
  category; denser rows with the accent strip, glyph-led bold mood, right-hand
  thumbnail, and an inline missing-photo state (A.7 copy + dashed placeholder).
- **Visual system**: filled/outlined buttons moved from stadium pills to 14px
  rounded rectangles (≥48px heights, Material states untouched); `radiusLarge` token
  added. No packages added; no second design system.
- **Hygiene (reported before acting)**: 24 golden failure-diff PNGs were accidentally
  tracked under `test/presentation/failures/` (swept in by `git add -A` during the QA
  pass). Removed from version control and the path added to `.gitignore`; they are
  regenerated diagnostics, never sources.

### Automated evidence (commands run 2026-09-02)

- `flutter test` → **226 tests, all passed** (was 212; +14 net new).
- `flutter analyze` → No issues found. `dart format --set-exit-if-changed` → clean.
- New/updated failing-first tests: 4 stage/panel layout-math tests; compact-viewport
  (320×568) tests for Home empty, Home completed, and the mood sheet; 200% text-scale
  tests still green (the capped panel now scrolls instead of overflowing — an actual
  overflow was caught and fixed this way); mood photo-stage assertions for both the
  draft and keep-existing paths; `compactDate` unit tests; History→Home and
  Detail→History back-navigation tests; inline missing-photo row test.
- Plant suites preserved and extended: determinism, identity, palette, trunk
  proportionality, morphology-spread ordering, maturity, seed state, in-bounds at all
  caps for every morphology, **plus new attachment assertions** (branch starts lie on
  the trunk polyline; every leaf/decoration anchor lies on a stem, within 2px).
- Goldens regenerated (6 baselines); `flutter test integration_test -d macos` →
  All tests passed.

### Manual visual inspection (not automated)

Real-font previews regenerated at `build/design_previews/` for the four required
states (before-today Home with growth, completed Home, Mood with photo stage and a
selection, populated History including a missing photo) and compared side-by-side
against Design 3. Observations: Home and History now read as the reference frames
(stage + raised panel with handle, wordmark, quiet icons, display headline over
eyebrow, card rows with accent strips and compact dates); the mood sheet matches the
reference's stage-over-sheet arrangement. Two defects were found this way and fixed —
button labels rendering in the wrong color after a theme change, and the mood stage
photo not resolving before capture. Iconography and typography could only be judged
because the preview harness uses real fonts; goldens (Ahem) cannot show this.
Remaining manual gap, unchanged from Sprint 5: no VoiceOver walkthrough yet.

## Diminishing returns

No goldens for every screen permutation (would freeze incidental pixels); no custom
page transitions (platform defaults are predictable and accessible); no plant
texture/grain pass yet — legibility first, texture only if it survives review.
