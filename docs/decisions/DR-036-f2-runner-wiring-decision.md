# DR-036: F2 Runner / CI Wiring Decision

Date: 2026-06-13
Status: Accepted
Track: harness
Linked DRs: DR-018, DR-020, DR-033, DR-035

## Question

`scripts/tests/run-harness-checks.sh`(harness 검증 척추 tier runner)를 CI required check 또는 pre-commit/hook에 배선해야 하는가? (DR-035 §6 Slice 3, backlog `Validation Spine residual follow-ups`의 F2)

## Decision

**배선하지 않는다(no-wiring).** `run-harness-checks.sh`는 CI required check로도, pre-commit/hook gate로도 배선하지 않고 **maintainer local 검증 도구**로 유지한다. runner의 자동 surfacing이 필요해지면 enforcement gate가 아니라 `/repo-health` surface(F4)에서 별도로 다룬다.

## Context

착수 시점 검증 표면별 실측:

| 검증 항목 | `ci.yml` (source) | `pre-commit` | `run-harness-checks.sh` |
| --- | --- | --- | --- |
| `bash -n create-harness.sh` | 상시 | staged 시 | tier0 |
| `git diff --check` (whitespace) | `diff-tree` 상시 | 상시 | tier0 |
| shipped DR closure | 없음 | staged 시 (hard gate) | tier1 |
| scaffold invariants (`check-scaffold-invariants.sh`) | 자체 inline 재구현 | 없음 | tier1/tier2 (SSoT 호출) |
| scaffold 실제 생성 (tier2 ×3 mode) | inline 유사 assertion | 없음 (과중) | tier2 |

- runner는 현재 **자동 호출이 0건**이다(수동 실행만). CI도 pre-commit도 runner를 호출하지 않는다.
- enforcement는 이미 두 표면이 제공한다: PR 시점 `ci.yml`(required-check 가능), commit 시점 `pre-commit`.

## Options Considered

| Option | 장점 | 단점 | 판단 |
| --- | --- | --- | --- |
| A. 무배선 + 근거 명문화 | runner가 오케스트레이션하는 검사(`bash -n`, `git diff --check`, DR closure)는 이미 `ci.yml`·`pre-commit`에서 강제됨. 변경 0, Simplicity First | runner 고유가치(invariants SSoT 호출)가 자동화되지 않은 채 남음 | **채택** |
| B. CI를 runner SSoT로 수렴 | `ci.yml`이 runner를 호출하면 invariants SSoT 단일화, drift↓ | `ci.yml`은 runner보다 넓은 검사(phrase scan, gate-config functional, commit format)를 보유 → 완전 대체 불가. 부분 중복 또는 전 CI 검사를 runner로 이관(scope 확장) | 비채택 |
| C. tier0를 pre-commit에 배선 | 빠른 local 통합 gate | pre-commit이 이미 `git diff --check` + 조건부 `bash -n` 수행 → 한계효용 낮음. 매 commit 전체 `*.sh` syntax로 약간 느려짐. tier2는 과중 | 비채택 |

## Rationale

핵심 판단 기준은 "runner가 오케스트레이션하는 검사가 **이미 enforcement되고 있는가**"다.

- runner tier0/tier1이 호출하는 `bash -n`, `git diff --check`, shipped DR closure는 이미 `ci.yml`과 `pre-commit`에서 강제된다. runner를 배선해도 동일 검사가 중복될 뿐 enforcement 공백을 메우지 않는다.
- runner tier2(scaffold 실제 생성 ×3 mode)는 pre-commit에 넣기엔 과중하고, CI는 이미 동등한 scaffold assertion을 inline 수행한다.
- runner의 진짜 고유가치는 `check-scaffold-invariants.sh`(invariants SSoT)를 실제 scaffold 생성과 함께 호출한다는 점인데, 이는 commit/PR을 차단하는 enforcement보다 **maintainer가 주기적으로 호출하는 검증 / repo-health surface** 성격에 가깝다. 따라서 배선 대상은 gate가 아니라 F4(repo-health)다.
- reversal cost가 Low("아무것도 안 함")이므로 이 결정의 가치는 되돌리기 보호가 아니라, 2026-06-08부터 세 차례 deferral된 F2를 **재론 없이 닫는 것(anti-re-litigation)**에 있다.

## Consequences

- `run-harness-checks.sh`는 manual-only로 유지된다. CI/hook은 변경하지 않는다.
- runner 자동 surfacing이 필요하면 F4(`runner 결과를 /repo-health에 surface`, 현재 Candidate·미구현)에서 별도로 다룬다. 이 DR은 F4를 구현하거나 대체하지 않는다.
- backlog `Validation Spine residual follow-ups (F1-F4)`의 F2는 이 DR로 흡수·종결한다. F1/F3/F4는 해당 항목에 그대로 잔존한다.
- backlog `문서-only 규칙 강제화`의 "남은 구현 범위: Runner / CI / F2 wiring decision"은 이 DR로 resolved 처리한다. 단 DR-035 follow-up split 전체가 닫히는 것이며, 이는 별도 `Validation Spine residual`의 F1/F3/F4와 무관하다.
- **Residual (F2 범위 밖, routing):** `ci.yml`이 `check-scaffold-invariants.sh`(invariants SSoT)를 호출하지 않고 scaffold assertion을 inline 재구현하므로, 두 표면이 발산할 drift 위험이 남는다. 무배선 결정은 이 drift를 자동으로 해소하지 않는다. 이는 "F2 배선 여부"가 아니라 CI↔SSoT parity 문제이므로 별도 backlog candidate로 다룬다(저빈도·저피해 — parity 점검 성격).

## Reversal Cost

Low — 코드 변경이 없으므로 결정 자체에 구조적 부채가 없다. 후일 배선이 필요하다고 판단되면 CI 또는 hook에 runner 호출을 추가하면 되고, 그때 이 DR을 superseding 결정으로 갱신한다.

## Linked Work

- CHORE-20260613-011
</content>
