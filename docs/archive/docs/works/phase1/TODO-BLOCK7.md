# BLOCK 7 — api-gateway

> 선행 조건: BLOCK 4 + BLOCK 5 + BLOCK 6 완료 + 각 CP-2 통과
> 목적: 단일 진입점, JWT 검증, 라우팅, 보안 필터 체인 구현
> 주의: 단위 테스트는 독립 가능. 통합 테스트는 전체 서비스 기동 필요.
> 기본 패키지: `io.kyungseo.msa.gateway`
> 참조: `docs/ARCHITECTURE.md` §6 필터 체인, §2 요청 흐름

---

## 7-1. 기본 라우팅 설정

- [ ] `application.yml` 라우팅 규칙 작성
  ```yaml
  spring:
    cloud:
      gateway:
        routes:
          - id: auth-service
            uri: ${AUTH_SERVICE_URL:http://localhost:8091}
            predicates:
              - Path=/api/v1/auth/**
          - id: user-service
            uri: ${USER_SERVICE_URL:http://localhost:8092}
            predicates:
              - Path=/api/v1/users/**
          - id: todo-service
            uri: ${TODO_SERVICE_URL:http://localhost:8093}
            predicates:
              - Path=/api/v1/todos/**
  ```

- [ ] 공개 경로(whitelist) 목록 Bean 정의
  - `POST /api/v1/auth/login`
  - `POST /api/v1/auth/refresh`
  - `POST /api/v1/users` (회원가입)
  - `GET /actuator/health` (헬스 체크용)

---

## 7-2. 필터 구현 (순서 보장)

> 필터 실행 순서: ① → ② → ③ → ④ → ⑤
> 자세한 필터 체인 다이어그램: `docs/ARCHITECTURE.md` §6

### ① MdcGatewayFilter

> **WebFlux MDC 전파 주의**: Gateway는 Reactor 기반으로 Servlet `ThreadLocal` MDC 방식 사용 불가.
> 요청이 여러 스레드에 걸쳐 실행되므로 일반적인 `MDC.put()` 방식으로는 MDC 값 전파 안 됨.
> 권장 방식: Micrometer Tracing의 `ObservationRegistry`가 Reactor Context 연동을 지원하므로
> traceId/spanId는 자동 전파됨. correlationId는 `Hooks.onEachOperator`로 추가 전파하거나
> 필터 체인 내에서 `contextWrite(ctx -> ctx.put(key, value))` + `doOnEach` 조합 사용.
> 자세한 방법: `docs/ARCHITECTURE.md §11 WebFlux MDC 전파 주의사항` 참조.

- [ ] `X-Correlation-ID` 헤더 추출 (없으면 UUID v4 생성)
- [ ] Reactor Context에 correlationId 저장 (`contextWrite` 사용 — ThreadLocal MDC 직접 설정 금지)
- [ ] 하위 서비스로 `X-Correlation-ID` 헤더 전파 (`mutate().header()` 사용)
- [ ] 응답에 `X-Correlation-ID` 헤더 전파 (클라이언트 디버깅용)

### ② SecurityHeadersFilter

- [ ] 보안 응답 헤더 추가
  - `X-Content-Type-Options: nosniff`
  - `X-Frame-Options: DENY`
  - `X-XSS-Protection: 1; mode=block`
  - `Strict-Transport-Security: max-age=31536000; includeSubDomains` (stg/prd 프로파일 조건부)

### ③ RateLimitFilter

- [ ] Redis 기반 Sliding Window Rate Limiting
  - 인증 경로 (`/api/v1/auth/**`): 5 req/sec
  - 일반 경로: 100 req/sec
  - Key: `rl:{userId}` (인증 후) 또는 `rl:ip:{remoteAddr}` (미인증)
  - 초과 시 429 Too Many Requests + `Retry-After` 헤더

### ④ JwtAuthFilter

- [ ] 공개 경로(whitelist) skip 처리
- [ ] `Authorization: Bearer {token}` 헤더 추출
- [ ] JJWT 서명 검증 + 만료 확인
- [ ] **`type == "access"` 검증** — Refresh Token으로 API 접근 시 401 반환 (token confusion 방어)
  > auth-service `/refresh` 엔드포인트는 공개 경로이므로 이 필터를 통과함.
  > Refresh Token이 일반 API에 사용되는 것만 차단하면 되므로 공개 경로 skip 후 검증.
- [ ] Redis Blacklist 조회 (`EXISTS bl:{jti}`)
- [ ] 유효하지 않으면 401 반환
- [ ] **Redis 장애 시 fail 정책 적용**
  ```yaml
  gateway:
    blacklist-fail-policy: ${BLACKLIST_FAIL_POLICY:fail-close}
  ```
  - `fail-close` (기본값): Redis 조회 실패 시 401 반환 — 보안 우선
  - `fail-open`: Redis 조회 실패 시 통과 허용 — 가용성 우선
  - 장애 발생 시 `ERROR` 레벨 로그 필수 기록

### ⑤ UserContextFilter

- [ ] **`X-User-Id`, `X-User-Role` 헤더 강제 제거** (외부 유입 차단 — Header Spoofing 방어)
  - 제거 없이 덮어쓰기만 하면 안 됨 — 반드시 remove 후 add
- [ ] JWT claim에서 `userId`, `role` 추출 → 새 헤더로 하위 서비스 전달

---

## 7-3. 필터 단위 테스트

- [ ] `JwtAuthFilterTest`
  - 유효 토큰 → 다음 필터 통과
  - 만료 토큰 → 401
  - Blacklist 토큰 → 401
  - Redis 장애 + `fail-close` → 401
  - Redis 장애 + `fail-open` → 통과
- [ ] `UserContextFilterTest`
  - 외부 `X-User-Id` 헤더 주입 시 → 제거 후 서버 값으로 교체 확인
  - 외부 `X-User-Role` 헤더 주입 시 → 제거 후 서버 값으로 교체 확인
- [ ] `RateLimitFilterTest`
  - 임계치 초과 시 429 반환
  - 인증/일반 경로 별도 임계치 적용 확인

---

## 7-4. 보안 및 공통 설정

- [ ] CORS 중앙 설정 (`ALLOWED_ORIGINS` 환경변수 기반, 전 서비스 일괄 적용)
- [ ] `/actuator/**` 외부 차단 설정 (8090 포트로 접근 불가, 8099만 허용)
- [ ] `BLACKLIST_FAIL_POLICY` 환경변수 `.env.example` 반영 확인
- [ ] springdoc-openapi-starter-**webflux**-ui 설정
  - JWT Bearer 인증 적용
  - `local` / `dev` 프로파일에서만 활성화
- [ ] Actuator health probes 설정 (management port: 8099)

---

## 7-5. 통합 테스트

> 전체 서비스 기동 상태에서 진행 (`@SpringBootTest` + Testcontainers)

- [ ] 유효 토큰으로 각 서비스 라우팅 통과 확인
- [ ] 만료 토큰 → 401 반환 확인
- [ ] Blacklist 토큰 → 401 반환 확인
- [ ] Rate Limiting 임계치 초과 → 429 반환 확인
- [ ] 공개 경로 인증 없이 통과 확인
- [ ] 외부에서 `X-User-Id` 헤더 직접 주입 시 서버 값으로 교체 확인

---

## 7-6. 체크포인트 CP-3

- [ ] 전체 스택 기동 (`make run` 또는 각 서비스 로컬 직접 실행)
- [ ] 로그인(auth) → Todo 생성(todo) E2E 흐름 Gateway(8090) 경유 확인
- [ ] MDC 로그에 동일 `X-Correlation-ID`가 Gateway / auth-service / todo-service 로그에 출력되는지 확인
- [ ] ✅ **CP-3 통과 기록 후 BLOCK 8 진행**

---

## 완료 조건

- [ ] `./gradlew :gateway:api-gateway:test` 전체 통과
- [ ] Gateway 경유 E2E 1개 흐름 동작 확인

## 다음 단계

CP-3 통과 → **BLOCK 8 (Dockerfile + 통합 테스트)** 진행
