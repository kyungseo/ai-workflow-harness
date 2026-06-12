# PLAN-SUMMARY.md - AI Workflow Harness

> 전체 방향은 `docs/PLAN.md` 참조. 이 파일은 세션 context용 요약이다.
> `PLAN-SUMMARY.md`는 독립 이력/결정 저장소가 아니라 `PLAN.md`, `STATUS.md`, 핵심 workflow surface에서 파생된 derived summary다.
> 변경 이력은 누적하지 않고, T5 PLAN 영향 판단 또는 closeout/finalization 시 stale 여부만 확인한다.

## Lifecycle Rules

- **역할:** `PLAN.md` / `STATUS.md` / 핵심 surface에서 파생된 세션 context 요약(derived cache). 독립 이력·결정 저장소가 아니다.
- **갱신 조건:** `PLAN.md` 또는 `STATUS.md`에 실질적 변경이 있을 때 stale 여부를 판정하고 필요한 경우만 갱신한다. T5(PLAN 영향 판단) step 또는 closeout/finalization에서 판정한다.
- **금지:** 자체 변경 이력 누적 금지. L3 결정 근거 기록 금지(→ `docs/decisions/DR-*.md`). 이 파일에서 독립적 의사결정 추적 금지.
- **갱신 책임:** T5 배선 지점(`/work-plan`, `/record-decision`, `/work-close`, commit/PR finalization, phase transition)에서 PLAN 변경이 있으면 이 파일의 stale 여부도 함께 판정한다.

## Project Summary

`ai-workflow-harness`는 AI-assisted development workflow를 운영하기 위한
manual-first harness다. 특정 application runtime보다 session entry, state tracking,
approval gate, validation, recovery, tool-surface alignment를 다룬다.

## Core Architecture

```text
Entry Points
  AGENTS.md / CLAUDE.md
        |
        v
Behavior + Workflow
  docs/BEHAVIOR-PRINCIPLES.md
  docs/AGENT-WORKFLOW.md
  docs/HARNESS-PROTOCOL.md
  docs/HARNESS-QUICK-REFERENCE.md
        |
        v
State + Tracking
  docs/STATUS.md
  docs/works/**
  docs/backlog/**
  docs/decisions/**
        |
        v
Tool Surfaces
  .claude/commands/**
  .claude/rules/**
  .cursor/rules/**
  .agents/skills/**
  .codex/hooks.json
  prompts/**
        |
        v
Scaffold + Adoption
  scripts/create-harness.sh
  docs/WORKFLOW-MANUAL.md
  README.md
```

## Key Operating Decisions

- Repository name은 `ai-workflow-harness`로 유지한다.
- `base-msa-template`의 전체 Git history는 의도적으로 보존한다.
- AWH-001 migration 이후 current tree는 AI Workflow Harness 중심으로 정리된 상태다.
- `docs/PLAN.md`와 `docs/STATUS.md`는 migration 이후에도 live 문서로 유지하고, migration 세부 기록은 Work 파일에 둔다.
- `docs/PLAN-SUMMARY.md`는 core Context Routing surface이므로 제거하지 않고 현재 상태에 맞게 유지한다. 단, 자체 이력이나 L3 결정 근거를 담지 않고 PLAN/STATUS에서 파생된 압축 context로만 관리한다.
- AWH-002(Workflow hardening) 완료 이후 current phase는 Public baseline / Maintenance로 전환됐다. 이후 작업은 public repository 유지·채택 지원·운영 부채 경감에 집중한다.

## Core Files

| 용도 | 파일 |
|------|------|
| Codex 진입점 | `AGENTS.md` |
| Claude Code 진입점 | `CLAUDE.md` |
| 전역 행동 원칙 | `docs/BEHAVIOR-PRINCIPLES.md` |
| 공통 workflow 규칙 | `docs/AGENT-WORKFLOW.md` |
| 상세 protocol | `docs/HARNESS-PROTOCOL.md` |
| 빠른 운영 요약 | `docs/HARNESS-QUICK-REFERENCE.md` |
| Git 전략 / CI | `docs/GIT-WORKFLOW.md` |
| Scaffold 부팅 guide | `docs/BOOTSTRAP.md`, `docs/SCAFFOLD-BOOTSTRAP.md` |
| 현재 dashboard | `docs/STATUS.md` |
| 프로젝트 plan | `docs/PLAN.md` |
| Work item SSoT | `docs/works/**` |
| Harness backlog | `docs/backlog/HARNESS.md` |
| 공개 manual | `docs/WORKFLOW-MANUAL.md` |
| Scaffold script | `scripts/create-harness.sh` |
| Pre-commit enforcement | `tools/git-hooks/**` |
| Conditional runbooks | `docs/HARNESS-NAMING-RULES.md`, `docs/HARNESS-RECOVERY-VALIDATION.md`, `docs/HARNESS-PARALLEL-WORK-CONTROLS.md` |

## Current Surface Policy

| Class | Examples |
|------|------|
| Core로 유지 | entrypoint, behavior/workflow/protocol docs, STATUS/PLAN/PLAN-SUMMARY, Work/backlog/DR structure, tool command/rule mirror, session-start fallback prompt, scaffold |
| Core로 전환 완료 | HARNESS-ARCHITECTURE, HARNESS-MAINTAINER-GUIDE (구 DEVELOPER-GUIDE + CODING-CONVENTIONS 통합) |
| Optional/example로 유지 | extended generic task prompt library, optional Spring Boot example profile |
| 유지 여부 검토 | troubleshooting, presentations, archive |
| 제거 또는 legacy 격리 완료 | Spring Boot runtime code, Gradle build, common/gateway/services/frontend/tests, Docker/K8s/DB infra, generated build output |

## Validation Defaults

| 변경 | 검증 |
|------|------|
| 문서 전용 변경 | `git diff --check`, 대상 stale-term search |
| Workflow/protocol/tool surface 변경 | canonical -> tool-specific -> user-facing -> scaffold cascade check |
| Scaffold script 변경 | `bash -n scripts/create-harness.sh`, generic dry-run, 필요 시 temp actual generation |
| Public release 준비 | secret/private-info scan, stale identity audit, GitHub visibility check |

## Key References

| 필요 상황 | 파일 |
|------|------|
| 현재 상태 확인 | `docs/STATUS.md` |
| 장기 project plan | `docs/PLAN.md` |
| Workflow 규칙 | `docs/AGENT-WORKFLOW.md` |
| 상세 protocol | `docs/HARNESS-PROTOCOL.md` |
| 사용자용 workflow guide | `docs/WORKFLOW-MANUAL.md` |
