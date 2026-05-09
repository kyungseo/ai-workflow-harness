---
name: write-tests-first
description: 테스트 우선 작성
agent: agent
id: write-tests-first.v1
purpose: 테스트를 먼저 작성하고 구현을 보완하기 위한 프롬프트
portability: generic
difficulty: intermediate
inputs:
  - target_behavior
output_contract:
  - 계획
  - 변경
  - 검증
  - 리스크
---


아래 대상에 대한 테스트를 먼저 작성해 줘.

대상:
{{target}}

요구사항:

- 정상 케이스
- 실패 케이스
- 경계값
- 읽기 쉬운 테스트 이름

출력 형식:

1. 테스트 코드
2. 최소 구현
3. 왜 이 테스트가 필요한지
