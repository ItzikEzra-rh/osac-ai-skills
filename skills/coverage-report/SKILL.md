---
name: coverage-report
description: >
  Explain an OSAC feature coverage report produced by the deterministic
  reporter at tools/coverage-report/ in the osac mono-repo. Use when the user
  asks for coverage of a Jira key or capability ("coverage for OSAC-2540",
  "test coverage of disk-image") or for a full quality plan across every
  registered feature. Runs make coverage-report from the osac repo root, reads
  the generated report.md and report.json, and explains the readiness verdict,
  per-tier metrics, evidence classes, and gaps. Never computes or adjusts a
  percentage itself.
metadata:
  version: "0.1.0"
---

# OSAC Coverage Report

Thin wrapper around the deterministic coverage reporter in the `osac`
mono-repo at `tools/coverage-report/`. The reporter owns every number: it
collects evidence, computes metrics, assigns evidence classes, and renders the
report. This skill runs it, reads its output, and explains it.

**Announce at start:** "Using the coverage-report skill to generate and explain
the coverage report."

## Hard Rules

The reporter is the only source of truth. This skill:

- **Never calculates, estimates, rounds, averages, or adjusts a percentage.**
  Quote numbers only from `report.md` or `report.json`.
- **Never upgrades an evidence class** or repeats an `inferred_mapping`
  suggestion as if it were reviewed or measured.
- **Never edits, regenerates by hand, or "corrects"** a generated report.
- **Never marks a mapping reviewed.** A `reviewed_by` reviewer handle is a
  QE reviewer's claim, not an agent's.
- **Never posts to Jira, opens a PR, or changes production code or tests.**
  Editing `tools/coverage-report/config/mappings/<KEY>.yaml`,
  `tools/coverage-report/config/features.yaml`, or `.coverage-skill.yaml` is
  proposed to the user and applied only with explicit approval.

If the user asks for a number the reporter did not produce, say it is not
available and point at the input that would produce it. Do not infer it from
Jira text, test names, or the test plan.

## Step 1: Resolve Intent

Run every command below from the **`osac` repo root** — the directory that
contains `tools/coverage-report/` and `.coverage-skill.yaml`.

| User asks | Command |
|---|---|
| Coverage for a Jira key or feature name | `make coverage-report FEATURE=<KEY\|name\|alias>` |
| Coverage of everything registered | `make coverage-report` |

`FEATURE` accepts an exact Jira key (`OSAC-2540`), a registry name
(`disk-image`), or an alias. Resolution succeeds only on exactly one registry
entry — see Step 2 for the failure paths.

Optional inputs go through `ARGS`:

```bash
make coverage-report FEATURE=OSAC-2540 \
  ARGS="--coverprofile /abs/path/cover.out --junit /abs/path/junit.xml --previous .artifacts/coverage-report/OSAC-2540/report.json"
```

- `--coverprofile PATH` — repeatable; measured unit evidence.
- `--junit PATH` — repeatable; observed execution evidence.
- `--previous PATH` — an explicit earlier `report.json` to diff against. When
  omitted, the reporter automatically compares against the previously published
  report for the same scope, if one exists.
- `--sha`, `--now`, `--out`, `--config`, `--repo` — provenance and path
  overrides; use only when the user asks for a pinned commit, timestamp, or
  non-default location.

### Measured unit coverage (optional)

Without a coverprofile the unit metric is `unavailable` — missing evidence,
**not** zero coverage. If the user wants a measured number, produce one from
`fulfillment-service`:

```bash
cd fulfillment-service
ginkgo run -r --cover --output-dir=/abs/path --coverprofile=cover.out internal
```

Warn that this runs the whole unit suite and is slow. Ginkgo's `--coverprofile`
takes a filename, not a path; `--output-dir` decides where it lands. Then pass
the resulting absolute path to the reporter via `ARGS` (`/abs/path/cover.out`).
A coverprofile carries no revision: write a sidecar
`/abs/path/cover.out.meta.json` containing `{"revision": "<commit sha>"}` only
when you know the commit the profile was produced at — normally the commit you
just ran the suite at. Never label an older profile with the current commit.
Regenerate instead of reusing a profile from another commit — a different
revision is classified `stale` and blocks the metric.

## Step 2: Run and Branch on the Exit Code

| Exit | Meaning | What to do |
|---|---|---|
| 0 | Report written | Continue to Step 3 |
| 2 | `SCOPE_UNRESOLVED`, `SCOPE_AMBIGUOUS`, or `USAGE_ERROR` | Show the printed error; for the scope codes show the `candidates:` list verbatim and ask the user to pick one — **never guess from Jira prose**. Offer to add a `features.yaml` entry (Step 4). |
| 3 | `CONFIG_INVALID` or `PREVIOUS_REPORT_INVALID` | Show the printed `error`, `field`, and `recovery` lines. Propose the config fix, or point `--previous` at an earlier `report.json`; do not edit config unasked. |
| 1 | Tool defect (`MODEL_INVARIANT`, `PUBLISH_FAILED`, `REPO_UNAVAILABLE`, `EVIDENCE_PROMOTION`, `INTERNAL_ERROR`) | Report the verbatim error plus `run_id`. Do not work around it by editing inputs, reports, or evidence. |

Also quote the printed `run_id:` on any failure — it is the audit handle for
the run.

## Step 3: Read and Explain the Report

The reporter writes, by default, under `.artifacts/coverage-report/<label>/`,
where `<label>` is the resolved Jira key (`OSAC-2540`) or `ALL` for a full run:

- `report.md` — human-readable report.
- `report.json` — authoritative structured report; every number in
  `report.md` comes from it.
- `run-manifest.json` — effective config, its precedence layer, inputs, and
  resolver provenance.
- `diagnostics/diagnostics.json` — warnings and errors behind the states.
- `inputs/` — copies and digests of the evidence files actually consumed.

Read both files, then explain in this order:

1. **Header** — the reported commit, its source (`--sha`, git HEAD), and
   `generated_at`; a report about a different commit is not evidence for the
   current tree.
2. **Readiness verdict** per feature — `ready`, `not ready`, or
   `insufficient evidence`, with the driver it names; do not restate it as your
   own judgment.
3. **Coverage table** — `Feature | Unit | Integration | E2E`, each cell exactly
   as rendered (value with numerator/denominator and metric version, provisional
   percentage, or state word).
4. **Metric states and evidence classes** — quote state words; never collapse
   `unavailable`, `na`, and `zero` into "0%". Keep `measured`,
   `observed_execution`, `declared_mapping`, `inferred_mapping`, and
   `gap_unknown` distinct; inferred suggestions never count. See
   [references/evidence-and-metric-states.md](references/evidence-and-metric-states.md).
5. **Detail per feature/tier** — formula, numerator/denominator, denominator
   breakdown, and the behavior table (status, execution, real/simulated
   boundary).
6. **Gaps, top actions, changes, diagnostics** — relay gaps as the reporter's
   recommendations; report the delta the reporter found, or state that none
   was possible (no earlier report, or a rerun over identical inputs); surface
   diagnostic codes with their recovery hints.

Do not rewrite the report or recompute totals; point at the generated files.

## Step 4: Propose Config Changes (Approval Required)

When a gap is a configuration gap, propose a concrete diff and stop:

- **Missing or wrong test-to-behavior mapping** →
  `tools/coverage-report/config/mappings/<KEY>.yaml` under `mappings:`.
- **Unassigned behavior tier** → the `behavior_tiers:` section of the same
  file (a reviewer may override a test-plan tier without editing the design),
  or the test plan's execution matrix.
- **Feature not registered, wrong name/alias, wrong testplan path, wrong
  components, suites, or `unit_packages`** →
  `tools/coverage-report/config/features.yaml`.

Rules for proposals:

- Show the exact YAML lines and the reason each entry is justified (test file,
  spec name, coverage note).
- Keep or set `reviewed_by: PENDING-REVIEW`. The reporter treats such entries
  as `inferred_mapping`, so they cannot inflate a metric. Only a QE reviewer
  replaces that marker, after verifying the named test asserts the behavior.
- `behavior_tiers` in a `PENDING-REVIEW` file still apply but are flagged
  `tier_reviewed: false`; say so.
- Apply the edit only after the user approves, then tell them to re-run Step 1
  so the report is regenerated by the reporter.

## References

- [references/evidence-and-metric-states.md](references/evidence-and-metric-states.md)
  — evidence classes, metric states, behavior statuses, and readiness verdicts.
- [references/troubleshooting.md](references/troubleshooting.md) — symptom →
  cause → action for missing, stale, blocked, and PENDING-REVIEW results.
- [evals/evals.json](evals/evals.json) — trigger and behavior cases for this
  skill.

The reporter's own `tools/coverage-report/README.md` in the `osac` repo is the
detailed reference for configuration keys, collectors, schemas, and metric
versions. Read it when the user asks how the reporter works rather than what a
report says.

## Red Flags

**Never:**

- Compute, average, round, or "sanity check" a percentage yourself
- Treat `unavailable` or `na` as zero, or `zero` as missing evidence
- Present an `inferred_mapping` or `PENDING-REVIEW` entry as reviewed coverage
- Guess a feature from Jira prose when scope resolution failed
- Edit a generated report, or a mapping file, without user approval
- Promote `reviewed_by` away from `PENDING-REVIEW`
- Post to Jira, open a PR, or modify production code or tests

**Always:**

- Run from the `osac` repo root and quote the reported commit
- Show scope candidates verbatim on exit 2
- Keep the reporter's state words and evidence classes in your explanation
- Send the user back to the reporter after any approved config change
