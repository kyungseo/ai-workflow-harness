# PLAN.md — base-msa-template

> 작성일: 2026-05-03
> 문서 버전: v1.6
> 최종 수정: 2026-05-07 (ErrorCode enum→interface 반영, PATCH 수정, e2e-gateway.http 형식 명시, Spring Cloud 2025.0.0 반영)
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
| **테스트** | Testcontainers | `@MybatisTest` + `@SpringBootTest` 통합 테스트에서 PostgreSQL/Redis 컨테이너 기동 |
| **로그 포맷** | logstash-logback-encoder | stg/prd 환경 JSON 구조화 로그 (§10 참조). `runtimeOnly` 의존성으로 추가 |

---

## 3. 서비스 구성 및 포트

| 서비스 | 포트 | 역할 |
|---|---|---|
| `api-gateway` | 8090 | 단일 진입점, 라우팅, 인증/인가, Rate Limiting |
| `auth-service` | 8091 | JWT 발급/갱신/블랙리스트, 로그인/로그아웃 |
| `user-service` | 8092 | 회원가입, 사용자 CRUD, RBAC 권한 관리 |
| `todo-service` | 8093 | 할 일 CRUD (가이드 샘플) |
| `PostgreSQL` | 5432 | 공유 DB (Phase 1), DB per Service는 Phase 2 |
| `Redis` | 6379 | Refresh Token, Blacklist, Rate Limiting |
| `Actuator` | 8099 | management port 분리 (외부 노출 차단) |
| `Frontend` | 3000 | Vanilla JS 독립 서빙 (python http.server / npx serve) |

> **서비스 디스커버리**: Eureka 미사용. 로컬은 localhost URL, K8s는 서비스명(DNS)으로 대체.

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
│   ├── CLAUDE.md                        # Claude Code 진입점 (운영 규칙, 참조 맵)
│   ├── STATUS.md                        # 진행 상태 트래킹 (단일 진실 공급원)
│   ├── PLAN.md                          # 이 문서 (설계 결정 및 기술 원칙 전체)
│   ├── ARCHITECTURE.md                  # 아키텍처 다이어그램 및 흐름
│   ├── DEVELOPER-GUIDE.md               # 개발자 가이드 (아키텍처 상세 + 개발 절차)
│   ├── TODO/
│   │   ├── PHASE1/
│   │   │   ├── TODO-BLOCK1.md           # 프로젝트 골격
│   │   │   ├── TODO-BLOCK2.md           # common-core
│   │   │   ├── TODO-BLOCK3.md           # 도메인 모델 + 01-schema.sql / 02-data.sql
│   │   │   ├── TODO-BLOCK4.md           # auth-service
│   │   │   ├── TODO-BLOCK5.md           # user-service
│   │   │   ├── TODO-BLOCK6.md           # todo-service
│   │   │   ├── TODO-BLOCK7.md           # api-gateway
│   │   │   ├── TODO-BLOCK8.md           # Dockerfile + 통합 테스트
│   │   │   ├── TODO-BLOCK9.md           # Frontend
│   │   │   └── TODO-BLOCK10.md          # 문서화 및 마무리
│   │   └── PHASE2/
│   └── decisions/
│       └── PHASE2-BACKLOG.md            # Phase 2 백로그 (Phase 1 중 격리)
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

```
common-core/src/main/java/io/kyungseo/msa/common/
├── response/
│   ├── ApiResponse<T>          # 공통 응답 래퍼 { code, message, data }
│   ├── ErrorResponse           # 에러 응답 { code, message, errors[] }
│   └── PageResponse<T>         # 페이징 응답 래퍼 { content, page, size, totalElements, totalPages }
├── exception/
│   ├── BusinessException       # 비즈니스 예외 베이스 클래스
│   ├── ErrorCode               # 에러 코드 interface (§11 에러 코드 체계 참고)
│   ├── CommonErrorCode         # 공통 에러 코드 enum (COMMON-0001~0006, ErrorCode 구현체)
│   └── GlobalExceptionHandler  # @RestControllerAdvice
│                               #   - MethodArgumentNotValidException 처리 포함
│                               #   - BusinessException 처리 포함
├── logging/
│   ├── MdcFilter               # X-Correlation-ID 추출/생성 → MDC 저장
│   └── LoggingConstants        # MDC key 상수 정의
├── security/
│   └── JwtProperties           # JWT 설정값 @ConfigurationProperties 바인딩
├── mybatis/
│   └── SlowQueryInterceptor    # 100ms 초과 쿼리 WARN 로깅 (@Profile local/dev 전용)
├── mapper/ (선택적)
│   └── BaseMapper<S, T>        # MapStruct 공통 변환 인터페이스
└── util/
    └── DateTimeUtils           # 날짜 포맷 유틸
```

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

### 설정 파일 구조 (각 서비스 공통 패턴)

```
src/main/resources/
├── application.yml           # 공통 설정 (프로파일 무관)
├── application-local.yml     # 로컬 전용
├── application-dev.yml       # 개발 서버 전용
├── application-stg.yml       # 스테이징 전용
└── application-prd.yml       # 프로덕션 전용
```

### 환경변수 기반 Config 원칙

```yaml
# application.yml — 민감정보는 기본값 없이 환경변수에서만 주입
# 값 없으면 기동 실패 → 의도적 설계 (보안)
spring:
  threads:
    virtual:
      enabled: true                  # JDK 21 Virtual Threads 활성화
  datasource:
    url: ${DB_URL}
    username: ${DB_USERNAME}
    password: ${DB_PASSWORD}
    hikari:
      maximum-pool-size: ${DB_POOL_MAX:10}    # Virtual Threads 환경 주의: 이 값이 실질적 DB 동시 처리 상한선
                                              # VT는 수천 개 동시 생성 가능 → pool 대기 큐 적체 가능성
                                              # 고부하 Phase 2 전환 시 서비스별 트래픽 기준으로 재조정
      minimum-idle: ${DB_POOL_MIN:5}
      connection-timeout: ${DB_CONN_TIMEOUT:30000}
      idle-timeout: 600000
      max-lifetime: 1800000
  data:
    redis:
      host: ${REDIS_HOST}
      port: ${REDIS_PORT:6379}        # 비민감 항목은 기본값 허용
jwt:
  secret: ${JWT_SECRET}              # 기본값 절대 금지
  access-token-expiry: ${JWT_ACCESS_EXPIRY:900}
  refresh-token-expiry: ${JWT_REFRESH_EXPIRY:604800}
management:
  server:
    port: 8099                        # Actuator 전용 포트 분리
```

### 로컬 환경변수 관리

```bash
# .env.example (Git 추적, 값 없음 — 온보딩 가이드 역할)
SPRING_PROFILES_ACTIVE=local
JWT_SECRET=
DB_URL=jdbc:postgresql://localhost:5432/msa_db
DB_USERNAME=
DB_PASSWORD=
DB_NAME=msa_db
DB_POOL_MAX=10
DB_POOL_MIN=5
DB_CONN_TIMEOUT=30000
REDIS_HOST=localhost
REDIS_PORT=6379
ALLOWED_ORIGINS=http://localhost:3000
BLACKLIST_FAIL_POLICY=fail-close

# .env (Git 제외, 실제값 기입)
SPRING_PROFILES_ACTIVE=local
JWT_SECRET=your-256bit-random-secret-here
DB_USERNAME=msa_user
DB_PASSWORD=msa_pass
...
```

### K8s 환경변수 분류

```
ConfigMap (비민감):
  SPRING_PROFILES_ACTIVE, SERVER_PORT, REDIS_HOST, REDIS_PORT,
  DB_URL, SERVICE_URL 등

Secret (민감):
  JWT_SECRET, DB_PASSWORD, DB_USERNAME, REDIS_PASSWORD 등
```

---

## 7. 데이터베이스 전략

### PostgreSQL 단일화 (H2 미사용)

- 처음부터 PostgreSQL로 실제 운영 환경과 동일하게 검증
- SQL 방언 차이로 인한 전환 비용 제거 (MyBatis XML 쿼리를 PostgreSQL 방언으로 작성)
- `01-schema.sql` + `02-data.sql`은 PostgreSQL init 스크립트(`/docker-entrypoint-initdb.d`)로 자동 실행
  > **파일명 규칙**: 알파벳 순 실행 특성상 `data.sql`(d)이 `schema.sql`(s)보다 먼저 실행됨. 숫자 접두사(`01-`, `02-`)로 순서 보장.

### Docker Compose DB 구성

```yaml
redis:
  image: redis:7-alpine          # 버전 명시 필수 — latest 사용 금지 (재현 불가)
  ports:
    - "6379:6379"
  healthcheck:
    test: ["CMD", "redis-cli", "ping"]
    interval: 10s
    timeout: 5s
    retries: 5

postgres:
  image: postgres:16-alpine
  environment:
    POSTGRES_DB: ${DB_NAME:-msa_db}
    POSTGRES_USER: ${DB_USERNAME}
    POSTGRES_PASSWORD: ${DB_PASSWORD}
  ports:
    - "5432:5432"
  volumes:
    - postgres_data:/var/lib/postgresql/data
    - ./init-sql:/docker-entrypoint-initdb.d   # 01-schema.sql → 02-data.sql 순서로 자동 실행
  healthcheck:
    test: ["CMD-SHELL", "pg_isready -U ${DB_USERNAME}"]
    interval: 10s
    timeout: 5s
    retries: 5
```

### 서비스 기동 순서 보장

```yaml
# 각 서비스 공통 패턴 (docker-compose.yml)
auth-service:
  depends_on:
    postgres:
      condition: service_healthy
    redis:
      condition: service_healthy
```

### DB 진화 경로

```
Phase 1 (현재): 모든 서비스가 단일 PostgreSQL 공유
Phase 2:        서비스별 PostgreSQL 분리 (DB per Service 원칙 적용)
Phase 3 (K8s):  관리형 DB (RDS, Cloud SQL 등) 또는 서비스별 StatefulSet
```

> **updated_at 자동 갱신**: `DEFAULT NOW()`는 INSERT 시에만 적용된다. UPDATE 시 자동 갱신을
> 위해 `01-schema.sql`에 `update_updated_at_column()` PostgreSQL 트리거 함수를 추가한다.
> (→ `docs/TODO/PHASE1/TODO-BLOCK3.md §3-2` 참조)
>
> **Phase 1 설계 원칙**: DB 분리를 고려하여 서비스 간 테이블에 FK 제약조건을 사용하지 않는다.
> `todos.user_id`는 `users.id`에 대한 **논리적 참조**로만 유지하며, 참조 무결성은 애플리케이션 레이어에서 보장한다.
> 이를 통해 Phase 2 DB 분리 시 스키마 변경 없이 전환 가능하다.

### Multi DataSource 준비 전략

Phase 1에서는 모든 서비스가 단일 DataSource를 공유하지만,
Phase 2 전환 비용을 최소화하기 위해 다음 원칙을 Phase 1부터 준수한다.

```yaml
# 각 서비스 application.yml — 지금은 모두 동일한 DB를 바라보지만
# 서비스별 독립 환경변수로 선언하여 Phase 2 전환 시 값만 교체
# auth-service / user-service / todo-service 모두 동일한 구조 사용
spring:
  datasource:
    url: ${DB_URL}          # Phase 2: 서비스별 DB URL로 교체
    username: ${DB_USERNAME}
    password: ${DB_PASSWORD}
```

- 서비스 간 테이블을 직접 JOIN하는 쿼리 작성 금지
- 다른 서비스 소유 테이블 참조 시 반드시 API 호출로 대체 (Phase 2 기준)
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

### JWT 흐름

```
[로그인]
클라이언트 → POST /api/v1/auth/login
           ← Access Token (15분) + Refresh Token (7일) + deviceId
              Refresh Token → Redis 저장 (key: rt:{userId}:{deviceId}, TTL: 7일)

[API 요청]
클라이언트 → Authorization: Bearer <access_token>
Gateway   → JWT 서명 검증
          → Redis Blacklist 조회 (로그아웃된 토큰 차단)
          → 유효: X-User-Id, X-User-Role 헤더로 하위 서비스 전달

[토큰 갱신 — Rotation]
클라이언트 → POST /api/v1/auth/refresh (Refresh Token + deviceId 전달)
auth-service → Redis에서 rt:{userId}:{deviceId} 존재 확인
             → 존재: 기존 토큰 삭제 + 신규 Access/Refresh Token 발급
             → 미존재 (탈취 의심): 해당 userId의 전체 디바이스 세션 무효화

[로그아웃]
클라이언트 → POST /api/v1/auth/logout (deviceId 전달)
auth-service → Access Token → Redis Blacklist 저장 (TTL = 잔여 만료시간)
             → rt:{userId}:{deviceId} → Redis에서 삭제
```

### Refresh Token Redis 키 구조

```
rt:{userId}:{deviceId}
  - userId  : 사용자 식별자
  - deviceId: 클라이언트가 최초 로그인 시 생성한 UUID (localStorage 보관)
              서버는 검증만 수행, 발급 주체는 클라이언트

예시)
  rt:42:a1b2c3d4-...   ← 사용자 42번의 Chrome 세션
  rt:42:e5f6g7h8-...   ← 사용자 42번의 모바일 앱 세션

멀티 디바이스 로그아웃:
  - 단일 디바이스: rt:{userId}:{deviceId} 삭제
  - 전체 디바이스: rt:{userId}:* 패턴으로 전체 삭제 (탈취 감지 시)
```

> **Phase 1 범위**: deviceId 기반 멀티 세션 구조로 설계하되,
> 프론트엔드 샘플에서는 단일 deviceId만 사용한다.
> 복수 디바이스 관리 UI는 Phase 2에서 추가한다.

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

### 로그 패턴

```yaml
# local/dev: 콘솔 가독성 우선
logging:
  pattern:
    level: "%5p [${spring.application.name:},%X{traceId:-},%X{spanId:-},%X{X-Correlation-ID:-}]"

# stg/prd: logstash-logback-encoder 사용 (JSON 구조화)
# 의존성 추가 필요 — 각 서비스 build.gradle.kts에 아래 추가
#   runtimeOnly(libs.logstash.logback.encoder)
# libs.versions.toml에 버전 선언 필요
#   logstash-logback-encoder = "7.4"
```

`logback-spring.xml` 프로파일별 구조 (각 서비스 `src/main/resources/`):

```xml
<configuration>
  <springProfile name="local,dev">
    <appender name="CONSOLE" class="ch.qos.logback.core.ConsoleAppender">
      <encoder><pattern>%d{HH:mm:ss} %5p [%X{traceId:-},%X{X-Correlation-ID:-}] %logger{36} - %msg%n</pattern></encoder>
    </appender>
    <root level="DEBUG"><appender-ref ref="CONSOLE"/></root>
  </springProfile>
  <springProfile name="stg,prd">
    <appender name="JSON" class="ch.qos.logback.core.ConsoleAppender">
      <encoder class="net.logstash.logback.encoder.LogstashEncoder"/>
    </appender>
    <root level="INFO"><appender-ref ref="JSON"/></root>
  </springProfile>
</configuration>
```

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

```yaml
# application-local.yml / application-dev.yml
logging:
  level:
    io.kyungseo.msa: DEBUG
    org.mybatis: DEBUG                          # MyBatis SQL 출력
    org.springframework.jdbc.core: DEBUG        # JDBC 바인딩 파라미터 출력

# application-stg.yml / application-prd.yml
logging:
  level:
    org.mybatis: OFF                            # stg/prd SQL 로깅 전면 차단 (민감정보 보호)
    org.springframework.jdbc.core: OFF
```

**MyBatis 실행시간 로깅 (SlowQueryInterceptor)**
- `local` / `dev` 프로파일 전용 MyBatis Interceptor (`@Intercepts`) 구현
- 100ms 초과 쿼리: `WARN` 레벨 로깅
- 적용 위치: `io.kyungseo.msa.common.mybatis.SlowQueryInterceptor`
- SQL 파라미터에 포함된 민감 필드는 마스킹 후 출력

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

### 위치 및 구조

```
tests/http/
├── auth.http     # 로그인, 토큰 갱신, 로그아웃 (토큰 변수 추출 포함)
├── user.http     # 회원가입, 사용자 조회/수정/삭제
└── todo.http     # 할 일 생성/조회/수정/삭제
```

### 운영 원칙

- `auth.http`, `user.http`, `todo.http`: VS Code REST Client 형식
- `e2e-gateway.http`: IntelliJ HTTP Client 형식 (`> {% client.global.set() %}` 변수 캡처)
- 모든 요청은 **Gateway(8090)를 통해** 호출 (`/api/v1/` prefix)
- `auth.http` 로그인 응답에서 토큰 변수 추출 → 이후 `.http` 파일에서 재사용
- 각 파일에 `### [성공 케이스]` + `### [실패 케이스]` 구분 주석 포함
- curl 등가 명령어도 주석으로 병기

### 예시 (auth.http)

```http
### 로그인 (admin)
# @name loginAdmin
POST http://localhost:8090/api/v1/auth/login
Content-Type: application/json

{
  "username": "admin",
  "password": "admin",
  "deviceId": "dev-local-001"
}

### 토큰 갱신
POST http://localhost:8090/api/v1/auth/refresh
Content-Type: application/json

{
  "refreshToken": "{{loginAdmin.response.body.data.refreshToken}}",
  "deviceId": "dev-local-001"
}

### 로그아웃
POST http://localhost:8090/api/v1/auth/logout
Authorization: Bearer {{loginAdmin.response.body.data.accessToken}}
Content-Type: application/json

{
  "deviceId": "dev-local-001"
}
```

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

### 컨테이너 이미지 (멀티스테이지 Dockerfile)

```dockerfile
# Stage 1: Build
FROM gradle:8-jdk21 AS builder
WORKDIR /app
COPY . .
RUN gradle :services:auth-service:bootJar --no-daemon

# Stage 2: Run
FROM eclipse-temurin:21-jre-jammy
COPY --from=builder /app/services/auth-service/build/libs/*.jar app.jar
ENTRYPOINT ["java", "-jar", "app.jar"]
```

### Actuator Health Probes (각 서비스 공통)

```yaml
management:
  server:
    port: 8099                        # 외부 노출 차단용 포트 분리
  endpoints:
    web:
      exposure:
        include: health, info, prometheus
  endpoint:
    health:
      probes:
        enabled: true                 # liveness / readiness 분리
```

### K8s Probe 설정 예시

```yaml
livenessProbe:
  httpGet:
    path: /actuator/health/liveness
    port: 8099
readinessProbe:
  httpGet:
    path: /actuator/health/readiness
    port: 8099
```

### Graceful Shutdown (각 서비스 공통)

```yaml
server:
  shutdown: graceful
spring:
  lifecycle:
    timeout-per-shutdown-phase: 30s
```

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

### Makefile 주요 타겟

```makefile
make build           # 전체 빌드 (Gradle)
make run             # Docker Compose 전체 스택 기동 (PostgreSQL + Redis + 서비스)
make run-local       # 로컬 직접 실행 (SPRING_PROFILES_ACTIVE=local)
make test            # 전체 테스트 실행
make clean           # 빌드 산출물 정리
make logs            # Docker Compose 로그 확인
make ps              # 실행 중인 컨테이너 상태 확인
make create-service  # 새 서비스 스캐폴딩 (이름 입력 프롬프트)
```

### create-service.sh 기능

- 새 서비스 디렉토리 및 패키지 구조 생성
- `build.gradle.kts`, `application.yml`, `Dockerfile` 템플릿 복사
- `settings.gradle.kts` 자동 등록

---

## 19. 구현 단계 (Phase)

### Phase 1 — 골격 구축 (현재 목표)

**인프라 / 환경**
- [ ] Gradle 멀티모듈 프로젝트 초기화 (Kotlin DSL + 버전 카탈로그)
- [ ] `infra/docker/docker-compose.yml` 구성 (PostgreSQL + Redis, healthcheck, depends_on)
- [ ] `.devcontainer/docker-compose.devcontainer.yml` 구성 (PostgreSQL + Redis만)
- [ ] DevContainer 설정 (Java 21 이미지, docker-in-docker)
- [ ] `.env.example` 작성 및 `.gitignore` 설정
- [ ] `Makefile` + `create-service.sh` 작성
- [ ] 각 서비스 멀티스테이지 `Dockerfile` 작성
- [ ] `infra/k8s/`, `infra/prometheus/`, `infra/grafana/` 디렉토리 구조 생성 (빈 상태)

**공통 모듈**
- [ ] common-core 구현 (ApiResponse, ErrorCode, GlobalExceptionHandler, MdcFilter, JwtProperties)

**서비스 구현**
- [ ] api-gateway (라우팅, JWT 검증, Blacklist 확인, Rate Limiting, CORS, Security Headers)
- [ ] auth-service (로그인, JWT 발급/갱신/블랙리스트, Redis 연동, Rotation, deviceId 기반 멀티 세션)
- [ ] user-service (회원가입, CRUD, RBAC, BCrypt, Bean Validation)
- [ ] todo-service (CRUD, 인가 확인, 가이드 샘플)

**DB**

- [x] `01-schema.sql` (PostgreSQL 방언, 전 테이블 DDL — 서비스 간 FK 미사용)
- [x] `02-data.sql` (admin/admin ROLE_ADMIN, user/user ROLE_USER BCrypt 해시, 샘플 Todo)

**공통 설정 (전 서비스)**
- [ ] springdoc-openapi + JWT 인증 + API 그룹 설정
- [ ] MDC + Micrometer Tracing 설정
- [ ] Actuator health probes + management port(8099) 분리
- [ ] Graceful Shutdown 설정
- [ ] 프로파일별 `application-{profile}.yml` 작성 (local/dev/stg/prd)

**테스트 및 문서**
- [ ] 각 서비스 단위/슬라이스 테스트 작성
- [ ] `tests/http/` API 테스트 파일 작성 (auth.http, user.http, todo.http)
- [ ] `README.md` 작성 (실행 가이드, 환경 설정, 포트 정보 포함)

**Frontend**
- [ ] Vanilla JS Frontend (로그인, 사용자 관리, 할 일 관리, deviceId 관리 포함)

### Phase 2 — 운영 준비

- [ ] Circuit Breaker (Resilience4j) 적용 — 서비스 간 RestClient 호출 발생 시
- [ ] 서비스별 PostgreSQL 분리 (DB per Service) — Phase 1 FK 미사용 설계 기반으로 전환
- [ ] 분산 트랜잭션 전략 수립 (Saga 패턴 / Outbox 패턴) — 서비스 간 데이터 정합성 보장
- [ ] Prometheus + Grafana 연결 및 대시보드 구성
- [ ] K8s 매니페스트 작성 (Kustomize, overlays: dev/stg/prd)
- [ ] K8s NetworkPolicy 적용 — Gateway → Service 직접 통신만 허용, 내부 서비스 외부 접근 차단
- [ ] CI/CD 파이프라인 (GitHub Actions) — RestAssured 기반 자동화 테스트 연동
- [ ] 복잡 RBAC (리소스+액션 기반 퍼미션)
- [ ] 서비스 간 내부 인증 전략 수립
- [ ] 멀티 디바이스 세션 관리 UI 추가

---

## 20. 미결 사항 (결정 보류)

| 항목 | 내용 |
|---|---|
| K8s 배포 도구 | Helm vs Kustomize → Phase 2에서 결정 |
| 복잡 RBAC | 리소스+액션 기반 퍼미션 → Phase 2에서 결정 |
| 메시지 큐 | Kafka / RabbitMQ 도입 여부 → Phase 2에서 결정 |
| 서비스 간 인증 | 내부 호출 시 토큰 전략 (서비스 계정 JWT 등) → Phase 2에서 결정 |
| 분산 트랜잭션 | Saga vs Outbox 패턴 선택 → Phase 2에서 결정 |

---

*이 문서는 ARCHITECTURE.md 및 TODO.md 작성의 기반이 됩니다.*
