# STATUS.md

AI Workflow Harness repository의 현재 프로젝트 상태 문서다.
이 파일은 dashboard로 유지하고, 작업별 세부 계획과 기록은 `docs/works/`에 둔다.

Last updated: 2026-05-22 (public-ready migration 시작)

## Current State

| Field | Value |
| --- | --- |
| Current phase | Initial public-ready migration |
| Current focus | AI Workflow Harness 전용 project identity 전환 |
| Project plan | `docs/PLAN.md` |
| Harness backlog | `docs/backlog/HARNESS.md` |
| Quick reference | `docs/HARNESS-QUICK-REFERENCE.md` |
| Harness protocol | `docs/HARNESS-PROTOCOL.md` |
| User workflow manual | `docs/WORKFLOW-MANUAL.md` |
| Public summary | `docs/WORKFLOW-MANUAL-SUMMARY-PUBLIC.md` |
| Repository visibility | Private until public-readiness review |

## Work Context Rule

이 파일은 현재 작업 상태의 dashboard다.
세션 시작 시에는 `Current State`, `Active Work`, `Blockers And Open Questions`, `Next Actions`만 확인한다.
상세 실행 흐름은 `docs/AGENT-WORKFLOW.md`를 따른다.

## Current Milestone Criteria

- [x] `kyungseo/ai-workflow-harness` private repository 생성
- [x] `base-msa-template` Git history / branch / tag 복제
- [x] 새 working copy 생성
- [x] migration feature branch 생성
- [x] AI Workflow Harness 전용 `docs/PLAN.md` 확정
- [x] current tree inventory and classification 완료
- [x] Spring Boot MSA production surface 제거 또는 legacy-isolate
- [x] public README / summary / workflow docs 정렬
- [x] secret/private-info audit 완료
- [ ] public 전환 전 final review 완료

## Active Work

| ID | Priority | Status | Work File |
| --- | --- | --- | --- |
| AWH-001 | P0 | Active | `docs/works/harness/AWH-001-public-repo-migration.md` |

## Blockers And Open Questions

| ID | Status | Question | Decision Needed |
| --- | --- | --- | --- |
| AWH-OQ-001 | Open | Spring Boot profile support를 public v1에 남길 것인가? | generic-only core 여부 결정 |
| AWH-OQ-002 | Open | historical product docs를 `docs/archive/`에 얼마나 남길 것인가? | 현재 guidance와 혼동되지 않는 legacy 기준 결정 |
| AWH-OQ-003 | Open | public positioning을 personal workflow, team workflow, reusable framework 중 어디에 둘 것인가? | README / summary wording 결정 |

## Recent Decisions

| Date | Decision | Reason | Reversal Cost |
| --- | --- | --- | --- |
| 2026-05-21 | Repository name은 `ai-workflow-harness`로 사용 | 현재 system은 AI workflow를 직접 실행하는 engine보다 session/status/gate/validation을 감싸는 harness에 가까움 | Low |
| 2026-05-21 | `base-msa-template` history를 보존한 독립 repo로 분리 | AI Workflow Harness가 product template 개발 과정에서 형성된 이력을 공개 가치로 남김 | Low |
| 2026-05-21 | public 전환 전까지 repository는 private 유지 | Spring Boot/MSA 흔적 정리와 private-info audit 후 공개하기 위함 | Low |

## Next Actions

1. AWH-001 CP-5: diff review and final public-readiness report
2. AWH-001 CP-5: PR 준비 전 reviewer-facing summary 작성
3. Public 전환은 PR merge 후 별도 final review에서 결정
