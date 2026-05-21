# DEVELOPER-GUIDE.md - AI Workflow Harness

> 대상: 이 repository에서 AI Workflow Harness를 정비하거나 다른 repository에 적용하려는 maintainer.
> 전체 구조 다이어그램의 기준 문서는 `docs/ARCHITECTURE.md`다.

---

## 1. Local Setup

필수 runtime은 별도로 없다. Core workflow는 Markdown 문서와 shell script로 구성된다.

권장 도구:

- Git
- Bash compatible shell
- `rg` for search
- Claude Code, Codex, or Cursor when testing tool-specific surfaces

Local hooks:

```bash
sh tools/git-hooks/install.sh
```

## 2. Daily Workflow

1. `docs/STATUS.md`의 Current State, Active Work, Blockers, Next Actions를 확인한다.
2. Active Work가 있으면 해당 `docs/works/**` 파일을 읽는다.
3. 변경 전 Scope, Files, Verification, Risk, Reversal Cost를 정리한다.
4. Approval Matrix에 따라 승인 후 수정한다.
5. 검증 후 Work checkpoint/discovery와 STATUS 필요 여부를 확인한다.

## 3. Editing Rules

- Shared behavior belongs in `docs/BEHAVIOR-PRINCIPLES.md`.
- Shared workflow belongs in `docs/AGENT-WORKFLOW.md` and `docs/HARNESS-PROTOCOL.md`.
- Tool-specific files should mirror only actionable runtime rules.
- Historical documents should not be rewritten unless the task explicitly targets them.
- `docs/STATUS.md` is a dashboard; detailed task history belongs in Work files.

## 4. Validation

Use the narrowest validation that proves the change.

| Change | Validation |
| --- | --- |
| Documentation-only | `git diff --check` |
| Scaffold script | `bash -n scripts/create-harness.sh` |
| Generic scaffold behavior | `./scripts/create-harness.sh --dry-run --profile generic sample /tmp/sample` |
| Tool-surface alignment | targeted `rg` across canonical, tool-specific, user-facing, scaffold surfaces |
| Public readiness | stale identity audit and secret/private-info scan |

## 5. Scaffold Development

Validate syntax first:

```bash
bash -n scripts/create-harness.sh
```

Validate generic dry-run:

```bash
./scripts/create-harness.sh --dry-run --profile generic sample /tmp/sample
```

For actual scaffold verification, generate into a fresh temp path:

```bash
./scripts/create-harness.sh --profile generic sample /tmp/sample-harness
```

Then inspect:

- generated `AGENTS.md` / `CLAUDE.md`
- `docs/STATUS.md`
- `docs/PLAN-SUMMARY.md`
- `docs/AGENT-WORKFLOW.md` Project Constants
- `.claude/rules/**`
- `.cursor/rules/**`
- `prompts/README.md`

## 6. Adding Or Changing Rules

When a rule changes, check the cascade:

| Layer | Examples |
| --- | --- |
| Canonical | `docs/AGENT-WORKFLOW.md`, `docs/HARNESS-PROTOCOL.md` |
| Tool-specific | `.claude/commands/**`, `.claude/rules/**`, `.cursor/rules/**` |
| User-facing | `README.md`, `docs/WORKFLOW-MANUAL.md`, public summary |
| Scaffold | `scripts/create-harness.sh`, generated skeleton files |
| Historical | archives, retrospectives, old review packages |

Historical files are normally checked for context, not edited.

## 7. Prompt Library

Generic prompts are core. Stack-specific prompts are optional example packs.

Update `prompts/README.md` when adding a prompt, changing frontmatter fields, or
moving a prompt between generic and optional sections.

## 8. Public Release Checks

Before making the repository public:

1. Confirm current tree no longer presents itself as an application runtime project.
2. Run stale identity searches on live docs and tool surfaces.
3. Scan for secrets, private URLs, and local-only paths.
4. Validate generic scaffold dry-run.
5. Confirm GitHub repository visibility remains private until review is complete.
