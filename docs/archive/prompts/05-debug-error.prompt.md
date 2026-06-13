---
name: debug-error
description: 에러 분석 및 수정
agent: agent
id: debug-error.v1
purpose: 에러의 원인을 분석하고 수정하기 위한 프롬프트
portability: generic
difficulty: intermediate
inputs:
  - error_log
  - repro_steps
output_contract:
  - 계획
  - 변경
  - 검증
  - 리스크
---


아래 에러 로그를 분석하고 수정해 줘.

에러:
{{error_log}}

제약:

- **Minimal patch only.** 에러 원인이 되는 부분만 수정.
- 리팩토링 금지.
- 구조 변경 금지.
- 관련 없는 코드 변경 금지.

요구사항:

- 원인 후보 3개 제시
- 가장 가능성 높은 원인부터 설명
- 확인 방법 포함
- 수정 코드는 변경된 부분만 출력

출력 형식:

1. 원인 후보 (가능성 순)
2. 재현 방법
3. 수정안 (변경 부분만)
4. 추가 확인 사항
