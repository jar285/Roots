# ADR 0007: Sprint 5 execution decisions (power-words review)

**Date:** 2026-09-01
**Status:** accepted

## Decision

Build Sprint 5 (deterministic painter, event-styled history, arch interface, motion,
accessibility, goldens) with **no new frameworks or packages**, one new deep module
(a pure `PlantLayout` computation), and golden tests restricted to stable high-value
states. Each choice below was reviewed through the Power Words lenses as the user
requested; every invocation names the decision, lens, finding, action, and evidence.

## Power-words review

1. **Decision:** Do we adopt an animation/graphics framework (Rive, Lottie, flutter_animate)
   or a golden helper package (golden_toolkit)?
   **Lens:** Contrarian + "Power words that do not belong" + Kent Beck (avoid speculative
   elements).
   **Finding:** The plant is deterministic vector geometry from projected state; a
   runtime animation asset framework adds a second source of visual truth and an asset
   pipeline for something CustomPainter + one AnimationController expresses directly.
   flutter_test's built-in `matchesGoldenFile` already covers goldens.
   **Action:** No new dependencies. Deliberate non-change.
   **Evidence:** pubspec diff for Sprint 5 adds nothing.

2. **Decision:** Where does plant geometry live?
   **Lens:** Parnas (information hiding) + Ousterhout (deep modules).
   **Finding:** Geometry rules (how morphology bends placement, how height maps to the
   trunk, where the arch sits) are the decisions most likely to change with taste;
   Canvas calls are stable plumbing. Burying geometry inside `paint()` would make the
   most volatile decisions the least testable.
   **Action:** A pure, side-effect-free `PlantLayout.compute(PlantState, Size) →
   placed elements` module in the presentation layer (it needs dart:ui geometry types,
   so it stays out of `lib/domain` by design); `PlantPainter` becomes a thin renderer
   of the layout in the spec A.10 drawing order.
   **Evidence:** layout unit tests (determinism, identity retention, morphology
   effects, bounds) that never touch a Canvas.

3. **Decision:** How is painter determinism proven?
   **Lens:** Kleppmann (derived vs canonical) + Flutter testing discipline.
   **Finding:** Geometry is derived data — recomputed, never persisted; replay equality
   belongs at the layout boundary (fast, exact structural assertions), pixel stability
   at the golden boundary (few, stable states). A large snapshot suite would freeze
   incidental pixels (testing-discipline misuse warning).
   **Action:** Structural layout tests + goldens only for: empty Home, completed-today
   Home, mature plant, and the four pacing states (30/90/180/365) the spec's
   validation gate demands for visual review.
   **Evidence:** `test/presentation/goldens/` holds exactly those baselines.

4. **Decision:** Growth reveal animation semantics.
   **Lens:** Norman (connect action to outcome) + Lamport-lite (states, not frames) +
   spec A.10.
   **Finding:** Motion's one job here is linking "I confirmed" to "the plant gained
   this"; it must never change the projected result, and reduced motion must show the
   same final truth.
   **Action:** Animation progress is an input to the painter that gates how much of the
   *already-computed* layout is revealed (≤ 800 ms, ease-out). Layout is computed
   independently of progress. `MediaQuery.disableAnimations` pins progress to 1.0.
   **Evidence:** layout API takes no progress parameter; widget test proves reduced
   motion settles instantly to the final state.

5. **Decision:** Do we add RepaintBoundary / snapshot caching around the plant now?
   **Lens:** Brendan Gregg (measure before optimizing) + Ward Cunningham (record the
   repayment trigger).
   **Finding:** No measured repaint or replay problem exists; the UI/UX philosophy says
   RepaintBoundary "where profiling supports it".
   **Action:** Deliberate non-change; profile on a real device in Sprint 6 alongside the
   image-isolate work. Trigger recorded: visible jank or >16 ms paints at realistic
   history sizes.
   **Evidence:** this ADR; Sprint 6's report must include the measurement.

6. **Decision:** Visual system boundaries for the arch direction (ADR 0006).
   **Lens:** Rams (less, but better) + Material (foundation, not template) + WCAG.
   **Finding:** The arch, glyphs, and green CTA carry the identity; everything else
   should stay themed Material so dialogs, focus, and touch behavior remain predictable.
   Design 3's "ADD TODAY'S GROWTH" home headline duplicates the confirmation title —
   one phrase meaning two things violates Evans' single-language rule.
   **Action:** Custom expression limited to: arch plant stage, mood glyphs, plant
   painter, card accents. Home keeps its calm ready-state prompt; the growth headline
   ("A new leaf is part of it now") appears only on the completed state and only when
   derived from the stored delta. Contrast is asserted by a computed WCAG-ratio test
   over the token pairs actually rendered together, plus golden inspection.
   **Evidence:** contrast test in the suite; copy table in the Sprint 5 report.

7. **Decision:** Accessibility proof boundary.
   **Lens:** WCAG (perceivable/operable) + Beck (lowest useful boundary).
   **Finding:** Contrast and text scaling are computable; semantics are assertable in
   widget tests; only focus-order feel needs a manual pass.
   **Action:** Automated: token-pair contrast ratios ≥ 4.5:1 for text; 200% text-scale
   widget tests (no clipping exceptions, actions visible); semantics assertions for the
   plant summary, mood selection state, and saving progress. Manual: VoiceOver walk on
   the macOS build, recorded in the report as observation, not claim.
   **Evidence:** named tests + report's manual-observation section.

## Pattern vocabulary adopted (Fowler: names as clarity, not proof)

- `PlantLayout` is a **projection** of PlantState into geometry — computed, disposable,
  never stored (same relationship PlantState has to events).
- `MoodGlyph` is a **value-styled component**: shape + accent derived from the Mood
  enum, the "never color alone" rule promoted to identity (ADR 0006 #3).

## Consequences

Sprint 5 changes presentation only: no schema, domain, or contract changes; no new
dependencies. The pacing gate closes with golden artifacts a human can eyeball.
