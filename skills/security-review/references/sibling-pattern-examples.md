# Sibling-pattern expansion — worked examples

Read this **before finalizing** any finding whose root cause is regex /
pattern-match masking, an allow-list or `frozenset`, enum or
status-string branching, or "add one more case" guards. The obligation
itself is in [SKILL.md](../SKILL.md)
(`## After each finding — expand the pattern class`).

These sketches are calibration, not a substitute for reading the
changed code.

## 1. Regex siblings (two unbounded matchers)

**Trigger instance:** a path matcher like `/[\w./-]+` with no closer
except greed — attacker text glued onto a real path stays inside the
match and is blanked as "just a path."

**Siblings to check in the same pass:** other alternation branches or
helpers that do the same job for URLs (`https?://\S+`), remaining
`re.compile` / `.sub` calls on the same line, and any second pass that
re-runs a bare matcher over text a previous pass already "protected"
(e.g. markdown-link label).

**Bad suggestion:** "Add a word boundary to the path regex." That is
the next sibling's turn.

**Good suggestion:** one left-to-right combined match (or verified-span
diffing); drop the unsafe class and require positive provenance; fail
closed if a span cannot be proven safe. One finding (one `File:Line`)
per unguarded sibling; severity from that sibling's own impact.

## 2. Status / enum siblings (`copied` missing)

**Trigger instance:** an identity-creation guard that special-cases
GitHub `added` and `renamed` and falls through to "already reviewed"
for everything else — even if the first arm you notice looks only
`ADVISORY`.

**Siblings to check:** other values of the same status set (`copied`,
`changed`, `unchanged`, omitted, future API values); other
allow-lists/`frozenset`s of basenames in the same helper; other
`if-elif` arms of the same chain.

**Bad suggestion:** "Add `copied` to the list." That is the next
status's turn.

**Good suggestion:** invert to a fail-closed invariant — only in-place
`modified` or same-basename `renamed` is identity-preserving; every
other status forces substantive / not logistics-safe.

## 3. One-off negative control

A single hardcoded credential (or one missing authz call with no
shared helper) is **not** a pattern class. Report that instance.
Do **not** demand a structural invariant, invent regex-alternation
findings, or sermonize about GitHub statuses. Removal / rotation (or
adding the missing check) is the fix.
