---
id: CHORE-20260605-004
priority: P1
status: Done
risk: Medium
scope: DR-022(PLAN lifecycle) 적용 — 기존 T5를 closeout/phase-transition/commit finalization에 배선, PLAN archive-drain 규칙 신설, PLAN.md 소생(stale header·§4 milestone·§7 roadmap AWH↔CHORE drift 정합). canonical/adapter rename·breaking 변경은 제외
appetite: 2d
planned_start: 2026-06-05
planned_end: 2026-06-07
actual_end: 2026-06-05
related_dr: [DR-022, DR-024]
related_troubleshooting: []
related_work: [CHORE-20260604-001, CHORE-20260607-001]
---

# CHORE-20260605-004: PLAN Lifecycle Wiring (DR-022 적용)

## Top Summary (결론 먼저)

- **목표:** DR-022가 정한 방향을 실제 문서/규칙에 배선. 신규 hard gate 신설 없음.
- **3축:** ① **T5 배선** — 기존 T5(PLAN 영향 결정)를 closeout(`/close`·T15/16)·phase-transition(T3)에 연결(들어오는 문). ② **archive-drain 규칙** — 닫힌 phase 상세는 `docs/archive/`로, PLAN은 현재+미래+링크 유지(나가는 문). ③ **PLAN 소생** — stale header(`v0.1`/`2026-05-22`), §4 milestone, §7 roadmap의 AWH↔CHORE drift(D3) 정합.
- **enforcement mode(DR-024):** PLAN impact 확인은 closeout에서 **recommended/warning** 수준(hard-stop 아님) — soft gate. content/no-code 프로젝트 거짓 차단 방지.
- **비목표:** canonical+adapter 전환, command rename, scaffold minimal output, breaking 변경. PLAN을 charter/roadmap 파일로 물리 분할하지 않음(DR-022: 분할이 아니라 배선).

## Context Manifest

| 순서 | 파일 | 섹션 | 왜 |
| --- | --- | --- | --- |
| 1 | `docs/decisions/DR-022-plan-lifecycle.md` | Decision/Consequences | 적용 대상 방향 |
| 2 | `docs/HARNESS-PROTOCOL.md` | T3(421)/T5(423)/T15-17(433-435)/Loop Safety(439-451)/STATUS Section Deletion(493) | T5 배선 지점 |
| 3 | `.claude/commands/close.md`, `done.md` | closeout 흐름 | T5 PLAN impact 삽입 위치 |
| 4 | `docs/PLAN.md` | §4 milestone, §7 roadmap, header | 소생·archive-drain·D3 대상 |
| 5 | `docs/HARNESS-PROTOCOL.md:496` (rolling window) | Recent Decisions drain | archive-drain 동형 모델 |

## Defect/Scope Inventory (실측)

| # | 항목 | 근거 |
| --- | --- | --- |
| W1 | T5는 존재하나 closeout(T15/16/17)·T3가 T5를 호출 안 함 | T3=`HARNESS-PROTOCOL.md:421`, T5=`:423`, T15~17=`:433-435`, loop safety=`:449-451` |
| W2 | PLAN에 archive-drain 규칙 없음(Recent Decisions에는 rolling window 있음) | `HARNESS-PROTOCOL.md:496` |
| W3 | PLAN header `v0.1`/`2026-05-22` stale, §7 roadmap `AWH-003/004` 정지, 실작업 `CHORE-*` | `docs/PLAN.md:3-4,112-119` |
| W4 | §4 Current Milestone이 AWH-001/002 기준, Phase 2 진행 미반영 | `docs/PLAN.md:57-69` |

## Plan

### A. T5 배선 (들어오는 문) — R13/R14 확정
1. `HARNESS-PROTOCOL.md`에 T5↔closeout/phase-transition 연결 추가. T5 wording은 "PLAN 영향 **판단** + 필요 시 proposal"(필수 작성 완료 아님). 근거 라인: T3=`:421`, T5=`:423`, T15~17=`:433-435`, loop safety=`:449-451`.
2. **`/close`**(Work Done 처리)에 PLAN impact 확인 step 추가(**recommended/warning soft**, hard-stop 아님). **`/done`은 closeout gate로 만들지 않는다** — session/commit summary에서 "PLAN impact 확인 여부"만 보고. Codex/Cursor mirror(`.agents/skills/workflow-close`, `.cursor/rules/workflow.mdc`) 동기화.

### B. archive-drain 규칙 (나가는 문)
3. PLAN.md에 lifecycle 규칙 섹션 신설: "현재+다음 horizon만 유지, 닫힌 phase 상세는 `docs/archive/`로 drain, PLAN엔 링크 한 줄, L3 근거는 DR로." Recent Decisions rolling-window와 동형.
4. `HARNESS-PROTOCOL.md` T3/STATUS Section Deletion checklist에 PLAN drain 연결(이미 T3=STATUS/PLAN archive 존재 → 구체화).

### C. PLAN 소생 (D3 포함)
5. header version/date 갱신(`v0.1`→현행, lifecycle 적용 명시).
6. §7 Roadmap을 현실 정합으로: AWH-001/002 완료 + **Phase 2(현재 horizon)** 반영. AWH↔CHORE drift 해소 — stage ID 체계 결정(PQ).
7. §4 Current Milestone을 Phase 2 진행 상태로 갱신.

### 결정 필요 (Codex)
- **PQ-1:** T5 배선의 enforcement mode — closeout PLAN impact를 recommended/warning으로 두는 게 DR-024 taxonomy와 맞는가? hard-stop 후보 상황은?
- **PQ-2:** archive-drain 규칙을 PLAN.md 자체에 둘지, HARNESS-PROTOCOL에 둘지, 양쪽 pointer로 둘지?
- **PQ-3:** AWH↔CHORE 정합 — roadmap stage를 (a) AWH-* 유지(stage label, Work ID와 구분 명시) (b) descriptive stage명으로 전환 (c) Phase{n} 체계로 통일? 최소 변경 + drift 재발 방지 기준.
- **PQ-4:** PLAN 소생 범위 — header/§4/§7만 vs 더 넓게? 과잉 rewrite 방지선.

## Done Criteria

- [x] A: T5가 closeout/commit finalization/phase-transition에 배선됨(protocol + close/done command, mirror 동기화)
- [x] B: PLAN archive-drain 규칙 신설(PLAN + protocol 연결)
- [x] C: PLAN.md 소생 — header/§4/§7 현행화, AWH↔CHORE drift 해소
- [x] cascade 점검(canonical→tool→user-facing→scaffold), enforcement mode는 DR-024 정합
- [x] Codex cross-agent 합의(plan + 결과)
- [x] **사용자 최종 리뷰** 후 Done

## Verification

- documentation 변경: `git diff --check`, 링크/stale phrase 점검.
- cascade: `close.md`/`done.md` 변경 시 `.agents/skills/workflow-close|done`, `.cursor/rules/workflow.mdc`, QUICK-REFERENCE 동기화 확인.
- PLAN drift 재검: `grep AWH docs/PLAN.md` 후 잔존 stale 확인.

## Checkpoints

| CP | Description | Status |
| --- | --- | --- |
| 1 | Plan Codex 검토(PQ-1~4) 합의 (R13/R14) | Done |
| 2 | A. T5 배선 (protocol + close/done + close skill + cursor mirror) | Done |
| 3 | B. archive-drain 규칙 (PLAN §7-a SSoT + protocol pointer) | Done |
| 4 | C. PLAN 소생 (header v0.2/§4 Phase 2/§7 roadmap + AWH note) | Done |
| 5 | cascade 점검 + Codex 결과 검토(R15) + 사용자 리뷰 | Done |

## Cross-Agent Review And Discussion

slice 1a/1b의 R7~R11을 이어, 이 slice도 **구현 전 plan**을 먼저 검토(PQ-1~4)하고 결과를 후속 라운드로 검토한다.

### Round Log

| Round | 작성자 | 단계 | 요약 |
| --- | --- | --- | --- |
| R12 | Claude | Plan | DR-022 적용 plan(A/B/C) + PQ-1~4 제기. Codex 검토 대기 |
| R13 | Codex | Plan Review | PQ-1~4 검토. T5는 recommended/warning soft gate, archive-drain은 PLAN SSoT + protocol pointer, AWH는 stage label로 유지, 소생 범위는 header/§4/§7 + lifecycle rule block로 제한 권장 |
| R14 | Claude | Plan Finalize | R13 전부 반영 — `/close`만 PLAN impact step, `/done`은 summary 보고로 제한, W1 근거 라인 정밀화. 구현 착수 준비 |
| R15 | Codex | Result Review | 구현 결과 검토. A/B/C는 R13 합의와 정합. DR-022/024 provenance 제거 동의. PQ-5는 이번 slice에서 scaffold PLAN propagate 대신 copied 문서 conditional/generic 유지 권장 |

### Codex Plan Review

작성: Codex, 2026-06-05. 이 리뷰는 구현 전 plan 검토다. `HARNESS-PROTOCOL.md`, `.claude/commands/*`, `PLAN.md` 실제 편집은 하지 않고, DR-022 적용 경계와 PQ-1~4의 결정 방향만 정한다.

#### Summary

Plan의 큰 방향에 **조건부 동의**한다. DR-022가 정한 핵심은 새 hard gate 신설이 아니라 기존 `T5`를 closeout/phase-transition/commit finalization에 연결하는 것이다(`docs/decisions/DR-022-plan-lifecycle.md:10-20`). 현재 protocol에는 `T3` phase trigger, `T5` PLAN 영향 trigger, `T15~T17` commit/PR 전 finalization trigger가 각각 존재하지만 서로 호출 관계가 없다(`docs/HARNESS-PROTOCOL.md:421-435`, `:449-451`). 따라서 A/B/C plan은 방향상 맞다.

조건은 세 가지다.

1. PLAN impact 확인은 평시 `/close`에서 **recommended/warning**으로 둔다. PLAN 작성 완료를 Work Done의 hard-stop으로 만들지 않는다.
2. archive-drain의 SSoT는 `PLAN.md`에 두고, `HARNESS-PROTOCOL.md`는 `T3`/section deletion에서 한 줄 pointer만 둔다.
3. PLAN 소생은 header/§4/§7과 새 lifecycle rule block으로 제한한다. §1-3, §5, §6, §8, §9를 해석 rewrite하지 않는다.

#### PQ별 권장안

| PQ | 권장안 | 근거 | Plan 반영 조건 |
| --- | --- | --- | --- |
| PQ-1: T5 enforcement mode | **recommended/warning**이 맞다. hard-stop은 PLAN impact "확인" 자체가 아니라, 이미 승인된 PLAN/STATUS/Work state 변경을 commit finalization에서 누락하려는 경우의 별도 bundling 문제로만 다룬다. | DR-022는 generated repo에서 `PLAN.md` 작성 완료를 feature work hard gate로 두지 않는다고 명시한다(`docs/decisions/DR-022-plan-lifecycle.md:20`). DR-024 taxonomy는 `recommended`와 `warning`을 hard-stop과 분리하고(`docs/decisions/DR-024-gate-strictness-taxonomy.md:14-16`), causal finalization bundling만 `conditional mandatory + hard-stop/explicit override` 예시로 둔다(`docs/decisions/DR-024-gate-strictness-taxonomy.md:19-24`). | `/close`에서는 "PLAN 영향 있음/없음/후속 필요"를 보고하는 soft step으로 둔다. 단, Work Done Criteria나 승인된 state-change proposal이 PLAN 수정을 이미 요구한 경우에는 T5가 아니라 기존 commit/tracking finalization에서 누락을 막는다. |
| PQ-2: archive-drain 규칙 위치 | **PLAN SSoT + protocol pointer**. 규칙 본문은 `PLAN.md`, trigger 연결은 `HARNESS-PROTOCOL.md`. | DR-022 Consequences는 "PLAN에 archive-drain 규칙이 생긴다"고 한다(`docs/decisions/DR-022-plan-lifecycle.md:38-42`). Protocol은 이미 trigger table과 section deletion checklist를 소유한다(`docs/HARNESS-PROTOCOL.md:417-435`, `:489-496`). Recent Decisions rolling-window처럼 운영 trigger는 protocol에, 보존 정책의 본문은 해당 SSoT에 두는 모델이 맞다(`docs/HARNESS-PROTOCOL.md:496`). | `PLAN.md`에는 "현재+다음 horizon, 닫힌 phase 상세 drain, archive link 유지, L3 근거는 DR" 원칙을 둔다. `HARNESS-PROTOCOL.md`는 T3/STATUS Section Deletion에서 "PLAN lifecycle/archive-drain 규칙 확인" pointer만 둔다. 같은 문장을 양쪽에 복제하지 않는다. |
| PQ-3: AWH↔CHORE roadmap stage 정합 | **(a) AWH-* 유지**를 권장한다. 단, AWH는 roadmap stage label이고 `CHORE-*`는 Work ID라는 층위를 명시한다. | PLAN Roadmap은 현재 `AWH-001~004` stage 표로 되어 있고(`docs/PLAN.md:112-119`), 실제 Work ID 체계는 `CHORE-*`로 진행된다. 이 둘은 같은 namespace가 아니므로 `AWH`를 `CHORE`로 치환하면 stage와 Work unit이 섞인다. | §7 표의 header나 note에 "AWH-*는 roadmap stage, CHORE-*는 실행 Work ID"를 명시한다. 현재 horizon은 Phase 2/CHORE Work 링크로 연결하되, stage label 전체를 descriptive/Phase 체계로 갈아엎지 않는다. |
| PQ-4: PLAN 소생 범위 | **header/§4/§7 + lifecycle rule block만** 손댄다. | PLAN header는 작성일/버전이 `2026-05-22`/`v0.1`로 stale하다(`docs/PLAN.md:1-6`). §4는 `Public baseline / Maintenance` 기준에 머물러 있고(`docs/PLAN.md:57-69`), §7은 `AWH-003/004`에서 정지해 있다(`docs/PLAN.md:112-119`). DR-022도 PLAN 본문 rewrite를 하류로 두되 이번 slice에서 그 하류 적용을 좁게 수행하는 취지다(`docs/decisions/DR-022-plan-lifecycle.md:42`). | §1-3, §5, §6, §8, §9는 이번 slice에서 rewrite하지 않는다. 필요하면 새 lifecycle rule block 또는 §7 note 수준의 최소 문구만 추가한다. |

#### Plan 타당성 및 수정 요청

| 항목 | 판단 | 근거/수정 요청 |
| --- | --- | --- |
| T5 배선이 새 gate 신설이 아닌가 | **조건부 동의** | plan은 "신규 hard gate 신설 없음"을 명시하고 있어 DR-022와 맞다(`docs/works/harness/CHORE-20260605-004-plan-lifecycle-wiring.md:17-22`). 다만 구현 문구에서 `T5 check`를 "필수 작성 완료"가 아니라 "영향 판단 + 필요 시 proposal"로 써야 한다. |
| `/close`와 `/done` 배선 | **수정 조건** | `/close`는 Work Done 처리이며 commit/PR finalization gate를 대체하지 않는다(`.claude/commands/close.md:49-52`). `/done`은 세션 요약만 출력하고 Work Done 처리를 포함하지 않는다(`.claude/commands/done.md:6-9`, `docs/AGENT-WORKFLOW.md:161-162`). 따라서 `/close`에는 Work closeout PLAN impact 확인을 넣고, `/done`에는 session/commit summary에서 PLAN impact 확인 여부를 보고하는 정도로 제한한다. `/done`을 Work closeout gate처럼 만들면 안 된다. |
| 실측 근거 W1 | **보강 요청** | W1은 `T3`와 `T5` 자체도 함께 인용해야 정확하다. 현재 근거는 `:433-435,449-451` 중심인데, `T3`는 `docs/HARNESS-PROTOCOL.md:421`, `T5`는 `:423`, `T15~T17`은 `:433-435`, loop safety는 `:449-451`이다. |
| cascade 범위 | **동의** | command/rule/workflow surface 변경은 T11/T14 성격이라 tool surface mirror 확인이 필요하다(`docs/HARNESS-PROTOCOL.md:429`, `:448`). plan Verification의 `.agents/skills/workflow-close|done`, `.cursor/rules/workflow.mdc`, QUICK-REFERENCE 동기화 확인은 적절하다. |
| scope guard | **동의** | canonical+adapter, command rename, scaffold minimal output을 비목표로 둔 것은 현재 slice의 DR-022 적용 범위를 지킨다(`docs/works/harness/CHORE-20260605-004-plan-lifecycle-wiring.md:19-22`). |

### Codex Result Review (R15)

작성: Codex, 2026-06-05. 이 리뷰는 구현 결과 검토다. 실제 protocol/command/PLAN 수정은 하지 않고, R13 합의와 DR-022/DR-024 정합성 및 PQ-5 방향만 판단한다.

#### Summary

전체 판단은 **조건부 동의**다. A(T5 배선), B(archive-drain), C(PLAN 소생)는 R13 합의와 대체로 정합하다. 특히 `/close`는 Work closeout의 PLAN impact 확인 step을 갖고(`.claude/commands/close.md:49-55`), `/done`은 PLAN impact를 summary에 보고하는 수준으로 제한되어 있다(`.claude/commands/done.md:30`). 이 구분은 `/done`을 closeout gate로 만들지 말라는 R13 조건을 지킨다.

남은 조건은 PQ-5 하나다. copied runtime 문서가 scaffold target에서도 쓰이는 이상, `docs/PLAN.md`의 "Roadmap Lifecycle 규칙"을 하드 섹션 전제로 읽히게 만들면 target product PLAN 템플릿과 soft section dangling이 생긴다(`scripts/create-harness.sh:660-690`). 이번 slice는 source PLAN lifecycle 배선이므로 scaffold PLAN 템플릿 propagate는 하류로 두고, copied 문서 쪽은 `if present` 또는 generic "PLAN lifecycle/drain rule" 참조로 충분히 느슨하게 유지하는 편을 권장한다.

검증 재실행: `scripts/tests/check-scaffold-invariants.sh` PASS, `git diff --check` PASS. 1b invariant는 core DR dangling과 index closure를 잡지만, Roadmap Lifecycle 같은 section-level dangling은 scope 밖이므로 PQ-5 판단이 별도로 필요하다.

#### 구현 결과 검토

| 대상 | 판단 | 근거 | 조건/수정 요청 |
| --- | --- | --- | --- |
| A. T5 배선 soft mode | **동의** | Protocol은 T15/T16/T17, T3, `/close`가 T5를 함께 확인하되 PLAN 영향 있으면 proposal, 없으면 보고만 하며 hard-stop으로 강제하지 않는다고 쓴다(`docs/HARNESS-PROTOCOL.md:452`). `/close`도 recommended/warning soft로 PLAN impact를 판단한다(`.claude/commands/close.md:49-55`, `.agents/skills/workflow-close/SKILL.md:55-59`). DR-024 taxonomy의 `recommended`/`warning`은 `hard-stop`과 분리되어 있다(`docs/decisions/DR-024-gate-strictness-taxonomy.md:14-16`). | 없음. 승인된 PLAN/STATUS/Work state 변경 누락은 T5가 아니라 기존 commit/tracking finalization 문제로 계속 분리한다. |
| `/close` vs `/done` 역할 분리 | **동의** | `/close`는 Work Done 처리이며 commit/PR finalization gate를 대체하지 않는다고 유지되어 있다(`.claude/commands/close.md:57-60`). `/done`은 "보고 수준, closeout gate 아님"이라고 명시한다(`.claude/commands/done.md:30`). Cursor mirror도 `/close`에서만 PLAN impact를 판단하고 `/done`은 Work Done processing을 수행하지 않는다고 유지한다(`.cursor/rules/workflow.mdc:40-42`). | 없음. |
| B. archive-drain SSoT + pointer | **조건부 동의** | PLAN §7-a는 현재+다음 horizon, drain/update/rationale 규칙을 본문으로 두고 SSoT가 이 섹션이라고 명시한다(`docs/PLAN.md:126-134`). Protocol은 trigger pointer만 둔다고 설명하고(`docs/HARNESS-PROTOCOL.md:452`), section-deletion checklist에서 PLAN 상세 drain을 PLAN 규칙으로 위임한다(`docs/HARNESS-PROTOCOL.md:491-494`). | source repo 기준으로는 중복 없이 적절하다. 다만 copied target 문서에서는 section이 없을 수 있으므로 protocol/command mirror의 참조는 "if present" 또는 generic wording으로 유지해야 한다(PQ-5). |
| C. PLAN 소생 범위 | **동의** | PLAN 변경은 header v0.2/lifecycle pointer(`docs/PLAN.md:1-7`), §4 milestone(`docs/PLAN.md:58-72`), §7 roadmap/AWH note/§7-a(`docs/PLAN.md:114-134`)에 한정된다. §1-3, §5, §6, §8 이후 본문 rewrite는 없다. | 없음. |
| AWH stage / CHORE Work ID note | **동의** | PLAN §7은 `AWH-*`가 roadmap stage label이고 `CHORE-YYYYMMDD-NNN`이 실행 Work ID라고 층위를 분리한다(`docs/PLAN.md:114-122`). | 없음. `AWH`를 `CHORE`로 치환하지 않은 처리가 맞다. |
| DR-022/024 provenance 제거 | **동의** | copied runtime 문서에서 `DR-022`/`DR-024` 직접 참조는 제거되어 있다(`rg DR-022|DR-024` 결과: copied protocol/command/skill/cursor/done에는 없음). scaffold 기본 copied DR 집합이 DR-007/008/013/014인 상황에서는 DR-022/024 직접 provenance가 core dangling을 만든다. | provenance는 Work, source PLAN §7-a, DR 파일에 남기는 편이 맞다. copied runtime 문서는 target-operational wording으로 유지한다. |
| PQ-5: scaffold PLAN lifecycle propagation | **조건부 — 이번 slice는 (b)** | scaffold target `docs/PLAN.md`는 Project Initialization Plan 템플릿으로 생성되며 Roadmap Lifecycle 섹션이 없다(`scripts/create-harness.sh:660-690`). 반면 copied protocol/close/cursor 문서는 `docs/PLAN.md` Roadmap Lifecycle 규칙을 참조할 수 있다(`docs/HARNESS-PROTOCOL.md:452`, `.claude/commands/close.md:55`, `.cursor/rules/workflow.mdc:40`). | 이번 slice에서는 scaffold PLAN 템플릿 propagate를 하지 않는다. copied 문서를 `if present`/generic reference로 유지하는 것이 맞다. target PLAN lifecycle 섹션 도입은 DR-022의 OQ-7(target-local harness plan) 또는 scaffold template slice에서 별도 판단한다. |

### Plan-Level Open Questions

| ID | Question | Owner | Status |
| --- | --- | --- | --- |
| CHORE-20260605-004/PQ-1 | T5 배선 enforcement mode(recommended/warning vs hard-stop 후보)? | Codex + Claude | Resolved (R13) — PLAN impact 확인은 recommended/warning soft gate. hard-stop은 승인된 state/tracking 변경 누락의 commit finalization 문제로만 분리 |
| CHORE-20260605-004/PQ-2 | archive-drain 규칙 위치(PLAN vs protocol vs 양쪽 pointer)? | Codex + Claude | Resolved (R13) — PLAN SSoT + protocol T3/section-deletion pointer |
| CHORE-20260605-004/PQ-3 | AWH↔CHORE roadmap stage 정합 방식(AWH 유지 vs descriptive vs Phase{n})? | Codex + Claude | Resolved (R13) — AWH-*는 roadmap stage label로 유지하고 CHORE-* Work ID와 층위 구분 명시 |
| CHORE-20260605-004/PQ-4 | PLAN 소생 범위(header/§4/§7만 vs 확대)? 과잉 rewrite 방지선? | Codex + Claude | Resolved (R13) — header/§4/§7 + lifecycle rule block만 수정. §1-3,5,6,8,9 rewrite 제외 |
| CHORE-20260605-004/PQ-5 | copied runtime 문서가 Roadmap Lifecycle 규칙을 참조할 때, scaffold target PLAN 템플릿에도 lifecycle 섹션을 propagate할지? | Codex + Claude | Resolved (R15) — 이번 slice는 (b) copied 문서 generic/conditional 유지. scaffold PLAN lifecycle propagate는 OQ-7 또는 scaffold template 하류 slice에서 별도 판단 |

### Consensus Log

| Date | Topic | Consensus | Remaining Risk |
| --- | --- | --- | --- |
| 2026-06-05 | R13 plan review | DR-022 적용 plan은 타당. T5는 recommended/warning soft gate로 배선하고, archive-drain은 PLAN SSoT + protocol pointer로 둔다. AWH-*는 roadmap stage label로 유지하되 CHORE-* Work ID와 구분한다. PLAN 소생은 header/§4/§7 + lifecycle rule block로 제한한다. | 구현 시 `/done`을 Work closeout gate처럼 만들거나, archive-drain 본문을 PLAN/protocol 양쪽에 중복 서술하면 SSoT drift 위험 |
| 2026-06-05 | R15 result review | 구현 결과는 R13 합의와 정합. T5는 soft recommended/warning, `/close`는 PLAN impact step, `/done`은 보고 수준. PLAN §7-a가 archive-drain SSoT이고 protocol은 pointer. DR-022/024 provenance 제거는 copied core dangling 방지로 타당. | PQ-5: target scaffold PLAN에는 Roadmap Lifecycle 섹션이 없으므로 copied runtime 문서의 참조는 conditional/generic이어야 한다. lifecycle propagate는 하류 판단 |

## Discovery

- **1b 테스트가 회귀 즉시 포착(2회째 가치 실증):** 초안에서 close.md·HARNESS-PROTOCOL·close skill·cursor에 `DR-022`/`DR-024` provenance를 인용했으나, 이 DR들은 scaffold target 미복사(foundational 007/008/013/014만 복사) → core A-class dangling FAIL. **조치:** copied runtime 문서에서 DR-022/024 인용 제거(provenance는 Work·PLAN §7-a·DR 파일에 보존), `§7-a` 하드 참조 → 이름 기반 "Roadmap Lifecycle 규칙"으로 완화. 재실행 PASS.
- **PQ-5 Resolved (R15) — scaffold PLAN propagation:** copied 문서가 "`docs/PLAN.md`의 Roadmap Lifecycle 규칙"을 참조하나 scaffold-generated target product PLAN 템플릿엔 lifecycle 섹션 부재(soft section dangling — 1b의 DR-NNN-only scope 밖, "if present"로 조건화). **결론:** 이번 slice는 (b) copied 문서 generic/conditional 유지. scaffold PLAN lifecycle propagate는 **OQ-7 또는 scaffold template 하류 slice**에서 별도 판단.
- **검증:** invariants PASS, `git diff --check` clean. AWH-* stage label note 추가됨(`PLAN.md:116`).
