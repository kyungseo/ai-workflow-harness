---
id: CHORE-20260624-002
priority: P2
status: Done
risk: L2
scope: docs/AGENT-WORKFLOW.md를 framework-owned 순수 운영 규칙으로 만들고 product-specific Project Constants/Verification Defaults 값은 product-owned surface(docs/PLAN-SUMMARY.md Implementation Baseline)로 이동/병합한다. adopter가 AGENT-WORKFLOW.md를 accepted-drift 없이 framework-update로 받게 한다. 단순 overwrite가 아닌 target별 one-time migration이므로 upgrade playbook/verification에 절차를 명시한다. cross-agent review(Claude driver/Codex reviewer)로 진행.
appetite: 1d
planned_start: 2026-06-24
planned_end: 2026-06-24
actual_end: 2026-06-24
related_dr: [DR-043, DR-034]
related_troubleshooting: []
related_work: [CHORE-20260624-001]
---

# CHORE-20260624-002: AGENT-WORKFLOW product constants pointer-only 전환

## Top Summary

CHORE-20260624-001 spring upgrade에서 남은 **단일 accepted-drift `docs/AGENT-WORKFLOW.md`**의 근본 원인은, framework-owned 운영 규칙 문서에 **product-specific 값(`Project Constants` / `Verification Defaults`)이 혼재**한다는 점이다. spring은 이 값을 Java/Spring으로 커스터마이즈했고, 그래서 source와 영구히 갈린다.

이 Work는 `docs/AGENT-WORKFLOW.md`를 **framework-pure**로 만들고, product 값을 product-owned home으로 옮겨 adopter가 이 파일을 **framework-update로 깨끗이 받게** 한다.

**핵심 evidence:** `docs/PLAN-SUMMARY.md`에 이미 `Implementation Baseline` home이 존재하고(`BOOTSTRAP §3`가 PLAN-SUMMARY Baseline과 AGENT-WORKFLOW Project Constants를 **둘 다** 채움 = 중복), `scripts/create-harness.sh:425`가 AGENT-WORKFLOW를 adopter에 adapt-ship한다. 즉 canonical home 후보가 이미 있고, 중복만 제거하면 된다.

**경계:** 이 Work는 **source 전환 + 절차 명시**까지다. 실제 spring target 적용은 별도(또는 후속)로 다루며, current source 전환을 spring apply에 섞지 않는다(CHORE-001 원칙 계승).

## Scope

**canonical home (R0 + EXECUTE-전 amend):** product constants/verification 명령의 operational home = **`docs/PLAN-SUMMARY.md` Implementation Baseline / Verification Defaults**(scaffold가 이미 생성하는 owned 섹션). **PLAN.md로 옮기는 추가 migration 안 함**(existing scaffold reality 보존). PLAN-SUMMARY의 일반 roadmap/decision/history는 여전히 derived summary이고, Implementation Baseline/product Verification Defaults 섹션만 product-owned operational home(derived 규칙 예외). source repo에서는 이 섹션을 "source project constants summary"로 좁히고 L3 근거·이력은 PLAN/DR에 둔다. (DR-043 amended)

> **amend 사유:** EXECUTE 직전, scaffold 템플릿(`create-harness.sh:1077`)이 PLAN-SUMMARY에 이미 owned Implementation Baseline을 생성하고 BOOTSTRAP/SCAFFOLD-BOOTSTRAP가 그 경로를 전제함을 발견. R0에서 (b)PLAN.md를 택한 건 source/scaffold를 다시 섞은 성급한 판단이라 (a)PLAN-SUMMARY로 정정.

**필드별 분류 (R0-Codex-N1 반영):**

| AGENT-WORKFLOW 필드 | 분류 | 처리 |
| --- | --- | --- |
| Runtime / Framework / Build / Architecture / Base package | product | PLAN-SUMMARY Implementation Baseline로 이동, AGENT-WORKFLOW는 pointer |
| `Active state file: docs/STATUS.md` | **framework convention** | AGENT-WORKFLOW **유지** |
| Verification Defaults — Documentation/Workflow/Scaffold/Public release | **framework defaults** | AGENT-WORKFLOW **유지** |
| Verification Defaults — project test/build 명령(`./gradlew test` 등) | product | PLAN-SUMMARY Verification Defaults로 이동 + framework pointer 1줄 |

| 대상 | 변경 |
| --- | --- |
| `docs/AGENT-WORKFLOW.md` | product 필드를 PLAN-SUMMARY pointer로 전환, framework convention/defaults는 유지(위 분류표) |
| `docs/PLAN-SUMMARY.md` | source 자신 Implementation Baseline 채움("source project constants summary"로 좁힘) + Implementation Baseline/product Verification Defaults가 derived 예외 owned 섹션임을 경계 note로 명시 |
| `scripts/create-harness.sh` | AGENT-WORKFLOW adapt-ship = pointer 버전(source 편집 자동 전파). PLAN-SUMMARY 템플릿은 이미 Implementation Baseline 보유 → 생성 변경 최소. onboarding fill-order 문자열에서 AGENT-WORKFLOW Project Constants/Verification Defaults 중복 제거(F4) |
| `docs/BOOTSTRAP.md` | §3 onboarding이 product 값을 **PLAN-SUMMARY에만** 채우도록 갱신(AGENT-WORKFLOW 중복 제거) |
| `docs/SCAFFOLD-BOOTSTRAP.md` | `:34`,`:43` "Workflow constants = AGENT-WORKFLOW" 참조 갱신(F4) |
| `docs/maintainer/ADOPTER-UPGRADE-MIGRATION-PLAYBOOK.md` | **one-time migration + 분류 gate(F3)**: ⓪ target AGENT-WORKFLOW diff를 constants/verification-only인지 분류 — 그 외 local edit이면 `merge`/`blocker` → ① product 값을 target `PLAN-SUMMARY.md` Implementation Baseline/Verification Defaults로 이동·병합 → ② AGENT-WORKFLOW를 framework pointer 버전으로 교체 → ③ PLAN-SUMMARY 보존 + AGENT-WORKFLOW shadow diff 확인 → ④ manifest rebaseline 후 `--check` drift 소멸(accepted-drift→framework-update) |
| `docs/maintainer/VERIFICATION-COMMANDS.md` | AGENT-WORKFLOW drift 제거 **전** product constants가 target `PLAN-SUMMARY.md`에 보존됐는지 확인 추가 |
| **신규 DR (F5)** | "product constants home + AGENT-WORKFLOW framework-pure policy" — EXECUTE 전 `/record-decision`. DR-034엔 cross-pointer만 |

**비목표:** spring 등 실제 target migration 적용은 별도 Work. source template 변경 없이 spring만 바꾸는 단기 hack 금지.

## Plan

1. (done) feature branch `feature/chore-20260624-002-agent-workflow-pointer`, backlog 등록, Work 파일
2. R0 plan review (/cross-review): Codex red-team — 특히 canonical home 선택·중복 제거 범위·migration 누락 시 값 유실 위험
3. EXECUTE: source AGENT-WORKFLOW pointer-only 전환 + PLAN-SUMMARY home 확정 + scaffold/BOOTSTRAP cascade + playbook/verification 절차 추가
4. VALIDATE: source `--check`/invariants, scaffold dry-run, BOOTSTRAP cascade grep, (가능 시) spring replay로 migration 적용 시 AGENT-WORKFLOW가 framework-update로 in-sync 되는지 temp 확인
5. R1 result review (/cross-review)
6. Finalization: STATUS/backlog/Work Done, commit/PR gate

## Done Criteria

- [x] AGENT-WORKFLOW product 필드 → PLAN-SUMMARY pointer 전환, framework convention/defaults 유지(필드 분류표대로)
- [x] `docs/PLAN-SUMMARY.md` source Implementation Baseline 채움 + derived 예외 경계 note. PLAN.md home migration 안 함
- [x] scaffold/BOOTSTRAP/SCAFFOLD-BOOTSTRAP/generated STATUS cascade 정합 — 참조 grep 정리(F4, live 중복 0)
- [x] playbook one-time migration + 분류 gate(F3) 추가 + VERIFICATION에 product-constants 보존 확인 추가
- [x] 신규 DR-043 기록(Amended) + DR-034 cross-pointer
- [x] cross-review R0(plan)·R1(result) 종료 — R0/R1 closed, R1 must-fix 4 + nice 2 전부 fix·재검증
- [x] source parity/closure 자기일관성 + spring replay evidence(divergence=constants/verification only)

## Verification

source `--check`/invariants, scaffold dry-run, BOOTSTRAP cascade grep, adopter replay(temp). Surface: canonical · scaffold · adopter cascade · maintainer.

## Risk And Reversal

- `AGENT-WORKFLOW.md`는 `CLAUDE.md`/`AGENTS.md`가 entry에서 로드하는 **core 문서** → 변경이 모든 tool에 영향. 신중 cascade 필요.
- migration 절차 누락 시 adopter의 product 값이 overwrite로 **유실** 위험 → playbook/verification 명시가 핵심 완화.
- DR-worthy: framework/product 경계 정책 + canonical home 결정(reversal Medium, 복수 컴포넌트) → R0 후 DR 기록 여부 판단.
- Reversal: source 변경은 feature branch + PR → revertable. **Medium**.

## Discovery

backlog candidate "AGENT-WORKFLOW product constants pointer-only 전환" 착수. CHORE-20260624-001 R1 잔여 accepted-drift(`AGENT-WORKFLOW.md`)를 근본 제거하는 후속 분리 Work.

착수 evidence: PLAN-SUMMARY Implementation Baseline home 기존재 + BOOTSTRAP §3 중복 채움 + scaffold adapt-ship(`create-harness.sh:425`).

### EXECUTE + VALIDATE 결과 (2026-06-24)

**변경 파일:** `docs/AGENT-WORKFLOW.md`(Project Constants→pointer, Verification Defaults에 product 명령 pointer 1줄, framework convention/defaults 유지) · `docs/PLAN-SUMMARY.md`(source Implementation Baseline/Verification Defaults 추가 + derived 예외 경계 note) · `scripts/create-harness.sh`(onboarding fill-order 5곳 중복 제거) · `docs/SCAFFOLD-BOOTSTRAP.md`(2곳) · `docs/maintainer/ADOPTER-UPGRADE-MIGRATION-PLAYBOOK.md`(DR-043 one-time migration + 분류 gate) · `docs/maintainer/VERIFICATION-COMMANDS.md`(product-constants 보존 check) · `docs/decisions/DR-043`(신규, Amended) + README + DR-034 cross-pointer.

**shipped-DR closure 처리:** AGENT-WORKFLOW(shipped)와 generated BOOTSTRAP/STATUS 문자열의 `DR-043` 토큰은 self-describe로 제거(seed 밖 DR). source-only 문서(PLAN-SUMMARY/maintainer/SCAFFOLD-BOOTSTRAP/DR-file)만 `DR-043` 토큰 유지.

**Validation:**
- shipped-DR closure: **OK** (토큰 제거 후 재확인)
- `git diff --check`: clean / `bash -n create-harness.sh`: OK
- temp scaffold(spring-boot/source-gitflow): generated AGENT-WORKFLOW = pointer-only, PLAN-SUMMARY = Implementation Baseline 존재, **DR-043 dangling 0**
- default-template parity: OK / surface-mirror parity: PASS
- live onboarding 중복: 없음(grep hit은 archive historical only)
- **N3 spring replay evidence:** spring `AGENT-WORKFLOW.md`의 framework baseline 대비 divergence = **정확히 product constants 5줄 + product 검증 명령 1줄뿐**(다른 local edit 0). → migration 분류 gate 통과 + pointer 버전 교체 시 drift 해소 입증. (실제 spring apply는 비범위 — 별도 Work)

## Cross-Agent Review And Discussion

Model: `/cross-review` manual relay. Driver = Claude, Reviewer = Codex, Arbiter = User. Max rounds: plan R0 + result R1.

### R0 — Plan Review (Cross-Agent Relay Packet)

**Role:** Driver = Claude / Reviewer = Codex / Arbiter = User

**Target:** Work plan `CHORE-20260624-002` (AGENT-WORKFLOW product constants pointer-only 전환)

**Current State:**
- branch `feature/chore-20260624-002-agent-workflow-pointer`, Work/backlog 등록만 (구현 미착수)
- evidence: `AGENT-WORKFLOW.md` Project Constants(6값) + Verification Defaults가 product-specific; `PLAN-SUMMARY.md` Implementation Baseline home 기존재; `create-harness.sh:425` adapt-ship; `BOOTSTRAP §3` 중복 채움

**Delta Since Last Round:** R0 (first)

**Review Objective:** apply 전 plan의 방향·경계·canonical home·cascade·migration 안전성 red-team.

**Must Check:**
1. canonical home을 `PLAN-SUMMARY.md` Implementation Baseline으로 두는 게 옳은가. PLAN(상세)/PLAN-SUMMARY(요약) 분리가 필요한가, 아니면 Implementation Baseline 단일이면 충분한가.
2. pointer-only 전환 범위 — `Project Constants`만인가, `Verification Defaults`도 포함해야 하나(Verification Defaults는 framework 공통 규칙 + product 명령(`./gradlew test`)이 섞여 있음 → 분해 경계 주의).
3. one-time migration 절차가 product 값 유실을 실제로 막는가. "agent가 알아서 추론"에 의존하지 않고 playbook/verification에 충분히 명시되는가.
4. scaffold/BOOTSTRAP cascade 누락 — 신규 scaffold가 AGENT-WORKFLOW pointer-only + PLAN-SUMMARY 값 채움으로 정합한가. 기존 adopter(spring 등)와 신규 scaffold의 경로가 갈리지 않는가.
5. 이 변경이 DR-worthy인가(framework/product 경계 정책). 그렇다면 신규 DR vs DR-034 확장 중 무엇인가.
6. 이 Work를 "source 전환 + 절차 명시"로 제한하고 실제 adopter 적용을 분리하는 경계가 적절한가(under/over-scope).

**Do Not Re-litigate:**
- 목표 방향(AGENT-WORKFLOW framework-pure화로 accepted-drift 제거) — 사용자 확정
- source 전환과 adopter 실제 적용 분리 — 사용자 확정
- cross-agent 역할(Claude driver/Codex reviewer) — 확정

**Reviewer Posture:** 방향·경계·cascade·migration 안전성 의심. product 값 유실 경로, canonical home 중복/충돌, core 문서 변경의 blast radius 점검. speculation 표시.

**Output Contract:** Verdict(approve/conditional/request-changes/reject) · must-fix · nice-to-have · residual risk · suggested wording.

### R0 — Reviewer Findings (Codex)

Verdict: **request-changes** (must-fix 반영 시 진행 가능).

| ID | Severity | Finding (요약) |
| --- | --- | --- |
| R0-Codex-F1 | P1 | live `PLAN-SUMMARY.md`에 Implementation Baseline 없음 + derived-cache 명시 → canonical home 부적격. PLAN(SSoT)/PLAN-SUMMARY(요약) 2층 명확히 |
| R0-Codex-F2 | P1 | `Verification Defaults` 통째 이동 금지 — framework 공통 defaults 포함. product 명령(`./gradlew test/build`)만 이동, framework defaults는 AGENT-WORKFLOW 유지 |
| R0-Codex-F3 | P1 | migration이 "constants만 이동 후 overwrite"로 부족. target AGENT-WORKFLOW diff를 constants-only인지 분류, 그 외 local edit 있으면 merge/blocker. 값 이동 후 보존 확인 gate |
| R0-Codex-F4 | P2 | cascade 누락: `docs/SCAFFOLD-BOOTSTRAP.md`(:34,:43) + generated STATUS/BOOTSTRAP fill order. grep 정리 검증을 Done Criteria에 |
| R0-Codex-F5 | P2 | DR 경로를 지금 확정. 신규 DR("product constants home / AGENT-WORKFLOW framework-pure policy") 권장, DR-034엔 cross-pointer만 |
| R0-Codex-N1 | nice | `Active state file: docs/STATUS.md`는 product 아닌 framework convention → AGENT-WORKFLOW 유지 |
| R0-Codex-N2 | nice | source repo 자신 constants는 PLAN.md에 두고 PLAN-SUMMARY는 요약만 |
| R0-Codex-N3 | nice | spring temp replay 명시: 값 이동 → AGENT-WORKFLOW pointer-only shadow apply → `--check` drift 0 |

### R0 — Driver Response (Claude)

코드 검증: live `PLAN-SUMMARY.md`에 Implementation Baseline 부재 + L4 derived-cache 선언 확인. `AGENT-WORKFLOW.md` Verification Defaults 4개 중 3개(Documentation/Workflow/Scaffold/Public release)는 framework defaults. `SCAFFOLD-BOOTSTRAP.md:34,43` AGENT-WORKFLOW constants 참조 확인. **F1~F4 사실 확인.**

| Finding | Decision | Response |
| --- | --- | --- |
| F1 | **accept + revise** | canonical home = **`docs/PLAN.md` Implementation Baseline**(SSoT). PLAN-SUMMARY는 derived 요약 유지(필요 시 1줄 파생 pointer). scaffold/BOOTSTRAP가 product 값을 PLAN.md로 라우팅하도록 cascade |
| F2 | **accept + revise** | `Verification Defaults`는 framework defaults를 AGENT-WORKFLOW에 **유지**, project-specific 명령만 PLAN.md Implementation Baseline로 이동 + framework pointer 1줄 |
| F3 | **accept** | playbook migration에 gate 추가: target AGENT-WORKFLOW diff를 constants/verification-only로 분류 → 그 외 local edit이면 `merge`/`blocker`. 값 이동 후 PLAN.md 보존 확인 + AGENT-WORKFLOW shadow diff 확인 |
| F4 | **accept** | scope에 `docs/SCAFFOLD-BOOTSTRAP.md` + `create-harness.sh` generated STATUS/BOOTSTRAP/readout 추가. Done Criteria에 `Project Constants`/`Verification Defaults`/`AGENT-WORKFLOW` 참조 grep 정리 |
| F5 | **accept** | 신규 DR 확정: **"product constants home + AGENT-WORKFLOW framework-pure policy"**(EXECUTE 전 record-decision). DR-034엔 cross-pointer만 |
| N1 | **accept** | `Active state file: docs/STATUS.md`는 framework convention → AGENT-WORKFLOW 유지. 필드별 분류표로 반영 |
| N2 | **accept** | source repo 자신 constants → PLAN.md, PLAN-SUMMARY 요약만 (F1과 일치) |
| N3 | **accept** | spring temp replay를 Verification에 명시 |

R0 verdict: request-changes → **전부 accept로 해소**. 핵심 변경: Verification Defaults 분해(framework 유지/product만 이동), 신규 DR 확정, cascade 확장.

**EXECUTE-전 amend (owner 결정):** F1의 home을 PLAN.md로 잡았으나, EXECUTE 직전 scaffold 템플릿이 PLAN-SUMMARY에 이미 owned Implementation Baseline을 생성함을 발견 → home을 **PLAN-SUMMARY Implementation Baseline**으로 정정(DR-043 Amended). PLAN.md migration 없이 existing scaffold reality 보존. derived 규칙은 Implementation Baseline/product Verification 섹션만 예외로 owned. (Codex 재확인 없이 진행, R1에서 검증)

### Round Log

| Round | Driver | Reviewer | Objective | Verdict | Status |
| --- | --- | --- | --- | --- | --- |
| R0 | Claude | Codex | plan review | request-changes → conditional(전부 accept) | closed |
| R1 | Claude | Codex | result review | request-changes → 전부 fix | closed |

### R1 — Reviewer Findings (Codex) + Driver Response

Verdict: **request-changes** (scaffold 출력 결함 + stale ref). 4 must-fix 전부 코드 검증 후 **accept·fix**.

| ID | Finding | Decision | Fix |
| --- | --- | --- | --- |
| R1-Codex-F1 | `create-harness.sh:854` generated onboarding "operational home4." 줄바꿈 누락(malformed) | accept | `4.` 항목 앞 newline 복원 |
| R1-Codex-F2 | `create-harness.sh:1004` generated checklist "그대로 둔다- [ ]" 줄바꿈 누락 | accept | checklist 항목 앞 newline 복원 |
| R1-Codex-F3 | `create-harness.sh:1397` final echo가 여전히 "AGENT-WORKFLOW — Project Constants와 Verification Defaults" | accept | "framework convention만 (product 값은 PLAN-SUMMARY Implementation Baseline)"로 교체 |
| R1-Codex-F4 | Work Scope 표가 아직 target `PLAN.md` migration/preservation 언급(stale) | accept | playbook/VERIFICATION row를 `PLAN-SUMMARY.md`로 정정 |
| R1-Codex-N1 | PLAN-SUMMARY Verification Defaults 문구가 product/source 검증 섞임 | accept | "source project verification summary (owned 예외)"로 좁힘 |
| R1-Codex-N2 | fix 후 temp scaffold 재생성 grep 0 확인 권장 | done | 재생성 후 `home4\.|둔다- \[|Project Constants와 Verification Defaults` grep = **0** |

**원인 메모:** F1/F2 malformed는 EXECUTE 중 generated 문자열의 ` (DR-043)` 토큰 제거가 인접 항목 사이 newline을 함께 삼킨 결과. 토큰 self-describe 처리 시 list-item 경계 손상 — 재검증 grep으로 0 확인.

R1 verdict: request-changes → **전부 fix + 재검증(generated defect 0, closure/parity OK)으로 해소**. cross-review(R0/R1) 종료.

### R1 — Result Review Relay Packet

**Role:** Driver = Claude / Reviewer = Codex / Arbiter = User

**Target:** EXECUTE 결과 (harness branch `feature/chore-20260624-002-agent-workflow-pointer`, uncommitted)

**Delta Since R0:** R0 must-fix 전부 accept + EXECUTE-전 home amend(PLAN.md→PLAN-SUMMARY, DR-043 Amended). 구현 완료.

**Current State (변경 11 + 신규 2):**
- `docs/AGENT-WORKFLOW.md`: Project Constants→PLAN-SUMMARY pointer, Verification Defaults에 product 명령 pointer 1줄, framework convention(`Active state file`)·framework defaults 유지
- `docs/PLAN-SUMMARY.md`: source Implementation Baseline/Verification Defaults 추가 + derived 예외 경계 note
- `scripts/create-harness.sh`: onboarding fill-order 5곳 중복 제거(product→PLAN-SUMMARY), generated에 DR 토큰 없음
- `docs/SCAFFOLD-BOOTSTRAP.md`: 2곳 갱신
- `docs/maintainer/{PLAYBOOK,VERIFICATION-COMMANDS}`: DR-043 one-time migration + 분류 gate + 보존 check
- `docs/decisions/DR-043`(신규, Accepted Amended) + README + DR-034 Linked

**Validation Evidence:**
- shipped-DR closure OK(토큰 self-describe 처리), `git diff --check` clean, `bash -n` OK
- temp scaffold(spring-boot): generated AGENT-WORKFLOW=pointer, PLAN-SUMMARY=Implementation Baseline, DR-043 dangling 0
- default-template parity OK, surface-mirror parity PASS, live 중복 0
- N3 replay: spring AGENT-WORKFLOW divergence = product constants 5 + product 검증 1줄뿐 → 분류 gate 통과, 교체 시 drift 해소

**Must Check:**
1. home amend(PLAN-SUMMARY) + derived 예외 경계가 일관적인가. PLAN-SUMMARY의 "derived cache" 규칙과 "Implementation Baseline owned" 예외가 충돌 없이 명확한가.
2. AGENT-WORKFLOW가 framework-pure인가 — product 값이 정말 다 빠졌고 framework convention/defaults만 남았나. 누락/과잉 제거 없나.
3. shipped-DR closure 처리(토큰 제거 vs source-only 유지)가 올바른가. generated 산출물에 dangling DR 없나.
4. one-time migration 분류 gate(F3)가 product 값 유실을 실제로 막는가. N3 evidence가 충분한가.
5. cascade 누락 — `Project Constants`/`Verification Defaults`/`AGENT-WORKFLOW` 참조가 source 전반에서 정합한가(특히 generated STATUS/BOOTSTRAP).
6. DR-043 Amended 내용이 결정과 일치하는가(home=PLAN-SUMMARY, PLAN.md migration 없음).

**Do Not Re-litigate:** home=PLAN-SUMMARY(owner amend), scope 경계(실제 adopter apply 별도 Work), Verification Defaults 분해 방향 — 확정.

**Reviewer Posture:** 결과 회귀·누락·과장 의심. framework-pure 완전성, derived 경계 명확성, shipped 누출 점검. speculation 표시.

**Output Contract:** Verdict(approve/conditional/request-changes/reject) · must-fix · nice-to-have · residual risk.
