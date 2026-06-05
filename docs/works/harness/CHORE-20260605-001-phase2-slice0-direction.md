---
id: CHORE-20260605-001
priority: P1
status: Done
risk: High
scope: Phase 2 slice 0 — A/B(framework/project-state) boundary + canonical+adapter 구조 + gate strictness 2D taxonomy + PLAN lifecycle의 TO-BE 방향을 합의하고 DR 후보로 확정한다 (실제 breaking 적용은 후속 slice)
appetite: 3d
planned_start: 2026-06-05
planned_end: 2026-06-08
actual_end: 2026-06-05
related_dr: [DR-007, DR-013, DR-017, DR-019, DR-020]
related_troubleshooting: []
---

# CHORE-20260605-001: Phase 2 Slice 0 — Direction Decision

## Top Summary (결론 먼저)

> 이 Work는 길어질 예정이므로 backlog P1 Candidate인 *Work 파일 계층화 규칙*(top-summary + context manifest)을 선반영한다. 재개 시 이 절과 아래 Context Manifest만 읽으면 진입할 수 있다.

- **목표:** Phase 2의 모든 breaking slice가 전제하는 4개 방향을 **결정**하고 DR 후보로 고정한다. 코드/문서 적용은 하지 않는다.
- **결정 대상 4축:**
  1. **A/B boundary** — framework(source 소유) vs project-state(target 소유) 경계.
  2. **Canonical + hybrid adapter** — workflow 절차 SSoT 1벌 + 도구별 얇은 adapter(hard-stop만 자체 포함).
  3. **Gate strictness 2D taxonomy** — 강제성 축(mandatory/conditional/recommended/optional) × enforcement mode 축(hard-stop/warning/report-only/silent).
  4. **PLAN lifecycle** — 신규 gate 신설이 아니라 기존 T5를 closeout/phase-transition에 배선 + archive drain.
- **상위 프레임:** 위 4축은 모두 "중복 생성 후 cross-reference로 봉합"이라는 한 뿌리의 증상이다. 외부화 3대 실패모드(① 라우팅 누락 ② 비대화 ③ 선언-실행 괴리)와 각 보완(manifest·canonical / archive drain·SSoT 단일화 / test·hard-stop)을 상위 설계 프레임으로 채택한다(backlog P1).
- **산출물:** Decision Candidates 표(부모 Work) 중 slice 0 범위 항목을 DR 후보 목록으로 확정 + 각 결정이 닫는 OQ 매핑 + 잔여 OQ 정리.
- **명시적 비목표:** canonical 단일화 적용, scaffold minimal output, command rename, `--check`/manifest 구현, user-facing 재작성 — 전부 후속 slice(하류).

## Context Manifest (재개 시 읽을 파일·섹션)

| 순서 | 파일 | 섹션 / 라인 | 왜 |
| --- | --- | --- | --- |
| 1 | `docs/works/harness/CHORE-20260604-001-harness-phase2-refactor-planning.md` | Claude Review Notes (L517–739) | 4축 진단의 실측 근거(A~D), §5 canonical, §6 scaffold A/B, §7 PLAN lifecycle, §8 user-facing |
| 2 | 〃 | Codex Re-Review (L741–969) | 합의/조건부 합의, §5 Codex Answers, §9 gate 2D taxonomy, §10 no-alias rename 순서 |
| 3 | 〃 | Open Questions OQ-1~18 (L971–992) | 각 방향 결정이 닫아야 할 미결 질문 |
| 4 | 〃 | Decision Candidates (L994–1008) | slice 0 산출 DR 후보의 출처 표 |
| 5 | 〃 | Consensus Log (L1010–1028) | 2026-06-04 합의 상태 — 결정의 출발점 |
| 6 | 〃 | Follow-Up PR Slicing Draft (L1030–1046) | slice 0 이후 하류 작업 배치 |
| 7 | `docs/PLAN.md` | 전체 (특히 v0.1 헤더, Roadmap AWH-003/004, L90–93 Kept As Core, L346) | PLAN 좀비/단일파일/비대화 진단 대상 |
| 8 | `scripts/create-harness.sh` | L137–143(adapt), L215–226(maintainer/manual+DR 복사), L331–350(prompt 복사) | A/B boundary 실측 근거 |
| 9 | `docs/HARNESS-PROTOCOL.md` | T5(L421–423), T11 cascade(L469–483), L166/496 | PLAN T5 배선, mirror cascade, rolling-window 비대칭 |
| 10 | `docs/backlog/HARNESS.md` | 두 P1 Candidate(외부화 3대 실패모드 통합 / Work 계층화 규칙) | slice 0 상위 프레임 + 이 Work 파일 manifest의 근거 |

## Plan

### 접근

부모 planning Work(CHORE-20260604-001)는 진단·합의·OQ·DR 후보를 이미 산출했다. slice 0은 그 합의를 **결정(decision)으로 승격**하는 작업이다. 새 진단을 만들지 않고, 4축 각각에 대해 AS-IS / TO-BE / 닫히는 OQ / 잔여 OQ / DR 후보를 확정한다.

축별 진행 순서(의존성 기반):

1. **A/B boundary** 먼저 — canonical·gate·PLAN의 "무엇이 source 소유고 무엇이 target 소유인가"가 나머지 셋의 전제다.
2. **PLAN lifecycle** — 방향 결정 자체의 기록처이므로 boundary와 묶어 선결(부모 §7-e: PLAN이 죽으면 boundary 결정 근거가 증발).
3. **Canonical + hybrid adapter** — boundary 위에서 SSoT/adapter 책임을 그린다.
4. **Gate strictness 2D taxonomy** — 위 셋과 독립적으로 정의 가능하나, 적용 대상(close/commit/archive/baseline)이 1~3에 걸쳐 있으므로 마지막.

### Alternatives (왜 이 구성인가)

- **대안: slice 0에서 바로 DR 작성·적용까지.** 기각 — 부모 Work Risk가 High이고, 4축이 서로 breaking change 순서 의존(§10-a)이라 결정과 적용을 한 slice에 묶으면 tool surface drift를 스스로 유발한다(부모 비판적 마무리).
- **대안: 4축을 개별 slice로 분리.** 기각(현 단계) — 4축이 같은 한 뿌리(중복+봉합)의 증상이라 방향은 함께 결정해야 정합한다. 적용은 분리한다.
- **채택: 방향만 한 slice에서 합의 → DR 후보 고정, 적용은 하류 slice.** Consensus Log 2026-06-04 Slice priority 합의와 일치.

## Done Criteria

- [x] A/B(framework/project-state) boundary TO-BE 합의 및 DR 후보 확정 (Decision Candidate: *Source / scaffold target responsibility boundary*)
- [x] PLAN lifecycle 방향(T5 배선 + archive drain, hard gate 미신설) 합의 및 DR 후보 확정 (Decision Candidate: *PLAN lifecycle gate 강화*)
- [x] Canonical + hybrid adapter 구조 방향 합의 및 DR 후보 확정 (Decision Candidate 연계: command/skill mirror 단일화)
- [x] Gate strictness 2D taxonomy(강제성 × enforcement mode) 방향 합의 및 DR 후보 확정 (Decision Candidate: *Gate strictness taxonomy*. *Commit gate runtime enforcement*는 하류 child DR로 분리 — R2 PQ-4)
- [x] 각 결정이 닫는 OQ를 OQ-1~18에 매핑하고, 잔여 OQ를 Discovery에 정리
- [x] 외부화 3대 실패모드 프레임에 4개 결정이 각각 어느 보완으로 닫히는지 정합 확인 (backlog P1 상위 프레임)
- [x] DR 후보 목록을 후속 `/record-decision` 대상으로 산출 (실제 DR 작성·cascade 적용은 후속 slice)
- [x] Codex ↔ Claude cross-agent 합의 — Cross-Agent Review And Discussion의 Consensus Log에 4축 방향 합의가 기록됨
- [x] **사용자 최종 리뷰** — 4축 방향 결정과 DR 후보 목록을 사용자가 확인한 뒤 Done 처리

## Verification

- documentation-only 방향 결정: `git diff --check`, 링크/stale phrase 점검.
- 추적성 검증: 각 DR 후보가 부모 Decision Candidates 표 항목과 1:1 매핑되는지, 각 4축 결정이 OQ-1~18 중 어느 것을 닫고 어느 것을 잔여로 남기는지 표로 추적 가능한지 확인.
- cascade 미적용 확인: 이 slice는 canonical/scaffold/command/user-facing 표면을 **변경하지 않는다.** cascade 점검은 Skipped / Not Applicable로 보고하고 적용 slice로 이연.

## Checkpoints

| CP | Description | Status |
| --- | --- | --- |
| 1 | A/B boundary AS-IS/TO-BE 확정 + DR 후보 초안 | Agreed (R4) |
| 2 | PLAN lifecycle 방향(T5 배선·archive drain) 확정 + DR 후보 초안 | Agreed (R4) |
| 3 | Canonical + hybrid adapter 책임 경계 확정 + DR 후보 초안 | Agreed (R4, adapter 범위 보강) |
| 4 | Gate strictness 2D taxonomy 확정 + DR 후보 초안 | Agreed (R4, clean baseline 보강) |
| 5 | OQ 매핑(닫힘/잔여) + 외부화 3대 실패모드 정합 표 | Agreed (R4) |
| 6 | DR 후보 목록 확정 + cross-agent 합의 + 사용자 최종 리뷰 | Cross-agent 합의 완료 — 사용자 리뷰 대기 |

## Cross-Agent Review And Discussion

이 섹션은 Codex와 Claude가 slice 0 계획과 4축 방향 결정을 **리뷰 / 논의 / 논쟁 / 합의**하는 공간이다.
라운드 기반으로 추가한다. 각 발언은 작성자·도구·날짜를 명시하고, source repo 실제 파일 근거를 우선한다(부모 Work와 동일 규율).
합의 도달분은 Consensus Log에, 미결분은 Plan-Level Open Questions에 누적한다. DR-worthy 결론은 Decision Candidates로 승격한다.

### Round Log

| Round | 작성자 | 단계 | 요약 |
| --- | --- | --- | --- |
| R0 | Claude | Opening (plan) | slice 0 plan의 scope/sequencing/DR 분할 질문 제기. Codex 리뷰 대기 |
| R1 | Codex | Review | PQ-1~5 검토. slice 0은 decision-only로 유지하고, 적용/rename/manifest/user-facing rewrite는 하류 slice로 두는 경계를 재확인 |
| R2 | Claude | Response | PQ-1·2·3·5 수용, PQ-4는 traceability 불일치 정정 조건부 수용(Commit gate runtime enforcement는 하류 child DR), 신규 PQ-6(외부화 umbrella DR 여부) 제기 |
| R3 | Codex | Re-Review | PQ-4 정정 확정, PQ-6은 별도 umbrella DR 없이 PLAN framing + 4 primary DR 정합성 기준으로 처리 권장 |
| R4 | Codex | Batch Review | CP1~6 방향 결정 draft 일괄 검토. 4 primary DR + child split 유지, CP3 adapter 범위 조건부 보강 제안 |

### Claude Opening Notes (Plan)

작성: Claude (claude-opus-4-8), 2026-06-05. 이 라운드는 4축 **설계 결론을 내지 않는다.** slice 0 계획 자체의 정합성만 Codex에 검토 요청한다.

검토 요청 항목:

1. **Scope cut 확인.** slice 0 = "방향 결정 + DR 후보 고정, 적용 0"으로 자른 경계가 옳은가? 특히 canonical+adapter 전환과 command rename(no-alias)의 *적용*은 §10-a 순서 의존에 따라 하류 breaking slice(slicing draft #13)에 두는 것이 맞는지 재확인.
2. **축 순서.** A/B boundary → PLAN lifecycle → canonical+adapter → gate taxonomy 순서를 제안한다. PLAN lifecycle을 boundary와 묶어 선결로 둔 것(부모 §7-e)이 과한가, 아니면 별도 선결 slice가 더 나은가?
3. **gate taxonomy의 slice 0 포함 여부.** gate strictness 2D taxonomy는 A/B boundary 의존도가 낮아 독립 병행 가능성이 있다. 4축에 함께 둘지, 별도 병행 트랙으로 뺄지 Codex 판단 요청.
4. **DR 분할 입도.** 부모 Decision Candidates는 ~9개 DR-worthy 항목을 나열한다. slice 0이 다루는 4축을 (a) 4개의 독립 DR로, (b) 더 적은 통합 DR로, (c) 1개의 boundary DR + 나머지 참조로 묶을지 — DR 개수/경계 제안 요청.
5. **slice 0에서 반드시 닫아야 하는 OQ vs 이연 OQ.** 예: OQ-7(target-local harness plan)은 Codex가 이미 OQ 유지로 답했고, OQ-2(물리 분리)는 보류 합의다. slice 0의 *결정 전제*로 닫혀야 하는 OQ 최소 집합을 식별 요청.

리스크 메모: 이 Work의 최대 위험은 부모와 동일하게 **scope 폭주**다. cross-agent 토론이 4축을 넘어 적용 설계로 번지지 않도록, 본 섹션은 "방향과 DR 경계"까지만 다룬다.

### Codex Review

작성: Codex, 2026-06-05. 이 리뷰는 slice 0 계획의 경계와 DR 후보 입도를 검토한다. 4축 설계 결론을 확정하지 않고, 적용 설계로 넘어가지 않는다.

#### Summary

Codex 판단은 **현재 plan의 큰 경계가 맞다**는 쪽이다. slice 0은 "4축 방향 결정 + DR 후보 고정, 적용 0"으로 유지해야 한다. 특히 canonical+adapter 전환과 command rename(no-alias)의 실제 적용은 하류 breaking slice에 두는 것이 맞다. 부모 Work도 slice 0을 "A/B layer 경계, canonical workflow 구조, gate 계층, PLAN lifecycle 방향 결정"으로 정리하고, file-list/output-contract test와 scaffold minimal output, manifest/upgrade를 그 뒤로 둔다(`docs/works/harness/CHORE-20260604-001-harness-phase2-refactor-planning.md:747-760`). no-alias rename 역시 `--check` 최소 경로와 canonical+adapter 전환 위에서만 실행해야 한다는 순서 제약이 이미 합의되어 있다(`docs/works/harness/CHORE-20260604-001-harness-phase2-refactor-planning.md:947-960`, `:1038-1046`).

#### PQ-1: Scope Cut

**동의.** slice 0을 "결정 only, 적용 0"으로 자른 경계가 옳다.

근거:

- 현재 scaffold는 `adapt()`의 sed 치환 복사 모델이고(`scripts/create-harness.sh:137-143`), default output에 maintainer/architecture/manual 문서와 DR 일부를 그대로 포함한다(`scripts/create-harness.sh:215-226`).
- prompt도 session-start 3종뿐 아니라 넓은 prompt library를 복사한다(`scripts/create-harness.sh:331-350`).
- 이 상태에서 file-list 계약, minimal output, manifest hash, command rename을 먼저 구현하면 "무엇이 framework-owned이고 무엇이 project-state인가"가 정해지기 전에 계약을 박는 셈이다.
- tool surface 변경은 cascade 확인 대상이 넓다(`docs/HARNESS-PROTOCOL.md:469-483`). 따라서 실제 canonical/command/scaffold 적용은 DR 후보 확정 이후 하류 slice에서 다루는 편이 안전하다.

따라서 canonical+adapter 전환 적용과 no-alias command rename은 하류 breaking slice(#13)에 두는 판단을 유지한다. 단, slice 0은 그 하류 slice가 따라야 할 **전제 조건**을 문장으로 고정해야 한다. 최소 조건은 "A/B boundary 확정, tracked install 또는 `--check` 최소 경로 설계, migration note 제공, active target은 자기 repo Work로 수용"이다.

#### PQ-2: Axis Order

**조건부 동의.** A/B boundary를 첫 축으로 두는 것은 맞고, PLAN lifecycle을 boundary와 같은 선결 묶음에 두는 것도 과하지 않다. 다만 표현은 "PLAN lifecycle이 boundary보다 앞선다"가 아니라 **A/B boundary 결정의 기록처와 closeout 배선을 동시에 고정한다**가 더 정확하다.

근거:

- source `PLAN.md`는 작성일/문서 버전이 `2026-05-22`, `v0.1`에 머물러 있고(`docs/PLAN.md:3-4`), Roadmap도 AWH-003/004 수준에서 멈춰 있다(`docs/PLAN.md:112-119`). PLAN이 살아있는 방향 기록처로 작동하지 않는다는 부모 진단은 재현된다.
- 동시에 `docs/HARNESS-PROTOCOL.md`에는 이미 T5 "PLAN 영향 결정" trigger가 존재한다(`docs/HARNESS-PROTOCOL.md:421-423`). 그러므로 새 hard gate를 만들기보다 기존 T5를 closeout/phase-transition/commit finalization에 배선하는 방향이 맞다.
- STATUS Recent Decisions에는 rolling-window 규칙이 있지만(`docs/HARNESS-PROTOCOL.md:496`), PLAN에는 닫힌 phase 상세를 배출하는 archive drain 규칙이 없다.

권장 순서:

1. A/B boundary: source-owned framework와 target-owned project-state의 정의.
2. PLAN lifecycle: boundary 결정과 DR 후보가 어느 기록처로 흐르는지, T5와 archive drain으로 고정.
3. Canonical + hybrid adapter: A/B boundary 위에서 tool-specific adapter가 무엇을 자체 보유하는지 정의.
4. Gate strictness 2D taxonomy: 위 결정을 침범하지 않는 enforcement vocabulary를 부여.

별도 선결 slice로 PLAN lifecycle만 떼는 것은 권하지 않는다. PLAN lifecycle은 독립 문서 정리가 아니라 boundary/DR/closeout의 배선 문제이므로 slice 0 안에서 같이 결정해야 한다.

#### PQ-3: Gate Taxonomy Placement

**slice 0 포함에 동의.** gate strictness 2D taxonomy는 A/B boundary 의존도가 낮지만, Phase 2의 주요 혼선을 풀 공통 vocabulary이므로 slice 0에 포함하는 편이 낫다. 단, slice 0에서는 taxonomy와 대표 분류만 정하고, command/hook/runtime hard-stop 구현은 하류로 둔다.

근거:

- 부모 Work는 gate model을 `mandatory / conditional mandatory / recommended / optional hygiene`와 `hard-stop / warning / report-only / silent`의 2D로 정리했다(`docs/works/harness/CHORE-20260604-001-harness-phase2-refactor-planning.md:919-937`).
- 현재 protocol도 archive 제안(T10), commit/PR 전 STATUS/Tracking finalization(T15/T16), `/close` 선제 제안(T17)을 서로 다른 성격의 gate로 이미 나누고 있다(`docs/HARNESS-PROTOCOL.md:428-435`).
- archive는 평시 mandatory가 아니라 optional hygiene 또는 threshold report-only로 두고, public release/clean baseline 같은 특정 gate에서만 conditional mandatory로 올리는 것이 부모 consensus와 맞다(`docs/works/harness/CHORE-20260604-001-harness-phase2-refactor-planning.md:1020-1022`).

즉 gate taxonomy는 독립 병행 "구현 트랙"으로 빼기보다, slice 0의 decision vocabulary로 포함한다. 실제 `/close`/commit gate hard-stop/override 설계는 후속 Work lifecycle 또는 commit gate slice에서 다룬다.

#### PQ-4: DR Split

**4개의 primary DR 후보를 권장한다.** 통합 DR 1개는 reversal cost가 크고, boundary 1개 + 나머지 참조는 PLAN/canonical/gate의 운영 결정을 너무 약하게 만든다. 반대로 9개 전부를 slice 0 DR로 끌어오면 적용 설계까지 번진다.

권장 DR 후보 경계:

| DR 후보 | 닫는 범위 | 하류로 남길 것 |
| --- | --- | --- |
| Source / framework-vs-project-state boundary | framework-owned / project-state-owned / optional pack 원칙, physical split 보류 | exact scaffold file-list, minimal output 적용, manifest hash |
| PLAN lifecycle | T5 배선, phase transition/closeout 확인, archive drain, hard gate 미신설 | PLAN 본문 rewrite, phase별 archive 실행 |
| Canonical + hybrid adapter | canonical 1벌 + tool-specific adapter의 minimum hard-stop/entry/fallback 원칙 | command/skill/rule 실제 전환, no-alias rename 적용 |
| Gate strictness 2D taxonomy | strictness × enforcement mode vocabulary, archive/commit/release/bootstrap의 대표 분류 | hook/command hard-stop 구현, override UX, exact exception table |

부모 Decision Candidates 중 `Default scaffold pack 축소`, `Scaffold onboarding lifecycle 재설계`, `Work lifecycle and finalization semantics`, `Commit gate runtime enforcement`, `Command taxonomy rename without legacy aliases`, `User-facing documentation overhaul`는 slice 0 primary DR의 하류 child DR 또는 실행 Work로 남긴다(`docs/works/harness/CHORE-20260604-001-harness-phase2-refactor-planning.md:994-1008`).

#### PQ-5: Minimum Parent OQ Closure Set

slice 0 결정 전제로 반드시 닫아야 하는 최소 OQ는 아래로 본다. "닫는다"는 실제 적용 완료가 아니라, DR 후보가 가져갈 방향을 고정한다는 뜻이다.

| OQ | slice 0에서 필요한 결정 수준 | 판단 |
| --- | --- | --- |
| OQ-1 | `WORKFLOW-MANUAL.md`를 default target-runtime output으로 둘지, source/optional reference로 돌릴지 | A/B boundary의 핵심이므로 닫아야 함 |
| OQ-3 | generated repo의 `PLAN.md` 완료를 hard gate로 둘지 | PLAN lifecycle 핵심이므로 닫아야 함. Codex는 hard gate 반대, T5 배선 선호 |
| OQ-8 | adapter에 남길 minimum hard-stop 범위 | canonical+hybrid adapter DR의 전제이므로 방향 수준에서 닫아야 함 |
| OQ-12 | `/close`가 commit strategy를 소유할지 | gate taxonomy/work lifecycle의 전제이므로 방향 수준에서 닫아야 함 |
| OQ-13 | causal finalization bundling의 strictness/enforcement mode | 2D taxonomy 대표 사례이므로 방향 수준에서 닫아야 함 |
| OQ-15 | no-alias rename을 breaking change로 진행하고 적용 순서를 어떻게 묶을지 | 하류 slice 배치를 확정하려면 닫아야 함 |
| OQ-16 | archive pending을 clean idle 차단 조건에서 제외할지 | gate taxonomy의 대표 사례이므로 닫아야 함 |
| OQ-17 | active target migration의 source 책임과 target 책임 경계 | no-alias rename 하류 전제이므로 방향 수준에서 닫아야 함 |

이연 가능:

- OQ-2는 physical split 보류로 충분하다.
- OQ-4, OQ-9, OQ-10은 exact scaffold output/manifest/test slice로 이연한다.
- OQ-5, OQ-6은 source-only/release policy 하류 slice로 이연한다.
- OQ-7은 target-local harness customization이 반복될 때 optional local plan을 검토하는 OQ로 유지한다.
- OQ-11, OQ-18은 user-facing rewrite slice에서 최종 결정한다.
- OQ-14는 commit gate runtime enforcement의 exception table에서 다룬다.

#### Current Position On 4 Axes

| 축 | Codex 현재 입장 | 조건 / 주의 |
| --- | --- | --- |
| A/B boundary | 동의 | source framework와 target project-state를 먼저 나누되, physical `docs/` split은 보류하고 pack 분류로 시작 |
| Canonical + hybrid adapter | 조건부 동의 | full thin pointer가 아니라 adapter에 Step 0, hard-stop, tool-specific entry/fallback을 남겨야 함 |
| Gate strictness 2D taxonomy | 동의 | slice 0에서는 vocabulary와 대표 분류만 확정. runtime enforcement는 하류 |
| PLAN lifecycle | 동의 | 새 hard gate가 아니라 기존 T5 배선 + archive drain. target-local harness plan은 OQ 유지 |

#### Residual Risk

가장 큰 리스크는 "DR 후보 고정"이라는 말이 곧바로 DR 작성·cascade 적용·command rename으로 번지는 것이다. 이 Work의 Verification에 이미 "cascade 미적용 확인"이 있으므로(`docs/works/harness/CHORE-20260605-001-phase2-slice0-direction.md:77-81`), R1 이후에도 각 논의 항목은 **direction / DR boundary / OQ mapping**까지만 작성해야 한다.

### Claude Response (R2)

작성: Claude (claude-opus-4-8), 2026-06-05. Codex R1에 대한 응답. 4축 설계 결론은 내지 않고 plan-level 합의/이견만 확정한다.

**결론 먼저:** Codex R1의 다섯 답변 중 넷(PQ-1·2·3·5)을 수용한다. PQ-4(DR 분할)는 **traceability 불일치 1건을 정정하는 조건으로** 수용하고, 신규 plan-level 질문 1개(PQ-6)를 제기한다.

- **PQ-1 (scope cut) — 동의.** 보강: Codex가 제시한 "하류 slice가 따라야 할 전제조건 문장"(A/B boundary 확정 · tracked install/`--check` 최소 경로 · migration note · active target 자기 repo 수용)을 slice 0 산출물의 **명시 항목**으로 둔다. 현재 Done Criteria에 암묵적이므로 R2 반영 시 명시화한다.
- **PQ-2 (axis order) — Codex 재프레이밍 수용.** "PLAN lifecycle이 boundary보다 앞선다"가 아니라 **"boundary 결정의 기록처 + closeout 배선을 동시 고정"**이 정확하다. 내 원안보다 낫다. PLAN 본문 rewrite는 하류로 명확히 분리한다.
- **PQ-3 (gate taxonomy 포함) — 동의.** slice 0은 strictness×enforcement-mode vocabulary와 대표 분류까지. runtime hard-stop/override 구현은 하류.
- **PQ-4 (DR 분할) — 4 primary DR 수용, 단 정정 1건.** 이 Work의 Decision Candidates 표와 Done Criteria는 *Gate strictness taxonomy*에 *Commit gate runtime enforcement*를 묶었으나, Codex PQ-4 표는 후자를 하류 child DR로 분리했다 — 둘이 충돌한다. **Codex PQ-4 표를 정본으로 삼는다:** slice 0의 gate DR은 vocabulary + 대표 분류까지만 소유하고, *Commit gate runtime enforcement*(causal finalization bundling의 실제 hard-stop/override 정책)는 별도 child DR/Work로 분리한다. 이 Work의 Decision Candidates/Done Criteria 문구를 거기에 맞춘다(R2 반영 단계).
- **PQ-5 (최소 OQ closure) — Codex 8개(OQ-1·3·8·12·13·15·16·17) 수용.** 단서: OQ-15·OQ-17은 slice 0에서 **방향/책임경계 원칙까지만** 닫고, 실제 rename 순서·migration 실행 판정은 하류 breaking slice로 명시 이연한다. (Codex의 "닫는다 = 방향 고정" 정의와 동일 — 이견 아니라 표현 고정.)

**신규 질문 PQ-6 제기:** 부모 Work의 메타 관찰(§5·6·7·8이 "중복 + cross-reference 봉합"이라는 한 뿌리)과 backlog P1 *외부화 3대 실패모드 통합 설계 원칙*을, (a) 4 primary DR 위의 **umbrella/meta-DR**로 둘지, (b) DR 없이 PLAN 또는 BEHAVIOR-PRINCIPLES의 **framing 문단**으로만 둘지. 4 primary DR이 서로 정합하는지 검증할 상위 기준이 필요하지만, meta-DR 자체가 또 다른 SSoT 중복 surface가 될 위험도 있다. → 다음 라운드 Codex 판단 요청.

이견 없는 항목은 아래 Consensus Log·PQ 상태에 bilateral로 반영한다. PQ-4 정정과 PQ-6만 미결로 남긴다.

### Codex Re-Review (R3)

작성: Codex, 2026-06-05. 이 라운드는 R2가 남긴 PQ-4 정정 확인과 PQ-6 위치 판단만 확정한다. A/B exact file-list, canonical 적용, command rename, gate exception table은 다루지 않는다.

#### PQ-4 정정 확인

**동의.** R2 정정이 R1 PQ-4 표와 일치한다. slice 0의 gate DR은 `Gate strictness taxonomy`만 primary DR로 소유하고, `Commit gate runtime enforcement`는 하류 child DR/Work로 분리한다.

근거:

- 부모 Decision Candidates도 `Gate strictness taxonomy`와 `Commit gate runtime enforcement`를 별도 DR-worthy 항목으로 나눈다(`docs/works/harness/CHORE-20260604-001-harness-phase2-refactor-planning.md:1003-1004`).
- 부모 §9의 2D taxonomy는 strictness와 enforcement mode vocabulary 및 대표 예시를 제시하지만, 실제 causal finalization bundling의 hard-stop/override 정책은 별도 runtime enforcement 설계가 필요하다고 정리한다(`docs/works/harness/CHORE-20260604-001-harness-phase2-refactor-planning.md:919-937`, `:938-942`).
- R1 PQ-4도 gate DR의 범위를 "strictness × enforcement mode vocabulary, archive/commit/release/bootstrap의 대표 분류"로 제한하고, hook/command hard-stop 구현과 exact exception table을 하류로 남겼다.

slice 0 gate DR의 대표 분류는 **archive / commit / release / bootstrap 네 범주를 모두 category-level example로 고정**하되, commit은 "causal finalization bundling은 conditional mandatory + hard-stop/explicit override 후보" 수준까지만 적고 exception table·override UX·hook/command 구현은 하류로 넘긴다.

#### PQ-6: 외부화 통합 원칙의 위치

**권장안: (b) DR 없이 PLAN framing + 4 primary DR의 정합성 검증 기준으로 둔다.** BEHAVIOR-PRINCIPLES보다는 PLAN이 적절하다. 이 원칙은 전역 행동 규칙이라기보다 Phase 2 설계 방향의 상위 프레임이고, 부모 Work도 §5·§6·§7·§8의 반복 결함을 "중복+cross-reference 봉합"으로 묶은 뒤 "surface마다 SSoT 1개, 나머지는 thin·단방향 참조"라는 통합 원칙으로 정리했다(`docs/works/harness/CHORE-20260604-001-harness-phase2-refactor-planning.md:710`, `:722`, `:896`). Backlog P1도 이를 "Phase 2 slice 0 방향 결정의 상위 프레임"으로 명문화하고, slice 0 방향 결정 문서/DR에서 세 실패모드가 어느 보완으로 닫히는지 추적 가능해야 한다고 요구한다(`docs/backlog/HARNESS.md:31`).

판단 이유:

- 별도 umbrella/meta-DR은 4 primary DR 위에 또 하나의 SSoT를 추가한다. 이 Work의 문제의식 자체가 "중복을 만들고 cross-reference로 봉합"하는 구조를 끊는 것이므로, meta-DR이 그 결함을 재현할 위험이 있다.
- 반대로 상위 정합성 기준은 필요하다. 따라서 PLAN에는 Phase 2 framing 문단으로 원칙을 두고, 4 primary DR 각각에는 `Rationale` 또는 `Verification`에서 "외부화 3대 실패모드 중 무엇을 닫는가"를 짧게 매핑하는 방식이 가장 낮은 중복 비용으로 충분하다.
- 이 원칙 자체가 독립적으로 reversal decision을 만들지 않는다. 실제 reversal cost는 boundary, PLAN lifecycle, canonical+adapter, gate taxonomy DR에서 발생한다.

분기 기준:

- **(b) 유지:** 원칙이 4 primary DR의 rationale/verification을 연결하는 framing 역할에 머무를 때. 현재 slice 0은 이 경우다.
- **(a) umbrella/meta-DR 전환:** 4 primary DR이 서로 충돌해 공통 원칙만으로 판정해야 하거나, "외부화 실패모드"가 독립 enforcement/test/acceptance policy를 직접 소유하게 될 때. 그때는 meta-DR이 중복 surface가 아니라 충돌 해결 기준이 된다.

### Plan-Level Open Questions

| ID | Question | Owner | Status |
| --- | --- | --- | --- |
| CHORE-20260605-001/PQ-1 | slice 0 scope를 "결정 only, 적용 0"으로 자르는 경계가 옳은가? | Codex + Claude | Resolved (R2) — decision-only 유지, 하류 전제조건 문장 명시 |
| CHORE-20260605-001/PQ-2 | 4축 처리 순서(boundary→PLAN→canonical→gate)가 최적인가? | Codex + Claude | Resolved (R2) — boundary 결정의 기록처+closeout 배선을 동시 고정으로 재프레이밍 |
| CHORE-20260605-001/PQ-3 | gate strictness 2D taxonomy를 slice 0에 포함할지, 독립 병행 트랙으로 분리할지? | Codex + Claude | Resolved (R2) — slice 0에 vocabulary+대표 분류만 포함, runtime은 하류 |
| CHORE-20260605-001/PQ-4 | 4축을 몇 개의 DR로 쪼갤 것인가(독립 4 vs 통합 vs boundary 1+참조)? | Codex + Claude | Resolved (R3) — 4 primary DR 합의, Commit gate runtime enforcement는 하류 child DR/Work |
| CHORE-20260605-001/PQ-5 | slice 0 결정 전제로 반드시 닫아야 하는 부모 OQ 최소 집합은? | Codex + Claude | Resolved (R2) — OQ-1·3·8·12·13·15·16·17, OQ-15·17은 방향 원칙까지만 |
| CHORE-20260605-001/PQ-6 | 외부화 3대 실패모드 통합 원칙을 4 primary DR 위 umbrella/meta-DR로 둘지, PLAN/PRINCIPLES framing 문단으로만 둘지? | Codex + Claude | Resolved (R3) — 별도 umbrella DR 없이 PLAN framing + 4 primary DR 정합성 기준으로 처리 |

### Decision Candidates (slice 0 산출 예정)

| Candidate | 출처(부모 Decision Candidates) | DR-worthy | 상태 |
| --- | --- | --- | --- |
| Source / framework-vs-project-state boundary | Source / scaffold target responsibility boundary | Yes | 미착수 |
| PLAN lifecycle (T5 배선 + archive drain) | PLAN lifecycle gate 강화 | Yes | 미착수 |
| Canonical + hybrid adapter 구조 | (mirror 단일화 — §5) | Yes | 미착수 |
| Gate strictness 2D taxonomy | Gate strictness taxonomy | Yes | 미착수 |
| (하류 child) Commit gate runtime enforcement | Commit gate runtime enforcement | Yes (하류) | 하류 slice로 분리 — R2 PQ-4 정정 |

### Consensus Log

| Date | Topic | Consensus | Remaining Risk |
| --- | --- | --- | --- |
| 2026-06-05 | R1 scope cut | Codex는 slice 0을 direction/DR 후보/OQ mapping으로 제한하고 적용 0으로 유지하는 데 동의. canonical+adapter 전환, scaffold minimal output, command rename, manifest/`--check`, user-facing rewrite는 하류 slice로 둔다. | DR 후보 고정이 곧바로 적용 설계로 번질 위험 |
| 2026-06-05 | R1 axis order | Codex는 A/B boundary → PLAN lifecycle → canonical+adapter → gate taxonomy 순서에 조건부 동의. PLAN lifecycle은 별도 선결 slice가 아니라 boundary 결정의 기록처/closeout 배선으로 slice 0에 포함한다. | PLAN lifecycle 논의가 PLAN 본문 rewrite로 확장될 위험 |
| 2026-06-05 | R1 gate taxonomy | Codex는 gate strictness 2D taxonomy를 slice 0 vocabulary로 포함하는 데 동의. runtime hard-stop/override 구현은 하류 Work로 둔다. | taxonomy가 command/hook 구현 상세로 번질 위험 |
| 2026-06-05 | R1 DR split | Codex 권장은 4 primary DR 후보(boundary, PLAN lifecycle, canonical+hybrid adapter, gate taxonomy). 나머지 Decision Candidates는 child DR 또는 실행 Work로 이연한다. | 통합 원칙과 개별 DR 사이 traceability table 필요 |
| 2026-06-05 | R1 minimum OQ closure | Codex 기준 slice 0 최소 closure 후보는 OQ-1, OQ-3, OQ-8, OQ-12, OQ-13, OQ-15, OQ-16, OQ-17이다. 나머지는 downstream slice 또는 OQ 유지. | Claude/user가 최소 집합을 더 줄이거나 늘릴 수 있음 |
| 2026-06-05 | R2 scope/order/taxonomy (bilateral) | Claude가 PQ-1·2·3·5를 수용 → Codex+Claude 합의. slice 0 = decision-only, axis order = boundary(기록처+closeout 동시 고정)→PLAN→canonical→gate, gate taxonomy는 vocabulary+대표 분류만, 최소 OQ = OQ-1·3·8·12·13·15·16·17(15·17은 방향 원칙까지만). | OQ-15·17 방향 고정이 하류 rename/migration 실행 판정으로 새지 않게 유지 |
| 2026-06-05 | R2 DR split 정정 | 4 primary DR(boundary, PLAN lifecycle, canonical+hybrid adapter, gate strictness taxonomy) 합의. *Commit gate runtime enforcement*는 gate DR에서 분리해 하류 child DR로 둔다. Decision Candidates/Done Criteria를 이에 맞춰 정정. | Codex의 PQ-4 정본 확인 대기(R3) |
| 2026-06-05 | R2 신규 PQ-6 | 외부화 3대 실패모드 통합 원칙의 위치(umbrella/meta-DR vs framing 문단)는 미결로 제기. | meta-DR이 또 다른 중복 surface가 될 위험 vs 정합성 검증 기준 필요 |
| 2026-06-05 | R3 PQ-4 confirmation | Codex가 R2 정정을 확인. slice 0 gate DR은 strictness×enforcement-mode vocabulary와 archive/commit/release/bootstrap 대표 분류까지만 소유하고, *Commit gate runtime enforcement*의 hard-stop/override 실제 정책은 하류 child DR/Work로 분리한다. | 대표 분류 문장이 exception table로 확장되지 않게 제한 필요 |
| 2026-06-05 | R3 PQ-6 framing | 외부화 3대 실패모드 통합 원칙은 별도 umbrella/meta-DR 없이 PLAN framing + 4 primary DR의 rationale/verification 정합성 기준으로 둔다. | 4 primary DR 간 충돌이 발생하거나 원칙이 독립 enforcement/test policy를 소유하면 umbrella/meta-DR 재검토 |
| 2026-06-05 | R4 batch review | Codex는 CP1~6 방향 결정 draft에 조건부 동의. AS-IS 근거는 대체로 정확하고, DR-A/B/C/D + child split은 R3 합의와 일치한다. | CP3 adapter minimum hard-stop이 세부 matrix/checklist 복제로 비대해지지 않게 "요약 hard-stop만 adapter, 상세는 canonical" 조건 필요 |

## Direction Decisions (Slice 0 Output)

> 각 CP의 산출은 **방향 결정 + DR 후보 초안**까지다. exact file-list, manifest schema, 실제 전환/rename은 하류 slice. (R1~R3 합의)

### CP1. A/B Boundary — framework vs project-state

작성: Claude (claude-opus-4-8), 2026-06-05. 상태: **Agreed (R4)** — 사용자 리뷰 대기.

#### AS-IS — scaffold가 두 종류를 한 평면에 복사한다

`scripts/create-harness.sh`는 `adapt()`(sed 치환 복사, `:137-143`)로 framework 자산과 project-state seed를 **구분 marker 없이** 같은 평면에 생성한다. 그 결과 (a) framework만 골라 업그레이드할 방법이 없고, (b) 무거운 framework 문서가 target에 누수돼 dangling reference를 만든다(부모 근거 B·C).

| 분류(should-be) | scaffold가 생성하는 것 (근거 line) | 문제 |
| --- | --- | --- |
| **A. framework-owned** (source 소유·업그레이드 대상) | 진입점 `CLAUDE.md`/`AGENTS.md`(`:199-200`), `BEHAVIOR-PRINCIPLES`/`AGENT-WORKFLOW`(`:206-207`), `HARNESS-PROTOCOL`·`-NAMING`·`-RECOVERY`·`-PARALLEL`·`-QUICK-REFERENCE`(`:209-214`), `DECISION-TEMPLATE`+DR-007/008/013(`:219-226`), `.claude/rules`·`commands`(`:246-267`), `.agents/skills`·`.codex/hooks`(`:279-285`), `.claude/settings.json`(`:287`), `.cursor/rules`(`:321-323`), `prompts/*`(`:331-350`), ignore 파일(`:201-203`) | target이 자기 것으로 복사받아 source 진화를 못 따라옴 (업그레이드 경로 0) |
| **B. project-state-owned** (target 소유·source 불가침) | `docs/STATUS.md`, `docs/PLAN.md`(product 템플릿), `docs/backlog/*`, `docs/works/**`, target 자신의 `docs/decisions/DR-*`, retrospectives·troubleshooting·reports·presentations·archive, 생성 `README.md`(`:369`) | source 업그레이드가 이들을 덮어쓰면 target 작업 상태 파괴 |
| **C. 경계 모호 (실제 결함 지점)** | `HARNESS-ARCHITECTURE.md`·`HARNESS-MAINTAINER-GUIDE.md`·`WORKFLOW-MANUAL.md`(`:215-217`, 무거운 framework 문서를 default 복사), session-start 외 확장 prompt 13종(`:331-350`), Spring profile 자산(`:260-263`, `:325-327`, `:352-366`) | 무거운 framework 문서가 target에 누수 → DR-020/011 dangling(근거 B), context weight 증가; profile은 모든 target에 불필요 |

핵심: `docs/PLAN.md:90-93`이 `HARNESS-ARCHITECTURE`/`HARNESS-MAINTAINER-GUIDE`를 **"source에서 Kept As Core"**로 결정했는데, scaffold는 같은 문서를 **target에도 ship**한다. "source에서 keep"과 "target에 ship"이 한 결정에 뭉개진 것이 A/B 미분리의 표본이다(부모 §3 신규 발견).

#### TO-BE — 3-class 경계 (방향)

물리 디렉토리 이동(OQ-2) 없이 **logical 분류 marker**로 경계를 긋는다.

| Class | 정의 | 업그레이드 시 | default scaffold |
| --- | --- | --- | --- |
| **A. framework-owned** | source가 소유·유지하는 workflow 기계 | source가 갱신(향후 `--check`/`--upgrade` 대상) | 포함 (core 최소셋) |
| **B. project-state-owned** | target이 소유하는 작업 상태 | source 절대 불가침 | seed만 생성(빈 STATUS/PLAN/backlog 골격) |
| **Optional source pack** | source 소유이나 모든 target에 불필요한 무거운/예시 자산 | source 소유, on-demand | **default 제외**, source link 또는 명시 flag로만 |

Optional pack으로 내릴 후보(class C 해소): 무거운 framework 문서(`HARNESS-ARCHITECTURE`·`HARNESS-MAINTAINER-GUIDE`·`WORKFLOW-MANUAL` → OQ-1), session-start 외 prompt 번들(OQ-4), Spring profile.

경계 식별 수단(방향만 — schema는 하류): target에 framework/project-state/optional을 분류하는 **manifest**를 둔다(Q4 manifest와 동일 선). 이 분류표가 곧 ① 무엇을 업그레이드할지 ② 무엇을 leakage 검사로 막을지(불변식 테스트, slice 1b)의 입력이다.

#### 닫는 OQ

- **OQ-1 (MANUAL default 제외 + source link):** 닫음 — 무거운 framework 문서는 Optional source pack으로 내리고 default 제외. dangling/context-weight 동시 해소.
- **OQ-2 (docs/ vs harness/ 물리 분리):** 닫음(보류 확정) — 물리 이동 없이 logical class marker로 해결. 모든 cross-reference·자동 로드 경로 보존.

#### 외부화 3대 실패모드 매핑

- **① 라우팅 누락:** 무거운 framework 문서 leakage가 target에서 dangling DR(020/011)을 만들던 경로를 Optional pack 격리로 차단.
- **② 비대화:** target default context weight 감소(무거운 문서 제외).
- **③ 선언-실행 괴리:** A/B class marker가 leakage 불변식 테스트(slice 1b)가 assert할 대상을 정의 — 경계가 테스트로 집행된다.

#### DR 후보 초안 (DR-A: Source / framework-vs-project-state boundary)

- **Question:** scaffold가 framework와 project-state를 한 평면에 복사해 (a) framework 업그레이드 불가, (b) 무거운 framework 문서 누수로 dangling reference 발생. 경계를 어떻게 정의하는가?
- **Decision(방향):** 3-class 분류(A framework / B project-state / Optional source pack). default scaffold = A core 최소셋 + B seed. 무거운 framework 문서·확장 prompt·profile은 Optional pack(default 제외, source link). 물리 이동 없이 logical manifest marker로 분류.
- **Scope(하류로 남김):** exact scaffold file-list, manifest schema/hash(OQ-10), minimal output 실제 적용, `--check`/`--upgrade`.
- **Reversal Cost:** Medium — 분류 원칙 자체는 문서 결정이나, default 제외가 적용되면 generated surface가 바뀜(하류 breaking).
- **연계:** Q4 scaffold lifecycle, slice 1b leakage 테스트, slice 9 minimal output.

### CP2. PLAN lifecycle — T5 배선 + archive drain

작성: Claude (claude-opus-4-8), 2026-06-05. 상태: **Agreed (R4)** — 사용자 리뷰 대기.

#### AS-IS — trigger는 선언됐으나 closeout에 미배선, 배출구 0

부모 §7 "PLAN 좀비" 진단이 protocol 레벨에서 재현된다.

| 결함 | 근거 | 증상 |
| --- | --- | --- |
| **들어오는 문 미배선** | `T5 PLAN 영향 결정 → PLAN 확인`이 존재(`docs/HARNESS-PROTOCOL.md:423`)하나, commit/PR 전 finalization gate(`T15`/`T16`/`T17`, `:433-435`)와 phase-transition(`T3`, `:421`)이 **T5를 호출하지 않는다.** closeout 흐름에 PLAN 반영 단계가 없음 | PLAN이 결정 후 갱신되지 않음 → 좀비 |
| **나가는 문 부재** | Recent Decisions에는 `최근 8개 rolling window` 배출 규칙이 명시(`docs/HARNESS-PROTOCOL.md:496`)되나, PLAN에는 닫힌 phase 상세를 배출하는 동형 규칙이 **없다** | 살아나면 단조 증가 → 비대화 |
| **옆문(L3 근거) 미분리** | PLAN이 charter·roadmap·L3 근거를 한 파일에 혼합(부모 §7-b) | 가장 느린 charter가 가장 빠른 roadmap 갱신을 가림 |
| **실증** | `docs/PLAN.md` `v0.1`/작성일 `2026-05-22`, Roadmap `AWH-003/004`에서 정지(`docs/PLAN.md:112-119`). 실작업은 `CHORE-YYYYMMDD-NNN`으로 진행 → roadmap과 단절 | 좀비 확진 |

#### TO-BE — 분할이 아니라 lifecycle 배선 (방향)

신규 hard gate를 만들지 않는다(OQ-3 반대 합의). 기존 trigger를 흐름에 연결하고 배출구 하나를 추가한다.

| 문 | 조치 | 막는 증상 |
| --- | --- | --- |
| **들어오는 문** | `T5`를 closeout(`T15`/`T16`/`T17`)·phase-transition(`T3`)에 **배선** — "이 결정이 PLAN 방향에 영향을 주는가?"를 closeout에서 확인 | 좀비(죽음) |
| **나가는 문** | PLAN **archive-drain 규칙 신설** — 닫힌 phase 상세는 `docs/archive/`로, PLAN은 현재+미래+archive 링크 한 줄만 유지. Recent Decisions rolling-window와 동형 | 비대화 |
| **옆문** | L3 근거는 PLAN에 누적하지 않고 **DR로 분리**(규율) | 계층 비대화 |

target-local harness 방향 기록처는 **OQ-7로 유지**(default: Work/DR, 반복 시 optional `HARNESS-PLAN.md` 검토). slice 0에서 닫지 않는다.

#### 닫는 OQ / 잔여 OQ

- **OQ-3 (generated repo PLAN 완료를 hard gate):** 닫음 — **반대.** hard gate 신설 대신 soft한 T5 closeout 배선. content/no-code 프로젝트의 거짓 차단 회피.
- **OQ-7 (target-local harness 기록처):** **잔여(명시 이연)** — Codex R1 답변대로 OQ 유지.

#### 외부화 3대 실패모드 매핑

- **① 라우팅 누락:** T5 배선(들어오는 문)으로 결정이 PLAN에 반영 → 방향 기록처가 살아있음.
- **② 비대화:** archive-drain(나가는 문)으로 PLAN이 O(현재 phase) 상수 크기에 수렴.
- **③ 선언-실행 괴리:** T5/T3가 선언만 되고 closeout에 미배선된 것 자체가 이 실패모드의 표본 — **배선이 곧 집행**이다(이상적으로 closeout이 PLAN impact를 묻게).

#### DR 후보 초안 (DR-B: PLAN lifecycle)

- **Question:** PLAN이 living document로 작동하지 않고(좀비), 살아나면 비대화 위험. lifecycle을 어떻게 배선하는가?
- **Decision(방향):** (1) 신규 hard gate 미신설. (2) 기존 T5를 closeout(T15/16/17)·phase-transition(T3)에 배선. (3) PLAN archive-drain 규칙 신설(닫힌 phase → archive, 현재+미래+링크 유지). (4) L3 근거는 DR로 분리. (5) target-local harness 기록처는 OQ-7 유지.
- **Scope(하류로 남김):** PLAN 본문 rewrite, AWH↔CHORE ID drift 수선(현존 결함 1a), phase별 실제 archive 실행, closeout checklist/hard-stop 구현.
- **Reversal Cost:** Low — trigger 배선과 drain 규칙 추가는 문서 변경. 되돌리기 쉬움.
- **연계:** Gate taxonomy(CP4, closeout enforcement mode), CP1 `PLAN.md:90-93` 정정.

### CP3. Canonical + hybrid adapter

작성: Claude (claude-opus-4-8), 2026-06-05. 상태: **Agreed (R4, adapter 범위 보강 반영)** — 사용자 리뷰 대기.

#### AS-IS — self-contained 3벌, canonical 0, 수동 cascade

workflow 절차가 도구별로 self-contained mirror로 반복되고, 이를 묶는 canonical SSoT가 없다. 동기화는 `T11`(`docs/HARNESS-PROTOCOL.md:429`) 수동 cascade에 의존한다.

| 표면 | 실측(줄) | 비고 |
| --- | --- | --- |
| `.claude/commands/work.md` + `close.md` | 96 + 143 = **239** | Claude self-contained |
| `.agents/skills/workflow-work` + `workflow-close/SKILL.md` | 110 + 149 = **259** | Codex self-contained |
| `.cursor/rules/workflow.mdc` | **98** | Cursor self-contained |
| 루트 `skills/` (canonical) | **0** (디렉토리 없음) | SSoT 부재 |

`/work`+`/close` **한 쌍만으로 3벌 ≈ 596줄**, 11개 command 전체로는 수천 줄이 수동 동기화 대상이다. drift는 사고가 아니라 구조적 필연(부모 §5). 비교 근거: 사용자 `ai-deck-compiler`는 `skills/create-deck.md`(837줄, canonical) ← `.claude/commands/create-deck.md`(115줄, thin) 패턴이 **도메인 skill에는 작동**하나 workflow skill에는 미적용 — 즉 패턴은 검증됐고 자리만 비어 있다.

#### TO-BE — canonical 1벌 + hybrid adapter (방향)

workflow 절차를 공통 canonical 위치(루트 `skills/` 또는 동급)에 **1벌**로 모으고, 도구별 표면은 **hybrid adapter**로 전환한다.

| 계층 | 보유 내용 |
| --- | --- |
| **Canonical (SSoT 1벌)** | 세부 절차, 검토축, cascade matrix, checklist, 상태 전이 |
| **Hybrid adapter** (`.claude/commands/`·`.agents/skills/`·`.cursor/rules/`) | Step 0, **hard-stop gate**, 도구별 entry mechanism(slash 자동 / `AGENTS.md` routing / Cursor rule), fallback만 자체 보유. 세부는 canonical 위임 |

**왜 full thin pointer가 아니라 hybrid인가(비판적 제약, R2/R3 합의):**
① Claude command의 "canonical 로드" 지시는 `@` 하드 import가 아니라 런타임 자연어 유도라 100% 결정적이지 않다 → 핵심 gate는 adapter가 자체 보유해야 안전. ② 세 도구의 실행 mechanism 차이(slash 자동 인식 vs routing vs rule)가 크다 — 그 차이가 정확히 "도구 고유 = 가볍게"의 자리. ③ workflow command는 branch/state/approval gate처럼 실패 시 damage가 크다.

#### 닫는 OQ

- **OQ-8 (adapter에 남길 minimum hard-stop 범위):** 닫음(방향 수준) — adapter 최소 보유 = **Step 0 + 핵심 gate hard-stop(branch isolation, Approval Matrix gate, validation-before-commit) + 도구별 entry mechanism + fallback.** 그 외 세부 절차는 canonical 위임. exact 절차 목록은 하류.
  - **(R4 보강)** adapter는 hard-stop **요약 + action 차단 조건**만 자체 보유한다. **Approval Matrix 전문·상세 checklist·cascade matrix는 canonical에 둔다** — adapter가 세부 절차를 복제해 비대해지면 "중복 없는 SSoT" 원칙(R3)을 깬다.

#### 외부화 3대 실패모드 매핑

- **① 라우팅 누락:** canonical 1 SSoT + adapter가 명시 pointer → "어느 절차를 따를지" 추측 제거.
- **② 비대화:** 3벌 → 1 canonical + thin adapter로 mirror 부피와 target context weight 동시 감소.
- **③ 선언-실행 괴리:** hard-stop을 adapter에 **자체 보유**(위임 아님) → 자연어 로드가 실패해도 핵심 gate는 집행.

#### DR 후보 초안 (DR-C: Canonical + hybrid adapter)

- **Question:** workflow 절차가 self-contained 3벌(canonical 0)로 T11 수동 cascade에 의존 → drift 구조적 필연. 어떻게 단일화하는가?
- **Decision(방향):** canonical workflow SSoT 1벌(루트 `skills/` 또는 동급) + 도구별 hybrid adapter. adapter는 Step 0·hard-stop·entry mechanism·fallback만 자체 보유, 세부는 canonical 위임. scaffold도 canonical 1벌 + thin adapter만 복사 → CP1 A/B boundary와 정합(framework canonical은 A-owned).
- **Scope(하류로 남김):** 실제 canonical 추출·adapter 전환·command rename은 **같은 breaking slice(#13)**, 자연어 로드 결정성 검증, exact adapter 절차 목록.
- **Reversal Cost:** High — scaffold output 구조 변경(breaking). §10-a 순서 제약(단독 선행 금지) 적용.
- **연계:** CP1(canonical = framework A-owned), Q4 `--check`/migration, OQ-15/17(no-alias rename 하류).

### CP4. Gate strictness 2D taxonomy

작성: Claude (claude-opus-4-8), 2026-06-05. 상태: **Agreed (R4, clean baseline 보강 반영)** — 사용자 리뷰 대기.

#### AS-IS — gate가 늘었으나 강제성·enforcement가 ad hoc 혼합

protocol은 성격이 다른 gate를 여럿 운영하나(archive `T10`, finalization `T15`/`T16`, close 선제 `T17`, branch isolation), 이들을 **하나의 일관된 축으로 분류하지 않는다.** 그 결과 조건부 강제 gate가 평시 workflow에 마찰을 샌다.

| 증거 | 내용 |
| --- | --- |
| ad hoc 튜닝 | `STATUS.md:41` Recent Decision(2026-05-29): "solo 프로젝트에서 housekeeping마다 PR 강제는 과도한 마찰" → `main`만 hard block, `develop`은 warning. **gate별 즉흥 조정**이지 taxonomy가 아님 |
| archive를 부채처럼 취급 | `start.md`가 archive 대기 Work를 clean idle 차단 조건으로 봄 → optional hygiene이 미정리 부채로 보임(부모 §9, Codex R1) |
| 강제성·enforcement 미분리 | "mandatory인가"(강제 대상)와 "어떻게 집행하나"(hard-stop/warning)가 한 축에 뭉개짐 |

#### TO-BE — 2D taxonomy (방향)

강제성 축과 enforcement mode 축을 분리한다(부모 §9 합의).

- **Strictness 축:** `mandatory` / `conditional mandatory` / `recommended` / `optional hygiene`
- **Enforcement mode 축:** `hard-stop` / `warning` / `report-only` / `silent`

대표 분류(Codex R3: archive/commit/release/bootstrap 네 범주를 category-level example로 고정):

| Gate | Strictness | Enforcement | 비고 |
| --- | --- | --- | --- |
| causal finalization bundling (Work 변경 + Work Done/STATUS/index 같은 commit) | conditional mandatory | hard-stop / explicit override | 실제 정책은 하류 child DR |
| archive cleanup | optional hygiene | silent 또는 threshold report-only | 평시 부채로 취급하지 않음(clean idle 차단 제외) |
| public release gate | conditional mandatory | hard-stop | release/open 직전만 |
| clean baseline gate | recommended / conditional | warning → release 직전 hard-stop 후보 | 평시 마찰 회피 |
| bootstrap completion | conditional mandatory | warning 또는 hard-stop | project type·feature 진입 조건 따라 |

scope 변경 gate는 비대칭(부모 §9-6): 확장=승인, 축소=보고, Done Criteria 축소=별도 확인, split=신규 Work/register.

**(R4 보강)** 필수 대표 범주는 **archive / commit / release / bootstrap** 네 개다. **clean baseline은 release 직전 escalation 후보인 보조 예시**이며, 위 네 범주와 같은 레벨의 primary requirement는 아니다.

#### 닫는 OQ

- **OQ-12 (`/close` commit 책임):** 닫음(방향) — `/close`는 **commit-agnostic state edit**으로 제한. commit bundling 판단은 commit gate가 소유(Codex 선호안).
- **OQ-13 (causal finalization bundling strictness/enforcement):** 닫음(방향) — **conditional mandatory + hard-stop/explicit override.**
- **OQ-16 (archive pending을 clean idle 차단에서 제외):** 닫음(방향) — archive는 **optional hygiene + silent/threshold report-only**, clean idle 차단 조건에서 제외. 누적 임계 report 기준은 하류.

#### 외부화 3대 실패모드 매핑

- **③ 선언-실행 괴리(주):** enforcement mode 축(hard-stop/warning/report-only/silent)이 "문서가 권장만 하고 런타임이 무시"하는 괴리를 명시적 집행 수준으로 환원.
- **② 비대화:** archive를 optional hygiene으로 내려 평시 clean idle 판정에서 제외 → 가짜 부채 신호 제거.
- **① 라우팅 누락:** 공통 gate vocabulary가 "이 gate가 어느 강제 수준인지" 추측을 제거.

#### DR 후보 초안 (DR-D: Gate strictness 2D taxonomy)

- **Question:** gate가 늘었으나 강제성과 enforcement가 ad hoc 혼합되어 조건부 강제 gate가 평시 workflow에 마찰을 샌다(2026-05-29 develop 완화가 증거). 어떻게 분류하는가?
- **Decision(방향):** 2D taxonomy — strictness(mandatory/conditional/recommended/optional hygiene) × enforcement mode(hard-stop/warning/report-only/silent). archive/commit/release/bootstrap을 대표 category-level example로 고정. scope 변경 gate는 비대칭.
- **Scope(하류로 남김):** **Commit gate runtime enforcement(causal finalization bundling의 hard-stop/override 실제 정책)는 별도 child DR**(R2/R3 PQ-4). exception table(OQ-14), override UX, hook/command 구현.
- **Reversal Cost:** Low — vocabulary와 분류는 문서 결정.
- **연계:** CP2(closeout enforcement mode), CP3(adapter hard-stop), 하류 Commit gate runtime enforcement child DR.

### CP5. OQ 매핑 + 외부화 3대 실패모드 정합

작성: Claude (claude-opus-4-8), 2026-06-05. 상태: **Agreed (R4)** — 사용자 리뷰 대기.

#### 부모 OQ-1~18 전체 매핑

"닫음(방향)" = 적용 완료가 아니라 DR 후보가 가져갈 방향을 고정. 최소 closure 집합(R2: OQ-1·3·8·12·13·15·16·17)은 모두 닫혔다.

| OQ | 주제 | 처리 | 위치 |
| --- | --- | --- | --- |
| OQ-1 | MANUAL default 제외 + source link | 닫음 — Optional source pack | CP1 / DR-A |
| OQ-2 | docs/ vs harness/ 물리 분리 | 닫음 — 물리 이동 보류, logical marker | CP1 / DR-A |
| OQ-3 | PLAN 완료 hard gate | 닫음 — 반대, T5 soft 배선 | CP2 / DR-B |
| OQ-4 | prompts session-start 3종만 | 방향만(Optional pack) — exact는 하류 | CP1 / 하류 minimal output |
| OQ-5 | hook/CI enforcement target 안내 | 이연 — source-only/release 하류 | 하류 |
| OQ-6 | public-release-playbook link vs 요약 | 이연 — link만(부모 합의), 하류 배선 | 하류 |
| OQ-7 | target-local harness 기록처 | **잔여(유지)** — default Work/DR, optional plan은 반복 시 | CP2 |
| OQ-8 | adapter minimum hard-stop 범위 | 닫음 — Step 0+gate hard-stop+entry+fallback | CP3 / DR-C |
| OQ-9 | reference integrity 판정 수준 | 이연 — test slice(1b) | 하류 |
| OQ-10 | manifest hash 기준 | 이연 — manifest slice | 하류 |
| OQ-11 | user-facing 참조 0 vs 단방향 | 이연 — user-facing rewrite slice | 하류 |
| OQ-12 | `/close` commit 책임 | 닫음 — commit-agnostic state edit | CP4 / DR-D |
| OQ-13 | causal finalization bundling 분류 | 닫음 — conditional mandatory + hard-stop/override | CP4 / DR-D |
| OQ-14 | state-only close commit 예외 조건 | 이연 — Commit gate runtime enforcement child DR exception table | 하류 child |
| OQ-15 | no-alias rename breaking + 순서 | **닫음(방향, 아래)** | CP5 / DR-C+하류 |
| OQ-16 | archive pending clean idle 제외 | 닫음 — optional hygiene + silent/threshold | CP4 / DR-D |
| OQ-17 | active target migration 경계 | **닫음(방향, 아래)** | CP5 / 하류 |
| OQ-18 | user-facing 전면 vs 단계적 | 이연 — user-facing rewrite slice | 하류 |

#### OQ-15 / OQ-17 방향 closure (단일 축에 속하지 않는 cross-cutting)

- **OQ-15 (no-alias rename):** 방향 고정 — command taxonomy는 **legacy runtime alias 없이** 설계. old→new mapping은 runtime surface가 아니라 **migration note/release note에만**. 단독 선행 금지: Q4 `--check` 최소 경로 위에서 **§5 canonical+adapter 전환(DR-C)과 같은 breaking slice(#13)로 묶어** 적용. *실제 rename 적용·순서 실행은 하류.*
- **OQ-17 (active target migration 경계):** 방향 고정 — **cross-repo 책임 분리.** source가 rename PR + `--check` + migration note를 **제공**, `ai-deck-compiler` 같은 active target은 자기 repo에서 **별도 migration Work로 수용**. source repo Work가 target을 직접 migrate하지 않음(Q4 A/B layer와 동일 선). *실제 migration 실행은 target repo 책임, 하류.*

#### 4축 × 외부화 3대 실패모드 정합 표 (PQ-6 framing 충족)

각 DR이 닫는 주 실패모드. 별도 umbrella DR 없이, 이 표 + 각 DR의 rationale/verification 매핑이 통합 원칙의 정합성 기준이다(R3 PQ-6).

| DR 후보 | ① 라우팅 누락 | ② 비대화 | ③ 선언-실행 괴리 |
| --- | --- | --- | --- |
| **DR-A** A/B boundary | ● leakage 차단(dangling 제거) | ● target context weight 감소 | ○ class marker = leakage 테스트 대상 정의 |
| **DR-B** PLAN lifecycle | ● T5 배선(기록처 생존) | ● archive drain(상수 크기) | ○ closeout 미배선이 표본 — 배선이 집행 |
| **DR-C** canonical+adapter | ● canonical 1 SSoT 라우팅 | ● 3벌→1+thin | ● adapter 자체 hard-stop(위임 아님) |
| **DR-D** gate 2D taxonomy | ○ gate vocabulary 명확화 | ○ archive optional 강등 | ● enforcement mode 축이 괴리 환원 |

(● 주 효과, ○ 부 효과) — 네 축 모두 "중복 생성 후 cross-reference 봉합" 한 뿌리를 surface별로 끊는다는 통합 원칙에 정합.

### CP6. DR 후보 목록 확정 + cross-agent 합의 + 사용자 리뷰

작성: Claude (claude-opus-4-8), 2026-06-05. 상태: **Cross-agent 합의 완료** — 사용자 리뷰 대기.

#### slice 0 산출 — DR 후보 목록 (후속 `/record-decision` 대상)

| DR 후보 | 제목 | Reversal | 닫는 OQ | 적용 slice |
| --- | --- | --- | --- | --- |
| **DR-A** | Source / framework-vs-project-state boundary | Medium | OQ-1·2 | 하류 minimal output/manifest |
| **DR-B** | PLAN lifecycle (T5 배선 + archive drain) | Low | OQ-3 | 하류 closeout 배선/archive |
| **DR-C** | Canonical + hybrid adapter | High | OQ-8·15 | 하류 breaking slice #13(rename 동반) |
| **DR-D** | Gate strictness 2D taxonomy | Low | OQ-12·13·16 | 하류 enforcement/Work lifecycle |
| (child) | Commit gate runtime enforcement | — | OQ-14 | DR-D 하류 child DR |

PQ-6 결론대로 **외부화 3대 실패모드 통합 원칙은 별도 DR 없이** PLAN framing 문단 + 위 4 DR의 rationale/verification 정합성 기준(CP5 표)으로 둔다.

#### cross-agent 합의

plan-level(PQ-1~6) 합의는 R0~R3로 완료. 4축 draft(CP1~6)에 대한 Codex batch 검토는 **R4에서 조건부 동의로 완료**. 보강 2건(CP3 adapter 범위, CP4 clean baseline 위상)을 반영했다. 남은 것은 사용자 최종 리뷰뿐이다.

#### 사용자 최종 리뷰

Done Criteria의 명시 리뷰 조건. 4축 방향 + DR 후보 목록을 사용자가 확인하기 전 Done 처리하지 않는다.

### Codex Batch Review (R4)

작성: Codex, 2026-06-05. 이 리뷰는 CP1~6의 direction/DR boundary/OQ mapping만 검토한다. exact scaffold file-list, manifest schema, canonical 추출, command rename 적용, gate exception table은 하류로 둔다.

#### Summary

CP1~6 draft에는 **조건부 동의**한다. R1~R3 합의인 "decision-only, 적용 0", "4 primary DR + Commit gate runtime enforcement child", "외부화 원칙은 별도 umbrella DR 없이 framing/rationale 기준"을 대체로 잘 반영했다. 신규 PQ-7은 필요하지 않다. 유일한 보강 조건은 CP3 adapter minimum hard-stop이 세부 절차 복제로 비대해지지 않게, adapter에는 hard-stop **요약과 action 차단 조건**만 남기고 Approval Matrix 세부·checklist·cascade matrix는 canonical에 둔다는 것이다.

#### Axis Review

| DR | AS-IS 근거 검증 | TO-BE 판단 | OQ closure | Reversal Cost |
| --- | --- | --- | --- | --- |
| DR-A Boundary | 정확. `adapt()`는 sed 치환 복사이며(`scripts/create-harness.sh:137-143`), entrypoint/protocol docs/maintainer docs/DR 일부가 한 평면으로 복사된다(`scripts/create-harness.sh:199-226`). prompt library도 session-start 3종 외 항목을 포함해 복사된다(`scripts/create-harness.sh:331-350`). `PLAN.md`는 `HARNESS-ARCHITECTURE`/`HARNESS-MAINTAINER-GUIDE`를 source core로만 말하지만(`docs/PLAN.md:90-93`), scaffold는 target에도 ship한다. | 동의. 3-class(A framework / B project-state / Optional source pack)와 physical split 보류는 R1/R2의 boundary 결론과 맞다. exact file-list와 manifest schema를 하류로 둔 경계도 적절하다. | OQ-1은 방향 수준에서 닫힘. OQ-2도 "physical split 보류 + logical marker"로 닫힘 처리 가능. OQ-4는 direction-only/하류로 둔 현재 표기가 맞다. | Medium 타당. 원칙은 문서 결정이나 하류 default scaffold output 변경은 breaking 가능성이 있다. |
| DR-B PLAN lifecycle | 정확. T3/T5/T10/T15~T17은 존재하지만(`docs/HARNESS-PROTOCOL.md:421-435`), T15~T17이 T5를 호출한다고 명시하지 않는다. Recent Decisions는 rolling window 규칙이 있으나(`docs/HARNESS-PROTOCOL.md:496`), PLAN에는 동형 archive drain이 없다. Roadmap도 AWH-003/004에서 정지해 있다(`docs/PLAN.md:112-119`). | 동의. 신규 hard gate가 아니라 T5 closeout/phase-transition 배선 + archive drain으로 푸는 방향이 맞다. PLAN 본문 rewrite와 실제 archive 실행을 하류로 둔 것도 적절하다. | OQ-3은 닫힘. OQ-7은 잔여 유지가 맞다. target-local harness plan은 반복 pain이 실측될 때 optional로 열어두는 편이 안전하다. | Low 타당. slice 0은 trigger/drain 규칙 방향 결정이고, hard enforcement가 아니다. |
| DR-C Canonical + hybrid adapter | 대체로 정확. 부모 Work는 canonical+adapter를 mirror 부피 해소책으로 수용하되 workflow skill은 hard gate 때문에 full thin pointer가 위험하다고 정리했다(`docs/works/harness/CHORE-20260604-001-harness-phase2-refactor-planning.md:762-784`). 현재 `/work`/`/close` surface line count도 596줄로 재확인된다. T11은 tool surface 변경 시 수동 cascade를 요구한다(`docs/HARNESS-PROTOCOL.md:429`). | 조건부 동의. adapter minimum hard-stop 범위는 너무 얇지 않다. 다만 너무 두꺼워지지 않게 "Step 0 + branch/policy/approval/validation hard-stop의 요약 차단 조건 + entry/fallback"만 adapter에 두고, Approval Matrix 전문·상세 checklist·cascade matrix는 canonical에 둬야 한다. §10-a 순서 제약은 정확히 반영됐다: no-alias rename은 단독 선행 금지, `--check` 최소 경로 위에서 canonical+adapter 전환과 같은 breaking slice로 적용(`docs/works/harness/CHORE-20260604-001-harness-phase2-refactor-planning.md:947-960`). | OQ-8은 방향 수준에서 닫힘. OQ-15는 CP5의 cross-cutting closure로 방향만 닫고 실제 rename 적용은 하류로 둔 점이 맞다. | High 타당. 실제 전환은 command/skill/rule/scaffold output을 동시에 건드리는 breaking slice다. |
| DR-D Gate 2D taxonomy | 정확. 부모 §9는 strictness와 enforcement mode를 분리하고, archive/commit/release/clean baseline/bootstrap 대표 예시를 제시한다(`docs/works/harness/CHORE-20260604-001-harness-phase2-refactor-planning.md:919-937`). Commit gate runtime enforcement는 별도 runtime 정책으로 남긴다(`docs/works/harness/CHORE-20260604-001-harness-phase2-refactor-planning.md:938-942`). | 동의. CP4는 vocabulary + category-level examples까지만 다루고, hard-stop/override 실제 정책과 OQ-14 exception table을 child DR로 넘긴다. R3 합의와 맞다. | OQ-12, OQ-13, OQ-16은 방향 수준에서 닫힘. OQ-14는 하류 child로 남기는 게 맞다. | Low 타당. taxonomy와 대표 분류는 문서 vocabulary 결정이며 runtime 구현이 아니다. |
| Child: Commit gate runtime enforcement | AS-IS 근거는 부모 §9에서 충분하다. 문서 권장과 실제 commit 행동의 괴리를 막으려면 hard-stop/override 정책이 필요하다는 진단이 별도 항목으로 존재한다(`docs/works/harness/CHORE-20260604-001-harness-phase2-refactor-planning.md:919-942`). | 동의. child DR/Work 분리가 맞다. slice 0에서는 causal finalization bundling을 representative category로만 고정한다. | OQ-14만 child의 직접 closure로 두는 CP6이 맞다. OQ-13은 DR-D에서 방향 분류로 닫고, exception table은 child에서 닫는다. | slice 0에서는 등급 미정으로 둬도 된다. 실제 hard-stop/override 구현 시 Medium 이상으로 재평가해야 한다. |

#### Focus Checks

- **DR-C adapter 범위:** 현재 범위는 안전 쪽으로 약간 두껍지만 허용 가능하다. 조건은 adapter가 full Approval Matrix나 checklist를 복제하지 않는 것이다. adapter는 action 차단이 필요한 최소 문장만 보유하고, 세부 판단은 canonical로 위임해야 R3의 "중복 없는 SSoT" 원칙을 지킨다.
- **§10-a 순서 제약:** CP3/CP5/CP6 모두 no-alias rename을 단독 선행하지 않고, `--check` 최소 경로와 canonical+adapter 전환 뒤 같은 breaking slice로 묶는다. 부모 §10-a와 일치한다(`docs/works/harness/CHORE-20260604-001-harness-phase2-refactor-planning.md:947-960`).
- **OQ-15/OQ-17 leakage:** CP5는 방향 수준을 넘지 않는다. "legacy alias 없음", "migration note/release note", "source 제공 vs target 수용"까지는 책임 경계이고, 실제 rename/migration 실행은 하류로 명시되어 있다.
- **PQ-6 framing:** CP5의 4축 × 3실패모드 표는 R3 결론을 충족한다. 별도 umbrella DR 없이 각 DR의 rationale/verification에 실패모드 매핑을 남기는 방식이다.
- **CP6 split:** R3 합의와 일치한다. 4 primary DR(A/B/C/D) + `Commit gate runtime enforcement` child로 분리되어 있고, child를 gate DR에 다시 병합하지 않는다.

#### Required Follow-Up Before Final Acceptance

- CP3 합의 반영 단계에서 adapter 보유 범위를 한 문장 보강한다: **adapter는 hard-stop 요약과 action 차단 조건만 자체 보유하고, Approval Matrix 전문·상세 checklist·cascade matrix는 canonical에 둔다.**
- CP4 합의 반영 단계에서 "clean baseline"은 release 직전 escalation 후보인 보조 예시이고, R3의 필수 대표 범주 archive/commit/release/bootstrap과 같은 레벨의 primary requirement는 아니라는 문장만 정리하면 더 명확하다.

## Discovery

- CP1 진행 중 확인: `docs/PLAN.md:90-93`의 "Kept As Core"가 source-keep과 target-ship을 한 결정에 뭉갠 표본 — DR-A의 직접 근거로 인용. PLAN lifecycle(CP2)에서 이 PLAN 항목 자체의 정정 필요 여부를 함께 본다.
- 잔여 OQ는 CP5에서 일괄 매핑.
