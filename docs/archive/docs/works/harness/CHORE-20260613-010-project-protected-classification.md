---
id: CHORE-20260613-010
priority: P1
status: Archived
risk: L2
scope: DR-035 follow-up implementation slice 2로 project-protected extension classification(`P1/P2`)만 다룬다. `.harness/gate-config`의 custom protected path를 어떤 형식으로 class declaration 하고, hook runtime이 그 선언을 어떻게 ingest할지 source repo 기준 최소 메커니즘을 정한다. framework default hardening(`I0/T1/S1`) 재수정과 Runner / CI / F2 wiring은 범위 밖이다.
appetite: 0.5d
planned_start: 2026-06-13
planned_end: 2026-06-13
actual_end: 2026-06-13
related_dr: [DR-024, DR-025, DR-035]
related_work: [CHORE-20260611-008, CHORE-20260613-007, CHORE-20260613-008]
---

# CHORE-20260613-010: Project-Protected Extension Classification

## Top Summary

- **목표:** DR-035에서 `P1/P2`로 분리한 project-protected extension을 실제 runtime이 다룰 수 있도록, repo-specific class declaration 방식과 ingest 경로를 최소 범위로 구현한다.
- **왜 지금:** framework default hardening(`CHORE-20260613-008`)이 끝났고, backlog/STATUS에도 남은 범위가 `P1/P2`와 `F2 wiring`으로 정리됐다. 현재 다음 자연스러운 blocking slice는 `P1/P2`다.
- **value boundary:** source repo에는 현재 `.harness/gate-config`가 없으므로, 이 slice의 즉시 효용은 source repo 자체보다도 adopter target repo가 custom protected path를 선언할 때 얻는 shipped/scaffold-ready mechanism에 있다.
- **핵심 경계:** 이번 Work는 `.harness/gate-config` custom protected path가 branch isolation에서 `P1 default-safe`로만 남아 있는 상태를 좁힌다. `I0/T1/S1` 기본 runtime, finalization gate, CI wiring은 건드리지 않는다.
- **코웍 구조:** Codex = author/driver, Claude = red team reviewer. R0 합의 전 구현 변경 금지.

## Candidate Comparison

| 후보 | 판단 | 이유 |
| --- | --- | --- |
| A. project-protected extension classification mechanism (`P1/P2`) | **선택** | DR-035 follow-up split 2번이고, `CHORE-20260613-008` 이후 남은 W4 핵심 범위다. custom protected path가 계속 `P1 hard-stop`으로만 머무는 운영 마찰을 다음으로 해소할 수 있다. |
| B. Runner / CI / F2 wiring decision | 보류 | runtime/classification 정책이 더 고정된 뒤 판단하는 게 맞다. 지금 열면 F2와 같은 결정을 병렬로 다시 열 위험이 있다. |
| C. W5 optional 후보 | 비추천 | DR-035 residual이 backlog와 STATUS에 이미 명시돼 있어, 지금 optional로 우회하면 closeout 정합이 다시 흐려진다. |

## Background / Facts

- DR-035는 repo-specific custom protected path를 `P1 unclassified` / `P2 classified`로 나눴다.
- source repo에는 현재 `.harness/gate-config`가 없고, `awh_project_glob_match`는 해당 파일이 없으면 즉시 return 1 한다.
- 현재 shipped/runtime 상태에서 `.harness/gate-config`의 `[protected]` 추가 경로는 branch isolation에서 모두 사실상 `P1 default-safe hard-stop`으로만 동작한다.
- `CHORE-20260613-008`은 의도적으로 `awh_project_glob_match`와 `.harness/gate-config` ingestion 경로를 비범위로 두었다.
- 따라서 다음 slice는 “custom path를 어떤 선언 형식으로 class map할지”와 “runtime이 그 map을 어디서 어떻게 읽을지”를 좁게 구현하는 문제다.
- DR-035 원칙상 mapping이 없으면 `P1`이고, mapping이 있으면 `P2`로 mapped class를 상속한다.

## Scope / Non-Goals

### Scope

1. repo-specific custom protected path의 class declaration 형식을 고정한다.
2. branch isolation runtime이 custom protected path를 `P1` 또는 `P2`로 판정하는 최소 ingestion 로직을 구현한다.
3. `P2`가 `tracking-state` 또는 `structural-policy` mapped class를 상속하도록 정렬한다.
4. `CHORE-20260613-008`에서 framework default-only로 제한한 `awh_is_branch_isolation_tracking_path()`에 `[tracking-state]` section 전용 custom fallthrough를 추가해, custom `P2-T1` 경로가 `T1` warning semantics를 상속하도록 한다.
4. `.harness/gate-config` 또는 그 대체 source가 source/scaffold에 어떤 방식으로 드러나는지 문서/rule 설명을 최소 정렬한다.

### Non-Goals

- framework default `I0/T1/S1` runtime 재설계
- `tools/git-hooks/pre-commit`의 `FINALIZATION_ONLY` 섹션 및 `AWH_GATE_OVERRIDE_TRAILER` 참조 변경
- `tools/git-hooks/commit-msg` / DR-025 finalization gate 변경
- `run-harness-checks.sh`, GitHub Actions, required check, F2 wiring 결정
- `[tracking-state]` section 전용 fallthrough를 넘는 broader custom-path reclassification 또는 framework default path-set 재분류
- `docs/STATUS.md` 변경. R0 합의 전 변경하지 않는다.
- parent backlog `문서-only 규칙 강제화` closeout

## Files

### Plan / Tracking

| File | Plan |
| --- | --- |
| `docs/works/harness/CHORE-20260613-010-project-protected-classification.md` | Work SSoT |
| `docs/works/harness/README.md` | Active Work index row only |
| `docs/STATUS.md` | R0 합의 전 변경 없음 |

### Expected Implementation Surfaces (후보 — R0 합의 후 확정)

| File | Plan |
| --- | --- |
| `tools/git-hooks/lib/gate-lists.sh` | custom protected path class declaration / lookup helper |
| `tools/git-hooks/pre-commit` | `P1/P2` 판정 결과를 branch isolation에 반영 |
| `.claude/rules/git-workflow.md` | custom protected path 설명 최소 정렬 |
| `docs/GIT-WORKFLOW.md` | branch isolation 설명 최소 정렬 |
| `.harness/gate-config` | 형식 변경이 필요하면 source example / docs 관점 검토 |

## Plan

### Phase 0 — R0 Review Package

1. Work file과 Work index Active row만 생성한다.
2. `docs/STATUS.md`는 건드리지 않는다.
3. Claude에게 R0 review를 요청한다.
4. R0 합의 전에는 hook/rule/doc 구현 surface를 수정하지 않는다.

### Phase 1 — Mechanism Audit

1. 현재 `.harness/gate-config`가 `[protected]` / `[finalization]`을 어떻게 읽는지 다시 정리한다.
2. custom protected path class declaration을 어디에 둘지 비교한다.
   - 기존 `gate-config` 확장
   - 별도 section
   - 별도 file/source
3. 현재 파서 구조를 기준으로 아래 방향이 최소인지 비교한다.
   - `[protected]`에만 있으면 `P1 hard-stop`
   - `[tracking-state]`에 있으면 `P2-T1`로 `T1` 상속
   - `P2-S1`은 별도 section 없이 `[protected]`에 두고 runtime 결과는 hard-stop으로 유지할지
4. runtime이 `P1 default-safe`와 `P2 mapped-class`를 어떻게 구분할지 최소 로직을 정리한다.
5. **checkpoint:** Phase 1 format 선택 결과를 사용자에게 보고하고, 그 방향으로 Phase 2 구현에 들어갈지 승인받는다.

### Phase 2 — Minimal Classification Implementation (R0 승인 후)

1. declaration format을 고정한다.
2. `gate-lists.sh` / `pre-commit`에 최소 helper와 판정 로직을 추가한다.
   - 특히 `awh_is_branch_isolation_tracking_path()`에 `[tracking-state]` section 전용 fallthrough를 넣어 custom `P2-T1`을 허용한다.
3. `P2`가 `tracking-state` 또는 `structural-policy`를 정확히 상속하는지 검증한다.
4. 문서/rule 설명을 runtime과 같은 수준으로 최소 정렬한다.

### Phase 3 — Verification / Closeout Prep

1. custom protected path 시나리오를 임시 repo로 검증한다.
2. Claude R1 result review를 요청한다.
3. 승인 시 `/work-close`로 Done 처리하고, W4 residual을 다시 정리한다.

## Done Criteria

- [x] custom protected path class declaration 형식이 고정된다.
- [x] mapping 없는 custom protected path는 `P1 default-safe hard-stop`으로 유지된다.
- [x] mapping 있는 custom protected path는 `P2`로서 `tracking-state` 또는 `structural-policy`를 상속한다.
- [x] `awh_project_glob_match` / existing add-only ingestion 철학과 충돌하지 않는다.
- [x] finalization gate / trailer semantics는 변하지 않는다.
- [x] Claude R0/R1 review와 disposition이 Round Log에 누적된다.

## Verification

Planned commands:

```bash
git diff --check
sh -n tools/git-hooks/pre-commit
sh -n tools/git-hooks/lib/gate-lists.sh
rg -n "gate-config|protected|finalization|P1|P2|tracking-state|structural-policy" \
  tools/git-hooks/lib/gate-lists.sh \
  tools/git-hooks/pre-commit \
  .claude/rules/git-workflow.md \
  docs/GIT-WORKFLOW.md
```

Scenario checks:

- custom protected path without class mapping → hard-stop
- custom protected path mapped to tracking-state → `T1` 상속 동작 확인
- custom protected path mapped to structural-policy → runtime 결과는 `P1`과 동일 hard-stop이지만, 명시적 분류 경로가 깨지지 않는지 확인
- custom path가 `[tracking-state]`에 있고 framework default tracking path와 함께 staged → `DEVELOP_T1_ONLY` 유지 확인
- custom path가 `[tracking-state]`에 있고 framework default `S1` path와 함께 staged → mixed set hard-stop 확인
- existing framework default path behavior unchanged

## Risk / Reversal Cost

| Item | Assessment |
| --- | --- |
| Risk level | L2 — hook/runtime + gate-config semantics |
| Reversal cost | Medium. custom declaration format을 once ship하면 source/scaffold 설명과 target expectations가 생긴다 |
| Main risk | declaration format이 과하게 복잡해져 F2/CI 또는 broader policy slice까지 scope가 번지는 것 |
| Secondary risk | custom path를 tracking-state로 과대 분류해 default-safe 원칙을 약화시키는 것 |
| Control | `P1 default-safe` 유지, declaration 최소화, 임시 repo 시나리오 검증 |

## Open Questions

| ID | Question | Default Assumption |
| --- | --- | --- |
| OQ-1 | class declaration을 기존 `.harness/gate-config` 안에서 확장하는가? | Yes. add-only ingestion 철학을 가능한 한 유지 |
| OQ-2 | `P2`는 `tracking-state` / `structural-policy` 두 값만 허용하는가? | Yes. DR-035 mapped class 상속 범위에 맞춘다 |
| OQ-3 | source repo에서 선언 format example을 실제 `.harness/gate-config`까지 추가해야 하는가? | No. 우선 문서/rule 또는 helper 레벨로 충분한지 먼저 판단 |

## Approval / State

| Item | Status |
| --- | --- |
| 위험도 | L2 |
| 실행 모드 | Standard Work |
| Branch Isolation | PASS — `feature/chore-20260613-010-project-protected-classification` dedicated branch |
| Tool rule reference | `.claude/rules/docs-workflow.md`, `.claude/rules/git-workflow.md` 수동 적용 |
| PLAN 영향 | 없음. DR-035 follow-up implementation slice 2 |
| STATUS proposal | R0 합의 전 `docs/STATUS.md` 변경 없음 |
| State machine | DONE — Work closed locally, STATUS update proposal pending |

## Cross-Agent Review And Discussion

### Claude R0 Review Request

Claude R0 plan review 요청: CHORE-20260613-010 Project-Protected Extension Classification

검토 포인트:

1. DR-035 follow-up 2번째 slice로 `P1/P2` classification mechanism을 지금 여는 순서가 타당한가?
2. declaration format을 기존 `.harness/gate-config` 확장으로 두는 가정이 과하지 않은가?
3. `awh_project_glob_match` / add-only ingestion 철학을 유지한 채 `P1/P2`를 넣을 수 있는가?
4. F2 wiring, finalization gate, framework default runtime 재수정이 non-goal로 충분히 묶였는가?
5. 임시 repo 검증 시나리오가 `P1 default-safe`와 `P2 mapped-class`를 분리 검증하기에 충분한가?

### Round Log

| Round | Reviewer | Type | Findings | Codex Disposition | Status |
| --- | --- | --- | --- | --- | --- |
| R0 | Claude | Plan Review | Approved with must-fix framing. F1: source repo에는 `.harness/gate-config`가 없으므로 adopter value boundary를 Top Summary/Phase 1에 명시할 것. F2: declaration format 선택 후 사용자 보고·승인 checkpoint를 Phase 1에 추가할 것. F3: `awh_is_branch_isolation_tracking_path()`에 `[tracking-state]` section 전용 custom fallthrough를 이번 scope로 명시할 것. F4: verification에서 `P2-S1`은 runtime 결과가 `P1`과 같음을 재서술하고, custom T1 mixed-set 시나리오를 보강할 것 | 반영. Top Summary/Background에 adopter value boundary 추가, Phase 1에 format 선택 후 승인 checkpoint 추가, Scope/Phase 2/Non-Goals에 `[tracking-state]` fallthrough를 이번 slice 범위로 명시, verification 시나리오를 `P2-S1` 재서술 + custom T1 mixed-set 케이스로 보강 | Addressed |
| R1 | Claude | Result Review | Approved. `[tracking-state]`를 `P2-T1` declaration으로 쓰는 방향, protected union 확장, custom tracking fallthrough, seed/template/rule/doc cascade, 임시 repo 검증 시나리오가 모두 DR-035 및 add-only ingestion 철학과 정합적이라고 판단. Non-blocking으로 `tracking-state`와 `finalization` 이중 선언이 필요한 adopter case를 docs에 더 명시할 수 있다는 관찰만 남김 | 수용. blocking finding 없음으로 Work Done 처리 진행. 이중 선언 docs 보강은 optional follow-up으로 보류 | Approved |

### Claude R1 Review Request

Claude R1 result review 요청: CHORE-20260613-010 Project-Protected Extension Classification

구현/검증 결과 요약:

1. `tools/git-hooks/lib/gate-lists.sh`
   - `awh_is_branch_isolation_tracking_path()`가 framework default path-set 뒤에 `awh_project_glob_match "$1" tracking-state` fallthrough를 갖도록 확장
   - `awh_is_branch_isolation_protected_path()`가 `[protected]` 뿐 아니라 `[tracking-state]`도 protected union으로 인식
2. `scripts/create-harness.sh`
   - `.harness/gate-config` seed에 `[tracking-state]` section과 주석/example 추가
   - summary 안내 문구를 `protected/tracking-state/finalization` 기준으로 갱신
3. `.claude/rules/git-workflow.md`, `docs/GIT-WORKFLOW.md`, `scripts/templates/source-gitflow/docs/GIT-WORKFLOW.md`
   - custom path 설명을 `[protected]` / `[tracking-state]` / `[finalization]` 기준으로 정렬
   - `[tracking-state]`는 project-specific 경로를 `T1 tracking-state-only` 예외로 분류할 때만 사용한다고 명시
4. local verification
   - `git diff --check` PASS
   - `sh -n tools/git-hooks/pre-commit` PASS
   - `sh -n tools/git-hooks/lib/gate-lists.sh` PASS
   - `bash -n scripts/create-harness.sh` PASS
   - `bash scripts/tests/check-shipped-dr-closure.sh` PASS
5. 임시 repo scenario verification PASS
   - `[protected]` custom path only on `develop` → hard-stop
   - `[tracking-state]` custom path only on `develop` → warning
   - `[tracking-state]` custom path + `docs/STATUS.md` → warning 유지
   - `[tracking-state]` custom path + framework `S1` path → hard-stop
   - `[tracking-state]` glob path (`custom/log/**`) → warning
   - `main` + custom tracking-state path → hard-stop

검토 포인트:

1. `[tracking-state]` section을 `P2-T1` declaration으로 쓰는 방향이 DR-035와 add-only ingestion 철학에 정합적인가?
2. `awh_is_branch_isolation_protected_path()`가 `[tracking-state]`를 protected union에 포함하는 방식이 overreach 없이 필요한 최소 변경인가?
3. `awh_is_branch_isolation_tracking_path()`의 custom fallthrough 추가가 `CHORE-20260613-008`의 framework default hardening을 불필요하게 흔들지 않았는가?
4. seed/template/rule/doc cascade가 runtime 설명과 같은 수준으로 정렬됐는가?
5. 임시 repo 검증 시나리오가 `P1 default-safe`와 `P2-T1 mapped-class`를 충분히 입증하는가?

## Discovery

- 2026-06-13: backlog/STATUS/work index 재점검 결과, `CHORE-20260613-008` closeout과 DR-011 Recent Decisions pruning까지 반영된 clean `develop` 상태를 확인했다.
- 2026-06-13: `문서-only 규칙 강제화` parent backlog row는 `framework default hardening 완료`와 `남은 구현 범위(P1/P2, F2 wiring)`까지 반영돼 있다.
- 2026-06-13: DR-035와 `CHORE-20260613-008` 결과를 기준으로, 다음 자연스러운 residual은 `project-protected extension classification`이라고 판단했다.
- 2026-06-13: Claude R0 review 반영. source repo에는 `.harness/gate-config`가 없으므로, 이번 slice의 즉시 효용은 adopter target repo의 custom protected path use case에 있다는 value boundary를 명시했다.
- 2026-06-13: Claude R0 review 반영. Phase 1 format 선택 후 사용자 보고·승인 checkpoint를 추가했고, `awh_is_branch_isolation_tracking_path()`의 `[tracking-state]` section 전용 fallthrough를 이번 scope로 명시했다.
- 2026-06-13: Phase 1 audit 결과, 최소 declaration format은 기존 `.harness/gate-config` 확장 + `[tracking-state]` section 추가라고 판단했다. `[protected]` only는 `P1`, `[tracking-state]`는 `P2-T1`, `P2-S1`은 별도 section 없이 `[protected]` hard-stop 유지로 정리했다.
- 2026-06-13: implementation 완료. `gate-lists.sh`에 custom tracking-state fallthrough와 protected union 확장을 추가했고, `create-harness.sh` seed / source rule / source doc / shipped template 설명을 `[tracking-state]` 기준으로 정렬했다.
- 2026-06-13: local verification 완료. `git diff --check`, `sh -n tools/git-hooks/pre-commit`, `sh -n tools/git-hooks/lib/gate-lists.sh`, `bash -n scripts/create-harness.sh`, `bash scripts/tests/check-shipped-dr-closure.sh` PASS.
- 2026-06-13: 임시 repo scenario verification PASS. custom `P1` hard-stop, custom `P2-T1` warning, custom T1 + default tracking warning, custom T1 + framework `S1` hard-stop, custom tracking glob warning, `main` hard-stop를 모두 확인했다.
- 2026-06-13: Claude R1 result review 승인. blocking finding 없이 `P1 default-safe` / `P2-T1` mapped-class / docs-template cascade 정렬이 확인됐고, optional docs clarification만 non-blocking 관찰로 남았다.

- 2026-06-13: batch archive (CHORE-20260613-013 DR-038 archive-side flow 실사용 검증). status Done→Archived, live README Done(Pending) 행 제거 후 archive-side Archived 인덱스로 이전.
