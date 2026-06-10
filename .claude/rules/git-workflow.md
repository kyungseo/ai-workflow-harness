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
- `.claude/commands/**`, `.claude/rules/**`, `.cursor/rules/**`, `.agents/skills/**`, `prompts/**`, `scripts/create-harness.sh`, `tools/git-hooks/**`, `.harness/gate-config`
- Any path listed under `[protected]` in `.harness/gate-config` (project-specific additions)

The list above is the harness default. A target repo adds its own sensitive paths under `[protected]` / `[finalization]` in `.harness/gate-config` (add-only) — do **not** edit framework-owned `tools/git-hooks/lib/gate-lists.sh` directly (it is overwritten on harness upgrade). When hooks are installed they read both the default and `.harness/gate-config`; treat the same union as protected here.

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
- If an Active Work file exists and all Done Criteria are checked ([x]), propose running `/work-close` before the commit so state changes (Work Done, Work Index, STATUS pointer) are bundled in the same commit rather than generated as a separate close commit later.
- If not committing after a completed task, record the reason and remaining risk in the session summary.

Tracking-only commits: the finalization-bundling gate exists to stop finalization being split *off* substantive work. A **pure tracking-only commit** — registration with no substantive work to bundle (e.g. `/work-register` adding a backlog row, a DR record, STATUS housekeeping) — is a legitimate exception, not a new commit type. Do **not** loosen the gate for it; use the existing override trailer with a tracking-only reason so a durable record stays in history:

```
AWH-Gate-Override: finalization-split
AWH-Gate-Reason: tracking-only registration: <what is being registered>
```

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
If this repository has `docs/GIT-WORKFLOW.md`, load it and follow section 2 (feature development cycle) and section 3 (release cycle). Otherwise, check the project-specific branch/release policy first.

PR Base Rule:
- feature/* → `develop` (ALWAYS use `--base develop` when opening a PR from a feature branch)
- develop → `main` (release PR only)

Sync Before PR:
- Before opening a feature PR, pull the latest `develop` into the feature branch (`git fetch origin && git merge origin/develop`) per `docs/GIT-WORKFLOW.md` §2-3, and resolve any conflicts locally first.
- Default to `merge`; the squash merge policy makes rebase's linear history moot, so reserve `git rebase origin/develop` for local-only unpushed commits.
- `--force-with-lease` is allowed only on your own feature branch — never force-push `develop` or `main`.

NEVER:
- Open a PR from a feature branch without `--base develop`. Default GitHub base (main) is wrong for this repo.
- Directly local-merge a feature branch into develop. Always merge via PR.
- Skip the develop sync step after a main PR merge (`git merge origin/main` into `develop`, then `git push origin develop`).

## Post-PR Merge Cleanup

After `gh pr merge` completes, follow the appropriate cleanup for the merge type:

**feature → develop PR:**
Merge flag: `gh pr merge --squash --delete-branch` (squash is the default per harness merge policy). Use `--merge` only when commit-level history must be preserved.
If this repository has `docs/GIT-WORKFLOW.md`, execute §2-5 in full without waiting for a separate instruction:
1. `git checkout develop && git pull origin develop`
2. `git branch -d feature/{name}` — delete local branch. If remote was not auto-deleted, also run `git push origin --delete feature/{name}`.
3. Suggest the next feature branch name based on upcoming work and ask whether to create it now.

**develop → main PR:**
Merge flag: `gh pr merge --merge` (regular merge is the default per harness merge policy). Fast-forward is allowed if applicable.
If this repository has `docs/GIT-WORKFLOW.md`, execute §3-4 (Post-Merge Develop Sync) instead:
`git checkout main && git pull origin main`, then `git checkout develop && git merge origin/main && git push origin develop`.
