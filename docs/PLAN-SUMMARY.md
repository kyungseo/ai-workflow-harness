# PLAN-SUMMARY.md - AI Workflow Harness

> 전체 방향은 `docs/PLAN.md` 참조. 이 파일은 세션 context용 요약이다.

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
  prompts/**
        |
        v
Scaffold + Adoption
  scripts/create-harness.sh
  docs/WORKFLOW-MANUAL.md
  docs/WORKFLOW-MANUAL-SUMMARY-PUBLIC.md
```

## Key Operating Decisions

- Repository name은 `ai-workflow-harness`로 유지한다.
- `base-msa-template`의 전체 Git history는 의도적으로 보존한다.
- AWH-001 migration 이후 current tree는 AI Workflow Harness 중심으로 정리된 상태다.
- `docs/PLAN.md`와 `docs/STATUS.md`는 migration 이후에도 live 문서로 유지하고, migration 세부 기록은 Work 파일에 둔다.
- `docs/PLAN-SUMMARY.md`는 core Context Routing surface이므로 제거하지 않고 현재 상태에 맞게 유지한다.
- Post-migration 작업은 Workflow hardening phase에 귀속하며, documentation alignment, scaffold consistency, tool-surface mirror, adoption readiness를 다룬다.

## Core Files

| 용도 | 파일 |
|------|------|
| Codex 진입점 | `AGENTS.md` |
| Claude Code 진입점 | `CLAUDE.md` |
| 전역 행동 원칙 | `docs/BEHAVIOR-PRINCIPLES.md` |
| 공통 workflow 규칙 | `docs/AGENT-WORKFLOW.md` |
| 상세 protocol | `docs/HARNESS-PROTOCOL.md` |
| 빠른 운영 요약 | `docs/HARNESS-QUICK-REFERENCE.md` |
| Scaffold 부팅 guide | `docs/BOOTSTRAP.md`, `docs/SCAFFOLD-BOOTSTRAP.md` |
| 현재 dashboard | `docs/STATUS.md` |
| 프로젝트 plan | `docs/PLAN.md` |
| Work item SSoT | `docs/works/**` |
| Harness backlog | `docs/backlog/HARNESS.md` |
| 공개 manual | `docs/WORKFLOW-MANUAL.md` |
| 공개 summary | `docs/WORKFLOW-MANUAL-SUMMARY-PUBLIC.md` |
| Scaffold script | `scripts/create-harness.sh` |

## Current Surface Policy

| Class | Examples |
|------|------|
| Core로 유지 | entrypoint, behavior/workflow/protocol docs, STATUS/PLAN/PLAN-SUMMARY, Work/backlog/DR structure, tool command/rule mirror, generic prompt, scaffold |
| Core로 전환 완료 | HARNESS-STRUCTURE (구 ARCHITECTURE), HARNESS-MAINTAINER-GUIDE (구 DEVELOPER-GUIDE + CODING-CONVENTIONS 통합) |
| 유지 여부 검토 | troubleshooting, presentations, archive, optional Spring Boot example profile and prompt pack |
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
