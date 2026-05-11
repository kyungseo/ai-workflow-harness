# PHASE2.md

Spring Boot MSA template의 Phase 2 backlog다.
각 항목은 `docs/STATUS.md`의 Active Work로 올라가기 전까지 candidate 상태로 둔다.

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
| P2-006 | P1 | Candidate | automated tests를 포함한 CI/CD pipeline 추가 | 안정적인 Gradle/test commands | GitHub Actions pipeline이 build/test를 수행하고 failure signal이 명확함 | CI run or local action equivalent |
| P2-007 | P1 | Candidate | Prometheus/Grafana observability baseline 추가 | Service metrics endpoints | metric naming convention과 기본 dashboard baseline 작성 | Metrics endpoint check; dashboard provisioning review |
| P2-008 | P2 | Candidate | Caffeine + Redis cache strategy 활성화 | Cache policy decision | TTL, invalidation, Pod-scope constraints가 문서화되고 안전한 cache만 활성화됨 | Cache tests; stale-data scenario review |
| P2-009 | P2 | Candidate | Resilience4j 기반 service-to-service resilience 추가 | 실제 inter-service RestClient calls | call이 존재하는 곳에 circuit breaker policy 적용 | Failure-path tests |
| P2-010 | P2 | Candidate | PostgreSQL을 service별로 분리 | Data ownership decision | DB-per-service migration plan과 connection settings 작성 | Migration dry run; service tests |
| P2-011 | P2 | Candidate | distributed transaction strategy 결정 | P2-010 | Saga 또는 Outbox 전략이 example flow와 함께 결정됨 | Decision review |
| P2-012 | P2 | Candidate | internal service authentication 추가 | Gateway/service trust model | service account token 또는 승인된 대안 구현 | Auth integration tests |
| P2-013 | P3 | Candidate | resource/action 기반 RBAC 추가 | 현재 role model | permission model과 migration path 정의 | Authorization tests |
| P2-014 | P3 | Candidate | multi-device session management UI 추가 | P2-003 | UI에서 session list 조회와 revoke가 안전하게 가능 | Frontend/manual flow test |
| P2-015 | P3 | Candidate | message queue 도입 검토 | Event-driven use case | Kafka/RabbitMQ decision 기록 또는 보류 결정 | Decision review |

## Recommended Start Order

1. P2-001, P2-002, P2-003: security와 production correctness.
2. P2-004, P2-005, P2-006: deployment와 delivery foundation.
3. P2-007, P2-008, P2-009: operations와 resilience.
4. P2-010 이후: 더 큰 architecture evolution.

## Deferred Decisions

| Topic | Current State | Next Decision Point |
| --- | --- | --- |
| Helm vs Kustomize | Open | P2-005 구현 전 |
| Saga vs Outbox | Open | P2-011 구현 전 |
| Kafka vs RabbitMQ | Open | 구체적인 async use case가 생겼을 때 |
| Complex RBAC | Open | core Phase 2 security hardening 이후 |
