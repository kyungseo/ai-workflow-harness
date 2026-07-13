---
id: CHORE-20260713-007
priority: P1
status: Archived
risk: L2
scope: Safety rule layer 4툴 정규화 (brief rule-asset-generalization 축 A) — A1(destructive/privileged/secret, always)/A2(infra/deploy/environment, path-scoped) 분리, skills/safety/ canonical SSoT 신설, Claude/Cursor adapter 정규화, Codex/AG는 AGENTS.md entry contract 경로로 반영, scaffold copy matrix 정합 + rule parity check 신설. 축 B(java-spring/testing stack rule)와 --no-safety opt-out은 비범위.
appetite: 1d
planned_start: 2026-07-13
planned_end: 2026-07-13
actual_end: 2026-07-13
related_dr: [DR-007, DR-021, DR-044]
related_work: [CHORE-20260713-006, CHORE-20260622-003]
---

# CHORE-20260713-007: Safety rule layer 정규화 (축 A)

## Top Summary

brief `rule-asset-generalization-strategy-20260622.md` 축 A 실행. 같은 stack-agnostic 안전 의도가 현재 **Claude `.claude/rules/infra.md`(path-scoped: `infra/**`·Dockerfile — 좁음)와 Cursor `.cursor/rules/safety-critical.mdc`(always — `rm -rf`/`sudo`/secret 포함, 넓음)로 메커니즘·범위가 불일치**하고, **Codex/Antigravity에는 repo-local 안전 rule surface가 0개**다. Claude는 `infra/**` 경로 밖에서 `rm -rf`/`sudo`/secret 안전망이 rule로는 없다(BEHAVIOR-PRINCIPLES·memory feedback 의존).

workflow canonical화의 SSoT+adapter 원칙을 재사용하되, rule은 호출형이 아닌 **always/path-scoped 적용**이므로 적용 메커니즘은 별도 설계한다(brief §3 메커니즘 주의). base-msa와 무관한 보편 자산이라 product 검증 없이 source-first로 진행 가능하다.

**P1 근거 (R0-F6 교정):** 근거는 "사고 예방 실적"이 아니라 ① tool 간 safety coverage 비대칭(구조 결함), ② 신규 scaffold default의 구조적 일관성이다. 이 Work는 **1-day bounded preventive parity slice**로 한정한다 — adopter migration·생성 체계 등으로 번지면 slice를 멈추고 P2 재분류를 제안한다.

**실측 정정 (Discovery):** brief의 scaffold line 참조(544·650)는 stale — 현행 `scripts/create-harness.sh` line 670(Claude rules default copy loop: `docs-workflow.md infra.md`), line 776(Cursor rules default copy loop: `safety-critical.mdc` 포함 8종).

## Scope

**포함:**

- A1/A2 분리 정규화: **A1 실행 안전**(destructive/privileged/secret — always) / **A2 infra 안전**(infra/deploy/environment — path-scoped)
- `skills/safety/` canonical SSoT 신설 (Codex skill이 아닌 canonical rule document임을 명시)
- 4툴 적용 표면: Claude(always A1 신설 + A2 유지), Cursor(A1 유지 + A2 신설), Codex/AG(`AGENTS.md` entry contract → canonical 로드, thin-entry 유지)
- scaffold copy matrix 정합 (default 포함 — generic 포함 모든 신규 target)
- rule parity check 신설 (최소 범위: canonical 존재·adapter pointer 존재·A1/A2 surface 존재·scaffold copy matrix 포함. 내용 동등성은 과검증이라 제외 — brief 기준)
- `docs/WORKFLOW-MANUAL.md` 등 사용자 문서의 rule 설명 갱신
- 결정 항목: canonical namespace·언어 정책·A1/A2 rollback 단위(한 PR vs 분리)·DR 기록 여부

**비포함:**

- 축 B(`java-spring.md`·`testing.md` + Cursor 미러) — option-pack backlog에 위임, 현행 유지
- `--no-safety` opt-out — 안전망 default 가치 약화로 기본 제외 (brief 미해결 결정에서 이미 방향 고정)
- `git-workflow.md` thin adapter화(UF-06 뒤 착수 고정), workflow skill invocation suppression(P3 — 별도 surface)
- adopter repo 반영 (다음 upgrade에서 수용 — fleet 즉시 영향 없음)

## Plan

Driver 제안 (R0 review 대상):

- **D1. canonical namespace = `skills/safety/`** (brief 기본값). 각 canonical 문서 서두에 "이 파일은 canonical rule document다 — `.agents/skills/`의 호출형 Codex skill이 아니다" 명시. 대안(`rules/{domain}`, `docs/rules/{domain}`)은 `.agents/skills`와의 혼동 관점에서 R0에서 재검증.
- **D2. 명칭: A1 = `safety-critical`, A2 = `infra`** — 기존 Cursor/Claude 파일명 연속성 유지, rename 비용 0. canonical 파일: `skills/safety/safety-critical.md`(A1), `skills/safety/infra.md`(A2).
- **D3. 4툴 적용 매핑 (R0-F1 반영):**
  | Tool | A1 (always) | A2 (path-scoped) |
  | --- | --- | --- |
  | Claude | `.claude/rules/safety-critical.md` **신설** (`paths: "**"`) | `.claude/rules/infra.md` 유지 |
  | Cursor | `.cursor/rules/safety-critical.mdc` 유지 (alwaysApply) | `.cursor/rules/infra.mdc` **신설** (globs) |
  | Codex/AG | root `AGENTS.md` entry contract: A1은 session start 항상 로드 지시 (`skills/safety/*.md` 직접 라우팅 — 중간 doc 신설 없음, pointer hop 최소화) | 동일 경로 — A2는 "infra/deploy/environment 파일 작업 시 로드" 조건부 지시 |
  **검증 주장 분리 (F1):** 결과 문구는 "Codex runtime 확인 + AG contract/static 확인"까지만 허용 — AG runtime 미실측이면 "4개 도구에서 소비 확인"이라 쓰지 않는다. 두 evidence를 분리 기록한다.
- **D4. adapter 형태 = thin projection (R0-F2 accept, 원안 전문 복제 철회).** adapter는 **canonical load directive + 최소 fail-closed bootstrap guard 1~2문장**으로 제한하고, guard 전문은 `skills/safety/*` 한 곳만 보유한다. 원안 철회 사유: canonical을 두면서 전문을 복제하고 동등성도 안 보는 조합은 canonical-in-name-only. **bounded duplication 예외는 evidence-gated:** pointer 소비가 특정 도구에서 신뢰되지 않는다는 실측이 나오면 그 도구만 예외 선언 + semantic key/hash 또는 생성 검사 동반. 실측 없는 전 도구 복제·generator 도입 금지.
- **D5. 언어 = English + DR-007 amendment (R0-F3 accept).** English canonical을 유지하는 대가로 DR-007 English Only 분류에 machine-consumed canonical rule 유형 `skills/safety/*.md`를 명시하는 **bounded amendment**를 이 Work에 포함한다(관련 language-policy 검증·설명 동기화 포함). amendment가 무산되면 fallback은 현행 default(한국어 주 언어).
- **D6. rollback 단위 = A1+A2 한 PR, 단 rollback ≠ PR 경계 (R0-F7).** 한 PR로 묶되 A1/A2 각각의 파일·copy loop·assertion은 독립적으로 되돌릴 수 있는 구조를 유지한다.
- **D7. scaffold:** `create-harness.sh`에 `skills/safety/` 복사 추가(default), Claude `safety-critical.md`를 line 670 loop에, Cursor `infra.mdc`를 line 776 loop에 추가. AGENTS.md template(source·scaffold 양쪽)에 entry contract 라인 반영.
- **D8. rule parity check (R0-F4 반영):** `scripts/tests/check-rule-surface-parity.sh` **별도 신설** (workflow mirror check와 통합 금지 — 적용 메커니즘이 다름). 최소 assertion: (a) canonical A1/A2 존재, (b) 각 adapter의 canonical pointer, (c) scope semantics — Claude A1 always·A2 path scope / Cursor A1 alwaysApply·A2 glob / AGENTS.md A1 always·A2 conditional routing, (d) `create-harness.sh` copy matrix, (e) **temp generic scaffold 실생성**으로 해당 파일 + manifest tracked entries assert. runner 독립 Tier 0 항목으로 편입.
- **D9. verification cascade 산출물 (R0-F5 승격):** ① `check-scaffold-invariants.sh` `core_files()` 갱신(`skills/safety/` 편입), ② `check-shipped-dr-closure.sh` shipped canonical 범위 갱신, ③ `docs/HARNESS-TEST-TAXONOMY.md`·`docs/maintainer/VERIFICATION-COMMANDS.md` executable 목록·설명 동기화, ④ `README.md` repository layout·`docs/WORKFLOW-MANUAL.md` tool/scaffold inventory 갱신.

실행 순서:

1. Work 파일 + plan → **R0 Codex plan review** → driver response → consensus
2. canonical 2종 작성(기존 2파일 내용 통합·정규화) → 4툴 adapter 정비 → AGENTS.md entry contract
3. scaffold copy matrix + WORKFLOW-MANUAL 갱신 → rule parity check 신설
4. Verification (아래) → **R1 Codex result review** → 사용자 최종 승인
5. `/work-close` → commit → PR(`--base develop`) → merge

## Done Criteria

- [x] A1/A2 명칭·canonical namespace·언어·rollback 단위 확정 (D1·D2·D5·D6 — DR-007 amendment 포함, CP1)
- [x] `skills/safety/` canonical 2종 + 4툴 적용 표면 정규화 (D3·D4 thin projection — **Codex current-entry runtime evidence 확보**(R1 관찰: canonical 로드·행동 변경), AG는 contract/static 한정. R1-F1 승인 경계 교정 반영)
- [x] scaffold copy matrix 정합 (D7 — temp generic scaffold 실생성, manifest tracked +5 확인, CP3)
- [x] rule parity check 신설·통과 (D8 — assertion (a)~(e), Tier 0d/2c 편입, CP3)
- [x] verification cascade 산출물 완료 (D9 — invariants core_files·shipped closure·taxonomy·VERIFICATION-COMMANDS·README layout·WORKFLOW-MANUAL, CP2)
- [x] Layer U 비영향 회귀 assertion + migration note **N/A 판정** + manifest tracked set delta(+5) 기록 (R0-F8, CP3)
- [x] DR 기록 여부 결정 — **DR-044 Accepted 신설** (R1-F3로 driver 보류안 철회, decisions index 반영. arbiter 최종 리뷰 대상)
- [x] cross-agent consensus: R0(plan) + R1(result, R1b 포함) 종결 — R1b approve, reviewer 독립 `--all` exit 0
- [x] 사용자 최종 리뷰 후 Done (2026-07-13 arbiter 최종 승인 — DR-044 신설 확인 포함, work-close·commit·PR·merge 지시)

## Verification

- **temp generic scaffold 실생성** (dry-run 파일명 관찰 아님 — R0-F5) — 4툴 안전 surface 파일 + manifest tracked path assert, tracked set delta 기록
- rule parity check 신설분 실행 + `bash scripts/tests/run-harness-checks.sh --tier0` (invariants·shipped closure 갱신분 포함)
- `git diff --check`, `bash scripts/tests/check-shipped-dr-closure.sh` (DR-007 amendment 시)
- `AGENTS.md` entry consumption: **Codex runtime 확인**(실측) + **AG contract/static 확인**(정합) — 두 evidence 분리 기록, over-claim 금지 (R0-F1)
- Layer U stack-marker 비영향 회귀 assertion (generic/Spring profile 판정 불변 확인 — R0-F8)
- `docs/WORKFLOW-MANUAL.md` rule 설명 stale 확인 (821절 등) + `README.md` repository layout
- Surface: tool surface · scaffold · canonical · adopter cascade(다음 upgrade에서 framework-add로 수용, migration note는 N/A 판정 — 수동 절차 없음)

## Risk / Reversal Cost

- scaffold default 표면 변경 — **모든 신규 target에 영향** (기존 adopter는 다음 upgrade에서만 수용, 즉시 영향 없음). source 내 revert는 용이하나 릴리즈 후에는 manifest tracked set 변화가 동반되므로 **Reversal Cost: Medium**.
- Codex/AG entry contract는 계약 기준 — AG runtime 실검증은 별도 필요(brief §3). over-claim 금지: "AG에서 소비 계약이 성립"까지만 주장.
- A1 always rule 추가로 Claude 세션 상시 컨텍스트 소폭 증가 — guard 전문을 간결하게 유지해 완화.

## Discovery

- Archived: 2026-07-13 — 당일 완료 3건(-006/-007/-008) batch archive (arbiter 지시).
- 착수: 2026-07-13, backlog "Safety rule layer 정규화 (축 A)" candidate 착수. branch `feature/safety-rule-layer`.
- 실측: scaffold 참조 지점은 brief 기록(544·650)이 아니라 line 670(Claude)·776(Cursor). `skills/`에는 `workflow/`만 존재 — `skills/safety/`는 신설.
- Done: 2026-07-13, cross-review R0/R1(request-changes)→R1b(approve, reviewer 독립 `--all` exit 0) + Codex runtime evidence + arbiter 최종 승인(DR-044 확인 포함).
- Needs-Triage: tool runtime dereference 검증 residual — Claude `paths: "**"`·Cursor `alwaysApply`의 canonical dereference와 AG runtime·fresh Codex auto-load는 미실측(static/contract evidence만). 이후 실제 세션에서 관측 기회가 생기면 evidence로 기록할 가치 (bounded duplication 예외 gate의 입력이기도 함).

## Checkpoints

### CP1 — 결정 기록 (2026-07-13, R0 consensus 반영)

| 결정 | 내용 |
| --- | --- |
| canonical namespace | `skills/safety/` — README + 각 파일 서두에 "canonical rule document, not a Codex skill" 명시 |
| 명칭 | A1 = `safety-critical`, A2 = `infra` (기존 파일명 연속성, rename 0) |
| adapter 형태 | thin projection — canonical load directive + fail-closed bootstrap guard. 전문은 canonical 단독 보유 (R0-F2) |
| 언어 | English (canonical 본문) + DR-007 amendment — English Only 표에 `skills/safety/*.md` 추가 (디렉토리 README는 한국어 인덱스 예외 명시) (R0-F3) |
| rollback | A1+A2 한 PR, 단 파일·copy loop·assertion 독립 되돌림 가능 구조 (R0-F7) |
| Codex/AG 경로 | root `AGENTS.md` "Safety Rule Layer" 절 — A1 session start 항상 로드 / A2 infra 작업 시 조건부. 중간 doc 신설 없음 (R0-F1) |
| DR 신설 여부 | **driver 제안: 보류** — 구조는 brief(방향 SSoT)+이 Work+DR-007 amendment+`skills/safety/README.md`(구조 self-describe)로 기록 충분. R1/arbiter 이견 시 재론 |

### CP2 — 실행 완료 (2026-07-13)

변경 파일 (기능별):

| 표면 | 파일 | 변경 |
| --- | --- | --- |
| canonical | `skills/safety/{README,safety-critical,infra}.md` | **신설** — A1/A2 SSoT (영어) + 한국어 인덱스 README |
| Claude adapter | `.claude/rules/safety-critical.md` 신설(`paths: "**"` always) / `.claude/rules/infra.md` thin projection 전환(paths 유지) | A1 공백 해소 |
| Cursor adapter | `.cursor/rules/safety-critical.mdc` thin projection 전환(alwaysApply 유지) / `.cursor/rules/infra.mdc` 신설(globs) | A2 공백 해소 |
| Codex/AG entry | `AGENTS.md` Safety Rule Layer 절 신설 + Language Policy 목록에 skills/safety 추가 | repo-local 안전 surface 0 → 확보 |
| 정책 | `docs/decisions/DR-007-language-policy.md` English Only 표 1행 amendment | R0-F3 |
| scaffold | `create-harness.sh`: ensure_dir + skills/safety copy loop + Claude/Cursor loop 확장 + 생성 README 표 1행 | default 편입 (D7) |
| 검증 | `check-rule-surface-parity.sh` **신설**(a~d static + `--scaffold` e), `run-harness-checks.sh` Tier 0d·2c 편입, `check-scaffold-invariants.sh` core_files·`check-shipped-dr-closure.sh` shipped_docs에 skills/safety 추가 | D8·D9 |
| 문서 | taxonomy·VERIFICATION-COMMANDS cascade 목록·README layout·WORKFLOW-MANUAL(296·821·899절) | D9 |

### CP3 — 검증 evidence (2026-07-13)

- `run-harness-checks.sh --all` **전체 PASS** — Tier 0(syntax·whitespace·template parity·mirror parity·**rule parity 0d**) + Tier 1(shipped DR closure — skills/safety 편입 후에도 닫힘) + Tier 2(scaffold 3모드 invariants + manifest contract + **rule parity 2c `--scaffold`**).
- **manifest tracked set delta:** fresh generic scaffold 82 tracked (변경 전 77) — **+5**: `skills/safety/{README,safety-critical,infra}.md`, `.claude/rules/safety-critical.md`, `.cursor/rules/infra.mdc`. 전건 manifest tracked 확인.
- **Layer U stack-marker 비영향:** generic 생성물에 `java-spring.md` 부재 유지(profile 판정 불변) — safety 파일은 default 복사라 profile 분기와 무관.
- **migration note: N/A 판정** — 기존 adopter는 다음 upgrade에서 `framework-add` 5건으로 수용, 수동 절차 없음 (R0-F8).
- **entry consumption:** AGENTS.md 계약 라인은 scaffold에 adapt 복사 확인(정적). Codex runtime 확인은 R1에서 reviewer(Codex)가 자기 세션에서 직접 관찰 가능 — evidence 분리 원칙(R0-F1)에 따라 "Codex runtime + AG contract/static"으로만 기록 예정.
- 잔여: temp probe 디렉토리 `temp/harness-tests/delta-probe` (gitignored, rm 권한 보류로 잔존).

## Cross-Agent Review And Discussion

Model: manual relay (`/cross-review`). Driver = Claude, Reviewer = Codex (red-team), Arbiter = User.
Max Rounds: plan 1 + result 1 기본, 필요 시 반복.

### R0 — Plan Review (Cross-Agent Relay Packet)

**Role:** Driver = Claude / Reviewer = Codex / Arbiter = User

**Target:**
1. 이 Work 파일 전체 (특히 §Plan D1~D8, §Scope 경계)
2. 입력: brief `rule-asset-generalization-strategy-20260622.md` 축 A·§1·§3·미해결 결정, `.claude/rules/infra.md`, `.cursor/rules/safety-critical.mdc`, `scripts/create-harness.sh` line 670·776 블록, root `AGENTS.md`

**Current State:**
- branch `feature/safety-rule-layer` (source repo), Work 파일만 생성된 PLAN 단계. validation 아직 없음.

**Delta Since Last Round:** 신규 Work — 직전 관련 결정은 brief(2026-06-22, 방향 비교만 확정)와 CHORE-20260622-003(trigger narrowing).

**Review Objective (red-team):**
1. **방향 자체:** 축 A를 지금 source-first로 닫는 것이 맞는가 — brief 이후 3주간 안전 사고 0건인데 P1 유지가 타당한가, 아니면 다른 P1(happy path compression)이 먼저인가.
2. **D3 Codex/AG 경로:** `AGENTS.md` entry contract → canonical 직접 로드가 실효성 있는가. AGENTS.md가 세션마다 실제로 읽히는지의 계약 한계(특히 AG runtime 미검증)를 어떻게 다뤄야 하는가. 별도 shared safety doc이 더 나은가.
3. **D4 adapter 형태:** "guard 전문 유지 + canonical pointer"는 사실상 내용 복제다 — SSoT 원칙과의 긴장을 어떻게 판단하나. thin pointer(즉시성 희생) vs 전문 복제(drift 위험) vs 생성 기반(과잉 설계?) 중 driver 선택이 맞는가.
4. **D5 언어 English:** canonical을 영어로 두는 것이 DR-007과 정합한가 (skills/workflow canonical은 한국어 — 같은 skills/ 아래 언어 혼재 발생).
5. **D8 parity check 범위:** 최소 검사 4항목이 충분한가, 과소한가. 기존 `check-surface-mirror-parity.sh`와의 관계(통합 vs 별도).
6. scope 누락·hidden cost·cascade: scaffold manifest tracked set 변화, WORKFLOW-MANUAL, Layer U stack-marker(축 B 의존이라 비영향 확인), migration note 필요 여부.

**Do Not Re-litigate:** 축 A/B 분리 자체와 축 B product-first 위임(brief 확정), `--no-safety` 기본 제외(brief 방향 고정), cross-agent 역할 배분, 단순 5파일 삭제안 기각.

**Reviewer Posture:** Red-team the direction, not only the prose. Question assumptions, priority, hidden cost, cascade, and rollback. Mark speculation as speculation.

**Output Contract:** Verdict(approve / conditional / request-changes / reject) + must-fix / nice-to-have findings + residual risk. 이 파일 `### R0 — Reviewer Findings (Codex)` 섹션에 기록하고 Round Log를 갱신해줘. D3·D4·D5에 대한 명시적 의견 포함.

### R0 — Reviewer Findings (Codex)

**Verdict: request-changes.** 축 A를 source-first로 닫는 방향과 A1/A2 분리는 타당하다. 그러나 현재 D4는 canonical SSoT를 두면서 adapter 전문을 복제하고, D8은 그 전문 간 semantic drift를 탐지하지 않는 조합이다. D5의 English canonical도 현행 DR-007에 분류가 없다. 이 상태로는 구현에 들어가지 말고 아래 must-fix를 계획에 먼저 반영해야 한다.

#### Must-Fix Findings

**F1 — D3의 `AGENTS.md → skills/safety/*` 직접 라우팅은 채택 가능하나, 4-tool runtime 검증 주장은 분리해야 한다.** `skills/safety/*` 자체가 shared safety document이므로 별도 중간 문서를 하나 더 만드는 것은 이득 없이 pointer hop만 늘린다. A1은 session start에 항상 로드하고 A2는 infra/deploy/environment 파일 작업 시에만 로드한다는 조건을 root/scaffold `AGENTS.md`에 둬야 한다. 다만 Codex에서 실제 consumption을 관찰한 결과와 Antigravity의 root `AGENTS.md` auto-load 계약·정적 정합을 별도 evidence로 기록하라. AG runtime을 실제로 실행하지 못했다면 Done Criteria와 결과 문구는 “Codex runtime 확인 + AG contract/static 확인”까지만 허용하고 “4개 도구에서 소비 확인”이라고 쓰면 안 된다.

**F2 — D4의 “guard 전문 유지 + pointer, 내용 동등성 미검사”는 canonical-in-name-only이므로 철회해야 한다.** 추천안은 adapter를 canonical load directive와 최소 fail-closed bootstrap guard 1~2문장으로 제한하는 thin projection이다. 전문은 `skills/safety/*` 한 곳만 보유한다. pointer 소비가 특정 도구에서 신뢰되지 않는다는 실측이 나오면 그 도구만 bounded duplication 예외로 선언하고 semantic key/hash 또는 생성 검사를 함께 도입하라. 실측 없이 전 도구 전문 복제나 generator를 먼저 도입하는 것은 각각 drift와 과잉 설계 비용이 크다.

**F3 — D5의 English canonical은 합리적 선택일 수 있지만 현행 DR-007과는 아직 정합하지 않다.** DR-007은 `.claude/rules/*`, `.cursor/rules/*`, root entry는 English Only로, `skills/workflow/*`는 한국어 주 언어로 명시하지만 `skills/safety/*`를 분류하지 않는다. 같은 `skills/` 아래 언어 혼재 자체가 문제라기보다 파일 유형 정책이 없는 것이 문제다. English를 유지하려면 DR-007의 English Only 표에 machine-consumed canonical rule 유형인 `skills/safety/*.md`를 명시하고 관련 language-policy 검증·설명을 함께 갱신하라. 그렇지 않으면 현행 default인 한국어 주 언어를 따라야 한다.

**F4 — D8은 기존 workflow mirror check와 분리하되 최소 assertion을 강화해야 한다.** `check-surface-mirror-parity.sh`는 workflow command/adapter 3자 관계 전용이므로 통합하면 서로 다른 적용 메커니즘이 섞인다. 별도 `check-rule-surface-parity.sh`가 맞다. 최소 범위는 (a) canonical A1/A2 존재, (b) 각 adapter의 canonical pointer, (c) Claude A1 always·A2 path scope, Cursor A1 `alwaysApply`·A2 glob scope, `AGENTS.md` A1 always·A2 conditional routing, (d) `create-harness.sh` copy matrix, (e) 실제 generic scaffold의 해당 파일과 manifest tracked entries까지 포함해야 한다. D4가 thin projection이면 전문 text equality는 검사하지 않아도 되지만, bounded duplication을 남기면 그 부분의 semantic drift assertion이 필수다.

**F5 — scaffold·verification cascade를 계획의 명시적 산출물로 올려야 한다.** `skills/safety/` 생성·복사만 추가하면 현재 `check-scaffold-invariants.sh`의 `core_files()`와 `check-shipped-dr-closure.sh`의 shipped canonical 범위가 `skills/workflow/`에 머물러 새 canonical이 closure 밖에 남는다. 두 검사 범위를 갱신하고, 새 rule parity check를 runner의 독립 Tier 0 항목으로 편입하며 `docs/HARNESS-TEST-TAXONOMY.md`와 `docs/maintainer/VERIFICATION-COMMANDS.md`의 executable 목록·설명을 동기화하라. `README.md` repository layout과 `docs/WORKFLOW-MANUAL.md` tool/scaffold inventory도 scope에 명시해야 한다. dry-run의 파일명 관찰이 아니라 temp generic scaffold 생성으로 manifest tracked path까지 assert해야 한다.

#### Nice-To-Have Findings

**F6 — source-first는 Go지만 P1의 근거를 “사고 예방 실적”으로 과장하지 말아야 한다.** 3주간 사고 0건은 결함 부재의 증거도, 긴급도의 증거도 아니다. 실제 근거는 tool 간 safety coverage 비대칭과 신규 scaffold default의 구조적 일관성이다. 반면 happy-path compression에는 관찰된 onboarding burden이 있으므로, 이 작업은 1-day 이내의 bounded preventive parity slice일 때만 현재 P1 병행/선행이 방어된다. DR 확대·생성 체계·adopter migration까지 번지면 P2로 내리거나 happy-path 뒤로 보내라.

**F7 — D1과 D6은 유지 가능하되 rollback을 PR 경계와 동일시하지 말아야 한다.** `skills/safety/`는 “Codex skill이 아닌 canonical rule document”를 README와 파일 서두에서 명시하고 D5 정책을 보완하면 사용할 수 있다. A1+A2 한 PR도 중간 비정합을 피하는 면에서 합리적이지만, A1 always와 A2 path-scoped는 파일·copy loop·assertion이 독립적으로 되돌릴 수 있어야 한다.

**F8 — Layer U와 migration note는 변경보다 명시적 N/A 판정이 적절하다.** Layer U stack-marker는 축 B의 `java-spring` surface에 의존하므로 축 A의 default safety 파일 추가가 generic/Spring profile 판정 결과를 바꾸지 않는다는 회귀 assertion만 남기고 문서 의미는 바꾸지 말라. 기존 adopter에는 다음 upgrade에서 framework-add 파일로 유입되므로 특별한 수동 migration 절차가 없다면 migration note 신설은 불필요하다. 대신 release/upgrade evidence에 manifest tracked set delta와 fallback 처리 가능 여부를 기록하라.

#### Residual Risk

- always-loaded A1이 실제로 canonical까지 dereference되는지는 도구별 instruction loader 동작에 의존한다. 정적 pointer parity만으로 compliance를 증명할 수 없다.
- Antigravity runtime 미실측은 남는다. 이번 slice에서 허용할 수 있지만 결과는 contract confidence로 제한해야 한다.
- safety wording이 지나치게 넓으면 정상적인 승인된 작업도 반복 중단시킬 수 있다. R1에서 destructive/privileged/secret 경계와 explicit approval 후 허용 경로를 함께 검토해야 한다.
- default scaffold에 추가된 tracked 파일은 release 후 제거 비용이 source revert보다 크다. 실제 generic 생성물과 manifest delta를 R1 evidence로 남겨야 한다.

### R0 — Driver Response (Claude)

| Finding | Decision | Response | Follow-up |
| --- | --- | --- | --- |
| R0-F1 | accept | D3 유지(직접 라우팅 — 중간 doc 무이득), 검증 주장을 "Codex runtime + AG contract/static"으로 분리·제한 | Done Criteria·Verification 문구 반영 완료 |
| R0-F2 | accept (원안 철회) | adapter = canonical load directive + fail-closed bootstrap guard 1~2문장(thin projection). 전문은 canonical 단독 보유. bounded duplication은 실측 evidence 후 도구별 예외 + semantic assertion | D4 개정 완료 |
| R0-F3 | accept | English 유지의 대가로 DR-007 bounded amendment(`skills/safety/*.md` English Only 분류 추가 + 검증 동기화) 포함. 무산 시 fallback 한국어 | D5 개정 완료 |
| R0-F4 | accept | 별도 check 유지, assertion (a)~(e)로 강화 — scope semantics·copy matrix·temp scaffold manifest까지 | D8 개정 완료 |
| R0-F5 | accept | cascade를 명시적 산출물 D9로 승격 (invariants core_files·shipped closure·taxonomy·VERIFICATION-COMMANDS·README·MANUAL) | D9 신설 완료 |
| R0-F6 | accept | P1 근거를 "coverage 비대칭 + scaffold default 일관성"으로 교정, 1-day bounded slice 한정 — 번지면 중단·P2 재분류 제안 | Top Summary 반영 완료 |
| R0-F7 | accept | 한 PR 유지하되 A1/A2 파일·loop·assertion 독립 되돌림 구조 | D6 개정 완료 |
| R0-F8 | accept | Layer U 비영향 회귀 assertion + migration note N/A 판정 + manifest delta를 release evidence로 기록 | Done Criteria·Verification 반영 완료 |

### Round Log / Consensus Log

| Round | Date | Driver | Reviewer | Verdict | 기록 |
| --- | --- | --- | --- | --- | --- |
| R0 | 2026-07-13 | Claude (Work+plan 작성, packet 발행) | Codex (plan review) | request-changes | findings 기록 — driver response 대기 |
| R0-resp | 2026-07-13 | Claude (F1~F8 전부 accept, Plan 개정) | — | **consensus (arbiter 확정 대기)** | 검증 주장 분리(F1), thin projection(F2), DR-007 amendment 포함(F3), parity assertion 강화(F4), cascade 산출물 D9(F5), P1 근거 교정+bounded slice(F6), rollback 독립성(F7), Layer U/migration N/A(F8) |
| R1 | 2026-07-13 | Claude (EXECUTE+검증, result packet 발행) | Codex (result review + runtime 관찰) | request-changes | safety wording·parity coverage·DR/cascade 교정 필요 — driver response 대기 |
| R1-resp | 2026-07-13 | Claude (F1~F4 + F5·F6 전부 accept, 교정 완료) | — | R1b 재확인 대기 | 승인 경계 state-changing 한정 + bounded temp cleanup(F1), parity literal/anchored + AGENTS routing + manifest 전건(F2), DR-044 Accepted 신설(F3), DR-007 metadata·index cascade(F4), [c2] invariant(F5), `--all` 재실행 전체 PASS — runner 충돌 해소 확인(F6) |
| R1b | 2026-07-13 | Claude (R1 교정 결과 제시) | Codex (narrow confirmation + 독립 `--all`) | **approve** | R1 F1~F4 종결, reviewer-side 전체 PASS — cross-agent consensus (사용자 최종 승인 대기) |

| Topic | Status | Notes |
| --- | --- | --- |
| 방향 (source-first 축 A) | agreed | Go — 단 1-day bounded preventive parity slice 한정 |
| D3 Codex/AG 경로 | agreed | AGENTS.md → canonical 직접 라우팅. evidence는 Codex runtime / AG contract·static 분리 |
| D4 adapter 형태 | agreed | thin projection. bounded duplication은 실측 gated 예외 |
| D5 언어 | agreed | English + DR-007 bounded amendment (fallback: 한국어) |
| D8/D9 검증 | agreed | 별도 rule parity check(a~e) + cascade 산출물 명시 |

### R1 — Result Review (Cross-Agent Relay Packet)

**Role:** Driver = Claude / Reviewer = Codex / Arbiter = User

**Target:**
1. working tree diff (미commit — 리뷰 후 commit): CP2 표의 전체 파일 (canonical 3 신설, adapter 4, AGENTS.md, DR-007, create-harness.sh, 검증 스크립트 4, 문서 4)
2. 이 Work 파일 CP1(결정)·CP2(실행)·CP3(검증 evidence)

**Current State:** branch `feature/safety-rule-layer`, EXECUTE 완료. `run-harness-checks.sh --all` 전체 PASS, manifest delta +5 실측.

**Delta Since Last Round:** R0 consensus(F1~F8) 실행 결과.

**Review Objective (red-team):**
1. **R0 must-fix 반영 충실도:** F2 thin projection — adapter에 guard 전문이 남았는가(bootstrap guard 1~2문장 경계 준수 여부). F1 — evidence 분리 문구가 실제 기록에 지켜졌는가.
2. **Codex runtime 확인 (reviewer 직접 수행):** 네 세션이 root `AGENTS.md` Safety Rule Layer 절을 따라 `skills/safety/safety-critical.md`를 실제로 로드·적용하는지 자기 관찰로 기록해줘 — 이것이 R0-F1의 "Codex runtime 확인" evidence다. AG는 contract/static 확인만.
3. **safety wording 경계 (R0 residual):** canonical A1의 destructive/privileged/secret 경계와 "explicit approval 후 재질문 없이 진행" 문구가 과도한 반복 중단 또는 과소 보호를 만드는지.
4. **parity check 품질:** assertion (a)~(e)가 grep 기반이라 취약한 지점(문구 변경 시 오탐/미탐), Tier 0d(static)/2c(scaffold) 분리가 F4·F5 취지에 맞는지.
5. **DR 신설 보류 판단 (CP1):** 구조 DR 없이 brief+Work+DR-007 amendment+README로 충분한가.
6. cascade 누락: shipped closure에 skills/safety 편입 후 DR 참조 규율, WORKFLOW-MANUAL·README 갱신 충분성, scaffold 생성 README 표.

**Do Not Re-litigate:** R0 consensus(D1~D9 방향), 축 A/B 분리, `--no-safety` 제외.

**Output Contract:** Verdict + must-fix/nice-to-have findings + residual risk + **Codex runtime 관찰 기록**을 이 파일 `### R1 — Reviewer Findings (Codex)` 섹션에 기록, Round Log 갱신.

### CP4 — R1 교정 실행 (2026-07-13)

| Finding | Decision | 교정 |
| --- | --- | --- |
| R1-F1 | accept | canonical A1/A2 승인 경계를 **state-changing/destructive/privileged로 한정** — "Allowed without approval" 절 신설: read-only/query/render/validate/dry-run(secret 미접촉) + **bounded temp cleanup**(같은 process가 만든 unique temp dir, path/prefix 검증 후; user/persistent/shared 경로는 계속 승인 대상). adapter fail-closed guard는 의도적으로 보수 유지(canonical 불가독 시) |
| R1-F2 | accept | parity check 강화: (b) `grep -qF` literal, (d) 실제 adapt copy loop 라인 anchored, (e) generated `AGENTS.md` 2 pointer + A1 지시 확인, manifest **python3 exact set membership로 신규 5 path 전건** assert. Tier 0d/2c 분리 유지 |
| R1-F3 | accept (driver 보류안 철회) | **DR-044 Accepted 신설** — A1/A2 구조·thin projection·AGENTS.md 경로·승인 경계·evidence boundary·scaffold 편입 기록. source-only(seed 미포함), shipped 표면은 token 미인용 self-describe (closure 규율) |
| R1-F4 | accept | DR-007 `Amended:`에 2026-07-13 추가, decisions README index DR-007 요약 갱신 + DR-044 행 추가 |
| R1-F5 (nice) | accept | thin projection invariant [c2] 신설 — adapter의 `MUST:`/`NEVER:` heading·다중 bullet 재유입 탐지 (한 줄 directive `CRITICAL: Load...`는 허용 — 구현 중 자기 오탐 1건 교정) |
| R1-F6 (nice) | accept | 교정 후 `run-harness-checks.sh --all` 재실행 **전체 PASS** — 좁힌 A1 경계(bounded temp cleanup 허용) 하에서 deterministic runner와 safety rule의 충돌 해소 확인 |

### R1 — Reviewer Findings (Codex)

**Verdict: request-changes.** R0-F1의 evidence 분리와 R0-F2의 thin projection은 구현에 충실하게 반영됐다. canonical 전문은 `skills/safety/*`에만 있고, Claude/Cursor adapter와 `AGENTS.md`는 load directive + fail-closed bootstrap guard 1문장 수준이다. 그러나 실제 Codex 적용 관찰에서 A1의 command-name blanket가 기존 deterministic verification까지 매번 승인 대상으로 만드는 과도한 중단을 확인했다. 또한 parity 2c는 CP3의 scaffold routing·manifest `+5` 주장을 전부 assertion하지 않고, CP1의 DR 보류는 현행 DR-worthy 기준과 맞지 않는다.

#### Codex Runtime Observation

- 이 R1에서 reviewer가 현재 working tree의 root `AGENTS.md`를 다시 읽어 `## Safety Rule Layer`의 A1 session-start load directive를 확인하고, 그 지시에 따라 `skills/safety/safety-critical.md`를 실제 로드했다. A2는 이번 검토 대상의 wording 확인을 위해 별도로 로드했으며, infra path trigger 자체를 runtime 검증한 것은 아니다.
- A1을 행동에 적용했다. `run-harness-checks.sh --tier0/--all`은 호출되는 `check-default-template-parity.sh`와 Tier 2 cleanup에서 `rm -rf`를 실행하므로, 명시적 destructive-command 승인이 없는 이번 result review에서는 재실행하지 않았다. 대신 destructive cleanup이 없는 `check-rule-surface-parity.sh` static 모드, 관련 shell 5종 `bash -n`, `git diff --check`를 실행했고 모두 PASS했다.
- 이 관찰은 **현재 root entry를 읽은 Codex가 canonical을 실제 소비하고 행동을 바꿨다**는 runtime evidence다. 다만 Safety Rule Layer가 세션 도중 working tree에 추가됐으므로, fresh Codex session이 수정된 `AGENTS.md`를 자동으로 읽는다는 사실까지 새로 증명하지는 않는다. 그 부분은 기존 root-entry contract에 의존한다.
- Antigravity는 runtime 미실측이다. source/scaffold `AGENTS.md`에 동일 pointer가 존재하고 기존 contract가 auto-load를 선언한다는 **contract/static evidence**만 인정한다. “4개 도구 runtime 소비 확인”으로 확대하지 않는다.

#### Must-Fix Findings

**R1-F1 — A1/A2의 CLI 이름 blanket를 mutation 경계로 좁히고 bounded temp cleanup을 명시해야 한다.** A1은 `kubectl`·`terraform`·cloud CLI 자체를 승인 대상으로 나열하면서 read-only inspection 우선을 함께 요구하고, A2도 같은 CLI 전체를 금지하면서 render/dry-run/read-only 우선을 요구한다. 이 문구대로면 `kubectl get`, local `terraform validate/show`, cloud `describe` 같은 비변경 진단도 매번 중단된다. 더 직접적으로는 repo의 Tier 0 helper가 agent-owned temp dir cleanup에 `rm -rf`를 사용하므로 normal validation도 자동 진행할 수 없다. 승인 대상은 state-changing/apply/destructive/privileged action으로 좁히고, secret을 읽지 않는 read-only/query/render/validate는 허용하라. 같은 process가 생성한 unique temp dir의 path·prefix를 검증한 bounded cleanup은 별도 허용 경계로 명문화하되, user/persistent/shared 경로 삭제와 경계가 섞이면 계속 승인 대상으로 유지하라. “specific command + specific purpose 승인 후 같은 action은 재질문하지 않음” 문구 자체는 과소 보호가 아니며 유지 가능하다.

**R1-F2 — Tier 0d/2c 분리는 적정하지만 assertion (d)/(e)가 R0-F4/F5와 CP3 주장을 완전히 잠그지 못한다.** static `grep`은 `skills/safety` 문자열이 generated README 표나 주석에만 있어도 copy path로 오인할 수 있고, loop의 파일명 존재만 보므로 실제 `adapt` destination과 연결되지 않아 false positive가 가능하다. `grep -q "$canon"`도 regex로 처리돼 literal path assertion이 아니다. scaffold 모드는 canonical 2 + adapter 4의 파일 존재만 보고, generated `AGENTS.md`의 A1/A2 routing을 검사하지 않는다. manifest loop도 `skills/safety/README.md`를 빼고 4개 path만 검사해 CP3의 tracked delta `+5` 전체를 고정하지 않는다. 최소 교정은 literal/anchored frontmatter 검사, executable copy block 또는 생성 결과 기반 검증 강화, generated `AGENTS.md` 두 pointer 확인, 신규 5개 path 전건의 exact manifest entry 확인이다. Tier 0d static / Tier 2c generated split 자체는 유지하라.

**R1-F3 — CP1의 “DR 신설 보류”는 철회해야 한다.** canonical rule layer, A1/A2 적용 메커니즘, 4-tool projection, default scaffold 편입은 Reversal Cost가 Work 자체에서 Medium이고 여러 component/tool에 영향을 주므로 `record-decision`의 DR-worthy 공통 기준을 충족한다. 입력 brief는 스스로 “방향 비교이며 실행 결정을 확정하지 않는다”고 경계를 두고, DR-007 amendment는 언어만 결정하며 README는 current structure를 설명할 뿐 WHY와 대안을 보존하지 않는다. 결정은 이미 완료됐으므로 Draft가 아니라 concise Accepted DR이 맞다. workflow 전용 질문을 가진 DR-023을 넓히기보다 safety rule layer의 적용·projection·runtime evidence 경계를 별도 DR로 기록하는 편이 명확하다.

**R1-F4 — DR-007 amendment metadata와 decisions index cascade가 누락됐다.** 본문에는 2026-07-13 amendment가 추가됐지만 상단 `Amended:`는 여전히 2026-06-15에서 끝난다. `docs/decisions/README.md`의 DR-007 요약도 마지막 amendment를 2026-06-15로만 표시한다. `Amended:` 날짜와 index summary를 함께 갱신하라. shipped closure에 `skills/safety/`를 포함한 변경, WORKFLOW-MANUAL, root/generated README layout은 적절하게 반영됐다.

#### Nice-To-Have Findings

**R1-F5 — thin projection invariant를 저비용으로 보호하라.** 현재 adapter 4종은 R0-F2 경계를 준수한다. 향후 전문이 다시 들어와도 pointer/scope 검사는 PASS하므로, adapter에서 canonical 전문 heading(`MUST:`, `NEVER:`)이나 다중 bullet body가 재등장하는 것을 탐지하는 작은 assertion을 추가하면 회귀 의도를 더 잘 보존할 수 있다. line-count 고정처럼 formatting 변화에 민감한 검사는 피하라.

**R1-F6 — CP3 evidence의 독립 재현 범위를 명확히 남겨라.** reviewer는 static parity·syntax·whitespace를 재현했다. `--all`과 manifest delta는 driver evidence 및 남아 있는 `delta-probe` manifest의 path 확인으로만 대조했으며, A1 적용 때문에 destructive cleanup 포함 runner를 독립 재실행하지 않았다. wording 교정 후 R1b에서 `--all`을 다시 실행하면 safety rule과 verification workflow의 충돌 해소까지 함께 증명할 수 있다.

#### Residual Risk

- Claude `paths: "**"`와 Cursor `alwaysApply: true`가 각 실제 runtime에서 canonical pointer를 dereference하는지는 이번 Codex review로 증명되지 않았다. static routing과 runtime compliance를 구분해야 한다.
- fresh Codex session auto-load와 Antigravity runtime은 미실측이다. Codex의 현재-entry consumption evidence와 AG contract/static evidence를 결합해 4-tool runtime으로 표현하면 안 된다.
- grep 기반 parity는 wording·format 변화에 본질적으로 민감하다. exact structured parser까지는 과잉일 수 있으나, frontmatter와 manifest path는 최소한 literal/anchored assertion으로 고정해야 한다.
- default scaffold tracked set `+5`는 release 후 adopter upgrade에 framework-add로 나타난다. migration note N/A 판단은 타당하지만 upgrade evidence에서 이 delta와 project-owned collision fallback을 계속 보여야 한다.

### R1b — Reviewer Confirmation (Codex)

**Verdict: approve.** R1 must-fix F1~F4가 권고 취지대로 반영됐고 blocking finding은 남지 않았다. cross-agent consensus를 종결해도 된다.

#### Confirmation

- **F1 승인 경계:** A1/A2는 approval gate를 state-changing/destructive/privileged action에 유지하면서 secret 미접촉 read-only/query/render/validate/dry-run만 허용한다. bounded temp cleanup도 같은 process/session이 만든 unique temp dir + path/prefix 확인으로 한정되고 user/persistent/shared path는 계속 gate된다. 과도한 반복 중단을 해소했으며 과소 보호로 넘어가지 않았다. specific command/purpose 승인 범위와 secret guard도 유지된다.
- **F2 parity:** pointer는 fixed-string, scope/copy loop는 anchored assertion으로 교정됐다. `[c2]`가 adapter 전문 재유입을 차단하고, Tier 2c는 canonical/adapter 7파일, generated `AGENTS.md` A1/A2 routing, manifest 신규 5개 path exact membership을 확인한다. Tier 0d static / Tier 2c generated 분리는 적정하다.
- **F3 DR:** `DR-044` Accepted가 A1/A2 구조, canonical/thin projection, Codex/AG entry, approval boundary, evidence limitation, scaffold default·reversal을 기록한다. brief가 확정하지 않았던 실행 결정을 독립 WHY로 보존하며 source-only/shipped closure 경계도 명확하다.
- **F4 cascade:** DR-007 `Amended:`에 2026-07-13이 추가됐고 decisions README의 DR-007 요약과 DR-044 index가 동기화됐다. shipped closure, WORKFLOW-MANUAL, root/generated README cascade도 정합하다.

#### Reviewer-Side Verification

- `bash scripts/tests/run-harness-checks.sh --all` 독립 재실행: **exit 0, OVERALL PASS**.
- Tier 0d: canonical/pointer/scope/[c2]/copy matrix 전건 PASS.
- Tier 1: shipped DR closure PASS.
- Tier 2: default·optional·source-gitflow scaffold invariants 및 cleanup PASS, manifest contract matrix PASS.
- Tier 2c: generated safety files·`AGENTS.md` routing·manifest 신규 5개 exact entry PASS.
- 따라서 bounded temp cleanup 경계 아래에서 safety rule과 deterministic verification workflow의 충돌이 reviewer 측에서도 해소됐음을 확인했다.

#### Non-Blocking Note / Residual Risk

- `check-rule-surface-parity.sh` 상단 `[e]` 설명의 “파일 6종”은 실제 검사 7파일(canonical 3 + adapter 4)과 숫자만 어긋난다. 실행·판정에는 영향이 없으며 closeout 전 문구 정정 정도면 충분하다.
- fresh Codex session auto-load, Antigravity runtime, Claude/Cursor canonical dereference는 이번 R1b 범위에서도 실측하지 않았다. `DR-044`의 evidence boundary가 이를 정확히 제한하므로 승인 차단 사유는 아니다.
