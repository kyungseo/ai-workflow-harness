# 06. Recovery and Validation

이 문서는 recovery와 validation 규칙의 canonical source다.

## Failure Conditions

- STATUS 불일치를 보고하지 않음
- 사용자 승인 없이 `docs/STATUS.md` 수정
- 승인 없이 구현
- 검증 실패 상태로 checkpoint 생성
- 작업 범위가 승인된 plan 밖으로 확장
- 동일 오류 2회 반복
- context limit 또는 정보 부족 상태에서 추측 진행
- `Done` 작업을 신규 작업 분리 없이 계속 수정
- 사용자 승인 없이 Work 파일을 `Archived`로 이동

## Recovery Flow

```text
FAIL -> report -> options -> user decision -> PLAN
```

Report includes:

- Failure type
- Root cause
- Affected files/state
- Recovery options
- Recommended path

## Validation Checklist

- 변경 파일이 plan 범위 안에 있는가
- 가장 좁은 검증을 실행했는가
- 검증을 못 했다면 이유를 기록했는가
- Work 파일 checkpoint/discovery 변경을 대상 Work ID와 함께 보고했는가
- Work 파일 Done 처리 또는 archive 이동에 사용자 확인이 있었는가
- `STATUS.md` 갱신이 필요한가
- `STATUS.md` 갱신이 필요하면 Approval Matrix에 맞는 제안과 사용자 승인이 있었는가
- DR/Work 파일/archive/cascade가 필요한가
- 다음 세션이 `STATUS.md`만 보고 재개 가능한가

## Approval Matrix State Detail

상태 변경이 필요하면 Approval Matrix의 상태 변경 규칙을 적용한다.

| 변경 대상 | 변경 유형 | Gate |
| --- | --- | --- |
| Work 파일 | Checkpoint 상태 업데이트, Discovery 추가 | 승인 불필요. 실행 후 대상 Work ID와 변경 내용을 보고 |
| Work 파일 | Done Criteria 전체 충족 확인, `status: Done`, `actual_end` 기입 | 대상 Work ID를 명시하고 사용자 확인 후 처리 |
| `docs/STATUS.md` | Active Work pointer 추가/제거 | 대상 Work ID를 명시한 1줄 제안 후 승인 |
| `docs/STATUS.md` | Phase completion criteria, Current phase/focus, Recent Decisions | `STATUS Update Proposal` 승인 후 처리 |

`docs/STATUS.md`의 고영향 변경이 필요하면 파일을 수정하기 전에 아래 항목을 먼저 보고한다.

- 변경 섹션
- 변경 이유
- 변경 후 상태
- 되돌리기 비용
- 승인 요청

승인 전에는 `docs/STATUS.md`를 수정하지 않는다.

## Commit Approval

Commit 전:

1. `git status`
2. `git add <files>`
3. `git status`
4. `git diff --cached`

`VALIDATE` 실패 상태에서는 commit하지 않는다.
Commit 전 승인은 risk level과 무관하게 항상 별도로 받는다.

L3 이상 작업은 논리 단계별 commit을 기본값으로 한다.

- 한 commit은 하나의 검증 가능한 목적을 담는다.
- 대형 문서·하네스 변경은 상태판, backlog, command/rule, protocol, prompt 같은 변경 축을 가능한 한 분리한다.
- rollback plan은 파일 복구뿐 아니라 어떤 commit 또는 단계까지 되돌릴 수 있는지 설명한다.
- 여러 축을 하나의 commit에 묶어야 한다면 이유와 부분 rollback 비용을 종료 요약에 남긴다.
