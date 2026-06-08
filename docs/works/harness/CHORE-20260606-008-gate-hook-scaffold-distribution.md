---
id: CHORE-20260606-008
priority: P1
status: Done
risk: High
scope: gate-enforcement-runtime-and-env slice (c1) source-gitflow scaffold hook distribution (opt-in)
appetite: 3d
planned_start: 2026-06-06
planned_end: 2026-06-08
actual_end: 2026-06-06
related_dr: [DR-021, DR-024, DR-025]
related_troubleshooting: []
related_work: [CHORE-20260606-004]
---

# Gate Hook Scaffold Distribution — Slice C1

> 역할: 이 slice는 A(Claude)가 Work+plan을 작성하고 B(Codex)가 Cross-Agent Review(R-round)를 수행한다. 합의 후 A가 구현하고 B가 결과 검토한다. 이전 (a)/(b)와 author/reviewer가 반대다.

## Context

CHORE-20260606-006(slice a, source hook runtime)와 CHORE-20260606-007(slice b, shared POSIX shell gate-list SSoT)는 Done/merge되었다.
현재 `tools/git-hooks/`(pre-commit, commit-msg, install.sh, lib/gate-lists.sh)는 **source repository에만** 존재하고, `scripts/create-harness.sh`는 `tools/`를 전혀 복사하지 않는다. 따라서 모든 scaffold target은 hook 미배포 = advisory-only 상태다(DR-025 §5 확정).

`docs/STATUS.md` Next Actions와 `docs/backlog/HARNESS.md`의 `gate-enforcement-runtime-and-env` 후보는 다음으로 (c) target scaffold hook 배포·install UX·CI/documented advisory 대안을 가리킨다. (c)는 단일 항목이 아니라 묶음이라 sub-slice로 분해한다.

## Sub-Slice Selection

**선정:** (c)의 첫 sub-slice는 **c1 = `--workflow source-gitflow` scaffold에 한정한 gate hook opt-in 배포**로 둔다.

**이유:**

- DR-025 §5는 target hard enforcement를 "downstream의 hook 배포 결정"에 위임했다. 그 배포 결정의 가장 좁고 boundary-safe한 첫 형태는, 이미 존재하는 `source-gitflow` opt-in marker 메커니즘(FEAT-20260527-001)을 그대로 확장해 "source-style workflow를 선택한 target에만 source-style gate hook을 함께 깐다"는 것이다.
- generic scaffold는 hook 0개(advisory-only)를 유지하므로 DR-021 source-vs-target 경계와 DR-025 §5 기본값이 보존된다.
- CI 대안(c2), hook-less target용 documented advisory/manifest check(c3), product-adaptive gate logic(c4)은 배포 메커니즘이 안정된 뒤 별도 sub-slice로 분리한다.
- hook **파일 배포**와 hook **설치(.git/hooks symlink)**는 다르다. 설치는 target이 git repo여야 가능하고 이는 slice (d) source-gitflow environment bootstrap의 영역이다. c1은 파일 배포 + 설치 안내까지만 하고 실제 `install.sh` 실행/`git init`은 (d)/사용자에게 남긴다(직교 유지).

## Review Questions (for Codex R-round)

| Question | Claude Draft Answer |
| --- | --- |
| 1. 첫 sub-slice를 c1(source-gitflow opt-in 배포)로 잡는 게 맞는가? | 맞다고 본다. 기존 marker opt-in을 확장하는 최소 변경이고 generic 누수가 구조적으로 차단된다. |
| 2. hook 파일을 template 디렉터리에 복제할 것인가, live `tools/git-hooks/`에서 복사할 것인가? | live `tools/git-hooks/`에서 `adapt`/copy 제안. `scripts/templates/source-gitflow/`에 hook을 복제하면 gate-lists.sh가 2곳이 되어 slice b가 없앤 중복이 재발한다. drift surface 최소화가 목적. Codex 판단 요청. |
| 3. target에 배포되는 gate-lists.sh를 source 그대로 둘 것인가, target용으로 조정할 것인가? | c1에서는 source 그대로 배포 제안(대부분의 path가 source-gitflow target에도 존재; 없는 path는 case-match 미스로 무해). product repo 고유 sensitive path 확장은 "project-configurable"(사용자 편집)로 남기고 문서화. target-specific default 분리는 필요해지면 c4로. |
| 4. c1이 실제 hook 설치(`install.sh` 실행)까지 할 것인가? | 아니다. 파일 배포 + "git init 후 `sh tools/git-hooks/install.sh` 실행" 안내까지만. 설치/`git init`은 (d)와 직교. no-git target에서 강제 설치 시도 금지. |
| 5. generic scaffold에 hook이 새지 않음을 어떻게 보증하는가? | 배포 분기를 `WORKFLOW_MODE == source-gitflow`에만 두고, generic/spring-boot dry-run + real temp scaffold에서 `tools/git-hooks` 부재를 검증한다. |

## Scope

### In Scope

- `scripts/create-harness.sh`: `--workflow source-gitflow`일 때만 `tools/git-hooks/{pre-commit,commit-msg,install.sh,lib/gate-lists.sh}`를 target에 배포. (R1-P1b) raw `cp`가 아니라 기존 `adapt()`를 거쳐 manifest에 framework-owned 파일로 기록한다. `adapt()`는 chmod를 하지 않으므로 exec hook 3개(pre-commit/commit-msg/install.sh)는 배포 후 명시적 `chmod +x`, gate-lists.sh는 non-exec 유지.
- 배포된 hook의 install 안내를 scaffold 종료 메시지 또는 생성되는 onboarding 문서에 최소 한 줄 추가(“git init 후 `sh tools/git-hooks/install.sh`”).
- (R1-P1a) hook-boundary 문구 정정 — 아래 3개 문서가 현재 "scaffold target은 harness hook 미배포/복사 안 함"이라 c1과 충돌하므로 "generic target = 미배포 / source-gitflow opt-in target = 배포(+gate-lists.sh를 자기 sensitive path로 확장)"로 정정:
  - `scripts/templates/source-gitflow/docs/GIT-WORKFLOW.md` §6 (target에 배포되는 문서)
  - `docs/GIT-WORKFLOW.md` (source) §6 note
  - `docs/HARNESS-MAINTAINER-GUIDE.md` §10
- generic/spring-boot scaffold에는 hook 미배포(advisory-only) 유지 확인.
- Cross-Agent Review R-round 누적.

### Out Of Scope

- CI 대안(GitHub Actions 등) 구현 — c2.
- hook-less/generic target용 documented advisory 또는 manifest 기반 check 보완 — c3.
- product-adaptive gate logic(target 고유 protected/finalization list 자동 조정) — c4.
- source-gitflow environment bootstrap(git init/main/develop/origin/branch protection), 실제 hook 설치 실행 — slice (d).
- `.harness/config.json`/Python helper 재도입(slice b에서 Design 2로 종결).
- source repo 자체 hook/gate 로직 변경(slice a/b 결과 보존).
- README/user-facing 문서 대규모 재개편(필요한 최소 안내만).

## Plan

| Field | Value |
| --- | --- |
| Risk | L3 - scaffold 출력 surface 변경 + source-vs-target 경계. 잘못되면 generic adopter가 원치 않는 hard gate를 상속 |
| Execution Mode | Full Work, slice (c1) only |
| Current State | Branch Isolation Check 완료: `develop` + `policy_type: source-gitflow`에서 `feature/chore-20260606-008-gate-hook-scaffold-distribution`로 전환 |
| Tool Rules | `.claude/rules/docs-workflow.md`, `.claude/rules/git-workflow.md` matched |
| Language Policy | DR-007 적용: docs는 Korean primary + Bilingual Rules, 코드/식별자는 English |
| State Machine | INIT -> PLAN -> APPROVAL -> EXECUTE -> VALIDATE -> CHECKPOINT -> END |

1. **R0 Plan Review (Codex)**
   - 이 Work 파일의 sub-slice 선정·배포 메커니즘 선택(Q2)·target gate-lists 정책(Q3)·boundary 보증(Q5)을 Codex가 검토하고 `Cross-Agent Review`에 R-round를 누적한다.
   - 합의 후에만 구현에 착수한다.

2. **배포 메커니즘 구현** (Q2 합의: live `tools/git-hooks/`를 `adapt()` 경유)
   - `create-harness.sh`의 source-gitflow 분기(현 `docs/GIT-WORKFLOW.md` 배포 지점 부근)에 hook 배포를 추가한다.
   - live `tools/git-hooks/`의 pre-commit/commit-msg/install.sh/lib/gate-lists.sh를 `adapt()`로 target에 배포(manifest 기록 포함). 이후 exec hook 3개에 `chmod +x`, gate-lists.sh는 non-exec.
   - template 디렉터리에 hook을 복제하지 않는다(gate-lists 중복 재발 방지).

3. **문서 hook-boundary 정정** (R1-P1a)
   - 위 3개 문서를 "generic = 미배포 / source-gitflow opt-in = 배포 + gate-lists.sh 사용자 확장"으로 정정한다. cascade: source `docs/GIT-WORKFLOW.md` → template GIT-WORKFLOW.md → MAINTAINER-GUIDE §10 정합.

4. **Install 안내**
   - scaffold 완료 메시지 또는 생성 문서에 "source-gitflow target: git repo 초기화 후 `sh tools/git-hooks/install.sh`로 gate hook을 설치하세요" 한 줄을 추가한다. 실제 설치는 실행하지 않는다.

5. **Leakage 방지 확인**
   - 배포 분기가 `WORKFLOW_MODE == source-gitflow`에만 걸리는지 확인한다.
   - generic/spring-boot scaffold 결과에 `tools/git-hooks`가 없음을 확인한다.

6. **Validation** (R1-P1c: workflow×profile 4조합)
   - `git diff --check`
   - `bash -n scripts/create-harness.sh`
   - dry-run: generic / spring-boot / source-gitflow / spring-boot+source-gitflow 4조합 출력 확인
   - real temp scaffold 4조합: source-gitflow 2종 target에 hook 4개 존재 + exec 3개 권한 확인, generic 2종 target에 hook 부재 확인
   - 배포된 target에서 `sh -n` hooks + `sh -n lib/gate-lists.sh` 통과, manifest에 hook 경로 기록 확인
   - scope guard: `git diff --name-only`로 CI/product-adaptive/source repo gate 로직/`.harness/config.json` 변경이 섞이지 않았는지 확인

7. **Result Review / Closeout (Codex)**
   - Claude self-validation 결과를 Checkpoints/Discovery에 기록한다.
   - Codex result review R-round를 추가한다.
   - 사용자 승인 후 `/work-close`, commit approval, PR `--base develop`, merge 순서로 진행한다.

## Done Criteria

- [x] Codex가 R0 plan review를 수행하고 Cross-Agent Review에 반영된다. (R1)
- [x] 배포 메커니즘(Q2: live-copy via `adapt()`)과 target gate-lists 정책(Q3: source 그대로)이 합의된다.
- [x] `--workflow source-gitflow` scaffold가 `tools/git-hooks/`(pre-commit/commit-msg/install.sh/lib/gate-lists.sh)를 배포하고 exec hook 3개가 실행권한을 갖는다.
- [x] generic/spring-boot scaffold에는 hook이 배포되지 않는다(advisory-only 유지).
- [x] hook-boundary 문서 3개(template/source GIT-WORKFLOW.md, MAINTAINER-GUIDE §10)가 c1 동작과 정합한다.
- [x] 실제 hook 설치/`git init`/CI/product-adaptive logic은 이번 PR에 포함되지 않는다.
- [x] Validation(4조합 포함)이 통과하거나, 미실행 항목과 잔여 risk가 명시된다.
- [x] Codex 결과 검토 후 사용자 승인까지 받은 뒤 `/work-close`를 진행한다. (R2→R2-accept→R3 Approved, 사용자 승인)

## Verification

| Check | Command / Method | Expected |
| --- | --- | --- |
| Diff hygiene | `git diff --check` | PASS |
| Scaffold syntax | `bash -n scripts/create-harness.sh` | PASS |
| source-gitflow deploy | real temp scaffold (generic profile + spring-boot, `--workflow source-gitflow`) | `tools/git-hooks/{pre-commit,commit-msg,install.sh,lib/gate-lists.sh}` 존재, exec hook 3개 실행권한 |
| generic no-leak | real temp scaffold (generic, spring-boot; workflow=generic) | `tools/git-hooks` 부재 |
| deployed hook validity | target에서 `sh -n` hooks + `sh -n lib/gate-lists.sh` | PASS |
| manifest tracking | target `.harness/manifest.json` | hook 4개 경로 기록 |
| doc consistency | template/source GIT-WORKFLOW.md, MAINTAINER-GUIDE §10 | generic 미배포/source-gitflow 배포로 정합 |
| Scope guard | `git diff --name-only` | CI/product-adaptive/source gate 로직/`.harness/config.json` 변경 없음 |

## Risks And Reversal Cost

| Risk | Impact | Mitigation |
| --- | --- | --- |
| generic 누수 | adopter가 원치 않는 hard gate 상속 | 배포 분기를 source-gitflow에만, generic/spring-boot temp scaffold로 부재 검증 |
| 실행권한 유실 | 배포된 hook이 설치돼도 동작 안 함 | 복사 시 chmod 보존, temp scaffold에서 권한 확인 |
| template 중복(Q2) | gate-lists.sh가 2곳이 되어 slice b 중복 제거 무효화 | live `tools/git-hooks/`에서 복사 제안, Codex 합의로 확정 |
| target gate-lists 부적합(Q3) | harness 전용 path가 target에서 무의미 | 없는 path는 case-match 미스로 무해; product 확장은 사용자 편집 + 문서화로 위임 |
| install 강제 시도 | no-git target에서 scaffold 실패 | 파일 배포 + 안내까지만, 실제 설치는 (d)/사용자 |

Reversal Cost: Medium. scaffold 분기 추가는 되돌리기 쉽지만, target에 배포된 schema/파일 구조가 c2~c4의 전제가 되면 이후 변경 비용이 오른다. 정책은 DR-025에 보존.

## STATUS Update Proposal

대상 Work ID: `CHORE-20260606-008`.

`docs/STATUS.md` Active Work에 이 Work 파일 pointer를 추가하고, Next Actions의 slice (c) 항목을 "(c1) 진행 중"으로 갱신해야 한다. `docs/backlog/HARNESS.md`와 `docs/works/harness/README.md`에도 Active row를 추가한다. 이 변경들은 dashboard/tracking state change이므로 사용자 승인 후 반영한다.

## Checkpoints

| CP | Description | Status |
| --- | --- | --- |
| CP-1 | Work file + plan 작성 (Claude) | Done |
| CP-2 | Codex R0 plan review | Done |
| CP-3 | Scope agreement and implementation approval | Done |
| CP-4 | 배포 메커니즘 구현 (Claude) | Done |
| CP-5 | Validation and Claude self-review | Done |
| CP-6 | Codex result review | Done |
| CP-7 | `/work-close`, commit, PR `--base develop`, merge | Done |

## Cross-Agent Review

| Round | Reviewer | Summary | Result |
| --- | --- | --- | --- |
| R0-prep | Claude | 첫 sub-slice를 c1(source-gitflow opt-in hook 배포)로 제안. 배포 출처는 live `tools/git-hooks/`(template 중복 회피), target gate-lists는 source 그대로, 실제 설치/CI/product-adaptive는 (d)/c2~c4로 분리. Q2/Q3 결정과 generic 누수 보증은 Codex review 요청. | Pending Codex Review |
| R1 | Codex | 조건부 승인. Q1 c1 선정은 DR-025 §5/DR-021 경계에 맞다. hook hard enforcement를 generic default가 아니라 `--workflow source-gitflow` opt-in에만 붙이는 가장 작은 배포 slice다. Q2는 live `tools/git-hooks/`를 복사하되 raw `cp`가 아니라 `adapt()` 또는 manifest-aware helper로 framework-owned 파일에 기록해야 한다. template 복제는 gate-lists 중복을 재발시키므로 반대. Q3 target `gate-lists.sh`는 source 그대로 시작해도 무방하나, source-gitflow target 문서와 hook protected list가 충돌하지 않게 `scripts/templates/source-gitflow/docs/GIT-WORKFLOW.md`의 Git Hooks/Protected Files 문구를 최소 갱신해야 한다. 현재 template §6은 "source harness repo hooks를 그대로 복사하지 않는다"고 말해 c1과 정면 충돌한다. source repo `docs/GIT-WORKFLOW.md`의 source-only note도 default/generic에는 미배포, source-gitflow opt-in에는 배포로 정정 필요. Q4 scaffold가 실제 install/git init을 실행하지 않는 분리는 맞다. Q5 leakage 보증은 분기 조건 + real temp scaffold 검증으로 충분하되 generic default, spring-boot default, source-gitflow, 가능하면 spring-boot+source-gitflow까지 workflow/profile 축을 분리 검증해야 한다. | Conditional — P1: generated/source Git Hooks 문구 충돌 해소, live-copy manifest tracking 명문화, validation matrix 보강 후 구현 착수 |
| R1-accept | Claude | R1 3건 전부 수용. **P1a 보강:** 충돌 문서는 2개가 아니라 3개 — template/source `GIT-WORKFLOW.md` + `docs/HARNESS-MAINTAINER-GUIDE.md` §10(둘이 §10을 pointer로 가리킴). 셋 다 "generic 미배포 / source-gitflow opt-in 배포"로 정정(scope 확장, 사용자 승인 완료). **P1b 보강:** `adapt()`는 manifest 기록 + name 치환은 하나 chmod는 안 함(sed redirect) → exec hook 3개 배포 후 `chmod +x` 명시, gate-lists.sh non-exec. **P1c 수용:** validation을 workflow×profile 4조합으로. In Scope/Plan/Verification/Done Criteria 반영, CP-3 합의 완료. | Agreed — 구현(CP-4) 착수 |
| R2 | Codex | 결과 검토. source-gitflow opt-in 배포 메커니즘은 R1 합의대로 구현됨: live `tools/git-hooks/`를 `adapt()`로 배포해 manifest에 기록하고, exec hook 3개는 `chmod +x`, `gate-lists.sh`는 non-exec 유지. 독립 real temp scaffold 4조합 검증 PASS: generic/generic-profile 및 generic/spring-boot에는 `tools/git-hooks` 없음, source-gitflow 2조합에는 hook 4개 존재·권한·`sh -n`·manifest 기록·name substitution 확인. dry-run 4조합 signal도 PASS. `git diff --check`, `bash -n scripts/create-harness.sh`, scope guard도 PASS이며 source `tools/git-hooks/`, CI, `.harness/config.json`, product-adaptive logic 변경은 없음. 단 P1: `scripts/templates/source-gitflow/docs/GIT-WORKFLOW.md`의 Protected Files 표가 실제 배포 hook의 `awh_is_branch_isolation_protected_path`와 불일치한다. 실제 hook은 `tools/git-hooks/*`를 protected로 취급하지만 generated 문서 표에는 Enforcement/`tools/git-hooks/**`가 없다. R1에서 문서와 hook protected list 충돌 해소를 조건으로 둔 만큼, source-gitflow template Protected Files 표에 Enforcement row를 추가해야 한다. 필요하면 `scripts/create-harness.sh`가 source-gitflow target에 `tools/git-hooks`를 배포한다는 사실과 같은 문서 §6도 이미 정합함. | Changes requested — P1 문서 정합 보강 후 재검토 |
| R2-accept | Claude | R2 P1 수용. 배포되는 template `GIT-WORKFLOW.md` Protected Files 표에 `Enforcement \| tools/git-hooks/**` row + gate-lists.sh 교차참조 note 추가 — deployed hook의 `awh_is_branch_isolation_protected_path`(`tools/git-hooks/*` protected)와 표를 정합. 같은 list의 `scripts/create-harness.sh`는 source-only라 target에 없으므로 표에 넣지 않음(harmless case-miss). 재검증: `bash -n`/`git diff --check` PASS, source-gitflow target 문서에 Enforcement row 반영 확인, generic no-leak 유지. | Fixed — Codex 재검토(R3) 요청 |
| R3 | Codex | R2 fix 재검토. template Protected Files 표가 deployed hook protected list와 정합함을 확인, 잔여 불일치 없음. 4조합 leakage/권한/manifest 결과 유지. | Approved — closeout 진행 (사용자 승인 포함) |

## Discovery

- `scripts/create-harness.sh`는 현재 `tools/`를 복사하지 않는다(grep 확인). source-gitflow 분기는 `docs/GIT-WORKFLOW.md`(marker)와 source git-workflow rule만 추가한다(line ~459, ~485).
- 템플릿은 `scripts/templates/{default,source-gitflow}/`에 있고 `adapt()`가 `ai-workflow-harness` → project name sed 치환을 한다. hook 파일의 `ai-workflow-harness` 주석은 치환돼도 무해(오히려 project-branded).
- 실제 hook 설치는 `tools/git-hooks/install.sh`가 `.git/hooks`에 symlink하므로 target이 git repo여야 한다 → slice (d) 영역.
- gate-lists.sh의 branch-isolation list 일부 path(`scripts/create-harness.sh`, `docs/HARNESS-PROTOCOL.md`)는 source-gitflow target에 없을 수 있으나 case-match 미스로 무해.

### CP-5 Self-Validation 결과 (Claude)

- `bash -n scripts/create-harness.sh`: PASS. `git diff --check`: clean.
- dry-run 4조합: generic 2종 = git-hooks 0 라인, source-gitflow 2종 = hook 배포 + install 안내 출력.
- real temp scaffold 4조합:
  - generic(generic/spring-boot): `tools/git-hooks` 부재(advisory-only) ✓
  - source-gitflow(generic/spring-boot): hook 4개 배포, exec bit = pre-commit/commit-msg/install.sh `x`, gate-lists.sh non-exec ✓; `sh -n` 전부 PASS; `.harness/manifest.json` hook 4행 기록 ✓; `adapt()` name 치환으로 install.sh의 `ai-workflow-harness` → project name(잔여 0) ✓
- scope guard: 변경 = `scripts/create-harness.sh`, `scripts/templates/source-gitflow/docs/GIT-WORKFLOW.md`, `docs/GIT-WORKFLOW.md`, `docs/HARNESS-MAINTAINER-GUIDE.md` + Work 파일. CI/product-adaptive/source gate 로직/`.harness/config.json` 변경 없음. source `tools/git-hooks/` 미변경(slice a/b 동작 보존).
- 잔여 risk: 배포된 target에서 실제 commit hard-stop/override 행동 시뮬레이션은 install(`git init` + symlink)이 전제라 (d)/사용자 영역으로 남김. 파일·권한·syntax 수준까지만 검증.
