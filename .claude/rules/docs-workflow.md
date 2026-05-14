---
paths:
  - "docs/**/*.md"
  - "CLAUDE.md"
  - ".claude/**/*.md"
---

# Documentation Workflow Rules

MUST:

- Keep active context files short and current.
- Use `docs/STATUS.md` for live work state.
- Use `docs/backlog/PHASE2.md` for product and Phase2 preparation candidate work.
- Use `docs/backlog/HARNESS.md` for harness, command/rule, and workflow hardening candidate work.
- Use `docs/archive/*.md` for completed historical detail.
- Use `docs/HARNESS-QUICK-REFERENCE.md` for daily workflow execution rules.
- Include done criteria and verification for actionable work items.
- Use backlog ID based filenames for large task TODO files: `docs/TODO/PHASE{n}/{BACKLOG-ID}-{lowercase-topic}.md`.
- Do not reuse task IDs for different meanings.
- Follow `docs/decisions/DR-007-language-policy.md` when editing docs, prompts, commands, rules, Cursor rules, or hook messages.
- Request explicit user approval before editing `docs/STATUS.md`; report a `STATUS Update Proposal` first.
- Keep `Done` work immutable. If follow-up correction is needed, propose a new work item.
- Check `docs/harness-protocol/05-triggers-and-cascade.md` when workflow rules, commands, DRs, or document structure change.

NEVER:

- Turn `docs/STATUS.md` into a full changelog.
- Duplicate long instruction blocks across `CLAUDE.md`, `docs/CLAUDE.md`.
- Mix product backlog items and harness backlog items without an explicit reason.
- Edit `docs/STATUS.md` silently as an agent scratchpad.
