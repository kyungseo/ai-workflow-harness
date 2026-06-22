# DR-040: Source-parity 검사 hook/CI 배선

Date: 2026-06-19
Status: Accepted
Track: harness
Linked DRs: DR-036, DR-033, DR-020

## Question

deterministic source-parity 검사 2종(`check-default-template-parity.sh`, `check-surface-mirror-parity.sh`)을 commit/CI 시점에 자동 배선해야 하는가? DR-036이 `run-harness-checks.sh`(runner) 무배선을 결정했는데, 이 결정이 두 parity 검사에도 적용되는가?

## Decision

**배선한다.** 두 parity 검사를 **직접 호출**로 `tools/git-hooks/pre-commit`과 `.github/workflows/ci.yml` 양쪽에 추가한다. `run-harness-checks.sh`(runner) 자체는 **여전히 무배선**(DR-036 불변) — runner를 경유하지 않고 두 스크립트만 직접 호출한다.

## Context

- 두 스크립트는 source 전용(adopter 부재 시 자체 SKIP/no-op), deterministic, 실측 각 ~50ms, false-positive≈0.
- 착수 전 실측: 두 검사는 `run-harness-checks.sh` tier0b/0c에서만 실행 = **manual-only, 자동 표면 호출 0건**.
- 실측 trigger: FEAT-20260618-001에서 `.cursor/rules/workflow.mdc`의 `work-brief` routing row가 `scripts/templates/default/**`에 미동기된 default-template drift가 #196(2026-06-15)~release 직전까지 약 2.5주 무탐지. release full-sweep(`run-harness-checks --all`)이 main 전에 잡았으나 도입~탐지 window가 실재.

## DR-036과의 관계 (non-applicability boundary)

DR-036을 supersede·amend하지 **않는다**. 독립 보완 DR이다.

- DR-036의 무배선 결정 근거는 *"runner가 오케스트레이션하는 검사(`bash -n`, `git diff --check`, shipped DR closure)가 이미 `ci.yml`·`pre-commit`에서 강제되고 있어, runner를 배선해도 동일 검사가 중복될 뿐"*이었다.
- 그러나 이 2종 parity 검사는 **어떤 자동 표면에서도 강제되지 않는다**. DR-036의 "이미 이중 커버됨" 논거가 이 둘에는 적용되지 않는 다른 fact pattern이다.
- DR-036 본문 Consequences의 Residual(F2 범위 밖, routing)이 *"CI↔SSoT parity 문제이므로 별도 backlog candidate로 다룬다"*고 이미 예고했다. 본 DR이 그 boundary를 이어받는다.
- runner는 여전히 무배선이다. runner tier0를 호출하면 이미 enforcement된 `bash -n`·`git diff --check`가 중복 부활하므로(DR-036이 기각한 구조), runner 경유가 아니라 **두 스크립트 직접 호출**로 범위를 좁힌다.

## Options Considered

| Option | 장점 | 단점 | 판단 |
| --- | --- | --- | --- |
| A. 직접 호출로 pre-commit + CI 양쪽 배선 | enforcement 공백 폐쇄. commit 시점(조기)+PR 시점(backstop) 이중 안전. 비용 무시 가능 | hook bypass·direct develop push는 여전히 미커버(아래 한계) | **채택** |
| B. CI-only | server-side, bypass 불가 | PR 열기 전까지 drift 허용. commit 시점 조기 차단 없음 | 비채택 — 약한 선택, low-cost인데 굳이 |
| C. pre-commit-only | 가장 빠른 차단(history 진입 전) | `--no-verify`·hook 미설치·remote commit에 취약 | 비채택 |
| D. runner tier0 호출 | 단일 진입점 | `bash -n`·`git diff --check` 중복 부활(DR-036 기각 구조). runner manual-only identity 훼손 | 비채택 |

## Coverage (정확한 표현 — "authoritative"가 아님)

| 표면 | 커버 시점 | 미커버 |
| --- | --- | --- |
| `pre-commit` | commit 시점(history 진입 전) | `--no-verify` bypass, hook 미설치 환경, remote/web commit |
| `ci.yml` | PR→{main, develop} 시점 + push→main | **direct develop push**(`push:` 트리거에 develop 없음), PR을 열기 전 구간 |

따라서 CI는 **PR backstop**이지 모든 경로를 닫는 authoritative gate가 아니다. 두 표면을 합쳐도 `--no-verify` + direct develop push 조합은 release full-sweep이 최종 안전망으로 남는다. 본 DR의 가치는 drift window를 release 시점에서 commit/PR 시점으로 **앞당기는 것**이다.

## Consequences

- `pre-commit`은 두 검사를 existence-guard로 호출한다(adopter no-op). `ci.yml`은 scaffold 생성 step 전 fail-fast 위치에서 두 스크립트를 직접 호출한다.
- **Single-commit atomicity 요구:** canonical과 template/mirror를 서로 다른 commit으로 나눠 수정하면 중간 commit에서 parity가 깨져 pre-commit이 차단한다. multi-commit refactor 시 canonical과 파생본을 같은 commit에 묶어야 한다(의도된 제약).
- `run-harness-checks.sh`는 manual-only 유지(DR-036 불변). runner는 여전히 tier2 scaffold 생성을 포함한 maintainer local 검증 도구다.
- backlog `Deferred Ideas`의 "Command/skill mirror atomicity — drift 자동 감지(CI/hook)" 항목 중 **mirror 존재 parity 차원은 본 DR로 자동화**된다. 단 surface-mirror parity는 mirror **존재**만 검사하고 **내용(content) drift**는 검사하지 않으므로, content-level atomicity 자동 감지는 해당 Deferred 항목에 잔존한다.

## Reversal Cost

Low — pre-commit 호출 블록 + ci.yml step 추가만으로, 제거 시 원복된다. 구조 부채 없음.

## Linked Work

- CHORE-20260619-001
