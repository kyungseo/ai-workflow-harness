# STATUS.md

AI Workflow Harness repository의 현재 프로젝트 상태 문서다.
이 파일은 dashboard로 유지하고, 작업별 세부 계획과 기록은 `docs/works/`에 둔다.

Last updated: 2026-05-26 (HRN-037 완료 — /close commit 전략 안내 3-state 감지 개선)

## Current State

| Field | Value |
| --- | --- |
| Current phase | Public baseline / Maintenance |
| Current focus | Public repository maintenance and adoption support |
| Project plan | `docs/PLAN.md` |
| Harness backlog | `docs/backlog/HARNESS.md` |
| Quick reference | `docs/HARNESS-QUICK-REFERENCE.md` |
| Harness protocol | `docs/HARNESS-PROTOCOL.md` |
| User workflow manual | `docs/WORKFLOW-MANUAL.md` |
| Repository visibility | Public release ready |

## Work Context Rule

이 파일은 현재 작업 상태의 dashboard다.
세션 시작 시에는 `Current State`, `Active Work`, `Blockers And Open Questions`, `Next Actions`만 확인한다.
상세 실행 흐름은 `docs/AGENT-WORKFLOW.md`를 따른다.

## Active Work

| ID | Title | Work File |
| --- | --- | --- |

## Blockers And Open Questions

| ID | Status | Question | Decision Needed |
| --- | --- | --- | --- |

## Recent Decisions

| Date | Decision | Reason | Reversal Cost |
| --- | --- | --- | --- |
| 2026-05-25 | `Current Milestone Criteria` 제거 및 `Current phase`를 `Public baseline / Maintenance`로 전환 | HRN-035: public clone 첫 `/start` 출력에서 maintainer 내부 milestone이 노출되지 않도록 baseline 정리. 이력은 HRN-035 Work에 보존 | Low |
| 2026-05-25 | `AWH-OQ-001` Blockers 제거 — archive policy가 필요할 때 신규 Work로 재등록 | public baseline에 Open Blocker가 남으면 "미완" 인상 지속. HARNESS.md Deferred Ideas로 이동 | Low |
| 2026-05-24 | Product Definition / Project Initialization Gate 도입 | baseline 없이 기능 후보를 등록하는 흐름 차단 — BOOTSTRAP.md §2–§3 + PLAN-SUMMARY.md Implementation Baseline + PHASE1.md Baseline Gate | Low |
| 2026-05-23 | README를 `WORKFLOW-MANUAL-SUMMARY-PUBLIC.md` 기반 단일 문서(경로 A)로 교체 | 파일 목록형 README에서 Prologue·원칙·흐름을 통합한 공개 front-door로 전환 — SUMMARY-PUBLIC drift 방지 | Low |
| 2026-05-22 | `AGENTS.md`와 `.cursor/rules/workflow.mdc`에 Document Language Policy 섹션 추가 | Codex/Cursor가 DR-007을 문서 편집 시 적용하지 않는 구조적 결함 수정 — path-scoped 자동 로딩이 없는 도구에 inline 규칙 삽입 | Medium |
| 2026-05-22 | AWH-001 이후 phase를 `Workflow hardening`으로 전환 | public-ready migration 이후 모든 후속 작업을 문서 현행화, scaffold 정합성, tool surface alignment 강화 단계로 묶기 위함 | Low |
| 2026-05-22 | `.cursor/rules/role-backend.mdc` → `role-harness-maintainer.mdc` rename | 파일명이 Spring Boot 시절 이름을 유지하고 있었고 내용은 이미 Harness Maintainer Role로 교체된 상태 — 파일명/내용 불일치 수정 | Low |
| 2026-05-22 | Spring Boot prompt bundle을 optional example pack으로 보존 | generic harness에서 제거하지 않고 stack-specific prompt 구성 방식을 보여주는 sample로 유지 | Low |

## Next Actions

(없음)
