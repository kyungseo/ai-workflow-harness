---
paths:
  - "docs/**/*.md"
  - "CLAUDE.md"
  - "AGENTS.md"
  - ".claude/**/*.md"
---

# Documentation Workflow Rules

MUST:

- Keep active context files short and current.
- Use `docs/STATUS.md` for live work state.
- Use `docs/backlog/PHASE{n}.md` for product and Phase{n} preparation candidate work.
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

## Command Intent Recognition

When the user's intent matches a workflow command without an explicit `/command` invocation, follow the corresponding command procedure by reading the command file:

| Intent | Command file to follow |
| --- | --- |
| 작업 항목 등록·추가 | `.claude/commands/register.md` |
| DR·의사결정 기록 | `.claude/commands/record-decision.md` |
| 특정 작업 시작·계획 | `.claude/commands/work.md` (사전 체크 3가지 포함) |
| 중단된 작업 재개 | `.claude/commands/resume.md` (drift 체크 포함) |

NEVER:

- Turn `docs/STATUS.md` into a full changelog.
- Duplicate long instruction blocks across `CLAUDE.md`, `AGENTS.md`, `docs/AGENT-WORKFLOW.md`.
- Mix product backlog items and harness backlog items without an explicit reason.
- Edit `docs/STATUS.md` silently as an agent scratchpad.
