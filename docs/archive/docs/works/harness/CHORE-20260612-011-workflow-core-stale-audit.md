---
id: CHORE-20260612-011
priority: P1
status: Archived
risk: L2
scope: Workflow core layering audit + minimal realignment. 상위 canonical에서 하위 상세로 내려가는 문서 위계 원칙을 세우고, AGENT-WORKFLOW / HARNESS-PROTOCOL / fallback/scaffold surface 중복·stale을 workflow 보존 기준으로 정렬한다. R0 전 구현 없음.
appetite: 0.5d
planned_start: 2026-06-12
planned_end: 2026-06-12
actual_end: 2026-06-13
related_dr: [DR-014, DR-021, DR-023, DR-027]
related_work: [CHORE-20260612-007, CHORE-20260612-008, CHORE-20260612-009, CHORE-20260612-010]
---

# CHORE-20260612-011: Workflow Core Layering Audit + Minimal Realignment

## Top Summary

- **목표:** 상위 canonical에서 하위 상세 문서로 내려가는 layering 원칙을 먼저 세우고, 그 원칙으로 `AGENT-WORKFLOW.md` / `HARNESS-PROTOCOL.md` / fallback prompt / scaffold surface의 중복·stale을 최소 정렬한다.
- **왜 지금:** 사용자가 원한 것은 단순 stale list가 아니라 "왜 하위 문서가 상위 구조를 다시 들고 있는가"라는 문서 위계 정비다. CHORE-20260612-007~010이 safe slice로 닫혔지만, 문서 계층 원칙 자체가 불명확하면 다음 W3 작업도 같은 의문을 반복한다.
- **핵심 경계:** workflow가 현재 잘 작동하는 사실을 보존한다. 즉, 문서 중복을 줄이더라도 `/session-start`, `/work-plan`, `/work-close`, commit/PR gate, scaffold bootstrap의 행동 유도는 깨뜨리지 않는다.
- **역할:** Codex = author/driver, Claude = red team reviewer.

## User Intent Clarification

이번 Work의 원천 의도는 "stale 후보 몇 개를 처리"가 아니다.

사용자가 원하는 결과:

1. **상위→하위 문서 위계가 명확해야 한다.**
   - 상위 문서가 실행 원칙과 routing을 잡고, 하위 문서는 필요한 상세만 가진다.
   - 하위 문서가 상위 구조를 다시 복제한다면 그것이 의도된 요약인지, drift-prone duplication인지 판단해야 한다.
2. **중복 제거가 workflow를 망치면 안 된다.**
   - 지금까지 잘 작동하던 workflow를 단순 정리 욕심으로 깨뜨리지 않는다.
   - 제거 전에는 실제 command/skill/fallback/scaffold load path에서 필요한 정보인지 확인한다.
3. **작게 닫기보다 체계가 맞아야 한다.**
   - 단, 체계 정비는 broad rewrite가 아니라 원칙 → matrix → 승인된 최소 realignment 순서로 진행한다.

## Trigger / User Questions

사용자가 제기한 stale 후보:

1. `docs/AGENT-WORKFLOW.md`
   - `Project Constants`가 문서 앞단에 있어야 하지 않는가?
   - `Context Routing`이 있는데 `docs/HARNESS-PROTOCOL.md`의 `Document Map`과 하단 `Load Map`이 모두 필요한가?
   - `State Machine`, `Approval Matrix`가 양쪽에 같이 존재하는 것이 맞는가?
2. `docs/GIT-WORKFLOW.md`
   - `Commit Message Format`의 `Type prefix`가 `commit-msg` hook에도 복사되어 있는데 SSoT 위반 아닌가?
3. `docs/decisions/DR-014-archive-policy.md`
   - `phase2/` 경로가 `PRODUCT.md` 전환 이후 stale 아닌가?
   - "harness protocol 문서에 archive trigger 반영 필요"가 이미 반영됐는가?
4. Scaffold / fallback prompt
   - `prompts/claude-session-start.md`의 `5. New Project Initialization`은 여전히 유효한가?
   - scaffold된 `docs/retrospectives/README.md`, `docs/troubleshooting/README.md`의 `Frontmatter 스펙 (DR-027)` 참조는 DR-027 seed inclusion과 맞는가?

## Initial Fact Check

R0 전 read-only 확인 결과:

| Candidate | Current Evidence | Initial Read |
| --- | --- | --- |
| Project Constants 위치 | `docs/AGENT-WORKFLOW.md` 하단 `## Project Constants` | 앞단 이동 검토 가치 있음. 단순 이동인지, `Session Startup`/`Context Routing` 근처 pointer화할지 판정 필요 |
| Document Map / Load Map / Context Routing | `AGENT-WORKFLOW.md` Context Routing, `HARNESS-PROTOCOL.md` §3 Document Map, §7 Load Map 모두 존재 | 중복 가능성 높음. 다만 AGENT-WORKFLOW는 startup load map, protocol은 detailed reference일 수 있어 role split 판정 필요 |
| State Machine / Approval Matrix | 양쪽에 존재. R0에서 Approval Matrix L3 description drift와 detail split 차이 확인됨 | AGENT-WORKFLOW는 compact execution gate, HARNESS-PROTOCOL은 상세 state detail일 수 있으나, 같은 정책의 표현이 달라진 경우는 content drift로 우선 판정 |
| GIT-WORKFLOW commit type list | `docs/GIT-WORKFLOW.md` §5와 hook surface 모두 존재 | hook runtime은 자체 list가 필요할 수 있음. SSoT/pointer/validation 방식 점검 대상 |
| DR-014 `phase2/` | archive tree example에 `phase2/` 존재 | stale 가능성 높음. quick fix 후보 |
| Archive trigger protocol 반영 | HARNESS-PROTOCOL T10, Work File Rules, `/work-close` archive section 존재 | 이미 반영된 것으로 보임. no-action 또는 DR-014 note 정리 후보 |
| `claude-session-start.md` New Project Initialization | fallback prompt에 section 존재 | bootstrap/STATUS-gated onboarding 이후 과한 fallback일 수 있음. cascade 확인 필요 |
| DR-027 scaffold README | `scripts/create-harness.sh`가 DR-027 seed와 README frontmatter spec을 생성 | current fresh scaffold에서는 대체로 맞음. 오래된 temp 산출물 false positive 가능성 있음 |

## Scope / Non-Goals

### Scope

1. workflow core layering principle을 문서화한다.
   - `docs/AGENT-WORKFLOW.md`: compact execution SSoT / startup load contract / approval gate summary.
   - `docs/HARNESS-PROTOCOL.md`: conditional detailed reference / trigger and lifecycle detail.
   - tool/fallback/scaffold surfaces: entry adapters and generated target guidance, not independent policy sources.
2. 사용자 stale 후보 8개를 이 layering principle에 따라 사실 확인한다.
3. 각 후보를 아래 네 가지로 분류한다.
   - **Fix now:** 한두 줄 stale, low risk, scope-local
   - **Defer as W3 slice:** 구조 판단이 필요하거나 reversal cost가 Medium 이상
   - **No action:** 이미 반영됐거나 의도된 중복
   - **Needs fresh scaffold verification:** 오래된 temp 산출물 가능성이 있는 항목
   - **Content sync:** 같은 정책의 표현이 drift된 경우. Minimal realignment의 하위 케이스로 우선 검토한다.
4. **Minimal realignment candidate**를 별도로 판정한다.
   - 중복이 명백하지만 제거 위험이 낮은 경우 pointer-only 정렬 또는 heading/prose 축소를 제안한다.
   - 행동 유도에 영향이 있으면 후속 W3 slice로 분리한다.
5. Fix-now 또는 minimal realignment 후보가 R1에서 승인되면 최소 패치만 적용한다.
6. 반박/수용 판단을 `Finding Disposition`으로 기록한다.

### Non-Goals

- `docs/HARNESS-PROTOCOL.md` trigger family simplification 전체 재작성.
- `AGENT-WORKFLOW.md` / `HARNESS-PROTOCOL.md` 대형 구조 개편. 단, R1에서 승인된 pointer-only/minimal realignment는 가능.
- prompt task library archive 이동.
- archive pending Work 정리.
- README/MANUAL readability rewrite.
- `commit-msg` hook runtime 로직 변경. 필요하면 후속 Work로 분리한다.
- scaffold live target에 파일 복사.

## Files

### Plan / Tracking

| File | Plan |
| --- | --- |
| `docs/works/harness/CHORE-20260612-011-workflow-core-stale-audit.md` | Work SSoT |
| `docs/works/harness/README.md` | Active Work index row |

### Audit Surfaces

| File / Path | Purpose |
| --- | --- |
| `docs/AGENT-WORKFLOW.md` | Project Constants 위치, Context Routing, State Machine, Approval Matrix |
| `docs/HARNESS-PROTOCOL.md` | Document Map, Load Map, state/approval duplicate, archive triggers |
| `docs/GIT-WORKFLOW.md` | commit message policy |
| `tools/git-hooks/commit-msg` | runtime type-prefix list and finalization gate |
| `docs/decisions/DR-014-archive-policy.md` | stale archive tree examples and protocol consequence |
| `prompts/claude-session-start.md` | fallback `New Project Initialization` validity |
| `scripts/create-harness.sh` | DR-027 seed inclusion and generated README/spec surfaces |
| `docs/retrospectives/README.md`, `docs/troubleshooting/README.md` | source README DR-027 references |

## Plan

### Phase 0 — R0 Review

1. Work file + index row만 생성한다.
2. Claude R0 plan review를 요청한다.
3. R0 findings를 반영하기 전 구현하지 않는다.

### Phase 1 — Layering Principle + Stale Matrix

1. `AGENT-WORKFLOW.md`, `HARNESS-PROTOCOL.md`, fallback prompt, scaffold seed의 역할 원칙을 먼저 쓴다.
2. 각 후보별 current source line과 role을 기록한다.
3. 중복이면 아래 기준으로 판정한다.
   - **Essential restatement:** 하위 표면이 독립 실행에 필요한 짧은 요약.
   - **Pointer-worthy detail:** 하위 표면에 있으면 비대화되는 상세. 상위/상세 SSoT로 위임.
   - **Stale duplication:** 같은 정책을 복제해 drift 위험을 만든 문장/표.
   - **Content drift:** 같은 정책인데 두 표면의 판정 기준/표현이 달라진 경우. one-liner sync 또는 pointer-only 위임을 먼저 검토.
   - **Runtime necessity:** hook/script처럼 실행을 위해 독립 list가 필요한 경우.
4. scaffold 관련 항목은 fresh dry-run으로 재검증한다.
5. `Fix now / Minimal realignment / Defer / No action / Fresh scaffold verification`으로 분류한다.

### Phase 2 — Minimal Realignment (R1 승인 후)

Fix-now와 R1 승인된 minimal realignment만 적용한다.

예상 후보:

- DR-014 archive tree의 historical `phase2/` example 정정.
- fallback prompt의 stale bootstrap wording 축소 또는 후속 Work 분리.
- `AGENT-WORKFLOW.md` Project Constants 위치 또는 pointer 정렬.
- Approval Matrix L3 description drift one-liner sync.
- `HARNESS-PROTOCOL.md` Approval Matrix State Detail 서브테이블 위임 또는 pointer-only 정렬.
- `HARNESS-PROTOCOL.md` Document Map/Load Map 중복은 대형 rewrite로 번지지 않는 범위에서만 pointer-only 수준으로 제한.

### Phase 3 — Closeout

1. verification 실행.
2. Work Done 처리.
3. STATUS Finalization / Tracking Finalization 보고.

## Done Criteria

- [x] workflow core layering principle이 기록된다.
- [x] 사용자 stale 후보 8개가 layering matrix로 분류된다.
- [x] 각 후보에 `Fix now / Minimal realignment / Defer as W3 slice / No action / Needs fresh scaffold verification` 판정이 있다.
- [x] 중복 제거가 `/session-start`, `/work-plan`, `/work-close`, commit/PR gate, scaffold bootstrap 행동 유도를 깨뜨리지 않는지 구체 검증 방법이 있다.
- [x] DR-014 archive trigger 반영 여부가 확인된다.
- [x] DR-027 scaffold seed inclusion 여부가 fresh source 또는 dry-run 기준으로 확인된다.
- [x] `AGENT-WORKFLOW.md`와 `HARNESS-PROTOCOL.md` 중복은 즉시 수정 여부와 후속 slice 여부가 분리된다.
- [x] Claude R0/R1/R2 review와 Codex disposition이 기록된다.

## Verification

Plan/audit verification:

```bash
git diff --check
rg -n "Project Constants|Context Routing|Document Map|Load Map|State Machine|Approval Matrix|Commit Message Format|Type prefix|phase2|New Project Initialization|DR-027" docs/AGENT-WORKFLOW.md docs/HARNESS-PROTOCOL.md docs/GIT-WORKFLOW.md docs/decisions/DR-014-archive-policy.md prompts/claude-session-start.md docs/retrospectives/README.md docs/troubleshooting/README.md tools/git-hooks scripts/create-harness.sh
```

Behavior preservation verification:

- `docs/AGENT-WORKFLOW.md` 변경 후, session-start entry contract에서 기본 로드되는 내용만으로 State Machine gate와 Approval Matrix L1/L2/L3 판단이 가능한지 hand-trace 1회 수행한다.
- `docs/HARNESS-PROTOCOL.md`로 상세를 위임하는 경우, `AGENT-WORKFLOW.md`에 "언제 protocol 상세를 로드해야 하는지"가 남아 있는지 확인한다.
- workflow skill/command surfaces가 protocol 상세를 조건부 로드해야 하는 경우, 해당 load point를 `rg`로 확인해 gate context가 사라지지 않았음을 기록한다.
- 승인/상태 변경/commit 전 gate 문구는 compact SSoT와 detail reference 중 어느 쪽을 따라야 하는지 Phase 1 matrix에 명시한다.

If scaffold stale is still suspected:

```bash
bash -n scripts/create-harness.sh
scripts/create-harness.sh --dry-run stale-audit-generic /private/tmp/awh-stale-audit-generic
scripts/create-harness.sh stale-audit-generic /private/tmp/awh-stale-audit-generic
```

## Phase 1 Audit Results

### Layering Principle

이번 Work의 기준 위계:

| Layer | Role | Boundary |
| --- | --- | --- |
| Entry points (`AGENTS.md`, `CLAUDE.md`) | tool별 session entry contract | 얇게 유지. 공통 실행 규칙은 `docs/AGENT-WORKFLOW.md`로 위임 |
| `docs/AGENT-WORKFLOW.md` | compact execution SSoT: startup load contract, State Machine, Approval Matrix, context routing, validation defaults | session-start 기본 로드만으로 plan/approval/state-change/commit gate 판단이 가능해야 함 |
| `docs/HARNESS-PROTOCOL.md` | conditional detailed reference: lifecycle detail, trigger/cascade, work file rules, state detail | `AGENT-WORKFLOW.md`와 정책이 다르면 안 됨. 상세는 pointer/detail로만 존재 |
| workflow skills/prompts | adapter/fallback execution surface | canonical 규칙을 재정의하지 않고, command unavailable 또는 tool-specific entry를 보완 |
| scaffold output | downstream target guidance | source policy를 그대로 확장하지 않고, generated target이 첫 세션에서 필요한 bootstrap guidance를 제공 |

Behavior preservation hand-trace:

1. Session start path는 `AGENTS.md`/`CLAUDE.md` -> `docs/BEHAVIOR-PRINCIPLES.md` -> `docs/AGENT-WORKFLOW.md` -> `docs/STATUS.md` current sections다.
2. `docs/AGENT-WORKFLOW.md`에는 State Machine(`INIT -> PLAN -> APPROVAL -> EXECUTE -> VALIDATE -> CHECKPOINT -> END`)과 Approval Matrix L1/L2/L3가 모두 존재하므로, protocol 전체를 읽지 않아도 실행 전 승인·상태 변경·commit 전 승인 판단이 가능해야 한다.
3. `docs/HARNESS-PROTOCOL.md`로 상세를 위임해도 `AGENT-WORKFLOW.md`의 gate summary는 제거하면 안 된다. protocol은 state detail, Work File Rules, trigger/cascade 같은 조건부 상세 역할로 제한한다.
4. workflow skill/command surfaces는 Approval Matrix를 직접 재정의하지 않고, state-change proposal과 validation/commit gate를 참조한다. 따라서 compact SSoT와 detail reference가 충돌하지 않도록 content sync가 우선이다.

### Candidate Matrix

| Candidate | Evidence | Layering Classification | Decision |
| --- | --- | --- | --- |
| `Project Constants` 위치 | `docs/AGENT-WORKFLOW.md:169-177`; generated README/BOOTSTRAP도 첫 세션에서 Project Constants 작성 지시 | Pointer-worthy detail / discoverability issue | **Minimal realignment candidate.** `AGENT-WORKFLOW.md` 앞단으로 이동하거나 Session Startup 근처에 pointer를 둔다. 행동 변경 없음 |
| `Context Routing` vs `Document Map` / `Load Map` | `docs/AGENT-WORKFLOW.md:34-56`; `docs/HARNESS-PROTOCOL.md:35-59`, `153-168`, `195-219` | Mixed: startup load SSoT + protocol document role catalogue + duplicated load map | **Minimal realignment / Defer split.** `AGENT-WORKFLOW.md` Context Routing은 유지. protocol Document Map은 역할 catalogue로 유지 가능. protocol Load Map은 중복성이 높으나 broad rewrite 위험이 있어 pointer-only 축소 후보로 제한 |
| State Machine / Approval Matrix | `docs/AGENT-WORKFLOW.md:69-105`; `docs/HARNESS-PROTOCOL.md:60-120`; L3 표현이 `아키텍처·인프라·DB schema·보안 구조` vs `구조 변경`으로 divergence | State Machine summary/detail split은 의도된 중복. Approval Matrix L3는 content drift | **Fix now + Minimal realignment.** L3 description은 `AGENT-WORKFLOW.md` 기준으로 sync. protocol State Detail table은 상세로 유지하되 independent policy가 아님을 pointer로 명시 |
| Commit type prefix docs vs hook | `docs/GIT-WORKFLOW.md:285-306`; `tools/git-hooks/commit-msg:5-8`, `20-27` | Runtime necessity with duplicated display text | **No action now.** hook은 runtime enforcement list가 필요하고 set은 일치한다. 필요 시 후속에서 docs order/hook message sync만 검토 |
| DR-014 `phase2/` archive tree | `docs/decisions/DR-014-archive-policy.md:17-29`; fresh scaffold에도 동일 stale `phase2/` 포함 | Stale duplication in shipped DR seed | **Fix now.** `phase2/` example을 `product/` 또는 `{category}/`로 정정 |
| DR-014 "protocol 반영 필요" consequence | `docs/decisions/DR-014-archive-policy.md:74-79`; protocol에는 Work lifecycle/archive trigger가 이미 존재(`docs/HARNESS-PROTOCOL.md:267-288`, `417-440`) | Stale consequence note | **Fix now.** "반영 필요"를 "반영됨" 또는 historical note로 정정 |
| `prompts/claude-session-start.md` New Project Initialization | `prompts/claude-session-start.md:121-154`; top principles already say bootstrap is STATUS-gated; section lists old command names and manual structure design | Stale fallback / scaffold overlap | **Fix now or narrow minimal realignment.** section을 "manual legacy fallback only; prefer `scripts/create-harness.sh`"로 축소하고 stale command list 제거 |
| DR-027 scaffold README concern | source `docs/retrospectives/README.md:10-26`, `docs/troubleshooting/README.md:11-32`; generator copies DR-027 seed and emits matching README sections(`scripts/create-harness.sh:431-432`, `481-505`, `1276-1304`); fresh scaffold confirms DR-027 file and README references | Fresh scaffold verification | **No action.** old `temp/awh-pp2` artifact likely stale. Current scaffold includes DR-027 and matching README specs |

### Minimal Patch Candidate Set

Phase 2에서 R1 승인 없이 바로 broad rewrite로 들어가면 안 된다. 현재 evidence 기준으로 작은 패치 후보만 아래로 제한한다.

| Candidate | Files | Proposed Action | Risk |
| --- | --- | --- | --- |
| Approval Matrix L3 sync | `docs/HARNESS-PROTOCOL.md` | L3 label/description을 `AGENT-WORKFLOW.md` 표현과 맞추고, State Detail이 detail table임을 명시 | Low |
| DR-014 archive stale | `docs/decisions/DR-014-archive-policy.md` | `phase2/` example 정정, protocol consequence stale note 정정 | Low |
| Claude fallback new project section | `prompts/claude-session-start.md` | Section 5를 scaffold-first/manual fallback wording으로 축소, stale command list 제거 | Low-Medium |
| Project Constants discoverability | `docs/AGENT-WORKFLOW.md` | Section move 또는 early pointer. 실제 gate 변경 없음 | Low |
| Protocol Load Map duplicate | `docs/HARNESS-PROTOCOL.md` | pointer-only 축소 가능성은 있으나 Document Map/Item Location까지 엮일 수 있어 이번 patch에서는 신중히 제한 | Medium |

R1 direction decisions:

- Section 5 replacement: **pointer-only (b)**. Fallback prompt가 scaffold 구조와 command list를 재구현하면 다시 drift source가 되므로, `scripts/create-harness.sh`와 README scaffold guide로 위임한다.
- Protocol Load Map: **defer as W3 slice**. `AGENT-WORKFLOW.md` Context Routing은 session startup decision table이고, `HARNESS-PROTOCOL.md` Document Map은 role catalogue다. `Load Map`은 중복성이 있으나 Document Map/Item Location과 함께 재설계될 위험이 있어 이번 Work에서는 건드리지 않는다.
- Approval Matrix State Detail pointer: **single-file patch in `docs/HARNESS-PROTOCOL.md`**. `AGENT-WORKFLOW.md`는 session-start compact SSoT로 유지하고, protocol §5에 detail reference 성격만 명시한다.

### Phase 1 Verification Notes

Executed:

```bash
rg -n "Project Constants|Context Routing|Document Map|Load Map|State Machine|Approval Matrix|Commit Message Format|Type prefix|phase2|New Project Initialization|DR-027" docs/AGENT-WORKFLOW.md docs/HARNESS-PROTOCOL.md docs/GIT-WORKFLOW.md docs/decisions/DR-014-archive-policy.md prompts/claude-session-start.md docs/retrospectives/README.md docs/troubleshooting/README.md tools/git-hooks scripts/create-harness.sh
bash -n scripts/create-harness.sh
scripts/create-harness.sh --dry-run stale-audit-generic /private/tmp/awh-stale-audit-generic-20260613-011-dry
scripts/create-harness.sh stale-audit-generic /private/tmp/awh-stale-audit-generic-20260613-011
rg -n "DR-027|Frontmatter 스펙|DR-014|phase2|Approval Matrix|L3 구조 변경|Project Constants|Document Map|Load Map|New Project Initialization" /private/tmp/awh-stale-audit-generic-20260613-011/docs /private/tmp/awh-stale-audit-generic-20260613-011/prompts /private/tmp/awh-stale-audit-generic-20260613-011/README.md
```

Result:

- `bash -n scripts/create-harness.sh`: PASS.
- fresh generic scaffold: PASS.
- DR-027: current scaffold includes `docs/decisions/DR-027-troubleshooting-retrospective-spec.md` and generated `docs/retrospectives/README.md` / `docs/troubleshooting/README.md` frontmatter specs. No source patch needed for DR-027.
- DR-014: stale `phase2/` remains in source and fresh scaffold because DR-014 is copied as seed. Source patch needed.
- STATUS consistency: `docs/works/harness/README.md` has CHORE-011 Active, but `docs/STATUS.md` Active Work is empty. This was intentional before R0 approval; now that Phase 1 is approved, STATUS Active pointer addition should be proposed before closeout or included with finalization if user approves.

## Phase 2 Implementation Results

Implemented minimal realignment only:

| File | Change | Reason |
| --- | --- | --- |
| `docs/HARNESS-PROTOCOL.md` | Approval Matrix L3 label synced to `아키텍처·인프라·DB schema·보안 구조`; added one sentence that protocol §5 is detail reference for `docs/AGENT-WORKFLOW.md` | Fix content drift while preserving session-start compact gate |
| `docs/decisions/DR-014-archive-policy.md` | `phase2/` archive tree example changed to `product/`; stale "protocol 반영 필요" consequence changed to current-state wording | Fix shipped DR seed stale text |
| `prompts/claude-session-start.md` | Section 5 changed to `New Project Initialization (Manual Fallback)` and pointer-only scaffold-first prompt | Remove stale command/file list and avoid duplicating scaffold generator behavior |
| `docs/works/harness/README.md` | Active Work index row added | Tracking inventory for active Work file |

Explicit non-changes:

- `docs/AGENT-WORKFLOW.md` Project Constants was not moved. It remains a low-risk discoverability candidate under the existing W3 backlog item `Canonical 개념 계층화 + context-routing restructure`; this Work prioritized verified policy/stale drift within appetite instead of moving sections.
- `docs/HARNESS-PROTOCOL.md` Document Map was kept. It is a role catalogue, not the same surface as `AGENT-WORKFLOW.md` Context Routing.
- `docs/HARNESS-PROTOCOL.md` Load Map was deferred to a W3 slice because pointer-only cleanup risks expanding into Item Location / Document Map restructuring.
- `docs/GIT-WORKFLOW.md` and `tools/git-hooks/commit-msg` were not changed. Commit type duplication is runtime necessity; current type set matches.
- DR-027 scaffold README concern was closed as no-action after fresh scaffold verification.

### Phase 2 Verification Notes

Executed:

```bash
git diff --check
bash -n scripts/create-harness.sh
scripts/create-harness.sh --dry-run phase2-verify /private/tmp/awh-phase2-verify-20260613-dry
scripts/create-harness.sh phase2-verify /private/tmp/awh-phase2-verify-20260613
rg -n -F "phase2" docs/decisions/DR-014-archive-policy.md /private/tmp/awh-phase2-verify-20260613/docs/decisions/DR-014-archive-policy.md
rg -n -F "반영 필요" docs/decisions/DR-014-archive-policy.md /private/tmp/awh-phase2-verify-20260613/docs/decisions/DR-014-archive-policy.md
rg -n -F "L3 구조 변경" docs/HARNESS-PROTOCOL.md /private/tmp/awh-phase2-verify-20260613/docs/HARNESS-PROTOCOL.md
rg -n -F ".claude/commands/ (start, pick, work, resume, debug, close, done" prompts/claude-session-start.md /private/tmp/awh-phase2-verify-20260613/prompts/claude-session-start.md
bash scripts/tests/check-shipped-dr-closure.sh
```

Result:

- `git diff --check`: PASS.
- `bash -n scripts/create-harness.sh`: PASS.
- fresh scaffold dry-run and actual creation: PASS.
- stale phrase checks for `phase2`, `반영 필요`, `L3 구조 변경`, old command-list text: 0 matches in source + fresh scaffold targets.
- `check-shipped-dr-closure.sh`: PASS.

R2 hold resolution:

- R2-F1: Project Constants non-change reason corrected to "appetite priority defer; keep under existing W3 `Canonical 개념 계층화 + context-routing restructure` candidate." No new backlog row is needed because that candidate already names `project constants`.
- R2-F2: Phase 2 Verification Notes are present above and explicitly include `git diff --check`: PASS plus source/fresh-scaffold stale phrase checks.
- R2-F3: `docs/HARNESS-PROTOCOL.md` pointer sentence separated from the next paragraph with a blank line.
- R2-F4: DR-014 `Linked Backlog Items: HRF-002 (Active)` is noted as out-of-scope informational cleanup candidate; no patch in this Work.

## Risk / Reversal Cost

| Item | Assessment |
| --- | --- |
| Risk level | L2 — workflow/protocol/fallback/scaffold surfaces may be touched |
| Reversal cost | Low for audit-only or DR-014 wording. Medium if map/state/approval structure moves |
| Main risk | layering 정비가 W3 broad restructure로 번지거나, 반대로 audit-only로 축소되어 사용자의 구조 정비 의도를 놓치는 것 |
| Control | Layering principle 먼저 작성, Fix-now / Minimal realignment / Defer / No-action matrix, R0 before implementation, workflow behavior preservation check |

## Open Questions

| ID | Question | Default Assumption |
| --- | --- | --- |
| OQ-1 | `Project Constants`는 앞단으로 이동해야 하는가? | Audit first. If only discovery load improves, pointer/short move may be enough |
| OQ-2 | `HARNESS-PROTOCOL.md` §3 Document Map과 §7 Load Map은 둘 다 필요한가? | Likely duplicate. Role split이 없으면 minimal realignment 또는 W3 slice |
| OQ-3 | State Machine / Approval Matrix 중복은 의도된 요약/상세인가? | 요약/상세 split으로 가정하되, content divergence가 발견되면 drift로 우선 판정한다 |
| OQ-4 | `commit-msg` hook type list는 policy duplication인가 runtime necessity인가? | Runtime necessity 가능성이 높음. docs should point to hook enforcement, not vice versa |
| OQ-5 | `claude-session-start.md` New Project Initialization은 fallback으로 유효한가? | Likely too heavy. But fallback prompt cascade가 있으므로 immediate edit는 R1 decision |
| OQ-6 | DR-027 scaffold README issue는 live source 문제인가 stale temp artifact인가? | Current script includes DR-027; fresh dry-run으로 no-action 가능성 높음 |

## Approval / State

| Item | Status |
| --- | --- |
| 위험도 | L2 |
| 실행 모드 | Standard Work |
| Branch Isolation | PASS — `feature/chore-20260612-011-workflow-core-stale-audit` |
| Tool rule reference | `.claude/rules/docs-workflow.md`, `.claude/rules/git-workflow.md`, DR-007 applies |
| STATUS proposal | R0 합의 전 `docs/STATUS.md` 변경 없음 |
| State machine | APPROVAL → EXECUTE. R0 findings reflected and user approved Phase 1 audit; STATUS pointer remains proposal-only |

## Claude R0 Review Request

Claude R0 plan review 요청: CHORE-20260612-011 Workflow Core Layering Audit + Minimal Realignment

Review focus:

1. 이 Work가 사용자의 의도(상위→하위 문서 위계 정비)를 충분히 반영하는가?
2. workflow behavior preservation guard가 충분한가?
3. Scope가 너무 audit-only로 축소되지 않았는가, 또는 broad restructure로 열려 있지 않은가?
4. 사용자 stale 후보가 누락 없이 포함됐는가?
5. Fix-now / Minimal realignment / Defer / No-action 분류 기준이 충분한가?
6. `AGENT-WORKFLOW.md` / `HARNESS-PROTOCOL.md` 중복을 layering principle로 먼저 판정하는 접근이 맞는가?

Please respond in this format:

```text
Approval: Approved | Conditional Hold | Hold

Findings
- F1 (Must-fix/Nice-to-have): ...

Review Questions
| Question | Answer |
| --- | --- |
| Captures user intent? | ... |
| Preserves workflow behavior? | ... |
| Scope balanced? | ... |
| Stale candidates complete? | ... |
| Classification criteria sufficient? | ... |

Round Log Entry
| Round | Reviewer | Status | Summary | Follow-Up |
| --- | --- | --- | --- | --- |
| R0 | Claude | ... | ... | ... |
```

## Cross-Agent Review And Discussion

### Round Log

| Round | Reviewer | Status | Summary | Follow-Up |
| --- | --- | --- | --- | --- |
| R0 | Claude | Conditional Hold | Must-fix 2개: F1(Approval Matrix L3 divergence가 Plan에 없어 Phase 1에서 Defer로 bias될 위험), F2(behavior preservation 검증 방법 미정의). Nice-to-have 2개: F3(sync-first 경로 명시), F4(OQ-3 default 보정). User Intent 포착과 layering principle 접근은 방향이 맞다. | F1/F2/F3/F4 반영 후 Phase 1 진입 가능 |
| R1 (Phase 1 audit) | Claude | Approved | Layering Principle 5-layer + hand-trace 견고. Candidate Matrix 8건 판정 전반 타당. Fix now 4종·Minimal realignment 2종 적절히 제한. Document Map은 No action, Load Map은 W3 Defer 권장. | F1: Section 5 교체 내용을 pointer-only로 확정. F2: Load Map defer 사유 기록. F3: State Detail pointer는 `docs/HARNESS-PROTOCOL.md` 단일 파일 patch로 확정. |
| R2 (Phase 2 result) | Claude | Conditional Hold | 핵심 3종 구현(L3 sync, DR-014 2건, Section 5 pointer-only)은 정확하고 stale wording 제거 확인됨. Must-fix 2개는 구현 문제가 아니라 Work 파일 기록 문제(F1 Project Constants 미실시 사유, F2 Phase 2 verification closeout-visible 기록). | F1/F2/F3 반영 후 closeout 가능. F4는 별도 cleanup 후보로 보류. |

### Finding Disposition

| Finding | Codex Disposition | Rationale / Action |
| --- | --- | --- |
| R0-F1 | Accepted | Approval Matrix L3 문구 차이는 단순 중복이 아니라 policy drift다. Initial Fact Check, Phase 1 criterion, Phase 2 예상 후보에 content drift / L3 sync / State Detail pointer 후보를 추가했다. |
| R0-F2 | Accepted | 기존 verification은 파일/스크립트 무결성 중심이었다. session-start load path에서 State Machine / Approval Matrix 판단이 가능한지 hand-trace와 load-point 확인을 추가했다. |
| R0-F3 | Accepted | `Content sync`를 Minimal realignment 하위 케이스로 추가해 drift가 무조건 Defer로 밀리지 않게 했다. |
| R0-F4 | Accepted | OQ-3 default를 "요약/상세 split으로 가정하되 divergence 발견 시 drift 우선"으로 보정했다. |
| R0 Challenge | Accepted | 이전 예상 후보가 peripheral 항목에 치우친 점이 맞다. Approval Matrix divergence를 core layering 후보로 올려 사용자 의도와 맞췄다. |
| R1-F1 | Accepted | Section 5는 pointer-only 방향으로 확정했다. fallback prompt가 command list와 scaffold file map을 재나열하지 않고 `scripts/create-harness.sh`와 README scaffold guide로 위임하게 한다. |
| R1-F2 | Accepted | `Context Routing`은 startup decision table, `Document Map`은 role catalogue로 판정했다. `Load Map`은 중복성이 있으나 broad rewrite 위험이 있어 W3 slice로 분리한다고 기록했다. |
| R1-F3 | Accepted | State Detail pointer는 `docs/HARNESS-PROTOCOL.md` §5에만 추가한다. `AGENT-WORKFLOW.md` compact gate는 유지해 session-start 기본 로드 판단을 보존한다. |
| R2-F1 | Accepted | Project Constants 미실시 사유를 appetite 내 우선순위 조정으로 정정했다. 기존 W3 backlog item `Canonical 개념 계층화 + context-routing restructure`가 `project constants`를 이미 포함하므로 신규 backlog row는 만들지 않는다. |
| R2-F2 | Accepted / Clarified | Phase 2 Verification Notes는 이미 존재했지만, R2 hold 해소 항목에 다시 연결했다. `git diff --check`: PASS와 stale phrase 0건 확인을 closeout-visible evidence로 유지한다. |
| R2-F3 | Accepted | `docs/HARNESS-PROTOCOL.md` pointer sentence 뒤 blank line을 추가했다. |
| R2-F4 | Deferred | DR-014의 `Linked Backlog Items: HRF-002 (Active)`는 이번 Work 책임 밖이다. legacy ID cleanup 후보로만 남기고 본 패치에는 포함하지 않는다. |

## Discovery

- 2026-06-12: PR #163 merge 후 `develop...origin/develop` clean 확인. 다음 Work ID는 `CHORE-20260612-011`.
- 2026-06-12: 사용자 stale 후보를 read-only로 예비 확인. DR-014 `phase2/`는 stale 가능성이 높고, archive trigger와 DR-027 scaffold seed는 이미 반영됐을 가능성이 높음.
- 2026-06-12: 사용자 의도 재확인. 원하는 것은 stale list 처리가 아니라 상위→하위 문서 위계 정비와 workflow 보존의 균형임. Work 제목과 scope를 `Workflow Core Layering Audit + Minimal Realignment`로 수정.
- 2026-06-13: Phase 1 audit 완료. Approval Matrix L3는 content drift, DR-014 `phase2/`와 consequence note는 stale, `claude-session-start.md` New Project Initialization은 scaffold-first 원칙과 겹치는 stale fallback으로 판정. DR-027 scaffold README concern은 fresh scaffold 기준 no-action.
- 2026-06-13: Claude R1 승인 반영. Section 5는 pointer-only 교체, Protocol Load Map은 W3 Defer, State Detail pointer는 `docs/HARNESS-PROTOCOL.md` 단일 파일 patch로 확정.
- 2026-06-13: Phase 2 minimal realignment 구현 완료. `docs/HARNESS-PROTOCOL.md`, `docs/decisions/DR-014-archive-policy.md`, `prompts/claude-session-start.md`만 실질 패치. Project Constants 이동은 appetite 내 우선순위 조정으로 미실시하고 existing W3 `Canonical 개념 계층화 + context-routing restructure` 후보로 유지. Protocol Load Map 정리는 Medium-risk W3 slice로 미실시.
- 2026-06-13: Claude R2 Conditional Hold 반영. Phase 2 verification evidence 재확인, Project Constants defer 사유 정정, protocol pointer blank line 보정.
- 2026-06-13: `/work-close` 처리. Done Criteria 전부 충족 확인, `status: Done`, `actual_end: 2026-06-13` 기입. `docs/STATUS.md` Active Work는 이미 비어 있어 제거할 pointer 없음. Archive는 보류.
