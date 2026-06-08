---
id: CHORE-20260606-010
priority: P0
status: Archived
risk: High
scope: gate-enforcement-runtime-and-env slice c2-B target CI template and ruleset required-check connection
appetite: 2d
planned_start: 2026-06-06
planned_end: 2026-06-08
actual_end: 2026-06-06
related_dr: [DR-020, DR-021, DR-024, DR-025]
related_troubleshooting: []
related_work: [CHORE-20260606-004]
---

# Gate Target CI Template And Ruleset Connection — Slice C2-B

> 역할: A(Codex)가 Work 파일+plan을 작성하고 B(Claude)가 Cross-Agent Review R-round를 수행한다. 합의 후 A가 구현하고 B가 결과 검토한다.

## Context

`gate-enforcement-runtime-and-env` P0 series는 종료 전까지 0순위로 유지한다.

완료된 선행 slice:

- (a) source hook runtime — CHORE-20260606-006
- (b) shared gate-list SSoT — CHORE-20260606-007
- (c1) source-gitflow opt-in hook 배포 — CHORE-20260606-008
- (c2-A) source repo CI hardening — CHORE-20260606-009

이번 slice는 **(c2-B) target CI 템플릿 + ruleset required-check 연결**이다.

현재 source CI(`.github/workflows/ci.yml`)는 source repo의 docs/scaffold validation, source-gitflow scaffold hook 배포 검증, PR commit message backstop을 수행한다. 그러나 scaffold target에는 아직 `.github/workflows` 템플릿이 배포되지 않는다. `DR-020`의 `protect-main`은 source repo에서 required status check(`validate`, strict)를 활성화했고, `protect-develop`은 PR만 강제하며 required check는 없다. target repo에서는 이 설정을 source와 동일하게 강제할지, source-gitflow opt-in에만 제공할지, 문서 안내로 둘지 결정이 필요하다.

R0에서 확인한 핵심 결함: GitHub ruleset `required_status_checks`의 `context`는 workflow job id가 아니라 실제 보고되는 check-run name과 매칭된다. source repo 현재 상태는 `protect-main`이 `validate`를 요구하지만 최근 Actions check-run name은 `Docs and Scaffold Validation`로 보고된다. 따라서 c2-B는 target template의 required-check name을 단일 값으로 고정하고, (d) bootstrap이 그 값을 ruleset에 연결할 수 있게 handoff 계약을 남겨야 한다.

## Sub-Slice Selection

**선정:** c2-B = scaffold target CI template + ruleset required-check connection.

**왜 지금 하는가:** c2-A는 source repo CI를 닫았지만, target repo는 hook이 없거나 설치되지 않은 상태에서 advisory-only로 남을 수 있다. c1이 source-gitflow target에 hook opt-in을 배포했으므로, c2-B는 hook-less/generic target과 source-gitflow target 사이의 CI/backstop 경계를 명확히 해야 한다.

## Scope

### In Scope

- `scripts/create-harness.sh` scaffold copy matrix 검토 및 필요 시 `.github/workflows` target CI template 배포.
- target CI template 설계:
  - generic target: hook-less/advisory 성격을 유지하면서 최소 docs/scaffold/workflow validation을 제공할지 결정.
  - source-gitflow target: hook opt-in과 CI backstop을 함께 제공할지 결정.
  - c2-B target CI 범위는 syntax/template presence/absence/commit-message backstop으로 제한한다. finalization-bundling 탐지는 PR context에서 신뢰성 대비 유지비가 높으므로 제외한다.
  - `--with-optional`, `--profile spring-boot`, minimal scaffold에서 template included/excluded behavior 확인.
- ruleset required-check 연결 방식 결정:
  - GitHub API/`gh` 자동 적용 script를 제공할지,
  - bootstrap/onboarding manual step으로 안내할지,
  - source-gitflow bootstrap slice (d)로 넘길지.
- required check name 안정화:
  - GitHub required check context는 **보고되는 check-run name**으로 고정한다.
  - target source-gitflow template handoff 계약: required check name = `harness-validate`.
  - target template은 `.github/workflows/harness-validate.yml`에 두고, job key를 `harness-validate`로 두며 job-level `name:`은 설정하지 않는다. 이렇게 해야 reported check-run name과 ruleset context가 같은 값(`harness-validate`)이 된다.
  - source repo CI의 현 mismatch(`protect-main` context `validate` vs check-run `Docs and Scaffold Validation`)는 R0 evidence로 기록하고, source ruleset correction 필요 여부를 c2-B closeout 또는 d bootstrap에서 다시 판단한다.
- docs/scaffold cascade:
  - README, generated README/manual/bootstrap, `docs/SCAFFOLD-BOOTSTRAP.md`, `docs/SCAFFOLD-ONBOARDING-GUIDE.md`, `docs/GIT-WORKFLOW.md` template 필요 여부 점검.
- Cross-agent R-round 기록:
  - B(Claude) plan review.
  - A(Codex) 구현 후 B(Claude) result review.

### Out Of Scope

- c3 hook-less/generic target documented advisory + manifest check 전면 구현.
- c4 product-adaptive gate logic과 tracking-only commit 예외 구현.
- CI 기반 finalization-bundling 탐지.
- d source-gitflow environment bootstrap 전체 구현. 단 c2-B에서 ruleset 연결을 d로 넘겨야 하는지 판단한다.
- active adopter(`ai-deck-compiler`) 직접 migration.
- prompt surface diet / optional pack archive 정리.
- `--workflow` option rename.

## Plan

| Field | Value |
| --- | --- |
| Risk | L3 - scaffold target CI/ruleset 정책은 target repository behavior와 GitHub settings에 영향을 준다 |
| Execution Mode | Full Work, P0 slice c2-B only |
| Branch | `feature/chore-20260606-010-gate-target-ci-ruleset` |
| Tool Rules | `.claude/rules/docs-workflow.md`, `.claude/rules/git-workflow.md` matched |
| Language Policy | DR-007 적용: docs Korean primary, workflow YAML/shell identifiers English |
| State Machine | INIT -> PLAN -> APPROVAL -> EXECUTE -> VALIDATE -> CHECKPOINT -> END |

1. **R0 Plan Review (Claude)**
   - 이 Work 파일의 Scope/Out Of Scope/Review Questions를 B(Claude)가 검토한다.
   - 합의 전에는 implementation을 시작하지 않는다.
   - R-round 결과는 아래 `Cross-Agent Review`에 누적한다.

2. **Target CI Template Policy 확정**
   - generic target에 CI template을 기본 배포할지, source-gitflow에만 배포할지, `--with-optional`에 둘지 결정한다.
   - 후보:
     - A) source-gitflow only: branch/ruleset 정책을 선택한 target에만 CI/ruleset template 제공.
     - B) all targets: generic도 minimal validation CI를 받되 required check 연결은 project-specific advisory.
     - C) template file은 제공하되 disabled/advisory docs로만 안내.
   - R0 합의 반영 기본 제안: **source-gitflow target에는 harness 전용 CI template(`.github/workflows/harness-validate.yml`) 배포, generic target은 advisory 문서만 우선**. generic target은 project-specific workflow를 정해야 하므로 required check 자동 연결은 과잉일 수 있다.

3. **Ruleset Required-Check 연결 경계 결정**
   - target ruleset 자동 적용은 GitHub API 권한, repo visibility, branch 존재, default branch 상태에 의존한다.
   - 이 slice에서 자동 API 적용까지 구현할지, source-gitflow bootstrap(d)로 넘길지 결정한다.
   - 기본 제안: c2-B는 **workflow template + required-check 연결 guide/command sketch**까지, 실제 repo 생성/branch/ruleset 자동화는 d에서 구현.
   - (d) handoff 계약: source-gitflow target bootstrap은 branch/ruleset 생성 후 `required_status_checks`에 `harness-validate`를 연결한다.

4. **Implementation**
   - 합의된 정책에 따라 `scripts/create-harness.sh`에 target CI template copy/generation 경로를 추가한다.
   - 필요하면 `scripts/templates/source-gitflow/.github/workflows/harness-validate.yml` 같은 scaffold-safe template을 추가한다.
   - generated README/BOOTSTRAP/GIT-WORKFLOW 안내를 source-vs-target boundary에 맞게 조정한다.
   - source CI에 fresh scaffold 검증을 추가해 target CI template presence/absence, `harness-validate` token, manifest registration, stale source-only phrase를 확인한다.

5. **Validation**
   - `git diff --check`
   - `bash -n scripts/create-harness.sh`
   - fresh generic scaffold: `.github/workflows/harness-validate.yml` 부재 확인.
   - fresh source-gitflow scaffold: `.github/workflows/harness-validate.yml`, required check token `harness-validate`, manifest 기록, docs guidance 확인.
   - `--with-optional` + `--profile spring-boot` 조합이 template policy와 충돌하지 않는지 확인.
   - source-vs-target 누수 grep: source-only DR/ruleset 문구가 generated target runtime docs에 과잉 노출되지 않는지 확인.

6. **Result Review / Closeout**
   - A(Codex)가 구현/검증 결과를 Work 파일에 기록한다.
   - B(Claude)가 result review를 수행하고 R-round에 누적한다.
   - 합의 후 `/work-close`, commit approval, PR `--base develop`, CI 확인, merge 순서로 진행한다.

## Review Questions (for Claude R0)

| Question | A(Codex) Draft Answer |
| --- | --- |
| Q1. target CI template은 generic에도 기본 배포해야 하나? | 기본 제안은 no. generic target은 project-specific workflow가 우선이고, source-gitflow opt-in target만 branch/ruleset/CI template을 함께 제공한다. |
| Q2. ruleset required-check 자동 적용을 c2-B에 포함해야 하나? | 기본 제안은 no. c2-B는 template + guide까지, 실제 GitHub repo/branch/ruleset bootstrap 자동화는 (d) source-gitflow environment bootstrap으로 넘긴다. |
| Q3. required check name은 `validate`로 고정해야 하나? | no. R0 verification 결과 GitHub required check context는 reported check-run name과 맞아야 한다. target source-gitflow 계약값은 `harness-validate`로 고정한다. job key를 `harness-validate`로 두고 job-level `name:`은 쓰지 않는다. |
| Q4. target CI가 finalization bundling을 hard-stop해도 되나? | no. DR-025상 published/PR context는 report-only다. c2-B CI에서는 finalization-bundling 탐지 자체를 제외하고 syntax/template/commit-message backstop으로 한정한다. finalization은 local hook 또는 prose advisory가 담당한다. |
| Q5. target CI template을 manifest에 framework-owned로 기록해야 하나? | yes, source가 유지하는 framework-owned file로 보고 `--check` drift 대상에 포함하는 편이 upgrade/migration과 정합적이다. |
| Q6. source CI에 c2-B 검증을 넣어야 하나? | yes. fresh scaffold에서 source-gitflow template presence, generic absence, `harness-validate` token, manifest registration, generated guidance를 검증해야 이후 scaffold drift를 잡을 수 있다. |

## Done Criteria

- [x] B(Claude)가 R0 plan review를 수행하고 Cross-Agent Review에 반영된다.
- [x] target CI template 배포 정책(generic/source-gitflow/optional)이 합의된다.
- [x] ruleset required-check 연결 경계(c2-B vs d)가 합의된다.
- [x] (d) handoff 계약 required check name = `harness-validate`가 Work 파일과 generated guidance에 명시된다.
- [x] (d) handoff에 required check + path filter stuck-pending caveat이 durable location에 명시된다.
- [x] DR-020 disposition이 silent-wrong SSoT로 남지 않도록 status note 또는 defer marker로 처리된다.
- [x] 합의된 target CI template/scaffold/docs/source CI 검증이 구현된다.
- [x] fresh-scaffold 검증 command가 CP3 전에 구체화된다.
- [x] source-vs-target boundary 누수가 없음을 확인한다.
- [x] validation 결과가 Work 파일에 기록된다.
- [x] B(Claude)가 result review를 수행하고 합의한다.
- [x] `/work-close`로 Done 처리 후 commit/PR/merge flow를 진행한다.

## Verification

```bash
git diff --check
bash -n scripts/create-harness.sh
# Fresh scaffold validation commands are finalized before CP3.
```

### CP3 Validation Commands

```bash
git diff --check
bash -n scripts/create-harness.sh
sh -n tools/git-hooks/pre-commit
sh -n tools/git-hooks/commit-msg
sh -n tools/git-hooks/install.sh
sh -n tools/git-hooks/lib/gate-lists.sh
ruby -e 'require "yaml"; YAML.load_file(".github/workflows/ci.yml"); YAML.load_file("scripts/templates/source-gitflow/.github/workflows/harness-validate.yml"); puts "yaml ok"'

# Fresh scaffold matrix:
# - generic / generic --with-optional / spring-boot: no .github/workflows/harness-validate.yml
# - source-gitflow variants: .github/workflows/harness-validate.yml present, job key harness-validate, no job-level name, manifest records path, GIT-WORKFLOW guidance contains required check context.
```

검증 결과(2026-06-06, A/Codex):

- `git diff --check` PASS
- `bash -n scripts/create-harness.sh` PASS
- `sh -n tools/git-hooks/{pre-commit,commit-msg,install.sh,lib/gate-lists.sh}` PASS
- YAML parse PASS: `.github/workflows/ci.yml`, `scripts/templates/source-gitflow/.github/workflows/harness-validate.yml`
- Fresh scaffold matrix PASS:
  - generic / spring-boot: `tools/git-hooks`와 `.github/workflows/harness-validate.yml` 없음
  - source-gitflow generic / source-gitflow spring-boot: `.github/workflows/harness-validate.yml` 있음, job key `harness-validate`, job-level `name:` 없음, manifest path 기록, generated `GIT-WORKFLOW.md` required check guidance 있음
- R2 handoff caveat rerun PASS:
  - `git diff --check`, `bash -n scripts/create-harness.sh`, hook shell syntax, YAML parse 재통과
  - fresh scaffold matrix 재통과(`/private/tmp/awh-c2b-r2-XOqI55`): generated `GIT-WORKFLOW.md`에 path-filter stuck-pending caveat 포함 확인

## Cross-Agent Review

| Round | Reviewer | Scope | Result | Notes |
| --- | --- | --- | --- | --- |
| R0 | Claude | Plan review | Approve-with-changes | Q1/Q2/Q4/Q5 방향 동의. Must-fix: GitHub required check는 check-run name 기준이므로 `validate` 가정 제거, source ruleset mismatch 검증 기록, (d) handoff required check name 고정, source CI에 token/absence assertion 추가. Nice-to-have: `harness-validate.yml` 파일명, finalization 탐지 제외, manifest assertion, DR-020 amend 또는 신규 DR 판단. |
| R0-A | Codex | R0 evidence + plan update | Done | `gh api` 확인: `protect-main` required context = `validate`; 최근 Actions job/check-run name = `Docs and Scaffold Validation`; commit status contexts empty. Target contract를 `harness-validate`로 고정하고 job-level `name:` 미사용 방침으로 plan 수정. |
| R1 | Claude | Revised plan | Approved | 잔여 Open Item: DR-020 SSoT 정확성. c2-B 구현은 진행 가능하되 closeout 전 DR-020 disposition을 Done Criteria에 추가하라는 권고. `harness-validate` convention은 Work 파일 외 durable 위치에 남기는 것을 권장. |
| R1-A | Codex | DR-020 disposition + implementation | Done | DR-020에 required check context는 reported check-run name과 매칭된다는 status note를 추가. Source CI는 job-level `name:` 제거로 `validate` check-run name과 ruleset context를 정합화. Target source-gitflow convention은 `harness-validate`로 고정. |
| R2 | Claude | Result review | Approve | 구현 6개 포인트는 정확하고 scope 누수 없음. Must-fix 1건: (d) handoff에 required check + path filter stuck-pending footgun 경고를 durable하게 남길 것. 코드 비차단. |
| R2-A | Codex | Handoff caveat | Done | generated `GIT-WORKFLOW.md`, DR-020, backlog (d) 항목에 `harness-validate` required check와 path filter `Expected`/pending caveat을 명시했다. |

## Checkpoints

| CP | Description | Status |
| --- | --- | --- |
| CP0 | Branch isolation + Work file/plan 작성 | Done |
| CP1 | Claude R0 plan review + 합의 | Done |
| CP2 | target CI/ruleset policy implementation | Done |
| CP3 | validation + A self-review | Done |
| CP4 | Claude result review | Done |
| CP5 | `/work-close` + commit/PR/merge | Done |

## Discovery

- 2026-06-06: Branch Isolation Check 결과 `develop` + source-gitflow mode였고, 이전 backlog reprioritization 변경이 unstaged로 남아 있었다. `feature/chore-20260606-010-gate-target-ci-ruleset` 브랜치로 전환한 뒤 이 Work를 시작했다.
- 2026-06-06: c2-A Work 기준 source repo CI는 source-gitflow scaffold hook 배포와 commit-message PR backstop을 이미 검증한다. c2-B는 target template 배포와 required-check 연결 경계를 합의해야 한다.
- 2026-06-06: R0 evidence. `gh api repos/:owner/:repo/rulesets/16726411`에서 source `protect-main` required check context가 `validate`로 확인됨. `gh api repos/:owner/:repo/actions/runs/27056021559/jobs`와 check-runs 조회에서 실제 job/check-run name은 `Docs and Scaffold Validation`로 확인됨. 따라서 "job id로 고정 + display 자유" 가정은 폐기한다.
- 2026-06-06: R1 반영. c2-B에서 source CI job-level `name:`을 제거해 source `validate` ruleset context와 check-run name을 맞춘다. source-gitflow scaffold에는 `.github/workflows/harness-validate.yml`을 framework-owned file로 배포하고, (d) bootstrap handoff required check name은 `harness-validate`로 고정한다.
- 2026-06-06: 구현 결과. generic scaffold에는 `harness-validate.yml`을 배포하지 않는다. source-gitflow scaffold에는 `harness-validate.yml`을 배포하고 `.harness/manifest.json`에 기록한다. template은 job key `harness-validate`를 사용하며 job-level `name:`을 두지 않는다.
- 2026-06-06: A self-review. c2-B는 target CI template과 ruleset handoff 계약을 닫았고, 실제 GitHub repo/branch/ruleset 생성·적용 자동화는 (d) source-gitflow environment bootstrap으로 남긴다. c2-B CI는 finalization-bundling 탐지를 포함하지 않는다.
- 2026-06-06: R2 반영. `harness-validate.yml`은 path filter를 사용하므로 이를 required check로 연결할 때 filter 미일치 PR이 `Expected`/pending 상태에 머물 수 있다. (d) bootstrap은 항상-실행 gate job 또는 path filter 없는 status-check 패턴으로 이 상호작용을 처리해야 한다.
- 2026-06-06: `/work-close` 처리. status를 Done으로 전환하고, archive는 보류한다.
