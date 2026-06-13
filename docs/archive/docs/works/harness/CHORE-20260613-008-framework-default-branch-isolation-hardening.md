---
id: CHORE-20260613-008
priority: P1
status: Archived
risk: L2
scope: DR-035 후속 implementation 첫 slice로 framework default branch-isolation hardening만 다룬다. source repo 기본 protected path에 대해 `develop` warning-only / `main` hard-stop의 현재 pre-commit 동작을 DR-035 class(`I0/T1/S1`) 기준으로 재정렬하고, 관련 `gate-lists`/rule/doc cascade를 함께 맞춘다. project-protected extension classification(`P1/P2`)과 F2 runner/CI 배선은 범위 밖이다.
appetite: 0.5d
planned_start: 2026-06-13
planned_end: 2026-06-13
actual_end: 2026-06-13
related_dr: [DR-024, DR-025, DR-035]
related_work: [CHORE-20260611-008, CHORE-20260613-007]
---

# CHORE-20260613-008: Framework Default Branch-Isolation Hardening

## Top Summary

- **목표:** DR-035에서 고정한 class split을 source repo의 framework default branch-isolation runtime에 반영한다. 첫 slice는 `I0 inherited-merge`, `T1 tracking-state-only`, `S1 structural-policy`만 다룬다.
- **왜 지금:** DR-035로 예외 클래스와 trailer 경계가 고정됐으므로, 이제야 `develop` warning-only 신호와 문서 인지 규칙 불일치를 runtime 쪽에서 좁게 정렬할 수 있다.
- **핵심 경계:** project-owned custom protected path(`P1/P2`)와 F2 runner/CI wiring은 다루지 않는다. 이번 Work는 framework default hardening + 문서/rule cascade까지만이다.
- **코웍 구조:** Codex = author/driver, Claude = red team reviewer. R0 합의 전 구현 변경 금지.

## Candidate Comparison

| 후보 | 판단 | 이유 |
| --- | --- | --- |
| A. framework default branch-isolation hardening | **선택** | DR-035 후속 split 1번과 정확히 일치한다. 현재 warning-only/FAIL 불일치를 가장 직접 줄일 수 있다. |
| B. project-protected extension classification mechanism | 보류 | `.harness/gate-config` custom path의 class mapping은 target-oriented complexity가 더 크다. source default hardening보다 뒤가 맞다. |
| C. Runner / CI / F2 wiring decision | 보류 | F2는 class/runtime 정책이 고정된 뒤 판단해야 한다. 지금 열면 같은 결정을 병렬로 다시 열게 된다. |

## Background / Facts

- `tools/git-hooks/pre-commit`은 현재 `main`에서는 protected path staged 시 exit 1, `develop`에서는 warning만 출력한다.
- `docs/GIT-WORKFLOW.md`와 `.claude/rules/git-workflow.md`는 protected path를 `develop`/`main`에서 피해야 한다고 말하지만, 실제 local develop 신호는 warning-only라 AI가 기계 신호를 따라 진행할 여지가 있다.
- DR-035는 이 불일치를 "모든 path 일괄 hard-stop"이 아니라 class split으로 해결하라고 결정했다.
  - `I0`: merge commit inherited exception
  - `T1`: tracking-state-only warning 예외
  - `S1`: structural-policy hard-stop
- DR-035는 branch isolation gate가 DR-025 `AWH-Gate-Override` trailer를 인식하지 않는다고 못박았다. 따라서 이번 slice는 trailer-aware 로직을 추가하지 않는다.
- `docs/backlog/HARNESS.md`의 `문서-only 규칙 강제화` 항목은 DR-035 선행 결정을 이미 반영했다. 이번 Work는 그 항목의 첫 implementation slice다.

## Scope / Non-Goals

### Scope

1. source repo framework default protected path를 `T1`과 `S1`로 나눌 때 runtime에서 필요한 최소 판정 로직을 구현한다.
2. `develop`에서:
   - `T1 tracking-state-only` staged set이면 warning 유지
   - `S1 structural-policy` staged set이 1개라도 포함되면 **DR-035 결정대로** hard-stop이 되도록 runtime을 반영한다
3. `main`에서 protected path hard-stop은 DR-035 class split과 모순이 없는지 확인하고 필요한 최소 조정만 한다.
4. merge commit(`.git/MERGE_HEAD`) inherited exception을 runtime/rule/doc에서 동일하게 유지한다.
5. 관련 surface를 함께 정렬한다.
   - `tools/git-hooks/pre-commit`
   - `tools/git-hooks/lib/gate-lists.sh`
   - `.claude/rules/git-workflow.md`
   - `docs/GIT-WORKFLOW.md`

### Non-Goals

- `.harness/gate-config` custom path를 `P1/P2`로 분류하는 메커니즘
- `gate-lists.sh` 수정 시 `awh_project_glob_match` 또는 `.harness/gate-config` custom path ingestion 경로 변경
- `tools/git-hooks/commit-msg` / DR-025 finalization gate 변경
- `tools/git-hooks/pre-commit` 내부의 `FINALIZATION_ONLY` 섹션 및 `AWH_GATE_OVERRIDE_TRAILER` 참조 변경
- `scripts/tests/run-harness-checks.sh` 배선, CI required check, F2 흡수
- `docs/STATUS.md` Active pointer 추가. R0 합의 전 변경하지 않는다.
- backlog `문서-only 규칙 강제화` 항목 closeout

## Files

### Plan / Tracking

| File | Plan |
| --- | --- |
| `docs/works/harness/CHORE-20260613-008-framework-default-branch-isolation-hardening.md` | Work SSoT |
| `docs/works/harness/README.md` | Active Work index row only |
| `docs/STATUS.md` | R0 합의 전 변경 없음 |

### Expected Implementation Surfaces (후보 — R0 합의 후 확정)

| File | Plan |
| --- | --- |
| `tools/git-hooks/pre-commit` | branch-isolation runtime class split 반영 중심 |
| `tools/git-hooks/lib/gate-lists.sh` | default protected path가 `T1`/`S1` 판정에 필요한 최소 helper로 충분한지 확인 |
| `.claude/rules/git-workflow.md` | branch isolation 설명이 runtime과 같아지도록 최소 정렬 |
| `docs/GIT-WORKFLOW.md` | pre-commit 설명과 allowed exception을 runtime과 최소 정렬 |
| `docs/backlog/HARNESS.md` | 이번 slice closeout 시 후속 implementation candidate wording 검토 |

## Plan

### Phase 0 — R0 Review Package

1. Work file과 Work index Active row만 생성한다.
2. `docs/STATUS.md` Active pointer는 건드리지 않는다.
3. Claude에게 R0 review를 요청한다.
4. R0 합의 전에는 hook/rule/doc 구현 surface를 수정하지 않는다.
5. 구현 착수 전 commit bundling 전략을 명시적으로 정리한다.
   - 기본 권장: CHORE-20260613-007 closeout 변경을 먼저 독립 commit
   - 이후 CHORE-20260613-008 Work/구현을 별도 commit
   - 또는 branch rename/분리가 더 명확한지 판단

### Phase 1 — Runtime Audit

1. 현재 `pre-commit`이 `develop`/`main`에서 어떤 path-set에 어떤 신호를 내는지 정리한다.
2. framework default protected path를 DR-035의 `T1`/`S1` 기준으로 분류한다.
3. current logic과 DR-035 사이의 mismatch를 좁게 정리한다.
   - `T1` warning 유지 여부
   - `S1` on develop 처리
   - merge inherited exception 유지 여부

### Phase 2 — Minimal Hardening (R0 승인 후)

1. `pre-commit`을 DR-035 class split에 맞게 최소 수정한다.
2. 필요하면 `gate-lists.sh`에 framework default `T1` 판단 helper를 추가하되, `P1/P2` custom mapping은 건드리지 않는다.
3. `.claude/rules/git-workflow.md`와 `docs/GIT-WORKFLOW.md`를 runtime 결과와 동일하게 정렬한다.

### Phase 3 — Verification / Closeout Prep

1. inject-revert로 `T1` warning / `S1` hard-stop / merge exception을 각각 검증한다.
2. Claude R1 result review를 요청한다.
3. 승인 시 `/work-close`로 Done 처리하고, backlog의 남은 implementation scope를 정리한다.

## Done Criteria

- [x] framework default branch-isolation runtime이 DR-035 `I0/T1/S1` 경계와 모순되지 않는다.
- [x] `T1 tracking-state-only`는 warning 예외로 남고, `S1 structural-policy`는 별도 강도로 처리된다.
- [x] merge commit inherited exception이 유지된다.
- [x] branch isolation gate는 여전히 DR-025 trailer를 인식하지 않는다.
- [x] hook/rule/doc cascade가 같은 분류를 가리킨다.
- [x] `P1/P2` custom extension classification과 F2 wiring은 범위 밖으로 유지된다.
- [x] Claude R0/R1 review와 disposition이 Round Log에 누적된다.

## Verification

Planned commands:

```bash
git diff --check
sh -n tools/git-hooks/pre-commit
sh -n tools/git-hooks/lib/gate-lists.sh
rg -n "MERGE_HEAD|protected|warning|hard-stop|AWH-Gate-Override" \
  tools/git-hooks/pre-commit \
  tools/git-hooks/lib/gate-lists.sh \
  .claude/rules/git-workflow.md \
  docs/GIT-WORKFLOW.md
```

Scenario checks:

- `develop` + `docs/STATUS.md` only staged → warning
- `develop` + `docs/AGENT-WORKFLOW.md` staged → hard-stop 여부가 DR-035와 정합
- `main` + protected path staged → hard-stop
- `.git/MERGE_HEAD` 존재 시 skip / N/A
- trailer 추가 여부가 branch isolation 결과를 바꾸지 않음

## Risk / Reversal Cost

| Item | Assessment |
| --- | --- |
| Risk level | L2 — hook/runtime + git workflow doc/rule surface |
| Reversal cost | Medium. 변경은 작을 수 있지만 pre-commit 신호가 바뀌면 maintainer 행동과 closeout 경로에 즉시 영향 |
| Main risk | `T1`과 `S1` 분류를 runtime에 과잉 구현해 custom extension/P1-P2/F2 scope까지 번지는 것 |
| Secondary risk | `develop` hardening을 올리면서 tracking-only bounded exception까지 같이 막아 false positive를 만드는 것 |
| Control | framework default만, trailer non-reuse 유지, inject-revert 4시나리오 검증 |

## Open Questions

| ID | Question | Default Assumption |
| --- | --- | --- |
| OQ-1 | `develop`에서 `S1 structural-policy`는 hard-stop으로 올리는가? | DR-035에서 이미 결정됨. 이번 slice는 결정이 아니라 runtime 반영 |
| OQ-2 | `T1` 판정을 위해 helper 함수를 새로 두는가, path-set inline 판정으로 충분한가? | 최소 helper 또는 inline 중 더 작은 변경 선택 |
| OQ-3 | `docs/decisions/**`를 hook runtime에서 별도 class로 보게 할 필요가 있는가? | `S1`에 포함된 것으로 충분 |
| OQ-4 | branch는 008 전용으로 분리하는가, 아니면 007 branch reuse를 유지하는가? | 008 전용 branch로 분리했다. 이후 구현/리뷰는 이 branch 기준으로 진행 |

## Approval / State

| Item | Status |
| --- | --- |
| 위험도 | L2 |
| 실행 모드 | Standard Work |
| Branch Isolation | PASS — `feature/chore-20260613-008-branch-isolation-hardening` dedicated branch |
| Tool rule reference | `.claude/rules/docs-workflow.md`, `.claude/rules/git-workflow.md` 수동 적용 |
| PLAN 영향 | 없음. DR-035 follow-up implementation slice 1번 실행 |
| STATUS proposal | Approval needed before edit. `docs/STATUS.md`의 W1 residual "hook exit(1) enforcement" 문구는 이번 Work 완료로 stale이므로, Recent Decisions/Next Actions 최소 정렬 제안 |
| State machine | END — Work Done, STATUS approval gate pending |

> **approval gating note:** `CHORE-20260613-007`은 독립 commit으로 먼저 분리했다. `CHORE-20260613-008` 구현과 Work closeout은 준비됐으며, `docs/STATUS.md`는 별도 승인 게이트 후 같은 commit에 묶어 반영한다.

## Cross-Agent Review And Discussion

### Claude R0 Review Request

Claude R0 plan review 요청: CHORE-20260613-008 Framework Default Branch-Isolation Hardening

검토 포인트:

1. DR-035 follow-up split 중 첫 구현 slice로 framework default hardening을 먼저 여는 순서가 타당한가?
2. `P1/P2` custom extension classification과 F2 wiring을 범위 밖으로 둔 선이 충분히 좁은가?
3. `develop`에서 `S1 structural-policy`를 어떻게 다룰지가 이번 slice의 핵심 쟁점으로 적절한가?
4. trailer non-reuse를 유지한 채 runtime hardening을 설계하는 방향이 맞는가?
5. 현재 branch reuse 상태에서 plan-only로 진행하는 것이 추적상 허용 가능한가?

### Round Log

| Round | Reviewer | Type | Findings | Codex Disposition | Status |
| --- | --- | --- | --- | --- | --- |
| R0 | Claude | Plan Review | Approved with must-fix framing. F1: `gate-lists.sh` 수정 시 `awh_project_glob_match` / custom path ingestion 경로는 non-goal로 고정할 것. F2: `S1 on develop`은 DR-035에서 이미 결정됐으므로 OQ/Scope를 "결정"이 아니라 "구현 반영"으로 수정할 것. F3: `pre-commit` 내부 `FINALIZATION_ONLY` 섹션과 `AWH_GATE_OVERRIDE_TRAILER` 참조는 불가침 범위로 명시할 것. F4: branch reuse는 허용 가능하나 Phase 0에 007 먼저 독립 commit 또는 branch rename/분리 판단을 추가할 것 | 반영. Non-Goals에 custom path ingestion 불가침과 pre-commit `FINALIZATION_ONLY` 불가침 추가, Scope/OQ-1을 DR-035 구현 반영 기준으로 수정, Phase 0에 commit bundling/branch rename 판단 추가 | Addressed |
| R1 | Claude | Result Review | Approved. `T1` subset gate는 충분히 좁고, `S1` + mixed set unified hard-stop은 DR-035와 정합. `gate-lists.sh` helper는 custom path ingestion 비범위를 침범하지 않았고, `FINALIZATION_ONLY` / `AWH_GATE_OVERRIDE_TRAILER` 불가침도 유지됨. rule doc ↔ runtime 일치 확인, `docs/GIT-WORKFLOW.md`는 commit 전 grep 재확인 권고 | 반영. `docs/GIT-WORKFLOW.md` grep 재확인 완료. blocking finding 없음이므로 closeout 진행 | Approved |

### Claude R1 Review Request

Claude R1 result review 요청: CHORE-20260613-008 Framework Default Branch-Isolation Hardening

구현/검증 결과 요약:

1. `tools/git-hooks/pre-commit`
   - `develop`에서 staged set 전체가 `docs/STATUS.md` / `docs/backlog/**` / `docs/works/**` 부분집합일 때만 warning
   - 그 외 protected direct commit(`S1` 또는 mixed staged set)은 `develop`에서 hard-stop
   - `main` hard-stop과 `.git/MERGE_HEAD` merge exception은 유지
2. `tools/git-hooks/lib/gate-lists.sh`
   - framework default `T1 tracking-state-only` 판정용 helper 추가
   - `awh_project_glob_match` / `.harness/gate-config` ingestion 경로는 미변경
3. `.claude/rules/git-workflow.md`, `docs/GIT-WORKFLOW.md`
   - runtime과 같은 class-sensitive 설명으로 정렬
   - `develop blanket warning` 문구 제거, `T1 bounded warning / structural-or-mixed hard-stop`으로 갱신
4. local verification
   - `git diff --check` PASS
   - `sh -n tools/git-hooks/pre-commit` PASS
   - `sh -n tools/git-hooks/lib/gate-lists.sh` PASS
   - 임시 repo 시나리오 검증 PASS:
     - `develop` + `docs/STATUS.md` only staged → exit 0 warning
     - `develop` + `docs/AGENT-WORKFLOW.md` staged → exit 1
     - `develop` + `docs/STATUS.md` + `README.md` staged → exit 1
     - `main` + protected path staged → exit 1
     - `.git/MERGE_HEAD` 존재 시 skip / exit 0

검토 포인트:

1. `T1 tracking-state-only` warning 예외가 staged-set subset 기준으로 충분히 좁게 구현됐는가?
2. `develop`에서 `S1 structural-policy`와 `tracking + non-tracking mixed set`을 같은 hard-stop으로 묶은 것이 DR-035와 정합적인가?
3. `gate-lists.sh` helper 추가가 `awh_project_glob_match` / custom path ingestion 비범위를 침범하지 않았는가?
4. `pre-commit`의 `FINALIZATION_ONLY` 섹션과 `AWH_GATE_OVERRIDE_TRAILER` 참조를 건드리지 않았는가?
5. `.claude/rules/git-workflow.md`와 `docs/GIT-WORKFLOW.md` 설명이 runtime 동작과 실제로 같은가?

## Discovery

- 2026-06-13: CHORE-20260613-007 decision slice closeout 후, DR-035 follow-up split 기준으로 framework default hardening을 다음 구현 후보로 선택했다.
- 2026-06-13: `CHORE-20260613-007` closeout은 commit `0e8bc61`로 독립 정리했다.
- 2026-06-13: 이후 tracking/implementation 혼선을 줄이기 위해 `feature/chore-20260613-008-branch-isolation-hardening` dedicated branch를 새로 만들고 이 Work의 기준 branch로 전환했다.
- 2026-06-13: backlog `문서-only 규칙 강제화`는 DR-035 선행 결정을 반영한 상태이며, 남은 implementation은 framework default hardening / project extension classification / F2 wiring으로 분해돼 있다.
- 2026-06-13: Claude R0 review 반영. `P1/P2` custom path ingestion과 `pre-commit`의 `FINALIZATION_ONLY` 섹션은 이번 slice non-goal로 고정했다.
- 2026-06-13: Claude R0 review 반영. `S1 on develop`은 DR-035에서 이미 결정된 사항으로 정리하고, 이번 Work는 hard-stop 여부를 재결정하지 않고 runtime 구현만 다루도록 Scope/OQ를 수정했다.
- 2026-06-13: Claude R0 review 반영. 구현 전 commit bundling 전략으로 `CHORE-20260613-007` closeout을 먼저 독립 commit할지, branch rename/분리가 더 명확한지 판단 단계를 Phase 0에 추가했다.
- 2026-06-13: implementation 완료. `tools/git-hooks/pre-commit`에 `develop` class-sensitive gate(`T1` warning / structural-or-mixed hard-stop)를 반영하고, `main` hard-stop 및 merge inherited exception은 유지했다.
- 2026-06-13: `tools/git-hooks/lib/gate-lists.sh`에 framework default `T1 tracking-state-only` helper를 추가했다. `awh_project_glob_match` 및 `.harness/gate-config` custom path ingestion 경로는 변경하지 않았다.
- 2026-06-13: `.claude/rules/git-workflow.md`와 `docs/GIT-WORKFLOW.md`를 runtime과 같은 class-sensitive 설명으로 정렬했다.
- 2026-06-13: local verification 완료. `git diff --check`, `sh -n tools/git-hooks/pre-commit`, `sh -n tools/git-hooks/lib/gate-lists.sh` PASS.
- 2026-06-13: 임시 repo 시나리오 검증 PASS. `develop T1 warning`, `develop S1 hard-stop`, `develop mixed hard-stop`, `main hard-stop`, `.git/MERGE_HEAD` skip를 모두 확인했다.
- 2026-06-13: Claude R1 Approved. blocking finding 없음. 권고된 `docs/GIT-WORKFLOW.md` grep 재확인 완료 후 closeout 준비로 전환했다.

- 2026-06-13: batch archive (CHORE-20260613-013 DR-038 archive-side flow 실사용 검증). status Done→Archived, live README Done(Pending) 행 제거 후 archive-side Archived 인덱스로 이전.
