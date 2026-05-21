# ai-workflow-harness

AI 보조 개발을 위한 Manual-first AI Workflow Harness.

이 저장소는 AI 코딩 에이전트와 협업하기 위한 운영 구조를 제공한다:
진입 계약, 상태 추적, 승인 게이트, Work 파일, 의사결정 기록,
도구별 rule mirror, prompt 템플릿, 검증 기본값, 복구 흐름.

Workflow 엔진이나 task runner가 아니다. 하네스는 AI 세션을 감싸
사람과 에이전트가 반복 세션과 다수 도구에 걸쳐 scope, 상태, 결정, 검증을 정렬할 수 있도록 한다.

## Origin

이 저장소는 [`kyungseo/base-msa-template`](https://github.com/kyungseo/base-msa-template)에서
Git history를 보존한 채 추출되었다. 하네스는 원래 Spring Boot MSA template을 hardening하는 과정에서 개발되었다.
현재 프로젝트는 AI Workflow Harness 자체에 집중한다.

## What This Provides

- Codex / Claude Code 진입 계약 (entry contract)
- AI 도구 공통 행동 원칙
- 공통 workflow 규칙과 Approval Matrix
- `STATUS.md` dashboard와 Work 파일 lifecycle
- Decision Record 및 archive 규칙
- Claude Code command 정의
- Cursor rule mirror
- 이식 가능한 prompt 템플릿
- 다른 저장소에 하네스를 적용하는 generic scaffold script
- 공개용 workflow manual과 quick reference

## Core Documents

| 문서 | 역할 |
| --- | --- |
| [AGENTS.md](AGENTS.md) | Codex 진입점 |
| [CLAUDE.md](CLAUDE.md) | Claude Code 진입점 |
| [docs/BEHAVIOR-PRINCIPLES.md](docs/BEHAVIOR-PRINCIPLES.md) | 전역 행동 원칙 |
| [docs/AGENT-WORKFLOW.md](docs/AGENT-WORKFLOW.md) | 공통 workflow, 상태 규칙, Approval Matrix |
| [docs/HARNESS-PROTOCOL.md](docs/HARNESS-PROTOCOL.md) | 상세 protocol 레퍼런스 |
| [docs/HARNESS-QUICK-REFERENCE.md](docs/HARNESS-QUICK-REFERENCE.md) | 세션 실행 규칙 빠른 참조 |
| [docs/STATUS.md](docs/STATUS.md) | 현재 프로젝트 dashboard |
| [docs/PLAN.md](docs/PLAN.md) | 프로젝트 방향과 roadmap |
| [docs/PLAN-SUMMARY.md](docs/PLAN-SUMMARY.md) | 세션 컨텍스트 요약 |
| [docs/WORKFLOW-MANUAL.md](docs/WORKFLOW-MANUAL.md) | 사용자용 workflow manual |
| [docs/WORKFLOW-MANUAL-SUMMARY-PUBLIC.md](docs/WORKFLOW-MANUAL-SUMMARY-PUBLIC.md) | 공개용 요약 |
| [docs/works/](docs/works/) | Work 파일 및 인덱스 |
| [docs/backlog/HARNESS.md](docs/backlog/HARNESS.md) | Harness backlog |
| [docs/decisions/](docs/decisions/) | Decision Records |
| [prompts/README.md](prompts/README.md) | Prompt 라이브러리 안내 |

## Repository Layout

```text
.
├── AGENTS.md
├── CLAUDE.md
├── .claude/
│   ├── commands/
│   └── rules/
├── .cursor/
│   └── rules/
├── docs/
│   ├── AGENT-WORKFLOW.md
│   ├── HARNESS-PROTOCOL.md
│   ├── HARNESS-QUICK-REFERENCE.md
│   ├── STATUS.md
│   ├── PLAN.md
│   ├── PLAN-SUMMARY.md
│   ├── WORKFLOW-MANUAL.md
│   ├── backlog/
│   ├── decisions/
│   ├── retrospectives/
│   └── works/
├── prompts/
├── scripts/
│   └── create-harness.sh
└── tools/
    └── git-hooks/
```

## Quick Start

로컬 hook 설치:

```bash
sh tools/git-hooks/install.sh
```

scaffold script 검증:

```bash
bash -n scripts/create-harness.sh
./scripts/create-harness.sh --dry-run --profile generic sample-harness /tmp/sample-harness
```

Codex 세션은 [AGENTS.md](AGENTS.md)를 읽는 것으로 시작한다.
Claude Code 세션은 [CLAUDE.md](CLAUDE.md)를 읽거나 [.claude/commands/](.claude/commands/)의 command 정의를 사용한다.

## Scaffold

새 generic harness scaffold 생성:

```bash
./scripts/create-harness.sh --profile generic my-project /path/to/my-project
```

기존 저장소에 하네스 적용:

```bash
./scripts/create-harness.sh --existing --profile generic my-project /path/to/existing-repo
```

## Current Status

이 저장소는 초기 public-ready migration 상태다. 아래를 참조:

- [docs/STATUS.md](docs/STATUS.md)
- [docs/works/harness/AWH-001-public-repo-migration.md](docs/works/harness/AWH-001-public-repo-migration.md)

## Validation

기본 검증:

```bash
git diff --check
bash -n scripts/create-harness.sh
./scripts/create-harness.sh --dry-run --profile generic sample /tmp/sample
```

## License

[LICENSE.txt](LICENSE.txt) 참조.
