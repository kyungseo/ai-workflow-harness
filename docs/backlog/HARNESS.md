# HARNESS.md

AI Workflow Harness backlog다.

이 파일은 Claude/Codex/Cursor 등 Agent workflow, 문서 상태 관리, command/rule 정합성, hook/CI enforcement 후보를 관리한다.
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
| W2. Adopter Transition | 다음 주 실제 product scaffold 운영에 필요한 적용·업그레이드·온보딩 흐름을 준비한다 | (upgrade/migration 완료 = CHORE-20260611-010, docs cascade 완료 = CHORE-20260611-011, planning pack 완료 = CHORE-20260612-001, readability rewrite 완료 = CHORE-20260612-002, clone verification 완료 = CHORE-20260612-003) 후속 후보: `ai-deck-compiler` first real walkthrough, internal managed mode guardrails(게이트 후), 첫 concrete product planning-pack exercise/import review, happy path / glossary / operator layering compression |
| W3. Workflow IA Diet ✓ 완결 | source/target 경계, canonical weight, optional pack, trigger 구조를 더 가볍게 정렬한다 | (Canonical 개념 계층화 핵심 달성 = CHORE-20260613-002~005, Prompt surface diet 완료 = CHORE-20260612-010, work-doc class 완료 = CHORE-20260613-005, trigger family simplification 완료 = CHORE-20260613-006) 전부 완료 |
| W4. Enforcement And Lifecycle | 반복되는 운영 실수를 hook/CI/test 또는 closeout 절차로 줄인다 | (전부 종결) Validation Spine residual F1~F4 = CHORE-20260613-017/018·DR-036, 문서-only 규칙 강제화 = DR-037, Archive 누적 관리 정책 = DR-038, CI inline assertion ↔ invariants SSoT parity = CHORE-20260613-016 no-action closeout |
| W5. Future / Optional | 실제 product 운용 후 필요가 확인되면 확장한다 | Spring Boot MSA TDD option-pack, project-state template, sub-agent autonomy policy, packaging/distribution revisit, Windows 지원 |

### Summary

| ID | Priority | Status | Risk | Title |
| --- | --- | --- | --- | --- |
| — | P1 | Candidate | L2 | `ai-deck-compiler` first real upgrade walkthrough + DR-034 acceptance judgment |
| — | P1 | Candidate | L2 | Happy path / glossary / operator layering compression |
| — | P1 | Candidate | L2 | First concrete planning-pack exercise (rfx-hub) + BOOTSTRAP prepared-brief intake hook + import review |
| — | P1 | Candidate | L2 | No-code/content onboarding depth — PLAN.md 목표 라우팅 분리 + non-code 운영-모델 step |
| — | P2 | Candidate | L3 | Internal managed mode design note + target guardrails (post-walkthrough gate) |
| — | P2 | Candidate | L3 | Spring Boot MSA TDD option-pack — product engineering pack 후보 |
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

#### First concrete planning-pack exercise (rfx-hub) + BOOTSTRAP prepared-brief intake hook + import candidate review

**Cluster:** W2. Adopter Transition

**Task:** `rfx-hub`(RFx 대응 engagement 운영 hub) onboarding을 **첫 concrete planning-pack exercise로 공식화**한다. source-only planning pack skeleton을 실제 product에 적용해 산출물 세트를 만들고, CHORE-20260612-001이 provisional로 남긴 source-owned / product-owned / import-candidate 경계를 실측한다.

이 exercise에서 노출된 gap을 함께 보강한다: **준비된 project brief/요약본/planning-pack 산출물을 onboarding이 적시에 intake하지 못한다**(현재 BOOTSTRAP은 순수 대화형 Q&A뿐 — live 세션에서 `temp/rfx-hub-onboarding-handoff.md`를 수동으로 끼워넣어야 했음). 보강:
- BOOTSTRAP §1 진입 직전 **intake step** 추가 — "준비된 brief/요약본/planning-pack 산출물이 있으면 경로 또는 텍스트로 먼저 받아 §1·§2·(§4) 초안에 반영. 권장 포맷은 PRODUCT-STARTER-PLANNING-PACK. 없으면 대화형 fallback."
- Bootstrap-State Rule(session-start)에 **보유 여부 선질문** 한 줄.

intake hook(소비 측)과 planning pack(입력 포맷)은 같은 loop의 양 끝이므로 한 작업으로 묶어 정합을 맞춘다.

**진행:** BOOTSTRAP prepared-brief intake hook은 `CHORE-20260617-001`로 구현 완료 — format-agnostic으로 planning-pack에 비의존(shipped 템플릿은 source-only 경로 비인용). 남은 candidate scope = rfx-hub clean 재온보딩 end-to-end exercise + import candidate review.

**Dependencies:**

- CHORE-20260612-001 planning pack/import loop 기준, `docs/maintainer/PRODUCT-STARTER-PLANNING-PACK.md`
- `rfx-hub` live onboarding test bed, `temp/rfx-hub-onboarding-handoff.md`(ad-hoc planning-pack 선례)
- session-start Bootstrap-State Rule(#206), BOOTSTRAP §0 git-init 권장 기본값(#207)

**Done Criteria:** BOOTSTRAP prepared-brief intake hook이 정의되고(없으면 대화형 fallback), `rfx-hub` clean re-scaffold 재온보딩으로 intake→§1/§2/§4 반영이 end-to-end 검증된다. planning-pack 산출물의 owner 분류(source/product/import)가 기록되고, import 후보의 일반화 가능 범위·보류 이유, Layer U/U4 checklist 유지/보강 판단이 정리된다.

**Verification:** Layer U checklist, product artifact → source import mapping review, intake hook fresh-scaffold 재온보딩 검증, optional pack/tool-surface spillover 점검. Surface: scaffold · canonical(session-start) · tool surface · adopter cascade · README/GUIDE/MANUAL.

---

#### No-code/content onboarding depth — PLAN.md 목표 라우팅 분리 + non-code 운영-모델 step

**Cluster:** W2. Adopter Transition

**Task:** rfx-hub(content/research, no-code) 첫 대화형 온보딩에서 노출된 gap. BOOTSTRAP이 code-centric이라 no-code 프로젝트가 정체성만 남고 얇게 부팅된다(실측: PLAN.md 전체 미작성 — `## 목표`조차 빈 placeholder, 운영/콘텐츠 구조 단계 부재).

- **gap 1 — PLAN.md 라우팅:** BOOTSTRAP §6 Fill Order가 PLAN.md를 통째로 "코드 프로젝트" 단계(step 5)에 묶어, no-code면 코드 비종속 부분(`## 목표`·roadmap)까지 누락. → 목표/roadmap을 Project Initialization Plan(코드 전용)과 분리해 모든 프로젝트에 라우팅한다.
- **gap 2 — non-code 운영-모델 step 부재:** 코드 프로젝트의 §3 Implementation Baseline에 대응하는 no-code용 step이 없음. content/research/no-code엔 운영/콘텐츠 모델(artifact 구조·taxonomy·수집/분류/재사용 workflow) step을 §3 대체로 제공한다.

**연계:** planning-pack exercise(rfx-hub) finding에서 도출. intake hook(`CHORE-20260617-001`)과 보완 — intake는 준비된 brief가 있을 때, 이 항목은 대화형 no-code 경로의 깊이. "Happy path / operator layering" 후보와 인접하나 그건 진입 경로 압축, 이건 no-code 부팅 깊이/PLAN 라우팅이라 별개.

**Dependencies:**

- BOOTSTRAP 템플릿(`scripts/create-harness.sh`) §3/§6, PLAN.md·PLAN-SUMMARY 템플릿
- rfx-hub 온보딩 실측(content/research, no-code) reference, `temp/rfx-hub-onboarding-handoff.md`(no-code 운영 구조 선례)

**Done Criteria:** no-code 프로젝트 온보딩이 (a) PLAN.md `## 목표`/roadmap을 코드 여부와 무관하게 채우도록 라우팅되고, (b) §3 N/A 시 운영/콘텐츠 모델 step으로 대체되어 정체성만 남는 thin 부팅이 해소된다. fresh no-code scaffold 재온보딩으로 검증된다.

**Verification:** BOOTSTRAP §3/§6 + PLAN/PLAN-SUMMARY 템플릿 변경, no-code fresh-scaffold 재온보딩 시뮬레이션. Surface: scaffold · README/GUIDE/MANUAL · (필요시) canonical(session-start/BOOTSTRAP 절차).

---

#### Spring Boot MSA TDD option-pack — product engineering pack 후보

**Cluster:** W5. Future / Optional

**Task:** 실제 신규 product에서 검증된 product engineering 산출물을 바탕으로 Spring Boot 기반 MSA용 TDD option-pack을 설계한다. 기존 "coding guide" 단일 문서 발상은 범위가 좁으므로, PRD/TRD/code conventions/user flow/DB design/screen/tasks/test structure/loop 절차를 포함할 수 있는 product engineering pack으로 재정의한다. 단, 처음부터 source repo에 과잉 일반화하지 않고 product repo에서 검증된 뒤 source repo로 import한다.

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

**Done Criteria:** core scaffold(옵션 미지정)에는 포함되지 않음. product repo에서 검증된 산출물 중 일반화 가능한 부분만 option-pack 후보로 편입. Spring Boot MSA pack을 둘지, 더 일반적인 product engineering pack으로 둘지 결정. stack별 확장(`--with-spring-boot-msa`, `--with-react` 등)은 필요가 확인된 것만 둔다.

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
| — | Command/skill mirror atomicity 강화 — Work CP 단위 atomicity rule은 `docs/HARNESS-PARALLEL-WORK-CONTROLS.md`와 health command/skill에 반영됨(CHORE-20260528-001). drift 자동 감지(CI/hook)가 필요해지면 L3 Work로 등록 | command/skill mirror drift가 실제 운영 버그로 이어질 때 |
