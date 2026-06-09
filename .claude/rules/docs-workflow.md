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
- Use `docs/backlog/PRODUCT.md` for Product track candidate work (optional phasing: `PRODUCT-P{n}.md`).
- Use `docs/backlog/HARNESS.md` for harness, command/rule, and workflow hardening candidate work.
- Use path-mirrored locations under `docs/archive/` for completed historical detail.
- Use `docs/HARNESS-QUICK-REFERENCE.md` for daily workflow execution rules.
- Include done criteria and verification for actionable work items.
- When adding or moving a file in a directory that has a `README.md` index, update that index in the same change. Applies to `docs/decisions/`, `docs/retrospectives/`, `docs/troubleshooting/`, `docs/works/{category}/`, and any other directory with a `README.md`. On archive moves, remove the row from the source index and add it to the archive index.
- Use Work files for large tasks: `docs/works/{category}/{ID}-{lowercase-topic}.md` (spec: DR-013).
- When creating a new `docs/troubleshooting/` or `docs/retrospectives/` file, apply the DR-027 frontmatter spec defined in each directory's `README.md`.
- Do not reuse task IDs for different meanings.
- Follow `docs/decisions/DR-007-language-policy.md` when editing docs, prompts, commands, rules, Cursor rules, or hook messages.
- Follow `docs/AGENT-WORKFLOW.md` Approval Matrix before execution, scope expansion, state changes, or committing.
- Request explicit user approval before editing `docs/STATUS.md`; report the Approval Matrix state-change proposal first.
- Keep `Done` work immutable. If follow-up correction is needed, propose a new work item.
- Check `docs/HARNESS-PROTOCOL.md` when workflow rules, commands, DRs, or document structure change.
- When detailed runbooks or checklists accumulate in core documents, extract them to a separate slice file and replace the content with a conditional pointer: `Load \`docs/{slice-file}.md\` only when {condition}.`

## Command Intent Recognition

When the user's intent matches a workflow command without an explicit `/command` invocation, follow the corresponding command procedure by reading the command file:

| Intent | Command file to follow |
| --- | --- |
| Register or add a work item — "작업 등록하자", "백로그에 추가해줘", "이 아이디어 등록해줘" | `.claude/commands/work-register.md` |
| Record a DR or decision — "결정 기록하자", "DR 남기자", "의사결정 기록해줘" | `.claude/commands/record-decision.md` |
| Start or plan a specific task — "작업 계획을 세우자", "work 파일 작성하자", "작업을 시작하자", "플랜 짜줘". Identify the target task from conversation context (recent Work ID, backlog item, or topic under discussion); if no specific task is identifiable from context, surface `/work-select` first. | `.claude/commands/work-plan.md` (includes the three pre-checks) |
| Resume interrupted work — "이어서 하자", "작업 재개하자", "중단된 작업 계속하자" | `.claude/commands/work-resume.md` (includes drift checks) |
| Complete / close / wrap up current work, or request commit·PR·merge after task — "작업 마무리하자", "close 처리해줘", "완료하고 PR 올리자", "커밋하자" | `.claude/commands/work-close.md` (load skill; multi-step procedure runs from canonical) |
| End the session, summarize today's work, or wrap up without closing a Work item — "세션 마무리하자", "오늘 정리해줘", "요약해줘" | `.claude/commands/session-summary.md` |

**Ambiguity rule:** If the recognized intent is uncertain or multiple interpretations are equally plausible, confirm the interpreted intent in one line before loading a procedure. Do not silently pick one and execute. Example: user says "진행해" after a descriptive (non-proposal) AI statement — confirm "work-close를 실행하는 것으로 이해하겠습니다, 맞나요?" before proceeding.

**Criteria for adding intent recognition here:**

| Criterion | Include | Exclude |
| --- | --- | --- |
| Frequency | Repeats almost every session | One-off or occasional use |
| Command file size | Lightweight: one procedure, narrow scope | Multi-step workflow or detailed production rules |
| False-positive risk | Intent is clear and low-risk to detect | Context is broad and may trigger incorrectly |
| Invocation style | Automatic recognition is more natural | Explicit `/command` invocation is more predictable |

Example: do not add `/work-doc` here because it is occasional and heavy. Load `work-doc.md` only for an explicit `/work-doc` invocation or a clear user request.

Excluded with justification:
- `/work-select` — intent is context-dependent ("what should I work on next?" means different things when Active Work exists vs. when idle; false-positive risk is high). Use explicit `/work-select` or follow session-start idle-state guidance.
- `/work-close` multi-step flag — added above with a trigger-load pattern rather than full inline procedure, to satisfy the "multi-step" exclusion criterion while still ensuring the skill is loaded on natural-language close intent.

NEVER:

- Turn `docs/STATUS.md` into a full changelog.
- Duplicate long instruction blocks across `CLAUDE.md`, `AGENTS.md`, `docs/AGENT-WORKFLOW.md`.
- Mix product backlog items and harness backlog items without an explicit reason.
- Edit `docs/STATUS.md` silently as an agent scratchpad.
