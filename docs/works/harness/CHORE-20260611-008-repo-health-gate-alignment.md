---
id: CHORE-20260611-008
priority: P1
status: Done
risk: L2
scope: gate-list(framework SSoT)와 gate-config(project add-only)·git-workflow rule 간 정합을 repo-health/검증 surface에 연결한다. repo-health 전면 리팩터, maintainer ops manual, Layer U(product) 경계 확장, runner/helper 변경은 범위 밖.
appetite: 0.5d
planned_start: 2026-06-11
planned_end: 2026-06-11
actual_end: 2026-06-11
related_dr: [DR-024, DR-025]
related_work: [CHORE-20260611-005, CHORE-20260611-006]
---

# CHORE-20260611-008: repo-health gate-config/gate-list 정합 surface

## Top Summary

- **목표:** gate 정책의 protected/finalization 경로 정합을 검증 surface에 연결한다. 핵심은 **같은 정책을 서술하는 5개 source-실재 surface** — `tools/git-hooks/lib/gate-lists.sh`(SSoT) ↔ `.claude/rules/git-workflow.md`(rule) ↔ `docs/GIT-WORKFLOW.md`(source user-facing) ↔ `scripts/templates/source-gitflow/docs/GIT-WORKFLOW.md`(shipped template) ↔ `create-harness.sh`의 `.harness/gate-config` seed — 사이의 **drift 미검출** 사각지대를 닫는 것이다(R0 must-fix: GIT-WORKFLOW 2종 추가).
- **핵심 판단 1 (backlog 전제 정정):** backlog "`​.harness/gate-config`가 live operational인데 LIVE_TARGETS에 없음"은 **source repo에선 부정확**하다 — source엔 gate-config가 **없다**(create-harness.sh가 target에 `write_text`로 seed하는 add-only 파일). source LIVE_TARGETS에 추가하면 phantom path grep. 또 gate-config는 **add-only**(framework default override 불가)라 "런타임 충돌"이 아니라 **문서/목록 parity drift**가 진짜 위험이다.
- **핵심 판단 2 (가장 위험한 drift, R0 지적):** shipped `source-gitflow template`(28/383행)이 "gate-lists.sh와 **동일 목록**, repo 고유 경로는 `case`에 직접 추가"라고 안내 — **add-only gate-config 정책(gate-lists.sh 직접 편집 금지)과 정면 충돌하는 stale 안내**. 이를 정정하고 parity Axis C2가 재발을 검출하게 한다.
- **핵심 판단 3 (surface별 정책 차이 ≠ drift, R0a must-fix):** surface마다 기대 key가 다르다 — `scaffold`(create-harness.sh)는 source 3종에 있으나 **template엔 N/A**(create-harness.sh가 target에 미ship), `project-gate-config`는 gate-lists.sh·rule·seed에 있으나 **user-facing GIT-WORKFLOW 2종엔 없음**. 따라서 "동일 key 집합"이 아니라 **surface별 expected key matrix**로 비교한다(아래 Axis A).
- **재정의된 gap:** ① 5 surface가 같은 protected/finalization 정책을 중복 서술하는데 drift 검출 없음. ② template stale 안내가 add-only 정책과 충돌. ③ seed 섹션명 ↔ gate-lists.sh section args 정합 검사 없음. ④ Required Surface Matrix에 gate parity trigger pointer 없음. ⑤ runner(F4) 미연결.
- **범위:** parity cross-check(concrete, Q-static) 1개를 catalog에 추가 + template stale 안내 2줄 정정 + repo-health Surface Matrix pointer + LIVE_TARGETS 정정 결정 + runner F4 pointer만. **repo-health 전면 리팩터·helper·runner 변경 없음.**

## Background / Facts (검증된 현황)

**Protected/finalization 경로가 서술되는 surface (5개, source 실재):**

1. `tools/git-hooks/lib/gate-lists.sh` — **framework SSoT**. `awh_is_branch_isolation_protected_path`(protected case 목록), `awh_is_finalization_file`(finalization case: STATUS/backlog/works/decisions/README), `awh_project_glob_match`(section args `protected`/`finalization`로 gate-config add-only 확장). manifest 추적, upgrade 시 overwrite.
2. `.claude/rules/git-workflow.md`(32~35행) — AI-facing rule. **protected 목록은 명시 path list**로 재서술하나, **finalization default는 같은 수준 path list로 반복하지 않고** "do not edit framework-owned gate-lists.sh; use add-only gate-config" 정책을 명시.
3. `docs/GIT-WORKFLOW.md`(source, 22~27행) — user-facing. protected를 **semantic 범주 표**(Workflow/status, AI entrypoint, Canonical workflow, Tool surface, Enforcement)로 서술. **stale gate-lists-edit 안내 없음(clean).**
4. `scripts/templates/source-gitflow/docs/GIT-WORKFLOW.md` — **shipped template**. 같은 범주 표 + (28행) "이 표는 gate-lists.sh와 **동일한 목록**… 두 곳을 함께 갱신" + (383행) "repo 고유 민감 경로는 `awh_is_*`의 **case 패턴에 추가**". → **add-only `.harness/gate-config` 정책(2·5와 create-harness seed 주석)과 정면 충돌하는 stale 안내.** target에서 gate-lists.sh는 framework-owned(upgrade overwrite)이므로 case 직접 추가는 잘못된 안내.
5. `scripts/create-harness.sh`(672~708행) gate-config seed — `[protected]`/`[finalization]` 섹션 + add-only 주석. write_text라 manifest 미추적, upgrade-safe.

**기타 사실:**

- source repo에는 `.harness/` 디렉터리 자체가 없음(gate-config 없음). gate-config는 **scaffold target 전용 live 파일**(source-gitflow에서 hook이 직접 읽음). → source LIVE_TARGETS 추가 시 phantom path.
- `skills/workflow/repo-health.md` Surface Matrix(139행): `tools/git-hooks/**` 행 Tool-specific 칸에 `gate-lists.sh`·`.harness/gate-config`가 **하위 점검 항목으로만** 등장. gate-list↔rule↔GIT-WORKFLOW parity 점검 pointer 없음. LIVE_TARGETS(148~154행)에 `.harness/` 없음(정상).
- repo-health mirror `.agents/skills/workflow-repo-health/SKILL.md`는 22줄 **thin pointer**(Surface Matrix 미복제) → canonical 편집 시 mirror parity 갱신 불필요.
- DR-024(gate 2D taxonomy), DR-025(commit gate runtime, decision-only) — 이 Work는 **기존 gate 자산의 정합 검증 연결 + stale 안내 정정**이므로 DR 신규·변경 불필요.

## Scope / Plan

> 합의 전 구현 금지. 아래는 Codex R0 plan review 대상.

> **3-axis 분리(must-fix 3):** protected / finalization / seed-section은 비교 성격이 달라 같은 방식으로 다루지 않는다.

1. **(concrete) gate parity cross-check 추가 — `VERIFICATION-COMMANDS.md` Layer Q 인접 "Q-static"** (hook functional과 분리된 static parity sub-check; 005 경계상 concrete 명령 home=catalog). 3축으로 구성:
   - **Axis A — Protected-path semantic-category parity (must-fix 2: raw sort-diff 금지 / R0a must-fix: surface별 expected matrix).** protected를 서술하는 surface 1~4를 **semantic key**로 비교한다. raw glob(`docs/backlog/*` vs `**` vs `*.md`)을 직접 diff하지 않고 **key 대표 토큰 존재**로 정규화한다. "동일 key 집합 강제"가 아니라 **surface별 expected key matrix**로 비교해 정책 차이를 drift로 오탐하지 않는다(R0a 지적: scaffold/gate-config는 surface별로 의도적 차이).

     | semantic key | gate-lists.sh (SSoT) | git-workflow.md rule | docs/GIT-WORKFLOW.md (source) | source-gitflow template |
     | --- | --- | --- | --- | --- |
     | workflow-status (STATUS/backlog/works/decisions) | ✓ | ✓ | ✓ | ✓ |
     | ai-entrypoint (AGENTS/CLAUDE) | ✓ | ✓ | ✓ | ✓ |
     | canonical-workflow (AGENT-WORKFLOW/HARNESS-PROTOCOL/QUICK-REFERENCE/GIT-WORKFLOW) | ✓ | ✓ | ✓ | ✓ |
     | tool-surface (.claude/.cursor/.agents/prompts) | ✓ | ✓ | ✓ | ✓ |
     | hooks (tools/git-hooks) | ✓ | ✓ | ✓ | ✓ |
     | scaffold (scripts/create-harness.sh) | ✓ | ✓ | ✓ | **N/A** (target 미ship) |
     | project-gate-config (.harness/gate-config) | ✓ | ✓ | **N/A** (user doc 미표기) | **N/A** |

     검사 규칙: 각 surface를 **자기 expected 열**과 대조한다 — expected ✓인데 누락이면 drift, expected N/A면 비교 제외. 즉 template에 scaffold 행이 없는 것은 PASS(N/A), gate-lists.sh에 scaffold가 빠지면 FAIL. expected matrix 자체가 정책의 SSoT이며 catalog에 표로 고정한다.
   - **Axis B — Finalization parity (must-fix 3: path-list 아님, policy/pointer).** gate-lists.sh `awh_is_finalization_file` default(STATUS/backlog/works/decisions/README)를 SSoT로 두고, rule·GIT-WORKFLOW는 finalization을 **DR-025 bundling 정책/pointer**로 서술하므로 **개념·canonical set·DR-025 참조 일관성**을 검사한다(raw path diff 금지).
   - **Axis C — seed section + add-only 안내 parity.** (c1) seed `[protected]`/`[finalization]` 섹션명 == gate-lists.sh `awh_project_glob_match` section args. (c2) **anti-drift assertion:** shipped doc이 project 경로를 framework-owned `gate-lists.sh` `case`에 직접 추가하라고 안내하지 않는다(add-only gate-config로 유도). template 28/383행 stale 안내가 이 assertion에 걸린다.
2. **(content fix) source-gitflow template stale 안내 정정** — `scripts/templates/source-gitflow/docs/GIT-WORKFLOW.md` 28행("동일한 목록…두 곳을 함께 갱신")·383행("case 패턴에 추가…목록만 확장")을 **add-only `.harness/gate-config`** 사용으로 정정(framework-owned gate-lists.sh 직접 편집 금지 정책과 정합). **2줄 수준 targeted 정정**(리팩터 아님). Codex가 지목한 "가장 위험한 drift" 실제 해소.
3. **(pointer) repo-health Surface Matrix 보강** — `tools/git-hooks/**` 행 보강 + gate parity trigger를 명시: `gate-lists.sh`·`.claude/rules/git-workflow.md`·`docs/GIT-WORKFLOW.md`·source-gitflow template·seed 변경 시 **Layer Q-static 실행** pointer. **grep 명령은 catalog에만, repo-health엔 pointer만**(중복 금지).
4. **(decision) LIVE_TARGETS 정정** — `.harness/gate-config`를 source LIVE_TARGETS에 **추가하지 않는다**(source 미존재 phantom). source-side 검사 대상은 `gate-lists.sh`·`git-workflow.md`·`docs/GIT-WORKFLOW.md`·shipped template·create-harness.sh seed이며 이미 `tools`/`.claude`/`scripts`/`docs`로 LIVE_TARGETS에 포함됨을 기록. gate-config는 scaffold-target surface(Tier2/OB7가 커버).
5. **(pointer) runner F4 surface** — runner `--all`이 gate 검증의 executable 동반자임을 pointer로만 명시. runner 변경·deep 통합은 후속(F4 본체).

### Files (후보 — R0 합의 후 확정)

| 파일 | 변경 | 비고 |
| --- | --- | --- |
| `docs/maintainer/VERIFICATION-COMMANDS.md` | Layer Q 인접 "Q-static" gate parity sub-check(Axis A/B/C) | concrete 명령 home. source-only maintainer 문서 |
| `scripts/templates/source-gitflow/docs/GIT-WORKFLOW.md` | 28/383행 stale 안내 → add-only gate-config로 정정 | shipped template. **targeted 2줄 정정** |
| `docs/GIT-WORKFLOW.md` (source) | commit-msg 절에 finalization bundling pointer 1줄 추가(R1 must-fix 1, Axis B 누락 해소) | shipped 표면. DR-025 토큰 없이 self-describe(closure-safe, DR-033 mode-a) |
| `skills/workflow/repo-health.md` | Surface Matrix gate parity trigger 보강 + Q-static/runner pointer | canonical. grep 중복 없이 pointer만 |
| `docs/backlog/HARNESS.md` | work-close 시 row 처리 | close 단계 |
| `docs/STATUS.md` | Recent Decisions / Next Actions / Last updated | close 단계, Approval Matrix |
| `docs/works/harness/README.md` | Active→Done | close 단계 |

> - mirror `.agents/skills/workflow-repo-health/SKILL.md`는 thin pointer라 **변경 불필요**(확인됨).
> - `docs/GIT-WORKFLOW.md`(source)는 stale 안내는 없으나(clean) **finalization bundling pointer가 누락**돼 있었다(template엔 hook 구성 절에 존재) → R1에서 commit-msg 절에 1줄 추가해 Axis B 정합.
> - 정정은 shipped 표면이므로 leak-scan/closure 재확인(통과).

### Verification

- **Q-static 3축 실행:** 현 5 surface가 Axis A(semantic key cover)/B(finalization policy 일관)/C(seed section + add-only 안내)에서 PASS.
- **inject-revert(축별):**
  - Axis A: gate-lists.sh protected에 가짜 key surface 추가 → 문서가 미반영하면 drift 검출 → revert → PASS.
  - Axis C(c2): template에 "edit gate-lists.sh case" 류 안내를 (테스트로) 재주입 → anti-drift assertion이 FAIL → revert → PASS. (이번 정정이 실제로 c2를 닫는지 증명.)
- `VERIFICATION-COMMANDS.md` 자체 점검 M1~M5(경로 실재, 명령 stale, bash 문법 1차, repo-health 등재, cascade 범위).
- `git diff --check`, `bash scripts/tests/check-shipped-dr-closure.sh`.
- 척추 연결: `bash scripts/tests/run-harness-checks.sh --all` green 유지. template 정정은 shipped 표면이므로 invariants `[2] leak-scan`(source-gitflow shipped set 포함)·tier2 source-gitflow 모드가 회귀 없이 PASS인지 확인.
- repo-health Surface Matrix가 가리키는 Q-static이 catalog에 실재하는지 pointer grep.

### Risk / Reversal

- **리스크 1:** backlog 문구를 그대로 따라 phantom `.harness/gate-config`를 LIVE_TARGETS에 넣으면 source repo grep noise/오탐. → 추가하지 않기로 결정(scope 3).
- **리스크 2:** parity check를 repo-health에 grep으로 직접 박으면 005 경계(HOW=catalog, judgment=repo-health) 위반 + 중복. → catalog에 두고 pointer만.
- **리스크 3:** gate enforcement 자체(hook hard-stop)로 scope 확장 위험. → 이 Work는 **정합 검출 연결만**, enforcement 강화는 별도(`문서-only 규칙 강제화`). backlog 메모의 hook exit(1) 논의는 건드리지 않음.
- **되돌리기 비용:** Low. source-only 문서/skill pointer 추가, branch revert 가능. gate-lists.sh 실행 로직·hook·scaffold 출력 미변경.

### 후속으로 넘길 항목

- runner→repo-health deep 통합(결과 파싱/출력) = F4 본체.
- hook exit(1) 강화 + 예외 클래스 DR = `문서-only 규칙 강제화` / 기존 gate series 메모.
- repo-health.md slice 분리(P2) = 별도 backlog 항목.

### Codex review questions

- parity check home: catalog 신규 sub-check vs 기존 Layer Q(hook functional) 확장 중 어디가 맞나? (OQ-1)
- Surface Matrix: 기존 `tools/git-hooks/**` 행 보강 vs gate-list/rule/seed 전용 trigger 행 신설? (OQ-2)
- LIVE_TARGETS에 `.harness/gate-config` 미추가 결정이 맞나(source phantom)? scaffold-target 검증은 Tier2/OB7가 이미 커버하므로 별도 불요? (OQ-3)
- parity 검출 방식: 정규화된 경로 목록 sort-diff vs 대표 키 grep 교차? false-positive 최소화 기준은? (OQ-4)
- runner F4는 pointer만으로 이번 Done Criteria 충족인가? (OQ-5)

### DR-007 언어 정책

- maintainer 문서 + canonical skill = Korean primary, 기술 식별자 English. commit Bilingual Rules.

### CHORE-20260611-005/006 검증 척추와의 연결

- parity check는 catalog(HOW) 층에 추가, repo-health(judgment)는 pointer만. taxonomy(WHAT/HOW-DEEP)는 gate parity가 executable 승격 가치가 있으면 F3 후보로 기록만(이번엔 catalog 명령 우선). runner 변경 없음.

## Cross-Agent Review And Discussion

이 Work는 A(Claude)가 author/driver로 Work 파일+plan 및 구현을 담당하고,
B(Codex)가 plan review와 result review를 수행한다.
합의 전에는 구현하지 않는다.

### Round Log

| Round | Reviewer | Type | Summary | Required Changes / Decision | Status |
| --- | --- | --- | --- | --- | --- |
| R0 | Codex | Plan Review | 변경 요청. backlog `.harness/gate-config` LIVE_TARGETS 전제 정정·미추가·catalog home·repo-health pointer-only 방향은 타당. | Must-fix 3건: ① parity 대상에 `docs/GIT-WORKFLOW.md` + `scripts/templates/source-gitflow/docs/GIT-WORKFLOW.md`(가장 위험한 user-facing shipped surface, template은 "gate-lists.sh와 동일 목록"이라며 add-only 정책과 충돌하는 stale 안내 보유) 포함 ② raw sort-diff 금지 → semantic normalization으로 비교 ③ protected parity와 finalization parity를 분리 설계(rule엔 finalization path list 미반복). **3건 반영 완료(아래 재설계).** | Changes Requested → Resolved |
| R0a | Codex | Plan Re-review | 조건부 변경요청(1·2 고치면 구현 착수 승인). 5 surface·3축·Q-static·template 정정 방향 타당. | Must-fix: ① Axis A를 "동일 key 집합"이 아니라 **surface별 expected key matrix**로(source 전용 scaffold key·gate-config가 surface별로 다른 정책 차이를 drift로 오탐 방지). ② Top Summary/재정의된 gap을 5 surface 기준으로 갱신. Nice-to-fix: R0a 확인 전 Consensus/OQ를 Agreed/Closed로 선반영하지 말 것. **3건 반영 완료.** | Conditional → Resolved |
| R1 | Codex | Result Review | 방향 R0/R0a 합의와 정합(5 surface, expected matrix, template add-only 정정, repo-health pointer-only, LIVE_TARGETS 미추가). | Must-fix: ① Axis B가 finalization 누락을 INFO로 넘겨 "실패하지 않는 검사" — `docs/GIT-WORKFLOW.md`에 finalization bundling pointer 추가 + expected-missing=DRIFT. ② Axis C anti-drift regex가 영어/식별자형(`edit gate-lists.sh case`, `awh_is_* case`) 누락 — regex 확장 + 부정문 오탐 회피. Nice-to-fix: Axis B도 pair label. **3건 반영 완료(검증: Axis B 전 surface OK, C2 한/영 3형태 검출 + 오탐 0, closure/runner PASS).** | Changes Requested → Resolved |
| R2 | Codex | Result Re-review | R1 must-fix 2건 및 nice-to-fix 확인. Axis B expected missing은 DRIFT로 승격, source/template label 충돌 해소. `docs/GIT-WORKFLOW.md` source finalization pointer로 실제 drift 닫힘. Axis C regex는 한/영/identifier형 직접편집 안내를 잡되 fixed 문서 오탐 없음. Q-static 수동 실행·closure·tier0·diff 모두 OK. | 추가 변경 요청 없음. `/work-close` 진행 승인. | Approved |

### Consensus Log

| Topic | Consensus | Source Round | Status |
| --- | --- | --- | --- |
| parity 비교 대상 | **5 surface**: gate-lists.sh ↔ git-workflow.md rule ↔ docs/GIT-WORKFLOW.md ↔ source-gitflow template ↔ seed. (R0 must-fix 1로 GIT-WORKFLOW 2종 추가) | R0 | Agreed |
| 비교 방식 | **semantic key normalization**(raw sort-diff 금지). protected는 key cover, finalization은 policy/pointer, seed는 section명 — 3축 분리 (R0 must-fix 2·3) | R0 | Agreed |
| Axis A 비교 단위 | "동일 key 집합"이 아니라 **surface별 expected key matrix**(scaffold=template N/A, project-gate-config=user doc N/A 등 정책 차이를 drift로 오탐하지 않음). matrix를 catalog에 SSoT로 고정 (R0a must-fix 1) | R0a | Agreed |
| parity check home | catalog `VERIFICATION-COMMANDS.md` **Layer Q 인접 "Q-static"**(hook functional과 분리). repo-health는 pointer만 (005 경계) | R0 | Agreed |
| template stale 안내 | source-gitflow template 28/383행 "edit gate-lists.sh case" → add-only gate-config로 정정(가장 위험한 drift 해소) | R0 | Agreed |
| LIVE_TARGETS | `.harness/gate-config` 미추가(source phantom). source-side는 seed+shipped template 검사 대상 명시. scaffold-target은 Tier2/OB7 커버 | R0 | Agreed |
| Surface Matrix | gate-list/rule/GIT-WORKFLOW/template/seed 변경 → Q-static 실행 pointer(grep 중복 없음) | R0 | Agreed |
| runner F4 | 이번엔 pointer만, deep 통합은 후속 | R0 | Agreed |

### Plan-Level Open Questions

| ID | Question | 합의 결과 | Owner | Status |
| --- | --- | --- | --- | --- |
| OQ-1 | parity check home | catalog **Layer Q 인접 "Q-static"**(hook functional과 분리된 static parity) — R0 합의 | Claude + Codex | Closed |
| OQ-2 | Surface Matrix 기존 행 보강 vs 신규 행 | 기존 `tools/git-hooks/**` 행 보강 + GIT-WORKFLOW/template/seed까지 거는 gate parity trigger 명시 — R0(기존 행만으론 부족) | Claude + Codex | Closed |
| OQ-3 | LIVE_TARGETS에 gate-config 미추가 | 미추가(source phantom) + seed·shipped template를 검사 대상 명시 — R0 합의 | Claude + Codex | Closed |
| OQ-4 | parity 검출 방식 | **semantic normalization**(raw sort-diff 반대) + 대표 키 보조, protected/finalization/seed 3축 분리 — R0 must-fix | Claude + Codex | Closed |
| OQ-5 | runner F4 pointer만으로 Done 충족 | 충족. deep 통합은 F4 본체 후속 — R0 합의 | Claude + Codex | Closed |
| OQ-6 | template stale 안내 정정을 이번 Work 범위에 포함 | 포함(2줄 targeted 정정). Codex가 "가장 위험한 drift"로 지목, parity Axis C가 검출하는 대상 — R0 must-fix 1 | Claude + Codex | Closed |

## Done Criteria

- [x] Q-static gate parity sub-check가 `VERIFICATION-COMMANDS.md` Layer Q 인접에 추가됨 — 5 surface, 3축(protected semantic-key matrix / finalization policy / seed section + add-only) 분리, raw sort-diff 미사용.
- [x] Axis C inject-revert로 drift 검출이 증명됨(injected=DRIFT, fixed=PASS). Axis A는 expected-matrix 대조로 N/A vs DRIFT 구분.
- [x] source-gitflow template 28/383행 stale 안내가 add-only gate-config로 정정됨.
- [x] repo-health Required Surface Matrix에 gate path-list parity 행 + Q-static/LIVE_TARGETS/F4 pointer note 추가(grep 중복 없음, 양방향 pointer 정합).
- [x] LIVE_TARGETS에 `.harness/gate-config` 미추가 결정·근거(source phantom, scaffold-target은 Tier2/OB7)가 기록됨.
- [x] runner F4 surface가 pointer로 명시되고 runner/helper 변경 없음.
- [x] repo-health 전면 리팩터·Layer U(product) 경계 혼입·gate enforcement 강화로 확장되지 않음.

## Discovery

- **검증 실행으로 결함 2건 자가 발견·수정(중요):**
  - **(1) inject-revert가 uncommitted 정정을 clobber.** Axis C2 inject-revert 1차 시도에서 `git checkout "$TPL"`로 inject를 되돌렸는데, template 정정이 commit 전이라 **정정까지 HEAD(stale)로 날아갔다**. → 재적용 후, inject-revert를 **working 파일이 아닌 temp 복사본**에서 수행하도록 교정(injected=DRIFT, fixed=PASS, working 무손상 확인). uncommitted 파일에 `git checkout` revert 금지 교훈.
  - **(2) source/template basename 충돌.** Axis A/C 출력에서 `docs/GIT-WORKFLOW.md`와 template이 둘 다 basename `GIT-WORKFLOW.md`로 표시돼 구분 불가 → `check_surface`/c2에 명시 label(`GWF(source)`/`GWF(template)`) 도입.
- **R0a must-fix 반영:** Axis A를 "동일 key 집합"이 아니라 **surface별 expected key matrix**로 설계(scaffold=template N/A, project-gate-config=user doc N/A). Top Summary/gap을 5 surface로 정렬. Consensus/OQ는 R0a 확인 후 확정.
- **검증 결과:** Q-static 3축 working 파일 전부 OK, Axis C inject-revert DRIFT 검출 증명, `run-harness-checks.sh --all` OVERALL PASS(template shipped 변경에도 source-gitflow leak-scan/tier2 회귀 없음), `git diff --check` clean, closure OK, Q-static bash `-n` 정상, 양방향 pointer(repo-health↔catalog) 정합.
- **변경 파일:** `VERIFICATION-COMMANDS.md`(Layer Q-static), `scripts/templates/source-gitflow/docs/GIT-WORKFLOW.md`(stale 안내 2줄 정정), `skills/workflow/repo-health.md`(Surface Matrix gate parity 행+pointer), `docs/works/harness/README.md`(Active 등록).
- **R1(Codex result review) must-fix 반영:**
  - **(must-fix 1) Axis B "실패하지 않는 검사" 결함:** `docs/GIT-WORKFLOW.md`(source)에 finalization/DR-025 언급이 전혀 없는데 Q-static이 INFO로 넘겼다(반면 template은 hook 구성 절에 보유 — 실제 drift였음). → source commit-msg 절에 finalization bundling pointer 1줄 추가(DR-025 토큰 없이 self-describe, closure-safe) + Axis B expected-missing을 **DRIFT**로 변경. 결과: 모든 expected surface OK.
  - **(must-fix 2) Axis C anti-drift regex 협소:** 한국어 stale 문구만 잡고 `edit gate-lists.sh case`·`add ... awh_is_..._path case` 영어/식별자형을 놓쳤다. → BAD regex에 영어/식별자 패턴 추가 + EXCL(`편집하지|add-only|gate-config`)로 "편집하지 말고" 부정문 오탐 회피. 검증: 한/영 3형태 모두 DETECTED, working(fix) 파일 오탐 0.
  - **(nice-to-fix) Axis B label:** source/template basename 충돌 → pair label(`rule`/`GWF(source)`/`GWF(template)`).
- **남은 후속:** runner→repo-health deep 통합 = F4 본체. hook exit(1) enforcement = `문서-only 규칙 강제화`. gate parity executable 승격(필요 시) = F3.
