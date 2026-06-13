---
id: CHORE-20260613-012
priority: P1
status: Archived
risk: L2
scope: backlog 테마 `문서-only 규칙 강제화 (CI/hook/hard-gate)`의 Done Criteria 충족 여부를 평가하고 종결한다. criterion #1(강제화 후보 규칙 목록 + 수단 매핑)의 명시적 공백을 DR-037 landscape로 메우고, parent backlog 항목을 제거하며 dangling 참조를 repoint한다. 새 enforcement 구현은 비범위(무배선·기존강제·behavioral 결론).
appetite: 0.5d
planned_start: 2026-06-13
planned_end: 2026-06-13
actual_end: 2026-06-13
related_dr: [DR-024, DR-025, DR-033, DR-035, DR-036, DR-037]
related_work: [CHORE-20260613-007, CHORE-20260613-008, CHORE-20260613-010, CHORE-20260613-011]
---

# CHORE-20260613-012: Doc-only Enforcement Theme Closure

## Top Summary

- **목표:** broad 테마 `문서-only 규칙 강제화`를 정직하게 종결한다. branch-isolation 강제화(008/010/011)로 테마의 실질 목표가 달성됐는지 평가하고, criterion #1의 명시 공백을 DR-037로 메운 뒤 parent 항목을 제거한다.
- **판단:** 종결 가능. (a)위반-피해 + (b)기계강제 가능 + (c)gate 부재를 동시 만족한 doc-only 규칙은 branch-isolation이 유일했고 강제화됨. 나머지는 기존 강제 또는 본질상 behavioral(hard-gate 부적합).
- **red-team 동기:** 그냥 닫으면 criterion #1("강제화 후보 규칙 **목록** + 수단 매핑")을 실제로 안 한 채 체크하는 것이 된다. DR-037 landscape 테이블이 그 공백을 메운다.
- **코웍 구조:** Codex 협업 없음. Claude self red-team 검토를 Round Log에 기록.

## Background / Facts

- parent 테마는 2026-06-10 등록, broad intent("doc-only 규칙 중 강제화할 주요 요소 검토·구현, 위반 빈도·실피해 큰 규칙부터").
- 실제로는 2026-06-08 설계 메모 → DR-035 → slice 008/010/011로 **branch-isolation에만 수렴**. doc-only 규칙 전반의 후보 목록은 산출물로 없었다.
- Done Criteria 판정: #2(enforcement 구현) ✅, #3(3갈래 scope 명시) ✅, #1(후보 목록 + 매핑) ⚠️ 암묵적만 → DR-037로 명시 충족.

## Scope / Non-Goals

### Scope

1. DR-037에 doc-only enforcement landscape + 수단 매핑 + 종결 결론을 기록한다.
2. parent backlog `문서-only 규칙 강제화`를 2단(Summary + Details) + Portfolio cell에서 제거한다.
3. 제거로 dangling되는 live 참조 3건을 repoint한다(Validation Spine Done Criteria → DR-036, TAXONOMY F2 pointer → DR-036, SOURCE-REPO-OPERATIONS machine-enforcement pointer → DR-037).
4. STATUS Recent Decisions + Next Actions W4를 갱신한다.

### Non-Goals

- 새 enforcement 구현(테마 결론이 "강제화 대상 없음 — 무배선/기존강제/behavioral").
- behavioral 규칙(Approval Matrix/STATUS 승인/PLAN trigger/language policy)의 hard-gate화.
- Done work files 007/008/010/011 및 DR-035 Linked Backlog(역사적 기록) 변경.
- `CI inline assertion ↔ invariants SSoT parity` / F4 처리(별도 candidate로 잔존).

## Files

| File | Plan |
| --- | --- |
| `docs/decisions/DR-037-doc-only-enforcement-landscape.md` | landscape + 종결 결론 (신규) |
| `docs/decisions/README.md` | DR-037 index row |
| `docs/works/harness/CHORE-20260613-012-doc-only-enforcement-closure.md` | Work SSoT |
| `docs/works/harness/README.md` | Active→Done row |
| `docs/backlog/HARNESS.md` | parent 제거(Summary+Details+Portfolio) + Validation Spine Done Criteria repoint |
| `docs/maintainer/HARNESS-TEST-TAXONOMY.md` | F2 pointer → DR-036 |
| `docs/maintainer/SOURCE-REPO-OPERATIONS.md` | machine-enforcement 후보 pointer → DR-037 |
| `docs/STATUS.md` | Recent Decisions + Next Actions W4 (승인 후) |

## Done Criteria

- [x] DR-037이 enforcement landscape + 수단 매핑 + 종결 결론을 기록한다 (criterion #1 명시 충족).
- [x] parent backlog가 Summary + Details + Portfolio cell에서 모두 제거된다.
- [x] dangling 참조 3건이 DR-036/DR-037로 repoint된다.
- [x] `rg "문서-only 규칙 강제화"` live 잔존 0 (archive/Done work file/역사적 DR 기록 제외).
- [x] STATUS Recent Decisions + Next Actions W4가 parent 종결을 반영한다.
- [x] Claude self red-team review가 Round Log에 기록된다.

## Verification

```bash
git diff --check
bash scripts/tests/check-shipped-dr-closure.sh
rg -n "문서-only 규칙 강제화" --glob '!docs/archive/**' --glob '!docs/works/harness/CHORE-2026061*'
```

- 코드/CI/hook 변경 없음 → inject-revert / scaffold cascade N/A.

## Risk / Reversal Cost

| Item | Assessment |
| --- | --- |
| Risk level | L2 — harness backlog/decision surface (코드 변경 없음) |
| Reversal cost | Low. DR-037 revert + backlog 행 복원 |
| Main risk | parent 제거로 dangling 참조 발생 → 3건 repoint + grep 검증으로 통제 |
| Secondary risk | behavioral 규칙을 "강제화 누락"으로 오해 → DR-037에 hard-gate 부적합 근거 명문화로 통제 |

## Approval / State

| Item | Status |
| --- | --- |
| 위험도 | L2 |
| 실행 모드 | Standard Work |
| Branch Isolation | PASS — `feature/chore-20260613-011-f2-wiring-decision` (같은 enforcement 테마 종결, 2번째 commit) |
| Tool rule reference | `.claude/rules/docs-workflow.md`, `.claude/rules/git-workflow.md` 수동 적용 |
| PLAN 영향 | 없음 |
| STATUS proposal | 승인 완료 — Recent Decisions + Next Actions W4 갱신 |
| State machine | DONE — Work closed, STATUS 번들 commit |

## Cross-Agent Review And Discussion

Codex 협업 없음. Claude가 reviewer 시각으로 self red-team 검토 후 기록한다.

### Round Log

| Round | Reviewer | Type | Findings | Disposition | Status |
| --- | --- | --- | --- | --- | --- |
| R0 | Claude (self red-team) | Direction Review | broad 테마를 branch-isolation만으로 닫으면 criterion #1("후보 규칙 목록")을 미수행 채 체크하는 문제. doc-only 규칙 전반 landscape를 명시 기록해야 정직한 종결. behavioral 규칙은 hard-gate 부적합 근거를 함께 기록해 "강제화 누락" 오해 방지. | DR-037에 landscape 테이블 + behavioral hard-gate 부적합 근거 작성. parent 제거 시 3건 repoint로 dangling 방지. | Addressed |

## Discovery

- 2026-06-13: parent Done Criteria 평가 — #2/#3 충족, #1은 암묵적만(branch-isolation 수렴, 후보 목록 부재).
- 2026-06-13: 사용자가 종결 방식으로 "DR-037 기록 후 close"를 선택.
- 2026-06-13: `문서-only 규칙 강제화` 참조 전수 grep — live 7곳(backlog 3, maintainer 2, STATUS 1 historical, DR-035/036 prose). 제거 + repoint 대상 식별.
- 2026-06-13: DR-037 작성, parent 제거, 3건 repoint, STATUS 갱신, verification PASS.
</content>

- 2026-06-13: batch archive (CHORE-20260613-013 DR-038 archive-side flow 실사용 검증). status Done→Archived, live README Done(Pending) 행 제거 후 archive-side Archived 인덱스로 이전.
