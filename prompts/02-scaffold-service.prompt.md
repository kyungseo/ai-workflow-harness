---
name: scaffold-service
description: create-service.sh 기반 신규 마이크로서비스 스캐폴딩
agent: agent
id: scaffold-service.v1
purpose: MSA 템플릿에 새로운 마이크로서비스를 골격부터 게이트웨이 연동까지 안전하게 추가하기 위한 프롬프트
portability: base-msa-template
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


`scripts/create-service.sh`를 기반으로 `{{service_name}}` 서비스를 추가해 줘.

서비스 정보:

- 이름: {{service_name}}
- 포트: {{port}}
- 도메인: {{domain_description}}

작업 범위:

1. `scripts/create-service.sh {{service_name}} {{port}}` 실행 계획 수립
2. `gateway/api-gateway/src/main/resources/application.yml`에 라우팅 추가
3. `infra/docker/docker-compose.yml`에 서비스 추가
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
