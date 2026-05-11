# STATUS.md

Claude Code를 위한 현재 프로젝트 상태 문서다.
이 파일은 짧게 유지하고, 완료된 Phase의 상세 이력은 `docs/archive/`로 옮긴다.

Last updated: 2026-05-11

## Current State

| Field | Value |
| --- | --- |
| Current phase | Phase 2 planning |
| Phase 1 | Complete |
| Active plan | `docs/PLAN.md` |
| Active backlog | `docs/backlog/PHASE2.md` |
| Phase 1 task details | `docs/TODO//PHASE1/TODO-BLOCK*.md` |
| Phase 1 status archive | `docs/archive/phase1-status.md` |
| Phase 1 plan archive | `docs/archive/phase1-plan.md` |

## Work Context Rule

이 파일은 작업 상태를 관리하기 위한 문서이며, planning, implementation, testing을 대체하지 않는다.

새 작업 항목은 다음 흐름으로 관리한다.

1. backlog 항목을 선택하거나 새로 만든다.
2. Priority, Dependencies, Done Criteria, Verification을 확인한다.
3. 작업이 크거나 위험하면 짧은 plan을 작성하고 approval을 받는다.
4. 구현 전 항목을 Active Work로 올린다.
5. 승인된 scope만 구현한다.
6. 합의된 command 또는 scenario로 검증한다.
7. Active Work, checkpoint status, blockers, next actions를 갱신한다.
8. 현재 작업 판단에 더 이상 필요 없는 완료 상세는 archive로 옮긴다.

## Active Work

| ID | Priority | Status | Scope | Done Criteria | Verification |
| --- | --- | --- | --- | --- | --- |
| P2-PLAN-001 | P0 | Done | Claude Code context와 Phase 2 작업관리 구조 정리 | `CLAUDE.md`, `docs/CLAUDE.md`, `docs/STATUS.md`, Phase 2 backlog가 context-efficient하고 재사용 가능함 | Documentation diff inspection |

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
| OQ-001 | Open | Phase 2는 infrastructure 확장보다 security hardening을 먼저 해야 하는가? | 권장: yes |
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

## Next Actions

1. Phase 2 backlog priority를 사용자와 검토한다.
2. `docs/backlog/PHASE2.md`에서 첫 implementation item을 선택한다.
3. work-management model이 바뀌면 Cursor rules도 함께 정렬한다.
