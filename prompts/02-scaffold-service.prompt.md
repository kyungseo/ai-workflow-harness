---
name: scaffold-service
description: Spring Boot example 신규 마이크로서비스 스캐폴딩 계획
agent: agent
id: scaffold-service.v1
purpose: Spring Boot example project에서 새로운 마이크로서비스를 골격부터 gateway 연동까지 안전하게 추가하기 위한 프롬프트
portability: spring-boot-example
difficulty: intermediate
inputs:
  - service_name
  - port
  - domain_description
output_contract:
  - 계획
  - 변경
  - 검증
  - 리스크
---


현재 프로젝트의 Spring Boot service scaffold 규칙을 기준으로 `{{service_name}}` 서비스를 추가해 줘.

서비스 정보:

- 이름: {{service_name}}
- 포트: {{port}}
- 도메인: {{domain_description}}

작업 범위:

1. 현재 프로젝트의 service scaffold 방식 확인
2. gateway routing 설정에 신규 서비스 경로 추가
3. local compose 또는 runtime 설정에 서비스 추가
4. `settings.gradle.kts`에 모듈 등록
5. `tests/http/{{service_name}}.http` 기본 테스트 파일 생성

규칙:

- 기존 서비스(auth-service, user-service, todo-service) 패턴을 따를 것.
- Gateway 필터 체인 순서(-5 ~ -1)를 변경하지 말 것.
- `com.example.{{service_name}}` 패키지 기준으로 생성할 것.

출력 형식:

1. 변경 계획 (파일별)
2. 실행할 커맨드
3. 검증 방법 (`./gradlew :services:{{service_name}}:build`)
4. 리스크
