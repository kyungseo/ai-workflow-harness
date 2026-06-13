---
id: CHORE-20260613-011
priority: P2
status: Archived
risk: L2
scope: DR-035 §6 Slice 3(Runner / CI / F2 wiring decision)만 다룬다. `run-harness-checks.sh`를 CI required check 또는 pre-commit/hook에 배선할지 결정하고, backlog `Validation Spine residual follow-ups`의 F2를 흡수한다. 결정은 "무배선 + 근거 명문화"이며 실제 배선 구현은 비범위다. framework default runtime, finalization gate, P1/P2 classification은 건드리지 않는다.
appetite: 0.5d
planned_start: 2026-06-13
planned_end: 2026-06-13
actual_end: 2026-06-13
related_dr: [DR-018, DR-020, DR-033, DR-035, DR-036]
related_work: [CHORE-20260611-005, CHORE-20260613-008, CHORE-20260613-010]
---

# CHORE-20260613-011: F2 Runner / CI Wiring Decision

## Top Summary

- **목표:** DR-035 §6 Slice 3 "Runner / CI / F2 wiring decision"을 결정으로 고정한다. `run-harness-checks.sh`를 CI required check 또는 pre-commit/hook에 배선할지 판단하고, backlog F2를 흡수한다.
- **결정:** **무배선(no-wiring)** — runner를 CI/pre-commit gate에 배선하지 않는다. 이유는 DR-036에 기록한다.
- **왜 지금:** DR-035 follow-up split 3개 중 1·2번(CHORE-20260613-008/010)이 끝났고, 남은 residual은 Slice 3 하나다. F2는 2026-06-08부터 세 차례 deferral된 항목으로, "결정으로 닫지 않으면 매번 재론"되는 상태였다.
- **코웍 구조:** 이번 Work는 Codex 협업 없이 진행한다. 외부 reviewer 대신 **Claude self red-team review**를 Round Log에 기록한다.
- **value boundary:** 코드/CI/hook 변경은 없다. 산출물은 DR-036 + backlog F2 흡수 + STATUS residual 정리다. runner는 결정 후에도 manual-only로 남으며, 자동 호출은 F4(`/repo-health` surface, 아직 Candidate)에서 별도로 다룬다.

## Candidate Comparison (F2 방향)

| 후보 | 판단 | 이유 |
| --- | --- | --- |
| A. 무배선 + 근거 명문화 | **선택** | `bash -n` / `git diff --check` / DR closure는 이미 `ci.yml` + `pre-commit`에서 강제된다. tier2(scaffold 실제 생성)는 pre-commit에 과중하다. runner 고유가치(invariants SSoT 호출)는 enforcement gate가 아니라 F4 repo-health surface에서 다루는 게 경계상 맞다. Simplicity First. |
| B. CI를 runner SSoT로 수렴 | 비채택 | `ci.yml`은 runner보다 넓은 검사(phrase scan, gate-config functional, commit format)를 inline 보유한다. runner로 완전 대체 불가 → 부분 중복 또는 모든 CI 검사를 runner로 이관(scope 확장). F2(배선 여부 결정) 범위를 초과한다. |
| C. tier0를 pre-commit에 배선 | 비채택 | pre-commit이 이미 `git diff --check` + staged 조건부 `bash -n`을 수행한다. tier0 배선은 한계효용이 낮고, 매 commit 전체 `*.sh` syntax 검사로 약간 느려진다. tier2는 과중해 제외. |

## Background / Facts

검증 표면별 현황(착수 시 실측):

| 검증 항목 | `ci.yml` (source) | `pre-commit` | `run-harness-checks.sh` |
| --- | --- | --- | --- |
| `bash -n create-harness.sh` | 상시 | staged 시 | tier0 |
| `git diff --check` (whitespace) | `diff-tree` 상시 | 상시 | tier0 |
| shipped DR closure | 없음 | staged 시 (hard gate) | tier1 |
| scaffold invariants (`check-scaffold-invariants.sh`) | **자체 inline 재구현** | 없음 | tier1/tier2 (SSoT) |
| scaffold 실제 생성 (tier2 ×3 mode) | inline 유사 assertion | 없음 (과중) | tier2 |

- runner는 현재 **자동 호출이 0건**이다(수동 실행만). CI도 pre-commit도 runner를 호출하지 않는다.
- enforcement는 이미 두 표면에서 제공된다: PR 시점 `ci.yml`(required-check 가능), commit 시점 `pre-commit`.
- runner의 고유 가치는 `check-scaffold-invariants.sh`(invariants SSoT)를 tier2로 실제 scaffold 생성과 함께 호출하는 데 있다. 이는 enforcement보다 **maintainer local 검증 / repo-health surface** 성격이다.

## Scope / Non-Goals

### Scope

1. DR-035 §6 Slice 3 "Runner / CI / F2 wiring decision"을 결정으로 고정한다 (DR-036).
2. backlog `Validation Spine residual follow-ups (F1-F4)`의 F2를 DR-036으로 흡수 명시한다.
3. backlog `문서-only 규칙 강제화`의 "남은 구현 범위: Runner / CI / F2 wiring decision"을 resolved로 갱신한다.
4. STATUS Recent Decisions + Next Actions W4 잔여를 정리한다.

### Non-Goals

- `ci.yml`, `tools/git-hooks/*`, `run-harness-checks.sh` 실제 변경 (무배선 결정이므로 코드 변경 없음).
- F1/F3/F4 처리 (별도 `Validation Spine residual` 항목에 잔존).
- F4(runner → `/repo-health` surface) 구현.
- CI inline scaffold assertion ↔ `check-scaffold-invariants.sh` SSoT parity 정비 (아래 Discovery R1 residual로 분리).
- framework default runtime / finalization gate / P1/P2 classification 변경.

## Files

| File | Plan |
| --- | --- |
| `docs/works/harness/CHORE-20260613-011-f2-wiring-decision.md` | Work SSoT |
| `docs/works/harness/README.md` | Active index row |
| `docs/decisions/DR-036-f2-runner-wiring-decision.md` | F2 wiring 결정 기록 (신규) |
| `docs/decisions/README.md` | DR-036 index row |
| `docs/backlog/HARNESS.md` | F1-F4 항목 F2 흡수 + `문서-only 규칙 강제화` residual 갱신 |
| `docs/STATUS.md` | Recent Decisions + Next Actions W4 잔여 (승인 후) |

## Done Criteria

- [x] DR-036이 F2 wiring을 "무배선 + 근거"로 고정한다.
- [x] DR-036이 R1 residual(CI inline assertion ↔ invariants SSoT parity)을 F2 범위 밖으로 명시 routing한다.
- [x] DR-036이 runner manual-only / F4 미구현 상태를 정직하게 기술한다(F4가 이미 커버하는 듯 호도하지 않는다).
- [x] backlog F2가 DR-036으로 흡수됨이 두 backlog 항목에 반영된다.
- [x] STATUS Next Actions가 "DR-035 follow-up split 완결"과 "F1/F3/F4 잔존"을 분리 기술한다.
- [x] Claude self red-team review와 disposition이 Round Log에 누적된다.

## Verification

```bash
git diff --check
bash scripts/tests/check-shipped-dr-closure.sh
rg -n "F2|wiring|run-harness-checks|DR-036" docs/backlog/HARNESS.md docs/STATUS.md docs/decisions/DR-036-f2-runner-wiring-decision.md
```

- 코드/CI/hook 변경 없음 → scaffold cascade / inject-revert N/A.
- backlog/STATUS/DR 간 pointer 정합 grep, stale phrase 점검.

## Risk / Reversal Cost

| Item | Assessment |
| --- | --- |
| Risk level | L2 — harness/workflow surface 결정 (실제 코드 변경 없음) |
| Reversal cost | Low. 무배선 결정을 되돌려도 나중에 배선만 추가하면 되며 구조적 부채가 남지 않는다 |
| Main risk | "무배선"으로 R1 residual(CI/invariants drift)을 암묵 방치하는 것 → DR-036에서 명시 routing으로 통제 |
| Secondary risk | Low reversal cost인데 DR을 만드는 과잉설계 우려 → DR의 가치는 reversal 보호가 아니라 F2 재론 차단(anti-re-litigation)에 둔다 |

## Approval / State

| Item | Status |
| --- | --- |
| 위험도 | L2 |
| 실행 모드 | Standard Work |
| Branch Isolation | PASS — `feature/chore-20260613-011-f2-wiring-decision` dedicated branch |
| Tool rule reference | `.claude/rules/docs-workflow.md`, `.claude/rules/git-workflow.md` 수동 적용 |
| PLAN 영향 | 없음. DR-035 follow-up implementation slice 3 (결정) |
| STATUS proposal | 승인 완료 — Recent Decisions + Next Actions W4 갱신 |
| State machine | DONE — Work closed, STATUS 번들 commit |

## Cross-Agent Review And Discussion

이번 Work는 Codex 협업이 없다. 사용자 지시에 따라 Claude가 reviewer 시각으로 self red-team 검토를 수행하고 결과를 아래에 기록한다.

### Round Log

| Round | Reviewer | Type | Findings | Disposition | Status |
| --- | --- | --- | --- | --- | --- |
| R0 | Claude (self red-team) | Plan/Direction Review | R1: Option A가 "CI가 invariants SSoT를 호출 않고 inline 재구현 → drift" gap을 암묵 방치 → DR-036에 명시 routing 필요. R2: "runner 가치는 F4에서 호출"은 F4가 미구현(Candidate)이므로 manual-only 현실을 정직히 기술할 것. R3: reversal cost가 Low라 DR-worthy 임계 미달 우려 → DR 가치를 anti-re-litigation으로 재정의하고 lean하게. R4: W4 잔여 회계에서 F1/F3/F4 생존을 F2 완결과 분리 기술. | 4건 모두 반영: DR-036 Consequences에 R1 residual routing, Background에 runner manual-only/F4 미구현 기술, Reversal Cost에 R3 framing, STATUS Next Actions에 R4 분리. | Addressed |

## Discovery

- 2026-06-13: 착수 시 실측 — `ci.yml`은 scaffold assertion을 inline 재구현하고 `check-scaffold-invariants.sh`를 호출하지 않는다. runner는 자동 호출 0건(수동만).
- 2026-06-13: 사용자가 F2 방향을 Option A(무배선 + 근거 명문화)로 선택.
- 2026-06-13: Claude self red-team R0 — R1~R4 보정점 도출 및 반영 (Round Log 참조).
- 2026-06-13: R1 residual 등록 — CI inline assertion ↔ `check-scaffold-invariants.sh` SSoT parity는 F2 범위 밖. closeout 시 별도 backlog candidate 등록 여부 제안.
</content>
</invoke>

- 2026-06-13: batch archive (CHORE-20260613-013 DR-038 archive-side flow 실사용 검증). status Done→Archived, live README Done(Pending) 행 제거 후 archive-side Archived 인덱스로 이전.
