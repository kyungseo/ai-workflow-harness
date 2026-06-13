---
id: CHORE-20260613-016
priority: P3
status: Archived
risk: L2
scope: source CI inline scaffold assertion과 `scripts/tests/check-scaffold-invariants.sh` 사이의 parity drift 실해악을 정량화하고, 필요 시 최소 parity 수단을 결정·구현한다. R0 전 구현 없음.
appetite: 0.5d
planned_start: 2026-06-13
planned_end: 2026-06-13
actual_end: 2026-06-13
related_dr: [DR-036]
related_troubleshooting: []
related_work: [CHORE-20260613-011, CHORE-20260613-015, CHORE-20260613-004]
---

# CHORE-20260613-016: CI Inline Assertion ↔ Invariants SSoT Parity

## Top Summary

- **목표:** `.github/workflows/ci.yml`의 inline scaffold assertion과 `scripts/tests/check-scaffold-invariants.sh`의 invariant SSoT 사이에 실제 drift 위험이 얼마나 있는지 먼저 정량화하고, 필요하면 최소 parity guard 또는 부분 수렴안을 설계한다.
- **왜 지금:** CHORE-20260613-011 / DR-036에서 F2 runner wiring은 무배선으로 닫았고, 그 과정에서 남은 residual이 바로 "CI가 invariants SSoT를 호출하지 않는다"는 점이었다. 지금 남은 질문은 "이게 실제로 위험한 drift인가, 아니면 역할이 다른 두 표면인가"다.
- **핵심 경계:** 이번 Work는 CI required-check 전체 재설계나 runner wiring 재론이 아니다. **CI inline assertion ↔ invariants SSoT parity**만 다룬다.
- **역할:** Codex = author/driver, Claude = reviewer. 구현 전 Claude R0 plan review, 구현 후 result review를 받는다.

## Candidate Fit

1. W4 잔여 후보 중 바로 앞 Work(CHORE-20260613-015)와 이어지는 검증 parity 주제라 momentum이 좋다.
2. 다만 scope가 미묘하다. CI에는 invariants 밖의 source-only assertion도 많아서, "전부 SSoT로 수렴"은 쉽게 과확장된다.
3. 그래서 이번 slice는 **실해악 정량화 + 경계 판정 + 최소 선택지 제안**까지를 우선 목표로 둔다.

## Context Manifest

| 순서 | 파일 | 섹션 | 왜 |
| --- | --- | --- | --- |
| 1 | `docs/backlog/HARNESS.md` | `CI inline assertion ↔ invariants SSoT parity` | 후보 정의, 비판적 framing, Done Criteria |
| 2 | `.github/workflows/ci.yml` | `validate` job | 현재 inline assertion 범위 실측 |
| 3 | `scripts/tests/check-scaffold-invariants.sh` | 전체 | invariants SSoT 현재 범위 확인 |
| 4 | `scripts/tests/run-harness-checks.sh` | tier0/tier1/tier2 | runner 경계와 F2 무배선 결정 영향 확인 |
| 5 | `docs/archive/docs/works/harness/CHORE-20260613-011-f2-wiring-decision.md` | Background / Discovery | residual 등록 근거 재확인 |
| 6 | `docs/maintainer/VERIFICATION-COMMANDS.md` | executable assertion 경계, Layer C 관련 문단 | source-only maintainer verification 문구와 SSoT pointer 확인 |

Trigger: W4 backlog candidate 착수. 직전 Work에서 default template parity guard를 닫았고, 다음 자연스러운 검증 parity 후보로 이어진다.

## Current Facts

| Surface | Current Role | Observation |
| --- | --- | --- |
| `.github/workflows/ci.yml` | source required check | generic/source-gitflow scaffold 생성 후 phrase/reference/posture/hook/gate-config 등 다수 assertion을 **inline**으로 수행한다 |
| `scripts/tests/check-scaffold-invariants.sh` | scaffold invariant SSoT | no-dangling-reference, no-source-only-leakage, decisions/README closure, root README optional docs, manifest self-consistency를 canonical하게 검사한다 |
| `scripts/tests/run-harness-checks.sh` | maintainer runner | tier1/tier2에서 invariants SSoT를 호출하지만, DR-036 결정으로 CI/pre-commit에는 자동 배선하지 않는다 |

초기 read-only 사실:

1. CI는 `check-scaffold-invariants.sh`를 직접 호출하지 않는다.
2. CI의 inline 검사는 invariants와 **부분 overlap**이 있지만 동일 집합이 아니다.
3. 특히 source-gitflow shipped hook/harness-validate assertions과 generic advisory posture 검사는 invariants의 직접 범위 밖이다.
4. 따라서 parity 논의는 "전부 일치해야 한다"보다 **overlap subset에서 drift가 실제로 위험한가**로 좁히는 것이 자연스럽다.

## Scope / Non-Goals

### Scope

1. CI inline scaffold assertion 목록과 invariants SSoT 검사 항목을 surface-by-surface로 대조한다.
2. overlap / CI-only / invariant-only를 분류하고, overlap 영역의 drift 실해악을 정량화한다.
3. 선택지를 아래 셋으로 제한해 비교한다.
   - A. no-action with explicit rationale
   - B. lightweight static parity check
   - C. partial convergence where CI calls invariant SSoT for the overlapping subset
4. R0 승인 후 선택된 최소 구현만 적용한다.

### Non-Goals

- `run-harness-checks.sh`를 CI required check나 pre-commit gate에 배선하는 재논의
- `.github/workflows/ci.yml` 전체 구조 재설계
- `check-scaffold-invariants.sh`의 invariant scope를 넓히기 위한 broad rewrite
- source-gitflow hook/harness-validate assertions 전체를 invariants로 흡수
- repo-health surface(F4) 구현

## Files

### Plan / Tracking

| File | Plan |
| --- | --- |
| `docs/works/harness/CHORE-20260613-016-ci-inline-invariants-parity.md` | Work SSoT |
| `docs/works/harness/README.md` | Active Work index row |

### Expected Implementation Surfaces (R0 승인 후)

| File | Purpose |
| --- | --- |
| `.github/workflows/ci.yml` | partial convergence나 lightweight static parity가 CI에 닿을 때만 |
| `scripts/tests/check-scaffold-invariants.sh` | overlap subset 경계가 여기로 이동할 때만 |
| `scripts/tests/run-harness-checks.sh` 또는 신규 helper | static parity helper가 필요할 때 |
| `docs/maintainer/VERIFICATION-COMMANDS.md` | source-only verification 문구가 실제 바뀔 때만 최소 반영 |

## Plan

### Phase 0 — R0 Plan Review

1. Work file + Active index row만 생성한다.
2. Claude R0 plan review를 요청한다.
3. R0 findings를 `Cross-Agent Review And Discussion`에 누적한다.
4. R0 승인 또는 must-fix 반영 전 구현하지 않는다.

### Phase 1 — Drift Harm Quantification

1. **분류 granularity는 CI step 단위로 고정**한다. `validate` job의 scaffold 관련 step 7개를 상한으로 삼고, step 내부 grep/rg clause를 추가 row로 쪼개지 않는다.
2. CI inline assertion 목록을 step 단위 논리 항목으로 분해한다.
3. invariants SSoT 검사 항목을 동일 granularity로 매핑한다.
4. 항목을 `Overlap / CI-only / Invariant-only / Out-of-scope`로 분류한다.
5. overlap 항목별 drift 실해악을 아래 기준으로 적는다.
   - 실제 user-visible regression 가능성
   - 이미 다른 check/hook에서 걸리는지
   - stale 발생 시 발견 시점이 얼마나 늦어지는지

### Phase 2 — Option Decision (R0 승인 후)

1. A/B/C 셋 중 하나를 선택한다.
2. 선택 기준:
   - scope 최소성
   - existing boundary 보존
   - regression signal strength
   - reversal cost
3. 구현이 필요하면 overlap subset에만 닿는 최소 change로 제한한다.

### Phase 3 — Validation And Review

1. source-level verification을 실행한다.
2. Claude result review 요청과 findings disposition을 기록한다.
3. `docs/STATUS.md` / backlog / Work closeout은 승인 후 묶어 처리한다.

## Done Criteria

- [x] CI inline assertion 목록과 invariants SSoT 항목이 동일 비교 단위로 분해된다.
- [x] overlap / CI-only / invariant-only 구분이 Work 파일에 기록된다.
- [x] overlap 영역의 drift 실해악이 정량 또는 명시적 rationale로 평가된다.
- [x] no-action / static parity / partial convergence 중 1개가 선택되거나, no-action 근거가 명문화된다.
- [x] no-action을 선택하면 Work 파일 Phase 2에 rationale이 남고, closeout 시 backlog candidate 정리 근거로 재사용 가능해야 한다.
- [x] 구현이 있을 경우 scope가 overlap subset 또는 parity helper로 제한된다.
- [x] CHORE-20260613-011의 residual framing과 모순되지 않는다.
- [x] Claude R0 plan review와 result review가 기록된다.

## Verification

### Plan Verification

```bash
git status --short --branch
git diff --check
rg -n "check-scaffold-invariants|harness-validate|advisory-only|manifest|gate config|phrase-check" .github/workflows/ci.yml scripts/tests/check-scaffold-invariants.sh scripts/tests/run-harness-checks.sh
```

### Expected Implementation Verification

```bash
bash -n scripts/tests/check-scaffold-invariants.sh
bash -n scripts/tests/run-harness-checks.sh
```

If CI/parity helper changes are approved:

```bash
bash scripts/tests/run-harness-checks.sh --tier0
# plus targeted source-level parity/inject proof depending on selected option
```

## Risk / Reversal Cost

| Item | Assessment |
| --- | --- |
| 위험도 | L2 — CI/workflow verification surface 조정 가능성 |
| 실행 모드 | Standard Work |
| Reversal cost | Low-Medium — static helper는 되돌리기 쉽지만 CI/invariant 경계를 잘못 합치면 후속 분리 비용이 생긴다 |
| Main risk | "parity"를 명분으로 CI inline 검사 전체를 invariants SSoT로 몰아 broad rewrite가 되는 것 |
| Control | overlap subset first, explicit Non-Goals, R0 before implementation, option set A/B/C 고정 |

## Open Questions

| ID | Question | Default Assumption |
| --- | --- | --- |
| OQ-1 | overlap subset이 실제로 충분히 크고 중요해서 parity action이 필요한가? | 아직 미정. Phase 1에서 정량화 후 결정 |
| OQ-2 | 가장 자연스러운 최소안은 static parity helper인가? | 기본은 Yes. runner wiring 재론 없이 source-level signal을 추가할 수 있으면 가장 작다 |
| OQ-3 | partial convergence가 필요하면 CI가 invariants SSoT를 직접 호출해야 하는가? | overlap subset이 명확하고 CI-only assertion과 깔끔히 분리될 때만 검토 |
| OQ-4 | no-action으로 닫는 것도 정당한가? | Yes. overlap drift 실해악이 낮고 existing checks로 충분히 잡힌다면 rationale 문서화만으로 종결 가능 |

## Approval / State

| Item | Status |
| --- | --- |
| 위험도 | L2 |
| 실행 모드 | Standard Work |
| Branch Isolation | PASS — `feature/chore-ci-inline-invariants-parity` |
| Tool rule reference | `.claude/rules/docs-workflow.md`, `.claude/rules/git-workflow.md`, DR-007 applies |
| Troubleshooting | Not Applicable |
| PLAN impact | `docs/PLAN.md` 강제 로드 조건 아님. 현재 PLAN 영향 없음 |
| STATUS proposal | closeout 번들에서 Recent Decisions / Next Actions / Last updated 갱신 완료 |
| State machine | DONE — result review 승인 후 archive까지 완료 |

## Claude R0 Review Request

Claude R0 plan review 요청: CHORE-20260613-016 CI Inline Assertion ↔ Invariants SSoT Parity

Review focus:

1. 후보 framing이 "drift 실해악 정량화 first"로 충분히 닫혀 있는가?
2. A/B/C 선택지가 scope를 지나치게 넓히지 않으면서도 decision-ready한가?
3. overlap / CI-only / invariant-only 분류가 이 후보의 핵심 질문을 푸는 데 적절한가?
4. `run-harness-checks.sh` wiring 재론이나 broad CI rewrite로 새지 않도록 Non-Goals가 충분한가?
5. no-action으로 닫을 가능성과 partial convergence 가능성을 동시에 공정하게 열어두었는가?
6. Round Log / Finding Disposition 구조가 다음 review를 누적하기에 충분한가?

Please respond in this format:

```text
Approval: Approved | Conditional Hold | Hold

Findings
- F1 (Must-fix/Nice-to-have): ...

Review Questions
| Question | Answer |
| --- | --- |
| Harm quantification framing sound? | ... |
| Option set balanced? | ... |
| Overlap classification useful? | ... |
| Non-Goals tight enough? | ... |
| No-action / convergence both fairly framed? | ... |

Round Log Entry
| Round | Reviewer | Status | Summary | Follow-Up |
| --- | --- | --- | --- | --- |
| R0 | Claude | ... | ... | ... |
```

## Cross-Agent Review And Discussion

### Round Log

| Round | Reviewer | Status | Summary | Follow-Up |
| --- | --- | --- | --- | --- |
| R0 | Claude | Approved | framing 적절, option set balanced, Non-Goals 충분. F1: Phase 1 분류 granularity 상한(CI step 단위) 선행 고정 권고. F2: Done Criteria에 no-action 산출물 기준 추가 권고. F3: 실측상 no-action(A)이 likely 결과로 관찰되나, Phase 1이 이를 직접 도출해야 설득력 있음 | F1/F2 반영 후 Phase 1 진행 |
| R1 | Claude | Approved | overlap 분류 sound, no-action 결론 Phase 1 데이터로 충분히 지지됨. adjacency vs overlap 판단 타당. F1: invariant-only 항목이 왜 CI required gate 대상이 아닌지 한 줄 보강 권고 | F1 보강 후 closeout 진행 가능 |

### Finding Disposition

| Finding | Codex Disposition | Rationale / Action |
| --- | --- | --- |
| F1 | Accepted | Phase 1 분류 단위를 `CI step 단위`로 고정해 row 폭증을 막고, Work 파일 본문에 상한을 명시했다. |
| F2 | Accepted | Done Criteria에 "no-action 선택 시 Work 파일 Phase 2 rationale + closeout 근거 재사용 가능" 기준을 추가했다. |
| F3 | Accepted as observation | no-action이 likely하다는 관찰은 채택하되, 결론은 직접 분류/실해악 평가 후 Work 파일에 독립적으로 도출한다. |
| R1-F1 | Accepted | invariant-only [1]/[3]/[4]가 CI required gate 대상이 아닌 이유를 Drift Harm/Phase 1 결론에 한 줄로 명시해 재질문 여지를 줄였다. |

## Phase 1 Findings

### 분류 규칙

- granularity: `CI step 단위`
- 비교 범위: `validate` job 중 scaffold output / scaffold mode / manifest / gate posture와 직접 관련된 7개 step만 포함
- 제외: whitespace, shell syntax, commit format, stale runtime identity는 scaffold invariant parity 후보가 아니므로 Out-of-scope

### CI Step ↔ Invariants 매핑

| CI step | 분류 | nearest invariant | 판단 메모 |
| --- | --- | --- | --- |
| Validate generic scaffold dry-run | CI-only | — | generator smoke test다. invariants script는 생성된 target의 구조를 검사하며, dry-run 성공 자체는 다루지 않는다. |
| Check scaffold output for source-only phrases | Overlap (partial) | [2] no-source-only-leakage | 둘 다 generic scaffold에 source-only 흔적이 새는지 막는다. 다만 CI는 특정 phrase blacklist, invariant는 runtime identity/path leakage를 본다. |
| Check scaffold output for broken artifact references | Overlap (partial) | [2] no-source-only-leakage 계열 | generic scaffold의 source-only artifact/reference 누수를 막는다는 점에서 같은 계열이지만 predicate는 다르다. `docs/GIT-WORKFLOW.md` unconditional load, `tools/git-hooks/install.sh` reference는 invariant [2]의 현재 정규식 범위 밖이다. |
| Validate generic scaffold has no gate hooks (advisory-only) | CI-only | — | generic의 advisory-only posture를 source-level hard gate로 본다. invariants는 generic/source-gitflow posture 차이를 canonical SSoT로 관리하지 않는다. |
| Validate generic advisory posture (c3) | CI-only (manifest/--check touchpoint only) | [5] partial adjacency | README/rule/manifest/`--check`의 advisory posture 일치 검증이다. invariant [5]는 manifest shape + drift 0 자기일관성이지 posture semantic parity는 아니다. |
| Validate source-gitflow scaffold deploys gate hooks | CI-only | [5] partial adjacency | source-gitflow shipped hook/workflow presence와 권한, docs guidance, manifest listing을 본다. invariants는 이 shipped mode-specific correctness를 직접 다루지 않는다. |
| Validate product-adaptive gate config (c4) | CI-only (manifest/--check touchpoint only) | [5] partial adjacency | `.harness/gate-config` seed/functional behavior/`--check` report를 검증한다. invariant [5]와 manifest/`--check` 접점은 있으나 목적이 다르다. |

### Invariant-only 항목

| Invariant | CI 대응 여부 | 메모 |
| --- | --- | --- |
| [1] core A-class no-dangling-reference | 없음 | scaffold core 문서의 DR closure는 CI inline step에 없다. maintainer-facing structural correctness 성격이다. |
| [1r] Optional-pack report-only dangling | 없음 | optional pack report-only 정책은 CI hard gate가 아니라 invariant 보고 성격이다. |
| [3] decisions/README index closure | 없음 | scaffold decisions index closure는 CI validate에 없다. |
| [4] root README ↔ optional docs on-disk parity | 없음 | optional docs listing parity는 CI에서 직접 점검하지 않는다. |
| [5] manifest shape + drift 0 self-consistency | 부분만 간접 overlap | CI는 posture/gate-config에서 manifest/`--check` 일부를 건드리지만, invariant [5] 전체를 대체하지 않는다. |

### Drift Harm 평가

| Overlap family | Drift scenario | Harm | Existing catch | Assessment |
| --- | --- | --- | --- | --- |
| source-only leakage family | invariant [2]가 바뀌었는데 CI phrase/reference step은 그대로 남음 | Low-Medium | CI 자체가 현재 알려진 failure mode를 hard-gate로 막고, invariant runner는 maintainer가 tier1/tier2로 별도 실행 가능 | "같은 문제를 같은 predicate로 보는" 관계가 아니라 drift가 곧 regression blind spot으로 직결되지는 않는다. |
| manifest / `--check` touchpoint family | invariant [5]가 바뀌었는데 CI c3/c4/source-gitflow step이 그대로 남음 | Low | CI는 posture/gate-config regression을, invariant는 manifest shape/drift 0을 본다 | overlap보다 adjacency가 더 크다. parity helper를 만들면 오히려 서로 다른 의미를 억지로 한 축에 묶게 된다. |
| invariant-only structural family ([1]/[3]/[4]) | "CI에 같은 step이 없다" | Low | maintainer는 `check-scaffold-invariants.sh` / tier1·tier2 runner로 structural correctness를 별도 검증한다 | 이 항목들은 maintainer-facing deep structure 검사라 CI required gate 대상이 아니다. source required check로 끌어오지 않아도 boundary상 자연스럽다. |

### Phase 1 결론

1. 실제 overlap은 **작고 부분적**이다. 대부분은 동일 검사를 중복 구현한 것이 아니라, 비슷한 scaffold surface를 각기 다른 목적에서 본다.
2. CI는 `known failure modes`를 hard gate로 막는 source required check이고, invariants는 `deep scaffold structural correctness`를 보는 maintainer-side SSoT다.
3. 따라서 residual의 실해악은 "동일 의미 검사가 두 군데에 중복돼 따로 진화한다"기보다, "비슷한 표면을 다른 추상도에서 본다"에 가깝다.
4. invariant-only [1]/[3]/[4]는 structural correctness 성격의 maintainer-facing 검사이므로 CI required gate에 없다는 사실 자체가 gap은 아니다. 별도 action은 불필요하다.

## Phase 2 Decision

### 선택

- **A. no-action with explicit rationale**

### 선택 이유

1. overlap subset이 작아서 parity helper를 따로 두어도 실질적으로 동기화할 항목이 많지 않다.
2. B(static parity helper)는 source-only leakage family와 manifest/`--check` family를 같은 모델로 환원해야 하는데, 현재는 predicate와 목적이 달라 helper가 오히려 boundary를 흐릴 가능성이 크다.
3. C(partial convergence)는 CI가 invariant SSoT를 직접 호출하더라도 CI-only step(advisory posture, source-gitflow shipped hook deploy, gate-config functional checks)을 제거하지 못한다. 결과적으로 inline CI + invariant 호출의 혼합만 늘고 단순화 효과가 작다.
4. DR-036 residual closeout 관점에서도, "왜 무조치가 정당한지"를 Work 파일에 명문화하는 편이 더 정직하다.

### no-action 산출물 기준

- 이 Work 파일의 Phase 1/2에 overlap 분류와 rationale을 남긴다.
- result review 승인 후 backlog candidate closeout 근거로 재사용한다.
- `docs/STATUS.md`는 closeout 번들에서만 제안한다.

## Claude Result Review Request

Claude result review 요청: CHORE-20260613-016 CI Inline Assertion ↔ Invariants SSoT Parity

Review focus:

1. `CI step 단위` granularity로 정리한 overlap / CI-only / invariant-only 분류가 과도하게 뭉개지지 않았는가?
2. Phase 1 근거만으로 `no-action` 결론이 충분히 방어 가능한가?
3. `broken artifact references`, `c3`, `c4`를 invariant와 `partial overlap`이 아니라 `adjacency` 위주로 본 판단이 타당한가?
4. parity helper 또는 partial convergence를 채택하지 않은 이유가 boundary 보존 관점에서 충분히 설득력 있는가?
5. closeout 시 backlog candidate 제거만으로 충분한지, 추가 DR/문서 반영이 필요한 누락이 없는가?

Please respond in this format:

```text
Approval: Approved | Conditional Hold | Hold

Findings
- F1 (Must-fix/Nice-to-have): ...

Review Questions
| Question | Answer |
| --- | --- |
| Granularity sound? | ... |
| No-action conclusion supported? | ... |
| Adjacency vs overlap judgment sound? | ... |
| Boundary rationale sufficient? | ... |
| Closeout surface complete? | ... |

Round Log Entry
| Round | Reviewer | Status | Summary | Follow-Up |
| --- | --- | --- | --- | --- |
| R1 | Claude | ... | ... | ... |
```

## Discovery

- 2026-06-13: 다음 candidate로 `CI inline assertion ↔ invariants SSoT parity`를 선택. 현재 branch는 `feature/chore-ci-inline-invariants-parity`.
- 2026-06-13: `ci.yml`은 `check-scaffold-invariants.sh`를 직접 호출하지 않지만, generic advisory posture / source-gitflow hook deploy / gate-config checks 등 invariants 바깥 assertion도 다수 갖고 있음을 재확인했다.
- 2026-06-13: CHORE-20260613-011 Discovery와 일치하게, 이번 후보의 핵심은 "CI가 SSoT를 호출하지 않는다" 그 자체가 아니라 overlap subset drift가 실제로 위험한지 판정하는 데 있다.
- 2026-06-13: Claude R0 Approved. F1/F2를 반영해 분류 단위를 `CI step 단위`로 고정했고, no-action 산출물 기준을 Done Criteria에 추가했다.
- 2026-06-13: Phase 1 실측 결과, 실제 overlap은 `source-only leakage family`와 `manifest/--check touchpoint`의 일부 접점에 국한됐다. 대부분의 CI scaffold assertion은 invariant 재구현보다 source required-check 전용 known failure mode gate 성격이 강했다.
- 2026-06-13: Claude R1 Approved. invariant-only [1]/[3]/[4]가 CI required gate 대상이 아님을 Phase 1 결론에 보강했고, no-action 근거로 candidate를 closeout했다.
- 2026-06-13: archive 처리. negative result(`no-action with explicit rationale`)도 DR-036 residual closeout 근거로 재사용 가능하므로 live queue에서 내리고 archive-side index로 이전한다.
