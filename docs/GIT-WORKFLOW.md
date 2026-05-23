# GIT-WORKFLOW.md

이 프로젝트의 Git 브랜치 전략, 일상 작업 사이클, CI 연동 방식을 정의한다.

> **현재 채택 전략: Gitflow** (feature → develop → main)
> 전략 변경 검토 중: `docs/backlog/HARNESS.md` HRN-FUT-004 참조
> 전략 변경 시 §1~§3 전체 재검토 필요

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
| `feature/p{n}-{topic}` | Phase{n} product 작업 (예: `feature/p2-auth`) |
| `feature/p{n}-pre{nn}` | Phase{n} pre-entry 묶음 작업 (예: `feature/p2-pre01`) |
| `feature/hrn-{id}` | Harness 개선 작업 (예: `feature/hrn-009`) |
| `hotfix/{topic}` | main 긴급 수정 (develop 우회, main → PR → main) |

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
- feature→develop PR은 `.github/workflows/ci.yml` path filter에 걸리는 문서, prompt, rule, scaffold 변경에서 GitHub Actions CI를 실행한다.
- PR 전에는 변경 범위에 맞는 로컬 검증 결과(`git diff --check`, `bash -n scripts/create-harness.sh`, scaffold dry-run 등)를 PR 본문이나 세션 요약에 남긴다.
- develop→main PR에서도 동일한 docs/scaffold CI를 최종 확인한다.

### 2-4. Post-PR Cleanup

PR merge 후:

```bash
# develop 동기화
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

Phase 또는 마일스톤 단위로 develop을 main에 병합한다.

```bash
# GitHub UI 또는 CLI로 develop → main PR 생성
gh pr create --base main --head develop --title "release: ..."
```

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

## 6. Pre-commit Hook

`tools/git-hooks/pre-commit`이 자동으로 실행된다.

| staged 파일 | 동작 |
|---|---|
| 전체 staged diff | `git diff --cached --check` |
| `scripts/*.sh`, `scripts/*/*.sh`, `tools/git-hooks/*` | `sh -n` shell syntax check |
| `scripts/create-harness.sh` | `bash -n scripts/create-harness.sh` |

hook 설치:

```bash
bash tools/git-hooks/install.sh
```

## 7. Related Documents

- `.claude/rules/git-workflow.md` — Claude Code용 커밋 gate 규칙
- `docs/decisions/DR-007-language-policy.md` — Bilingual Rules
- `.github/workflows/ci.yml` — CI 상세 설정
- `docs/HARNESS-MAINTAINER-GUIDE.md` — 로컬 환경 설정 및 유지보수 절차
