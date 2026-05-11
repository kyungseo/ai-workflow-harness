# DR-003: Phase 2 착수 순서 — Security Hardening vs Infrastructure Expansion

Date: 2026-05-11
Status: Accepted

## Question

Phase 2는 infrastructure 확장(K8s, CI/CD)보다 security hardening(token storage, rate limiting, Redis session)을 먼저 해야 하는가?

## Decision

Security Hardening 우선. P2-001 → P2-002 → P2-003 → P2-004 순서로 진행.

## Options Considered

| 선택지 | 장점 | 단점 |
|--------|------|------|
| **Security first** (P2-001~003) | 프로덕션 배포 전 보안 결함 해소, 이후 인프라 작업이 더 안전한 기반 위에서 진행 | K8s 구조 결정이 늦어짐 |
| **Infrastructure first** (P2-004~006) | 배포 환경 확정 후 보안 전략 결정 가능 | 보안 미결 상태로 인프라 확장, 위험 누적 |

## Rationale

P2-001(token storage), P2-002(rate limiting IP), P2-003(Redis session)은 모두 P0 항목이다.
현재 프로덕션에서 실제 노출 위험이 있는 결함들이므로 인프라 확장보다 선행되어야 한다.

## Consequences

P2-004 이후 항목은 P2-001~003 완료 후 착수. OQ-001 → Closed.

## Reversal Cost

Low — 착수 순서 변경은 backlog 우선순위 조정만으로 가능.

## Linked Backlog Items

- P2-001, P2-002, P2-003 (P0 security items)
- P2-004, P2-005, P2-006 (P1 infrastructure items)
