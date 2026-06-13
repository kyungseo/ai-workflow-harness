---
id: CHORE-20260613-002
priority: P1
status: Done
risk: L2
scope: Protocol Load Map / Context Routing 중복 최소 정리. `docs/AGENT-WORKFLOW.md`의 Context Routing / Project Constants와 `docs/HARNESS-PROTOCOL.md`의 Document Map / Load Map 역할 경계를 감사하고, workflow 보존 가능한 최소 realignment만 R0 이후 수행한다.
appetite: 0.5d
planned_start: 2026-06-13
planned_end: 2026-06-13
actual_end: 2026-06-13
related_dr: [DR-007, DR-021, DR-023]
related_work: [CHORE-20260612-007, CHORE-20260612-008, CHORE-20260612-009, CHORE-20260612-011, CHORE-20260613-001]
---

# CHORE-20260613-002: Protocol Load Map / Context Routing Minimal Realignment

## Top Summary

- **목표:** `docs/AGENT-WORKFLOW.md`의 startup-oriented Context Routing과 `docs/HARNESS-PROTOCOL.md`의 detailed reference Load Map이 같은 역할을 반복하는지 확인하고, SSoT / summary / detail reference 경계를 깨지 않는 최소 정리만 수행한다.
- **왜 지금:** CHORE-20260612-011은 workflow core layering drift를 정리했고, CHORE-20260613-001은 prompt live surface를 축소했다. 다음 W3 후보 중 `Load Map` / `Context Routing` 접점은 이전 흐름과 가장 자연스럽지만, broad restructure로 번질 위험이 있어 이번 Work는 하나의 작은 slice로 제한한다.
- **핵심 경계:** 잘 작동하는 `/session-start`, `/work-plan`, `/work-close`, commit/PR gate, scaffold bootstrap 유도는 유지한다. 중복 제거 명분으로 operational detail을 삭제하지 않는다.
- **역할:** Codex = author/driver, Claude = red team reviewer.

## Candidate Comparison

1. **Protocol Load Map / Context Routing 중복 최소 정리**는 CHORE-20260612-011의 남은 후속이고, W3 구조 정리에 가장 직접 닿는다.
2. **Project Constants discoverability**는 작고 안전하지만 단독으로 닫으면 구조 정리 효과가 좁다. 이번 Work 안에서는 Context Routing audit의 하위 판단으로만 다룬다.
3. **Harness protocol trigger family simplification**은 중요하지만 `docs/HARNESS-PROTOCOL.md` trigger 전체 재그룹화로 커질 위험이 커서 이번 세션 첫 항목으로 부적절하다.
4. **repo-health / work-doc slice-class 검토**는 의미 있지만 CHORE-20260613-001 직후 흐름보다 한 단계 옆에 있다.
5. archive pending 정리는 tracking hygiene이며, 사용자가 명시하지 않았으므로 이번 범위에서 제외한다.

## Scope / Non-Goals

### Scope

1. `docs/AGENT-WORKFLOW.md`의 `Context Routing`, `Trigger And Naming Pointers`, `Project Constants`, `Verification Defaults`가 어떤 질문에 답하는지 확인한다.
2. `docs/HARNESS-PROTOCOL.md`의 `Document Map`, `Load Map`, trigger/cascade pointer가 어떤 상세 판단에 필요한지 확인한다.
   - `docs/HARNESS-PROTOCOL.md` §7.2 `Operating Tracks`는 read-only boundary observation만 허용하고, 이번 Work의 수정 대상으로 확장하지 않는다.
3. 두 문서 사이의 항목을 아래로 분류한다.
   - **SSoT:** 하나의 문서에만 남겨야 하는 정책 원문.
   - **Summary:** entry/startup에 필요한 짧은 요약.
   - **Detail Reference:** 조건부로 로드하는 상세 판단 자료.
   - **Stale Duplication:** 같은 목적과 같은 정보를 반복해 drift 위험만 만드는 항목.
4. R0 승인 후에도 변경은 다음 중 하나로 제한한다.
   - `docs/HARNESS-PROTOCOL.md` Load Map을 `AGENT-WORKFLOW.md` Context Routing의 detailed-reference pointer로 축소.
   - `docs/AGENT-WORKFLOW.md` Project Constants discoverability를 한두 줄 pointer 또는 위치 조정으로 보강.
   - 두 문서의 역할 설명 문장 추가 또는 stale phrase 제거.
5. Work 파일에 Claude R0/R1 review와 Codex disposition을 누적한다.

### Non-Goals

- `docs/HARNESS-PROTOCOL.md` trigger family simplification 전체 재작성.
- State Machine 또는 Approval Matrix 의미 변경.
- README / MANUAL / GUIDE readability rewrite.
- scaffold output 변경.
- prompts archive, docs archive pending, Work archive 정책 정리.
- `Operating Tracks` 정의 중복 해소. `AGENT-WORKFLOW.md`와 `HARNESS-PROTOCOL.md` 양쪽에 존재하는 것은 Phase 1에서 발견해도 이번 Work의 수정 대상으로 확장하지 않고, 필요 시 후속 W3 후보로만 기록한다.
- `skills/workflow/repo-health.md` slice 분리 또는 `skills/workflow/work-doc.md` class 이동.
- source repo 정책을 scaffold target 기본값으로 확장.

## Files

### Plan / Tracking

| File | Plan |
| --- | --- |
| `docs/works/harness/CHORE-20260613-002-protocol-load-map-routing.md` | Work SSoT |
| `docs/works/harness/README.md` | Active Work index row only |

### Expected Audit / Implementation Surfaces

| File | Plan |
| --- | --- |
| `docs/AGENT-WORKFLOW.md` | Context Routing / Project Constants role audit. R0 이후 승인된 최소 pointer 또는 prose 정리만 가능 |
| `docs/HARNESS-PROTOCOL.md` | Document Map / Load Map role audit. R0 이후 승인된 최소 Load Map 축소 또는 pointer 정리만 가능 |
| `docs/HARNESS-QUICK-REFERENCE.md` | 변경 후 user-facing quick route가 stale해지는지 read-only 확인 |
| `skills/workflow/*.md`, `.agents/skills/*/SKILL.md` | workflow가 protocol detail을 조건부 로드하는 위치가 사라지지 않는지 grep 확인 |

## Plan

### Phase 0 — R0 Review Package

1. Work file과 Work index Active row만 생성한다.
2. `docs/STATUS.md` Active pointer는 R0 합의 전 변경하지 않는다.
3. Claude R0 plan review를 요청한다.
4. R0 findings 반영 전 `docs/AGENT-WORKFLOW.md` / `docs/HARNESS-PROTOCOL.md` 구현 변경은 하지 않는다.

### Phase 1 — Role Matrix Audit

1. `AGENT-WORKFLOW.md`와 `HARNESS-PROTOCOL.md`의 관련 섹션을 line-based로 재확인한다.
2. 각 row/section을 `SSoT / Summary / Detail Reference / Stale Duplication`으로 분류한다.
3. Project Constants는 "startup 판단에 필요한가"와 "하단에 있어도 discoverable한가"를 따로 판정한다.
4. `HARNESS-PROTOCOL.md` Load Map은 `AGENT-WORKFLOW.md` Context Routing을 복제하는지, 아니면 protocol 내부 detailed reference로 독립 가치가 있는지 판정한다.
5. `Operating Tracks` 중복은 이 Work에서 수정하지 않는다. Phase 1 중 발견되면 "out-of-scope duplicate / follow-up candidate"로만 기록한다.
6. broad rewrite 위험이 감지되면 implementation을 중단하고 후속 Work 후보로 분리한다.

### Phase 2 — Minimal Realignment Only

R0 승인 및 Phase 1 audit 결과가 모두 충족될 때만 아래 중 필요한 최소 변경을 수행한다.

1. `docs/HARNESS-PROTOCOL.md` Load Map이 단순 복제면 table을 새 compact table로 줄이지 않는다. output form은 `AGENT-WORKFLOW.md` `Context Routing`을 참조하는 1줄 pointer로 교체하는 방식만 허용한다.
2. `docs/AGENT-WORKFLOW.md` Project Constants가 실제 discoverability gap이면 startup/read path에 영향을 주지 않는 최소 pointer 또는 위치 조정을 적용한다.
3. 중복이 의도된 summary/detail split이면 삭제하지 않고 역할 문장만 선명하게 한다.
4. 변경이 trigger family simplification으로 커지면 이 Work에서 제외하고 후속 후보로 남긴다.

### Phase 3 — Review / Closeout Prep

1. 검증 명령을 실행한다.
2. Claude R1 result review를 요청한다.
3. 승인되면 `/work-close`로 Done 처리하고, 그때 STATUS / Tracking finalization을 별도로 보고한다.

## Done Criteria

- [x] `Context Routing`, `Document Map`, `Load Map`, `Project Constants`의 역할이 matrix로 분류된다.
- [x] `SSoT / Summary / Detail Reference / Stale Duplication` 경계가 Work 파일에 기록된다.
- [x] `Operating Tracks` 중복은 이번 Work의 수정 대상이 아님을 audit 결과 또는 Non-goals에서 유지한다.
- [x] 중복 제거가 workflow 행동 유도를 깨뜨리지 않는다는 hand-trace가 기록된다.
- [x] hand-trace 각 path에 pass criterion이 1줄씩 기록된다.
- [x] R0 승인 전 구현 변경이 없다.
- [x] R0 이후 변경이 있다면 `docs/AGENT-WORKFLOW.md`와 `docs/HARNESS-PROTOCOL.md` 중 승인된 최소 범위에 한정된다.
- [x] `docs/STATUS.md` Active pointer는 별도 state-change approval 전까지 변경하지 않는다.
- [x] Claude R0/R1 review와 Codex disposition이 누적된다.

## Verification

Plan / audit verification:

```bash
git diff --check
rg -n "Context Routing|Document Map|Load Map|Project Constants|Trigger And Naming Pointers|Verification Defaults|HARNESS-PROTOCOL|AGENT-WORKFLOW" docs/AGENT-WORKFLOW.md docs/HARNESS-PROTOCOL.md docs/HARNESS-QUICK-REFERENCE.md skills/workflow .agents/skills
```

Behavior preservation hand-trace:

- Session startup: `AGENTS.md` -> `docs/BEHAVIOR-PRINCIPLES.md` -> `docs/AGENT-WORKFLOW.md` -> `docs/STATUS.md`만으로 현재 상태와 승인 gate 판단이 가능한지 확인한다.
  - **Pass:** `docs/HARNESS-PROTOCOL.md`를 먼저 읽지 않아도 Active Work 여부, L2 approval gate, STATUS 변경 금지 조건을 판단할 수 있다.
- Work planning: `/work-plan`이 naming / branch / protocol detail을 필요한 조건에서만 로드하는지 확인한다.
  - **Pass:** Work ID/branch/protocol detail은 조건부 문서 로드로 도달 가능하고, startup 기본 로드에 상세 checklist가 새로 복제되지 않는다.
- Closeout: `/work-close`와 commit/PR finalization에서 STATUS / Tracking finalization pointer가 사라지지 않았는지 확인한다.
  - **Pass:** STATUS Finalization / Tracking Finalization / commit approval pointer가 `AGENT-WORKFLOW.md` 또는 workflow canonical surface에서 계속 발견된다.
- Protocol detail: trigger/cascade 판단이 필요할 때 `docs/HARNESS-PROTOCOL.md`를 로드해야 한다는 pointer가 남아 있는지 확인한다.
  - **Pass:** document/workflow/scaffold/status surface 변경 시 `HARNESS-PROTOCOL.md` trigger/cascade section을 조건부 로드하는 pointer가 유지된다.

Optional if implementation touches scaffold-adjacent wording:

```bash
bash -n scripts/create-harness.sh
```

## Risk / Reversal Cost

| Item | Assessment |
| --- | --- |
| Risk level | L2 — harness/workflow canonical/protocol surface |
| Reversal cost | Low to Medium. 문서 변경은 되돌리기 쉽지만 load contract를 잘못 줄이면 agent 행동이 달라질 수 있음 |
| Main risk | `HARNESS-PROTOCOL.md`의 상세 load map을 줄이다가 failure/recovery/trigger 판단 경로가 흐려지는 것 |
| Control | R0 review 전 구현 금지, matrix 기반 판정, hand-trace, grep validation |

## Open Questions

| ID | Question | Default Assumption |
| --- | --- | --- |
| OQ-1 | `HARNESS-PROTOCOL.md` Load Map은 독립 상세 reference인가, `AGENT-WORKFLOW.md` Context Routing의 stale duplicate인가? | 일부 중복 가능성이 크지만, 삭제보다 pointer 축소를 우선 검토 |
| OQ-2 | Project Constants는 앞단 이동이 필요한가, 아니면 pointer만으로 충분한가? | pointer 또는 role sentence가 우선. 단순 위치 이동은 R0가 요구할 때만 |
| OQ-3 | `Document Map`도 이번 Work에서 줄일 것인가? | 기본값은 No. Document Map은 protocol 내부 catalogue일 수 있어 Load Map보다 위험함 |
| OQ-4 | trigger family simplification을 함께 할 것인가? | No. 별도 W3 Work로 유지 |
| OQ-5 | PLAN 또는 PLAN-SUMMARY 변경이 필요한가? | 기본값은 No. 방향 변경이 아니라 W3 slice 실행 |
| OQ-6 | `Operating Tracks` 중복도 이번 Work에서 해소할 것인가? | No. read-only observation만 허용하고 수정은 후속 후보로 분리 |

## Phase 1 Audit Results

### Role Matrix

| Surface | Evidence | Classification | Decision |
| --- | --- | --- | --- |
| `AGENT-WORKFLOW.md` `Context Routing` | L34-L57. Startup 기본 load contract와 conditional load rules를 보유 | **SSoT / Summary** | 유지. session startup에서 필요한 compact load contract다 |
| `AGENT-WORKFLOW.md` `Operating Tracks` | L59-L67. Product/Harness track 정의 | **Out-of-scope duplicate** | `HARNESS-PROTOCOL.md` §7.2와 실질 중복이나 이번 Work에서 수정하지 않음. 후속 W3 후보로만 기록 |
| `AGENT-WORKFLOW.md` `Trigger And Naming Pointers` | L158-L167. DR-007, protocol trigger/cascade, naming pointer | **Summary / Detail Reference pointer** | 유지. protocol 상세를 조건부 로드하게 하는 핵심 pointer다 |
| `AGENT-WORKFLOW.md` `Project Constants` | L169-L176. runtime/build/architecture/static state info | **Summary / Discoverability issue** | policy duplication은 아님. 최소 pointer 후보만 허용하고, 별도 Work 분리는 불필요 |
| `HARNESS-PROTOCOL.md` `Document Map` | L35-L58. 문서별 역할 catalogue | **Detail Reference** | 유지. load instruction이 아니라 protocol 내부 document catalogue로 역할이 다름 |
| `HARNESS-PROTOCOL.md` `Context Loading` intro | L141-L144. STATUS first, conditional load 원칙 | **Detail Reference summary** | 유지. protocol 내부 §7의 framing으로 충분히 짧음 |
| `HARNESS-PROTOCOL.md` `Operating Tracks` | L146-L153. Product/Harness track 정의 | **Out-of-scope duplicate** | 수정하지 않음. 이번 Work는 Load Map / Context Routing slice로 제한 |
| `HARNESS-PROTOCOL.md` `Load Map` | L155-L169. 10-row table | **Stale Duplication candidate** | Phase 2 최소 변경 후보. 새 compact table 금지. `AGENT-WORKFLOW.md` `Context Routing` pointer 1줄로 교체하는 방식만 허용 |
| `HARNESS-PROTOCOL.md` `Triggers and Cascade` | L419-L496. trigger summary, loop safety, cascade matrix | **Detail Reference** | 유지. `AGENT-WORKFLOW.md`에서 조건부 로드 pointer가 있어야 하는 상세 판단 자료 |

### Hand-Trace

| Path | Evidence | Pass Criterion | Result |
| --- | --- | --- | --- |
| Session startup | `AGENT-WORKFLOW.md` L13-L23, L82-L91, L127-L162 | `HARNESS-PROTOCOL.md`를 먼저 읽지 않아도 Active Work 여부, L2 approval gate, STATUS 변경 금지 조건을 판단할 수 있다 | PASS |
| Work planning | `AGENT-WORKFLOW.md` L42, `skills/workflow/work-plan.md`이 naming/protocol detail을 조건부 로드 | Work ID/branch/protocol detail은 조건부 문서 로드로 도달 가능하고, startup 기본 로드에 상세 checklist가 새로 복제되지 않는다 | PASS |
| Closeout / commit gate | `AGENT-WORKFLOW.md` L145-L152, `docs/HARNESS-QUICK-REFERENCE.md` STATUS/Tracking Finalization, `skills/workflow/work-close.md` finalization pointer | STATUS Finalization / Tracking Finalization / commit approval pointer가 계속 발견된다 | PASS |
| Protocol detail lookup | `AGENT-WORKFLOW.md` L160-L162, `HARNESS-PROTOCOL.md` L419-L496 | document/workflow/scaffold/status surface 변경 시 protocol trigger/cascade section을 조건부 로드하는 pointer가 유지된다 | PASS |

### Minimal Patch Candidate Set

| Candidate | File | Proposed Action | Rationale | Risk |
| --- | --- | --- | --- | --- |
| Protocol Load Map duplicate | `docs/HARNESS-PROTOCOL.md` | §7.3 `Load Map` 10-row table을 `docs/AGENT-WORKFLOW.md` `Context Routing`으로 위임하는 1줄 pointer로 교체. 새 compact table은 만들지 않음 | 현재 table은 startup load map을 다시 들고 있고, 조건부 load nuance가 `AGENT-WORKFLOW.md`보다 약함 | Low-Medium |
| Project Constants discoverability | `docs/AGENT-WORKFLOW.md` | `Context Routing` 직후 또는 `Session Startup` 근처에 "runtime/build assumptions are summarized in Project Constants below" 수준의 1줄 pointer만 검토. 섹션 이동은 하지 않음 | static info는 duplication이 아니지만 하단 고립으로 발견성이 낮을 수 있음 | Low |

### Phase 2 Codex Disposition

- **F1 disposition:** `Operating Tracks` 중복은 실제로 확인됐다. 하지만 R0 반영대로 이번 Work에서는 수정하지 않는다. Scope 확장 없이 follow-up candidate로만 남긴다.
- **F2 disposition:** `HARNESS-PROTOCOL.md` Load Map 변경을 한다면 output form은 pointer 1줄뿐이다. compact summary table은 drift surface를 새로 만들기 때문에 금지한다.
- **F3 disposition:** hand-trace별 pass criterion을 추가했고 Phase 1 audit에 PASS/FAIL 기준을 기록했다.
- **Phase 2 entry condition:** 사용자 또는 reviewer가 위 Minimal Patch Candidate Set을 승인해야 한다. 승인 전 `docs/AGENT-WORKFLOW.md` / `docs/HARNESS-PROTOCOL.md` 구현 변경은 금지한다.

### Phase 2 Result

| File | Change | Boundary Check |
| --- | --- | --- |
| `docs/AGENT-WORKFLOW.md` | `Context Routing` 아래에 Project Constants 위치를 알리는 1줄 pointer 추가 | section 이동 없음. load table 의미 변경 없음 |
| `docs/HARNESS-PROTOCOL.md` | §7.3 `Load Map` 10-row table을 `AGENT-WORKFLOW.md` `Context Routing` pointer 문장으로 교체 | 새 compact table 생성 없음. `Operating Tracks`, `Document Map`, trigger/cascade section 미변경 |

### Validation Results

| Check | Result | Notes |
| --- | --- | --- |
| `git diff --check` | PASS | whitespace error 없음 |
| planned `rg` audit | PASS | `AGENT-WORKFLOW.md` Context Routing / Project Constants pointer, `HARNESS-PROTOCOL.md` Load Map pointer, trigger/cascade detail reference 유지 확인 |
| Session startup hand-trace | PASS | `AGENT-WORKFLOW.md`만으로 L2 approval gate와 STATUS 변경 금지 조건 확인 가능 |
| Work planning hand-trace | PASS | Work ID/naming/protocol detail은 `work-plan.md` 조건부 load pointer로 도달 가능 |
| Closeout / commit gate hand-trace | PASS | STATUS Finalization / Tracking Finalization pointer 유지 |
| Protocol detail hand-trace | PASS | `AGENT-WORKFLOW.md` Trigger And Naming Pointers가 `HARNESS-PROTOCOL.md` trigger/cascade 조건부 로드를 유지 |

## Approval / State

| Item | Status |
| --- | --- |
| 위험도 | L2 |
| 실행 모드 | Standard Work |
| Branch Isolation | PASS — `feature/chore-20260613-002-protocol-load-map-routing` |
| Tool rule reference | `.claude/rules/docs-workflow.md` 적용. DR-007 확인 완료 |
| Retrospective reference | `docs/retrospectives/harness-workflow-strictness-20260606.md` 확인 — source repo branch/workflow strictness는 유지 |
| PLAN 영향 | 없음. W3 backlog slice 실행이며 roadmap 방향 변경 아님 |
| STATUS proposal | R0 합의 전 `docs/STATUS.md` 변경 없음. R0 승인 후 `CHORE-20260613-002` Active pointer 추가 제안 예정 |
| State machine | CHECKPOINT. R1 승인 후 Work Done 처리 완료 |

## Cross-Agent Review And Discussion

### Round Log Structure

| Round | Reviewer | Type | Findings | Codex Disposition | Status |
| --- | --- | --- | --- | --- | --- |
| R0 | Claude | Plan Review | Conditional Hold. F1: `Operating Tracks` 중복을 scope 포함 또는 Non-goals 차단으로 결정 필요. F2: Load Map 축소 output form을 pointer 1줄 vs compact table 중 명시 필요. F3: hand-trace pass criterion 추가 권장 | F1은 Non-goals 차단으로 처리. F2는 "Load Map table -> AGENT-WORKFLOW Context Routing pointer 1줄"만 허용하도록 Phase 2를 고정. F3은 각 hand-trace path에 pass criterion 1줄씩 추가 | Addressed |
| R1 | Claude | Result Review | 승인 | Phase 2 result review 승인으로 확인. `/work-close` 진행 | Approved |

### Claude R0 Review Request

Claude R0 plan review 요청: CHORE-20260613-002 Protocol Load Map / Context Routing Minimal Realignment

Review focus:

1. Scope가 `Load Map` / `Context Routing` 최소 realignment로 충분히 좁은가?
2. Project Constants discoverability를 이 Work 하위로 다루는 것이 맞는가, 아니면 별도 Work로 분리해야 하는가?
3. `HARNESS-PROTOCOL.md` Load Map 축소가 trigger/recovery/detail lookup을 흐리게 만들 위험은 무엇인가?
4. Non-goals가 trigger family simplification, README/MANUAL rewrite, archive pending cleanup을 충분히 차단하는가?
5. Verification과 hand-trace가 "잘 작동하는 workflow를 망치지 않음"을 검증하기에 충분한가?

### Claude R1 Review Request

Claude R1 result review 요청: CHORE-20260613-002 Protocol Load Map / Context Routing Minimal Realignment

Review focus:

1. `docs/HARNESS-PROTOCOL.md` §7.3 `Load Map`이 새 compact table 없이 `AGENT-WORKFLOW.md` `Context Routing` pointer 1줄로 정리됐는가?
2. `docs/AGENT-WORKFLOW.md` Project Constants 보강이 discoverability pointer에 그치고, section 이동/정책 변경으로 확장되지 않았는가?
3. `Operating Tracks`, `Document Map`, trigger/cascade section이 이번 Work scope 밖으로 유지됐는가?
4. Validation Results와 hand-trace가 R0 F3의 pass criterion 요구를 충족하는가?
5. R1 승인 시 `/work-close`로 넘어가도 되는가?

## Discovery

- 2026-06-13: Session startup entry contract 확인. `develop`은 `origin/develop`과 일치했고 최근 merge commit은 `490d94e`였다.
- 2026-06-13: Branch Isolation Check 결과 source-gitflow mode. `develop`에서 직접 protected workflow/tracking 파일을 수정하지 않기 위해 `feature/chore-20260613-002-protocol-load-map-routing` branch 생성.
- 2026-06-13: `docs/works/harness/` 기준 다음 Work ID는 `CHORE-20260613-002`.
- 2026-06-13: 후보 비교 결과 trigger family simplification은 broad rewrite 위험이 크고, repo-health/work-doc은 CHORE-20260613-001 직후 흐름보다 옆 단계라 이번 세션에서 제외.
- 2026-06-13: Claude R0 Conditional Hold 반영. `Operating Tracks` 중복은 Non-goals로 차단했고, Load Map 축소 output은 새 compact table이 아니라 `AGENT-WORKFLOW.md` Context Routing pointer 1줄로만 제한했다. hand-trace pass criterion도 추가했다.
- 2026-06-13: Phase 1 audit 완료. `HARNESS-PROTOCOL.md` Load Map은 stale duplication candidate, `Document Map`은 detail reference, `Operating Tracks`는 out-of-scope duplicate로 판정. Phase 2 전 Minimal Patch Candidate Set 승인 필요.
- 2026-06-13: Phase 2 승인 반영. `AGENT-WORKFLOW.md`에는 Project Constants 발견성 pointer 1줄만 추가했고, `HARNESS-PROTOCOL.md` Load Map table은 `AGENT-WORKFLOW.md` Context Routing pointer 문장으로 교체했다. 새 compact table, Operating Tracks 정리, trigger family 변경은 하지 않았다.
- 2026-06-13: validation 완료. `git diff --check`, planned `rg` audit, 4-path hand-trace 모두 PASS. Claude R1 result review 요청 상태로 전환.
- 2026-06-13: R1 승인 확인 후 `/work-close` 처리. Work status Done, actual_end 기입, Work index Active -> Done 이동.
