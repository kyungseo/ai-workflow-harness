---
name: "source-command-debug"
description: "지정 대상의 원인을 코드/로그 근거로 좁히고 최소 변경 계획을 보고한다"
---

# source-command-debug

Use this skill when the user asks to run the migrated source command `debug`.

## Command Template

docs/STATUS.md를 확인해줘.

작업 대상: $ARGUMENTS

먼저 현재 상태 머신 단계를 `INIT`으로 선언하고, 디버깅 작업의 위험도를 판단해줘.

먼저 관련 코드와 테스트를 읽고,
추측이 아니라 실제 코드/로그/테스트 근거로 원인 또는 개선 지점을 좁혀줘.

그다음 아래 항목을 포함한 최소 변경 계획을 보고해줘.

1. 현재 상태 머신 단계와 다음 전이 조건
2. 위험도: L1 / L2 / L3
3. 확인한 근거 파일, 로그, 테스트
4. 원인 후보와 배제한 가정
5. 변경 예정 파일
6. 검증 방법
7. 리스크와 되돌리기 비용
8. docs/STATUS.md 반영 필요 여부

승인 전에는 수정하지 마.

검증 실패 또는 같은 오류 2회 반복 시 `FAIL -> RECOVER -> PLAN`으로 전환해줘.

docs/STATUS.md 변경이 필요하면 즉시 수정하지 말고 Approval Matrix state rules에 맞게 먼저 보고해줘.
사용자가 명시적으로 승인한 뒤에만 STATUS.md를 수정해줘.
