---
name: migrate-ts
description: JavaScript에서 TypeScript로 마이그레이션
agent: agent
id: migrate-ts.v1
purpose: JavaScript 코드를 TypeScript로 단계적 이전하기 위한 프롬프트
portability: generic
difficulty: advanced
inputs:
  - target_scope
output_contract:
  - 계획
  - 변경
  - 검증
  - 리스크
---


이 코드를 JavaScript에서 TypeScript로 옮겨 줘.

요구사항:

- 타입은 느슨하지 않게
- 빌드 깨짐 방지
- 단계적으로 수정
- 관련 타입 정의도 함께 추가

출력 형식:

1. 마이그레이션 계획
2. 수정 코드
3. 타입 설계
