# ADR 0002: Sprint 1 domain semantics

**Date:** 2026-09-01
**Status:** accepted

## Decision

Fix the small semantic choices the spec leaves open so the deterministic domain is fully
testable, without materially changing product behavior.

1. **Normalization vs caps** (reconciles spec §4.2 "normalized and capped before
   persistence" with §4.4 "enforce global caps" at projection): *delta-level
   normalization* happens at creation — integer fields clamped to ≥ 0, spread factor
   clamped to [0.0, 1.0]; *global plant caps* (height 500, branches 20, leaves 50,
   decorations 40) are enforced during projection. Stored deltas are already resolved
   and normalized.
2. **Maturity** = all four global caps reached (height, branches, leaves, decorations).
   Later events still create history and are counted; they add no geometry past caps.
3. **Silly mood semantics** (spec A.3): the four count fields are seeded *additions* on
   top of the time modifier; `spread nextDouble()` *sets* the spread factor (consistent
   with how energetic/calm set spread). Locked PRNG call order: height `nextInt(15)`,
   branches `nextInt(3)`, leaves `nextInt(4)`, decorations `nextInt(2)`, spread
   `nextDouble()`.
4. **Mood spread overrides time spread** when the mood defines one (derived from the
   spec's own worked examples: afternoon+calm ⇒ 0.3, evening+happy ⇒ 0.4).
5. **Repo-owned PRNG**: a 32-bit xorshift generator implemented in `lib/domain/rng/`,
   not `dart:math Random`, so a stored `randomSeed` reproduces the original roll across
   Dart SDK versions and platforms. (Replay never re-rolls — deltas are stored resolved —
   the seed exists for explainability and tests.) Seed 0 is remapped to a fixed non-zero
   constant because xorshift has a zero fixed point.
6. **Palette and morphology identifiers** are opaque, event-scoped strings resolved at
   event creation: palette `v1.<mood>` (e.g. `v1.happy`); morphology by deterministic
   precedence — `v1.vertical` if the delta prefers vertical, else `v1.spiral` if it
   prefers spiral, else by spread: ≤ 0.4 `v1.compact`, ≥ 0.6 `v1.broad`, otherwise
   `v1.balanced`. Renderers may interpret them freely; events never lose them.
7. **Local date derivation**: `localDate` and the category hour come from one UTC instant
   plus the recorded `timezoneOffsetMinutes` (local = UTC + offset), matching spec §4.1.

## Context

Sprint 1 implements the deterministic domain test-first; these points were flagged during
alignment (2026-09-01) as under-specified details whose resolution does not change the
approved product behavior. The approved plan carries these proposals; the user approved.

## Alternatives rejected

- `dart:math Random`: algorithm not contractually stable across SDKs; silent drift would
  break seed explainability.
- Maturity on height alone: contradicts §4.7 "all relevant caps".
- Silly spread as an addition: could exceed 1.0 and contradicts the set-style of other
  mood spread modifiers.

## Consequences

All Appendix A worked examples remain exactly reproducible; growth rules are pure
functions of (timeCategory, mood, seed); painters receive stable identifiers. Reopen via
ADR if a future algorithm version changes any rule — never by editing v1 behavior.
