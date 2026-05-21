# ai-workflow-harness

Manual-first AI Workflow Harness for AI-assisted development.

This repository provides an operating structure for working with AI coding agents:
entry contracts, state tracking, approval gates, Work files, decision records,
tool-specific rule mirrors, prompt templates, validation defaults, and recovery flow.

It is not an AI workflow engine or task runner. The harness wraps AI sessions so
humans and agents can keep scope, state, decisions, and verification aligned across
repeated sessions and multiple tools.

## Origin

This repository was extracted from [`kyungseo/base-msa-template`](https://github.com/kyungseo/base-msa-template)
with Git history preserved. The harness was originally developed while hardening a
Spring Boot MSA template. The current project is now focused on the AI Workflow
Harness itself.

## What This Provides

- Codex and Claude Code entry contracts
- Shared behavior principles for AI tools
- Common workflow rules and Approval Matrix
- `STATUS.md` dashboard and Work file lifecycle
- Decision Record and archive conventions
- Claude Code command definitions
- Cursor rule mirrors
- Portable prompt templates
- Generic scaffold script for applying the harness to another repository
- Public workflow manual and quick reference

## Core Documents

| Document | Role |
| --- | --- |
| [AGENTS.md](AGENTS.md) | Codex entrypoint |
| [CLAUDE.md](CLAUDE.md) | Claude Code entrypoint |
| [docs/BEHAVIOR-PRINCIPLES.md](docs/BEHAVIOR-PRINCIPLES.md) | Global behavior principles |
| [docs/AGENT-WORKFLOW.md](docs/AGENT-WORKFLOW.md) | Common workflow, status rules, Approval Matrix |
| [docs/HARNESS-PROTOCOL.md](docs/HARNESS-PROTOCOL.md) | Detailed protocol reference |
| [docs/HARNESS-QUICK-REFERENCE.md](docs/HARNESS-QUICK-REFERENCE.md) | Short operational reference |
| [docs/STATUS.md](docs/STATUS.md) | Current project dashboard |
| [docs/PLAN.md](docs/PLAN.md) | Project direction and roadmap |
| [docs/PLAN-SUMMARY.md](docs/PLAN-SUMMARY.md) | Session context summary |
| [docs/WORKFLOW-MANUAL.md](docs/WORKFLOW-MANUAL.md) | User-facing workflow manual |
| [docs/WORKFLOW-MANUAL-SUMMARY-PUBLIC.md](docs/WORKFLOW-MANUAL-SUMMARY-PUBLIC.md) | Public summary |
| [docs/works/](docs/works/) | Work files and indexes |
| [docs/backlog/HARNESS.md](docs/backlog/HARNESS.md) | Harness backlog |
| [docs/decisions/](docs/decisions/) | Decision Records |
| [prompts/README.md](prompts/README.md) | Prompt library guide |

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

Install local hooks:

```bash
sh tools/git-hooks/install.sh
```

Validate the scaffold script:

```bash
bash -n scripts/create-harness.sh
./scripts/create-harness.sh --dry-run --profile generic sample-harness /tmp/sample-harness
```

Start a Codex session by reading [AGENTS.md](AGENTS.md). Start a Claude Code
session by reading [CLAUDE.md](CLAUDE.md) or by using the command definitions in
[.claude/commands/](.claude/commands/).

## Scaffold

Create a new generic harness scaffold:

```bash
./scripts/create-harness.sh --profile generic my-project /path/to/my-project
```

Apply the harness to an existing repository:

```bash
./scripts/create-harness.sh --existing --profile generic my-project /path/to/existing-repo
```

## Current Status

This repository is in an initial public-ready migration. See:

- [docs/STATUS.md](docs/STATUS.md)
- [docs/works/harness/AWH-001-public-repo-migration.md](docs/works/harness/AWH-001-public-repo-migration.md)

## Validation

Default checks:

```bash
git diff --check
bash -n scripts/create-harness.sh
./scripts/create-harness.sh --dry-run --profile generic sample /tmp/sample
```

## License

See [LICENSE.txt](LICENSE.txt).
