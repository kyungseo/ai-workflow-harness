# HARNESS.md

AI Workflow Harness backlog다.

이 파일은 Claude/Codex/Cursor 등 Agent workflow, 문서 상태 관리, command/rule 정합성, hook/CI enforcement 후보를 관리한다.
프로젝트 기능 backlog가 필요한 경우 `docs/backlog/PRODUCT.md`를 별도로 둔다.

기존 product-template backlog와 Work 기록은 history와 archive에 남아 있지만, 이 repository의 현재 active scope는 AI Workflow Harness다.

> Done/Superseded 항목은 이 파일에서 제거된다.
> 완료 이력: Work 파일이 있는 항목은 `docs/works/harness/README.md` Archived 테이블, Work 파일이 없는 항목(Quick Mode)은 `git log --grep="{ID}"`로 확인한다.

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
| W1. Validation Spine ✓ 완결 | 이번 주 이후 큰 하네스 변경을 줄이더라도 regression을 잡을 수 있는 최소 검증 척추를 만든다 | (전부 완료) 검증 척추 spine 도입 = CHORE-20260611-005, scaffold/tool-surface leak-scan alignment = CHORE-20260611-006, product pack 검증 Layer U = CHORE-20260611-007, gate path-list parity = CHORE-20260611-008, source repo maintainer operations manual = CHORE-20260611-009. 잔여 후속 F1~F4는 W3 repo-health slice·W4 enforcement로 연결 |
| W2. Adopter Transition | 다음 주 실제 product scaffold 운영에 필요한 적용·업그레이드·온보딩 흐름을 준비한다 | (upgrade/migration 완료 = CHORE-20260611-010, docs cascade 완료 = CHORE-20260611-011, planning pack 완료 = CHORE-20260612-001) User-facing docs readability rewrite, Scaffold multi-user clone verification |
| W3. Workflow IA Diet | source/target 경계, canonical weight, optional pack, trigger 구조를 더 가볍게 정렬한다 | 외부화 실패모드 원칙, Canonical 개념 계층화, Prompt surface diet, trigger family simplification, repo-health slice, work-doc class |
| W4. Enforcement And Lifecycle | 반복되는 운영 실수를 hook/CI/test 또는 closeout 절차로 줄인다 | 문서-only 규칙 강제화, Backlog row lifecycle SSoT, Archive 누적 관리 정책 |
| W5. Future / Optional | 실제 product 운용 후 필요가 확인되면 확장한다 | Spring Boot MSA TDD option-pack, project-state template, CLI naming audit, Windows 지원, `/exit` gap |

### Summary

| ID | Priority | Status | Risk | Title |
| --- | --- | --- | --- | --- |
| — | P1 | Candidate | L2 | User-facing docs readability rewrite — audience-aware README/MANUAL/GUIDE |
| — | P1 | Candidate | L2 | Scaffold multi-user clone verification |
| — | P2 | Candidate | L2 | Validation Spine residual follow-ups (F1-F4) |
| — | P1 | Candidate | L2 | 외부화 실패모드 통합 설계 원칙 명문화 |
| — | P1 | Candidate | L3 | Canonical 개념 계층화 + context-routing restructure |
| — | P1 | Candidate | L2 | Prompt surface diet + optional pack 재정의 |
| — | P2 | Candidate | L2 | Harness protocol trigger family simplification |
| — | P2 | Candidate | L2 | `skills/workflow/repo-health.md` slice 분리 |
| — | P2 | Candidate | L2 | `skills/workflow/work-doc.md` class 재검토 |
| — | P1 | Candidate | L2 | 문서-only 규칙 강제화 (CI/hook/hard-gate) |
| — | P1 | Candidate | L2 | Backlog row lifecycle SSoT 정비 |
| — | P2 | Candidate | L2 | Archive 누적 관리 정책 |
| — | P2 | Candidate | L3 | Spring Boot MSA TDD option-pack — product engineering pack 후보 |
| — | P2 | Candidate | L2 | Project-state template pack 검토 |
| — | P2 | Candidate | L3 | Scaffold CLI naming audit |
| HRN-032 | P2 | Candidate | L2 | Windows 지원 확장 |
| HRN-016 | P3 | Candidate | L1 | `/exit` → Stop hook gap 추적 |

---

### Details

> **Verification 작성 기준:** 변경이 건드리는 surface를 항목별로 명시한다.
> 점검 후보: tool surface · adopter cascade · canonical · scaffold · README/GUIDE/MANUAL
> 해당 없는 surface는 제외한다.

---

#### Validation Spine residual follow-ups (F1-F4)

> 2026-06-11 등록/정리 (CHORE-20260611-005~009 Discovery). W1 Validation Spine 자체는 완결됐지만, executable 승격·CI/hook 배선·repo-health 통합은 별도 후보로 계속 추적한다.

**Cluster:** W3/W4 bridge — Workflow IA Diet + Enforcement And Lifecycle.

**Task:**

- F1: `VERIFICATION-COMMANDS.md` catalog Layer J/J-OB/Q를 deterministic script로 변환하고, catalog Layer J/J-OB/Q/R/S의 `/tmp/awh-*` 경로를 repo-local `temp/` 정책에 맞춰 치환한다. `HARNESS-TEST-TAXONOMY.md` §5는 이미 정책만 확정했으며, 일괄 치환은 이 후속 Work 범위다.
- F2: `run-harness-checks.sh`를 CI required check 또는 pre-commit/hook에 배선할지 결정한다. `문서-only 규칙 강제화`와 함께 예외/우회 정책을 먼저 판단한다.
- F3: mirror parity, prompt 정합, language policy 같은 catalog/judgment 점검을 deterministic Tier 1 assertion으로 승격할지 검토·구현한다. product pack Layer U의 executable 승격도 실제 반복 필요가 확인되면 여기서 다룬다.
- F4: runner 결과를 `/repo-health`에 surface한다. `skills/workflow/repo-health.md` slice 분리와 연계하되, repo-health가 deterministic 불변식을 재구현하지 않고 runner/catalog 결과를 호출·해석하는 경계를 유지한다.

**Dependencies:**

- CHORE-20260611-005: taxonomy + tier runner
- CHORE-20260611-006: scaffold/source-gitflow regression alignment
- CHORE-20260611-007: product pack Layer U
- CHORE-20260611-008: gate path-list parity Q-static
- CHORE-20260611-009: source repo operations runbook(Update Triggers)

**Done Criteria:** F1~F4 각각이 Work로 분해되거나, 범위가 다른 backlog 항목(`문서-only 규칙 강제화`, `repo-health.md slice 분리`, W2/W5 product pack 후보)에 명시적으로 흡수됨. `HARNESS-TEST-TAXONOMY.md` §6와 `SOURCE-REPO-OPERATIONS.md` Update Triggers의 후속 pointer가 stale하지 않음.

**Verification:** taxonomy §5/§6, `VERIFICATION-COMMANDS.md` Layer J/J-OB/Q/R/S, `run-harness-checks.sh`, `skills/workflow/repo-health.md`, `SOURCE-REPO-OPERATIONS.md` 간 pointer 정합 grep. F1 착수 시 `/tmp/awh-*` 잔존 grep으로 치환 범위 확인.

---

#### Backlog row lifecycle SSoT 정비

**Cluster:** W4. Enforcement And Lifecycle

**Task:** backlog row 제거 시점이 `HARNESS-PROTOCOL.md`("Work archived 시"), `work-plan.md`("develop merge 후 tracking-only commit"), `work-close.md`(현재는 Step 5에 동일 commit 제거 명시) 세 곳에서 불일치. 매 work-close마다 수동으로 잡아야 하는 구조적 결함. 단일 시점("Work Done 처리 시 동일 commit에 포함")으로 통일하고, `work-plan.md`의 잘못된 타이밍 문구를 정정한다. `HARNESS-PROTOCOL.md` Pruning Policy도 일치시킨다.

> **[2026-06-11 추가, CHORE-20260611-005 close 시 사용자 제기]** `DR-013`의 "backlog row 정리는 develop merge 후 tracking-only commit" 문구도 함께 정리 대상이다. 이 문구는 본래 **ID-less candidate에 Work ID를 역기입하지 않는 정책 맥락**인데, 완료 row 제거 일반 규칙으로 오독될 수 있다. canonical `work-close.md` Step 5(동일 commit 제거)와 정합하도록 DR-013 문구를 한정·정정한다(제거 ≠ ID backfill).

**Dependencies:**

- CHORE-20260607-002 (착수 정합성 hardening Done)

**Done Criteria:** 세 파일의 backlog row 제거 시점이 동일하게 정의됨. work-close 실행 시 backlog row 확인 단계가 자연스럽게 포함됨

**Verification:** work-close 시뮬레이션에서 backlog row 제거 단계가 프롬프트 없이 실행됨. `work-plan`·`work-close`·`HARNESS-PROTOCOL` 세 파일 grep으로 일치 확인

---

#### 외부화 실패모드 통합 설계 원칙 명문화

**Cluster:** W3. Workflow IA Diet

**Task:** AI 맥락 외부화의 3대 실패모드(① 라우팅 누락 ② 비대화 ③ 선언-실행 괴리)와 각 보완(manifest·canonical / archive drain·SSoT 단일화 / test·hard-stop)을 Phase 2 slice 0 방향 결정의 상위 프레임으로 채택

**Dependencies:**

- CHORE-20260604-001 (Done), slice 0

**Done Criteria:** 3대 실패모드와 보완 매핑을 Phase 2 설계 원칙으로 문서화하고, 기존 §5·§7·§8·§9 결정이 이 프레임에 정합하는지 확인

**Verification:** slice 0 방향 결정 문서/DR에서 세 실패모드가 각각 어느 보완으로 닫히는지 추적 가능

---

#### Archive 누적 관리 정책

> 2026-06-10 등록 (사용자 제기).

**Cluster:** W4. Enforcement And Lifecycle

**Task:**

- archive artifact가 지속 누적되는 구조가 문제인지 판단하고, 필요 시 관리 정책을 수립한다.
- **범위(사용자 지시 확장):** work 파일뿐 아니라 **decision(DR) 및 기타 archived artifact(retrospective/troubleshooting)** 누적도 동일 프레임으로 다룬다.
- **실태 (2026-06-10 측정):**
  - `docs/archive/docs/works/harness/` 71개, `docs/archive/docs/decisions/` 9개.
  - work 파일은 6월 1~10일 ~30개 증가(≈3/day) — 증가율 가파름.

**비판적 framing (먼저 해악을 정량화 — Simplicity First):**

- archive는 세션 시작 시 자동 로드되지 않는다 (`docs/AGENT-WORKFLOW.md`가 archive 로드를 명시 금지). 따라서 운영/context 비용 ≈ 0.
- 실제 bounded 해악: ① archive index README 비대 ② `find`/디렉터리 스캔 노이즈 ③ repo 파일 수 bloat ④ git 연산 marginal 저하.
- **항목의 첫 과제:** "쌓이는 게 문제"가 구체적으로 무엇을 깨뜨리는지 정의한다. 무문제면 무조치 근거를 명문화하고 닫는다(아래 옵션 A).

**개선 방향 옵션 (이 항목이 결정할 대상):**

- A) **현행 유지 + 무조치 근거 명문화** — git-tracked·미로드 → cost~0를 DR/정책으로 확정.
- B) **주기적 rollup/digest** — 월/분기 단위 단일 digest로 압축, 세부는 git history. 파일 수↓ / granular 검색성↓.
- C) **retention/pruning** — 오래된 artifact 실제 삭제(git log 보존). 공격적, reversal cost 있음.
- D) **close 시 archive 미이동** — `/work-close`에서 work 파일을 옮기지 않고 제거, git history가 기록. archive works 디렉터리 축소/폐지.
- E) **tiered/index-only** — 최근 N개만 full 유지, 이전은 index README row만 남기고 본문 압축.

**Dependencies:**

- DR-014 archive policy, `/work-close` archive step.
- 연계: `Backlog row lifecycle SSoT 정비`(W1, 같은 lifecycle hygiene 클러스터).
- 흡수: 구 Deferred `AWH-OQ-001`(historical product docs를 archive에 얼마나 남길 것인가 — 현재 guidance와 혼동되지 않는 legacy 기준 결정).

**Done Criteria:**

- 누적의 실해악을 정량 정의하고, 옵션 A~E 중 방향을 결정(또는 무조치 근거 명문화).
- 결정이 work·decision·기타 artifact에 일관 적용되는지 확인. 필요 시 DR-014 갱신 또는 신규 DR.

**Verification:**

- 결정 방향에 따라: 정책 문서/DR 반영 확인, `/work-close` archive step과의 정합, archive index README 정합.

---

#### Canonical 개념 계층화 + context-routing restructure

> 2026-06-10 등록 (사용자 테마 — README 흐름 검토 + 개념 상위화 통합).

**Cluster:** W3. Workflow IA Diet

**Task:**

- README의 Repository Structure 흐름이 정확한지, 흐름 자체를 리팩토링할 필요는 없는지, 현재 흐름이 효율적으로 구성·관리되고 있는지 점검한다.
- 상위→하위 흐름에서 중복된 내용을 제거한다.
- 기본 개념·구조는 상위(예: `docs/AGENT-WORKFLOW.md`)에 짧은 개요를 먼저 두고, 하위 흐름의 필요한 지점에서 구체화 + 상세는 하위 링크로 위임하는 구조로 조정할지 검토한다. 대상 예:
  - 하네스 기본 구조, Operating Tracks, project constants
  - 문서 구조와 매핑/포인터
  - State Machine 기본 구조
  - 전역에 산재한 baseline · routing · gate · trigger · Approval Matrix · Finalization · git workflow · verification (그 외 추가 가능)
  - scaffold 기본 개념·구조·상세 포인터
- 목적: 사용자의 흐름 이해와 AI의 효율적 context 로드·전개 양쪽에 유리하게.
- **[불변 제약] AI workflow가 주축이다. 사용자 이해의 흐름을 돕는다는 이유로 workflow가 사용자 매뉴얼화되어서는 절대 안 된다.**

**Dependencies:**

- 연계: `Prompt surface diet + optional pack 재정의`(P1, canonical weight 경량화), `skills/workflow/repo-health.md slice 분리`(P2), `skills/workflow/work-doc.md class 재검토`(P2), `Harness protocol trigger family simplification`(P2, trigger 재그룹화 ⊂ 이 restructure).
- 검증 척추(CHORE-20260611-005 도입 완료) — restructure cascade를 test-backed로 검증.
- DR-021, DR-023.

**Done Criteria:**

- README 흐름 정확성 검증 + (필요 시) 리팩토링안 반영.
- 상위 개요 + 하위 포인터 구조로 중복 제거, canonical 비대화 없이.
- AI 매뉴얼화 금지 제약 충족(workflow 주축 유지) 확인.

**Verification:**

- before/after context 로드 시나리오(사람/AI)에서 개요→상세 경로가 끊김 없이 연결됨.
- 중복 grep으로 제거 확인, stale pointer 없음.

---

#### Prompt surface diet + optional pack 재정의

**Cluster:** W3. Workflow IA Diet

**Task:** source repo에서도 `prompts/*session-start.md` 3종과 `prompts/README.md`를 제외한 task prompt(`00~22`)를 live surface에서 제거할지 결정한다. 제거 결정 시 실제 삭제하지 않고 `docs/archive/` 하위로 이동하거나 opt-in archive/example pack으로 격리해 이력을 보존한다. 기본 판단: canonical workflow(`skills/workflow/*.md` + adapter) 이후 task prompt library는 harness core라기보다 과거 product-template/example pack 성격이 강하고 cascade 비용이 큼. archive/격리 시 `scripts/create-harness.sh --with-optional`, README, WORKFLOW-MANUAL, PLAN/PLAN-SUMMARY, maintainer guide, repo-health prompt cascade 표를 함께 정리한다. **연계: `work-doc.md` class 재검토(P2)**

**docs/ 물리 레이아웃 재검토 (CHORE-20260610-009 라우팅):** 이 항목에서 `--with-optional` 재정의와 함께 docs/ 물리 레이아웃(user/maintainer/pack을 audience별 디렉토리로 분리할지)도 재검토한다. DR-021은 "물리 이동 보류, logical marker로 식별"을 채택했고 근거는 "reversal cost가 높다"였으나, **그 비용은 hardcoded flat-path 참조 방식에 종속**된다 — manifest/anchor 기반 indirection을 도입하면 이동 비용이 낮아져 물리 분리 재고가 정당해질 수 있다. 즉흥 뒤집기 대신 pack 구조·scaffold wiring을 통합 설계하는 이 시점에서 함께 판단한다.

**Dependencies:**

- DR-021 Optional source pack, DR-023 canonical workflow, DR-014 archive policy, prompt/session-start fallback 유지 정책

**Done Criteria:** session-start fallback만 core로 남기는지, task prompt examples를 archive/격리/유지할지 결정하고 source/scaffold 설명이 일관됨. `--with-optional`의 남은 의미(heavy docs/example rules/profile)를 재정의. docs/ 물리 레이아웃 분리 여부와 (분리 시) 참조 indirection 방식을 DR-021 reversal-cost 논거와 함께 결정

**Verification:** `find prompts`, `rg "prompts/"`, scaffold dry-run, generated README/manual/prompt inventory 확인. archive 결정 시 live prompt stale reference 없음 + archive 경로에서 이력 보존 확인

---

#### Harness protocol trigger family simplification

**Cluster:** W3. Workflow IA Diet

**Task:** `docs/HARNESS-PROTOCOL.md` T1~T17 trigger가 복잡해졌으므로 Decision / Planning / Surface / Scaffold / Finalization / Archive family로 재그룹화할 수 있는지 검토한다. 단, P0 gate series가 T15~T17/c4를 건드리므로 P0 완료 전 대형 재작성은 피한다.

**Trigger 정비 (사용자 요청 흡수, 2026-06-10):** "Trigger 정비"는 별도 신규 항목이 아니라 이 항목으로 합친다. `Canonical 개념 계층화 + context-routing restructure`(P1)가 trigger를 상위 개요 + 하위 포인터 구조로 다루므로 **그 restructure와 시퀀싱을 함께 결정**한다 (trigger family 재그룹화 ⊂ canonical restructure).

**Dependencies:**

- DR-024, DR-025, P0 gate series

**Done Criteria:** trigger 의미는 유지하면서 사용자/AI가 빠르게 찾을 수 있는 family summary 또는 quick reference를 추가. core 문서 비대화 없이 pointer 구조 유지

**Verification:** trigger 시나리오별 before/after lookup 테스트, stale trigger reference grep

---

#### 문서-only 규칙 강제화 (CI/hook/hard-gate)

> 2026-06-10 등록 (사용자 테마).

**Cluster:** W4. Enforcement And Lifecycle

**Task:**

- 문서상으로만 기술된 내용 중 ci · hook · hard gate 및 가용한 다른 수단으로 강제화할 주요 요소를 검토하고 구현한다.
- 우선순위는 위반 빈도·실피해가 큰 규칙부터.

> **[2026-06-08 설계 메모 — CHORE-20260611-008 close 시 `repo-health gate series 보강`에서 이관]** pre-commit hook이 protected 파일을 develop에서 stage할 때 WARNING만 발행하고 exit(1)하지 않는다. `git-workflow.md`의 인지 규칙("move to FAIL")과 기계 신호(WARNING=proceed)가 불일치하며, AI 도구는 기계 신호를 따라 commit을 진행할 수 있다. GitHub ruleset이 push 단계에서 hard-stop을 제공하므로 실피해는 "local develop에 잘못된 commit이 남는 불편함"에 한정된다. hook exit(1) 강화를 검토했으나 예외 설계가 복잡하다는 결론: ① STATUS.md 같은 상태 파일의 tracking-only commit은 develop 직접 commit이 정당한 예외, ② Quick Mode L1은 feature branch 없이 처리하는 경우가 있음, ③ product track 확장 시 repo별 custom protected path 추가, ④ `commands/**`·`rules/**`·`create-harness.sh` 같은 구조 파일은 trailer 우회도 불가해야 할 수 있음. 이 예외 클래스 분류(상태 파일 vs 구조 파일), hook의 override trailer 인식 여부, Quick Mode/product track 적용 범위를 사전에 DR로 확정하지 않으면 hook 구현이 설계 없이 진행될 위험이 있다. 현재 GitHub ruleset으로 충분한 보호가 이뤄지고 있어 현행 유지가 더 효율적일 수 있다는 판단 하에 보류. 착수 시 hook 강화보다 **예외 클래스 설계 DR을 선행**해야 함.

**Dependencies:**

- 연계: gate path-list parity Q-static(CHORE-20260611-008 완료), 기존 gate series(CHORE-20260606-006~016), DR-024, DR-025.
- 구조 확정 후 착수 권장 — 곧 restructure될 표면을 hard-gate하지 않도록 `Canonical 개념 계층화 + context-routing restructure`(P1) 이후.

**Done Criteria:**

- 강제화 후보 규칙 목록 + 수단(CI/hook/hard-gate) 매핑 결정.
- 선정 규칙에 대한 enforcement 구현 + 우회/예외 클래스 설계(위 hook exit(1) 예외 클래스 메모 반영).

**Verification:**

- inject-revert로 위반 차단 + 정상 통과 확인.
- 예외(상태 파일 tracking-only 등) 정상 동작 확인.

---

#### `skills/workflow/repo-health.md` slice 분리

**Cluster:** W3. Workflow IA Diet

**Task:** 422줄로 canonical 파일 중 가장 무거움. 상시 로드 섹션(Procedure/Mode Contract/Output Contract/Inspection Areas A~B)과 조건부 섹션(--full 전용: C/D/F, --cascade 전용: G/H, Required Simulation Matrix)을 별도 slice 파일로 분리하고 conditional pointer로 교체. context budget 절감 및 --full/--cascade 로드 범위 명확화. **연계: gate path-list parity(CHORE-20260611-008 완료, Surface Matrix gate row 추가됨), scaffold/tool-surface regression alignment(CHORE-20260611-006 완료) F4 repo-health 연계**

**Dependencies:**

- gate path-list parity(CHORE-20260611-008 완료), scaffold/tool-surface regression alignment(CHORE-20260611-006 완료) F4 repo-health 연계

**Done Criteria:** 상시 로드 섹션이 200줄 이하로 줄고, 조건부 섹션이 conditional pointer로 참조됨

**Verification:** `/repo-health` 기본·--full·--cascade 모드별 실행 후 각 섹션이 올바르게 로드되는지 확인

---

#### `skills/workflow/work-doc.md` class 재검토

**Cluster:** W3. Workflow IA Diet

**Task:** 243줄. Design System·Tone & Manner·Presentation Deck Principles 등 product-track 특화 내용이 harness core A-class canonical에 포함되어 있음. DR-021 A/B-class boundary 기준으로 Optional source pack 또는 source-only 이동 여부를 결정한다. **연계: Prompt surface diet + optional pack 재정의(P1)**

**Dependencies:**

- DR-021 A/B-class boundary, `Prompt surface diet + optional pack 재정의`(P1)

**Done Criteria:** DR-021 기준으로 class 판정 완료. Optional pack 이동 시 scaffold/adapter/README cascade 반영

**Verification:** class 결정 후 scaffold dry-run + generated README 확인. Optional pack 이동 시 `find skills/workflow/work-doc.md` + adapt/write_text 경로 확인

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
- 필요 시 `--with-spring-boot-msa` 또는 유사 옵션. 이름은 `Scaffold CLI naming audit`와 함께 판단한다.

**Dependencies:**

- CHORE-20260612-001에서 정리한 planning pack/import loop 기준 위에서 실제 product 산출물과 일반화 가능 범위를 먼저 확보.
- `Prompt surface diet + optional pack 재정의`(P1) 방향 결정.
- scaffold/tool-surface regression alignment(CHORE-20260611-006 완료) 이후 착수 권장.
- `scripts/create-harness.sh --with-optional` 현행 설계 파악 필요.

**Done Criteria:** core scaffold(옵션 미지정)에는 포함되지 않음. product repo에서 검증된 산출물 중 일반화 가능한 부분만 option-pack 후보로 편입. Spring Boot MSA pack을 둘지, 더 일반적인 product engineering pack으로 둘지 결정. stack별 확장(`--with-spring-boot-msa`, `--with-react` 등)은 필요가 확인된 것만 둔다.

**Verification:** core scaffold dry-run에서 pack 미포함 확인. option-pack dry-run에서 파일 목록·tool surface wiring 확인. product repo 산출물 → source repo import 후보 mapping 검토. README/GUIDE/MANUAL에 pack 설명이 과잉 노출되지 않는지 확인.

**사전 참고:** 현재 `scripts/create-harness.sh`는 `--profile spring-boot`와 `--with-optional`만 지원한다. `--with-spring-boot-msa` 같은 새 옵션은 즉시 전제하지 않고, product pack 검증 Layer U(CHORE-20260611-007)가 정의한 검증 골격 위에서 import format이 W2에서 확정된 뒤 판단한다.

---

#### User-facing docs readability rewrite — audience-aware README/MANUAL/GUIDE

**Cluster:** W2. Adopter Transition

**Task:** README/MANUAL/GUIDE류 문서를 초보 개발자 또는 일반 독자도 따라올 수 있는 구조와 톤으로 재작성한다. 단, 전문적 제약·운영 위험·정책 판단은 생략하지 않는다. 이번 항목은 CHORE-20260611-011의 객관적 cascade가 아니라, 독자별 구성·톤·문장 품질을 다루는 별도 rewrite 작업이다.

**Audience / Writing Principles:**

- 쉬운 문장은 단순화가 아니라 **독자별 정보 설계**다. 먼저 독자의 상황과 다음 행동을 잡고, 필요한 개념·명령·위험을 그 순서로 설명한다.
- source maintainer용 문서는 더 촘촘해도 되지만, 사람이 쓴 운영 문서처럼 읽혀야 한다. 선언문·슬로건·AI가 생성한 듯한 추상어를 줄이고, "왜 필요한가 → 언제 읽는가 → 무엇을 하면 되는가"가 보이게 쓴다.
- 새 용어나 framework 내부 개념은 처음 등장할 때 짧게 의미를 풀고, 이후에는 일관된 이름으로 사용한다. 독자가 모르는 전제를 암묵적으로 요구하지 않는다.
- AI execution SSoT(`skills/workflow/*.md`, protocol, adapter)는 사용자 매뉴얼화하지 않는다. readability 원칙의 1차 대상은 README, onboarding guide, workflow manual, maintainer guide 같은 human-facing 문서다.

**Dependencies:**

- CHORE-20260611-011 Docs cascade 현행화 완료.
- CHORE-20260606-005 README overhaul 기준.
- DR-007 language policy, DR-021 source/target boundary.

**Done Criteria:** README/MANUAL/GUIDE류 핵심 문서가 청중별 목적·다음 행동·전문적 제약을 자연스러운 문장으로 설명한다. 사람이 쓴 운영 문서처럼 읽히며, AI식 추상 문장과 선언문 과잉이 줄어든다. canonical workflow나 skills 문서를 사용자용 manual처럼 바꾸지 않는다.

**Verification:** 주요 문단 샘플 리뷰: "초보 독자가 다음 행동을 알 수 있는가", "전문적 제약이 누락되지 않았는가", "AI식 추상 문장이 과잉이지 않은가". README ↔ onboarding guide ↔ workflow manual ↔ maintainer guide의 audience/role 중복 점검. DR-007 language policy와 source/target boundary grep.

---

#### Scaffold multi-user clone verification

**Cluster:** W2. Adopter Transition

**Task:** scaffold 후 여러 사용자가 clone하여 작업하는 상황을 상정해 branch/ruleset/hook/CI/advisory/manifest/check 동작을 점검한다. source-gitflow target과 generic/hook-less target을 분리해 검증하고, 결과는 P0 gate series 또는 onboarding refresh에 흡수한다.

**Dependencies:**

- P0 gate series, DR-020, DR-021, source-gitflow bootstrap

**Done Criteria:** fresh scaffold→git init/remote/clone→두 사용자 작업→PR/check/manual gate 경로의 위험과 문서 gap을 식별하고 필요한 후속 Work로 연결

**Verification:** temp repo 2개 clone 시뮬레이션 또는 mock 한계 보고, branch/ruleset/manifest/check 경로 확인

---

#### Project-state template pack 검토

**Cluster:** W5. Future / Optional

**Task:** `docs/decisions/DECISION-TEMPLATE.md` 외에 project-state-owned 파일을 채우는 template이 더 필요한지 검토한다. 후보: Work 파일 skeleton, backlog candidate row guide, retrospective/troubleshooting template, project decision index seed. 단, 작은 target에서 파일 수만 늘어나는 과잉 template은 피한다.

**Dependencies:**

- DR-021 project-state-owned, DR-013 Work spec, scaffold onboarding

**Done Criteria:** scaffold target이 project-owned 상태 파일을 채울 때 필요한 최소 template set을 확정하고, 불필요한 template은 만들지 않음

**Verification:** fresh scaffold onboarding 시뮬레이션, template 추가 전후 파일 수/사용 경로 확인

---

#### Scaffold CLI naming audit

**Cluster:** W5. Future / Optional

**Task:** `--workflow`는 실제로 Git/branch flow 선택인데 harness workflow 전체 옵션처럼 오해될 수 있다. 대안: `--branch-flow`, `--git-flow`, `--repo-flow`. 단 no-alias/breaking policy와 upgrade/migration 설계가 얽히므로 즉시 rename하지 않고 option naming + migration note + no-runtime-alias 정책을 함께 검토한다.

**Dependencies:**

- DR-021, DR-023 no-alias migration 방향, upgrade/migration 후보

**Done Criteria:** rename 여부/시점/마이그레이션 안내를 결정. 유지한다면 docs에서 `--workflow`가 branch/release policy 옵션임을 더 명확히 함

**Verification:** CLI help/docs/scaffold generated text grep, old/new option migration impact review

---

#### Windows 지원 확장 (HRN-032)

**Cluster:** W5. Future / Optional

**Task:** macOS 기준 workflow/scaffold 검증을 Windows/WSL/Git Bash까지 정렬

**Dependencies:**

- HRN-031 이후 scaffold smoke test

**Done Criteria:** `/start`와 scaffold 후 첫 세션이 Windows native, WSL, Git Bash 환경에서 어떤 명령·hook·경로 전제를 갖는지 정리하고, 필요한 문서/스크립트 보완안을 반영

**Verification:** Windows/WSL/Git Bash별 `/start` 시뮬레이션, `create-harness.sh` 실행 경로, `python3` Stop hook, `/tmp` 검증 경로 대체안 확인

---

#### `/exit` → Stop hook gap 추적 (HRN-016)

**Cluster:** W5. Future / Optional

**Task:** Claude Code process-exit hook 지원 여부 모니터링 (소극적 감시; 지원 확인 전 action 없음)

**Dependencies:**

- —

**Done Criteria:** Claude Code 릴리즈 노트에서 process-exit hook 지원 확인 시 `settings.json` 보완 및 문서 갱신

**Verification:** 릴리즈 노트 확인 후 gap 해소 여부 검증

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
