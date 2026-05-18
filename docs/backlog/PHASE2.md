# PHASE2.md

Spring Boot MSA template의 Phase 2 product backlog다.
각 항목은 `docs/STATUS.md`의 Active Work로 올라가기 전까지 candidate 상태로 둔다.

AI Workflow Harness 개선 항목은 `docs/backlog/HARNESS.md`에서 관리한다.
Phase1 종료 직후 백업본은 `docs/archive/harness-refactor-20260514/PHASE2-backlog-before-refactor.md`에 보존되어 있다.

## Priority Guide

| Priority | Meaning |
| --- | --- |
| P0 | 넓은 Phase 2 구현 전에 반드시 결정하거나 처리해야 하는 항목 |
| P1 | 가치가 높거나 risk를 줄이는 핵심 구현 항목 |
| P2 | 중요하지만 Phase 2 첫 pass 이후 진행해도 되는 항목 |
| P3 | 선택적, 탐색적, 또는 후순위 항목 |

## Backlog

| ID | Priority | Status | Task | Dependencies | Done Criteria | Verification |
| --- | --- | --- | --- | --- | --- | --- |
| P2-001 | P0 | Candidate | token storage 전략 재검토: localStorage vs HttpOnly Cookie | 현재 auth/frontend flow | 선택한 전략의 XSS/CSRF trade-off와 migration scope가 decision으로 기록됨 | Decision review; targeted auth/frontend test plan |
| P2-002 | P0 | Candidate | proxy/ingress 환경을 고려한 rate limiting client IP 전략 수정 | Gateway rate limiter | trusted proxy policy가 있고 `X-Forwarded-For` parsing과 spoofing 방어가 검증됨 | Gateway unit/integration tests |
| P2-003 | P0 | Candidate | Redis refresh-token session index 개선 | 기존 `TokenRedisRepository` | SCAN 기반 invalidation을 per-user session set 또는 승인된 대안으로 대체 | Repository tests; logout-all scenario |
| P2-004 | P1 | Candidate | K8s 배포 도구 선택: Helm vs Kustomize | Deployment target assumptions | dev/stg/prd overlay 전략을 포함한 decision record 작성 | Manifest dry-run plan |
| P2-005 | P1 | Candidate | K8s manifests와 NetworkPolicy baseline 추가 | P2-004 | Gateway-to-service traffic은 허용되고 의도하지 않은 service access는 차단됨 | Kustomize/Helm render check; policy review |
| P2-006 | P1 | Done | Testcontainers 도입 — 통합 테스트 자급자족화 (DR-010) | DR-010 Accepted | auth/user/todo-service의 @SpringBootTest가 Testcontainers로 전환됨, ci.yml services 블록 제거 가능 | `./gradlew test` (docker compose 없이) 통과 |
| P2-007 | P1 | Candidate | Prometheus/Grafana observability baseline 추가 | Service metrics endpoints | metric naming convention과 기본 dashboard baseline 작성 | Metrics endpoint check; dashboard provisioning review |
| P2-008 | P2 | Candidate | Caffeine + Redis cache strategy 활성화 | Cache policy decision | TTL, invalidation, Pod-scope constraints가 문서화되고 안전한 cache만 활성화됨 | Cache tests; stale-data scenario review |
| P2-009 | P2 | Candidate | Resilience4j 기반 service-to-service resilience 추가 | 실제 inter-service RestClient calls | call이 존재하는 곳에 circuit breaker policy 적용 | Failure-path tests |
| P2-010 | P2 | Candidate | PostgreSQL을 service별로 분리 | Data ownership decision | DB-per-service migration plan과 connection settings 작성 | Migration dry run; service tests |
| P2-011 | P2 | Candidate | distributed transaction strategy 결정 | P2-010 | Saga 또는 Outbox 전략이 example flow와 함께 결정됨 | Decision review |
| P2-012 | P2 | Candidate | internal service authentication 추가 | Gateway/service trust model | service account token 또는 승인된 대안 구현 | Auth integration tests |
| P2-013 | P3 | Candidate | resource/action 기반 RBAC 추가 | 현재 role model | permission model과 migration path 정의 | Authorization tests |
| P2-014 | P3 | Candidate | multi-device session management UI 추가 | P2-003 | UI에서 session list 조회와 revoke가 안전하게 가능 | Frontend/manual flow test |
| P2-015 | P3 | Candidate | message queue 도입 검토 | Event-driven use case | Kafka/RabbitMQ decision 기록 또는 보류 결정 | Decision review |
| P2-016 | P1 | Candidate | JWT secret 최소 길이 검증 + `signingKey()` 캐싱 | — | `JwtProperties`에 `@Size(min=32)` 검증 추가, `JwtTokenProvider`에 SecretKey 필드 캐싱 | unit test 통과, 짧은 secret 거부 확인 |
| P2-017 | P1 | Candidate | CSP 헤더 추가 및 `X-XSS-Protection` 제거 | SecurityHeadersFilter | `Content-Security-Policy` 정책 정의 및 SecurityHeadersFilter 추가, deprecated `X-XSS-Protection` 제거 | security header 검증 |
| P2-018 | P1 | Candidate | Actuator `show-details` prd 제한 | application-prd.yml | prd profile에서 `show-details: when-authorized` 또는 `never` 적용 | prd health endpoint 응답 확인 |
| P2-019 | P1 | Candidate | HTTP 요청 액세스 로그 구현 (method/path/status/duration) | common-core MdcFilter | 각 서비스에 AccessLogFilter 추가, correlation ID 포함 | 로그 출력 및 포맷 확인 |
| P2-020 | P1 | Candidate | Micrometer tracing exporter 구성 (Zipkin 또는 OTLP) | micrometer-tracing-bridge-brave | stg/prd application.yml에 exporter 설정 추가 | stg에서 trace 수집 확인 |
| P2-021 | P2 | Candidate | 오류 응답 포맷 통일 — `ErrorResponse` → `ApiResponse` 통합 | GlobalExceptionHandler | `MethodArgumentNotValidException` 등 모든 오류가 동일 포맷 반환 | 오류 시나리오별 응답 포맷 검증 |
| P2-022 | P2 | Candidate | SecurityHeadersFilter에 `Referrer-Policy`, `Permissions-Policy` 추가 | P2-017 | 두 헤더 모든 환경 응답에 포함 | header 검증 |
| P2-023 | P2 | Candidate | Gateway 자체 로그 MDC 구현 (`Hooks.onEachOperator`) | MdcGatewayFilter | WebFlux tracing context → MDC 자동 주입, gateway 로그에 correlationId 포함 | gateway 로그 correlationId 확인 |
| P2-024 | P2 | Candidate | Gateway retry filter 구성 | Spring Cloud Gateway | 502/503 응답 시 retry 정책 정의 및 적용 | retry 동작 확인 |
| P2-025 | P2 | Candidate | JaCoCo 커버리지 측정 추가 | — | `./gradlew test jacocoTestReport` 성공, 모듈별 리포트 생성 | 커버리지 리포트 확인 |
| P2-026 | P2 | Candidate | Gateway 필터 체인 통합 테스트 | — | JwtAuth + RateLimit + UserContext 시나리오 통합 테스트 추가 | `./gradlew test` 통과 |
| P2-027 | P2 | Candidate | `OpenApiConfig` 중복 제거 — common-core 공통 추출 | — | 4개 서비스 개별 OpenApiConfig 제거, common-core에 공통 base 추출 | swagger-ui 정상 동작 |
| P2-028 | P2 | Candidate | docker-compose 서비스 health check 강화 (`service_healthy`) | — | gateway의 서비스 의존 조건을 `service_started` → `service_healthy`로 전환, 서비스별 `/actuator/health` healthcheck 정의 | `docker compose up` 후 라우팅 안정성 확인 |

## Phase 2 Preparation Candidates

| ID | Priority | Status | Task | Dependencies | Done Criteria | Verification |
| --- | --- | --- | --- | --- | --- | --- |
| PRE-B | P0 | Candidate | 개발환경 전략 결정 (로컬 실행 구조, Windows 지원, devcontainer, mono-repo) | Phase2 execution assumptions | B-1~B-4 결정 사항이 decision record 또는 planning 문서에 반영됨 | 결정 문서 리뷰 |
| PRE-C1 | P0 | Active | Phase 1 아키텍처 현황 분석 + 실무 완성도 갭 발굴 | Phase1 implementation | 분석 결과와 개선 필요 항목 목록 작성 | backlog 또는 planning 문서 반영 확인 |
| PRE-C2 | P0 | Candidate | Phase 2 요건 정의 확정 | PRE-B, PRE-C1, relevant DRs | backlog PHASE2.md 업데이트, security-first 우선순위 재검토 완료 | backlog + decision review |
| PRE-C3 | P1 | Candidate | Dockerfile 개선 (Gradle 캐시 레이어, JAVA_OPTS 외부화, HEALTHCHECK) | Dockerfile strategy review | 각 서비스 Dockerfile 개선 적용, 재빌드 성공 | `make rebuild` 후 서비스 정상 기동 |

## Recommended Start Order

> Phase2 본격 착수 전에는 `Phase 2 Preparation Candidates` (PRE-B, PRE-C1, PRE-C2)를 먼저 완료한다.
> 아래 순서는 PRE-C1 분석(2026-05-18) 기준으로 전체 backlog 항목을 의존성·위험도·테마 기준으로 통합한 것이다.

### Wave 0 — Phase 2 Preparation (착수 전 완료)

| 항목 | 이유 |
|---|---|
| PRE-B | 개발환경 구조 미결정 시 Wave 1 이후 설정 충돌 가능 |
| PRE-C1 | *(Active — 본 분석)* |
| PRE-C2 | PRE-B + PRE-C1 결과로 요건 확정 후 backlog 재정렬 |

### Wave 1 — Security Hardening (P0/P1 즉시)

보안 결함은 이후 모든 기능 위에 쌓이므로 가장 먼저 처리한다.

| 항목 | 내용 | 비고 |
|---|---|---|
| P2-016 | JWT secret 검증 + signingKey 캐싱 | 코드 1~2줄, 위험도 높음 |
| P2-018 | Actuator `show-details` prd 제한 | yml 1줄 수정 |
| P2-017 | CSP 헤더 추가 + `X-XSS-Protection` 제거 | SecurityHeadersFilter |
| P2-022 | Referrer-Policy, Permissions-Policy 추가 | P2-017 후속 |
| P2-002 | Rate limit IP 전략 수정 (X-Forwarded-For) | P0, Gateway |
| P2-001 | Token storage 전략 결정 (localStorage vs HttpOnly Cookie) | P0, decision |
| P2-003 | Redis refresh-token session index 개선 | P0, TokenRedisRepository |

### Wave 2 — Observability Baseline (P1)

운영 가시성이 없으면 Wave 3 이후 문제를 발견하기 어렵다.

| 항목 | 내용 | 비고 |
|---|---|---|
| P2-019 | HTTP 요청 액세스 로그 (method/path/status/duration) | common-core |
| P2-007 | Prometheus/Grafana observability baseline | micrometer-registry-prometheus 추가 |
| P2-020 | Micrometer tracing exporter (Zipkin/OTLP) | Brave bridge 이미 포함 |
| P2-023 | Gateway 자체 로그 MDC (`Hooks.onEachOperator`) | WebFlux-safe MDC |

### Wave 3 — Dev & Deploy Foundation (P1/P2)

K8s 배포 기반과 컨테이너 품질을 확보한다.

| 항목 | 내용 | 비고 |
|---|---|---|
| PRE-C3 | Dockerfile 개선 (캐시 레이어, non-root user) | G-DEV-001/002 |
| P2-028 | docker-compose 서비스 health check 강화 | service_healthy 전환 |
| P2-004 | K8s 배포 도구 결정 (Helm vs Kustomize) | decision, P2-005 선행 |
| P2-005 | K8s manifests + NetworkPolicy baseline | P2-004 이후, Header Spoofing 방어 완성 |

### Wave 4 — Quality & Resilience (P2)

테스트 품질과 장애 대응력을 높인다.

| 항목 | 내용 | 비고 |
|---|---|---|
| P2-025 | JaCoCo 커버리지 측정 | G-TEST-001 |
| P2-026 | Gateway 필터 체인 통합 테스트 | G-TEST-002 |
| P2-024 | Gateway retry filter 구성 | 502/503 대응 |
| P2-009 | Resilience4j circuit breaker | inter-service 호출 존재 시 |
| P2-008 | Caffeine + Redis cache strategy | Caffeine 의존성 이미 포함 |

### Wave 5 — Code Quality & Structural Cleanup (P2)

기능 구현 안정화 후 구조적 품질을 높인다.

| 항목 | 내용 | 비고 |
|---|---|---|
| P2-021 | 오류 응답 포맷 통일 (ApiResponse 단일화) | G-ARCH-001 |
| P2-027 | OpenApiConfig 중복 제거 (common-core 통합) | G-DEV-003 |
| P2-012 | Internal service authentication | P2-005 NetworkPolicy 이후 |

### Wave 6 — Architecture Evolution (P2/P3)

DB 분리, 분산 트랜잭션 등 큰 구조 변경은 Wave 1~5 안정화 후 진행한다.

| 항목 | 내용 | 비고 |
|---|---|---|
| P2-010 | PostgreSQL DB-per-service 분리 | data ownership decision 필요 |
| P2-011 | Distributed transaction strategy (Saga/Outbox) | P2-010 이후 |
| P2-013 | RBAC (resource/action 기반) | P3 |
| P2-014 | Multi-device session management UI | P2-003 이후, P3 |
| P2-015 | Message queue 도입 검토 | async use case 확정 후, P3 |

## Deferred Decisions

| Topic | Current State | Next Decision Point |
| --- | --- | --- |
| Helm vs Kustomize | Open | P2-005 구현 전 |
| Saga vs Outbox | Open | P2-011 구현 전 |
| Kafka vs RabbitMQ | Open | 구체적인 async use case가 생겼을 때 |
| Complex RBAC | Open | core Phase 2 security hardening 이후 |
