# ai-workflow-harness

AI 보조 개발을 위한 Manual-first AI Workflow Harness.

AI 코딩 에이전트(Claude Code, Codex, Cursor)와 반복 세션을 운영할 때 발생하는 핵심 문제를 해결한다:
scope 확장, 상태 불일치, 승인 없는 실행, 결정 기록 소실.
하네스는 이 문제들을 workflow 엔진 없이 — 문서와 명시적 gate만으로 — 제어한다.

하네스는 AI session을 감싸는 운영 골격이다. Workflow 엔진이나 task runner가 아니다.
사람과 에이전트가 반복 세션과 다수 도구에 걸쳐 scope, 상태, 결정, 검증을 정렬할 수 있도록 한다.

## What This Provides

| 구성 요소 | 역할 |
| --- | --- |
| Entry Contract | 세션 시작 시 에이전트가 읽는 진입 계약 (`CLAUDE.md`, `AGENTS.md`) |
| Behavior Principles | 모든 AI 도구에 적용되는 전역 행동 원칙 |
| Approval Matrix | scope, 상태 변경, commit을 명시적 gate로 제어 |
| State & Tracking | `STATUS.md` dashboard, Work 파일 lifecycle, backlog, Decision Record |
| Tool Mirrors | Claude Code command, Cursor rule, portable prompt template |
| Scaffold | 다른 repository에 하네스를 적용하는 generic scaffold script |

## Key Documents

### Entry Points

| 문서 | 역할 |
| --- | --- |
| [AGENTS.md](AGENTS.md) | Codex 진입점 |
| [CLAUDE.md](CLAUDE.md) | Claude Code 진입점 |

### Workflow Core

| 문서 | 역할 |
| --- | --- |
| [docs/BEHAVIOR-PRINCIPLES.md](docs/BEHAVIOR-PRINCIPLES.md) | 전역 행동 원칙 — 모든 AI 도구 공통 |
| [docs/AGENT-WORKFLOW.md](docs/AGENT-WORKFLOW.md) | 공통 workflow, Approval Matrix, status 규칙 |
| [docs/HARNESS-PROTOCOL.md](docs/HARNESS-PROTOCOL.md) | 상세 protocol 레퍼런스 |
| [docs/HARNESS-QUICK-REFERENCE.md](docs/HARNESS-QUICK-REFERENCE.md) | 세션 실행 규칙 빠른 참조 |
| [docs/GIT-WORKFLOW.md](docs/GIT-WORKFLOW.md) | Git 브랜치 전략과 커밋 규칙 |

### State & Tracking

| 문서 | 역할 |
| --- | --- |
| [docs/STATUS.md](docs/STATUS.md) | 현재 프로젝트 dashboard |
| [docs/PLAN.md](docs/PLAN.md) | 프로젝트 방향과 roadmap |
| [docs/PLAN-SUMMARY.md](docs/PLAN-SUMMARY.md) | 세션 컨텍스트 경량 요약 |
| [docs/works/](docs/works/) | Work 파일 및 인덱스 |
| [docs/backlog/HARNESS.md](docs/backlog/HARNESS.md) | Harness 개선 backlog |
| [docs/decisions/](docs/decisions/) | Decision Records |

### Reference & Manual

| 문서 | 역할 |
| --- | --- |
| [docs/WORKFLOW-MANUAL.md](docs/WORKFLOW-MANUAL.md) | 사용자용 workflow manual |
| [docs/WORKFLOW-MANUAL-SUMMARY-PUBLIC.md](docs/WORKFLOW-MANUAL-SUMMARY-PUBLIC.md) | 공개용 workflow 요약 |
| [prompts/README.md](prompts/README.md) | Prompt 라이브러리 안내 |

### Structure & Maintenance

| 문서 | 역할 |
| --- | --- |
| [docs/HARNESS-STRUCTURE.md](docs/HARNESS-STRUCTURE.md) | harness 구조와 정보 흐름 시각화 |
| [docs/HARNESS-MAINTAINER-GUIDE.md](docs/HARNESS-MAINTAINER-GUIDE.md) | 유지보수·convention 가이드 |

## Quick Start

### 이 Repository에서 작업

로컬 hook 설치:

```bash
sh tools/git-hooks/install.sh
```

Claude Code 세션: `/start` 실행 또는 [docs/STATUS.md](docs/STATUS.md) 확인.
Codex 세션: [AGENTS.md](AGENTS.md)를 읽는 것으로 시작한다.

### 새 프로젝트에 하네스 적용

새 repository에 generic harness scaffold 생성:

```bash
./scripts/create-harness.sh --profile generic my-project /path/to/my-project
```

기존 repository에 적용:

```bash
./scripts/create-harness.sh --existing --profile generic my-project /path/to/existing-repo
```

Scaffold 후 첫 세션에서 [docs/PLAN-SUMMARY.md](docs/PLAN-SUMMARY.md)의 Project Constants를 프로젝트에 맞게 채운다.

## Repository Layout

```text
.
├── AGENTS.md                         # Codex 진입점
├── CLAUDE.md                         # Claude Code 진입점
├── .claude/
│   ├── commands/                     # slash command 정의 (/start, /work, /close 등)
│   └── rules/                        # path-scoped rule mirror
├── .cursor/
│   └── rules/                        # Cursor rule mirror
├── docs/
│   ├── BEHAVIOR-PRINCIPLES.md        # 전역 행동 원칙
│   ├── AGENT-WORKFLOW.md             # 공통 workflow·Approval Matrix
│   ├── HARNESS-PROTOCOL.md           # 상세 protocol 레퍼런스
│   ├── HARNESS-QUICK-REFERENCE.md    # 세션 실행 규칙 빠른 참조
│   ├── HARNESS-STRUCTURE.md          # harness 구조 시각화
│   ├── HARNESS-MAINTAINER-GUIDE.md   # 유지보수·convention 가이드
│   ├── GIT-WORKFLOW.md               # Git 브랜치·커밋 전략
│   ├── STATUS.md                     # 현재 dashboard
│   ├── PLAN.md                       # 프로젝트 방향·roadmap
│   ├── PLAN-SUMMARY.md               # 세션 컨텍스트 요약
│   ├── WORKFLOW-MANUAL.md            # 사용자용 workflow manual
│   ├── backlog/                      # 후보 작업 목록
│   ├── decisions/                    # Decision Records
│   ├── retrospectives/               # 회고 기록
│   └── works/                        # Work 파일 (작업 단위 SSoT)
├── prompts/                          # portable prompt 템플릿
├── scripts/
│   └── create-harness.sh             # scaffold script
└── tools/
    └── git-hooks/                    # pre-commit hook
```

## Validation

```bash
git diff --check
bash -n scripts/create-harness.sh
./scripts/create-harness.sh --dry-run --profile generic sample /tmp/sample
```

## Origin

이 저장소는 [`kyungseo/base-msa-template`](https://github.com/kyungseo/base-msa-template)에서
Git history를 보존한 채 추출되었다. 하네스는 Spring Boot MSA template을 hardening하는 과정에서 형성되었으며,
현재는 AI Workflow Harness 자체에 집중한다.

## License

[LICENSE](LICENSE) 참조.
