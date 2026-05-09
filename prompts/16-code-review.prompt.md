---
name: code-review
description: 코드 리뷰
agent: agent
id: code-review.v1
purpose: 변경사항의 결함/리스크를 검토하기 위한 프롬프트
portability: generic
difficulty: intermediate
inputs:
  - diff_or_scope
output_contract:
  - 계획
  - 변경
  - 검증
  - 리스크
---


이 변경사항을 시니어 개발자 관점에서 리뷰해 줘.

관점:

- 버그 가능성
- 보안
- 유지보수성
- 성능

출력 형식:

1. 주요 지적 사항
2. 심각도
3. 수정 제안
