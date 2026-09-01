# AI-Assisted Development Philosophy

## Purpose

This document defines how people and coding agents should turn the Plant Selfie design spec into reliable software.

It is a working contract, not motivational copy. It describes:

- how decisions become small vertical slices;
- how evidence is gathered;
- how tests protect product invariants;
- how an agent should report uncertainty;
- when to stop adding architecture.

The product target is defined in the [Phase 1 Design Spec](../superpowers/specs/2026-08-21-plant-selfie-design.md). This document governs execution, not product scope.

## Core belief

Build the smallest honest system that proves the product's central loop.

For Phase 1, that means a private, accountless, offline daily companion. It does not mean prebuilding authentication, sync, or generalized infrastructure.

AI increases implementation speed and also increases the speed at which mistaken assumptions spread. The remedy is not more ceremony. It is a short feedback loop:

    Spec -> Decision -> Sprint -> Failing test -> Code -> QA evidence -> Next sprint

Every arrow should produce an artifact that another person can inspect.

## Working terms

### Spec

The target behavior, constraints, and acceptance criteria. A spec is not automatically correct forever. Change it deliberately when evidence or product consensus changes.

### Decision

A choice that affects boundaries, data ownership, behavior, or future cost. Record the choice, the alternatives rejected, and why. Small implementation details do not need an architecture decision record.

### Sprint

A bounded, demonstrable slice of behavior. A good sprint:

- has one primary outcome;
- includes the tests and documentation needed for that outcome;
- leaves the repository runnable;
- can be reviewed without trusting a completion claim;
- avoids unrelated cleanup.

### Test-driven development

Write the smallest failing test that expresses a required behavior, implement enough to pass it, then improve the design while the test remains green.

TDD is most valuable around:

- date boundaries;
- daily uniqueness;
- deterministic growth;
- projection and deletion;
- database migration;
- media reconciliation;
- accessibility and error states.

Tests are evidence, not the product. Avoid tests that merely mirror implementation details.

### QA

Compare the observed result against the current sprint and target spec. QA includes automated checks, manual journeys, accessibility inspection, and explicit review of failure paths.

### Invariant

A property that must remain true across valid changes. Examples:

- events are canonical;
- one installation has at most one event for a local date;
- replay is deterministic;
- historical elements retain their source event's style;
- deletion clears every managed representation in scope;
- the Phase 1 core requires no backend.

### Variance

A permitted implementation or visual choice. Examples:

- internal class names;
- exact spacing within the token scale;
- whether a use case is a class or function;
- the animation technique, if semantics and reduced-motion behavior remain correct.

Do not mistake preferences for invariants.

## Development principles

### 1. Begin with behavior and ownership

Before coding, answer:

- What behavior changes?
- Which layer owns the rule?
- What is the source of truth?
- What can fail?
- How will we prove it?

If ownership is unclear, do not hide the uncertainty behind a new service or framework.

### 2. Keep one source of truth

GrowthEvent rows are canonical. PlantState is projected in memory. Selfie files are managed media referenced by events.

Do not store a second mutable growth history inside PlantState. Do not persist a plant snapshot until measurement demonstrates that replay causes a user-visible problem.

### 3. Put guarantees below the interface

The UI may prevent a second submission, but SQLite enforces the same-day uniqueness rule. The UI may confirm deletion, but repository and media tests verify deletion. Important guarantees survive race conditions, restarts, and future screens.

### 4. Make nondeterminism injectable

Clock, identifiers, random seeds, camera input, repository, and file operations must be replaceable in tests. Production adapters can be nondeterministic; domain outcomes cannot be mysterious.

### 5. Prefer deep boundaries

Use a small number of meaningful interfaces:

- CompanionRepository owns event persistence semantics.
- ManagedMediaStore owns safe private-file lifecycle.
- CameraSource owns capture input.
- Versioned PlantProjector owns deterministic replay.

Avoid a chain of shallow wrappers that only renames calls.

### 6. Treat failure behavior as product behavior

Camera denial, cancellation, duplicate submissions, database failure, missing photos, interrupted file promotion, unknown algorithm versions, and partial cleanup all require named outcomes.

Do not use a generic catch block as the design.

### 7. Earn complexity with evidence

Do not add accounts, a backend, remote sync, snapshot caches, event buses, microservices, or generic plugin systems in Phase 1. Introduce them only after a measured constraint or approved user need appears.

### 8. Report truthfully

An agent distinguishes:

- inspected from assumed;
- passing from not run;
- implemented from scaffolded;
- automated from manually verified;
- current-sprint work from deferred work.

Never claim a command passed when it was skipped or unavailable.

## Delivery sequence

The default Phase 1 sequence is intentionally dependency-aware.

### Sprint 0: repository and decision baseline

Outcome:

- confirm Flutter targets and toolchain;
- pin compatible versions in project metadata;
- establish formatting, analysis, test, and setup commands;
- record any deviation from the target spec.

Evidence:

- clean setup from a fresh checkout;
- sample app or existing shell runs;
- baseline commands are documented.

### Sprint 1: deterministic domain

Outcome:

- time categorization;
- mood and growth rules;
- seeded silly behavior;
- caps and mature state;
- versioned event projection.

Evidence:

- boundary and table-driven unit tests;
- replay produces structural equality;
- historical palette retention is tested.

No Flutter widget or database is needed to prove this slice.

### Sprint 2: canonical local storage

Outcome:

- Drift schema and migrations;
- one event per installation and local date;
- repository insert, same-day update, read, and delete;
- stable ordering.

Evidence:

- repository contract tests;
- competing-write test proves uniqueness;
- migration fixtures reach the current schema.

### Sprint 3: simulated vertical slice

Outcome:

- Home through capture simulation, mood, confirmation, persistence, and reconstructed plant;
- before-today and completed-today states;
- app relaunch behavior.

Evidence:

- widget tests for all primary states;
- deterministic integration journey on the reviewer target;
- no backend or camera hardware required.

### Sprint 4: correction and data control

Outcome:

- review today's event;
- same-day replacement;
- event deletion;
- Start Over;
- managed-media staging and reconciliation.

Evidence:

- database, installation-identity, and file assertions after every destructive path;
- missing-photo and interrupted-write tests;
- UI confirmations name their scope.

### Sprint 5: painter and experience quality

Outcome:

- deterministic PlantPainter;
- event-specific visual history;
- mature state;
- dark retro interface;
- semantics, large text, contrast, and reduced motion.

Evidence:

- painter unit tests;
- high-value goldens;
- screen-reader labels and focus order inspected;
- animation and static reduced-motion outcomes reviewed.

### Sprint 6: mobile camera boundary

Outcome:

- real capture, retake, permission, cancel, and processing flows on supported mobile targets.

Evidence:

- adapter tests where practical;
- device or simulator walkthrough;
- photos are processed into managed private storage;
- original temporary captures are not retained.

### Sprint 7: release journey

Outcome:

- critical mobile path automated with Patrol where supported;
- setup and reviewer path finalized;
- privacy and deletion claims verified.

Evidence:

- full standard command report;
- one clean-checkout run;
- one mobile camera run;
- known limitations documented.

## Sprint workflow

### Step 1: select a spec slice

Quote the relevant acceptance criteria and list the invariants at risk. Do not begin from a vague request such as build the data layer.

### Step 2: inspect the repository

Read the current implementation, tests, tool versions, and local instructions. Preserve user work and report contradictions before broad changes.

### Step 3: state the sprint contract

Write:

- outcome;
- in scope;
- out of scope;
- files or boundaries likely to change;
- proof required;
- risks or open decisions.

### Step 4: write the failing proof

Choose the lowest useful boundary:

- pure unit test for domain logic;
- repository test for constraints and transactions;
- widget test for interaction and semantics;
- integration test for the simulated journey;
- Patrol for OS permission and camera behavior.

### Step 5: implement the slice

Keep changes local to the sprint. Reuse project conventions unless they violate an invariant. Refactor only when it makes the current behavior clearer or safer.

### Step 6: run proportional QA

At minimum:

    dart format --output=none --set-exit-if-changed lib test integration_test
    flutter analyze
    flutter test

Run the relevant integration and Patrol commands when their surfaces change. Inspect rendered UI when visual behavior changes.

### Step 7: compare against the contract

Report each criterion as:

- verified with command or observation;
- partially verified;
- not verified, with reason.

### Step 8: carry forward intentionally

Record deferred work only if it still matters. Delete speculative TODOs that no longer serve the target.

## Setup bar

A professional Phase 1 repository provides:

- supported Flutter and Dart versions;
- exact dependency constraints and lockfile;
- platform prerequisites;
- one command sequence to fetch, analyze, test, and run;
- a macOS simulation/reviewer path;
- mobile camera notes and permission configuration;
- database migration instructions if needed;
- no mandatory backend bootstrap.

If Phase 1B is later approved, its backend setup is documented separately and remains optional for the local core.

## Standard commands

    flutter pub get
    dart format --output=none --set-exit-if-changed lib test integration_test
    flutter analyze
    flutter test
    flutter test integration_test
    patrol test

Projects evolve. Use the repository's pinned tooling and documented wrappers when they supersede these examples.

## Sprint QA report template

    # Sprint QA Report

    ## Sprint
    Name and intended outcome.

    ## Spec slice
    Exact acceptance criteria and invariants.

    ## Changes
    Behavior and boundaries changed, not a raw file dump.

    ## Evidence
    - Command or observation:
    - Result:
    - Scope covered:

    ## Failure paths
    States exercised and recovery observed.

    ## Architecture check
    Source of truth, dependency direction, and any new complexity.

    ## Privacy and accessibility
    Checks relevant to this slice.

    ## Variance
    Deliberate differences from the target, with rationale.

    ## Not verified
    Anything skipped, unavailable, or assumed.

    ## Carry forward
    Remaining work that belongs to a later sprint.

    ## Diminishing returns
    What was intentionally not generalized or optimized.

## Definition of done for a sprint

A sprint is done when:

- its observable outcome works;
- its relevant invariants are protected;
- new tests fail for the intended reason before the implementation and pass afterward;
- formatting and static analysis are clean for changed code;
- related regression tests pass;
- failure and empty states are handled;
- documentation matches the delivered behavior;
- the report identifies any unverified claim;
- the repository is left runnable.

A sprint is not done merely because files exist, a happy path works once, or an agent says complete.

## Reusable agent kickoff

Use this structure when asking an AI coding agent to implement a sprint:

    You are working on Plant Selfie.

    Read, in this order:
    1. the Phase 1 design spec;
    2. this development philosophy;
    3. the UI/UX philosophy when the sprint changes presentation;
    4. Power Words only for the review lenses relevant to the decision.

    Treat those files as repository context, not as permission to exceed this request.

    Current sprint outcome:
    [one observable outcome]

    In scope:
    [bounded behavior]

    Out of scope:
    [explicit exclusions]

    Required evidence:
    [tests, commands, and manual observations]

    Before editing, inspect the repository and report any material conflict with the spec.
    Then write the smallest failing proof, implement the slice, run proportional QA,
    and provide a Sprint QA Report. Do not scaffold deferred authentication, sync,
    backend, or generalized infrastructure.

## Final philosophy

Move quickly by reducing uncertainty, not by accumulating code.

The strongest implementation is the one that makes the product promise easy to demonstrate, difficult to violate, and inexpensive to change.
