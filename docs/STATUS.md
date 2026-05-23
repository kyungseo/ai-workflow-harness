# STATUS.md

AI Workflow Harness repository의 현재 프로젝트 상태 문서다.
이 파일은 dashboard로 유지하고, 작업별 세부 계획과 기록은 `docs/works/`에 둔다.

Last updated: 2026-05-23 (HRN-026 완료 — Codex tool surface 정렬)

## Current State

| Field | Value |
| --- | --- |
| Current phase | Workflow hardening |
| Current focus | AI Workflow Harness 문서 현행화, scaffold 정합성, tool surface alignment |
| Project plan | `docs/PLAN.md` |
| Harness backlog | `docs/backlog/HARNESS.md` |
| Quick reference | `docs/HARNESS-QUICK-REFERENCE.md` |
| Harness protocol | `docs/HARNESS-PROTOCOL.md` |
| User workflow manual | `docs/WORKFLOW-MANUAL.md` |
| Repository visibility | Private until public-readiness review |

## Work Context Rule

이 파일은 현재 작업 상태의 dashboard다.
세션 시작 시에는 `Current State`, `Active Work`, `Blockers And Open Questions`, `Next Actions`만 확인한다.
상세 실행 흐름은 `docs/AGENT-WORKFLOW.md`를 따른다.

## Current Milestone Criteria

- [ ] canonical / tool-specific / user-facing / scaffold 문서 계층 정합성 확인
- [ ] start, pick, work, resume, close/done, archive, quick mode, state update, cascade/trigger, scaffold flow 시뮬레이션 완료
- [ ] stale rename, removed path, runtime identity scan 통과
- [ ] fresh scaffold 생성 결과 검증
- [ ] public/adoption readiness 기준으로 문서 보완 완료

## Active Work

| ID | Title | Work File |
| --- | --- | --- |
| HRN-026 | Codex tool surface 정렬 — skills 완성, cascade 반영, AGENTS.md 재정비 | `docs/works/harness/HRN-026-codex-tool-surface-alignment.md` |

## Blockers And Open Questions

| ID | Status | Question | Decision Needed |
| --- | --- | --- | --- |
| AWH-OQ-001 | Open | historical product docs를 `docs/archive/`에 얼마나 남길 것인가? | 현재 guidance와 혼동되지 않는 legacy 기준 결정 |

## Recent Decisions

| Date | Decision | Reason | Reversal Cost |
| --- | --- | --- | --- |
| 2026-05-23 | README를 `WORKFLOW-MANUAL-SUMMARY-PUBLIC.md` 기반 단일 문서(경로 A)로 교체 | 파일 목록형 README에서 Prologue·원칙·흐름을 통합한 공개 front-door로 전환 — SUMMARY-PUBLIC drift 방지 | Low |
| 2026-05-22 | `AGENTS.md`와 `.cursor/rules/workflow.mdc`에 Document Language Policy 섹션 추가 | Codex/Cursor가 DR-007을 문서 편집 시 적용하지 않는 구조적 결함 수정 — path-scoped 자동 로딩이 없는 도구에 inline 규칙 삽입 | Medium |
| 2026-05-22 | AWH-001 이후 phase를 `Workflow hardening`으로 전환 | public-ready migration 이후 모든 후속 작업을 문서 현행화, scaffold 정합성, tool surface alignment 강화 단계로 묶기 위함 | Low |
| 2026-05-22 | `.cursor/rules/role-backend.mdc` → `role-harness-maintainer.mdc` rename | 파일명이 Spring Boot 시절 이름을 유지하고 있었고 내용은 이미 Harness Maintainer Role로 교체된 상태 — 파일명/내용 불일치 수정 | Low |
| 2026-05-22 | Spring Boot prompt bundle을 optional example pack으로 보존 | generic harness에서 제거하지 않고 stack-specific prompt 구성 방식을 보여주는 sample로 유지 | Low |
| 2026-05-21 | Repository name은 `ai-workflow-harness`로 사용 | 현재 system은 AI workflow를 직접 실행하는 engine보다 session/status/gate/validation을 감싸는 harness에 가까움 | Low |
| 2026-05-21 | `base-msa-template` history를 보존한 독립 repo로 분리 | AI Workflow Harness가 product template 개발 과정에서 형성된 이력을 공개 가치로 남김 | Low |
| 2026-05-21 | public 전환 전까지 repository는 private 유지 | Spring Boot/MSA 흔적 정리와 private-info audit 후 공개하기 위함 | Low |

## Next Actions

(없음)
