# Power Words

## Why this document exists

This document gives people and coding agents a compact set of expert review lenses for Plant Selfie.

A power word is a prompt for disciplined reasoning. It is not:

- a claim that an expert endorses this product;
- permission to imitate a person's writing style;
- a substitute for evidence;
- a reason to add fashionable architecture;
- an instruction that overrides the product spec.

Use the smallest relevant set of lenses, state what each reveals, and connect recommendations to this repository.

## Local contract

The Phase 1 product is:

- accountless;
- offline-first;
- one private companion per installation;
- one growth-producing check-in per local calendar day;
- based on self-reported mood;
- reconstructed deterministically from canonical GrowthEvent rows;
- designed for individual and full deletion;
- mobile-first, with a deterministic macOS reviewer path;
- intentionally free of backend and sync dependencies.

The central risk is no longer can we build a plant from a selfie. The risk is allowing hidden duplication, date ambiguity, file leakage, or speculative infrastructure to make a small product unreliable.

Every lens in this document must be interpreted through that contract.

## How to invoke a lens

A useful invocation has five parts:

1. **Decision:** the concrete choice being reviewed.
2. **Lens:** the named principle or body of work.
3. **Finding:** what becomes visible through that lens.
4. **Action:** a specific change, test, or deliberate non-change.
5. **Evidence:** how the action will be verified.

Example:

> Review same-day save through Jim Gray's transaction lens. UI disabling is insufficient because two writes can race. Enforce a unique installation/date index and transactional upsert, then prove it with competing repository writes.

An invocation such as make it like Martin Fowler is not actionable.

## Five working stances

These are team stances, not historical authorities. Use them to prevent one mode of thinking from dominating.

### Contrarian

Ask:

- Which accepted premise might be unnecessary?
- What feature is present because similar apps have it?
- What would improve if we removed the dependency?

Plant Selfie example:

Authentication looked conventional but delayed the first moment of value. Phase 1 removes it and requires a user benefit before adding it back.

Guardrail:

Contrarian review still respects proven constraints. It does not reject a database unique index simply because constraints feel conventional.

### First Principles

Ask:

- What must remain true for the promise to be honest?
- What is the smallest source of truth?
- Which rule must survive restarts and races?

Plant Selfie example:

The product needs recorded daily events and a reproducible plant. Therefore events are canonical, while PlantState is derived.

Guardrail:

First-principles reasoning does not mean rebuilding established tools from scratch.

### Expansionist

Ask:

- What valuable extension becomes possible if the core boundary is clean?
- Which present choice creates or removes future options?
- Is there a low-cost seam worth preserving?

Plant Selfie example:

Algorithm versions and repository boundaries allow old plants to replay after future growth-rule changes. They preserve an option without requiring sync or plugins now.

Guardrail:

An extension is not Phase 1 scope merely because it is imaginable.

### Outsider

Ask:

- What would a first-time user or reviewer misunderstand?
- Which terms make sense only to the implementation team?
- What claim cannot be observed from outside?

Plant Selfie example:

One event per day is technical language. The interface needs to say today's check-in is complete and that review changes it rather than adding more growth.

Guardrail:

Do not flatten a meaningful product character into generic enterprise language.

### Executor

Ask:

- What is the next demonstrable slice?
- What failing proof should exist first?
- What is explicitly out of scope?
- What evidence closes the sprint?

Plant Selfie example:

Before building camera integration, complete the simulated Home to confirmation loop with deterministic persistence and replay.

Guardrail:

Execution speed does not excuse silently changing the contract.

## Product and interaction lenses

### Don Norman: conceptual model and affordance

Core ideas:

- users act through a mental model of the system;
- controls should suggest their available action;
- feedback should connect action to outcome;
- errors often reveal design problems, not user incompetence.

Use for:

- daily check-in mental model;
- capture, retake, and confirmation controls;
- same-day correction;
- deletion and Start Over;
- cause and effect in the growth reveal.

Plant Selfie question:

> Does the user understand that today's confirmation changes one event and one plant contribution?

Concrete application:

- change the Home action from TAKE TODAY'S SELFIE to REVIEW TODAY'S CHECK-IN after completion;
- explain replacement before saving an edit;
- reveal the new contribution only after persistence succeeds.

Misuse:

Do not cite affordance to justify decorative realism that reduces clarity.

### Jakob Nielsen: usability heuristics

Core ideas:

- system status must be visible;
- language should match the user's world;
- users need control and recovery;
- consistency reduces cognitive cost;
- error prevention is preferable to error messaging.

Use for:

- saving and completion status;
- camera denial;
- missing photo behavior;
- delete confirmation;
- navigation consistency.

Plant Selfie question:

> At every point, can the user tell what is saved, what remains editable, and how to recover?

Concrete application:

- preserve the preview and mood on recoverable save failure;
- show a missing-photo placeholder without discarding the event;
- name the date and scope in destructive dialogs.

Misuse:

Heuristics guide review; they are not a numerical design score.

### Steve Krug: eliminate unnecessary thought

Core idea:

The main action and next state should be apparent without tutorial dependence.

Use for:

- Home hierarchy;
- first launch;
- mood selection;
- History scanability.

Plant Selfie question:

> Can a new user identify the next meaningful action in a few seconds?

Concrete application:

Keep one dominant daily action and make history/settings visibly secondary.

Misuse:

Do not use simplicity as a reason to omit privacy context or destructive scope.

### Dieter Rams: less, but better

Core ideas:

- useful;
- understandable;
- restrained;
- thorough;
- durable.

Use for:

- rejecting dashboard clutter;
- limiting decorative effects;
- choosing a small component system;
- protecting the plant as the hero.

Plant Selfie question:

> Does this element help the ritual, explain system state, or make the plant more legible?

Concrete application:

Remove streak counters, redundant summary cards, and decorative controls that compete with the plant.

Misuse:

Restraint is not blankness. The product still needs warmth and a distinct visual identity.

### Material Design: behavior and component foundation

Core ideas:

- consistent component states;
- responsive layout;
- accessible touch interaction;
- predictable dialogs, sheets, focus, and navigation.

Use for:

- Flutter component selection;
- touch targets;
- loading and pressed states;
- responsive mobile/reviewer layouts.

Plant Selfie question:

> Can themed Material 3 behavior provide this interaction before we create a custom component?

Concrete application:

Use one ThemeData and token layer. Customize expression without creating a second button or dialog system.

Misuse:

Material is a foundation, not a requirement to look like a default template.

### WCAG: perceivable, operable, understandable, robust

Use for:

- contrast;
- non-color state cues;
- screen-reader semantics;
- focus order;
- 200 percent text scaling;
- reduced motion.

Plant Selfie question:

> Does the complete daily loop remain understandable without color, animation, precise touch, or default text size?

Concrete application:

- label mood choices and selected state;
- summarize the canvas as one meaningful semantic node;
- show the same final plant under reduced motion;
- use at least 48 by 48 logical-pixel targets.

Misuse:

Passing one contrast calculation does not prove an accessible journey.

## System design lenses

### David Parnas: information hiding

Core idea:

Modules should hide decisions likely to change, not merely group steps in execution order.

Use for:

- persistence boundary;
- media path handling;
- camera adapter;
- growth algorithm versions.

Plant Selfie question:

> Which volatile decision does this interface hide?

Concrete application:

CompanionRepository hides Drift schema and transaction details. ManagedMediaStore hides safe directories, staging names, and cleanup.

Misuse:

Do not create interfaces for stable value objects or every function.

### John Ousterhout: deep modules

Core idea:

A strong module offers substantial capability through a small, coherent interface. Shallow layers increase cognitive load.

Use for:

- application boundaries;
- provider structure;
- repository API;
- avoiding service chains.

Plant Selfie question:

> Does this abstraction remove complexity for its caller, or only rename it?

Concrete application:

A SaveDailyCheckIn use case can coordinate clock, rules, media, and repository semantics while exposing one intentional operation. Five pass-through services would be worse.

Misuse:

Deep does not mean oversized. A module still needs one coherent responsibility.

### Butler Lampson: hints versus guarantees

Core idea:

Place correctness properties at the layer that can guarantee them. Higher layers may provide hints and convenience.

Use for:

- daily uniqueness;
- save-button disabling;
- deletion;
- cache design.

Plant Selfie question:

> Is this rule guaranteed by storage, or merely suggested by the UI?

Concrete application:

The UI disables duplicate submission as feedback. SQLite provides the unique installation/date guarantee.

Misuse:

Not every interaction needs database enforcement. Apply this lens to correctness properties.

### Barbara Liskov: behavioral substitutability

Core idea:

Implementations of a contract must preserve its observable promises, including failure behavior.

Use for:

- in-memory and Drift repositories;
- simulated and mobile cameras;
- fake and real media stores.

Plant Selfie question:

> Would the application behave correctly if this fake were replaced with the production adapter?

Concrete application:

Run shared repository contract tests against in-memory test implementations and Drift. Both must preserve ordering, upsert, delete, and error semantics.

Misuse:

Matching method signatures is not behavioral substitutability.

### Leslie Lamport: state transitions and concurrency

Core idea:

Reason about what can happen between states, including repeated, reordered, or competing operations.

Use for:

- rapid double save;
- same-day correction;
- interruption during media promotion;
- relaunch reconciliation.

Plant Selfie question:

> What state is visible if this operation repeats or stops after each step?

Concrete application:

Specify check-in states such as draft, staged media, committed event, and promoted media. Test interruption boundaries and idempotent recovery.

Misuse:

Phase 1 does not need formal verification infrastructure. It needs explicit transitions for risky workflows.

### Jim Gray: transactions

Core ideas:

- atomicity;
- consistency;
- isolation;
- durability.

Use for:

- daily upsert;
- event replacement;
- event deletion;
- Start Over database work.

Plant Selfie question:

> Which changes must succeed or fail together inside SQLite?

Concrete application:

Use a transaction plus unique index for same-day upsert. Keep filesystem reconciliation separate because database and files cannot share one atomic transaction.

Misuse:

Do not pretend a database transaction also makes a file write atomic.

### Martin Kleppmann: data as a durable contract

Core ideas:

- choose sources of truth deliberately;
- distinguish derived data from canonical data;
- evolve schemas compatibly;
- make replay and correction explicit.

Use for:

- GrowthEvent schema;
- PlantState projection;
- algorithm versioning;
- migrations.

Plant Selfie question:

> Can this stored event still be interpreted after the application evolves?

Concrete application:

Persist algorithmVersion, randomSeed, and resolved growthDelta. Test migrations from the oldest shipped fixture.

Misuse:

Do not import distributed-systems complexity into a single-device product.

### Martin Fowler: patterns as vocabulary

Core idea:

Patterns help name recurring tradeoffs, but context determines whether they are useful.

Useful local vocabulary:

- Repository;
- Value Object;
- Service Layer or use case;
- Gateway/adapter;
- Event Sourcing as a comparison, not a Phase 1 platform choice.

Plant Selfie question:

> Does naming this pattern clarify ownership and consequences?

Concrete application:

Call PlantState a projection from canonical events. Do not claim a full event-sourced architecture with infrastructure the app does not need.

Misuse:

A pattern name is not proof of good design.

### Eric Evans: domain language

Core idea:

Use precise shared terms that match product behavior.

Preferred local language:

- check-in;
- GrowthEvent;
- growth contribution;
- PlantState;
- managed selfie;
- current local date;
- mature plant;
- Start Over.

Avoid:

- session for a daily event;
- logout for local deletion;
- emotion detection;
- sync when only local persistence exists.

Plant Selfie question:

> Do product copy, tests, classes, and documentation mean the same thing by check-in?

Misuse:

The product does not need full strategic domain-driven design or bounded-context machinery in Phase 1.

## Flutter and delivery lenses

### Riverpod: explicit state ownership

Core ideas:

- dependencies are visible;
- asynchronous states are modeled;
- test overrides are possible;
- widgets observe state rather than own persistence.

Use for:

- current companion projection;
- daily check-in workflow;
- history loading;
- error and retry states.

Plant Selfie question:

> Who owns this state, how long should it live, and how is it replaced in a test?

Concrete application:

Keep draft photo and mood route-scoped when possible. Put repository-backed companion state in a feature provider with explicit loading, data, and error outcomes.

Misuse:

Do not create providers for every local value or hide business rules inside provider callbacks.

### Flutter testing and golden discipline

Core ideas:

- pure logic belongs in fast unit tests;
- widgets prove interaction, layout, and semantics;
- goldens protect chosen visual contracts;
- integration tests prove wiring.

Use for:

- growth rules;
- painter determinism;
- daily Home states;
- large text;
- simulated end-to-end review.

Plant Selfie question:

> What is the lowest boundary that can prove this behavior without making the test brittle?

Concrete application:

Test growth numerically before testing pixels. Use goldens for empty Home, completed-today Home, and mature state rather than every screen permutation.

Misuse:

Large snapshot suites can freeze incidental pixels and hide behavioral gaps.

### Patrol: operating-system boundary

Core idea:

Some failures exist only where the app meets real permissions and native UI.

Use for:

- camera permission;
- capture flow;
- app relaunch;
- supported mobile platform behavior.

Plant Selfie question:

> Which claim cannot be proven by the simulation path?

Concrete application:

Keep the deterministic integration path for fast review, then use a focused Patrol journey for the real mobile camera boundary.

Misuse:

Do not make every domain scenario a slow device test. Desktop support can change; verify current tool support when configuring the suite.

### Kent Beck: test feedback and simple design

Core ideas:

- make behavior visible through tests;
- work in small steps;
- remove duplication;
- express intent clearly;
- avoid speculative elements.

Use for:

- sprint slicing;
- deterministic rules;
- repository contracts;
- refactoring after green.

Plant Selfie question:

> What is the smallest failing example that would force the correct behavior?

Concrete application:

Start same-day semantics with one repository test that saves twice on the same date and expects one updated event.

Misuse:

TDD does not mean mocking every class or refusing necessary integration tests.

### Ward Cunningham: technical debt as a learning gap

Core idea:

Debt is dangerous when implementation and understanding diverge. Make deliberate shortcuts visible and payable.

Use for:

- deferred migrations;
- temporary reviewer adapters;
- known media limitations;
- decision records.

Plant Selfie question:

> Is this shortcut based on a conscious tradeoff, and what evidence would trigger repayment?

Concrete application:

A simple projection is correct until profiling shows replay latency. Record the measurement threshold rather than adding a speculative snapshot.

Misuse:

Do not label ordinary unfinished work as strategic debt.

### Jez Humble and Dave Farley: continuous delivery

Core ideas:

- keep software releasable;
- automate repeatable checks;
- prefer small reversible changes;
- make deployment and setup routine.

Use for:

- sprint completion;
- clean-checkout setup;
- standard commands;
- migration safety.

Plant Selfie question:

> Can another person reproduce this result without the original agent's hidden state?

Concrete application:

End each slice runnable, pin dependencies, and include exact evidence in the sprint report.

Misuse:

Phase 1 does not need a complex release platform to practice delivery discipline.

## Reliability, performance, and privacy lenses

### Michael Nygard: stability patterns

Core idea:

Failures cross boundaries. Name, isolate, and recover from the realistic ones.

Use for:

- camera cancellation;
- storage exhaustion;
- corrupt database values;
- missing files;
- repeated retry.

Plant Selfie question:

> What happens when this dependency fails, slows, or returns an unexpected state?

Concrete application:

Keep user input across recoverable save failure and make reconciliation idempotent.

Misuse:

Do not add distributed circuit breakers to local file operations. Use the principle at the scale of the product.

### Google SRE: service level thinking

Core idea:

Reliability is an observable user outcome with a budget and tradeoff, not a vague aspiration.

Use for:

- defining successful daily save;
- measuring launch and projection latency;
- deciding whether replay optimization is needed;
- tracking crash-free critical journeys.

Plant Selfie question:

> Which user outcome matters, and what measurement would tell us it is degrading?

Concrete application:

Measure time from confirmation to durable event and visible growth. Do not optimize an internal function with no user-visible impact.

Misuse:

A local Phase 1 app does not need a full on-call or SRE organization.

### Brendan Gregg: measure before optimizing

Core idea:

Build a performance model from evidence, identify the bottleneck, and optimize the limiting resource.

Use for:

- event replay;
- CustomPainter;
- image resizing;
- app startup.

Plant Selfie question:

> Do we know where the time or memory is spent under realistic history sizes?

Concrete application:

Benchmark replay and paint with several years of daily events before considering persisted snapshots. Profile image processing on representative devices.

Misuse:

Do not cite performance without a workload and measurement.

### OWASP and Adam Shostack: threat modeling

Core ideas:

- identify assets;
- map trust boundaries and data flows;
- enumerate plausible misuse;
- choose mitigations proportional to risk.

Phase 1 assets:

- private selfie files;
- mood and date history;
- installation identifier;
- database contents;
- logs and crash reports.

Phase 1 boundaries:

- camera temporary output;
- application-private media directory;
- SQLite;
- OS backup and device storage;
- any future analytics SDK.

Plant Selfie question:

> Where can private data escape, persist after deletion, or enter logs?

Concrete application:

Validate managed paths before deletion, exclude sensitive fields from diagnostics, and verify staging/final-file cleanup.

Misuse:

Do not claim perfect local privacy or end-to-end encryption when the platform does not provide it.

### Ross Anderson: security is a systems property

Core idea:

Security claims depend on the whole system, including incentives, defaults, recovery, and operations.

Use for:

- privacy copy;
- deletion;
- future backups;
- permissions and export.

Plant Selfie question:

> Does the interface claim more protection than storage, backups, logging, and recovery actually provide?

Concrete application:

Say photos stay on this device in Phase 1. Do not say only you can ever access them unless the entire platform model supports that statement.

Misuse:

Security review should improve honest product behavior, not paralyze a local prototype with irrelevant enterprise controls.

## Phase 1B-only lenses

These become primary only if optional accounts, backup, or sync are approved. They must not pull Phase 1 toward a backend.

### Roy Fielding and Arnaud Lauret: resource-oriented API design

Use for:

- stable resource names;
- HTTP semantics;
- status codes;
- idempotency;
- evolvable contracts.

Future question:

> Are check-ins represented as durable resources with clear identity and replacement semantics?

Possible application:

Use an idempotency key for remote daily check-in creation and explicit versioning for breaking API changes.

### Sam Newman: service boundaries and evolutionary architecture

Use for:

- deciding whether any backend separation is justified;
- avoiding a premature service split;
- planning strangler-style migration if an existing monolith later needs change.

Future question:

> Which independent business capability and operational need justify a separate service?

Default answer for early Plant Selfie:

One modular backend is safer than microservices.

### Kleppmann, Lamport, and Gray together: sync conflicts

Before sync, specify:

- event identity across installations;
- how one daily event is selected or merged;
- clock and timezone semantics;
- delete propagation and tombstones;
- media upload state;
- offline edits;
- retry and idempotency;
- account deletion and backup retention.

Do not describe upload plus last-write-wins as solved sync without reviewing data loss behavior.

## Secondary vocabulary

Use these when a decision genuinely calls for them:

| Name or body of work | Useful local question |
|---|---|
| Robert C. Martin | Does dependency direction keep domain rules independent from frameworks? |
| Grady Booch | Do structure and behavior tell one coherent architectural story? |
| Gang of Four | Is a small established pattern clearer than custom branching? |
| Apple Human Interface Guidelines | Does iOS permission and navigation behavior feel platform-appropriate? |
| Flutter platform guidance | Does Android behavior respect current platform conventions? |
| HashiCorp-style operations | If infrastructure arrives, is configuration explicit and reproducible? |

Secondary does not mean unimportant. It means these lenses are less central to the current risk profile than data ownership, deterministic replay, deletion, and daily semantics.

## Power words that do not belong in Phase 1

Reject these unless a concrete measured need is approved:

- microservices;
- Kubernetes;
- service mesh;
- CQRS infrastructure;
- distributed event bus;
- vector database;
- blockchain;
- facial emotion AI;
- multi-agent runtime;
- generalized plugin marketplace;
- real-time collaborative editing;
- globally distributed consistency.

Some may be valid in other products. Here they obscure the current problem.

## Short invocation map

| Decision | Start with |
|---|---|
| Daily user journey | Norman, Nielsen, Krug |
| Visual restraint and system | Rams, Material, WCAG |
| Module boundary | Parnas, Ousterhout |
| UI rule versus real guarantee | Lampson, Gray |
| Fake versus production adapter | Liskov |
| Interrupted or repeated workflow | Lamport, Nygard |
| Canonical events and replay | Kleppmann, Evans |
| Flutter state ownership | Riverpod |
| Test boundary | Beck, Flutter testing, Patrol |
| Performance concern | Gregg, SRE |
| Privacy or deletion claim | OWASP/Shostack, Anderson |
| Scope pressure | Contrarian, First Principles, Executor |
| Future extension | Expansionist, Parnas |
| First-time comprehension | Outsider, Krug |
| Future API | Fielding/Lauret |
| Future sync | Kleppmann, Lamport, Gray |

## Acceptance standard

A power-word review is complete only when it:

- names the decision;
- uses no more lenses than needed;
- identifies a repository-specific consequence;
- distinguishes an invariant from a preference;
- recommends a concrete action or deliberate non-action;
- names the verifying evidence;
- respects the Phase 1 boundary;
- does not treat reputation as proof.

## Relationship to other documents

Read in this order:

1. [Phase 1 Design Spec](../superpowers/specs/2026-08-21-plant-selfie-design.md) for the product and system contract.
2. [Development Philosophy](development-philosophy.md) for execution and QA.
3. [UI/UX Design Philosophy](ui-ux-design-philosophy.md) for interface decisions.
4. This document for targeted review lenses.

Power Words helps interrogate the contract. It does not replace it.

## Final guidance

The strongest review is not the one with the most famous names. It is the one that finds the hidden assumption, makes the tradeoff explicit, and leaves behind a testable decision.
