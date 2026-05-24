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
- Treat `.claude/commands/*.md` as Claude Code command definitions, not as executable Codex commands.
- Do not read `.claude/commands/*.md` at session start; load a command file only when that workflow is explicitly invoked or clearly relevant.
- When a Claude command is relevant, follow the same procedure manually.
- Treat `.claude/rules/*.md` as project-local rule references. Do not load them at session start; when editing files whose paths match a rule's `paths` frontmatter, read only the matching rule files and apply their guidance manually.
- Follow `docs/AGENT-WORKFLOW.md` Approval Matrix before execution, scope expansion, state changes, and every commit.

NEVER:

- Duplicate shared rules here.
- Bypass `docs/STATUS.md` or the Approval Matrix.

## Codex Command Mapping

Full procedures live in `.agents/skills/workflow-{name}/SKILL.md`.
Load the relevant skill when a command is invoked or its intent is matched.

| Command | Intent |
| --- | --- |
| `/start` | Summarize current STATUS, Done-not-archived Work, and next candidates |
| `/pick` | Route to the appropriate backlog and recommend the next work item |
| `/register [description]` | Register a new work item in the correct backlog or STATUS location |
| `/work <ID>` | Plan a specific backlog item — pre-checks, Work file, risk, scope |
| `/resume <ID>` | Reopen an Active Work item — drift check before editing |
| `/debug` | Identify root cause from code/logs and propose the smallest fix |
| `/doc [brief]` | Produce a presentation, report, or review artifact |
| `/record-decision` | Draft and file a DR for an accepted technical/workflow decision |
| `/close` | Work Done processing only — Done Criteria, status, README, STATUS pointer |
| `/done` | Session summary — validation, risk, STATUS/Tracking Finalization, commit status |
| `/health [--full] [--cascade]` | Workflow and document health inspection |

## Command Intent Recognition

When the user's intent matches a workflow operation without an explicit slash command, follow the corresponding procedure:

| Intent | Procedure |
| --- | --- |
| Register / add a work item | `/register` — determine urgency and type, route accordingly (see table below) |
| Record a decision as DR | `/record-decision` — DR format, file naming, OQ linkage |
| Start / plan a specific task | `/work` — pre-checks: PLAN.md force-load conditions, troubleshooting check, risk level declaration |
| Resume an interrupted task | `/resume` — drift check: compare actual file state vs `docs/STATUS.md` before editing |

## Approval Matrix State Rules

| Target | Change | Gate |
| --- | --- | --- |
| Work file | Checkpoint status update, Discovery note | No prior approval required; report the target Work ID and change after execution |
| Work file | Done Criteria all met, `status: Done`, `actual_end` | Confirm with the user and name the target Work ID |
| `docs/STATUS.md` | Active Work pointer add/remove | One-line proposal naming the target Work ID, then wait for approval |
| `docs/STATUS.md` | Phase criteria, Current phase/focus, Recent Decisions | Full STATUS Update Proposal |

When `docs/STATUS.md` changes are needed, approve and apply them **before** committing. Include them in the same commit as the substantive changes — never as a separate follow-up commit.

Work item routing:

| Urgency / Type | Target |
| --- | --- |
| Start immediately (urgent patch) | `docs/STATUS.md` Active Work → chain to `/work` |
| Soon / next session | `docs/STATUS.md` Next Actions |
| Scaffold bootstrap / identity setup | When `docs/STATUS.md` Next Actions explicitly point to bootstrap/onboarding, use `docs/BOOTSTRAP.md`; verify `docs/PLAN-SUMMARY.md` Implementation Baseline before proposing feature candidates |
| Product track / Phase{n} feature | `docs/backlog/PHASE{n}.md` |
| Harness / workflow / rule improvement | `docs/backlog/HARNESS.md` |

## Git Commit Format

Follow Conventional Commits with Bilingual Rules (per `docs/decisions/DR-007-language-policy.md`):

- **Type prefix** — always in English: `feat`, `fix`, `docs`, `chore`, `refactor`, `test`, `style`, `ci`, `config`, `perf`, `build`, `revert`
- **Subject line** — Korean primary; English for technical terms, proper nouns, file paths, IDs (e.g., `DR-007`, `STATUS.md`)
- **Body** — Korean primary with English technical terms inline; explain *why*, not *what*

## Document Language Policy

When creating or editing any document, prompt, command, rule, or hook message:

- **English Only:** `CLAUDE.md`, `AGENTS.md`, `.claude/rules/*.md`, `.cursor/rules/*.mdc`
- **Korean primary + Bilingual Rules:** `docs/*.md`, `prompts/*.md`, `.claude/commands/*.md`

Bilingual Rules (applies to Korean-primary files):
- Section titles: English Title Case — never translate (e.g., `## Active Work`, `## Next Steps`)
- Technical terms: English verbatim — no transliteration (e.g., Kubernetes, CI/CD, Refactoring)
- Body text: Korean primary

Full policy: `docs/decisions/DR-007-language-policy.md`

## Branch Flow

When the user expresses branch merge intent (e.g., asking to merge, open a PR, or merge into develop),
load `docs/GIT-WORKFLOW.md` and follow §2 (Feature Development Cycle) and §3 (Release Cycle).

NEVER:
- Directly local-merge a feature branch into develop. Always merge via PR.
- Skip the develop sync step after a main PR merge (`git merge main && git push origin develop`).

## Failure And Recovery

On validation failure, status drift, scope drift, or insufficient context, move to FAIL and report:

- Failure type
- Root cause
- Affected files/state
- Recovery options
- Recommended path

Then wait for user direction before returning to PLAN.

When a non-trivial issue (environment mismatch, non-obvious root cause) is resolved during recovery, propose recording it in `docs/troubleshooting/` using the symptom → cause → action pattern.

Detailed flow: `docs/HARNESS-PROTOCOL.md`
