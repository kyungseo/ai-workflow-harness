---
id: CHORE-20260606-011
priority: P0
status: Done
risk: High
scope: gate-enforcement-runtime-and-env slice d source-gitflow environment bootstrap
appetite: 2d
planned_start: 2026-06-06
planned_end: 2026-06-08
actual_end: 2026-06-06
related_dr: [DR-020, DR-021, DR-024, DR-025]
related_troubleshooting: []
related_work: [CHORE-20260606-004]
---

# Source-Gitflow Environment Bootstrap — Slice D

> 역할: A(Codex)가 Work 파일+plan을 작성하고 B(Claude)가 Cross-Agent Review R-round를 수행한다. 합의 후 A가 구현하고 B가 결과 검토한다.

## Context

`gate-enforcement-runtime-and-env` P0 series는 종료 전까지 0순위로 유지한다.

완료된 선행 slice:

- (a) source hook runtime — CHORE-20260606-006
- (b) shared gate-list SSoT — CHORE-20260606-007
- (c1) source-gitflow opt-in hook 배포 — CHORE-20260606-008
- (c2-A) source repo CI hardening — CHORE-20260606-009
- (c2-B) target CI template + ruleset handoff — CHORE-20260606-010

이번 slice는 **(d) source-gitflow environment bootstrap**이다.

source-gitflow target은 `docs/GIT-WORKFLOW.md`, `tools/git-hooks/`, `.github/workflows/harness-validate.yml`을 받지만, scaffold 직후에는 git repository, `main`/`develop` branch, remote `origin`, GitHub ruleset이 준비되어 있지 않다. 따라서 현재 안내만으로는 "source-style workflow를 선택한 target이 실제로 어떤 순서로 environment를 안전하게 완성하는가"가 불명확하다.

c2-B handoff의 핵심 계약:

- target required check context는 `harness-validate`다.
- `harness-validate.yml`은 job-level `name:`을 두지 않는다.
- GitHub ruleset `required_status_checks.context`는 reported check-run name과 매칭된다.
- `harness-validate.yml`은 path filter가 있으므로, 이를 required check로 직접 연결하면 filter 미일치 PR에서 `Expected`/pending 상태가 될 수 있다. (d)는 이 footgun을 처리해야 한다.

## Scope

### In

- source-gitflow target의 environment bootstrap sequence 결정:
  - `git init`
  - default branch를 `main`으로 만들기
  - initial commit
  - `develop` branch 생성
  - `origin` remote 연결/push
  - hook install timing
  - GitHub ruleset 생성/적용 또는 적용 guide
- `harness-validate` required check + path-filter stuck-pending 처리 방식 결정.
- generated target 문서/스크립트/검증 surface 보강.
- source CI/fresh scaffold 검증에 bootstrap 산출물 presence와 source-vs-generic boundary assertion 추가.
- B(Claude) R0 plan review와 구현 후 result review를 Work 파일 `Cross-Agent Review`에 누적.

### Out

- generic target에 source-gitflow branch/ruleset policy 강제.
- c3 hook-less/generic target advisory + manifest check.
- c4 product-adaptive gate logic.
- GitHub public/private visibility 전환 정책 재설계.
- Remote-writing 또는 destructive command 자동 실행. `gh api` ruleset 적용은 runbook/preview 대상이며 이 slice의 자동 실행 대상이 아니다.
- 기존 source repo ruleset 운영 방식의 대규모 재설계. 단, d에 필요한 DR-020 handoff note 보강은 포함 가능.

## Plan

### 1. Bootstrap Contract 결정

- 현재 generated `docs/BOOTSTRAP.md`, `docs/GIT-WORKFLOW.md`, README, scaffold console output의 source-gitflow 안내를 대조한다.
- bootstrap contract를 두 층으로 분리할지 결정한다:
  - local bootstrap: git init/branches/hooks/initial commit.
  - GitHub bootstrap: remote push/ruleset/security settings/required checks.
- fresh-repo와 existing-repo를 반드시 분기한다:
  - fresh-repo: git repository 없음. `git init`부터 main/develop/origin/hook 순서를 안내한다.
  - existing-repo: 이미 git repository가 있음. `git init`/default branch 재작성/branch 생성 강제 없이 branch·remote·hook·ruleset 정합성만 점검한다.
- 기본 제안: **runbook-first**. local bootstrap은 deterministic command guide로 충분한지 먼저 판단하고, helper script는 반복 오류가 입증될 때만 후속으로 추가한다. GitHub bootstrap은 `gh` auth/permission/repo 존재 여부에 의존하므로 자동 적용하지 않는다.

### 2. Required Check / Path Filter 처리

- c2-B의 `harness-validate` 계약을 d bootstrap에 연결한다.
- **R0 반영 기본 결정: Option C.** `scripts/templates/source-gitflow/.github/workflows/harness-validate.yml`에서 workflow-level path filter를 제거하고 required check context `harness-validate` 계약을 유지한다.
  - 이유: path filter 없는 단일 lightweight workflow는 모든 main PR에서 항상 실행되어 stuck-pending을 원천 제거한다.
  - 이유: 새 context를 만들지 않아 c2-B에서 DR-020/GIT-WORKFLOW/source CI에 고정한 durable contract churn을 피한다.
- 대안 Option B: 별도 path-filter 없는 workflow/status check를 required로 만들고 `harness-validate`는 optional/report-only 유지. 단 한 slice 전 고정한 required-check contract를 바꾸는 비용이 있어 기본값으로 채택하지 않는다.
- 동작 불가 옵션 제거: workflow-level `on.*.paths`가 있으면 workflow 자체가 trigger되지 않으므로, 같은 workflow 안에 always-run job을 추가하는 방식은 후보에서 제외한다.
- ruleset required check 연결 범위는 `protect-main`에 한정한다. DR-020에 따라 `protect-develop`에는 required check를 연결하지 않는다.

### 3. Implementation Surface 결정

- 산출물을 어디에 둘지 결정한다.
- 후보:
  - `scripts/templates/source-gitflow/docs/GIT-WORKFLOW.md`에 runbook 확장.
  - generated `docs/BOOTSTRAP.md` source-gitflow conditional section 보강.
  - `tools/git-hooks/install.sh` 안내 연결.
  - `docs/SCAFFOLD-BOOTSTRAP.md` source 기준 보강.
- 기본 제안: 실제 destructive/remote-writing command는 자동 실행하지 않고 generated runbook으로 둔다. helper script는 이번 slice의 기본 산출물이 아니다. 만약 R1에서 helper가 꼭 필요하다고 합의되면 user-confirmed preview 중심으로 제한하고, manifest 추적 + CI syntax check + existing-repo 분기를 Done Criteria에 추가한다.

### 4. Source CI / Fresh Scaffold 검증

- generic scaffold에는 d bootstrap 산출물이 누수되지 않는지 확인한다.
- source-gitflow scaffold에는 bootstrap guidance/script가 배포되는지 확인한다.
- source-gitflow generated docs가 required check context와 path-filter caveat을 포함하는지 확인한다.
- `harness-validate.yml` 템플릿에 workflow-level `paths`가 없는지 source CI regression guard를 추가한다.
- generated runbook이 `protect-main` required check만 안내하고 `protect-develop`에는 required check를 연결하지 않는지 검증한다.
- generated runbook이 fresh-repo와 existing-repo를 분기하는지 검증한다.
- helper script가 생기면 `bash -n` 또는 `sh -n` 검증을 추가한다.

### 5. Result Review / Closeout

- A(Codex)가 구현/검증 결과를 Work 파일에 기록한다.
- B(Claude)가 result review를 수행하고 R-round에 누적한다.
- 합의 후 `/work-close`, commit, PR `--base develop`, CI 확인, merge 순서로 진행한다.

## Review Questions (for Claude R0)

| Question | A(Codex) Draft Answer |
| --- | --- |
| Q1. d slice가 GitHub ruleset을 실제 `gh api`로 자동 생성/수정해야 하나? | 기본 제안은 no. auth/permission/repo visibility/branch 존재에 의존하므로 자동 적용은 opt-in helper 또는 runbook으로 제한한다. 단 fresh test repo에서 mock/explicit dry-run 검증은 가능하다. |
| Q2. source-gitflow bootstrap helper script를 새로 만들까, 문서 runbook만 둘까? | R0 반영 기본 제안은 runbook-first. helper는 framework-owned surface와 CI/manifest 부담을 늘리므로, 시퀀스가 실제로 error-prone함이 입증될 때 후속으로 추가한다. |
| Q3. required check context는 계속 `harness-validate`로 유지해야 하나? | yes. c2-B contract churn을 피하고, `harness-validate.yml`의 workflow-level path filter를 제거해 required check가 항상 보고되도록 한다. |
| Q4. path-filter stuck-pending의 preferred fix는 무엇인가? | Option C. workflow-level path filter를 제거한다. 같은 workflow에 always-run job을 추가하는 방식은 workflow 자체가 trigger되지 않아 동작하지 않으므로 후보에서 제거한다. |
| Q5. generic scaffold에 bootstrap helper/guidance가 들어가야 하나? | no. source-gitflow opt-in target에만 branch/ruleset bootstrap을 제공한다. generic은 project-specific git policy가 우선이다. |
| Q6. DR-020을 amend해야 하나? | yes, 최소 amend. 기존 path-filter caveat을 "resolved: `harness-validate`는 path filter 없이 항상 실행되어 required check로 안전"으로 갱신한다. 신규 DR은 불필요하다. |

## Done Criteria

- [x] B(Claude)가 R0 plan review를 수행하고 Cross-Agent Review에 반영된다.
- [x] source-gitflow bootstrap scope(local vs GitHub remote/ruleset)가 합의된다.
- [x] required check context와 path-filter stuck-pending 처리 방식이 합의된다.
- [x] source-gitflow runbook이 fresh-repo와 existing-repo를 분기한다.
- [x] ruleset required check 연결 범위가 `protect-main`에 한정되고 `protect-develop`에는 연결하지 않음이 명시된다.
- [x] generic/source-gitflow boundary가 유지된다.
- [x] 합의된 generated guidance/script/source CI 검증이 구현된다.
- [x] fresh scaffold 검증 command가 CP3 전에 구체화된다.
- [x] source-vs-target boundary 누수가 없음을 확인한다.
- [x] validation 결과가 Work 파일에 기록된다.
- [x] B(Claude)가 result review를 수행하고 합의한다.
- [x] `/work-close`로 Done 처리 후 commit/PR/merge flow를 진행한다.

## Verification

```bash
git diff --check
bash -n scripts/create-harness.sh
# Helper script가 추가되면 bash/sh syntax check.
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
# - generic / generic --with-optional: no .github/workflows/harness-validate.yml and no docs/GIT-WORKFLOW.md
# - source-gitflow generic / spring-boot: harness-validate workflow present, no job-level name, no workflow-level paths,
#   manifest records workflow, generated GIT-WORKFLOW has fresh/existing repo bootstrap and protect-main-only guidance.
```

검증 결과(2026-06-06, A/Codex):

- `git diff --check` PASS
- `bash -n scripts/create-harness.sh` PASS
- `sh -n tools/git-hooks/{pre-commit,commit-msg,install.sh,lib/gate-lists.sh}` PASS
- YAML parse PASS: `.github/workflows/ci.yml`, `scripts/templates/source-gitflow/.github/workflows/harness-validate.yml`
- Path filter guard PASS: source `validate` workflow와 target `harness-validate` template에 workflow-level `paths` 없음
- Fresh scaffold matrix PASS(`/private/tmp/awh-d-bootstrap-TL4v9E`):
  - generic / generic --with-optional: `.github/workflows/harness-validate.yml`와 `docs/GIT-WORKFLOW.md` 없음
  - source-gitflow generic / spring-boot: `harness-validate` workflow 있음, job-level `name:` 없음, workflow-level `paths` 없음, manifest path 기록, generated `GIT-WORKFLOW.md`에 fresh/existing repo bootstrap과 `protect-main` only guidance 있음
- R2 guard hardening PASS:
  - `paths-ignore` regression guard 추가
  - `git diff --check`, `bash -n scripts/create-harness.sh`, workflow YAML parse 재통과

## Cross-Agent Review

| Round | Reviewer | Scope | Result | Notes |
| --- | --- | --- | --- | --- |
| R0 | Claude | Plan review | Approve-with-changes | Must-fix: 동작 불가 candidate A 제거, Option C(path filter 제거 + `harness-validate` 계약 유지) 기본값 채택, required check 연결은 `protect-main` 한정, bootstrap runbook은 fresh-repo/existing-repo 분기. Push back: helper script는 runbook-first로 낮추고, gh api 자동 적용 금지. |
| R0-A | Codex | R0 plan update | Done | Option C로 확정. 같은 workflow에 always-run job을 추가하는 후보를 제거하고, `harness-validate` path filter 제거 + context 유지로 plan 수정. Runbook-first, main-only required check, existing-repo 분기를 Done Criteria와 검증 계획에 추가. |
| R1 | Claude | Revised plan | Approve | 구현 진행 가능. 신규 비차단 finding: source repo `.github/workflows/ci.yml`의 required check `validate`도 path-filter stuck-pending에 노출되어 있어, source path filter 제거 또는 risk accept 중 명시 결정 필요. |
| R1-A | Codex | Scope decision + implementation | Done | 옵션 1 채택. target `harness-validate`뿐 아니라 source `validate` required check에서도 workflow-level path filter를 제거해 source/target footgun을 함께 해소한다. |
| R2 | Claude | Result review | Approve | Must-fix 없음. 구현이 Option C + R1 옵션1과 일치하고 scope 누수 없음. Nice-to-have: `paths-ignore`도 required-check workflow skip을 만들 수 있으므로 regression guard에 추가 권장. |
| R2-A | Codex | Guard hardening | Done | `paths-ignore` guard를 source CI와 generated source-gitflow scaffold assertion에 추가했다. |

## Checkpoints

| CP | Description | Status |
| --- | --- | --- |
| CP0 | Branch isolation + Work file/plan 작성 | Done |
| CP1 | Claude R0/R1 plan review + 합의 | Done |
| CP2 | source-gitflow bootstrap implementation | Done |
| CP3 | validation + A self-review | Done |
| CP4 | Claude result review | Done |
| CP5 | `/work-close` + commit/PR/merge | Done |

## Discovery

- 2026-06-06: Branch Isolation Check 결과 source-gitflow repo이며 `develop`에서 시작했다. `feature/chore-20260606-011-source-gitflow-bootstrap` 브랜치로 전환한 뒤 이 Work를 시작했다.
- 2026-06-06: c2-B handoff는 target required check context를 `harness-validate`로 고정했지만, path-filtered workflow를 required check로 연결할 때 stuck-pending footgun이 있어 d에서 반드시 처리해야 한다.
- 2026-06-06: DR-020은 GitHub ruleset 설정 SSoT이며, 2026-06-06 note에 check-run name matching과 path-filter caveat이 이미 기록되어 있다.
- 2026-06-06: DR-021에 따라 source-gitflow bootstrap 산출물은 source-owned framework asset이어야 하며 generic scaffold에는 누수되지 않아야 한다.
- 2026-06-06: DR-024/025에 따라 bootstrap gate는 conditional mandatory 성격이고, hook/CI hard enforcement claim은 설치/환경 context에 한정되어야 한다.
- 2026-06-06: R0 반영. `harness-validate` 계약은 유지하고 workflow-level path filter를 제거하는 Option C를 기본 결정으로 둔다. 같은 workflow에 always-run job을 추가하는 방식은 GitHub workflow-level paths와 함께 동작하지 않으므로 후보에서 제거했다.
- 2026-06-06: R1 반영. source repo `protect-main` required check `validate`도 같은 path-filter stuck-pending 리스크가 있으므로, 이 slice에서 source `.github/workflows/ci.yml` path filter도 함께 제거한다. 이는 target-only 변경보다 scope가 조금 넓지만 required-check 안정성 문제의 같은 원인 제거다.
- 2026-06-06: 구현 결과. Source CI `validate`와 target `harness-validate` 모두 workflow-level path filter를 제거했다. `harness-validate` check context는 유지한다. Generated `GIT-WORKFLOW.md`는 fresh repo와 existing repo bootstrap을 분기하고, required check는 `protect-main`에만 연결하도록 안내한다. GitHub ruleset 적용은 자동 실행하지 않고 maintainer-runbook으로 남긴다.
- 2026-06-06: R2 반영. `paths-ignore`도 required-check workflow skip을 만들 수 있으므로 source CI guard와 fresh scaffold assertion에 함께 추가했다.
- 2026-06-06: `/work-close` 처리. status를 Done으로 전환하고, archive는 보류한다.
