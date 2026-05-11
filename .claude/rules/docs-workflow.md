---
paths:
  - "docs/**/*.md"
  - "CLAUDE.md"
  - ".claude/**/*.md"
---

# Documentation Workflow Rules

## Core Principles

- Follow `CLAUDE.md` and `docs/CLAUDE.md` first.
- Treat `docs/STATUS.md` as the single source of truth for current work state.
- Read only the sections needed — never load long documents in full by default.
- Load `docs/TODO/PHASE1/TODO-BLOCK*.md` only when Phase 1 historical context is explicitly required.
- When work state changes, propose updating `docs/STATUS.md`.

## Document Management

MUST:

- Keep active context files short and current.
- Use `docs/STATUS.md` for live work state.
- Use `docs/backlog/*.md` for candidate work.
- Use `docs/archive/*.md` for completed historical detail.
- Include done criteria and verification for actionable work items.

NEVER:

- Turn `docs/STATUS.md` into a full changelog.
- Duplicate long instruction blocks across `CLAUDE.md`, `docs/CLAUDE.md`, and `.claude/system.md`.
