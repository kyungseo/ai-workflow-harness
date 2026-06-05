# STATUS.md

AI Workflow Harness repository의 현재 프로젝트 상태 문서다.
이 파일은 dashboard로 유지하고, 작업별 세부 계획과 기록은 `docs/works/`에 둔다.

Last updated: 2026-06-05 (Scaffold minimal output Done — CHORE-20260605-005, DR-021 적용)

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
| 2026-06-05 | slice 0 4축 방향 DR 채택 — DR-021(source/target boundary), DR-022(PLAN lifecycle), DR-023(canonical+hybrid adapter), DR-024(gate 2D taxonomy) | Phase 2 리팩토링 4축 TO-BE 확정. cross-agent R0~R6 합의, decision-only(적용은 하류 slice) — CHORE-20260605-001/002 | DR별 상이(Low~High) |
| 2026-05-29 | pre-commit: main만 hard block, develop은 warning 유지. commit-msg build type 추가, 두 hook 설치 | GitHub ruleset이 develop direct push를 이미 차단. solo 프로젝트에서 housekeeping마다 PR 강제는 과도한 마찰 — CHORE-20260529-003 + fix | Low |
| 2026-05-27 | Work/OQ/Tracker ID를 `<TYPE>-<YYYYMMDD>-<NNN>` 형식으로 전환, backlog candidate ID-less 정책 도입 | 전역 순번 HRN-*/P{n}-NNN 방식의 병렬 feature 충돌 및 scaffold 확장성 문제 해소 — CHORE-20260527-001 | Medium |
| 2026-05-26 | feature branch pre-PR `/close`가 commit 전략을 3-state(미push/push+PR없음/push+PR열림·공유·확인불가)로 안내하도록 개선 | feature branch /close 시 별도 close commit이 PR history 노이즈를 만드는 패턴 해소 — HRN-037 | Low |
| 2026-05-25 | `Current Milestone Criteria` 제거 및 `Current phase`를 `Public baseline / Maintenance`로 전환 | HRN-035: public clone 첫 `/start` 출력에서 maintainer 내부 milestone이 노출되지 않도록 baseline 정리. 이력은 HRN-035 Work에 보존 | Low |
| 2026-05-25 | `AWH-OQ-001` Blockers 제거 — archive policy가 필요할 때 신규 Work로 재등록 | public baseline에 Open Blocker가 남으면 "미완" 인상 지속. HARNESS.md Deferred Ideas로 이동 | Low |
| 2026-05-24 | Product Definition / Project Initialization Gate 도입 | baseline 없이 기능 후보를 등록하는 흐름 차단 — BOOTSTRAP.md §2–§3 + PLAN-SUMMARY.md Implementation Baseline + PHASE1.md Baseline Gate | Low |
| 2026-05-23 | README를 `WORKFLOW-MANUAL-SUMMARY-PUBLIC.md` 기반 단일 문서(경로 A)로 교체 | 파일 목록형 README에서 Prologue·원칙·흐름을 통합한 공개 front-door로 전환 — SUMMARY-PUBLIC drift 방지 | Low |

## Next Actions

1. **하류 slice 진행** — scaffold minimal output(CHORE-20260605-005, DR-021) Done. Follow-Up PR Slicing Draft(부모 Work CHORE-20260604-001) 남은 순서: **breaking slice #13(DR-023 canonical+adapter 전환 + no-alias command rename 동시; Q4 `--check` 경로 위에서만, 단독 선행 금지)** → user-facing 개편(slice #11). PQ-5/OQ-7(scaffold PLAN Roadmap Lifecycle propagate)는 별도 scaffold PLAN/template slice로 이월. 각 slice 착수 시 Next Actions 재평가(자동 연쇄 아님).
2. **child DR — Commit gate runtime enforcement** — DR-024 하류. causal finalization bundling hard-stop/override 정책을 gate runtime enforcement 적용 slice에서 별도 DR로 작성.
