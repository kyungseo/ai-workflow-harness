# STATUS.md

Live project state for Claude Code.
Keep this file short. Move completed phase detail to `docs/archive/`.

Last updated: 2026-05-11

## Current State

| Field | Value |
| --- | --- |
| Current phase | Phase 2 planning |
| Phase 1 | Complete |
| Active plan | `docs/PLAN.md` |
| Active backlog | `docs/backlog/PHASE2.md` |
| Phase 1 status archive | `docs/archive/phase1-status.md` |
| Phase 1 plan archive | `docs/archive/phase1-plan.md` |

## Work Context Rule

Use this file to manage work state, not as a substitute for planning, implementation, or testing.

For every new work item:

1. Select or create a backlog item.
2. Confirm priority, dependencies, done criteria, and verification.
3. Create a short plan and get approval when the work is broad or risky.
4. Move the item into Active Work before implementation.
5. Implement the approved scope.
6. Verify with the agreed command or scenario.
7. Update Active Work, checkpoint status, blockers, and next actions.
8. Move completed detail to archive when it no longer informs active work.

## Active Work

| ID | Priority | Status | Scope | Done Criteria | Verification |
| --- | --- | --- | --- | --- | --- |
| P2-PLAN-001 | P0 | Done | Prepare Claude Code context and Phase 2 work-management structure | `CLAUDE.md`, `docs/CLAUDE.md`, `docs/STATUS.md`, and Phase 2 backlog are context-efficient and reusable | Documentation diff inspection |

## Phase 2 Checkpoints

| Checkpoint | Purpose | Status | Verification |
| --- | --- | --- | --- |
| CP-P2-0 | Phase 2 plan and backlog are structured before implementation | Done | Review `docs/STATUS.md` and `docs/backlog/PHASE2.md` |
| CP-P2-1 | Security-sensitive token/session decisions are resolved | Not started | Decision records and targeted tests |
| CP-P2-2 | Gateway/proxy behavior is production-aware | Not started | Rate limiting and trusted proxy tests |
| CP-P2-3 | Infrastructure direction is selected | Not started | K8s/CI decision records and dry-run validation |
| CP-P2-4 | Observability baseline is implemented | Not started | Metrics/tracing/logging validation |

## Blockers And Open Questions

| ID | Status | Question | Decision Needed |
| --- | --- | --- | --- |
| OQ-001 | Open | Should Phase 2 prioritize security hardening before infrastructure expansion? | Recommended: yes |
| OQ-002 | Open | Should K8s use Helm or Kustomize? | Decide before writing manifests |
| OQ-003 | Open | Should token storage move from localStorage to HttpOnly Cookie? | Decide before frontend/auth changes |
| OQ-004 | Closed | `.claude/claude.json` was legacy custom harness config | Deleted; official Claude Code config is `.claude/settings.json` |

## Recent Decisions

| Date | Decision | Reason | Reversal Cost |
| --- | --- | --- | --- |
| 2026-05-11 | Keep active state in `docs/STATUS.md` and move Phase 1 detail to archive | Reduce Claude context load for Phase 2 | Low |
| 2026-05-11 | Make root `CLAUDE.md` reusable and import `docs/CLAUDE.md` explicitly | Improve instruction loading and cross-project reuse | Low |
| 2026-05-11 | Add official `.claude/settings.json` and path-scoped `.claude/rules/` | Reduce duplicated prompt context and align with Claude Code configuration | Low |
| 2026-05-11 | Delete legacy `.claude/claude.json` | Remove obsolete custom harness configuration after user confirmation | Low |

## Next Actions

1. Review Phase 2 backlog priorities with the user.
2. Choose the first implementation item from `docs/backlog/PHASE2.md`.
3. Keep Cursor rules aligned with Claude rules when the work-management model changes.
