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
| W1. Validation Spine ✓ 완결 | 이번 주 이후 큰 하네스 변경을 줄이더라도 regression을 잡을 수 있는 최소 검증 척추를 만든다 | (전부 완료) 검증 척추 spine 도입 = CHORE-20260611-005, scaffold/tool-surface leak-scan alignment = CHORE-20260611-006, product pack 검증 Layer U = CHORE-20260611-007, gate path-list parity = CHORE-20260611-008, source repo maintainer operations manual = CHORE-20260611-009. 잔여 후속은 W3/W4 후보에서 별도 추적 |
| W2. Adopter Transition | 다음 주 실제 product scaffold 운영에 필요한 적용·업그레이드·온보딩 흐름을 준비한다 | (upgrade/migration 완료 = CHORE-20260611-010, docs cascade 완료 = CHORE-20260611-011, planning pack 완료 = CHORE-20260612-001, readability rewrite 완료 = CHORE-20260612-002) Scaffold multi-user clone verification |
| W3. Workflow IA Diet ✓ 완결 | source/target 경계, canonical weight, optional pack, trigger 구조를 더 가볍게 정렬한다 | (Canonical 개념 계층화 핵심 달성 = CHORE-20260613-002~005, Prompt surface diet 완료 = CHORE-20260612-010, work-doc class 완료 = CHORE-20260613-005, trigger family simplification 완료 = CHORE-20260613-006) 전부 완료 |
| W4. Enforcement And Lifecycle | 반복되는 운영 실수를 hook/CI/test 또는 closeout 절차로 줄인다 | 문서-only 규칙 강제화, Backlog row lifecycle SSoT, Archive 누적 관리 정책 |
| W5. Future / Optional | 실제 product 운용 후 필요가 확인되면 확장한다 | Spring Boot MSA TDD option-pack, project-state template, CLI naming audit, Windows 지원, `/exit` gap |

### Summary

| ID | Priority | Status | Risk | Title |
| --- | --- | --- | --- | --- |
| — | P2 | Candidate | L2 | Validation Spine residual follow-ups (F1-F4) |
| — | P1 | Candidate | L2 | 문서-only 규칙 강제화 (CI/hook/hard-gate) |
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
- F4: runner 결과를 `/repo-health`에 surface한다. CHORE-20260613-004의 repo-health slice 분리 이후 구조와 연계하되, repo-health가 deterministic 불변식을 재구현하지 않고 runner/catalog 결과를 호출·해석하는 경계를 유지한다.

**Dependencies:**

- CHORE-20260611-005: taxonomy + tier runner
- CHORE-20260611-006: scaffold/source-gitflow regression alignment
- CHORE-20260611-007: product pack Layer U
- CHORE-20260611-008: gate path-list parity Q-static
- CHORE-20260611-009: source repo operations runbook(Update Triggers)

**Done Criteria:** F1~F4 각각이 Work로 분해되거나, 범위가 다른 backlog 항목(`문서-only 규칙 강제화`, CHORE-20260613-004, W2/W5 product pack 후보)에 명시적으로 흡수됨. `HARNESS-TEST-TAXONOMY.md` §6와 `SOURCE-REPO-OPERATIONS.md` Update Triggers의 후속 pointer가 stale하지 않음.

**Verification:** taxonomy §5/§6, `VERIFICATION-COMMANDS.md` Layer J/J-OB/Q/R/S, `run-harness-checks.sh`, `skills/workflow/repo-health.md`, `SOURCE-REPO-OPERATIONS.md` 간 pointer 정합 grep. F1 착수 시 `/tmp/awh-*` 잔존 grep으로 치환 범위 확인.

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

#### 문서-only 규칙 강제화 (CI/hook/hard-gate)

> 2026-06-10 등록 (사용자 테마).

**Cluster:** W4. Enforcement And Lifecycle

**Task:**

- 문서상으로만 기술된 내용 중 ci · hook · hard gate 및 가용한 다른 수단으로 강제화할 주요 요소를 검토하고 구현한다.
- 우선순위는 위반 빈도·실피해가 큰 규칙부터.
- **선행 결정 완료 (2026-06-13):** DR-035에서 protected workflow surface branch isolation 예외 클래스를 `I0/T1/S1/P1/P2`로 고정했다. 남은 범위는 implementation slice다.

> **[2026-06-08 설계 메모 — CHORE-20260611-008 close 시 `repo-health gate series 보강`에서 이관]** pre-commit hook이 protected 파일을 develop에서 stage할 때 WARNING만 발행하고 exit(1)하지 않는다. `git-workflow.md`의 인지 규칙("move to FAIL")과 기계 신호(WARNING=proceed)가 불일치하며, AI 도구는 기계 신호를 따라 commit을 진행할 수 있다. GitHub ruleset이 push 단계에서 hard-stop을 제공하므로 실피해는 "local develop에 잘못된 commit이 남는 불편함"에 한정된다. hook exit(1) 강화를 검토했으나 예외 설계가 복잡하다는 결론: ① STATUS.md 같은 상태 파일의 tracking-only commit은 develop 직접 commit이 정당한 예외, ② Quick Mode L1은 feature branch 없이 처리하는 경우가 있음, ③ product track 확장 시 repo별 custom protected path 추가, ④ `commands/**`·`rules/**`·`create-harness.sh` 같은 구조 파일은 trailer 우회도 불가해야 할 수 있음. 이 예외 클래스 분류(상태 파일 vs 구조 파일), hook의 override trailer 인식 여부, Quick Mode/product track 적용 범위를 사전에 DR로 확정하지 않으면 hook 구현이 설계 없이 진행될 위험이 있다. 현재 GitHub ruleset으로 충분한 보호가 이뤄지고 있어 현행 유지가 더 효율적일 수 있다는 판단 하에 보류. 착수 시 hook 강화보다 **예외 클래스 설계 DR을 선행**해야 함.

**Dependencies:**

- 연계: gate path-list parity Q-static(CHORE-20260611-008 완료), 기존 gate series(CHORE-20260606-006~016), DR-024, DR-025.
- 선행 decision: DR-035 (Protected Workflow Enforcement Exception Classes) — branch isolation 예외 클래스, Quick Mode non-exception, DR-025 trailer non-reuse, follow-up split 3종 고정.
- Canonical 개념 계층화의 핵심 목표는 CHORE-20260613-002~005로 달성됨(2026-06-13). 이 항목은 blocking dependency 없이 독립 착수 가능하다.

**Done Criteria:**

- 강제화 후보 규칙 목록 + 수단(CI/hook/hard-gate) 매핑 결정.
- 선정 규칙에 대한 enforcement 구현. 예외 클래스 설계는 DR-035를 따른다.
- implementation Work는 최소 다음 3갈래 중 어디를 다루는지 scope를 명시한다: framework default hardening / project extension classification / F2 wiring.

**Verification:**

- inject-revert로 위반 차단 + 정상 통과 확인.
- 예외(`T1 tracking-state-only`, merge inherited exception 등) 정상 동작 확인.

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
