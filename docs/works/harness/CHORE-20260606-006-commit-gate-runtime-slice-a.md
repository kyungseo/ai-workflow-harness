---
id: CHORE-20260606-006
priority: P1
status: Done
risk: High
scope: gate-enforcement-runtime-and-env slice (a) commit-gate hard-stop/sentinel runtime
appetite: 3d
planned_start: 2026-06-06
planned_end: 2026-06-08
actual_end: 2026-06-06
related_dr: [DR-024, DR-025]
related_troubleshooting: []
related_work: [CHORE-20260606-004]
---

# Commit Gate Runtime Slice A

## Context

`docs/STATUS.md` Next Actions는 `gate-enforcement-runtime-and-env`를 다음 후보로 가리킨다.
`docs/backlog/HARNESS.md`의 해당 후보는 구 HRN-002(hard enforcement hook)와 구 HRN-FUT-001(`.harness/config.json` SSoT)을 흡수하되, (a)~(d)를 단일 PR이 아니라 별도 slice로 착수하라고 명시한다.

DR-025는 commit gate runtime enforcement 정책을 Accepted로 확정했지만 decision-only다. 실제 hook hard-stop/sentinel, `.harness/config.json`, scaffold 배포/CI 대안, source-gitflow 환경 부트스트랩은 이 downstream 후보에서 분리 구현한다.

이번 Work는 plan review 전 구현을 시작하지 않는다. Codex가 Work 파일과 plan을 작성하고, Claude가 Cross-Agent Review R-round를 수행한 뒤 합의된 slice만 구현한다.

## Sub-Slice Selection

**선정:** 첫 sub-slice는 (a) `commit-gate hard-stop/sentinel + validation-gap 감지 hook`으로 둔다. 단, 이번 slice의 runtime 대상은 source repository hook context로 제한하고, config/scaffold/source-gitflow environment는 제외한다.

**이유:**

- DR-025가 이미 gate 대상(`T15`/`T16` finalization 산출물), local-only 증명 기준, override 방향(commit-trailer sentinel), N/A/degrade 원칙을 확정했으므로 최소 source hook은 `.harness/config.json` 없이도 설계 가능하다.
- (b) config SSoT를 먼저 만들면 실제 runtime 판정과 sentinel 경계가 검증되기 전에 protected path와 bundling target schema를 먼저 고정하게 된다. 이는 나중에 hook 구현에서 schema를 다시 바꿀 가능성을 키운다.
- (a)는 hook 내부 default list로 시작하되, 이 list가 2곳 이상으로 퍼지거나 project-specific 확장이 필요해지는 순간 (b)로 넘긴다.
- (a)에서 target scaffold에 hook을 배포하지 않는다. default/generic scaffold는 project-specific branch policy를 유지하고, source-style hard gate는 `--workflow source-gitflow` 또는 `policy_type: source-gitflow` marker가 있을 때만 강하게 적용한다.

## Review Questions

| Question | Codex Draft Answer |
| --- | --- |
| 1. 첫 sub-slice는 (a)인가, (b)인가? | (a)를 먼저 한다. DR-025 policy boundary가 확정되어 있어 source hook runtime을 먼저 검증하고, config SSoT는 runtime shape가 안정된 뒤 (b)로 둔다. |
| 2. Gitflow 강제와 runtime gate 강제가 scaffold target에 새지 않는가? | 이번 slice에서 scaffold를 수정하지 않고, source-gitflow marker가 없는 generic/project-specific context는 N/A 또는 advisory로 둔다. source repo Gitflow는 유지하되 scaffold default로 강제하지 않는다. |
| 3. hook 미설치 환경에서 advisory-only가 충분한가? | source hook slice의 hard enforcement claim은 hook-installed context로 제한한다. target hook 배포, CI 대안, documented check 보완은 (c)에서 다룬다. 이번 slice에서는 남은 risk로 명시한다. |
| 4. source-gitflow 환경 부트스트랩은 별도 (d)인가? | 맞다. git init/main/develop/origin/branch-protection 준비는 commit gate runtime과 직교하므로 (d)로 분리한다. no-remote/bootstrap context는 이번 slice에서 N/A/degrade 판정만 확인한다. |

## Scope

### In Scope

- 현행 `tools/git-hooks/pre-commit`, `tools/git-hooks/commit-msg`, `tools/git-hooks/install.sh` 구조 확인.
- DR-025의 source hook runtime 판정 설계: finalization-only commit 감지, local-only 증명 가능성, warning/report-only degrade, explicit override sentinel.
- pre-commit과 commit-msg hook의 책임 분리 설계. pre-commit은 staged file/context 판정에 강하고, commit-msg는 commit-trailer sentinel 검증에 강하므로 둘의 역할을 분리한다.
- 최소한의 hook 사용자 메시지 정리. 메시지는 한국어 주 언어 + Bilingual Rules를 따른다.
- Cross-Agent Review R-round 누적.

### Out Of Scope

- `.harness/config.json` 생성 또는 schema 확정.
- target scaffold hook 배포, install flow, CI 대안, product-adaptive hook logic.
- source-gitflow environment bootstrap(git init, main/develop/origin/branch protection).
- README/user-facing 문서 재개편.
- source repo Gitflow 폐기 또는 scaffold product repo Gitflow 기본 강제.
- 기존 source hook hygiene 전수 점검. 현행 hook hygiene 후보는 별도 backlog item으로 유지한다.

## Plan

| Field | Value |
| --- | --- |
| Risk | L3 - hook/runtime gate는 commit behavior와 workflow policy boundary에 영향 |
| Execution Mode | Full Work, slice (a) only |
| Current State | Branch Isolation Check 완료: `develop` + `policy_type: source-gitflow`에서 feature branch로 전환 |
| Tool Rules | `.claude/rules/docs-workflow.md`, `.claude/rules/git-workflow.md` matched; Codex가 수동 적용 |
| Language Policy | DR-007 적용: docs는 Korean primary + Bilingual Rules, frontmatter key는 English |
| State Machine | INIT -> PLAN -> APPROVAL -> EXECUTE -> VALIDATE -> CHECKPOINT -> END |

1. **R0 Plan Review 준비**
   - 변경 전제, 첫 slice 선택, 비목표, 검증 계획을 이 Work 파일에 고정한다.
   - Claude Review 요청 시 아래 Cross-Agent Review 섹션에 R-round를 누적한다.

2. **Runtime 판정 설계**
   - finalization 산출물 후보를 source hook default list로 정의한다. 초기 후보는 `docs/STATUS.md`, `docs/works/**`, `docs/backlog/**`, `docs/decisions/**`, `docs/works/**/README.md` 중심이다.
   - (R0 P2-1) 이 bundling 대상 list는 pre-commit의 branch-isolation **protected-path list**와 다른 개념(bundling vs branch isolation)이므로 **별도 list로 유지**하고 하나로 합치지 않는다. 두 list 모두 향후 (b) config에서 별도 key로 승격한다.
   - "finalization-only commit"과 "substantive+finalization bundled commit"의 판정 기준을 분리한다.
   - local-only 증명 불가 상태(detached HEAD, rebase/merge/cherry-pick 진행, remote/upstream 불확실, no-remote)는 hard-stop이 아니라 warning/report-only로 degrade한다.

3. **Hook 책임 분리 구현** (R0 P1-1 반영: override-aware hard-stop은 commit-msg가 소유)
   - `pre-commit`: finalization 산출물 detection + advisory warning까지만 한다. diff hygiene, shell syntax, branch isolation은 현행대로 유지한다. commit message가 아직 없으므로 여기서 hard-stop을 띄우지 않는다(띄우면 override trailer가 unreachable).
   - `commit-msg`: staged set(`git diff --cached --name-only`)과 message($1)를 함께 읽어 DR-025 gate 대상 판정, local-only 증명, hard-stop/warning/report-only degrade, override trailer sentinel(`AWH-Gate-Override`, `AWH-Gate-Reason`) 검증까지 집행한다. 두 신호를 동시에 보는 유일한 stage이므로 실제 hard-stop은 여기서 일어난다.
   - `install.sh`: hook 설명을 실제 책임과 맞게 최소 갱신한다. commit-msg 책임이 "Conventional Commits format"에서 "format + finalization gate"로 확장됨을 반영한다.

4. **Leakage 방지 확인** (R0 P1-2 반영: hook 내부 marker-gating)
   - 새 finalization hard-stop은 hook 내부에서 `policy_type: source-gitflow` marker가 있을 때만 작동시킨다. AI-advisory 레이어(`work-plan.md`, `work-close.md`)가 이미 marker-gated이므로 hook 레이어도 일관시키고, (c)에서 target 배포가 결정돼도 generic context에서 자동 inert가 되게 한다.
   - default/generic scaffold에는 source repo hard gate가 배포되지 않았음을 확인한다(현행 `scripts/create-harness.sh`는 `tools/git-hooks/`를 복사하지 않음 — R0 검증 완료).
   - source-gitflow marker가 없는 context는 hard gate가 아니라 N/A/advisory로 남긴다.
   - `.harness/config.json`, scaffold templates, source-gitflow bootstrap 파일은 수정하지 않는다.

5. **Validation**
   - `git diff --check`
   - `sh -n tools/git-hooks/pre-commit tools/git-hooks/commit-msg tools/git-hooks/install.sh`
   - temp git repository에서 local-only finalization split, override trailer, published/shared 또는 no-remote degrade scenario를 시뮬레이션한다.
   - `git diff --name-only`로 scaffold/config/source-gitflow env 파일이 섞이지 않았는지 확인한다.
   - 필요 시 `bash -n scripts/create-harness.sh`만 추가 확인한다. scaffold 파일을 수정하지 않는 한 fresh scaffold 생성은 Not Applicable로 보고한다.

6. **Result Review / Closeout**
   - Codex self-validation 결과를 Work 파일 Checkpoints/Discovery에 기록한다.
   - Claude 결과 검토 R-round를 Cross-Agent Review에 추가한다.
   - 사용자 승인 후 `/work-close`, commit approval, PR `--base develop`, merge 순서로 진행한다.

## Done Criteria

- [x] Claude가 R0 plan review를 수행하고, Cross-Agent Review에 반영된다.
- [x] 사용자 또는 Claude/Codex 합의로 slice (a) 범위가 확정된다.
- [x] source hook runtime이 DR-025의 T15/T16 bundling, local-only 증명 기준, default-safe degrade, override sentinel 원칙을 구현한다.
- [x] `.harness/config.json`, scaffold hook 배포/CI, source-gitflow bootstrap은 이번 PR에 포함되지 않는다.
- [x] hook 미설치 환경의 advisory-only gap과 (c) 보완 필요성이 Discovery 또는 follow-up에 기록된다.
- [x] Validation 항목이 통과하거나, 미실행 항목과 잔여 risk가 명시된다.
- [x] Claude 결과 검토 후 사용자 승인까지 받은 뒤 `/work-close`를 진행한다.

## Verification

| Check | Command / Method | Expected |
| --- | --- | --- |
| Diff hygiene | `git diff --check` | PASS |
| Shell syntax | `sh -n tools/git-hooks/pre-commit tools/git-hooks/commit-msg tools/git-hooks/install.sh` | PASS |
| Local-only hard-stop | temp git repo scenario | finalization split without override is blocked only when local-only is provable |
| Override sentinel | temp git repo scenario | valid trailer+reason allows explicit override; malformed override fails |
| Degrade contexts | temp git repo scenario | no-remote/uncertain/published-like contexts do not hard-stop |
| Scope guard | `git diff --name-only` | no `.harness/config.json`, no scaffold template, no source-gitflow env bootstrap changes |

## Risks And Reversal Cost

| Risk | Impact | Mitigation |
| --- | --- | --- |
| pre-commit cannot read final commit message | override cannot be validated in pre-commit alone | split responsibilities with `commit-msg` |
| finalization-only detection false positive | user blocked on legitimate maintenance commit | local-only hard-stop only when evidence is strong; otherwise warning/report-only |
| config deferred | default list may be hardcoded for one slice | keep list local and promote to (b) before expansion |
| hook uninstalled | no runtime hard-stop | scope claim limited to hook-installed source context; (c) owns CI/install alternative |
| scaffold leakage | adopters get unwanted Gitflow/hard gate | no scaffold changes in this slice; marker-based source-gitflow boundary retained |

Reversal Cost: Medium for hook logic once implemented, Low for this planning/tracking edit. Hook changes can be reverted by restoring `tools/git-hooks/*`; policy remains in DR-025.

## STATUS Update Result

대상 Work ID: `CHORE-20260606-006`.

사용자 승인 후 `docs/STATUS.md` Active Work에 이 Work 파일 pointer를 추가했다. `docs/backlog/HARNESS.md` row도 `Active`로 맞췄다.

## Checkpoints

| CP | Description | Status |
| --- | --- | --- |
| CP-1 | Work file + plan 작성 | Done |
| CP-2 | Claude R0 plan review | Done |
| CP-3 | Scope agreement and implementation approval | Done |
| CP-4 | Source hook runtime implementation | Done |
| CP-5 | Validation and Codex self-review | Done |
| CP-6 | Claude result review | Done |
| CP-7 | `/work-close` state finalization | Done |

## Cross-Agent Review

| Round | Reviewer | Summary | Result |
| --- | --- | --- | --- |
| R0-prep | Codex | 첫 slice는 (a)로 제안. (b) config, (c) scaffold/CI, (d) source-gitflow bootstrap은 독립 slice로 분리한다. | Pending Claude Review |
| R0 | Claude | 조건부 승인. slice 경계(a 우선, b~d 분리)·source-vs-scaffold boundary는 DR-025/DR-024 정합. P1-1: override-aware hard-stop을 pre-commit→commit-msg로 이동(§4 trailer는 message stage에서만 보임, pre-commit hard-stop 시 override unreachable). P1-2: 새 finalization hard-stop을 hook 내부 `policy_type: source-gitflow` marker로 게이팅(advisory 레이어와 일관, (c) 배포 누수 차단). P2: bundling list와 branch-isolation protected-path list 분리, local-only 탐지 default-safe 매핑·install.sh 문구 범위 확장 반영. | Conditional — P1-1/P1-2 해소를 Plan에 반영 완료, 구현 착수 가능 |
| R1 | Claude | 결과 검토 승인. 코드 정독과 독립 temp-repo 6개 시나리오 재현으로 R0 조건 충족을 확인했다. 5개 질문 모두 PASS. `classify_finalization_context`가 DR-025 §3을 보수적으로 구현하고, override token+reason 검증이 durable record 요구를 충족한다고 평가했다. | Approved — blocker 없음. Discovery 보강 3건(R1-N1~N3) 기록 권장 |

## Discovery

- 현행 `pre-commit`은 diff hygiene, protected workflow file branch warning/block, shell syntax check만 수행한다.
- 현행 `commit-msg`는 Conventional Commits format만 검증한다.
- override sentinel은 commit message를 읽어야 하므로 `commit-msg` 관여가 필요하다. pre-commit 단독 구현은 DR-025 override 요구를 충족하기 어렵다.
- (R0) 현행 `pre-commit`의 branch-isolation 블록은 marker를 검사하지 않고 develop/main이면 무조건 작동한다. source repo에서는 무해(항상 marker 보유 + scaffold 미배포)하나, 새 finalization hard-stop을 같은 hook에 추가할 때는 hook 내부 marker-gating으로 (c) 배포 누수를 차단한다(P1-2).
- (R0) `scripts/create-harness.sh`는 `tools/git-hooks/`를 복사하지 않는다(grep 0건). 따라서 이번 slice의 hook 변경은 파일 배포 레벨에서 target으로 새지 않는다.
- (R0 P2-2) "provably local-only" 탐지는 `@{upstream}`/`git branch -r --contains HEAD` 등으로 판정하되, 신호 부재·불확실 시 곧바로 DR-025 §3 "불확실 → warning"으로 default-safe degrade한다(hard-stop 금지). 상세 탐지 로직은 구현 단계 책임.
- 구현 결과: `pre-commit`은 source-gitflow marker가 있을 때 finalization-only staged set을 advisory warning으로만 보고한다. diff hygiene, branch isolation, shell syntax check는 기존 책임을 유지한다.
- 구현 결과: `commit-msg`가 staged set과 commit message를 함께 읽어 finalization-only 여부, source-gitflow marker, local-only/published/uncertain context, override trailer(`AWH-Gate-Override: finalization-split` + `AWH-Gate-Reason`)를 판정한다.
- 구현 결과: finalization bundling list는 branch-isolation protected-path list와 분리했다. 이번 slice의 list는 `docs/STATUS.md`, `docs/backlog/*`, `docs/works/*`, `docs/decisions/README.md`이며, `.harness/config.json` 승격은 (b)에서 다룬다.
- Validation PASS: `git diff --check`, `sh -n tools/git-hooks/pre-commit tools/git-hooks/commit-msg tools/git-hooks/install.sh`.
- Scenario Validation PASS: temp git repos에서 local-only hard-stop, valid override pass, malformed override fail, no-remote warning pass, published report-only pass, generic marker absent pass, bundled substantive+finalization pass를 확인했다. 테스트 root: `/private/tmp/awh-gate-tests.RzDjWA`.
- Pre-commit Advisory PASS: feature branch temp repo에서 finalization-only staged set이 warning을 출력하고 exit 0으로 통과함을 확인했다.
- Scope Guard PASS: `git diff --name-only` 기준 `.harness/config.json`, scaffold template, source-gitflow env bootstrap 파일 변경 없음. 다만 `scripts/templates/source-gitflow/docs/GIT-WORKFLOW.md`에는 기존 hook 참고 문구가 있어 (c)에서 target 배포/CI 대안을 다룰 때 재확인 대상이다.
- (R1-N1) 계획보다 구현이 더 정확해진 지점: Plan step 2 초안은 finalization 후보에 `docs/decisions/**`를 넓게 적었으나, 구현은 `docs/decisions/README.md`만 bundling finalization list에 포함했다. 개별 `DR-*.md` 작성/수정은 substantive work이고, DR tracker인 decisions README만 finalization 산출물이라는 DR-025 §1 의도에 더 정확하다.
- (R1-N2) 잔여 edge: planning-only Work 파일 단독 checkpoint commit은 local-only이면 finalization-only로 hard-stop될 수 있다. override path가 있고, (b) `.harness/config.json`에서 Work 파일 세부 경로나 checkpoint 성격을 더 정교화할 수 있으므로 blocker는 아니다.
- (R1-N3) UX noise: `pre-commit`은 commit trailer를 볼 수 없으므로 override trailer가 있는 commit도 먼저 finalization warning을 출력하고, 이후 `commit-msg`가 override recorded로 마무리한다. R0 P1-1에 따른 구조적 귀결이며 정상 동작으로 둔다.
- `/work-close` 처리: 2026-06-06에 Done 처리했다. Archive는 보류하고, commit/PR/merge는 git workflow gate에서 이어간다.
