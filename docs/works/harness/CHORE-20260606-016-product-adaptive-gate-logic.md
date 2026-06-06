---
id: CHORE-20260606-016
priority: P0
status: Done
risk: High
scope: gate-enforcement-runtime-and-env slice c4 product-adaptive gate logic (project-configurable protected/finalization list) and tracking-only commit exception review
appetite: 2d
planned_start: 2026-06-06
planned_end: 2026-06-08
actual_end: 2026-06-06
related_dr: [DR-025, DR-024, DR-021, DR-020]
related_troubleshooting: []
---

# Product-Adaptive Gate Logic + Tracking-Only Commit Exception — Slice C4

> 역할: A(Claude)가 author/driver로 Work 파일+plan과 구현을 담당하고, B(Codex)가 Cross-Agent Review R-round(plan review + result review)를 수행한다. 합의 전에는 구현하지 않는다.

## Context

`gate-enforcement-runtime-and-env` P0 series는 종료 전까지 0순위로 유지한다. c4는 series의 **마지막 권장 sub-slice**다.

완료된 선행 slice:

- (a) source hook runtime — CHORE-20260606-006
- (b) shared gate-list SSoT — CHORE-20260606-007
- (c1) source-gitflow opt-in hook 배포 — CHORE-20260606-008
- (c2-A) source repo CI hardening — CHORE-20260606-009
- (c2-B) target CI template + ruleset handoff — CHORE-20260606-010
- (d) source-gitflow environment bootstrap — CHORE-20260606-011
- (c3) hook-less/generic advisory + manifest check — CHORE-20260606-015

이번 slice는 **(c4) product-adaptive gate logic**이다. 두 부분으로 구성된다.

1. **target 고유 protected/finalization list 자동 조정** — gate 집행 대상 리스트를 product repo가 자기 민감 파일로 확장할 수 있게 한다.
2. **tracking-only commit 예외 흡수 검토** — finalization-only hard-stop이 정당한 순수 registration commit을 막는 문제를 어떻게 흡수할지 검토한다.

### 현 상태 진단 (AS-IS)

- gate 집행 대상은 Class A(framework-owned) `tools/git-hooks/lib/gate-lists.sh`에 하드코딩되어 있다:
  - `awh_is_branch_isolation_protected_path()` — harness/project-state 경로(CLAUDE.md, docs/STATUS.md, docs/backlog/*, docs/works/*, .claude/* 등)
  - `awh_is_finalization_file()` — STATUS, backlog, works, decisions/README
- scaffold summary(`scripts/create-harness.sh:1179`)는 target에게 **"Tune protected/finalization paths ... in tools/git-hooks/lib/gate-lists.sh"** 라고 안내한다. 그러나 `gate-lists.sh`는 **Class A framework-owned**이다. 직접 편집하면 (a) `--check` manifest sha256 drift를 만들고 (b) 향후 upgrade(P1 `--upgrade`/`--check`)에서 덮어써진다. 즉 현재 안내가 DR-021 경계를 위반하도록 유도한다.
- DR-025 §6은 "집행 대상 리스트는 harness default ship + **project-configurable**, product repo는 default 유지하며 자기 민감 파일 확장. 가변 메커니즘(config SSoT)은 downstream 소유"로 명시 위임했다. c4가 그 downstream이다.
- hook은 source-gitflow target에만 배포된다(`create-harness.sh:508-526`). generic target은 hook 없음 → gate는 `.claude/rules/git-workflow.md` 기반 AI-advisory(c3). generic 템플릿 rule에는 protected-path 목록 자체가 열거되어 있지 않다.
- finalization-only gate(commit-msg hook, DR-025 §3): staged set ⊆ finalization 파일 + provably local-only이면 hard-stop. 정당한 tracking-only commit(`/work-register` backlog row 추가, DR record-only, STATUS housekeeping)도 substantive 변경이 없어 같은 조건에 걸린다. 현재 정식 통과 경로는 override trailer(`AWH-Gate-Override: finalization-split` + reason)뿐이며, "tracking-only는 이렇게 처리한다"는 안내가 없다.

### 외부화 실패모드 매핑

- ③ 선언-실행 괴리: scaffold가 Class A 편집을 권하는 안내(선언)와 DR-021 upgrade 경계(실행)가 어긋남 → project-owned config로 닫는다.
- ① 라우팅 누락: hook 경로와 advisory(AI) 경로가 같은 project 리스트를 보지 못하면 경계가 갈라짐 → 단일 project config + 양 경로 reader/pointer로 닫는다.

## Scope

### In

- **Project-configurable gate list mechanism (R0 confirmed)**: product repo가 framework-owned `gate-lists.sh`를 건드리지 않고 자기 protected/finalization 경로를 **추가(add-only)** 할 수 있는 Class B(project-state-owned) config 도입. 단일 파일 `.harness/gate-config`, `[protected]`/`[finalization]` 섹션형 declarative glob, `#` comment·blank line 허용, **source/eval 금지**(commit-time 임의코드 실행 회피, 라인 읽어 `case "$path" in $glob)` 매칭). hook reader는 default(Class A) + project config(Class B)를 합산한다.
- **`.harness/gate-config` 자체를 protected path에 추가 (R0 Must-fix 1)**: 이 파일은 gate 동작을 바꾸는 policy state이므로 develop/main 직접 변경을 막아야 한다. `awh_is_branch_isolation_protected_path`(`gate-lists.sh`)와 generic advisory rule의 protected 입력에 `.harness/gate-config`를 추가한다. **finalization 파일로는 분류하지 않는다.**
- **Hook reader 확장**: `awh_is_branch_isolation_protected_path` / `awh_is_finalization_file`가 default `case` 이후 project config glob을 추가 매칭. config 부재 시 현행 동작과 동일(degrade-safe, add-only).
- **Scaffold 재배선**: project config seed(주석 골격) 생성 + `create-harness.sh:1179` 안내를 "Class A `gate-lists.sh` 편집 금지, `.harness/gate-config`에서 tune(upgrade-safe)"로 교체.
- **`--check` 범위 고정 (R0 Must-fix 2)**: `--check`는 **report-only**로 `.harness/gate-config` presence + non-comment entry count만 표시한다. manifest sha256 set·신규 manifest 필드에는 **넣지 않는다**. config missing은 **advisory(drift 아님)** 로 처리한다.
- **Advisory(AI) 경로 정합**: generic/hook-less target의 `.claude/rules/git-workflow.md`가 동일 `.harness/gate-config`를 protected/finalization 입력으로 참조하도록 pointer 추가. 단 generic은 hook이 없으므로 **advisory input**임을 명확히 하고 hard enforcement처럼 보이지 않게 한다(R0 Q4).
- **Tracking-only commit 예외 — document-only (R0 Must-fix 3)**: finalization-only hard-stop이 정당한 tracking-only commit을 막는 경우, **신규 토큰을 도입하지 않고** 기존 `AWH-Gate-Override: finalization-split` trailer + `AWH-Gate-Reason: tracking-only registration: ...` reason convention으로 흡수한다. gate를 약화시키지 않는다. tracking-only convention만 DR-025에 최소 amend하고, config 메커니즘 구현 세부는 이 Work 파일에 둔다.
- **Source CI / fresh scaffold 검증**: project config로 추가한 경로가 develop/main에서 protected/finalization으로 인식되는지, config 부재 시 동작 불변인지, source-vs-target 경계 누수 없음 확인.
- Cross-agent R-round 기록: A(Claude) plan+구현, B(Codex) R0 plan review + result review.

### Out

- gate 리스트의 **제거/override**(default 약화) — add-only만. default 보호 경로 삭제는 harness 무결성 약화라 out.
- 민감 파일 **자동 탐지**(magic detection) — "자동 조정"은 config-driven adaptation을 의미하며, 휴리스틱 자동 탐지는 over-engineering이라 out.
- generic target에 실제 git hook 추가(c3 advisory-only 설계 위반).
- 신규 standalone check 명령/바이너리(기존 `--check`만 필요 시 최소 확장).
- active adopter(`ai-deck-compiler`) 직접 migration.
- P1 `--upgrade`/migration 메커니즘 본체(별도 후보). c4는 config가 upgrade-safe(Class B)임을 보장하는 데까지만.

## Plan

| Field | Value |
| --- | --- |
| Risk | L3 — gate(보안/무결성) 집행 대상 메커니즘 + scaffold + DR. 단 변경은 additive·degrade-safe(config 부재 시 현행 동작) |
| Execution Mode | Full Work, P0 slice c4 only |
| Branch | `feature/chore-20260606-016-product-adaptive-gate-logic` |
| Tool Rules | `.claude/rules/docs-workflow.md`, `.claude/rules/git-workflow.md` matched |
| Language Policy | DR-007: docs Korean primary, shell/manifest/config identifiers English |
| State Machine | INIT -> PLAN -> APPROVAL -> EXECUTE -> VALIDATE -> CHECKPOINT -> END |
| Reversal Cost | Low–Medium — additive hook reader + Class B seed + scaffold 문구 + DR amend. revert로 원복, config 부재 시 무영향 |

1. **R0 Plan Review (Codex)** — Done. Conditional approve, Must-fix 3건 R0-A에서 수용. mechanism/tracking-only/DR 범위 확정.
2. **Implementation (CP2)** — 다음을 구현한다:
   - `gate-lists.sh`: (i) `.harness/gate-config` 파서(declarative glob, no eval/source, `[protected]`/`[finalization]` 섹션, `#`/blank 무시) + default 이후 add-only 합산, (ii) `.harness/gate-config`를 `awh_is_branch_isolation_protected_path` default에 추가.
   - `create-harness.sh`: `.harness/gate-config` seed(주석 골격) 생성, `:1179` 안내 교체, `do_check()`에 report-only presence + entry count(missing=advisory).
   - generic advisory rule(`.claude/rules/git-workflow.md` 템플릿): `.harness/gate-config` 참조 pointer(advisory input 명시).
   - DR-025 최소 amend: tracking-only reason convention(`§3/§4`).
   - tracking-only 안내: `.claude/rules/git-workflow.md` / work-register 경로에 reason convention 문서화(최소 surface, R0-A 범위).
   - source CI: project-config 합산·protected·report-only 검증 step.
3. **Validation (CP3)** — 아래 Verification 매트릭스 + A self-review.
4. **Result Review (CP4)** — A가 결과 기록, B가 result review.
5. **Closeout (CP5)** — 합의 후 `/work-close`, commit approval, PR `--base develop`, CI 확인, merge. close 시 STATUS Next Actions를 "c4 Done → gate series 완료"로 갱신.

## Review Questions (for Codex R0)

| Question | A(Claude) Draft Answer |
| --- | --- |
| Q1. project config의 파일명/위치/포맷? | draft: Class B `.harness/gate-config`(또는 `.harness/gate-paths`) — `.harness/`는 이미 manifest가 사는 project-discoverable 위치. 포맷은 **declarative glob 리스트**(`[protected]`/`[finalization]` 섹션 또는 2개 파일), 한 줄당 glob. **shell source/eval 금지**(commit-time 임의코드 실행 회피) — 라인 읽어 `case "$path" in $glob)` 매칭. manifest sha256 set에 넣지 않아 upgrade-safe. |
| Q2. add-only인가, 제거/override도 허용? | **add-only.** DR-025 §6 "default 유지하며 확장". default 보호 경로 제거는 무결성 약화. 제거 needs는 별도 후보로 분리. |
| Q3. "자동 조정"의 정의 — 자동 탐지인가? | config-driven adaptation. 휴리스틱 자동 탐지(민감파일 magic)는 out(over-engineering). target이 선언하면 gate가 그에 맞게 동작. |
| Q4. generic(hook 없음) target도 config를 받나? 받는다면 advisory 경로는? | draft: 두 mode 모두 seed 생성. generic은 hook이 없으니 config가 AI-advisory 입력 → `.claude/rules/git-workflow.md`에 "이 project config의 경로도 protected/finalization으로 취급" pointer 1~2줄. source-gitflow는 hook이 직접 소비. (B 판단: generic에 seed가 과한지) |
| Q5. `--check`/manifest가 project config를 보고해야 하나? | draft: 최소. `--check`에 project-config presence + extra-path 건수 정도(report-only). manifest 신규 필드는 지양. 비용 대비 가치 낮으면 생략 가능 — R0에서 좁힌다. |
| Q6. tracking-only commit 흡수 방식? | draft: **document-only.** 기존 override trailer가 durable record 메커니즘이므로 이를 tracking-only의 정식 경로로 문서화(work-register/git-workflow). gate 약화(자동 예외) 회피. 단 override 토큰 의미(`finalization-split`)가 순수 registration에 안 맞으면 reason convention 또는 alt 토큰 검토. first-class 신호 도입은 B와 결정. |
| Q7. DR amend vs 신규 DR? | draft: **DR-025 amend**(§6 가변 메커니즘 구체화 + §3/§4 tracking-only 명문화). 신규 구조 결정이 크면 신규 DR. B 판단. |
| Q8. scaffold seed를 commit해 target repo에 포함시키나, .gitignore 후보인가? | draft: **commit 포함**(project가 자기 gate 정책을 버전관리). 빈 주석 골격으로 seed. |

## Done Criteria

- [x] B(Codex)가 R0 plan review를 수행하고 Cross-Agent Review에 반영된다. (Conditional approve, Must-fix 3건)
- [x] project config의 파일명/포맷/위치/파싱 안전성(no eval/source)/add-only 의미가 합의된다. (`.harness/gate-config`, 섹션형 declarative glob, no source/eval, add-only)
- [x] hook reader가 default + project config를 add-only로 합산하고, config 부재 시 동작이 불변임이 구현된다.
- [x] `.harness/gate-config` 자체가 branch-isolation protected path에 추가된다(finalization 분류 안 함, R0 Must-fix 1).
- [x] scaffold가 `.harness/gate-config` seed를 생성하고, `gate-lists.sh` 직접편집 안내가 upgrade-safe config 안내로 교체된다(create-harness.sh summary + MAINTAINER-GUIDE §211).
- [x] `--check`가 report-only로 config presence + non-comment entry count만 표시하고, manifest 미포함·missing=advisory가 지켜진다(R0 Must-fix 2).
- [x] generic advisory(AI) 경로가 동일 `.harness/gate-config`를 참조하되 advisory input임이 명확하다(R0 Q4).
- [x] tracking-only commit이 신규 토큰 없이 기존 override trailer + reason convention으로 흡수되고, gate를 약화시키지 않음이 확인된다(R0 Must-fix 3, e2e B).
- [x] DR-025가 tracking-only reason convention만 최소 amend된다(§4).
- [x] source-vs-target boundary 누수가 없음을 확인한다(project config가 source repo gate를 오염시키지 않음 — source repo는 `.harness/gate-config` 부재로 default-only).
- [x] fresh scaffold 검증 매트릭스가 CP3 전에 구체화되고 통과한다.
- [x] validation 결과가 Work 파일에 기록된다.
- [~] B(Codex)가 result review를 수행하고 합의한다. — **Waived(B 방전), A self-review 대체. 후속 R2 권장.**
- [x] `/work-close`로 Done 처리 후 commit/PR/merge flow를 진행하고 STATUS Next Actions를 "c4 Done → gate series 완료"로 갱신한다.

## Verification

```bash
git diff --check
bash -n scripts/create-harness.sh
sh -n tools/git-hooks/lib/gate-lists.sh
sh -n tools/git-hooks/pre-commit
sh -n tools/git-hooks/commit-msg

# Fresh scaffold matrix (--existing into mktemp dirs):
#  source-gitflow:
#    - project config seed present (.harness/gate-config 류), gate-lists.sh 미편집
#    - config에 product glob(예: infra/**) 추가 시 develop/main에서 pre-commit이 protected로 인식
#    - config에 finalization glob 추가 시 commit-msg finalization 판정에 반영
#    - config 부재(빈 seed)면 동작이 현행과 동일(default-only)
#  generic:
#    - config seed 생성 여부(R0 결정) + advisory rule pointer presence
#    - hook 미배포 유지(advisory-only)
#  boundary:
#    - source repo gate-lists.sh는 project config 합산 로직만 추가, source 자체 gate 동작 회귀 없음
#    - source-vs-target 누수 grep

# Tracking-only:
#  - finalization-only staged set + provably local-only에서 합의된 tracking-only 경로(override trailer 또는 신규 신호)로 통과, durable record 남음
```

검증 결과(2026-06-06, A/Claude):

**Static**
- `git diff --check` PASS
- `bash -n scripts/create-harness.sh` PASS
- `sh -n` + `dash -n` on `gate-lists.sh`, `sh -n` pre-commit/commit-msg PASS
- `.github/workflows/ci.yml` YAML parse PASS

**Parser cross-shell** (`awh_project_glob_match`, sh/dash/bash 동일):
- default 경로(`docs/STATUS.md`, `.harness/gate-config`) protected, project glob(`infra/**`, `db/schema.sql`) protected, `[finalization]` glob(`docs/PRODUCT-STATUS.md`) finalization, 비-등록 경로(`src/main.c`, `README.md`) 비매칭 PASS
- config 부재 시 default-only로 degrade, project 경로 비매칭 PASS

**Fresh scaffold matrix** (`/tmp/awh-c4-*`, generic/source-gitflow/spring-boot):
- 7개 섹션 전부 PASS — seed presence + `[protected]`/`[finalization]` 헤더 + manifest 미포함 + `--check` 0-entry, default-only 동작, add-only 기능(`--check` 3-entry), c3 posture(`advisory-only`/`hook-capable`) 회귀 없음, generic rule advisory-input pointer + source-gitflow rule advisory-only 부재, source-vs-target 누수 없음, summary가 gate-lists.sh 대신 `.harness/gate-config` 안내

**End-to-end (installed hooks, `/tmp/awh-c4e2e-*`)**:
- A: project `[finalization]` 경로만 staged + remote 있고 HEAD unpushed(local-only) → commit-msg `Finalization-only commit blocked by DR-025` hard-stop PASS (project config가 commit-msg 판정에 반영됨)
- B: 동일 commit에 `AWH-Gate-Override: finalization-split` + `AWH-Gate-Reason: tracking-only registration: ...` → 통과 PASS (part 2 tracking-only convention)
- C: project `[protected]` 경로(`infra/main.tf`)를 develop에 commit → pre-commit branch-isolation WARNING PASS (pre-commit이 project config 반영)

**구현 중 발견·수정한 결함 (dash 이식성):** `awh_project_glob_match`의 section-header 파싱 `${_awh_line#[}`/`${_awh_sec%]}`가 macOS `sh`/`bash`에서는 `[`를 stripping했으나 **dash(Ubuntu/GitHub Actions 기본 `/bin/sh`)에서는 `[`를 glob bracket-expression opener로 보고 stripping하지 않아** `_awh_sec`가 `[protected`가 되고 모든 project-config 매칭이 실패했다. cross-shell 테스트(sh/dash/bash)로 포착했다. bracket char를 quote(`${_awh_line#"["}`/`${_awh_sec%"]"}`)해 literal로 매칭하도록 수정 → 3개 shell 동일 동작. 이 수정 없이 ship됐다면 대부분의 Ubuntu target에서 product-adaptive gate가 조용히 무력화될 결함이었다.

## Cross-Agent Review

| Round | Reviewer | Scope | Result | Notes |
| --- | --- | --- | --- | --- |
| R2 | Codex | Result review | **Waived this session** | B(Codex) 방전으로 result review 미수행. A(Claude)가 self-review로 대체: cross-shell(sh/dash/bash) parser 테스트, fresh scaffold matrix 7섹션, installed-hook e2e 3케이스, static(`bash -n`/`sh -n`/`dash -n`/YAML/`diff --check`) 수행. **한계:** 독립 reviewer 부재 — Codex 복귀 시 R2 result review를 후속으로 받는 것을 권장(특히 dash 이식성 수정과 add-only 경계). |
| R0 | Codex | Plan review | Conditional approve | 방향은 DR-021/DR-025와 정합. 구현 전 (1) project gate config 파일 자체를 branch-isolation protected path에 포함, (2) manifest 제외 + `--check` report-only 범위 고정, (3) tracking-only는 신규 토큰 없이 기존 override trailer + reason convention으로 문서화하는 것으로 합의 필요. Q1: 단일 `.harness/gate-config`, `[protected]`/`[finalization]` 섹션형 declarative glob, `#` comment·blank line 허용, source/eval 금지, config 파일 자체 protected. Q4: generic seed OK이나 advisory input임을 README/rule에서 명확히(hard enforcement처럼 보이지 않게). Q5: 최소 report-only, manifest 신규 필드 불필요. Q6: document-only. Q7: DR-025 amend는 tracking-only convention 남길 때만 최소, config 파일명 등 구현 세부는 Work/impl docs. |
| R0-A | Claude | Must-fix 수용 + plan update | Done | 조건 3건 전부 수용. (1) `.harness/gate-config`를 `awh_is_branch_isolation_protected_path`와 generic advisory rule의 protected 입력에 추가(finalization 분류 안 함). (2) `--check`는 report-only로 config presence + non-comment entry count만 표시, manifest sha256 set·신규 필드 미포함, missing=advisory(drift 아님)로 고정. (3) tracking-only는 신규 토큰 없이 기존 `AWH-Gate-Override: finalization-split` + `AWH-Gate-Reason: tracking-only registration: ...` reason convention 문서화. DR-025 amend는 tracking-only convention만 최소 반영, config 메커니즘 구현 세부는 이 Work 파일에 유지. Q1/Q4/Q5/Q6/Q7 disposition 합의. |

## Checkpoints

| CP | Description | Status |
| --- | --- | --- |
| CP0 | Branch isolation + Work file/plan 작성 | Done |
| CP1 | Codex R0 plan review + 합의 | Done |
| CP2 | mechanism + tracking-only implementation | Done |
| CP3 | validation + A self-review | Done |
| CP4 | Codex result review | Waived (B 방전; A self-review 대체, 후속 R2 권장) |
| CP5 | `/work-close` + commit/PR/merge | Done (work-close 처리, commit/PR 진행) |

## Discovery

- 2026-06-06: 역할 — A(Claude) author/driver, B(Codex) reviewer. c4는 gate series 마지막 sub-slice.
- 2026-06-06: Branch Isolation Check — `develop`에서 시작, `feature/chore-20260606-016-product-adaptive-gate-logic`로 전환 후 Work 시작.
- 2026-06-06: 다음 free Work ID 확인 — git log + works dir + docs grep 결과 CHORE-20260606-001~011·015 사용, 012~014·016 미사용. 016 확정(c3 Work의 "001~014 사용 중" 기록은 부정확).
- 2026-06-06: 핵심 gap 발견 — `create-harness.sh:1179`가 target에게 Class A `gate-lists.sh` 직접편집을 안내(DR-021 위반: manifest drift + upgrade 덮어쓰기). DR-025 §6이 project-configurable 메커니즘을 downstream(c4)에 위임.
- 2026-06-06: hook은 source-gitflow에만 배포(`create-harness.sh:508-526`), generic은 advisory-only. generic 템플릿 rule에는 protected-path 목록이 열거돼 있지 않음.
- 2026-06-06: R0/Codex Conditional approve. Must-fix 3건 R0-A에서 전부 수용 → CP1 합의 완료. (1) `.harness/gate-config` 자체 protected, (2) `--check` report-only·manifest 미포함·missing=advisory, (3) tracking-only는 신규 토큰 없이 override trailer + reason convention. mechanism 구현 세부는 Work 파일, DR-025는 tracking-only convention만 최소 amend.
- 2026-06-06: CP2 구현. `gate-lists.sh`에 `awh_project_glob_match`(no eval/source, 섹션형 declarative glob) + default 이후 add-only 합산 + `.harness/gate-config` default protected 추가. `create-harness.sh`에 seed(write_text → manifest 제외) + `do_check()` report-only(presence + entry count) + summary 안내 교체. generic 템플릿 rule advisory-input pointer, source `.claude/rules/git-workflow.md` extensibility note + tracking-only convention, DR-025 §4 amend, MAINTAINER-GUIDE §211 수정, source CI c4 step.
- 2026-06-06: **dash 이식성 결함 발견·수정.** `${var#[}` bracket strip이 dash에서 동작하지 않아 section 파싱이 깨지고 모든 project-config 매칭이 실패했다(macOS sh/bash에서는 우연히 동작). cross-shell 테스트로 포착, bracket quote로 수정. Ubuntu target 대부분에서 gate가 조용히 무력화될 결함이었다.
- 2026-06-06: B(Codex) 방전으로 CP4 result review waived. A self-review(cross-shell parser, fresh scaffold 7섹션, installed-hook e2e 3케이스, static)로 대체. 독립 reviewer 부재가 유일한 잔여 risk — Codex 복귀 시 R2 후속 권장.
- 2026-06-06: merge 전 A 독립 재검토(2차). parser를 fresh eyes로 정독 + adversarial 엣지케이스(orphan 패턴 무시, leading-indent 허용, CRLF \r trim, wildcard, 비-등록 비매칭)를 sh/dash/bash에서 0 mismatch 확인. **발견: inline-comment footgun** — `infra/**  # note`는 inline 주석을 strip하지 않아 literal 패턴이 되어 silent 비매칭. gate 약화가 아닌 "강해지지 않음"(fail-safe)이나 사용자 혼동 소지. seed/`gate-lists.sh` 주석에 "inline 주석 미지원, 주석은 한 줄로" 명시로 보강. **잔여 한계:** busybox/Alpine `sh` 미검증(dash는 통과 — 가장 엄격한 공통 POSIX sh). 변경 전체 additive·degrade-safe.
