# HARNESS-ARCHITECTURE.md - AI Workflow Harness

> 기준: `docs/PLAN.md`, `docs/PLAN-SUMMARY.md`
> 목적: AI Workflow Harness의 현재 아키텍처와 정보 흐름을 시각화한다.

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

    subgraph SLICES["Conditional Policy Slices"]
        NAMING["docs/HARNESS-NAMING-RULES.md"]
        RECOVERY["docs/HARNESS-RECOVERY-VALIDATION.md"]
        PARALLEL["docs/HARNESS-PARALLEL-WORK-CONTROLS.md"]
    end

    subgraph STATE["State and Tracking"]
        STATUS["docs/STATUS.md"]
        WORKS["docs/works/**"]
        BACKLOG["docs/backlog/**"]
        DR["docs/decisions/**"]
    end

    subgraph BRANCH["Branch and Release"]
        GIT["docs/GIT-WORKFLOW.md"]
        CI[".github/workflows/**"]
        HOOKS["tools/git-hooks/**"]
    end

    subgraph TOOLS["Tool Mirrors"]
        COMMANDS[".claude/commands/**"]
        CRULES[".claude/rules/**"]
        CURSOR[".cursor/rules/**"]
        SKILLS[".agents/skills/**"]
        CODEXHOOKS[".codex/hooks.json"]
        PROMPTS["prompts/**"]
    end

    subgraph ADOPT["Adoption"]
        SCRIPT["scripts/create-harness.sh"]
        BOOTSTRAP["docs/BOOTSTRAP.md"]
        SCAFFOLD_BS["docs/SCAFFOLD-BOOTSTRAP.md"]
        ONBOARD["docs/SCAFFOLD-ONBOARDING-GUIDE.md"]
        MANUAL["docs/WORKFLOW-MANUAL.md"]
        README["README.md"]
    end

    USER --> AGENT
    AGENT --> ENTRY
    ENTRY --> CORE
    CORE --> SLICES
    CORE --> STATE
    CORE --> BRANCH
    CORE --> TOOLS
    STATE --> TOOLS
    BRANCH --> TOOLS
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
    NEED -->|"세션 실행 규칙 빠른 확인"| QR["docs/HARNESS-QUICK-REFERENCE.md"]
    NEED -->|"Scaffold onboarding 설계 기준"| SCAFFOLD_BS["docs/SCAFFOLD-BOOTSTRAP.md"]
    NEED -->|"Work ID / OQ / DR ID / filename"| NAMING["docs/HARNESS-NAMING-RULES.md"]
    NEED -->|"Validation failure / recovery / commit approval"| RECOVERY["docs/HARNESS-RECOVERY-VALIDATION.md"]
    NEED -->|"Parallel branch / agent conflict"| PARALLEL["docs/HARNESS-PARALLEL-WORK-CONTROLS.md"]
    NEED -->|"Branch / PR / release intent"| GIT["docs/GIT-WORKFLOW.md"]
    NEED -->|"우선순위 / 반복 risk 확인"| RETRO["docs/retrospectives/"]
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
| `docs/HARNESS-QUICK-REFERENCE.md` | 세션 실행 규칙 빠른 확인용 요약 (session start, cascade triggers, commit checklist, command taxonomy) |
| `docs/HARNESS-NAMING-RULES.md` | Work/OQ/DR ID, 파일명, branch slug 관련 조건부 naming 기준 |
| `docs/HARNESS-RECOVERY-VALIDATION.md` | failure, recovery, validation, commit approval 조건부 기준 |
| `docs/HARNESS-PARALLEL-WORK-CONTROLS.md` | 병렬 branch/agent 충돌, Work ID/DR 번호, STATUS/index 복구 기준 |
| `docs/GIT-WORKFLOW.md` | source repo Gitflow, release gate, commit format |
| `docs/BOOTSTRAP.md` | scaffolded product repo 첫 세션 입력 gate |
| `docs/SCAFFOLD-BOOTSTRAP.md` | scaffold onboarding 설계 기준 (source) |
| `docs/SCAFFOLD-ONBOARDING-GUIDE.md` | scaffold 사용자의 초기 adoption guide |
| `docs/HARNESS-MAINTAINER-GUIDE.md` | harness 유지보수 가이드 |
| `docs/WORKFLOW-MANUAL.md` | 사람이 읽는 workflow manual |
| `README.md` | public-facing quick start와 repo 소개 |
| `docs/retrospectives/**` | 리뷰 및 학습 산출물 |
| `docs/archive/**` | historical snapshot 및 완료 기록 |

## 5. Tool Surface Model

```mermaid
graph LR
    CANON["Canonical docs\nBEHAVIOR / AGENT-WORKFLOW / PROTOCOL"]
    SLICES["Conditional slices\nNAMING / RECOVERY / PARALLEL"]
    CLAUDE["Claude Code\n.claude/commands + .claude/rules"]
    CODEX["Codex\nAGENTS.md + .agents/skills + .codex/hooks.json"]
    CURSOR["Cursor\n.cursor/rules"]
    PROMPTS["prompts/**\n(shared fallback)"]
    SCAFFOLD["create-harness.sh\n+ scripts/templates/**"]

    CANON --> CLAUDE
    CANON --> CODEX
    CANON --> CURSOR
    CANON --> PROMPTS
    CANON --> SCAFFOLD
    CANON --> SLICES
    SLICES --> CLAUDE
    SLICES --> CODEX
    CLAUDE <-->|"command/skill mirror"| CODEX
    CURSOR -->|"rule mirror"| CANON
```

Canonical 문서가 동작을 정의한다. Tool-specific 파일은 해당 도구가 runtime에 실제로 필요한 부분만 mirror한다.
조건부 slice는 항상 로드되는 core 문서가 아니라, 해당 충돌·검증·naming 상황에서만 로드되는 policy surface다.

## 6. Scaffold Flow

### Script Execution

```mermaid
sequenceDiagram
    participant U as User
    participant S as create-harness.sh
    participant T as Target Repository

    U->>S: --profile generic my-project /path/to/repo
    S->>T: create entrypoints
    S->>T: create workflow docs
    S->>T: create tool rules and commands
    S->>T: copy conditional slices
    opt source-gitflow workflow
        S->>T: add docs/GIT-WORKFLOW.md and source-gitflow marker
    end
    S->>T: create skeleton STATUS / PLAN / backlog / works
    S-->>U: report required first-session fields
    Note over U,T: .git/ 없으면 git init + initial commit 안내<br/>git 기반 절차는 Not Applicable
```

generic profile은 특정 프로그래밍 언어, framework, database, application runtime, source repo Gitflow를 가정하지 않는다.
source-gitflow workflow는 harness source repo와 동일한 feature -> develop -> main 운영 모델이 필요한 경우에만 선택한다.

### First Session Bootstrap Gate

```mermaid
flowchart TD
    A["/session-start"] --> B["STATUS.md → bootstrap pointer 확인"]
    B --> C["docs/BOOTSTRAP.md 로드"]
    C --> D{"Product Definition\n확정됐는가?"}
    D -->|No| E["Product Definition Gate\n제품 목표·범위·사용자 정의"]
    E --> D
    D -->|Yes| F{"Project Initialization\nbaseline 확정됐는가?"}
    F -->|No| G["Project Initialization Gate\nruntime·framework·build·DB baseline"]
    G --> F
    F -->|Yes| H["PLAN.md / PLAN-SUMMARY.md\nProject Constants 채우기"]
    H --> I["Phase 1 backlog 도출"]
    I --> J["Feature work 시작 가능"]
```

Product Definition과 Project Initialization baseline이 비어 있으면 Phase 1 backlog를 도출하지 않는다.

## 7. Source Repo / Product Repo Boundary

```mermaid
flowchart LR
    SOURCE["Harness source repo"]
    DEFAULT["Default scaffold product repo"]
    GITFLOW["Source-gitflow scaffold product repo"]

    SOURCE -->|"maintains templates, slices, release gate"| DEFAULT
    SOURCE -->|"optional workflow profile"| GITFLOW
    DEFAULT -->|"project-specific branch/release policy"| PROJECT_POLICY["Project docs"]
    GITFLOW -->|"docs/GIT-WORKFLOW.md marker"| SOURCE_STYLE["source-style Gitflow checks"]
```

source repo 규칙은 scaffold product repo에 무조건 적용되지 않는다. product repo는 기본적으로 project-specific branch/release policy를 따른다.
`source-gitflow` marker가 있는 scaffold에만 source-style branch isolation과 release gate를 적용한다.

## 8. Migration Boundary

harness를 기존 프로젝트에 overlay 적용한 경우, live 문서와 historical snapshot 간 경계를 명확히 한다.
현재 live 문서는 이 harness 기준으로 기술한다. Historical snapshot은 historical로 명확히 표시된 경우 이전 맥락을 유지할 수 있다.

## 9. Document Priority Hierarchy

충돌 시 상위 계층이 하위 계층을 override한다.
세션 시작 시 자동 로드되는 계층은 `BEHAVIOR-PRINCIPLES.md`와 `AGENT-WORKFLOW.md`다. 나머지는 조건부 로드다.

```mermaid
graph TD
    BP["BEHAVIOR-PRINCIPLES.md\n전역 행동 원칙 — 최우선, 항상 적용"]
    AW["AGENT-WORKFLOW.md\n공통 실행 규칙 — 세션 자동 로드"]
    HP["HARNESS-PROTOCOL.md\n상세 프로토콜 — 조건부 로드"]
    QR["HARNESS-QUICK-REFERENCE.md\n일상 실행 요약 — 조건부 로드"]
    TOOLS["Tool-specific surfaces\n.claude/rules · .cursor/rules · .agents/skills\n도구 실행 시 적용"]

    BP -->|"우선순위 ↓"| AW
    AW --> HP
    HP --> QR
    QR --> TOOLS
```

## 10. Work File Lifecycle

Work 파일은 `docs/works/{category}/`에서 생성·관리되고 완료 후 `docs/archive/docs/works/{category}/`로 이동한다.

```mermaid
stateDiagram-v2
    direction LR
    [*] --> Candidate : /work-register
    Candidate --> Active : /work-plan 착수 승인\n(Work 파일 생성)
    Active --> Done : /work-close\n(Done Criteria 충족)
    Done --> Archived : archive 승인\n(/session-start · /work-resume trigger)
```

| 상태 | 위치 | STATUS.md |
| --- | --- | --- |
| Candidate | `docs/backlog/**` | 없음 (ID 없음) |
| Active | `docs/works/{category}/` | Active Work pointer 있음 |
| Done | `docs/works/{category}/` | Active Work pointer 제거됨 |
| Archived | `docs/archive/docs/works/{category}/` | 없음 |
