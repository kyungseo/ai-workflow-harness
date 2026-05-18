# 01. Session State Machine

이 문서는 session state machine의 canonical source다.

## Core Flow

```text
INIT -> PLAN -> APPROVAL -> EXECUTE -> VALIDATE -> CHECKPOINT -> END
                 ^              |
                 |              v
              RECOVER <- FAIL <-+
```

## State Definitions

| State | Meaning | Required Output |
| --- | --- | --- |
| INIT | 현재 상태 확인 | current phase, active work, blockers |
| PLAN | 작업 범위와 검증 정의 | scope, files, verification, risk, reversal cost |
| APPROVAL | 사용자 승인 대기 | "진행할까요?" |
| EXECUTE | 승인된 범위만 수행 | minimal diff |
| VALIDATE | 결과 확인 | command/result 또는 미실행 사유 |
| CHECKPOINT | 재개 가능한 저장점. Work Done 처리(`/close`)도 이 단계에서 수행 | approved STATUS update, commit decision |
| END | 세션 종료 (`/done`). Work Done 처리 없음 — Done 처리는 CHECKPOINT에서 `/close`로 수행 | summary, next files, residual risk |
| FAIL | 규칙 위반 또는 검증 실패 | failure type, root cause |
| RECOVER | 복구 경로 선택 | options, recommended path |

## Hard Rules

- 승인 없이 EXECUTE로 넘어가지 않는다.
- 상태 변경은 Approval Matrix의 상태 변경 규칙을 따른다.
- VALIDATE 실패 상태에서는 CHECKPOINT 또는 commit을 만들지 않는다.
- 작업 범위가 넓어지면 PLAN으로 돌아간다.
- 동일 오류가 2회 반복되면 FAIL을 보고한다.
- `Done` 상태의 작업을 계속 수정하지 않는다. 완료 후 보정은 신규 작업으로 분리한다.

## Approval Matrix

| 변경 유형 | 실행 전 | 상태 변경 | commit 전 |
| --- | --- | --- | --- |
| L1 product surface | 간단 plan 승인 후 실행. Quick Mode 가능 | Work checkpoint/discovery는 승인 불필요. 실행 후 대상 Work ID와 변경 보고 | validation 결과, diff summary, 제안 commit message 보고 후 승인 |
| L2 harness/workflow surface 또는 설정 변경 | 상세 plan 승인 후 실행. Work 파일 사용을 기본값으로 둔다 | Work Done과 STATUS Active pointer 변경은 대상 Work ID를 명시하고 승인 후 처리 | validation 결과, diff summary, 제안 commit message 보고 후 승인 |
| L3 구조 변경 | 관련 계획 또는 `docs/PLAN.md` 확인, AS-IS/TO-BE와 rollback 포함 후 승인 | Phase criteria, Current phase/focus, Recent Decisions는 `STATUS Update Proposal` 승인 후 처리 | validation 결과, diff summary, 제안 commit message, rollback 단위 보고 후 승인 |

멀티 Active Work 환경에서는 모든 state update 제안에 대상 Work ID를 포함한다.
각 Work는 독립 gate를 가진다.

## Checkpoint Rules

CHECKPOINT는 다음 세션이 재개할 수 있는 저장점이다.

필수:

- 검증 결과 또는 미실행 사유를 보고한다.
- `docs/STATUS.md` 변경 필요 여부를 판단한다.
- Work 파일 checkpoint/discovery 변경은 실행 후 대상 Work ID와 함께 보고한다.
- `docs/STATUS.md` 변경이 필요하면 Approval Matrix에 맞는 제안을 제시하고 승인받는다.

Commit:

- 작업 단위가 완료되고 사용자가 승인하면 commit 가능한 상태로 정리한다.
- commit을 수행하지 않는 경우에는 이유와 남은 risk를 종료 요약에 남긴다.
