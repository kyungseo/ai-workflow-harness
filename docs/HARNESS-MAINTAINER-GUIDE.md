# HARNESS-MAINTAINER-GUIDE.md - AI Workflow Harness

> 대상: 이 repository에서 AI Workflow Harness를 정비하거나 다른 repository에 적용하려는 maintainer.
> 전체 구조 다이어그램의 기준 문서는 `docs/HARNESS-ARCHITECTURE.md`다.

---

## 1. Setup

필수 runtime은 별도로 없다. Core workflow는 Markdown 문서와 shell script로 구성된다.

권장 도구:

- Git
- Bash compatible shell
- `rg` for search
- Claude Code, Codex, or Cursor when testing tool-specific surfaces

GitHub repository 설정 (ruleset, 보안, 기능 옵션)은 `docs/decisions/DR-020-github-repo-settings.md`를 기준으로 적용한다.

pre-commit / commit-msg hook 설치는 `tools/git-hooks/`가 있는 경우에만 적용된다 — §10 참조.

## 2. Daily Workflow

1. `docs/STATUS.md`의 Current State, Active Work, Blockers, Next Actions를 확인한다.
2. Active Work가 있으면 해당 `docs/works/**` 파일을 읽는다.
3. 변경 전 Scope, Files, Verification, Risk, Reversal Cost를 정리한다.
4. Approval Matrix에 따라 승인 후 수정한다.
5. 검증 후 Work checkpoint/discovery와 STATUS 필요 여부를 확인한다.

## 2-a. Related Maintainer References

이 문서는 maintainer용 개요와 운영 기준을 설명하는 메인 진입 문서다. 실제 작업에 들어갈 때는 아래 satellite 문서를 같이 봐야 한다.

| 문서 | 언제 함께 읽나 | 역할 |
| --- | --- | --- |
| `docs/maintainer/HARNESS-TEST-TAXONOMY.md` | 검증 depth, Tier, `temp/` 정책이 헷갈릴 때 | 검증 구조와 용어의 기준 |
| `docs/maintainer/SOURCE-REPO-OPERATIONS.md` | source repo 변경 유형별 실행 경로를 고를 때 | 변경 lifecycle별 runbook |
| `docs/maintainer/VERIFICATION-COMMANDS.md` | 실제 검증 명령이나 release sweep이 필요할 때 | Layer별 검증 catalog |
| `docs/maintainer/PRODUCT-STARTER-PLANNING-PACK.md` | product starter pack / import loop / source-product 경계를 볼 때 | planning pack 기준 문서 |
| `docs/maintainer/VERSIONING.md` | 버전 bump, tag, release note 판단이 필요할 때 | source repo 버전 정책 |

이 문서 하나만으로 세부 절차를 끝내려 하지 말고, 위 표에서 지금 작업과 직접 맞닿는 문서를 함께 읽는 것이 기본이다.

## 3. Conventions

### Language Policy

DR-007을 따른다.

- Commit type prefix는 English.
- Commit subject/body는 Korean primary, technical term은 English 허용.
- Entry instruction과 tool rule은 instruction 준수에 유리한 경우 English를 사용할 수 있다.
- User-facing Korean 문서는 section 이름과 technical term을 English로 유지한다.

### Documentation Style

- 공유 규칙은 entrypoint에 중복하지 않고 canonical docs에 둔다.
- `AGENTS.md`와 `CLAUDE.md`는 얇게 유지한다.
- `docs/STATUS.md`는 dashboard 전용으로 사용한다.
- 작업 세부사항, checkpoint, discovery는 Work 파일에 기록한다.
- 명시적으로 요청받지 않는 한 historical snapshot을 재작성하지 않는다.
- live 문서가 변경되면 quick reference, manual, prompt, rule, scaffold surface의 정렬이 필요한지 확인한다.

### Work File Convention

Work 파일은 `docs/works/{category}/` 아래에 위치한다. 파일명 형식: `{ID}-{lowercase-topic}.md`.

Work ID 형식: `<TYPE>-<YYYYMMDD>-<NNN>` (예: `CHORE-20260528-001`). 상세 기준은 `docs/HARNESS-NAMING-RULES.md`.

필수 frontmatter:

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
related_dr: []
related_commits: []
related_troubleshooting: []
---
```

필수 섹션 (DR-013 기준):

- Plan
- Done Criteria
- Verification
- Checkpoints
- Discovery

### Prompt Convention

Live `prompts/` surface는 session-start fallback prompt와 README로 제한한다.
Generic task prompt나 stack-specific prompt example을 다시 추가하려면 먼저 별도 Work에서 example pack 정책과 scaffold copy boundary를 정한다.

### Shell Script Convention

- bash script는 `bash -n` 검증을 수행한다.
- 실용적인 범위에서 idempotent하게 작성한다.
- scaffold 또는 filesystem을 변경하는 script는 dry-run을 지원하는 것을 권장한다.
- secret이나 local machine-specific path를 embed하지 않는다.
- scaffold 생성 후 다음으로 필요한 manual step을 출력한다.

### Markdown Hygiene

- repository 문서에는 relative link를 사용한다.
- table은 간결하고 한눈에 파악할 수 있게 유지한다.
- command에는 fenced code block을 사용한다.
- 복잡한 state 또는 flow diagram에는 Mermaid를 사용한다.
- commit 전 `git diff --check`를 실행한다.

## 4. Editing Rules

- 공유 동작 원칙은 `docs/BEHAVIOR-PRINCIPLES.md`에 기록한다.
- 공유 workflow는 `docs/AGENT-WORKFLOW.md`와 `docs/HARNESS-PROTOCOL.md`에 기록한다.
- Tool-specific 파일은 actionable runtime rule만 mirror한다.
- 해당 작업이 명시적으로 대상으로 삼지 않는 한 historical 문서를 재작성하지 않는다.
- `docs/STATUS.md`는 dashboard이며, 작업 세부 히스토리는 Work 파일에 기록한다.
- 조건부 runbook이 core 문서에 축적되면 별도 slice 파일로 분리하고 조건부 pointer로 교체한다.

## 5. Validation

변경 사항을 검증하는 가장 좁은 방법을 사용한다.

| Change | Validation |
| --- | --- |
| Documentation-only | `git diff --check` |
| Scaffold script | `bash -n scripts/create-harness.sh` |
| Generic scaffold behavior | `./scripts/create-harness.sh --dry-run --profile generic sample /tmp/sample` |
| Source-gitflow scaffold behavior | `./scripts/create-harness.sh --dry-run --workflow source-gitflow sample /tmp/sample` |
| Tool-surface alignment | targeted `rg` across canonical, tool-specific, user-facing, scaffold surfaces |
| Validation spine (regression) | `bash scripts/tests/run-harness-checks.sh --all` — syntax·scaffold invariant·DR closure·default template/surface mirror parity·onboarding 전수. 기준·Tier는 `docs/maintainer/HARNESS-TEST-TAXONOMY.md`, 명령 카탈로그는 `docs/maintainer/VERIFICATION-COMMANDS.md` (둘 다 source-only). PR merge 전·마일스톤 완료 시 권장 |
| Public readiness | stale identity audit and secret/private-info scan |

## 6. Scaffold Development

먼저 syntax를 검증한다:

```bash
bash -n scripts/create-harness.sh
```

Generic dry-run을 검증한다:

```bash
./scripts/create-harness.sh --dry-run --profile generic sample /tmp/sample
```

Source-gitflow mode dry-run을 검증한다 (`docs/GIT-WORKFLOW.md` 생성 포함):

```bash
./scripts/create-harness.sh --dry-run --workflow source-gitflow sample /tmp/sample
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
- `.agents/skills/**`
- `.codex/hooks.json`
- `prompts/README.md`

## 7. Tool Surface Alignment

rule이나 workflow 동작이 변경되면 다음 cascade를 확인한다:

| Layer | Examples |
| --- | --- |
| Canonical | `docs/AGENT-WORKFLOW.md`, `docs/HARNESS-PROTOCOL.md` |
| Tool-specific | `.claude/commands/**`, `.claude/rules/**`, `.cursor/rules/**`, `.agents/skills/**`, `.codex/hooks.json` |
| User-facing | `README.md`, `docs/WORKFLOW-MANUAL.md` |
| Scaffold | `scripts/create-harness.sh`, generated skeleton files |
| Historical | archives, retrospectives, old review packages |

Historical 파일은 편집하지 않고 context 확인 용도로만 참조한다.
변경된 동작의 live mirror에 해당하는 surface만 업데이트한다. 모든 surface를 일괄 수정하지 않는다.

## 8. Prompt Fallback Surface

Live prompt는 session-start fallback surface다.

`prompts/*session-start.md`를 변경하면 `prompts/README.md`, session-start canonical procedure, tool-specific command/adapter, scaffold output을 함께 확인한다.

## 9. Public Release Checks

repository를 public으로 전환하기 전에:

1. 현재 tree가 application runtime project로 표현되지 않는지 확인한다.
2. live 문서와 tool surface에 대해 stale identity 검색을 수행한다.
3. secret, private URL, local-only path를 스캔한다.
4. generic scaffold dry-run을 검증한다.
5. review가 완료될 때까지 GitHub repository visibility가 private 상태임을 확인한다.
6. GitHub repository ruleset, 보안 설정, 기능 옵션을 `docs/decisions/DR-020-github-repo-settings.md` 기준으로 구성한다.

> **Version release(반복) vs public 전환(1회):** 위 6단계는 repo를 처음 public으로 여는 1회성 점검이다. 이후 버전 bump release(develop → main)마다는 `docs/GIT-WORKFLOW.md` §3-1 Public Clean Baseline Gate(state cleanliness + `Validation spine`·`Surface sweep` evidence row)와 `docs/maintainer/VERIFICATION-COMMANDS.md` "Release Full Sweep"(출하 표면 Layer 전수)을 함께 따른다. tag·VERSION 정합은 `docs/maintainer/VERSIONING.md`.

## 10. Product Repo Hook Policy

scaffold workflow mode에 따라 hook 배포가 달라진다.

- **generic workflow(기본):** product repo에 `tools/git-hooks/`가 포함되지 않는다. product repo는 자체 lint/test/pre-commit stack을 우선하고, hook이 필요하면 해당 repo의 branch policy, protected paths, validation commands, commit message 규칙에 맞게 project-specific hook으로 별도 정의한다.
- **`--workflow source-gitflow`(opt-in):** harness gate hook(`tools/git-hooks/{pre-commit,commit-msg,install.sh,lib/gate-lists.sh}`)이 함께 배포된다. source repo와 동일한 feature→develop→main 운영 모델과 DR-025 finalization gate를 그대로 적용하려는 경우에만 선택한다. 배포된 target은 자기 protected/finalization 경로를 **`.harness/gate-config`**(`[protected]`/`[finalization]` 섹션, add-only, upgrade-safe)에서 확장하고 `sh tools/git-hooks/install.sh`로 설치한다. framework-owned `tools/git-hooks/lib/gate-lists.sh`는 직접 편집하지 않는다(manifest drift + upgrade 시 덮어쓰기).

generic workflow에서 harness hook을 임의로 그대로 복사하지 않는다. source harness hook은 harness source repo의 protected files, branch naming, validation scope, commit type을 전제로 하므로 그대로 적용하면 기존 hook stack과 충돌하거나 잘못된 branch/workflow 제약을 만들 수 있다. source-gitflow opt-in은 이 전제를 받아들인 선택이므로 예외다.
