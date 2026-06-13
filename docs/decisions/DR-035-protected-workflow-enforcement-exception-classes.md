# DR-035: Protected Workflow Enforcement Exception Classes

Date: 2026-06-13
Status: Accepted
Track: harness
Linked DRs: DR-021, DR-024, DR-025

## Question

protected workflow surface를 `develop`/`main`에서 direct commit하지 않는 branch isolation rule에 대해, 어떤 예외 클래스가 존재하고 각 클래스는 어떤 enforcement mode와 override 메커니즘을 가져야 하는가?

## Decision

branch isolation gate는 protected workflow surface를 **클래스별로 다르게 집행**한다. 이번 결정은 "모든 protected path를 같은 강도로 막는다"가 아니라, **경로 성격과 집행 가능 시점(pre-commit)** 을 기준으로 exception class를 나눈다.

### 1. Exception Class Table

| Class | Meaning | Representative paths | Enforcement on `develop`/`main` | Override mechanism |
| --- | --- | --- | --- | --- |
| `I0 inherited-merge` | 기존 merge commit 예외. 사람이 protected file을 직접 편집하는 것이 아니라 Git이 release sync merge를 쓰는 경우 | `.git/MERGE_HEAD` 존재 상태 | **skip / N/A** | 없음. 기존 규칙 inherited |
| `T1 tracking-state-only` | dashboard/registration 성격의 state tracking만 수행하는 경우 | `docs/STATUS.md`, `docs/backlog/**`, `docs/works/**` | **warning**. 단, staged set이 tracking-state 경로의 부분집합일 때만 | **없음.** trailer 불가 |
| `S1 structural-policy` | workflow/policy/tool/scaffold/decision 구조를 바꾸는 경우 | `AGENTS.md`, `CLAUDE.md`, `docs/AGENT-WORKFLOW.md`, `docs/HARNESS-PROTOCOL.md`, `docs/HARNESS-QUICK-REFERENCE.md`, `docs/GIT-WORKFLOW.md`, `docs/decisions/**`, `.claude/**`, `.cursor/**`, `.agents/skills/**`, `prompts/**`, `scripts/create-harness.sh`, `tools/git-hooks/**` | **hard-stop** | **없음. no-override** |
| `P1 project-protected-extension (unclassified)` | repo가 add-only protected path를 추가했지만 class mapping을 아직 명시하지 않은 경우 | `.harness/gate-config`로 추가된 custom protected path | **hard-stop** (default-safe) | **없음.** 명시 분류 전 override 불가 |
| `P2 project-protected-extension (classified)` | repo가 custom protected path를 class로 명시 매핑한 경우 | repo-specific policy가 `tracking-state` 또는 `structural-policy`로 선언한 custom path | mapped class 상속 | mapped class 상속 |

### 2. Quick Mode / Product Track Rule

`Quick Mode`와 `product track L1`은 **독립 예외 클래스가 아니다**.

- protected list 밖의 product L1 파일은 branch isolation gate 대상이 아니므로 **non-exception**이다.
- protected list 안의 파일은 Quick Mode 여부와 무관하게 **경로 class 규칙**을 따른다.
- 즉, Quick Mode는 `T1`/`S1`/`P1`/`P2` 판정을 바꾸지 않는다.

### 3. Tracking-State Exception Boundary

`T1 tracking-state-only`는 "tracking-only direct commit이 bounded exception"이라는 기존 운영 현실을 인정하되, 범위를 아래처럼 좁힌다.

- 적용 조건: staged set이 `docs/STATUS.md`, `docs/backlog/**`, `docs/works/**`의 부분집합이다.
- 비적용 조건:
  - `docs/decisions/**`가 포함된다.
  - 구조/정책 class(`S1`) 파일이 1개라도 포함된다.
  - protected file과 비protected substantive file을 함께 커밋한다.

위 비적용 조건에서는 `T1` 예외를 주장할 수 없고, feature branch로 이동한다.

archive move(`docs/works/**` → `docs/archive/**`)는 `/work-close` closeout 흐름에서 발생하더라도 **feature branch에서 수행되는 작업**으로 본다. 따라서 `docs/archive/**`를 `T1` direct-develop 예외에 포함하지 않는다.

### 4. DR-025 Trailer Crosspoint

`AWH-Gate-Override: finalization-split`와 `AWH-Gate-Reason:`는 **finalization/bundling gate 전용**이다.

- branch isolation gate는 이 trailer를 **인식하지 않는다**.
- 이유:
  - branch isolation의 1차 집행은 `pre-commit`에 있고, trailer 기반 예외를 안정적으로 쓰려면 `commit-msg`와의 분리 집행이 필요해져 설계를 과도하게 복잡하게 만든다.
  - 같은 trailer를 branch isolation까지 확장하면 finalization gate 전용 의미가 희석된다.
  - "tracking-only니까 trailer로 통과" 방향은 branch isolation을 path-set warning 예외가 아니라 message-aware exception으로 바꿔 UX와 구현 복잡도를 모두 악화시킨다.

즉, `T1`은 **path-set 기반 warning 예외**이고, `S1`/`P1`은 **no-override hard-stop**이다. branch isolation gate용 별도 override가 필요하다고 판단되면, 이는 별도 child slice/DR로 다룬다.

### 5. Class Ownership

- framework-owned default path의 class는 이 DR이 고정한다.
- repo-specific custom protected path는 repo-specific policy가 `P2` mapping을 제공해야 한다.
- mapping이 없으면 `P1`로 간주하고 default-safe hard-stop을 적용한다.

### 6. Follow-up Implementation Split

후속 구현은 아래처럼 분리한다.

1. **Framework default branch-isolation hardening**
   - 대상: `I0`/`T1`/`S1`
   - 범위: hook runtime + `gate-lists` + rule/doc cascade
   - 비범위: CI/F2, repo-specific custom classification
2. **Project-protected extension classification mechanism**
   - 대상: `P1`/`P2`
   - 범위: repo-specific class declaration 방식과 runtime ingestion
   - default-safe 유지 전제
3. **Runner / CI / F2 wiring decision**
   - 대상: `run-harness-checks.sh` 배선, required check 여부
   - 앞선 class/runtime 정책이 고정된 뒤 별도 판단
   - F2(`run-harness-checks.sh`를 CI/pre-commit/hook에 배선할지 결정`)와 중복 결정을 만들지 않도록, 해당 Work를 열 때 F2 흡수 여부를 명시한다

## Options Considered

| 선택지 | 장점 | 단점 |
|--------|------|------|
| A. 모든 protected path hard-stop + 단일 override | 단순 | tracking-only bounded exception과 merge 예외를 과하게 뭉개고, pre-commit 단계에서 trailer를 볼 수 없어 설계가 깨짐 |
| B. 모든 protected path warning-only 유지 | 현재 마찰 최소 | structure/policy 파일까지 같은 강도로 취급해 incident 이후 hardening 우선순위를 흡수하지 못함 |
| C. class-sensitive enforcement (채택) | merge / tracking-state / structure / custom extension을 분리해 bounded exception과 hardening 대상을 함께 유지 | custom extension class mapping 후속 slice 필요 |

## Rationale

핵심 제약은 "무엇이 protected인가"보다 **"무엇을 pre-commit 시점에 안전하게 판정할 수 있는가"** 다. merge 예외는 `.git/MERGE_HEAD`로 판정 가능하고, tracking-state는 path-set subset으로 판정 가능하다. 반면 trailer 기반 override는 `pre-commit`에서 볼 수 없으므로 branch isolation의 기본 메커니즘으로 채택하면 설계가 깨진다.

또한 기존 protected 목록은 tracking/state와 policy/structure를 같은 묶음으로 다뤘다. 이 상태에서 hook exit(1)을 일괄 도입하면 `docs/STATUS.md`/backlog registration 같은 bounded exception까지 false positive로 막게 된다. 반대로 전부 warning-only로 두면 `AGENTS.md`, rule, hook, scaffold 같은 구조 파일도 같은 강도로만 다뤄진다. class-sensitive split이 가장 작은 결정으로 두 리스크를 동시에 줄인다.

## Consequences

- branch isolation gate는 "protected면 일괄 처리"가 아니라 `I0`/`T1`/`S1`/`P1`/`P2` class를 기준으로 구현돼야 한다.
- `docs/decisions/**`는 tracking이 아니라 policy/structure class로 취급한다.
- Quick Mode/product L1은 독립 예외 클래스로 사용하지 않는다.
- `AWH-Gate-Override: finalization-split` trailer는 branch isolation에서 재사용하지 않는다.
- 후속 구현 Work는 runtime hardening, custom extension classification, F2 wiring을 분리해서 연다.
- 이번 결정만으로 hook/CI 동작은 바뀌지 않는다. 현재 bounded risk와 ruleset backstop은 유지된다.

## Reversal Cost

Medium — 문서 결정 자체는 되돌릴 수 있지만, 이 DR을 기준으로 branch-isolation runtime slice와 custom protected-path policy가 분해되므로 되돌리면 하류 slice 구조도 함께 조정해야 한다.

## Linked Backlog Items

- `문서-only 규칙 강제화 (CI/hook/hard-gate)`
- `Validation Spine residual follow-ups (F1-F4)`의 F2/F4 경계
- CHORE-20260613-007
