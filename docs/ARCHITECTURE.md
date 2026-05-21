# ARCHITECTURE.md - AI Workflow Harness

> 기준: `docs/PLAN.md`, `docs/PLAN-SUMMARY.md`
> 목적: AI Workflow Harness의 현재 구조와 정보 흐름을 시각화한다.

---

## 1. System Overview

```mermaid
graph TB
    USER["User / Maintainer"]
    AGENT["AI Agent\nClaude Code / Codex / Cursor"]

    subgraph ENTRY["Entry Contract"]
        CLAUDE["CLAUDE.md"]
        AGENTS["AGENTS.md"]
    end

    subgraph CORE["Core Workflow"]
        BP["docs/BEHAVIOR-PRINCIPLES.md"]
        AW["docs/AGENT-WORKFLOW.md"]
        HP["docs/HARNESS-PROTOCOL.md"]
        QR["docs/HARNESS-QUICK-REFERENCE.md"]
    end

    subgraph STATE["State and Tracking"]
        STATUS["docs/STATUS.md"]
        WORKS["docs/works/**"]
        BACKLOG["docs/backlog/**"]
        DR["docs/decisions/**"]
    end

    subgraph TOOLS["Tool Mirrors"]
        COMMANDS[".claude/commands/**"]
        CRULES[".claude/rules/**"]
        CURSOR[".cursor/rules/**"]
        PROMPTS["prompts/**"]
    end

    subgraph ADOPT["Adoption"]
        SCRIPT["scripts/create-harness.sh"]
        MANUAL["docs/WORKFLOW-MANUAL.md"]
        SUMMARY["docs/WORKFLOW-MANUAL-SUMMARY-PUBLIC.md"]
    end

    USER --> AGENT
    AGENT --> ENTRY
    ENTRY --> CORE
    CORE --> STATE
    CORE --> TOOLS
    STATE --> TOOLS
    CORE --> ADOPT
```

## 2. Session Flow

```mermaid
stateDiagram-v2
    [*] --> INIT
    INIT --> PLAN
    PLAN --> APPROVAL
    APPROVAL --> EXECUTE
    EXECUTE --> VALIDATE
    VALIDATE --> CHECKPOINT
    CHECKPOINT --> END
    VALIDATE --> FAIL
    FAIL --> RECOVER
    RECOVER --> PLAN
    APPROVAL --> PLAN: scope changes
```

Core rule:

- `STATUS.md` is the dashboard.
- Work files are the task-level SSoT.
- Approval Matrix gates execution, state changes, and commits.
- Validation failure moves to FAIL/RECOVER before more work proceeds.

## 3. Context Routing

```mermaid
flowchart TD
    START["Session Start"] --> STATUS["Read docs/STATUS.md current sections"]
    STATUS --> NEED{"Need more context?"}
    NEED -->|"Architecture summary"| PLAN_SUMMARY["docs/PLAN-SUMMARY.md"]
    NEED -->|"Planning basis / L3"| PLAN["docs/PLAN.md"]
    NEED -->|"Harness task"| HARNESS["docs/backlog/HARNESS.md"]
    NEED -->|"Active Work"| WORK["docs/works/{category}/{ID}.md"]
    NEED -->|"Decision context"| DR["docs/decisions/DR-*.md"]
    NEED -->|"Issue history"| TROUBLE["docs/troubleshooting/"]
    NEED -->|"No"| EXEC["Plan next action"]
```

The routing rule is deliberately conditional. Agents should not bulk-load archive,
manual, or historical documents unless the current task needs them.

## 4. Document Roles

| File | Role |
| --- | --- |
| `docs/PLAN.md` | Long-term direction and roadmap |
| `docs/PLAN-SUMMARY.md` | Lightweight project and architecture context |
| `docs/STATUS.md` | Current dashboard and active work pointer |
| `docs/works/**` | Task-level plan, checkpoints, discovery, Done Criteria |
| `docs/backlog/HARNESS.md` | Candidate and deferred harness improvements |
| `docs/decisions/**` | Accepted decisions and trade-offs |
| `docs/retrospectives/**` | Review and learning artifacts |
| `docs/archive/**` | Historical snapshots and closed records |

## 5. Tool Surface Model

```mermaid
graph LR
    CANON["Canonical docs\nBEHAVIOR / AGENT-WORKFLOW / PROTOCOL"]
    CLAUDE["Claude Code\ncommands + rules"]
    CODEX["Codex\nAGENTS.md + prompts"]
    CURSOR["Cursor\n.cursor/rules"]
    SCAFFOLD["create-harness.sh"]

    CANON --> CLAUDE
    CANON --> CODEX
    CANON --> CURSOR
    CANON --> SCAFFOLD
```

Canonical docs define behavior. Tool-specific files mirror only the portions those
tools actually need at runtime.

## 6. Scaffold Flow

```mermaid
sequenceDiagram
    participant U as User
    participant S as create-harness.sh
    participant T as Target Repository

    U->>S: --profile generic my-project /path/to/repo
    S->>T: create entrypoints
    S->>T: create workflow docs
    S->>T: create tool rules and commands
    S->>T: create skeleton STATUS / PLAN / backlog / works
    S-->>U: report required first-session fields
```

The generic profile should not assume a programming language, framework, database,
or application runtime.

## 7. Current Migration Boundary

`ai-workflow-harness` still preserves historical records from `base-msa-template`.
Current live guidance should describe the harness project. Historical snapshots may
keep product-template context when clearly marked as historical.
