---
name: integration-coverage-review
description: Integration-coverage review of a branch's changes before PR submission. Reads the consumer repo's own integration-testing guide and component agent-doc touched-area maps, classifies every touched behavior as unit-only or boundary-crossing, and flags changed boundaries whose qualifying suite, tier, executed command, or real-vs-faked disclosure is missing — mocks and unit doubles never satisfy a documented real boundary. Use standalone before opening a PR, or via create-pr's config-driven pre-flight gate, which invokes it directly. Repos without OSAC integration-testing documentation are out of scope and report NONE.
allowed-tools: Read, Grep, Bash, Glob
metadata:
  version: "0.2.0"
---

# Integration Coverage Review

Per-component integration-coverage review of a branch's changes — checks that
every touched boundary has qualifying coverage while it is still cheap to fix,
before the change is pushed or reviewed.

This is one of the reviewers in OSAC's pre-flight review gate. When run via
`create-pr`'s Step 4, it is one of the reviewers
`skills/.config/create-pr-reviewers.yaml` currently enables — `create-pr`
invokes each reviewer directly and in parallel. It is also independently
invocable — run it any time you want a coverage pass without going through a
gate. It does not self-report PASS or BLOCKED; severity labels are its only
contribution toward an eventual gate decision.

**Severity contract:** tag every finding `CRITICAL`, `IMPORTANT`, or
`ADVISORY` — the shared vocabulary with `review-gate`'s Severity section.
`CRITICAL`/`IMPORTANT` block; `ADVISORY` doesn't.

## Scope

Review **everything this branch has changed since diverging from `{BASE}`**
(`{BASE}` is `main` by default — set it yourself if this branch is stacked on
another and you run this standalone), plus any untracked files:

```bash
MERGE_BASE=$(git merge-base {BASE} HEAD)
git diff "$MERGE_BASE" --name-only
git diff "$MERGE_BASE"
git ls-files --others --exclude-standard
```

**If `git merge-base` fails** (`{BASE}` stale, unfetched, or doesn't exist),
stop and report the exact git error — don't treat a failed lookup as nothing
to review. Diff from the merge-base, not `{BASE}` directly — `{BASE}` moves,
and a raw `git diff {BASE}` pulls in changes this branch never made.

**`git diff` alone misses untracked files.** If
`git ls-files --others --exclude-standard` lists anything, read each listed
file in full and include it in scope exactly as if it were an added file —
a brand-new controller or integration test that was never `git add`-ed
produces no diff output at all.

## What the review reads

The judgment of required coverage comes from the **consumer repo's own
documentation**, never from this skill. Locate and read:

- `docs/INTEGRATION-TESTING.md` — the shared tier definitions and the
  affected component's section (touched-area requirements, test tiers and
  commands table, coverage notes, and coverage gaps with their follow-up
  tickets).
- The affected component's own `AGENTS.md` — its touched-area map and
  integration-testing section.

**Repos without OSAC integration-testing documentation are out of scope.**
If the consumer repo has no `docs/INTEGRATION-TESTING.md` and no component
touched-area map, report `NONE` with a one-line rationale — do not invent
tiers, suites, or requirements the repo never documented.

## What to check

For each changed behavior, classify it against the consumer repo's tier
definitions:

1. **Unit-only or boundary-crossing.** A change is unit-only when it touches
   no component boundary (no persistence, no deployed controller, no provider
   protocol, no cross-component call). A unit-only classification needs a
   rationale. Changes with no code are exempt only when they cannot alter
   boundary behavior; classify any change that can — including tooling and
   generated configuration — against the touched boundaries per the rules
   below.
2. **Wrong-tier substitution.** For a boundary-crossing change, does a test
   exist at the tier the repo's guide names for that boundary? Unit tests and
   mocks do not satisfy a documented real boundary; a fixture-only or
   double-only suite is not coverage of a real provider, deployed service, or
   real storage backend merely because it is labelled integration.
3. **Executed evidence.** The repo's guide names the suite and command for
   each tier. A required command with no executed, passing run is planned, not
   covered — record what execution would require (command, working directory,
   prerequisites) rather than treating its absence as satisfied.
4. **Gap linkage.** Where the repo's guide documents a coverage gap with an
   owning follow-up ticket, a change touching that boundary must cite the gap
   as unresolved — never as covered. A change touching a boundary with no
   documented follow-up must report the gap as unresolved; do not invent a
   ticket.

## Findings

Tag one severity per finding, with a concrete file, behavior, and the doc
passage (or gap ticket) the finding rests on:

- `CRITICAL` — the change would report a documented real boundary as covered
  on the strength of unit tests, mocks, or test doubles alone; or coverage is
  claimed for a boundary the repo's guide explicitly lists as a tracked gap,
  contradicting that guide.
- `IMPORTANT` — a boundary-crossing change has no qualifying test at the named
  tier, or the named integration command has no executed evidence, or a
  touched documented gap is not cited as unresolved.
- `ADVISORY` — classifications recorded but vague (no rationale, no command
  citation); traceability or wording improvements worth raising, not worth
  gating.

A finding names the changed file or behavior and the repo's own doc passage
applied — never a requirement this skill supplies from outside the repo.

## Output

Standalone use: findings as lines in the form
`[CRITICAL|IMPORTANT|ADVISORY] file:line — description — suggested fix`, or
exactly `integration coverage review: no findings` when the branch carries no
findings and the repo's documentation covers the touched components.

When spawned by `create-pr`, that invocation's response-format instructions
override this section — emit exactly that invocation's format, and never a
PASS/BLOCKED verdict: gate decisions belong to the caller, not this review.
