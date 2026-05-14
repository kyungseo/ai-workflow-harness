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

Commit Gate:

- Commit only after validation is complete or the remaining risk is explicitly accepted.
- If `docs/STATUS.md` needs to change before commit, provide a `STATUS Update Proposal` and wait for user approval before editing it.
- If not committing after a completed task, record the reason and remaining risk in the session summary.
