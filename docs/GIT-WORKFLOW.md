# GIT-WORKFLOW.md

이 프로젝트의 Git 브랜치 전략, 일상 작업 사이클, CI 연동 방식을 정의한다.

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

### 브랜치 Naming

| 패턴 | 용도 |
|---|---|
| `feature/p{n}-{topic}` | Phase{n} product 작업 (예: `feature/p2-auth`) |
| `feature/p{n}-pre{nn}` | Phase{n} pre-entry 묶음 작업 (예: `feature/p2-pre01`) |
| `feature/hrn-{id}` | Harness 개선 작업 (예: `feature/hrn-009`) |
| `hotfix/{topic}` | main 긴급 수정 (develop 우회, main → PR → main) |

## 2. 일상 작업 사이클 (Feature 개발)

### 2-1. Feature 브랜치 생성

```bash
git checkout develop
git pull origin develop
git checkout -b feature/{name}
```

### 2-2. 작업 → 커밋

커밋 전 체크 순서 (`.claude/rules/git-workflow.md` 참조):

```bash
git status                  # 전체 워킹트리 확인
git add <files>             # 의도한 파일만 스테이지
git status                  # 누락 없는지 재확인
git diff --cached           # 스테이지 내용 리뷰
git commit -m "..."
```

커밋 메시지 형식은 [Commit Message Format](#5-commit-message-format) 참조.

### 2-3. PR 생성 (feature → develop)

```bash
gh pr create --base develop --title "..." --body "..."
```

또는 GitHub UI에서 base를 `develop`으로 설정하여 PR 생성.

### 2-4. Post-PR 정리 절차

PR merge 후:

```bash
# develop 동기화
git checkout develop
git pull origin develop

# feature 브랜치 삭제 (로컬)
git branch -d feature/{name}

# 리모트 ref 정리 (GitHub에서 "Delete branch" 클릭하거나)
git remote prune origin

# 다음 feature 브랜치 생성
git checkout -b feature/{next}
```

> `gh pr merge --delete-branch` 사용 시 로컬·리모트 feature 브랜치 삭제가 자동 처리된다.

## 3. 릴리즈 사이클 (Develop → Main)

Phase 또는 마일스톤 단위로 develop을 main에 병합한다.

```bash
# GitHub UI 또는 CLI로 develop → main PR 생성
gh pr create --base main --head develop --title "release: ..."
```

PR merge 후:

```bash
git checkout main
git pull origin main

git checkout develop
git merge origin/main       # develop을 main과 동기화
git push origin develop
```

## 4. CI Trigger

| 이벤트 | 실행 Job |
|---|---|
| `push` to `develop` | build |
| `push` to `main` | lint → test |
| `pull_request` targeting `main` | lint → test |

> feature → develop PR은 CI가 자동 실행되지 않는다.
> develop → main PR 또는 main push 시 전체 검증이 실행된다.

## 5. Commit Message Format

Conventional Commits 형식을 따르며, DR-007 Bilingual Rules를 적용한다.

```
<type>: <subject>

<body>
```

**Type prefix** (항상 영문): `feat`, `fix`, `docs`, `chore`, `refactor`, `test`, `style`, `ci`

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
| `*.java`, `*.kt`, `*.kts`, `*.gradle`, `gradle.properties` 포함 | Checkstyle 실행 (`./gradlew checkstyleMain`) |
| docs-only (위 파일 없음) | Checkstyle skip |

hook 설치:

```bash
bash tools/git-hooks/install.sh
```

## 7. 관련 문서

- `.claude/rules/git-workflow.md` — Claude Code용 커밋 gate 규칙
- `docs/decisions/DR-007-language-policy.md` — Bilingual Rules
- `.github/workflows/ci.yml` — CI 상세 설정
- `docs/DEVELOPER-GUIDE.md` — 로컬 개발환경 설정
