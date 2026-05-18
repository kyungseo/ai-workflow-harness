---
id: HRN-019
priority: P2
status: Done
risk: Low
scope: /done Work 완료 절차 분리 — /close 커맨드 신규 도입 (Work Done + 선택적 Archive), /done에서 Work Done 단계 제거 및 pause Discovery 체크 추가
appetite: 1d
planned_start: 2026-05-18
planned_end:
actual_end: 2026-05-18
related_dr: []
related_commits: []
related_troubleshooting: []
---

## Plan

현재 `/done`은 세션 종료 요약과 Work Done 처리를 함께 수행한다.
이 구조는 두 가지 시나리오를 처리하지 못한다.

1. **Work 완료 후 세션 계속**: Work는 끝났지만 다른 작업을 이어가고 싶을 때 수단이 없다.
2. **Pause 시 Discovery 미기록**: Work가 미완료인 채로 `/done`을 실행하면 현재 진행 상황이 기록되지 않고 세션이 종료될 수 있다.

**해결책:**
- `/close` 신규 생성: Work Done 처리 전용. 실행 후 세션 계속. Archive 여부도 선택 가능.
- `/done` 수정: Work Done 단계 제거. Pause 시 Active Work Discovery 미기록이면 기록 내용 제안.

**Alternatives:**
- `/done`에 조건 분기 추가: `/done --work`처럼 — 인터페이스가 복잡해짐. 채택 안 함.
- 별도 `/archive` 커맨드: Archive 경로를 `/close`에 포함하면 `/archive`는 불필요. 채택 안 함.

## Done Criteria

- [x] `close.md` 생성: Work Done 처리 + 선택적 Archive, 세션 계속 흐름 명시
- [x] `done.md` 수정: items 11-12 제거, `/close` 안내 + pause Discovery 체크 추가
- [x] `AGENTS.md`: `/close` → Work Done+Archive, `/done` → session summary only 반영
- [x] `workflow.mdc`: 동일
- [x] `HARNESS-QUICK-REFERENCE.md`: `/close` 추가, END 설명 갱신
- [x] `WORKFLOW-MANUAL.md`: 완료 절차 재작성
- [x] `prompts/claude-session-start.md`, `prompts/README.md`, `prompts/codex-session-start.md` 반영
- [x] `scripts/create-harness.sh` scaffold 반영 확인
- [x] Verification 통과 (`git diff --check`, `bash -n create-harness.sh`, 시나리오 확인)

## Verification

```bash
git diff --check
bash -n scripts/create-harness.sh
# /close 시나리오: Work Done만, 세션 계속
# /done 시나리오: Work Done 없음, pause Discovery 체크
rg -n "/close|Work Done" .claude/commands/done.md .claude/commands/close.md AGENTS.md .cursor/rules/workflow.mdc docs/HARNESS-QUICK-REFERENCE.md docs/WORKFLOW-MANUAL.md prompts/README.md prompts/claude-session-start.md prompts/codex-session-start.md
```

## Checkpoints

| CP | Description | Status |
|----|-------------|--------|
| 1  | Work 파일 생성 + `close.md` 신규 생성 | Done |
| 2  | `done.md` 수정 | Done |
| 3  | `AGENTS.md`, `workflow.mdc` 수정 | Done |
| 4  | `HARNESS-QUICK-REFERENCE.md`, `WORKFLOW-MANUAL.md` 수정 | Done |
| 5  | `prompts/`, `create-harness.sh` 반영 확인 | Done |
| 6  | Verification | Done |

## Discovery
