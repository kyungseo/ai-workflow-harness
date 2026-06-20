# HARNESS.md

AI Workflow Harness backlog다.

이 파일은 Claude/Codex/Antigravity/Cursor 등 Agent workflow, 문서 상태 관리, command/rule 정합성, hook/CI enforcement 후보를 관리한다.
프로젝트 기능 backlog가 필요한 경우 `docs/backlog/PRODUCT.md`를 별도로 둔다.

기존 product-template backlog와 Work 기록은 history와 archive에 남아 있지만, 이 repository의 현재 active scope는 AI Workflow Harness다.

> Done/Superseded 항목은 이 파일에서 제거된다.
> 완료 이력: Work 파일이 있는 항목은 `docs/archive/docs/works/harness/README.md` Archived 인덱스, Work 파일이 없는 항목(Quick Mode)은 `git log --grep="{ID}"`로 확인한다.

## Priority Guide

| Priority | Meaning |
| --- | --- |
| P0 | public-ready migration 또는 harness 운영 전에 처리해야 하는 기반 |
| P1 | 세션 안정성 또는 규칙 준수율을 크게 높이는 항목 |
| P2 | 운영 부채를 줄이는 보완 항목 |
| P3 | 선택적, 실험적, 또는 사용 빈도 확인 후 진행할 항목 |

## Backlog

### Portfolio View

> 이 분류는 확정된 실행 순서가 아니라 backlog를 읽기 위한 portfolio view다.
> 각 Work 착수 시 `/work-plan`에서 항목 자체의 논리성, 합리적 의사결정, 현재 product 적용 맥락을 다시 검토한다.

| Cluster | Goal | Backlog Items |
| --- | --- | --- |
| W1. Validation Spine ✓ 완결 | 이번 주 이후 큰 하네스 변경을 줄이더라도 regression을 잡을 수 있는 최소 검증 척추를 만든다 | (전부 완료) 검증 척추 spine 도입 = CHORE-20260611-005, scaffold/tool-surface leak-scan alignment = CHORE-20260611-006, product pack 검증 Layer U = CHORE-20260611-007, gate path-list parity = CHORE-20260611-008, source repo maintainer operations manual = CHORE-20260611-009. 잔여 후속은 W3/W4 후보에서 별도 추적 |
| W2. Adopter Transition | 다음 주 실제 product scaffold 운영에 필요한 적용·업그레이드·온보딩 흐름을 준비한다 | (upgrade/migration 완료 = CHORE-20260611-010, docs cascade 완료 = CHORE-20260611-011, planning pack 완료 = CHORE-20260612-001, readability rewrite 완료 = CHORE-20260612-002, clone verification 완료 = CHORE-20260612-003) 후속 후보: `ai-deck-compiler` first real walkthrough, internal managed mode guardrails(게이트 후), 첫 concrete product planning-pack evidence review(`spring-modular-template` P1 완료 반영), planning-pack template/scaffold integration model, happy path / glossary / operator layering compression |
| W3. Workflow IA Diet ✓ 완결 | source/target 경계, canonical weight, optional pack, trigger 구조를 더 가볍게 정렬한다 | (Canonical 개념 계층화 핵심 달성 = CHORE-20260613-002~005, Prompt surface diet 완료 = CHORE-20260612-010, work-doc class 완료 = CHORE-20260613-005, trigger family simplification 완료 = CHORE-20260613-006) 전부 완료 |
| W4. Enforcement And Lifecycle | 반복되는 운영 실수를 hook/CI/test 또는 closeout 절차로 줄인다 | (전부 종결) Validation Spine residual F1~F4 = CHORE-20260613-017/018·DR-036, 문서-only 규칙 강제화 = DR-037, Archive 누적 관리 정책 = DR-038, CI inline assertion ↔ invariants SSoT parity = CHORE-20260613-016 no-action closeout |
| W5. Future / Optional | 실제 product 운용 후 필요가 확인되면 확장한다 | Spring modular/product engineering option-pack, project-state template, sub-agent autonomy policy, packaging/distribution revisit, Windows 지원 |

**Adopter evidence set:** 현재 scaffold된 실제 적용 프로젝트는 `ai-deck-compiler`, `rfx-hub`, `spring-modular-template` 3개로 본다. `base-msa-template`은 `ai-workflow-harness`의 mirror/reference 입력이므로 scaffold target evidence set에서 제외한다.

### Summary

| ID | Priority | Status | Risk | Title |
| --- | --- | --- | --- | --- |
| — | P1 | Candidate | L2 | `ai-deck-compiler` first real upgrade walkthrough + DR-034 acceptance judgment |
| — | P1 | Candidate | L2 | Happy path / glossary / operator layering compression |
| — | P1 | Candidate | L2 | First concrete planning-pack evidence review (`spring-modular-template` P1 + fresh no-code follow-up) |
| — | P2 | Candidate | L2 | Archive decision surfacing — closeout/archive 시 forward-relevant 결정의 backlog 승격 |
| — | P2 | Candidate | L2 | Planning-pack template/scaffold integration model |
| — | P2 | Candidate | L3 | Internal managed mode design note + target guardrails (post-walkthrough gate) |
| — | P2 | Candidate | L3 | Spring modular/product engineering option-pack 후보 |
| — | P3 | Candidate | L2 | Sub-agent/Main Agent Authority Boundary |
| — | P2 | Candidate | L2 | Project-state template pack 검토 |
| — | P3 | Candidate | L3 | Packaging / distribution revisit after upgrade logic proof |
| HRN-032 | P2 | Hold | L2 | Windows 지원 확장 (WSL/Git Bash robustness로 scope 축소, 실수요 전 보류) |

---

### Details

> **Verification 작성 기준:** 변경이 건드리는 surface를 항목별로 명시한다.
> 점검 후보: tool surface · adopter cascade · canonical · scaffold · README/GUIDE/MANUAL
> 해당 없는 surface는 제외한다.

---

#### `ai-deck-compiler` first real upgrade walkthrough + DR-034 acceptance judgment

**Cluster:** W2. Adopter Transition

**Task:** `ai-deck-compiler` 실제 adopter를 대상으로 Layer T upgrade/migration walkthrough를 수행해 **External Adopter Mode** 기준의 first real upgrade 경험을 만든다. pre-manifest inventory, shadow scaffold baseline, selective migration, accepted drift 분류를 실측하고, source 쪽 설계가 문서상 placeholder를 넘어서 실제 adopter friction을 얼마나 줄이는지 확인한다. 결과를 바탕으로 DR-034를 Draft 유지할지 Accepted로 올릴지 판단하며, 동일 target에서 **Internal Managed Mode 후보를 열 필요가 있는지**도 gate로 판정한다.

**Dependencies:**

- CHORE-20260611-010에서 정리한 upgrade/migration 메커니즘과 `docs/maintainer/VERIFICATION-COMMANDS.md` Layer T
- `docs/briefs/harness-internal-managed-upgrade-20260615.md`의 Candidate A 판단
- `docs/retrospectives/harness-v1-2-readiness-retrospective-20260615.md`의 "first real walkthrough가 fleet mode의 선행 gate" 판단
- `docs/briefs/harness-distribution-plugin-model-20260608.md`의 "배포 방식보다 upgrade/migration 로직이 선행" 판단
- 실제 adopter target 접근 가능 여부와 current target 상태 확인
- 필요 시 `docs/maintainer/migrations/*.md` note 보강

**Done Criteria:** 실제 adopter walkthrough 결과가 inventory-first 분류와 함께 남고, framework-owned / project-owned / customized / accepted drift 구분이 기록된다. selective migration 후 `--check` 결과와 남은 manual-merge hotspot이 정리되며, DR-034 상태 판단(승격 또는 유지 이유)이 명시된다. 또한 "같은 target에서 internal managed mode를 열 가치가 있는가"에 대한 yes/no 판단과 이유가 남는다.

**Verification:** Layer T walkthrough, `scripts/create-harness.sh --check <target>`, drift summary 기록, maintainer migration note/README pointer 정합 확인. Surface: adopter cascade · scaffold · README/GUIDE/MANUAL.

---

#### Internal managed mode design note + target guardrails (post-walkthrough gate)

**Cluster:** W2. Adopter Transition

**Task:** 첫 실제 walkthrough에서 반복 비용과 중앙 관리 필요가 관측될 때만, internal managed mode의 최소 정책 초안을 정리한다. 핵심은 메커니즘 구현이 아니라 **guardrail** 정의다: framework-owned 변경을 중앙 PR 경로로만 제안할지, target product repo에서 harness 변경과 product code를 같은 변경 단위로 묶지 않도록 할지, reviewer·rollback·registry write control을 어떻게 둘지 정리한다. 실제 runner/prototype 메커니즘은 이 후보(B) 이후에만 여는 추가 gate된 downstream 단계(Candidate C)로 남긴다.

**Dependencies:**

- `ai-deck-compiler` first real walkthrough 결과와 DR-034 상태 판단
- `docs/briefs/harness-internal-managed-upgrade-20260615.md` Candidate B / 운영·보안 리스크 / policy-runner 경계
- `docs/retrospectives/harness-v1-2-readiness-retrospective-20260615.md`의 "fleet mode는 walkthrough 이후 opt-in 후속 후보" 판단
- 사용자 note: framework-owned 파일 변경 제약, product code와 harness를 같이 묶어 커밋하지 않는 원칙 검토

**Done Criteria:** internal managed mode를 열 조건이 명시되고, 최소 guardrail 초안이 정리된다. 예: `pr-only` 원칙, framework-owned path mutation policy, target review rule, product/harness bundle 금지 여부, registry write-control, rollback 책임. walkthrough 전에는 착수하지 않는다. 또한 runner/prototype은 이 후보의 산출물이 아니라 별도 downstream gate라는 점이 문서상 분리된다.

**Verification:** source 문서 근거 대조, guardrail matrix review, target ownership boundary self-check. Surface: canonical · adopter cascade · README/GUIDE/MANUAL.

---

#### Happy path / glossary / operator layering compression

**Cluster:** W2. Adopter Transition

**Task:** v1.2.0 readiness 회고에서 드러난 신규 사용자 부담을 줄이기 위해, scaffold 직후와 이미 scaffold된 project 재진입 시의 happy path를 10분 내 이해 가능한 routing으로 압축한다. 목표는 새 절차를 늘리는 것이 아니라 README/GUIDE/MANUAL의 첫 진입 경로와 "무엇을 먼저 하면 되는가"를 더 얇게 만들고, 동시에 glossary / concept map / 문서 3층 구조(10분 happy path / daily operator guide / maintainer deep reference)를 분리하는 것이다. **연계:** `docs/retrospectives/harness-v1-2-readiness-retrospective-20260615.md`

**Dependencies:**

- `docs/retrospectives/harness-v1-2-readiness-retrospective-20260615.md`의 onboarding weakness / happy path 제안
- 같은 문서의 glossary / concept map / operator layering 제안
- `docs/SCAFFOLD-ONBOARDING-GUIDE.md`, `docs/HARNESS-QUICK-REFERENCE.md`, README의 기존 routing 구조
- `docs/AGENT-WORKFLOW.md`의 session startup / context routing 원칙

**Done Criteria:** 신규 adopter가 "새 project에 적용할 때", "이미 적용된 project를 시작할 때", "Quick Mode vs Work file 경계", "AI에게 첫 메시지로 무엇을 말할지"를 한 화면 또는 짧은 path로 찾을 수 있다. source-only maintainer 문서와 scaffold target 사용자 문서가 섞이지 않는다. 또한 source repo / scaffold target / product repo, framework-owned / project-owned / accepted drift, Work / DR / STATUS / backlog 같은 핵심 용어를 초심자가 빠르게 찾을 수 있는 최소 glossary 또는 concept map이 생긴다.

**Verification:** README/GUIDE/MANUAL routing diff review, stale phrase/link check, scaffold output에서 happy path가 source-only maintainer 문서를 요구하지 않는지 확인. Surface: adopter cascade · scaffold · README/GUIDE/MANUAL.

---

#### First concrete planning-pack evidence review (`spring-modular-template` P1 + fresh no-code follow-up)

**Cluster:** W2. Adopter Transition

**Task:** 첫 concrete planning-pack exercise를 실제 product repo까지 확장해 evidence review를 수행한다. `spring-modular-template` P1에서 planning-pack prepared brief → scaffold onboarding → target repo PRODUCT backlog → selective import → Work closeout 흐름이 한 번 실행됐다. 이 결과를 source repo 관점에서 되짚어 CHORE-20260612-001이 provisional로 남긴 source-owned / product-owned / import-candidate 경계를 실측한다. fresh no-code scaffold 재온보딩은 별도 축으로 남아 있으므로, code-product evidence와 no-code evidence를 섞어 결론내리지 않는다.

이 exercise에서 노출된 gap을 함께 보강한다: **준비된 project brief/요약본/planning-pack 산출물을 onboarding이 적시에 intake하지 못한다**(현재 BOOTSTRAP은 순수 대화형 Q&A뿐 — live 세션에서 `temp/rfx-hub-onboarding-handoff.md`를 수동으로 끼워넣어야 했음). 보강:
- BOOTSTRAP §1 진입 직전 **intake step** 추가 — "준비된 brief/요약본/planning-pack 산출물이 있으면 경로 또는 텍스트로 먼저 받아 §1·§2·(§4) 초안에 반영. 권장 포맷은 PRODUCT-STARTER-PLANNING-PACK. 없으면 대화형 fallback."
- Bootstrap-State Rule(session-start)에 **보유 여부 선질문** 한 줄.

intake hook(소비 측)과 planning pack(입력 포맷)은 같은 loop의 양 끝이므로 한 작업으로 묶어 정합을 맞춘다. 단, 향후 planning-pack 공식 템플릿화·scaffold 배포·session-start 자동 탐색은 이 evidence review의 scope가 아니라 별도 후보 `Planning-pack template/scaffold integration model`에서 다룬다.

**진행:** intake hook(`CHORE-20260617-001`)·no-code onboarding depth(`CHORE-20260617-002`) 구현 완료. rfx-hub(content/research, no-code) 첫 온보딩이 두 gap을 노출시킨 뒤 **finding 수집 완료로 삭제**됨. `spring-modular-template`(code product)에서는 planning-pack을 repo에 통째 복사하지 않고 prepared brief로 소비했고, 새 target repo에서 P1 core slice(`FEAT-20260619-001`)를 Done 처리했다. 남은 candidate scope = **code-product evidence review + fresh no-code scaffold 재온보딩 end-to-end 검증**(intake hook + no-code depth 동작 확인) + import candidate review.

**Scope split (CHORE-20260620-001, R1 F4):** code-product evidence review는 `CHORE-20260620-001`(5+ 사이클: FEAT-001~005, DR-030~033)에서 수행한다. 결론은 **code-product only** — prepared-brief flow는 agent-mediated code-product에서 작동했으나 manual external adopter·no-code target은 **미검증**(negative conclusion). 따라서 **fresh no-code scaffold 재온보딩 end-to-end 검증은 이 Work 비범위로 남는 별도 residual axis**이며, code-product 결론을 no-code adopter equivalence로 확장하지 않는다.

**Evidence boundary:** `spring-modular-template` P1은 planning-pack prepared brief가 agent-mediated onboarding input으로 작동함을 보여준다. 다만 planning-pack 생성, scaffold, brief 소비가 모두 harness-side agent 흐름으로 이어졌으므로, external adopter가 수동으로 scaffold 후 planning-pack을 발견·전달·검증하는 UX와 동일하다고 단정하지 않는다. manual adopter equivalence는 clean target replay 또는 fresh scaffold 재온보딩으로 별도 검증한다.

**Dependencies:**

- CHORE-20260612-001 planning pack/import loop 기준, `docs/maintainer/PRODUCT-STARTER-PLANNING-PACK.md`
- fresh no-code scaffold (초기 test bed `rfx-hub`는 finding 수집 후 삭제), `temp/rfx-hub-onboarding-handoff.md`(ad-hoc planning-pack 선례)
- session-start Bootstrap-State Rule(#206), BOOTSTRAP §0 git-init 권장 기본값(#207), intake hook(#209)·no-code depth(CHORE-20260617-002)
- `spring-modular-template` P1 결과: planning-pack D-24 prepared-brief flow, `docs/ADOPTER-RENAME.md`, Testcontainers troubleshooting, PRODUCT backlog/Work closeout evidence

**Done Criteria:** `spring-modular-template` P1 evidence에서 ① D-24 prepared-brief flow가 실제로 작동했는지, ② planning-pack을 target repo에 복사하지 않은 경계가 유지됐는지, ③ adopter rename/placeholder leak check를 source acceptance로 끌어올릴지, ④ product repo 산출물 중 source option-pack/import 후보가 무엇인지 정리한다. 또한 intake hook과 no-code depth가 **fresh no-code scaffold 재온보딩**으로 intake→§1/§2/§4 반영 + no-code thick 부팅이 end-to-end 검증된다. planning-pack 산출물의 owner 분류(source/product/import)가 기록되고, import 후보의 일반화 가능 범위·보류 이유, Layer U/U4 checklist 유지/보강 판단이 정리된다.

**Verification:** Layer U checklist, product artifact → source import mapping review, intake hook fresh-scaffold 재온보딩 검증, optional pack/tool-surface spillover 점검. Surface: scaffold · canonical(session-start) · tool surface · adopter cascade · README/GUIDE/MANUAL.

---

#### Archive decision surfacing — closeout/archive 시 forward-relevant 결정의 backlog 승격

**Cluster:** W2. Adopter Transition

**Task:** archived Work 안에 충분한 근거가 있는 forward-relevant 결정이 live backlog로 자동 승격되지 않아, 다음 세션이 archive를 수동으로 파야 표면화된다. `spring-modular-template`에서 실증됨: auth-session pack(refresh/blacklist/Redis) 후보는 `FEAT-20260620-002`가 명시적 non-goal + extraction trigger로 기록했지만, archive 후 사용자가 질문한 뒤에야 수동 backlog 승격됐다. closeout/archive 절차(`/work-close` 또는 archive step)에서 "deferred/non-goal/extraction-trigger로 표시된 결정"을 backlog candidate로 surfacing하는 경량 규약을 결정한다. **출처: CHORE-20260620-001 evidence review (R1 F1 durable closure).**

**Dependencies:** DR-014 archive policy, `/work-close` canonical(`skills/workflow/work-close.md`), Work 파일 frontmatter/섹션 컨벤션(DR-013), `spring-modular-template` auth-session 사례.

**Done Criteria:** archive/closeout 시 forward-relevant 결정(deferred/non-goal/extraction-trigger/follow-up)을 식별·승격하는 최소 규약이 결정된다. 과잉 자동화(모든 결정을 backlog로 복제) 없이, "trigger 표시된 결정만" 승격하는 경계가 명시된다. 구현 위치(work-close vs archive step vs session-start 안내)가 정해진다.

**Verification:** auth-session 사례로 규약 dry-run(이 결정이 자동 표면화됐을지), work-close/archive cascade 점검, 과잉 승격 false-positive review. Surface: canonical(work-close) · tool surface(command) · docs(archive policy).

---

#### Planning-pack template/scaffold integration model

**Cluster:** W2. Adopter Transition

**Task:** 여러 product에서 준비된 brief/planning-pack 산출물을 반복적으로 쓰기 시작할 때, planning-pack을 source repo에서 어떤 template 단위로 관리하고 scaffold·session-start에 어디까지 연결할지 결정한다. 후보는 `templates/planning-pack/` 공식 템플릿, target repo 바깥 또는 `.harness/planning-pack/` 규약 경로, `create-harness.sh` 자동 배포, `workflow-session-start` 자동 탐색이다. 단, 현재 진행 중인 `spring-modular-template` P1 evidence review와 섞지 않고, product repo에 planning-pack을 통째 복사하지 않는 경계를 먼저 재확인한 뒤 설계한다.

**Evidence payload — pack resolver (CHORE-20260620-001, R1 F3):** `spring-modular-template` multi-pack 실증에서 resolver concept가 드러났다 — `observability-export`가 `local-deploy` substrate를 **requires**하고, `run-observe`가 두 pack 동시 존재를 guard, `observability-export`는 `provides` metrics export. source-generalizable shape(구현은 이 후보 gate, evidence review는 미구현): pack catalog에 `provides / requires / conflicts / modes`, target manifest에 `selected_packs` vs `resolved_packs`(transitive 포함)·`resolution.added`. DR-033(multi-pack 합성 컨벤션)·DR-032(`pack/{name}/` 레이아웃)가 product-local precedent.

**Dependencies:**

- `First concrete planning-pack evidence review`의 source/product/import owner 분류 결과
- fresh no-code scaffold 재온보딩 결과와 prepared-brief intake hook의 실제 사용성
- `docs/maintainer/PRODUCT-STARTER-PLANNING-PACK.md`와 Layer U/U4 checklist
- `scripts/create-harness.sh`의 scaffold distribution boundary와 adopter-owned 파일 정책

**Done Criteria:** planning-pack template의 owner(source-owned template / scaffold-owned seed / product-owned artifact / import-candidate)가 분리된다. 자동 배포 여부와 기본 경로가 결정되고, session-start가 자동 탐색해야 하는지 또는 수동 경로 입력을 유지해야 하는지 근거가 기록된다. 템플릿 후보(결정표, 경계표, 자산 분류, prepared brief 양식)는 과잉 scaffold 파일 증가 없이 최소 단위로 정리된다.

**Verification:** evidence review 결과 대조, scaffold file-list impact review, `create-harness.sh` dry-run 또는 `--check` 필요 여부 판단, session-start intake 경로 시뮬레이션. Surface: scaffold · canonical(session-start) · tool surface · adopter cascade.

---

#### Spring modular/product engineering option-pack 후보

**Cluster:** W5. Future / Optional

**Task:** 실제 신규 product에서 검증된 product engineering 산출물을 바탕으로 Spring Boot 기반 option-pack을 설계한다. `spring-modular-template`의 방향은 classic MSA가 아니라 **modular monolith first + extractable seams**이므로, 기존 "Spring Boot MSA TDD option-pack" 명칭은 채택 장벽을 만들 수 있다. 기존 "coding guide" 단일 문서 발상도 범위가 좁으므로, PRD/TRD/code conventions/user flow/DB design/screen/tasks/test structure/loop 절차를 포함할 수 있는 product engineering pack으로 재정의한다. 단, 처음부터 source repo에 과잉 일반화하지 않고 product repo에서 검증된 뒤 source repo로 import한다.

**Evidence payload — import 후보 (CHORE-20260620-001, R1 F2/F4 ④):** `spring-modular-template` 검증 산출물을 principle / product-local impl로 분리한다.
- **source-generalizable principle**: pack 경계=app artifact surface(dependency activation+management endpoint+security surface, DR-033), 조건부 dependency activation, multi-pack 합성(substrate+two-pack guard), prod/stage fail-safe(seed `& !prod`, datasource fail-fast, DR-032), published-API module seam(`UserDirectory`/`CredentialVerifier`, DR-001/030), instrumentation=core / export=pack(DR-031).
- **product-local implementation(직접 import 아님, reference만)**: Gradle `-PobservabilityExport`, compose override, `EndpointRequest.to("prometheus")`, root Makefile `wildcard` guard, `DemoSeedRunner`, micrometer/brave bridge 배선.
- import 시 principle을 일반화하고 impl은 reference로만 둔다(성급한 코드 복사 금지).

**후보 구성:**

- `docs/CODING-PRINCIPLES.md` 또는 code convention guide.
- TDD loop / Done Criteria 반복 절차.
- architecture / TRD skeleton.
- PRD skeleton.
- DB design / screen / task / test structure template.
- `.claude/rules/`, `.cursor/rules/` 등 tool-surface wiring.
- 필요 시 `--with-spring-boot-msa` 또는 유사 옵션. 이름과 CLI surface의 **최소 결정**은 이 후보 안에서 ad hoc으로 먼저 정할 수 있고, 더 넓은 naming/distribution cleanup은 `Packaging / distribution revisit after upgrade logic proof` 후보에서 재검토한다.

**Dependencies:**

- CHORE-20260612-001에서 정리한 planning pack/import loop 기준 위에서 실제 product 산출물과 일반화 가능 범위를 먼저 확보.
- CHORE-20260612-010 prompt/optional pack classification result.
- scaffold/tool-surface regression alignment(CHORE-20260611-006 완료) 이후 착수 권장.
- `scripts/create-harness.sh --with-optional` 현행 설계 파악 필요.

**Done Criteria:** core scaffold(옵션 미지정)에는 포함되지 않음. product repo에서 검증된 산출물 중 일반화 가능한 부분만 option-pack 후보로 편입. Spring modular pack, Spring Boot MSA pack, 더 일반적인 product engineering pack 중 무엇이 맞는지 결정. stack별 확장(`--with-spring`, `--with-spring-modular`, `--with-react` 등)은 필요가 확인된 것만 둔다.

**Verification:** core scaffold dry-run에서 pack 미포함 확인. option-pack dry-run에서 파일 목록·tool surface wiring 확인. product repo 산출물 → source repo import 후보 mapping 검토. README/GUIDE/MANUAL에 pack 설명이 과잉 노출되지 않는지 확인.

**사전 참고:** 현재 `scripts/create-harness.sh`는 `--profile spring-boot`와 `--with-optional`만 지원한다. `--with-spring-boot-msa` 같은 새 옵션은 즉시 전제하지 않고, product pack 검증 Layer U(CHORE-20260611-007)가 정의한 검증 골격 위에서 import format이 W2에서 확정된 뒤 판단한다.

---

#### Project-state template pack 검토

**Cluster:** W5. Future / Optional

**Task:** `docs/decisions/DECISION-TEMPLATE.md` 외에 project-state-owned 파일을 채우는 template이 더 필요한지 검토한다. 후보: Work 파일 skeleton, backlog candidate row guide, retrospective/troubleshooting template, project decision index seed. 단, 작은 target에서 파일 수만 늘어나는 과잉 template은 피한다.

**Dependencies:**

- DR-021 project-state-owned, DR-013 Work spec, scaffold onboarding

**Done Criteria:** scaffold target이 project-owned 상태 파일을 채울 때 필요한 최소 template set을 확정하고, 불필요한 template은 만들지 않음

**Verification:** fresh scaffold onboarding 시뮬레이션, template 추가 전후 파일 수/사용 경로 확인

---

#### Sub-agent/Main Agent Authority Boundary

**Cluster:** W5. Future / Optional

**Task:** sub-agent / delegated agent 환경에서 **sub-agent와 main agent의 권한 경계**를 decision-only로 정리한다. 핵심은 메커니즘 구현이 아니라 policy다. sub-agent의 `write/propose` 경계, main agent의 `proposal / conditional approval / final approval` 가능 범위, human final approval 기본 유지 여부와 예외 조건, 그리고 이 차이를 어디에 인코딩할지(spawn prompt / delegation contract / tool 호출 규약)를 명시한다. 또한 single-session 병렬성의 기본 전제로 `disjoint task + isolated worktree`를 둘지 함께 정리한다. 이 후보는 trigger 전까지 dormant한 future candidate로 둔다.

**Dependencies:**

- `docs/briefs/harness-identity-policy-first-20260608.md`의 sub-agent autonomy / policy-mechanism 경계
- `docs/briefs/harness-sub-agent-concurrency-and-multi-user-tracking-20260616.md`
- current `docs/AGENT-WORKFLOW.md` Approval Matrix와 Work/DR tracking 규칙
- 실제 sub-agent 기능이 실용 단계에 들어오는지 여부

**Done Criteria:** sub-agent와 main agent의 최소 authority boundary 초안이 생기고, "spawn/how" 같은 메커니즘과 "who may propose/approve/finalize what" 같은 policy가 분리된다. sub-agent가 tracking surface를 직접 write할 수 있는지, main agent가 어떤 조건에서 conditional approval까지 맡을 수 있는지, human final approval을 어디까지 기본값으로 유지할지, multi-agent 결과물의 evidence relay와 escalation 경계가 어디인지 명시한다. multi-user source repo와 internal managed cross-repo는 신규 정책으로 재정의하지 않고 pointer로만 연결된다. trigger 전에는 dormant candidate로 유지된다.

**Verification:** policy matrix review, existing Approval Matrix와 충돌 여부 점검, authority encoding surface 후보 검토, `disjoint task + isolated worktree` 전제 하에서 어떤 위험이 줄고 어떤 것은 남는지 점검. Surface: canonical · tool surface · README/GUIDE/MANUAL.

---

#### Packaging / distribution revisit after upgrade logic proof

**Cluster:** W5. Future / Optional

**Task:** upgrade/migration 로직이 실제 target에서 검증되고 adopter 수요가 늘어날 때, packaging/distribution layer를 재검토한다. 범위는 npm wrapping, GitHub Releases + versioned install, upgrade discovery UX, 그리고 `--workflow` 명칭 같은 CLI surface clarity를 함께 다룬다. 단 plugin/npm 전환은 로직 검증보다 선행하지 않는다. 특정 option-pack에서 발생하는 국소 naming 마찰은 이 후보를 기다리지 않고 ad hoc으로 먼저 정리할 수 있다.

**Dependencies:**

- `docs/briefs/harness-distribution-plugin-model-20260608.md`의 "배포 방식보다 upgrade logic 선행" 판단
- `ai-deck-compiler` first real walkthrough 결과
- shell upgrade/migration 로직 안정화 여부
- DR-021, DR-023 no-alias migration 방향, CLI/help/generated text 현행 surface

**Done Criteria:** packaging/distribution을 다시 열 조건이 명시되고, npm wrapping / GitHub Releases / naming cleanup 중 무엇을 언제 검토할지 판단 기준이 생긴다. `--workflow` naming audit은 이 후보 안에서 하위 질문으로 흡수한다.

**Verification:** distribution option matrix review, CLI help/docs/scaffold generated text grep, old/new option migration impact review. Surface: scaffold · README/GUIDE/MANUAL · canonical.

---

#### Windows 지원 확장 (HRN-032)

**Cluster:** W5. Future / Optional

**Status:** 🔒 **보류(Hold)** — 실제 Windows adopter 또는 환경 robustness 실수요 확인 전 착수하지 않는다. 2026-06-13 실측 기반 scope 재정의.

**실측 (2026-06-13):** "Windows 지원"을 native(cmd/PowerShell only)까지 넓히는 framing은 과대하다.

- Claude Code/Codex Windows 사용자는 대부분 **WSL 또는 Git Bash** 환경이며, 그 환경에서 `create-harness.sh`(bash)·`tools/git-hooks/*`(sh, source-gitflow opt-in)·python은 **이미 동작**한다.
- `/tmp` 비호환은 검증 spine의 `temp/harness-tests/` 정책으로 **이미 해소**됐다 → 과거 Verification의 "`/tmp` 검증 경로 대체안" 항목은 **stale이라 제거**.
- 따라서 실질 fragility는 **Stop hook의 `python3` 의존성 1개**로 좁혀진다(`python3`가 아니라 `python`만 있는 환경 — Windows 한정이 아닌 환경 일반 문제).

**Task (재정의):** native cmd/PowerShell 지원은 **비목표**. 착수 시 ① WSL/Git Bash 동작 가정을 onboarding 문서에 명시 + 1회 smoke test, ② Stop hook `python3` 의존성을 환경 robustness 관점에서 점검(부재 시 graceful)으로 한정한다.

**Dependencies:** 실제 Windows adopter 발생 또는 `python3` 의존성 실수요.

**Done Criteria:** (착수 시) WSL/Git Bash 전제가 onboarding 문서에 명시되고 `python3` 의존성의 graceful 동작이 확인됨. native cmd/PowerShell 지원은 Done 기준에 포함하지 않는다.

**Verification:** WSL/Git Bash별 `create-harness.sh`·`/start` smoke, Stop hook의 `python3`/`python` fallback 동작 확인. (과거 `/tmp` 대체안 항목은 `temp/` 정책으로 해소되어 제거됨.)

---

## Deferred Ideas

| ID | Topic | Decision Point |
| --- | --- | --- |
| HRN-FUT-002 | `/health` 주간 자동 실행 설정 | 자동화 요청이 명확해지고 notification 경로가 확정된 후 |
| — | Work ID collision 자동화 — NNN 재배정 절차는 HARNESS-NAMING-RULES.md에 문서화 완료(CHORE-20260528-001). 병렬 feature에서 실제 collision이 반복되면 helper script로 `docs/works/**` 중복 Work ID 검사를 자동화 (L3) | collision이 실제 발생하거나 병렬 Active Work가 3개 이상 반복될 때 |
| — | External tracker override 적용 가이드 — escape hatch는 문서화 완료. Jira/Linear/GitHub Issues 등 external tracker를 실제 사용하는 product repo가 생기면 project-specific tracker policy와 Work ID 매핑 가이드 작성 | external tracker를 사용하는 product repo 운영 시점 |
| — | STATUS/Work README merge conflict 자동 복구 — manual-first conflict-resolution rule은 `docs/HARNESS-PARALLEL-WORK-CONTROLS.md`에 문서화하고 `docs/HARNESS-PROTOCOL.md`에는 조건부 pointer만 남김(CHORE-20260528-001). index regeneration automation이 필요해지면 L3 Work로 등록 | 병렬 feature PR merge 시 conflict가 반복될 때 |
| — | DR-### global sequence 충돌 처리 자동화 — Accepted 직전 번호 재확인 절차는 record-decision command/skill에 추가 완료(CHORE-20260528-001). `DR-DRAFT-{slug}` 임시 식별자 또는 번호 lock 자동화가 필요해지면 L3 Work로 등록 | 동시 진행 DR이 실제로 충돌하는 시점 |
| — | Command/skill mirror atomicity 강화 — Work CP 단위 atomicity rule은 `docs/HARNESS-PARALLEL-WORK-CONTROLS.md`와 health command/skill에 반영됨(CHORE-20260528-001). **mirror 존재 parity 차원은 DR-040(CHORE-20260619-001)으로 pre-commit+CI 자동 배선됨.** 잔여 = 내용(content) drift 자동 감지 — `check-surface-mirror-parity.sh`는 mirror 존재만 검사하고 내용 일치는 검사하지 않음. content-level 자동 감지가 필요해지면 L3 Work로 등록 | command/skill mirror **내용** drift가 실제 운영 버그로 이어질 때 |
| — | Multi-agent Exit Trigger 정량 임계치 — DR-039 Exit Trigger(Codex/Antigravity 격리)는 현재 정성 조건만 둠. 핵심 workflow(`work-plan` 등) 2회 연속 validation 실패 시 격리 DR 자동 개시 같은 정량 임계치를 검토 (FEAT-20260618-001 R2 C-b 제안) | 에이전트 엔진 분화로 공유 surface 실패가 실제 반복 관측될 때 |
