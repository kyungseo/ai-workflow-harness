---
name: api-integration
description: REST API 연동
agent: agent
id: api-integration.v1
purpose: 외부/내부 API를 클라이언트 코드에 연동하기 위한 프롬프트
portability: generic
difficulty: intermediate
inputs:
  - api_spec
output_contract:
  - 계획
  - 변경
  - 검증
  - 리스크
---


이 화면에 API 연동을 추가해 줘.

요구사항:

- loading / error / success 상태 처리
- 서버가 바뀌어도 쉽게 교체 가능하게 설계
- 응답 실패 시 사용자 메시지 표시

출력 형식:

1. 데이터 흐름
2. API 래퍼
3. 화면 코드
4. 예외 처리
