---
id: CHORE-20260606-015
priority: P0
status: Archived
risk: High
scope: gate-enforcement-runtime-and-env slice c3 hook-less/generic target documented advisory and manifest-based check
appetite: 2d
planned_start: 2026-06-06
planned_end: 2026-06-08
actual_end: 2026-06-06
related_dr: [DR-021, DR-024, DR-025]
related_troubleshooting: []
related_work: [CHORE-20260606-004]
---

# Hook-less / Generic Target Advisory + Manifest Check — Slice C3

> 역할(이번 slice는 swap): A(Claude)가 Work 파일+plan을 작성하고 B(Codex)가 Cross-Agent Review R-round를 수행한다. 합의 후 A가 구현하고 B가 결과 검토한다.

## Context

`gate-enforcement-runtime-and-env` P0 series는 종료 전까지 0순위로 유지한다.

완료된 선행 slice:

- (a) source hook runtime — CHORE-20260606-006
- (b) shared gate-list SSoT — CHORE-20260606-007
- (c1) source-gitflow opt-in hook 배포 — CHORE-20260606-008
- (c2-A) source repo CI hardening — CHORE-20260606-009
- (c2-B) target CI template + ruleset handoff — CHORE-20260606-010
- (d) source-gitflow environment bootstrap — CHORE-20260606-011

이번 slice는 **(c3) hook-less/generic target documented advisory + manifest 기반 check**이다.

현 상태 진단:

- source-gitflow target은 hook(c1) + CI(c2-B) + bootstrap(d)로 gate를 런타임 강제한다.
- generic/hook-less target은 `tools/git-hooks/`를 받지 않는다(DR-025 §47: hook 미설치 시 gate는 AI-advisory). 그러나 generic target의 `.claude/rules/git-workflow.md`에는 "hook이 없어 branch-isolation·finalization-bundling·commit gate가 honor-system advisory"라는 **명시가 없다**. 사용자/agent가 enforcement posture를 오인할 수 있다.
- `.harness/manifest.json`은 이미 `workflow_mode`(generic/source-gitflow), `profile`, `with_optional`를 기록한다(`scripts/create-harness.sh:623`). 즉 enforcement posture는 이미 machine-discoverable다.
- `scripts/create-harness.sh --check`는 framework-file drift만 보고하고, target이 hook-gated인지 advisory-only인지는 보고하지 않는다.

따라서 c3는 (1) hook-less/generic target의 advisory posture를 명시 문서화하고, (2) 이미 존재하는 manifest `workflow_mode`를 활용해 `--check`가 enforcement posture를 보고하도록 최소 확장한다. 신규 필드/명령은 만들지 않는 것을 기본 방향으로 둔다.

## Scope

### In

- **Documented advisory**: hook-less/generic target은 git hook이 없어 gate(branch isolation, finalization bundling, commit message)가 AI advisory/honor-system임을 명시한다. hook enforcement opt-in 경로(`--workflow source-gitflow`)를 함께 안내한다. (정확한 surface 위치는 R0에서 B와 확정)
- **Manifest-based check**: `scripts/create-harness.sh --check`에 manifest `workflow_mode` 기반 enforcement posture 보고(예: `advisory-only (no hooks)` vs `hook-gated`)를 추가한다. report-only 유지. gate-relevant 파일(advisory rule 등) presence/drift까지 볼지는 R0에서 성공 기준을 좁힌다.
- **Source CI / fresh scaffold 검증**: generic scaffold에 advisory doc presence + `workflow_mode=generic` + posture line 확인, source-gitflow scaffold는 hook-gated posture 확인·advisory 중복 없음, generic/source-gitflow 경계 누수 grep.
- Cross-agent R-round 기록: A(Claude) plan + 구현, B(Codex) R0 plan review + result review.

### Out

- c4 product-adaptive gate logic, tracking-only commit 예외 흡수.
- generic target에 실제 git hook 추가(advisory-only 설계 위반).
- 신규 standalone check 명령/바이너리(기존 `--check`만 확장).
- 신규 DR 신설(원칙은 DR-024/025/021 재사용). 단 posture 문구를 SSoT로 박아야 하면 최소 amend는 포함 가능.
- d source-gitflow environment bootstrap(완료).
- active adopter(`ai-deck-compiler`) 직접 migration.

## Plan

| Field | Value |
| --- | --- |
| Risk | L2–L3 - scaffold generated docs + `--check` 출력 + source CI 변경 |
| Execution Mode | Full Work, P0 slice c3 only |
| Branch | `feature/chore-20260606-015-hookless-advisory-manifest-check` |
| Tool Rules | `.claude/rules/docs-workflow.md`, `.claude/rules/git-workflow.md` matched |
| Language Policy | DR-007 적용: docs Korean primary, shell/manifest identifiers English |
| State Machine | INIT -> PLAN -> APPROVAL -> EXECUTE -> VALIDATE -> CHECKPOINT -> END |

1. **R0 Plan Review (Codex)**
   - 이 Work 파일의 Scope/Out/Review Questions를 B(Codex)가 검토한다.
   - 합의 전에는 implementation을 시작하지 않는다.
   - R-round 결과는 아래 `Cross-Agent Review`에 누적한다.

2. **Advisory Surface 확정 (R0 Must-fix 2 반영)**
   - advisory posture는 cross-tool fact이므로 Claude 전용 surface 하나로는 부족하다(Codex/Cursor/user 경로 누락).
   - **합의: 두 surface에 generic 한정으로 배치한다.**
     - (a) generated `README.md` generic-only 짧은 "Workflow enforcement" note — cross-tool + human front-door로 모든 adopter가 읽는 universal 경로.
     - (b) generic `.claude/rules/git-workflow.md` advisory posture 한 줄 — Claude agent의 gate rule이 이미 사는 자리에 posture를 co-locate.
   - 근거: README는 도구 무관·사람 포함 universal catch, `.claude/rules`는 gate rule locus. Codex(AGENTS)·Cursor(.cursor/rules) entry는 shared docs로 routing되며 README note가 cross-tool 누락을 막는다. opt-in 경로(`--workflow source-gitflow`)를 한 줄 링크. core 문서 비대화 방지를 위해 각 1~2줄로 제한.

3. **Manifest Check 확장 범위 확정 (R0 Must-fix 1 + Nice-to-have 1 반영)**
   - **posture label은 hook 설치 상태를 과잉 주장하지 않는다.** `workflow_mode`는 hook 파일 배포 여부일 뿐 `.git/hooks` 설치 여부가 아니므로:
     - generic → `enforcement: advisory-only (no hook files)`
     - source-gitflow → `enforcement: hook-capable (source-gitflow hook files present; run tools/git-hooks/install.sh to activate)`
   - **missing/old manifest에서 `workflow_mode`가 없거나 빈 값이면 invalid로 실패시키지 않고 `enforcement: unknown (workflow_mode not recorded)`로 degrade**하고 계속 진행한다(기존 `--check`의 degrade-friendly 정책과 일관).
   - 성공 기준: posture line + advisory rule 파일 presence 1건(**generic 한정**). file drift는 기존 framework-file 로직이 커버하므로 중복하지 않는다.
   - (선택) `.git/hooks/pre-commit` 실제 설치 감지로 `hook-capable` → `hook-installed` 승격은 구현 시 비용 대비 가치로 판단. 기본 산출물은 아니다.

4. **Implementation**
   - generic advisory 문구를 (a) generated README generic-only note + (b) generic `.claude/rules/git-workflow.md`에 추가.
   - `do_check()`에 manifest `workflow_mode` 읽어 posture 출력 추가(위 label·degrade 규칙).
   - source CI에 generic advisory presence + posture 검증, **source-gitflow에는 advisory-only 문구 부재 assertion(R0 Must-fix 3, 양방향)** 추가.

5. **Validation**
   - `git diff --check`
   - `bash -n scripts/create-harness.sh`
   - fresh generic scaffold: README+rules advisory presence, `workflow_mode=generic`, `--check` posture=`advisory-only`.
   - fresh source-gitflow scaffold: `--check` posture=`hook-capable`, **advisory-only 문구 부재**.
   - missing/empty `workflow_mode` manifest에서 `--check`가 `unknown` posture로 degrade하고 비정상 종료하지 않음.
   - `--with-optional` / `--profile spring-boot` 조합 충돌 없음.
   - source-vs-target 누수 grep.

6. **Result Review / Closeout**
   - A(Claude)가 구현/검증 결과를 Work 파일에 기록한다.
   - B(Codex)가 result review를 수행하고 R-round에 누적한다.
   - 합의 후 `/work-close`, commit approval, PR `--base develop`, CI 확인, merge 순서로 진행한다.
   - close 시 STATUS Next Actions를 "c3 Done, 잔여 c4"로 갱신한다.

## Review Questions (for Codex R0)

| Question | A(Claude) Draft Answer |
| --- | --- |
| Q1. advisory posture 문서 surface는 어디에 둬야 하나? | **합의(R0 Must-fix 2):** Claude 전용 surface 하나로는 cross-tool 누락. generated README generic-only note(universal) + generic `.claude/rules/git-workflow.md` posture 한 줄, 둘 다 generic 한정. opt-in 경로 링크. 각 1~2줄. |
| Q2. `--check`에 enforcement posture 출력을 추가해야 하나, 별도 출력이 필요한가? | 기존 `--check`에 한 줄 posture 추가. **단 label은 hook 설치를 과잉 주장하지 않음(R0 Must-fix 1):** `advisory-only` / `hook-capable` / `unknown`. 신규 필드/명령 불필요. |
| Q3. "manifest 기반 check"의 성공 기준은? | posture 보고 + advisory rule 파일 presence 1건(**generic 한정**). source-gitflow는 advisory-only 문구 부재를 assert(R0 Must-fix 3). file drift는 기존 로직이 커버. missing/empty `workflow_mode`는 `unknown`으로 degrade(R0 Nice-to-have 1). |
| Q4. advisory 강도는 어디까지? | DR-025 §47(hook 미설치 → advisory-only)을 근거로 짧게 명시. 별도 enforcement-posture 표는 과할 수 있어 prose 1~2줄 + opt-in 링크로 제한. |
| Q5. generic/source-gitflow 경계에서 advisory가 generic 한정으로만 들어가나? | yes. source-gitflow는 이미 hook/CI/bootstrap 안내가 있어 advisory-only 문구가 들어가면 모순. WORKFLOW_MODE 분기로 generic 전용 배치 + source-gitflow 부재 assertion(양방향). |
| Q6. DR amend가 필요한가? | **합의: no.** DR-024/025/021로 충분(R0 Nice-to-have 2 일치). |

## Done Criteria

- [x] B(Codex)가 R0 plan review를 수행하고 Cross-Agent Review에 반영된다.
- [x] advisory posture 문서 surface가 합의된다(README generic-only note + `.claude/rules`).
- [x] `--check` posture 출력과 manifest check 성공 기준이 합의된다(`advisory-only`/`hook-capable`/`unknown` label, overclaim 금지).
- [x] generic/source-gitflow 경계가 유지된다(advisory는 generic 한정 + source-gitflow 부재 assertion 양방향).
- [x] missing/empty `workflow_mode` manifest에서 `--check`가 `unknown` posture로 degrade하고 실패하지 않는다.
- [x] 합의된 advisory 문서(2 surface) / `--check` 확장 / source CI 검증이 구현된다.
- [x] fresh scaffold 검증 command가 CP3 전에 구체화된다.
- [x] source-vs-target boundary 누수가 없음을 확인한다.
- [x] validation 결과가 Work 파일에 기록된다.
- [x] B(Codex)가 result review를 수행하고 합의한다.
- [x] `/work-close`로 Done 처리 후 commit/PR/merge flow를 진행하고 STATUS Next Actions를 c4 잔여로 갱신한다.

## Verification

```bash
git diff --check
bash -n scripts/create-harness.sh
ruby -e 'require "yaml"; YAML.load_file(".github/workflows/ci.yml"); puts "yaml ok"'

# Fresh scaffold matrix (--existing into mktemp dirs):
#  generic:        README "Workflow enforcement (advisory-only)" present,
#                  .claude/rules/git-workflow.md "Enforcement Posture (advisory-only)" present,
#                  manifest workflow_mode=generic, --check enforcement=advisory-only
#  source-gitflow: --check enforcement=hook-capable, advisory-only 문구 부재(README+rule)
#  spring-boot(generic workflow): --check enforcement=advisory-only
#  unknown degrade: manifest에서 workflow_mode 제거 → --check enforcement=unknown, exit 0 (no crash)
```

검증 결과(2026-06-06, A/Claude):

- `bash -n scripts/create-harness.sh` PASS
- `git diff --check` PASS
- YAML parse `.github/workflows/ci.yml` PASS
- generic scaffold: README note + rule posture + `workflow_mode=generic` + `--check` posture=`advisory-only` PASS (exit 0)
- source-gitflow scaffold: `--check` posture=`hook-capable`, advisory-only 문구 부재(README/rule 0 hits) PASS (exit 0)
- spring-boot(generic workflow) scaffold: `--check` posture=`advisory-only` PASS
- unknown degrade: `workflow_mode` 제거 manifest에서 `--check` posture=`unknown (workflow_mode not recorded)`, 비정상 종료 없음 PASS

**구현 중 발견·수정한 결함:** `do_check()`의 신규 `m_workflow="$(field workflow_mode)"`가 `set -euo pipefail`(L31) 하에서 workflow_mode 부재 시 `field()` grep 실패 → pipefail 전파 → 스크립트 abort(출력 없이 종료)를 일으켰다. 이는 정확히 unknown-degrade 케이스를 깨뜨렸다. `m_workflow="$(field workflow_mode || true)"`로 수정해 degrade가 의도대로 동작하게 했다. 기존 필수 필드(harness_version/project_name)는 항상 존재해 노출되지 않던 잠재 결함이었다.

## Cross-Agent Review

| Round | Reviewer | Scope | Result | Notes |
| --- | --- | --- | --- | --- |
| R0 | Codex | Plan review | Approve-with-changes | 방향은 타당하나 구현 전 Must-fix 3건 필요. (1) `--check`가 manifest `workflow_mode=source-gitflow`만 보고 `hook-gated`라고 출력하면 과잉 주장이다. hook 파일 배포와 `.git/hooks` 설치는 다르므로, 실제 hook 설치 상태를 검사하지 않을 거면 label을 `hook-capable`/`source-gitflow files present`처럼 낮춰야 한다. (2) advisory posture surface를 generic `.claude/rules/git-workflow.md`에만 두면 Codex/Cursor/user-facing 경로에서 놓칠 수 있다. 짧은 shared generated surface(예: README 또는 BOOTSTRAP의 conditional note)를 하나 포함하거나, 왜 `.claude/rules`가 충분한지 근거를 명시해야 한다. (3) advisory rule presence check는 generic 한정으로 정의하고 source-gitflow에는 advisory-only 문구가 없어야 함을 assertion해야 한다. Nice-to-have: missing/old manifest에서 `workflow_mode`가 없거나 unknown일 때 `--check`가 invalid로 죽을지, `unknown` posture로 degrade할지 명시. DR amend는 현재 불필요. |
| R0-A | Claude | Must-fix 수용 + plan update | Done | Must-fix 3건 전부 수용. (1) posture label을 `advisory-only`/`hook-capable`/`unknown`으로 확정해 hook 설치 과잉 주장 제거(`.git/hooks` 실제 설치 감지는 선택적 승격으로 분리). (2) advisory surface를 generated README generic-only note(universal) + generic `.claude/rules/git-workflow.md` 두 곳으로 확정, cross-tool 근거 명시. (3) advisory presence는 generic 한정, source-gitflow는 advisory-only 문구 부재를 양방향 assert. Nice-to-have: missing/empty `workflow_mode` → `unknown` degrade(no-fail) 채택, DR amend 없음 합의. |
| R2 | Codex | Result review | Approve | Must-fix 없음. (1) posture label은 `advisory-only`/`hook-capable`/`unknown`으로 overclaim 없이 정확함. (2) advisory surface는 generated README + generic `.claude/rules` 2곳에 generic 한정으로 들어가고, source-gitflow 부재 assertion도 CI에 있음. (3) `field workflow_mode || true`로 unknown degrade가 `set -euo pipefail` 아래에서도 동작함을 독립 matrix로 확인. (4) c4/product-adaptive/finalization logic 유입 없음. Nice-to-have: 없음. |

## Checkpoints

| CP | Description | Status |
| --- | --- | --- |
| CP0 | Branch isolation + Work file/plan 작성 | Done |
| CP1 | Codex R0 plan review + 합의 | Done |
| CP2 | advisory + manifest check implementation | Done |
| CP3 | validation + A self-review | Done |
| CP4 | Codex result review | Done |
| CP5 | `/work-close` + commit/PR/merge | In Progress |

## Discovery

- 2026-06-06: 역할 swap. 이번 c3 slice는 A(Claude) author/driver, B(Codex) reviewer로 진행한다.
- 2026-06-06: Branch Isolation Check 결과 `develop`에서 시작했고, `feature/chore-20260606-015-hookless-advisory-manifest-check` 브랜치로 전환한 뒤 이 Work를 시작했다.
- 2026-06-06: manifest는 이미 `workflow_mode`/`profile`/`with_optional`를 기록하므로(`scripts/create-harness.sh:623`), c3는 신규 필드 없이 기존 `--check` + manifest로 enforcement posture를 보고할 수 있다.
- 2026-06-06: ID 사용 현황 확인 — CHORE-20260606-001~014 사용 중, 015가 다음 free ID다.
- 2026-06-06: 구현. generic advisory를 2 surface(generated README generic-only note via `ENFORCEMENT_NOTE` 변수 + generic 전용 `scripts/templates/default/.claude/rules/git-workflow.md`)에 배치. `do_check()`에 posture line(`advisory-only`/`hook-capable`/`unknown`) 추가. source CI에 generic presence+posture step과 source-gitflow posture+advisory부재 assertion 추가.
- 2026-06-06: self-validation 중 `set -euo pipefail` × optional field 추출 abort 결함을 발견·수정(`field workflow_mode || true`). unknown-degrade 케이스가 이 수정으로 통과.
- 2026-06-06: R2/Codex result review. 독립 검증: `git diff --check`, `bash -n scripts/create-harness.sh`, workflow YAML parse, fresh scaffold matrix(`/private/tmp/awh-c3-r2-7T6WPh`) PASS. generic/spring은 advisory-only, source-gitflow는 hook-capable, workflow_mode 누락 manifest는 unknown posture로 degrade함을 확인.
