---
name: security-review
description: 코드 변경의 auth/injection/SSRF/token 보안 검토
agent: agent
id: security-review.v1
purpose: 구현 또는 변경된 코드에 보안 결함이 없는지 검토하기 위한 프롬프트
portability: spring-boot-example
difficulty: intermediate
inputs:
  - target
output_contract:
  - 발견된 위험
  - 수정 권고
  - 통과 항목
---


아래 대상의 보안 취약점을 검토해 줘.

대상: {{target}}

검토 항목:

- **SQL Injection**: MyBatis `${}` 사용 여부 (whitelist validation 없는 경우)
- **JWT 처리**: 토큰 검증 우회 가능성, 만료 처리, 블랙리스트 확인 누락
- **입력 검증**: Bean Validation 누락, 범위/형식 검증 없는 외부 입력
- **민감 정보 노출**: Access Token, Refresh Token, 비밀번호, Authorization 헤더 로깅 여부
- **SSRF**: 외부 URL을 직접 받아서 fetch하는 패턴
- **인가 누락**: `@PreAuthorize` 또는 Gateway 필터에서 ROLE 검증 누락
- **Redis 키 충돌**: `rt:`, `bl:`, `rl:` 이외 패턴 사용 여부
- **Actuator 노출**: 8099 포트 외부 노출 설정 여부

출력 형식:

1. 발견된 위험 (심각도: High/Medium/Low + 위치 + 수정 방법)
2. 통과 항목
3. 추가 확인이 필요한 항목
