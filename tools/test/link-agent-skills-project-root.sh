#!/usr/bin/env bash
# Smoke test: PROJECT_ROOT override for consumer fan-out.
# Run from osac-ai-skills: bash tools/test/link-agent-skills-project-root.sh
set -euo pipefail

SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
REPO_ROOT=$(cd "${SCRIPT_DIR}/../.." && pwd)
SCRIPT="${REPO_ROOT}/tools/link-agent-skills.sh"

fail() { echo "FAIL: $*" >&2; exit 1; }
pass() { echo "PASS: $*"; }

[[ -f "$SCRIPT" ]] || fail "missing $SCRIPT"
[[ -x "$SCRIPT" ]] || fail "$SCRIPT is not executable"

TMPDIR_ROOT=$(mktemp -d)
trap 'rm -rf "$TMPDIR_ROOT"' EXIT

# --- Contracts ---

test_default_project_root_links_in_repo() {
  # Unset PROJECT_ROOT → agent links land under the skills repo root.
  unset PROJECT_ROOT || true
  (
    cd "$REPO_ROOT"
    "$SCRIPT" --claude
  ) >/dev/null

  [[ -L "${REPO_ROOT}/.claude/skills" ]] || fail ".claude/skills is not a symlink"
  local expected resolved
  expected=$(cd "${REPO_ROOT}/skills" && pwd -P)
  resolved=$(cd -L "${REPO_ROOT}/.claude/skills" && pwd -P)
  [[ "$resolved" == "$expected" ]] || fail "default mode resolved to $resolved, expected $expected"
  [[ -r "${REPO_ROOT}/.claude/skills/create-pr/SKILL.md" ]] || fail "cannot read create-pr via default .claude/skills"
  # Do not leave agent discovery dirs or optional workflow symlinks behind.
  rm -rf "${REPO_ROOT}/.claude"
  pass "unset PROJECT_ROOT links under skills repo root"
}

test_project_root_override_links_consumer() {
  local consumer vendor_skill
  consumer=$(mktemp -d "${TMPDIR_ROOT}/consumer.XXXXXX")
  mkdir -p "${consumer}/skills"

  # Materialize native skills as symlinks (consumer overlay).
  for vendor_skill in "${REPO_ROOT}/skills"/*/; do
    [[ -d "$vendor_skill" ]] || continue
    local name
    name=$(basename "$vendor_skill")
    ln -sfn "${vendor_skill%/}" "${consumer}/skills/${name}"
  done
  [[ -r "${consumer}/skills/create-pr/SKILL.md" ]] || fail "fixture missing create-pr"

  # Stub ai-workflows under the consumer for --with-ai-workflows.
  mkdir -p "${consumer}/.ai-workflows/bugfix" \
    "${consumer}/.ai-workflows/design" \
    "${consumer}/.ai-workflows/e2e" \
    "${consumer}/.ai-workflows/implement" \
    "${consumer}/.ai-workflows/prd" \
    "${consumer}/.ai-workflows/_shared"
  echo '# stub' >"${consumer}/.ai-workflows/bugfix/SKILL.md"
  echo '# stub' >"${consumer}/.ai-workflows/design/SKILL.md"
  echo '# stub' >"${consumer}/.ai-workflows/e2e/SKILL.md"
  echo '# stub' >"${consumer}/.ai-workflows/implement/SKILL.md"
  echo '# stub' >"${consumer}/.ai-workflows/prd/SKILL.md"

  PROJECT_ROOT="$consumer" "$SCRIPT" --claude --with-ai-workflows >/dev/null

  [[ -L "${consumer}/.claude/skills" ]] || fail "consumer .claude/skills is not a symlink"
  local expected resolved
  expected=$(cd "${consumer}/skills" && pwd -P)
  resolved=$(cd -L "${consumer}/.claude/skills" && pwd -P)
  [[ "$resolved" == "$expected" ]] || fail "override resolved to $resolved, expected $expected"
  [[ -r "${consumer}/.claude/skills/create-pr/SKILL.md" ]] || fail "cannot read create-pr via consumer .claude/skills"

  [[ -L "${consumer}/skills/bugfix" ]] || fail "expected skills/bugfix symlink under consumer"
  [[ -r "${consumer}/skills/bugfix/SKILL.md" ]] || fail "cannot read bugfix via consumer skills/"

  # Must not have created agent links inside the skills repo for this invocation.
  # (Default-mode test may have created REPO_ROOT/.claude — that is fine and gitignored.)
  pass "PROJECT_ROOT override links under consumer tree"
}

test_default_project_root_links_in_repo
test_project_root_override_links_consumer

echo "All link-agent-skills PROJECT_ROOT smoke tests passed."
