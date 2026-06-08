---
id: CHORE-20260606-009
priority: P1
status: Archived
risk: Medium
scope: gate-enforcement-runtime-and-env slice (c2-A) source repo CI hardening
appetite: 2d
planned_start: 2026-06-06
planned_end: 2026-06-08
actual_end: 2026-06-06
related_dr: [DR-020, DR-024, DR-025]
related_troubleshooting: []
related_work: [CHORE-20260606-004]
---

# Gate CI Source Hardening — Slice C2-A

> 역할: A(Claude)가 Work+plan을 작성하고 B(Codex)가 Cross-Agent Review(R-round)를 수행한다. 합의 후 A가 구현하고 B가 결과 검토한다.

## Context

`gate-enforcement-runtime-and-env`의 (a) source hook runtime, (b) shared gate-list SSoT, (c1) source-gitflow opt-in hook 배포는 Done/merge되었다.
이번은 (c) 묶음의 **c2 = CI 대안** 중 첫 sub-slice인 **c2-A = source repo CI 하드닝**이다.

현행 `.github/workflows/ci.yml`은 PR(main/develop)에서 whitespace, `bash -n create-harness.sh`, generic dry-run, scaffold phrase/artifact scan, stale identity를 검사한다. 두 가지 공백이 있다:

1. **c1이 남긴 커버리지 공백:** CI는 `--workflow source-gitflow` scaffold 경로를 전혀 테스트하지 않는다. 또한 "scaffold 출력에 `tools/git-hooks/install.sh` 참조 금지" 체크(ci.yml line 65-85)는 이제 **generic scaffold에만 참**이다 — c1이 source-gitflow scaffold에는 의도적으로 그 참조와 hook을 배포하기 때문. 현재 CI가 generic scaffold만 검사해서 통과 중이라 #83은 깨지지 않았지만, 의미상 이 체크는 "generic-only"로 명시돼야 한다.
2. **hook 미설치 gap:** local hook(commit-msg 형식 등)을 설치하지 않은 contributor/AI clone에는 server-side backstop이 없다.

## Sub-Slice Selection

**선정:** c2-A = source repo `ci.yml` 하드닝. 사용자 결정으로 c2-B(target CI 템플릿)와 ruleset required-status-check 연결은 분리한다.

**개념적 제약 (세 c2 안 공통):** CI는 PR(=이미 push/published) 시점에 돈다. DR-025 §3상 published context는 **report-only**이므로 **CI는 finalization-bundling을 hard-stop할 수 없다.** 따라서 c2-A에서 CI의 실효 강제는 commit-msg 형식·scaffold 정합·syntax이고, finalization은 advisory(report)에 그친다.

## Review Questions (for Codex R-round)

| Question | Claude Draft Answer |
| --- | --- |
| 1. commit-msg backstop의 commit range 판정 방법? | PR base..HEAD 범위의 각 commit subject를 Conventional Commits 정규식으로 검사. merge commit(부모 2개)은 면제. `pull_request` 이벤트에서 base를 fetch해야 하므로 `actions/checkout`의 `fetch-depth: 0` 또는 base fetch 필요. Codex 판단 요청. |
| 2. install.sh-reference 체크를 어떻게 workflow-aware로? | 기존 generic scaffold 체크는 "install.sh 참조 없음"으로 유지. source-gitflow scaffold를 추가 생성해 반대로 "hook 4개 배포 + install.sh 참조 있음 + exec 권한"을 assert. 두 경로를 분리된 step/케이스로. |
| 3. ruleset required-status-check 연결을 c2-A에 포함? | 아니오 제안. c2-A는 CI workflow 콘텐츠만. CI job을 ruleset required check로 거는 것은 DR-020 변경(L3 결정)이라 별도 follow-up으로 분리. |
| 4. CI finalization은 advisory(report-only)만, hard-stop 없음이 맞나? | 맞다. published=report-only(DR-025 §3). c2-A는 finalization hard-stop을 CI에 넣지 않는다. |
| 5. commit-msg backstop이 local hook과 중복인데 server-side 가치가 정당한가(과잉 아닌가)? | hook 미설치 clone(특히 AI agent)에는 local commit-msg gate가 없으므로 PR backstop은 defense-in-depth로 정당. 단 ruleset required로 걸지 않으면 advisory에 그치는 점은 Q3와 연계. 과잉 우려가 크면 c2-min(공백 보강만)으로 축소 가능 — Codex 판단. |

## Scope

### In Scope

- `.github/workflows/ci.yml` 확장:
  - **source-gitflow scaffold 커버리지 추가:** `--workflow source-gitflow` real scaffold(generic + spring-boot profile)에서 `tools/git-hooks/{pre-commit,commit-msg,install.sh,lib/gate-lists.sh}` 배포 + exec hook 3개 권한 + manifest 기록을 assert. generic workflow scaffold에는 `tools/git-hooks` 부재를 assert.
  - **install.sh-reference 체크 workflow-aware化:** generic scaffold = 참조 없음(현행), source-gitflow scaffold = 참조 있음으로 분리.
  - **commit-msg 형식 backstop:** PR commit range subject를 Conventional Commits 형식으로 검증(merge commit 면제).

### Out Of Scope

- c2-B target CI 템플릿(scaffold가 `.github/workflows` 배포).
- ruleset required status check 연결(DR-020 변경) — 별도 follow-up.
- CI finalization hard-stop(개념상 불가, published=report-only).
- branch isolation의 CI 강제 — ruleset(DR-020)이 develop/main direct push를 이미 차단하므로 중복. 추가하지 않는다.
- c3(documented advisory)/c4(product-adaptive)/d(bootstrap), `.harness/config.json`, source hook/gate 로직 변경.

## Plan

| Field | Value |
| --- | --- |
| Risk | L2 - CI workflow surface 변경. ruleset required-status-check 미연결이므로 추가 검사는 merge blocker가 아니라 PR signal/advisory다(R0 Q3/Q5 합의) |
| Execution Mode | Full Work, slice (c2-A) only |
| Current State | Branch Isolation Check 완료: `develop` + `policy_type: source-gitflow`에서 `feature/chore-20260606-009-gate-ci-source-hardening`로 전환 |
| Tool Rules | `.claude/rules/docs-workflow.md`, `.claude/rules/git-workflow.md` matched |
| Language Policy | DR-007 적용: docs Korean primary, YAML/코드 English |
| State Machine | INIT -> PLAN -> APPROVAL -> EXECUTE -> VALIDATE -> CHECKPOINT -> END |

1. **R0 Plan Review (Codex)** — sub-slice 선정, commit-range 판정(Q1), workflow-aware 분리(Q2), ruleset 분리(Q3), advisory-only(Q4), 과잉 여부(Q5)를 검토하고 Cross-Agent Review에 R-round 누적. 합의 후 구현.

2. **source-gitflow 커버리지 step 구현**
   - real scaffold `--workflow source-gitflow`(generic/spring-boot)로 hook 배포·권한·manifest assert step 추가.
   - generic workflow scaffold의 `tools/git-hooks` 부재 assert.

3. **install.sh-reference 체크 정정**
   - 기존 step을 generic-only로 명시하고, source-gitflow 경로용 반대 assert 추가.

4. **commit-msg backstop step 구현** (R0 합의 고정)
   - `actions/checkout@v4`에 `fetch-depth: 0`.
   - range = `${{ github.event.pull_request.base.sha }}..${{ github.event.pull_request.head.sha }}` (event의 base/head sha 사용 — `pull_request` checkout이 merge ref일 수 있어 `HEAD` 단독보다 안전).
   - `git log --no-merges --format=%s "$BASE_SHA..$HEAD_SHA"`로 subject만 검사, merge commit은 range 단계에서 면제.
   - 정규식은 local `commit-msg` hook과 동일 type 목록 사용.
   - **advisory 성격 명시:** ruleset required-status-check 미연결이므로 이 job은 merge blocker가 아니라 PR signal/advisory다(Q5/Q3).

5. **Validation**
   - `git diff --check`
   - YAML lint 가능 시(또는 `python3 -c 'import yaml,sys; yaml.safe_load(open("...ci.yml"))'`로 파싱) syntax 확인
   - CI step 명령을 로컬에서 재현: source-gitflow/generic real scaffold assert, commit-msg 정규식을 샘플 메시지로 검증
   - scope guard: `.github/workflows/ci.yml` + Work/tracking 외 변경 없음(scaffold/source hook/ruleset 무변경)

6. **Result Review / Closeout (Codex)** — Claude self-validation 기록, Codex result review R-round 추가, 사용자 승인 후 `/work-close`, commit, PR `--base develop`, merge.

## Done Criteria

- [x] Codex가 R0 plan review를 수행하고 Cross-Agent Review에 반영된다. (R0 conditional → R0-accept)
- [x] commit-range 판정(Q1)과 workflow-aware 분리(Q2), ruleset 분리(Q3)가 합의된다.
- [x] CI가 source-gitflow scaffold(hook 배포/권한/manifest)와 generic scaffold(hook 부재)를 모두 검증한다.
- [x] install.sh-reference 체크가 workflow-aware로 정정된다(generic=없음, source-gitflow=있음).
- [x] commit-msg 형식 backstop이 PR commit range에 적용되고 merge commit을 면제한다.
- [x] ruleset 연결/target CI 템플릿/finalization hard-stop은 이번 PR에 포함되지 않는다.
- [x] Validation이 통과하거나, 미실행 항목과 잔여 risk가 명시된다.
- [x] Codex 결과 검토 후 사용자 승인까지 받은 뒤 `/work-close`를 진행한다. (R2→R2-accept, R3 재검은 사용자 결정으로 생략·closeout 승인)

## Verification

| Check | Command / Method | Expected |
| --- | --- | --- |
| Diff hygiene | `git diff --check` | PASS |
| YAML parse | `python3 -c 'import yaml; yaml.safe_load(open(".github/workflows/ci.yml"))'` | PASS |
| source-gitflow coverage | CI step 로컬 재현 (real scaffold) | hook 4개 배포 + exec 권한 + manifest 기록 assert PASS |
| generic no-leak | CI step 로컬 재현 | generic scaffold `tools/git-hooks` 부재 assert PASS |
| commit-msg backstop | 샘플 valid/invalid subject | valid 통과, invalid 실패, merge commit 면제 |
| Scope guard | `git diff --name-only` | `.github/workflows/ci.yml` + Work/tracking 외 변경 없음 |

## Risks And Reversal Cost

| Risk | Impact | Mitigation |
| --- | --- | --- |
| commit-range fetch 누락 | CI에서 base..HEAD 계산 실패 | `fetch-depth: 0` 또는 base fetch, merge commit 면제 |
| commit-msg backstop false positive | 정당한 PR commit이 CI fail | ruleset required 미연결(advisory) → merge 차단 아님; 정규식은 local commit-msg hook과 동일 source |
| source-gitflow CI step가 real scaffold 의존 | CI 시간/취약성 증가 | 기존 phrase-check가 이미 real scaffold를 쓰므로 동일 패턴 재사용 |
| 과잉(중복) | local hook과 중복 | hook 미설치 clone 대비 backstop으로 한정, 필요 시 c2-min으로 축소 |

Reversal Cost: Low. `.github/workflows/ci.yml` 변경은 revert로 복구. 정책은 DR-025/DR-020에 보존.

## STATUS Update Proposal

대상 Work ID: `CHORE-20260606-009`. `docs/STATUS.md` Active Work pointer 추가 + backlog/works README Active row는 합의 후 closeout commit에 일괄 반영한다(사용자 지침).

## Checkpoints

| CP | Description | Status |
| --- | --- | --- |
| CP-1 | Work file + plan 작성 (Claude) | Done |
| CP-2 | Codex R0 plan review | Done |
| CP-3 | Scope agreement and implementation approval | Done |
| CP-4 | CI 하드닝 구현 (Claude) | Done |
| CP-5 | Validation and Claude self-review | Done |
| CP-6 | Codex result review | Done |
| CP-7 | `/work-close`, commit, PR `--base develop`, merge | Done |

## Cross-Agent Review

| Round | Reviewer | Summary | Result |
| --- | --- | --- | --- |
| R0-prep | Claude | c2-A(source CI 하드닝) 제안. source-gitflow scaffold 커버리지 + install.sh-reference workflow-aware化 + commit-msg backstop. ruleset 연결/target CI 템플릿/finalization hard-stop은 분리. commit-range 판정(Q1)·과잉 여부(Q5)는 Codex review 요청. | Pending Codex Review |
| R0 | Codex | 조건부 승인. c2-A를 source repo CI hardening으로 좁히는 선정은 타당하다. **Q1:** PR commit-msg backstop은 `pull_request`에서 `actions/checkout@v4`에 `fetch-depth: 0`을 주고, `${{ github.event.pull_request.base.sha }}..${{ github.event.pull_request.head.sha }}` 범위를 검사하는 방식이 가장 명료하다. `git log --no-merges --format=%s "$BASE_SHA..$HEAD_SHA"`로 subject만 검사하고 merge commit은 range 단계에서 면제한다. `pull_request` checkout이 merge ref일 수 있으므로 `HEAD` 단독 기준보다 event의 base/head sha를 쓰는 편이 안전하다. **Q3:** ruleset required-status-check 연결은 c2-A에서 제외하는 것이 맞다. DR-020은 `protect-develop`에 required status check 미포함을 명시하고 있으므로, required check 연결은 repo policy 변경이자 DR-020 후속 결정으로 분리해야 한다. **Q5:** commit-msg backstop은 local hook과 중복이지만 hook 미설치/우회 clone의 server-side signal로 가치가 있다. 다만 ruleset에 연결하지 않으면 merge blocker가 아니라 PR signal/advisory에 가깝다는 점을 Plan/Risk에 명시해야 한다. finalization bundling hard-stop은 CI에 넣지 않는 현재 경계가 DR-025 published=report-only와 정합한다. | Conditional — fetch-depth/base-head range/subject-only/no-merges를 plan에 고정하고, required-status-check 분리와 advisory 성격을 명시한 뒤 구현 착수 가능 |
| R0-accept | Claude | R0 조건 전부 수용(이견 없음 — 전부 draft 제안의 확정). Plan step 4에 `fetch-depth: 0` + event base/head sha range + `git log --no-merges --format=%s` + 동일 정규식 고정, Risk/Plan에 advisory(merge blocker 아님) 명시. Q2 workflow-aware 분리, Q3 ruleset 분리, Q4 finalization advisory 유지. CP-3 합의 완료. | Agreed — 구현(CP-4) 착수 |
| R2 | Codex | 결과 검토. source-gitflow/generic scaffold coverage와 install.sh-reference workflow-aware 분리는 독립 재현 PASS: generic/spring-boot generic workflow에는 `tools/git-hooks`와 `tools/git-hooks/install.sh` 참조가 없고, source-gitflow 2 profile에는 hook 4개·exec 3개·non-exec `gate-lists.sh`·manifest hook rows·install guidance가 존재한다. `git diff --check`, `bash -n scripts/create-harness.sh`, commit subject regex sample도 PASS. Scope guard도 `.github/workflows/ci.yml` + Work 파일뿐이며 source hook/ruleset/`.harness/config.json` 변경 없음. finalization hard-stop도 CI에 추가되지 않았다. **P1:** commit-msg backstop step의 `while ... < <(git log ...)` 구조는 `git log` range 계산이 실패해도 bash가 0으로 통과할 수 있음을 재현했다. backstop의 핵심 전제인 base/head range failure는 fail-closed여야 하므로, `git log --no-merges --format=%s "$BASE_SHA..$HEAD_SHA" > /tmp/commit-subjects`처럼 먼저 range 명령을 독립 실행해 실패를 잡은 뒤 파일을 순회하도록 수정해야 한다. **P2:** CI manifest assert는 현재 pre-commit row만 확인한다. 계획상 hook 4개 manifest 기록을 보장하려면 4개 경로 모두 grep하거나 helper loop로 확인하는 편이 좋다. | Changes requested — P1 range failure silent-pass 수정 필요, P2 manifest all-rows check 권장 |
| R2-accept | Claude | R2 P1/P2 모두 수용. **P1:** commit-msg backstop을 process substitution → 독립 명령(`git log ... > /tmp/commit-subjects`) 후 파일 순회로 변경. 잘못된 range는 `set -e`로 fail-closed됨을 로컬 재현 확인(bad sha → 실패, good range → 통과). **P2:** manifest assert를 4경로(pre-commit/commit-msg/install.sh/lib/gate-lists.sh) loop로 보강, real scaffold에서 4개 모두 기록 확인. 재검증: `git diff --check`/YAML parse PASS. | Fixed — Codex 재검토(R3) 요청 |
| R3 | Codex/User | 사용자가 재검(R3) 생략을 결정하고 R2 fix(P1 fail-closed, P2 manifest 4경로) 반영 상태로 closeout~merge를 일괄 승인. | Approved (재검 생략) — closeout 진행 |

## Discovery

- 현행 `ci.yml`은 generic/spring-boot scaffold만 real로 생성해 검사하고, source-gitflow 경로는 미검증.
- ci.yml line 65-85의 "install.sh 참조 금지"는 c1 이후 generic-only 의미가 됨.
- DR-020 ruleset `protect-develop`에는 status check 미포함(develop CI는 현재 선택적) → CI job을 required로 거는 것은 별도 DR-020 변경.
- DR-025 §3: published=report-only → CI finalization hard-stop 불가.

### CP-5 Self-Validation 결과 (Claude)

- `git diff --check`: clean. YAML parse(`ruby -ryaml`): OK.
- source-gitflow coverage step 로컬 재현: generic/spring-boot 2 profile 모두 hook 4개 배포 + exec 3개 권한 + gate-lists.sh non-exec + manifest `tools/git-hooks/pre-commit` 기록 + GIT-WORKFLOW.md install.sh 안내 — assert PASS.
- generic no-leak step 재현: generic/spring-boot 모두 `tools/git-hooks` 부재 PASS.
- commit-msg 정규식: `chore:`/`feat(scope):`/`fix: 한글` PASS, type 없는 subject FAIL, `Merge pull request...`는 `--no-merges`로 애초에 제외(merge commit 면제 확인).
- scope guard: 변경 = `.github/workflows/ci.yml` + Work 파일뿐. scaffold/source hook/ruleset/`.harness/config.json` 무변경.
- 미실행/잔여: 실제 GitHub Actions 런타임(`pull_request` 이벤트의 base/head sha, `fetch-depth: 0`)은 PR 생성 후에야 확인 가능 — step 명령 자체는 로컬 재현으로 검증. `if: github.event_name == 'pull_request'` 가드로 push(main) 이벤트에서는 backstop step skip.
