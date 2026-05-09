---
name: performance-fix
description: 성능 개선
agent: agent
id: performance-fix.v1
purpose: 병목을 식별하고 성능을 개선하기 위한 프롬프트
portability: generic
difficulty: advanced
inputs:
  - symptom
  - measurement
output_contract:
  - 계획
  - 변경
  - 검증
  - 리스크
---


이 화면의 성능을 개선해 줘.

우선순위:

- 불필요한 리렌더링 제거
- 메모이제이션
- 비싼 연산 최적화

출력 형식:

1. 병목 원인
2. 개선 코드
3. 기대 효과
