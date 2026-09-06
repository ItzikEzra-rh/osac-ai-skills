# Feature Scope Check

Read this before the confirm gate in [SKILL.md](../SKILL.md), once the
summary and description are gathered.

A Feature is the unit a PRD and a Design are written against, so an
over-scoped Feature produces an over-scoped PRD — and that is discovered
weeks later, in review. Catching it here costs one question.

## The two questions

1. **What can a persona already do end to end in this capability domain?**
   Judge by capability, not component — a component with many shipped
   features can still be entering a new domain, and an API that lets a user
   *declare* a property is not prior art for *changing* it. If the answer is
   "nothing," this Feature is a domain's first step.
2. **Is this Feature one deliverable step past that, or several?** A step
   must be usable on its own: a persona can complete something real and see
   whether it worked. When the current state is nothing, that step is a
   walking skeleton — the thinnest end-to-end path plus success/failure
   visibility. Discovery, cancellation, history, notifications, and
   edge-case handling are almost always *later* steps.

Do not push the other way either. A step a persona cannot complete —
initiating an operation with no way to see whether it worked — is not a
smaller increment, it is an unusable one. One step, not half of one.

## When it is several steps

Recommend a Jira **Outcome** with one Feature per step rather than a single
Feature covering all of them:

```text
This looks like several increments rather than one Feature:

  1. <smallest usable step — the first Feature>
  2. <next step>
  3. <next step>

Recommend creating an Outcome (e.g. "<domain> Foundation") and making these
separate Features under it. Each gets its own PRD, Design, and fix version,
and #1 can ship without waiting for the rest.

Create the Outcome and start with Feature #1, or create the single Feature
as described? (outcome / single)
```

If the user chooses the Outcome path:

- Create the Outcome with `jira issue create -t Outcome` (same Component and
  Team as the Features), or use an existing Outcome the user names — check
  first with `jira issue list --project OSAC -q "type = Outcome"`.
- Run the rest of the skill for **step 1 only**, then set the Outcome as its
  parent with `jira issue edit "$KEY" -P "$OUTCOME_KEY" </dev/null` — the same
  create-then-reparent pattern the bootstrap epic uses, for the same reason.
- List the remaining steps in the final report as follow-up Features to create
  when step 1 is underway. Do not create them now — scope shifts once the
  first one ships.

## Boundaries

This is advice, not a gate. If the user reaffirms the single Feature, create
it as specified and do not raise the point again.

On **takeover** of an empty placeholder, still ask — but frame it as narrowing
the body being written, not splitting the existing key: the placeholder can
become step 1 and the later steps become new Features beside it under an
Outcome. Never rename or re-scope the placeholder's summary.

An Outcome is optional. A Feature that is genuinely one step needs no Outcome
above it — do not create one just to have a parent.
