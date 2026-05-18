# PLAN.md — base-msa-template

> 작성일: 2026-05-03
> 문서 버전: v1.8
> 최종 수정: 2026-05-12 (v1.7 대비: 구현 세부사항 제거, 아키텍처 결정 근거 중심 재편, ARCHITECTURE.md 교차 참조 추가)
> 목적: 프로젝트 시 즉시 활용할 수 있는 수준의 MSA 템플릿 구축
> 기준: JDK 21+, Spring Boot 3.5.x, Mono Repo, Multi-Module

---

## 1. 프로젝트 목표

- Spring Boot 3.5 기반 MSA 템플릿을 **즉시 활용 가능한 수준**으로 구축
- 일반적이고 확장성 있는 구조로, 신규 서비스 추가가 쉬운 골격 제공
- 보안·성능·운영 관점의 베스트 프랙티스를 코드와 설정으로 직접 시연
- 로컬 → K8s / Cloud(EKS, AKS 등) 배포까지 고려한 구조

---

## 2. 확정 기술 스택

| 구분 | 기술 | 비고 |
|---|---|---|
| **Runtime** | JDK 21 (Eclipse Temurin) | Virtual Threads 활성화 (`spring.threads.virtual.enabled=true`) |
| **Framework** | Spring Boot 3.5.x | 최신 안정 버전 |
| **Build** | Gradle 8.x (Kotlin DSL) | 버전 카탈로그(libs.versions.toml) |
| **Gateway** | Spring Cloud Gateway (WebFlux) 2025.0.0 | 라우팅, JWT 검증, Rate Limiting, CORS, Security Headers. `spring-cloud-starter-gateway-server-webflux` 사용 |
| **Security** | Spring Security 6.5 + JJWT 0.12.x | RBAC (ROLE_ADMIN / ROLE_USER) |
| **Token Store** | Redis | Refresh Token 저장, Blacklist 관리 |
| **ORM** | MyBatis 3.x (mybatis-spring-boot-starter 3.x) | XML Mapper 방식 |
| **DB** | PostgreSQL 16 | Docker Compose로 로컬 실행, H2 미사용 |
| **Connection Pool** | HikariCP (Spring Boot 내장) | 환경변수 기반 pool size 조정 가능 |
| **API Client** | RestClient (Spring 6.1 내장) | 서비스 간 동기 호출, 별도 의존성 없음 |
| **Circuit Breaker** | Resilience4j | Phase 2 — Phase 1에서 서비스 간 직접 호출 없음 |
| **Lombok** | lombok 1.18.x | `@Getter` `@Builder` `@RequiredArgsConstructor` `@Slf4j` 활용. `@Data` 사용 금지 (equals/hashCode 부작용) |
| **MapStruct** | mapstruct 1.6.x | DTO ↔ 도메인 객체 변환. Lombok annotation processor 순서 주의 (`lombok` → `mapstruct` 순) |
| **Local Cache** | Caffeine | 서비스 내 단기 캐싱 (변경 빈도 낮은 데이터). JVM 로컬 캐시로 Pod 간 공유 불가 — Pod 스케일 아웃 시 캐시 불일치 허용 설계. TTL 짧게 유지 필수. 무효화가 필요한 데이터는 Redis 사용 |
| **Validation** | spring-boot-starter-validation | Bean Validation, GlobalExceptionHandler 연계 |
| **API Docs** | springdoc-openapi 2.x | JWT 인증 적용, 서비스별 API 그룹 |
| **Logging** | SLF4J + Logback | JSON 구조화 로그 (stg/prd), 콘솔 패턴 (local/dev) |
| **Tracing** | Micrometer Tracing + MDC | traceId/spanId 자동 MDC 주입, X-Correlation-ID 필터 |
| **Config** | 환경변수 기반 | .env(로컬) → K8s ConfigMap/Secret |
| **Frontend** | Vanilla JS + Bootstrap CDN | 빌드 도구 없음, 가이드 샘플 목적 |
| **Infra** | Docker Compose | 로컬 통합 실행 (PostgreSQL, Redis 포함) |
| **Dev Env** | VS Code + DevContainer | Java 21 이미지, docker-in-docker |
| **테스트** | Testcontainers | DR-010 Accepted — P2-006에서 `@SpringBootTest` 전환 예정. CI는 GitHub Actions services 블록 interim 유지 |
| **CI** | GitHub Actions | `develop` push → Checkstyle lint only / PR to main → 전체 테스트 (DR-009), `.github/workflows/ci.yml` |
| **Code Quality** | Checkstyle 10.21.0 | Google Java Style + LineLength=120/Indentation=4 오버라이드, 파일 헤더 없음 정책 (DR-004, DR-005) |
| **로그 포맷** | logstash-logback-encoder | stg/prd 환경 JSON 구조화 로그 (§10 참조). `runtimeOnly` 의존성으로 추가 |

---

## 3. 서비스 구성 및 포트

> 서비스 목록·포트·역할 전체 → `docs/PLAN-SUMMARY.md §서비스 포트`
> 서비스 디스커버리: Eureka 미사용. 로컬은 localhost URL, K8s는 서비스명(DNS)으로 대체.

---

## 4. 프로젝트 디렉토리 구조

```
base-msa-template/
├── .devcontainer/
│   ├── devcontainer.json
│   └── docker-compose.devcontainer.yml  # DB/Redis만 기동 (서비스는 VS Code에서 직접 실행)
├── common/
│   └── common-core/                     # 공통 모듈 (§5 참고)
├── services/
│   ├── auth-service/
│   │   └── Dockerfile
│   ├── user-service/
│   │   └── Dockerfile
│   └── todo-service/
│       └── Dockerfile
├── gateway/
│   └── api-gateway/
│       └── Dockerfile
├── frontend/
│   └── web-app/
│       ├── index.html
│       ├── login.html
│       ├── todo.html
│       └── js/
│           ├── api.js                   # fetch 래퍼, JWT 헤더 처리, 401 자동 갱신
│           ├── auth.js                  # 로그인/로그아웃, 토큰 관리
│           └── todo.js                  # 할 일 CRUD UI
├── tests/
│   └── http/                            # API 통합 테스트
│       ├── auth.http                    # 로그인, 토큰 갱신, 로그아웃 (VS Code REST Client)
│       ├── user.http                    # 회원가입, 사용자 CRUD (VS Code REST Client)
│       ├── todo.http                    # 할 일 CRUD (VS Code REST Client)
│       └── e2e-gateway.http             # Gateway 경유 E2E 전체 흐름 (IntelliJ HTTP Client)
├── infra/
│   ├── docker/
│   │   ├── docker-compose.yml           # 전체 스택 통합 실행 (make run)
│   │   └── init-sql/
│   │       ├── 01-schema.sql            # 테이블 DDL (PostgreSQL 방언)
│   │       └── 02-data.sql             # 초기 데이터 (테스트 계정, 샘플 Todo)
│   ├── k8s/                             # 구조만 생성 (Phase 2)
│   │   ├── base/
│   │   │   ├── gateway/
│   │   │   ├── auth-service/
│   │   │   ├── user-service/
│   │   │   └── todo-service/
│   │   └── overlays/
│   │       ├── dev/
│   │       ├── stg/
│   │       └── prd/
│   ├── prometheus/                      # 구조만 생성 (Phase 2)
│   └── grafana/                         # 구조만 생성 (Phase 2)
├── scripts/
│   ├── create-service.sh                # 새 서비스 스캐폴딩 자동화
│   └── Makefile                         # build/run/test/clean 자동화
├── docs/
│   ├── CLAUDE.md                        # Claude Code project operating rules
│   ├── STATUS.md                        # Live project state and active work
│   ├── PLAN.md                          # Approved architecture and plan reference (this file)
│   ├── PLAN-SUMMARY.md                  # 세션 컨텍스트용 기술 스택·포트·Phase 방향 요약
│   ├── ARCHITECTURE.md                  # 아키텍처 다이어그램 및 흐름
│   ├── DEVELOPER-GUIDE.md               # 개발자 가이드 (아키텍처 상세 + 개발 절차)
│   ├── CODING-CONVENTIONS.md            # 코드 컨벤션 SSOT (DR-004, DR-005 반영)
│   ├── backlog/
│   │   ├── PHASE2.md                    # Phase 2 product backlog
│   │   └── HARNESS.md                   # Harness improvement backlog
│   ├── archive/
│   │   ├── docs/works/                  # Archived Work files (path mirrored)
│   │   └── snapshots/                   # Phase/refactor snapshots
│   ├── works/
│   │   ├── README.md                    # Work category and lifecycle guide
│   │   ├── harness/                     # Harness Work files
│   │   ├── phase1/                      # Legacy Phase 1 Work/TODO records
│   │   └── phase2/                      # Phase 2 preparation/product Work files
│   ├── retrospectives/              # 시점별 harness 평가 및 워크플로우 회고 (분기별)
│   └── decisions/
│       ├── DECISION-TEMPLATE.md         # DR 작성 템플릿
│       └── DR-001 ~ DR-010.md           # 기술 결정 기록 (§21 참조)
├── .claude/
│   ├── commands/                        # slash commands (start, work, pick, done 등)
│   ├── rules/                           # path-scoped rules (java-spring.md, testing.md 등)
│   └── settings.json                    # Claude Code 권한·hooks 설정
├── .cursor/
│   └── rules/                           # Cursor AI rules (.mdc 형식, §21 참조)
├── .env.example                         # 환경변수 템플릿 (값 없음, Git 추적)
├── .env                                 # 로컬 실제값 (gitignore)
├── .gitignore
├── settings.gradle.kts                  # 멀티모듈 선언
├── build.gradle.kts                     # 루트 공통 빌드 설정
├── gradle/
│   └── libs.versions.toml               # 버전 카탈로그
└── README.md
```

### docker-compose 파일 역할 구분

| 파일 | 위치 | 용도 | 기동 대상 |
|---|---|---|---|
| `docker-compose.devcontainer.yml` | `.devcontainer/` | DevContainer 개발 환경 | PostgreSQL + Redis만 |
| `docker-compose.yml` | `infra/docker/` | 전체 스택 통합 실행 (`make run`) | 전체 서비스 + PostgreSQL + Redis |

---

## 5. common-core 모듈 구성

### 포함 항목 (경계 명시)

> 패키지 트리 상세 → `docs/ARCHITECTURE.md §5 common-core`

핵심 구성: `response/` (ApiResponse, ErrorResponse, PageResponse), `exception/` (BusinessException, ErrorCode, GlobalExceptionHandler), `logging/` (MdcFilter, LoggingConstants), `security/` (JwtProperties), `mybatis/` (SlowQueryInterceptor — local/dev 전용), `util/` (DateTimeUtils)

### 포함하지 않는 항목

| 항목 | 이유 |
|---|---|
| JWT 발급/검증 로직 | auth-service 전담 |
| Redis 연동 코드 | 서비스마다 용도 상이 |
| MyBatis 설정 | 각 서비스 독립 DataSource |
| Spring Security Config | 서비스마다 보안 정책 상이 |
| 도메인 모델 (User, Todo 등) | 도메인은 각 서비스 소유 |
| Swagger/OpenAPI 설정 | 서비스마다 그룹·설명 상이 |
| RestClient 설정 | 호출 대상이 서비스마다 상이 |

> **원칙**: "모든 서비스가 무조건 필요한 것만" 포함. 하나라도 의문이 생기면 넣지 않는다.

---

## 6. 환경(Profile) 구성

### 프로파일 체계

| 프로파일 | 용도 | DB | 로그 레벨 | 로그 포맷 | Swagger UI |
|---|---|---|---|---|---|
| `local` | 개발자 로컬 실행 | PostgreSQL (로컬 Docker) | DEBUG | 콘솔 패턴 | ✅ 활성 |
| `dev` | 개발 서버 / DevContainer | PostgreSQL (로컬 Docker) | DEBUG | 콘솔 패턴 | ✅ 활성 |
| `stg` | 스테이징 서버 | PostgreSQL (외부) | INFO | JSON 구조화 | ❌ 비활성 |
| `prd` | 프로덕션 | PostgreSQL (외부) | WARN | JSON 구조화 | ❌ 비활성 |

### 환경변수 기반 Config 원칙

- 민감정보(JWT_SECRET, DB_PASSWORD 등)는 환경변수에서만 주입 — 기본값 절대 금지 (값 없으면 기동 실패, 의도적 설계)
- 비민감 항목(REDIS_PORT, DB_POOL_MAX 등)은 기본값 허용
- HikariCP pool size: Virtual Threads 환경에서 이 값이 실질적 DB 동시 처리 상한선. VT는 수천 개 동시 생성 가능 → pool 대기 큐 적체 가능. 고부하 Phase 2 전환 시 서비스별 트래픽 기준 재조정 필요

**K8s 환경변수 분류:**
- `ConfigMap` (비민감): SPRING_PROFILES_ACTIVE, SERVER_PORT, REDIS_HOST, DB_URL 등
- `Secret` (민감): JWT_SECRET, DB_PASSWORD, DB_USERNAME, REDIS_PASSWORD 등

> `.env.example` 전체 변수 목록 → 프로젝트 루트 `.env.example` 참조

---

## 7. 데이터베이스 전략

### PostgreSQL 단일화 (H2 미사용)

- 처음부터 PostgreSQL로 실제 운영 환경과 동일하게 검증
- SQL 방언 차이로 인한 전환 비용 제거 (MyBatis XML 쿼리를 PostgreSQL 방언으로 작성)
- `01-schema.sql` + `02-data.sql`은 PostgreSQL init 스크립트(`/docker-entrypoint-initdb.d`)로 자동 실행
  > **파일명 규칙**: 알파벳 순 실행 특성상 `data.sql`(d)이 `schema.sql`(s)보다 먼저 실행됨. 숫자 접두사(`01-`, `02-`)로 순서 보장.

### DB 진화 경로

```
Phase 1 (현재): 모든 서비스가 단일 PostgreSQL 공유
Phase 2:        서비스별 PostgreSQL 분리 (DB per Service 원칙 적용)
Phase 3 (K8s):  관리형 DB (RDS, Cloud SQL 등) 또는 서비스별 StatefulSet
```

> **updated_at 자동 갱신**: `DEFAULT NOW()`는 INSERT 시에만 적용된다. UPDATE 시 자동 갱신을
> 위해 `01-schema.sql`에 `update_updated_at_column()` PostgreSQL 트리거 함수를 추가한다.
> (→ legacy Phase 1 note: `docs/TODO/PHASE1/TODO-BLOCK3.md §3-2`; archive/migration policy is tracked by HRN-006)
>
> **Phase 1 설계 원칙**: DB 분리를 고려하여 서비스 간 테이블에 FK 제약조건을 사용하지 않는다.
> `todos.user_id`는 `users.id`에 대한 **논리적 참조**로만 유지하며, 참조 무결성은 애플리케이션 레이어에서 보장한다.
> 이를 통해 Phase 2 DB 분리 시 스키마 변경 없이 전환 가능하다.

### Multi DataSource 준비 전략

Phase 1에서는 모든 서비스가 단일 DataSource를 공유하지만, Phase 2 전환 비용 최소화를 위해:

- 서비스별 독립 환경변수(`DB_URL`, `DB_USERNAME`, `DB_PASSWORD`)로 선언 — Phase 2 전환 시 값만 교체
- 서비스 간 테이블 직접 JOIN 금지
- 다른 서비스 소유 테이블 참조 시 반드시 API 호출로 대체
- `@Primary` / `@Qualifier` / `AbstractRoutingDataSource` 구성은 Phase 2에서 추가

### 초기 데이터 (02-data.sql)

| 계정 | 비밀번호 | 역할 | 용도 |
|---|---|---|---|
| `admin` | `admin` | `ROLE_ADMIN` | 관리자 기능 테스트 |
| `user` | `user` | `ROLE_USER` | Todo CRUD + 페이징 테스트 (메인) |
| `user2` | `user2` | `ROLE_USER` | 타인 소유권 테스트 + 사용자 페이징 더미 |
| `user3` | `user3` | `ROLE_USER` | 사용자 페이징 더미 |
| `user4` | `user4` | `ROLE_USER` | 사용자 페이징 더미 |

> **페이징 재현을 위한 최소 데이터 근거**
> - `GET /users?page=0&size=3`: 5명 → page=0: 3명, page=1: 2명 (totalPages=2 검증)
> - `GET /todos?page=0&size=5`: user 계정 8건 → page=0: 5건, page=1: 3건 (totalPages=2 검증)
> - `GET /todos?completed=true`: 초기 completed=true 항목이 없으면 필터 테스트 불가

**Todo 초기 데이터 수량**

| 계정 | 건수 | completed=false | completed=true | 비고 |
|---|---|---|---|---|
| `admin` | 3건 | 2건 | 1건 | 관리자 기본 샘플 |
| `user` | **8건** | 5건 | **3건** | 페이징(size=5)·필터 테스트 필수 |
| `user2` | 2건 | 2건 | 0건 | 타인 소유권 테스트용 |

- 비밀번호는 평문이 아닌 **BCrypt(strength 12) 해시값**으로 02-data.sql에 삽입
- `todos.user_id` 삽입 시 하드코딩 대신 **서브셀렉트** 사용 (ID 순서 의존 방지)
  ```sql
  INSERT INTO todos (user_id, title, description, completed)
  SELECT id, '제목', '설명', false FROM users WHERE username = 'user';
  ```
- 테스트 계정은 `local` / `dev` 프로파일 전용 (stg/prd 02-data.sql 미포함)

---

## 8. 인증/인가 설계

### JWT 클레임 구조

```
Access Token 클레임:
  sub  : userId
  role : ROLE_USER | ROLE_ADMIN
  type : "access"          ← 토큰 종류 구분 (token confusion attack 방어)
  jti  : UUID              ← Blacklist 조회 키
  iat  : 발급 시각
  exp  : 발급 시각 + 15분

Refresh Token 클레임:
  sub  : userId
  type : "refresh"         ← 토큰 종류 구분
  jti  : UUID
  iat  : 발급 시각
  exp  : 발급 시각 + 7일

검증 규칙:
  Gateway JwtAuthFilter — API 요청 시 type == "access" 강제. "refresh"이면 401 반환
  auth-service /refresh  — type == "refresh" 강제. "access"이면 401 반환
```

### JWT 흐름 및 Redis 키 구조

> 인증 흐름 다이어그램 (login / refresh / logout) → `docs/ARCHITECTURE.md §3 인증 흐름`
> Redis 키 구조 상세 (`rt:`, `bl:`, `rl:`) → `docs/ARCHITECTURE.md §8 Redis 데이터 구조`

**핵심 설계 결정:**
- Refresh Token Rotation: 사용 즉시 폐기 + 재발급. 탈취 의심(Redis에 키 없음) 시 해당 userId 전체 세션 무효화
- deviceId: 클라이언트가 최초 로그인 시 생성한 UUID — 서버는 검증만, 발급 주체는 클라이언트
- Phase 1: 프론트엔드 샘플은 단일 deviceId만 사용. 복수 디바이스 관리 UI는 Phase 2 추가 예정

### RBAC

- 역할: `ROLE_ADMIN`, `ROLE_USER` (Phase 1 고정)
- 권한 제어: Gateway 레벨(경로 기반) + 서비스 레벨(`@PreAuthorize`) 이중 적용
- 확장 설계: 리소스+액션 기반 퍼미션은 Phase 2 TODO

### Gateway 내부 네트워크 신뢰 모델

- Phase 1: Gateway에서 JWT 검증 후 `X-User-Id`, `X-User-Role` 헤더로 하위 서비스 전달
- 하위 서비스는 헤더를 신뢰하며 JWT 재검증을 수행하지 않음 (내부 네트워크 신뢰 가정)
- **Phase 2 보완 계획**: K8s 환경 배포 시 NetworkPolicy로 Gateway → Service 직접 통신만 허용,
  외부에서 하위 서비스 포트로의 직접 접근 차단

### 비밀번호 정책

- 인코더: `BCryptPasswordEncoder` (strength: 12)
- 최소 길이: 8자 이상
- 복잡도: 영문 + 숫자 조합 필수
- Bean Validation `@Pattern` 어노테이션으로 입력 시 검증
- 단, 초기 테스트 계정(admin/user)은 정책 예외 처리 (개발 편의)

---

## 9. API 버전 관리

- **전략**: URL Path Versioning (`/api/v1/`)
- 모든 엔드포인트에 `/api/v1/` prefix 적용 (Gateway 라우팅 기준)
- 버전 업 시 `/api/v2/` 경로 추가, 이전 버전 병행 운영 후 deprecated 처리

```
POST   /api/v1/auth/login                     # 로그인 (공개)
POST   /api/v1/auth/refresh                   # 토큰 갱신 (공개)
POST   /api/v1/auth/logout                    # 로그아웃 (인증 필요)

GET    /api/v1/users                          # 사용자 목록 조회 (ADMIN 전용, ?page=0&size=20)
POST   /api/v1/users                          # 회원가입 (공개)
GET    /api/v1/users/{id}                     # 사용자 단건 조회 (본인 또는 ADMIN)
PATCH  /api/v1/users/{id}                     # 사용자 정보 수정 (본인 또는 ADMIN, 선택적 필드)
DELETE /api/v1/users/{id}                     # 사용자 삭제 (ADMIN 전용)

GET    /api/v1/todos                          # 내 할 일 목록 (?page=0&size=20&completed=)
POST   /api/v1/todos                          # 할 일 생성
GET    /api/v1/todos/{id}                     # 할 일 단건 조회
PUT    /api/v1/todos/{id}                     # 할 일 전체 수정
PATCH  /api/v1/todos/{id}/complete            # 완료 상태 토글
DELETE /api/v1/todos/{id}                     # 할 일 삭제
```

---

## 10. Logging & Tracing 설계

### 전략

- **Micrometer Tracing**: `traceId` / `spanId` 자동 MDC 주입 (Spring Boot 3.5 내장)
- **X-Correlation-ID**: Gateway에서 생성/전파, 각 서비스 `MdcFilter`에서 수신 및 MDC 저장
- **로그 포맷**: JSON 구조화 (stg/prd), 콘솔 패턴 (local/dev)

### 로그 패턴 및 설정

> logback-spring.xml 프로파일별 구조, WebFlux MDC 주의사항 → `docs/ARCHITECTURE.md §11 Logging & Tracing`

의존성: `runtimeOnly(libs.logstash.logback.encoder)` — stg/prd JSON 구조화 로그 필수

### 민감정보 마스킹 원칙

- `Authorization` 헤더 전체: 로그 출력 금지
- 비밀번호, 토큰 전체값: 로그 출력 금지
- 이메일, 전화번호: 마스킹 처리 (예: `a***@example.com`)
- Request/Response 로깅 필터에서 위 항목 자동 마스킹 적용

**마스킹 대상 필드 목록 (전 서비스 공통)**

| 필드 | 마스킹 방식 |
|------|------------|
| `password` | `"****"` 고정 |
| `email` | `a***@example.com` |
| `phone` | `010-****-1234` |
| `accessToken` | 앞 10자 + `...` |
| `refreshToken` | 앞 10자 + `...` |
| `Authorization` 헤더 | 전체 출력 금지 |

### SQL 로깅 설계 (local / dev 전용)

- local/dev: MyBatis + JDBC 바인딩 파라미터 DEBUG 출력
- stg/prd: `org.mybatis`, `org.springframework.jdbc.core` → `OFF` (민감정보 보호)
- `SlowQueryInterceptor`: local/dev 전용, 100ms 초과 쿼리 WARN 로깅, 민감 필드 마스킹 후 출력

---

## 11. 에러 코드 체계

### 코드 형식

```
{서비스 PREFIX}-{4자리 숫자}
예: AUTH-0001, USER-0001, TODO-0001, COMMON-0001
```

### 공통 에러 코드 (CommonErrorCode enum — ErrorCode interface 구현체)

| 코드 | HTTP Status | 설명 |
|---|---|---|
| `COMMON-0001` | 400 | 잘못된 요청 파라미터 |
| `COMMON-0002` | 400 | 입력값 유효성 검증 실패 |
| `COMMON-0003` | 401 | 인증 필요 |
| `COMMON-0004` | 403 | 권한 없음 |
| `COMMON-0005` | 404 | 리소스 없음 |
| `COMMON-0006` | 500 | 서버 내부 오류 |

### 서비스별 에러 코드 (각 서비스 정의)

```
AUTH-0001: 로그인 실패 (아이디/비밀번호 불일치)
AUTH-0002: 토큰 만료
AUTH-0003: 유효하지 않은 토큰
AUTH-0004: 블랙리스트 토큰 (로그아웃된 토큰)
AUTH-0005: Refresh Token 없음 (탈취 의심 — 전체 세션 무효화)

USER-0001: 이미 존재하는 이메일
USER-0002: 사용자 없음
USER-0003: 비밀번호 정책 불일치

TODO-0001: 할 일 없음
TODO-0002: 본인 소유 아님 (권한 없음)
```

---

## 12. API 테스트 파일 구성

위치: `tests/http/` (auth.http, user.http, todo.http, e2e-gateway.http)

- VS Code REST Client 형식 (`auth.http`, `user.http`, `todo.http`) + IntelliJ HTTP Client 형식 (`e2e-gateway.http`)
- 모든 요청은 Gateway(8090) 경유 (`/api/v1/` prefix), 성공/실패 케이스 구분 주석 포함
- `auth.http` 로그인 응답에서 토큰 변수 추출 → 이후 파일에서 재사용

---

## 13. API 문서화 (springdoc-openapi)

- 일반 서비스: `springdoc-openapi-starter-webmvc-ui`
- Gateway: `springdoc-openapi-starter-webflux-ui`
- 모든 서비스: Swagger UI에 JWT Bearer 인증 적용
- API 그룹: 서비스별 `GroupedOpenApi` Bean 정의
- Swagger UI는 `local` / `dev` 프로파일에서만 활성화 (`stg`/`prd` 비활성)

---

## 14. 테스트 전략

| 레벨 | 도구 | 대상 | 비고 |
|---|---|---|---|
| 단위 테스트 | JUnit 5 + Mockito | 서비스 레이어, 유틸 | 외부 의존성 Mock |
| 슬라이스 테스트 | `@WebMvcTest` | 컨트롤러 레이어 | Security 슬라이스 포함 |
| MyBatis 테스트 | `@MybatisTest` | Mapper XML | Testcontainers PostgreSQL |
| 통합 테스트 | `@SpringBootTest` + Testcontainers | 전체 흐름 | PostgreSQL + Redis 컨테이너 |
| API 테스트 | `.http` 파일 | 각 엔드포인트 (Gateway 경유) | `tests/http/` 디렉토리 |

> **Testcontainers 전환 계획 (DR-010 Accepted)**:
> P2-006에서 `@SpringBootTest` 통합 테스트를 Testcontainers 기반으로 전환.
> 전환 전까지 CI는 GitHub Actions `services` 블록(PostgreSQL/Redis)으로 interim 운영.
> 전환 완료 후 `services` 블록 제거.

> **CI 단계별 테스트 실행 (DR-009)**:
> `develop` push: Checkstyle lint만 실행 (`./gradlew checkstyleMain checkstyleTest`)
> PR to main: 전체 테스트 실행 (`./gradlew test`)

> **Phase 2**: CI/CD 연동 자동화 테스트 필요 시 RestAssured 도입 검토 (Phase 2 백로그 참고)

### TestFixture 전략 (전 서비스 공통)

- `common-core`의 `src/test/java` 하위에 `TestFixture` 클래스 구현
- 전 서비스 테스트에서 재사용 가능한 도메인 객체 팩토리 메서드 제공
- `@Sql` 어노테이션보다 `TestFixture` + `@BeforeEach` 조합 우선 사용

```java
public class TestFixture {
    public static User adminUser() { return User.builder()... }
    public static User regularUser() { return User.builder()... }
    public static Todo sampleTodo(Long userId) { return Todo.builder()... }
}
```

---

## 15. K8s / Cloud 배포 준비 사항

> 멀티스테이지 Dockerfile, Actuator Health Probe YAML, K8s Probe 설정, Graceful Shutdown 설정 → `docs/ARCHITECTURE.md §14 K8s 배포`

**설계 결정 근거:**
- management port(8099) 분리: 외부 Gateway에서 `/actuator/**` 차단 가능 (보안)
- Graceful Shutdown (`timeout-per-shutdown-phase: 30s`): K8s pod 교체 시 in-flight 요청 안전 처리
- liveness/readiness 프로브 분리: 재시작 vs 트래픽 차단 정책 독립 설정

### 서비스 URL 환경별 전략

```
local/dev : http://localhost:{port}          (application-local.yml 직접 명시)
K8s       : http://{service-name}:{port}     (K8s DNS, 환경변수로 주입)
```

---

## 16. Secure Coding 체크리스트

| 항목 | 내용 | 적용 위치 |
|---|---|---|
| JWT Secret | 256bit 이상 랜덤, 환경변수 전용, 기본값 금지 | auth-service |
| Refresh Token Rotation | 사용 즉시 폐기 + 재발급, 탈취 감지 시 전체 세션 무효화 | auth-service |
| Refresh Token 키 구조 | `rt:{userId}:{deviceId}` — 멀티 디바이스 세션 독립 관리 | auth-service (Redis) |
| JWT Blacklist | 로그아웃 시 Access Token Redis 저장 (TTL = 잔여 만료시간) | auth-service + Gateway |
| MyBatis `#{}` 강제 | `${}` 사용 시 화이트리스트 검증 필수, XML 주석 가이드 포함 | 각 서비스 Mapper XML |
| 민감정보 로그 마스킹 | Authorization 헤더, 비밀번호, 토큰 전체값 출력 금지 | MdcFilter, 로깅 설정 |
| Rate Limiting 차등 | 인증 API: 5 req/sec / 일반 API: 100 req/sec | Gateway |
| CORS 중앙 관리 | Gateway에서만 설정, `ALLOWED_ORIGINS` 환경변수 | Gateway |
| Security Headers | `X-Content-Type-Options`, `X-Frame-Options`, `X-XSS-Protection` | Gateway 필터 |
| HTTPS / HSTS | stg/prd 환경: `Strict-Transport-Security` 헤더 적용 | Gateway (프로파일 조건) |
| Actuator 보안 | management port(8099) 분리, Gateway에서 `/actuator/**` 외부 차단 | 전 서비스, Gateway |
| SQL Injection 방어 | MyBatis `#{}` 원칙, ORDER BY 동적 처리 시 화이트리스트 | Mapper XML |
| 비밀번호 정책 | BCrypt strength 12, 최소 8자, 영문+숫자 조합 필수 (테스트 계정 예외) | user-service |
| Bean Validation | `@Valid` + `MethodArgumentNotValidException` → GlobalExceptionHandler | 전 서비스, common-core |
| Swagger UI 접근 제한 | `local` / `dev` 프로파일에서만 활성화 | 각 서비스 application-{profile}.yml |
| JWT 토큰 타입 검증 | Access Token: `type == "access"` 강제 (Gateway). Refresh Token: `type == "refresh"` 강제 (auth-service /refresh). token confusion attack 방어 | Gateway `JwtAuthFilter`, auth-service `JwtTokenProvider` |
| 내부 네트워크 보안 | Phase 1: 내부 신뢰 모델 / Phase 2: K8s NetworkPolicy 적용 | K8s 환경 (Phase 2) |
| Upstream 헤더 제거 | Gateway `UserContextFilter`에서 `X-User-Id`, `X-User-Role` 주입 전 외부 유입 헤더 강제 제거 (Header spoofing 방어) | Gateway `UserContextFilter` |
| Redis Blacklist fail 정책 | Redis 장애 시 동작 정책을 환경변수(`BLACKLIST_FAIL_POLICY`)로 명시: `fail-open`(통과) 또는 `fail-close`(차단, 기본값) | Gateway `JwtAuthFilter` |
| Caffeine 로컬 캐시 | JVM 내 단기 캐싱 (`@Cacheable`). 민감 데이터(토큰, 비밀번호) 캐싱 금지. TTL 명시 필수 (기본값 사용 금지) | 각 서비스 (필요 시) |

---

## 17. Frontend (Vanilla JS)

- **목적**: 백엔드 API 연동 가이드 샘플 (빌드 도구 없음)
- **구성**: HTML + Vanilla JS + Bootstrap CDN
- **위치**: `frontend/web-app/` (독립 디렉토리, Gateway와 분리)
- **서빙**: `python3 -m http.server 3000` 또는 `npx serve`

| 파일 | 역할 |
|---|---|
| `api.js` | fetch 래퍼, JWT 헤더 자동 첨부, 401 시 자동 토큰 갱신 |
| `auth.js` | 로그인/로그아웃, localStorage 토큰 관리, deviceId 생성/보관 |
| `todo.js` | 할 일 CRUD UI |

---

## 18. 개발 자동화 (scripts)

> Makefile 타겟 목록 및 `create-service.sh` 사용법 → `README.md §개발 자동화`

---

## 19. 구현 단계 (Phase)

### Phase 1 — 골격 구축 ✅ 완료 (2026-05)

> 상세 체크리스트 → `docs/archive/phase1-plan.md`

### Phase 2 — 운영 준비 (진행 중)

**P0 즉시 착수 (backlog 참조: `docs/backlog/PHASE2.md`)**
- [ ] [P2-006] Testcontainers 도입 — `@SpringBootTest` 통합 테스트 자급자족화 (DR-010 Accepted)
- [ ] [P2-001] Security hardening — token storage HttpOnly Cookie, Redis session index (DR-003, OQ-003)
- [ ] [P2-002] Gateway IP rate limiting + Trusted Proxy 설정

**P1 다음 단계 (PRE-B/C 완료 후)**
- [ ] [PRE-B] 개발환경 전략 결정 (로컬 실행 구조, Windows 지원, devcontainer, mono-repo)
- [ ] [PRE-C1/C2] Phase 1 아키텍처 현황 분석 + Phase 2 요건 정의 확정 (DR-001 완료)
- [ ] [P2-004] K8s 배포 도구 결정 (DR-002 Draft → Accepted 필요)
- [ ] [P2-005] K8s manifests baseline — DR-002 결정 후 착수
- [ ] [P2-007] Prometheus + Grafana observability baseline
- [ ] [P2-008] Resilience4j Circuit Breaker — 서비스 간 RestClient 호출 발생 시
- [ ] K8s NetworkPolicy 적용 — Gateway → Service 직접 통신만 허용

**P2 장기**
- [ ] 서비스별 PostgreSQL 분리 (DB per Service) — Phase 1 FK 미사용 설계 기반
- [ ] 분산 트랜잭션 전략 수립 (Saga 패턴 / Outbox 패턴)
- [ ] 복잡 RBAC (리소스+액션 기반 퍼미션)
- [ ] 서비스 간 내부 인증 전략 수립
- [ ] 멀티 디바이스 세션 관리 UI 추가

---

## 20. 미결 사항 (결정 보류)

| 항목 | 내용 | DR |
|---|---|---|
| K8s 배포 도구 | Helm vs Kustomize — manifests 작성 전 결정 필요 | DR-002 Draft |
| token storage 전환 | localStorage → HttpOnly Cookie — frontend/auth 변경 전 결정 필요 | OQ-003 Open |
| 복잡 RBAC | 리소스+액션 기반 퍼미션 → Phase 2 중후반 결정 | — |
| 메시지 큐 | Kafka / RabbitMQ 도입 여부 → Phase 2에서 결정 | — |
| 서비스 간 인증 | 내부 호출 시 토큰 전략 (서비스 계정 JWT 등) → Phase 2에서 결정 | — |
| 분산 트랜잭션 | Saga vs Outbox 패턴 선택 → Phase 2 중후반 결정 | — |

---

## 21. 개발 도구 및 AI Workflow 구조

Phase 2부터 Claude Code / Cursor 기반 AI workflow를 적극 활용한다.

### Claude Code 도구 (`.claude/`)

| 파일 | 용도 |
|---|---|
| `commands/start.md` | 세션 시작 — STATUS.md Current State / Active Work / Next Actions 빠른 확인 |
| `commands/work.md` | 작업 착수 — backlog에서 항목 선택하고 진행 계획 수립 |
| `commands/pick.md` | 다음 작업 후보 검토 — 우선순위 기준으로 착수 가능한 항목 제안 |
| `commands/done.md` | 세션 종료 — 완료 요약, STATUS.md 업데이트, DR 제안 |
| `commands/record-decision.md` | DR 즉시 기록 — 확정 결정을 `docs/decisions/DR-XXX.md`로 저장 |
| `commands/health.md` | 워크플로우·문서 건강 상태 점검 (Quick/Full 모드) |
| `rules/java-spring.md` | Java·Spring Boot 코딩 규칙 (glob: `*.java`, `*.kts`) |
| `rules/testing.md` | 테스트 작성 규칙 (glob: `**/src/test/**/*.java`) |
| `rules/git-workflow.md` | 커밋 전 체크리스트 강제 (alwaysApply) |
| `rules/infra.md` | 인프라·Docker·K8s 변경 안전 규칙 |
| `settings.json` | 권한 허용 목록, hooks 설정 |

### Cursor AI rules (`.cursor/rules/`)

| 파일 | `alwaysApply` | 용도 |
|---|---|---|
| `role-backend.mdc` | true | 백엔드 엔지니어 역할 및 프로젝트 컨텍스트 |
| `coding.mdc` | true | 핵심 코딩 원칙 (최소·가역적 변경) |
| `execution.mdc` | true | 빌드·테스트·검증 명령어 및 CI 구조 |
| `output-format.mdc` | true | 응답 구조 (결론 → 변경 → Verification → Risk) |
| `safety-critical.mdc` | true | 파괴적·권한 필요 작업 안전 제한 |
| `java-spring.mdc` | false (glob) | Java·Spring Boot 규칙 (`.java`, `*.kts` 대상) |
| `testing.mdc` | false (glob) | 테스트 작성 규칙 (`**/src/test/**/*.java` 대상) |
| `git-commit.mdc` | false (on-demand) | git commit 요청 시 커밋 절차 |
| `debugging.mdc` | false (on-demand) | 디버깅·오류 추적 절차 |

### 코드 컨벤션 SSOT

- `docs/CODING-CONVENTIONS.md` — 전 규칙의 단일 진실 출처
- `config/checkstyle/checkstyle.xml` — Checkstyle 설정 파일 (DR-005)
- `.editorconfig` — 에디터 포맷 기준
- `tools/git-hooks/pre-commit` — 커밋 전 Checkstyle 자동 실행

### 기술 결정 기록 (Decision Records)

`docs/decisions/DR-XXX.md` 형식. DR-worthy 기준은 `docs/AGENT-WORKFLOW.md` 요약과 `docs/harness-protocol/05-triggers-and-cascade.md`를 참조한다.

| DR | 결정 내용 | Status |
|---|---|---|
| DR-001 | Phase 2 요건 정의 | Draft |
| DR-002 | K8s 배포 도구 선택 (Helm vs Kustomize) | Draft |
| DR-003 | Phase 2 Security hardening 우선 | Accepted |
| DR-004 | 파일 헤더 없음 정책 | Accepted |
| DR-005 | Checkstyle 채택 (Google Style 기반) | Accepted |
| DR-006 | CI job 분리 구조 | Accepted |
| DR-007 | 파일 유형별 언어 원칙 | Accepted |
| DR-008 | docs/ 파일명 대소문자 표준 | Accepted |
| DR-009 | CI trigger 분리 (develop=lint, PR to main=전체) | Accepted |
| DR-010 | 통합 테스트 인프라 — Testcontainers 채택 | Accepted |

---

## 문서 관계

| 문서 | 역할 |
|---|---|
| `docs/PLAN.md` (이 문서) | 아키텍처 결정 근거 (WHY) + Phase 로드맵 |
| `docs/ARCHITECTURE.md` | 다이어그램 중심 아키텍처 레퍼런스 (Mermaid, 흐름도) |
| `docs/PLAN-SUMMARY.md` | 세션 컨텍스트용 요약 (기술 스택, 포트, 핵심 결정) |
| `docs/DEVELOPER-GUIDE.md` | 개발자 온보딩 + HOW (설정법, 실행법, 패턴 예시) |
| `docs/CODING-CONVENTIONS.md` | 코딩 컨벤션 SSOT |
