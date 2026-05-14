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
- `STATUS.md` 갱신이 필요한가
- `STATUS.md` 갱신이 필요하면 `STATUS Update Proposal`과 사용자 승인이 있었는가
- DR/TODO/archive/cascade가 필요한가
- 다음 세션이 `STATUS.md`만 보고 재개 가능한가

## STATUS Update Proposal

`docs/STATUS.md` 변경이 필요하면 파일을 수정하기 전에 아래 항목을 먼저 보고한다.

- 변경 섹션
- 변경 이유
- 변경 후 상태
- 되돌리기 비용
- 승인 요청

승인 전에는 `docs/STATUS.md`를 수정하지 않는다.

## Commit Gate

Commit 전:

1. `git status`
2. `git add <files>`
3. `git status`
4. `git diff --cached`

`VALIDATE` 실패 상태에서는 commit하지 않는다.
