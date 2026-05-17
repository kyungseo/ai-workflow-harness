# base-msa-template

Spring Boot 3.5 + Spring Cloud 2025 기반 MSA 스캐폴딩 템플릿입니다.
API Gateway, JWT token rotation, Redis rate limiting, MyBatis, PostgreSQL, Vanilla JS frontend, Checkstyle, GitHub Actions CI, Claude/Cursor AI workflow harness를 포함합니다.

## 주요 기능

- Spring Boot 3.5, Java 21, Gradle Kotlin DSL multi-module
- Spring Cloud Gateway 단일 진입점
- JWT access/refresh token rotation, Redis blacklist
- PostgreSQL 16 + MyBatis
- Redis sliding-window rate limiting
- Vanilla JS + Bootstrap frontend
- Checkstyle + Git hooks + GitHub Actions CI
- Claude Code / Cursor workflow harness

## 기술 스택

| 영역 | 스택 |
| --- | --- |
| Runtime | Java 21, Spring Boot 3.5.0 |
| Gateway | Spring Cloud Gateway 2025.0.0 |
| Auth | Spring Security, JJWT 0.12.x, Redis |
| Data | PostgreSQL 16, MyBatis 3 |
| Build | Gradle 8, Kotlin DSL |
| Quality | Checkstyle 10.21.0, EditorConfig, Git hooks |
| CI | GitHub Actions |
| Frontend | Vanilla JS, Bootstrap 5.3 |

## 사전 요건

- Docker Desktop 4.x+
- JDK 21+
- GNU Make
- Python 3 (frontend 로컬 서빙용)

## 빠른 시작

```bash
cp .env.example .env
```

`.env`에 필수 값을 입력한다:

```bash
JWT_SECRET=<256-bit 랜덤 문자열>
DB_USERNAME=<postgres 사용자명>
DB_PASSWORD=<postgres 비밀번호>
```

Git hooks 설치 후 전체 스택 기동:

```bash
sh tools/git-hooks/install.sh

cd scripts
make run
make ps
```

동작 확인:

```bash
curl -s http://localhost:8090/actuator/health
curl -s http://localhost:8099/actuator/health | python3 -m json.tool
curl -s http://localhost:8090/api/v1/auth/login \
  -X POST -H "Content-Type: application/json" \
  -d '{"username":"admin","password":"admin","deviceId":"test"}'
```

Frontend 실행:

```bash
cd frontend/web-app
python3 -m http.server 3000
```

`http://localhost:3000/login.html`에 접속한다.
초기 사용자는 `admin / admin`, `user / user`이다.

## 서비스 구성

| 서비스 | 포트 | 역할 |
| --- | --- | --- |
| api-gateway | 8090 | 라우팅, JWT 검증, rate limiting |
| auth-service | 8091 | 로그인, refresh, logout, blacklist |
| user-service | 8092 | 사용자 CRUD, RBAC 샘플 |
| todo-service | 8093 | Todo CRUD 샘플 |
| PostgreSQL | 5432 | Phase 1 공용 DB |
| Redis | 6379 | Refresh token, blacklist, rate limit |
| Actuator | 8099 | Management port |
| Frontend | 3000 | 정적 웹 앱 |

## 자주 쓰는 명령

```bash
cd scripts

make help
make run
make run-local
make rebuild
make stop
make logs
make logs SERVICE=api-gateway
make test
make build
make create-service NAME=order-service
```

## 문서

| 문서 | 역할 |
| --- | --- |
| [docs/ARCHITECTURE.md](docs/ARCHITECTURE.md) | 시스템 아키텍처 및 Mermaid 다이어그램 |
| [docs/DEVELOPER-GUIDE.md](docs/DEVELOPER-GUIDE.md) | 로컬 설정, 서비스/API/테스트 절차 |
| [docs/CODING-CONVENTIONS.md](docs/CODING-CONVENTIONS.md) | 코딩 컨벤션 SSOT |
| [docs/GIT-WORKFLOW.md](docs/GIT-WORKFLOW.md) | 브랜치 전략·PR 흐름·CI 연동 |
| [docs/DOCKERFILE-GUIDE.md](docs/DOCKERFILE-GUIDE.md) | Dockerfile 설명 및 개선 포인트 |
| [docs/PLAN-SUMMARY.md](docs/PLAN-SUMMARY.md) | 스택 및 아키텍처 요약 |
| [docs/PLAN.md](docs/PLAN.md) | 전체 기술 근거 |
| [docs/backlog/PHASE2.md](docs/backlog/PHASE2.md) | Product 및 Phase 2 준비 backlog |
| [docs/backlog/HARNESS.md](docs/backlog/HARNESS.md) | AI workflow harness backlog |
| [docs/decisions/](docs/decisions/) | Decision Records |
| [docs/troubleshooting/](docs/troubleshooting/) | 증상별 원인 분석 및 조치 기록 |

## AI Workflow Harness

경량 상태 머신 기반 AI 개발 workflow가 포함되어 있다.

| 문서 | 역할 |
| --- | --- |
| [CLAUDE.md](CLAUDE.md) | Claude Code 진입점 |
| [AGENTS.md](AGENTS.md) | Codex 진입점 |
| [docs/AGENT-WORKFLOW.md](docs/AGENT-WORKFLOW.md) | 공통 운영 규칙 |
| [docs/STATUS.md](docs/STATUS.md) | 현재 프로젝트 상태 |
| [docs/HARNESS-PROTOCOL.md](docs/HARNESS-PROTOCOL.md) | Harness protocol 허브 |
| [docs/HARNESS-QUICK-REFERENCE.md](docs/HARNESS-QUICK-REFERENCE.md) | 일상 실행 빠른 참조 |
| [docs/WORKFLOW-MANUAL.md](docs/WORKFLOW-MANUAL.md) | 사용자용 워크플로우 매뉴얼 |
| [docs/harness-protocol/](docs/harness-protocol/) | 상세 protocol 모듈 |
| [prompts/README.md](prompts/README.md) | 재사용 prompt 라이브러리 |

Claude Code slash command는 `.claude/commands/`에 있다.
Cursor rules는 `.cursor/rules/`에 있다.

## 테스트

통합 테스트는 Testcontainers로 자급자족한다. `docker compose up` 없이 실행 가능하다.

```bash
./gradlew test
```

PostgreSQL, Redis 컨테이너를 테스트 실행 시 자동 기동한다.

### Docker Desktop 4.73.0+ (macOS)

`build.gradle.kts`에 Docker API 버전과 소켓 경로가 설정되어 있으므로 별도 로컬 설정 없이 `./gradlew test`가 동작한다.

연결 오류가 발생하면 [docs/troubleshooting/testcontainers-docker-desktop-4.73.md](docs/troubleshooting/testcontainers-docker-desktop-4.73.md)를 참조한다.

## CI

`develop` push 시 Checkstyle을 실행한다.
`main` push 또는 `main` 대상 PR에서 `lint → test` 순서로 실행된다.

[.github/workflows/ci.yml](.github/workflows/ci.yml) 참조.

## 라이선스

[LICENSE.txt](LICENSE.txt) 참조.
