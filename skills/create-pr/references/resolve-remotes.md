# Resolving remotes via the vendored osac-ai-skills checkout

`resolve-remotes.sh` lives in this skill's own repo (`osac-ai-skills`), not
`$REPO_DIR` (the component repo you're creating a PR in) — resolve it from
whichever vendored `osac-ai-skills` checkout is present:

```bash
OSAC_AI_SKILLS_DIR=""
for _cand in "${HOME}/.osac-ai-skills" "${REPO_DIR}/.osac-ai-skills"; do
  if [[ -x "${_cand}/tools/resolve-remotes.sh" ]]; then
    OSAC_AI_SKILLS_DIR="${_cand}"; break
  fi
done
if [[ -z "$OSAC_AI_SKILLS_DIR" ]]; then
  echo "resolve-remotes.sh not found in a vendored osac-ai-skills checkout (~/.osac-ai-skills or ${REPO_DIR}/.osac-ai-skills). Run tools/bootstrap.sh, then retry." >&2
  exit 1
fi
_resolve_out=$("${OSAC_AI_SKILLS_DIR}/tools/resolve-remotes.sh" "$REPO_DIR") || {
  echo "Failed to resolve remotes. Run ${OSAC_AI_SKILLS_DIR}/tools/resolve-remotes.sh --print to diagnose."
  exit 1
}
eval "$_resolve_out"
```

This sets `$UPSTREAM_REMOTE` (the osac-project remote) and `$PUSH_REMOTE`
(developer's push target). Run `"${OSAC_AI_SKILLS_DIR}/tools/resolve-remotes.sh" --print`
to see current detection.
