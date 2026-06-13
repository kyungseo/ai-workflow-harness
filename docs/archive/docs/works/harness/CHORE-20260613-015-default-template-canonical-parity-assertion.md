---
id: CHORE-20260613-015
priority: P2
status: Archived
risk: L2
scope: default template variant를 가지는 canonical 쌍(`.cursor/rules/workflow.mdc`, `.claude/rules/git-workflow.md`)에 대해 허용 차이 외 parity drift를 maintainer 검증에서 검출하는 helper+tier0 경로를 설계·구현한다.
appetite: 0.5d
planned_start: 2026-06-13
planned_end: 2026-06-13
actual_end: 2026-06-13
related_dr: []
related_troubleshooting: []
related_work: [CHORE-20260613-014, CHORE-20260613-005, CHORE-20260611-008]
---

# CHORE-20260613-015: Default Template Canonical Parity Assertion

## Top Summary

- **목표:** default template로 별도 tracked 되는 canonical/template 쌍 2개(`workflow.mdc`, `git-workflow.md`)에 대해 허용 차이만 남기고 나머지 drift를 deterministic하게 잡는 maintainer guard를 설계한다.
- **왜 지금:** CHORE-20260613-014에서 `workflow.mdc` default variant가 stable tracked template로 분리되면서 temp 기반 self-consistency 문제는 닫혔지만, 그만큼 canonical 수정 후 default template이 조용히 stale해질 위험이 커졌다.
- **핵심 경계:** 이번 Work는 `source canonical ↔ scaffold default variant` parity만 다룬다. `CI inline assertion ↔ invariants SSoT parity` 후보와 통합하지 않는다.
- **역할:** Codex = author/driver, Claude = reviewer. 구현 전 R0 plan review, 구현 후 result review를 받는다.

## Candidate Fit

1. W3는 닫혔고, 이 후보는 W4/W5 잔여 중에서도 CHORE-20260613-014 closeout residual과 직접 연결된다.
2. 현재 확인된 쌍은 2개로 범위가 작고 deterministic guard로 닫기 쉽다.
3. runner/CI/invariants 경계와 닿지만, backlog가 비범위를 명확히 적어두어 작은 enforcement slice로 유지할 수 있다.

## Context Manifest

| 순서 | 파일 | 섹션 | 왜 |
| --- | --- | --- | --- |
| 1 | `docs/backlog/HARNESS.md` | `default template ↔ canonical parity assertion` | 후보 정의, 비범위, Done Criteria |
| 2 | `.cursor/rules/workflow.mdc` | Step 0 table | canonical pair의 source 기준 |
| 3 | `scripts/templates/default/.cursor/rules/workflow.mdc` | 전체 | default pair의 intentional delta 확인 |
| 4 | `.claude/rules/git-workflow.md` | branch isolation / finalization / branch flow | source-gitflow canonical 기준 |
| 5 | `scripts/templates/default/.claude/rules/git-workflow.md` | advisory-only posture | default pair의 intentional delta 확인 |
| 6 | `scripts/create-harness.sh` | `git-workflow.md`, `workflow.mdc` adapt 분기 | 실제 scaffold 파생 경로 확인 |
| 7 | `scripts/tests/run-harness-checks.sh` | tier orchestration | maintainer verification wiring 후보 |
| 8 | `scripts/tests/check-scaffold-invariants.sh` | source-level invariant scope | existing invariant과의 경계 확인 |
| 9 | `docs/maintainer/VERIFICATION-COMMANDS.md` | Layer Q-static | existing parity/semantic-key 검증 패턴 재사용 가능성 확인 |

Trigger: backlog candidate 착수 / CHORE-20260613-014 closeout residual. 사용자가 W4 follow-up으로 이 candidate를 지정했고, 이번 세션은 R0 review까지를 우선 목표로 둔다.

## Current Facts

| Pair | Current Intentional Delta | Current Risk |
| --- | --- | --- |
| `.cursor/rules/workflow.mdc` ↔ `scripts/templates/default/.cursor/rules/workflow.mdc` | default variant는 `work-doc` routing row 1개만 제외 | canonical table 수정 시 default template stale 가능 |
| `.claude/rules/git-workflow.md` ↔ `scripts/templates/default/.claude/rules/git-workflow.md` | default variant는 advisory-only posture를 추가하고 source-gitflow 전용 branch isolation / post-merge cleanup을 제거 | source rule 문구 변경 후 default variant 설명이 drift해도 조용히 남을 수 있음 |

현재 source에는 create-time 분기와 몇 개의 grep verification은 있지만, 두 tracked pair 자체의 parity drift를 직접 fail시키는 deterministic guard는 없다.

## Phase 1 Design Decisions

| Item | Decision |
| --- | --- |
| Pair inventory | 현재 대상은 2쌍만 고정: `workflow_mdc`, `git_workflow_rule` |
| Assertion home | pair 전용 helper `scripts/tests/check-default-template-parity.sh` + `run-harness-checks.sh --tier0` wiring |
| Registry posture | helper 상단 comment에 pair registry를 explicit하게 유지 |
| `workflow.mdc` normalization | canonical에서 `work-doc` routing row 1개만 제거한 expected default를 재구성 후 비교 |
| `git-workflow.md` normalization | **reconstruction** 채택. canonical에서 advisory-only preface를 삽입하고 source-gitflow 전용 branch isolation / tracking-only trailer / detailed branch-flow body를 제거 또는 generic branch-flow 문장으로 치환한 expected default를 재구성 후 비교 |
| `check-scaffold-invariants.sh` relation | scaffold output invariant과 source tracked-pair drift 검출은 성격이 달라 이번 Work에서는 helper 분리 유지 |

## Scope / Non-Goals

### Scope

1. default variant를 가지는 canonical/template 쌍 목록을 현재 기준으로 확정한다.
2. 각 쌍의 허용 차이(allowed delta)를 명시한다.
3. 허용 차이 외 drift를 maintainer verification에서 검출하는 최소 assertion 경로를 설계한다.
4. 새 variant pair가 추가될 때 검증 누락이 드러나는 최소 운영 규칙을 정한다.
5. R0 승인 후 최소 구현과 검증, Claude result review 요청까지 진행한다.

### Non-Goals

- `CI inline assertion ↔ invariants SSoT parity` 후보와 통합하지 않는다.
- source-gitflow shipped template(`scripts/templates/source-gitflow/...`) parity 정비로 범위를 넓히지 않는다.
- `docs/GIT-WORKFLOW.md`, hook runtime, `.github/workflows/ci.yml` 전반 재설계로 번지지 않는다.
- `workflow.mdc` / `git-workflow.md`의 정책 내용 자체를 새로 결정하지 않는다. 이번 Work는 drift 검출 guard가 중심이다.
- R0 review 전 source/template/rule/script 본문 구현 변경은 하지 않는다.

## Files

### Plan / Tracking

| File | Plan |
| --- | --- |
| `docs/works/harness/CHORE-20260613-015-default-template-canonical-parity-assertion.md` | Work SSoT |
| `docs/works/harness/README.md` | Active Work index row |

### Expected Implementation Surfaces (R0 승인 후)

| File | Purpose |
| --- | --- |
| `scripts/tests/check-default-template-parity.sh` | pair registry + reconstructed expected default 비교 helper |
| `scripts/tests/run-harness-checks.sh` | source maintainer runner의 tier0 wiring |
| `docs/maintainer/VERIFICATION-COMMANDS.md` | operator-facing verification 문구가 실제로 바뀔 때만 최소 반영 |

## Plan

### Phase 0 — R0 Plan Review

1. Work file + Active index row만 생성한다.
2. Claude R0 plan review를 요청한다.
3. R0 findings를 `Cross-Agent Review And Discussion`에 누적한다.
4. R0 승인 또는 must-fix 반영 전 구현하지 않는다.

### Phase 1 — Pair Contract And Guard Design

1. canonical/default pair 2개를 inventory로 확정한다.
2. 각 pair의 allowed delta를 raw diff가 아니라 semantic contract로 정리한다.
3. `git-workflow.md` normalization approach를 Phase 2 전 확정하고 Work 파일에 기록한다.
   - 후보: reconstruction, normalized diff fingerprint, section-presence/absence check
   - 목표: advisory-only preface 추가 + source-gitflow-only section 제거라는 양방향 변환을 허용 차이로 안정적으로 표현
4. assertion home을 source-level tier0 경로로 확정한다.
   - 기본 방향: pair 전용 helper 추가 후 `run-harness-checks.sh --tier0`에서 호출
   - `check-scaffold-invariants.sh` 본문 확장은 기본안에서 제외하고, helper 분리가 불가능할 때만 재검토
5. "새 variant pair 추가 시 검증 누락이 드러나는 방식"을 최소 규칙으로 정한다.
   - 기본 방향: assertion script 내부 pair registry comment 또는 동급의 inline 목록으로 명시

### Phase 2 — Minimal Implementation (R0 승인 후)

1. pair parity assertion helper와 tier0 wiring을 구현한다.
2. inject-revert 방식으로 두 pair 모두 FAIL/ PASS를 재현한다.
3. 필요할 때만 source-only maintainer verification 문서를 최소 갱신한다.

### Phase 3 — Validation And Review

1. source-level verification을 실행한다.
2. Claude result review 요청과 findings disposition을 기록한다.
3. `docs/STATUS.md` pointer/closeout 여부는 별도 승인 후 처리한다.

## Done Criteria

- [x] default variant를 가지는 canonical/template 쌍 목록이 현재 기준으로 확정된다.
- [x] `workflow.mdc`, `git-workflow.md` 두 쌍의 allowed delta가 Work 파일에 명시된다.
- [x] `git-workflow.md` normalization approach가 Phase 2 구현 전 Work 파일에 확정된다.
- [x] 허용 차이 외 drift가 maintainer verification에서 FAIL로 검출된다.
- [x] 두 쌍 모두 inject-revert로 FAIL/ PASS 재현 evidence가 남는다.
- [x] assertion script 내 pair registry가 명시되고, 새 variant pair 추가 시 검증 누락이 드러나는 최소 운영 규칙이 정리된다.
- [x] `CI inline assertion ↔ invariants SSoT parity` 후보와 범위가 섞이지 않는다.
- [x] Claude R0 plan review와 result review가 기록된다.

## Verification

### Plan Verification

```bash
git status --short --branch
git diff --check
git diff --no-index -- .cursor/rules/workflow.mdc scripts/templates/default/.cursor/rules/workflow.mdc
git diff --no-index -- .claude/rules/git-workflow.md scripts/templates/default/.claude/rules/git-workflow.md
```

### Expected Implementation Verification

```bash
bash -n scripts/create-harness.sh
bash -n scripts/tests/check-default-template-parity.sh
bash -n scripts/tests/run-harness-checks.sh
bash scripts/tests/run-harness-checks.sh --tier0
```

Inject-revert proof:

```bash
bash scripts/tests/check-default-template-parity.sh
bash scripts/tests/run-harness-checks.sh --tier0
```

Result:

- `bash -n scripts/tests/check-default-template-parity.sh`: PASS
- `bash -n scripts/tests/run-harness-checks.sh`: PASS
- `bash scripts/tests/check-default-template-parity.sh`: PASS (`workflow_mdc`, `git_workflow_rule`)
- `bash scripts/tests/run-harness-checks.sh --tier0`: PASS
- temp root inject-revert proof:
  - `workflow_mdc` default tracked file에 injected row 추가 시 helper FAIL, tier0 FAIL 재현
  - `git_workflow_rule` default tracked file에 injected advisory block line 추가 시 helper FAIL, tier0 FAIL 재현

## Risk / Reversal Cost

| Item | Assessment |
| --- | --- |
| 위험도 | L2 — rule/template/scaffold verification surface 변경 |
| 실행 모드 | Standard Work |
| Reversal cost | Low-Medium — helper+tier0 wiring은 되돌리기 쉽지만 wrong normalization contract를 고르면 후속 정리가 필요 |
| Main risk | pair-specific logic가 CI parity 후보나 broader hook/doc rewrite로 번지는 것 |
| Control | pair inventory first, explicit Non-Goals, R0 before implementation, helper+tier0 default, `git-workflow.md` normalization contract 선확정 |

## Open Questions

| ID | Question | Default Assumption |
| --- | --- | --- |
| OQ-1 | assertion home은 `check-scaffold-invariants.sh`인가, pair helper + runner wiring인가? | pair helper + `run-harness-checks.sh --tier0` wiring을 기본안으로 둔다 |
| OQ-2 | `git-workflow.md` normalization은 어떤 방식으로 비교할 것인가? | raw full-file diff는 부적합. Phase 1에서 reconstruction / normalized diff fingerprint / section-presence check 중 1개를 확정하고 기록한 뒤 Phase 2로 진입 |
| OQ-3 | future pair coverage는 explicit registry가 필요한가? | Yes. helper 내부 pair registry comment 또는 동급 inline 목록으로 명시해 누락을 visible하게 만든다 |
| OQ-4 | maintainer docs update가 정말 필요한가? | 기본은 No. operator command가 실제로 바뀔 때만 source-only docs를 최소 수정 |

## Approval / State

| Item | Status |
| --- | --- |
| 위험도 | L2 |
| 실행 모드 | Standard Work |
| Branch Isolation | PASS — `feature/chore-20260613-015-template-parity-assertion` |
| Tool rule reference | `.claude/rules/docs-workflow.md`, `.claude/rules/git-workflow.md`, DR-007 applies |
| Troubleshooting | Not Applicable |
| PLAN impact | `docs/PLAN.md` 강제 로드 조건 아님. 현재 PLAN 영향 없음 |
| STATUS proposal | R0 합의 전 `docs/STATUS.md` 변경 없음. 착수 pointer 추가가 필요하면 `CHORE-20260613-015` 대상으로 별도 승인 제안 |
| STATUS finalization | `docs/STATUS.md` Active Work pointer는 원래 비어 있어 제거 대상 없음. Last updated / Recent Decisions만 반영 |
| State machine | END — Work Done + archive 처리 완료, commit/PR finalization 대기 |

## Claude R0 Review Request

Claude R0 plan review 요청: CHORE-20260613-015 Default Template Canonical Parity Assertion

Review focus:

1. backlog 의도대로 범위가 `source canonical ↔ default variant` parity에만 닫혀 있는가?
2. allowed delta를 semantic contract로 다루려는 접근이 두 pair 모두에 적절한가?
3. assertion 위치 후보(`check-scaffold-invariants.sh` 확장 vs helper + runner wiring)가 scope/reversal cost 측면에서 균형적인가?
4. future pair coverage를 explicit registry로 다루려는 방향이 과설계가 아닌가?
5. verification이 plan 단계와 implementation 단계로 충분히 분리되어 있는가?
6. Cross-Agent Review And Discussion / Round Log 구조가 findings 누적에 충분한가?

Please respond in this format:

```text
Approval: Approved | Conditional Hold | Hold

Findings
- F1 (Must-fix/Nice-to-have): ...

Review Questions
| Question | Answer |
| --- | --- |
| Scope closed to default-template parity only? | ... |
| Semantic allowed-delta approach sound? | ... |
| Assertion home balanced? | ... |
| Future pair coverage overdesigned? | ... |
| Verification split sufficient? | ... |

Round Log Entry
| Round | Reviewer | Status | Summary | Follow-Up |
| --- | --- | --- | --- | --- |
| R0 | Claude | ... | ... | ... |
```

## Claude R1 Review Request

Claude R1 result review 요청: CHORE-20260613-015 Default Template Canonical Parity Assertion

Changed files:

- `scripts/tests/check-default-template-parity.sh`
- `scripts/tests/run-harness-checks.sh`
- `docs/works/harness/CHORE-20260613-015-default-template-canonical-parity-assertion.md`
- `docs/works/harness/README.md`

Review focus:

1. `git-workflow.md` normalization contract가 helper 구현과 정확히 일치하는가?
2. helper+tier0 분리가 `check-scaffold-invariants.sh`와의 책임 경계를 깔끔하게 유지하는가?
3. pair registry를 helper comment로 둔 것이 lightweight하면서도 누락 가시성 측면에서 충분한가?
4. PASS/FAIL inject-revert proof가 두 pair 모두에서 설계 의도를 충분히 보여주는가?
5. 이번 구현이 backlog 비범위(CI parity, source-gitflow shipped template, broader hook/doc rewrite)를 넘지 않았는가?
6. 남은 closeout risk나 추가 verification gap이 있는가?

Please respond in this format:

```text
Approval: Approved | Conditional Hold | Hold

Findings
- F1 (Must-fix/Nice-to-have): ...

Review Questions
| Question | Answer |
| --- | --- |
| Normalization contract implemented correctly? | ... |
| Helper/tier0 boundary clean? | ... |
| Pair registry lightweight but sufficient? | ... |
| Inject-revert proof sufficient? | ... |
| Scope stayed closed? | ... |

Round Log Entry
| Round | Reviewer | Status | Summary | Follow-Up |
| --- | --- | --- | --- | --- |
| R1 | Claude | ... | ... | ... |
```

## Cross-Agent Review And Discussion

### Round Log

| Round | Reviewer | Status | Summary | Follow-Up |
| --- | --- | --- | --- | --- |
| R0 | Claude | Approved | scope 적절, `workflow.mdc` pair 접근 clean. `git-workflow.md` normalization approach는 Phase 2 전 Phase 1 설계 산출물로 확정 필요(F1). registry 위치 구체화(F2), tier0 wiring 선결정(F3)은 nice-to-have | F1 must-resolve before Phase 2. Phase 1 완료 시 normalization approach를 Work 파일에 기록하고 구현 진입 전 확인 |
| R1 | Codex | Result | `check-default-template-parity.sh`를 신설해 pair registry를 명시하고, `workflow_mdc`는 row-removal reconstruction, `git_workflow_rule`은 advisory preface insertion + source-gitflow-only block rewrite reconstruction으로 expected default를 재구성해 tracked default와 비교하도록 구현했다. `run-harness-checks.sh --tier0`에 helper 실행을 배선했고, 실제 source에서는 PASS, temp root inject-revert로 두 pair 모두 helper FAIL / tier0 FAIL을 재현했다. | Claude R1 result review 요청 |
| R1 | Claude | Approved | R0 must-resolve 3건(normalization 확정, registry 위치, tier0 wiring)이 모두 구현에 반영됐다. inject-revert FAIL/PASS와 tier0 OVERALL: PASS 확인. 추가 차단 사유 없음. | Nice-to-have만 반영 후 closeout 진행 가능 |

### Finding Disposition

| Finding | Codex Disposition | Rationale / Action |
| --- | --- | --- |
| R0-F1 | Accepted | `git-workflow.md`는 단순 필터가 아니라 양방향 변환이므로 OQ-2를 "Yes" 전제에서 구현 전 결정 항목으로 수정했다. Phase 1에 normalization approach 확정 단계를 추가하고, Done Criteria에도 구현 전 확정 항목을 명시했다. |
| R0-F2 | Accepted | future pair coverage의 위치를 helper 내부 pair registry comment 또는 동급 inline 목록으로 좁혔다. Done Criteria도 assertion script registry 명시 기준으로 보강했다. |
| R0-F3 | Accepted | source-level pair drift 검출은 scaffold 생성이 필요 없으므로 helper + `run-harness-checks.sh --tier0` wiring을 기본안으로 승격했다. verification과 risk/control 문구도 이에 맞춰 정렬했다. |
| R1-F1 | Accepted | `emit_expected_git_default`의 Branch Flow 치환이 EOF까지 trim된다는 의도를 awk 블록에 comment 1줄로 보강했다. 동작 변경은 없고 유지보수 가시성만 높인다. |
| R1-F2 | Noted | inject-revert 중 `cp -i` alias로 restore prompt가 생길 수 있다는 관찰은 helper 결함이 아니라 검증 shell 환경 이슈다. Work 범위 변경 없이 observation으로만 기록한다. |

## Discovery

- 2026-06-13: backlog candidate `default template ↔ canonical parity assertion (`workflow.mdc` / `git-workflow.md`)` 착수.
- 2026-06-13: Branch Isolation Check — `develop` + `policy_type: source-gitflow`로 시작했으므로 `feature/chore-20260613-015-template-parity-assertion` branch를 생성해 planning surface를 분리했다.
- 2026-06-13: `.cursor/rules/workflow.mdc` pair는 현재 `work-doc` row 1개만 intentional delta임을 확인했다.
- 2026-06-13: `.claude/rules/git-workflow.md` pair는 advisory-only posture 추가 + source-gitflow 전용 section 제거가 intentional delta임을 확인했다.
- 2026-06-13: `scripts/create-harness.sh`는 두 pair 모두 create-time 분기만 제공하고, 현재 source에는 pair parity drift를 직접 fail시키는 deterministic guard가 없다.
- 2026-06-13: Claude R0 Approved 수신. F1(`git-workflow.md` normalization approach)은 Phase 2 전 필수 정리 항목으로 수용했고, F2(pair registry 위치)·F3(helper+tier0 wiring)는 plan에 선반영했다.
- 2026-06-13: Phase 1 결정 확정 — `git-workflow.md` normalization은 reconstruction 채택. advisory-only preface 삽입, Branch Isolation Check 제거, tracking-only trailer 제거, detailed Branch Flow를 generic 2문장으로 치환한 expected default를 helper가 재구성한다.
- 2026-06-13: `scripts/tests/check-default-template-parity.sh` 신설, helper 상단에 explicit pair registry 추가. `run-harness-checks.sh --tier0`에서 source-level parity를 실행하도록 배선했다.
- 2026-06-13: validation PASS — `bash -n` 2종, helper PASS, `run-harness-checks.sh --tier0` PASS.
- 2026-06-13: temp root inject-revert proof 완료 — `workflow_mdc` row drift와 `git_workflow_rule` advisory block drift 각각에 대해 helper FAIL 및 tier0 FAIL 재현.
- 2026-06-13: Claude R1 Approved 수신. R0 must-resolve 3건 모두 충족 확인. Nice-to-have로 `emit_expected_git_default`의 Branch Flow trim-to-EOF 의도 comment를 추가했다. inject-revert 중 `cp -i` alias prompt 충돌은 shell 환경 observation으로만 기록한다.
- 2026-06-13: `/work-close` 처리. Done Criteria 전부 충족 확인, backlog candidate 제거, archive 즉시 진행. `docs/STATUS.md` Active Work는 원래 비어 있어 pointer 제거는 불필요했고, Last updated / Recent Decisions만 갱신 대상으로 남겼다.
