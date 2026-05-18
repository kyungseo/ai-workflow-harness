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
- Follow `docs/AGENT-WORKFLOW.md` Approval Matrix before execution, scope expansion, state changes, or committing.
- Request explicit user approval before editing `docs/STATUS.md`; report the Approval Matrix state-change proposal first.
- Keep `Done` work immutable. If follow-up correction is needed, propose a new work item.
- Check `docs/HARNESS-PROTOCOL.md` when workflow rules, commands, DRs, or document structure change.

## Command Intent Recognition

When the user's intent matches a workflow command without an explicit `/command` invocation, follow the corresponding command procedure by reading the command file:

| Intent | Command file to follow |
| --- | --- |
| 작업 항목 등록·추가 | `.claude/commands/register.md` |
| DR·의사결정 기록 | `.claude/commands/record-decision.md` |
| 특정 작업 시작·계획 | `.claude/commands/work.md` (사전 체크 3가지 포함) |
| 중단된 작업 재개 | `.claude/commands/resume.md` (drift 체크 포함) |

**등록 기준 — 이 테이블에 추가하는 조건:**

| 기준 | 등록 대상 (O) | 등록 제외 (X) |
| --- | --- | --- |
| 사용 빈도 | 세션마다 반복적으로 사용 | 단발성 또는 가끔 사용 |
| Command 파일 크기 | 경량 — 단일 절차, 좁은 범위 | 다단계 workflow, 상세 생산 규칙 포함 |
| 오탐(false positive) 위험 | 의도 감지가 명확하고 낮음 | 문맥이 넓어 잘못 트리거될 수 있음 |
| 호출 방식 | 자동 감지가 더 자연스러움 | 명시적 `/command` 입력이 더 예측 가능 |

예시: `/doc`은 단발성·대용량 커맨드이므로 이 테이블에 추가하지 않는다. 명시적 `/doc` 입력 또는 사용자 요청 시에만 `doc.md`를 로드한다.

NEVER:

- Turn `docs/STATUS.md` into a full changelog.
- Duplicate long instruction blocks across `CLAUDE.md`, `AGENTS.md`, `docs/AGENT-WORKFLOW.md`.
- Mix product backlog items and harness backlog items without an explicit reason.
- Edit `docs/STATUS.md` silently as an agent scratchpad.
