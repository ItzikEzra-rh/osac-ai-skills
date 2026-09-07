# Outcome Creation and Parenting

Step 2a of the Jira create workflow in [SKILL.md](../SKILL.md), and only when
[scope-check.md](scope-check.md) set `OUTCOME_MODE`. Skip this file entirely
when the Feature is one step and needs no Outcome — most Features do not.

An Outcome groups the Features that deliver one capability domain
incrementally: `Outcome → Feature → Bootstrap epic → gate tasks`.

## Ordering

The Outcome is created **after** the confirm gate, alongside the Feature —
never during the scope check. Declining the gate must leave Jira untouched,
so nothing is created while the user is still deciding.

Use `</dev/null` on every create and edit, like the rest of this skill
(jira-cli#948 — a create or edit without it can hang waiting on stdin).

## Create or reuse

`OUTCOME_MODE=existing` — the user named a key. Verify it before parenting:

```bash
jira issue view "$OUTCOME_KEY" --raw </dev/null
```

If the view fails, `.fields.project.key` is not `OSAC`, or
`.fields.issuetype.name` is not `Outcome`, report it, skip parenting, and
continue the bootstrap with the Feature unparented — the Feature already exists
by this step, so never abort here. To offer the user a list first:

```bash
jira issue list --project OSAC -q "type = Outcome" --plain --no-headers </dev/null
```

`OUTCOME_MODE=new` — create it with the same Component and Team as the
Feature. `OUTCOME_SUMMARY` takes the same validation as `FEATURE_SUMMARY`
(see SKILL.md's Feature summary rules); reject and re-ask on failure. Write the
body to a temp file first and pass it with `--template`, as the Feature create
does — one paragraph naming the capability domain, then step 1 and
`DEFERRED_STEPS` as the Features that will hang off it:

```bash
OUTCOME_BODY=$(new_temp osac-outcome-body)
add_temp "$OUTCOME_BODY"
# write the markdown body to $OUTCOME_BODY, then:

jira issue create -t Outcome -P OSAC \
  -s "$OUTCOME_SUMMARY" -C "$COMPONENT" --template "$OUTCOME_BODY" \
  --no-input </dev/null
```

Team is not writable via jira-cli — on a **new** Outcome, apply it with
`apply_team` as the Feature does (see [bash-patterns.md](bash-patterns.md)).
Never touch an existing Outcome's Team or Component; verify and parent only.
Capture the key into `OUTCOME_KEY` and validate it matches `OSAC-[0-9]+`
before using it.

## Parent the Feature

Create the Feature first, then reparent — the same create-then-edit pattern
the bootstrap epic uses, and for the same reason (a create with `-P` against
this hierarchy returns HTTP 400):

```bash
jira issue edit "$KEY" -P "$OUTCOME_KEY" </dev/null
```

Verify with `jira issue view "$KEY" --raw </dev/null` and re-check
`.fields.parent.key`. The bootstrap epic still parents to the **Feature**,
not to the Outcome.

## Failures

Every failure here is non-fatal. The Feature is the unit the PRD and Design
hang off; it stands on its own without an Outcome, so never abort the
bootstrap over Outcome trouble.

| Failure | Action |
|---------|--------|
| Outcome summary fails validation | Ask the user to revise before the confirm gate; do not create |
| User-supplied key is not an OSAC Outcome, or the view fails | Report type and project; ask for another key or drop to no Outcome; never reparent; continue the bootstrap |
| Outcome create failed (no `OUTCOME_KEY`) | Continue with no Outcome — report that the Feature was created unparented and the deferred steps are untracked. **Do not print a reparent command**; there is no key to reparent to |
| Outcome team edit failed | Report; continue — Component and hierarchy still landed |
| Reparent failed (`OUTCOME_KEY` exists) | Report both keys and the manual `jira issue edit "$KEY" -P "$OUTCOME_KEY" </dev/null`; continue bootstrap |

## Report

Add to SKILL.md's success report when this file ran:

```text
Outcome:        https://redhat.atlassian.net/browse/<OUTCOME_KEY> (<new | existing>)
                | https://redhat.atlassian.net/browse/<OUTCOME_KEY> — created but
                  Feature unparented (<reason>)
                | not created (<reason>) — Feature is unparented

Follow-up Features to create once this one is underway:
  2. <next step>
  3. <next step>
```

`not created` is only for the case with no `OUTCOME_KEY` — reporting it after a
failed reparent invites a duplicate Outcome on the next run.

Name the deferred steps even when the Outcome failed — that list is the
scoping decision, and it is worth more than the parent link.
