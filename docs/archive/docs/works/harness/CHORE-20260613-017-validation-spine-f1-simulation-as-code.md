---
id: CHORE-20260613-017
priority: P2
status: Archived
risk: L2
scope: `Validation Spine residual follow-ups (F1-F4)` 중 F1만 독립 slice로 다룬다. `VERIFICATION-COMMANDS.md` Layer J/J-OB/Q를 deterministic script로 승격할 최소 경로와 Layer J/J-OB/Q/R/S의 `/tmp/awh-*` 경로를 repo-local `temp/` 정책에 정렬하는 방안을 설계·구현한다. F3/F4와 broad repo-health 재구조화는 비범위다. R0 전 구현 없음.
appetite: 0.5d
planned_start: 2026-06-13
planned_end: 2026-06-13
actual_end: 2026-06-13
related_dr: [DR-036, DR-038]
related_troubleshooting: []
related_work: [CHORE-20260611-005, CHORE-20260611-006, CHORE-20260613-004, CHORE-20260613-016]
---

# CHORE-20260613-017: Validation Spine residual F1 — Simulation-as-code + temp policy alignment

## Top Summary

- **목표:** `Validation Spine residual`에서 가장 구체적이고 닫기 쉬운 F1만 떼어, `VERIFICATION-COMMANDS.md` Layer J/J-OB/Q의 human-run 시뮬레이션 명령을 deterministic source-side script로 승격할 최소 경로를 만들고 `/tmp/awh-*` 경로를 repo-local `temp/` 정책에 맞춘다.
- **왜 지금:** 직전 CHORE-20260613-016이 CI↔invariants parity를 no-action으로 닫으면서 W4 잔여는 다시 `Validation Spine residual` F1/F3/F4만 남았다. 이 중 F1은 이미 taxonomy §6과 backlog에 명시된 후속이며, F3/F4보다 범위가 작고 executable spine을 직접 강화한다.
- **핵심 경계:** 이번 Work는 `repo-health` deep integration(F4)나 mirror/prompt/language Tier 1 승격(F3)을 열지 않는다. 오직 F1, 즉 **simulation-as-code + temp policy alignment**만 다룬다.
- **역할:** Codex = author/driver, Claude = reviewer. 구현 전 Claude R0 plan review, 구현 후 result review를 받는다.

## Candidate Fit

1. W4 잔여 중 우선순위가 가장 높고(P2) taxonomy/runner에 이미 후속 자리(F1)가 예약돼 있어 연결성이 높다.
2. 직전 no-action closeout들과 달리 이번 후보는 실제 executable surface를 추가하는 positive slice라 momentum이 좋다.
3. F3/F4는 scope가 넓고 경계 논쟁이 크다. 반면 F1은 Layer J/J-OB/Q와 `temp/` 정책이라는 구체 surface로 닫힌다.

## Context Manifest

| 순서 | 파일 | 섹션 | 왜 |
| --- | --- | --- | --- |
| 1 | `docs/backlog/HARNESS.md` | `Validation Spine residual follow-ups (F1-F4)` | F1 원문 범위, Done Criteria, 잔여 후속 맥락 |
| 2 | `docs/maintainer/VERIFICATION-COMMANDS.md` | Layer J/J-OB/Q/R/S | 현재 human-run simulation 명령과 `/tmp/awh-*` 잔존 범위 실측 |
| 3 | `docs/maintainer/HARNESS-TEST-TAXONOMY.md` | §4 runner, §5 temp 정책, §6 후속 분해 | F1이 이미 어떤 후속으로 정의됐는지 확인 |
| 4 | `scripts/tests/run-harness-checks.sh` | 전체 | 기존 tier runner가 어디까지 spine을 맡고 있는지 확인 |
| 5 | `docs/archive/docs/works/harness/CHORE-20260611-005-workflow-verification-system.md` | Top Summary / Scope / F1 follow-up | F1 분해의 최초 의도 재확인 |
| 6 | `docs/archive/docs/works/harness/CHORE-20260611-006-scaffold-tool-surface-regression.md` | 후속 분해 F1/F3/F4 | F1/F3/F4 경계 재확인 |
| 7 | `docs/retrospectives/harness-workflow-strictness-20260606.md` | 결론 / revisit trigger | 엄격성 자체보다 "작게 닫히는 slice를 먼저"라는 운영 리듬 확인용 참고 1건 |

Trigger: CHORE-20260613-016 closeout 이후 즉시 다음 후보 착수. `STATUS.md` Active Work는 비어 있고, Next Actions W4/W5의 유일한 concrete 잔여는 `Validation Spine residual` F1/F3/F4다.

## Current Facts

| Surface | Current Role | Observation |
| --- | --- | --- |
| `VERIFICATION-COMMANDS.md` Layer J/J-OB/Q | maintainer human-run simulation catalog | scaffold 생성 후 user action / onboarding / hook functional test를 상세 명령으로 기술하지만 deterministic script는 없다 |
| `VERIFICATION-COMMANDS.md` Layer J/J-OB/Q/R/S | path examples | 여전히 `/tmp/awh-*` 경로를 전제로 쓴다 |
| `HARNESS-TEST-TAXONOMY.md` §5 | temp policy SSoT | Tier 2 simulation은 repo-local `temp/`가 표준이라고 이미 선언돼 있다 |
| `run-harness-checks.sh` | thin deterministic runner | tier0 / closure / invariants / default-template parity만 수행한다. Layer J/J-OB/Q 수준의 user-flow simulation은 아직 없다 |
| backlog F1 | residual item | "Layer J/J-OB/Q deterministic script화 + J/J-OB/Q/R/S `/tmp`→`temp/` 치환"이 이미 작업 문장으로 명시돼 있다 |

초기 read-only 사실:

1. F1은 새 backlog 후보가 아니라 이미 taxonomy/backlog에 박힌 잔여 후속이다.
2. 지금 남은 질문은 "얼마나 많은 Layer J/J-OB/Q를 실제 script로 옮길 것인가"와 "경로 치환을 script 도입과 어느 정도 결합할 것인가"다.
3. F1을 과하게 잡으면 onboarding/full simulation 전체를 거대한 runner로 재구현하게 되고, 그 순간 F4 및 broad repo-health 논의로 새기 쉽다.

## Scope / Non-Goals

### Scope

1. `VERIFICATION-COMMANDS.md` Layer J/J-OB/Q의 step들을 **deterministic script화 가능한 단위**로 분해한다.
2. script로 승격할 최소 subset과 catalog에 human-run으로 남길 subset을 구분한다.
3. `Layer J/J-OB/Q/R/S`의 `/tmp/awh-*` 경로를 `temp/` 정책에 맞추는 최소 수정 범위를 결정한다.
4. R0 승인 후 선택된 최소 구현만 적용한다.

### Non-Goals

- `repo-health` Required Surface Matrix나 cascade slice 재구조화
- F3(mirror parity, prompt 정합, language policy Tier 1 승격)
- F4(runner 결과를 `/repo-health`에 surface)
- `run-harness-checks.sh`를 CI/pre-commit에 배선하는 재논의
- product/adopter verification layer(U) 확장

## Files

### Plan / Tracking

| File | Plan |
| --- | --- |
| `docs/works/harness/CHORE-20260613-017-validation-spine-f1-simulation-as-code.md` | Work SSoT |
| `docs/works/harness/README.md` | Active Work index row |

### Expected Implementation Surfaces (R0 승인 후)

| File | Purpose |
| --- | --- |
| `scripts/tests/run-harness-checks.sh` 또는 신규 helper | F1 deterministic helper를 추가/연결할 때 |
| `scripts/tests/*.sh` 신규 script | Layer J/J-OB/Q의 최소 deterministic slice를 수용할 때 |
| `docs/maintainer/VERIFICATION-COMMANDS.md` | Layer J/J-OB/Q/R/S catalog를 script pointer + `temp/` 경로 기준으로 정리할 때 |
| `docs/maintainer/HARNESS-TEST-TAXONOMY.md` | F1 완료 상태와 runner/Layer 경계를 최소 보강할 때 |
| 필요 시 source-only maintainer docs | helper usage/pointer가 추가로 필요할 때만 |

## Plan

### Phase 0 — R0 Plan Review

1. Work file + Active index row만 생성한다.
2. Claude R0 plan review를 요청한다.
3. R0 findings를 `Cross-Agent Review And Discussion`에 누적한다.
4. R0 승인 전 구현하지 않는다.

### Phase 1 — F1 Slice Definition

1. Layer J/J-OB/Q의 명령을 `deterministic script 가능 / human-run 유지 / out-of-scope`로 분류한다.
2. `/tmp/awh-*` 사용 지점을 `script 내부로 흡수 / 문서 경로만 치환 / 유지 불가`로 분류한다.
3. 최소 구현 단위를 아래 후보 중 하나로 좁힌다.
   - A. onboarding/generic/source-gitflow smoke를 하나의 source-side script로 추출
   - B. Layer J-OB/Q의 핵심만 deterministic helper로 추출하고 J는 catalog로 유지
   - C. path policy 정리만 하고 script화는 더 작은 subset으로 제한

### Phase 2 — Implementation Decision (R0 승인 후)

1. A/B/C 중 하나를 선택한다.
2. 선택 기준:
   - taxonomy §5 `temp/` 정책과의 직접 정합
   - runner/`repo-health` 경계 보존
   - catalog duplication 감소
   - verification cost 대비 regression signal
3. 구현이 필요하면 신규 helper는 source-only deterministic spine 규칙(`set -euo pipefail`, cleanup, narrow scope)을 따른다.

### Phase 3 — Validation And Review

1. source-level verification을 실행한다.
2. Claude result review 요청과 findings disposition을 기록한다.
3. `/work-close`에서 taxonomy/backlog 기준으로 F1이 완결인지, 아니면 partial-done 재등록이 필요한지 명시 판단한다.

## Phase 1 Findings

1. **Layer J는 human-run 유지:** `/session-start` 출력 관찰, work lifecycle 해석, repo-health 진입은 interactive 성격이 강해 deterministic script로 승격하는 순간 유지비가 커진다.
2. **deterministic core는 J-OB/Q에 집중:** OB0/OB1/OB3/OB4/OB5와 Layer Q의 main/develop/feature hook core는 source-side helper로 충분히 고정 가능하다.
3. **granularity 상한은 scenario family 기준:** grep line 단위가 아니라 `J / J-OB / Q` 시나리오 family로 분류해 Work 파일 밀도를 유지한다.
4. **`/tmp`→`temp/`는 helper 흡수 + appendix 치환 조합:** helper가 생성하는 경로는 `temp/harness-tests/`로 고정하고, 수동 appendix인 J/J-OB/Q/R/S도 같은 기준으로 맞추면 정책이 일관된다.

## Phase 2 Decision

- **선택:** Option B
- **결정:** Layer J는 catalog/human-run으로 남기고, Layer J-OB deterministic core + Layer Q core만 `scripts/tests/check-onboarding-flows.sh`로 분리 구현한다.
- **runner 경계:** `run-harness-checks.sh`에는 직접 추가하지 않는다. onboarding/hook helper는 source-side deterministic smoke이고, runner는 thin orchestrator로 유지한다.

## Implementation Summary

1. `scripts/tests/check-onboarding-flows.sh` 신설
   - OB0 scaffold 4-mode 생성(generic / source-gitflow / optional / existing)
   - OB1 generic bootstrap pointer smoke
   - OB3 source-gitflow onboarding surface smoke
   - OB4 optional-pack presence + invariants
   - OB5 existing overlay preservation + `--check` drift 0
   - Layer Q core(main hard-stop / develop warning / feature PASS)
2. `docs/maintainer/VERIFICATION-COMMANDS.md`
   - Layer J는 interactive/manual appendix로 명시
   - Layer J-OB / Q는 helper pointer + manual appendix 구조로 정리
   - Layer J/J-OB/Q/R/S의 `/tmp/awh-*` 예시를 repo-local `temp/harness-tests/` 기준으로 치환
3. `docs/maintainer/HARNESS-TEST-TAXONOMY.md`
   - helper를 관련 문서에 추가
   - thin runner vs standalone helper 경계를 명시
   - F1 정의를 실제 구현 방향(J manual 유지, J-OB/Q core helper)으로 구체화

## Done Criteria

- [x] Layer J/J-OB/Q step이 deterministic script 가능성 기준으로 분류된다.
- [x] Layer J/J-OB/Q/R/S의 `/tmp/awh-*` 경로 처리 방침이 Work 파일에 기록된다.
- [x] A/B/C 중 최소 구현 단위 1개가 선택되거나, script화 범위를 더 줄여야 하는 근거가 명문화된다.
- [x] 구현이 있을 경우 `temp/` 정책과 runner 경계가 taxonomy와 모순되지 않는다.
- [x] `VERIFICATION-COMMANDS.md`가 새 helper와 중복 명령을 과도하게 보유하지 않는다.
- [x] F3/F4 비범위가 Work 파일과 review log에 명확히 남는다.
- [x] Claude R0 plan review와 result review가 기록된다.

## Verification

### Plan Verification

```bash
git status --short --branch
git diff --check
rg -n "^## Layer J|^## Layer J-OB|^## Layer Q|^## Layer R|^## Layer S|/tmp/awh" docs/maintainer/VERIFICATION-COMMANDS.md
rg -n "temp/|F1|Tier 2|run-harness-checks" docs/maintainer/HARNESS-TEST-TAXONOMY.md scripts/tests/run-harness-checks.sh
```

### Expected Implementation Verification

```bash
bash -n scripts/tests/*.sh
git diff --check
```

If new deterministic helper is approved:

```bash
bash scripts/tests/run-harness-checks.sh --tier0
# plus targeted helper execution and inject-revert proof depending on chosen option
```

### Verification Results

- `bash -n scripts/tests/*.sh` → PASS
- `bash scripts/tests/check-onboarding-flows.sh` → PASS
- `bash scripts/tests/run-harness-checks.sh --tier0` → `OVERALL: PASS`
- `git diff --check` → clean
- `rg -n "/tmp/awh" docs/maintainer/VERIFICATION-COMMANDS.md` → Layer J/J-OB/Q/R/S 기준 잔존 없음 (Layer A dry-run 예시만 유지)

## Risk / Reversal Cost

| Item | Assessment |
| --- | --- |
| 위험도 | L2 — harness/workflow validation surface 조정 |
| 실행 모드 | Standard Work |
| Reversal cost | Low-Medium — 신규 helper는 되돌리기 쉽지만 J/J-OB/Q를 과도하게 재구현하면 catalog/runner 경계가 흐려진다 |
| Main risk | F1 명분으로 onboarding/full simulation 전부를 거대한 source-side runner로 끌어오게 되는 것 |
| Control | minimal A/B/C option set, F3/F4 explicit non-goal, R0 before implementation |

## Open Questions

| ID | Question | Default Assumption |
| --- | --- | --- |
| OQ-1 | Layer J/J-OB/Q 전체를 script화해야 하는가, 아니면 핵심 subset만 deterministic helper로 올려도 충분한가? | 기본은 subset. J 전체는 너무 넓다 |
| OQ-2 | `run-harness-checks.sh`에 직접 넣는 것이 맞는가, 아니면 별도 helper script를 두는 것이 경계상 더 나은가? | 기본은 helper 분리. runner는 thin orchestrator 유지 선호 |
| OQ-3 | `/tmp`→`temp/` 경로 치환을 script 도입과 한 commit으로 묶는 것이 맞는가? | script가 건드리는 Layer는 함께, 나머지는 최소 문서 치환 또는 defer 가능 |
| OQ-4 | F1 완료 후 backlog residual 표기를 `F3/F4 only`로 줄일 수 있는가? | Yes, 구현 범위가 F1 정의를 충족하면 가능 |

## Approval / State

| Item | Status |
| --- | --- |
| 위험도 | L2 |
| 실행 모드 | Standard Work |
| Branch Isolation | PASS — `feature/chore-validation-spine-f1-deterministic-scripts` |
| Active Work discovery | 없음 |
| PLAN 영향 | 없음. 신규 서비스/infra/DB schema 변경 아님 |
| Troubleshooting | Not Applicable |
| Tool rule reference | `.claude/rules/docs-workflow.md`, `.claude/rules/git-workflow.md`; `scripts/tests/*`는 별도 path-scoped shell rule 없음 → existing spine style 준수 |
| STATUS proposal | `CHORE-20260613-017` Active Work pointer 추가 필요. 단 R0 합의 전 `docs/STATUS.md` 변경 없음 |
| State machine | IMPLEMENTED — result review 대기 |

## STATUS Update Proposal

- 변경 섹션: `Active Work`
- 변경 이유: `Validation Spine residual F1`을 독립 Work로 착수할 경우 live dashboard pointer가 필요함
- 변경 후 상태: `CHORE-20260613-017` Active row 추가
- 되돌리기 비용: Low

현재는 Work 파일과 live README만 생성하고, `docs/STATUS.md`는 R0 합의 또는 착수 승인 후에만 수정한다.

## Claude R0 Review Request

Claude R0 plan review 요청: CHORE-20260613-017 Validation Spine residual F1 — Simulation-as-code + temp policy alignment

Review focus:

1. `Validation Spine residual`을 F1 단독 slice로 떼는 방향이 지금 가장 작은 closable 작업으로 적절한가?
2. A/B/C 선택지가 F1을 과도하게 넓히지 않으면서 implementation-ready한가?
3. `run-harness-checks.sh` 직접 확장보다 helper 분리 선호(OQ-2)가 경계상 타당한가?
4. `/tmp`→`temp/` 치환을 "script가 닿는 Layer와 함께, 나머지는 최소"로 보는 기본 가정이 적절한가?
5. F3/F4 비범위 설정이 충분히 단단한가?

Please respond in this format:

```text
Approval: Approved | Conditional Hold | Hold

Findings
- F1 (Must-fix/Nice-to-have): ...

Review Questions
| Question | Answer |
| --- | --- |
| F1 slice framing sound? | ... |
| Option set balanced? | ... |
| Helper-vs-runner boundary sound? | ... |
| temp policy alignment scope sound? | ... |
| Non-Goals tight enough? | ... |

Round Log Entry
| Round | Reviewer | Status | Summary | Follow-Up |
| --- | --- | --- | --- | --- |
| R0 | Claude | ... | ... | ... |
```

## Cross-Agent Review And Discussion

### Round Log

| Round | Reviewer | Status | Summary | Follow-Up |
| --- | --- | --- | --- | --- |
| R0 | Claude | Approved | slice framing 타당, option set balanced, helper 분리 선호 적절. Layer J는 interactive 성격이 강해 B안(J-OB 핵심 + Q script화, J catalog 유지)이 자연스럽다는 관찰 포함 | F1: option C 선택 시 taxonomy F1 완료 여부를 Phase 3 산출물로 명시 권고(차단 아님). 구현은 B안으로 진행 |
| R1 | Claude | Approved | 구현 clean, runner 경계 유지, temp 정책 정렬 완료. OB2 제외 근거 미명시(Nice-to-have). Layer Q AWH-Gate-Override 활용이 실제 harness 패턴과 일치해 hook test 현실 대표성 높음 | F1: OB2 제외 근거 helper Non-goal comment에 추가(적용 완료) |

### Finding Disposition

| Finding | Codex Disposition | Rationale / Action |
| --- | --- | --- |
| R0-F1 | Accepted | Phase 3 항목을 "F1 완결 vs partial-done 재등록 판단"으로 구체화했다. closeout 시 taxonomy/backlog residual 표기를 이 기준으로 정리한다. |
| R0-F2 | Accepted | Phase 1 Findings/Phase 2 Decision에 반영. Layer J는 manual catalog 유지, J-OB core + Q core를 helper로 구현한다. |
| R1-F1 | Accepted | OB2 제외 근거(static grep + mv 조작 성격, document content 검증)를 `check-onboarding-flows.sh` Non-goal comment에 추가했다. |

## Claude Result Review Request

Claude result review 요청: CHORE-20260613-017 Validation Spine residual F1 — Simulation-as-code + temp policy alignment

Review focus:

1. Layer J를 human-run catalog로 남기고 J-OB/Q deterministic core만 helper로 추출한 B안이 F1 범위에 정확히 맞는가?
2. `check-onboarding-flows.sh`가 OB0/OB1/OB3/OB4/OB5 + Q core를 충분히 커버하면서 runner 경계를 흐리지 않는가?
3. `VERIFICATION-COMMANDS.md`의 helper pointer / manual appendix 분리가 중복 없이 읽히는가?
4. `HARNESS-TEST-TAXONOMY.md`가 thin runner vs standalone helper 경계를 명확히 설명하는가?
5. closeout 시 backlog/taxonomy residual을 F3/F4만 남기는 방향이 타당한가?

Please respond in this format:

```text
Approval: Approved | Conditional Hold | Hold

Findings
- F1 (Must-fix/Nice-to-have): ...

Review Questions
| Question | Answer |
| --- | --- |
| Scope closed to F1 only? | ... |
| Option B boundary sound? | ... |
| Helper-vs-runner split sound? | ... |
| temp policy alignment sufficient? | ... |
| Closeout direction (F3/F4-only residual) sound? | ... |

Round Log Entry
| Round | Reviewer | Status | Summary | Follow-Up |
| --- | --- | --- | --- | --- |
| R1 | Claude | ... | ... | ... |
```

## Discovery

- 2026-06-13: 다음 candidate 비교 결과, `Validation Spine residual` 전체 대신 F1을 독립 slice로 먼저 닫는 것이 가장 작고 P2 우선순위에도 맞다고 판단했다.
- 2026-06-13: `VERIFICATION-COMMANDS.md` 실측 결과 Layer J/J-OB/Q는 여전히 human-run simulation이며, `/tmp/awh-*` 경로가 J/J-OB/Q/R/S에 넓게 남아 있다.
- 2026-06-13: taxonomy §5는 이미 `temp/`를 Tier 2 표준으로 선언했고, `run-harness-checks.sh`는 아직 J/J-OB/Q 수준의 user-flow deterministic helper를 갖지 않는다.
- 2026-06-13: Claude R0 review는 B안(J manual 유지, J-OB/Q core helper화)을 가장 자연스러운 결론으로 관찰했고, 해당 방향으로 구현했다.
- 2026-06-13: 신규 helper `scripts/tests/check-onboarding-flows.sh`는 source-only deterministic smoke로 OB0/OB1/OB3/OB4/OB5 + Q core를 커버한다.
- 2026-06-13: `VERIFICATION-COMMANDS.md` Layer J/J-OB/Q/R/S는 `temp/harness-tests/` 기준으로 정렬했고, taxonomy는 runner thin 경계와 helper 위치를 명시했다.
- 2026-06-13: retrospective 1건(`harness-workflow-strictness-20260606`)은 직접적인 F1 설계 답을 주진 않지만, 작은 reversible slice를 먼저 닫는 현재 운영 리듬과 충돌하지 않음을 확인하는 보조 근거로만 사용했다.
