# STATUS.md

Claude Code를 위한 현재 프로젝트 상태 문서다.
이 파일은 짧게 유지하고, 완료된 Phase의 상세 이력은 `docs/archive/`로 옮긴다.

Last updated: 2026-05-11 (AI workflow 정비 심화 + Cursor 정렬 완료)

## Current State

| Field | Value |
| --- | --- |
| Current phase | Phase 2 planning |
| Phase 1 | Complete |
| Active plan | `docs/PLAN.md` |
| Active backlog | `docs/backlog/PHASE2.md` |
| Phase 1 task details | `docs/TODO/PHASE1/TODO-BLOCK*.md` |
| Phase 1 status archive | `docs/archive/phase1-status.md` |
| Phase 1 plan archive | `docs/archive/phase1-plan.md` |

## Work Context Rule

이 파일은 작업 상태를 관리하기 위한 문서이며, planning, implementation, testing을 대체하지 않는다.
작업 흐름 상세: `docs/CLAUDE.md` → Work Management Model 참조.

실행 흐름 요약: `backlog 선택 → plan → approval → implementation → verification → status update`

## Active Work

| ID | Priority | Status | Scope | Done Criteria | Verification |
| --- | --- | --- | --- | --- | --- |
| P2-PLAN-001 | P0 | Done | Claude Code context와 Phase 2 작업관리 구조 정리 | `CLAUDE.md`, `docs/CLAUDE.md`, `docs/STATUS.md`, Phase 2 backlog가 context-efficient하고 재사용 가능함 | Documentation diff inspection |
| P2-PLAN-002 | P0 | Done | AI workflow 점검 및 개선 (Vibe Coding best practice 기준) | `.claude/commands/` 6개, `.claude/rules/testing.md`, `docs/decisions/` 구조, `docs/PLAN-SUMMARY.md`, `settings.json` 수정 완료 | 파일 존재 확인 및 `/start` slash command 동작 확인 |
| P2-PLAN-003 | P0 | Done | AI workflow 정비 심화 + Cursor 정렬 | 언어 원칙 정의, rules 정합성·token 효율 개선, prompts 라이브러리 Spring Boot 특화, Cursor rules Claude와 정렬 완료 | 파일 존재 확인 및 git log 검토 |

## Phase 2 Checkpoints

| Checkpoint | Purpose | Status | Verification |
| --- | --- | --- | --- |
| CP-P2-0 | Phase 2 계획과 backlog 구조화 | Done | `docs/STATUS.md`, `docs/backlog/PHASE2.md` 검토 |
| CP-P2-1 | token/session 관련 보안 의사결정 완료 | Not started | Decision records and targeted tests |
| CP-P2-2 | gateway/proxy 동작을 운영 환경 기준으로 보정 | Not started | Rate limiting and trusted proxy tests |
| CP-P2-3 | infrastructure 방향 결정 | Not started | K8s/CI decision records and dry-run validation |
| CP-P2-4 | observability baseline 구현 | Not started | Metrics/tracing/logging validation |

## Blockers And Open Questions

| ID | Status | Question | Decision Needed |
| --- | --- | --- | --- |
| OQ-001 | Closed | Phase 2는 infrastructure 확장보다 security hardening을 먼저 해야 하는가? | DR-003 참조: Security first 결정. P2-001→002→003→004 순서 |
| OQ-002 | Open | K8s 배포 도구는 Helm과 Kustomize 중 무엇을 쓸 것인가? | manifests 작성 전 결정 |
| OQ-003 | Open | token storage를 localStorage에서 HttpOnly Cookie로 전환할 것인가? | frontend/auth 변경 전 결정 |
| OQ-004 | Closed | `.claude/claude.json`은 legacy custom harness config였는가? | 삭제 완료. 공식 Claude Code config는 `.claude/settings.json` |

## Recent Decisions

| Date | Decision | Reason | Reversal Cost |
| --- | --- | --- | --- |
| 2026-05-11 | active state는 `docs/STATUS.md`에 유지하고 Phase 1 상세는 archive로 이동 | Phase 2에서 Claude context load 감소 | Low |
| 2026-05-11 | root `CLAUDE.md`를 재사용 가능하게 만들고 `docs/CLAUDE.md`를 명시 import | instruction loading 개선 및 cross-project reuse | Low |
| 2026-05-11 | 공식 `.claude/settings.json`과 path-scoped `.claude/rules/` 추가 | 중복 prompt context 감소 및 Claude Code 설정 정렬 | Low |
| 2026-05-11 | legacy `.claude/claude.json` 삭제 | 사용자 확인 후 obsolete custom harness configuration 제거 | Low |
| 2026-05-11 | AI workflow 개선: `.claude/commands/` 6개, `testing.md` rule, `PLAN-SUMMARY.md`, `decisions/` DR 초안 3개, `settings.json` 수정 | Phase 2 착수 전 workflow 마찰 최소화, Vibe Coding best practice 정렬 | Low |
| 2026-05-11 | 언어 원칙 정의: `.claude/rules/*.md`·루트 `CLAUDE.md` → 영어, `docs/*.md`·`prompts/*.md` → 한국어+기술용어 영어 유지 | token 효율 및 instruction 준수율 향상 | Low |
| 2026-05-11 | `git-workflow.md` rule 신규 추가: 커밋 전 `git status → add → status → diff --cached` 프로세스 강제 | 커밋 누락 방지 (unstaged/untracked 미확인 문제) | Low |
| 2026-05-11 | Cursor rules를 Claude rules와 정렬: `java-spring.mdc`, `testing.mdc` 신규, `git-commit.mdc` 프로세스 추가, `.cursorignore` 업데이트 | Claude/Cursor 간 규칙 정합성 확보 | Low |
| 2026-05-11 | prompts 라이브러리 Spring Boot 특화: `21-create-layer`, `22-minimal-diff` 신규, 기존 5개 개선 (minimal patch, API contract 불변, Spring 안티패턴 체크) | AI 작업 품질 및 범위 제어 향상 | Low |

## Next Actions

1. `/pick` 커맨드로 Phase 2 첫 구현 항목 선택 (P2-001 권장).
2. `docs/decisions/DR-001-token-storage.md`를 채워서 P2-001 착수 전 결정 완료.
3. `docs/decisions/DR-002-k8s-tool.md`는 P2-004 착수 전까지 Draft 유지.
