---
id: HRN-021-S4
priority: P1
status: Done
risk: L2
scope: AI Workflow simplification S4 — Quick Mode 예외 조건 삭제, harness/workflow surface 기본 L2 명시
appetite: 0.5d
planned_start: 2026-05-18
planned_end:
actual_end: 2026-05-18
related_dr: []
related_commits: []
related_troubleshooting: []
---

## Plan

`docs/retrospectives/ai-workflow-complexity-review-20260518.md`의 Simplification Candidates S4를 실행한다.

현재 L1 Quick Mode는 "workflow/protocol/command/rule/prompt/scaffold/status 파일을 건드리면 cascade check를 수행한다"는 예외를 가진다.
Harness 작업에서는 이 예외가 사실상 항상 적용되어 Quick Mode가 작동하지 않는다.

이번 작업은 Quick Mode 예외 구조를 단순화한다.

- harness/workflow surface: 기본 L2
- product surface: L1 Quick Mode 가능

S2 Approval Matrix 통합, S5 manual 역할 재정의, S1 protocol 통합, S6 health checklist화, S3 Candidate 제거는 이번 범위에 포함하지 않는다.

## Done Criteria

- [x] `docs/AGENT-WORKFLOW.md`가 harness/workflow surface 기본 L2와 product surface L1 Quick Mode 가능성을 명시한다.
- [x] `docs/HARNESS-QUICK-REFERENCE.md`가 같은 기준을 짧게 반영한다.
- [x] `docs/harness-protocol/03-work-items-and-naming.md` Quick Mode 기준에서 기존 cascade 예외 대신 surface 기준을 반영한다.
- [x] `docs/harness-protocol/05-triggers-and-cascade.md` T13/T14가 product L1 Quick Mode와 harness L2 기준을 구분한다.
- [x] Claude/Codex/Cursor prompt/rule surface의 Quick Mode 문구가 충돌하지 않는다.
- [x] User-facing `docs/WORKFLOW-MANUAL.md`의 Quick Mode/T13 설명이 새 기준과 충돌하지 않는다.
- [x] S2 이후 simplification candidates는 후속 항목으로 남아 있다.
- [x] 사용자 최종 리뷰 완료: 변경된 Quick Mode/L2 surface 문구를 사용자가 검토하고 Done 처리 가능하다고 확인한다. 이 확인 전에는 HRN-021-S4를 Done 처리하지 않는다.

## Verification

```bash
rg -n "Quick Mode|L1 Quick|harness/workflow|workflow/protocol/command/rule/prompt/scaffold/status|cascade check|기본 L2" \
  docs/AGENT-WORKFLOW.md docs/HARNESS-QUICK-REFERENCE.md \
  docs/harness-protocol/03-work-items-and-naming.md \
  docs/harness-protocol/05-triggers-and-cascade.md \
  docs/WORKFLOW-MANUAL.md \
  .claude/commands/work.md .claude/commands/health.md \
  .cursor/rules/workflow.mdc .cursor/rules/coding.mdc \
  prompts/claude-session-start.md prompts/codex-session-start.md prompts/cursor-session-start.md
scripts/create-harness.sh --dry-run --profile generic harness-s4-review /private/tmp/harness-s4-review
git diff --check
```

## Checkpoints

| CP | Description | Status |
|----|-------------|--------|
| 1 | Work 파일 생성 및 backlog 후속 항목 정리 | Done |
| 2 | Canonical/quick reference/protocol Quick Mode 문구 수정 | Done |
| 3 | Claude/Codex/Cursor prompt/rule surface 정렬 | Done |
| 4 | Verification 및 사용자 최종 리뷰 | Done |

## Discovery

### 착수 메모 (2026-05-18)

사용자 요청에 따라 HRN-021 simplification series 중 S4만 실행한다.
사용자 최종 리뷰를 HRN-021-S4의 Done Criteria에 포함한다.
전체 Work lifecycle에 사용자 리뷰 조건을 일반화하는 방안은 별도 backlog 후보로 분리한다.

### 영향 검토 메모 (2026-05-19)

S4 영향 재검토 결과 P0 없음.
`entrypoint`를 harness/workflow surface 예시에 추가하고, `/work`의 Work 파일 생성 문구를 "기본값으로 검토"로 완화했다.
사용자 매뉴얼 T13 조건도 product surface의 L1 작은 변경으로 명확화했다.
임시 scaffold 생성물(`/private/tmp/harness-s2-review-real`) 기준 S4 Quick Mode/L2 surface 문구가 전파됨을 확인했다.
