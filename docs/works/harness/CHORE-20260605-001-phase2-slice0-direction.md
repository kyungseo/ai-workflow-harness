---
id: CHORE-20260605-001
priority: P1
status: Active
risk: High
scope: Phase 2 slice 0 — A/B(framework/project-state) boundary + canonical+adapter 구조 + gate strictness 2D taxonomy + PLAN lifecycle의 TO-BE 방향을 합의하고 DR 후보로 확정한다 (실제 breaking 적용은 후속 slice)
appetite: 3d
planned_start: 2026-06-05
planned_end: 2026-06-08
actual_end:
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

- [ ] A/B(framework/project-state) boundary TO-BE 합의 및 DR 후보 확정 (Decision Candidate: *Source / scaffold target responsibility boundary*)
- [ ] PLAN lifecycle 방향(T5 배선 + archive drain, hard gate 미신설) 합의 및 DR 후보 확정 (Decision Candidate: *PLAN lifecycle gate 강화*)
- [ ] Canonical + hybrid adapter 구조 방향 합의 및 DR 후보 확정 (Decision Candidate 연계: command/skill mirror 단일화)
- [ ] Gate strictness 2D taxonomy(강제성 × enforcement mode) 방향 합의 및 DR 후보 확정 (Decision Candidate: *Gate strictness taxonomy*. *Commit gate runtime enforcement*는 하류 child DR로 분리 — R2 PQ-4)
- [ ] 각 결정이 닫는 OQ를 OQ-1~18에 매핑하고, 잔여 OQ를 Discovery에 정리
- [ ] 외부화 3대 실패모드 프레임에 4개 결정이 각각 어느 보완으로 닫히는지 정합 확인 (backlog P1 상위 프레임)
- [ ] DR 후보 목록을 후속 `/record-decision` 대상으로 산출 (실제 DR 작성·cascade 적용은 후속 slice)
- [ ] Codex ↔ Claude cross-agent 합의 — Cross-Agent Review And Discussion의 Consensus Log에 4축 방향 합의가 기록됨
- [ ] **사용자 최종 리뷰** — 4축 방향 결정과 DR 후보 목록을 사용자가 확인한 뒤 Done 처리

## Verification

- documentation-only 방향 결정: `git diff --check`, 링크/stale phrase 점검.
- 추적성 검증: 각 DR 후보가 부모 Decision Candidates 표 항목과 1:1 매핑되는지, 각 4축 결정이 OQ-1~18 중 어느 것을 닫고 어느 것을 잔여로 남기는지 표로 추적 가능한지 확인.
- cascade 미적용 확인: 이 slice는 canonical/scaffold/command/user-facing 표면을 **변경하지 않는다.** cascade 점검은 Skipped / Not Applicable로 보고하고 적용 slice로 이연.

## Checkpoints

| CP | Description | Status |
| --- | --- | --- |
| 1 | A/B boundary AS-IS/TO-BE 확정 + DR 후보 초안 | Todo |
| 2 | PLAN lifecycle 방향(T5 배선·archive drain) 확정 + DR 후보 초안 | Todo |
| 3 | Canonical + hybrid adapter 책임 경계 확정 + DR 후보 초안 | Todo |
| 4 | Gate strictness 2D taxonomy 확정 + DR 후보 초안 | Todo |
| 5 | OQ 매핑(닫힘/잔여) + 외부화 3대 실패모드 정합 표 | Todo |
| 6 | DR 후보 목록 확정 + cross-agent 합의 + 사용자 최종 리뷰 | Todo |

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

## Discovery

(실행 중 채워나간다 — 계획과 달라진 점, 잔여 OQ, 후속 slice를 위한 인사이트)
