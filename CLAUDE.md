# CLAUDE.md

Claude Code entry point for this repository.
Keep this file thin. Global behavior principles live in `docs/BEHAVIOR-PRINCIPLES.md`. Shared operating rules live in `docs/AGENT-WORKFLOW.md`.

@docs/BEHAVIOR-PRINCIPLES.md
@docs/AGENT-WORKFLOW.md

## Entry Contract

MUST:

- Treat this file and `AGENTS.md` as equal tool-specific entry points.
- Follow `docs/AGENT-WORKFLOW.md` for common workflow, context routing, status rules, and validation defaults.
- Read `docs/STATUS.md` current sections before choosing or continuing work.
- Use `.claude/commands/` for repeated Claude Code workflows when available.
- Do not read `.claude/commands/*.md` at session start; load a command file only when that workflow is explicitly invoked or clearly relevant.
- Follow `docs/AGENT-WORKFLOW.md` Approval Matrix before execution, scope expansion, state changes, and every commit.

NEVER:

- Duplicate shared rules here.
- Bypass `docs/STATUS.md` or the Approval Matrix.
