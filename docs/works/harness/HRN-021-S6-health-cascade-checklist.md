---
id: HRN-021-S6
priority: P1
status: Done
risk: L2
scope: AI Workflow simplification S6 — /health --cascade를 coverage-preserving checklist runner로 정리
appetite: 0.5d
planned_start: 2026-05-19
planned_end:
actual_end: 2026-05-19
related_dr: []
related_commits: []
related_troubleshooting: []
---

## Plan

`docs/retrospectives/ai-workflow-complexity-review-20260518.md`의 Simplification Candidates S6을 실행한다.

S6는 `/health --cascade`의 감사 범위를 줄이지 않는다.
canonical -> tool-specific -> user-facing -> scaffold 계층과 P0/P1/P2 발견 분류는 유지하되, AI가 넓게 추론하는 판단 엔진이 아니라 변경 파일 유형별 필수 surface, 필수 grep, 필수 simulation을 고정한 checklist runner로 정리한다.

S3 Work lifecycle Candidate 제거는 이번 범위에 포함하지 않는다.

## Done Criteria

- [x] `.claude/commands/health.md`의 `--cascade` 설명이 coverage-preserving checklist runner 기준을 명시한다.
- [x] 변경 파일 유형별 required surfaces, required grep, required simulations 표가 있다.
- [x] report format이 P0/P1/P2, checked surfaces, skipped/not applicable, suggested fixes 중심으로 단순화된다.
- [x] `docs/HARNESS-PROTOCOL.md`, `docs/HARNESS-QUICK-REFERENCE.md`, `docs/WORKFLOW-MANUAL.md`가 `/health --cascade` 역할을 과장 없이 설명한다.
- [x] Work 파일과 STATUS/Work index lifecycle pointer가 `HRN-021-S6` 상태를 반영한다.
- [x] `git diff --check` 통과.

## Verification

```bash
rg -n "coverage-preserving|Required Surface|Required Grep|Required Simulation|Skipped|P0|P1|P2" \
  .claude/commands/health.md docs/HARNESS-PROTOCOL.md docs/HARNESS-QUICK-REFERENCE.md docs/WORKFLOW-MANUAL.md
git diff --check
```

## Checkpoints

| CP | Description | Status |
|----|-------------|--------|
| 1 | Work 파일 생성 및 Active pointer 추가 | Done |
| 2 | health --cascade checklist runner 구조 반영 | Done |
| 3 | canonical/quick/user-facing 역할 설명 정렬 | Done |
| 4 | Verification 및 diff review | Done |

## Discovery

### 착수 메모 (2026-05-19)

사용자 우려를 반영해 S6는 감사 범위 축소가 아니라 coverage 보존형 구조화로 진행한다.
S1까지 완료되어 protocol 구조는 단일 `docs/HARNESS-PROTOCOL.md` 기준으로 안정화된 상태다.

### 검증 메모 (2026-05-19)

`/health --cascade`를 coverage-preserving checklist runner로 정리했다.
필수 surface matrix, grep pack, simulation matrix, skipped/not applicable 보고 기준을 추가해 감사 범위는 유지하고 AI 재량 판단을 줄였다.
검증 중 `docs/` 전체 grep이 historical snapshot까지 섞어 노이즈를 만들 수 있음을 확인해, 기본 grep 대상은 live surface로 제한하고 historical match는 별도 snapshot reference로 분류하도록 보강했다.
또한 zsh에서 공백 문자열 변수는 target 목록으로 분리되지 않으므로, `LIVE_TARGETS`는 배열로 정의하도록 수정했다.
live target grep 결과에서 `STATUS.md` Recent Decisions, 과거 Done Work 파일, grep 예시 자체의 match는 historical/context match로 분류했고, active backlog의 S6 설명은 새 표현으로 정렬했다.
`git diff --check` 통과.

### Close 메모 (2026-05-19)

Done Criteria 충족 및 `git diff --check`, scaffold dry-run 통과를 확인했다.
STATUS Active Work pointer는 제거하고, Work index는 Done archive pending으로 이동한다.
