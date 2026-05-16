# CLAUDE.md

Claude Code entry point for this repository.
Keep this file thin. Shared operating rules live in `docs/AGENT-WORKFLOW.md`.

@docs/AGENT-WORKFLOW.md

## Entry Contract

MUST:

- Treat this file and `AGENTS.md` as equal tool-specific entry points.
- Follow `docs/AGENT-WORKFLOW.md` for common workflow, context routing, status rules, and validation defaults.
- Read `docs/STATUS.md` current sections before choosing or continuing work.
- Use `.claude/commands/` for repeated Claude Code workflows when available.
- Follow `docs/AGENT-WORKFLOW.md` Scope And Commit Approval before scope expansion and every commit.

NEVER:

- Duplicate shared rules here.
- Bypass `docs/STATUS.md` or the STATUS Update Proposal gate.
