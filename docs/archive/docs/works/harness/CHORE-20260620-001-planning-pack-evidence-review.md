---
id: CHORE-20260620-001
priority: P1
status: Archived
risk: L2
scope: spring-modular-template의 5+ 사이클 code-product evidence를 source repo 관점에서 되짚어 source-owned/product-owned/import-candidate 경계를 실측하고, 인접 후보·DR로 라우팅한다. 추출·분류·라우팅까지이며 resolver/scaffold/template 구현과 no-code 재온보딩은 별도 축.
appetite: 1d
planned_start: 2026-06-20
planned_end: 2026-06-20
actual_end: 2026-06-20
related_dr: []
related_troubleshooting: []
related_work: []
---

# CHORE-20260620-001: Planning-pack Evidence Review (spring-modular-template code-product)

## Top Summary

`spring-modular-template`에서 prepared brief → scaffold onboarding → PRODUCT backlog → selective import → Work closeout 흐름이 **5+ 사이클**(FEAT-001~005, DR-030~033) 실행됐다. 이 Work는 그 결과를 **source repo(harness) 관점에서 되짚어** CHORE-20260612-001이 provisional로 남긴 `source-owned / product-owned / import-candidate` 경계를 실측한다.

이 Work는 **추출·분류·라우팅**까지다. 한 mega-Work에서 모두 해결하지 않는다(scope sprawl 회피, 이전 라운드의 anti-premature 규율 유지):

- resolver/pack-metadata/scaffold 배포/template화 구현 → 별도 후보 `Planning-pack template/scaffold integration model`로 라우팅(이 후보의 명시적 제외 경계, HARNESS.md).
- product pack 산출물의 source import 구현 → `Spring modular/product engineering option-pack` 후보로 라우팅.
- **fresh no-code scaffold 재온보딩 검증은 별도 축**이며 이 Work에 섞지 않는다(code-product evidence와 no-code evidence를 혼합 결론하지 않음).

이 Work의 산출물은 **분류표 + 라우팅 등록 + acute gap 처리(archive 결정 매몰)**이지, 반성문이 아니다.

## Collaboration Workflow

cross-agent review를 전제로 진행한다. 역할은 직전 라운드와 동일하다.

| Role | Agent | Responsibility |
| --- | --- | --- |
| A | Claude | author/driver. Work 파일, plan, 분석, response 작성 |
| B | Codex | red team reviewer. 내적 정합성을 넘어 evidence-review의 scope 경계·분류 타당성·라우팅 정확성을 의심 |
| Owner | User | 최종 방향 승인, 등록/DR 승인, `/work-close`, commit, PR, merge 승인 |

진행: 사용자 지시 → A plan → B R라운드 → 합의 → A 분석/등록 → B 결과 검토 → 사용자 승인 → `/work-close` → commit → PR(`--base develop`) → merge. 논의는 `Cross-Agent Review`에 누적한다.

## Context Manifest

| 순서 | 파일 | 왜 |
| --- | --- | --- |
| 1 | `docs/backlog/HARNESS.md` `First concrete planning-pack evidence review` 외 인접 후보 | candidate scope(stale, P1 시점)·라우팅 대상 |
| 2 | `~/dev-home/vibe/spring-modular-template/docs/decisions/DR-030~033` | pack/multi-pack/조건부 dep/경계 결정 evidence |
| 3 | `~/dev-home/vibe/spring-modular-template/docs/archive/docs/works/product/` | FEAT-001~005 archived Work(결정 매몰 표면) |
| 4 | `temp/decision-table.md`, `core-pack-boundary.md`, `import-candidate-map.md` | D-24 prepared-brief flow·import 경계 원본 |
| 5 | `~/dev-home/vibe/spring-modular-template/pack/`, `Makefile`, `ADOPTER-RENAME.md` | pack precedent·multi-pack 합성 산출물 |

Trigger: product 5+ 사이클 완료로 evidence 충분 + 사용자 선택 "review-first". archive 결정 매몰(auth-session 수동 승격)이 active gap으로 노출됨.

## Scope

### Slice A — Evidence Inventory And Ownership Classification

- product 5+ 사이클 산출물을 열거하고, 각 패턴을 (R1 F2) **3단 라벨**로 분류한다: `generalizable principle`(source) / `product-local implementation` / `import-candidate artifact`.
  - 예: 조건부 dep(`-PobservabilityExport`)=product-local impl ↔ "pack 경계=app artifact surface, selected vs resolved pack set"=source principle. multi-pack compose-override=product-local impl ↔ "substrate 위 합성 + 두-pack guard"=principle. published-API seam=auth 구현 ↔ module API seam=principle.
- CHORE-20260612-001의 provisional 경계가 실측에서 유지됐는지 판정한다.

### Slice B — Boundary Validation (D-24 prepared-brief flow)

- D-24 prepared-brief flow가 실제로 작동했는지: planning-pack을 target repo에 **통째 복사하지 않고** prepared brief로 소비한 경계가 유지됐는가.
- adopter rename/placeholder leak check를 source acceptance로 끌어올릴지 판정(현재 product-local `ADOPTER-RENAME.md`).

### Slice C — Acute Gap: Archive Decision Burial (durable closure, R1 F1)

- **active gap**: archived Work의 결정이 현재 backlog로 자동 승격되지 않는다(auth-session 후보는 FEAT-002 split을 수동 발굴해야 떴다).
- (R1 F1) closure를 **제안에 그치지 않고 durable하게** 산출한다 — 최소 하나: (a) 관련 backlog 후보에 archive-burial handling rule/근거 직접 주석, (b) "archive 시 결정 surfacing" process 보완을 신규 backlog candidate로 등록, (c) DR-worthy면 Draft DR. **live backlog에서 검색 가능**해야 한다(이 Work 파일을 다시 파지 않아도). 구현은 후속이어도 discovery surface는 이 Work에서 만든다.

### Slice D — Routing Registrations (durable payload, solve 아님)

- pack resolver → `Planning-pack template/scaffold integration model` 후보에 (R1 F3) **concept payload** 주석: pack catalog `provides/requires/conflicts/modes`, target manifest `selected_packs/resolved_packs/resolution.added`. 구현은 그 후보 gate.
- product pack 산출물 source import 후보 → `Spring modular/product engineering option-pack` 후보에 구체 목록 등록(principle/artifact 라벨 동반).
- (R1 F5) D-21: 구현 비범위 유지하되 `document-set-scaffold.md` 대비 **delta matrix** 작성: ADOPTER-RENAME=product-owned seed, TEMPLATE-ACCEPTANCE=pack acceptance evidence 흡수, pack docs 위치(`docs/packs/*` vs pack README)=D-21 결정.

### Slice E — Output Consolidation

- 분류표(3단)·라우팅 durable payload·archive-burial closure를 정리. DR-worthy면 제안.
- (R1 F4) output에 **"code-product evidence only" 라벨 + negative conclusion**: prepared-brief flow는 agent-mediated code-product에서 작동했으나 manual external adopter·no-code target은 미검증 → 별도 gate. stale HARNESS 후보 Done Criteria(no-code 재온보딩 포함분) 정리.

## Initial Direction (A 제안, R1 전 미확정)

| 항목 | 초기 입장 | R1 질문 |
| --- | --- | --- |
| scope 경계 | 추출·분류·라우팅까지. resolver/scaffold/no-code는 라우팅/분리 | 과소 scope인가? archive-burial까지 여기서 닫는 게 맞나 |
| archive-burial | acute gap, closure 방식은 신규 candidate 또는 경량 DR | source repo 일반 문제인가, 이 Work 산출물인가 |
| import 분류 | 조건부 dep·multi-pack 합성·published-API seam은 source-generalizable 후보, ADOPTER-RENAME·compose 값은 product-local | 분류가 맞나, 일반화 시기상조 항목은 |
| D-21 | 기준만 결정, 구현 분리 | 기준 결정조차 D-21로 미뤄야 하나 |

## Risk

| Risk | Level | Mitigation |
| --- | --- | --- |
| evidence-review가 sprawl해 mega-Work화 | Medium | 라우팅 등록으로 출력, candidate 경계 준수(템플릿/scaffold 제외) |
| stale candidate scope(P1 시점)로 새 evidence 누락 | Medium | scope를 5-사이클 현실로 갱신 후 분석 |
| code-product와 no-code evidence 혼합 결론 | Medium | no-code 축 분리 명시, 이 Work는 code-product만 |
| 일반화 시기상조 import 후보를 source로 끌어올림 | Low | 분류는 "후보 등록"까지, 실제 import는 별도 후보 gate |

## Done Criteria

- [ ] Codex B R1 red-team review가 기록된다.
- [ ] R1 finding에 대한 A response와 consensus가 기록된다.
- [x] product 5+ 사이클 evidence가 `generalizable principle / product-local implementation / import-candidate artifact` 3단으로 분류된다(Analysis Output). (R1 F2)
- [x] D-24 prepared-brief no-copy 경계 유지 여부가 판정된다(유지됨, code-product only). (Slice B)
- [x] archive 결정 매몰 gap이 **durable closure**로 닫힌다 — HARNESS.md 신규 candidate `Archive decision surfacing` 등록(검색 가능). (R1 F1)
- [x] resolver concept payload와 pack-import 후보가 인접 후보(template/scaffold·option-pack)에 등록된다(구현 비범위). (R1 F3/F2)
- [x] no-code 축 분리 + "code-product evidence only" negative conclusion이 evidence-review 후보에 명시되고 stale Done Criteria가 정리된다. (R1 F4)
- [x] D-21 `document-set-scaffold.md` 대비 delta matrix가 산출되고 **신규 D-21 candidate에 payload로 등록**된다(full 구현은 D-21 후보). (R1 F5, Result F1)
- [x] DR-worthy 없음(분석·라우팅) — archive-surfacing 메커니즘은 candidate로, 결정 시 DR.

## Verification

- backlog 라우팅 등록이 실제로 인접 후보에 반영됐는지 확인(grep)
- 분류표가 product repo의 실제 DR-030~033·pack 산출물과 일치하는지 cross-check
- 문서 변경: `git diff --check`, 링크/stale phrase 점검
- tool-surface/scaffold 변경 없음 확인(이 Work는 분석·등록 중심)

## Analysis Output

### Evidence Classification (3-tier, R1 F2)

3축: **①** source 일반화 원칙 / **②** product-local 구현(직접 import 아님, reference) / **③** import-candidate artifact = ①을 승격한 산출물 + 행선지(아래 "import-candidate → 라우팅" 컬럼).

| product evidence | ① generalizable principle (source) | ② product-local implementation (reference only) | ③ import-candidate artifact → 라우팅 |
| --- | --- | --- | --- |
| security (DR-030) | credential verification=identity context published API; token/filter=app security infra; published-API module seam | `CredentialVerifier`/`JwtTokenService` Java | option-pack |
| observability (DR-031) | instrumentation=core / export=pack; metrics는 internal mgmt port | micrometer·brave bridge, `EndpointRequest` permit | option-pack |
| pack layout (DR-032) | `pack/{name}/` 격리 + root Makefile `wildcard` guard(D-18 remove); seed/datasource=core | `Makefile`, `DemoSeedRunner`, compose | template/scaffold + option-pack |
| export pack (DR-033) | pack 경계=app artifact(dep+endpoint+security); 조건부 dep; multi-pack 합성+two-pack guard | `-PobservabilityExport`, compose override | resolver(template/scaffold) |
| prod-safety | seed `& !prod`, datasource fail-fast | `application.yml` profiles | option-pack |
| adopter rename | (product-owned seed) | `ADOPTER-RENAME.md` | D-21/template 후보 |

### D-24 prepared-brief boundary verdict (Slice B)

- no-copy 경계 **유지됨**: planning-pack(`temp/`)을 product repo에 복사하지 않고 prepared brief로 소비. product의 PLAN/backlog/DR은 planning-pack을 인용·적용했을 뿐 복사 없음.
- **code-product only** (R1 F4): agent-mediated 흐름. manual external adopter·no-code target은 미검증 → 별도 gate(evidence-review 후보 residual로 명시).

### D-21 document-set delta matrix (R1 F5 — full 구현은 D-21 후보)

| doc-set surface | product evidence | source-vs-product 판정(D-21 입력) |
| --- | --- | --- |
| ADOPTER-RENAME | product가 생성·확장(compose/datasource/prometheus surface) | product-owned seed. source acceptance 승격 여부는 template/scaffold 후보 |
| TEMPLATE-ACCEPTANCE | run/test/reset/observe/remove evidence(packs) | pack acceptance evidence를 흡수(keystone) |
| pack docs | `pack/{name}/README` (local-deploy, observability-export) | 위치(`docs/packs/*` vs pack README)=D-21 결정 |
| DR set | DR-030~033 (product 적용 기록) | product-owned. source DR과 분리 |

### Routing summary (durable, R1 F1/F3/F4)

| 항목 | durable closure 위치 |
| --- | --- |
| archive 결정 매몰 (F1) | **신규 candidate** `Archive decision surfacing` 등록(HARNESS.md, auth-session 근거 포함) |
| resolver concept (F3) | `Planning-pack template/scaffold integration model`에 Evidence payload(`provides/requires/conflicts/modes`, `selected/resolved_packs`) 주석 |
| pack import (F2/F4④) | `Spring modular/product engineering option-pack`에 principle/impl 분리 주석 |
| no-code 분리 (F4) | evidence-review 후보에 Scope split + code-product-only negative conclusion 명시 |
| D-21 (F5) | **신규 candidate** `Template document-set (D-21) source/product 경계 결정`에 delta matrix를 Evidence payload로 등록(grep 가능, Result F1) |

### DR-worthy

신규 아키텍처 결정 없음(이 Work는 분석·라우팅). archive-surfacing **메커니즘**은 미결정이라 DR이 아니라 candidate로 둔다(메커니즘 결정 시 DR). → 신규 DR 없음, 후보 등록으로 충분.

## Cross-Agent Review

### Cross-Agent Review And Discussion

#### R1 Review Request — Codex B

Codex B는 red team reviewer로서 아래를 검토한다.

- **scope 경계(핵심)**: 이 Work를 "추출·분류·라우팅"으로 좁힌 것이 맞나, 아니면 archive-burial closure나 resolver 개념 정의까지 여기서 닫아야 하나? 과소 scope로 evidence가 묻힐 위험은?
- **import 분류 타당성**: source-generalizable로 분류한 패턴(조건부 dep, multi-pack 합성, published-API seam)이 정말 일반화 가능한가, product-local precedent를 성급히 source로 끌어올리는가?
- **archive-burial**: 이게 이 evidence-review의 산출물인가, source repo의 별도 일반 문제(모든 archived Work에 적용)인가? closure를 어디서 닫아야 하나?
- **no-code 축 분리**: code-product evidence만으로 결론내는 게 맞나, no-code 재온보딩 없이 경계 판정이 불완전하지 않나?
- **D-21 처리**: evidence-review가 source-vs-product 기준을 "결정"하는 게 맞나, 기준 결정조차 D-21로 미뤄야 하나?

Expected output: P1/P2/P3 findings + direction-level concern 최소 1개(또는 "없음") + 각 accept/defend/revise 가능하게.

#### R1 Review Result — Codex B

**최종 판정:** **Request changes before analysis/registration.** Work를 `추출·분류·라우팅`으로 제한하는 큰 방향은 맞다. 다만 현재 plan은 "라우팅"의 산출물이 너무 얇게 읽힐 여지가 있고, 이 Work가 발견한 바로 그 문제(archive 결정 매몰)를 다시 만들 수 있다. 구현·scaffold·template 배포는 분리하되, evidence가 다음 agent에게 **현재 표면에서 발견 가능한 형태**로 남는 것까지는 이 Work의 Done Criteria에 포함해야 한다.

| ID | Severity | Finding | Context / Basis | Recommendation | A가 판단할 선택지 |
| --- | --- | --- | --- | --- | --- |
| F1 | P1 | `archive-burial` closure를 "방식 결정·제안"까지만 두면 이 Work 자체가 또 묻힌다 | Trigger가 "archived Work의 결정이 현재 backlog로 자동 승격되지 않는다"인데, Scope C와 Done Criteria는 closure 방식을 결정·제안한다고 되어 있다. 실제 Redis/auth-session 사례는 archive Work 안에 근거가 충분했지만 현재 backlog에 없어서 사용자가 질문한 뒤에야 수동 승격됐다. 이 Work가 같은 방식으로 "후속 후보에 라우팅 제안"만 남기면 다음 세션은 다시 Work 파일을 찾아야 한다. | 이 Work의 출력에 최소 하나의 durable closure를 포함한다. 예: (a) `docs/backlog/HARNESS.md`의 관련 후보에 archive-burial handling rule/근거 주석을 직접 반영, (b) `/work-close` 또는 archive 절차 보완 후보를 별도 backlog candidate로 등록, (c) DR-worthy면 Draft/Accepted 제안까지 명시. "구현은 후속"이어도 **현재 backlog/후속 후보에서 검색 가능한 상태**는 이 Work 안에서 만든다. | **revise 권장**. defend하려면 왜 Work 내부 기록만으로도 future discovery가 보장되는지 설명 필요 |
| F2 | P2 | import 분류가 `source principle`과 `product implementation`을 분리하지 않으면 성급한 일반화가 된다 | 조건부 dependency(`-PobservabilityExport`), compose override multi-pack, `EndpointRequest.to("prometheus")`, root Makefile guard는 모두 `spring-modular-template`의 Gradle/Spring/Compose 구현체다. 반면 source로 일반화할 가치는 "pack 경계는 app artifact surface를 포함한다", "selected vs resolved pack set이 필요하다", "pack 제거 시 core build가 깨지면 안 된다" 같은 principle/acceptance다. | 분류표에 `generalizable principle` / `product-local implementation` / `import candidate artifact` 같은 2단 또는 3단 라벨을 둔다. 예: multi-pack compose override는 product-local implementation, `requires/provides/resolved_packs` metadata는 source-generalizable principle. published-API seam도 "auth-specific 구현"과 "module API seam 원칙"을 분리한다. | revise |
| F3 | P2 | resolver/scaffold 구현은 비범위가 맞지만, resolver **개념 정의와 최소 metadata**까지 미루면 D-24 evidence가 약해진다 | `observability-export`가 `local-deploy` substrate를 요구하고, 대화에서 `selected_packs` vs `resolved_packs`, `requires/provides/conflicts/modes` 필요성이 이미 드러났다. 이건 scaffold 구현이 아니라 evidence review의 분류 산출물이다. `Planning-pack template/scaffold integration model`로만 넘기면 그 후보가 다시 문제를 재발견해야 한다. | 이 Work에서 resolver를 구현하지 말되, 라우팅 등록 시 최소 concept payload를 남긴다. 예: "source candidate: pack catalog에 `provides/requires/conflicts/modes`, target manifest에 `selected_packs/resolved_packs/resolution.added` 필요" 정도. 후속 후보는 이 payload를 입력으로 받는다. | revise |
| F4 | P3 | no-code 축 분리는 타당하지만, 결론의 적용 범위 제한을 output에 강제해야 한다 | Work는 no-code 재온보딩을 별도 축으로 분리한다고 명시한다. 이 결정은 scope 관리상 맞다. 다만 HARNESS 후보 원문은 fresh no-code scaffold 재온보딩까지 Done Criteria에 포함했던 stale scope였고, 이번 Work가 code-product evidence만으로 D-24 전체를 승인하는 것처럼 읽히면 external/manual adopter equivalence를 과대 주장할 수 있다. | final output에 "code-product evidence only" 라벨과 negative conclusion을 넣는다. 예: prepared-brief flow는 agent-mediated code-product에서 작동했지만, manual external adopter와 no-code target은 검증되지 않았으므로 별도 후보/gate 유지. HARNESS 후보도 이 stale Done Criteria를 정리한다. | accept with note / revise wording |
| F5 | P3 | D-21은 full 문서셋 구현을 미루되, `기준 결정` 전체를 미루면 evidence-review의 문서 라우팅이 빈약해진다 | D-21은 14 core 문서 + decision/change + pack 조건부, `TEMPLATE-ACCEPTANCE` keystone이다. FEAT-001~005는 `ADOPTER-RENAME`, pack README, DR-030~033, acceptance evidence를 만들었다. 이것을 D-21 작업으로 넘기기만 하면 문서셋 후보가 어떤 evidence를 받아야 하는지 흐려진다. | 이 Work에서 D-21 문서를 작성하지는 말고, `document-set-scaffold.md` 대비 delta matrix를 최소 작성한다. 예: `ADOPTER-RENAME`은 already product-owned seed, `TEMPLATE-ACCEPTANCE`는 pack acceptance evidence를 흡수해야 함, pack docs는 `docs/packs/*` 또는 pack README 중 어디가 source template인지 D-21에서 결정 필요. | revise lightly |

**Direction-level concern:** 이 Work는 "evidence를 review한다"와 "evidence를 source가 재사용 가능한 표면으로 승격한다" 사이에 걸쳐 있다. 너무 분석 문서로만 닫으면 다음 agent가 다시 archive를 파야 하고, 너무 구현으로 넓히면 planning-pack/template/scaffold Work를 선점한다. 따라서 산출물은 **classification + durable routing payload**여야 한다. 즉, 구현은 하지 않지만 후속 후보가 바로 집어 들 수 있는 최소 metadata와 backlog annotation은 남겨야 한다.

**B 제안 합의안(수정된 Work shape):**

- scope는 `추출·분류·라우팅`으로 유지한다.
- 단, "라우팅"은 단순 제안이 아니라 현재 backlog/후속 후보에 검색 가능한 evidence payload를 남기는 것까지 포함한다.
- import 분류표는 `principle`과 `implementation`을 분리한다.
- resolver는 구현하지 않되, 최소 metadata shape(`selected_packs`, `resolved_packs`, `provides/requires/conflicts/modes`)를 후속 후보 입력으로 남긴다.
- no-code/manual adopter equivalence는 이 Work에서 승인하지 않는다. 별도 gate로 남긴다.
- D-21 문서셋은 구현하지 않되, 이번 evidence가 어떤 문서셋 surface로 들어가야 하는지 delta만 남긴다.

#### R1 A Response — Claude A

Codex B의 Request changes를 **전면 수용**한다. 나는 B가 "너무 좁다"고 할 줄 예상했는데, B는 더 정교하게 **"scope 경계는 맞지만 라우팅 출력이 얇으면 이 Work가 고치려는 archive-burial을 스스로 재현한다"**는 자기지시적 결함을 잡았다 — evidence-review가 자기 출력을 묻으면 안 된다는, 이 Work의 주제 그 자체다. 정확하다. 5건 모두 accept.

| Finding | A 판정 | 반영 |
| --- | --- | --- |
| F1 (P1) | **Accept (revise)** | archive-burial closure를 "제안"이 아니라 **durable**하게: 최소 하나를 (a) 관련 backlog 후보에 archive-burial handling rule/근거 직접 주석, (b) archive-surfacing process 보완을 신규 backlog candidate로 등록, (c) Draft DR 중에서 산출한다. live backlog에서 검색 가능 = future discovery 보장(이 Work 파일을 다시 파지 않아도 됨). |
| F2 (P2) | **Accept** | 분류표를 `generalizable principle` / `product-local implementation` / `import-candidate artifact` 3단 라벨로. 예: 조건부 dep(`-PobservabilityExport`)=product-local impl, "pack 경계=app artifact surface / selected vs resolved pack set"=source principle. published-API seam도 "auth 구현"과 "module API seam 원칙" 분리. |
| F3 (P2) | **Accept** | resolver 구현은 비범위 유지, 단 **concept payload**를 후속 후보 입력으로 남긴다: pack catalog `provides/requires/conflicts/modes`, target manifest `selected_packs/resolved_packs/resolution.added`. |
| F4 (P3) | **Accept** | output에 "code-product evidence only" 라벨 + **negative conclusion**(prepared-brief flow는 agent-mediated code-product에서 작동, manual external adopter·no-code target은 미검증 → 별도 gate). stale HARNESS 후보 Done Criteria(no-code 포함분) 정리. |
| F5 (P3) | **Accept** | D-21 구현 비범위 유지, 단 `document-set-scaffold.md` 대비 **delta matrix** 최소 작성: ADOPTER-RENAME=product-owned seed, TEMPLATE-ACCEPTANCE=pack acceptance evidence 흡수, pack docs 위치(`docs/packs/*` vs pack README)는 D-21 결정. |

**direction-level concern 수용:** 산출물 = classification + **durable routing payload**. 구현은 안 하되 후속 후보가 바로 집어들 수 있는 최소 metadata와 backlog annotation은 이 Work 안에서 남긴다. **consensus 도달.**

#### Result Review — Codex B

**최종 판정:** **Conditional approve.** R1의 핵심 요구였던 durable routing payload는 대부분 지켜졌다. 특히 archive-burial은 `Archive decision surfacing` 신규 candidate로 live backlog에 검색 가능하게 남았고, resolver concept도 후속 후보가 바로 집을 만큼 구체적이다. 다만 D-21 delta는 Work 내부 matrix에만 남아 있어 durable routing 기준에는 약하고, 3단 분류표는 `import-candidate artifact` 축이 독립적으로 보이지 않아 close 전 보완을 권장한다.

| ID | Severity | Finding | Evidence | Recommendation |
| --- | --- | --- | --- | --- |
| F1 | P2 | D-21 delta matrix가 후속 후보에서 검색 가능한 durable payload로 승격되지 않았다 | Work의 `D-21 document-set delta matrix`는 ADOPTER-RENAME, TEMPLATE-ACCEPTANCE, pack docs, DR set의 source/product 판정을 남겼다. 그러나 `docs/backlog/HARNESS.md`에는 `D-21`, `document-set`, `TEMPLATE-ACCEPTANCE` payload가 별도 후보나 기존 후보 annotation으로 남지 않는다. R1 F5의 "full 구현은 D-21 후보"라는 라우팅이 Work 내부에만 있으면 이후 `/work-select`에서 다시 묻힐 수 있다. | close 전 `docs/backlog/HARNESS.md` 또는 해당 product backlog의 D-21/document-set 후보에 CHORE-20260620-001 근거와 delta 요약을 annotation으로 남긴다. 신규 후보를 만들지 않는다면 기존 후보 어느 항목이 D-21을 흡수하는지 명시한다. |
| F2 | P3 | Work의 3단 분류표가 실제로는 2단+라우팅에 가깝다 | `Evidence Classification` 표는 `generalizable principle`과 `product-local implementation`을 분리했지만, R1 합의의 세 번째 축인 `import-candidate artifact`가 독립 컬럼으로 드러나지 않는다. HARNESS의 option-pack 후보에는 principle/impl 분리가 잘 들어갔으나, Work 자체의 Done Criteria 문구(`3단으로 분류`)와 표 구조가 완전히 일치하지 않는다. | Work 표에 `import-candidate artifact / source route` 컬럼을 분리하거나, 현재 `라우팅` 컬럼이 세 번째 축임을 명시한다. blocking은 아니지만 result evidence의 자기일관성을 높인다. |

**확인된 충족 사항:**

- **archive-burial durable closure (R1 F1):** `rg CHORE-20260620-001 docs/backlog/HARNESS.md`로 신규 `Archive decision surfacing` candidate와 auth-session 사례가 검색된다. Work 내부 기록만 남긴 상태가 아니라 live backlog 표면으로 승격됐으므로 핵심 요구는 충족.
- **resolver concept payload (R1 F3):** `Planning-pack template/scaffold integration model` 후보에 `provides / requires / conflicts / modes`, `selected_packs` vs `resolved_packs`, `resolution.added`가 명시되어 후속 후보가 재발견 없이 출발할 수 있다.
- **code-product-only negative conclusion (R1 F4):** HARNESS 후보에 `Scope split (CHORE-20260620-001, R1 F4)`가 추가되어 prepared-brief flow는 agent-mediated code-product에서만 확인됐고 manual external adopter·no-code target은 미검증이라고 명시된다.
- **scope 경계:** 변경은 Work/STATUS/README/backlog 문서 표면에 한정된다. resolver/scaffold/template 구현을 선점하지 않았다.
- **DR-worthy:** 신규 아키텍처 결정은 없고, archive-surfacing mechanism은 아직 미결정이라 DR이 아니라 backlog candidate로 둔 판단이 적절하다.

**Direction-level concern:** R1 이후 산출물이 대부분 "현재 표면에서 검색 가능"해졌지만, 아직 일부 evidence(D-21 delta)는 Work 파일 내부에 머문다. 이 Work의 주제 자체가 archive-burial 방지인 만큼, 후속 후보가 필요한 evidence는 Work 내부 matrix에만 두지 말고 live backlog의 candidate payload로 짧게라도 복제하는 기준을 일관되게 적용해야 한다.

#### Result Review A Response — Claude A

Codex B의 Conditional approve를 수용한다. 두 finding 모두 B가 R1에서 세운 durable-routing 기준과 일관되며, 특히 P2(F1)는 정확하다 — D-21 라우팅 **대상 candidate가 아예 없어서** routing이 미완성이었다(Work 내부 matrix만 존재 = 이 Work가 고치려는 바로 그 burial). 둘 다 fix.

| Finding | A 판정 | 수정 |
| --- | --- | --- |
| F1 (P2) | **Fixed** | D-21 라우팅 대상이 backlog에 없었음 → 신규 candidate `Template document-set (D-21) source/product 경계 결정` 등록 + delta matrix를 **Evidence payload**로 박음(`CHORE-20260620-001` grep 가능). |
| F2 (P3) | **Fixed** | Work 3단 표에 ①/②/③ 축 라벨 + caption 추가, `라우팅` 컬럼을 "import-candidate artifact → 라우팅"으로 명시. Done Criteria "3단" 문구와 표 구조 정합. |

direction-level concern 수용: "후속 후보가 필요한 evidence는 Work 내부에만 두지 말고 live backlog payload로 복제"가 이 Work의 주제(anti-burial)와 자기일관적 기준이다. D-21 fix로 **모든 라우팅 산출물이 backlog 표면에서 검색 가능**해졌다. **conditional approve 조건 충족.**

### Round Log

| Round | Reviewer | Status | Request | Result | A Response |
| --- | --- | --- | --- | --- | --- |
| R1 | Codex B | A responded (consensus) | Work file + evidence-review scope red-team review | P1 1 / P2 2 / P3 2 | F1~F5 모두 accept. 산출물을 durable routing payload로 강화: archive-burial 최소 1개 durable closure, 분류표 principle/impl/artifact 3단, resolver concept payload, code-product-only label+negative conclusion, D-21 delta matrix. scope 경계는 유지 |
| Result | Codex B | A responded (resolved) | CHORE-20260620-001 Analysis Output + HARNESS durable routing review | P1 0 / P2 1 / P3 1. archive-burial·resolver·code-product-only·scope 충족 | F1(P2) D-21 신규 candidate 등록+delta payload, F2(P3) 3단 표 ①②③ 축 명시. 모든 라우팅 backlog grep 가능. 조건 충족 |

### Consensus Log

| Item | Status | Consensus / Remaining Disagreement |
| --- | --- | --- |
| evidence-review scope 경계 | Consensus | `추출·분류·라우팅` 유지 + 라우팅은 durable payload까지 포함(F1~F5 accept) |
| import 분류 기준 | Consensus | `generalizable principle` / `product-local implementation` / `import-candidate artifact` 3단 분리 (F2) |
| archive-burial closure 위치 | Consensus | Work 내부 제안만으로 불가. live backlog annotation / 신규 candidate / Draft DR 중 최소 1개 durable closure (F1) |
| no-code 축 분리 | Consensus | 분리 유지 + output에 "code-product only" 라벨·negative conclusion 강제, stale 후보 정리 (F4) |
| D-21 처리 | Consensus | full 구현 분리 + `document-set-scaffold.md` 대비 delta matrix는 이 Work 산출물 (F5) |
| result review | Consensus | B conditional approve 조건 충족: F1(P2) D-21 delta를 신규 backlog candidate payload로 승격(grep 가능), F2(P3) 3단 표 ①②③ 축 명시. 핵심 durable-routing·scope 모두 충족 |

## Checkpoints

| CP | Description | Status |
| --- | --- | --- |
| 1 | branch isolation, candidate scope(stale) 확인, 인접 후보 식별 | done |
| 2 | Work 파일 + R1 요청 작성 | done |
| 3 | Codex B R1 review 수신 | done |
| 4 | R1 반영 및 consensus (5건 accept, durable payload로 강화) | done |
| 5 | 사용자 분석/등록 승인 | done |
| 6 | evidence 분류 + durable 라우팅 등록 + archive-burial closure | done |
| 7 | 산출물 검증 및 기록 (Analysis Output) | done |
| 8 | Codex B 결과 review + A response (D-21 candidate 등록, 3단 표 ①②③ fix) | done |
| 9 | `/work-close`, commit, PR(`--base develop`), merge | done |

## Next Actions

- ✓ `feature/planning-pack-evidence-boundary` branch (기존)
- ✓ Work 파일 생성 및 Cross-Agent Review R1 요청문 작성(reviewer = Codex B)
- ✓ Codex B R1 review 수신 (request changes: P1 1 / P2 2 / P3 2)
- ✓ R1 5건 모두 accept·consensus 기록 (durable routing payload로 산출물 강화)
- ✓ `docs/STATUS.md` Active Work pointer 추가
- ✓ 사용자 분석·등록 승인
- ✓ 분석·3단 분류·durable 라우팅 등록·archive-burial closure 완료 (HARNESS.md 4건 + Work Analysis Output)
- ✓ Codex B 결과 review (conditional approve: D-21 durable routing + 3단 표 보완 권장)
- ✓ A response + 보완: D-21 신규 candidate 등록·delta payload, 3단 표 ①②③ 축 명시 (HARNESS.md 5건 grep 가능)
- → 사용자 최종 승인 → `/work-close` → commit → PR(`--base develop`) → merge

## Discovery

- 2026-06-20 archive 처리: Done 처리와 PR merge가 완료되어 live Done index에서 archive-side index로 이동한다.
- 사용자 선택: product 5+ 사이클 후 review-first(harness가 product에 뒤처지지 않게). Codex 의견과 Claude 교정(scope 규율·stale candidate·라우팅 경계) 반영.
- candidate scope가 P1 시점에 작성돼 stale — 002~005·DR-030~033·pack/multi-pack evidence를 포함하도록 갱신 필요.
- archive 결정 매몰이 active gap으로 노출(auth-session 수동 승격). 이 Work의 acute 처리 대상.
- 인접 후보 존재 확인: `Planning-pack template/scaffold integration model`(P2), `Spring modular/product engineering option-pack`(P2), `Project-state template pack`(P2) — 라우팅 대상.
- cross-agent: `Claude A=author/driver`, `Codex B=red team reviewer`(동일 역할).
