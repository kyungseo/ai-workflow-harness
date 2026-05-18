---
id: HRN-021-S5
priority: P1
status: Done
risk: L2
scope: AI Workflow simplification S5 — WORKFLOW-MANUAL.md AI 로드 제외와 cascade 대상 유지 기준 명시
appetite: 0.5d
planned_start: 2026-05-19
planned_end:
actual_end: 2026-05-19
related_dr: []
related_commits: []
related_troubleshooting: []
---

## Plan

`docs/retrospectives/ai-workflow-complexity-review-20260518.md`의 Simplification Candidates S5를 실행한다.

`docs/WORKFLOW-MANUAL.md`는 사용자용 레퍼런스다.
AI 실행 규칙의 canonical source는 `docs/AGENT-WORKFLOW.md`, `docs/HARNESS-PROTOCOL.md`, `docs/harness-protocol/`, tool-specific command/rule/prompt surface다.

이번 작업은 두 기준을 분리한다.

- 평소 AI context loading: `docs/WORKFLOW-MANUAL.md` 제외
- user-facing workflow 변경 또는 cascade 감사: `docs/WORKFLOW-MANUAL.md` 확인 대상 유지

S1 protocol 통합, S6 health checklist화, S3 Candidate 제거는 이번 범위에 포함하지 않는다.

## Done Criteria

- [x] `docs/AGENT-WORKFLOW.md` Context Routing이 `docs/WORKFLOW-MANUAL.md`의 평시 AI 로드 제외 기준을 명시한다.
- [x] `docs/harness-protocol/02-context-loading.md`가 같은 기준을 반영한다.
- [x] `.claude/commands/health.md`가 `--cascade` user-facing layer에서 manual 확인 역할을 유지하되 일반 로드 대상이 아님을 명시한다.
- [x] `docs/WORKFLOW-MANUAL.md`가 사용자 매뉴얼 역할과 cascade 대상 유지 기준을 과장 없이 설명한다.
- [x] Work 파일과 STATUS/Work index lifecycle pointer가 `HRN-021-S5` 상태를 반영한다.
- [x] `git diff --check` 통과.

## Verification

```bash
rg -n "WORKFLOW-MANUAL|user-facing|사용자 매뉴얼|context loading|로드 제외|평시" \
  docs/AGENT-WORKFLOW.md docs/harness-protocol/02-context-loading.md \
  .claude/commands/health.md docs/WORKFLOW-MANUAL.md
git diff --check
```

## Checkpoints

| CP | Description | Status |
|----|-------------|--------|
| 1 | Work 파일 생성 및 Active pointer 추가 | Done |
| 2 | Canonical context loading 기준 정리 | Done |
| 3 | Health cascade/user-facing 기준 정리 | Done |
| 4 | User-facing manual 역할 설명 정리 | Done |
| 5 | Verification 및 diff review | Done |

## Discovery

### 착수 메모 (2026-05-19)

S2 close 직후 HRN-021 simplification series 다음 단계인 S5를 진행한다.
S2 close 변경은 커밋 전 상태로 유지되어 있으며, S5 완료 후 같은 logical series로 함께 검토한다.

### 검증 메모 (2026-05-19)

`WORKFLOW-MANUAL.md`는 평시 AI 실행 규칙 로드 대상에서 제외하고, user-facing workflow 변경 또는 cascade 감사가 필요할 때만 확인하도록 정리했다.
`git diff --check` 통과.

### 영향 검토 반영 메모 (2026-05-19)

S5 영향 검토 결과 P0 없음.
`WORKFLOW-MANUAL.md` 문서 역할 표에서 평시 AI 겸용 오해를 제거하고, user-facing cascade 확인 용도로만 관련 섹션을 확인하도록 정리했다.
`/health --cascade`에는 manual 섹션 확인 예시를 추가했고, scaffold 생성 README의 manual 설명은 사용자용 워크플로우 가이드로 정렬했다.

### Close 메모 (2026-05-19)

Done Criteria 충족 및 `git diff --check` 통과를 확인했다.
STATUS Active Work pointer는 제거하고, Work index는 Done archive pending으로 이동한다.
