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

제약:

- **API contract 변경 금지.** (메서드 시그니처, 반환 타입, 예외 타입)
- **외부 동작 변경 금지.** (입출력 결과, 사이드이펙트)
- 불필요한 추상화 도입 금지.
- 변경된 이유를 설명할 것.

출력 형식:

1. 문제점 (개선 이유)
2. 리팩터링 코드
3. 변경 요약 (API contract 유지 확인 포함)
