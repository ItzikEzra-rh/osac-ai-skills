# osac-ai-skills

Dedicated repository for OSAC AI skills and the tooling that only exists to
support or validate them:

- Native Agent Skills under `skills/`
- Skillsaw lint config and CI (`.skillsaw.yaml`, `.github/workflows/`)
- Generic agent skill fan-out (`tools/link-agent-skills.sh`)
- Shared helper scripts consumed by specific skills (`tools/resolve-remotes.sh`,
  `tools/jira-safe-create.sh`)
- Skill-quality eval harness (`evals/`)

This is the skills content store. Bootstrap/orchestration (what to clone and
when) lives in consumer repos — primarily `osac/tools/bootstrap.sh`, and
until cutover also `osac-workspace/bootstrap.sh`. `flightctl/ai-workflows`
remains a separate vendored dependency of those consumers; it is not hosted
here.

## Consumer fan-out

From a standalone clone of this repo:

```bash
tools/link-agent-skills.sh --all
# optional: also wire flightctl/ai-workflows under skills/
tools/link-agent-skills.sh --all --with-ai-workflows
```

From a consumer workspace that vendors this repo (e.g. as `.osac-ai-skills/`),
set `PROJECT_ROOT` to the consumer root so agent symlinks land there. Native
skills must already be present under `$PROJECT_ROOT/skills/` (typically as
symlinks into the vendored `skills/` tree):

```bash
PROJECT_ROOT=/path/to/consumer \
  /path/to/.osac-ai-skills/tools/link-agent-skills.sh --all --with-ai-workflows
```

## Shared helper scripts

Some skills need small bash helpers beyond what's inlined in their `SKILL.md`.
Rather than each skill (or each consumer repo) carrying its own copy, these
live once in `tools/` here and are resolved by skill instructions from
whichever vendored checkout of this repo the consumer has — `~/.osac-ai-skills`
or the consumer repo's own `.osac-ai-skills/` — the same 2-candidate order
`link-agent-skills.sh`'s `resolve_osac_ai_skills_dir()` uses. There is no
per-consumer copy to keep in sync.

- **`tools/resolve-remotes.sh`** — detects which git remote points at the
  `osac-project` org (upstream) vs. the developer's fork (push target).
  Consumed by `create-pr` and `osac-release`.
- **`tools/jira-safe-create.sh`** — temp-file/cleanup and Jira-credential
  helpers (`new_temp`/`add_temp`, `jira_login`/`jira_token`) for the safe
  `jira issue create` pattern. Consumed by `jira-task-management`,
  `report-bug`, `capture-tasks-from-meeting-notes`, and `osac-feature`.

Smoke tests for both live in `tools/test/` and are run manually (no CI wiring
yet — see `tools/test/*.sh` headers for invocation).

## Background

See ADR 0001 in `osac-project/osac-workspace`:
`decisions/0001-dedicated-ai-skills-repo.md`.
