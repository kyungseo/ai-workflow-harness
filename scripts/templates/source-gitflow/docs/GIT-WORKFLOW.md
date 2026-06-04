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
| `feature/p{n}-{topic}` | Phase{n} product 작업 단축 패턴 (예: `feature/p2-auth`) |
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
- Regular merge 기본 — feature 브랜치의 커밋 히스토리를 보존한다.
- WIP 커밋이 많아 히스토리가 지저분할 때만 Squash merge를 선택한다.

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

**머지 방식:** 항상 Regular merge (Merge commit) — develop 브랜치의 커밋 히스토리와 feature 단위 커밋을 main에 보존한다.

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
| `/start` output | public clone 첫 `/start`가 clean idle 또는 의도한 상태로 시뮬레이션됨 | STATUS 기준 문서 시뮬레이션 |
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

CI 설정은 project-specific이다. 아래는 참고 패턴이다.

| 이벤트 | 조건 | 실행 Job |
|---|---|---|
| `push` to `main` | docs/prompts/tool surface 변경 시 | Docs Validation |
| `pull_request` targeting `main` 또는 `develop` | docs/prompts/tool surface 변경 시 | Docs Validation |

**Path filter 대상 (예시):** `docs/**`, `prompts/**`, `.claude/**`, `.cursor/**`, `AGENTS.md`, `CLAUDE.md`, `README.md`

> CI 상세 설정은 프로젝트 CI 파일을 참조한다.

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

## 6. Git Hooks (Optional)

hook은 자동 설치하지 않으며, 필요하면 project-specific hook으로 별도 정의한다.
source harness repo의 `tools/git-hooks/`를 그대로 복사하지 않는다 — protected file 목록과 validation scope가 source-specific이므로 이 project의 경로·규칙에 맞게 직접 작성한다.

**branch isolation 강제가 필요한 경우 — pre-commit hook 참고 패턴:**

`develop`·`main`에 workflow 파일을 직접 commit하는 것을 차단하려면 아래 패턴을 project-specific protected paths에 맞게 조정한다.

```sh
#!/usr/bin/env sh
BRANCH=$(git branch --show-current 2>/dev/null || echo "")
[ -f ".git/MERGE_HEAD" ] && exit 0   # merge commit 면제
if [ "$BRANCH" = "develop" ] || [ "$BRANCH" = "main" ]; then
    STAGED=$(git diff --cached --name-only --diff-filter=ACMR)
    # project 경로에 맞게 수정
    PROTECTED=$(echo "$STAGED" | grep -E \
        "^(AGENTS\.md|CLAUDE\.md|docs/STATUS\.md|docs/backlog/|docs/works/|\.claude/|\.cursor/)")
    if [ -n "$PROTECTED" ]; then
        echo "ERROR: feature/* branch에서 commit해야 합니다."
        echo "$PROTECTED"
        exit 1
    fi
fi
git diff --cached --check
```

**commit message 형식 검증이 필요한 경우 — commit-msg hook:**

§5 Commit Message Format의 type 목록을 기준으로 commit-msg hook을 작성한다. harness source repo의 `tools/git-hooks/commit-msg`를 참고할 수 있다.

## 7. Related Documents

- `.claude/rules/git-workflow.md` — Claude Code용 커밋 gate 규칙
- `docs/decisions/DR-007-language-policy.md` — Bilingual Rules
