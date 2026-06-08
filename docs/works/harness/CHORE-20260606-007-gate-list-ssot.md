---
id: CHORE-20260606-007
priority: P1
status: Done
risk: High
scope: gate-enforcement-runtime-and-env slice (b) shared hook gate-list SSoT planning
appetite: 3d
planned_start: 2026-06-06
planned_end: 2026-06-08
actual_end: 2026-06-06
related_dr: [DR-024, DR-025]
related_troubleshooting: []
related_work: [CHORE-20260606-004]
---

# Gate List SSoT Slice B

## Context

CHORE-20260606-006 completed slice (a): source hook runtime for DR-025 finalization bundling.
That slice intentionally kept finalization and branch-isolation lists local to hook files, then recorded that the duplicated lists should be promoted to a shared SSoT before they spread further.

`docs/STATUS.md` now points to a `gate-enforcement-runtime-and-env` follow-up slice. The remaining options are:

- (b) hook gate-list SSoT
- (c) target scaffold hook distribution / install / CI alternatives
- (d) source-gitflow environment bootstrap

## Sub-Slice Selection

**선정:** 다음 sub-slice는 (b) hook gate-list SSoT로 진행한다. R0 review 후 **Design 2: shared POSIX shell SSoT**를 채택한다.

**이유:**

- Slice (a)가 이미 runtime behavior를 증명했으므로, 이제 duplicated hardcoded list를 한 shared hook-owned SSoT로 승격할 순서다.
- 현재 실제 consumer는 source shell hook뿐이다. JSON schema를 scaffold/CI consumer가 생기기 전 고정하면 slice (a)가 피하려던 "consumer 전 schema 고정"을 반복한다.
- `.harness/config.json`은 project-configurable target/scaffold consumer가 생기는 (c)에서 다시 판단한다.
- (d) source-gitflow bootstrap은 branch/environment 준비 문제라 config-driven gate mechanics와 직교한다.
- R1-N2의 잔여 edge(planning-only Work checkpoint commit hard-stop 가능성)는 exception granularity 문제이므로 이번 list SSoT schema에 선반영하지 않고 follow-up으로 둔다.

## Review Questions

| Question | Codex Draft Answer |
| --- | --- |
| 1. (b)를 (c)/(d)보다 먼저 하는가? | Yes, but as shared hook list SSoT, not `.harness/config.json` schema. 배포/CI와 JSON project config는 (c)에서 다룬다. |
| 2. `.harness/config.json`은 source repo 전용인가, scaffold target에도 복사할 것인가? | 이번 slice에서는 생성하지 않는다. JSON config는 실제 non-shell/scaffold consumer가 생기는 (c)에서 재검토한다. |
| 3. JSON parsing은 hook 안에서 어떻게 할 것인가? | 이번 slice에서는 JSON/Python helper를 도입하지 않는다. POSIX shell shared file을 두 hook이 source한다. |
| 4. shared list SSoT가 source-gitflow marker를 대체하는가? | No. `policy_type: source-gitflow` marker는 applicability gate로 유지한다. shared list SSoT도 marker를 대체하지 않는다. |
| 5. branch-isolation protected paths와 finalization bundling targets를 같은 list로 합칠 것인가? | No. DR-025와 R0/R1 결과에 따라 별도 shell variables/functions로 둔다. |

## Scope

### In Scope

- Shared POSIX shell SSoT 작성. 후보 path: `tools/git-hooks/lib/gate-lists.sh`.
- Branch-isolation protected paths와 finalization bundling targets를 같은 파일 안의 별도 list/function으로 유지.
- Override trailer token과 reason trailer token을 shared SSoT로 이동.
- `tools/git-hooks/pre-commit`과 `tools/git-hooks/commit-msg`가 shared file을 source하도록 rewire.
- Shared file 부재/소싱 실패 시 source hook이 어떻게 fail할지 결정. 후보: source repo hook file missing은 hard fail, list mismatch는 shell syntax/test에서 잡는다.
- Cross-Agent Review R-round 누적.

### Out Of Scope

- `.harness/config.json` 작성 또는 JSON schema 확정.
- Python helper 도입.
- target scaffold에 `.harness/config.json` 또는 hooks를 배포.
- CI 대안, hook install UX, scaffold product-adaptive logic.
- source-gitflow environment bootstrap(git init/main/develop/origin/branch protection).
- README/user-facing docs 재개편.
- source repo Gitflow 자체 변경 또는 scaffold default Gitflow 강제.
- 기존 source hook hygiene 전수 점검. 현행 hook hygiene 후보는 별도 backlog item으로 유지한다.

## Plan

| Field | Value |
| --- | --- |
| Risk | L2/L3 boundary - commit hook runtime logic을 정리하지만 새 runtime dependency나 scaffold schema는 도입하지 않음 |
| Execution Mode | Full Work, slice (b) only |
| Current State | Branch Isolation Check 완료: `develop` + `policy_type: source-gitflow`에서 `feature/chore-20260606-007-gate-config-ssot` branch로 전환 |
| Tool Rules | `.claude/rules/docs-workflow.md`, `.claude/rules/git-workflow.md` matched; Codex가 수동 적용 |
| Language Policy | DR-007 적용: docs는 Korean primary + Bilingual Rules, shell variable/function names are English |
| State Machine | INIT -> PLAN -> APPROVAL -> EXECUTE -> VALIDATE -> CHECKPOINT -> END |

1. **R0 Plan Review 준비**
   - 이번 Work 파일에 slice (b) 경계, Design 2 선택, non-goals를 고정한다.
   - Claude Review 요청 시 `Cross-Agent Review`에 R-round를 누적한다.

2. **Shared Shell SSoT 작성**
   - `tools/git-hooks/lib/gate-lists.sh` 후보를 만든다.
   - 포함 대상은 실제 중복/공유가 필요한 것만 둔다:
     - branch isolation protected paths matcher
     - finalization bundling target matcher
     - override trailer token
     - override reason trailer token
   - `validation.shell_syntax_paths`, `workflow_marker_file`, R1-N2 exception granularity는 포함하지 않는다.
   - `docs/decisions/*.md`는 기본 bundling target에 넣지 않고, tracker인 `docs/decisions/README.md`만 넣는다.

3. **Hook Rewire**
   - `pre-commit`: shared protected path matcher와 finalization matcher를 source한다. finalization은 계속 advisory-only다.
   - `commit-msg`: shared finalization matcher와 override trailer tokens를 source한다. hard-stop/degrade logic은 slice (a)와 동일하게 유지한다.
   - `policy_type: source-gitflow` marker check는 유지한다. Shared list SSoT가 marker를 대체하지 않는다.
   - shared file이 없거나 source 실패하면 source repo hook integrity failure로 명확히 실패시킨다. 이는 Python/config parse failure 축이 아니라 hook code missing/corruption 축이다.

4. **Validation**
   - `git diff --check`
   - `sh -n tools/git-hooks/pre-commit tools/git-hooks/commit-msg tools/git-hooks/install.sh tools/git-hooks/lib/gate-lists.sh`
   - temp git repo scenario: local-only hard-stop, override pass, malformed override fail, no-remote degrade, generic marker absent inert, bundled substantive+finalization pass.
   - shared list SSoT check: `pre-commit` and `commit-msg` no longer define separate finalization matchers.
   - scope guard: no scaffold template/CI/source-gitflow bootstrap changes.
   - `bash -n scripts/create-harness.sh`는 scaffold 파일 미수정이면 optional/Not Applicable로 보고한다.

5. **Result Review / Closeout**
   - Codex self-validation 결과를 Checkpoints/Discovery에 기록한다.
   - Claude result review R-round를 추가한다.
   - 사용자 승인 후 `/work-close`, commit approval, PR `--base develop`, merge 순서로 진행한다.

## Done Criteria

- [x] Claude가 R0 plan review를 수행하고, Cross-Agent Review에 반영된다.
- [x] 사용자 또는 Claude/Codex 합의로 slice (b) 범위와 SSoT strategy가 확정된다.
- [x] shared POSIX shell SSoT가 생성된다.
- [x] hook hardcoded protected/finalization/trailer lists가 shared SSoT를 사용한다.
- [x] source-gitflow marker가 applicability gate로 유지되고, shared SSoT가 scaffold default Gitflow 강제로 새지 않는다.
- [x] `.harness/config.json`, Python helper, scaffold 배포, CI 대안, source-gitflow bootstrap은 이번 PR에 포함되지 않는다.
- [x] Validation 항목이 통과하거나, 미실행 항목과 잔여 risk가 명시된다.
- [x] Claude 결과 검토가 완료된다.
- [x] 사용자 승인 후 `/work-close`를 진행한다.

## Verification

| Check | Command / Method | Expected |
| --- | --- | --- |
| Diff hygiene | `git diff --check` | PASS |
| Shell syntax | `sh -n tools/git-hooks/pre-commit tools/git-hooks/commit-msg tools/git-hooks/install.sh` | PASS |
| Shared shell syntax | `sh -n tools/git-hooks/lib/gate-lists.sh` | PASS |
| Runtime scenarios | temp git repo matrix | existing slice-a behavior preserved |
| Marker boundary | generic marker absent scenario | finalization hard gate inert |
| Scope guard | `git diff --name-only` | no scaffold template, CI, source-gitflow bootstrap changes |

### Validation Result

- `git diff --check`: PASS.
- `sh -n tools/git-hooks/pre-commit tools/git-hooks/commit-msg tools/git-hooks/install.sh tools/git-hooks/lib/gate-lists.sh`: PASS.
- `bash -n scripts/create-harness.sh`: PASS (scaffold script untouched; optional guard).
- Temp repo matrix: PASS 7/7 at `/private/tmp/awh-gate-list-ssot.qoNddj`.
  - pre-commit finalization-only advisory: exit 0 with warning.
  - local-only finalization hard-stop: exit 1.
  - valid override pass: exit 0.
  - malformed override fail: exit 1.
  - no-remote warning degrade: exit 0.
  - marker absent inert: exit 0.
  - bundled substantive plus finalization pass: exit 0.
- Shared SSoT check: `rg` shows finalization path literals and override trailer literals only in `tools/git-hooks/lib/gate-lists.sh`; hooks call shared functions/variables.
- Scope guard: modified files are docs tracking files plus `tools/git-hooks/pre-commit`, `tools/git-hooks/commit-msg`, and new `tools/git-hooks/lib/gate-lists.sh`; no `.harness/config.json`, Python helper, scaffold template, CI, or bootstrap files changed.

## Risks And Reversal Cost

| Risk | Impact | Mitigation |
| --- | --- | --- |
| shared shell file sourcing | missing/corrupt SSoT breaks hooks | fail loudly as source hook integrity failure; `sh -n` validation |
| JSON deferred | project-configurable non-shell consumer still unavailable | record (c) follow-up; no current consumer exists |
| shell-only SSoT | cross-tool/CI cannot read config directly | acceptable for source hook-only consumer; revisit in (c) |
| source/scaffold leakage | target repos inherit source hard gate defaults | no scaffold copy in this slice; marker remains separate |
| config/list confusion | branch isolation and finalization semantics blur | separate keys and tests for each list |

Reversal Cost: Low/Medium. Shared shell SSoT can be inlined back into hooks if needed. Reversal cost rises only after future scaffold/JSON distribution.

## STATUS Update Result

대상 Work ID: `CHORE-20260606-007`.

`docs/STATUS.md` Active Work에 이 Work 파일 pointer를 추가했다. `docs/backlog/HARNESS.md`와 `docs/works/harness/README.md`에도 Active row를 추가했다.

## Checkpoints

| CP | Description | Status |
| --- | --- | --- |
| CP-1 | Work file + plan 작성 | Done |
| CP-2 | Claude R0 plan review | Done |
| CP-3 | Implementation approval | Done |
| CP-4 | Shared shell SSoT implementation | Done |
| CP-5 | Hook rewire | Done |
| CP-6 | Validation and Codex self-review | Done |
| CP-7 | Claude result review | Done |
| CP-8 | `/work-close` | Done |
| CP-9 | commit, PR `--base develop`, merge | Pending post-close git workflow |

## Cross-Agent Review

| Round | Reviewer | Summary | Result |
| --- | --- | --- | --- |
| R0-prep | Codex | Slice (b)를 다음 작업으로 제안. Config schema는 source runtime SSoT로 제한하고, scaffold 배포/CI/source-gitflow bootstrap은 별도 slice로 유지한다. JSON parser strategy와 parse-failure enforcement mode는 R0 review 필요. | Pending Claude Review |
| R0 | Claude | 조건부 승인. (b) 우선·source-only 경계·marker 분리·별도 list는 정합. P1-1: `.harness/config.json`+Python(Design 1)과 shared shell SSoT(Design 2) 분기 미결 — 이번 slice의 실제 consumer는 source shell hook뿐이므로 JSON schema를 (c) 전에 고정하면 consumer 전 schema 고정 anti-pattern 반복. P1-2: Design 1이면 config absent/Python absent/parse failure는 built-in floor+warning degrade로 명문화 필요. P2: schema는 실제 중복분으로 최소화, `workflow_marker_file`/validation paths/R1-N2 exception 선반영 금지. | Conditional — Codex가 Design 2(shared POSIX shell SSoT)를 채택하고 plan에 반영 |
| R1-prep | Codex | Design 2로 구현 완료. `tools/git-hooks/lib/gate-lists.sh`에 branch-isolation protected matcher, finalization matcher, override/reason trailer token을 모으고 `pre-commit`/`commit-msg`가 source하도록 변경했다. `policy_type: source-gitflow` marker와 finalization hard-stop/degrade 판정은 slice (a)와 동일하게 유지했다. Validation은 diff hygiene, shell syntax, optional `create-harness.sh` syntax, temp repo 7-scenario matrix, scope guard 모두 PASS. | Pending Claude Result Review |
| R1 | Claude | 승인. 코드 정독과 독립 7-scenario matrix로 Design 2 구현이 R0 합의대로이며 slice A behavior를 보존한다고 확인했다. marker 없음은 완전 inert, no-remote는 warning degrade, local-only는 hard-stop, override+reason은 pass, reason 누락은 block, published는 report-only, missing SSoT는 fail-closed로 확인. `sh -n`과 `git diff --check`도 PASS. 기록 권장: missing SSoT fail-closed는 Design 2에서 floor 자체가 깨진 hook integrity failure라 의도된 선택임을 Discovery에 명시하고, `is_source_gitflow`/finalization-only counting loop 중복은 이번 slice 밖 future hygiene로만 남긴다. | Approve |

## Discovery

- CHORE-20260606-006 구현은 source hook runtime을 증명했지만, `pre-commit`과 `commit-msg`에 finalization list가 중복으로 존재한다.
- `find` 기준 repo root에는 현재 `.harness/config.json`이 없다. `tmp/*/.harness/manifest.json`은 generated/test output으로 보이며 이번 SSoT 대상이 아니다.
- `scripts/create-harness.sh`와 templates는 source-gitflow scaffold에 `docs/GIT-WORKFLOW.md` marker를 복사하지만, `tools/git-hooks/`는 복사하지 않는다. 이번 slice도 scaffold copy matrix를 건드리지 않는다.
- DR-025 §6은 protected paths와 bundling target을 project-configurable로 열어두지만, config mechanism은 downstream 소유라고 명시한다. 이 Work가 그 mechanism의 첫 slice다.
- R0 decision: Design 2(shared shell SSoT)를 채택한다. `.harness/config.json`은 실제 scaffold/non-shell/CI consumer가 생기는 (c)에서 다시 판단한다.
- Python is already used by advisory Stop hooks, but R0 confirmed that adding Python to the commit critical path has a different risk class and would expand the unresolved HRN-032 portability surface. This slice avoids that new dependency.
- Implementation result: shared POSIX shell SSoT는 `tools/git-hooks/lib/gate-lists.sh`로 두었다. hook source 실패는 config parse failure가 아니라 source hook integrity failure이므로 명시적 hard fail로 처리한다.
- The current branch name still contains `gate-config-ssot`; content scope has been corrected to `gate-list-ssot`. Renaming the branch is optional hygiene and not required for runtime behavior.
- R1 review confirmed that missing `tools/git-hooks/lib/gate-lists.sh` is intentionally fail-closed. In Design 2 the shared shell file is the built-in floor itself, so falling back would silently disable diff hygiene/branch isolation/finalization gate behavior after hook corruption.
- R1 review noted remaining algorithm duplication (`is_source_gitflow` and finalization-only staged counting loop) as optional future hook hygiene, not a slice (b) defect. This slice keeps the agreed boundary at list/token SSoT.
