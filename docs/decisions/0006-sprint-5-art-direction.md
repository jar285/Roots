# ADR 0006: Sprint 5 art direction — Greenhouse arch (Design 3)

**Date:** 2026-09-01
**Status:** accepted

## Decision

Sprint 5 builds the "Greenhouse arch" direction
(`docs/_architecture/Roots - Design 3.png`), chosen by the user from three candidates
committed as design references. All three candidates live inside the approved UI/UX
philosophy, so this is a variance selection, **not** a contract amendment.

What the direction means concretely:

1. **The arch vitrine is the identity motif**: a rounded-arch surface with a soft
   radial glow frames the plant on Home — the philosophy's "quiet digital object in a
   dim, cozy room" made literal. The plant stays the hero inside it.
2. **Organic curved plant rendering** (stems, leaf shapes, mood-accent leaves) for the
   real PlantPainter. Pixel rendering (Design 2's technique) was considered and set
   aside; plant technique remains permitted variance if revisited.
3. **Mood glyph system adopted product-wide**: happy ○, mysterious ◇, energetic ▲,
   calm 🍃(leaf shape), silly ▢ — drawn as simple shapes in the mood accent, shown with
   the label everywhere a mood appears (options, history, detail, today status).
   Strengthens "never color alone" into an identity element.
4. **Warm green filled primary CTA** (plant green on dark), white-on-dark secondary
   outline buttons; bottom-sheet-style mood grid (2-column cards with glyph + label +
   selected border/check) — sheet vs page is permitted variance.
5. **History as cards** with a mood-accent left edge strip, glyph + label, date, and
   thumbnail/placeholder.
6. **Display type**: large geometric-sans headers in caps for short ritual titles only;
   body stays sentence case. Headers must survive 200% text scaling by wrapping, never
   clipping.
7. **Copy voice additions** (documented variance; A.7 remains the base):
   - Completed-today support: "Come back tomorrow, or don't. It keeps."
   - Growth confirmation may describe the actual contribution (e.g. "A new leaf is
     part of it now") **only when derived from the stored delta** — copy must never
     claim growth the delta did not contain; otherwise use the generic line.
8. **Motion**: the growth reveal animates inside the arch (≤ 800 ms, ease-out); reduced
   motion shows the final deterministic state instantly. Animation reveals geometry
   but never alters the projected result (spec A.10).

## Context

The user asked about broader art styles (glassmorphism, game-style photoreal); the
approved philosophy rejects those directions explicitly. Three in-contract candidates
were produced and reviewed against the philosophy: Design 1 (editorial serif
botanical), Design 2 (pixel terminal — most distinctive, but its clinical specimen-log
voice conflicts with "never clinical" and sentence-case rules), Design 3 (greenhouse
arch — strongest match for the founding metaphor and the no-pressure voice). The user
chose Design 3 on 2026-09-01.

## Alternatives rejected

- Design 2 as a whole direction: clinical voice, mono ALL-CAPS body, log-table energy —
  three philosophy conflicts; its pixel plant remains a legitimate future variance.
- Design 1: excellent (its timeline history nearly made a hybrid) but less ownable as
  an object and least "retro"; its serif needed extra legibility care.
- Amending the philosophy for glassmorphism/photoreal: rejected directions exist for
  stated reasons (contrast, detachment from the tactile plant, gamified pressure).

## Consequences

Sprint 5 has a concrete visual target: arch Home, real organic PlantPainter with
event-styled elements, glyph system, card history, motion + reduced motion, goldens for
the high-value states, and the accessibility passes — all inside the existing token
layer. The three reference PNGs stay in `docs/_architecture/` as the review baseline.
