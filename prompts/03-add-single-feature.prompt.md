---
name: add-single-feature
description: 기존 코드에 기능 하나 추가
agent: agent
id: add-single-feature.v1
purpose: 기존 코드에 단일 기능을 안전하게 추가하기 위한 프롬프트
portability: generic
difficulty: beginner
inputs:
  - feature
output_contract:
  - 계획
  - 변경
  - 검증
  - 리스크
---


현재 코드에 {{feature}} 기능만 추가해 줘.

규칙:

- 기존 동작은 유지할 것.
- 관련 없는 코드는 건드리지 말 것.
- 변경 범위는 최소화할 것.
- 완료 후 변경 이유를 설명할 것.

출력 형식:

1. 변경 계획
2. 수정 코드
3. 변경 요약
