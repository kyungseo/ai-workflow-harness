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
| W2. Adopter Transition | 다음 주 실제 product scaffold 운영에 필요한 적용·업그레이드·온보딩 흐름을 준비한다 | (upgrade/migration 완료 = CHORE-20260611-010, docs cascade 완료 = CHORE-20260611-011, planning pack 완료 = CHORE-20260612-001, readability rewrite 완료 = CHORE-20260612-002, clone verification 완료 = CHORE-20260612-003) 후속 후보: `ai-deck-compiler` 실제 upgrade walkthrough, 첫 concrete product planning-pack exercise/import review |
| W3. Workflow IA Diet ✓ 완결 | source/target 경계, canonical weight, optional pack, trigger 구조를 더 가볍게 정렬한다 | (Canonical 개념 계층화 핵심 달성 = CHORE-20260613-002~005, Prompt surface diet 완료 = CHORE-20260612-010, work-doc class 완료 = CHORE-20260613-005, trigger family simplification 완료 = CHORE-20260613-006) 전부 완료 |
| W4. Enforcement And Lifecycle | 반복되는 운영 실수를 hook/CI/test 또는 closeout 절차로 줄인다 | (전부 종결) Validation Spine residual F1~F4 = CHORE-20260613-017/018·DR-036, 문서-only 규칙 강제화 = DR-037, Archive 누적 관리 정책 = DR-038, CI inline assertion ↔ invariants SSoT parity = CHORE-20260613-016 no-action closeout |
| W5. Future / Optional | 실제 product 운용 후 필요가 확인되면 확장한다 | Spring Boot MSA TDD option-pack, project-state template, CLI naming audit, Windows 지원 |

### Summary

| ID | Priority | Status | Risk | Title |
| --- | --- | --- | --- | --- |
| — | P1 | Candidate | L2 | `ai-deck-compiler` actual upgrade walkthrough + DR-034 acceptance judgment |
| — | P1 | Candidate | L2 | First concrete product planning-pack exercise + import candidate review |
| — | P2 | Candidate | L3 | Spring Boot MSA TDD option-pack — product engineering pack 후보 |
| — | P2 | Candidate | L2 | Project-state template pack 검토 |
| — | P2 | Candidate | L3 | Scaffold CLI naming audit |
| HRN-032 | P2 | Hold | L2 | Windows 지원 확장 (WSL/Git Bash robustness로 scope 축소, 실수요 전 보류) |

---

### Details

> **Verification 작성 기준:** 변경이 건드리는 surface를 항목별로 명시한다.
> 점검 후보: tool surface · adopter cascade · canonical · scaffold · README/GUIDE/MANUAL
> 해당 없는 surface는 제외한다.

---

#### `ai-deck-compiler` actual upgrade walkthrough + DR-034 acceptance judgment

**Cluster:** W2. Adopter Transition

**Task:** `ai-deck-compiler` 실제 adopter를 대상으로 Layer T upgrade/migration walkthrough를 수행해 pre-manifest inventory, shadow scaffold baseline, selective migration, accepted drift 분류를 실측한다. source 쪽 설계가 문서상 placeholder를 넘어서 실제 adopter friction을 얼마나 줄이는지 확인하고, 결과를 바탕으로 DR-034를 Draft 유지할지 Accepted로 올릴지 판단한다.

**Dependencies:**

- CHORE-20260611-010에서 정리한 upgrade/migration 메커니즘과 `docs/maintainer/VERIFICATION-COMMANDS.md` Layer T
- 실제 adopter target 접근 가능 여부와 current target 상태 확인
- 필요 시 `docs/maintainer/migrations/*.md` note 보강

**Done Criteria:** 실제 adopter walkthrough 결과가 inventory-first 분류와 함께 남고, framework-owned / project-owned / customized / accepted drift 구분이 기록됨. selective migration 후 `--check` 결과와 남은 manual-merge hotspot이 정리되며, DR-034 상태 판단(승격 또는 유지 이유)이 명시된다.

**Verification:** Layer T walkthrough, `scripts/create-harness.sh --check <target>`, drift summary 기록, maintainer migration note/README pointer 정합 확인. Surface: adopter cascade · scaffold · README/GUIDE/MANUAL.

---

#### First concrete product planning-pack exercise + import candidate review

**Cluster:** W2. Adopter Transition

**Task:** source-only planning pack skeleton을 첫 concrete product에 적용해 실제 산출물 세트를 만들고, CHORE-20260612-001이 provisional로 남겨둔 source-owned / product-owned / import-candidate 경계를 실측한다. 결과를 바탕으로 Layer U(U2~U4) checklist와 import review aid가 계속 provisional이어야 하는지, 일부를 더 구체화해도 되는지 판단한다.

**Dependencies:**

- CHORE-20260612-001 planning pack/import loop 기준
- `docs/maintainer/PRODUCT-STARTER-PLANNING-PACK.md`
- 실제 product 착수 timing과 import candidate로 볼 산출물 확보

**Done Criteria:** 첫 concrete product exercise가 끝나고 planning-pack 산출물의 owner 분류(source/product/import)가 기록된다. import 후보의 일반화 가능 범위와 보류 이유가 남고, Layer U/U4 checklist 또는 review aid의 유지/보강 판단이 정리된다.

**Verification:** Layer U checklist, product artifact → source import mapping review, optional pack/tool-surface spillover 점검. Surface: tool surface · adopter cascade · README/GUIDE/MANUAL.

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
