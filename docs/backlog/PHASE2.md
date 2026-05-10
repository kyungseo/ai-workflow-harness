# PHASE2.md

Phase 2 backlog for the Spring Boot MSA template.
Items are candidates until moved into `docs/STATUS.md` Active Work.

## Priority Guide

| Priority | Meaning |
| --- | --- |
| P0 | Must resolve before broad Phase 2 implementation |
| P1 | High-value or risk-reducing implementation work |
| P2 | Important but can follow the first Phase 2 pass |
| P3 | Optional, exploratory, or later-stage work |

## Backlog

| ID | Priority | Status | Task | Dependencies | Done Criteria | Verification |
| --- | --- | --- | --- | --- | --- | --- |
| P2-001 | P0 | Candidate | Review token storage strategy: localStorage vs HttpOnly Cookie | Current auth/frontend flow | Decision recorded; selected strategy has XSS/CSRF trade-off and migration scope | Decision review; targeted auth/frontend test plan |
| P2-002 | P0 | Candidate | Fix rate limiting client IP strategy for proxy/ingress environments | Gateway rate limiter | Trusted proxy policy exists; `X-Forwarded-For` parsing is validated; spoofing risk addressed | Gateway unit/integration tests |
| P2-003 | P0 | Candidate | Improve Redis refresh-token session index | Existing `TokenRedisRepository` | Replace SCAN-dependent invalidation with per-user session set or approved alternative | Repository tests; logout-all scenario |
| P2-004 | P1 | Candidate | Select K8s deployment tool: Helm vs Kustomize | Deployment target assumptions | Decision record exists; chosen tool has dev/stg/prd overlay strategy | Manifest dry-run plan |
| P2-005 | P1 | Candidate | Add K8s manifests and NetworkPolicy baseline | P2-004 | Gateway-to-service traffic is allowed; unintended service access is denied | Kustomize/Helm render check; policy review |
| P2-006 | P1 | Candidate | Add CI/CD pipeline with automated tests | Stable Gradle/test commands | GitHub Actions pipeline builds and runs tests; failure signals are clear | CI run or local action equivalent |
| P2-007 | P1 | Candidate | Add observability baseline with Prometheus and Grafana | Service metrics endpoints | Metric naming convention and dashboard baseline exist | Metrics endpoint check; dashboard provisioning review |
| P2-008 | P2 | Candidate | Enable Caffeine + Redis cache strategy | Cache policy decision | TTL, invalidation, and Pod-scope constraints documented; safe caches enabled | Cache tests; stale-data scenario review |
| P2-009 | P2 | Candidate | Add service-to-service resilience with Resilience4j | Real inter-service RestClient calls | Circuit breaker policy exists where calls exist | Failure-path tests |
| P2-010 | P2 | Candidate | Split PostgreSQL by service | Data ownership decision | DB-per-service migration plan and connection settings exist | Migration dry run; service tests |
| P2-011 | P2 | Candidate | Decide distributed transaction strategy | P2-010 | Saga or Outbox strategy selected with example flow | Decision review |
| P2-012 | P2 | Candidate | Add internal service authentication | Gateway/service trust model | Service account token or approved alternative implemented | Auth integration tests |
| P2-013 | P3 | Candidate | Add resource/action based RBAC | Current role model | Permission model and migration path defined | Authorization tests |
| P2-014 | P3 | Candidate | Add multi-device session management UI | P2-003 | UI can list and revoke sessions safely | Frontend/manual flow test |
| P2-015 | P3 | Candidate | Evaluate message queue adoption | Event-driven use case | Kafka/RabbitMQ decision recorded or deferred | Decision review |

## Recommended Start Order

1. P2-001, P2-002, P2-003: security and production correctness.
2. P2-004, P2-005, P2-006: deployment and delivery foundation.
3. P2-007, P2-008, P2-009: operations and resilience.
4. P2-010 and later: larger architecture evolution.

## Deferred Decisions

| Topic | Current State | Next Decision Point |
| --- | --- | --- |
| Helm vs Kustomize | Open | Before P2-005 |
| Saga vs Outbox | Open | Before P2-011 implementation |
| Kafka vs RabbitMQ | Open | When a concrete async use case exists |
| Complex RBAC | Open | After core Phase 2 security hardening |
