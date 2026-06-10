---
policy_type: source-gitflow
---

# GIT-WORKFLOW.md

이 프로젝트의 Git 브랜치 전략, 일상 작업 사이클, CI 연동 방식을 정의한다.

> **채택 전략: Gitflow** (feature → develop → main) — 이 repo는 확정. scaffold 적용 repo는 자체 결정.
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
| Scaffold | `scripts/create-harness.sh` |
| Enforcement | `tools/git-hooks/**` |

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

> 병렬 feature/agent 간 충돌(Work ID·STATUS·index 동시 변경)은 `docs/HARNESS-PARALLEL-WORK-CONTROLS.md`를 따른다.

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
- feature→develop PR은 `.github/workflows/ci.yml` path filter에 걸리는 문서, prompt, rule, scaffold 변경에서 GitHub Actions CI를 실행한다.
- PR 전에는 변경 범위에 맞는 로컬 검증 결과(`git diff --check`, `bash -n scripts/create-harness.sh`, scaffold dry-run 등)를 PR 본문이나 세션 요약에 남긴다.
- develop→main PR에서도 동일한 docs/scaffold CI를 최종 확인한다.

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

> 이 release cycle과 Public Clean Baseline Gate는 `ai-workflow-harness` source repo의 기본 정책이다.
> scaffold product repo에서는 project-specific `docs/GIT-WORKFLOW.md` 또는 선택한 workflow mode에 따라 적용 여부를 결정한다.
> source-style workflow profile을 opt-in한 repo에서는 동일 gate를 적용한다.

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
| Adoption path | README → `docs/SCAFFOLD-ONBOARDING-GUIDE.md` → scaffold bootstrap 흐름 정합 | link/path inspection |
| Scaffold | `bash -n scripts/create-harness.sh` + `--dry-run` 통과. 실제 temp scaffold 생성은 scaffold 파일 변경 시에만 | `bash -n scripts/create-harness.sh`, `scripts/create-harness.sh --dry-run ...` |
| Docs cascade | release gate 관련 문서 변경 시 canonical/tool/user-facing/scaffold cascade 정렬 확인 | targeted cascade check |
| Validation | `git diff --check` 통과 | `git diff --check` |

### 3-2. Main Merge Gate

> 적용 범위는 §3 Release Cycle note를 따른다. 일반 scaffold product repo에는 기본 강제하지 않는다.

아래 조건을 모두 만족할 때만 develop → main PR을 생성한다.

- feature 작업은 먼저 feature → develop PR로 병합되어 있어야 한다.
- Public Clean Baseline Gate를 모두 통과해야 한다.
- Gate 결과를 PR body에 남긴다.
- main PR은 `develop` → `main` 방향만 허용한다.

**main PR 금지 조건:**

- Active Work가 남아 있는 상태
- Done archive pending Work가 남아 있는 상태
- Open Blocker/OQ가 public 사용자에게 혼란을 줄 수 있는 상태
- README 또는 onboarding/scaffold 경로가 stale한 상태
- feature branch에서 직접 main으로 PR을 여는 경우

### 3-3. PR Creation (Develop → Main)

```bash
gh pr create --base main --head develop --title "release: ..."
```

> **Release marking (source repo 한정):** `VERSION` bump(semver 판정)과 머지 후 tag(`ai-workflow-v{VERSION}`)·GitHub 릴리즈 노트 절차는 `docs/maintainer/VERSIONING.md` §3(Bump 절차)·§5(릴리즈 노트 템플릿)를 따른다. **GitHub Release 객체 생성은 선택이며, tag·`VERSION` 정합은 필수다.** (scaffold 적용 repo는 자체 버전 정책. 이 포인터 대상 `VERSIONING.md`는 source 전용이라 scaffold 템플릿에는 포함하지 않는다.)

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

| 이벤트 | 조건 | 실행 Job |
|---|---|---|
| `push` to `main` | docs/prompts/tool surface/scaffold/root entrypoint 변경 시 | Docs and Scaffold Validation |
| `pull_request` targeting `main` 또는 `develop` | docs/prompts/tool surface/scaffold/root entrypoint 변경 시 | Docs and Scaffold Validation |

**Path filter 대상:** `docs/**`, `prompts/**`, `.claude/**`, `.cursor/**`, `scripts/**`, `.github/workflows/**`, `AGENTS.md`, `CLAUDE.md`, `README.md`

> develop push는 CI 트리거 없음. PR과 main push에서 docs/scaffold validation을 수행한다.
> application runtime이 없으므로 Java/Gradle lint/test는 기본 CI 대상이 아니다.

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

> **배포 경계.** `tools/git-hooks/`의 hook은 `ai-workflow-harness` source repo에서 설치·운영한다. scaffold된 product repo에는 기본(generic workflow) 포함되지 않으나, `--workflow source-gitflow`로 scaffold하면 opt-in으로 함께 배포된다 — `docs/HARNESS-MAINTAINER-GUIDE.md` §10 참조.

### pre-commit

commit 전 자동 실행.

| staged 파일 | 동작 |
|---|---|
| 전체 staged diff | `git diff --cached --check` |
| `main`에 protected workflow 파일 staged | hard block (exit 1) — `feature/*` 또는 `hotfix/*` branch로 이동 필요 |
| `develop`에 protected workflow 파일 staged | warning only — GitHub ruleset이 실질 강제. feature branch 사용 권장 |
| `scripts/*.sh`, `scripts/*/*.sh`, `tools/git-hooks/*` | `sh -n` shell syntax check |
| `scripts/create-harness.sh` | `bash -n scripts/create-harness.sh` |

merge commit (`.git/MERGE_HEAD` 존재) 시 branch isolation check 면제.

### commit-msg

commit message 형식 검증. Conventional Commits 미준수 시 hard block (exit 1).

유효 type: `feat` `fix` `docs` `style` `refactor` `chore` `config` `test` `perf` `ci` `build` `revert`

### hook 설치

```bash
bash tools/git-hooks/install.sh
```

### Enforcement 설계 원칙

branch isolation은 세 계층으로 구성된다. 각 계층이 독립적으로 작동하므로 하나가 누락돼도 나머지가 보완한다.

| Layer | 수단 | 역할 |
|---|---|---|
| 1 | AI rule (`.claude/rules/git-workflow.md`) | 즉각 FAIL 선언 — commit 시도 전에 feature branch 생성을 안내한다 |
| 2 | pre-commit hook | 로컬 안전망 — AI가 규칙을 놓쳤을 때 commit 단계에서 포착한다 |
| 3 | GitHub ruleset (`protect-develop`, `protect-main`) | 실질 강제 — push/PR 없이는 어떤 commit도 remote에 반영되지 않는다 |

`main`은 공개 릴리즈 스냅샷이므로 layer 2에서 hard block. `develop`은 GitHub ruleset(layer 3)이 실질 강제를 담당하므로 layer 2는 warning으로 충분하다. solo 프로젝트에서 housekeeping 작업마다 PR을 강제하는 것은 불필요한 마찰이다.

## 7. Related Documents

- `.claude/rules/git-workflow.md` — Claude Code용 커밋 gate 규칙
- `docs/decisions/DR-007-language-policy.md` — Bilingual Rules
- `.github/workflows/ci.yml` — CI 상세 설정
- `docs/HARNESS-MAINTAINER-GUIDE.md` — 로컬 환경 설정 및 유지보수 절차
