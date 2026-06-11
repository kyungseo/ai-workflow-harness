---
id: CHORE-20260611-006
priority: P1
status: Archived
risk: L2
scope: "PR #93 이후 전수 재검증" 대신 scaffold/tool-surface drift를 대표 regression asset으로 흡수한다(CHORE-20260611-005 검증 척추 위에). 1차 slice는 invariant leak-scan coverage gap(shipped 비-core 표면, 특히 source-gitflow `GIT-WORKFLOW.md`) 수정 + 검증 척추로의 regression asset 흡수 명문화 + repo-health/HARNESS-PROTOCOL trigger 결정까지로 자르고, mirror parity executable 승격·full simulation-as-code는 후속(F1/F3)으로 분해한다.
appetite: 1d
planned_start: 2026-06-11
planned_end: 2026-06-12
actual_end: 2026-06-11
related_dr: []
related_troubleshooting: []
related_work: [CHORE-20260611-005]
---

# CHORE-20260611-006: Scaffold/tool-surface regression alignment

## Top Summary

- **목표:** DR 등재·README 추가·hardcode 변경 시 scaffold가 자동 동기화되지 않아 생기는 drift를, "PR #93 이후 전수 재검증"이 아니라 **CHORE-20260611-005 검증 척추(taxonomy + runner)에 흡수된 대표 regression asset**으로 체계화한다.
- **시발점:** W1 Validation Spine backlog 2번째 항목 `Scaffold/tool-surface regression alignment 체계화`. 직전 `CHORE-20260611-005`가 taxonomy/runner를 도입해 "흡수 대상"이 실재하게 됐다.
- **핵심 발견(plan 조사):** leak-scan coverage gap이 **이중**이다. ① `check-scaffold-invariants.sh [2] no-source-only-leakage`의 `core_files()`에 `docs/GIT-WORKFLOW.md`(및 다른 source-gitflow shipped 표면)가 없다. ② invariants no-arg 두 모드(default/`--with-optional`)는 **source-gitflow를 생성조차 하지 않아** GIT-WORKFLOW.md가 스캔 대상에 등장하지 않는다. 따라서 그 파일에 `/Users/`·`/home/` 절대경로가 누수돼도 미검출(adapt()는 `ai-workflow-harness`만 치환, 절대경로는 그대로 통과).
- **범위 절제(Simplicity First):** 항목 전체(전수 재검증·mirror parity·repo-health 재구조화)는 크다. 이 Work는 **1차 slice(leak-scan gap 수정 + regression asset 흡수 명문화 + repo-health/trigger 결정)**까지만 구현하고, mirror parity executable 승격(F3)·full simulation-as-code(F1)는 후속으로 넘긴다.
- **author/driver:** Claude (A). **reviewer:** Codex (B). **합의 전 구현 보류.**

## Context Manifest

| 순서 | 파일 | 섹션 | 왜 |
|---|---|---|---|
| 1 | `docs/backlog/HARNESS.md` | `Scaffold/tool-surface regression alignment 체계화` | 본 Work 정의 + 하위 과제 1/2 + Done Criteria |
| 2 | `scripts/tests/check-scaffold-invariants.sh` | `core_files()`, `[2] no-source-only-leakage`, 모드 디스패치 | leak-scan gap의 실제 위치(core_files 목록 + no-arg 생성 모드) |
| 3 | `scripts/create-harness.sh` | L187 `adapt()`, L543~ source-gitflow extras | adapt가 `ai-workflow-harness`만 치환(절대경로 통과), source-gitflow shipped 표면 목록 |
| 4 | `scripts/tests/run-harness-checks.sh` | `run_tier2`/`gen_and_check` | coverage parity — invariants 모드 추가 시 runner도 동기화 |
| 5 | `docs/maintainer/HARNESS-TEST-TAXONOMY.md` | §2~3 Tier/Matrix, §6 후속 | regression asset 흡수 위치 + scaffold surface Tier 매핑 |
| 6 | `docs/maintainer/VERIFICATION-COMMANDS.md` | Layer C, Q, OB3 | source-gitflow simulation·invariants 카탈로그 정합 |
| 7 | `docs/works/harness/CHORE-20260611-005-...md` | F1~F5 분해, Discovery | 선행 Work 산출물·후속 경계 |

Trigger: backlog candidate 착수 / W1 Validation Spine 2번째 항목 / 사용자 세션 지시(2026-06-11).

## Problem Statement

scaffold는 source 변경을 자동 반영하지 않는다. 과거(2026-06-07) drift 4건 + dangling DR 5건이 한꺼번에 발견된 적이 있고, backlog는 이를 "PR #93 이후 전수 재검증"으로 잡으려 했으나 시점이 지나 비용 대비 효율이 낮다(#94~#145에서 표면이 크게 바뀜). 대신 **재발을 잡는 대표 regression asset**으로 흡수하는 것이 합리적이다.

검증 척추(CHORE-20260611-005)가 그 흡수 대상을 제공한다. 그러나 척추의 핵심 executable assertion인 `check-scaffold-invariants.sh [2] no-source-only-leakage`에 **shipped 비-core 표면 사각지대**가 있다:

- `core_files()`는 canonical docs + decisions/rules/commands/skills/cursor + session-start prompt만 나열한다. **source-gitflow가 배포하는 `docs/GIT-WORKFLOW.md`·`.github/workflows/harness-validate.yml`·`tools/git-hooks/**`는 빠져 있다.**
- 게다가 invariants no-arg는 default·`--with-optional` 두 모드만 생성한다 — **source-gitflow target을 만들지 않으므로** GIT-WORKFLOW.md는 애초에 디스크에 없다.
- `adapt()`는 `sed s/ai-workflow-harness/<name>/`만 수행 → `ai-workflow-harness`는 치환되지만 `/Users/`·`/home/` 절대경로는 그대로 누수. PR #139에서 generic 처리로 회피했으나 gap 자체는 잔존.

## Conceptual Model — regression asset의 3-Tier 흡수

CHORE-20260611-005 taxonomy의 Tier로 backlog "Regression assets"를 매핑한다(중복 없이 흡수 위치 고정).

| backlog Regression asset | Tier | 흡수 위치(executable) |
| --- | --- | --- |
| `bash -n create-harness.sh` | Tier 0 | runner `--tier0` (이미) |
| `git diff --check` | Tier 0 | runner `--tier0` (이미) |
| `create-harness <name> temp/<name>` + `check-scaffold-invariants temp/<name>` | Tier 2 | runner `--tier2/--all` (이미, default+optional) |
| tool-surface DR 참조 일관성 grep | Tier 1 | shipped-dr-closure(이미) + (mirror parity는 **F3 defer**) |
| **(gap) shipped 비-core 표면 leak-scan** | Tier 1/2 | **이 Work가 닫는다** — invariants 확장 |

즉 대부분의 backlog regression asset은 이미 척추에 흡수됐고, **남은 실질 gap은 leak-scan coverage**다. 이 Work는 그 gap을 닫고, 흡수 사실을 taxonomy/backlog에 명문화한다.

## Scope / Plan

### Slice 1 (이 Work)

1. **Leak-scan coverage gap 수정 (하위 과제 2)** → 검증: source-gitflow shipped 표면의 절대경로/source-only 토큰 누수가 invariants로 검출됨.
   - `check-scaffold-invariants.sh`에 **source-gitflow 생성 모드 추가**(no-arg 디스패치에 3번째 모드) — `--workflow source-gitflow` target 생성 후 `check_target`.
   - leak-scan 대상에 **source-gitflow shipped adapt text set 6개 전체**를 포함(R0 must-fix, OQ-2 해소). `[[ -f ]]` 가드라 비-source-gitflow target에선 자동 제외. 전용 helper(`gitflow_shipped_files()`) 또는 `core_files()` 가드 확장으로 구현:
     - `docs/GIT-WORKFLOW.md`
     - `.github/workflows/harness-validate.yml`
     - `tools/git-hooks/pre-commit`
     - `tools/git-hooks/commit-msg`
     - `tools/git-hooks/install.sh`
     - `tools/git-hooks/lib/gate-lists.sh`
   - **coverage parity:** `run-harness-checks.sh run_tier2`에 source-gitflow `gen_and_check` 추가 → `--tier2/--all`이 default + optional + source-gitflow 3모드 검사(기존 2모드 coverage 유지·확장).
   - **참고(범위 밖):** `.codex/hooks.json`은 모든 모드에서 adapt되지만 core_files 밖이다(source-gitflow 한정 아님). 이 always-shipped non-core gap은 이번 targeted fix 범위 밖이며 manifest-driven 일반해(후속) 근거로 Discovery에 기록한다.
2. **Regression asset 흡수 명문화** → 검증: backlog "전수 재검증 생략"의 대체물이 명시되고, taxonomy가 scaffold surface의 대표 regression을 가리킴.
   - `HARNESS-TEST-TAXONOMY.md` §3 Surface×Depth Matrix scaffold 행에 source-gitflow 모드/leak-scan 포함 반영.
   - backlog 항목 Done 처리 시 "대표 regression = runner `--all`(3모드 invariants + closure + tier0)"로 정리.
3. **runner 실행 기준 명문화 (하위 과제 1, 최소 — taxonomy/catalog 중심)** → 검증: "언제 runner를 돌리나"가 이미 항상 읽히는 표면에 고정되되 표면 추가는 최소화.
   - **`HARNESS-TEST-TAXONOMY.md` + `VERIFICATION-COMMANDS.md`에** "PR merge 전 / harness 마일스톤 완료 시 `run-harness-checks.sh --all` 권장"을 둔다(R0 P2 반영). runner 실행 기준은 이미 `AGENT-WORKFLOW.md` Verification Defaults + taxonomy가 잡고 있으므로 그 위에 짧게 얹는다.
   - **`HARNESS-PROTOCOL.md` trigger 추가는 defer** — trigger family simplification 전 표면 증식 방지(R0 P2). 단, 기존 protocol에 정확히 들어갈 짧은 자리가 있고 중복이 작으면 구현 시 재검토(조건부).
   - repo-health 깊은 통합은 **F4/`repo-health gate series 보강`으로 defer**.
4. **test-backed 검증(inject-revert)** → 검증: GIT-WORKFLOW.md 템플릿에 leak 토큰 inject → invariants FAIL → revert 후 PASS (backlog Verification 그대로).

### 후속 Work 분해 (이 Work 비범위)

- **F3 — mirror parity executable 승격:** tool surface adapter/skill mirror 쌍 일치를 Tier 1 assertion으로(현재 catalog Layer F manual). CHORE-005 F3과 동일 라인.
- **F1 — simulation-as-code:** catalog Layer J/J-OB/Q deterministic 스크립트화 + `/tmp`→`temp/`.
- **F4 — repo-health 깊은 연계:** runner 결과를 `/repo-health` Required Surface Matrix/LIVE_TARGETS에 통합(↔ `repo-health gate series 보강`).
- **manifest-driven leak-scan(대안):** `core_files()` 하드코딩 대신 manifest `framework_files` 전체를 leak-scan 대상으로(일반해). 이 Work에서 targeted fix를 택하면 후속 후보.

## Non-Goals

- PR #93 이후 모든 Work 파일 전수 재검토.
- product/adopter pack 검증(→ `Product pack verification layer 보강`).
- CI/hook hard-gate화(→ CHORE-005 F2 / `문서-only 규칙 강제화`).
- repo-health 구조 분리/재구조화(→ `repo-health.md slice 분리`·`repo-health gate series 보강`).
- full simulation-as-code 전환(→ F1).
- mirror parity executable 승격(→ F3).
- `HARNESS-PROTOCOL.md` trigger 추가(R0 P2 — trigger family simplification 전 표면 증식 방지, defer/조건부).
- `.codex/hooks.json` 등 always-shipped non-core 표면의 leak-scan(→ manifest-driven 일반해 후속).

## Done Criteria

> 합의 후 확정. 현재는 1차 slice 기준 제안.

- [x] `check-scaffold-invariants.sh`가 source-gitflow target을 생성·검사하고, leak-scan이 **source-gitflow shipped adapt text set 6개 전체**를 포함(R0 must-fix). `[2]`만 `leak_scan_files()`로 확장, `[1]/[3]`은 `core_files` 유지(closure 범위 과다 확장 방지).
- [x] `run-harness-checks.sh --tier2/--all`이 default + optional + source-gitflow 3모드를 생성·검사(coverage parity 유지·확장).
- [x] inject-revert 검증: `GIT-WORKFLOW.md` 템플릿에 `/Users/...` inject → source-gitflow 모드 `[2]` LEAK 검출 + RESULT FAIL(exit 1) → revert 후 PASS(exit 0). 잔여 토큰 0.
- [x] backlog "전수 재검증 생략"의 대체 대표 regression이 taxonomy(Conceptual Model 3-Tier)·backlog에 명문화.
- [x] runner 실행 기준("PR merge 전/마일스톤 완료 시 `--all`")이 `HARNESS-TEST-TAXONOMY.md` + `VERIFICATION-COMMANDS.md`에 명시(R0 P2 — HARNESS-PROTOCOL 수정 defer).
- [x] **(사용자 조정 반영) `scripts/tests/**`를 source-side verification surface로 등록:** runner `--tier0`이 `scripts/tests/*.sh` syntax 검사, taxonomy Surface×Depth Matrix에 행 추가, VERIFICATION-COMMANDS에 변경 cascade 명시. target leak-scan과 경계 구분(scaffold ship 아님 → target 대상 아님).
- [x] 후속 분해(F1/F3/F4 + manifest-driven 대안, `.codex/hooks.json` always-shipped gap)가 Work Discovery/backlog에 기록.

## Verification

- `check-scaffold-invariants.sh` OVERALL PASS(3모드 green), `run-harness-checks.sh --all` exit 0.
- inject-revert: GIT-WORKFLOW.md 템플릿에 `/Users/...` 토큰 inject → source-gitflow 모드 [2] FAIL 검출 확인 → revert.
- `git diff --check`, `bash scripts/tests/check-shipped-dr-closure.sh`.
- `bash -n` (수정 스크립트 2종).
- 문서 cascade: backlog ↔ taxonomy ↔ (필요 시) HARNESS-PROTOCOL trigger ↔ VERIFICATION-COMMANDS Layer C/Q pointer 정합. DR-007 언어 정책.

## Risk / Reversal

- **리스크 1 (생성 비용 증가):** invariants/runner에 source-gitflow 3번째 모드 추가 → 실행 시간 증가. → Tier 2 비용은 본래 simulation 영역. tier0/tier1은 영향 없음. 허용 가능.
- **리스크 2 (core_files 과다 확장):** 모든 shipped 표면을 leak-scan에 넣으면 noise/false-positive. → 1차는 docs 표면(GIT-WORKFLOW.md) 중심, 비-doc(.yml/hooks)은 OQ-2로 명시 결정. manifest-driven 일반해는 후속.
- **리스크 3 (scope 확장):** repo-health 깊은 통합까지 가면 비대. → trigger/pointer까지만, 구조 변경은 defer.
- **되돌리기 비용:** Low. 스크립트 2종 소규모 확장 + 문서 pointer. branch 단위 revert. 기존 default/optional coverage·closure 동작 불변.

## 이번 Work에서 실제로 수정할 후보 파일

| 파일 | 변경 | 비고 |
| --- | --- | --- |
| `scripts/tests/check-scaffold-invariants.sh` | source-gitflow 생성 모드 추가 + leak-scan에 source-gitflow shipped set 6개 포함(helper 또는 core_files 가드 확장) | leak-scan gap 핵심 수정 |
| `scripts/tests/run-harness-checks.sh` | `run_tier2`에 source-gitflow `gen_and_check` 추가 | coverage parity |
| `docs/maintainer/HARNESS-TEST-TAXONOMY.md` | §3 Matrix scaffold 행 + runner 실행 기준("PR merge 전/마일스톤 시 --all") + (필요 시) §6 manifest-driven·hooks.json gap 기록 | 흡수 명문화 + 실행 기준 |
| `docs/maintainer/VERIFICATION-COMMANDS.md` | Layer C에 source-gitflow leak-scan 반영 + runner 실행 기준 + `scripts/tests/**` cascade | catalog 정합 |
| `scripts/tests/run-harness-checks.sh` (추가) | `--tier0`에 `scripts/tests/*.sh` syntax 검사 | source-side surface (사용자 조정) |
| `docs/backlog/HARNESS.md` | 항목 Done 처리·대표 regression 명문화 | close 시 tracking |
| `docs/STATUS.md`, `docs/works/harness/README.md` | Active 등록 / close 시 정리 | tracking |

## Codex가 확인해야 할 Review Questions

1. **leak-scan gap 수정 방식:** "source-gitflow 생성 모드 추가 + `core_files()` 확장"(targeted) vs "manifest `framework_files` 전체 스캔"(general). targeted를 1차로, general을 후속으로 두는 것이 맞나?
2. **scan 대상 범위(OQ-2):** `GIT-WORKFLOW.md`(doc)만 포함 vs `.github/workflows/harness-validate.yml`·`tools/git-hooks/**`(비-doc shipped)도 포함? noise vs coverage trade-off.
3. **coverage parity:** invariants 3모드(default/optional/source-gitflow) + runner 동기화가 적절한가? source-gitflow를 두 스크립트 모두에 넣는 것이 과한가(한쪽만으로 충분?)?
4. **repo-health/trigger 경계(OQ-4):** 이 Work에서 trigger/pointer까지만, 깊은 통합은 `repo-health gate series 보강`/F4로 defer가 맞나? trigger 위치는 HARNESS-PROTOCOL이 맞나?
5. **mirror parity defer:** tool-surface mirror parity executable 승격을 F3로 미루는 것이 맞나, 아니면 이 Work의 "tool-surface" 명목상 일부라도 포함해야 하나?
6. **Slice 절단선:** leak-scan + 흡수 명문화 + trigger까지가 적절한 최소 slice인가?

## 제약

- **합의 전 구현 금지.** 이 Work는 Work 파일 + plan 작성까지만 진행하고 Codex R0 review 대기 상태로 멈춘다.
- `CHORE-20260611-004` Harness Context Discipline 전제 — 검증 기준/절차는 agent-side memory가 아니라 repo 문서/스크립트에 남긴다.
- `CHORE-20260611-005` 검증 척추 산출물(`HARNESS-TEST-TAXONOMY.md`, `run-harness-checks.sh`)을 사용·확장한다. `check-scaffold-invariants.sh` 변경 시 default + `--with-optional` coverage를 유지하고 source-gitflow를 추가한다(축소 금지).
- 기존 `scripts/tests/` 스타일(POSIX-safe, `set -euo pipefail`, source-repo 존재 가드)과 `create-harness.sh` 흐름을 따른다.
- DR-007 문서 언어 정책 준수. PR은 반드시 `--base develop`.

## Cross-Agent Review And Discussion

이 Work는 A(Claude)가 author/driver로 Work 파일+plan 및 구현을 담당하고,
B(Codex)가 plan review와 result review를 수행한다.
합의 전에는 구현하지 않는다.

### Round Log

| Round | Reviewer | Type | Summary | Required Changes / Decision | Status |
| --- | --- | --- | --- | --- | --- |
| R0 | Codex | Plan Review | leak-scan gap 이중성(source-gitflow 표면이 core_files 밖 + no-arg 생성 모드에도 없음) 진단 타당. targeted fix 1차 + manifest-driven/mirror parity/repo-health deep 후속 slice 적절. | Must-fix: OQ-2를 `GIT-WORKFLOW.md`만이 아니라 source-gitflow shipped adapt text set(.github workflow + tools/git-hooks/**)까지 포함하거나 제외 근거 명시. P2: HARNESS-PROTOCOL trigger는 과할 수 있으니 taxonomy/catalog pointer 중심, protocol 수정 신중. | Conditional Approve |
| R0a | Claude | Plan Revision | R0 must-fix 반영. leak-scan 대상을 source-gitflow shipped adapt text set 6개 전체로 확정하고, runner 실행 기준은 taxonomy + VERIFICATION-COMMANDS에 두며 HARNESS-PROTOCOL 수정은 defer로 조정. `.codex/hooks.json` always-shipped gap은 manifest-driven 일반해 후속 근거로 Discovery 기록. | Codex 합의. 구현 승인. | Agreed |
| R1 | Codex | Result Review | leak-scan 분리(`leak_scan_files`는 [2]만, [1]/[3]은 core_files 유지), source-gitflow shipped 6파일 coverage, invariants/runner 3모드 parity, inject-revert 검출, scripts/tests source-side surface 반영 확인. | Approve. work-close 진행 가능. | Approved |

**구현 주의점 (Codex R0a 합의 시 제시):**
- scan 대상 helper를 `core_files`로 계속 두면 의미가 흐려진다 → source-gitflow shipped extra까지 포함하는 **별도 `leak_scan_files()` helper**로 분리.
- `[1] no-dangling-reference`는 기존 **core A-class(`core_files`) 유지**, `[2] leak-scan`만 `leak_scan_files`로 확장. 모든 check에 같은 목록을 쓰면 DR closure 범위가 의도치 않게 커진다.
- runner `--tier2/--all`은 default + optional + source-gitflow **3모드** coverage 유지.
- **inject-revert 최소 1개 필수**: `/Users/...`를 source-gitflow template 중 하나에 inject → FAIL 확인 → revert.
- taxonomy/VERIFICATION-COMMANDS는 "PR merge 전/마일스톤 완료 시 `run-harness-checks.sh --all` 권장" 정도로 짧게.

### Consensus Log

| Topic | Consensus | Source Round | Status |
| --- | --- | --- | --- |
| Scope slice | leak-scan gap 수정 + 흡수 명문화 + runner 실행 기준(taxonomy/catalog)까지. mirror parity F3, simulation-as-code F1, repo-health deep F4 defer | R0 (OQ-1/6) | Agreed |
| leak-scan coverage | source-gitflow shipped adapt text set 6개 전체 포함(GIT-WORKFLOW.md + harness-validate.yml + git-hooks 4종). targeted fix 1차, manifest-driven 일반해는 후속 | R0 (must-fix, OQ-2) | Agreed |
| tool-surface regression assets | 대부분 CHORE-005 척추에 흡수 완료. 남은 executable gap은 leak-scan. mirror parity는 F3 | R0 (OQ-5) | Agreed |
| repo-health/runner boundary | deep 통합 defer(F4). runner 실행 기준은 taxonomy+catalog pointer, HARNESS-PROTOCOL trigger defer/조건부 | R0 (OQ-4, P2) | Agreed |
| coverage parity | source-gitflow를 invariants·runner 양쪽에 추가, default+optional 유지 | R0 (OQ-3) | Agreed |
| source test scripts surface | `scripts/tests/**`는 검증 척추 executable SSoT → source-side 영향도 surface. runner `--tier0` syntax + taxonomy/catalog cascade. **target leak-scan과 별개**(scaffold ship 아님). repo-health 반영은 F4 | 사용자 조정(구현 중) | Agreed(사용자), Codex R1 확인 |

### Plan-Level Open Questions

| ID | Question | Owner | Status |
| --- | --- | --- | --- |
| OQ-1 | 이번 Work의 최소 slice를 어디까지로 자를 것인가? | Claude + Codex | Resolved — leak-scan + 흡수 명문화 + runner 실행 기준(taxonomy/catalog) |
| OQ-2 | shipped non-core 표면을 leak scan 대상에 포함할 것인가? | Claude + Codex | Resolved — source-gitflow shipped adapt text set 6개 전체 포함 |
| OQ-3 | mirror parity를 이번 Work에서 executable 승격? | Claude + Codex | Resolved — F3 defer |
| OQ-4 | runner 실행 기준 pointer/trigger 위치? | Claude + Codex | Resolved — taxonomy+catalog, HARNESS-PROTOCOL defer/조건부 |

## Checkpoints

| CP | Description | Status |
|----|-------------|--------|
| 1 | Work 파일 + plan 작성, feature branch 생성, Active 등록 | ✓ 완료 |
| 2 | Codex R0 plan review 반영(R0a) + 합의 | ✓ 합의 완료 |
| 3 | Slice 1 구현(leak-scan gap 6파일 + coverage parity 3모드 + 흡수 명문화 + 실행 기준 + source-side surface) | ✓ 완료, 검증 green(inject-revert 포함) |
| 4 | Codex R1 result review | ✓ Approved |
| 5 | `/work-close` Done 처리 + commit + PR(--base develop) + merge | → Done 처리·commit 진행 중 |

## Next Actions

- ✓ CP1: Work 파일 + plan 작성, Active 등록
- ✓ CP2: Codex R0 Conditional Approve → R0a 반영, 합의 완료
- ✓ CP3: Slice 1 구현 — invariants source-gitflow 모드 + `leak_scan_files` 6파일(+set -e 버그 수정) + runner 3모드 + `--tier0` test scripts syntax + taxonomy/catalog 흡수·실행 기준·source-side surface. 검증 green(runner `--all` 3모드 exit 0, inject-revert 성공, closure OK, git diff --check clean)
- → CP4: Codex R1 result review 요청 후 대기
- ○ 합의 후 `/work-close` → commit → PR(--base develop) → merge

## Discovery

- backlog `Scaffold/tool-surface regression alignment 체계화` candidate 착수. backlog row 정리는 Work Done 동일 commit(work-close Step 5).
- **leak-scan gap 이중성 확인:** ① `core_files()`에 `docs/GIT-WORKFLOW.md` 부재 ② invariants no-arg가 source-gitflow를 생성하지 않음. `adapt()`는 `ai-workflow-harness`만 sed 치환하므로 절대경로(`/Users/`·`/home/`) 누수는 생성 output 스캔으로만 잡힌다.
- source-gitflow shipped 표면: `docs/GIT-WORKFLOW.md`, `.github/workflows/harness-validate.yml`, `tools/git-hooks/**`(모두 adapt). 전부 core_files 밖 → OQ-2 범위 결정 대상.
- manifest(`framework_files`)가 이미 모든 adapt() 파일을 추적 → leak-scan을 manifest-driven 일반해로 가는 대안 존재(후속 후보).
- **선행 Work archive 대기:** CHORE-20260611-005 Work 파일이 `docs/works/harness/`에 archive 대기. 이 Work와 함께 또는 다음 세션에서 배치 archive 가능.
- **Archived 2026-06-11:** PR #146 merge 후 CHORE-20260611-005와 묶어 archive 처리(routine, `/work-close` archive step).
- **[구현 발견 + 수정] `leak_scan_files()` set -e 누수:** 새 helper가 마지막 `[[ -f ]] && echo`(default 모드엔 source-gitflow 파일 부재 → false=1)로 끝나, `leak_scan_files > tmp`가 `set -e`로 스크립트를 죽였다(CHORE-005 cleanup 버그와 동형). `core_files`는 마지막이 `find`(항상 0)라 무사. → helper 끝에 `return 0` 추가로 수정. 3모드 PASS 회복.
- **[검증] inject-revert 성공:** `GIT-WORKFLOW.md` 템플릿에 `/Users/...` inject → source-gitflow 모드 `[2]`가 `LEAK: docs/GIT-WORKFLOW.md:7` 검출 + RESULT FAIL(exit 1). 이전엔 미검출이던 gap이 닫힘을 실증. revert 후 PASS, 잔여 토큰 0.
- **[사용자 조정] test scripts 자체가 verification spine 영향도 surface:** `scripts/tests/**`(invariants/closure/runner)는 척추의 executable SSoT이므로 변경 시 cascade 대상. 단 **scaffold target leak-scan과 별개**(source-only maintainer surface, scaffold ship 아님 → target leak-scan 대상 아님). 이번 Work에서 최소 반영: runner `--tier0` syntax + taxonomy matrix 행 + VERIFICATION-COMMANDS cascade. repo-health 영향 surface 반영은 **F4로 defer**(pointer만).
- **Codex R1 확인 포인트(사용자 제시):** ① `scripts/tests/**`를 runner `--tier0` 대상으로 즉시 포함한 것이 적절한가 ② source-side executable surface 행을 taxonomy에 추가한 것이 과하지 않은가 ③ repo-health 영향 surface는 이번 Work pointer만/F4 defer가 맞는가.
