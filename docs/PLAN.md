# PLAN.md - AI Workflow Harness

> 작성일: 2026-05-22 · 최종 갱신: 2026-06-08
> 문서 버전: v0.3 (Phase 2 종료 · AWH-004 Maintenance & Adoption 전환)
> 목적: AI-assisted development workflow를 안정적으로 운영하기 위한 manual-first harness를 정의한다.
> 기준: Git history 보존, 도구 중립성, 명시적 승인 gate, public-ready 문서화
> Lifecycle: 이 문서는 현재+다음 horizon만 유지한다. 갱신/배출 규칙은 §7 Roadmap Lifecycle 참조.

---

## 1. Project Goal

`ai-workflow-harness`는 AI agent와 함께 개발할 때 필요한 운영 구조를 제공한다.
이 프로젝트의 대상은 특정 application runtime이 아니라, 반복 가능한 AI-assisted
development workflow다.

핵심 목표:

- session 시작 시 읽어야 할 entry contract를 명확히 한다.
- `STATUS.md`, Work file, backlog, decision record의 역할을 분리한다.
- scope approval, state-change approval, commit approval을 명시적 gate로 관리한다.
- Claude Code, Codex, Cursor가 같은 운영 규칙을 따르도록 entrypoint와 rule surface를 정렬한다.
- 작업 실패, drift, validation failure가 발생했을 때 recovery flow를 제공한다.
- 다른 repository에 적용 가능한 generic scaffold를 제공한다.
- public repository로 공개해도 이해 가능한 문서 구조를 유지한다.

## 2. Project Identity

현재 project name은 `ai-workflow-harness`다.

여기서 harness는 AI workflow를 직접 실행하는 engine이 아니라, AI session을 감싸고
상태, 승인, 검증, 복구 흐름을 제어하는 운영 골격을 뜻한다.

이 repository는 `kyungseo/base-msa-template`에서 Git history와 branch/tag refs를
보존한 채 분리되었다. 과거 history에는 Spring Boot MSA template 구현과 문서가 남아
있으며, 이는 이 harness가 실제 product template 개발 과정에서 형성된 배경으로 보존한다.
현재 tree는 AI Workflow Harness 전용 project로 정리한다.

## 3. Core Surfaces

| Surface | Role |
| --- | --- |
| `AGENTS.md`, `CLAUDE.md` | Codex / Claude Code entrypoint |
| `docs/BEHAVIOR-PRINCIPLES.md` | 모든 AI 도구에 적용되는 전역 행동 원칙 |
| `docs/AGENT-WORKFLOW.md` | 공통 workflow, Approval Matrix, status rule |
| `docs/HARNESS-PROTOCOL.md` | 상세 protocol reference |
| `docs/HARNESS-QUICK-REFERENCE.md` | session 중 빠르게 확인하는 operational summary |
| `docs/STATUS.md` | 현재 project dashboard |
| `docs/PLAN-SUMMARY.md` | 세션 context용 architecture / project summary |
| `docs/works/**` | 작업 단위 SSoT |
| `docs/backlog/**` | 다음 작업 후보와 deferred work |
| `docs/decisions/**` | accepted decision 기록 |
| `.claude/commands/**` | Claude Code command definition |
| `.claude/rules/**`, `.cursor/rules/**` | tool-specific rule mirror |
| `prompts/**` | command를 직접 사용할 수 없는 도구를 위한 prompt template |
| `scripts/create-harness.sh` | 새 repository 또는 기존 repository에 harness 구조를 적용하는 scaffold |

## 4. Current Milestone

현재 milestone은 `AWH-004 — Maintenance & Adoption`이다.

Phase 2(Externalization refactor)는 DR-021~025 적용과 27개 Work 완료로 종료했고,
그 산출물을 `ai-workflow-v1.1.0`으로 릴리즈한다. 이후 초점은 harness를 실제로
채택하는 repository 지원과 반복 운영 부채 축소다.

Milestone 목표:

- `ai-workflow-v1.1.0` 릴리즈 — Phase 2 산출물을 공개 버전으로 확정(breaking은 릴리즈 노트 명시).
- 실 adopter(`ai-deck-compiler`) upgrade/migration 경로를 제공한다.
- onboarding/manual 정합을 현행화한다(README overhaul 이후 path 점검).
- 반복 운영에서 발생하는 운영 부채를 점진적으로 줄인다.
- public repository 상태를 clean baseline으로 유지한다.

## 5. Scope Policy

### Keep As Core

- AI tool entrypoint와 공통 workflow 문서
- behavior principles, protocol, quick reference, manual
- `PLAN.md`(장기 project plan, L3 decisions 근거), `PLAN-SUMMARY.md`(Context Routing용 아키텍처 요약)
- Work / backlog / decision / retrospective 체계
- generic prompt와 generic scaffold
- tool-specific rule mirror

### Review Before Keeping

- Optional Spring Boot example profile support
- Java/Spring-specific prompt bundle as optional example pack
- Java/Spring-specific Claude/Cursor rules as optional profile surface
- historical snapshots and presentation drafts
- product-template 시절의 troubleshooting record

### Kept As Core (Previously Under Review)

- `HARNESS-ARCHITECTURE.md` — harness 아키텍처 시각화 문서
- `HARNESS-MAINTAINER-GUIDE.md` (구 `DEVELOPER-GUIDE.md` + `CODING-CONVENTIONS.md` 통합) — 유지보수·convention 가이드

### Remove Or Legacy-Isolate

- Spring Boot application source
- Gradle multi-module build files
- service, gateway, common runtime module
- Docker, K8s, DB runtime infrastructure
- MSA-specific architecture and developer guide content
- Runtime-specific validation defaults that no longer apply to this project

## 6. Non-Goals

- AI workflow runtime engine을 구현하지 않는다.
- task scheduler나 DAG runner를 제공하지 않는다.
- 특정 programming language나 framework를 기본 전제로 삼지 않는다.
- 모든 team process를 자동화하지 않는다. Manual-first gate를 기본으로 둔다.
- 과거 Git history에서 Spring Boot MSA 흔적을 제거하지 않는다.

## 7. Roadmap

`AWH-*`는 roadmap **stage label**이고, `CHORE-YYYYMMDD-NNN` 등은 실행 단위 **Work ID**다. 둘은 층위가 다르며 같은 namespace가 아니다. Stage는 방향/horizon을, Work ID는 개별 작업을 가리킨다.

| Stage | Status | Focus | Output |
| --- | --- | --- | --- |
| AWH-001 | 완료 | Public-ready migration | 현재 tree 정리, public docs, release readiness |
| AWH-002 | 완료 | Workflow hardening | 문서 정합성, scaffold 검증, tool surface alignment, adoption readiness |
| AWH-003 (Phase 2) | 완료 | Externalization refactor | source/target boundary·canonical+adapter·gate taxonomy·PLAN lifecycle 적용. 방향: DR-021~025. 실행 Work: `CHORE-20260604-001`(planning)~`CHORE-20260608-003`. 산출물은 `ai-workflow-v1.1.0`으로 릴리즈 |
| AWH-004 | 진행 | Maintenance & Adoption | 1.1.0 릴리즈, 실 adopter upgrade/migration, onboarding/manual 현행화, 운영 부채 축소. 후보는 `docs/backlog/HARNESS.md` |

horizon이 닫히거나 재정의되면 아래 Lifecycle 규칙(§7-a)에 따라 처리한다.

### 7-a. Roadmap Lifecycle (DR-022)

PLAN은 **현재 + 다음 horizon만** 유지한다. STATUS Recent Decisions의 rolling-window와 동형의 배출 규칙이다.

- **나가는 문(drain):** 닫힌 phase의 상세는 `docs/archive/`로 배출하고, PLAN에는 archive link 한 줄만 남긴다. phase 완료/전환은 `docs/HARNESS-PROTOCOL.md` T3가 트리거한다.
- **들어오는 문(update):** Work closeout·phase transition·commit finalization 시 T5(PLAN 영향 판단)로 roadmap/milestone을 갱신한다. PLAN 작성 완료를 hard-stop으로 강제하지 않는다(recommended/warning).
- **옆문(rationale):** L3 결정 근거는 PLAN에 누적하지 않고 `docs/decisions/DR-*.md`로 분리한다.

이 규칙의 SSoT는 이 섹션이다. `HARNESS-PROTOCOL.md`는 trigger pointer만 둔다.

## 8. Validation Model

기본 검증은 변경 유형에 따라 선택한다.

| Change | Validation |
| --- | --- |
| 문서 변경 | `git diff --check`, 링크와 stale phrase 점검 |
| workflow / protocol 변경 | canonical -> tool-specific -> user-facing -> scaffold cascade 점검 |
| scaffold 변경 | `bash -n scripts/create-harness.sh`, generic dry-run, 필요 시 temp 실제 생성 |
| public release 준비 | secret/private-info scan, stale project identity audit |

## 9. Open Questions

| ID | Question | Status |
| --- | --- | --- |
| AWH-OQ-001 | historical product docs를 어느 범위까지 남길 것인가? | Deferred — archive policy가 실제로 필요해지는 시점에 신규 Work로 재등록. `docs/backlog/HARNESS.md` Deferred Ideas 참조 |
