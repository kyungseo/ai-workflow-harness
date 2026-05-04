# PHASE2-BACKLOG.md — Phase 2 백로그

> Phase 1 완료 후 착수.
> Claude Code 작업 시 이 파일은 Phase 1 진행 중 참조 불필요.

---

## Phase 2 태스크

- [ ] Circuit Breaker (Resilience4j) — 서비스 간 RestClient 호출 발생 시
- [ ] 서비스별 PostgreSQL 분리 (DB per Service) — Phase 1 FK 미사용 설계 기반으로 전환
- [ ] **분산 트랜잭션 전략 수립** — Saga 패턴 또는 Outbox 패턴
- [ ] Prometheus + Grafana 연결 및 대시보드 구성
  - metric naming convention 정의
  - 기본 대시보드 구조 (p95 latency, error rate)
- [ ] K8s 매니페스트 작성 (Kustomize, overlays: dev/stg/prd)
- [ ] **K8s NetworkPolicy 적용** — Gateway → Service 직접 통신만 허용
- [ ] **CI/CD 파이프라인 (GitHub Actions) + RestAssured 기반 자동화 테스트 연동**
- [ ] 복잡 RBAC (리소스+액션 기반 퍼미션)
- [ ] 서비스 간 내부 인증 전략 수립 (서비스 계정 JWT 등)
- [ ] 멀티 디바이스 세션 관리 UI 추가
- [ ] K8s 배포 도구 결정 (Helm vs Kustomize)
- [ ] 메시지 큐 도입 검토 (Kafka / RabbitMQ)
- [ ] **Redis Refresh Token — SCAN → Set 구조 전환** (성능 개선)
  - 현재: `rt:{userId}:{deviceId}` 개별 키 + 전체 세션 무효화 시 `rt:{userId}:*` SCAN
  - 개선: `rt:sessions:{userId}` Set에 deviceId 목록 관리 → 전체 삭제 `DEL rt:sessions:{userId}` 1회
  - 전환 시 auth-service `TokenRedisRepository` 및 ARCHITECTURE.md §8/§16 동시 업데이트 필요
- [ ] **Rate Limiting — X-Forwarded-For 처리 (Proxy/Ingress 환경 대응)**
  - 현재: `remoteAddr` 기준 IP → Reverse Proxy 경유 시 모든 요청이 Proxy IP로 집계되어 Rate Limiting 무력화
  - 개선: `X-Forwarded-For` 첫 번째 값 추출 + Trusted Proxy CIDR 검증 로직 추가
- [ ] **토큰 저장소 전략 재검토 — HttpOnly Cookie vs localStorage**
  - 현재(Phase 1): Frontend localStorage 기반 (XSS에 취약)
  - 대안: HttpOnly Cookie (XSS 방어, CSRF 위협 → SameSite=Strict 또는 CSRF 토큰 병행 필요)
  - 전환 시 auth-service 응답 방식 변경(Set-Cookie) + Frontend auth.js 전면 수정 필요

---

## 미결 사항 (결정 보류)

| 항목 | 내용 |
|------|------|
| K8s 배포 도구 | Helm vs Kustomize → Phase 2에서 결정 |
| 복잡 RBAC | 리소스+액션 기반 퍼미션 → Phase 2에서 결정 |
| 메시지 큐 | Kafka / RabbitMQ 도입 여부 → Phase 2에서 결정 |
| 서비스 간 인증 | 내부 호출 시 토큰 전략 → Phase 2에서 결정 |
| 분산 트랜잭션 | Saga vs Outbox 패턴 선택 → Phase 2에서 결정 |
