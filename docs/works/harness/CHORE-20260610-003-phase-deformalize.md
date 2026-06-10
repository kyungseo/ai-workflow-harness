---
id: CHORE-20260610-003
priority: P2
status: Done
risk: L2
scope: harness "Phase" 모델을 descriptive + optional 라벨로 de-formalize한다. 제거된 `Phase completion criteria`/`Current Milestone Criteria` 필드의 dangling 참조를 일괄 정정, T3 phase-transition 트리거를 "criteria 게이트"에서 "전환 기록(Recent Decisions + PLAN Roadmap Lifecycle)"으로 재정의, Work Done을 진실 단위로 명문화(phase 경계 비강제). 추가로 routing 중복(works/{category}) framing 통일 + scaffold target STATUS/PLAN의 "Phase 1" 강제를 phaseless-default로 정합(DR-031 정렬). DR-032로 결정 기록. backlog HRN-030 candidate 착수.
appetite: 1d
planned_start: 2026-06-10
planned_end: 2026-06-10
actual_end: 2026-06-10
related_dr: [DR-032, DR-015, DR-022, DR-031, DR-014, DR-008]
related_troubleshooting: []
related_work: [CHORE-20260609-005, CHORE-20260610-001]
---

# CHORE-20260610-003: Phase 모델 de-formalize + routing/decomposition 정리 (HRN-030)

## Top Summary

- **목표:** `Current Milestone Criteria` 제거(2026-05-25) 이후 공중에 뜬 phase-transition 기계장치를 정리한다. phase를 **descriptive + optional 라벨**로 de-formalize하고, Work Done을 진실 단위로 확정한다.
- **결정 (사용자 승인, DR-032):** phase = descriptive milestone 라벨. 완료 criteria 게이트 없음. 전환은 결정으로 STATUS Recent Decisions에 기록(+ PLAN Roadmap Lifecycle). Work는 phase 경계에 정렬 강제 없음.
- **Scope (사용자 보강 3축):**
  - 축1(product 운용 혼선): scaffold target STATUS `Phase 1` 강제 → phaseless-default 정합(DR-031), 필드명 `Phase`→`Current phase` 통일.
  - 축2(전 표면 점검): 어댑터·rule·prompt·guide 전수 → 대부분 정당한 `Current phase/focus`(보존). cascade 경계 확정.
  - 축3(phase 옵션 확장성): de-formalized 모델이 phaseless·phased 양쪽 동작. 단계 선택 시 라벨 + `PRODUCT-P{n}` 연결 경로 명시.

## Phase 4-용어 Disambiguation (DR-032 핵심)

| 용어 | 의미 | 위치 | 성격 |
| --- | --- | --- | --- |
| `Current phase` (STATUS field) | macro lifecycle/milestone 라벨 | STATUS Current State | **descriptive, optional, de-formalized** |
| Product phasing (`PRODUCT-P{n}`) | adopter 제품 로드맵 단계 | backlog/works/product | optional (DR-031) |
| 절차 "Phase 1-6" | 명령 실행 step 라벨 | work-doc/repo-health | 무관, 보존 |
| State-machine phase | INIT/PLAN/EXECUTE… | 상태머신 | 무관, 보존 |

## Transition 모델 (de-formalized)

- phase 전환 = **결정** → STATUS Recent Decisions 기록 (+ roadmap 이동 시 PLAN Roadmap Lifecycle).
- **Work Done = 진실 단위.** Work는 phase 경계와 독립. 전환은 Work 경계와 무관하게 결정으로 전진.
- **T3 재정의**: "phase/milestone 전환 선언 시 → Recent Decisions 기록 + (해당 시) archive drain + T5 PLAN 영향 확인". criteria 게이트 제거.
- dangling `Phase completion criteria`/`Phase criteria`/`Current Milestone Criteria` 참조 일괄 정정 → `Current phase/focus, Recent Decisions`.

## Scope / Plan (cascade)

| 그룹 | 파일 | 작업 |
| --- | --- | --- |
| DR | `DR-032`(신규 Accepted), `DR-015`(45행), `DR-031`(34행), `DR-022`(정합 확인), decisions/README | 결정 기록 + 제거 필드 참조 정정 |
| canonical | `HARNESS-PROTOCOL.md`(T3 423, STATUS-field 98/110/453, routing 165, Work files 500, Work Done↔phase 경계 추가), `AGENT-WORKFLOW.md`(32/62/93/116), `HARNESS-QUICK-REFERENCE.md`(32/93) | de-formalize 반영 |
| tool surface | `skills/workflow/{session-start,session-summary,work-select,work-resume,work-plan}.md` | dangling STATUS-field 참조 정정 |
| user-facing | `WORKFLOW-MANUAL.md`(613 reframe; 528-540 repo-health 시점 유지) | descriptive 표현 |
| maintainer | `docs/maintainer/migrations/product-track-rename.md`(38) | "Phase completion criteria 보존" 의미 갱신 |
| scaffold (⊕축1) | `scripts/create-harness.sh`(860 STATUS, 1101 PLAN, 838/967/1310 안내) | `Phase 1` 강제 제거 → phaseless-default, 필드명 통일 |

**PRESERVE:** state-machine phase(`output-format.mdc`), 절차 "Phase 1-6", repo-health "Phase 전환 전 사용" 시점, harness "Phase 2" refactor 이력, 예제팩 product 프롬프트(08/11/13/14), 전체 archive, STATUS `Current phase` 라벨 자체.

## Done Criteria

- [x] DR-032 신규(Accepted) + DR-015(폐지 표시)/DR-031(보존필드 정정) + DR-022 정합 확인 + decisions/README closure(invariant [3] OK)
- [x] canonical 3개 문서 de-formalize 반영 (T3 재정의, Work Done↔phase 경계 §10 명문화)
- [x] dangling `Phase (completion )?criteria`/`milestone criteria` 참조 0 — 잔존은 DR-032 정의·Work self·deferred candidate row뿐
- [x] routing 2행(AGENT-WORKFLOW 62/116) + HARNESS-PROTOCOL 165 framing "큰 작업의 SSoT(실행 계획·세부 분해)"로 통일, §10에 "분해=신규 Work ID, phase 무관" 명시
- [x] scaffold target STATUS `Phase`→`Current phase`, PLAN `Phase 계획`→`Roadmap`(optional) 정합
- [x] scaffold 생성물 검증: STATUS `Current phase`(단계 강제 없음), PLAN `## Roadmap` 확인

## Verification 결과

- invariant [1]: 내 regression(`HARNESS-PROTOCOL → DR-032` dangling) 발견 → DR-032 인용 3곳 self-describing으로 정정 → 재검증 시 제거 확인. 남은 4건(DR-029→DR-011/030, DR-013/014→DR-031)은 **pre-existing**(shipped DR seed가 비-seed DR 참조 — 별도 follow-up).
- invariant [2]leak/[3]README closure/[4]root README/[5]manifest: OK.
- `bash -n` OK, `git diff --check` clean, dangling phase-criteria 0.

## Verification

- `rg` dangling 0 (archive 제외), canonical→adapter→user-facing→scaffold cascade 점검
- phase 전환/Work Done 경계 시나리오 문서 시뮬레이션 (HRN-030 Verification)
- `bash -n scripts/create-harness.sh` + dry-run(temp/) → 생성 STATUS phaseless 확인
- decisions/README ↔ DR-032 closure, `git diff --check`

## Risk / Reversal

- **리스크:** 광범위 mechanical cascade — 누락 시 일관성 깨짐. `rg` 전수로 차단. 개념 변경은 작으나 표면 넓음.
- **되돌리기:** Medium. DR-032 revert + 참조 재기입. branch 단위.

## Discovery

- backlog HRN-030 "Phase transition 기준 정립" candidate 착수. CHORE-20260609-005(DR-031 Phase→PRODUCT)에서 파생.
- 사용자 결정: phase de-formalize(descriptive label) + routing/decomposition 묶음. 보강 3축으로 scaffold template 정합 추가.

## Checkpoints

- (착수) 2026-06-10 branch + Work 파일 + DR-032 계획 확정.
- 2026-06-10 실행 완료 — DR 그룹(DR-032 신규 + DR-015/031 정정 + README) → canonical 3종(T3 재정의, dangling 정정, routing 통일, §10 명문화) → tool surface 5 skill → user-facing(MANUAL) + maintainer(migration) → scaffold template(phaseless-default). 18파일.
- 2026-06-10 verification에서 `HARNESS-PROTOCOL → DR-032` dangling regression 발견·정정(DR-032 인용 제거, self-describing). pre-existing 4 dangler는 scope 외 — follow-up candidate로 보고.

## Next Actions

- DR-032 → canonical → tool-surface → scaffold 순 실행 → verification → `/work-close`.
