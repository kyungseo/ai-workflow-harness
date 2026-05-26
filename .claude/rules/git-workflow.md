---
paths:
  - "**"
---

# Git Workflow Rules

If the current directory is not a git repository (bootstrap initial state), report the steps below as `Not Applicable` and proceed with document/file validation only.

Before committing, always run in this order:

1. `git status` — confirm full working tree state (unstaged + untracked)
2. `git add <files>` — stage intended files
3. `git status` — verify nothing is missed before committing
4. `git diff --cached` — review staged content

NEVER use `git diff --cached` alone as the only pre-commit check.
It does not show unstaged modifications or untracked files.

## Branch Isolation Check

Before staging or committing, check the current branch:

```bash
git branch --show-current
```

If the branch is `develop` or `main` AND any of the following files are staged — move to FAIL:

- `AGENTS.md`, `CLAUDE.md`, `docs/STATUS.md`, `docs/backlog/**`, `docs/works/**`, `docs/decisions/**`
- `docs/AGENT-WORKFLOW.md`, `docs/HARNESS-PROTOCOL.md`, `docs/HARNESS-QUICK-REFERENCE.md`, `docs/GIT-WORKFLOW.md`
- `.claude/commands/**`, `.claude/rules/**`, `.cursor/rules/**`, `.agents/skills/**`, `prompts/**`, `scripts/create-harness.sh`

FAIL response: report current branch and the staged protected files, then propose creating a `feature/*` or `hotfix/*` branch and moving the changes there.

Exception: skip this check if `.git/MERGE_HEAD` exists (merge commit — release sync).
Not Applicable: if the current directory is not a git repository.

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

When the user expresses branch merge intent, such as asking to merge, open a PR, or merge into `develop`,
load `docs/GIT-WORKFLOW.md` and follow section 2 (feature development cycle) and section 3 (release cycle — §3-1 Public Clean Baseline Gate 수행 포함).

PR Base Rule:
- feature/* → `develop` (ALWAYS use `--base develop` when opening a PR from a feature branch)
- develop → `main` (release PR only)

NEVER:
- Open a PR from a feature branch without `--base develop`. Default GitHub base (main) is wrong for this repo.
- Directly local-merge a feature branch into develop. Always merge via PR.
- Skip the develop sync step after a main PR merge (`git merge main && git push origin develop`).
