---
id: HRN-033
priority: P2
status: Archived
risk: Medium
scope: Scaffold onboarding git repository bootstrap and no-git workflow handling
appetite: 0.5d
planned_start: 2026-05-24
planned_end: 2026-05-24
actual_end: 2026-05-24
related_dr: []
related_commits: []
related_troubleshooting: []
---

# HRN-033: Scaffold Onboarding Git Repository Bootstrap

## Context

`scripts/create-harness.sh`는 신규 프로젝트 디렉토리에 harness 파일을 생성하지만
git repository를 자동 초기화하지 않는다. 이는 안전한 기본값이다.
default branch, remote, visibility, initial commit policy는 사용자가 결정해야 하기 때문이다.

하지만 scaffold 직후 첫 `/start`와 bootstrap onboarding은 repo-visible state,
commit gate, branch/PR workflow, `related_commits`, `git diff --check` 같은 git 기반 절차를
암묵적으로 기대할 수 있다. 신규 scaffold 디렉토리가 아직 git repository가 아니라면
이 절차들은 실패하거나 `Not Applicable`로 처리되어야 한다.

이 Work는 `git init`을 자동 수행하는 것이 아니라, scaffold/onboarding 단계에서
git repository 존재 여부를 명시적으로 확인하고, 미초기화 상태에서 agent가 어떤 절차를
비활성화하거나 제안해야 하는지 정렬한다.

## Risk And Mode

- 위험도: L2
- 실행 모드: Standard Work
- 이유: scaffold script, generated onboarding docs, workflow protocol/manual, tool-facing command 또는 prompt surface가 함께 영향을 받을 수 있다.

## Scope

### In Scope

- 신규 scaffold와 `--existing` overlay의 git repository 존재 여부 판단 기준 정리.
- git repository가 없을 때 `/start`, bootstrap onboarding, `/work`, `/close`, `/done`, commit gate에서 어떤 항목을 `Not Applicable`로 보고할지 정리.
- 사용자 승인 기반 `git init` / initial commit 안내 문구 설계.
- generated `README.md`, `docs/BOOTSTRAP.md`, `docs/STATUS.md` 또는 scaffold 완료 메시지 중 가장 적절한 위치에 안내 반영.
- source 기준 문서(`docs/SCAFFOLD-BOOTSTRAP.md`, 필요 시 `docs/WORKFLOW-MANUAL.md`, `docs/HARNESS-PROTOCOL.md`)와 tool surface를 정렬.
- git repo 없음/있음 시나리오별 scaffold smoke test 설계 및 실행.

### Out Of Scope

- `scripts/create-harness.sh`에서 자동 `git init` 수행.
- remote repository 생성, GitHub repository 설정, branch protection 설정.
- Gitflow 자체 변경.
- Windows native 지원 확장. OS별 shell/path 이슈는 HRN-032에서 다룬다.
- pre-commit hook 자동 설치.

## Current Assumptions

- 신규 scaffold mode는 target directory가 존재하지 않아야 하며, 생성 후 `.git/`도 없다.
- `--existing` mode는 target이 이미 git repository일 수도 있고 아닐 수도 있다.
- `/start` 자체는 문서 읽기 중심이므로 git repository가 없어도 동작 가능해야 한다.
- commit/PR/branch 관련 절차는 git repository가 없으면 `Not Applicable`로 보고해야 한다.
- `git init`은 destructive하지 않지만 project governance를 바꾸는 초기화 행위이므로 사용자 승인 후 안내 또는 실행해야 한다.

## Candidate User Experience

### New Scaffold, No Git Repository

1. scaffold 완료 메시지가 "git repository is not initialized by default"를 알려준다.
2. 첫 `/start`는 `docs/STATUS.md` Next Actions의 bootstrap onboarding pointer를 확인한다.
3. bootstrap onboarding에서 "Repository Setup"을 확인한다.
4. git repo가 없으면 agent는 아래를 보고한다.
   - commit/PR/branch workflow: `Not Applicable until git init`
   - related commits: `Not Applicable`
   - validation: 문서/파일 검증은 가능, git diff 기반 검증은 제한
   - recommended next step: 사용자 승인 후 `git init`, default branch 결정, initial commit 여부 결정

### Existing Project Overlay

1. scaffold 완료 메시지나 bootstrap checklist가 existing target의 git repository 여부 확인을 요구한다.
2. git repo가 있으면 기존 branch/remote 정책을 먼저 확인하고, harness Gitflow 문서를 그대로 강제하지 않는다.
3. git repo가 없으면 신규 scaffold와 같은 `Not Applicable` 안내를 사용한다.

## Plan

### Step 1 - Current Surface Audit

- `scripts/create-harness.sh` generated `README.md`, `STATUS.md`, `BOOTSTRAP.md`, CLI 완료 메시지를 확인한다.
- `docs/SCAFFOLD-BOOTSTRAP.md`의 Boot Sequence와 Required Setup Items를 확인한다.
- `docs/AGENT-WORKFLOW.md`, `docs/HARNESS-PROTOCOL.md`, `docs/WORKFLOW-MANUAL.md`, `docs/GIT-WORKFLOW.md`에서 git repository 전제를 가진 문장을 찾는다.
- `.claude/commands/*.md`, `.agents/skills/workflow-*`, `.cursor/rules/*`, prompts에서 `/start`, `/done`, commit gate, git workflow 안내가 git repo 없음 상태를 어떻게 처리하는지 확인한다.

### Step 2 - Policy Decision

- 다음 정책을 채택할지 사용자에게 확인한다.

```text
신규 scaffold는 git repository를 자동 초기화하지 않는다.
첫 onboarding에서 현재 디렉토리가 git repository인지 확인하고,
필요하면 사용자 승인 후 git init과 initial commit 절차를 진행한다.
git repository가 아니면 commit/PR/branch 관련 workflow는 Not Applicable로 보고한다.
```

- DR-worthy 여부를 판단한다.
  - 자동 `git init`을 하지 않는 정책은 scaffold behavior와 onboarding contract에 영향을 주지만 reversal cost는 낮거나 중간이다.
  - 기존 policy를 명확화하는 수준이면 DR 없이 Work Discovery와 문서에 기록한다.
  - 자동 초기화 여부, branch naming 기본값, initial commit 강제 여부까지 결정하면 DR 후보로 본다.

### Step 3 - Documentation And Scaffold Output Design

- generated `docs/BOOTSTRAP.md`에 `Repository Setup` 섹션을 추가하는 방안을 우선 검토한다.
- generated `README.md`의 `사전 작업`에 "git repository 자동 초기화 없음" 안내를 추가할지 검토한다.
- `scripts/create-harness.sh` 완료 메시지에 optional next step을 추가할지 검토한다.
- source 기준 문서 `docs/SCAFFOLD-BOOTSTRAP.md`에 같은 기준을 반영한다.
- 필요한 경우 `docs/WORKFLOW-MANUAL.md`의 scaffold onboarding section과 `docs/HARNESS-PROTOCOL.md`의 validation/commit gate wording을 정렬한다.

### Step 4 - Tool Surface Alignment

- Claude command와 Codex skill 중 `/start`, `/work`, `/done`, `/health`가 git repo 없음 상태를 명시해야 하는지 확인한다.
- Cursor rules와 session prompts가 commit/PR flow를 무조건 전제하는지 확인한다.
- 필요한 경우 "git repository가 없으면 commit/PR/branch workflow를 Not Applicable로 보고" 문구를 최소 surface에 추가한다.

### Step 5 - Scenario Verification

- 신규 scaffold 생성 후 `.git/`이 없는 상태를 확인한다.
- no-git scaffold에서 bootstrap 안내가 git setup을 제안하고, commit/PR 관련 절차를 강제하지 않는지 문서 기준으로 시뮬레이션한다.
- `git init` 후 같은 scaffold에서 guidance가 기존 git repo로 인식되는지 확인한다.
- `--existing` mode에서 git repo 있음/없음 target의 dry-run 또는 actual 생성 결과를 확인한다.
- generic과 spring-boot profile 모두에서 generated 안내가 일관적인지 확인한다.

## Proposed Change Surface

| Surface | Change Need | Notes |
| --- | --- | --- |
| `scripts/create-harness.sh` | Likely | generated `README.md`/`BOOTSTRAP.md`/completion output 보강 |
| `docs/SCAFFOLD-BOOTSTRAP.md` | Likely | source 기준 onboarding policy 추가 |
| `docs/WORKFLOW-MANUAL.md` | Possible | scaffold onboarding section 정렬 |
| `docs/HARNESS-PROTOCOL.md` | Possible | validation/commit gate에서 no-git `Not Applicable` 기준 명시 |
| `.claude/commands/*.md` | Possible | `/done` 또는 `/health` commit gate wording 확인 |
| `.agents/skills/workflow-*` | Possible | Claude command mirror와 동일하게 확인 |
| `.cursor/rules/*.mdc`, `prompts/*.md` | Possible | session-start / commit wording 확인 |
| `docs/STATUS.md` | State-change only | Active Work pointer 추가/제거는 별도 승인 |

## Done Criteria

- [x] 신규 scaffold가 git repository를 자동 초기화하지 않는다는 정책이 generated onboarding surface에 명확히 표시된다.
- [x] git repo가 없는 경우 commit/PR/branch workflow, `related_commits`, git diff 기반 검증을 `Not Applicable`로 보고하는 기준이 문서화된다.
- [x] 사용자 승인 기반 `git init` / initial commit 안내가 scaffold onboarding에 포함된다.
- [x] 신규 scaffold와 `--existing` overlay의 git repo 있음/없음 시나리오가 구분된다.
- [x] source docs와 generated docs가 같은 onboarding 정책을 설명한다.
- [x] Claude/Codex/Cursor surface가 commit gate를 무조건 전제하지 않도록 필요한 범위에서 정렬된다.
- [x] generic과 spring-boot scaffold 생성 결과가 일관된다.
- [x] 사용자 리뷰 후 `/close` 전 최종 검증 결과가 Work 파일에 반영된다.

## Verification

```bash
git diff --check
bash -n scripts/create-harness.sh
./scripts/create-harness.sh --dry-run --profile generic hrn-033-generic /private/tmp/hrn-033-generic-dry
./scripts/create-harness.sh --profile generic hrn-033-generic /private/tmp/hrn-033-generic
test ! -d /private/tmp/hrn-033-generic/.git
rg -n "git repository|git init|initial commit|Not Applicable|commit/PR/branch" \
  /private/tmp/hrn-033-generic README.md docs scripts .claude .agents .cursor prompts AGENTS.md CLAUDE.md \
  -g '!docs/archive/**'
git -C /private/tmp/hrn-033-generic init
git -C /private/tmp/hrn-033-generic status --short
./scripts/create-harness.sh --dry-run --existing --profile generic hrn-033-existing /private/tmp/hrn-033-existing-git
./scripts/create-harness.sh --dry-run --existing --profile generic hrn-033-existing-nogit /private/tmp/hrn-033-existing-nogit
./scripts/create-harness.sh --dry-run --profile spring-boot hrn-033-spring /private/tmp/hrn-033-spring-dry
```

Temp directory setup/cleanup is allowed only for HRN-033-owned paths.
If a target already exists, use a fresh `/private/tmp/hrn-033-*` path.

## Risks

| Risk | Impact | Mitigation |
| --- | --- | --- |
| Agent treats no-git state as validation failure | First onboarding becomes noisy or blocked | Define no-git as bootstrap state, not FAIL, for commit/PR-only workflows |
| Auto `git init` seems convenient but oversteps | Unexpected repo policy, branch, remote assumptions | Keep auto-init out of scope; require user approval |
| Guidance duplicated across too many surfaces | Drift risk | Put detailed policy in bootstrap/source docs, mirror only short decision rules in tool surfaces |
| `--existing` project has its own git workflow | Harness Gitflow may conflict with existing branch policy | Existing repo onboarding must inspect current branch/remote before recommending Gitflow |
| Windows path/shell issues get mixed in | Scope creep into HRN-032 | Track OS-specific command/path compatibility separately under HRN-032 |

Reversal cost: Medium.
The policy can be removed from docs and scaffold output, but once users follow onboarding guidance it may shape their initial repository setup.

## Codex Rule Reference

- `.claude/rules/docs-workflow.md` applies because this Work changes docs and workflow/scaffold guidance.
- `.claude/rules/git-workflow.md` applies if implementation touches commit/branch workflow guidance.
- No Java, testing, or infra-specific rule applies unless spring-boot profile docs are changed.

## STATUS Update Proposal

Do not update `docs/STATUS.md` without explicit approval.

Proposed one-line state update if this Work is accepted for active execution:

> Add Active Work pointer for HRN-033 (`docs/works/harness/HRN-033-git-repository-bootstrap.md`) to `docs/STATUS.md`.

## Checkpoints

| CP | Description | Status |
| --- | --- | --- |
| CP-1 | HRN-033 Work plan 작성 | Done |
| CP-2 | 사용자 리뷰 및 scope 승인 | Done |
| CP-3 | no-git onboarding policy 확정 | Done |
| CP-4 | scaffold/generated docs/source docs 반영 | Done |
| CP-5 | tool surface alignment | Done |
| CP-6 | scenario verification and final review | Done |

## Discovery

- HRN-025에서 bootstrap은 daily `/start`가 아니라 generated `STATUS.md` Next Actions pointer로만 재진입되는 one-time onboarding flow로 정리됐다.
- HRN-033은 이 bootstrap flow 안에 repository setup check를 추가하는 작업이며, `/bootstrap` command를 새로 도입하지 않는다.
- 신규 scaffold mode는 target directory가 새로 생성되므로 git repository가 없을 가능성이 높다.
- Existing overlay mode는 git repo 있음/없음이 모두 가능하므로 같은 안내를 강제하지 않고 먼저 확인해야 한다.

### Surface Audit 결과 (Step 1 완료)

#### scaffold completion message (`scripts/create-harness.sh` L671–700)

- "Bootstrap onboarding targets"와 "First session" 안내만 출력하고, git repository가 초기화되지 않는다는 사실을 전혀 언급하지 않는다.
- **Gap**: 사용자가 `claude` + `/start`를 실행하기 전까지 git 미초기화 사실을 알 방법이 없다.

#### generated `docs/STATUS.md` Next Actions (script L410–416)

- 6개 항목 중 git repository setup에 대한 항목이 없다.
- **Gap**: 첫 `/start`가 Next Actions를 읽어도 git 미초기화 상태를 발견하지 못한다.

#### generated `docs/BOOTSTRAP.md` (script L421–497)

- §1 Project Identity / §2 Product Track / §3 Harness Track / §4 Core Doc Fill / §5 Example Pack / §6 First Session Prompt / §7 Completion Rule — 7개 섹션 중 git repository setup 섹션이 없다.
- §2, §3 모두 work 파일, backlog 등록, commit 여부 판단을 체크리스트에 포함하지만 그 전제인 git 상태를 확인하지 않는다.
- **Gap**: git setup이 가장 자연스럽게 추가될 위치인데 완전히 빠져 있다.
- **결론**: `Repository Setup` 섹션을 §2 앞에 삽입하는 것이 최소 변경 경로다.

#### `docs/SCAFFOLD-BOOTSTRAP.md` (source, 73줄)

- Boot Sequence 7단계는 identity/backlog/docs/work/example pack/Next Actions 중심이며 commit을 직접 전제하지는 않는다. 다만 repo-visible state와 Work tracking을 전제하고, git repository setup 확인 항목이 없다.
- Required Setup Items 테이블에 git row가 없다.
- **Gap**: source 기준 문서가 no-git 상태를 정의하지 않아 generated 문서도 반영할 기준이 없다.

#### `docs/HARNESS-PROTOCOL.md`

- "Not Applicable"는 scaffold script가 없는 repository에서 T12 검증을 건너뛸 때만 사용된다 (L479).
- commit/validation gate에 no-git 조건이 없다.
- **Gap**: no-git을 FAIL이 아닌 bootstrap 상태로 정의하는 기준이 프로토콜에 없다.

#### `.claude/commands/done.md`, `.agents/skills/workflow-done/SKILL.md`

- `/done`은 `git status → git add → git diff --cached` 순서를 명시 (done.md L42).
- **Gap**: git 명령이 없는 디렉토리에서 실행하면 에러 또는 혼란스러운 출력이 발생한다.
- `.claude/commands/done.md`와 `.agents/skills/workflow-done/SKILL.md`를 각각 수정해야 한다. mirror 자동 정렬은 없다.

#### `.claude/commands/close.md`, `.agents/skills/workflow-close/SKILL.md`

- `/close`는 "commit/PR finalization gate를 대체하지 않는다"고 명시하지만 no-git 예외가 없다.
- `/close`의 optional archive 단계는 `git mv`를 명시한다. no-git이면 이 단계도 `Not Applicable` 또는 plain `mv` 제안으로 처리해야 한다.
- **Gap**: done.md와 동일하게, `.claude/commands/close.md`와 `.agents/skills/workflow-close/SKILL.md`를 각각 수정해야 한다.
- 단, archive는 optional이므로 짧은 조건문으로 충분하다.

#### git rule / prompt surface

- `.claude/rules/git-workflow.md`, `.cursor/rules/git-commit.mdc`, `.cursor/rules/workflow.mdc`, `prompts/` 의 commit gate 문구가 no-git 상태를 어떻게 처리하는지 확인이 필요하다.
- deep rewrite는 불필요하지만, "git repo가 아니면 commit/PR gate는 Not Applicable" 한 줄이 필요할 수 있다.
- **확인 대상 수준**: Step 4에서 audit 후 필요 여부 결정.

---

### 변경 경로 우선순위

| 순위 | Surface | 이유 |
|---|---|---|
| 1 | `scripts/create-harness.sh` — completion message | 사용자가 scaffold 직후 가장 먼저 보는 출력 |
| 2 | `scripts/create-harness.sh` — generated `BOOTSTRAP.md` §2 앞에 `Repository Setup` 섹션 삽입 | bootstrap flow의 첫 체크이며 이후 commit/work 전제를 제어하는 핵심 위치 |
| 3 | `docs/SCAFFOLD-BOOTSTRAP.md` — Boot Sequence와 Required Setup Items에 git check 추가 | source 기준 문서가 없으면 generated 문서를 재설계할 기준이 없다 |
| 4 | `docs/HARNESS-PROTOCOL.md` — commit gate wording에 no-git `Not Applicable` 조건 추가 | protocol 기준이 있어야 agent가 일관되게 판단한다 |
| 5 | `.claude/commands/done.md` + `.agents/skills/workflow-done/SKILL.md` — 짧은 no-git 조건 문구 추가 | 각각 독립 수정 필요; mirror 자동 정렬 없음 |
| 6 | `.claude/commands/close.md` + `.agents/skills/workflow-close/SKILL.md` — git mv archive no-git 예외 추가 | archive가 optional이므로 짧은 조건문으로 충분 |
| 7 | git rule/prompt surface — Step 4에서 audit 후 결정 | `.claude/rules/git-workflow.md`, `.cursor/rules/git-commit.mdc`, `.cursor/rules/workflow.mdc`, `prompts/` 대상; 한 줄 추가 수준 예상 |

generated `docs/STATUS.md` Next Actions에 git setup 항목을 추가하는 것은 BOOTSTRAP.md §Repository Setup로 충분히 커버되므로 별도 변경을 최소화한다.

---

### Policy 결정 사항 (Step 2 pre-check)

아래 정책은 Scope에서 이미 정리됐으나 audit 후 재확인이 필요한 항목만 기록한다.

- **자동 `git init` 금지** 유지 — completion message에서 "next step suggestion"으로만 안내한다.
- **no-git = bootstrap 상태**, FAIL 아님 — `/done`·`/close`에서 git 명령을 Not Applicable로 건너뛰되 work/doc 검증은 계속 진행한다.
- **DR 불필요** — 기존 policy를 명확화하는 수준이며 새 결정이 아니다. Work Discovery와 문서 변경으로 충분하다.
- **`--existing` overlay** — git repo 있음/없음 모두 가능하므로 bootstrap 체크리스트에 "현재 디렉토리가 git repository인지 확인" 항목으로 통일한다. Gitflow 강제는 하지 않는다.

### Scenario Simulation 결과 (1차)

#### New scaffold, no git init 유보

- `/private/tmp/hrn-033-sim-nogit` generic scaffold 생성 후 `.git/`이 없는 것을 확인했다.
- completion output에 "git repository is not initialized"와 `docs/BOOTSTRAP.md` §0 안내가 표시된다.
- generated `README.md` 사전 작업에 git repository가 자동 초기화되지 않는다는 안내가 생성된다.
- generated `docs/BOOTSTRAP.md` §0 Repository Setup에 `git init`, default branch, initial commit 결정 항목이 생성된다.
- `git -C /private/tmp/hrn-033-sim-nogit status`와 `rev-parse --is-inside-work-tree`는 exit 128 / "not a git repository"로 실패한다. 이 상태는 validation FAIL이 아니라 no-git bootstrap 상태로 해석해야 한다.
- commit/PR/branch workflow, `related_commits`, `git diff` 기반 검증은 `Not Applicable`로 보고하고 문서/파일 검증만 진행하는 흐름이 맞다.

#### New scaffold 후 사용자가 `git init` 진행

- `/private/tmp/hrn-033-sim-init` generic scaffold 생성 후 `git init`을 실행했다.
- `git status --short`는 scaffold 산출물을 모두 untracked로 표시했다.
- local default branch는 `main`으로 잡혔고 remote는 없었다.
- 이 경우 commit/PR/branch workflow는 더 이상 `Not Applicable`이 아니지만, remote와 Gitflow 적용 여부는 별도 확인 후 제안해야 한다.

#### `--existing` overlay: git repo 있음/없음

- `.git/`이 있는 existing target dry-run에서는 no-git completion note가 출력되지 않았다.
- `.git/`이 없는 existing target dry-run에서는 no-git completion note가 출력됐다.
- 따라서 completion message의 `.git/` 분기는 existing overlay에서도 의도대로 동작한다.

#### spring-boot profile

- `/private/tmp/hrn-033-sim-spring` spring-boot scaffold 생성 후 `.git/`이 없는 것을 확인했다.
- generic과 동일하게 generated `README.md`, `docs/BOOTSTRAP.md`, completion output에 no-git 안내가 생성됐다.
- profile-specific prompt/rule 추가와 git bootstrap 안내가 충돌하지 않는다.

#### Follow-up correction

- generated `docs/BOOTSTRAP.md` 문구에 double quote가 들어가면 `scripts/create-harness.sh`의 heredoc-like string 인자에서 문장이 잘릴 수 있음을 확인했다.
- `not a git repository` 안내는 quote 없이 생성되도록 수정했고, generic/spring-boot r3 scaffold에서 전체 문장이 정상 생성되는 것을 재확인했다.
- `docs/WORKFLOW-MANUAL.md`의 Work archive 절차와 T10 trigger 설명에도 no-git 상태에서는 plain `mv` 또는 archive 보류를 제안하도록 정렬했다.
