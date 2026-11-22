# OSAC Design Document (EP) — Section Guidance

Instructions for the AI on how to fill each section of the OSAC design template.
This file is read during the `/draft` phase. It is not included in the final output.

The design records the decisions reviewers must agree on before implementation:
what changes, the interfaces other components depend on, and the risks that
matter. Routine implementation mechanics belong in implementation PRs, not here.

## Plain Language

The reader is a busy engineer reviewing several documents this week. Write so
they understand each sentence on the first read.

- **Concrete actors and verbs.** Name who does what: "the fulfillment controller
  writes X to the ComputeInstance", not "reconciliation projects X into the hub".
- **Avoid abstract filler words** when a concrete word exists: contract,
  boundary, surface, shape, carry, hold, envelope, project/projection (as a
  verb), intent, posture, semantics. Say the API, the field, the table, the
  message, the check.
- **One rule per sentence, one condition per bullet.** No semicolon chains. No
  sentence with more than one "when", "unless", "only if" or "except".
- **Branching conditions go in a list or a table.** If behavior depends on two
  or more conditions, write a short lead sentence and then a bullet per
  condition, or a table of condition -> behavior.
- **Definitions go on their own line,** not in parentheses inside a rule. Put
  shared terms in a short Terminology list once and reuse them.
- **Say each thing once.** Before finishing, delete any sentence that restates
  another section. Link to the section instead.
- **Short sentences.** Aim for under 25 words. Split anything over 35.
- **Name things directly.** "Revision 5 replaces D4" not "Round 5 (date)
  supersedes D4, D8, and D12 and adds D14-D16".

## Length and Depth

- Scale depth to risk and blast radius, not to the number of template sections.
- Target: small change under 150 lines, medium under 300, large cross-component
  under 500 (excluding the Test Plan). If you exceed the target, cut mechanics
  and repetition before cutting decisions.
- Prefer a diagram plus three bullets over three paragraphs of flow description.

## General Rules

- **No customer or engagement names.** The `enhancement-proposals` repository
  is public. Never reference specific customer names, program names,
  engagement names, or other confidential business information. Describe the
  technical capability or deployment scenario instead.
- Write in third person, present tense.
- **Be specific where it matters.** Name the structure, the field, the cache
  strategy. Specific does not mean exhaustive: specify decisions, not every
  code path.
- **Traceability without inline noise.** Do not append source markers such as
  `[PRD: FR-3]`, `[Locked: D4]` or `[Research: §X]` to sentences. The
  frontmatter `prd` field covers the PRD. If a decision comes from somewhere
  non-obvious (a clarification, a user instruction, existing code), say so in
  plain words once: "Per the PRD clarification, ...", or link the file.
- **Incorporate, don't narrate.** Write each decision in its final form. Do not
  describe earlier positions, rounds, or what was superseded.
- Do NOT invent requirements. If the PRD doesn't specify something, flag it as
  an open question.
- If information is unavailable, write "To be determined — {what's needed}".
- **No silent scope reduction.** If something won't fit, say so and propose a split.
- **Formatting restraint.** Use bold sparingly.
- **Diagrams:** Use Mermaid when they add clarity, with one or two sentences on
  what the reader should take away. Keep them simple: labeled nodes and edges,
  no styling. No ASCII art or PlantUML.
- **Sections that do not apply.** Keep the required header so the EP review
  finds it, and write one line: "Not applicable: {reason}." Nothing more.

## Applying Review Feedback

When revising after review comments:

- An edge case raised in review becomes its own bullet, table row, or short
  sentence next to the rule. Never splice it into the existing sentence as an
  "unless ..." or "only when ..." clause.
- If a rule gains a third condition, convert it to a list or table.
- If the edge case is an implementation detail, answer it in the PR thread or
  defer it to implementation instead of growing the design.

## Per-Section Guidance

### YAML Frontmatter

- **title**: Lowercase slug with hyphens
- **authors**: The human who owns or requested this feature — never the AI assistant. Derive from `git config user.email` if available; otherwise ask.
- **creation-date** / **last-updated**: ISO dates
- **tracking-link**: Full Jira URL
- **prd**: Relative path to the PRD (typically `prd.md`)
- **see-also**: Related enhancements as paths
- **replaces/superseded-by**: Usually `N/A`

### Summary

1-2 sentences: what this design achieves and how. End with "See [PRD](prd.md) for detailed requirements."

### Motivation

1-2 short paragraphs. The current limitation in implementation terms and why
this approach. Do not repeat the PRD problem statement.

### Goals / Non-Goals

- Design-scoped constraints on the approach, not product outcomes (those are in the PRD).
- 3-5 goals and 2-4 non-goals, one sentence each.

### Proposal

1-2 paragraphs naming the key pieces (new APIs, CRDs, services, controller
changes) and how they relate. Add a Terminology list here if the design
introduces terms.

### Workflow Description

- Actors are OSAC personas (Provider, Tenant, Admin).
- Numbered steps from a defined starting state, naming the API involved.
- Cover the main error paths a user can hit, as separate steps or a short table.
- One Mermaid sequence diagram if there are more than three actors or hops.

### API Extensions

List each new or changed API, CRD, webhook or finalizer, one bullet each, with
its operational impact (what breaks if its controller is down).

### Implementation Details/Notes/Constraints

Only the decisions reviewers must agree on:

- Proto/CRD schema for new or changed resources, following the standard object
  shape in `osac/fulfillment-service/docs/API.md`.
- New or changed database tables, and whether the migration is additive.
- Ordering or consistency guarantees other components rely on.

Leave out step-by-step controller logic, function names and code-level flow.
Those are reviewed in implementation PRs.

### Security Considerations

- Authentication/authorization changes, input validation and data exposure risks.
- For multi-tenant features: how tenant isolation is enforced.
- If the existing model applies unchanged, say so in one sentence.

### Failure Handling and Recovery

- Only failures that change user-visible behavior, lose data, or need operator action.
- One table: failure | what happens | how it recovers | what the user sees.
- Generic retry behavior of standard controllers needs no entry.

### RBAC / Tenancy

- Tenant-scoped resources carry `osac.openshift.io/tenant` and, where applicable, `osac.openshift.io/owner-reference`.
- State visibility rules in one or two bullets.
- If unchanged: "No RBAC or tenancy changes."

### Observability and Monitoring

- New metrics, events or alerts, one bullet each: name, type, when it matters.
- If none: "Not applicable: existing monitoring applies."

### Risks and Mitigations

- Technical risks only, one bullet each with its mitigation.

### Drawbacks

- 2-4 bullets: the strongest honest arguments against this design.

### Alternatives (Not Implemented)

- Alternatives for the one to three decisions reviewers are most likely to question.
- For each: one line on what it is, one line on why not.

### Open Questions

- Optional. Numbered, each with Owner and Impact. Omit the section if none.

### Test Plan

- A short list of the scenarios that prove the design works, grouped by Unit,
  Integration, E2E. The detailed test plan lives in `testplan.md`.

### Graduation Criteria

- If not targeting a release: one line saying so.

### Upgrade / Downgrade Strategy

- New API: one line. Changed API: the migration steps.

### Version Skew Strategy

- One line unless components must roll out in a specific order.

### Support Procedures

- How an operator detects the problem, disables the feature, and recovers. Bullets, not prose.

### Infrastructure Needed

- Usually "None".
