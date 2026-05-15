# AGENTS.md

Codex entry point for this repository.
Keep this file thin. Shared operating rules live in `docs/AGENT-WORKFLOW.md`.

## Entry Contract

MUST:

- Treat this file and `CLAUDE.md` as equal tool-specific entry points.
- Read and follow `docs/AGENT-WORKFLOW.md` at session start for common workflow, context routing, status rules, and validation defaults.
- Read `docs/STATUS.md` current sections before choosing or continuing work.
- Treat `.claude/commands/*.md` as Claude Code command definitions, not as executable Codex commands.
- When a Claude command is relevant, follow the same procedure manually.

NEVER:

- Duplicate shared rules here.
- Bypass `docs/STATUS.md` or the STATUS Update Proposal gate.

## Codex Command Mapping

| Claude workflow | Codex procedure |
| --- | --- |
| `/start` | Read `docs/STATUS.md` current sections and summarize current state, candidates, needed context, risks |
| `/pick` | Route to `docs/backlog/PHASE{n}.md` or `docs/backlog/HARNESS.md`, compare candidates, recommend one |
| `/register [description]` | Register a new work item; route to STATUS Active Work / Next Actions / PHASE{n}.md / HARNESS.md based on urgency and type; propose STATUS Update if needed |
| `/work <ID>` | Find the backlog item, declare risk level, propose scope/files/verification/risk, then wait for approval |
| `/resume <ID>` | Compare `docs/STATUS.md` with actual files, report drift, and propose recovery before editing |
| `/done` | Report completed work, changed files, validation, residual risk, STATUS update need, decision need, state, commit status |

## Command Intent Recognition

When the user's intent matches a workflow operation without an explicit slash command, follow the corresponding procedure:

| Intent | Procedure |
| --- | --- |
| Register / add a work item | `/register` — determine urgency and type, route accordingly (see table below) |
| Record a decision as DR | `/record-decision` — DR format, file naming, OQ linkage |
| Start / plan a specific task | `/work` — pre-checks: PLAN.md force-load conditions, troubleshooting check, risk level declaration |
| Resume an interrupted task | `/resume` — drift check: compare actual file state vs `docs/STATUS.md` before editing |

Work item routing:

| Urgency / Type | Target |
| --- | --- |
| Start immediately (urgent patch) | `docs/STATUS.md` Active Work → chain to `/work` |
| Soon / next session | `docs/STATUS.md` Next Actions |
| Product / Phase{n} feature | `docs/backlog/PHASE{n}.md` |
| Harness / workflow / rule improvement | `docs/backlog/HARNESS.md` |

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
