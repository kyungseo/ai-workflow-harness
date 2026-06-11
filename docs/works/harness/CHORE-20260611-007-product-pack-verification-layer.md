---
id: CHORE-20260611-007
priority: P1
status: Done
risk: L2
scope: 신규 product 착수 흐름(product starter planning pack, product engineering option-pack, product repo → source repo import loop)을 검증하는 layer를 maintainer 검증 카탈로그에 보강한다. 실제 planning pack/MSA option-pack 구현이나 base-msa-template 분석은 범위 밖.
appetite: 0.5d
planned_start: 2026-06-11
planned_end: 2026-06-11
actual_end: 2026-06-11
related_dr: [DR-021, DR-023, DR-031]
related_troubleshooting: []
related_work: [CHORE-20260611-002, CHORE-20260611-005, CHORE-20260611-006]
---

# CHORE-20260611-007: Product pack verification layer

## Top Summary

- **목표:** 신규 product 착수 흐름의 검증 기준을 `docs/maintainer/VERIFICATION-COMMANDS.md` 중심으로 보강한다. 대상: ① product starter planning pack 산출물 ② core scaffold ↔ product engineering option-pack 경계 ③ product repo → source repo import 후보 형식.
- **핵심 판단(driver의 push-back):** 검증 대상 중 **오늘 실재하는 것은 `--profile`/`--with-optional` 경계뿐**이다. planning pack(PRD/TRD/...)·import loop·MSA option-pack 산출물은 아직 **설계 전(W2 `Product starter planning pack + feedback import loop`, W5 `Spring Boot MSA TDD option-pack`)**이다. 존재하지 않는 산출물 형식에 concrete grep 명령을 지금 박으면 추측 기반 코딩이 된다(BEHAVIOR-PRINCIPLES §2). 따라서 이 Work는 **criteria/checklist 우선 layer**로 두고, concrete 명령은 *오늘 실재하는 surface(stack/profile↔core 경계)*에만 넣으며, 미설계 산출물은 Layer T처럼 **criteria + placeholder**로 표기한다.
- **Scope guard (Codex R0 must-fix):** `--profile spring-boot` 검사는 **legacy/current profile boundary smoke check일 뿐**이며, 미래 product engineering pack의 보존·내용 검증이 *아니다*. 현 spring-boot profile은 효용이 낮아 교체될 수 있다(backlog W5). Layer U는 "spring-boot이 곧 product pack"을 encode하지 **않는다** — encode하는 것은 **① 현 stack/profile-specific 콘텐츠가 core(generic)에 누수되면 안 된다 ② 미래 어떤 product pack이 들어와도 동등한 core↔pack 경계 검사를 가져야 한다**는 일반 원칙이다. spring-boot은 그 원칙의 *현재 유일한 구체 사례*로만 쓴다.
- **범위:** 문서 layer/checklist 보강 + 기존 척추(CHORE-20260611-005/006)와 경계 정렬만. helper script·실제 pack 구현·base-msa-template 분석은 후속.

## Background

- backlog `Product pack verification layer 보강`의 사전 검토(2026-06-11)는 이미 다음을 확정: Layer J/J-OB/Q가 scaffold·onboarding·hook simulation을 충분히 다루고, Layer T는 upgrade/migration placeholder다. product starter/import loop·product-local harness 산출물·import 후보 형식은 **별도 layer가 없다**.
- 검증 척추(CHORE-20260611-005) 3층 경계: `scripts/tests/**`(executable SSoT) / `VERIFICATION-COMMANDS.md`(HOW 카탈로그) / `repo-health.md`(judgment). product pack 검증은 **deterministic 불변식이 아니라 judgment/checklist** 성격이므로 executable spine이 아니라 **catalog layer**에 둔다. taxonomy §3은 이미 product/adopter surface를 "non-goal → 이 Work"로 위임해 둠.
- `--profile spring-boot`는 오늘 실재하며 stack-specific 콘텐츠를 생성한다(`create-harness.sh` 529/620/656/977 등). 즉 "core scaffold ↔ stack/profile pack 경계"는 **지금 검증 가능**하다. 단 이는 *현재 사례*일 뿐 — spring-boot profile 자체는 효용이 낮아 교체될 수 있으므로(W5), Layer U는 spring-boot 보존이 아니라 **일반 경계 원칙**(stack 콘텐츠 비누수 + 미래 pack 동등 경계 요구)을 검증한다.

## Scope / Plan

> 합의 전 구현 금지. 아래는 Codex R0 plan review 대상. R0 합의 후 구현 착수.

### Scope

1. `VERIFICATION-COMMANDS.md`에 **신규 Layer(U 후보) — Product Starter / Option-pack Import 검증** 추가.
   - **(a) 지금 실재 — concrete 명령 (boundary smoke check):** core scaffold(generic)에 stack/profile-specific·optional 콘텐츠가 누수되지 않고, `--profile spring-boot`/`--with-optional` 선택 시에만 나타나는 경계 확인. **이는 현 profile boundary smoke check이지 spring-boot pack 보존·내용 검증이 아니다** — Layer U 서술은 "현 stack 콘텐츠 비누수 + 미래 product pack도 동등 경계 검사 필요"라는 일반 원칙으로 기술하고, spring-boot은 그 원칙의 현재 구체 사례로만 인용한다.
   - **(b) criteria/checklist — 미설계 산출물:** product starter planning pack 산출물 존재·역할 checklist, base-msa-template 분석 include/exclude 기준, product→source import 후보 mapping 형식. **concrete 명령 대신 판정 기준**으로 두고, W2/W5 산출물이 확정되면 명령으로 채운다(Layer T 패턴).
2. `VERIFICATION-COMMANDS.md` **M5 양방향 cascade 표**에 product engineering pack 옵션/문서 변경 → Layer U 갱신 trigger 행 추가.
3. `HARNESS-TEST-TAXONOMY.md` §3 product/adopter surface 행: **executable spine 기준 non-goal 유지** + "catalog Layer U(checklist)로 정의됨" pointer만 갱신(구조 변경 아님).
4. `HARNESS-RECOVERY-VALIDATION.md`: **기본 추천 = 미변경**. import loop가 아직 live가 아니므로 always-loaded judgment 체크리스트에 미존재 흐름 항목을 추가하지 않는다(core 비대화 회피, §2/§6). (대안은 OQ-2에서 Codex 판단.)
5. helper script: **이번 Work 없음**. checklist/catalog만. 사유 기록(OQ-5).

### Files (후보 — R0 합의 후 확정)

| 파일 | 변경 | 비고 |
| --- | --- | --- |
| `docs/maintainer/VERIFICATION-COMMANDS.md` | 신규 Layer U + M5 cascade 행 | 주 변경. source-only maintainer 문서(scaffold 대상 아님) |
| `docs/maintainer/HARNESS-TEST-TAXONOMY.md` | §3 product/adopter 행 pointer 갱신 | 1줄 수준 pointer, non-goal 판정 유지 |
| `docs/HARNESS-RECOVERY-VALIDATION.md` | 기본 미변경(OQ-2 결과 따름) | 변경 시 judgment item 1개 이하 |
| `docs/backlog/HARNESS.md` | work-close 시 row 처리 | close 단계 |
| `docs/STATUS.md` | Recent Decisions / Next Actions / Last updated | close 단계, Approval Matrix |
| `docs/works/harness/README.md` | Active→Done 이동 | close 단계 |

### Verification

- `VERIFICATION-COMMANDS.md` 자체 점검 M1~M5(경로 실재, 명령 stale, bash 문법 1차, repo-health 등재, cascade 범위).
- 신규 Layer U의 (a) concrete 명령을 실제 실행: generic scaffold에 spring-boot/optional 산출물 누수 없음 + spring-boot/optional 선택 시 등장. → `temp/`에 생성하여 walkthrough.
- `git diff --check`, `bash scripts/tests/check-shipped-dr-closure.sh`.
- **척추 연결:** `bash scripts/tests/run-harness-checks.sh --all`을 변경 후 1회 — 이번 변경은 source-only 문서라 runner 자체 회귀는 없어야 하나, `--tier0`(문서 whitespace/script syntax)와 tier2(scaffold 3모드) green 유지를 확인한다. Layer U의 (a)가 invariants `[2] leak-scan`/scaffold 생성과 충돌하지 않는지 교차 확인.
- Done Criteria walkthrough: 신규 Layer가 W2 product starter flow와 W5 option-pack 후보를 *어떻게* 검증하게 될지 경로가 끊기지 않는지(현재 (a) 실행 + (b) criteria로 연결).

### Risk / Reversal

- **리스크 1 (주):** 미설계 산출물(planning pack/import format)에 대해 과하게 구체적인 검증을 박으면 W2/W5 착수 시 재작성·drift 발생. → criteria/placeholder로 한정하여 완화.
- **리스크 2:** Layer 문자/배치(U vs L), taxonomy 행 처리 방식에 대한 이견. → OQ-1/추가 OQ로 R0에서 합의.
- **리스크 3:** recovery-validation에 judgment item을 넣을지 경계 모호. → OQ-2.
- **되돌리기 비용:** Low. 전부 source-only maintainer 문서 추가/조정이며 branch 단위 revert 가능. executable spine·scaffold 출력 미변경.

### 후속으로 넘길 항목

- planning pack/import format concrete 명령 채우기 → W2 `Product starter planning pack + feedback import loop` 착수 후.
- MSA option-pack 전용 검증 → W5 `Spring Boot MSA TDD option-pack` 착수 후.
- product pack 검증의 executable 승격(필요 시) → 척추 F3.
- runner/repo-health 연계 → F4(`repo-health gate series 보강`).
- helper script 여부 → 반복 사용 확인 후.

### Codex review questions

- Layer 배치: 끝(Layer U, Layer T와 future-leaning 군집) vs K↔N 사이 gap(Layer L)? (OQ-1)
- recovery-validation 미변경이 맞는가, 아니면 최소 judgment item 1개를 지금 넣는 게 맞는가? (OQ-2)
- planning pack checklist 최소 산출물 집합이 적절한가(과/소)? (OQ-3)
- import 후보 mapping format을 provisional table로 지금 명시 vs W2까지 형식 자체도 미정으로 둘지? (OQ-4)
- helper script 없이 checklist/catalog만으로 이번 Done Criteria가 충족되는가? (OQ-5)

### DR-007 언어 정책

- 수정 대상이 maintainer 문서(한국어 primary). 신규 Layer 서술은 Korean primary + 기술 식별자 English 유지. commit subject/body Bilingual Rules.

### CHORE-20260611-005/006 검증 척추와의 연결 방식

- 이 Layer는 **catalog(HOW) 층**에만 추가된다. taxonomy(WHAT/HOW-DEEP)는 product/adopter를 executable non-goal로 유지하고 pointer만 갱신. recovery-validation(WHETHER/WHEN)은 기본 미변경.
- `run-harness-checks.sh`는 변경하지 않는다(executable spine은 deterministic 불변식 전용, product pack 검증은 judgment).

## Cross-Agent Review And Discussion

이 Work는 A(Claude)가 author/driver로 Work 파일+plan 및 구현을 담당하고,
B(Codex)가 plan review와 result review를 수행한다.
합의 전에는 구현하지 않는다.

### Round Log

| Round | Reviewer | Type | Summary | Required Changes / Decision | Status |
| --- | --- | --- | --- | --- | --- |
| R0 | Codex | Plan Review | 조건부 승인. Layer U 신설, Layer T 분리, recovery-validation 미변경, taxonomy non-goal+pointer, helper 없음 방향 타당. OQ-1~5 전부 승인(OQ-4는 "review aid"로 명시 조건). | Must-fix 2건: ① Work 파일 끝 `</content>`/`</invoke>` 제거 ② `--profile spring-boot` 검증은 legacy/current profile boundary smoke check일 뿐 미래 product engineering pack 보존/검증이 아님을 Layer U·plan에 명시. **둘 다 반영 완료.** | Conditional Approval → Resolved |
| R1 | Codex | Result Review | 변경 방향 R0 합의와 정합(Layer U/T 분리, recovery-validation 미변경, taxonomy non-goal, spring scope guard 확인). diff/closure/tier0 재검증 PASS. | Must-fix: U1 hard check가 rule marker만 봐 stack 전용 prompt 누수 미검출 가능 → `stack_markers`에 대표 prompt 포함(rule+prompt 동일 loop). Nice-to-fix: Discovery "14종" count 정정. **둘 다 반영 완료.** | Changes Requested → Resolved |
| R2 | Codex | Result Review | R1 보정 확인. U1 marker 검사가 rule + 대표 prompt를 같은 absent/present 루프에서 확인하도록 보강되어 stack prompt 누수 미검출 리스크가 닫힘. Discovery count도 현재 구조(rule 4 + prompt 10)와 정합. | 추가 변경 요청 없음. work-close 진행 승인. | Approved |

### Consensus Log

| Topic | Consensus | Source Round | Status |
| --- | --- | --- | --- |
| Layer placement | 신규 Layer U(끝, Layer T와 future-leaning 군집). Layer T(upgrade/migration)와 분리. product 검증은 catalog 층 | R0 | Agreed |
| product starter checklist | 산출물 **존재·역할** checklist(내용 검증 아님): product goal/PRD/TRD, architecture, code conventions, user flow, DB design, screen/flow, tasks, test structure, loop 절차. 내용 품질 검증은 W2/W5 | R0 | Agreed |
| import mapping format | provisional 경량 표(product artifact → generalizable? → source target path → adapt/write_text class). **format contract가 아니라 review aid로 명시**. W2에서 확정 | R0 | Agreed |
| recovery/taxonomy boundary | recovery-validation 기본 미변경(concrete command 복제 없음); taxonomy §3 행 executable non-goal 유지 + Layer U pointer만 갱신 | R0 | Agreed |
| helper script need | 이번 Work 없음(checklist/catalog만). 반복 사용 확인 후 후속 판단 | R0 | Agreed |
| existing-vs-speculative split | concrete 명령은 stack/profile↔core 경계(실재)만 — **boundary smoke check이지 spring-boot pack 보존/검증 아님**; planning pack/import는 criteria+placeholder. Layer U는 "현 stack 비누수 + 미래 pack 동등 경계" 일반 원칙을 encode | R0 | Agreed |

### Plan-Level Open Questions

| ID | Question | 합의 결과 | Owner | Status |
| --- | --- | --- | --- | --- |
| OQ-1 | product pack 검증을 신규 layer로 둘 것인가, 기존 Layer T와 연결할 것인가? Layer 문자는 U vs L? | 신규 Layer **U**(Layer T와 분리 — upgrade/migration ≠ product starter/import). 끝에 배치 — R0 승인 | Claude + Codex | Closed |
| OQ-2 | `HARNESS-RECOVERY-VALIDATION.md`에 judgment item을 추가할 것인가? | **미변경**(import loop 미-live, core judgment 비대화 회피) — R0 승인 | Claude + Codex | Closed |
| OQ-3 | source-first planning pack checklist의 최소 산출물은? | 9종(존재·역할만, 내용 품질은 W2/W5) — R0 승인 | Claude + Codex | Closed |
| OQ-4 | product→source import 후보 mapping format 형태는? | provisional 경량 표, **format contract 아닌 review aid로 명시**, W2에서 확정 — R0 승인 | Claude + Codex | Closed |
| OQ-5 | scripts helper 없이 checklist/catalog만으로 충분한가? | **충분**. 미설계 산출물에 helper는 과조기 — R0 승인 | Claude + Codex | Closed |

## Done Criteria

- [x] product starter planning pack과 product engineering option-pack에 대한 검증 layer가 `VERIFICATION-COMMANDS.md`에 추가됨(Layer U: U1 boundary + U2 planning pack checklist + U3 base-msa 범위 + U4 import review aid + U5 cascade).
- [x] Layer T(upgrade/migration)와 역할 경계가 명확함(Layer U intro에 분리 근거 명시, Release Full Sweep 게이트 밖 목록에 별도 등재).
- [x] 오늘 실재하는 surface(stack/profile↔core 경계)에 대해서는 concrete 명령이, 미설계 산출물(U2~U4)에 대해서는 criteria/placeholder가 들어감(추측 기반 명령 없음).
- [x] `HARNESS-RECOVERY-VALIDATION.md`에는 concrete command가 중복되지 않음(미변경 — OQ-2 합의대로).
- [x] taxonomy §3 product/adopter 행이 Layer U pointer로 정합(executable non-goal 유지 명시).
- [x] scripts helper 필요 여부 판단 + 미사용 사유 기록(없음 — 미설계 산출물에 helper 과조기, OQ-5).
- [x] M5 cascade 표에 product pack 옵션/문서 변경 trigger 행 추가.

## Discovery

- **U1 concrete 명령의 false-positive를 실제 실행으로 잡음(중요).** 초안 U1.1은 `grep "spring-boot\|CODING-PRINCIPLES"`로 generic core 누수를 보려 했으나, generic `BOOTSTRAP.md`/`HARNESS-PROTOCOL.md`가 `--profile spring-boot` 옵션을 *안내 문구로 언급*하는 것을 LEAK로 오탐했고 `CODING-PRINCIPLES`는 실존 파일이 아니었다. 실제 stack 콘텐츠는 **파일 단위**로 spring profile에만 추가된다(rule 4: `.claude|.cursor/rules/{java-spring,testing}` + stack 전용 prompt 10 = 14 파일). → U1을 **stack-marker 파일 존재 검사**(`comm -13` 진단 + 단일 `stack_markers` 리스트로 rule + 대표 prompt를 absent/present `-e` 검사)로 정정. 재실행 시 FP 없이 전부 OK.
- **R1(Codex result review) must-fix 반영:** 초안 U1 hard check가 rule marker만 봐 stack 전용 prompt 누수를 놓칠 수 있었다. rule + 대표 prompt(`02-scaffold-service`, `21-create-layer`)를 같은 absent/present loop로 검사하도록 보강. Discovery prompt count도 "14종"→"rule 4 + prompt 10"으로 정정.
- **추가 portability 보강(실행 중 자가 발견):** R1 반영 1차안에서 `stack_markers` scalar를 `for m in $stack_markers`로 분리하려 했으나, 이 repo 셸이 **zsh**라 unquoted scalar word-splitting이 일어나지 않아 marker 전체가 단일 토큰으로 처리됐다(bash에선 분리되나 카탈로그는 임의 셸에서 maintainer가 직접 실행). → marker 리스트를 **`for ... do` literal 리스트**로 두어 bash/zsh 양쪽 portable하게, 각 marker의 generic-부재 + spring-존재를 단일 루프에서 검사하도록 최종 정정. (카탈로그의 기존 BSD grep portability 주석 정책과 동일 선상.)
- 검증 결과: `run-harness-checks.sh --all` OVERALL PASS(source-only 문서 변경이라 척추 회귀 없음), `git diff --check` clean, `check-shipped-dr-closure.sh` OK. M1 self-check의 MISSING 4건은 전부 기존 false positive(M1/M2 자기참조 텍스트, J5/N optional 경로, Layer F 루프변수)로 이번 변경과 무관.
- 변경 파일: `VERIFICATION-COMMANDS.md`(Layer U + M5 행 + sweep 게이트밖), `HARNESS-TEST-TAXONOMY.md`(§3 pointer), `docs/works/harness/README.md`(Active 등록), Work 파일 신설.
- 남은 후속: planning pack/import concrete 승격은 W2, MSA pack 검증은 W5, executable 승격은 F3, repo-health 연계는 F4.
