# BLOCK 4 — auth-service

> 선행 조건: BLOCK 3 완료 + CP-1 통과
> 목적: JWT 발급/갱신/블랙리스트, 로그인/로그아웃 구현
> 병렬 가능: BLOCK 5 (user-service), BLOCK 6 (todo-service)
> 기본 패키지: `io.kyungseo.msa.auth`
> 참조: `docs/PLAN.md` §8 인증/인가, §11 에러 코드

---

## 4-1. MyBatis 및 DB 연동

- [ ] MyBatis 설정 (`@MapperScan("io.kyungseo.msa.auth.mapper")`, `DataSource`, `SqlSessionFactory`)
- [ ] `UserMapper` 인터페이스 + `UserMapper.xml` 작성
  - `findByUsername(username)` — 로그인 시 사용자 조회
  - `findById(id)` — 토큰 갱신 시 사용자 검증
  - XML 상단 주석: `<!-- #{} 파라미터 바인딩 사용. ${} 절대 사용 금지 (SQL Injection 방어) -->`
- [ ] **MyBatis 슬라이스 테스트** (`@MybatisTest` + Testcontainers PostgreSQL)
  - `findByUsername` 성공 케이스 (존재하는 사용자)
  - `findByUsername` 미존재 케이스 (Optional.empty 반환 확인)

---

## 4-2. JWT 핵심 로직

- [ ] `JwtTokenProvider` 구현 (JJWT 0.12.x)
  - Access Token 생성 (TTL: `jwt.accessTokenExpiry`초, claim: `userId`, `role`, `jti`, `type: "access"`)
  - Refresh Token 생성 (TTL: `jwt.refreshTokenExpiry`초, claim: `userId`, `jti`, `type: "refresh"`)
    > **token confusion attack 방어**: Access Token이 Refresh 엔드포인트에 사용되거나
    > Refresh Token이 API 접근에 사용되는 것을 `type` 클레임 검증으로 차단. (→ PLAN.md §8 참조)
  - 토큰 서명 검증 (HS256, `JWT_SECRET` 환경변수 기반)
  - 토큰에서 `userId` 추출
  - 토큰에서 `role` 추출
  - 토큰에서 `jti` 추출
  - 토큰에서 `type` 추출 및 검증 (`"access"` / `"refresh"` 구분)
  - 토큰 잔여 만료시간 계산 (Blacklist TTL 설정용)
  - 만료된 토큰 감지 (`ExpiredJwtException`)
- [ ] **`JwtTokenProvider` 단위 테스트**
  - Access Token 생성 + claim 추출 검증
  - Refresh Token 생성 검증
  - 유효하지 않은 토큰 검증 실패 확인
  - 만료된 토큰 감지 확인

---

## 4-3. Redis 연동 (멀티 디바이스 세션 구조)

> Redis 키 구조: `docs/ARCHITECTURE.md` §8, §16 참조

- [ ] Redis 설정 (`RedisTemplate<String, String>`, `StringRedisTemplate`)
- [ ] `TokenRedisRepository` 구현
  - Refresh Token 저장: `SET rt:{userId}:{deviceId} {token} EX {ttl}`
  - Refresh Token 조회: `GET rt:{userId}:{deviceId}`
  - 단일 디바이스 삭제: `DEL rt:{userId}:{deviceId}`
  - 전체 디바이스 세션 삭제: `SCAN rt:{userId}:* → DEL` (탈취 감지 시)
  - Blacklist 저장: `SET bl:{jti} logout EX {잔여만료시간}`
  - Blacklist 존재 확인: `EXISTS bl:{jti}`
- [ ] **`TokenRedisRepository` 단위 테스트** (Mockito로 RedisTemplate Mock)
  - Refresh Token 저장/조회/단일삭제
  - 전체 세션 무효화 (SCAN + DEL 로직 검증)
  - Blacklist 저장/조회

---

## 4-4. 인증 API 구현

- [ ] `auth-service` 전용 `ErrorCode` 정의 (서비스 내 enum)
  - `AUTH-0001`: 로그인 실패 (400)
  - `AUTH-0002`: 토큰 만료 (401)
  - `AUTH-0003`: 유효하지 않은 토큰 (401)
  - `AUTH-0004`: Blacklist 토큰 (401)
  - `AUTH-0005`: Refresh Token 없음 — 탈취 의심 (401)

- [ ] `POST /api/v1/auth/login`
  - 요청: `{ username, password, deviceId }`
  - 처리: BCrypt 검증 → Access + Refresh Token 발급 → Redis 저장 (`rt:{userId}:{deviceId}`)
  - 실패: `AUTH-0001` 반환 (사용자 없음 / 비밀번호 불일치 동일 메시지 — 정보 노출 방지)
  - 응답: `{ accessToken, refreshToken, tokenType: "Bearer" }`

- [ ] `POST /api/v1/auth/refresh` (Refresh Token Rotation)
  - 요청: `{ refreshToken, deviceId }`
  - 처리:
    1. Refresh Token 서명 검증
    2. **`type == "refresh"` 검증** — Access Token으로 갱신 시도 시 401 반환 (token confusion 방어)
    3. Redis `rt:{userId}:{deviceId}` 존재 확인
    4. 존재: 기존 삭제 + 신규 Access/Refresh Token 발급 + 신규 저장
    5. 미존재(탈취 의심): `rt:{userId}:*` 전체 삭제 + `AUTH-0005` 반환
  - 응답: `{ accessToken, refreshToken }`

- [ ] `POST /api/v1/auth/logout`
  - 요청 헤더: `Authorization: Bearer {accessToken}`
  - 요청 바디: `{ deviceId }`
  - 처리: Access Token Blacklist 등록 (TTL = 잔여 만료시간) + `rt:{userId}:{deviceId}` 삭제
  - 응답: 200 OK

- [ ] `AuthController` (`@Valid` 입력 검증 적용)
- [ ] Spring Security 설정
  - `/api/v1/auth/**` → `permitAll()`
  - 나머지 → `authenticated()`
  - CSRF 비활성화 (stateless REST API)
  - Session: `STATELESS`

- [ ] **`AuthService` 단위 테스트** (JwtTokenProvider, TokenRedisRepository, UserMapper Mock)
  - 로그인 성공: 토큰 발급 + Redis 저장 확인
  - 로그인 실패: `AUTH-0001` 반환 확인
  - 토큰 갱신 정상: 기존 삭제 + 신규 발급 확인
  - 토큰 갱신 탈취 의심: 전체 세션 무효화 + `AUTH-0005` 확인
  - 로그아웃: Blacklist 등록 + Refresh Token 삭제 확인

- [ ] **`AuthController` 슬라이스 테스트** (`@WebMvcTest`)
  - 요청 바디 유효성 검증 (필수 필드 누락 시 `COMMON-0002`)
  - 응답 포맷 (`ApiResponse<>` 래퍼) 확인

---

## 4-5. 공통 설정

- [ ] springdoc-openapi JWT Bearer 인증 설정 (`SecurityScheme` Bean)
- [ ] MDC + Micrometer Tracing 설정 (로그 패턴: `[auth-service,%X{traceId},%X{spanId},%X{X-Correlation-ID}]`)
- [ ] Actuator health probes 설정 (management port: 8099, liveness/readiness 분리)

---

## 4-6. 통합 테스트

- [ ] `@SpringBootTest` + Testcontainers (PostgreSQL + Redis)
  - 로그인 → 토큰 갱신 → 로그아웃 전체 흐름 검증
  - 로그아웃 후 Blacklist 토큰으로 재요청 → 401 확인
  - 동일 userId 다른 deviceId 로그인 → 각 세션 독립 동작 확인 (멀티 디바이스)

---

## 4-7. 체크포인트 CP-2 (auth-service)

- [ ] auth-service 단독 기동 (`SPRING_PROFILES_ACTIVE=local`)
- [ ] Swagger UI(`http://localhost:8091/swagger-ui.html`) 접근 확인
- [ ] `tests/http/auth.http` (또는 Swagger)로 로그인 API 응답 확인
  - Access Token, Refresh Token 정상 발급 확인
- [ ] ✅ **CP-2 통과 기록 후 BLOCK 7 진행 허용 (BLOCK 5, 6도 완료 시)**

---

## 완료 조건

- [ ] `./gradlew :services:auth-service:test` 전체 통과
- [ ] 로그인 → 갱신 → 로그아웃 E2E 흐름 동작 확인

## 다음 단계

CP-2 (auth) 통과 → BLOCK 7 진행 조건 중 하나 충족
