# Evidence Classes and Metric States

Definitions as the reporter implements them. Quote these meanings; the
reporter, not this skill, decides which one applies to a report.

## Evidence classes (strongest first)

| Class | Meaning | Can it raise a metric? |
|---|---|---|
| `measured` | A collector measured the artifact directly — a Go coverprofile for unit coverage. | Yes, unit numerator. |
| `observed_execution` | A test actually ran; JUnit records the outcome. | Yes, execution status. |
| `declared_mapping` | A human-reviewed mapping says this test covers the behavior (`reviewed_by` names a GitHub user or team). | Yes, behavior numerator. |
| `inferred_mapping` | A heuristic or an unreviewed config entry suggests coverage. Includes `PENDING-REVIEW` mappings, TC references, coverage notes, and keyword overlap. | **No — never counts.** |
| `gap_unknown` | A mapping names evidence that cannot be found (missing test file or spec). | No. |

Only one transition is ever allowed: `inferred_mapping` → `declared_mapping`,
and only when a reviewer sets `reviewed_by`. Nothing is promoted automatically.

## Metric states

| State | Meaning | Unit | Integration / E2E |
|---|---|---|---|
| `value` | A percentage with numerator and denominator. | A measurable profile. | A complete denominator. |
| `zero` | A **measured** zero. Real evidence of no coverage; reported as `not ready`, not as missing evidence. | Measured packages cover nothing. | No behavior covered against a complete denominator. |
| `na` | The metric does not apply because its source is absent: no behavior inventory (`BEHAVIOR_INVENTORY_UNAVAILABLE`) or no denominator (`BEHAVIOR_METRIC_NO_DENOMINATOR`). | — | Yes. |
| `unavailable` | No collector produced evidence at all (`UNIT_EVIDENCE_UNAVAILABLE`). **Not zero.** | Yes. | — |
| `stale` | Evidence is from another revision (`UNIT_EVIDENCE_STALE`); not usable evidence. | Yes. | Rare. |
| `blocked` | A percentage would be misleading or the denominator is incomplete. | Missing mapped package (`UNIT_PACKAGE_MISSING`) or partial stale evidence (`UNIT_EVIDENCE_PARTIAL_STALE`). | Duplicate TC ids (`BEHAVIOR_INVENTORY_DUPLICATE`) or unassigned tiers (`BEHAVIOR_TIER_UNASSIGNED`). |

`unavailable` and `blocked` still carry the arithmetic over the evidence that
*was* present, so the shortfall is auditable — but never a `value_percent`.

### Provisional percentages

A behavior-tier metric with tier-unassigned behaviors reports `blocked` plus a
**provisional** percentage computed only over the behaviors that have a tier.
It is printed as `blocked (provisional X% n/d, N tier-unassigned)`, where `N`
is the number of behaviors still without a tier — not the number the
percentage was computed over. It is not a real value: never quote it as
coverage. Say instead that the percentage is provisional over the tiered
behaviors and blocked until the `N` tier-unassigned behaviors get a tier.

## Behavior statuses (Detail section)

| Status | Meaning |
|---|---|
| `covered` | At least one reviewed mapping at the required tier whose boundary satisfies the behavior. |
| `gap` | Assessable, but not covered; the reason is shown in parentheses. |
| `excluded` | The behavior's required tier is a different tier. |
| `unassessable` | The evidence cannot decide coverage (for example missing test structure). |
| `tier-unassigned` | No tier declared in the test plan or `behavior_tiers`; excluded from both denominators and blocks the metric. |

Gap reasons, strongest first: `no-mapping`, `inferred-only`, `wrong-tier`,
`boundary-simulated`, `test-missing`, `planned-not-implemented`,
`not-executed`, `tier-unassigned`.

`planned-not-implemented` means the approved test plan names a test path that
is marked "proposed" or does not exist in the repository. Relay it as planned
work that was never implemented, not as a mapping problem.

## Execution status

| Status | Meaning |
|---|---|
| `executed-pass-current` | JUnit recorded a pass at the reported revision. |
| `executed-fail` | JUnit recorded a failure. |
| `stale` | JUnit recorded a result at a different revision. |
| `not-executed` | A mapping exists but no run was recorded. |
| `unknown` | No execution evidence either way. |

The default policy (`require_execution: false`) counts a declared mapping even
without a passing run and still reports execution status per behavior. When
`require_execution: true`, a current passing run is required in the numerator.

## Boundary

Each behavior and evidence record lists `real` and `simulated` components. A
behavior whose required boundary includes a real component is not satisfied by
a suite that simulates it; that becomes a `boundary-simulated` gap. `simulated`
and `real` are never merged when explaining coverage.

## Freshness

`current`, `stale`, `unknown`. A revision equal to the reported commit (or an
unambiguous prefix of at least 7 hex characters) is current; a different
revision is stale; a missing revision is unknown — freshness is never assumed.

## Readiness verdicts

| Verdict | Condition |
|---|---|
| `ready` | No critical or high gaps, no measured zero metric, and no unavailable, stale, or blocked metric. |
| `not ready` | Any critical/high gap, or any measured zero metric. |
| `insufficient evidence` | Any unavailable, stale, or blocked metric, or any tier-unassigned behavior. |

`insufficient evidence` is not a failing grade — it means the inputs cannot
support a readiness claim yet. Fix the missing input rather than reporting a
number.

## Metric versions

- Unit: `statement-weighted-v2` by default (`sum(covered)/sum(total)` over
  measured packages). The unit cell may also show `legacy-package-average-v1`
  as a comparison — the unweighted mean of per-package percentages. Say which
  version a quoted number came from.
- Integration and E2E: `behavior-inventory-v1` (`covered behaviors / assessable
  behaviors whose required tier matches`).
