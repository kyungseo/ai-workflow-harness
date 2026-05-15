# base-msa-template

Spring Boot 3.5 + Spring Cloud 2025 기반 MSA 스캐폴딩 템플릿입니다.
API Gateway, JWT token rotation, Redis rate limiting, MyBatis, PostgreSQL, Vanilla JS frontend, Checkstyle, GitHub Actions CI, Claude/Cursor AI workflow harness를 포함합니다.

## Features

- Spring Boot 3.5, Java 21, Gradle Kotlin DSL multi-module
- Spring Cloud Gateway 단일 진입점
- JWT access/refresh token rotation, Redis blacklist
- PostgreSQL 16 + MyBatis
- Redis sliding-window rate limiting
- Vanilla JS + Bootstrap frontend
- Checkstyle + Git hooks + GitHub Actions CI
- Claude Code / Cursor workflow harness

## Tech Stack

| Area | Stack |
| --- | --- |
| Runtime | Java 21, Spring Boot 3.5.0 |
| Gateway | Spring Cloud Gateway 2025.0.0 |
| Auth | Spring Security, JJWT 0.12.x, Redis |
| Data | PostgreSQL 16, MyBatis 3 |
| Build | Gradle 8, Kotlin DSL |
| Quality | Checkstyle 10.21.0, EditorConfig, Git hooks |
| CI | GitHub Actions |
| Frontend | Vanilla JS, Bootstrap 5.3 |

## Requirements

- Docker Desktop 4.x+
- JDK 21+
- GNU Make
- Python 3 for local frontend serving

## Quick Start

```bash
cp .env.example .env
```

Edit required values in `.env`:

```bash
JWT_SECRET=<256-bit random string>
DB_USERNAME=<postgres username>
DB_PASSWORD=<postgres password>
```

Install hooks and run the full stack:

```bash
sh tools/git-hooks/install.sh

cd scripts
make run
make ps
```

Verify:

```bash
curl -s http://localhost:8090/actuator/health
curl -s http://localhost:8099/actuator/health | python3 -m json.tool
curl -s http://localhost:8090/api/v1/auth/login \
  -X POST -H "Content-Type: application/json" \
  -d '{"username":"admin","password":"admin","deviceId":"test"}'
```

Run the frontend:

```bash
cd frontend/web-app
python3 -m http.server 3000
```

Open `http://localhost:3000/login.html`.
Initial users are `admin / admin` and `user / user`.

## Services

| Service | Port | Role |
| --- | --- | --- |
| api-gateway | 8090 | Routing, JWT validation, rate limiting |
| auth-service | 8091 | Login, refresh, logout, blacklist |
| user-service | 8092 | User CRUD and RBAC sample |
| todo-service | 8093 | Todo CRUD sample |
| PostgreSQL | 5432 | Shared DB for Phase 1 |
| Redis | 6379 | Refresh tokens, blacklist, rate limits |
| Actuator | 8099 | Management port |
| Frontend | 3000 | Static web app |

## Common Commands

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

## Documentation

| Document | Purpose |
| --- | --- |
| [docs/ARCHITECTURE.md](docs/ARCHITECTURE.md) | System architecture and Mermaid diagrams |
| [docs/DEVELOPER-GUIDE.md](docs/DEVELOPER-GUIDE.md) | Local setup, service/API/test procedures |
| [docs/CODING-CONVENTIONS.md](docs/CODING-CONVENTIONS.md) | Coding convention SSOT |
| [docs/DOCKERFILE-GUIDE.md](docs/DOCKERFILE-GUIDE.md) | Dockerfile explanation and improvement points |
| [docs/PLAN-SUMMARY.md](docs/PLAN-SUMMARY.md) | Lightweight stack and architecture summary |
| [docs/PLAN.md](docs/PLAN.md) | Full technical rationale |
| [docs/backlog/PHASE2.md](docs/backlog/PHASE2.md) | Product and Phase2 preparation backlog |
| [docs/backlog/HARNESS.md](docs/backlog/HARNESS.md) | AI workflow harness backlog |
| [docs/decisions/](docs/decisions/) | Decision Records |

## AI Workflow Harness

This repository includes a lightweight state-machine-based AI development workflow.

| Document | Purpose |
| --- | --- |
| [CLAUDE.md](CLAUDE.md) | Root Claude Code contract |
| [AGENTS.md](AGENTS.md) | Root Codex contract |
| [docs/AGENT-WORKFLOW.md](docs/AGENT-WORKFLOW.md) | Shared agent operating rules |
| [docs/STATUS.md](docs/STATUS.md) | Live project state |
| [docs/HARNESS-PROTOCOL.md](docs/HARNESS-PROTOCOL.md) | Harness protocol hub |
| [docs/HARNESS-QUICK-REFERENCE.md](docs/HARNESS-QUICK-REFERENCE.md) | Daily execution quick reference |
| [docs/harness-protocol/](docs/harness-protocol/) | Detailed protocol modules |
| [prompts/README.md](prompts/README.md) | Reusable prompt library guide |

Claude Code slash commands live in `.claude/commands/`.
Cursor rules live in `.cursor/rules/`.

## Testing

```bash
cd scripts
make run-local
make test
```

Current integration tests use local PostgreSQL and Redis containers.
DR-010 accepted Testcontainers as the target strategy; implementation is tracked in [P2-006](docs/backlog/PHASE2.md).

## CI

GitHub Actions runs Checkstyle on `develop` pushes.
Tests run after lint on `main` pushes and PRs targeting `main`.

See [.github/workflows/ci.yml](.github/workflows/ci.yml).

## License

See [LICENSE.txt](LICENSE.txt).
