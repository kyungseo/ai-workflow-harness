---
id: CHORE-20260611-009
priority: P2
status: Done
risk: L2
scope: source repo maintainer/AI driver용 운영 runbook(`docs/maintainer/SOURCE-REPO-OPERATIONS.md`)을 신설하고 `docs/maintainer/README.md`를 갱신해 검증 척추(CHORE-20260611-005~008) 산출물을 변경 lifecycle 순서로 엮는다. 배포 surface(AGENT-WORKFLOW/GUIDE/WORKFLOW-MANUAL) 변경, 검증 기준/명령/정책 SSoT 복제, 기존 자산 재배치·rewrite, upgrade/migration·product planning pack 설계는 범위 밖.
appetite: 0.5d
planned_start: 2026-06-11
planned_end: 2026-06-11
actual_end: 2026-06-11
related_dr: [DR-021, DR-025]
related_work: [CHORE-20260611-005, CHORE-20260611-006, CHORE-20260611-007, CHORE-20260611-008]
---

# CHORE-20260611-009: Source repo maintainer operations manual

## Top Summary

- **목표:** source repo maintainer/AI driver가 "변경 lifecycle에서 어떤 문서·스크립트를 어느 순서로 실행·해석하는지" 막힘없이 따라갈 수 있는 **운영 runbook**을 만든다. CHORE-20260611-005~008로 검증 척추(taxonomy·runner·catalog·gate parity)는 생겼으나, 이것들을 **실제 변경 흐름 순서로 엮는 진입 문서가 없다**.
- **핵심 판단 1 (흡수/대체/재배치 — backlog가 요구한 비판적 검토의 답):** 기존 `docs/HARNESS-MAINTAINER-GUIDE.md`를 **흡수·대체하지 않는다.** 근거는 `docs/maintainer/README.md`가 이미 고정한 **audience × distribution 직교축**이다. GUIDE는 `distribution=optional-pack`(scaffold `--with-optional`로 **target에 adapt 배포** — `create-harness.sh:417`)이라 adopter도 읽는 문서다. 신규 runbook은 `distribution=source-only`(어디에도 미배포, cross-agent·source-gitflow·temp/ 등 **source repo 고유 운영**)다. 흡수하면 배포되는 adopter-facing maintainer guide를 잃는다. → **올바른 관계는 분리 + 경계 명시 + 상호 pointer**이며, 신규 문서는 `docs/maintainer/`(source-only)에 둔다.
- **핵심 판단 2 (복제 금지 — runbook은 순서만 엮는다):** taxonomy(기준 SSoT)·VERIFICATION-COMMANDS(명령 카탈로그)·HARNESS-RECOVERY-VALIDATION(판단·정책)·repo-health(orchestration)·HARNESS-MAINTAINER-GUIDE(setup/convention)의 **내용을 복제하지 않는다.** runbook은 "언제 무엇을 어느 순서로, 무엇을 보고 판단하는지"의 **순서축**만 담고 기준·명령·정책은 **pointer로 위임**한다(표면 비대화 경계).
- **핵심 판단 3 (배포 surface를 건드리지 않고 파일 범위를 source-only로 닫는다 — R0 Must-fix 1·3):** 이번 009는 canonical `AGENT-WORKFLOW.md`(배포)와 `HARNESS-MAINTAINER-GUIDE.md`(optional-pack 배포)를 **변경하지 않는다.** 배포 surface에 source-only 개념을 추가하면 target/adopter 기본 로딩 표면에 source-only 부담이 새고, 파일 범위가 안 닫혀 검증 강도도 안 닫힌다. 진입점은 source-only `docs/maintainer/README.md`로 충분히 닫는다(maintainer 자산 인덱스). → **Files = source-only 2개(`SOURCE-REPO-OPERATIONS.md` + `maintainer/README.md`)로 확정**, 배포 surface 0개 → 검증은 diff/pointer/중복 grep으로 닫힌다.
- **핵심 판단 4 (tool-neutral review pattern — R0 Must-fix 2):** lifecycle을 `Claude=A driver / Codex=B reviewer` 고정 절차로 박지 않는다. 이 repo 공통 운영 문서는 Claude/Codex/Cursor를 함께 전제하고 `.claude/commands/*`는 Codex/Cursor가 따르는 canonical이 아니다. runbook 본문은 **"single-agent 또는 cross-agent review 가능; cross-agent일 때 Round/Consensus Log를 남긴다"**로 일반화하고, command pointer는 `.claude/commands/*`가 아니라 **canonical `skills/workflow/*` + HARNESS-PROTOCOL/GIT-WORKFLOW** 중심으로 잡는다. 현재 W1의 A/B 방식은 Work 파일 내부 관례/예시로만 둔다.
- **재정의된 gap:** ① 검증 척추 산출물을 변경 lifecycle 순서로 엮는 진입 runbook 부재. ② 변경 유형(docs-only / workflow·tool-surface / scaffold·template / verification taxonomy·catalog / release prep)별 실행 경로가 문서·스크립트에 분산. ③ run-harness-checks tier 선택 기준과 temp/ 운용 근거가 산재. ④ 네 검증 자산(taxonomy/catalog/recovery/repo-health)의 역할 차이가 한곳에 정리돼 있지 않음.
- **범위:** runbook 1개 신설(`docs/maintainer/SOURCE-REPO-OPERATIONS.md`) + `docs/maintainer/README.md` 분류표·자산표 행 추가. **배포 surface(AGENT-WORKFLOW/GUIDE/WORKFLOW-MANUAL) 변경 0개**, 새 검증 기준/명령/정책 작성 없음, 기존 문서 rewrite·재배치 없음.

## Background / Facts (검증된 현황)

**검증 척추 산출물 (이 runbook이 엮을 대상):**

| Work | 산출물 | 역할 |
| --- | --- | --- |
| CHORE-20260611-005 | `docs/maintainer/HARNESS-TEST-TAXONOMY.md` + `scripts/tests/run-harness-checks.sh` | 검증 **기준 SSoT**(Surface×Depth·Tier·temp/ 정책) + tier runner |
| CHORE-20260611-006 | leak-scan(source-gitflow 6 shipped 표면) | scaffold/tool-surface regression |
| CHORE-20260611-007 | VERIFICATION-COMMANDS Layer U | product pack 검증(stack/profile↔core, planning pack) |
| CHORE-20260611-008 | VERIFICATION-COMMANDS Layer Q-static | gate path-list parity(5 surface 3축) |

**문서 표면 분류 (`docs/maintainer/README.md`가 고정한 직교축):**

| 문서 | audience | distribution | 위치 |
| --- | --- | --- | --- |
| `WORKFLOW-MANUAL.md` | user / adopter | optional-pack | `docs/` 루트 |
| `HARNESS-MAINTAINER-GUIDE.md` | maintainer | **optional-pack(배포)** | `docs/` 루트 |
| `VERIFICATION-COMMANDS.md`·`VERSIONING.md`·`migrations/` | maintainer | **source-only(미배포)** | `docs/maintainer/` |
| **(신규) SOURCE-REPO-OPERATIONS.md** | **source maintainer / AI driver** | **source-only(미배포)** | `docs/maintainer/` |

**관련 사실:**

- `docs/maintainer/`는 명시적 **source-only** 디렉토리 — "scaffold 어떤 옵션(`--with-optional` 포함)에서도 target에 복사되지 않는다." 근거: DR-021 Amendment(2026-06-10).
- `HARNESS-MAINTAINER-GUIDE.md`는 setup/daily workflow/convention/validation/scaffold dev/tool-surface alignment/public release/hook policy(§1~§10)를 다룬다. 이 중 §2 Daily Workflow·§5 Validation·§6 Scaffold Development·§7 Tool Surface Alignment가 **운영 순서와 중복 위험**이 있는 영역 → runbook은 이 영역을 복제하지 않고 가리킨다.
- WORKFLOW-MANUAL은 자칭 "사용자 매뉴얼"(user/adopter-facing). runbook과 audience가 다르다 — 섞지 않는다.
- `run-harness-checks.sh`는 `--tier0/--tier1 <target>/--tier2/--all` 모드를 가진다(CHORE-005). temp/ 정책(생성 위치·cleanup·왜 /tmp 대신 temp/)은 taxonomy가 SSoT.
- `HARNESS-RECOVERY-VALIDATION.md`는 failure state·Validation Checklist·Commit Approval 판단의 conditional-load 문서. runbook은 "실패 시 여기로" pointer만.

## Scope / Plan

> 합의 전 구현 금지. 아래는 Codex R0 plan review 대상.

### Scope (포함)

1. **(신규) source-only 운영 runbook 작성** — 후보 경로 `docs/maintainer/SOURCE-REPO-OPERATIONS.md`(이름·위치 OQ-1). 구성:
   - **A. 작업 lifecycle(순서축, tool-neutral):** work-select → work-plan(3 pre-check) → **review(single-agent self-review 또는 cross-agent review)** → 구현 → result review → work-close → commit(approval) → PR(`--base develop`) → squash merge → develop sync. review 단계는 도구 중립으로 서술하고, **cross-agent로 진행할 때 Round/Consensus Log를 남긴다**는 조건부 패턴으로만 명시(Claude=A/Codex=B 같은 고정 역할은 박지 않음). **각 단계는 canonical `skills/workflow/*`·HARNESS-PROTOCOL·GIT-WORKFLOW를 가리키는 pointer만**(`.claude/commands/*`는 adapter이므로 진입 pointer로 쓰지 않음), 절차 본문 복제 금지.
   - **B. 변경 유형별 검증 경로(매트릭스):** 행=변경 유형(docs-only / workflow·protocol·tool-surface / scaffold·template / maintainer verification taxonomy·catalog / release prep), 열=무엇을 어느 순서로 실행(taxonomy Tier 선택 → catalog Layer → runner 모드 → cascade 점검 → git diff --check). 각 셀은 **기존 자산 pointer**(예: "tool-surface → catalog Layer Q-static + runner `--tier1`").
   - **C. runner tier 선택 기준:** `--tier0`(syntax) / `--tier1 <target>`(deterministic) / `--tier2`(scaffold simulation) / `--all`을 **언제 쓰는지** 1표. 기준 자체는 taxonomy SSoT pointer.
   - **D. temp/ 실테스트 운용:** 생성 위치·cleanup·`/tmp` 대신 `temp/`인 이유 — taxonomy pointer + 운영 주의(예: inject-revert는 working file 아닌 temp 복사본).
   - **E. 네 검증 자산 역할 구분 1표:** taxonomy(기준) / VERIFICATION-COMMANDS(명령) / HARNESS-RECOVERY-VALIDATION(판단·정책) / repo-health(orchestration). **복제 아닌 "어느 것을 언제 펴나" 구분.**
   - **F. PR 전 최소 검증 checklist → 실패 시 recovery 연결 → CI/hook/hard-gate 미적용 항목 해석.**
2. **(pointer) `docs/maintainer/README.md` 갱신** — 자산 표 + 문서 표면 분류표에 신규 runbook 행 추가(source-only 마킹). **이것이 유일한 진입점이다.**

### Non-goals (명시적 제외 — 확장 방지)

- WORKFLOW-MANUAL rewrite, README rewrite (user-facing, W2 `User-facing docs rewrite`).
- HARNESS-MAINTAINER-GUIDE 삭제·대체·전면 개편·pointer 추가 (분리 유지 + 이번 범위 미변경 — R0 Must-fix 1).
- canonical `AGENT-WORKFLOW.md` Context Routing 변경 (배포 surface에 source-only 개념 누수 방지 — R0 Must-fix 1). 진입점은 `docs/maintainer/README.md`로 닫는다.
- lifecycle을 특정 도구 역할(Claude=A/Codex=B)로 고정 (tool-neutral 일반화 — R0 Must-fix 2).
- upgrade/migration 메커니즘, product starter planning pack 설계 (W2 / Layer U).
- 새 검증 기준·명령·정책 작성 (taxonomy/catalog/recovery SSoT 복제 금지, pointer만).
- F1~F4(runner→repo-health deep 통합 등) 본체 구현 — runbook은 "완료 시 update trigger" pointer만.
- product/adopter 운영 흐름(scaffolded project operations) — source repo operations와 **경계 분리**.

### 8개 비판적 검토에 대한 응답 (사용자 요구)

| # | 질문 | plan의 답 |
| --- | --- | --- |
| 1 | 새 문서 vs GUIDE 재배치 | **신규(분리).** distribution 축이 다름(GUIDE=배포, runbook=source-only). 흡수 시 adopter-facing guide 상실. |
| 2 | WORKFLOW-MANUAL user-facing 유지? | 유지. audience 다름(user/adopter). 섞지 않음. |
| 3 | taxonomy/catalog/recovery/repo-health 역할 복제 안 함? | E절은 **역할 구분 1표**(복제 아님), 나머지는 전부 pointer. |
| 4 | CHORE-005~008 후속 무작정 흡수 안 함? | runbook엔 **pointer + update-trigger만**, 본체 구현 제외(Non-goals). |
| 5 | F1~F4/F5·W2 과혼합 안 함? | F1~F4=pointer only, W2=Non-goals 명시. |
| 6 | source vs scaffolded project 경계 명확? | runbook은 **source repo operations 전용**, product/adopter 운영 제외(Non-goals). 배포 surface 0개로 경계 물리 차단(R0a). |
| 7 | "문서 하나 더"가 아니라 실제 경로 시뮬레이션 가능? | Verification에서 변경 유형 5종 walkthrough로 검증(아래). |
| 8 | docs rewrite/upgrade/product pack로 확장 안 함? | 전부 Non-goals 명시. |

### Files (후보 — R0 합의 후 확정)

> **파일 범위 확정(R0a):** 배포 surface 0개. source-only 2파일 + tracking만.

| 파일 | 변경 | 비고 |
| --- | --- | --- |
| `docs/maintainer/SOURCE-REPO-OPERATIONS.md` | 신규 runbook | source-only. 이름 OQ-1=승인 |
| `docs/maintainer/README.md` | 자산표·분류표 행 추가 | source-only. **유일 진입점** |
| `docs/STATUS.md` | Active pointer·Recent Decisions·Next Actions | **R0a 합의·승인 후에만** |
| `docs/backlog/HARNESS.md` | 항목 제거(완료 시) | close 시 |
| `docs/works/harness/README.md` | Active 등록 → Done | 흐름 |

> **제외 확정:** `docs/HARNESS-MAINTAINER-GUIDE.md`, `docs/AGENT-WORKFLOW.md`는 **건드리지 않는다**(R0 Must-fix 1). 배포 surface 0개이므로 shipped/adopter dangling·scaffold simulation 검증은 불필요(Verification 6 참조).

## Verification (계획)

1. **변경 유형별 walkthrough(핵심 — #7 응답):** runbook의 B 매트릭스를 따라 5개 변경 유형 각각에 대해 "지금 이 변경이면 어느 셀 → 어느 자산을 어느 순서로" 경로가 끊김 없이 연결되는지 dry walkthrough. 막히는 셀이 있으면 pointer 보강.
2. **pointer 실재 grep:** runbook이 인용한 모든 경로(taxonomy·catalog·recovery·repo-health·command/skill·GIT-WORKFLOW·runner)가 실재하는지 `grep`/파일 존재 확인. dangling 0.
3. **중복/역할 충돌 grep:** runbook ↔ HARNESS-MAINTAINER-GUIDE(§2/§5/§6/§7) ↔ WORKFLOW-MANUAL 간에 절차 본문이 복제되지 않았는지 grep(기준/명령/정책 문장이 runbook에 재서술되면 fail).
4. **tool-neutral 검사(R0 Must-fix 2):** runbook 본문에 `Claude=A`/`Codex=B` 같은 고정 역할이 절차로 박혀 있지 않은지, command pointer가 `.claude/commands/*`가 아니라 canonical `skills/workflow/*`를 가리키는지 grep 확인.
5. **git diff --check** + 문서 stale phrase 점검.
6. **run-harness-checks tier 선택 근거(파일 범위 확정에 따른 검증 강도):** Files=source-only 2파일, **배포 surface 0개**(R0a). 따라서 docs-only(source-only maintainer 문서)로 **`--tier0`(script 무결성 회귀) + diff --check + pointer 실재 + 중복/역할 grep으로 닫힌다.** Tier 2 scaffold simulation·shipped/adopter dangling 검증·runner cascade는 **불필요**(배포 surface를 건드리지 않으므로). 이 분기 근거를 Verification에 명시.

## Risk / Reversal Cost

- **Risk:** L2(maintainer/workflow surface 문서). 주요 위험 = ① runbook이 기준/명령/정책을 복제해 SSoT 이원화 → grep 검사(Verification 3)로 차단. ② source-only 진입점이 `docs/maintainer/README.md`에만 있어 **발견성이 낮을 수 있음** → maintainer 자산 인덱스에 명시 등재로 완화(배포 surface pointer는 future scope). ③ "문서 하나 더" 표면 비대화 → pointer-only 원칙 + Non-goals로 차단.
- **Reversal Cost:** Low. 되돌리려면 **runbook 삭제 + `docs/maintainer/README.md` 행 제거 + tracking 정리**로 충분. 배포 surface 변경 0이므로 외부(adopter/target) 영향 없음.

## Cross-Agent Review And Discussion

> Claude=A(author/driver), Codex=B(reviewer). 합의 전 구현 금지. Round Log / Consensus Log 누적.

### Round Log

| Round | 주체 | 유형 | 요약 |
| --- | --- | --- | --- |
| R0 | Codex(B) | plan review | 방향 적절(분리 판단 OK). 단 shipped core/tool-specific surface 경계 미닫힘. Must-fix 3건: ① `AGENT-WORKFLOW.md` source-only pointer 제외(target/adopter 표면 부담), ② lifecycle `Claude=A/Codex=B` 고정 → tool-neutral review pattern 일반화 + command pointer canonical skills 중심, ③ 파일 범위(source-only vs shipped) 확정 후 검증 강도 분기. OQ-1~5 답변 제공. **Changes Requested** |
| R0a | Codex(B) | plan re-review | R0 must-fix 실질 방향 반영됨(배포 surface 0개, 진입점=`docs/maintainer/README.md` 단일, lifecycle tool-neutral). 단 Top Summary·Risk·frontmatter scope에 이전 범위 문구(배포 surface pointer/N/A 마킹, 기존 자산 재배치) 잔존 → 정리 필요. **Conditional Approval** (stale 문구 3곳 정리 후 구현 착수 가능, R0b 불필요) |
| R0b | Claude(A) | fix | stale scope 문구 3곳 정리: Top Summary 범위 줄(배포 surface pointer 삭제), Risk(dangling→발견성 risk 재정의, dangling=future scope), frontmatter scope(재배치 문구 제거). 승인 범위와 plan 일치 확정. |
| R1 | Codex(B) | result review | 승인 범위(source-only runbook + maintainer README + tracking) 준수, 배포 surface 변경 0 확인. runbook도 pointer-only로 억제됨. 단 B 매트릭스 `workflow/protocol/tool-surface` 행을 `--tier1 <target>`로 라우팅한 것이 runner 의미와 불일치(`--tier1`은 기존 target 디렉터리 전용 → source 변경 기본 검증에 쓰면 usage error/오기대). **Changes Requested** (Must-fix 1 + nice-to-fix: Reversal Cost 이전 흔적 정리) |
| R1b | Claude(A) | fix | Must-fix: B 매트릭스 workflow 행 tier를 `--tier0 + catalog Layer` 기본, scaffold 영향 시 `--tier2`/`--all`, 기존 target 검증 필요 시에만 `--tier1 <target-dir>`로 정정. nice-to-fix: Reversal Cost를 "runbook 삭제 + README 행 제거 + tracking 정리, 배포 surface 0"으로 정리. |
| R2 | Codex(B) | result re-review | R1 must-fix 확인. workflow 행이 runner 의미와 정합되도록 정정됨, Reversal Cost 흔적 정리됨. 신규 파일 whitespace·tier0·배포 surface 미변경 확인. 추가 변경 요청 없음. **Approved** — `/work-close` 진행 승인(비차단: Verification "Tier 0/1" 문구를 "Tier 0 + diff/pointer/중복 grep"으로 정리 권장). |
| R2b | Claude(A) | fix | 비차단 정리 반영: Verification 6 "Tier 0/1 doc 검사" → "`--tier0` + diff --check + pointer 실재 + 중복/역할 grep". |

### Consensus Log

| 항목 | 상태 | 합의 내용 |
| --- | --- | --- |
| 흡수 vs 분리(HARNESS-MAINTAINER-GUIDE) | Agreed | 분리 유지. GUIDE 부분 이관은 이번 범위 밖(R0 OQ-2). |
| 복제 금지(순서축만, 기준/명령/정책 pointer) | Agreed | runbook은 순서만, SSoT 복제 금지(R0 이견 없음). |
| 배포 surface 변경 범위 | Agreed | AGENT-WORKFLOW **미변경**, GUIDE도 이번 범위 미변경. 진입점=`docs/maintainer/README.md` 단일. 파일 범위 source-only 2파일로 확정(R0 Must-fix 1·3, A가 GUIDE도 제외로 더 보수적 채택). |
| review pattern | Agreed | tool-neutral(고정 역할 없음). cross-agent는 조건부 패턴, command pointer는 canonical skills 중심(R0 Must-fix 2, OQ-5). |
| 변경 유형 분류 | Agreed | 5종 유지(R0 OQ-4). Tier 매핑은 C절 표에서 pointer로 연결. |

### Plan-Level Open Questions

| ID | 상태 | 질문 / 결론 |
| --- | --- | --- |
| OQ-1 | Closed | 문서명/위치 → `docs/maintainer/SOURCE-REPO-OPERATIONS.md` **승인**(R0). |
| OQ-2 | Closed | 분리 유지. GUIDE 부분 이관은 범위 밖(R0). |
| OQ-3 | Closed | 배포 surface(GUIDE·AGENT-WORKFLOW)에서 가리키지 **않는다**. 진입점=README 단일(R0 Must-fix 1 + A 보수적 채택). |
| OQ-4 | Closed | 5종 분류 유지(R0). Tier 매핑은 C절. |
| OQ-5 | Closed | cross-agent는 조건부 패턴으로만, 고정 절차화 금지(R0 Must-fix 2). |

## Done Criteria

- [x] source repo maintainer/AI driver가 변경 lifecycle에서 어떤 문서·스크립트를 어느 순서로 쓰는지 막힘없이 따라갈 수 있는 runbook이 `docs/maintainer/`에 존재 — `SOURCE-REPO-OPERATIONS.md`(A~F절 + Update Triggers).
- [x] 검증 기준/명령/정책(taxonomy/catalog/recovery)을 복제하지 않고 pointer로 연결 — V3: dry-run 전체 명령 복제 0, 표 기반 pointer-only.
- [x] WORKFLOW-MANUAL / product pack(Layer U) / HARNESS-MAINTAINER-GUIDE와 경계 명확 — 문서 상단 경계 블록 + `docs/maintainer/README.md` 직교축 표에 등재.
- [x] 배포 surface(AGENT-WORKFLOW/GUIDE) 미변경 — 변경 파일 = STATUS/maintainer README/Work index README/runbook/Work 파일뿐(배포 surface 0).
- [x] lifecycle이 tool-neutral(고정 역할 없음), command pointer가 canonical skills 중심 — V4: 고정 역할 0, `.claude/commands/*`는 "진입 pointer로 쓰지 않는다"는 부정 서술만.
- [x] 변경 유형 5종 walkthrough 경로 끊김 없음 — B 매트릭스 5종 각 셀의 Layer(E/F/G/H/N/P/A/B/C/D/J/Q-static/R/Release Sweep)·tier 실재 확인.
- [x] pointer dangling 0 — V2: 인용 경로 16종 전부 OK.
- [x] STATUS / backlog / Work index 정합 — work-close에서 STATUS Active 제거·Recent Decisions·Next Actions, backlog row 제거, Work index Done 반영.

## Discovery

- **runbook 구성 확정:** A(lifecycle tool-neutral 순서축) / B(변경 유형 5종 × tier·catalog Layer·cascade 매트릭스) / C(runner tier 선택) / D(temp/ 운용) / E(네 검증 자산 역할 1표) / F(PR 전 checklist→실패→enforcement 해석) + Update Triggers.
- **catalog Layer 실재 매핑:** docs-only→E/H/P/N, workflow·tool-surface→E/F/G/Q-static, scaffold·template→A/B/C/D/J/J-OB, taxonomy·catalog→self-check(M)+해당 Layer, release→Release Full Sweep+H/R. (`VERIFICATION-COMMANDS.md` Layer 인덱스로 확인.)
- **runner 인자 형식 확인:** `--tier1`은 `<target-dir>` 인자 필수(생성 없음), `--tier2`/`--all`은 temp/ 생성 포함.
- **검증 결과:** V2 pointer 16종 dangling 0 / V3 명령 복제 0 / V4 tool-neutral 통과 / V5 diff --check clean / V6 tier0 OVERALL PASS.
- **경계 차단:** 배포 surface(AGENT-WORKFLOW/GUIDE/WORKFLOW-MANUAL) 0개 변경으로 source-only 경계를 물리적으로 닫음(R0 Must-fix 1).
