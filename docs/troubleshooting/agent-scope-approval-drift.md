---
symptom: Agent가 승인된 범위 밖 문서까지 함께 수정
track: harness
category: workflow
environment: 공통
status: Resolved
related_dr: []
---

# Agent Scope Approval Drift

Date: 2026-05-17
Environment: Claude Code, Codex, Cursor 공통 workflow
Related: `docs/AGENT-WORKFLOW.md`, `docs/HARNESS-QUICK-REFERENCE.md`

---

## 증상

사용자가 특정 문서에 addendum을 추가하자고 승인했는데, Agent가 관련 문서 정합성을 이유로
`README.md`와 `docs/DEVELOPER-GUIDE.md`까지 함께 수정했다.

사용자 의도는 addendum 안에 후속 변경 범위를 남기는 것이었고, 실제 후속 파일을 즉시 수정하는
것은 아니었다.

---

## 원인

기존 workflow에는 이미 다음 규칙이 있었다.

- 구현 또는 문서 변경 전 plan을 제시하고 승인 후 실행한다.
- 승인 없이 넓은 변경, L3 변경, scope 확장을 실행하지 않는다.
- commit 전에는 `git status`, `git add`, `git status`, `git diff --cached` 순서로 확인한다.

하지만 이 규칙은 큰 원칙 중심이라 다음 edge case가 충분히 명시적이지 않았다.

- 작은 L1 작업은 승인된 scope 안에서 빠르게 진행해도 되는지
- 관련 문서까지 고치고 싶을 때 그것이 scope expansion인지
- commit 전 diff 확인을 Agent 내부 확인으로 끝낼지, 사용자에게 diff summary와 commit message를
  보고하고 승인받아야 하는지

그 결과 Agent가 "관련 문서도 맞추는 것이 좋다"는 판단을 사용자 승인 범위로 과잉 해석했다.

---

## 조치

새 승인 체계를 만들지 않고, 기존 승인 규약을 `Scope And Commit Approval`로 명확화했다.

공통 규칙:

- 승인된 scope 안의 작은 L1 변경은 빠르게 편집할 수 있다.
- 승인된 scope 밖의 파일, 문서, 설정으로 변경이 확장되면 먼저 추가 scope, 이유, 검증 방법을
  보고하고 승인 대기한다.
- 특히 `README.md`, `docs/STATUS.md`, workflow 문서, command, prompt, rule, developer-facing
  문서로 확장되면 승인 없이 수정하지 않는다.
- commit 전에는 validation 결과, diff summary, 제안 commit message를 보고하고 승인 대기한다.

반영 위치:

- `docs/AGENT-WORKFLOW.md`: canonical 공통 규칙
- `docs/HARNESS-QUICK-REFERENCE.md`: daily checklist
- `AGENTS.md`, `CLAUDE.md`: entry point 참조
- `.claude/rules/docs-workflow.md`, `.claude/rules/git-workflow.md`: Claude rule 표면
- `.cursor/rules/coding.mdc`, `.cursor/rules/git-commit.mdc`: Cursor rule 표면
- `prompts/codex-session-start.md`: Codex fallback prompt 표면

---

## 검증

확인할 사항:

- `Scope And Commit Approval`이 공통 문서와 quick reference에 존재한다.
- `AGENTS.md`와 `CLAUDE.md`가 같은 공통 규칙을 참조한다.
- Claude/Cursor git commit rule 모두 commit 전 사용자 승인 문구를 포함한다.
- `git diff --check`가 통과한다.

---

## 변경 내역

| Date | Commit | 내용 |
| --- | --- | --- |
| 2026-05-17 | `9d9fb29639c768cfbf0c419ebb3c3b5ed29e4f18` | Scope And Commit Approval 공통 규칙과 Claude/Codex/Cursor 표면 정렬 |

---

## 관련 문서

- [docs/AGENT-WORKFLOW.md](../AGENT-WORKFLOW.md)
- [docs/HARNESS-QUICK-REFERENCE.md](../HARNESS-QUICK-REFERENCE.md)
