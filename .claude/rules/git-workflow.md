---
paths:
  - "**"
---

# Git Workflow Rules

Before committing, always run in this order:

1. `git status` — confirm full working tree state (unstaged + untracked)
2. `git add <files>` — stage intended files
3. `git status` — verify nothing is missed before committing
4. `git diff --cached` — review staged content

NEVER use `git diff --cached` alone as the only pre-commit check.
It does not show unstaged modifications or untracked files.

Commit Approval:

- Commit only after validation is complete or the remaining risk is explicitly accepted.
- Before committing, follow the Approval Matrix: report validation result, diff summary, and proposed commit message, then wait for user approval.
- Before committing or opening a PR, report STATUS Finalization: whether `docs/STATUS.md` update is needed, why, and the required Approval Matrix proposal if needed.
- If `docs/STATUS.md` needs to change before commit, provide the Approval Matrix state-change proposal and wait for user approval before editing it.
- If not committing after a completed task, record the reason and remaining risk in the session summary.

## Commit Message Format

Follow Conventional Commits with Bilingual Rules (per `docs/decisions/DR-007-language-policy.md`):

```
<type>: <subject>

<body>
```

**Type prefix** — always in English: `feat`, `fix`, `docs`, `chore`, `refactor`, `test`, `style`, `ci`, `config`, `perf`, `build`, `revert`.

**Subject line** — Korean primary; English for technical terms and identifiers.

- Use Korean verbs and sentence endings.
- Keep English for proper nouns, tool names, file paths, IDs (e.g., `DR-007`, `STATUS.md`, `Bilingual Rules`).
- Example: `docs: DR-007 Bilingual Rules 적용 — commands 및 harness protocol 섹션 타이틀 영문화`

**Body** — Korean primary with English technical terms inline; follow the same Bilingual Rules as the subject line.

- Use blank line to separate subject from body.
- Explain *why*, not *what*.
- Example body line: `harness protocol 문서의 섹션 타이틀을 영문 Title Case로 통일하여 DR-007 정책과 일치시킴`

**Co-author trailer** — always in English (system-generated, do not translate).

## Branch Flow

When the user expresses branch merge intent ("머지하자", "PR 올리자", "develop에 합치자", etc.),
load `docs/GIT-WORKFLOW.md` and follow §2 (Feature 개발 사이클) and §3 (릴리즈 사이클).

NEVER:
- Directly local-merge a feature branch into develop. Always merge via PR.
- Skip the develop sync step after a main PR merge (`git merge main && git push origin develop`).
