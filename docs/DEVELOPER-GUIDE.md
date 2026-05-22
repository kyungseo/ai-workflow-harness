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

- 공유 동작 원칙은 `docs/BEHAVIOR-PRINCIPLES.md`에 기록한다.
- 공유 workflow는 `docs/AGENT-WORKFLOW.md`와 `docs/HARNESS-PROTOCOL.md`에 기록한다.
- Tool-specific 파일은 actionable runtime rule만 mirror한다.
- 해당 작업이 명시적으로 대상으로 삼지 않는 한 historical 문서를 재작성하지 않는다.
- `docs/STATUS.md`는 dashboard이며, 작업 세부 히스토리는 Work 파일에 기록한다.

## 4. Validation

변경 사항을 검증하는 가장 좁은 방법을 사용한다.

| Change | Validation |
| --- | --- |
| Documentation-only | `git diff --check` |
| Scaffold script | `bash -n scripts/create-harness.sh` |
| Generic scaffold behavior | `./scripts/create-harness.sh --dry-run --profile generic sample /tmp/sample` |
| Tool-surface alignment | targeted `rg` across canonical, tool-specific, user-facing, scaffold surfaces |
| Public readiness | stale identity audit and secret/private-info scan |

## 5. Scaffold Development

먼저 syntax를 검증한다:

```bash
bash -n scripts/create-harness.sh
```

Generic dry-run을 검증한다:

```bash
./scripts/create-harness.sh --dry-run --profile generic sample /tmp/sample
```

실제 scaffold 검증이 필요하면 새 임시 경로에 생성한다:

```bash
./scripts/create-harness.sh --profile generic sample /tmp/sample-harness
```

생성 후 다음을 확인한다:

- generated `AGENTS.md` / `CLAUDE.md`
- `docs/STATUS.md`
- `docs/PLAN-SUMMARY.md`
- `docs/AGENT-WORKFLOW.md` Project Constants
- `.claude/rules/**`
- `.cursor/rules/**`
- `prompts/README.md`

## 6. Adding Or Changing Rules

rule이 변경되면 cascade를 확인한다:

| Layer | Examples |
| --- | --- |
| Canonical | `docs/AGENT-WORKFLOW.md`, `docs/HARNESS-PROTOCOL.md` |
| Tool-specific | `.claude/commands/**`, `.claude/rules/**`, `.cursor/rules/**` |
| User-facing | `README.md`, `docs/WORKFLOW-MANUAL.md`, public summary |
| Scaffold | `scripts/create-harness.sh`, generated skeleton files |
| Historical | archives, retrospectives, old review packages |

Historical 파일은 편집하지 않고 context 확인 용도로만 참조한다.

## 7. Prompt Library

Generic prompt는 core이며, stack-specific prompt는 optional example pack이다.

prompt를 추가하거나, frontmatter field를 변경하거나, generic과 optional section 간에 prompt를 이동할 때는 `prompts/README.md`를 업데이트한다.

## 8. Public Release Checks

repository를 public으로 전환하기 전에:

1. 현재 tree가 application runtime project로 표현되지 않는지 확인한다.
2. live 문서와 tool surface에 대해 stale identity 검색을 수행한다.
3. secret, private URL, local-only path를 스캔한다.
4. generic scaffold dry-run을 검증한다.
5. review가 완료될 때까지 GitHub repository visibility가 private 상태임을 확인한다.
