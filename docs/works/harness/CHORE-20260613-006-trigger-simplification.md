---
id: CHORE-20260613-006
priority: P2
status: Done
risk: L2
scope: docs/HARNESS-PROTOCOL.md §14 Trigger Summary 표 앞에 family quick reference 섹션 추가. T1~T17 번호·내용·순서 변경 없음. 비대화 억제.
appetite: 0.5d
planned_start: 2026-06-13
planned_end: 2026-06-13
actual_end: 2026-06-13
related_dr: []
related_work: [CHORE-20260613-002, CHORE-20260613-003, CHORE-20260613-004, CHORE-20260613-005]
---

# CHORE-20260613-006: Harness Protocol Trigger Family Simplification

## Top Summary

- **목표:** `docs/HARNESS-PROTOCOL.md` §14 Trigger Summary 표 앞에 family quick reference를 추가해 사람/AI가 trigger ID를 family별로 빠르게 찾을 수 있도록 한다.
- **왜 지금:** W3 Workflow IA Diet 잔여 항목. Canonical 개념 계층화 핵심 목표(CHORE-002~005)로 blocking dependency 해제. trigger 표 재구성이 아니라 family 요약 추가만으로 Done Criteria 충족 가능.
- **핵심 제약:** T1~T17 번호·내용·순서 변경 금지. Loop Safety / Cascade Rule / Tool Surface Cascade Matrix 무변경. 추가 텍스트 최소화(비대화).
- **역할:** Claude = author/driver, Codex = red team reviewer.

## Scope / Non-Goals

### Scope

- `docs/HARNESS-PROTOCOL.md` §14 Trigger Summary 표 앞에 family quick reference 표 추가 (6개 family, lookup 용도)
- T7 cascade Level A 확인: downstream surface stale reference 없음 확인
- W3 Next Actions 항목 `Harness protocol trigger family simplification` 완결 처리

### Non-Goals

- T1~T17 trigger 내용·순서·번호 변경
- Loop Safety / Cascade Rule / Tool Surface Cascade Matrix 변경
- `docs/AGENT-WORKFLOW.md` Trigger And Naming Pointers 변경
- trigger 재분류 또는 새 trigger 추가
- broad canonical restructure (별도 항목으로 종료됨)

## Files

### Plan / Tracking

| File | Plan |
| --- | --- |
| `docs/works/harness/CHORE-20260613-006-trigger-simplification.md` | Work SSoT |
| `docs/works/harness/README.md` | Active Work index row |
| `docs/STATUS.md` | Active Work pointer (R0 합의 후 추가) |

### Implementation Surface

| File | Plan |
| --- | --- |
| `docs/HARNESS-PROTOCOL.md` | §14 앞에 family quick reference 표 추가. 나머지 섹션 무변경 |
| `docs/HARNESS-QUICK-REFERENCE.md` | trigger lookup이 stale해지는지 read-only 확인 |
| `skills/workflow/*.md`, `.claude/commands/`, `.cursor/rules/` | T7 cascade Level A — stale reference grep |

## Plan

### Phase 0 — R0 Review Package

1. Work 파일과 Work index Active row 생성.
2. Claude R0 plan review 요청.
3. R0 findings 반영 전 `docs/HARNESS-PROTOCOL.md` 구현 변경 금지.
4. `docs/STATUS.md` Active pointer는 R0 합의 후 추가.

> **[현황 메모]** 이번 Work에서 Phase 0 이전에 `docs/HARNESS-PROTOCOL.md` §14 변경이 실행됐다(family quick reference 표 추가). R0 게이트보다 앞선 실행이므로 이 사실을 Discovery에 기록하고, R0를 소급 적용한다. 변경 내용이 scope 정의와 일치하는지 R0에서 확인한다.

### Phase 1 — Implementation

Family 그룹핑 (6개 family):

| Family | Trigger IDs | 용도 |
| --- | --- | --- |
| Decision | T1, T2 | DR 생성·정리 |
| Planning | T3, T4, T5 | phase 전환·작업 분해·PLAN 영향 |
| Surface | T6, T7, T11, T12, T13, T14 | 문서·command·tool·scaffold 변경 |
| Record | T8, T8b, T9 | troubleshooting·회고·산출물 |
| Lifecycle | T10 | Work Done 상태 발견 |
| Finalization | T15, T16, T17 | commit/PR 전 STATUS·tracker·/work-close |

### Phase 2 — Review / Closeout Prep

1. 검증 명령 실행.
2. Claude R1 result review 요청.
3. 승인 시 `/work-close`로 Done 처리, STATUS/Tracking finalization 보고.

## Done Criteria

- [x] family quick reference 추가 — family → TN 번호 즉시 찾을 수 있음
- [x] T1~T17 번호·내용 변경 없음 확인
- [x] 추가 텍스트 최소화 확인 (비대화)
- [x] `git diff --check` 통과
- [x] T7 cascade Level A: `HARNESS-QUICK-REFERENCE.md`, `skills/workflow/`, `.claude/commands/`, `.cursor/rules/` stale reference 없음
- [x] R0 승인 기록 (소급 — Codex R0 Addressed)
- [x] Codex R0/R1 review와 disposition이 Round Log에 누적됨

## Verification

```bash
git diff --check
```

```bash
# T7 cascade Level A — trigger lookup pointer stale 여부
grep -rn "Trigger\|T1[0-9]\|T[1-9][^0-9]" \
  docs/HARNESS-QUICK-REFERENCE.md \
  skills/workflow/ \
  .claude/commands/ \
  .cursor/rules/ 2>/dev/null | grep -v "Binary" | head -30
```

## Risk / Reversal Cost

| Item | Assessment |
| --- | --- |
| Risk level | L2 — harness/workflow protocol surface |
| Reversal cost | Low — 추가 섹션 제거로 원복 가능 |
| Main risk | family 그룹핑이 잘못되면 사용자/AI가 잘못된 trigger ID로 찾아갈 수 있음 |
| Control | R0에서 family 그룹핑 정확성 확인, T1~T17 내용 변경 없음 확인 |

## Open Questions

| ID | Question | Default Assumption |
| --- | --- | --- |
| OQ-1 | family 6개 분류가 T8/T8b/T9를 Record로 묶는 것이 직관적인가? | 사용 패턴상 큰 문제 없음. R0에서 확인 |
| OQ-2 | T6(구조/흐름 구현 변경)을 Surface family에 포함하는 것이 맞는가? | Surface로 포함. 단, T6가 "architectural"이면 별도 family 가능 |
| OQ-3 | quick reference가 Loop Safety/Cascade Rule보다 앞에 있어야 하는가? | Trigger Summary 바로 앞이 자연스러움 |

## Approval / State

| Item | Status |
| --- | --- |
| 위험도 | L2 |
| 실행 모드 | Standard Work |
| Branch Isolation | PASS — `feature/chore-20260613-006-trigger-simplification` |
| Tool rule reference | `.claude/rules/docs-workflow.md`, `.claude/rules/git-workflow.md` 적용 |
| PLAN 영향 | 없음. W3 backlog slice 실행, roadmap 방향 변경 아님 |
| STATUS proposal | R0 합의 후 `CHORE-20260613-006` Active pointer 추가 제안 |
| State machine | CHECKPOINT — Codex R1 findings Addressed. /work-close 진행 가능 |

## Cross-Agent Review And Discussion

### Round Log

| Round | Reviewer | Type | Findings | Claude Disposition | Status |
| --- | --- | --- | --- | --- | --- |
| R0 | Codex | Plan Review | F1(Must): R0 이전 구현 실행 — scope 정의와 diff 일치 확인, 소급 처리 가능. F2(Must): T6를 Surface family에 포함 시 설명 보강 또는 별도 family 분리 검토. F3(Nice): T9가 "Record"보다 "Output"에 가까움 — family명 수정 또는 용도 명시 검토 | F1: Phase 0 주의사항 기록 완료. F2: Surface 설명에 "구조" 추가(`문서·구조·command·tool·scaffold 변경`). F3: "Record" 유지 — 용도 열에 "산출물"이 이미 명시돼 T9 포함 자명함 | Addressed |
| R1 | Codex | Result Review | Conditional Hold. F1(Must): backlog P1 Canonical 항목이 살아 있다는 전제 — 실제로는 e31a5bb에서 이미 제거됨(stale info). F2(Must): cascade 검증 범위 부족 — AGENTS.md, CLAUDE.md, .claude/rules/, .agents/skills/, .codex/hooks.json, prompts/, scaffold 미포함. F3(Nice): head -30 truncation으로 증거 불완전. OQ-1: STATUS pointer 승인 여부 확인 필요. OQ-2: Canonical backlog 처리 의도 확인 필요 | F1: e31a5bb commit 확인 — 제거 완료(Codex stale info). F2: 전체 7 surface 검증 완료, 모두 Level A(additive change, stale ref 없음). F3: head 제거 후 전체 grep 완료 — 신규 stale ref 없음 확인. OQ-1: 사용자 "응 진행해" 승인에 STATUS pointer 포함. OQ-2: Canonical 항목 이미 제거됨(e31a5bb) | Addressed |

### Codex R0 Review Request

Claude(author)가 작성한 plan을 Codex(red team reviewer)에게 요청한다.

Review focus:

1. Scope가 "family quick reference 추가"로 충분히 좁은가? T1~T17 내용 변경이 없는가?
2. family 6개 분류(Decision/Planning/Surface/Record/Lifecycle/Finalization)가 trigger ID를 정확하게 반영하는가?
3. `docs/HARNESS-PROTOCOL.md` §14 앞에 추가하는 것이 Loop Safety/Cascade Rule 위치를 방해하지 않는가?
4. R0 이전 실행(Phase 0 주의사항)이 scope 정의와 일치하는가? 추가 수정이 필요한가?
5. Non-goals가 충분히 차단하는가?

### Codex R1 Review Request

Claude(author)가 구현한 결과를 Codex(red team reviewer)에게 요청한다.

**구현 결과 요약:**
- `docs/HARNESS-PROTOCOL.md` §14 Trigger Summary 앞에 `### Trigger Family Quick Reference` 표 추가 (6개 family, 8행)
- Codex R0 F2 disposition 반영: Surface family 설명 `문서·구조·command·tool·scaffold 변경`으로 보강
- T1~T17 번호·내용·순서 변경 없음. Loop Safety / Cascade Rule / Tool Surface Cascade Matrix 무변경

Review focus:

1. family quick reference 표가 T1~T17 trigger를 정확하게 그룹핑했는가?
2. Surface family에 T6(구조/흐름 구현 변경) 포함 + "구조" 설명 보강이 적절한가?
3. 추가 내용이 §14 구조(Loop Safety, Cascade Rule)를 방해하지 않는가?
4. `git diff --check` PASS, cascade Level A PASS — 검증이 충분한가?
5. R1 승인 시 `/work-close` 진행해도 되는가?

## Discovery

- 2026-06-13: backlog의 `Harness protocol trigger family simplification` candidate 착수. Canonical 개념 계층화 blocking dependency 해제(CHORE-002~005 달성) 확인 후 독립 착수.
- 2026-06-13: Branch Isolation Check — source-gitflow mode. `feature/chore-20260613-006-trigger-simplification` branch 생성.
- 2026-06-13: Work 파일 초안이 co-working 패턴(역할 분리, R0/R1 gate, Round Log, Approval/State, tracker 연동) 미반영으로 재작성. 초안은 개인 메모 수준이었음.
- 2026-06-13: R0 gate 이전에 `docs/HARNESS-PROTOCOL.md` §14 변경 실행(family quick reference 표 추가) — 절차 위반. Phase 0 주의사항에 기록하고 R0를 소급 적용.
