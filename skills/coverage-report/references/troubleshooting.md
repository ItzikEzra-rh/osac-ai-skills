# Troubleshooting a Coverage Report

Symptom → what the reporter means → what to do. Quote the diagnostic `code`,
`message`, and `recovery` from `diagnostics/diagnostics.json` when explaining a
result. All commands run from the `osac` repo root unless stated otherwise.

## Missing or unreadable inputs

| Symptom | Cause | Action |
|---|---|---|
| Unit is `unavailable` (`UNIT_EVIDENCE_UNAVAILABLE`) | No coverprofile was discovered and none was passed. | Say plainly that this is missing evidence, not zero. To measure: `cd fulfillment-service && ginkgo run -r --cover --coverprofile=/abs/path/cover.out internal`, then re-run with `ARGS="--coverprofile /abs/path/cover.out"`. Warn that it is slow. |
| Unit is `blocked`, `UNIT_PACKAGE_MISSING` | A package listed in `features.yaml` `unit_packages` is absent from the profile. | Run the full suite (`-r internal`) rather than a focused package, or correct the `unit_packages` entry (with approval). |
| `UNIT_METRIC_SCOPE_INCOMPLETE` | The feature maps no `unit_packages`; there is nothing to measure. | Propose packages in `features.yaml` (with approval). |
| Integration/E2E is `na`, `BEHAVIOR_INVENTORY_UNAVAILABLE` | No test plan was loaded for the feature. | Check the `testplan` path in `features.yaml` and the `enhancement_roots` in `.coverage-skill.yaml`. The file must exist under a configured root. |
| `BEHAVIOR_INVENTORY_DUPLICATE` | The test plan repeats a `TC-...` id. | Each test case id must be unique; fix the test plan, not the report. |
| `INPUT_MISSING` | A path passed via `--coverprofile` / `--junit` does not exist. | Use an absolute, existing path. |

## Stale evidence

| Symptom | Cause | Action |
|---|---|---|
| Unit is `stale` (`UNIT_EVIDENCE_STALE`) | The coverprofile sidecar records a different revision than the reported commit. | Regenerate at the reported commit, or report the commit the profile describes (`--sha`). Do not relabel evidence. |
| Unit is `blocked`, `UNIT_EVIDENCE_PARTIAL_STALE` | Some mapped packages are stale, others current. | Regenerate the whole profile; mixing revisions is refused by design. |
| `UNIT_REVISION_UNKNOWN` warning | The coverprofile has no revision metadata; freshness is `unknown`, which still allows a value. | Write `/abs/path/cover.out.meta.json` with `{"revision": "<commit sha>"}` so freshness becomes `current`. |
| JUnit results show `stale` / evidence is stale | The JUnit run recorded a different revision (from a `<file>.meta.json` sidecar or `<testsuite>` `revision`/`git_sha`/`commit` property). | Re-run the suite at the reported commit, or add/correct the sidecar revision. |
| `no revision in a sidecar or <properties>` diagnostic | JUnit XML carries no revision, so freshness is unknown. | Write `<junit>.meta.json` with `{"revision": "<commit sha>"}`. |

## Blocked or provisional behavior metrics

| Symptom | Cause | Action |
|---|---|---|
| `blocked`, `BEHAVIOR_TIER_UNASSIGNED`, cell shows `provisional X%` | Some test cases have no tier. | Assign a tier in the test plan's execution matrix, or propose `behavior_tiers:` in `config/mappings/<KEY>.yaml` (with approval). Explain the percentage as provisional, never as coverage. |
| `tier_reviewed: false` on behaviors | Tiers came from a `PENDING-REVIEW` mapping file. | Valid but unreviewed; a QE reviewer must set `reviewed_by` before it counts as reviewed. |
| Verdict `insufficient evidence` with no gaps | An unavailable, stale, or blocked metric, or an unassigned tier. | Fix the input named in the metrics table; the verdict is not a coverage failure. |
| Verdict `not ready` with no critical/high gaps | A measured `zero` metric. | Zero is real evidence of no coverage; treat it as a gap to close, not a missing report. |

## PENDING-REVIEW mappings

A mapping file whose `reviewed_by` is `PENDING-REVIEW` (or empty, `pending`,
`todo`, `tbd`, `unreviewed`, `none`) is treated as `inferred_mapping`. Its
entries do **not** count toward any metric, even though the tests may genuinely
cover the behavior.

- Explain the distinction: "suggested by an unreviewed config entry" ≠
  "reviewed coverage".
- Do not replace `reviewed_by` yourself. A QE reviewer does that after
  checking that the named test actually asserts the behavior.
- The report's summary counts `PENDING-REVIEW` entries and unreviewed tier
  overrides; quote those counts instead of estimating.

## Scope and configuration failures

| Exit / code | Cause | Action |
|---|---|---|
| 2 `SCOPE_UNRESOLVED` | No registry entry matches the input. | Show the `candidates:` line and the printed registry snippet; ask the user to choose, or propose a `features.yaml` entry. Never pick a feature from Jira prose. |
| 2 `SCOPE_AMBIGUOUS` | The input matches more than one entry (for example an alias shared by two features). | Show every candidate and ask which one was meant; propose disambiguating the alias or name. |
| 2 `USAGE_ERROR` | Bad flag or argument. | Show the usage message; fix the command. |
| 3 `CONFIG_INVALID` | Invalid `.coverage-skill.yaml`, `features.yaml`, or mapping file. | Show `error`, `field`, and `recovery`; propose the minimal fix with approval. Unknown keys are rejected, not ignored. |
| 1 `MODEL_INVARIANT`, `PUBLISH_FAILED`, `REPO_UNAVAILABLE`, `EVIDENCE_PROMOTION`, `INTERNAL_ERROR` | Tool defect or unusable repository state. | Report the verbatim error and `run_id`. Do not edit inputs or reports to force a pass; escalate. |

## Reading outputs

- The full-run label is `ALL`; `.artifacts/coverage-report/ALL/report.md`.
- `--previous` overrides the automatic comparison; without it the reporter
  compares against the previously published report for the same scope. The
  report says "No previous report was compared" when none exists or the rerun
  has identical inputs.
- `PREVIOUS_REPORT_INVALID` (exit 3) means the `--previous` file is unreadable
  or is not a report document; point `--previous` at a `report.json` from an
  earlier run.
- `run-manifest.json` records which config layer supplied each effective value
  (CLI flags > `.coverage-skill.yaml` > defaults). Use it when a value looks
  unexpected instead of guessing.
- Regenerating is always cheaper than hand-editing: any approved config change
  is followed by re-running Step 1 of the skill.
