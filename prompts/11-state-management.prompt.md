---
name: state-management
description: 상태 관리 구조 정리
agent: agent
id: state-management.v1
purpose: 상태 관리 전략을 정리/개선하기 위한 프롬프트
portability: generic
difficulty: advanced
inputs:
  - current_state_flow
output_contract:
  - 계획
  - 변경
  - 검증
  - 리스크
---


이 프로젝트의 상태 관리를 정리해 줘.

분류:

- 로컬 상태
- 전역 상태
- 서버 상태

요구사항:

- 어디에 무엇을 둘지 설명
- 과도한 전역 상태는 피할 것
- 필요한 코드 수정 포함

출력 형식:

1. 상태 분류
2. 설계안
3. 코드 수정
