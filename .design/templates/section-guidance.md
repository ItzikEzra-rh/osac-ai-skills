# OSAC Implementation Design — Section Guidance

Instructions for the AI on how to fill each section of the OSAC design template
(`.design/templates/design.md`). This file is read during the `/draft` phase.
It is not included in the final output.

The design captures what implementers need to build the feature correctly and
what reviewers must agree on. Motivation and goals live in the PRD.
Alternatives, trade-offs and open questions live in the design brief.

## Plain Language

The reader is a busy engineer reviewing several documents this week. Write so
they understand each sentence on the first read.

- **Concrete actors and verbs.** Name who does what: "the fulfillment controller
  writes X to the ComputeInstance", not "reconciliation projects X into the hub".
- **Avoid abstract filler words** when a concrete word exists: contract,
  boundary, surface, shape, carry, hold, envelope, project/projection (as a
  verb), intent, posture, semantics.
- **One rule per sentence, one condition per bullet.** No semicolon chains. No
  sentence with more than one "when", "unless", "only if" or "except".
- **Branching conditions go in a list or a table.**
- **Definitions go on their own line,** not in parentheses. Put shared terms in a
  short Terminology list at the start of High-Level Design.
- **Say each thing once.** Link to the section instead of restating it.
- **Short sentences.** Aim for under 25 words. Split anything over 35.

## Depth

- Scale depth to risk. Small change under 150 lines, medium under 300, large
  cross-component under 500.
- Cut routine mechanics (function names, step-by-step controller code paths)
  before cutting rules that keep the system correct.
- **Never cut correctness rules.** Every invariant the design depends on goes in
  Guard Rails, even if it is internal to one component. For stateful or
  billing-like systems this includes: which writes are atomic together, how
  duplicates are prevented, what is recomputed versus stored, and what happens
  on crash, restart, restore and failure of a resource.
- Specify decisions with concrete values: schemas, field names, topic names,
  identifiers, retention.

## Grounding

- Before describing a component as new or existing, check the source tree.
- When the design changes behavior defined in another accepted EP, name the EP
  and the specific difference.

## General Rules

- **No customer or engagement names.** The repository is public.
- Write in third person, present tense.
- **No inline source markers** such as `[PRD: FR-3]`, `[Locked: D4]` or
  `[Research: §X]`. Refer to PRD identifiers in plain words where it helps:
  "PRD CAP-8 asks for ...".
- **Incorporate, don't narrate.** Final positions only, no history of rounds.
- Do NOT invent requirements.
- **Diagrams:** Mermaid, simple, with one or two sentences on the takeaway.
- **Formatting restraint.** Use bold sparingly.

## Per-Section Guidance

### Scope
- One bullet per PRD capability: delivered here, or deferred with where it goes.
- This prevents silent scope growth or loss. Decide it first.

### High-Level Design
- Terminology list if the design introduces terms.
- Components and their responsibilities, one bullet each.
- One diagram of the main data flow.

### Guard Rails
- 5-15 bullets. Each is a rule that, if broken, causes wrong results, data loss,
  duplicate processing, or a tenant isolation breach.

### API and Access Changes
- Proto/CRD/table definitions for new or changed resources, following
  `osac/fulfillment-service/docs/API.md`.
- Who can call or read what: tenant, project and provider scoping.

### Observability
- New metrics, events and log fields, one bullet each with when it matters.

### Security
- Authentication, authorization, data exposure. One line if unchanged.

### Scale
- Expected load, the first bottleneck, and how it scales.

### Upgrade and Compatibility
- Migration steps, version skew, backward compatibility. One line for a new API.

### Deployment
- How it is installed and configured, and what is optional.

### Failure Handling and Recovery
- One table: failure | what happens | recovery | what the user sees.
- Only failures that change behavior, lose data, or need operator action.

### Gotchas
- Edge cases from review or analysis go here as separate bullets, never as
  "unless" clauses inside other sections.

### Validation Strategy
- The scenarios that prove the Guard Rails hold, by tier (unit, integration, e2e).

### Open questions
- Open questions belong in the design brief. If no brief exists, end the
  document with "Open Questions for the Brief", one bullet each, at most 6.
  Resolve questions that could change implementation before the design is
  marked ready to build.
