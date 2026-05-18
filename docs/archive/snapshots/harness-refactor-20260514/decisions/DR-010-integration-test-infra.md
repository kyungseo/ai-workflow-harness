# DR-010: 통합 테스트 인프라 전략 — Testcontainers 채택

Date: 2026-05-12
Status: Accepted

## Question

`@SpringBootTest` 통합 테스트에서 PostgreSQL, Redis 등 외부 서비스를 어떻게 제공할 것인가?

## Decision

**목표**: Testcontainers(`@Testcontainers`, `@Container`, `@ServiceConnection`) 채택.

**현재(interim)**: GitHub Actions `services:` 블록 + `spring.sql.init`으로 임시 운영.
CI 실패 긴급 수정 목적으로 도입했으며, Testcontainers 전환 완료 후 제거한다.

전환 대상 서비스: auth-service (PostgreSQL + Redis), user-service (PostgreSQL), todo-service (PostgreSQL).

## Options Considered

| 선택지 | 장점 | 단점 |
|--------|------|------|
| GitHub Actions services + spring.sql.init (현재 interim) | 테스트 코드 변경 없음, 즉시 적용 | 로컬 실행에 docker compose 선행 필요, 신규 서비스마다 ci.yml 수정 필요 |
| Testcontainers (채택) | 테스트 자급자족, CI workflow 독립, 로컬 선행 조건 없음 | 컨테이너 기동 시간 추가, 어노테이션 추가 필요 |
| H2 in-memory DB | 빠름, 외부 의존성 없음 | PostgreSQL 방언 차이로 실제 쿼리 검증 불가, Redis 대체 불가 |
| 외부 Docker Compose 의존 (기존) | 설정 단순 | CI 환경에서 동작 불가 |

## Rationale

- 템플릿 프로젝트로서 Spring Boot 통합 테스트 best practice를 제시해야 한다.
- Testcontainers는 테스트를 완전히 자급자족(self-contained)하게 만들어 환경 의존성을 제거한다.
- `tc-postgresql`, `tc-junit`, `tc-spring` 의존성이 이미 모든 서비스 build.gradle에 선언되어 있다 — 준비 상태.
- 전환 후 ci.yml의 `services:` 블록과 `application-test.yml`의 `spring.sql.init`을 제거할 수 있다.

## Migration Path

1. auth-service: `@Testcontainers` + `PostgreSQLContainer` + `GenericContainer`(Redis) + `@ServiceConnection`
2. user-service: `@Testcontainers` + `PostgreSQLContainer` + `@ServiceConnection`
3. todo-service: `@Testcontainers` + `PostgreSQLContainer` + `@ServiceConnection`
4. `application-test.yml`에서 datasource/redis localhost 하드코딩 제거
5. `ci.yml`에서 `services:` 블록 및 관련 health-check 옵션 제거

## Consequences

- 로컬에서 `docker compose up` 없이 `./gradlew test`만으로 통합 테스트 실행 가능
- 신규 서비스 추가 시 ci.yml 수정 불필요
- 테스트 클래스별 컨테이너 기동으로 초기 실행 시간 다소 증가 (static container 패턴으로 완화 가능)

## Reversal Cost

Medium — 어노테이션 제거 + application-test.yml 복구 + ci.yml services 복원 필요.

## Linked Items

- P2-006: Testcontainers 도입 (구현 작업)
- DR-009: CI trigger 분리 전략
- `.claude/rules/testing.md`: `@Testcontainers` 사용 금지 조건 — 이 DR Accepted로 해제됨
