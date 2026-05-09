---
name: reproduce-and-fix
description: 버그 재현 및 수정
agent: agent
id: reproduce-and-fix.v1
purpose: 버그를 재현한 뒤 원인 수정까지 수행하기 위한 프롬프트
portability: generic
difficulty: advanced
inputs:
  - bug_description
  - environment
output_contract:
  - 계획
  - 변경
  - 검증
  - 리스크
---


이 버그를 재현하고 수정해 줘.

버그 설명:
{{bug_description}}

요구사항:

- 재현 절차 먼저 정리
- 최소 수정으로 해결
- 가능하면 테스트 추가

출력 형식:

1. 재현 절차
2. 원인
3. 수정 코드
4. 테스트
