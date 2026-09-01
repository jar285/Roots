# UI/UX Design Philosophy

## Purpose

This document defines how Plant Selfie should feel, communicate, and behave in Phase 1.

It protects a clear product character while keeping the experience:

- private;
- calm;
- understandable;
- accessible;
- honest about system state;
- practical to implement in Flutter.

The target behavior and data contract live in the [Phase 1 Design Spec](../superpowers/specs/2026-08-21-plant-selfie-design.md). This document translates that contract into interface decisions.

## Experience thesis

Plant Selfie should feel like a quiet digital object in a dim, cozy room: personal, slightly playful, and alive without demanding attention.

The user is not completing a productivity task. They are making a small daily reflection. The interface should reward presence without manufacturing urgency.

The experience promise is:

> One private daily check-in adds a visible piece to a plant that remembers its history.

## Product truths the interface must preserve

1. The app opens to the companion, not an account wall.
2. Mood is selected by the user and never inferred from the image.
3. One local date creates at most one growth contribution.
4. Returning on the same day offers review and correction, not more growth.
5. Missing a day carries no penalty.
6. Historical growth keeps the color and form assigned by its source event.
7. Photos stay on the device in Phase 1.
8. The user can delete one event or start over.
9. Mature plants still record future reflections.
10. Camera, storage, and media failures have understandable recovery paths.

Any design that obscures one of these truths is out of alignment, even if it looks polished.

## Design workflow

Use this order:

    Product truth -> User state -> Information hierarchy -> Interaction -> Visual treatment -> Motion -> QA

### 1. Name the user state

Before drawing a screen, identify the state being represented:

- first launch;
- empty companion;
- ready for today's check-in;
- capturing or simulating;
- choosing a mood;
- confirming;
- saving;
- complete for today;
- reviewing today's event;
- viewing history;
- missing photo;
- permission denied;
- save failed;
- mature plant;
- confirming deletion;
- confirming Start Over.

Do not hide distinct states behind one generic layout.

### 2. Define the decision

Each screen should answer one primary user question. Examples:

- Home: What has my plant become, and what can I do today?
- Capture: Is this the photo I want to keep locally?
- Mood: How do I describe how I feel?
- Confirmation: What will be saved and changed?
- History: What have I recorded?
- Event detail: What did this day contribute, and can I remove it?

### 3. Establish hierarchy

Order content by importance before applying visual style:

1. current plant or current task;
2. primary action;
3. status and supporting explanation;
4. secondary navigation;
5. metadata;
6. destructive controls.

### 4. Style with the system

Use project tokens, Material 3 behavior, and a small reusable component set. Avoid one-off effects that create a second design system.

### 5. Verify in rendered states

Review actual pixels at compact and large phone sizes, 200 percent text scale, light system overlays, keyboard or screen-reader focus, and reduced motion. Code inspection alone is not visual QA.

## Locked Phase 1 visual direction

### Product type

A mobile-first personal companion with a macOS simulation/reviewer surface.

### Target feeling

- intimate;
- restorative;
- quietly magical;
- dependable;
- a little retro;
- never clinical or competitive.

### Primary style

Dark organic retro:

- deep blue-charcoal environment;
- softly raised surfaces;
- crisp cream text;
- botanical greens;
- restrained mood accents;
- subtle grain or pixel-inspired detail only where legibility remains strong.

The dark palette is motivated by the physical scene: a private object viewed during small morning or evening pauses. It is not a generic developer aesthetic.

### Supporting style

Use modern Material behavior underneath the custom expression:

- predictable focus and pressed states;
- accessible touch targets;
- semantic roles;
- clear dialogs and sheets;
- responsive layout;
- platform-aware camera and settings behavior.

### Rejected directions

- Glassmorphism: weakens contrast and feels detached from the tactile plant.
- Dense dashboard cards: turns reflection into analytics.
- Photoreal botanical UI: competes with the plant's symbolic history.
- Gamified streak UI: creates pressure and punishment.
- Global mood recoloring: erases the visual record.
- Neon cyberpunk: overpowers the calm ritual.
- Bare utility minimalism: removes the warmth that makes the loop worth revisiting.

## Visual system

### Color tokens

| Token | Value | Use |
|---|---|---|
| background | #10151C | App environment |
| surface | #18212B | Sheets and grouped content |
| surface raised | #202C38 | Interactive or emphasized surfaces |
| primary text | #F4F7F8 | Titles and essential content |
| secondary text | #AEBBC6 | Supporting copy and metadata |
| plant green | #70D6A0 | Botanical baseline and positive completion |
| focus | #4CC9F0 | Focus ring and active affordance |
| warning | #FFD166 | Attention without danger |
| destructive | #FF6B6B | Delete and reset actions |

Mood accents:

| Mood | Accent |
|---|---|
| happy | #FFD166 |
| mysterious | #9B5DE5 |
| energetic | #F15BB5 |
| calm | #70D6A0 |
| silly | #4CC9F0 |

Do not use color alone to identify mood, selection, warning, or completion. Verify WCAG AA contrast on final rendered pairs.

### Typography

Use at most two families:

- a distinctive display face for short hero labels if bundled and legible;
- the platform or project sans face for all functional text.

Rules:

- body copy is sentence case;
- all caps is reserved for short display titles and primary ritual actions;
- metadata does not drop below a comfortable mobile size;
- line length is constrained on wider reviewer surfaces;
- 200 percent text scaling must not clip controls or plant status.

### Spacing and shape

- base spacing unit: 4 logical pixels;
- common gaps: 8, 12, 16, 24, 32;
- minimum control height and touch target: 48;
- common corner radius: 12 to 20;
- primary content maximum width on desktop: 720;
- destructive sections receive separation through spacing and labeling, not only color.

Prefer a few generous regions to a grid of floating cards.

### Elevation and texture

Use tonal separation before shadows. If texture is added, keep it subtle, static under reduced motion, and outside critical text. Avoid blur-heavy glass effects.

### Icons and illustration

Use one coherent icon family. Do not use emoji as product icons. The plant itself is the hero illustration; secondary decoration should not compete with it.

## Screen hierarchy

| Screen/state | Primary content | Primary action | Secondary actions |
|---|---|---|---|
| First launch | Empty plant and brief privacy promise | BEGIN | Skip explanation if shown as pages |
| Home, no event today | Current plant and calm daily prompt | TAKE TODAY'S SELFIE | History, settings |
| Home, event complete | Current plant and completion state | REVIEW TODAY'S CHECK-IN | History, settings |
| Capture | Camera preview or simulation | USE THIS PHOTO | Retake, cancel |
| Mood | Five labeled mood choices | CONTINUE | Back |
| Confirmation | Photo, mood, privacy, contribution preview | ADD TODAY'S GROWTH | Back, cancel |
| Saving | Stable preview and progress | None | None unless retry becomes available |
| History | Newest-first check-ins | Open an event | Back |
| Event detail | Date, mood, photo/placeholder, contribution | REVIEW TODAY if eligible | Delete check-in |
| Mature Home | Mature plant and saved-today status | Daily capture or review action | History, settings |
| Settings | Privacy and local-data controls | None | Start Over |

One screen gets one strongest action. Secondary actions should not compete through equal size or saturation.

## Core journeys

### First launch

Open directly into the product. If an explanation is needed, keep it short and skippable:

- one private check-in per day;
- the plant grows from that record;
- selfies remain on this device.

Do not ask for an account, camera permission, notification permission, or personal profile before the user chooses the related action.

### Today's check-in

1. Home makes the current daily state obvious.
2. Camera permission is explained immediately before the OS prompt.
3. Capture provides cancel and retake.
4. Mood choices use label, supporting phrase, selection indicator, and accent.
5. Confirmation states that this is today's single growth event.
6. Save disables duplicate submission and shows visible progress.
7. Completion returns attention to the newly added plant contribution.

The growth reveal should feel satisfying in under one second. Do not trap the user in a long animation.

### Same-day review

After saving, Home changes the action to REVIEW TODAY'S CHECK-IN. The review screen clearly states that saving changes today's existing contribution rather than adding another one.

If the photo is replaced:

- show the replacement before save;
- keep the old event intact until the new data is durable;
- return to one clear completed state.

### History and deletion

History is a personal archive, not a metric dashboard.

Each row shows:

- date;
- mood label and accent;
- time category;
- thumbnail or missing-photo placeholder.

Event detail can explain the contribution in friendly language such as added two leaves and a branch. Deletion is visible but not visually dominant. Its dialog names the date and explains that both the entry and its plant contribution will be removed.

### Start Over

Place Start Over in Settings under a Local Data heading and inside a separate destructive section.

Confirmation copy states:

- all check-ins will be removed;
- managed selfies will be removed;
- the plant will return to its seed state;
- the action cannot be undone in Phase 1.

Never disguise Start Over as logout.

### Mature plant

Maturity is a celebratory state, not an end screen. The daily action remains available. After confirmation, the interface says the reflection was added to the plant's story even if persistent geometry is capped.

Do not introduce prestige levels, infinite currency, or a new progression system.

## Empty, loading, and error states

Every async surface has an intentional state.

### Loading

- preserve layout to avoid jumping;
- show progress only when work is actually underway;
- never present an enabled save action during an unresolved write.

### Empty

- empty Home invites the first check-in;
- empty History explains that completed check-ins will appear there;
- emptiness does not imply error or failure.

### Camera permission denied

Explain why camera access matters and provide:

- Open Settings when the platform supports it;
- Try Again;
- Cancel;
- reviewer simulation only where that mode is deliberately exposed.

Do not repeatedly trigger the OS prompt.

### Camera cancelled

Return to the previous stable state with no event and no error toast.

### Save failed

Keep the user's current preview and mood selection when safe. State that nothing was added yet and offer Retry. Do not show completed growth before persistence succeeds.

### Missing photo

Show a neutral placeholder and preserve date, mood, contribution, and delete control. The plant remains reconstructable.

### Partial cleanup

If database deletion succeeds but file cleanup reports a problem, the event disappears from the product immediately. Surface a calm local cleanup message only when the user can act; otherwise record a privacy-safe diagnostic for reconciliation.

## Motion

Motion has three jobs:

1. connect an action to a result;
2. explain hierarchy or navigation;
3. make growth feel alive.

Use short ease-out transitions. Avoid bounce-heavy motion, perpetual decorative animation, and simultaneous movement across unrelated regions.

Suggested timing:

- pressed and selected state: 80 to 150 milliseconds;
- content transition: 160 to 240 milliseconds;
- growth reveal: 400 to 800 milliseconds;
- dialog or sheet: platform default unless a tested custom transition improves clarity.

Reduced motion:

- skips staged plant drawing;
- shows the final deterministic state;
- removes texture movement and decorative drift;
- preserves selection and focus feedback.

Animation progress may reveal geometry but must not alter the final PlantState.

## Accessibility

### Semantics

- Plant canvas has a concise summary, not hundreds of decorative nodes.
- Mood controls announce label, supporting phrase, and selected state.
- Photo controls distinguish capture, retake, use, and cancel.
- Destructive dialogs announce scope before actions.
- Progress states are announced without repeated chatter.

### Input

- touch targets are at least 48 by 48 logical pixels;
- keyboard and switch focus order follows visual order;
- focus is visible against every surface;
- hover is supplemental, never required.

### Text and layout

- text scales to 200 percent;
- actions wrap or expand rather than clip;
- landscape and compact heights remain usable;
- wide desktop layouts constrain reading width instead of stretching.

### Color

- selection uses shape, icon, or text in addition to color;
- plant elements remain distinguishable under common color-vision deficiencies;
- destructive actions use wording and placement as well as red.

## Flutter-specific implementation guidance

- Build on Material 3 components and semantics.
- Keep a single ThemeData and token layer.
- Use SafeArea where system UI can overlap content.
- Model loading, data, empty, and error states explicitly.
- Keep PlantPainter pure: immutable PlantState plus animation progress in, pixels out.
- Do not read the clock, random source, database, or files during paint.
- Use RepaintBoundary around the plant where profiling supports it.
- Avoid a custom button or dialog family when themed Material components satisfy the need.
- Test text scaling, screen-reader labels, and reduced motion at widget level.

## UI/UX QA checklist

### Product alignment

- [ ] App opens to the companion without authentication.
- [ ] Mood is presented as self-report.
- [ ] Before-today and completed-today states are distinct.
- [ ] No streak, guilt, decay, or competitive signal appears.
- [ ] Privacy copy matches actual local behavior.

### Hierarchy and copy

- [ ] Each screen has one strongest action.
- [ ] Titles describe the current decision.
- [ ] Destructive actions name their scope.
- [ ] Technical errors are translated into recoverable user language.
- [ ] Copy does not make unsupported security or permanence claims.

### Layout and components

- [ ] No clipping at compact height or 200 percent text.
- [ ] Primary content is constrained on wide screens.
- [ ] Spacing follows the token scale.
- [ ] Material states remain visible and consistent.
- [ ] The plant remains the visual focus on Home.

### Accessibility

- [ ] Touch targets meet 48 by 48 minimum.
- [ ] Focus order and visible focus are correct.
- [ ] Screen-reader announcements are concise and complete.
- [ ] Contrast is checked on rendered component pairs.
- [ ] Meaning does not rely on color alone.

### Motion

- [ ] Motion connects cause and effect.
- [ ] Growth reveal completes quickly.
- [ ] Reduced motion shows the same final information.
- [ ] No perpetual or distracting motion remains.

### Failure and data control

- [ ] Camera denial, cancellation, and retake are usable.
- [ ] Save failure retains safe user input and offers retry.
- [ ] Missing photos do not erase event context.
- [ ] Delete and Start Over confirmations are specific.
- [ ] Same-day correction does not appear to add a second event.

### Visual QA

- [ ] Empty, loading, error, mature, and populated states were rendered.
- [ ] Small and large phone viewports were inspected.
- [ ] The macOS simulation harness was inspected at constrained width.
- [ ] Goldens protect only stable, high-value states.
- [ ] Any deliberate visual variance is documented.

## Design invariants and variance

Invariants:

- accountless Home entry;
- one dominant daily action;
- self-reported mood;
- local privacy language;
- no punishment for absence;
- event-specific historical styling;
- accessible interaction;
- explicit destructive scope.

Permitted variance:

- exact plant illustration technique;
- display font after legibility review;
- minor spacing within the token scale;
- page versus sheet for mood selection;
- exact reveal animation within motion constraints;
- decorative texture density.

When an agent changes an invariant, it must raise the conflict before implementation. When it changes a permitted detail, it should explain the visual reasoning and verify the result.

## Reusable design review prompt

    Review this Plant Selfie UI against:
    1. the current user state and primary decision;
    2. the Phase 1 product truths;
    3. information hierarchy and action priority;
    4. the dark organic retro visual system;
    5. accessibility at 200 percent text and reduced motion;
    6. failure, empty, mature, and destructive states;
    7. Flutter feasibility and component consistency.

    Inspect rendered evidence before making visual claims.
    Separate invariant violations from optional polish.
    Recommend the smallest changes that materially improve clarity,
    trust, delight, or accessibility.

## Final philosophy

Plant Selfie should be memorable because the ritual and plant feel personal, not because the interface is loud.

Clarity earns trust. Restraint protects calm. A small moment of growth provides delight. User control makes the memory worth keeping.
