# AGENTS.md

Codex entry point for this repository.
Keep this file thin. Global behavior principles live in `docs/BEHAVIOR-PRINCIPLES.md`. Shared operating rules live in `docs/AGENT-WORKFLOW.md`.

## Entry Contract

MUST:

- Treat this file and `CLAUDE.md` as equal tool-specific entry points.
- Read and follow `docs/BEHAVIOR-PRINCIPLES.md` at session start for global behavioral principles that apply to all tasks.
- Read and follow `docs/AGENT-WORKFLOW.md` at session start for common workflow, context routing, status rules, and validation defaults.
- Read `docs/STATUS.md` current sections before choosing or continuing work.
- Do not check `docs/BOOTSTRAP.md` just because it exists; use it only when `docs/STATUS.md` Next Actions explicitly points to scaffold bootstrap/onboarding work.
- Treat `.claude/commands/*.md` as Claude Code command definitions, not as executable Codex commands. Do not read them at session start or follow them directly; run workflows through the Codex skill adapters per Codex Skill Routing below.
- Treat `.claude/rules/*.md` as project-local rule references. Do not load them at session start; when editing files whose paths match a rule's `paths` frontmatter, read only the matching rule files and apply their guidance manually.
- Follow `docs/AGENT-WORKFLOW.md` Approval Matrix before execution, scope expansion, state changes, and every commit.
- On failure: follow `docs/HARNESS-PROTOCOL.md` Failure And Recovery.

NEVER:

- Duplicate shared rules here.
- Bypass `docs/STATUS.md` or the Approval Matrix.

## Codex Skill Routing

When a workflow command is invoked or its intent is matched,
load `.agents/skills/workflow-{name}/SKILL.md` and follow the procedure.
Skill name maps directly to command name (e.g., `/session-start` → `workflow-session-start`).
Each skill adapter must load the matching canonical procedure in `skills/workflow/{name}.md` as Step 0.

Available workflow skills are the directories under `.agents/skills/`.

If the matched skill intent is uncertain or multiple skills are equally plausible, confirm the interpreted intent in one line before loading a skill. Do not silently pick one and execute.

## Document Language Policy

When creating or editing any document, prompt, command, rule, or hook message — confirm DR-007 applies.

- **English Only:** `AGENTS.md`, `CLAUDE.md`, `.claude/rules/*.md`, `.cursor/rules/*.mdc`
- **Korean primary + Bilingual Rules:** `docs/*.md`, `prompts/*.md`, `skills/workflow/*.md`, `.claude/commands/*.md`, `.agents/skills/*/SKILL.md`

Full policy: `docs/decisions/DR-007-language-policy.md`

## Branch Flow

When the user expresses branch merge intent (e.g., asking to merge, open a PR, or merge into develop),
If this repository has `docs/GIT-WORKFLOW.md`, load it and follow §2 (Feature Development Cycle) and §3 (Release Cycle). Otherwise, check the project-specific branch/release policy first.
If this repository has `docs/GIT-WORKFLOW.md`, follow §5 for commit format.

NEVER open a PR from a feature branch without `--base develop`. Default GitHub base (main) is wrong for this repo.

Before opening a feature PR, sync the latest `develop` into the feature branch (`git fetch origin && git merge origin/develop`) per `docs/GIT-WORKFLOW.md` §2-3, resolving conflicts locally. Default to `merge` (squash policy makes rebase's linear history moot); `--force-with-lease` only on your own feature branch, never on `develop`/`main`.

After `gh pr merge` completes, follow the merge type:
- feature→develop: use `--squash` (default per harness merge policy); use `--merge` only when commit-level history must be preserved. Then execute §2-5 (sync develop, delete local feature branch, suggest next feature branch).
- develop→main: use `--merge` (regular merge is the default per harness merge policy). Then execute §3-4 (Post-Merge Develop Sync: sync main, merge origin/main into develop, push develop).
