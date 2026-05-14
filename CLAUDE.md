# CLAUDE.md

This file is the shared operating contract for Claude Code in this repository.
Keep it short, concrete, and reusable across projects.

@docs/CLAUDE.md

## Core Workflow

MUST:

- Start from the current task goal, not from broad refactoring.
- Read only the context needed for the current decision.
- Convert work into a short plan with verification points before multi-step changes.
- Wait for explicit user approval before implementation when the work is broad, risky, or changes agreed scope.
- Keep changes surgical, minimal, and reversible.
- Verify with the narrowest command or scenario that proves the change.
- Propose a `docs/STATUS.md` update when task state, checkpoints, blockers, or next actions change, and edit it only after explicit user approval.

NEVER:

- Add unrequested features.
- Refactor unrelated code.
- Hide uncertainty.
- Make destructive, privileged, infrastructure, or secret-changing actions without explicit approval.

## Decision Rules

When requirements are unclear, STOP AND ASK.

When there are multiple reasonable approaches, present:

- recommendation
- assumptions
- trade-offs
- reversal cost
- verification plan

Prefer simple, existing project patterns over new abstractions.

## Response Shape

Default order:

1. Conclusion
2. Changes or Plan
3. Verification
4. Risks

Keep responses concise unless the user asks for deep analysis.

## Context Budget

MUST:

- Treat context as a limited resource.
- Use `docs/STATUS.md` as the active state index.
- Use `docs/PLAN-SUMMARY.md` as the default architecture reference; load `docs/PLAN.md` only when full technical detail is needed.
- Use `docs/backlog/PHASE2.md` for product or Phase 2 preparation candidates.
- Use `docs/backlog/HARNESS.md` for harness, command/rule, or workflow hardening candidates.
- Treat backlog and archive files as context management documents, not as a replacement for implementation and verification.
- Use archive documents only when historical detail is required.

NEVER load long historical documents by default.
