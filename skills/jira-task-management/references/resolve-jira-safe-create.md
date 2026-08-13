# Resolving jira-safe-create.sh via the vendored osac-ai-skills checkout

`jira-safe-create.sh` lives in this skill's own repo (`osac-ai-skills`), not
the caller's working repo (`$REPO_DIR` below) — resolve it from whichever
vendored `osac-ai-skills` checkout is present, then source it (do not
execute — it only defines shell functions):

```bash
REPO_DIR=$(git rev-parse --show-toplevel)
_jsc=""
for _cand in "${HOME}/.osac-ai-skills" "${REPO_DIR}/.osac-ai-skills"; do
  [[ -f "${_cand}/tools/jira-safe-create.sh" ]] && { _jsc="${_cand}/tools/jira-safe-create.sh"; break; }
done
if [[ -z "$_jsc" ]]; then
  echo "jira-safe-create.sh not found in a vendored osac-ai-skills checkout. Run tools/bootstrap.sh, then retry." >&2
  exit 1
fi
source "$_jsc"
```

This defines `new_temp`, `add_temp`, `jira_login()`, and `jira_token()` in
the current shell. Sourcing is idempotent (guarded internally by
`JIRA_SAFE_CREATE_LOADED`), so re-sourcing later in the same skill run
(e.g. before a follow-up REST call in a separate step) is always safe.
