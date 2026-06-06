---
paths:
  - "**"
---

# Git Workflow Rules

## Enforcement Posture (advisory-only)

This scaffold uses the generic workflow: **no git hooks are installed**, so the branch-isolation, finalization-bundling, and commit-message gates below are **advisory** — they rely on the agent and committer honoring them, not on runtime enforcement (per DR-025: gates are AI-advisory when hooks are absent).
To enable runtime hook enforcement, re-scaffold with `--workflow source-gitflow`.

Project-specific gate paths: this repository may list extra protected/finalization
paths in `.harness/gate-config` (`[protected]` / `[finalization]` sections, one glob
per line). Because this is a generic scaffold there are no hooks to enforce them, so
treat any paths listed there as **advisory input** — honor them as protected (avoid
direct `develop`/`main` edits) and as finalization (bundle with substantive work) the
same way as the defaults below.

If the current directory is not a git repository (bootstrap initial state), report the steps below as `Not Applicable` and proceed with document/file validation only.

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
- Before committing or opening a PR, report Tracking Finalization: whether backlog/Work/DR tracker updates are needed, why, and which tracker files changed if any.
- If `docs/STATUS.md` needs to change before commit, provide the Approval Matrix state-change proposal and wait for user approval before editing it.
- When `docs/STATUS.md` changes are approved, include them in the **same commit** as the substantive changes. Never commit substantive changes first and update `docs/STATUS.md` in a separate follow-up commit.
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
- Example: `docs: [Korean subject using DR-007 and Bilingual Rules identifiers]`

**Body** — Korean primary with English technical terms inline; follow the same Bilingual Rules as the subject line.

- Use blank line to separate subject from body.
- Explain *why*, not *what*.
- Example body line: `[Korean body explaining why the harness protocol section titles now follow DR-007]`

**Co-author trailer** — always in English (system-generated, do not translate).

## Branch Flow

When the user expresses branch merge intent (merging, opening a PR),
if this repository has `docs/GIT-WORKFLOW.md`, load it and follow its branch and PR guidance. Otherwise, follow the project-specific branch policy.
