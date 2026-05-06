# STATUS.md — 진행 상태 트래킹

> 마지막 업데이트: 2026-05-06 (BLOCK 7 완료)
> 이 파일은 구현 진행에 따라 지속적으로 업데이트된다.
> Claude Code는 각 태스크 완료 후 이 파일의 해당 항목을 업데이트할 것을 **제안**하고,
> 사용자 확인 후 반영한다.

---

## 현재 진행 블록

**▶ BLOCK 8 — Dockerfile + 통합 테스트**

---

## 블록별 상태 요약

| 블록 | 이름 | 상태 | 완료율 |
|------|------|------|--------|
| BLOCK 1 | 프로젝트 골격 | ✅ 완료 | 100% |
| BLOCK 2 | common-core | ✅ 완료 | 100% |
| BLOCK 3 | 도메인 모델 + schema.sql | ✅ 완료 | 100% |
| BLOCK 4 | auth-service | ✅ 완료 | 100% |
| BLOCK 5 | user-service | ✅ 완료 | 100% |
| BLOCK 6 | todo-service | ✅ 완료 | 100% |
| BLOCK 7 | api-gateway | ✅ 완료 | 100% |
| BLOCK 8 | Dockerfile + 통합 테스트 | ⏸ 대기 | - |
| BLOCK 9 | Frontend | ⏸ 대기 | - |
| BLOCK 10 | 문서화 및 마무리 | ⏸ 대기 | - |

**상태 아이콘**: 🔵 시작 전 / 🟡 진행 중 / ✅ 완료 / ⏸ 대기 / ⚠️ 블로킹 이슈

---

## BLOCK 1 세부 진행 (완료)

> 상세 태스크는 `docs/TODO/TODO-BLOCK1.md` 참조

### 1-1. Gradle 멀티모듈 초기화
- [x] 루트 `build.gradle.kts`
- [x] `gradle/libs.versions.toml`
- [x] `settings.gradle.kts`
- [x] 각 모듈 `build.gradle.kts` (5개)
- [x] Gradle Wrapper
- [x] 루트 `.gitignore`

### 1-2. 환경변수 및 설정 파일 뼈대
- [x] `.env.example`
- [x] 각 서비스 `application.yml` (4개)
- [x] 각 서비스 `application-local.yml` (4개)
- [x] 각 서비스 `application-dev.yml` (4개)
- [x] 각 서비스 `application-stg.yml` (4개)
- [x] 각 서비스 `application-prd.yml` (4개)

### 1-3. Docker Compose 인프라
- [x] `infra/docker/docker-compose.yml`
- [x] `.devcontainer/docker-compose.devcontainer.yml`
- [x] `infra/docker/init-sql/01-schema.sql` (BLOCK 3에서 작성 완료 — 파일명 변경)
- [x] `infra/docker/init-sql/02-data.sql` (BLOCK 3에서 작성 완료 — 파일명 변경)

### 1-4. DevContainer 설정
- [x] `.devcontainer/devcontainer.json`

### 1-5. 빈 디렉토리 구조
- [x] `infra/k8s/` 하위 구조 + `.gitkeep`
- [x] `infra/prometheus/`, `infra/grafana/` `.gitkeep`
- [x] `tests/http/` `.gitkeep`

### 1-6. 자동화 스크립트
- [x] `scripts/Makefile`
- [x] `scripts/create-service.sh`

---

## BLOCK 2 세부 진행 (완료)

> 상세 태스크는 `docs/TODO/TODO-BLOCK2.md` 참조

### response/
- [x] `ApiResponse<T>`
- [x] `ErrorResponse`
- [x] `PageResponse<T>`

### exception/
- [x] `BusinessException`
- [x] `ErrorCode` enum
- [x] `GlobalExceptionHandler`

### logging/
- [x] `MdcFilter`
- [x] `LoggingConstants`

### security/
- [x] `JwtProperties`

### mybatis/
- [x] `SlowQueryInterceptor`

### util/
- [x] `DateTimeUtils`

### 테스트
- [x] `ApiResponseTest`
- [x] `ErrorCodeTest`
- [x] `BusinessExceptionTest`
- [x] `MdcFilterTest`
- [x] `GlobalExceptionHandlerTest`

---

## BLOCK 3 세부 진행 (완료)

> 상세 태스크는 `docs/TODO/TODO-BLOCK3.md` 참조

### 3-1. 도메인 모델 확정

- [x] `User` 필드 확정 (id, username, email, password, role, enabled, created_at, updated_at)
- [x] `Todo` 필드 확정 (id, user_id, title, description, completed, created_at, updated_at)

### 3-2. 01-schema.sql 작성

- [x] `users` 테이블 DDL
- [x] `todos` 테이블 DDL (DB FK 없음, 논리적 참조)
- [x] 인덱스 3개 (`idx_todos_user_id`, `idx_users_email`, `idx_users_username`)
- [x] `updated_at` 자동 갱신 트리거 함수 + `users`/`todos` 트리거

### 3-3. 02-data.sql 작성

- [x] 테스트 계정 5개 (BCrypt strength 12 해시, 평문 없음)
- [x] 샘플 Todo 13건 (subselect 패턴, user_id 하드코딩 없음)

### 3-4. CP-1 통과

- [x] `.env` 생성 (JWT_SECRET 256-bit 랜덤 생성)
- [x] `docker compose up postgres redis -d` 기동
- [x] 스키마 확인: `users`, `todos` 테이블 + 인덱스 3개 + 트리거 2개
- [x] 데이터 확인: 계정 5명, Todo admin 3건 / user 8건 / user2 2건

> **파일명 변경**: PostgreSQL init 스크립트는 알파벳 순 실행 → `data.sql`(d)이 `schema.sql`(s)보다 먼저 실행되어 오류 발생.
> `01-schema.sql` / `02-data.sql` 로 변경하여 해결.

---

## 체크포인트 상태

| CP | 조건 | 상태 |
|----|------|------|
| CP-1 | BLOCK 3 완료 → `docker compose up postgres` + psql 스키마/데이터 확인 | ✅ 통과 |
| CP-2 (auth) | auth-service 단독 기동 → 로그인 API 응답 확인 | ✅ 통과 |
| CP-2 (user) | user-service 단독 기동 → 회원가입 API 응답 확인 | 🟡 미검증 (빌드/테스트 통과, 기동 미확인) |
| CP-2 (todo) | todo-service 단독 기동 → Todo 생성 API 응답 확인 | 🟡 미검증 (빌드/테스트 통과, 기동 미확인) |
| CP-3 | 전체 스택 기동 → 로그인 → Todo 생성 E2E Gateway 경유 확인 | ⏸ 대기 |

---

## BLOCK 4 세부 진행 (완료)

> 상세 태스크는 `docs/TODO/TODO-BLOCK4.md` 참조

### 선행 작업 — common-core 리팩토링

- [x] `ErrorCode` enum → interface 변경 (서비스별 ErrorCode 지원)
- [x] `CommonErrorCode` enum 신규 생성 (기존 COMMON-0001~0006 이관)

### 4-1. MyBatis 및 DB 연동

- [x] `UserMapper` 인터페이스 (`findByUsername`, `findById`)
- [x] `UserMapper.xml` (#{} 바인딩, enabled=TRUE 필터)

### 4-2. JWT 핵심 로직

- [x] `JwtTokenProvider` (JJWT 0.12.x, HS256, type 클레임으로 token confusion 방어)
- [x] `JwtTokenProviderTest` (6개 케이스 — 만료/변조/type 검증 포함)

### 4-3. Redis 연동

- [x] `TokenRedisRepository` (`rt:{userId}:{deviceId}`, `bl:{jti}` 키 구조)
- [x] `TokenRedisRepositoryTest` (Mockito Mock, 7개 케이스)

### 4-4. 인증 API

- [x] `AuthErrorCode` (AUTH-0001~0005)
- [x] `AuthService` (로그인/갱신/로그아웃, Token Rotation, 탈취 의심 시 전체 세션 무효화)
- [x] `AuthController` (`/login`, `/refresh`, `/logout`)
- [x] `SecurityConfig` (auth/** permitAll, STATELESS)
- [x] `AuthServiceTest` (Mockito, 5개 케이스)
- [x] `AuthControllerTest` (@WebMvcTest, 5개 케이스)
- [x] `AuthIntegrationTest` (@SpringBootTest, 로컬 PG/Redis 사용, 3개 케이스)

### 4-5. 공통 설정

- [x] `OpenApiConfig` (Swagger Bearer 인증)
- [x] `MyBatisConfig`, `JwtConfig`

### 4-7. CP-2 (auth)

- [x] auth-service 단독 기동 (`SPRING_PROFILES_ACTIVE=local`)
- [x] Actuator (8099): UP — PostgreSQL + Redis 연결 확인
- [x] `POST /api/v1/auth/login` → Access + Refresh Token 정상 발급 확인

### 특이 사항

- `@SpringBootApplication(scanBasePackages = {"io.kyungseo.msa.auth", "io.kyungseo.msa.common"})` 필수 — 없으면 GlobalExceptionHandler 미등록
- Testcontainers가 이 환경의 Docker Desktop과 호환 안 됨 → 통합 테스트는 로컬 running 컨테이너 사용 (`@ActiveProfiles("test")` + `application-test.yml`)

---

## BLOCK 5 세부 진행 (완료)

### 5-1. 도메인 / 예외 / DTO

- [x] `domain/User.java` (@Getter @Builder, id/username/email/password/role/enabled/timestamps)
- [x] `exception/UserErrorCode.java` (USER-0001~0003: 이메일 중복, 사용자 미존재, 비밀번호 정책)
- [x] `dto/RegisterRequest.java` (@NotBlank, @Email, @Pattern 비밀번호 정책)
- [x] `dto/UpdateUserRequest.java` (username, password 선택적 수정)
- [x] `dto/UserResponse.java` (정적 팩토리 from(User), 비밀번호 미노출)

### 5-2. MyBatis

- [x] `mapper/UserMapper.java` (findAll/count/findById/findByEmail/existsByEmail/insert/update/deleteById)
- [x] `resources/mapper/UserMapper.xml` (#{} 바인딩, LIMIT/OFFSET 페이지네이션, dynamic `<set>`)

### 5-3. 보안 필터 / 설정

- [x] `filter/UserContextFilter.java` (X-User-Id/X-User-Role 헤더 → SecurityContext 구성, finally 블록에서 clearContext)
- [x] `config/SecurityConfig.java` (STATELESS, CSRF disable, POST /api/v1/users permitAll, @EnableMethodSecurity)
- [x] `config/MyBatisConfig.java` (@MapperScan)
- [x] `config/OpenApiConfig.java` (Swagger Bearer 인증)
- [x] `UserServiceApplication.java` (scanBasePackages 추가 — GlobalExceptionHandler 등록 필수)

### 5-4. 서비스 / 컨트롤러

- [x] `service/UserService.java` (register/getUsers/getUser/updateUser/deleteUser, BCrypt 12, FORBIDDEN 체크)
- [x] `controller/UserController.java` (5개 엔드포인트, @PreAuthorize, SecurityContextHolder 직접 참조)

### 5-5. 테스트

- [x] `UserServiceTest.java` (Mockito 단위, 7케이스)
- [x] `UserControllerTest.java` (@WebMvcTest 슬라이스, excludeAutoConfiguration, SecurityContextHolder 직접 설정, 7케이스)
- [x] `UserIntegrationTest.java` (@SpringBootTest, 로컬 PostgreSQL 사용, 4케이스)
- [x] `test/resources/application-test.yml`
- [x] `test/resources/test-schema.sql`

### 5-6. HTTP 테스트 파일

- [x] `tests/http/user.http` (10개 시나리오)

### 구현 중 발견한 사항

- `@WebMvcTest`에서 `authentication()` PostProcessor가 동작하지 않는 문제 (SecurityContextHolderFilter 미포함): `SecurityContextHolder` 직접 설정 방식으로 해결
- 컨트롤러에서 `Authentication authentication` 파라미터 대신 `SecurityContextHolder.getContext().getAuthentication()` 직접 참조로 변경 (MockMvc 슬라이스 테스트 호환)

---

## BLOCK 6 세부 진행 (완료)

### 6-1. MyBatis

- [x] `mapper/TodoMapper.java` (findAllByUserId/countByUserId/findById/insert/update/updateCompleted/deleteById)
- [x] `mapper/UserExistenceMapper.java` (existsById — users 테이블 직접 조회, FK 미사용 설계 보완)
- [x] `resources/mapper/TodoMapper.xml` / `UserExistenceMapper.xml` (#{} 바인딩, completed nullable 필터)

### 6-2. 도메인 / 예외 / DTO

- [x] `domain/Todo.java` (@Getter @Builder)
- [x] `exception/TodoErrorCode.java` (TODO-0001~0002)
- [x] `dto/CreateTodoRequest.java` / `UpdateTodoRequest.java` / `TodoResponse.java`

### 6-3. 보안 필터 / 설정

- [x] `filter/TodoContextFilter.java` (Header Spoofing Phase 1/2 주석 포함)
- [x] `config/SecurityConfig.java` (STATELESS, 전체 인증 필수, @EnableMethodSecurity)
- [x] `config/MyBatisConfig.java` / `config/OpenApiConfig.java`
- [x] `TodoServiceApplication.java` (scanBasePackages 추가 — GlobalExceptionHandler 등록 필수)

### 6-4. 서비스 / 컨트롤러

- [x] `service/TodoService.java` (getTodos/createTodo/getTodo/updateTodo/toggleComplete/deleteTodo, validateOwnership 공통 메서드, @Transactional)
- [x] `controller/TodoController.java` (6개 엔드포인트, SecurityContextHolder 직접 참조)

### 6-5. 테스트

- [x] `TodoServiceTest.java` (Mockito 단위, 9케이스)
- [x] `TodoControllerTest.java` (@WebMvcTest 슬라이스, SecurityContextHolder 직접 설정, 4케이스)
- [x] `TodoIntegrationTest.java` (@SpringBootTest, .with(authentication(...)) per-request 방식, 4케이스)
- [x] `test/resources/application-test.yml` / `test-schema.sql`
- [x] `tests/http/todo.http` (12개 시나리오)

### 구현 중 발견한 사항

- 통합 테스트에서 SecurityContextHolder.setAuthentication() 후 중간 전환 시 SecurityContextHolderFilter와 충돌 (다음 요청에서 이전 userId가 유지됨): `SecurityMockMvcRequestPostProcessors.authentication()` per-request 방식으로 해결
- build.gradle.kts에 불필요한 JJWT 의존성, application.yml에 jwt.secret 설정 제거 (user-service와 동일 패턴)

---

## BLOCK 7 세부 진행 (완료)

### 7-1. 설정 / 공통

- [x] `ApiGatewayApplication.java` (scanBasePackages 추가 — GlobalExceptionHandler 등록 필수)
- [x] `config/GatewayProperties.java` (blacklistFailPolicy, allowedOrigins, isFailClose())
- [x] `security/JwtVerifier.java` (JJWT 0.12.x 검증, type == "access" token confusion 방어)
- [x] `config/OpenApiConfig.java` (springdoc-webflux, JWT Bearer 스킴)
- [x] `config/SecurityConfig.java` (@EnableWebFluxSecurity, CORS, Actuator denyAll)
- [x] `test/resources/application-test.yml`

### 7-2. GlobalFilter 체인 (Order: -5 → -1)

- [x] `filter/MdcGatewayFilter.java` (Order -5 — X-Correlation-ID 생성/전파, Reactor Context 저장)
- [x] `filter/SecurityHeadersFilter.java` (Order -4 — X-Content-Type-Options, X-Frame-Options, HSTS stg/prd만)
- [x] `filter/RateLimitFilter.java` (Order -3 — Redis Lua sliding window, auth 5/s, 일반 100/s, 429+Retry-After)
- [x] `filter/JwtAuthFilter.java` (Order -2 — JWT 검증, Redis 블랙리스트 조회, fail-close/fail-open 정책)
- [x] `filter/UserContextFilter.java` (Order -1 — Header Spoofing 방어, X-User-Id/Role 강제 대체)

### 7-3. 테스트 (10/10 통과)

- [x] `JwtAuthFilterTest.java` (6케이스 — 공개경로 스킵, 유효토큰 통과, 401×2, fail-close, fail-open)
- [x] `UserContextFilterTest.java` (2케이스 — 스푸핑 헤더 교체, claims 없음 시 제거)
- [x] `RateLimitFilterTest.java` (2케이스 — 제한 이하 통과, 초과 시 429)

### 7-4. HTTP 테스트 파일

- [x] `tests/http/gateway.http` (6개 시나리오 — 공개경로, 인증, 헤더스푸핑, 인증실패, Actuator차단, Rate Limit)

### 구현 중 발견한 사항

- `reactor-test` 의존성 누락 → `testImplementation("io.projectreactor:reactor-test")` 추가
- `ReactiveRedisTemplate.execute()` Mockito 오버로드 모호성 → 필드 타입을 `ReactiveRedisOperations`(인터페이스)로 변경, 스텁 시 `anyList()` 사용
- `MockServerWebExchange` remoteAddress 기본값 null → `.remoteAddress(new InetSocketAddress("127.0.0.1", 0))` 필수
- `UnnecessaryStubbingException` → `@BeforeEach` chain 스텁은 `lenient().when(...)` 적용
- MDC 편차 수정: 계획(방식 A)과 달리 `doFirst(() -> MDC.put(...))` ThreadLocal 방식이 적용되어 있었음 → 제거하고 `contextWrite` Reactor Context 저장만 유지. 방식 A (Hooks.onEachOperator) 는 Phase 2 적용

---

## 이슈 / 블로킹 사항

> 현재 없음

---

## 변경 이력

| 날짜 | 블록 | 변경 내용 |
|------|------|-----------|
| 2026-05-03 | - | 초기 STATUS.md 생성 |
| 2026-05-04 | BLOCK 1 | BLOCK 1 전체 완료 (.gitignore 추가, create-service.sh 실행권한 부여 포함) |
| 2026-05-04 | BLOCK 2 | BLOCK 2 전체 완료 (common-core 구현 + 단위 테스트 18개 통과) |
| 2026-05-05 | BLOCK 3 | BLOCK 3 전체 완료 (01-schema.sql/02-data.sql 작성, CP-1 통과 — init 스크립트 실행 순서 보장을 위해 파일명에 숫자 접두사 추가) |
| 2026-05-05 | common-core | ErrorCode enum → interface 리팩토링 + CommonErrorCode enum 신규 (서비스별 에러코드 분리 지원) |
| 2026-05-05 | BLOCK 4 | BLOCK 4 전체 완료 (auth-service 구현, 테스트 28/28 통과, CP-2 auth 통과) |
| 2026-05-06 | BLOCK 5 | BLOCK 5 전체 완료 (user-service 구현, 테스트 17/17 통과, CP-2 user 기동 미검증) |
| 2026-05-06 | BLOCK 6 | BLOCK 6 전체 완료 (todo-service 구현, 테스트 19/19 통과, CP-2 todo 기동 미검증) |
| 2026-05-06 | BLOCK 7 | BLOCK 7 전체 완료 (api-gateway 구현, 테스트 10/10 통과, MDC doFirst 버그 수정) |
