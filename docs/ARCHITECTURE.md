# ARCHITECTURE.md — base-msa-template

> 작성일: 2026-05-03
> 문서 버전: v1.3
> 최종 수정: 2026-05-03 (기본 패키지 io.kyungseo.msa 확정, §14 Mermaid 버그 수정)
> 기준: PLAN.md v1.5
> 목적: 시스템 전체 아키텍처 및 주요 흐름 시각화

---

## 1. 시스템 전체 구성도

```mermaid
graph TB
    subgraph CLIENT["Client Layer"]
        FE["🌐 Frontend\nVanilla JS + Bootstrap\n:3000"]
    end

    subgraph GATEWAY["Gateway Layer"]
        GW["🔀 api-gateway\nSpring Cloud Gateway\n:8090"]
    end

    subgraph SERVICES["Service Layer"]
        AUTH["🔐 auth-service\nJWT 발급/갱신/블랙리스트\n:8091"]
        USER["👤 user-service\nCRUD / RBAC\n:8092"]
        TODO["✅ todo-service\nCRUD 가이드 샘플\n:8093"]
    end

    subgraph INFRA["Infrastructure Layer"]
        PG[("🐘 PostgreSQL 16\n:5432")]
        RD[("🔴 Redis\n:6379")]
    end

    subgraph OPS["Ops Layer (Phase 2)"]
        PROM["📊 Prometheus"]
        GRAF["📈 Grafana"]
    end

    FE -->|"HTTP /api/v1/*"| GW

    GW -->|"JWT 검증 후 라우팅"| AUTH
    GW -->|"X-User-Id, X-User-Role 헤더"| USER
    GW -->|"X-User-Id, X-User-Role 헤더"| TODO

    AUTH -->|"사용자 조회"| PG
    USER -->|"사용자 CRUD"| PG
    TODO -->|"할 일 CRUD"| PG

    AUTH -->|"Refresh Token / Blacklist"| RD
    GW -->|"Rate Limiting / Blacklist 확인"| RD

    AUTH -.->|"Actuator :8099"| PROM
    USER -.->|"Actuator :8099"| PROM
    TODO -.->|"Actuator :8099"| PROM
    GW -.->|"Actuator :8099"| PROM
    PROM -.-> GRAF
```

---

## 2. 네트워크 요청 흐름 (Request Flow)

```mermaid
sequenceDiagram
    participant FE as Frontend :3000
    participant GW as api-gateway :8090
    participant RD as Redis :6379
    participant SVC as Service (user/todo)

    FE->>GW: HTTP 요청 (Authorization: Bearer <token>)

    GW->>GW: 1. JWT 서명 검증
    GW->>RD: 2. Blacklist 조회 (jti 기준)
    RD-->>GW: 존재 여부 반환

    alt 토큰 유효
        GW->>GW: 3. X-User-Id, X-User-Role 헤더 추가
        GW->>SVC: 4. 하위 서비스로 라우팅
        SVC-->>GW: 응답
        GW-->>FE: 최종 응답
    else 토큰 무효 또는 Blacklist
        GW-->>FE: 401 Unauthorized
    end
```

---

## 3. 인증 흐름 (Authentication Flow)

### 3-1. 로그인

```mermaid
sequenceDiagram
    participant FE as Frontend
    participant GW as api-gateway
    participant AUTH as auth-service
    participant PG as PostgreSQL
    participant RD as Redis

    FE->>GW: POST /api/v1/auth/login\n{ username, password, deviceId }
    GW->>AUTH: 라우팅 (인증 불필요 경로)
    AUTH->>PG: 사용자 조회 + 비밀번호 BCrypt 검증
    PG-->>AUTH: 사용자 정보

    AUTH->>AUTH: Access Token 생성 (15분)
    AUTH->>AUTH: Refresh Token 생성 (7일)
    AUTH->>RD: Refresh Token 저장\n(key: rt:{userId}:{deviceId}, TTL: 7일)

    AUTH-->>GW: { accessToken, refreshToken }
    GW-->>FE: { accessToken, refreshToken }
```

### 3-2. 토큰 갱신 (Rotation)

```mermaid
sequenceDiagram
    participant FE as Frontend
    participant GW as api-gateway
    participant AUTH as auth-service
    participant RD as Redis

    FE->>GW: POST /api/v1/auth/refresh\n{ refreshToken, deviceId }
    GW->>AUTH: 라우팅

    AUTH->>RD: rt:{userId}:{deviceId} 존재 확인
    RD-->>AUTH: 결과

    alt 존재 (정상)
        AUTH->>RD: 기존 rt:{userId}:{deviceId} 삭제
        AUTH->>AUTH: 신규 Access Token + Refresh Token 생성
        AUTH->>RD: 신규 rt:{userId}:{deviceId} 저장
        AUTH-->>FE: { accessToken, refreshToken }
    else 미존재 (탈취 의심)
        AUTH->>RD: rt:{userId}:* 전체 삭제 (모든 디바이스 세션 무효화)
        AUTH-->>FE: 401 Unauthorized
    end
```

### 3-3. 로그아웃

```mermaid
sequenceDiagram
    participant FE as Frontend
    participant GW as api-gateway
    participant AUTH as auth-service
    participant RD as Redis

    FE->>GW: POST /api/v1/auth/logout\n(Authorization: Bearer <token>, deviceId)
    GW->>AUTH: 라우팅

    AUTH->>RD: Access Token → Blacklist 저장\n(key: bl:{jti}, TTL = 잔여 만료시간)
    AUTH->>RD: rt:{userId}:{deviceId} 삭제

    AUTH-->>FE: 200 OK
```

---

## 4. 모듈 의존성 구조

```mermaid
graph LR
    subgraph ROOT["Root Project"]
        CORE["common-core"]
    end

    subgraph GW_MOD["gateway/"]
        APIGW["api-gateway"]
    end

    subgraph SVC_MOD["services/"]
        ASVC["auth-service"]
        USVC["user-service"]
        TSVC["todo-service"]
    end

    APIGW -->|"implementation"| CORE
    ASVC  -->|"implementation"| CORE
    USVC  -->|"implementation"| CORE
    TSVC  -->|"implementation"| CORE

    style CORE fill:#f9f,stroke:#333,stroke-width:2px
```

> 서비스 간 직접 의존성 없음. 모든 통신은 Runtime HTTP(RestClient)로만 이루어짐.

---

## 5. common-core 내부 구조

```mermaid
graph TD
    subgraph CORE["common-core"]
        subgraph RESP["response/"]
            AR["ApiResponse&lt;T&gt;\n{ code, message, data }"]
            ER["ErrorResponse\n{ code, message, errors[] }"]
            PR["PageResponse&lt;T&gt;\n{ content, page, size, totalElements, totalPages }"]
        end
        subgraph EXC["exception/"]
            BE["BusinessException"]
            EC["ErrorCode (enum)"]
            GEH["GlobalExceptionHandler\n@RestControllerAdvice"]
        end
        subgraph LOG["logging/"]
            MF["MdcFilter\nX-Correlation-ID → MDC"]
            LC["LoggingConstants\nMDC key 상수"]
        end
        subgraph SEC["security/"]
            JP["JwtProperties\n@ConfigurationProperties"]
        end
        subgraph UTL["util/"]
            DU["DateTimeUtils"]
        end
        subgraph MYBATIS["mybatis/"]
            SQI["SlowQueryInterceptor\n@Profile(local, dev)\n100ms 초과 WARN 로깅"]
        end
    end

    GEH -->|"uses"| EC
    GEH -->|"returns"| ER
    BE  -->|"uses"| EC
    MF  -->|"uses"| LC
```

> **기본 패키지**: `io.kyungseo.msa.common`
> 전체 경로 예시: `io.kyungseo.msa.common.response.ApiResponse`
> 각 서비스 기본 패키지: `io.kyungseo.msa.{service-name}` (예: `io.kyungseo.msa.auth`, `io.kyungseo.msa.user`, `io.kyungseo.msa.todo`, `io.kyungseo.msa.gateway`)

---

## 6. api-gateway 내부 필터 체인

```mermaid
graph LR
    REQ["📥 Incoming Request"]

    subgraph FILTERS["Gateway Filter Chain (순서 보장)"]
        F1["① MdcGatewayFilter\nX-Correlation-ID 생성/전파\n(Reactor Context 기반 — ThreadLocal 아님)"]
        F2["② SecurityHeadersFilter\nX-Content-Type-Options\nX-Frame-Options 등"]
        F3["③ RateLimitFilter\nRedis 기반\n인증 API: 5/s\n일반 API: 100/s"]
        F4["④ JwtAuthFilter\n서명 검증\nBlacklist 확인\n(fail-open / fail-close 정책)"]
        F5["⑤ UserContextFilter\n외부 유입 헤더 제거\nX-User-Id / X-User-Role 주입"]
    end

    ROUTE["🔀 Route to Service"]

    REQ --> F1 --> F2 --> F3 --> F4 --> F5 --> ROUTE

    style F4 fill:#ffd,stroke:#f90
    style F5 fill:#ffe,stroke:#f60
```

> 공개 경로(`/api/v1/auth/login`, `/api/v1/auth/refresh`, `/api/v1/users` POST)는
> ④ JwtAuthFilter를 건너뜀.
>
> **④ JwtAuthFilter — Redis Blacklist fail 정책**
> Redis 장애 시 동작은 환경변수 `BLACKLIST_FAIL_POLICY`로 제어한다.
> - `fail-close` (기본값): Blacklist 조회 실패 시 인증 차단 → 보안 우선
> - `fail-open`: Blacklist 조회 실패 시 통과 허용 → 가용성 우선
>
> **⑤ UserContextFilter — Header Spoofing 방어**
> 외부 클라이언트가 `X-User-Id`, `X-User-Role` 헤더를 직접 주입하는 공격을 차단한다.
> JWT 검증 후 서버가 직접 생성한 값으로 **덮어쓰기 전에 기존 헤더를 강제 제거**한다.

---

## 7. 각 서비스 내부 레이어 구조

```mermaid
graph TD
    subgraph SVC["Service (auth / user / todo 공통 패턴)"]
        CTR["Controller Layer\n@RestController\n@Valid 입력 검증\nRequest/Response DTO"]
        MSTR["MapStruct Layer\nDTO ↔ Domain 변환\n@Mapper(componentModel=spring)"]
        SRV["Service Layer\n비즈니스 로직\n@Transactional\nDomain 객체 사용"]
        MAP["MyBatis Mapper Layer\nMyBatis XML Mapper\nSQL 실행"]
        DB[("PostgreSQL")]
    end

    subgraph CROSS["Cross-cutting"]
        GEH["GlobalExceptionHandler\n(common-core)"]
        MDC["MdcFilter\n(common-core)"]
        SWAGGER["springdoc-openapi\nSwagger UI"]
    end

    REQ["📥 Request (Gateway 경유)"] --> MDC
    MDC --> CTR
    CTR -->|"@Valid 실패 시"| GEH
    CTR -->|"RequestDTO → Domain"| MSTR
    MSTR --> SRV
    SRV -->|"BusinessException"| GEH
    SRV --> MAP
    MAP --> DB
    SRV -->|"Domain → ResponseDTO"| MSTR
    MSTR -->|"ResponseDTO 반환"| CTR
    CTR -.->|"API 문서 자동 생성"| SWAGGER
```

---

## 8. Redis 데이터 구조

```mermaid
graph LR
    subgraph REDIS["Redis Key-Value 구조"]
        subgraph RT["Refresh Token Store"]
            RK["Key: rt:{userId}:{deviceId}\nValue: refreshToken\nTTL: 7일\n\n예) rt:42:a1b2c3d4-...\n    rt:42:e5f6g7h8-..."]
        end
        subgraph BL["Blacklist"]
            BK["Key: bl:{jti}\nValue: 'logout'\nTTL: Access Token 잔여 만료시간"]
        end
        subgraph RL["Rate Limit (Gateway)"]
            LK["Key: rl:{userId 또는 IP}\nValue: 요청 카운터\nTTL: 1초 sliding window"]
        end
    end

    AUTH["auth-service"] -->|"저장/삭제\n(디바이스 단위)"| RT
    AUTH -->|"Blacklist 등록"| BL
    GW["api-gateway"] -->|"Blacklist 조회"| BL
    GW -->|"Rate Limit 확인"| RL
```

> **멀티 디바이스 세션 관리**
> - 단일 디바이스 로그아웃: `rt:{userId}:{deviceId}` 삭제
> - 전체 디바이스 세션 무효화 (탈취 감지): `rt:{userId}:*` 패턴 전체 삭제
>
> **SCAN 성능 trade-off (Phase 1 설계 결정)**
> `rt:{userId}:* SCAN + DEL` 패턴은 탈취 감지 시 전체 세션 무효화에 사용된다.
> 운영 환경 대규모 키 공간에서는 SCAN 성능 저하 및 Redis CPU 급증 위험이 있음.
> Phase 1(소규모 사용자)에서는 허용 가능한 수준이나, Phase 2에서는 `rt:sessions:{userId}` Set
> 구조로 전환하여 SCAN 없이 O(1)로 세션 목록 조회할 것을 권장한다. (→ PHASE2-BACKLOG.md 참조)

---

## 9. 데이터베이스 스키마 (ERD)

```mermaid
erDiagram
    USERS {
        bigserial   id          PK
        varchar     username    UK  "로그인 ID"
        varchar     email       UK
        varchar     password        "BCrypt 해시"
        varchar     role            "ROLE_ADMIN / ROLE_USER"
        boolean     enabled         "계정 활성 여부"
        timestamp   created_at
        timestamp   updated_at
    }

    TODOS {
        bigserial   id          PK
        bigint      user_id         "논리 참조 (FK 미사용)"
        varchar     title
        text        description
        boolean     completed
        timestamp   created_at
        timestamp   updated_at
    }

    USERS ||--o{ TODOS : "owns (논리적 관계)"
```

> **FK 미사용 원칙**: `todos.user_id`는 `users.id`에 대한 논리적 참조로만 유지한다.
> DB 레벨 FK 제약조건을 사용하지 않음으로써 Phase 2의 DB per Service 분리를 용이하게 한다.
> 참조 무결성(존재하지 않는 userId 방지)은 애플리케이션 레이어(todo-service)에서 보장한다.

---

## 10. 환경별 배포 구성

```mermaid
graph TB
    subgraph LOCAL["local / dev"]
        direction LR
        DC["Docker Compose\n(PostgreSQL + Redis)"]
        VS["VS Code\n서비스 직접 실행\n(DevContainer)"]
    end

    subgraph STG["stg (Staging)"]
        direction LR
        K8S_S["K8s Cluster\n(Phase 2)"]
        EXT_S[("PostgreSQL\n(외부 관리형)")]
    end

    subgraph PRD["prd (Production)"]
        direction LR
        K8S_P["K8s Cluster\nEKS / AKS\n(Phase 2)"]
        EXT_P[("PostgreSQL\nRDS / Cloud SQL\n(Phase 2)")]
    end

    DEV["개발자"] -->|"make run / devcontainer"| LOCAL
    LOCAL -->|"이미지 빌드 → 배포"| STG
    STG -->|"승인 후 배포"| PRD
```

---

## 11. Logging & Tracing 흐름

```mermaid
sequenceDiagram
    participant FE as Frontend
    participant GW as api-gateway
    participant AUTH as auth-service
    participant TODO as todo-service

    FE->>GW: HTTP 요청

    GW->>GW: X-Correlation-ID 생성 (없으면)\nMDC: {traceId, spanId, correlationId}
    note over GW: 로그: [api-gateway, traceId, spanId, corrId]

    GW->>AUTH: 요청 전달\n헤더: X-Correlation-ID
    AUTH->>AUTH: MdcFilter: correlationId → MDC 저장
    note over AUTH: 로그: [auth-service, traceId, spanId, corrId]

    GW->>TODO: 요청 전달\n헤더: X-Correlation-ID
    TODO->>TODO: MdcFilter: correlationId → MDC 저장
    note over TODO: 로그: [todo-service, traceId, spanId, corrId]
```

> **WebFlux MDC 전파 주의사항**
> api-gateway는 WebFlux(Project Reactor) 기반으로, Servlet `OncePerRequestFilter`의 ThreadLocal MDC
> 전파 방식이 동작하지 않는다. 하나의 요청이 여러 스레드에 걸쳐 실행될 수 있기 때문에 일반적인
> `MDC.put()` 방식으로는 MDC 값이 전파되지 않음.
>
> **Gateway MdcGatewayFilter 구현 방식 (권장: 방식 A)**
> - **방식 A (권장)**: `Hooks.onEachOperator`를 활용한 Context → MDC 자동 전파
>   - `reactor.util.context.Context`에 correlationId 저장 → 각 operator 실행 시 MDC 자동 주입
>   - Micrometer Tracing이 이미 Reactor Context 연동을 지원하므로 traceId/spanId도 함께 전파됨
> - **방식 B**: `ServerWebExchange` attribute에 저장 후 필요 시점에 MDC 수동 설정
>   - 구현은 간단하나 비동기 체인에서 MDC 누락 가능성 있음
>
> Phase 1 권장: 방식 A. 상세 구현은 `docs/TODO/TODO-BLOCK7.md §7-2` 참조.

---

## 12. 멀티모듈 Gradle 빌드 구조

```mermaid
graph TD
    ROOT["build.gradle.kts\n(루트 — 공통 설정)"]
    VERSIONS["libs.versions.toml\n(버전 카탈로그)"]

    ROOT --> CORE["common/common-core\nbuild.gradle.kts"]
    ROOT --> GW["gateway/api-gateway\nbuild.gradle.kts"]
    ROOT --> AUTH["services/auth-service\nbuild.gradle.kts"]
    ROOT --> USER["services/user-service\nbuild.gradle.kts"]
    ROOT --> TODO["services/todo-service\nbuild.gradle.kts"]

    VERSIONS -.->|"버전 참조"| ROOT
    VERSIONS -.->|"버전 참조"| CORE
    VERSIONS -.->|"버전 참조"| GW
    VERSIONS -.->|"버전 참조"| AUTH
    VERSIONS -.->|"버전 참조"| USER
    VERSIONS -.->|"버전 참조"| TODO

    style ROOT fill:#e8f4f8,stroke:#2196F3
    style VERSIONS fill:#fff9e6,stroke:#FFC107
```

---

## 13. DevContainer 개발 환경 구성

```mermaid
graph TB
    subgraph HOST["MacBook M4 Pro (Host)"]
        VSCODE["VS Code\n+ DevContainer Extension"]
        DOCKER["Docker Desktop"]
    end

    subgraph CONTAINER["DevContainer (Java 21)"]
        subgraph TOOLS["개발 도구"]
            GRADLE["Gradle 8.x"]
            GIT["Git / GitHub CLI"]
            JAVA["JDK 21 (Temurin)"]
        end
        subgraph APPS["서비스 (직접 실행)"]
            GW_D["api-gateway :8090"]
            AUTH_D["auth-service :8091"]
            USER_D["user-service :8092"]
            TODO_D["todo-service :8093"]
        end
    end

    subgraph SIDECARS["Sidecar (docker-compose.devcontainer.yml)"]
        PG_D[("PostgreSQL :5432")]
        RD_D[("Redis :6379")]
    end

    VSCODE -->|"Remote Container"| CONTAINER
    DOCKER --> CONTAINER
    DOCKER --> SIDECARS
    APPS -->|"DB 연결"| PG_D
    APPS -->|"캐시 연결"| RD_D
```

---

## 14. K8s 배포 구조 (Phase 2 목표)

```mermaid
graph TB
    subgraph K8S["Kubernetes Cluster"]
        subgraph NS["Namespace: msa-template"]
            ING["Ingress Controller\n(외부 트래픽 진입)"]

            subgraph PODS["Pods"]
                GWP["api-gateway Pod\n:8090"]
                AUTHP["auth-service Pod\n:8091"]
                USERP["user-service Pod\n:8092"]
                TODOP["todo-service Pod\n:8093"]
            end

            subgraph CFG["Config"]
                CM["ConfigMap\n(비민감 환경변수)"]
                SEC["Secret\nJWT_SECRET, DB_PASSWORD"]
            end

            subgraph NET["Network"]
                NP["NetworkPolicy\nGateway to Service only\n외부 직접 접근 차단"]
            end

            subgraph DB_K8S["Data"]
                PG_K[("PostgreSQL\nStatefulSet or RDS")]
                RD_K[("Redis\nStatefulSet")]
            end
        end
    end

    INTERNET["Internet"] --> ING
    ING --> GWP
    GWP --> AUTHP
    GWP --> USERP
    GWP --> TODOP

    PODS -.->|"env 주입"| CM
    PODS -.->|"env 주입"| SEC
    NP -.->|"트래픽 제어"| PODS
    PODS --> DB_K8S
```

> **NetworkPolicy (Phase 2)**: 하위 서비스(auth/user/todo)는 Gateway Pod에서 오는 트래픽만 수신.
> 외부에서 직접 `:8091~8093` 포트로 접근하는 경우 차단하여 Header spoofing 위협 제거.

---

## 15. 보안 아키텍처 요약

```mermaid
graph LR
    subgraph EXTERNAL["외부"]
        CLIENT["Client"]
    end

    subgraph GATEWAY_SEC["Gateway 보안 레이어"]
        CORS["CORS\n(ALLOWED_ORIGINS)"]
        RATE["Rate Limiting\n인증 5/s\n일반 100/s"]
        JWT_V["JWT 검증\n서명 + Blacklist"]
        HEADERS["Security Headers\nX-Content-Type-Options\nX-Frame-Options\nX-XSS-Protection"]
        HSTS["HSTS\n(stg/prd 전용)"]
    end

    subgraph SERVICE_SEC["서비스 보안 레이어"]
        RBAC["@PreAuthorize\nRBAC 검증"]
        VALID["Bean Validation\n입력값 검증"]
        MYBATIS["MyBatis #{}\nSQL Injection 방어"]
    end

    subgraph INFRA_SEC["인프라 보안"]
        ACTUATOR["Actuator :8099\n외부 차단"]
        SWAGGER_SEC["Swagger UI\nlocal/dev만 활성"]
        ENCRYPT["BCrypt\npassword 해시"]
        NETPOL["K8s NetworkPolicy\n(Phase 2)\nGateway만 서비스 접근 허용"]
    end

    CLIENT --> CORS --> RATE --> JWT_V --> HEADERS --> HSTS
    HSTS --> RBAC --> VALID --> MYBATIS
    MYBATIS -.-> ACTUATOR
    MYBATIS -.-> SWAGGER_SEC
    MYBATIS -.-> ENCRYPT
    MYBATIS -.-> NETPOL
```

---

## 16. 인증 토큰 저장 구조 (Redis)

Phase 1에서 적용하는 멀티 디바이스 대응 토큰 키 구조를 명시한다.

```
┌─────────────────────────────────────────────────────────┐
│  Refresh Token Store                                    │
│                                                         │
│  rt:{userId}:{deviceId}  →  refreshTokenValue           │
│                                                         │
│  예시)                                                   │
│  rt:42:a1b2c3d4-1234-...  →  eyJhbGci...  (TTL: 7d)    │
│  rt:42:e5f6g7h8-5678-...  →  eyJhbGci...  (TTL: 7d)    │
│  rt:99:f9g0h1i2-9012-...  →  eyJhbGci...  (TTL: 7d)    │
│                                                         │
│  단일 디바이스 로그아웃:                                  │
│    DEL rt:42:a1b2c3d4-1234-...                          │
│                                                         │
│  전체 세션 무효화 (탈취 감지):                            │
│    SCAN + DEL rt:42:*                                   │
└─────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────┐
│  Blacklist                                              │
│                                                         │
│  bl:{jti}  →  "logout"  (TTL: Access Token 잔여 만료)   │
└─────────────────────────────────────────────────────────┘
```

> **deviceId 생성 주체**: 클라이언트(Frontend)가 최초 로그인 시 UUID를 생성하여 localStorage에 보관.
> 서버는 전달받은 deviceId를 키 구성에 사용하며 별도 검증은 하지 않는다.
> Phase 1에서는 단일 deviceId로 동작하나, 키 구조는 처음부터 멀티 세션을 지원하도록 설계한다.

---

*다음 단계: `docs/STATUS.md` 확인 후 현재 BLOCK의 `docs/TODO/TODO-BLOCK{n}.md` 참고하여 구현 진행*
