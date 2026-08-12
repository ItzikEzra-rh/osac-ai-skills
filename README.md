# osac-ai-skills

Dedicated repository for OSAC AI skills and the tooling that only exists to
support or validate them:

- Native Agent Skills under `skills/`
- Skillsaw lint config and CI (`.skillsaw.yaml`, `.github/workflows/`)
- Generic agent skill fan-out (`tools/link-agent-skills.sh`)
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

## Background

See ADR 0001 in `osac-project/osac-workspace`:
`decisions/0001-dedicated-ai-skills-repo.md`.
