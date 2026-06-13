---
policy_type: source-gitflow
---

# GIT-WORKFLOW.md

이 프로젝트의 Git 브랜치 전략, 일상 작업 사이클, CI 연동 방식을 정의한다.

> **현재 채택 전략: Gitflow** (feature → develop → main)
> 전략 변경 시 §1~§3 전체 재검토 필요

## 0. Branch Isolation Rule

`develop`과 `main`은 직접 수정하지 않는다. 모든 실질 작업은 `feature/*` 또는 `hotfix/*` branch에서 수행한다.

### Protected Files

아래 파일을 `develop` 또는 `main`에서 직접 staged하거나 commit하지 않는다.

| 범주 | 경로 |
|---|---|
| Workflow/status tracking | `docs/STATUS.md`, `docs/backlog/**`, `docs/works/**`, `docs/decisions/**` |
| AI entrypoint | `AGENTS.md`, `CLAUDE.md` |
| Canonical workflow | `docs/AGENT-WORKFLOW.md`, `docs/HARNESS-PROTOCOL.md`, `docs/HARNESS-QUICK-REFERENCE.md`, `docs/GIT-WORKFLOW.md` |
| Tool surface | `.claude/commands/*.md`, `.claude/rules/*.md`, `.cursor/rules/*.mdc`, `.agents/skills/**`, `prompts/**` |
| Enforcement | `tools/git-hooks/**` |

> 이 표는 `tools/git-hooks/lib/gate-lists.sh`의 `awh_is_branch_isolation_protected_path` 기본 목록을 가리킨다. 이 repo 고유 경로는 framework-owned `gate-lists.sh`를 편집하지 말고(upgrade 시 overwrite) add-only `.harness/gate-config`의 `[protected]` 또는 `[tracking-state]`에 추가한다. `[tracking-state]`는 project-specific 경로를 `T1 tracking-state-only` 예외로 분류할 때만 사용한다.

### Allowed Exceptions

| 예외 유형 | 조건 |
|---|---|
| Release sync | merge commit 한정 (`.git/MERGE_HEAD` 존재). `git merge origin/main` 같은 자동 merge — 파일 직접 편집 아님 |
| Emergency hotfix | `hotfix/*` branch에서 수행. `main` 직접 수정 금지 |
| Read-only validation | staged 없음. inspection/rg/diff만 수행 |

### Branch Types

| 작업 유형 | Branch |
|---|---|
| 일반 작업 (기능·문서·rule·tracking 포함) | `feature/*` |
| Release gate 전 보정 (`docs/STATUS.md` 포함) | `feature/release-prep-{YYYYMMDD}` |
| 긴급 수정 (main 기준) | `hotfix/*` |

Violation: AI tool은 `develop` 또는 `main`에서 protected files가 staged된 경우 FAIL로 전환하고 적절한 branch 생성을 제안한다.

## 0-1. Environment Bootstrap

`--workflow source-gitflow`로 scaffold된 repo는 source-style branch/ruleset/hook 정책을 선택한 상태다.
단, scaffold 직후 git repository와 GitHub ruleset이 자동으로 만들어지지는 않는다.

### Fresh repo

git repository가 아직 없을 때만 아래 순서를 사용한다.

```bash
git init
git checkout -b main
git add .
git commit -m "chore: scaffold AI workflow harness"
git checkout -b develop
sh tools/git-hooks/install.sh
```

remote repository를 만든 뒤:

```bash
git remote add origin <git-url>
git push -u origin main
git push -u origin develop
```

### Existing repo

이미 git repository가 있으면 `git init` 또는 branch 재작성 명령을 실행하지 않는다.
먼저 현재 branch, remote, protected branch 운영 정책을 확인한다.

```bash
git status --short --branch
git remote -v
git branch --list main develop
```

- `main`/`develop`이 이미 있으면 기존 history와 remote 정책을 보존한다.
- `develop`이 없으면 생성 여부를 사용자와 결정한 뒤 `main`에서 분기한다.
- 기존 default branch가 `main`이 아니면 rename 여부를 별도 decision으로 다룬다.
- hook 설치는 git repository가 확인된 뒤 실행한다: `sh tools/git-hooks/install.sh`.

### Clone from existing remote

이미 remote repository가 있고 두 번째 contributor로 참여하는 경우에 사용하는 경로다.

```bash
git clone <git-url>
cd <repo-name>
sh tools/git-hooks/install.sh
```

- `tools/git-hooks/install.sh`는 pre-commit·commit-msg hook을 `.git/hooks/`에 설치한다.
- 설치하지 않으면 commit message 형식 강제가 동작하지 않는다.
- branch/release 정책과 PR 절차는 §1·§2를 확인한다.

### GitHub Ruleset

GitHub ruleset 적용은 repo 존재, branch 존재, `gh` auth, admin 권한에 의존한다.
따라서 scaffold가 자동 적용하지 않는다. Repository maintainer가 확인 후 GitHub UI 또는 `gh api`로 적용한다.

- `protect-main`: deletion, non-fast-forward, PR required, required status check context `harness-validate`.
- `protect-develop`: deletion, non-fast-forward, PR required. Required status check는 연결하지 않는다.

`harness-validate` workflow는 path filter 없이 항상 실행되어 required check가 `Expected`/pending 상태에 머무는 것을 방지한다.

## 1. Branch Strategy

```
main
 └── develop
      └── feature/*
```

| 브랜치 | 역할 | 직접 push |
|---|---|---|
| `main` | 배포 가능한 안정 브랜치. PR을 통해서만 업데이트 | 금지 |
| `develop` | 통합 브랜치. feature가 여기로 PR됨 | 금지 |
| `feature/*` | 작업 단위 브랜치. `develop` 기준으로 생성 | 허용 |

### Branch Naming

| 패턴 | 용도 |
|---|---|
| `feature/{work-id}-{slug}` | 신규 Work (FEAT/PATCH/CHORE). Work ID + slug 권장 (예: `feature/chore-20260527-001-id-tracker-rule`) |
| `feature/prod-{topic}` | product 작업 단축 패턴 (예: `feature/prod-auth`) |
| `feature/release-prep-{YYYYMMDD}` | develop→main PR 전 release-prep 보정 (예: `feature/release-prep-20260528`) |
| `hotfix/{topic}` | main 긴급 수정 — Work ID `HOTFIX-YYYYMMDD-NNN` (develop 우회, main → PR → main) |

Work ID(`<TYPE>-<YYYYMMDD>-<NNN>`)와 branch name은 1:1 강제하지 않는다. Work ID를 branch 생성 전에 확정할 수 없는 경우 slug만 사용해도 된다. Work ID 형식 상세는 `docs/HARNESS-NAMING-RULES.md`를 따른다.

> **대소문자 규칙**: Work ID는 uppercase (`CHORE-20260527-001`), branch segment는 lowercase normalized (`chore-20260527-001`). 예: Work ID `CHORE-20260527-001` → branch `feature/chore-20260527-001-id-tracker-rule`.

## 2. Feature Development Cycle

### 2-1. Feature Branch Creation

```bash
git checkout develop
git pull origin develop
git checkout -b feature/{name}
```

### 2-2. Work And Commit

커밋 전 체크 순서 (`.claude/rules/git-workflow.md` 참조):

```bash
git status                  # 전체 워킹트리 확인
git add <files>             # 의도한 파일만 스테이지
git status                  # 누락 없는지 재확인
git diff --cached           # 스테이지 내용 리뷰
git commit -m "..."
```

커밋 메시지 형식은 [Commit Message Format](#5-commit-message-format) 참조.

### 2-3. Sync With Develop

feature 작업 중 다른 작업이 `develop`에 먼저 병합될 수 있다. **commit·push·PR 직전에 최신 `develop`을 feature 브랜치로 끌어와 미리 반영하는 것을 기본 습관으로 둔다.** 사소해 보이지만 누락하기 쉽고, 누락하면 PR 단계에서 충돌·stale 검증으로 되돌아온다.

```bash
git fetch origin
git checkout feature/{name}
git merge origin/develop        # 최신 develop을 feature에 반영
```

**언제 sync하나:**

- PR을 열기 직전 (특히 오래 작업한 브랜치).
- `develop`이 내 변경과 겹치는 파일을 건드린 정황이 보일 때.
- 최신 `develop` 기준으로 로컬 검증이나 CI를 돌리고 싶을 때.

**merge vs rebase:**

- **기본은 `git merge origin/develop`이다.** 이 repo는 feature→develop을 **squash merge**(§2-4, DR-017 Amended)하므로 feature 내부 history는 단일 커밋으로 합쳐진다. rebase로 linear history를 만들어도 그 이점이 결과에 남지 않으므로, 이미 push된 브랜치를 rebase해 force-push하는 비용을 치를 이유가 없다.
- rebase는 **아직 push하지 않은 로컬 전용 커밋**을 정리할 때만 선택한다: `git rebase origin/develop`.

**충돌 발생 시:**

- 충돌은 GitHub PR 화면이 아니라 **로컬 sync 단계에서 먼저 해소**한다. `git status`로 충돌 파일 확인 → 수정 → `git add` → `git merge --continue` (rebase면 `git rebase --continue`).
- PR 생성 후 base가 다시 앞서 나가 충돌이 나면 같은 방식으로 feature에서 재-sync한 뒤 push한다.

**force-push 정책:**

- `--force-with-lease`는 **본인이 단독 작업하는 feature 브랜치에 한해서만** 허용한다 (`--force`는 사용하지 않는다).
- `develop`·`main`에는 어떤 경우에도 force-push하지 않는다.

> 병렬 feature/agent 간 충돌(Work ID·STATUS·index 동시 변경) 통제가 필요하면 project-specific 병렬 작업 정책을 따른다.

### 2-4. PR Creation (feature → develop)

> **feature PR의 base는 항상 `develop`이다. `main`으로 직접 PR하지 않는다.**
> **feature 브랜치를 develop에 직접 local merge하지 않는다. 반드시 PR을 통해 머지한다.**

```bash
gh pr create --base develop --title "..." --body "..."
```

또는 GitHub UI에서 base를 `develop`으로 설정하여 PR 생성.
`gh pr create` 기본 base는 저장소 default branch(`main`)이므로 `--base develop`을 반드시 명시한다.

**머지 전략:**
- Squash merge 기본 — develop 히스토리를 기능 단위 단일 커밋으로 간결하게 유지한다. work-close 단일 커밋 패턴과 일치한다. (DR-017 Amended)
- Regular merge 예외 — 커밋 단위 이력을 반드시 보존해야 할 경우에만 선택한다.

**검증 책임:**
- PR 전에는 변경 범위에 맞는 로컬 검증 결과(`git diff --check` 등)를 PR 본문이나 세션 요약에 남긴다.

### 2-5. Post-PR Cleanup

feature → develop PR merge 후, 방금 merge된 최신 develop을 로컬에 반영한다.

```bash
# feature PR merge 결과를 develop에 동기화
git checkout develop
git pull origin develop

# feature 브랜치 삭제 (로컬)
git branch -d feature/{name}

# 리모트 브랜치 삭제
git push origin --delete feature/{name}
```

> `gh pr merge --delete-branch` 사용 시 로컬·리모트 feature 브랜치 삭제가 자동 처리된다.

마지막으로 다음 feature 브랜치명을 제안하고 생성 여부를 확인한다.

## 3. Release Cycle (Develop → Main)

> 이 release cycle과 Public Clean Baseline Gate는 이 프로젝트의 기본 정책이다.
> project-specific 요구사항에 따라 gate 항목을 조정할 수 있다.
> 버전·릴리즈 표식(VERSION·tag·릴리즈 노트) 정책은 프로젝트가 자체 수립한다.

`main`은 일반 통합 브랜치가 아니라 **release snapshot**이다.
feature를 develop에 병합했다고 곧바로 main PR을 열지 않는다.
의미 있는 패치(하나 또는 여러 feature 묶음)가 완료되어 release 준비가 됐을 때만 develop → main PR을 만든다.

**머지 방식:** Regular Merge (Merge commit) 원칙 — develop 브랜치의 커밋 히스토리와 feature 단위 커밋을 main에 보존한다. Fast-Forward가 가능하면 허용한다. (DR-017 Amended)

### 3-0. Release Prep Branch

develop → main PR을 열기 전에 짧은 release-prep branch에서 release gate를 먼저 실측한다.
이 branch는 새 기능을 추가하는 곳이 아니라, release-block 보정과 evidence 수집을 위한 작업 단위다.

```bash
git checkout develop
git pull origin develop
git checkout -b feature/release-prep-{YYYYMMDD}
```

**Release-prep에서 수행할 일:**

1. project-specific version/tag/release-note 정책이 있으면 현재 `main`, `develop`, 최신 release tag, version file의 관계를 확인한다.
2. 이미 존재하는 release tag와 같은 version으로 새 release를 만들 수 없으면 project-specific semver 기준에 따라 version을 목표 값으로 올린다.
3. `docs/STATUS.md`와 `docs/PLAN.md`의 release target 문구가 목표 release와 맞는지 확인하고, 필요한 최소 보정만 반영한다.
4. §3-1 Public Clean Baseline Gate를 실제 명령으로 확인한다.
5. project-specific release validation을 수행한다. 최소 evidence는 `git diff --check`, scaffold/onboarding 경로 확인, 필요한 build/test 명령을 포함한다.
6. 발견된 release-block만 수정한다. 예: archive Work의 `status` 불일치, stale release target, version/tag mismatch, onboarding 경로 stale.
7. release-prep 변경은 feature → develop PR로 먼저 병합한다. 그 다음에 develop → main release PR을 연다.

### 3-1. Public Clean Baseline Gate

develop → main PR 생성 전 아래 항목을 모두 확인한다.
확인 결과는 **PR body에 반드시 남긴다.**

| Area | Clean Condition | Evidence |
| --- | --- | --- |
| Working tree | develop working tree가 clean | `git status --short --branch` |
| STATUS Active Work | `docs/STATUS.md` Active Work 비어 있음 | file inspection |
| STATUS Blockers/OQ | Open Blocker/OQ 없음. 남길 경우 외부/이해관계자에게 노출돼도 되는 이유 기록 | file inspection |
| STATUS Next Actions | 비어 있거나 외부에 노출돼도 되는 항목만 존재 | file inspection |
| Work lifecycle | `docs/works/*/*.md`에 `status: Done` archive pending 없음 | `rg -n "^status: Done" docs/works` |
| Work active leakage | release 대상에 internal Active Work가 남지 않음 | `rg -n "^status: Active" docs/works` |
| Archive state | `docs/archive/docs/works/**` 아래 Work는 모두 `status: Archived` | `rg -n "^status:" docs/archive/docs/works` |
| `/session-start` output | 첫 `/session-start`가 clean idle 또는 의도한 상태로 시뮬레이션됨 | STATUS 기준 문서 시뮬레이션 |
| Docs cascade | release gate 관련 문서 변경 시 canonical/tool/user-facing cascade 정렬 확인 | targeted cascade check |
| Validation | `git diff --check` 통과 | `git diff --check` |

### 3-2. Main Merge Gate

아래 조건을 모두 만족할 때만 develop → main PR을 생성한다.

- feature 작업은 먼저 feature → develop PR로 병합되어 있어야 한다.
- Public Clean Baseline Gate를 모두 통과해야 한다.
- Gate 결과를 PR body에 남긴다.
- main PR은 `develop` → `main` 방향만 허용한다.

**main PR 금지 조건:**

- Active Work가 남아 있는 상태
- Done archive pending Work가 남아 있는 상태
- Open Blocker/OQ가 외부/이해관계자에게 혼란을 줄 수 있는 상태
- README 또는 onboarding 경로가 stale한 상태
- feature branch에서 직접 main으로 PR을 여는 경우

### 3-3. PR Creation (Develop → Main)

```bash
gh pr create --base main --head develop --title "release: ..."
```

release PR body 또는 release note 초안은 project-specific release note 정책을 따른다. 정책이 없으면 이번 release의 impact, validation evidence, breaking/change notes를 PR body에 명시한다.

### 3-4. Post-Merge Develop Sync

PR merge 후:

```bash
git checkout main
git pull origin main
git status                  # "up to date with 'origin/main'" 확인

git checkout develop
git merge origin/main       # develop을 main과 동기화
git push origin develop
git status                  # "up to date with 'origin/develop'" 확인

# sync 결과 검증 (절차 수행이 아니라 결과 정합 확인 — git status 보강)
git log origin/develop..origin/main --oneline   # 비어 있어야 develop이 main과 완전 sync
```

### 3-5. Hotfix Cycle

`main`의 긴급 결함은 `develop`을 거치지 않고 `main` 기준 `hotfix/*` 브랜치에서 수정한다 (§1 Branch Naming).

```bash
git checkout main
git pull origin main
git checkout -b hotfix/{topic}
# 수정 + commit
gh pr create --base main --head hotfix/{topic} --title "fix: ..."
```

- hotfix PR의 base는 `main`이다. feature와 달리 `develop`을 경유하지 않는다.
- Work ID는 `HOTFIX-YYYYMMDD-NNN`을 사용한다.

**main 병합 후 develop 역병합 (필수):** hotfix가 `main`에만 반영되면 다음 release에서 `develop`이 `main`을 덮어써 수정이 유실된다. main 병합 직후 반드시 `develop`으로 역병합한다.

```bash
git checkout main
git pull origin main
git checkout develop
git merge origin/main        # hotfix를 develop에 반영
git push origin develop
```

> 이는 §3-4 Post-Merge Develop Sync와 동일한 main→develop 동기화다. release든 hotfix든 `main`이 앞서면 `develop`을 즉시 맞춘다.

## 4. CI Trigger

이 repo는 source-gitflow mode로 scaffold되어 harness validation workflow를 포함한다.

| 파일 | 역할 |
|---|---|
| `.github/workflows/harness-validate.yml` | harness-owned validation. GitHub ruleset required check에 연결할 check-run name은 `harness-validate`다. |

`harness-validate.yml`의 job key는 `harness-validate`이며 job-level `name:`을 설정하지 않는다.
GitHub ruleset의 `required_status_checks`는 job key가 아니라 보고되는 check-run name과 매칭되므로,
branch ruleset을 설정할 때 required check context는 `harness-validate`로 연결한다.
Required check는 `protect-main`에만 연결한다. `protect-develop`에는 required status check를 연결하지 않는다.

CI trigger는 project-specific product CI와 공존할 수 있다. Product test/build workflow는 별도 파일로 추가한다.
`harness-validate.yml`은 workflow-level path filter 없이 실행된다. Required check로 연결되는 workflow에
path filter가 있으면 filter 미일치 PR에서 check가 `Expected`/pending 상태로 남을 수 있기 때문이다.

| 이벤트 | 조건 | 실행 Job |
|---|---|---|
| `push` to `main` | 항상 | Harness Validate |
| `pull_request` targeting `main` 또는 `develop` | 항상 | Harness Validate |

> Product CI가 필요하면 `.github/workflows/product-ci.yml` 같은 별도 workflow로 추가한다.

## 5. Commit Message Format

Conventional Commits 형식을 따르며, DR-007 Bilingual Rules를 적용한다.

```
<type>: <subject>

<body>
```

**Type prefix** (항상 영문): `feat`, `fix`, `docs`, `chore`, `refactor`, `test`, `style`, `ci`, `config`, `perf`, `build`, `revert`

**Subject line**: 한국어 주체, 기술 용어·식별자는 영문 유지. Type prefix는 영문이지만, subject 문장은 한국어 독자가 먼저 이해할 수 있게 쓴다.

```
docs: GIT-WORKFLOW.md에 Gitflow 브랜치 전략과 CI 연동 기준 추가
fix: TokenRedisRepository의 SCAN 기반 invalidation 제거
```

**Body**: 한국어 주체, *why* 중심으로 작성. Subject와 빈 줄로 구분.

상세 규칙: `docs/decisions/DR-007-language-policy.md`

## 6. Git Hooks

이 repository는 `--workflow source-gitflow`로 scaffold되어 gate hook이 `tools/git-hooks/`에 함께 포함된다(generic workflow scaffold에는 포함되지 않는다).

- `pre-commit`: diff hygiene, `develop`·`main` branch isolation, shell syntax, finalization advisory.
- `commit-msg`: Conventional Commits 형식 검증 + DR-025 finalization bundling gate(override trailer 지원).
- `lib/gate-lists.sh`: protected paths와 finalization bundling targets, override trailer token의 단일 정의.

### 설치

git repository 초기화 후 한 번 실행한다:

```sh
sh tools/git-hooks/install.sh
```

### 이 repo에 맞게 조정

`tools/git-hooks/lib/gate-lists.sh`의 `awh_is_branch_isolation_protected_path`와 `awh_is_finalization_file` 목록은 harness 기본값이며 framework-owned다(upgrade 시 overwrite). 이 repo 고유의 민감 경로(예: 배포 설정, secret 경로)는 `gate-lists.sh`를 편집하지 말고 add-only `.harness/gate-config`의 `[protected]`/`[tracking-state]`/`[finalization]`에 추가한다 — upgrade-safe하며, hook이 기본 목록과 `.harness/gate-config`를 합쳐 읽는다. `[tracking-state]`는 project-specific 경로를 `T1 tracking-state-only` 예외로 분류할 때만 사용한다.

## 7. Related Documents

- `.claude/rules/git-workflow.md` — Claude Code용 커밋 gate 규칙
- `docs/decisions/DR-007-language-policy.md` — Bilingual Rules
