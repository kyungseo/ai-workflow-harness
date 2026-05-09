---
name: refactor-code
description: 가독성 리팩터링
agent: agent
id: refactor-code.v1
purpose: 동작을 유지하며 코드 구조를 개선하기 위한 프롬프트
portability: generic
difficulty: intermediate
inputs:
  - target_scope
output_contract:
  - 계획
  - 변경
  - 검증
  - 리스크
---


이 코드를 리팩터링해 줘.

목표:

- 가독성 향상
- 중복 제거
- 함수명 명확화
- 기능 유지

제약:

- 동작은 바꾸지 말 것.
- 변경된 이유를 설명할 것.

출력 형식:

1. 문제점
2. 리팩터링 코드
3. 변경 요약
