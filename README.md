# base-msa-template

Spring Boot 3.5 + Spring Cloud 2025 기반 MSA 스캐폴딩 템플릿.  
JWT 인증(Token Rotation), Redis Rate Limiting, API Gateway, MyBatis, Vanilla JS Frontend를 포함하며, 신규 프로젝트 시작 시 즉시 활용 가능한 수준으로 구성되어 있다.

---

## 기술 스택

| 영역 | 기술 |
|------|------|
| 언어 / 런타임 | Java 21 (Virtual Threads), Spring Boot 3.5.0 |
| 게이트웨이 | Spring Cloud Gateway (WebFlux) 2025.0.0 |
| 인증 | Spring Security + JJWT 0.12.x + Redis |
| 데이터 접근 | MyBatis 3 + PostgreSQL 16 |
| DTO 변환 | MapStruct 1.6 |
| 로컬 캐시 | Caffeine (설정 포함, Phase 2에서 활성화) |
| 인프라 | Docker Compose, PostgreSQL 16, Redis 7 |
| 빌드 | Gradle 8 (Kotlin DSL, 멀티모듈) |
| 코드 품질 | Checkstyle 10.21.0 (Google Java Style + 프로젝트 오버라이드) |
| CI | GitHub Actions (lint → test, `.github/workflows/ci.yml`) |
| API 문서 | springdoc-openapi (Swagger UI) |
| 프론트엔드 | Vanilla JS + Bootstrap 5.3 |
| 로깅 | Logback (로컬: 패턴, stg/prd: JSON via logstash-logback-encoder) |

---

## 사전 요구사항

- Docker Desktop 4.x 이상
- JDK 21 이상 (`java -version` 확인)
- GNU Make (`make --version` 확인)
- Python 3 (Frontend 로컬 서빙 시)

---

## 빠른 시작

### 1. 환경변수 설정

```bash
cp .env.example .env
```

`.env` 파일을 열고 아래 필수값을 입력한다:

```bash
JWT_SECRET=<256-bit 이상 랜덤 문자열>  # openssl rand -hex 32
DB_USERNAME=<postgres 사용자명>
DB_PASSWORD=<postgres 비밀번호>
```

> `DB_USERNAME` / `DB_PASSWORD` 는 PostgreSQL 컨테이너 초기화에도 사용된다.
> 최초 기동 후 변경하려면 `docker volume rm docker_postgres_data` 로 볼륨을 초기화해야 한다.

### 2. 개발 환경 초기 설정 (최초 1회)

```bash
# Git hooks 설치 (Conventional Commits 검증 + Checkstyle pre-commit)
sh tools/git-hooks/install.sh

# Checkstyle 로컬 확인
./gradlew checkstyleMain
```

`.editorconfig`는 IntelliJ / VS Code에서 자동 인식된다.
상세 컨벤션: [`docs/CODING-CONVENTIONS.md`](docs/CODING-CONVENTIONS.md)

### 3. 전체 스택 기동

```bash
cd scripts
make run        # PostgreSQL + Redis + 4개 서비스 전부 기동
make ps         # 컨테이너 상태 확인
```

> 최초 기동 시 Gradle 멀티스테이지 빌드가 포함되어 **10~20분** 소요된다.  
> 이후 기동은 레이어 캐시 덕분에 훨씬 빠르다.

### 3. 동작 확인

```bash
# Gateway health (403이 정상 — SecurityConfig에서 Actuator denyAll)
curl -s http://localhost:8090/actuator/health

# auth-service Actuator (DB + Redis 연결 확인)
curl -s http://localhost:8099/actuator/health | python3 -m json.tool

# 로그인 테스트
curl -s http://localhost:8090/api/v1/auth/login \
  -X POST -H "Content-Type: application/json" \
  -d '{"username":"admin","password":"admin","deviceId":"test"}'
```

### 4. Frontend 실행

```bash
cd frontend/web-app
python3 -m http.server 3000
# 브라우저에서 http://localhost:3000/login.html 접속
```

초기 계정: `admin / admin`, `user / user` (02-data.sql 참조)

---

## 서비스 포트 맵

| 서비스 | 포트 | 역할 |
|--------|------|------|
| api-gateway | 8090 | 단일 진입점 — 라우팅, JWT 검증, Rate Limiting |
| auth-service | 8091 | JWT 발급 / 갱신 / 블랙리스트 |
| user-service | 8092 | 회원가입, 사용자 CRUD |
| todo-service | 8093 | 할 일 CRUD (가이드 샘플) |
| PostgreSQL | 5432 | 공유 DB (Phase 1) |
| Redis | 6379 | Refresh Token, Blacklist, Rate Limiting |
| Actuator (공통) | 8099 | management port — 모든 서비스 내부 전용, 외부 미노출 |
| Frontend | 3000 | Vanilla JS 독립 서빙 |

---

## 주요 API 엔드포인트

모든 요청은 Gateway(`http://localhost:8090`)를 통해 들어온다.

| 메서드 | 경로 | 인증 | 설명 |
|--------|------|------|------|
| POST | `/api/v1/auth/login` | 불필요 | 로그인 (accessToken + refreshToken 발급) |
| POST | `/api/v1/auth/refresh` | 불필요 | Token Rotation (새 쌍 발급) |
| POST | `/api/v1/auth/logout` | Bearer | 로그아웃 (Blacklist 등록) |
| POST | `/api/v1/users` | 불필요 | 회원가입 |
| GET | `/api/v1/users` | ADMIN | 사용자 목록 (페이지네이션) |
| GET | `/api/v1/users/{id}` | Bearer | 사용자 조회 (본인 또는 ADMIN) |
| PATCH | `/api/v1/users/{id}` | Bearer | 사용자 수정 (본인 또는 ADMIN) |
| DELETE | `/api/v1/users/{id}` | ADMIN | 사용자 삭제 |
| GET | `/api/v1/todos` | Bearer | 내 할 일 목록 (페이지네이션) |
| POST | `/api/v1/todos` | Bearer | 할 일 생성 |
| GET | `/api/v1/todos/{id}` | Bearer | 할 일 조회 |
| PUT | `/api/v1/todos/{id}` | Bearer | 할 일 수정 |
| PATCH | `/api/v1/todos/{id}/complete` | Bearer | 완료 토글 |
| DELETE | `/api/v1/todos/{id}` | Bearer | 할 일 삭제 |

**Swagger UI** (local/dev 프로파일에서만 활성화):

| 서비스 | URL |
|--------|-----|
| auth-service | http://localhost:8091/swagger-ui.html |
| user-service | http://localhost:8092/swagger-ui.html |
| todo-service | http://localhost:8093/swagger-ui.html |

인증이 필요한 API는 먼저 `/api/v1/auth/login`으로 로그인 후 `Authorize` 버튼에 Access Token을 입력한다.

---

## 환경변수 레퍼런스

`.env.example` 기준:

| 변수 | 필수 | 기본값 | 설명 |
|------|------|--------|------|
| `JWT_SECRET` | ✅ | — | 256-bit 이상. `openssl rand -hex 32` 으로 생성 |
| `JWT_ACCESS_EXPIRY` | — | 900 | Access Token 만료(초) |
| `JWT_REFRESH_EXPIRY` | — | 604800 | Refresh Token 만료(초, 7일) |
| `DB_URL` | ✅ | — | `jdbc:postgresql://...` |
| `DB_USERNAME` | ✅ | — | |
| `DB_PASSWORD` | ✅ | — | |
| `REDIS_HOST` | — | localhost | Docker 환경: `msa-redis` |
| `ALLOWED_ORIGINS` | — | `http://localhost:3000` | CORS 허용 Origin |
| `BLACKLIST_FAIL_POLICY` | — | `fail-close` | `fail-close`: Redis 오류 시 401 / `fail-open`: 통과 |

---

## 테스트 실행

```bash
# 전체 테스트 (단위 + 슬라이스 + 통합)
cd scripts && make test

# 모듈별
./gradlew :services:user-service:test

# 통합 테스트는 로컬 PostgreSQL + Redis 필요
cd scripts && make run-local   # infra만 기동
./gradlew :services:auth-service:test
```

> Testcontainers는 Docker Desktop 환경에서 호환 문제로 미사용.  
> 통합 테스트는 `application-test.yml`의 로컬 실행 중인 컨테이너를 직접 사용한다.

---

## E2E 테스트 실행

```bash
cd scripts && make run   # 전체 스택 기동
# IntelliJ HTTP Client에서 tests/http/e2e-gateway.http 열고
# "Run All Requests in File" 실행
```

개별 서비스 HTTP 테스트 파일 (VS Code REST Client 형식):
- `tests/http/auth.http`
- `tests/http/user.http`
- `tests/http/todo.http`
- `tests/http/gateway.http`

---

## DevContainer 실행

VS Code에서 `.devcontainer/` 설정을 이용해 컨테이너 기반 개발 환경을 사용할 수 있다.

```bash
# VS Code Command Palette
# > Dev Containers: Reopen in Container
```

`.devcontainer/docker-compose.devcontainer.yml` 이 PostgreSQL + Redis를 함께 기동한다.

---

## 신규 서비스 추가

```bash
cd scripts
make create-service NAME=order-service
```

생성 후 수동으로 해야 할 작업:

1. `services/order-service/src/main/resources/application.yml` — `spring.application.name` 및 `server.port` 변경
2. `services/order-service/src/main/java/.../OrderServiceApplication.java` — `scanBasePackages`에 `"io.kyungseo.msa.common"` 추가
3. `infra/docker/docker-compose.yml` — 서비스 블록 추가
4. `gateway/api-gateway/src/main/resources/application-*.yml` — 라우팅 규칙 추가

자세한 절차는 [docs/DEVELOPER-GUIDE.md](docs/DEVELOPER-GUIDE.md#신규-서비스-추가-절차) 참조.

---

## 유용한 명령어

```bash
cd scripts

make help               # 명령어 목록 (make help로 확인)
make run                # 전체 스택 기동
make run-local          # infra만 기동 (postgres + redis)
make rebuild            # 이미지 재빌드 후 기동
make rebuild-nc         # 캐시 없이 재빌드 후 기동
make stop               # 전체 중지
make logs               # 전체 로그
make logs SERVICE=api-gateway  # 특정 서비스 로그
make ps                 # 컨테이너 상태
make test               # 전체 테스트
make build              # 빌드 (테스트 제외)
make clean              # 빌드 아티팩트 삭제

# Docker 볼륨 초기화 (DB 데이터 전체 삭제)
make stop && docker volume rm docker_postgres_data
make run
```

---

## 프로젝트 구조

```
base-msa-template/
├── common/
│   └── common-core/          # 공통 모듈 (ErrorCode, BusinessException, ApiResponse 등)
├── services/
│   ├── auth-service/         # JWT 인증 서비스
│   ├── user-service/         # 사용자 관리 서비스
│   └── todo-service/         # Todo 샘플 서비스
├── gateway/
│   └── api-gateway/          # Spring Cloud Gateway
├── frontend/
│   └── web-app/              # Vanilla JS + Bootstrap 5
├── infra/
│   ├── docker/               # docker-compose.yml + init SQL
│   ├── k8s/                  # K8s 매니페스트 (Phase 2)
│   ├── prometheus/           # Prometheus 설정 (Phase 2)
│   └── grafana/              # Grafana 대시보드 (Phase 2)
├── tests/
│   └── http/                 # .http 테스트 파일
├── scripts/
│   ├── Makefile
│   └── create-service.sh     # 서비스 스캐폴딩 스크립트
├── config/
│   └── checkstyle/           # Checkstyle 설정 (checkstyle.xml, suppressions.xml)
├── tools/
│   └── git-hooks/            # pre-commit, commit-msg, install.sh
├── .github/
│   └── workflows/
│       └── ci.yml            # lint → test CI
├── docs/
│   ├── STATUS.md             # 현재 작업 상태 (active board)
│   ├── PLAN-SUMMARY.md       # 기술 스택·포트·Phase 요약 (경량 참조용)
│   ├── PLAN.md               # 전체 설계 결정 및 기술 원칙 (상세용, 필요 시만 로드)
│   ├── ARCHITECTURE.md       # 아키텍처 다이어그램
│   ├── DEVELOPER-GUIDE.md    # 개발자 가이드 (상세)
│   ├── CODING-CONVENTIONS.md # 코드 컨벤션 SSOT
│   ├── CLAUDE.md             # Claude Code 프로젝트 운영 규칙
│   ├── decisions/            # 기술 결정 기록 (DR-001~)
│   ├── backlog/              # Phase별 후보 작업 목록
│   ├── archive/              # 완료된 Phase 이력
│   └── retrospectives/       # 시점별 harness 평가 및 워크플로우 회고
├── prompts/                  # AI 작업 프롬프트 라이브러리 (23개, prompts/README.md 참조)
├── .claude/
│   ├── commands/             # 슬래시 커맨드 (/start, /pick, /work, /resume, /debug, /done, /record-decision, /health)
│   ├── rules/                # 경로별 규칙 (java-spring, testing, infra, docs-workflow)
│   └── settings.json         # 권한 설정, hooks
├── .editorconfig             # IDE 공통 스타일 (4-space, UTF-8, LF, 120자)
├── .env.example
├── .devcontainer/
├── CLAUDE.md                 # Claude와의 공통 작업 계약
└── build.gradle.kts          # 루트 빌드 파일
```

### docs/ 파일 독자 분류

| 독자 | 파일 |
|------|------|
| 개발자 | `ARCHITECTURE.md`, `DEVELOPER-GUIDE.md`, `CODING-CONVENTIONS.md`, `DOCKERFILE-GUIDE.md`, `WORKFLOW-MANUAL.md`, `PLAN.md` |
| AI 운영 (Claude) | `CLAUDE.md`, `STATUS.md`, `PLAN-SUMMARY.md`, `backlog/`, `decisions/`, `archive/`, `TODO/` |
| ※ AI 운영 (Cursor) | `.cursor/rules/*.mdc` 참고 (9개 mdc 구성) |
| 개발자 + AI 겸용 | `PLAN-SUMMARY.md` (기술 스택·포트 요약, AI 기본 참조 + 개발자 빠른 조회) |

---

## AI 개발 워크플로우 (Claude Code)

이 템플릿은 Claude Code 기반 Vibe Coding 워크플로우를 내장하고 있다.

**슬래시 커맨드** (`.claude/commands/`):

| 커맨드 | 역할 |
|--------|------|
| `/start` | 세션 시작 — `STATUS.md` 상태 요약 |
| `/pick` | Phase 2 백로그에서 작업 선택 |
| `/work P2-001` | 특정 백로그 항목 계획 수립 |
| `/resume` | 중단된 작업 재개 |
| `/debug` | 에러 분석 / 리팩토링 시작 |
| `/done` | 세션 종료 요약 |
| `/record-decision` | 확정된 기술 결정을 DR로 기록 |
| `/health` | 워크플로우·문서 전체 정합성 점검 및 보고 (`--full`로 심화 점검) |

**프롬프트 라이브러리** (`prompts/`):
- 23개 범용 프롬프트 (Claude / Cursor / ChatGPT 공용)
- Spring Boot 특화: `21-create-layer` (레이어별 생성), `22-minimal-diff` (최소 수정 강제) 등
- 상세 안내: `prompts/README.md`

**경로 규칙** (`.claude/rules/`):

대화 중 접근한 파일 경로가 각 rule의 `paths` glob과 매칭될 때 자동 로드된다. 별도 지정 불필요.

| 파일 | 적용 경로 | 내용 |
|------|-----------|------|
| `java-spring.md` | `services/**`, `gateway/**`, `common/**/*.java` 등 | Lombok 규칙, MyBatis `#{}` 강제, 패키지 컨벤션, 주석 정책 (파일 헤더 없음, WHY-only 주석) |
| `testing.md` | `**/src/test/**/*.java` | 테스트 레이어 어노테이션, AssertJ/BDD 스타일, Testcontainers 미사용 주의 |
| `infra.md` | `infra/**`, `**/Dockerfile`, `.github/workflows/**` | 인프라 변경 제약 |
| `docs-workflow.md` | `docs/**/*.md`, `CLAUDE.md` | 문서 작성 규칙 |

> **주의**: `paths`가 없는 rule은 모든 대화에 전역 적용된다. 컨텍스트 낭비를 막기 위해 반드시 `paths`를 지정할 것.

---

## 다음 단계 (Phase 2)

`docs/backlog/PHASE2.md` 참조 (우선순위: `docs/decisions/DR-003-phase2-priority.md`):

- **P2-001**: Spring Security RBAC 강화 (Permission 기반 세분화)
- **P2-002**: JWT 보안 강화 (HttpOnly Cookie, Secure flag)
- **P2-003**: Rate Limiting 고도화 (사용자별 / 역할별)
- **P2-004**: Resilience4j Circuit Breaker 실전 적용
- DB per Service 분리
- Prometheus + Grafana 연동
- K8s 매니페스트 (Kustomize)
- Caffeine + Redis 2단계 캐시 활성화

> GitHub Actions CI (lint → test)는 PRE-A2+A3에서 구현 완료. Docker build·deploy 단계는 Phase 2 인프라 결정 후 추가.

미결정 사항은 `docs/decisions/DR-001~007.md` 참조.
