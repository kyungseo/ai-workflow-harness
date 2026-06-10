# STATUS.md

AI Workflow Harness repository의 현재 프로젝트 상태 문서다.
이 파일은 dashboard로 유지하고, 작업별 세부 계획과 기록은 `docs/works/`에 둔다.

Last updated: 2026-06-10 (harness Phase 모델 de-formalize — descriptive+optional 라벨, dangling criteria 정리, scaffold phaseless-default 정합(DR-032) — CHORE-20260610-003)

## Current State

| Field | Value |
| --- | --- |
| Current phase | AWH-004 — Maintenance & Adoption |
| Current focus | 1.1.0 릴리즈, adopter upgrade/migration, onboarding 현행화 |
| Project plan | `docs/PLAN.md` |
| Harness backlog | `docs/backlog/HARNESS.md` |
| Quick reference | `docs/HARNESS-QUICK-REFERENCE.md` |
| Harness protocol | `docs/HARNESS-PROTOCOL.md` |
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
| 2026-06-10 | DR-032: harness "Phase"를 descriptive+optional 라벨로 de-formalize. 완료 criteria 게이트 제거, 전환=Recent Decisions 기록, Work Done=진실 단위 | 제거된 `Phase completion criteria` 필드의 dangling 기계장치 정리, DR-031 optional 철학 정렬 — CHORE-20260610-003 | Medium |
| 2026-06-09 | DR-031: Product track을 harness와 대칭(`PRODUCT.md`/`works/product/`)으로 전환, phase는 optional migration. source-only migration note는 `docs/migrations/` | `PHASE{n}` backlog가 harness 내부 "Phase"와 네이밍 충돌. 대칭화로 충돌 제거 + phase 강제 폐지 — CHORE-20260609-005 | Medium |
| 2026-06-09 | DR-029: DR 등록 3-way triage(Accepted/Draft/OQ·backlog) + Draft DR lifecycle(승격·Dropped·repo-health hygiene surfacing) | 미결 질문의 Accepted DR 위장 차단, Draft 누적 soft 관리. 기존 lifecycle 참조 — CHORE-20260609-002 | Low |
| 2026-06-07 | DR-027: troubleshooting·retrospective 파일 최소 frontmatter 스펙 도입. `track: harness \| product` 필드 신설 | 분류·상태를 파일 열람 없이 파악하기 위한 최솟값 정형화. 기존 파일 소급 적용, T11 cascade 완료 | Low |
| 2026-06-07 | DR-026: `/repo-decision` → `/record-decision` 원복. `track: harness \| product` 메타데이터 도입 | `repo-decision` 명칭이 harness repo 한정 coverage로 오해 유발. 원래 이름으로 복원 + product decision 명시 — CHORE-20260607-006 | Low |
| 2026-06-05 | slice 0 4축 방향 DR 채택 — DR-021(source/target boundary), DR-022(PLAN lifecycle), DR-023(canonical+hybrid adapter), DR-024(gate 2D taxonomy) | Phase 2 리팩토링 4축 TO-BE 확정. cross-agent R0~R6 합의, decision-only(적용은 하류 slice) — CHORE-20260605-001/002 | DR별 상이(Low~High) |
| 2026-05-29 | pre-commit: main만 hard block, develop은 warning 유지. commit-msg build type 추가, 두 hook 설치 | GitHub ruleset이 develop direct push를 이미 차단. solo 프로젝트에서 housekeeping마다 PR 강제는 과도한 마찰 — CHORE-20260529-003 + fix | Low |
| 2026-05-27 | Work/OQ/Tracker ID를 `<TYPE>-<YYYYMMDD>-<NNN>` 형식으로 전환, backlog candidate ID-less 정책 도입 | 전역 순번 HRN-*/P{n}-NNN 방식의 병렬 feature 충돌 및 scaffold 확장성 문제 해소 — CHORE-20260527-001 | Medium |

## Next Actions

1. **P1 우선순위 Top 4** (다음 작업 선택은 `/work-select`):
   - **Scaffold/tool-surface alignment 점검 체계화** — scaffold drift 구조적 문제. PR #93 이후 신규 merge 전체 재검증 즉시 실행 가능
   - **Harness upgrade/migration 메커니즘** — 실 adopter(`ai-deck-compiler`) upstream 반영 필요. concrete driver 있는 유일한 항목
   - **Backlog row lifecycle SSoT 정비** — work-close마다 수동 확인 발생. 세션 안정성 직접 영향
   - **Adopter onboarding/manual refresh** — README overhaul 이후 onboarding path 정합 미확인. upgrade/migration 전 기반 정리 필요
2. **Canonical weight 경량화 + Optional pack 재정의 클러스터** — `repo-health.md` slice 분리·`work-doc.md` class 재검토(P2 신규)를 repo-health gate 보강·Prompt surface diet(P1)와 묶어 착수
