---
paths:
  - "docs/**/*.md"
  - "CLAUDE.md"
  - "AGENTS.md"
  - ".claude/**/*.md"
  - ".agents/**/*.md"
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
- Follow `docs/AGENT-WORKFLOW.md` Approval Matrix before execution, scope expansion, state changes, or committing.
- Request explicit user approval before editing `docs/STATUS.md`; report the Approval Matrix state-change proposal first.
- Keep `Done` work immutable. If follow-up correction is needed, propose a new work item.
- Check `docs/HARNESS-PROTOCOL.md` when workflow rules, commands, DRs, or document structure change.

## Command Intent Recognition

When the user's intent matches a workflow command without an explicit `/command` invocation, follow the corresponding command procedure by reading the command file:

| Intent | Command file to follow |
| --- | --- |
| Register or add a work item | `.claude/commands/register.md` |
| Record a DR or decision | `.claude/commands/record-decision.md` |
| Start or plan a specific task | `.claude/commands/work.md` (includes the three pre-checks) |
| Resume interrupted work | `.claude/commands/resume.md` (includes drift checks) |

**Criteria for adding intent recognition here:**

| Criterion | Include | Exclude |
| --- | --- | --- |
| Frequency | Repeats almost every session | One-off or occasional use |
| Command file size | Lightweight: one procedure, narrow scope | Multi-step workflow or detailed production rules |
| False-positive risk | Intent is clear and low-risk to detect | Context is broad and may trigger incorrectly |
| Invocation style | Automatic recognition is more natural | Explicit `/command` invocation is more predictable |

Example: do not add `/doc` here because it is occasional and heavy. Load `doc.md` only for an explicit `/doc` invocation or a clear user request.

NEVER:

- Turn `docs/STATUS.md` into a full changelog.
- Duplicate long instruction blocks across `CLAUDE.md`, `AGENTS.md`, `docs/AGENT-WORKFLOW.md`.
- Mix product backlog items and harness backlog items without an explicit reason.
- Edit `docs/STATUS.md` silently as an agent scratchpad.
