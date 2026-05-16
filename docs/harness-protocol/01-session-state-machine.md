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
| CHECKPOINT | 재개 가능한 저장점 | approved STATUS update, commit decision |
| END | 세션 종료 | summary, next files, residual risk |
| FAIL | 규칙 위반 또는 검증 실패 | failure type, root cause |
| RECOVER | 복구 경로 선택 | options, recommended path |

## Hard Rules

- 승인 없이 EXECUTE로 넘어가지 않는다.
- `docs/STATUS.md` 변경은 `STATUS Update Proposal` 보고와 사용자 승인 후에만 수행한다.
- VALIDATE 실패 상태에서는 CHECKPOINT 또는 commit을 만들지 않는다.
- 작업 범위가 넓어지면 PLAN으로 돌아간다.
- 동일 오류가 2회 반복되면 FAIL을 보고한다.
- `Done` 상태의 작업을 계속 수정하지 않는다. 완료 후 보정은 신규 작업으로 분리한다.

## Checkpoint Rules

CHECKPOINT는 다음 세션이 재개할 수 있는 저장점이다.

필수:

- 검증 결과 또는 미실행 사유를 보고한다.
- `docs/STATUS.md` 변경 필요 여부를 판단한다.
- `docs/STATUS.md` 변경이 필요하면 먼저 `STATUS Update Proposal`을 제시하고 승인받는다.

Commit:

- 작업 단위가 완료되고 사용자가 승인하면 commit 가능한 상태로 정리한다.
- commit을 수행하지 않는 경우에는 이유와 남은 risk를 종료 요약에 남긴다.
