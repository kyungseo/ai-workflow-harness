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
- Use path-mirrored locations under `docs/archive/` for completed historical detail.
- Use `docs/HARNESS-QUICK-REFERENCE.md` for daily workflow execution rules.
- Include done criteria and verification for actionable work items.
- Use Work files for large tasks: `docs/works/{category}/{ID}-{lowercase-topic}.md` (spec: DR-013).
- Do not reuse task IDs for different meanings.
- Follow `docs/decisions/DR-007-language-policy.md` when editing docs, prompts, commands, rules, Cursor rules, or hook messages.
- Follow `docs/AGENT-WORKFLOW.md` Scope And Commit Approval before expanding approved scope or committing.
- Request explicit user approval before editing `docs/STATUS.md`; report the State Update Gate proposal first.
- Keep `Done` work immutable. If follow-up correction is needed, propose a new work item.
- Check `docs/harness-protocol/05-triggers-and-cascade.md` when workflow rules, commands, DRs, or document structure change.

## Command Intent Recognition

When the user's intent matches a workflow command without an explicit `/command` invocation, follow the corresponding command procedure.
Load only the matching command file; do not read `.claude/commands/*.md` as a group.

| Intent | Command file |
| --- | --- |
| Register or add a work item | `.claude/commands/register.md` |
| Record an accepted decision as a DR | `.claude/commands/record-decision.md` |
| Start or plan a specific task | `.claude/commands/work.md` |
| Resume interrupted work | `.claude/commands/resume.md` |
| Debug or investigate a failure | `.claude/commands/debug.md` |
| Create presentation, report, review package, or polished document artifact | `.claude/commands/doc.md` |
| Finish or close out current work | `.claude/commands/done.md` |
| Audit workflow or document consistency | `.claude/commands/health.md` |

Use `/health --cascade` intent when the user asks whether a workflow/document change requires canonical, tool-specific, user-facing, scaffold, or historical follow-up checks.

NEVER:

- Turn `docs/STATUS.md` into a full changelog.
- Duplicate long instruction blocks across `CLAUDE.md`, `AGENTS.md`, `docs/AGENT-WORKFLOW.md`.
- Mix product backlog items and harness backlog items without an explicit reason.
- Edit `docs/STATUS.md` silently as an agent scratchpad.
