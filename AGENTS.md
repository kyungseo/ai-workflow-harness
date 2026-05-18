# AGENTS.md

Codex entry point for this repository.
Keep this file thin. Shared operating rules live in `docs/AGENT-WORKFLOW.md`.

## Entry Contract

MUST:

- Treat this file and `CLAUDE.md` as equal tool-specific entry points.
- Read and follow `docs/AGENT-WORKFLOW.md` at session start for common workflow, context routing, status rules, and validation defaults.
- Read `docs/STATUS.md` current sections before choosing or continuing work.
- Treat `.claude/commands/*.md` as Claude Code command definitions, not as executable Codex commands.
- Do not read `.claude/commands/*.md` at session start; load a command file only when that workflow is explicitly invoked or clearly relevant.
- When a Claude command is relevant, follow the same procedure manually.
- Follow `docs/AGENT-WORKFLOW.md` Scope And Commit Approval before scope expansion and every commit.
- Follow the State Update Gate: Work checkpoint/discovery updates may be reported after execution, Work Done/archive and all `docs/STATUS.md` changes require the appropriate user confirmation.

NEVER:

- Duplicate shared rules here.
- Bypass `docs/STATUS.md` or the State Update Gate.

## Codex Command Mapping

| Claude workflow | Codex procedure |
| --- | --- |
| `/start` | Read `docs/STATUS.md` current sections and summarize current state, candidates, needed context, risks |
| `/pick` | Route to `docs/backlog/PHASE{n}.md` or `docs/backlog/HARNESS.md`, compare candidates, recommend one |
| `/register [description]` | Register a new work item; route to STATUS Active Work / Next Actions / PHASE{n}.md / HARNESS.md based on urgency and type; propose STATUS Update if needed |
| `/work <ID>` | Find the backlog item; check `docs/works/{category}/` for an existing Work file; if none and decomposition criteria met, include Work file creation in the plan; declare risk level, propose scope/files/verification/risk, then wait for approval |
| `/resume <ID>` | Compare `docs/STATUS.md` and Work file Checkpoints with actual files, report drift, and propose recovery before editing; if the Work is Done, do not resume it and propose archive or follow-up work |
| `/debug` | Analyze failures from code, logs, tests, or user-provided symptoms; identify root cause and propose the smallest safe fix before editing |
| `/doc [brief]` | Create high-quality presentation/report artifacts; confirm brief, route sources, choose output format/tool, verify quality |
| `/record-decision` | Draft a DR for an accepted technical/workflow decision; include status, context, decision, consequences, alternatives, and linked work items |
| `/done` | Report completed work, changed files, validation, residual risk, STATUS update need, decision need, state, commit status; if Active Work has a Work file, handle Done processing (`status: Done`, `actual_end`, README Active→Done, STATUS pointer removal proposal). Archive only after explicit approval or a later `/start`/`/resume` archive trigger |
| `/health [--full] [--cascade]` | Inspect workflow/document health. Use default for quick structure hygiene, `--full` for deeper structure/implementation sync, `--cascade` for canonical → tool-specific → user-facing → scaffold drift and loop-risk audit |

## Command Intent Recognition

When the user's intent matches a workflow operation without an explicit slash command, follow the corresponding procedure:

| Intent | Procedure |
| --- | --- |
| Register / add a work item | `/register` — determine urgency and type, route accordingly (see table below) |
| Record a decision as DR | `/record-decision` — DR format, file naming, OQ linkage |
| Start / plan a specific task | `/work` — pre-checks: PLAN.md force-load conditions, troubleshooting check, risk level declaration |
| Resume an interrupted task | `/resume` — drift check: compare actual file state vs `docs/STATUS.md` before editing |

## State Update Gate

| Layer | Change | Gate |
| --- | --- | --- |
| Layer 1 — Work file | Checkpoint status update, Discovery note | No prior approval required; report the target Work ID and change after execution |
| Layer 1 — Work file | Done Criteria all met, `status: Done`, `actual_end` | Confirm with the user and name the target Work ID |
| Layer 2 — `docs/STATUS.md` | Active Work pointer add/remove | One-line proposal naming the target Work ID, then wait for approval |
| Layer 2 — `docs/STATUS.md` | Phase criteria, Current phase/focus, Recent Decisions | Full STATUS Update Proposal |

Work item routing:

| Urgency / Type | Target |
| --- | --- |
| Start immediately (urgent patch) | `docs/STATUS.md` Active Work → chain to `/work` |
| Soon / next session | `docs/STATUS.md` Next Actions |
| Product / Phase{n} feature | `docs/backlog/PHASE{n}.md` |
| Harness / workflow / rule improvement | `docs/backlog/HARNESS.md` |

## Git Commit Format

Follow Conventional Commits with Bilingual Rules (per `docs/decisions/DR-007-language-policy.md`):

- **Type prefix** — always in English: `feat`, `fix`, `docs`, `chore`, `refactor`, `test`, `style`, `ci`
- **Subject line** — Korean primary; English for technical terms, proper nouns, file paths, IDs (e.g., `DR-007`, `STATUS.md`)
- **Body** — Korean primary with English technical terms inline; explain *why*, not *what*

## Failure And Recovery

On validation failure, status drift, scope drift, or insufficient context, move to FAIL and report:

- Failure type
- Root cause
- Affected files/state
- Recovery options
- Recommended path

Then wait for user direction before returning to PLAN.

When a non-trivial issue (environment mismatch, non-obvious root cause) is resolved during recovery, propose recording it in `docs/troubleshooting/` using the symptom → cause → action pattern.

Detailed flow: `docs/harness-protocol/06-recovery-and-validation.md`
