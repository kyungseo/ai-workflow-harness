---
date: 2026-06-11
track: harness
type: reference
scope: harness workflow 검증 척추 — surface별 검증 기준(무엇/어느 깊이), 3층 검증 수단 경계, Tier 정의, temp/ 실테스트 정책
status: active
related_work: [CHORE-20260611-005]
---

# HARNESS-TEST-TAXONOMY.md

harness workflow 변경 시 **무엇을 / 어느 깊이로 / 어떤 수단으로** 검증할지의 기준 문서다.
검증 척추(verification spine)의 SSoT이며, 변경마다 들쭉날쭉하던 검증 범위·깊이를 표준화한다.

이 파일은 **source repo 전용 maintainer 문서**다. scaffold로 ship되지 않으며 adopter repo에는 없다(N/A).

**경계:** 이 파일은 **검증 기준·수단 경계(WHAT/HOW-DEEP)**다.
- 실행할 **구체 명령 카탈로그(HOW)**는 `docs/maintainer/VERIFICATION-COMMANDS.md`.
- 진행 가능 여부 **판단·정책(WHETHER/WHEN)**은 `docs/HARNESS-RECOVERY-VALIDATION.md`.
- 변경 유형별 **기본 검증 규칙**은 `docs/AGENT-WORKFLOW.md` Verification Defaults.

관련 문서:
- `docs/AGENT-WORKFLOW.md` Verification Defaults — 변경 유형별 기본 검증 규칙(shipped/core)
- `docs/maintainer/VERIFICATION-COMMANDS.md` — Layer별 실행 명령 카탈로그
- `skills/workflow/repo-health.md` — `/repo-health` 감사 절차. Cascade detail/Required Surface Matrix는 `skills/workflow/repo-health-cascade.md`
- `scripts/tests/run-harness-checks.sh` — 이 문서의 Tier를 오케스트레이션하는 runner
- `scripts/tests/check-onboarding-flows.sh` — Layer J-OB deterministic core + Layer Q core helper

---

## 1. 3층 검증 수단과 책임 경계

세 수단이 중복 없이 협업하도록 경계를 고정한다.

| 수단 | 성격 | 실행자 | 출력 | SSoT 역할 |
| --- | --- | --- | --- | --- |
| `scripts/tests/**` (executable assertions) | deterministic, non-interactive, exit-code | CI·hook·AI·maintainer | PASS/FAIL | **검증 가능한 불변식의 SSoT** |
| `docs/maintainer/VERIFICATION-COMMANDS.md` (command catalog) | 광범위·human-run·일부 false-positive 허용(screening) | maintainer(직접 셸) | grep 결과(증거) | **HOW 카탈로그** |
| `skills/workflow/repo-health.md` + conditional slices (`/repo-health`) | interactive 감사·judgment·cascade 선택 | AI(세션 중) | 분류 보고 | **오케스트레이션/판단 표면** |

**경계 원칙:**

- **executable assertion**은 "기계적으로 PASS/FAIL이 갈리고 false-positive가 거의 없는, 회귀로 잠글 가치가 있는" 점검만 담는다. 핵심 불변식은 scaffold invariants(`check-scaffold-invariants.sh`)·DR closure(`check-shipped-dr-closure.sh`)이며, parity(`check-default-template-parity.sh`·`check-surface-mirror-parity.sh`)·onboarding(`check-onboarding-flows.sh`) helper가 더해져 있다.
- **command catalog**는 더 넓은(판단 개입·false-positive 가능) 점검을 human-run 명령으로 유지한다. executable로 승격된 항목은 catalog가 **스크립트를 pointer로만** 보유하고 명령을 중복 보유하지 않는다(Layer C→invariants, Layer I→closure가 이미 그렇다).
- **repo-health**는 위 둘을 *호출·해석*하는 judgment 표면이다. 자체적으로 deterministic 불변식을 재구현하지 않는다.
- onboarding / hook처럼 multi-scenario 생성과 git 동작이 섞인 deterministic core는 **별도 helper script**로 둘 수 있다. runner는 여전히 thin orchestrator로 유지한다.
- `HARNESS-RECOVERY-VALIDATION.md`는 **WHETHER/WHEN(판단·정책)** SSoT로 그대로 둔다. 이 척추는 **HOW-DEEP(기준)**만 추가한다.

---

## 2. Tier 정의

Tier는 실행 비용·결정성·생성 여부 순서다.

| Tier | 의미 | scaffold 생성 | 예시 |
| --- | --- | --- | --- |
| Tier 0 | syntax / 무결성. 생성 없음 | 없음 | `bash -n create-harness.sh`, `git diff --check` |
| Tier 1 | **제공된 target만** 검사하는 deterministic assertion. 생성 없음 | 없음 | `check-scaffold-invariants.sh <target>`, `check-shipped-dr-closure.sh` |
| Tier 2 | scaffold를 **실제 생성한 뒤** 검사하는 simulation | **있음 → repo-local `temp/`** | invariants no-arg(생성), Layer J/J-OB/Q OB 시나리오 |

> **`check-scaffold-invariants.sh`의 이중성(중요):** 이 스크립트는 **인자 없이 실행하면 내부 `mktemp -d`로 default/`--with-optional` scaffold를 실제 생성**한 뒤 검사한다(= Tier 2 생성 검증). 반면 **`<target-dir>` 인자를 주면 이미 존재하는 target만 검사**한다(= Tier 1 deterministic assertion). 호출 형태에 따라 Tier가 갈리므로, runner는 이를 플래그로 명시 구분한다(§4).

---

## 3. Surface × Depth Matrix

각 surface를 어느 깊이로 test-backed 검증할지의 기준선.

| Surface | Tier 0 | Tier 1 (target 제공) | Tier 2 (생성) | 현재 자산 / gap |
| --- | --- | --- | --- | --- |
| scaffold 출력 | `bash -n` | invariants 5종 (`<target>`) | invariants no-arg 3모드(default/optional/source-gitflow) / OB 시나리오 | 자산: invariants ✓ (leak-scan은 source-gitflow shipped set 포함) |
| tool surface (adapter/rule/skill mirror) | — | mirror 존재·쌍 일치 (`check-surface-mirror-parity.sh`) | — | 자산: mirror/prompt parity ✓ (F3) — 과잉반복·adapter 비대 판단은 catalog/judgment 유지 |
| cascade (canonical→adapter→user→scaffold) | — | 변경 surface→영향 surface 매핑 | — | gap: repo-health --cascade(judgment)만 |
| canonical / 공통 규칙 | — | DR 참조 closure(closure ✓), Superseded 참조 탐지 | — | 자산: closure ✓ |
| user-facing (README/MANUAL/GUIDE) | — | README↔optional docs 일치(invariants [4] ✓), command 행↔파일 교차 | scaffold 후 문서 경로 실재 | 부분 자산 |
| prompts 정렬 | — | session-start 3종 존재 (`check-surface-mirror-parity.sh`) | — | 부분 자산 ✓ (F3, 존재만) — canonical 참조·섹션 정합은 catalog 유지 |
| product/adopter surface | — | (이 척추 범위 밖) | — | **executable spine non-goal 유지** (judgment/checklist 성격). catalog `VERIFICATION-COMMANDS.md` Layer U(criteria + U1 boundary smoke)로 정의됨 — CHORE-20260611-007 |
| language policy (DR-007) | — | 한글 비율/순영어 파일 탐지 | — | catalog 유지 (F3 보류) — rule 파일 다수가 정당한 영어라 deterministic 승격 시 false-positive·judgment 필요 |
| **source test scripts** (`scripts/tests/**`) — 검증 척추 executable SSoT | `bash -n scripts/tests/*.sh` (runner `--tier0`에 포함) | 해당 script 자체 실행 / `run-harness-checks.sh --all` | — | **source-side surface** (scaffold ship 아님 → target leak-scan 대상 아님). 변경 시 taxonomy/runner/catalog 정합 cascade |

> executable로 잠긴 것은 scaffold 출력·canonical DR closure·user-facing 일부·tool surface mirror/prompt 존재(F3)다. language policy 등 judgment·screening surface는 catalog에 유지한다(F3에서 승격 가치 검토 후 보류 결정).

---

## 4. Runner — `scripts/tests/run-harness-checks.sh`

기존 deterministic 검증을 **tier별로 오케스트레이션**하는 thin orchestrator다. 검증 로직은 기존 스크립트에 위임하고 runner는 호출 선택 + exit code 집계만 담당한다.

| 플래그 | 의미 | scaffold 생성 |
| --- | --- | --- |
| `--tier0` | syntax/무결성(`bash -n`, `git diff --check`) | 없음 |
| `--tier1 <target>` | **target 인자 필수** — closure + invariants `<target>`(기존 target 검사만) | 없음 |
| `--tier2` | `temp/harness-tests/<label>-<ts>/`에 **default minimal + `--with-optional` + `--workflow source-gitflow` 세 모드** 생성 후 각각 invariants + cleanup(기존 no-arg와 동일 coverage). source-gitflow 모드는 `GIT-WORKFLOW.md`/hooks 등 shipped 표면을 leak-scan에 포함 | **있음 → `temp/`** |
| `--all` | tier0 + source-level tier1(closure) + tier2(**실제 생성 포함, 세 모드**), exit code 누적 | tier2 단계만 |

**경계 규약:**

- **생성하는 모드(`--tier2`, `--all`의 tier2 단계)만 repo-local `temp/`를 사용한다**(`/tmp` 미사용 — AI 권한으로 dry만 되는 한계 회피).
- `--tier1`은 **target 인자 필수**이며 **생성하지 않는다**(기존 target 검사만). 미지정 시 usage 에러로 종료한다(invariants no-arg의 암묵적 생성을 runner 레벨에서 차단).
- `--all`은 source-level tier1(closure)과 **실제 생성을 포함하는** tier2를 함께 돈다. help/usage에 생성 포함을 명시한다.
- Layer J-OB / Q의 deterministic core는 `check-onboarding-flows.sh`가 담당한다. 이 helper는 source-side smoke 성격이며 runner에 직접 접합하지 않는다(F4 전까지 thin-runner 경계 유지).

**실행 기준:** 일상 변경은 변경 surface에 맞는 tier만 실행한다. **PR merge 전 또는 harness 마일스톤 완료 시 `run-harness-checks.sh --all`을 권장**한다(scaffold 3모드 + closure + syntax 전수).

**leak-scan 대상 분리(중요):** `check-scaffold-invariants.sh`의 `[1] no-dangling-reference`/`[3] closure`는 **core A-class(`core_files`)**만 본다. `[2] no-source-only-leakage`만 **`leak_scan_files`**(= core_files + source-gitflow shipped adapt text set: `GIT-WORKFLOW.md` + `.github/workflows/harness-validate.yml` + `tools/git-hooks/{pre-commit,commit-msg,install.sh,lib/gate-lists.sh}`)로 확장한다. 모든 check에 동일 목록을 쓰면 DR closure 범위가 의도치 않게 커지므로 분리한다.

**Graceful skip guard (adopter-safe — 중요):**

runner(`scripts/tests/run-harness-checks.sh`)는 scaffold로 ship될 수 있다. adopter repo에는 `scripts/create-harness.sh`와 maintainer 검증 스크립트가 없을 수 있으므로, 다음을 **존재 가드로 graceful skip(SKIP/N/A, 해당 step은 PASS 기여)** 처리한다.

- `scripts/create-harness.sh` 부재 → 생성·`bash -n`·tier2·invariants는 SKIP(N/A).
- `scripts/tests/check-scaffold-invariants.sh` 부재 → invariants step SKIP.
- `scripts/tests/check-shipped-dr-closure.sh`는 자체 guard 보유(source 부재 시 자체 SKIP).
- guard로 빠진 step은 실패가 아니다 — adopter repo에서 runner가 깨지지 않도록 한다.

---

## 5. temp/ 실테스트 정책

- **표준:** Tier 2 simulation의 기본 작업 디렉토리는 repo-local `temp/`(`/tmp` 대체).
- **근거:** `temp/`는 `.gitignore`에 등록되어 commit 오염이 없고, 과거 scaffold 검증(`temp/gitflow-vfy*`)에서 권한 문제 없이 실생성이 확인됐다. `/tmp`는 환경에 따라 AI 권한 제약으로 dry만 수행되는 경우가 있다.
- **절차:** `temp/harness-tests/<scenario>-<ts>/`에 생성 → 검증 → 명시적 cleanup. runner가 생성 경로와 cleanup을 책임진다.
- **catalog 정합:** `VERIFICATION-COMMANDS.md` Layer J/J-OB/Q/R/S manual appendix와 `check-onboarding-flows.sh` helper는 같은 `temp/harness-tests/` 기준을 사용한다. 이 척추는 그 정책 기준을 제공한다.

---

## 6. 후속 분해 (이 척추 비범위)

| ID | 범위 |
| --- | --- |
| F1 | catalog Layer J는 interactive/human-run으로 유지하고, deterministic core는 Layer J-OB(OB0/OB1/OB3/OB4/OB5) + Layer Q core helper로 승격한다. catalog Layer J/J-OB/Q/R/S의 `/tmp/awh-*` 예시는 repo-local `temp/` 정책에 맞춰 정렬한다 |
| F2 | ✅ 종결 — runner를 CI required check / pre-commit에 **배선하지 않기로 결정**(무배선, DR-036) |
| F3 | ✅ 종결 (2026-06-13, CHORE-20260613-018). mirror parity(canonical↔claude↔agents 3자) + session-start prompt 3종 존재를 `check-surface-mirror-parity.sh`로 Tier 1 승격(runner `--tier0`). language policy는 정당한 영어 rule 다수로 deterministic 승격 시 false-positive·judgment 필요 → **보류**, catalog screening 유지 |
| F4 | ✅ 종결 (2026-06-13, CHORE-20260613-018). Layer K + `repo-health.md` Execution Principles에 runner tier 호출/해석 경계 명시(Quick=tier0/tier1 생성 없음, --full=--all). repo-health는 불변식 재구현 없이 호출·해석만 |

---

## 7. 이 파일 자체 점검

`HARNESS-TEST-TAXONOMY.md`를 수정했을 때:

- 참조 경로(§ 관련 문서, §4 runner) 실재 확인.
- `VERIFICATION-COMMANDS.md`·`AGENT-WORKFLOW.md` Verification Defaults·`repo-health.md`와 경계 중복·stale pointer 없음.
- Surface×Depth Matrix의 "현재 자산"이 `scripts/tests/` 실제 파일과 일치.
