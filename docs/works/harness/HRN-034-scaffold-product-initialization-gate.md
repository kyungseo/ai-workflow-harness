---
id: HRN-034
priority: P1
status: Active
risk: Medium
scope: Scaffold onboarding product definition and project initialization gate
appetite: 0.5d
planned_start: 2026-05-24
planned_end:
actual_end:
related_dr: []
related_commits: []
related_troubleshooting: []
---

# HRN-034: Scaffold Product Definition / Project Initialization Gate

## Context

HRN-033에서 scaffold 직후 git repository 미초기화 상태를 bootstrap flow 안에서 명확히 다뤘다.
이후 실제 scaffold 프로젝트에서 PoC/MVP 개발을 시작하면, Product 결정과 project initialization baseline이 비어 있는데도
example feature 또는 사용자 관리 구현 같은 기능 작업으로 바로 진행될 수 있음이 확인됐다.

현재 generated `docs/BOOTSTRAP.md`는 Product Track Setup을 제공하지만,
제품 결정, runtime/framework/build/package/module/DB 같은 project initialization 기준,
`docs/PLAN.md`와 `docs/PLAN-SUMMARY.md` 구체화, Phase 1 backlog 도출 순서를 강하게 고정하지 않는다.
그 결과 `P1-001` 후보가 product baseline 이전의 기능 구현으로 오해될 수 있다.

이 Work는 scaffold가 기능 구현을 서두르게 하는 흐름을 막고,
신규 프로젝트가 먼저 제품 목표와 기술 baseline을 확정한 뒤 backlog를 만들도록 onboarding contract를 보강한다.

## Risk And Mode

- 위험도: L2
- 실행 모드: Standard Work
- 이유: scaffold script, generated docs, source bootstrap guide, prompt/session surface, user-facing README/manual에 영향을 줄 수 있는 workflow surface 변경이다.

## Scope

### In Scope

- scaffold 직후 `Product Definition Gate`와 `Project Initialization Gate`를 도입할 위치와 문구 설계.
- generated `docs/BOOTSTRAP.md`의 순서를 재정렬하거나 보강한다.
- generated `docs/PLAN-SUMMARY.md`에 implementation baseline 또는 project initialization summary를 추가하는 방안 검토.
- generated `docs/PLAN.md`에 project initialization plan 섹션을 추가하는 방안 검토.
- generated `docs/backlog/PHASE1.md`에 product definition과 initialization baseline이 비어 있으면 기능 backlog를 만들지 말라는 guard를 추가하는 방안 검토.
- session prompts와 scaffold onboarding prompt가 example feature를 실제 backlog로 승격하지 않도록 정렬한다.
- PoC/MVP 개발에 필요한 framework-neutral initialization checklist를 먼저 정의하고, Spring Boot 항목은 stack-specific 예시로만 둘지 결정한다.
- generic과 spring-boot profile 모두에서 scaffold 결과를 시뮬레이션한다.

### Out Of Scope

- 실제 application code 생성.
- Spring Initializr 같은 stack-specific generator를 직접 호출하거나 dependency를 다운로드하는 자동화.
- 특정 DB, package name, build DSL, security strategy를 harness 기본값으로 강제.
- Spring Boot example pack 전체 재설계 또는 prompt bundle 대규모 rewrite.
- Windows native 지원. OS별 실행 호환성은 HRN-032에서 다룬다.

## Current Assumptions

- 신규 scaffold의 첫 세션은 feature implementation보다 onboarding과 planning을 먼저 수행해야 한다.
- `generic` profile도 product definition과 initialization gate가 필요하다.
- `spring-boot` profile은 Java/Spring rules와 prompt bundle을 포함하지만, Spring Boot project 자체를 생성하지 않는다.
- 개발이 필요한 PoC/MVP에서는 첫 Product track 작업이 "사용자 관리 구현" 같은 기능 구현이 아니라 "Project Initialization" 또는 그 계획 확정일 가능성이 높다.
- stack-specific 예시는 guide가 될 수 있지만, actual backlog item으로 자동 승격되어서는 안 된다.

## Problem Statement

현재 scaffold 후 agent가 다음 순서로 미끄러질 수 있다.

1. `/start`에서 `STATUS.md` Next Actions의 bootstrap pointer를 확인한다.
2. `BOOTSTRAP.md`를 읽고 Product track backlog 후보를 만들라고 이해한다.
3. example prompt 또는 이전 맥락의 "사용자 관리"를 `P1-001` 기능 구현으로 제안한다.
4. PLAN/PLAN-SUMMARY의 runtime, framework, build, base package, module, DB, verification baseline은 비어 있는 상태로 남는다.

원하는 순서는 다음과 같다.

1. Product Definition을 먼저 확정한다.
2. Project Initialization baseline을 정한다.
3. `PLAN.md`, `PLAN-SUMMARY.md`, `AGENT-WORKFLOW.md` Project Constants / Verification Defaults를 채운다.
4. 그 기준에서 Phase 1 backlog를 도출한다.
5. example feature는 실제 제품 목표와 baseline에 부합할 때만 후보가 된다.

## Project Initialization Checklist

PoC/MVP 등 코드 개발이 필요한 프로젝트에서는 stack과 무관하게 아래 항목을 먼저 결정해야 한다.
이 목록은 framework-neutral checklist 후보이며, 특정 runtime이나 framework를 harness 기본값으로 강제하지 않는다.

- 생성 방식: 수동 생성, 공식 generator, template, 기존 repository overlay 중 선택.
- Runtime/language version과 framework/library version 결정.
- Package/module namespace 또는 root module naming 결정.
- Build tool과 wrapper/lockfile/package manager 정책 결정.
- Dependency baseline과 dependency 추가 기준 결정.
- 실행 entrypoint와 local run command 결정.
- 환경/profile 전략: local, test, prod 또는 이에 준하는 환경 분리.
- configuration 파일 위치와 secret/env var 관리 방식 결정.
- 기본 directory/package 구조 결정: layer-based, feature-based, module-based 등.
- Data storage 필요 여부와 DB/cache/message broker 선택.
- Migration 또는 schema 관리 방식 필요 여부 결정.
- Health/readiness endpoint 또는 smoke check 방식 결정.
- API/interface contract 형식 결정: REST, GraphQL, CLI, library API, batch job 등.
- Error handling, validation, logging 기준 결정.
- Test baseline: unit, integration, e2e, fixture/test data 전략.
- CI baseline: test/build/lint/format/typecheck 중 초기 필수 명령 결정.
- Documentation baseline: README run instructions, architecture notes, decision records.
- `docs/AGENT-WORKFLOW.md` Project Constants의 Runtime, Framework, Build, Architecture, Base package/module 확정.

## Spring Boot Example Checklist

Spring Boot 개발 검증 프로젝트에서는 framework-neutral checklist에 더해 아래 항목을 예시로 검토한다.
이 목록은 Spring Boot profile의 stack-specific 예시이며, HRN-034 정책 자체를 Spring Boot로 한정하지 않는다.

- Spring Initializr 또는 수동 생성 방식 결정.
- Java version, Spring Boot version, group, artifact, base package 결정.
- Gradle Kotlin DSL(`build.gradle.kts`) vs Groovy DSL(`build.gradle`) 결정.
- Gradle Wrapper 포함 여부와 version 관리 방식 결정.
- Dependencies 결정: Spring Web, Spring Data JPA, Validation, Actuator, DB driver, test dependencies.
- DB 선택: H2, PostgreSQL, MySQL 등과 local/test/prod profile 분리.
- `application.yml` 기본 설정: datasource, JPA `ddl-auto`, logging, profile activation.
- Health endpoint 방식: `/actuator/health` 또는 custom endpoint.
- Spring package 구조: `config`, `domain`, `application`, `api`, `infra` 등.
- Spring module shape: single module, multi-module, package-by-feature, package-by-layer 중 선택.
- Migration 도구 사용 여부: Flyway 또는 Liquibase.
- API error response와 validation error format 기준.
- Security/auth baseline: MVP에서 제외, placeholder만 둠, 또는 Spring Security 기본 구조 포함 여부.
- Test baseline: unit, WebMvc slice, integration, Testcontainers 사용 여부.
- CI baseline: `./gradlew test`, `bootJar`, lint/format/checkstyle 여부.
- OpenAPI/Swagger 사용 여부.
- Docker Compose/local infra 필요 여부.
- secret/env var 관리 방식.

## Plan

### Step 1 - Surface Audit

- `scripts/create-harness.sh` generated `BOOTSTRAP.md`, `PLAN-SUMMARY.md`, `PLAN.md`, `PHASE1.md`, completion output을 확인한다.
- `docs/SCAFFOLD-BOOTSTRAP.md`의 Boot Sequence와 Required Setup Items를 확인한다.
- `README.md`의 New Project Adoption 흐름과 generated scaffold 설명을 확인한다.
- `prompts/claude-session-start.md`, `prompts/codex-session-start.md`, `prompts/cursor-session-start.md`에서 신규 프로젝트 또는 P1 후보 생성 문구를 확인한다.
- `prompts/01-scaffold-project.prompt.md`, `prompts/02-scaffold-service.prompt.md`, `prompts/03-add-single-feature.prompt.md`, `prompts/19-design-feature.prompt.md`가 bootstrap 초기 상태에서 기능 구현을 자극하는지 확인한다.
- `.cursor/rules/workflow.mdc`와 tool-specific startup surface가 Product backlog empty 상태를 어떻게 안내하는지 확인한다.

### Step 2 - Policy Decision

다음 정책을 채택할지 리뷰한다.

```text
Scaffold 직후에는 example feature 또는 기능 구현을 바로 시작하지 않는다.
Product Definition과 Project Initialization baseline을 먼저 확정하고,
PLAN/PLAN-SUMMARY/AGENT-WORKFLOW를 채운 뒤 Phase 1 backlog를 도출한다.
baseline이 비어 있으면 기능 backlog 후보는 Proposed가 아니라 Blocked / Not Ready로 보고한다.
```

DR-worthy 여부:

- 신규 architecture나 tool 선택을 강제하는 결정은 아니다.
- scaffold onboarding contract를 강화하는 정책이므로 Work Discovery와 문서 변경으로 충분할 가능성이 높다.
- 다만 "기능 backlog 생성 전 initialization gate 필수"를 장기 정책으로 고정한다면 DR 후보로 볼 수 있다.

### Step 3 - Bootstrap Flow Design

generated `docs/BOOTSTRAP.md`의 순서를 아래처럼 바꾸는 방안을 우선 검토한다.

1. Repository Setup
2. Product Definition
3. Project Initialization
4. Core Document Fill Order
5. Phase 1 Backlog Derivation
6. Harness Track Setup
7. Example Pack Review
8. First Session Prompt
9. Completion Rule

핵심 guard:

- product goal, primary user, production type, success criteria가 비어 있으면 Product backlog 후보를 만들지 않는다.
- runtime/framework/build/base package/module/DB/test baseline이 비어 있으면 implementation feature를 제안하지 않는다.
- example pack의 user-management 또는 service scaffold 예시는 실제 제품 결정 전에는 reference로만 둔다.

### Step 4 - Generated Plan Surface

- `docs/PLAN-SUMMARY.md`에 `Implementation Baseline` 표를 추가한다.
  - Runtime
  - Framework
  - Build
  - Base package/module
  - Module shape
  - Data storage
  - Profiles/environments
  - Verification defaults
- `docs/PLAN.md`에 `Project Initialization Plan` 섹션을 추가한다.
  - stack choices
  - initial structure
  - dependency rationale
  - phase 1 readiness checklist
- `docs/AGENT-WORKFLOW.md` Project Constants가 scaffold 프로젝트에서 반드시 채워져야 하는 onboarding target임을 명확히 한다.

### Step 5 - Backlog Guard

generated `docs/backlog/PHASE1.md`에 아래 guard를 추가하는 방안을 검토한다.

- Product Definition과 Project Initialization baseline이 비어 있으면 feature backlog 작성 보류.
- 첫 candidate는 필요 시 `P1-001 Project Initialization` 또는 `P1-001 MVP Baseline Setup` 같은 준비 작업이 될 수 있음.
- example feature는 product goal과 baseline이 확정된 뒤에만 후보로 승격.

### Step 6 - Prompt / Tool Surface Alignment

- First Session Prompt에 "기능 구현 후보를 바로 만들지 말고, product definition과 initialization baseline을 먼저 제안" 문구를 추가한다.
- Claude/Codex/Cursor session prompts의 P1-001 후보 생성 문구를 baseline gate와 정렬한다.
- `prompts/02-scaffold-service.prompt.md`의 MSA/gateway/auth-service/user-service/todo-service 전제가 spring-boot example pack 안에서 reference로만 쓰이는지 확인한다.
- 필요 시 framework-neutral project initialization prompt를 추가하거나 기존 scaffold prompt description을 보강한다. Spring Boot prompt는 stack-specific 예시로만 정렬한다.

### Step 7 - Scenario Verification

- generic scaffold 생성 후 generated `BOOTSTRAP.md`가 Product Definition → Project Initialization → Plan fill → Backlog 순서를 안내하는지 확인한다.
- generic scaffold에서 `PHASE1.md` guard가 example feature 착수를 막는지 확인한다.
- spring-boot scaffold 생성 후 Java/Spring rules/prompt bundle과 initialization gate가 충돌하지 않는지 확인한다.
- PoC/MVP 개발 시나리오를 문서 기준으로 시뮬레이션한다. Spring Boot는 대표 예시로 포함한다.
  - 사용자가 "사용자 관리 구현"을 요청해도, baseline이 비어 있으면 initialization plan을 먼저 제안하는지 확인.
  - 사용자가 `git init`을 유보한 상태면 HRN-033의 no-git guard와 함께 동작하는지 확인.
- `bash -n scripts/create-harness.sh`, `git diff --check`, stale phrase search를 실행한다.

## Proposed Change Surface

| Surface | Change Need | Notes |
| --- | --- | --- |
| `scripts/create-harness.sh` | Likely | generated `BOOTSTRAP.md`, `PLAN-SUMMARY.md`, `PLAN.md`, `PHASE1.md` 보강 |
| `docs/SCAFFOLD-BOOTSTRAP.md` | Likely | source 기준 boot sequence에 Product Definition / Project Initialization gate 추가 |
| `README.md` | Possible | New Project Adoption 설명에서 bootstrap 순서 보강 |
| `docs/WORKFLOW-MANUAL.md` | Possible | user-facing scaffold flow가 바뀌면 정렬 |
| `prompts/claude-session-start.md` | Likely | New Project Initialization 또는 P1 후보 생성 문구 보강 |
| `prompts/codex-session-start.md` | Likely | Product backlog empty guidance에 baseline gate 추가 |
| `prompts/cursor-session-start.md` | Likely | Claude/Codex와 동일하게 정렬 |
| `.cursor/rules/workflow.mdc` | Possible | Product backlog empty rule에 baseline gate 추가 |
| `prompts/01/02/03/19` | Possible | 기능 구현 prompt가 bootstrap 초기 상태에서 오용되지 않도록 description/guard 보강 |
| `docs/STATUS.md` | State-change only | Active Work pointer 추가/제거는 별도 승인 |

## Done Criteria

- [ ] scaffold bootstrap flow가 Product Definition → Project Initialization → PLAN/PLAN-SUMMARY 구체화 → Phase 1 backlog 순서를 명확히 설명한다.
- [ ] generated `PLAN-SUMMARY.md`와 `PLAN.md`가 project initialization baseline을 채울 구조를 제공한다.
- [ ] generated `PHASE1.md`가 baseline 이전의 기능 backlog 생성을 막는 guard를 가진다.
- [ ] PoC/MVP project initialization checklist가 framework-neutral 기준으로 포함되고, Spring Boot는 stack-specific 예시로만 위치가 명확해진다.
- [ ] example feature 또는 사용자 관리 구현이 baseline 이전에 바로 착수되지 않도록 prompt/tool surface가 정렬된다.
- [ ] generic과 spring-boot scaffold 생성 결과가 일관된다.
- [ ] HRN-033 no-git bootstrap guard와 충돌하지 않는다.
- [ ] 사용자 리뷰 후 `/close` 전 최종 검증 결과가 Work 파일에 반영된다.

## Verification

```bash
git diff --check
bash -n scripts/create-harness.sh
./scripts/create-harness.sh --dry-run --profile generic hrn-034-generic /private/tmp/hrn-034-generic-dry
./scripts/create-harness.sh --profile generic hrn-034-generic /private/tmp/hrn-034-generic
./scripts/create-harness.sh --profile spring-boot hrn-034-spring /private/tmp/hrn-034-spring
rg -n "Product Definition|Project Initialization|Implementation Baseline|Spring Initializr|사용자 관리|user management|P1-001" \
  /private/tmp/hrn-034-generic /private/tmp/hrn-034-spring README.md docs scripts prompts .cursor .claude .agents \
  -g '!docs/archive/**'
```

Temp directory setup/cleanup is allowed only for HRN-034-owned paths.
If a target already exists, use a fresh `/private/tmp/hrn-034-*` path.

## Risks

| Risk | Impact | Mitigation |
| --- | --- | --- |
| Bootstrap이 너무 길어짐 | 신규 사용자가 첫 세션에서 피로를 느낌 | 필수 gate와 optional checklist를 분리하고, generated docs는 표 중심으로 유지 |
| Generic profile에 특정 framework 냄새가 섞임 | framework-neutral scaffold 원칙 약화 | 공통 checklist는 framework-neutral하게 유지하고 Spring Boot checklist는 optional example 또는 profile-specific wording으로 격리 |
| Feature delivery가 과도하게 늦어짐 | MVP 개발 속도 저하 | baseline이 충분히 채워지면 바로 P1 기능 후보로 이동할 수 있게 Completion Rule 정리 |
| Prompt surface가 중복됨 | drift risk 증가 | canonical bootstrap guide를 기준으로 tool/session prompt는 짧은 guard만 추가 |
| Existing project overlay에 과한 초기화 요구 | 이미 있는 구조와 충돌 | existing mode에서는 codebase inspection 후 빈 항목만 보강하도록 문구 분리 |

Reversal cost: Medium.
Generated template과 prompt wording을 되돌리면 되지만, adopter onboarding 흐름에 영향을 주는 정책이라 cascade 확인이 필요하다.

## Codex Rule Reference

- `.claude/rules/docs-workflow.md` applies because this Work changes docs, prompts, command/rule-adjacent workflow guidance, and scaffold documentation.
- `.claude/rules/git-workflow.md` applies for final commit/PR handling only.
- Java/Spring-specific rules are reference-only unless implementation changes Spring Boot example rule files or prompts.

## STATUS Update Proposal

Do not update `docs/STATUS.md` without explicit approval.

Proposed one-line state update if this Work is accepted for active execution:

> Add Active Work pointer for HRN-034 (`docs/works/harness/HRN-034-scaffold-product-initialization-gate.md`) to `docs/STATUS.md`.

## Checkpoints

| CP | Description | Status |
| --- | --- | --- |
| CP-1 | HRN-034 backlog 등록 및 Work plan 작성 | Done |
| CP-2 | 사용자 리뷰 및 scope 승인 | Done |
| CP-3 | Product Definition / Project Initialization gate 정책 확정 | Done |
| CP-4 | scaffold/generated docs/source docs 반영 | Done |
| CP-5 | prompt/tool surface alignment | Done |
| CP-6 | generic/spring-boot scenario verification | Done |

## Discovery

- HRN-033은 git repository 미초기화 상태를 bootstrap gate로 다뤘다. HRN-034는 그 다음 gate인 product/project initialization readiness를 다룬다.
- 현재 generated `BOOTSTRAP.md`는 Product Track Setup을 포함하지만, feature backlog 작성 전 `PLAN.md`/`PLAN-SUMMARY.md` baseline을 먼저 채우라는 guard가 약하다.
- 현재 generated `PHASE1.md`는 후보 형식만 제공하며, Product Definition 또는 Project Initialization baseline이 비어 있을 때 기능 후보 생성을 보류하라는 명시적 guard가 없다.
- `prompts/02-scaffold-service.prompt.md`는 Spring Boot MSA 예시 전제를 강하게 담고 있으므로 greenfield PoC/MVP에서는 직접 사용 전 baseline 확인 guard가 필요하다.
- 2026-05-24 Codex pre-public review는 신규 채택자 초기 부팅 비용을 Medium risk로 남겼다. HRN-034는 이 adopter readiness gap의 구체적 보완이다.
- 추가 리뷰에서 generated `BOOTSTRAP.md`의 First Session Prompt가 §8로 이동했지만 generated README, root README, `docs/WORKFLOW-MANUAL.md`가 §6 prompt와 즉시 P1 후보 도출 흐름을 유지하는 drift를 확인했다.
- prompt 현행화 보완으로 `prompts/README.md`에 scaffold 직후 Implementation Baseline이 비어 있으면 task prompt보다 `docs/BOOTSTRAP.md` §8 Project Initialization을 먼저 진행하라는 안내를 추가했다.
- README 보완으로 root README `10. New Project Adoption`, generated README, `docs/WORKFLOW-MANUAL.md` Appendix B를 §8 prompt와 Product Definition / Implementation Baseline / Project Initialization flow 기준으로 정렬했다.
- generic/spring-boot fresh scaffold r2에서 generated README, `BOOTSTRAP.md`, `PLAN-SUMMARY.md`, `PLAN.md`, `PHASE1.md`, prompt README, Spring Boot service prompt가 baseline gate를 일관되게 포함하는 것을 확인했다.

### Surface Audit 결과 (Step 1 완료)

#### generated `docs/PLAN-SUMMARY.md` (script L508–535)

- "Project Summary" 표: 프로젝트 목표, 주요 사용자, production 성격, 배포 방식, 제품 핵심 workflow, AI 도구, 주요 제약 조건.
- "Core Architecture": `*(채워야 함)*` 한 줄.
- "Verification Defaults": `*(채워야 함)*`.
- **Gap**: Runtime, Framework, Build, Base package/module, Data storage, Profiles/environments 를 담는 `Implementation Baseline` 표가 없다. "Core Architecture" 자유 텍스트 안에 묻히면 agent가 이 항목을 baseline gate로 쓸 수 없다.
- **결론**: `Implementation Baseline` 표를 `Project Summary` 바로 아래에 별도 섹션으로 추가한다. 각 항목에 `Readiness` 열(Not Started / Partial / Ready / Not Applicable)을 추가해 agent가 baseline 충족 여부를 판단할 수 있게 한다. code development가 불필요한 프로젝트(content/research/no-code 운영 등)는 전체 표를 Not Applicable로 처리할 수 있다.

#### generated `docs/PLAN.md` (script L537–559)

- "기술 스택 선택 근거": `*(채워야 함)*`.
- "Phase 계획 / Phase 1": 목표·범위 두 줄.
- **Gap**: stack choices, initial structure, dependency rationale, phase 1 readiness checklist를 담는 `Project Initialization Plan` 섹션이 없다. "기술 스택 선택 근거"는 결정 이후의 근거 기록 공간이고, 결정 전 체크리스트가 아니다.
- **결론**: `Project Initialization Plan` 섹션 추가. 단, PLAN.md는 "필요한 경우에만 로드"하는 문서이므로 gate 역할은 PLAN-SUMMARY.md 표가 담당하고, PLAN.md는 세부 근거를 담는 위치로 유지한다.

#### generated `docs/backlog/PHASE1.md` (script L561–586)

- "Active Candidates" 설명: "제품 목표에서 도출한 후보 작업을 우선 등록한다."
- P1-001 형식 예시는 주석(comment)으로 제공되어 채울 내용이 없다.
- **Gap**: Product Definition(목표·사용자·성격·성공 기준) 또는 Project Initialization baseline이 비어 있을 때 feature candidate 등록을 보류하라는 명시적 guard가 없다.
- **결론**: Active Candidates 섹션 상단에 guard 문구 한 단락 추가. "제품 목표·사용자·성공 기준과 PLAN-SUMMARY.md Implementation Baseline이 확정된 뒤에만 기능 후보를 등록한다. 비어 있으면 feature candidate은 Not Ready로 보고하고, 첫 후보로 Project Initialization을 제안한다. code development가 필요한 경우 `P1-001 Project Initialization`; code development가 없는 프로젝트(content/research/no-code 운영 등)는 해당 project type의 baseline/setup 작업으로 대체한다."

#### generated `docs/BOOTSTRAP.md` §2 Product Track Setup (script L445–452)

- 현재 체크리스트: "Phase 1 목표 한 문장", "P1-001~ 후보 등록", "즉시 착수할 항목 제안", "Work 파일 생성 여부 판단" 등.
- **Gap**: PLAN-SUMMARY.md baseline을 먼저 채우라는 순서 constraint가 없다. "P1-001~ 후보 등록" 전에 `PLAN-SUMMARY.md Implementation Baseline 완성` 체크 항목이 없다.
- 재정렬 후 순서 제안 (Step 3의 방안과 정렬):
  - §1: Product Definition (목표·사용자·성격·성공 기준)
  - §2: Project Initialization (PLAN-SUMMARY.md Implementation Baseline 완성)
  - §3: Phase 1 Backlog Derivation (baseline 완성 후 P1-001~ 등록)
  - 기존 §2 Product Track Setup은 §3으로 재편, "P1-001~ 등록" 항목을 §3으로 이동.
- **주의**: §0 Repository Setup(HRN-033)과 순서 연계가 필요하다. §0 → §1 → §2 → §3 흐름이 자연스럽다. 코드 개발이 없는 content/research 타입 프로젝트는 §2 Project Initialization을 "Not Applicable" 처리할 수 있어야 한다.

#### `docs/SCAFFOLD-BOOTSTRAP.md` Boot Sequence (source, step 1–8)

- step 1: git 상태 확인 (HRN-033 추가)
- step 2: Project identity 정한다 (이름, 한 줄 설명, 주요 사용자, production 성격, 공개/배포 방식)
- step 3: Product track 먼저 만든다 (PHASE1.md 후보 도출)
- step 4: Harness track 분리
- **Gap**: step 2(identity)와 step 3(Product backlog) 사이에 "Project Initialization baseline 확정" 단계가 없다. 현재 흐름은 identity → backlog로 바로 이어진다.
- **결론**: step 3을 "Project Initialization baseline을 확정한다 (코드 개발이 필요한 프로젝트에만 적용)"로 삽입하고 기존 step 3~8을 4~9로 밀어낸다.

#### `prompts/claude-session-start.md` §2 Work Selection

- "Product backlog가 아직 비어 있으면 제품 목표, 사용자, Phase 1 범위를 기준으로 P1-001~ 후보를 먼저 제안해줘."
- **Gap**: PLAN-SUMMARY.md Implementation Baseline 확인 단계가 없다. 빈 backlog에서 바로 P1-001 feature candidate을 제안하는 흐름이다.
- **결론**: "P1-001~ 후보를 먼저 제안해줘" 앞에 "단, PLAN-SUMMARY.md의 Implementation Baseline이 비어 있으면 feature 후보 대신 Project Initialization 항목을 첫 candidate로 제안해줘" 한 줄 삽입.

#### `prompts/codex-session-start.md`

- "scaffold bootstrap/onboarding을 명시하면 제품 목표와 Phase 범위를 먼저 정리하고, 그 결과를 PHASE1.md의 Product track 후보로 등록한다."
- **Gap**: claude-session-start.md와 동일. baseline gate 없이 P1 candidate 등록 유도.
- **결론**: claude-session-start.md와 동일한 guard 한 줄 추가. mirror 수정 필요.

#### `.cursor/rules/workflow.mdc` L34

- "use docs/BOOTSTRAP.md to identify project identity and production type before proposing P1-001~ candidates."
- **Gap**: identity와 production type 확인 후 P1-001 제안 — Implementation Baseline 확인 없음.
- **결론**: "and verify PLAN-SUMMARY.md Implementation Baseline is filled before proposing feature candidates; if empty, propose Project Initialization as P1-001" 추가.

#### `prompts/02-scaffold-service.prompt.md`

- `portability: spring-boot-example`로 이미 격리됨.
- **Gap**: description에 "Project Initialization baseline 완료 후 사용" 안내가 없다. spring-boot profile에서 bootstrap 초기 상태에서 불려오면 baseline 미확정 상태에서 서비스 scaffold가 시작될 수 있다.
- **결론**: description 또는 prompt 서두에 "Project Initialization baseline이 완료된 뒤 사용할 것" 한 줄 추가. "spring-boot project가 초기화된 뒤"처럼 stack-specific 표현을 쓰면 일반 정책과 어긋나고, Spring Boot 예시가 다시 중심으로 올라오는 역효과가 생긴다.

#### `prompts/01-scaffold-project.prompt.md`, `prompts/03-add-single-feature.prompt.md`, `prompts/19-design-feature.prompt.md`

- 03, 19는 기존 코드에 추가/설계 작업이므로 bootstrap 초기 상태에서 직접 사용될 가능성이 낮다.
- 01은 뼈대 생성 prompt이나 사용자가 명시적으로 호출하는 task prompt이다.
- **결론**: 세 파일 모두 별도 guard 추가 불필요. 02-scaffold-service만 대상으로 충분하다.

---

### 변경 경로 우선순위

| 순위 | Surface | 이유 |
|---|---|---|
| 1 | `scripts/create-harness.sh` — generated `PLAN-SUMMARY.md`에 `Implementation Baseline` 표 추가 | agent가 baseline gate로 쓸 수 있는 구조적 anchor. 모든 guard의 참조 기준이 됨 |
| 2 | `scripts/create-harness.sh` — generated `PHASE1.md` Active Candidates 상단에 baseline guard 문구 추가 | feature candidate 오등록을 막는 가장 직접적인 위치 |
| 3 | `scripts/create-harness.sh` — generated `BOOTSTRAP.md` §2 앞에 `Product Definition` + `Project Initialization` 순서 재정렬 | onboarding flow 순서 자체를 바로잡는 구조 변경 |
| 4 | `docs/SCAFFOLD-BOOTSTRAP.md` Boot Sequence — step 3으로 Project Initialization 삽입 | source 기준 문서 정렬 |
| 5 | `prompts/claude-session-start.md` §2, `prompts/codex-session-start.md` — baseline gate 한 줄 추가 | session prompt가 빈 backlog에서 feature candidate을 바로 제안하는 흐름 차단 |
| 6 | `.cursor/rules/workflow.mdc` L34 — baseline gate 보강 | Claude/Codex mirror와 정렬 |
| 7 | `scripts/create-harness.sh` — generated `PLAN.md`에 `Project Initialization Plan` 섹션 추가 | 세부 근거 공간 확보. 필요 시만 로드하는 문서이므로 gate 역할은 PLAN-SUMMARY.md가 담당 |
| 8 | `prompts/02-scaffold-service.prompt.md` — description에 baseline 완료 후 사용 안내 추가 | spring-boot bootstrap 오용 방지. optional이고 낮은 위험 |

---

### Scenario Verification 결과 (Step 7 — 2026-05-24)

generic과 spring-boot 두 profile에서 scaffold 실행 후 다음 사항 확인:

- generated `PLAN-SUMMARY.md`: Implementation Baseline 표 (8개 항목, Readiness 열) 포함 — **OK**
- generated `PHASE1.md`: Active Candidates 상단 Baseline Gate guard 포함 — **OK**
- generated `BOOTSTRAP.md`: §2 Product Definition → §3 Project Initialization → §4 Phase 1 Backlog Derivation 순서 — **OK**
- generated `PLAN.md`: Project Initialization Plan 섹션 포함, Phase 1 Readiness Checklist 포함 — **OK**
- generated `STATUS.md`: Next Actions에 baseline 완료 후 P1-001~ 등록 순서 명시 — **OK**
- spring-boot `prompts/02-scaffold-service.prompt.md`: 사전 조건("Project Initialization baseline이 완료된 뒤") 포함 — **OK**
- HRN-033 no-git note: 두 profile 모두 git 미초기화 시 note 출력, git 있는 경우 미출력 — **OK** (충돌 없음)
- `git diff --check`: whitespace 오류 없음 — **OK**
- script dry-run: 오류 없이 전체 파일 목록 출력 — **OK**

### Policy 결정 사항 (Step 2 완료 — 2026-05-24 사용자 승인)

- **DR 불필요**: onboarding contract 강화이며 기존 scaffold 정책의 명확화 수준이다. Work Discovery와 문서 변경으로 충분하다.
- **code development required 기준 분기**: Implementation Baseline 적용 여부는 production 성격(internal tool 여부 등)이 아니라 **code development required: yes/no**로 판단한다. content/research 프로젝트도 코드가 있으면 baseline 필요. internal tool도 no-code 문서/운영 프로젝트면 Not Applicable 가능. PLAN-SUMMARY.md 표 Readiness 열에서 "Not Applicable" 선택으로 처리한다.
- **기능 착수 기준 — Not Ready**: baseline이 비어 있으면 feature candidate은 **Not Ready**로 보고하고, 첫 후보로 Project Initialization을 제안한다. "Blocked"는 agent가 과하게 멈출 수 있으므로 사용하지 않는다. 부분적으로 채워져 있으면 채워진 범위 내에서 초기 P1 후보를 제안할 수 있다.
- **existing overlay**: 이미 코드가 있는 프로젝트에 overlay하는 경우, codebase를 먼저 확인하고 비어 있는 항목만 보강한다. Gitflow처럼 기존 구조를 무조건 강제하지 않는다.
