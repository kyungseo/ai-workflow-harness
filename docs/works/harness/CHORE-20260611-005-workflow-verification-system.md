---
id: CHORE-20260611-005
priority: P1
status: Done
risk: L2
scope: harness workflow 변경 시 surface별 검증을 test-backed로 일관·정확하게 수행할 수 있는 검증 척추를 정립한다. 1차 slice는 "test taxonomy 정의 + surface×depth 기준 + temp/ 실테스트 정책 + 최소 runner skeleton"까지로 자르고, 깊은 simulation-as-code·CI 게이트화·hard-gate 강제화는 후속 Work로 분해한다.
appetite: 1d
planned_start: 2026-06-11
planned_end: 2026-06-12
actual_end: 2026-06-11
related_dr: []
related_troubleshooting: []
related_work: [CHORE-20260611-004]
---

# CHORE-20260611-005: Harness workflow verification test system

## Top Summary

- **목표:** harness workflow 변경 시 "무엇을 / 어느 깊이로 / 어떤 실행 수단으로" 검증할지를 표준화한 **검증 척추(verification spine)**를 정립한다. 현재는 변경마다 검증 정도가 들쭉날쭉하고 누락이 잦다 → surface별 기준을 정하고 deterministic test 수단으로 일관화한다.
- **시발점:** W1 Validation Spine backlog 최상위 항목 `harness workflow 검증 테스트 체계 정립`. 직전 `CHORE-20260611-004`(Harness Context Discipline)가 "harness docs = SSoT, agent-side 컨텍스트 보정 금지"를 확정해 이 Work의 전제(검증이 문서/스크립트만으로 유도되어야 함)를 마련했다.
- **핵심 판단(이 Work가 결정할 것):** ① repo-health와의 책임 경계 ② `VERIFICATION-COMMANDS.md`(command catalog) vs `scripts/tests/`(executable assertions) 역할 경계 ③ surface별 검증 깊이 ④ `temp/` 실테스트 표준 절차 ⑤ 최소 실행 slice 범위.
- **범위 절제(Simplicity First):** 항목 전체는 매우 크다. 이 Work는 **1차 slice(taxonomy + 기준 + temp/ 정책 + 최소 runner skeleton)**까지만 구현하고, simulation layer를 실행 스크립트로 변환하는 작업·CI 배선·hard-gate는 후속 Work로 넘긴다.
- **author/driver:** Claude (A). **reviewer:** Codex (B). **합의 전 구현 보류.**

## Context Manifest

| 순서 | 파일 | 섹션 | 왜 |
|---|---|---|---|
| 1 | `docs/backlog/HARNESS.md` | `harness workflow 검증 테스트 체계 정립`, `Scaffold/tool-surface regression alignment 체계화`, `Product pack verification layer 보강` | 본 Work 정의 + 인접 항목과의 경계·자산 인계 |
| 2 | `docs/maintainer/VERIFICATION-COMMANDS.md` | Layer A~T, M1~M5, Release Full Sweep | 기존 command catalog의 coverage와 경계 결정 기준 |
| 3 | `docs/HARNESS-RECOVERY-VALIDATION.md` | Validation Checklist, CI/Manual/Hook 책임 경계 | 판단·정책 SSoT — test system은 HOW를, 이 문서는 WHETHER/WHEN을 담당 |
| 4 | `scripts/tests/check-scaffold-invariants.sh` | 전체 | 기존 executable assertion #1 (scaffold 불변식 5종) |
| 5 | `scripts/tests/check-shipped-dr-closure.sh` | 전체 | 기존 executable assertion #2 (shipped DR closure, pre-commit hook 게이트) |
| 6 | `docs/AGENT-WORKFLOW.md` | Verification Defaults | 변경 유형별 기본 검증 규칙(shipped/core) — taxonomy와 정합 필요 |
| 7 | `skills/workflow/repo-health.md` | Procedure / Required Surface Matrix | repo-health와의 책임 경계 결정 대상 |
| 8 | `.gitignore` | `temp/` 항목 | `temp/`가 gitignored·repo-local임을 확인(실테스트 디렉토리 근거) |

Trigger: backlog candidate 착수 / W1 Validation Spine 최우선 항목 / 사용자 세션 지시(2026-06-11).

## Problem Statement

harness는 markdown 문서 + shell script로 구성된 다층 표면(canonical / tool-specific adapter / user-facing / scaffold / prompt)을 가진다. 한 표면을 바꾸면 cascade로 다른 표면도 정합을 유지해야 하는데, 현재 검증은 다음 한계를 가진다.

1. **검증 깊이 불균등:** 변경마다 AI가 점검하는 surface 범위·깊이가 일관되지 않아 누락이 발생한다.
2. **수단 분산:** deterministic 자동 검증(`scripts/tests/` 2종)과 manual command catalog(`VERIFICATION-COMMANDS.md` Layer A~T)와 interactive 감사(`/repo-health`)가 공존하지만, **"어떤 변경에 무엇을 실행하면 충분한가"의 단일 기준이 없다.**
3. **실테스트 신뢰성:** `/tmp` 기반 scaffold simulation은 AI 권한 문제로 dry만 수행되는 경우가 있어, 실제 생성 후 검증이 일관되게 보장되지 않는다.

이 Work는 위 세 한계를 "test taxonomy(무엇/어느 깊이) + executable 수단 경계(어떻게) + temp/ 실테스트 정책(어디서)"으로 닫는 척추를 만든다. 단, 척추 전체를 한 번에 코드화하지 않고 1차 slice로 골격만 세운다.

## Conceptual Model — 3층 검증 수단과 책임 경계

이 Work의 핵심 설계 판단. 세 수단이 중복 없이 협업하도록 경계를 고정한다.

| 수단 | 성격 | 실행자 | 출력 | SSoT 역할 |
| --- | --- | --- | --- | --- |
| `scripts/tests/**` (executable assertions) | deterministic, non-interactive, exit-code | CI·hook·AI·maintainer | PASS/FAIL | **검증 가능한 불변식의 SSoT** |
| `docs/maintainer/VERIFICATION-COMMANDS.md` (command catalog) | 광범위·human-run·일부 false-positive 허용(screening) | maintainer(직접 셸) | grep 결과(증거) | **HOW 카탈로그** — 넓은 점검 명령 참조 |
| `skills/workflow/repo-health.md` (`/repo-health`) | interactive 감사·judgment·cascade 선택 | AI(세션 중) | 분류 보고 | **오케스트레이션/판단 표면** |

**경계 원칙(제안):**

- **executable assertion**은 "기계적으로 PASS/FAIL이 갈리고 false-positive가 거의 없는, 회귀로 잠글 가치가 있는" 점검만 담는다. 현재 2종(invariants, shipped-dr-closure)이 여기 속한다.
- **command catalog**는 그보다 넓은(판단 개입·false-positive 가능) 점검을 human-run 명령으로 유지한다. executable로 승격된 항목은 catalog가 **스크립트를 가리키기만** 하고 명령을 중복 보유하지 않는다(이미 Layer C→invariants, Layer I→closure가 그렇게 함).
- **repo-health**는 위 둘을 *호출·해석*하는 judgment 표면이다. 자체적으로 deterministic 불변식을 재구현하지 않는다.
- `HARNESS-RECOVERY-VALIDATION.md`는 **WHETHER/WHEN(판단·정책)** SSoT로 그대로 둔다. test system은 **HOW**만 추가한다.

## Surface × Depth Matrix (검증 기준 — 1차 정의)

각 surface를 어느 깊이로 test-backed 검증할지의 기준선. **Tier**는 실행 비용·결정성 순서다.

| Surface | Tier 0 (syntax) | Tier 1 (deterministic assertion, target 제공) | Tier 2 (simulation, scaffold 생성) | 현재 자산 / gap |
| --- | --- | --- | --- | --- |
| scaffold 출력 | `bash -n create-harness.sh` | invariants 5종 (`<target>` 인자) | invariants no-arg(생성) / OB 시나리오 | 자산: invariants ✓ (이중성 — 아래 주석) |
| tool surface (adapter/rule/skill mirror) | — | mirror 존재·쌍 일치 grep → **executable 후보** | — | gap: 현재 catalog Layer F manual |
| cascade (canonical→adapter→user→scaffold) | — | 변경 surface→영향 surface 매핑 점검 | — | gap: repo-health --cascade(judgment)만 존재 |
| canonical / 공통 규칙 | — | DR 참조 closure(shipped-dr-closure ✓), Superseded 참조 탐지 | — | 자산: closure ✓ |
| user-facing (README/MANUAL/GUIDE) | — | README↔optional docs 일치(invariants [4] ✓), command 행↔파일 교차 | scaffold 후 문서 경로 실재 | 부분 자산 |
| prompts 정렬 | — | session-start 3종 ↔ canonical 정합 grep | — | gap: catalog Layer S manual |
| product/adopter surface | — | (이 Work 범위 밖 — `Product pack verification layer 보강`에 위임) | — | **non-goal** |
| language policy (DR-007) | — | 한글 비율/순영어 파일 탐지 | — | gap: catalog Layer P manual |

> 이 매트릭스는 **1차 합의 대상**이다. Tier 1으로 승격할 후보(mirror parity, prompt 정합, language)는 이 Work에서 *기준만 확정*하고, 실제 스크립트화는 F3로 defer한다 — OQ-1 / R0 합의.

> **[R0 must-fix 1] `check-scaffold-invariants.sh`의 이중성:** 이 스크립트는 **인자 없이 실행하면 내부 `mktemp -d`로 default/`--with-optional` scaffold를 실제 생성**한 뒤 검사한다(생성 검증 = Tier 2-lite). 반면 **`<target-dir>` 인자를 주면 이미 존재하는 target만 검사**한다(deterministic assertion = Tier 1). 따라서 invariants는 호출 형태에 따라 Tier가 갈린다. runner는 이를 Tier 플래그로 명시적으로 구분한다(아래 Runner 설계).

## temp/ 실테스트 정책 (제안)

- **결론:** Tier 2 simulation의 기본 작업 디렉토리를 repo-local `temp/`로 고정한다(`/tmp` 대체).
- **근거:** `temp/`는 `.gitignore`에 등록되어 있고(commit 오염 없음), 과거 세션에서 scaffold 검증(`temp/gitflow-vfy*`)에 실제 사용되어 권한 문제 없이 실생성이 확인됐다. `/tmp`는 환경에 따라 AI 권한 제약으로 dry만 수행되는 경우가 있다.
- **표준 절차(제안):** `temp/harness-tests/<scenario>-<timestamp>/`에 생성 → 검증 → 명시적 cleanup. runner가 생성 경로와 cleanup을 책임진다.
- **기존 catalog 정합:** `VERIFICATION-COMMANDS.md`의 Layer J/J-OB/Q/R/S가 `/tmp/awh-*`를 사용한다. 이를 일괄 `temp/`로 치환하는 것은 catalog 대규모 편집이므로 **이 Work에서는 정책만 확정**하고, 치환은 후속(F1)으로 둔다.

## Runner 설계 — Tier 플래그 의미 (R0 must-fix 1 반영)

thin orchestrator. 검증 로직은 기존 스크립트에 위임하고 runner는 **tier별 호출 선택 + exit code 집계**만 담당한다. **생성하는 모드만 repo-local `temp/`를 사용한다**는 원칙을 고정한다.

| 플래그 | 의미 | scaffold 생성 | 호출 대상(잠정) |
| --- | --- | --- | --- |
| `--tier0` | syntax/무결성. 생성 없음 | 없음 | `bash -n scripts/create-harness.sh`, `git diff --check` |
| `--tier1` | **제공된 target만** 검사하는 deterministic assertion. 생성 없음 | 없음(target 인자 필수) | `check-scaffold-invariants.sh <target>`, `check-shipped-dr-closure.sh` |
| `--tier2` | repo-local `temp/harness-tests/<scenario>-<ts>/`에 scaffold **생성 후** invariants 실행 + cleanup | **있음 → `temp/`** | scaffold 생성 → `check-scaffold-invariants.sh <생성 target>` |
| `--all` | tier0 → tier1 → tier2 순차 실행, 누적 exit code 집계 | tier2 단계만 | 위 전부 |

**경계 규약:**

- `--tier1`은 **target 인자 필수**다(생성하지 않음). target 미지정 시 명확한 usage 에러로 종료한다 — invariants no-arg의 암묵적 생성을 runner 레벨에서 차단한다.
- `--tier2`만 scaffold를 생성하며, 생성 위치는 `temp/` 하위로 강제한다(`/tmp` 미사용). 생성·검사·cleanup을 runner가 책임진다.
- shipped-dr-closure는 source-only 정적 검사(생성 불필요)이므로 `--tier1`에 둔다.
- runner는 source-repo 전용이며 `scripts/create-harness.sh` 부재 시(adopter repo) 존재 가드로 no-op 종료한다(기존 `check-shipped-dr-closure.sh` 패턴 따름).

> 위 호출 대상·플래그명은 **구현 시 확정**할 잠정안이다. 핵심 합의 사항은 "생성 모드(`--tier2`)만 `temp/` 사용 + `--tier1`은 target 필수 비생성"이라는 경계다.

## Scope / Plan

### Slice 1 (이 Work — 골격 정립)

1. **Test taxonomy 문서 신설** → 검증: 3층 수단 경계 + Surface×Depth Matrix + Tier 정의 + temp/ 정책이 한 문서에 정합 기술되고, 기존 `VERIFICATION-COMMANDS.md`/`repo-health.md`와 중복 없이 pointer로 연결됨.
2. **최소 runner skeleton 신설** → 검증: 기존 deterministic 검증(`bash -n`, `git diff --check`, invariants, shipped-dr-closure)을 tier 인자로 오케스트레이션하고 exit code를 집계하는 thin orchestrator가 `bash -n` 통과 + 실제 실행 시 기존 2종과 동일 결과.
3. **경계 pointer 배선** → 검증: ① `docs/AGENT-WORKFLOW.md` Verification Defaults에 taxonomy/runner를 가리키는 **짧은 pointer 1줄 필수 추가**(R0 must-fix 2 — 세션 시작 시 항상 읽는 표면에서 검증 척추가 발견 가능해야 하며, 상세 명령은 taxonomy/catalog로 위임). **AGENT-WORKFLOW.md는 shipped/core 표면이고 taxonomy/runner는 source-only이므로, 기존 `VERIFICATION-COMMANDS.md` 참조와 동일한 "source repo 전용 — adopter repo N/A" 가드를 pointer에 붙인다**(adopter dangling 방지). ② `VERIFICATION-COMMANDS.md`에 catalog↔executable tier 경계 명시 + taxonomy/runner pointer. 두 pointer 모두 stale 없이 연결됨.
4. **backlog 인계/현행화** → 검증: `Scaffold/tool-surface regression alignment 체계화`의 regression asset이 taxonomy Tier로 흡수됐음을 backlog에 명시, `Product pack verification layer 보강`과 non-goal 경계 기록(close 시 tracking commit).

### 후속 Work 분해(이 Work 비범위)

- **F1 — Simulation-as-code:** catalog Layer J/J-OB/Q를 deterministic 스크립트로 변환 + temp/ 표준 적용(catalog `/tmp`→`temp/` 치환 포함).
- **F2 — CI/hook 게이트화:** runner를 CI required check / pre-commit에 배선(↔ `문서-only 규칙 강제화` backlog와 경계 조정).
- **F3 — Tier 1 승격 확대:** mirror parity·prompt 정합·language policy를 executable assertion으로 승격(이 Work에서 기준만 확정).
- **F4 — repo-health 연계:** runner 결과를 `/repo-health`에 surface(↔ `repo-health gate series 보강`·`repo-health.md slice 분리`와 함께).
- **F5 — Source repo maintainer operations manual:** 척추 산출물(taxonomy/runner/temp 정책/F1~F4)을 source repo 운영 runbook으로 통합(`docs/maintainer/SOURCE-REPO-OPERATIONS.md` 후보). adopter-facing `WORKFLOW-MANUAL.md`와 분리, maintainer/AI driver용. 기준/명령/정책은 복제하지 않고 pointer 연결. **이 Work 구현 범위 밖 — backlog 신규 등록(2026-06-11), `docs/backlog/HARNESS.md` W1 후속/P2.** Codex R2-extra 합의: 기존 `HARNESS-MAINTAINER-GUIDE.md`는 병렬 추가가 아니라 **흡수·대체·재배치 우선 검토**. 착수 시 남은 Open은 문서명/위치 최종 확정뿐.

## Non-Goals

- product/adopter pack 검증 layer 추가(→ `Product pack verification layer 보강`).
- CI/hook hard-gate 강제화(→ F2 / `문서-only 규칙 강제화`).
- catalog 전체 `/tmp`→`temp/` 치환(→ F1).
- repo-health 구조 변경·slice 분리(→ 별도 backlog).
- 모든 surface의 Tier 1 스크립트 완성(이 Work는 골격 + 일부; 나머지 F3).

## Done Criteria

> 합의 후 확정. 현재는 1차 slice 기준 제안.

- [x] test taxonomy 문서가 신설되고(`docs/maintainer/HARNESS-TEST-TAXONOMY.md`), 3층 수단(scripts/catalog/repo-health) 책임 경계가 §1에 명확히 기술됨.
- [x] Surface×Depth Matrix와 Tier 정의가 문서화되고(§2~3), 기존 자산(invariants/closure)·gap이 매핑됨.
- [x] `temp/` 기반 실테스트 표준 절차가 문서화됨(§5, `/tmp` dry 한계 회피 근거 포함).
- [x] 최소 runner skeleton(`scripts/tests/run-harness-checks.sh`)이 기존 deterministic 검증을 오케스트레이션하고 `bash -n` 통과 + `--all` 실행 결과가 기존 2종과 일치(exit 0). **tier2/--all은 default minimal + `--with-optional` 두 모드를 모두 생성·검사해 기존 invariants no-arg coverage와 동일**(R1 must-fix 반영). tier 플래그가 "생성 모드(`--tier2`/`--all`)만 `temp/` 사용 + `--tier1` target 필수 비생성" 경계를 따름. adopter-safe graceful skip guard 포함.
- [x] `docs/AGENT-WORKFLOW.md` Verification Defaults에 taxonomy/runner pointer가 추가되고, source-only N/A + "있으면 사용/없으면 Skipped" 가드가 붙음(R0 must-fix 2 + 사용자 adopter-safe 기준).
- [x] `VERIFICATION-COMMANDS.md`에 catalog↔executable 경계 단락 + taxonomy/runner pointer 추가(중복 명령 없음).
- [x] repo-health와 책임 경계가 taxonomy §1에 문서로 분리됨(repo-health.md 직접 편집은 F4로 defer — 경계는 taxonomy가 SSoT).
- [x] 후속 Work 분해(F1~F4)가 taxonomy §6과 Work Discovery에 기록됨.
- [x] (scope 확장, 사용자 승인) runner가 노출한 `check-scaffold-invariants.sh` exit-code 버그(target 인자 모드 false FAIL)를 surgical 수정(cleanup `return 0`), no-arg/CI 경로 회귀 없음 확인.

## Verification

- 신설 taxonomy 문서: 참조 경로 실재 grep, `repo-health.md`/`VERIFICATION-COMMANDS.md`와 중복·stale pointer 없음.
- runner skeleton: `bash -n scripts/tests/<runner>.sh`, 실제 실행 시 invariants·closure와 동일 PASS/FAIL.
- `git diff --check`, `bash scripts/tests/check-shipped-dr-closure.sh`(shipped DR closure 게이트).
- 문서 변경 cascade: canonical(AGENT-WORKFLOW Verification Defaults)→catalog→taxonomy pointer 정합.
- DR-007 언어 정책(신설 문서는 Korean primary + Bilingual Rules).

## Risk / Reversal

- **리스크 1 (또 하나의 표면 추가):** taxonomy 문서가 catalog와 중복되면 검증 표면만 늘고 부채가 된다. → 경계 원칙을 명시하고 catalog는 executable 항목을 pointer로만 보유. 신설 문서는 "기준·경계·temp/ 정책"에 한정, 명령 카탈로그를 복제하지 않음.
- **리스크 2 (over-scope):** 모든 surface를 한 번에 코드화하려다 slice가 비대해짐. → Slice 1을 골격으로 못박고 F1~F4 분해.
- **리스크 3 (runner와 기존 스크립트 책임 중첩):** runner가 검증 로직을 재구현하면 SSoT 분산. → runner는 thin orchestrator(기존 스크립트 호출 + exit 집계)로만 한정.
- **되돌리기 비용:** Low. 신설 문서 1 + 신설 스크립트 1 + 소규모 pointer 편집. branch 단위 revert 가능. 기존 2종 스크립트·catalog 동작은 불변.

## 이번 Work에서 실제로 수정할 후보 파일

| 파일 | 변경 | 비고 |
| --- | --- | --- |
| `docs/maintainer/HARNESS-TEST-TAXONOMY.md` (신설, 잠정명) | 신규 | taxonomy + Surface×Depth + Tier + temp/ 정책 + 경계. source-only maintainer 문서 |
| `scripts/tests/run-harness-checks.sh` (신설, 잠정명) | 신규 | thin orchestrator(tier 인자, exit 집계). source-only(존재 가드 no-op) |
| `scripts/tests/check-scaffold-invariants.sh` | **소규모 수정(scope 확장·사용자 승인)** | cleanup `return 0` 1줄 — target 인자 모드 exit-code 버그. runner가 노출 |
| `docs/maintainer/VERIFICATION-COMMANDS.md` | 소규모 편집 | catalog↔executable tier 경계 명시 + taxonomy/runner pointer |
| `docs/AGENT-WORKFLOW.md` | **필수** 소규모 편집 | Verification Defaults에 taxonomy/runner pointer 1줄(R0 must-fix 2). shipped/core 표면이므로 DR-007·cascade 점검 |
| `skills/workflow/repo-health.md` (조건부) | 소규모 편집 | 책임 경계 pointer(필요 판단 시, 아니면 F4로 defer) |
| `docs/backlog/HARNESS.md` | tracking | asset 인계·non-goal 경계·F1~F4 기록(close 시) |
| `docs/STATUS.md` | tracking | Active 등록 / close 시 정리 |
| `docs/works/harness/README.md` | tracking | Active/Done index |

## Codex가 확인해야 할 Review Questions

1. **수단 경계(R0 핵심):** "scripts/tests = deterministic SSoT / catalog = HOW / repo-health = judgment" 3층 경계가 타당한가? executable로 승격할 기준("기계적 PASS/FAIL + low false-positive + 회귀 가치")이 충분히 crisp한가?
2. **Slice 절단선:** Slice 1을 "taxonomy + temp/ 정책 + 최소 runner skeleton"으로 자르는 것이 적절한가, 아니면 Tier 1 승격 후보(mirror parity 등) 중 하나를 1차에 포함해 "실행되는 첫 자산"을 보여야 하는가?
3. **신설 문서 위치/정당성:** `docs/maintainer/HARNESS-TEST-TAXONOMY.md` 신설이 맞는가, 아니면 `VERIFICATION-COMMANDS.md`에 섹션 추가가 중복을 줄이는가? (표면 추가 vs 단일 문서 비대 트레이드오프)
4. **temp/ 정책 적용 범위:** 이 Work에서 정책만 확정하고 catalog `/tmp`→`temp/` 치환은 F1로 미루는 분리가 합당한가?
5. **runner 형태:** thin orchestrator로 시작하는 것이 맞는가? tier 플래그 설계(예: `--tier0|1|2`, `--all`)와 exit 집계 방식에 대한 의견.
6. **Product pack 경계:** product/adopter surface를 명시적 non-goal로 두고 `Product pack verification layer 보강`에 위임하는 경계가 명확한가?

## 제약

- **합의 전 구현 금지.** 이 Work는 현재 Work 파일 + plan 작성까지만 진행하고 Codex R0 review 대기 상태로 멈춘다.
- `CHORE-20260611-004` Harness Context Discipline(BEHAVIOR-PRINCIPLES §6)을 전제한다 — 검증 절차·기준은 agent-side memory/profile에 저장하지 않고 **반드시 repo 문서/스크립트**(이 Work 산출물)에 남긴다.
- 실제 scripts 변경 시 기존 `scripts/tests/` 스타일(POSIX-safe, `set -euo pipefail`, source-repo 존재 가드 no-op)과 `scripts/create-harness.sh` 흐름을 먼저 따른다.
- DR-007 문서 언어 정책 준수(신설 maintainer 문서·runner 주석은 Korean primary + Bilingual Rules).
- PR은 반드시 `--base develop`.

## Cross-Agent Review And Discussion

이 Work는 A(Claude)가 author/driver로 Work 파일+plan 및 구현을 담당하고,
B(Codex)가 plan review와 result review를 수행한다.
합의 전에는 구현하지 않는다.

### Round Log

| Round | Reviewer | Type | Summary | Required Changes / Decision | Status |
| --- | --- | --- | --- | --- | --- |
| R0 | Codex | Plan Review | 3층 경계, Surface×Depth Matrix, temp/ 정책, product/adopter non-goal 분리는 타당. Slice 1은 taxonomy + temp 정책 + thin runner skeleton으로 충분, 신규 Tier 1 assertion은 F3로 defer. | Must-fix 2건: (1) `check-scaffold-invariants.sh` no-arg 생성 특성을 반영해 Tier1/Tier2 runner 의미 명확화, (2) `AGENT-WORKFLOW.md` Verification Defaults pointer를 Slice 1 필수로 변경. | Conditional Approve |
| R0a | Claude | Plan Revision | Must-fix 2건 반영: invariants 이중성(Tier1=target 인자/Tier2=no-arg 생성) 명시 + Runner 설계 절(tier 플래그·"생성 모드만 temp/" 경계) 신설, AGENT-WORKFLOW pointer를 Slice 1 필수로 승격(+source-only N/A 가드). | 조건 충족 — 합의 대기 | Addressed |
| R1 | Codex | Result Review | taxonomy 3층 경계·pointer 배선·adopter-safe guard·invariants cleanup `return 0` 수정 타당. runner tier 의미·help도 합의와 일치. | Must-fix: `--tier2/--all`이 default scaffold만 검사해 기존 invariants no-arg의 default+optional coverage를 축소. 두 모드 모두 생성·검사하도록 보완(또는 의도적 축소면 coverage claim 정정). | Request Changes |
| R1a | Claude | Result Revision | `run_tier2`를 `gen_and_check` 헬퍼로 리팩터해 default minimal + `--with-optional` 두 모드 생성·검사. taxonomy §4·Work Done Criteria coverage 문구 정정. `--all` exit 0, 두 모드 모두 invariants PASS, cleanup 정상 확인. | 조건 충족 — close 진행 가능 | Addressed |
| R2 | Codex | Result Review | R1 P1 보완 확인. `--tier2/--all`이 default minimal + `--with-optional` 두 모드를 모두 생성·검사해 기존 invariants no-arg coverage와 일치. temp cleanup, target 필수 가드, shipped/adopter-safe pointer, taxonomy 경계도 확인. | Approve. work-close 진행 가능. | Approved |
| R2-extra | Codex | Backlog Adjustment Review | F5 신규 backlog(`Source repo maintainer operations manual`) 등록 방향 동의 — W1 후속/P2, `SOURCE-REPO-OPERATIONS.md`, WORKFLOW-MANUAL/product pack 경계 타당. | P2: 기존 `HARNESS-MAINTAINER-GUIDE.md`를 병렬 추가가 아니라 흡수·대체·재배치 우선 검토로 backlog 문구 선명화. → 반영 완료. | Approved with clarification |

### Consensus Log

| Topic | Consensus | Source Round | Status |
| --- | --- | --- | --- |
| Scope slice | Slice 1 = taxonomy + temp/ 정책 + thin runner skeleton. 신규 Tier 1 assertion(mirror parity 등)은 F3로 defer | R0 (OQ-1) | Agreed |
| repo-health boundary | scripts/tests = deterministic SSoT, VERIFICATION-COMMANDS = HOW catalog, repo-health = judgment/orchestration | R0 (OQ-2) | Agreed |
| test runner/script strategy | thin orchestrator. `--tier0/1/2/--all`, "생성 모드(`--tier2`)만 repo-local temp/ 사용 + `--tier1` target 필수 비생성". invariants no-arg는 Tier2-lite로 재분류 | R0 (OQ-3 + must-fix 1) | Agreed |
| temp/ execution policy | `temp/`를 Tier 2 표준으로 채택. catalog 전체 `/tmp`→`temp/` 치환은 F1로 defer | R0 (OQ-4) | Agreed |
| 신설 문서 위치 | `docs/maintainer/HARNESS-TEST-TAXONOMY.md` 신설(catalog 비대화 회피) | R0 (OQ-3) | Agreed |
| AGENT-WORKFLOW pointer | Verification Defaults에 짧은 pointer 필수(+source-only N/A 가드). 상세는 taxonomy/catalog 위임 | R0 (must-fix 2) | Agreed |
| product/adopter surface | non-goal — `Product pack verification layer 보강`에 위임 | R0 | Agreed |
| runner tier2 coverage | `--tier2/--all`은 default minimal + `--with-optional` 두 모드 생성·검사(기존 invariants no-arg와 동일). default-only 축소 불가 | R1 (must-fix) | Agreed |

### Plan-Level Open Questions

| ID | Question | Owner | Status |
| --- | --- | --- | --- |
| OQ-1 | 이번 Work를 어느 최소 slice로 자를 것인가? | Claude + Codex | Resolved — taxonomy + temp/ 정책 + thin runner skeleton, Tier1 신규 assertion은 F3 defer |
| OQ-2 | repo-health와 verification test system의 책임 경계는 무엇인가? | Claude + Codex | Resolved — scripts=SSoT / catalog=HOW / repo-health=judgment |
| OQ-3 | `VERIFICATION-COMMANDS.md`는 catalog 유지하고 scripts/tests는 executable로 둘 것인가? | Claude + Codex | Resolved — 분리 유지 + `HARNESS-TEST-TAXONOMY.md` 신설 |
| OQ-4 | `temp/` 기반 scaffold simulation을 표준 절차로 둘 것인가? | Claude + Codex | Resolved — Tier2 표준 채택, catalog 치환은 F1 |

## Checkpoints

| CP | Description | Status |
|----|-------------|--------|
| 1 | Work 파일 + plan 작성, feature branch 생성, Active 등록 | ✓ 완료 |
| 2 | Codex R0 plan review 반영(R0a) + 합의 | ✓ 합의 완료 |
| 3 | Slice 1 구현(taxonomy 문서 + runner skeleton + pointer 배선 + invariants 버그 수정) | ✓ 완료, 검증 green |
| 4 | Codex result review(R1 Request Changes) + R1a 보완(두 모드 coverage) | ✓ 합의, close 가능 |
| 5 | `/work-close` Done 처리 + commit + PR(--base develop) + merge | → Done 처리·commit 진행 중 |

## Next Actions

- ✓ CP1: Work 파일 + plan 작성, Active 등록
- ✓ CP2: Codex R0 Conditional Approve → must-fix 2건 R0a 반영, 합의 완료
- ✓ CP3: Slice 1 구현 — taxonomy 신설 + runner skeleton + pointer 2개 + invariants 버그 수정. 검증 green(runner `--all` exit 0, no-arg 회귀 없음, closure OK, git diff --check clean)
- ✓ CP4: Codex R1 Request Changes(tier2 default-only coverage 축소) → R1a 두 모드 보완, 검증 green, 합의
- → 사용자 승인 후 `/work-close` → commit → PR(--base develop) → merge

## Discovery

- backlog `harness workflow 검증 테스트 체계 정립` candidate 착수. backlog row 정리는 develop merge 후 tracking-only commit으로 처리(DR-013).
- `temp/`가 `.gitignore`에 등록되어 있고 과거 scaffold 검증에 실제 사용됨을 확인 — `/tmp` 대체 근거 확보.
- 기존 executable assertion은 2종(`check-scaffold-invariants.sh`, `check-shipped-dr-closure.sh`)뿐이며, 나머지 surface 검증은 `VERIFICATION-COMMANDS.md` manual catalog와 `/repo-health` judgment에 분산되어 있음 — 이 Work의 척추가 그 경계를 고정한다.
- **[발견 + 수정] `check-scaffold-invariants.sh` exit-code 버그:** runner가 invariants exit code를 프로그램적으로 소비하는 첫 사례라 노출됨. `cleanup()` EXIT trap이 마지막 줄 `[[ -n "${GEN_BASE}" ]] && rm -rf`로 끝나는데, **target 인자 모드에서는 `GEN_BASE=""`**라 이 `[[ ]]`가 false(status 1)를 반환하고, macOS bash에서 `exit 0` 후 trap의 비-0 종료가 스크립트 exit code를 1로 덮어쓴다. 결과: PASS인데도 exit 1. no-arg 모드는 `GEN_BASE`가 실 경로라 영향 없음(그래서 CI에서 미노출). → **수정:** cleanup 끝에 `return 0` 추가(surgical, 사용자 승인). no-arg/CI 경로 회귀 없음 확인. **이것이 검증 척추가 잡아야 할 정확한 종류의 회귀 — runner의 첫 실효 검출.**
- **F1~F4 후속 분해** taxonomy §6에 기록: F1(catalog `/tmp`→`temp/` 치환·simulation-as-code), F2(CI/hook 게이트화), F3(mirror/prompt/language Tier1 승격), F4(repo-health 연계). 별도 backlog 등록은 close 시 tracking에서 판단.
- **[조정 요청 반영, 2026-06-11] F5 — Source repo maintainer operations manual:** 사용자 판단으로, 검증 척추 산출물을 묶는 source repo 운영 매뉴얼(`WORKFLOW-MANUAL.md`와 분리된 maintainer-facing runbook)이 필요하다는 gap 식별. **이 Work 구현 범위는 늘리지 않고** `docs/backlog/HARNESS.md`에 신규 Candidate 등록(W1 후속, P2 제안) + 후속 분해 F5로 기록. 문서명/위치·cluster·우선순위·HARNESS-MAINTAINER-GUIDE 중복 여부는 착수(`/work-plan`) 시 Codex와 확정.
