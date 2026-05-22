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

## Current Milestone

| Field | Value |
|------|------|
| Phase | Initial public-ready migration |
| Active Work | `AWH-001` |
| Work File | `docs/works/harness/AWH-001-public-repo-migration.md` |
| Branch | `feature/ai-workflow-harness-migration` |
| Visibility | Private until public-readiness review |

## Key Operating Decisions

- Repository name: `ai-workflow-harness`
- Full Git history from `base-msa-template` is intentionally preserved.
- Current tree should become AI Workflow Harness focused.
- `docs/PLAN.md` and `docs/STATUS.md` stay live after migration; migration details live in Work files.
- `docs/PLAN-SUMMARY.md` is a core Context Routing surface and must be rewritten, not removed.
- Public release happens only after product surface cleanup and private-info audit.

## Core Files

| Purpose | File |
|------|------|
| Codex entrypoint | `AGENTS.md` |
| Claude Code entrypoint | `CLAUDE.md` |
| Global behavior principles | `docs/BEHAVIOR-PRINCIPLES.md` |
| Common workflow rules | `docs/AGENT-WORKFLOW.md` |
| Detailed protocol | `docs/HARNESS-PROTOCOL.md` |
| Quick operational summary | `docs/HARNESS-QUICK-REFERENCE.md` |
| Current dashboard | `docs/STATUS.md` |
| Project plan | `docs/PLAN.md` |
| Work item SSoT | `docs/works/**` |
| Harness backlog | `docs/backlog/HARNESS.md` |
| Public manual | `docs/WORKFLOW-MANUAL.md` |
| Public summary | `docs/WORKFLOW-MANUAL-SUMMARY-PUBLIC.md` |
| Scaffold | `scripts/create-harness.sh` |

## Current Cleanup Classification

| Class | Examples |
|------|------|
| Keep as core | entrypoints, behavior/workflow/protocol docs, STATUS/PLAN/PLAN-SUMMARY, Work/backlog/DR structure, tool command/rule mirrors, generic prompts, scaffold |
| Keep as core (converted) | HARNESS-STRUCTURE (구 ARCHITECTURE), MAINTAINER-GUIDE (구 DEVELOPER-GUIDE + CODING-CONVENTIONS 통합) |
| Review before keeping | troubleshooting, presentations, archive, Spring Boot profile, Java/Spring rules and prompts |
| Remove or legacy-isolate | Spring Boot runtime code, Gradle build, common/gateway/services/frontend/tests, Docker/K8s/DB infra, generated build output |

## Validation Defaults

| Change | Validation |
|------|------|
| Documentation-only | `git diff --check`, targeted stale-term search |
| Workflow/protocol/tool surface | canonical -> tool-specific -> user-facing -> scaffold cascade check |
| Scaffold script | `bash -n scripts/create-harness.sh`, generic dry-run, optional temp actual generation |
| Public release prep | secret/private-info scan, stale identity audit, GitHub visibility check |

## Active References

| Need | File |
|------|------|
| Current state | `docs/STATUS.md` |
| Migration plan and discoveries | `docs/works/harness/AWH-001-public-repo-migration.md` |
| Long-term project plan | `docs/PLAN.md` |
| Workflow rules | `docs/AGENT-WORKFLOW.md` |
| Detailed protocol | `docs/HARNESS-PROTOCOL.md` |
| User-facing workflow guide | `docs/WORKFLOW-MANUAL.md` |
