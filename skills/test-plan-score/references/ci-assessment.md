# CI assessment mode

When the trusted CI caller explicitly selects this mode, return an internal
assessment object with exactly `scores`, `criterionNotes`, `summary`, `feedback`,
`findings`, and `policy`. Keep the existing five score/note keys and the three
finding arrays. Do not emit `verdict` or `total`; the trusted gate computes them
and writes the existing public `verdict.json` contract. Standalone scoring uses the
[public output format](../SKILL.md#output).

`policy` has exactly:

- `integrationRequired`: boolean, based on the affected component maps and
  approved PRD/design boundary requirements.
- `groundingUsable`: boolean; usable proposed test work can be true before
  execution when its source and complete execution evidence are identified.
- `caps`: array, empty when no stated rubric cap applies. Each object contains
  `code`, `caseIds` (nonempty array of case or source-obligation references),
  `source` (the source section/map establishing the condition), and `detail`
  (specific observed missing evidence or mismatch).

Allowed cap codes are `boundary_mismatch` for a demonstrated required-tier or
real-versus-faked mismatch, `missing_required_case` for an absent required
boundary case, `unusable_grounding` for absent/unusable test-source grounding,
and `undisclosed_dependencies` when a required integration case leaves
real-versus-faked dependencies undisclosed. The latter is a Rework veto even
at a high total; score Grounding 0 when that case is also stub-only. Cite the
case and the source obligation, and identify the absent dependency disclosure.
Ambiguous but present disclosure is a Grounding 1 gap, not this veto.
If groundingUsable is false, supply the unusable_grounding cap with evidence.
Missing or ambiguous required-integration execution fields get Grounding 1;
integrationRequired then makes the trusted gate cap readiness at Revise.
Identify those fields in the Grounding note. A known wrong-tier/faked boundary
is the stronger boundary_mismatch veto.

Assess every condition; do not omit a cap to raise readiness. Optional formatting,
consistent local aliases, and valid uniform priority are not cap codes. Keep
planning evidence separate from execution results and name the actual cases and
source passages. Scores, notes and policy facts must agree. Internal assessments
are retained separately from the public verdict for diagnostics.
