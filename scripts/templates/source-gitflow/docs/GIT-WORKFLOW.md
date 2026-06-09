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

> 이 표는 `tools/git-hooks/lib/gate-lists.sh`의 `awh_is_branch_isolation_protected_path`와 동일한 목록을 가리킨다. 이 repo 고유 경로를 추가하려면 두 곳을 함께 갱신한다.

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

### 2-3. PR Creation (feature → develop)

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

### 2-4. Post-PR Cleanup

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

`main`은 일반 통합 브랜치가 아니라 **public release snapshot**이다.
feature를 develop에 병합했다고 곧바로 main PR을 열지 않는다.
의미 있는 패치(하나 또는 여러 feature 묶음)가 완료되어 release 준비가 됐을 때만 develop → main PR을 만든다.

**머지 방식:** Regular Merge (Merge commit) 원칙 — develop 브랜치의 커밋 히스토리와 feature 단위 커밋을 main에 보존한다. Fast-Forward가 가능하면 허용한다. (DR-017 Amended)

### 3-1. Public Clean Baseline Gate

develop → main PR 생성 전 아래 항목을 모두 확인한다.
확인 결과는 **PR body에 반드시 남긴다.**

| Area | Clean Condition | Evidence |
| --- | --- | --- |
| Working tree | develop working tree가 clean | `git status --short --branch` |
| STATUS Active Work | `docs/STATUS.md` Active Work 비어 있음 | file inspection |
| STATUS Blockers/OQ | Open Blocker/OQ 없음. 남길 경우 public 사용자에게 보여도 되는 이유 기록 | file inspection |
| STATUS Next Actions | 비어 있거나 public 사용자가 따라도 되는 항목만 존재 | file inspection |
| Work lifecycle | `docs/works/*/*.md`에 `status: Done` archive pending 없음 | `rg -n "^status: Done" docs/works` |
| Work active leakage | release 대상에 internal Active Work가 남지 않음 | `rg -n "^status: Active" docs/works` |
| Archive state | `docs/archive/docs/works/**` 아래 Work는 모두 `status: Archived` | `rg -n "^status:" docs/archive/docs/works` |
| `/session-start` output | public clone 첫 `/session-start`가 clean idle 또는 의도한 상태로 시뮬레이션됨 | STATUS 기준 문서 시뮬레이션 |
| Adoption path | README → onboarding 흐름 정합 | link/path inspection |
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
- Open Blocker/OQ가 public 사용자에게 혼란을 줄 수 있는 상태
- README 또는 onboarding 경로가 stale한 상태
- feature branch에서 직접 main으로 PR을 여는 경우

### 3-3. PR Creation (Develop → Main)

```bash
gh pr create --base main --head develop --title "release: ..."
```

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
```

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

**Subject line**: 한국어 주체, 기술 용어·식별자는 영문 유지

```
docs: GIT-WORKFLOW.md 생성 — Gitflow 브랜치 전략 및 CI 연동 정의
fix: TokenRedisRepository SCAN 기반 invalidation 제거
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

`tools/git-hooks/lib/gate-lists.sh`의 `awh_is_branch_isolation_protected_path`와 `awh_is_finalization_file` 목록은 harness 기본값에서 시작한다. 이 repo 고유의 민감 경로(예: 배포 설정, secret 경로)는 해당 함수의 `case` 패턴에 추가한다. hook 로직 자체를 수정할 필요 없이 목록만 확장하면 된다.

## 7. Related Documents

- `.claude/rules/git-workflow.md` — Claude Code용 커밋 gate 규칙
- `docs/decisions/DR-007-language-policy.md` — Bilingual Rules
