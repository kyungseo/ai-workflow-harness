# PLAN-SUMMARY.md — base-msa-template

> 전체 기술 근거는 `docs/PLAN.md` 참조. 이 파일은 세션 컨텍스트용 요약이다.

## 기술 스택

| 구분 | 기술 |
|------|------|
| Runtime | JDK 21 (Virtual Threads 활성화) |
| Framework | Spring Boot 3.5.x |
| Build | Gradle 8.x (Kotlin DSL, libs.versions.toml) |
| Gateway | Spring Cloud Gateway (WebFlux) 2025.0.0 |
| Security | Spring Security 6.5 + JJWT 0.12.x |
| Token Store | Redis (Refresh Token, Blacklist, Rate Limiting) |
| ORM | MyBatis 3.x (XML Mapper) |
| DB | PostgreSQL 16 (Phase 1 공유 DB) |
| Validation | spring-boot-starter-validation + Bean Validation |
| API Docs | springdoc-openapi 2.x |
| Logging | SLF4J + Logback (JSON: stg/prd, 콘솔: local/dev) |
| Tracing | Micrometer Tracing + MDC (X-Correlation-ID) |
| Infra | Docker Compose (로컬), K8s (Phase 2) |
| CI | GitHub Actions — lint (Checkstyle) → test 체인, `.github/workflows/ci.yml` |
| Code Quality | Checkstyle 10.21.0, Google Java Style + LineLength=120/Indentation=4 오버라이드 |
| Test | Testcontainers — DR-010 Accepted, P2-006에서 실제 활성화 예정 (CI interim: GitHub Actions services 블록) |

## 서비스 포트

| 서비스 | 포트 |
|--------|------|
| api-gateway | 8090 |
| auth-service | 8091 |
| user-service | 8092 |
| todo-service | 8093 |
| PostgreSQL | 5432 |
| Redis | 6379 |
| Actuator (관리 포트) | 8099 |
| Frontend | 3000 |

서비스 디스커버리: Eureka 미사용. 로컬은 localhost URL, K8s는 서비스 DNS.

## 핵심 아키텍처 결정

- **패키지**: `io.kyungseo.msa`
- **DB**: Phase 1은 공유 PostgreSQL. DB per Service는 Phase 2 (P2-010).
- **Redis key 스키마**:
  - `rt:{userId}:{deviceId}` — Refresh Token (TTL 7일)
  - `bl:{jti}` — Access Token Blacklist (TTL = 잔여 만료시간)
  - `rl:{userId}` — Rate Limiting
- **Gateway 필터 체인 순서**: -5 (Correlation ID) → -4 (JWT 검증) → -3 (Security Header) → -1 (MDC)
- **인증 흐름**: Gateway에서 JWT 검증 → 서비스에 `X-User-Id`, `X-User-Role` 헤더 전달
- **Error Code**: `COMMON-XXXX`, `AUTH-XXXX`, `USER-XXXX`, `TODO-XXXX` 형식 (ErrorCode interface)

## Phase 1 완료 요약

- Gradle 멀티 모듈 구조 (common-core, auth/user/todo-service, api-gateway)
- JWT 발급/갱신/블랙리스트 + Refresh Token 로테이션
- Gateway Rate Limiting + Security Headers + CORS
- MyBatis 기반 CRUD (user, todo) + RBAC (ROLE_ADMIN / ROLE_USER)
- Docker Compose 로컬 통합 실행 + Vanilla JS 프론트엔드

## Phase 2 전략적 방향

1. **Security hardening first** (P0): token storage, rate limiting IP, Redis session index — DR-003 참조
2. **Deployment foundation** (P1): K8s manifests, CI/CD — DR-002 결정 후 착수
3. **Operations & resilience** (P1-P2): Prometheus/Grafana, Resilience4j, Caffeine cache

## 활성 참조 문서

| 목적 | 파일 |
|------|------|
| 현재 작업 상태 | `docs/STATUS.md` |
| Phase 2 backlog | `docs/backlog/PHASE2.md` |
| 의사결정 기록 | `docs/decisions/DR-001~010.md` |
| 코드 컨벤션 SSOT | `docs/CODING-CONVENTIONS.md` |
| 전체 기술 근거 | `docs/PLAN.md` (688줄, 필요시만 로드) |
