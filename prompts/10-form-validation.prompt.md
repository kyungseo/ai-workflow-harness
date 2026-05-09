---
name: form-validation
description: 폼 검증 추가
agent: agent
id: form-validation.v1
purpose: 폼 입력 검증 규칙 및 메시지를 추가하기 위한 프롬프트
portability: generic
difficulty: beginner
inputs:
  - form_fields
output_contract:
  - 계획
  - 변경
  - 검증
  - 리스크
---


이 폼에 검증 로직을 추가해 줘.

필수 항목:

- 이메일
- 비밀번호
- 필수값
- 사용자 친화적 에러 메시지

출력 형식:

1. 검증 규칙
2. 코드
3. 에러 메시지 예시
