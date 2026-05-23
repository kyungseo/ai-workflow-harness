# HARNESS-STRUCTURE.md - AI Workflow Harness

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
        SKILLS[".agents/skills/**"]
        HOOKS[".codex/hooks.json"]
        PROMPTS["prompts/**"]
    end

    subgraph ADOPT["Adoption"]
        SCRIPT["scripts/create-harness.sh"]
        MANUAL["docs/WORKFLOW-MANUAL.md"]
        README["README.md"]
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

핵심 규칙:

- `STATUS.md`는 dashboard다.
- Work 파일은 작업 단위 SSoT다.
- Approval Matrix는 실행, 상태 변경, commit을 승인 게이트로 제어한다.
- Validation 실패 시 FAIL/RECOVER로 전환한 뒤 다음 작업을 진행한다.

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

routing 규칙은 의도적으로 조건부로 설계되어 있다. 에이전트는 현재 작업에 필요하지 않은
archive, manual, 과거 문서를 일괄 로드하지 않는다.

## 4. Document Roles

| 파일 | 역할 |
| --- | --- |
| `docs/PLAN.md` | 장기 방향과 roadmap |
| `docs/PLAN-SUMMARY.md` | 경량 프로젝트 및 아키텍처 컨텍스트 |
| `docs/STATUS.md` | 현재 dashboard 및 Active Work pointer |
| `docs/works/**` | 작업 단위 plan, checkpoint, discovery, Done Criteria |
| `docs/backlog/HARNESS.md` | harness 개선 후보 및 보류 항목 |
| `docs/decisions/**` | 확정된 결정과 tradeoff |
| `docs/retrospectives/**` | 리뷰 및 학습 산출물 |
| `docs/archive/**` | historical snapshot 및 완료 기록 |

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

Canonical 문서가 동작을 정의한다. Tool-specific 파일은 해당 도구가 runtime에 실제로 필요한 부분만 mirror한다.

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

generic profile은 특정 프로그래밍 언어, framework, database, application runtime을 가정하지 않는다.

## 7. Current Migration Boundary

`ai-workflow-harness`는 `base-msa-template`의 historical record를 보존하고 있다.
현재 live 문서는 harness project를 기준으로 기술해야 한다. Historical snapshot은
historical로 명확히 표시된 경우 product-template 맥락을 유지할 수 있다.
