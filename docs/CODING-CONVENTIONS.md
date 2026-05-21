# CODING-CONVENTIONS.md - AI Workflow Harness

> 이 문서는 AI Workflow Harness repository의 documentation, prompt, and script convention이다.
> Programming-language-specific conventions belong in optional example packs, not in the core harness.

---

## 1. Language Policy

DR-007을 따른다.

- Commit type prefix는 English.
- Commit subject/body는 Korean primary, technical term은 English 허용.
- Entry instructions and tool rules may use English when it improves instruction adherence.
- User-facing Korean docs may keep section names and technical terms in English.

## 2. Documentation Style

- Keep shared rules in canonical docs, not duplicated in entrypoints.
- Keep `AGENTS.md` and `CLAUDE.md` thin.
- Use `docs/STATUS.md` as dashboard only.
- Put task details, checkpoints, and discovery in Work files.
- Do not rewrite historical snapshots unless explicitly requested.
- When a live doc changes, check whether quick reference, manual, prompt, rule, and scaffold surfaces need alignment.

## 3. Work File Convention

Work files live under `docs/works/{category}/`.

Required frontmatter:

```yaml
---
id:
priority:
status:
risk:
scope:
appetite:
planned_start:
planned_end:
actual_end:
---
```

Required sections:

- Context
- Plan
- Done Criteria
- Checkpoints
- Discovery

## 4. Prompt Convention

Task prompt frontmatter should keep these keys:

- `id`
- `purpose`
- `portability`
- `difficulty`
- `inputs`
- `output_contract`

Generic prompts should not assume a specific framework. Stack-specific prompts must be
marked as optional/example content in `prompts/README.md`.

## 5. Shell Script Convention

- Use `bash -n` validation for bash scripts.
- Keep scripts idempotent where practical.
- Prefer dry-run support for scaffold or filesystem-changing scripts.
- Do not embed secrets or local machine-specific paths.
- Print next required manual steps after scaffold generation.

## 6. Markdown Hygiene

- Prefer relative links for repository docs.
- Keep tables compact and scannable.
- Use fenced code blocks for commands.
- Use Mermaid for complex state or flow diagrams.
- Run `git diff --check` before commit.

## 7. Tool Surface Alignment

When editing workflow behavior, check:

- canonical docs
- Claude commands/rules
- Cursor rules
- Codex entrypoint/prompt
- user-facing manual/README
- scaffold output

Do not update every surface blindly. Update only surfaces that are live mirrors of
the changed behavior.
