---
id: CHORE-20260613-003
priority: P1
status: Done
risk: L2
scope: Operating Tracks definition boundary minimal realignment. `docs/AGENT-WORKFLOW.md`와 `docs/HARNESS-PROTOCOL.md` 양쪽의 Product/Harness track 정의 중복을 감사하고, startup summary와 protocol detail reference 역할을 깨지 않는 최소 정리만 R0 이후 수행한다.
appetite: 0.5d
planned_start: 2026-06-13
planned_end: 2026-06-13
actual_end: 2026-06-13
related_dr: [DR-007, DR-021, DR-023, DR-031]
related_work: [CHORE-20260612-008, CHORE-20260612-009, CHORE-20260612-011, CHORE-20260613-002]
---

# CHORE-20260613-003: Operating Tracks Definition Boundary Minimal Realignment

## Top Summary

- **목표:** `docs/AGENT-WORKFLOW.md`와 `docs/HARNESS-PROTOCOL.md`에 중복된 `Operating Tracks` 정의를 SSoT / startup summary / detail reference 경계로 분류하고, 승인된 경우 최소 pointer 정리만 수행한다.
- **왜 지금:** CHORE-20260613-002 R0에서 `HARNESS-PROTOCOL.md` §7.2 `Operating Tracks`가 별도 맹점으로 확인됐다. 이전 Work에서는 scope 확장을 막기 위해 Non-goal로 잠갔으므로, 이제 별도 slice로 작게 처리하는 것이 자연스럽다.
- **핵심 경계:** Product/Harness track 의미 자체를 바꾸지 않는다. source repo와 scaffold target의 track 경계도 재논의하지 않는다.
- **역할:** Codex = author/driver, Claude = red team reviewer.

## Candidate Comparison

1. **Operating Tracks definition boundary**는 CHORE-20260613-002의 직접 후속이며, 실제 중복 위치가 이미 확인돼 작게 자를 수 있다.
2. **Harness protocol trigger family simplification**은 W3 본류지만 trigger 전체 재그룹화로 번질 위험이 커서 아직 broad하다.
3. **`skills/workflow/repo-health.md` slice 분리**는 context budget에는 효과적이나 별도 canonical 파일 분해 작업이라 현재 `AGENT-WORKFLOW`/`HARNESS-PROTOCOL` 계층 정리 흐름보다 옆 단계다.
4. **`skills/workflow/work-doc.md` class 재검토**는 prompt/optional pack 후속으로 의미 있지만 optional pack 이동 판단까지 커질 수 있다.
5. 따라서 이번 Work는 `Operating Tracks` 정의 중복만 분리하고, trigger/repo-health/work-doc은 그대로 후속 후보로 둔다.

## Scope / Non-Goals

### Scope

1. `docs/AGENT-WORKFLOW.md` `Operating Tracks`가 startup/default execution summary로 필요한지 확인한다.
2. `docs/HARNESS-PROTOCOL.md` §7.2 `Operating Tracks`가 protocol detail reference로 독립 가치가 있는지 확인한다.
3. 두 정의의 의미·표현·source/scaffold boundary가 drift했는지 확인한다.
4. R0 승인 후에도 변경은 다음 중 하나로 제한한다.
   - `AGENT-WORKFLOW.md`를 compact SSoT로 유지하고 `HARNESS-PROTOCOL.md` §7.2를 pointer로 축소.
   - 양쪽 모두 필요한 경우, protocol 쪽에 "summary duplicate, policy source is AGENT-WORKFLOW" 역할 문장만 추가.
   - 중복이 의도된 summary/detail split이면 구현 변경 없이 Work 파일에 No action 판정.
5. Work 파일에 Claude R0/R1 review와 Codex disposition을 누적한다.

### Non-Goals

- Product track / Harness track 의미 변경.
- DR-031 Product track 대칭 구조 재논의.
- source repo vs scaffold target boundary 재논의.
- `docs/HARNESS-PROTOCOL.md` trigger family simplification.
- `docs/AGENT-WORKFLOW.md` Context Routing / Project Constants 추가 변경.
- README / MANUAL / GUIDE readability rewrite.
- scaffold output 변경.
- docs archive pending cleanup.
- repo-health/work-doc slice-class 검토.

## Files

### Plan / Tracking

| File | Plan |
| --- | --- |
| `docs/works/harness/CHORE-20260613-003-operating-tracks-boundary.md` | Work SSoT |
| `docs/works/harness/README.md` | Active Work index row only |

### Expected Audit / Implementation Surfaces

| File | Plan |
| --- | --- |
| `docs/AGENT-WORKFLOW.md` | `Operating Tracks` role audit. R0 이후 승인된 최소 role sentence/pointer만 가능 |
| `docs/HARNESS-PROTOCOL.md` | §7.2 `Operating Tracks` role audit. R0 이후 승인된 최소 pointer 정리만 가능 |
| `docs/backlog/HARNESS.md` | read-only check: W3 backlog가 Operating Tracks를 canonical 계층화 후보로 포함하는지 확인 |
| `docs/HARNESS-QUICK-REFERENCE.md`, `skills/workflow/*.md` | 변경 후 track routing pointer가 stale해지는지 read-only 확인 |

## Plan

### Phase 0 — R0 Review Package

1. Work file과 Work index Active row만 생성한다.
2. `docs/STATUS.md` Active pointer는 R0 합의 전 변경하지 않는다.
3. Claude R0 plan review를 요청한다.
4. R0 findings 반영 전 `docs/AGENT-WORKFLOW.md` / `docs/HARNESS-PROTOCOL.md` 구현 변경은 하지 않는다.

### Phase 1 — Track Definition Role Audit

1. `AGENT-WORKFLOW.md`와 `HARNESS-PROTOCOL.md`의 `Operating Tracks` 정의를 bullet/sentence 단위로 비교한다.
2. 각 문장과 bullet을 `SSoT / Startup Summary / Detail Reference / Stale Duplication`으로 분류한다.
3. source repo와 scaffold target 경계가 어느 문서에서 더 정확히 유지되는지 확인한다.
4. `HARNESS-PROTOCOL.md` 쪽이 단순 복제면 pointer 축소 후보로 기록한다.
5. Product/Harness track 의미 변경이 필요해 보이면 implementation을 중단하고 별도 Work/DR 후보로 분리한다.

### Phase 2 — Minimal Realignment Only

R0 승인 및 Phase 1 audit 결과가 모두 충족될 때만 아래 중 필요한 최소 변경을 수행한다.

1. `HARNESS-PROTOCOL.md` §7.2가 단순 복제면 `AGENT-WORKFLOW.md` `Operating Tracks`를 참조하는 1줄 pointer로 교체한다.
2. `AGENT-WORKFLOW.md` 쪽 문장이 SSoT로 부족하면 한 문장만 보강한다.
3. 새 track taxonomy, new table, scaffold behavior 변경은 만들지 않는다.

### Phase 3 — Review / Closeout Prep

1. 검증 명령을 실행한다.
2. Claude R1 result review를 요청한다.
3. 승인되면 `/work-close`로 Done 처리하고, commit 전 STATUS / Tracking finalization을 별도로 보고한다.

## Done Criteria

- [x] 양쪽 `Operating Tracks` 정의가 `SSoT / Startup Summary / Detail Reference / Stale Duplication`으로 분류된다.
- [x] Product/Harness track 의미가 변경되지 않았음을 확인한다.
- [x] source repo와 scaffold target 경계가 흐려지지 않았음을 확인한다.
- [x] R0 승인 전 구현 변경이 없다.
- [x] R0 이후 변경이 있다면 `docs/AGENT-WORKFLOW.md`와 `docs/HARNESS-PROTOCOL.md` 중 승인된 최소 범위에 한정된다.
- [x] `docs/STATUS.md` Active pointer는 별도 state-change approval 전까지 변경하지 않는다.
- [x] Claude R0/R1 review와 Codex disposition이 누적된다.

## Verification

Plan / audit verification:

```bash
git diff --check
rg -n "Operating Tracks|Product track|Harness track|docs/backlog/PRODUCT.md|docs/backlog/HARNESS.md|source repo|scaffold" docs/AGENT-WORKFLOW.md docs/HARNESS-PROTOCOL.md docs/HARNESS-QUICK-REFERENCE.md docs/backlog/HARNESS.md skills/workflow
```

Behavior preservation hand-trace:

- Session startup: `AGENT-WORKFLOW.md`만으로 Product/Harness track 구분과 source repo 예외를 이해할 수 있는지 확인한다.
- Protocol detail: `HARNESS-PROTOCOL.md`를 읽을 때 track definition을 다시 정책 원문처럼 재정의하지 않고 startup SSoT로 연결되는지 확인한다.
- Work selection: harness 후보는 `docs/backlog/HARNESS.md`, product 후보는 `docs/backlog/PRODUCT.md`로 라우팅되는 pointer가 유지되는지 확인한다.

## Risk / Reversal Cost

| Item | Assessment |
| --- | --- |
| Risk level | L2 — harness/workflow canonical/protocol surface |
| Reversal cost | Low. 문서 pointer 변경 중심이며 revert가 쉽다 |
| Main risk | track 정의를 줄이다가 source repo / scaffold target 경계 설명이 약해지는 것 |
| Control | R0 review 전 구현 금지, meaning-preservation hand-trace, grep validation |

## Open Questions

| ID | Question | Default Assumption |
| --- | --- | --- |
| OQ-1 | Operating Tracks의 SSoT는 `AGENT-WORKFLOW.md`인가? | Yes. session startup 기본 운영 규칙이므로 compact SSoT에 더 적합 |
| OQ-2 | `HARNESS-PROTOCOL.md`에도 track 정의 전문이 필요한가? | Probably no. detail protocol에서는 pointer 또는 짧은 context로 충분할 가능성이 높음 |
| OQ-3 | 이 변경이 DR-worthy인가? | No. 기존 track 의미를 바꾸지 않는 pointer 정리 |
| OQ-4 | STATUS나 PLAN 업데이트가 필요한가? | 기본값은 No. W3 slice 실행이며 roadmap 방향 변경 아님 |

## Phase 1 Audit Results

### R0 Disposition

| Finding | Codex Disposition |
| --- | --- |
| Overall Approved | Phase 1 audit 착수 |
| F1 Nice-to-have: section 전체가 아니라 bullet/sentence 단위로 분류 권장 | 반영. 같은 섹션 안의 고유 내용과 duplicate를 분리해 판단 |
| Harness track의 `prompt` vs `tool surface` 어휘 차이 확인 권장 | 반영. CHORE-20260613-001 이후 live prompt surface는 축소됐지만 session-start fallback prompt와 prompt surface 자체는 남아 있으므로 `prompt` 항목은 유지 가능 |

### Bullet-Level Role Matrix

| Unit | Evidence | Classification | Decision |
| --- | --- | --- | --- |
| Shared opening | `AGENT-WORKFLOW.md` L63, `HARNESS-PROTOCOL.md` L148 | **SSoT duplicate** | `AGENT-WORKFLOW.md`가 startup SSoT. protocol은 pointer로 충분 |
| Product track scope | `AGENT-WORKFLOW.md` L65: 기능, 문서, 테스트, 인프라, Phase backlog. `HARNESS-PROTOCOL.md` L150: Phase backlog와 기능 work | **AGENT-WORKFLOW.md = SSoT / protocol = lossy duplicate** | AGENT-WORKFLOW 표현이 더 넓고 정확함. protocol 쪽 압축문은 제거 가능 |
| Harness track scope | `AGENT-WORKFLOW.md` L66: AI workflow, command/rule, prompt, scaffold, status/process hardening. `HARNESS-PROTOCOL.md` L151: AI 작업 방식, tool surface, workflow rule, scaffold, status/process 개선 | **AGENT-WORKFLOW.md = SSoT / protocol = alternate wording duplicate** | `prompt`는 task prompt archive 후에도 session-start fallback prompt와 prompt surface가 남아 있어 track 범위로 유지 가능. protocol 쪽 alternate wording은 drift risk |
| Source repo exception | `AGENT-WORKFLOW.md` L68: Product track이 비어 있을 수 있고 active work는 주로 Harness track. `HARNESS-PROTOCOL.md` L152: Product track backlog가 없을 수 있음 | **AGENT-WORKFLOW.md = SSoT / protocol = partial duplicate** | AGENT-WORKFLOW가 active work 귀속까지 포함해 더 정확함 |
| Scaffold case | `AGENT-WORKFLOW.md` L69: Product/Harness track 모두 가짐. `HARNESS-PROTOCOL.md` L153: `docs/backlog/PRODUCT.md`와 `docs/backlog/HARNESS.md` 파일명 명시 | **Mixed: SSoT + local detail duplicate** | 파일명 detail은 protocol `Document Map`/`Item Location Reference`에 이미 존재하므로 §7.2에서는 제거 가능 |

### Phase 1 Decision

`AGENT-WORKFLOW.md`의 `Operating Tracks`가 compact SSoT로 충분하다. `HARNESS-PROTOCOL.md` §7.2는 부분 중복과 alternate wording이 섞여 drift surface가 되므로, Phase 2에서는 해당 subsection 본문을 1줄 pointer로 축소한다.

변경하지 않는 것:

- Product/Harness track 의미.
- `prompt`를 Harness track 정의에서 제거하는 것.
- `docs/HARNESS-PROTOCOL.md` `Document Map`, `Item Location Reference`, trigger/cascade.
- scaffold output.

### Minimal Patch Candidate

| File | Proposed Action | Risk |
| --- | --- | --- |
| `docs/HARNESS-PROTOCOL.md` | §7.2 `Operating Tracks` 본문을 `docs/AGENT-WORKFLOW.md` `Operating Tracks` pointer 1줄로 교체 | Low |

### Phase 2 Result

| File | Change | Boundary Check |
| --- | --- | --- |
| `docs/HARNESS-PROTOCOL.md` | §7.2 `Operating Tracks` 본문을 `docs/AGENT-WORKFLOW.md` `Operating Tracks` pointer 1줄로 교체 | Product/Harness track 의미 변경 없음. `AGENT-WORKFLOW.md`는 변경하지 않음. trigger/cascade/Document Map/Item Location Reference 미변경 |

### Validation Results

| Check | Result | Notes |
| --- | --- | --- |
| `git diff --check` | PASS | whitespace error 없음 |
| planned `rg` audit | PASS | `AGENT-WORKFLOW.md`의 track SSoT, `HARNESS-PROTOCOL.md` pointer, quick reference/workflow routing pointer 유지 확인 |
| Session startup hand-trace | PASS | `AGENT-WORKFLOW.md`만으로 Product/Harness track 구분과 source repo 예외 이해 가능 |
| Protocol detail hand-trace | PASS | `HARNESS-PROTOCOL.md`는 track 정의를 재정의하지 않고 `AGENT-WORKFLOW.md`로 연결 |
| Work selection hand-trace | PASS | `docs/backlog/PRODUCT.md` / `docs/backlog/HARNESS.md` routing pointer 유지 |

## Approval / State

| Item | Status |
| --- | --- |
| 위험도 | L2 |
| 실행 모드 | Standard Work |
| Branch Isolation | PASS — `feature/chore-20260613-003-operating-tracks-boundary` |
| Tool rule reference | `.claude/rules/docs-workflow.md` 적용. DR-007 확인 완료 |
| PLAN 영향 | 없음. W3 backlog slice 실행이며 roadmap 방향 변경 아님 |
| STATUS proposal | R0 합의 전 `docs/STATUS.md` 변경 없음 |
| State machine | DONE. R1 승인 후 Work Done 처리 완료 |

## Cross-Agent Review And Discussion

### Round Log Structure

| Round | Reviewer | Type | Findings | Codex Disposition | Status |
| --- | --- | --- | --- | --- | --- |
| R0 | Claude | Plan Review | Approved. Nice-to-have: bullet/sentence-level classification, `prompt` vs `tool surface` 표현 확인 | 반영. Phase 1 audit을 bullet-level matrix로 수행했고 `prompt`는 session-start fallback prompt surface가 남아 있어 유지 가능하다고 판정 | Addressed |
| R1 | Claude | Result Review | Approved. F1 nice-to-have: pointer 2번째 문장의 `상세 위치·trigger 판단` 표현을 CHORE-002 Load Map pointer와 같은 `상세 protocol 판단` 패턴으로 정리 권장 | 반영. `HARNESS-PROTOCOL.md` §7.2 pointer 문장을 `상세 protocol 판단이 필요할 때만`으로 정리 | Approved |

### Claude R0 Review Request

Claude R0 plan review 요청: CHORE-20260613-003 Operating Tracks Definition Boundary Minimal Realignment

Review focus:

1. 이 Work가 `Operating Tracks` 정의 중복만 다루도록 충분히 좁은가?
2. `AGENT-WORKFLOW.md`를 track definition SSoT로 보는 기본 가정이 맞는가?
3. `HARNESS-PROTOCOL.md` §7.2를 pointer로 축소할 경우 protocol detail lookup이 약해질 위험은 무엇인가?
4. Non-goals가 trigger family, repo-health/work-doc, source/scaffold boundary 재논의를 충분히 차단하는가?
5. Verification과 hand-trace가 track 의미 보존을 검증하기에 충분한가?

### Claude R1 Review Request

Claude R1 result review 요청: CHORE-20260613-003 Operating Tracks Definition Boundary Minimal Realignment

Review focus:

1. `docs/HARNESS-PROTOCOL.md` §7.2 `Operating Tracks`가 `AGENT-WORKFLOW.md` pointer 1줄로만 축소됐는가?
2. Product/Harness track 의미와 source repo / scaffold target 경계가 변경되지 않았는가?
3. `prompt`는 Harness track 정의에 유지되고, task prompt archive 이후 live session-start prompt surface와 충돌하지 않는가?
4. `Document Map`, `Item Location Reference`, trigger/cascade, quick reference, scaffold output이 scope 밖으로 유지됐는가?
5. Validation Results와 hand-trace가 R1 승인에 충분한가?

## Discovery

- 2026-06-13: CHORE-20260613-002 R0에서 `Operating Tracks` 중복이 hard finding으로 확인됐지만, 해당 Work에서는 scope 확장을 막기 위해 Non-goal로 잠갔다.
- 2026-06-13: PR #166 merge 후 `develop...origin/develop` clean 확인. 다음 Work ID는 `CHORE-20260613-003`.
- 2026-06-13: Claude R0 Approved 반영. Phase 1 audit을 bullet/sentence 단위로 수행했고, `HARNESS-PROTOCOL.md` §7.2는 `AGENT-WORKFLOW.md` SSoT에 대한 pointer로 축소하는 것이 안전하다고 판정.
- 2026-06-13: Phase 2 구현. `HARNESS-PROTOCOL.md` §7.2 `Operating Tracks` 본문을 `AGENT-WORKFLOW.md` pointer 1줄로 교체했다. `AGENT-WORKFLOW.md`와 track 의미는 변경하지 않았다.
- 2026-06-13: validation 완료. `git diff --check`, planned `rg` audit, 3-path hand-trace PASS. Claude R1 result review 요청 상태로 전환.
- 2026-06-13: R1 승인 반영. F1 nice-to-have에 따라 §7.2 pointer 표현을 `상세 protocol 판단이 필요할 때만`으로 정리했다.
- 2026-06-13: `/work-close` 처리. Done Criteria 전부 충족, status Done, actual_end 기입. `docs/STATUS.md`는 Active Work pointer가 비어 있어 변경 없음.
