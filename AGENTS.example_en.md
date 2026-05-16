# AGENTS.example_en.md

> This file is a design draft saved as AGENTS.example_en.md.
> The actual Codex entry point is `AGENTS.md` at the repo root.
> This file is kept for reference only.

Project-level instruction automatically read by Codex from the repo root.
Symmetric counterpart to `CLAUDE.md`. Shared operating rules live in `docs/AGENT-WORKFLOW.md` and `docs/harness-protocol/`.

## 1. Required Reading Order (Session Start)

1. `CLAUDE.md` — shared operating contract
2. `docs/AGENT-WORKFLOW.md` — minimal operating rules (includes context routing table)
3. `docs/STATUS.md` — current work state (read Current State, Active Work, Checkpoints, Blockers And Open Questions, Next Actions sections only)
4. (conditional) `docs/backlog/PHASE2.md` or `docs/backlog/HARNESS.md`

Conditional load criteria follow the Context Routing table in `docs/AGENT-WORKFLOW.md`.

## 2. State Machine

```text
INIT -> PLAN -> APPROVAL -> EXECUTE -> VALIDATE -> CHECKPOINT -> END
                 ^              |
                 |              v
              RECOVER <- FAIL <-+
```

Detail: `docs/harness-protocol/01-session-state-machine.md`

## 3. Manual Command Equivalents

Codex does not execute `.claude/commands/*.md` directly.
Perform the equivalent steps manually as follows.

| Claude command | Codex manual equivalent |
| --- | --- |
| `/start` | Follow §1 reading order, then report: conclusion / current status / next work candidates / additional docs needed / risks |
| `/pick` | Read STATUS.md → select PHASE2.md or HARNESS.md based on work type → recommend the single highest-priority candidate |
| `/work <ID>` | Locate ID in backlog → declare L1/L2/L3 risk → report plan with scope/files/verification/risk → end with "Shall I proceed?" and wait for approval |
| `/done` | Execute §4 session-end checklist |
| `/resume <ID>` | Read STATUS.md → check actual file state against STATUS.md → report any mismatch before modifying |

## 4. Session-End Checklist

1. Work completed
2. Files changed
3. Verification executed
4. Residual risk
5. Whether `docs/STATUS.md` needs updating — if so, report a STATUS Update Proposal first and modify only after explicit approval
6. Whether any DR-worthy decisions were made — if so, list them and ask whether to record
7. State machine exit state — VALIDATE result, whether CHECKPOINT or FAIL/RECOVER is needed
8. Commit state — if not committed, state the reason and residual risk
9. Starter sentence for the next session

## 5. Failure and Recovery

Report validation failure, state mismatch, or context loss immediately as FAIL.

Report must include:
- Failure type
- Root cause
- Affected files / state
- Recovery options
- Recommended path

Recovery flow: `FAIL -> report -> options -> user decision -> PLAN`

Detail: `docs/harness-protocol/06-recovery-and-validation.md`

## 6. STATUS Protection Rules

Do not modify `docs/STATUS.md` directly without approval.

If a change is needed, first report:
- Section to change
- Reason for change
- State after change
- Reversal cost

Modify only after the user gives explicit approval.

## 7. Prohibited Actions

- Do not start implementation without approval
- Do not commit while in a VALIDATE-failed state
- Do not resume a `Done` task directly — propose a new work item for any follow-up correction
- Do not read `.env`, `secrets/**`, `*.key`, `*.pem`, `.claude/settings.local.json`
- Do not run `sudo`, `rm -rf`, `kubectl`, or `terraform`
