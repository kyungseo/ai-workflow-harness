---
id: PRE-C1
priority: P0
status: Done
risk: Low
scope: Phase 1 아키텍처 현황 분석 + 실무 적용 가능 수준 완성도 갭 발굴 — 레이어 일관성, common-core, gateway, 보안, 관찰가능성, 복원력, 개발경험, 테스트 전략
appetite: 5d
planned_start: 2026-05-18
planned_end:
actual_end: 2026-05-18
related_dr: []
related_commits: []
related_troubleshooting: []
---

## Plan

Phase 1 구현 결과를 분석하여 Phase 2 설계의 기반을 마련한다.
현황 파악에 그치지 않고 현장 실무 적용 가능 수준까지 완성도를 올리기 위한 갭을 발굴한다.
코드를 직접 읽고 실제 상태를 파악한다 — 문서 기반 추정 금지.

분석 카테고리:
1. **아키텍처 & 코드 품질** — 레이어 일관성, common-core 의존성 방향, 중복/추상화 수준
2. **보안** — JWT 구현 완성도, 인증/인가 일관성, CORS·rate limiting, secrets 관리
3. **관찰가능성** — 구조화 로깅·MDC·correlation ID, Actuator/metrics, 분산 추적 준비
4. **복원력 & 운영** — circuit breaker·retry·timeout, graceful shutdown, health check
5. **개발 경험 & 배포** — Dockerfile 품질, docker-compose 실행 완성도, OpenAPI 문서
6. **테스트 전략** — 단위/통합 커버리지 비율, Testcontainers 활용, E2E 구조

**Alternatives 검토:**
- 문서만 보고 분석 — 실제 코드와 문서 불일치 가능성 높음, 채택 안 함
- Phase 2 착수 후 분석 병행 — 설계 기반 없이 착수하면 재작업 위험, 채택 안 함

## Done Criteria

**현황 파악**
- [x] 레이어 구조 일관성 분석 완료 (위반 항목 목록화)
- [x] common-core 모듈 의존성 방향 검증
- [x] gateway 라우팅/필터 현황 정리
- [x] 테스트 커버리지 수치 파악 (`./gradlew test` BUILD SUCCESSFUL, JaCoCo 미적용이므로 수치는 P2-025에서 측정)

**갭 발굴**
- [x] 보안 갭 목록화 (G-SEC-001~007)
- [x] 관찰가능성 갭 목록화 (G-OBS-001~004)
- [x] 복원력 갭 목록화 (G-RES-001~003)
- [x] 개발/배포 갭 목록화 (G-DEV-001~004)
- [x] 테스트 전략 갭 목록화 (G-TEST-001~004)

**반영**
- [x] 발굴된 개선 항목 → `docs/backlog/PHASE2.md` 신규 항목 P2-016~P2-028 등록 및 우선순위 제안
- [x] `./gradlew test` BUILD SUCCESSFUL 확인

## Verification

```bash
./gradlew test
./gradlew build
```

분석 결과: `docs/backlog/PHASE2.md` 업데이트 및 필요 시 신규 DR 제안

## Checkpoints

| CP | Description | Status |
|----|-------------|--------|
| 1  | 아키텍처 & 코드 품질 분석 | Done |
| 2  | common-core / gateway 분석 | Done |
| 3  | 보안 갭 분석 | Done |
| 4  | 관찰가능성 / 복원력 갭 분석 | Done |
| 5  | 개발 경험 / 테스트 전략 분석 | Done |
| 6  | 결과 → backlog 반영 및 우선순위 제안 | Done |

## Discovery

### CP1: 아키텍처 & 코드 품질

**현황 — 양호:**
- Controller → Service → Mapper 레이어 구조 전 서비스 일관 적용
- `BusinessException` + `ErrorCode` 패턴 공통 적용, `ApiResponse<T>` 통일 포맷
- Virtual Threads (Java 21 Loom) 활성화, Lombok @Data 미사용

**갭:**
- G-ARCH-001: `GlobalExceptionHandler`에서 `BusinessException`은 `ApiResponse<Void>`, `MethodArgumentNotValidException`은 `ErrorResponse` 반환 — 클라이언트 파싱 이중 처리 필요
- G-ARCH-002: `ApiResponse.success()`의 `"성공"` 메시지 하드코딩 — i18n 미지원
- G-ARCH-003: `todo-service`의 `UserExistenceMapper`가 users 테이블 직접 조회 — MSA DB 분리 원칙 위배. 실제 분리 시 동작 불가
- G-ARCH-004: Offset-based pagination — 대용량 데이터 성능 하락 가능

### CP2: common-core / gateway 분석

**현황 — 양호:**
- common-core: exception/logging/response/security 패키지 명확히 분리. 서비스 도메인 로직 없음
- Gateway 필터 우선순위 체계 완성 (SecurityHeaders -4 → MdcGateway -5 → RateLimit -3 → JwtAuth -2 → UserContext)
- CORS 중앙 관리, `ALLOWED_ORIGINS` 환경변수 기반

**갭:**
- G-GW-001: `allowedHeaders: List.of("*")` 하드코딩 — 환경변수 제어 불가
- G-GW-002: 서비스 SecurityConfig에서 `/actuator/**` permitAll — 관리 포트(8099) 분리되어 있지만 서비스 포트에서도 접근 가능

### CP3: 보안 갭

**현황 — 양호:**
- JWT: access/refresh type 분리, token confusion 방어, JTI 블랙리스트, Token Rotation
- fail-close/fail-open 정책, BCrypt(12), 로그인 실패 동일 메시지
- SecurityHeadersFilter: X-Content-Type-Options, X-Frame-Options, X-XSS-Protection, HSTS(stg/prd)
- UserContextFilter: Header Spoofing 대응 Phase 2 K8s NetworkPolicy 계획 명시됨

**갭:**
- G-SEC-001: `JwtTokenProvider.signingKey()` 매 호출마다 `Keys.hmacShaKeyFor()` 재실행 — 필드 캐싱 필요 (성능 + 명시적 초기화)
- G-SEC-002: JWT secret 최소 길이 검증 없음 — HS256 최소 32바이트(256bit) 미검증
- G-SEC-003: `Content-Security-Policy` 헤더 없음 — XSS 방어 불완전
- G-SEC-004: `X-XSS-Protection: 1; mode=block` deprecated — 모던 브라우저 지원 중단, CSP로 대체 권장
- G-SEC-005: Rate limit IP 추출에 `X-Forwarded-For` 미처리 — reverse proxy 뒤에서 실제 IP 아닌 proxy IP로 키 생성 가능
- G-SEC-006: Actuator `show-details: always` 전 환경 적용 — prd에서 DB pool, disk, Redis 상태 노출
- G-SEC-007: `Referrer-Policy`, `Permissions-Policy` 헤더 없음

### CP4: 관찰가능성 / 복원력 갭

**현황 — 양호:**
- MdcFilter(서비스) + MdcGatewayFilter(WebFlux-safe Reactor Context) correlation ID 전파
- logback-spring.xml: 환경별 console/LogstashEncoder JSON 구조화 로그
- `micrometer-tracing-bridge-brave` 의존성 포함
- SlowQueryInterceptor (local/dev, 100ms threshold)

**갭:**
- G-OBS-001: `micrometer-registry-prometheus` 없음 — Prometheus/Grafana 연동 불가
- G-OBS-002: Gateway 자체 로그 MDC 미완성 — "Phase 2에서 적용" 명시, `Hooks.onEachOperator` 미구현
- G-OBS-003: 요청 액세스 로그 없음 — HTTP method/path/status/duration 로깅 미구현
- G-OBS-004: Brave → Zipkin/OTLP exporter 미구성 — tracing bridge 있지만 stg/prd 전송 설정 없음
- G-RES-001: Circuit breaker 없음 — resilience4j 미포함, 다운스트림 장애 시 cascading failure 위험
- G-RES-002: Gateway retry filter 미구성
- G-RES-003: SlowQueryInterceptor `@Profile({"local", "dev"})` — stg 성능 측정 불가

### CP5: 개발 경험 & 테스트 전략

**현황 — 양호:**
- `.dockerignore` 완성도 양호 (docs/, tests/, .env 제외)
- docker-compose.yml: healthcheck, depends_on, network 분리, 볼륨
- `.env.example` 존재
- 환경별 profile 분리 (local/dev/stg/prd)
- 각 서비스: Controller/Service 단위 테스트 + Testcontainers 통합 테스트 + 인프라(Redis) 테스트
- `.http` E2E 파일 존재 (tests/http/auth/user/todo/gateway)
- `@ServiceConnection` Spring Boot 3.1+ 자동 컨테이너 연결

**갭:**
- G-DEV-001: Dockerfile non-root user 없음 — 컨테이너 보안 취약 (`USER nonroot` 미설정)
- G-DEV-002: Dockerfile 의존성 캐시 레이어 없음 — 소스 변경마다 전체 재빌드 (CI 속도 저하)
- G-DEV-003: `OpenApiConfig` 4개 서비스 각각 중복 — common-core autoconfigure 통합 가능
- G-DEV-004: docker-compose에서 서비스 자체 health check `service_healthy` 조건 없음 — gateway가 서비스 시작 직후 라우팅 시도 가능 (현재 `service_started`)
- G-TEST-001: JaCoCo 없음 — 커버리지 수치 측정 불가
- G-TEST-002: Gateway 통합 테스트 없음 — 필터 체인 end-to-end 시나리오 미구현
- G-TEST-003: Contract testing 없음 — 서비스 API 변경 시 gateway 라우팅 정합성 미보장
- G-TEST-004: auth-service Redis 컨테이너 `@DynamicPropertySource` 수동 설정 — user/todo는 `@ServiceConnection` 사용, 불일치
