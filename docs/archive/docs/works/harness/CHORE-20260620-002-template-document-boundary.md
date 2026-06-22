---
id: CHORE-20260620-002
priority: P2
status: Archived
risk: L2
scope: D-21 Template document-set의 source-template-owned / scaffold-seed / product-owned / pack-conditional / guide-only 경계를 결정한다. Full 문서셋 작성과 scaffold 구현은 비범위.
appetite: 1d
planned_start: 2026-06-20
planned_end: 2026-06-20
actual_end: 2026-06-20
related_dr: [DR-041]
related_troubleshooting: []
related_work: [CHORE-20260620-001]
---

# CHORE-20260620-002: Template Document-Set Boundary Decision

## Top Summary

CHORE-20260620-001이 `spring-modular-template` 5+ 사이클 evidence를 `Template document-set (D-21) source/product 경계 결정` 후보로 승격했다. 이 Work는 그 후보를 열어 D-21 document-set surface별 소유권과 흡수 기준을 결정한다.

비목표는 명확하다. 14 core 문서 완성본을 작성하지 않고, `scripts/create-harness.sh` 또는 scaffold template을 바꾸지 않으며, auth-session pack·planning-pack resolver·archive decision surfacing을 한 번에 구현하지 않는다.

산출물은 **문서셋 경계 decision/brief**다. 결정이 DR-worthy이면 DR로 승격을 제안하고, 아니면 이 Work 내 decision으로 남긴다.

## Collaboration Workflow

| Role | Agent | Responsibility |
| --- | --- | --- |
| A | Codex | author/driver. Work 파일, 계획, 분석, response 작성 |
| B | Claude | cross-agent red team reviewer. 방향 자체와 scope 경계, source/product 소유권 기준을 의심 |
| Owner | User | 최종 방향 승인, 분석/문서 변경 승인, `/work-close`, commit, PR, merge 승인 |

절차: Codex plan → Claude R1 red-team review → Codex accept/defend/revise response → Owner 승인 → 경계 결정/문서 변경 → Claude result review → Owner 승인 → `/work-close` → commit → PR(`--base develop`) → merge.

## Context Manifest

| 순서 | 파일 | 섹션 | 왜 |
| --- | --- | --- | --- |
| 1 | `docs/backlog/HARNESS.md` | `Template document-set (D-21) source/product 경계 결정` | 착수 후보와 Done Criteria |
| 2 | `temp/document-set-scaffold.md` | 전체 | D-21 document-set 원안 |
| 3 | `temp/decision-table.md` | D-21 | locked decision 문구와 재검토 gate |
| 4 | `temp/template-acceptance-matrix.md` | 전체 | `TEMPLATE-ACCEPTANCE`와 pack acceptance 6축 |
| 5 | `temp/base-msa-template-techreq-gap-analysis-20260619.md` | §6.4, §7 D-21, §8 | D-21 document-set의 design original. no-stub, thin+pointer, adopter/maintainer 분리, `TEMPLATE-ACCEPTANCE` keystone 근거 |
| 6 | `docs/works/harness/CHORE-20260620-001-planning-pack-evidence-review.md` | D-21 delta, Routing summary, Cross-Agent Review | 이 Work를 낳은 evidence payload와 reviewer 요구 |
| 7 | `docs/retrospectives/harness-v1-2-readiness-retrospective-20260615.md` | W2 / 경계 감각 | source-owned / product-owned / import-candidate 반복 리스크 |

필요 시 product evidence를 추가 확인한다: `/Users/kyungseo/dev-home/vibe/spring-modular-template/docs/decisions/DR-030~033`, `/Users/kyungseo/dev-home/vibe/spring-modular-template/docs/archive/docs/works/product/FEAT-20260620-001~005`, `/Users/kyungseo/dev-home/vibe/spring-modular-template/docs/ADOPTER-RENAME.md`, `/Users/kyungseo/dev-home/vibe/spring-modular-template/pack/*/README.md`.

Trigger: backlog의 `Template document-set (D-21) source/product 경계 결정` candidate 착수. CHORE-20260620-001이 D-21 delta를 live backlog payload로 승격했고, 사용자가 이 후보를 첫 작업으로 선택했다.

## Scope

### Slice A — Evidence-Bounded Boundary Inventory

- `document-set-scaffold.md`의 전체 surface를 억지로 확정하지 않는다.
- 이번 Work에서 실제로 결정하는 surface는 CHORE-20260620-001이 evidence payload로 넘긴 4개로 제한한다: `ADOPTER-RENAME`, `TEMPLATE-ACCEPTANCE`, pack docs 위치, product DR set.
- 나머지 core 문서 surface는 D-21 기본값을 유지한다: "source-template-owned thin+pointer seed, 개별 product evidence가 생길 때 재검토".
- 분류는 2축으로 나눈다.
  - Ownership axis: `source-template-owned` / `scaffold-seed` / `product-owned`
  - Nature axis: `core-required` / `pack-conditional` / `guide/recipe-only`

### Slice B — Open Decisions

- D-21 lock과의 관계를 먼저 판정한다. lock 빈 영역을 채우는 결정인지, D-21이 인용한 §6.4 전제를 바꾸는 supersede/DR-worthy 결정인지 구분한다.
- `ADOPTER-RENAME`이 product-owned seed인지, source acceptance로 승격해야 하는지 결정한다.
- `TEMPLATE-ACCEPTANCE`가 pack acceptance evidence를 흡수하는 방식을 정한다. 목표는 keystone 유지이며, 거대 실행 로그 문서화는 피한다.
- pack docs 표준 위치를 정한다: `pack/{name}/README`와 `docs/packs/*`의 역할 차이를 분리한다.
- product DR set(DR-030~033)과 source DR의 분리 기준을 정한다.

### Slice C — Decision Form

- 위 결정이 DR-worthy인지 판단한다. 특히 D-21 locked premise를 바꾸는 경우 Work 내 decision으로 닫지 않는다.
- DR-worthy이면 `/record-decision` 후보로 제안한다.
- DR까지 필요 없으면 Work 내 `Decision Output`으로 남기고, 후속 후보가 검색할 수 있게 `docs/backlog/HARNESS.md` 반영 필요 여부를 판단한다.

## Scope Guard

- Full 14문서 작성은 비범위다.
- `scripts/create-harness.sh`, `.agents/skills/`, `.claude/commands/`, scaffold template 구현 변경은 비범위다.
- auth-session pack, planning-pack resolver, archive decision surfacing은 인접 후보로 둔다.
- product evidence는 source 결정의 근거로만 사용한다. product-local 구현을 source-owned로 즉시 끌어올리지 않는다.

## Initial Direction (R1 전 미확정)

| 항목 | 초기 입장 | R1 질문 |
| --- | --- | --- |
| D-21 착수 순서 | 지금 여는 것이 타당. 이유는 auth-session/resolver 선행이 아니라 product evidence가 D-21 design original(`docs/packs/*`)과 이미 divergence를 보였기 때문이다 | auth-session/resolver 이후가 더 맞나 |
| 문서셋 범위 | 4개 evidence surface만 결정하고, 나머지는 D-21 default rule + 재검토 trigger로 보류한다 | scope가 충분히 좁은가 |
| `ADOPTER-RENAME` | product-owned seed가 기본, source acceptance 승격은 leak-check 기준만 최소화 가능 | 승격 유지비가 과한가 |
| `TEMPLATE-ACCEPTANCE` | keystone은 유지하되 pack별 full log를 흡수하지 않고 acceptance contract와 evidence pointer만 둔다 | 너무 커지는가 |
| pack docs 위치 | product evidence는 `pack/{name}/README`만 지지한다. `docs/packs/*`는 D-21 design original이므로 바꾸려면 supersede/DR-worthy로 다룬다 | 어느 쪽을 source template 표준으로 삼아야 하나 |
| DR set 분리 | product DR은 적용 기록, source DR은 template policy. 번호·본문 import 금지 | 분리 기준이 충분한가 |

## Risk

| Risk | Level | Mitigation |
| --- | --- | --- |
| D-21이 full document-set writing으로 번짐 | Medium | Scope Guard와 Done Criteria에서 boundary-only로 고정 |
| product-local evidence를 source-owned로 과잉 승격 | Medium | `product-owned` / `scaffold-seed` / `pack-conditional` 라벨을 별도 둠 |
| `TEMPLATE-ACCEPTANCE`가 모든 pack 로그를 삼키는 거대 문서가 됨 | Medium | contract + pointer 방식으로 제한하는 decision 포함 |
| Work 내부 decision이 다시 묻힘 | Low | DR-worthy 판단과 backlog 반영 필요 여부를 closeout에서 확인 |

## Done Criteria

- [x] Claude B R1 red-team review가 기록된다.
- [x] R1 finding에 대한 Codex A response와 consensus가 기록된다.
- [x] D-21 lock과의 관계가 구분된다: lock 빈 영역 보강인지, D-21 locked premise supersede인지.
- [x] 4개 evidence surface가 2축(`ownership`, `nature`)으로 분류된다.
- [x] ownership 판정 test가 명시된다: source-owned / scaffold-seed / product-owned를 가르는 기준이 각 surface에 적용된다.
- [x] 나머지 document-set surface의 default rule과 재검토 trigger가 명시된다.
- [x] `ADOPTER-RENAME` 소유권과 source acceptance 승격 여부가 결정된다.
- [x] `TEMPLATE-ACCEPTANCE`가 pack acceptance evidence를 흡수하는 방식과 제한선이 결정된다.
- [x] pack docs 위치 기준(`pack/{name}/README` vs `docs/packs/*`)이 결정된다.
- [x] product DR과 source DR 분리 기준이 결정된다.
- [x] `template-acceptance-matrix.md`(maintainer planning artifact)와 `docs/TEMPLATE-ACCEPTANCE.md`(adopter shipped derived)의 관계가 명시된다.
- [x] 결론에 `code-product-informed` 한정 라벨과 첫 non-code/manual adopter 재검토 trigger가 명시된다.
- [x] DR-worthy 여부와 기록 위치(신규 DR 또는 Work 내 decision)가 명시된다. D-21 locked premise를 바꾸는 결정은 DR/supersede 없이는 close하지 않는다.
- [x] Claude result review와 Codex response가 기록된다.
- [x] Owner 최종 승인 후 `/work-close` 대상 상태가 된다.

## Verification

- D-21 후보 payload와 CHORE-20260620-001 delta 대조
- `document-set-scaffold.md`, `decision-table.md`, `template-acceptance-matrix.md`와 decision matrix 일치 확인
- 필요 시 `spring-modular-template` product evidence spot-check
- 문서 변경: `git diff --check`
- scaffold/code 변경 없음 확인

## Cross-Agent Review

### R1 Review Request — Claude B

Claude B는 cross-agent red team reviewer로서 아래를 검토한다.

- **작업 순서:** D-21을 지금 여는 것이 맞나, 아니면 auth-session/resolver 이후가 맞나?
- **scope 경계:** full 문서 작성으로 scope가 새지 않게 경계가 충분한가?
- **소유권 기준:** source-template-owned와 product-owned 기준이 source 쪽으로 과도하게 끌려가지 않나?
- **ADOPTER-RENAME:** source acceptance로 승격하면 유지비가 과해지지 않나?
- **pack docs 위치:** `pack/{name}/README`와 `docs/packs/*` 중 어떤 기준이 맞나? 둘을 나눠야 한다면 역할은 무엇인가?
- **TEMPLATE-ACCEPTANCE:** 너무 거대한 문서가 되지 않게 evidence 흡수 방식을 어떻게 제한해야 하나?
- **근거 정합성:** `base-msa-template-techreq-gap-analysis-20260619.md` §6.4의 design original과 `document-set-scaffold.md`·CHORE-20260620-001 delta 사이에 충돌하거나 오래된 전제가 남아 있나?
- **DR-worthy:** 이 결정은 DR로 남길 수준인가, Work 내 decision으로 충분한가?

Expected output: P1/P2/P3 findings + direction-level concern 최소 1개(또는 "없음") + 각 finding별 accept/defend/revise 가능한 recommendation.

### R1 Review Result — Claude B

**결론:** 착수는 타당하나 plan은 3가지 구조적 결함을 안고 있어 그대로 진행하면 "검증 가능한 경계 결정"이 아니라 "lock 위에서 증거 없이 넓힌 결정"이 된다. (1) D-21이 이미 🔒 v1.0 LOCKED(2026-06-19)인데 plan이 인지하지 않음 — 일부 결정(pack docs 위치)이 lock-cited §6.4의 `docs/packs/` 전제를 바꾸는데 supersede 경로가 없다. (2) 소유권 축과 전달 형태 축을 하나의 5-way 분류로 섞은 category error. (3) 14 surface 중 실증 evidence가 있는 건 4개뿐인데 전부 분류하려는 speculative inventory.

**P1 — 결정 산출 전 반드시 해소**

| # | Finding | 근거 | Recommendation |
|---|---|---|---|
| P1-1 | D-21 LOCK 미인지 + supersede 경로 부재. `decision-table.md` D-21은 `🔒 v1.0 LOCKED`, 재검토 trigger `—`이고 lock 문구가 §6.4를 인용. §6.4·`document-set-scaffold.md §3`은 pack 조건부 문서를 `docs/packs/*`에 둔다. Q5 결정이 이 전제를 바꾸면 자유 결정이 아니라 TEMPLATE-EVOLUTION supersede 사안. Slice C는 "Work 내 decision 충분" 가능성을 두고 `related_dr: []`. | `decision-table.md:5,29`, `document-set-scaffold.md:31` | revise — "D-21 lock 관계" 구분 명시: (a) lock 빈 영역을 채우는 결정(자유) vs (b) lock-cited 전제를 바꾸는 결정(supersede/DR 필수). 후자 최소 1건(pack docs)이므로 `related_dr`를 `[]`로 close 금지. |
| P1-2 | 소유권 축 × 전달 형태 축 혼선(category error). 5-way flat 분류는 *누가 유지하나*와 *어떻게 전달되나*를 한 평면에 섞음. pack-conditional 문서도 source/product 양쪽 가능 → 셀 모호. backlog Done Criteria는 3-way만 요구해 plan과 불일치. | Work `Slice A:57-62`, `HARNESS.md:257` | revise — 2축 분리: 축1 ownership(source-template / scaffold-seed / product-owned), 축2 nature(core-required / pack-conditional / guide-only). |

**P2 — 결정 품질에 직접 영향**

| # | Finding | 근거 | Recommendation |
|---|---|---|---|
| P2-1 | Speculative full-inventory(Q2). "쓰기 금지"는 막혔으나 Slice A는 ~25 surface 분류. 실증 evidence는 4개뿐(ADOPTER-RENAME, TEMPLATE-ACCEPTANCE, pack docs 위치, DR set). 나머지(API-GUIDE·TESTING-GUIDE…)는 product가 미작성 → 분류=추측(BEHAVIOR §2 위반의 문서판). | `document-set-scaffold.md:6-26`, product `docs/packs/` 부재 | revise — inventory를 evidence/conflict 있는 surface로 좁히고, 나머지는 "default: source-template-owned thin+pointer per D-21, 개별 결정 보류" 단일 규칙으로. |
| P2-2 | Ownership 판정 *기준(test)* 부재(Q3). 5 라벨만 있고 source vs product 판정 규칙이 없어 주관적·양방향 drift. Q3가 우려한 "source 과잉 끌림" 방지 장치 자체가 없음. | Work Slice A, Initial Direction 표 | revise — 명시 test 추가. 예: source-owned ⇔ 모든 adopter가 충족해야 하는 template invariant/acceptance 인코딩 / product-owned ⇔ 특정 적용의 local 선택 기록. |
| P2-3 | pack docs `docs/packs/*` 미증거 institutionalize(Q5). 제품은 `pack/{name}/README`만 보유, `docs/packs/` 부재. plan은 "둘 다(split-role)"를 두자 하나 `docs/packs/*` 카탈로그는 adopter 수요 없음. | `pack/local-deploy/README.md`·`pack/observability-export/README.md` 존재, product `docs/packs/` 부재 | revise — `pack/{name}/README`를 source-template 표준 확정(evidence-backed). `docs/packs/*` index는 3+ pack adopter 수요 전까지 deferred/guide-only. 두 위치 동시 lock 금지. |

**P3 — 정합성·근거 보정**

| # | Finding | Recommendation |
|---|---|---|
| P3-1 | 시퀀싱 근거 약함(Q1). "auth-session/resolver 이전에 열어야 문서 위치 재발견 방지"는 결합 약함(resolver=provides/requires, auth-session=pack mechanism, doc-set과 직접 의존 없음). 진짜 trigger는 "제품이 design original `docs/packs/`에서 이미 이탈"한 concrete conflict. | revise 근거(착수는 accept) — 시퀀싱 정당화를 "기존 divergence 해소"로 교체. |
| P3-2 | 단일 제품 evidence 한정 라벨 누락. 모든 근거가 `spring-modular-template`(code product). CHORE-001이 no-code adopter 미검증 gate 명시했는데 결론에 한정 미부착. | revise — 결론에 "code-product-informed, 첫 non-code adopter에서 ownership 재검토" trigger 부착. |
| P3-3 | 근거 stale. §6.4 maintainer 목록 `TEMPLATE-EVOLUTION (D-1~D-21)`은 현재 decision-table D-1~D-24와 불일치. | accept(note) — 본 결정에 §6.4를 "D-21 범위" 근거로 인용 금지, 주석/backlog로만. |
| P3-4 | 이름 충돌. `TEMPLATE-ACCEPTANCE.md`(shipped adopter keystone)와 `template-acceptance-matrix.md`(maintainer planning artifact) 관계 미정 → 중복/혼동. | revise — decision에 1줄: matrix = maintainer planning source, ACCEPTANCE.md = adopter shipped derived. |

**Direction-level concern:** 이 Work는 "검증 가능한 경계 결정"을 표방하지만 실제 구조는 ① 이미 lock된 D-21 위에서 ② 단일 code product evidence로 ③ 14 surface 중 4개만 실증을 가진 채 대부분의 경계를 증거 없이 결정하려 한다. anti-burial 명분은 정당하나, 진짜 anti-burial은 "지금 모든 surface 분류"가 아니라 "evidence 있는 4개를 정확히 결정하고 나머지는 default rule + 재검토 trigger로 *명시적으로 미루는 것*"이다. 결정을 진공에서 넓히면 다음 adopter에서의 supersede 부채가 되어 burial을 형태만 바꿔 재생산한다.

**질문별 accept/defend/revise 요약**

| Q | 판정 | 한 줄 |
|---|---|---|
| Q1 지금 여나 | accept(착수) + revise(근거) | 열되 정당화를 "product divergence 해소"로 (P3-1). |
| Q2 scope 충분한가 | revise | speculative 분류 leak 미차단 (P2-1). |
| Q3 source 과잉 끌림 | defend(라벨) + revise(판정 test) | 방향 OK, 기준 부재가 구멍 (P2-2). |
| Q4 ADOPTER-RENAME 유지비 | defend | leak-check acceptance만 승격=저비용, split 명시. |
| Q5 pack docs 위치 | revise | `pack/{name}/README` 확정, `docs/packs/*` deferred + lock supersede 플래그 (P2-3, P1-1). |
| Q6 TEMPLATE-ACCEPTANCE 비대화 | defend(contract+pointer) + revise(gate·이름) | 6축 contract + per-pack status + evidence pointer, 실행 로그 inline 금지 (P3-4). |

### R1 A Response — Codex A

Claude B의 R1은 **수용한다**. 핵심은 "D-21을 지금 열지 말자"가 아니라, "D-21을 이미 lock된 결정으로 인정하고, 실제 evidence가 있는 4개 surface만 결정하자"다. 내 초기 plan은 D-21 전체 surface inventory를 너무 넓게 잡았고, `ownership`과 `nature`를 한 축으로 섞었다. 이대로 진행하면 full 문서 작성은 피하더라도 "증거 없는 문서 경계 결정"으로 새는 문제가 생긴다.

| Finding | A 판정 | 반영 |
| --- | --- | --- |
| P1-1 D-21 LOCK 미인지 + supersede 경로 부재 | **Accept / revise** | Scope에 D-21 lock 관계 판정을 선행 step으로 추가했다. pack docs 위치처럼 §6.4 전제를 바꾸는 항목은 Work 내 decision만으로 close하지 않고 DR/supersede 필요 여부를 명시한다. `related_dr`는 실제 DR 생성 전까지 비워두되, Done Criteria에 "D-21 locked premise를 바꾸는 결정은 DR/supersede 없이는 close 금지"를 추가했다. |
| P1-2 소유권 축 × 전달 형태 축 혼선 | **Accept / revise** | flat 5-way 분류를 폐기하고 2축으로 분리했다: ownership(`source-template-owned / scaffold-seed / product-owned`)과 nature(`core-required / pack-conditional / guide/recipe-only`). |
| P2-1 speculative full-inventory | **Accept / revise** | 전체 14+ surface 확정은 중단한다. 이번 Work는 evidence가 있는 4개 surface(`ADOPTER-RENAME`, `TEMPLATE-ACCEPTANCE`, pack docs, product DR set)만 결정한다. 나머지는 D-21 default rule + 재검토 trigger로 보류한다. |
| P2-2 ownership 판정 test 부재 | **Accept / revise** | Decision Output에 판정 test를 넣는다. 초안 기준: source-owned = 모든 adopter에게 적용되는 template invariant 또는 acceptance contract, scaffold-seed = source가 seed를 주지만 target이 project state로 소유, product-owned = 특정 적용의 local 선택·운영 기록. |
| P2-3 `docs/packs/*` 미증거 institutionalize | **Accept / revise** | product evidence가 지지하는 표준은 `pack/{name}/README`다. `docs/packs/*`는 design original에는 있으나 제품 evidence가 없으므로 deferred/guide-only 또는 supersede 대상으로 둔다. 두 위치를 동시에 lock하지 않는다. |
| P3-1 시퀀싱 근거 약함 | **Accept / revise** | 착수 근거를 "auth-session/resolver 이전"에서 "product evidence가 D-21 design original과 이미 divergence를 보였기 때문"으로 바꿨다. |
| P3-2 단일 제품 evidence 한정 라벨 누락 | **Accept / revise** | Decision Output에 `code-product-informed` 라벨과 "첫 non-code adopter에서 ownership 재검토" trigger를 붙인다. |
| P3-3 근거 stale | **Accept with note** | §6.4는 design original로만 쓰고, 현재 authoritative decision은 `temp/decision-table.md` D-21~D-24와 이후 CHORE-20260620-001 delta로 본다. `TEMPLATE-EVOLUTION (D-1~D-21)` 같은 stale 표현은 본 결정의 직접 근거로 쓰지 않는다. |
| P3-4 `TEMPLATE-ACCEPTANCE` 이름 충돌 | **Accept / revise** | Decision Output에 관계를 명시한다: `template-acceptance-matrix.md`는 maintainer planning source, `docs/TEMPLATE-ACCEPTANCE.md`는 adopter shipped derived artifact다. |

**수정된 Work shape:**

- D-21은 지금 연다.
- 단, "D-21 전체 문서셋 재분류"가 아니라 "product evidence가 충돌을 만든 4개 surface의 boundary decision"으로 축소한다.
- 4개 surface 외 항목은 D-21 기본값을 유지하고, 첫 non-code adopter 또는 2번째 product evidence에서 재검토한다.
- pack docs 위치는 `pack/{name}/README`를 evidence-backed current standard로 본다. `docs/packs/*`를 계속 유지하려면 D-21 design original supersede 여부를 DR-worthy로 판단한다.
- `TEMPLATE-ACCEPTANCE`는 모든 실행 로그를 모으는 문서가 아니라 contract + per-pack status + evidence pointer로 제한한다.

**Owner 승인 전제:** 이 response 기준으로 다음 분석을 진행한다. 즉, 분석 산출물은 4개 evidence surface의 2축 matrix, D-21 lock/supersede 판정, DR-worthy 판단, non-code adopter 재검토 trigger까지다. Full document-set 작성과 scaffold 구현은 계속 비범위다.

### R1 Consensus Check — Claude B

Claude B consensus 확인: R1 finding 9건은 모두 closed. 단, B가 별도 확인 조건을 남겼다.

- P2-2 ownership 판정 test는 Decision Output에서 빠지면 안 된다.
- P3-2 `code-product-informed` 한정 라벨과 첫 non-code/manual adopter 재검토 trigger는 Decision Output에서 빠지면 안 된다.

Codex A 조치: 두 항목을 Done Criteria에 명시적으로 추가했다. Result Review에서도 누락 여부를 확인한다.

## Decision Output

### Decision Scope Label

이 결정은 **code-product-informed**다. 근거는 `spring-modular-template`의 agent-mediated code product 적용 결과이며, manual external adopter 또는 no-code scaffold target 검증은 아직 없다. 따라서 첫 non-code/manual adopter에서 ownership 기준과 pack docs 위치를 재검토한다.

### Ownership Test

| 판정 | Test |
| --- | --- |
| `source-template-owned` | 모든 adopter가 충족해야 하는 template invariant, acceptance contract, 또는 source가 유지해야 하는 경계 정책이다. product별 값·운영 선택 없이도 source가 일반 기준으로 검증할 수 있다. |
| `scaffold-seed` | source가 초기 파일/체크리스트를 제공하지만, scaffold 이후 target repo가 자기 project identity·환경·운영 판단으로 수정하고 소유한다. source는 seed shape와 최소 acceptance만 유지한다. |
| `product-owned` | 특정 product 적용의 local 선택, 구현 기록, 운영 decision, 또는 product context에 묶인 DR/Work evidence다. source는 직접 흡수하지 않고 import-candidate나 precedent로만 참조한다. |

Nature axis는 별도로 둔다.

| 판정 | Test |
| --- | --- |
| `core-required` | core template이 항상 제공해야 하며, pack 선택과 무관하게 존재한다. |
| `pack-conditional` | 특정 pack 선택 또는 pack 합성 시에만 나타난다. |
| `guide/recipe-only` | runnable/support acceptance를 보장하지 않는 안내·레시피다. 승격하려면 별도 evidence가 필요하다. |

### Boundary Matrix (4 Evidence Surfaces Only)

| Surface | Evidence | Ownership | Nature | Decision |
| --- | --- | --- | --- | --- |
| `ADOPTER-RENAME` seed checklist | product `docs/ADOPTER-RENAME.md`가 package/group/app name/compose/OpenAPI/MyBatis/ArchUnit/test/docs/env prefix까지 교체 대상으로 열거 | `scaffold-seed` | `core-required` adoption seed | source는 rename tooling을 만들지 않는다. Source는 seed checklist shape만 제공하고, scaffold 이후 target repo가 실제 값·항목 확장·문서 위치를 product state로 소유한다. |
| `ADOPTER-RENAME` leak-check contract | product `docs/ADOPTER-RENAME.md`가 `rg "com\\.example\\.modular\|spring-modular-template\|io\\.kyungseo"` leak check와 acceptance를 제공 | `source-template-owned` | `core-required` acceptance contract | placeholder leak-check pattern과 "의도한 안내 외 0건" acceptance는 모든 adopter에게 적용되는 template invariant다. Full rename automation은 future gated로 남긴다. |
| `TEMPLATE-ACCEPTANCE` | `template-acceptance-matrix.md`와 product pack README가 `run/test/reset/observe/replace/remove` evidence를 pack별로 남김 | `source-template-owned` | `core-required` keystone + `pack-conditional` rows | `docs/TEMPLATE-ACCEPTANCE.md`는 shipped adopter artifact로 두되, 실행 로그를 inline 수집하지 않는다. source는 acceptance contract, per-pack status, evidence pointer만 유지한다. pack별 상세 evidence는 해당 pack README 또는 Work/DR로 pointer 처리한다. |
| pack docs 위치 | product에는 `docs/packs/`가 없고 `pack/local-deploy/README.md`, `pack/observability-export/README.md`만 존재. DR-032/033도 `pack/{name}/` 레이아웃과 substrate/합성 경계를 확정 | `source-template-owned` for location rule, pack content는 `pack-conditional` target-owned after scaffold | `pack-conditional` | evidence-backed current standard는 `pack/{name}/README.md`다. `docs/packs/*`는 product evidence가 없으므로 지금 source standard로 lock하지 않는다. 다만 D-21 design original §6.4의 pack-docs 경로 가정이 `docs/packs/*`였으므로, 이 변경은 **§6.4 pack-docs path assumption**의 부분 supersede 후보로 본다. |
| product DR set (`DR-030~033`) | product DR들은 planning-pack v1.0 LOCKED를 재결정하지 않고 `spring-modular-template`에 적용한 기록이며, 모두 "planning-pack을 바꾸려면 TEMPLATE-EVOLUTION supersede"를 명시 | `product-owned` | `core-required` 또는 `pack-conditional` 적용 기록 | source DR로 번호/본문을 import하지 않는다. source는 product DR에서 generalizable principle만 추출해 후보/DR로 승격한다. product 적용 기록은 product repo에 남긴다. |

### Default Rule For Non-Evidence Surfaces

이번 Work는 D-21의 나머지 core 문서 전체를 새로 분류하지 않는다. 기본값은 아래로 둔다.

- D-21 core 14문서는 기존 lock을 유지한다: source가 thin+pointer seed와 문서 완료 기준을 제공하고, scaffold 이후 target repo가 project state로 채운다.
- 각 문서의 구체 내용이 product-local implementation 또는 pack-specific evidence를 요구하면 그 부분만 `product-owned` 또는 `pack-conditional`로 분리한다.
- 새 product evidence 2건 이상에서 같은 문서 위치/소유권 drift가 반복되거나, 첫 non-code/manual adopter에서 적용 비용이 확인되면 D-21 재검토 trigger로 올린다.

### TEMPLATE-ACCEPTANCE Naming Relationship

`temp/template-acceptance-matrix.md`는 maintainer planning source다. `docs/TEMPLATE-ACCEPTANCE.md`는 shipped adopter artifact로, matrix에서 파생되는 acceptance contract를 target repo가 읽을 수 있게 얇게 제공한다.

따라서 `docs/TEMPLATE-ACCEPTANCE.md`는 "모든 검증 로그의 창고"가 아니다. 포함 범위는 아래로 제한한다.

- core와 선택된 pack의 acceptance row
- 각 row의 required command / observable evidence / remove boundary
- 실제 검증 결과가 있는 Work, DR, pack README pointer
- 미검증 pack은 `guide/recipe-only` 또는 `candidate`로 표시

### D-21 Lock / Supersede Assessment

| Item | Lock relation | Assessment |
| --- | --- | --- |
| `ADOPTER-RENAME` | D-21의 빈 영역을 채우는 보강 | Work 내 decision으로 충분. source acceptance는 leak-check contract까지, tooling은 future gated. |
| `TEMPLATE-ACCEPTANCE` | D-21 keystone 구체화 | Work 내 decision으로 충분. D-18/D-21 방향과 정합한다. |
| pack docs 위치 | D-21 design original §6.4의 `docs/packs/*` 경로 가정과 충돌 | **DR-worthy / narrow supersede 필요.** `pack/{name}/README.md`를 current source standard로 채택하려면 core D-21 전체가 아니라 §6.4 pack-docs path assumption을 부분 supersede한다는 기록이 필요하다. 이 Work만으로 close하지 않는다. |
| product DR set 분리 | D-21 외부 적용 기록 정리 | Work 내 decision으로 충분. product DR은 source DR로 import하지 않는다. |

### DR-Worthy Verdict

신규 DR이 필요하다. 이유는 pack docs 위치가 D-21 core decision 전체가 아니라, D-21이 인용한 design original §6.4의 pack-docs 경로 가정(`docs/packs/*`)을 부분적으로 바꾸기 때문이다.

제안: `/record-decision`으로 "§6.4 pack docs path assumption supersede"를 기록한다.

초안 결정:

- supported runnable pack의 canonical local documentation은 `pack/{name}/README.md`에 둔다.
- `docs/packs/*`는 pack index 또는 adopter-facing aggregate guide가 실제 수요로 확인될 때만 생성한다.
- `docs/TEMPLATE-ACCEPTANCE.md`는 pack README를 evidence pointer로 참조한다.
- 이 DR은 **code-product-informed**다. 근거는 `spring-modular-template` code product evidence이며, 첫 non-code/manual adopter에서 재검토한다.
- 이 결정은 D-21 자체를 재작성하지 않고, design original §6.4의 "pack 조건부 문서 = `docs/packs/*`" 경로 가정만 부분 supersede한다.

### Resulting Work Shape

이번 Work는 Decision Output만으로는 아직 close하지 않는다.

남은 필수 단계:

1. Owner가 위 Decision Output을 승인한다.
2. §6.4 pack-docs path assumption supersede DR을 기록한다. → DR-041 완료.
3. 이 Work의 `related_dr`에 DR-041을 연결한다. → 완료.
4. Claude result review에서 조건부 승인 항목이 모두 닫혔는지 확인한다. → 완료.

## Result Review

### Result Review — Claude B

**판정:** Conditional approve. R1 9개 finding 본문 반영은 확인됐다. 단 close 전 아래 3개를 보완해야 한다.

| ID | Severity | Finding | Recommendation |
| --- | --- | --- | --- |
| P2-a | P2 | `ADOPTER-RENAME`이 자기 Ownership Test와 모순된다. seed checklist는 scaffold-seed지만 leak-check contract는 모든 adopter에게 적용되는 acceptance invariant라 source-owned다. | `ADOPTER-RENAME`을 seed checklist와 leak-check contract로 split한다. |
| P3-a | P3 | supersede DR 범위가 "core D-21"처럼 넓게 읽힌다. 실제 변경은 §6.4의 pack-docs 경로 가정이다. | DR scope를 "§6.4 pack-docs path assumption supersede"로 낮춘다. |
| P3-b | P3 | DR 초안이 `code-product-informed` caveat을 상속하지 않는다. | DR 초안에도 code product evidence 기반, 첫 non-code/manual adopter 재검토 trigger를 포함한다. |

### Result Review A Response — Codex A

Claude B의 conditional approve를 수용하고 3건 모두 반영했다.

| Finding | A 판정 | 수정 |
| --- | --- | --- |
| P2-a | **Fixed** | `ADOPTER-RENAME`을 `seed checklist`(`scaffold-seed`)와 `leak-check contract`(`source-template-owned`)로 분리했다. |
| P3-a | **Fixed** | supersede 표현을 core D-21 전체가 아니라 `§6.4 pack-docs path assumption` 부분 supersede로 좁혔다. |
| P3-b | **Fixed** | DR 초안에 `code-product-informed` caveat과 첫 non-code/manual adopter 재검토 trigger를 추가했다. |

**조건부 승인 후 남은 것:** Owner가 수정된 Decision Output과 §6.4 pack-docs path assumption supersede DR 생성 여부를 승인해야 한다.

## Checkpoints

| CP | Description | Status |
| --- | --- | --- |
| 1 | branch isolation, session-start, work-plan pre-check | done |
| 2 | Work 파일 생성 및 R1 request 작성 | done |
| 3 | Claude B R1 review 수신 | done |
| 4 | R1 response와 consensus 기록 | done |
| 5 | Owner 분석/문서 변경 승인 | done |
| 6 | D-21 boundary decision 작성 | done |
| 7 | Claude result review와 response | done |
| 8 | Owner 최종 승인 및 `/work-close` | done |
| 9 | commit, PR, merge | pending |

## Next Actions

- ✓ `feature/chore-20260620-002-template-document-boundary` branch 생성
- ✓ Work 파일 생성 및 R1 request 작성
- ✓ Claude B R1 review 수신·기록 (P1 2 / P2 3 / P3 4 + direction-level concern)
- ✓ Codex A finding별 accept/defend/revise response 작성
- ✓ Owner 승인 후 D-21 boundary decision 작성
- ✓ Owner Decision Output 승인 및 §6.4 pack-docs path assumption supersede DR 생성 여부 확인
- ✓ DR-041 생성 및 Work 연결
- ✓ `/work-close` 처리: Work Done, backlog 후보 제거, STATUS Active pointer 제거
- → commit/PR finalization gate

## Discovery

- 2026-06-20 archive 처리: Done 처리와 PR merge가 완료되어 live Done index에서 archive-side index로 이동한다.
- `docs/STATUS.md` Active Work는 비어 있었고, CHORE-20260620-001은 Done (Archive Pending) 상태다.
- Branch Isolation Check: source-gitflow mode에서 `develop` 직접 작업은 실패 조건이므로 feature branch로 분리했다.
- Backlog 후보에는 CHORE-20260620-001의 D-21 delta payload가 이미 반영되어 있어, 이번 Work는 해당 payload를 재발견하지 않고 결정으로 좁힐 수 있다.
- 관련 retrospective는 source-owned / product-owned / import-candidate 경계를 유지해야 한다는 반복 리스크를 뒷받침한다.
- 사용자 지적으로 `temp/base-msa-template-techreq-gap-analysis-20260619.md`를 확인했다. 이 파일의 §6.4는 `document-set-scaffold.md`의 design original로, 이번 Work에서 원안 의도와 이후 evidence delta를 대조하는 핵심 근거다.
- Claude B R1 결과, 이번 Work는 전체 document-set inventory가 아니라 4개 evidence surface만 결정하는 쪽으로 축소됐다. `ownership`과 `nature`를 분리하고, D-21 lock premise 변경은 DR/supersede 없이는 close하지 않는 기준을 추가했다.
- Claude B result review는 conditional approve. 3개 조건을 반영했다: `ADOPTER-RENAME` seed/contract split, supersede scope를 §6.4 pack-docs 경로 가정으로 축소, DR 초안에 `code-product-informed` caveat 상속.
- Owner 승인 후 DR-041을 생성했다. 이 DR은 D-21 core decision 전체가 아니라 design original §6.4의 pack-docs path assumption만 부분 supersede한다.
- `/work-close`로 Work Done 처리했다. commit/PR/merge는 별도 finalization gate에서 진행한다.
