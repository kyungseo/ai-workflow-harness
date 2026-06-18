# repo-health-cascade

Conditional detail slice for `/repo-health --cascade`.

Load this file only after `skills/workflow/repo-health.md` when the invocation includes `--cascade`.

## File Reading Order

**Phase 6 — Cascade Checklist (--cascade only)**

변경된 파일 목록을 먼저 확인한다:

```bash
git diff --name-only
git diff --cached --name-only
```

변경 파일을 기준으로 필요한 layer만 선택적으로 읽는다. 전체 문서 일괄 로드는 금지한다.
`docs/WORKFLOW-MANUAL.md`는 평시 AI 실행 규칙 로드 대상이 아니며, `--cascade`에서 user-facing workflow drift를 확인할 때만 필요한 섹션을 읽는다.
예: slash command 설명, trigger reference, 사용자-visible workflow, scaffold 안내가 바뀐 경우.

> **Optional pack 참조 주의:** 아래 Required Surface Matrix·Grep Pack이 가리키는 `docs/WORKFLOW-MANUAL.md`, `docs/HARNESS-ARCHITECTURE.md`, `docs/HARNESS-MAINTAINER-GUIDE.md`는 Optional source pack이라 minimal scaffold에는 없을 수 있다. 해당 파일이 없으면 그 surface/grep 항목은 N/A로 처리하고, 필요하면 `scripts/create-harness.sh --with-optional`로 재생성하거나 source repo 문서를 참조한다.

`--cascade`는 변경 파일 기준으로 감사 대상을 좁힌다. 단, 선택된 파일 유형의 required surface, grep, simulation은 생략하지 않고, 누락·불일치·과잉반복·불필요복잡성·사용자생산성저하를 P0/P1/P2로 보고한다.
변경 파일이 없으면 Quick 모드(A+B+E)와 동일하게 동작한다.
전체 surface를 모두 훑어야 하면 `--full --cascade`를 사용한다.

> **검증 명령 카탈로그:** 아래 Surface Matrix·Grep Pack의 구체 grep 명령과 scaffold/onboarding 시뮬레이션 상세는 `docs/maintainer/VERIFICATION-COMMANDS.md`(source repo 전용 maintainer 문서)에 Layer별로 정리되어 있다. 릴리즈 직전 전수 점검은 동 문서 "Release Full Sweep" 프리셋을 사용한다.

## Required Surface Matrix

| 변경 파일 유형 | Canonical | Tool-specific | User-facing | Scaffold | Historical |
| --- | --- | --- | --- | --- | --- |
| `docs/AGENT-WORKFLOW.md`, `docs/HARNESS-PROTOCOL.md` | 두 파일 모두 | `AGENTS.md`, `CLAUDE.md`, `.claude/commands/`, `.claude/rules/`, `.agents/skills/`, `.codex/hooks.json`, `.cursor/rules/`, `prompts/*` | `docs/HARNESS-QUICK-REFERENCE.md`, 관련 `docs/WORKFLOW-MANUAL.md` 섹션, `README.md` | `scripts/create-harness.sh`가 있으면 dry-run 또는 temp scaffold, 없으면 scaffold source 검증 제외 | 관련 retrospective/brief는 snapshot 여부만 확인 |
| `.claude/commands/*.md` 또는 `.agents/skills/*/SKILL.md` | `docs/HARNESS-PROTOCOL.md`, `docs/AGENT-WORKFLOW.md` | 대응 `.agents/skills/workflow-{name}/SKILL.md` 또는 `.claude/commands/{name}.md` (suffix mapping: `.claude/commands/{name}.md` ↔ `.agents/skills/workflow-{name}/SKILL.md`), `AGENTS.md`, `.cursor/rules/workflow.mdc`, `prompts/*session-start.md` | `docs/HARNESS-QUICK-REFERENCE.md`, 관련 `docs/WORKFLOW-MANUAL.md` command 섹션 | command/skill 복사 산출물 | 필요 시 관련 Work/retrospective/brief |
| `.claude/rules/*.md`, `.cursor/rules/*.mdc`, `.codex/hooks.json` | `docs/HARNESS-PROTOCOL.md`, `docs/AGENT-WORKFLOW.md` | 반대 tool rule, hook, prompts | 필요 시 manual/rules 설명 | rule/hook 복사 산출물 | 필요 시 관련 Work/retrospective/brief |
| `prompts/*` | `docs/AGENT-WORKFLOW.md`, 필요 시 `docs/HARNESS-PROTOCOL.md` | `AGENTS.md`, `CLAUDE.md`, command/skill/rule/hook | `prompts/README.md`, 필요 시 manual prompt 섹션 | prompt 복사 산출물 | 필요 시 관련 Work/retrospective/brief |
| `docs/WORKFLOW-MANUAL.md`, `README.md`, `docs/HARNESS-QUICK-REFERENCE.md` | `docs/AGENT-WORKFLOW.md`, `docs/HARNESS-PROTOCOL.md` | 관련 command/rule/prompt | 변경된 user-facing 문서 상호 참조 | 필요 시 scaffold README/manual 산출물 | snapshot 덮어쓰기 금지 |
| `scripts/create-harness.sh`가 존재할 때 | `docs/AGENT-WORKFLOW.md`, `docs/HARNESS-PROTOCOL.md`, `docs/SCAFFOLD-BOOTSTRAP.md` | commands/rules/prompts source | generated README/manual expectations | dry-run + temp scaffold + stale phrase search | 필요 시 related Work |
| `docs/SCAFFOLD-BOOTSTRAP.md` | `docs/HARNESS-PROTOCOL.md` | — | — | `scripts/create-harness.sh`가 있으면 생성 BOOTSTRAP.md 템플릿과 Boot Sequence·Completion Rule 동기화, 없으면 source repo 전용 기준으로 표시 | — |
| `docs/STATUS.md`, `docs/works/**`, `docs/backlog/**`, `docs/decisions/**`, `docs/briefs/**` | `docs/HARNESS-PROTOCOL.md`, `docs/AGENT-WORKFLOW.md` | session-start/work-resume/work-close/session-summary/record-decision/work-brief commands | quick reference/manual state sections | work/index scaffold templates | 관련 Work/DR/retrospective/brief |
| `docs/GIT-WORKFLOW.md`, branch/release policy 변경 | `docs/AGENT-WORKFLOW.md` | `.claude/commands/work-plan.md`, `work-close.md`, 대응 SKILL mirror | `docs/WORKFLOW-MANUAL.md` branch 섹션, `docs/HARNESS-QUICK-REFERENCE.md` | `scripts/templates/source-gitflow/docs/GIT-WORKFLOW.md`, generated work-plan/work-close command | 관련 Work |
| `scripts/templates/**` 변경 | `docs/SCAFFOLD-BOOTSTRAP.md`, `docs/AGENT-WORKFLOW.md` | `scripts/create-harness.sh` | `docs/WORKFLOW-MANUAL.md` scaffold 섹션, `README.md` §10 | dry-run + fresh generation, generated command/skill/rule | 관련 Work |
| `.claude/commands/{x}.md` ↔ `.agents/skills/workflow-{x}/SKILL.md` mirror pair 변경 | `docs/HARNESS-PROTOCOL.md`, `docs/AGENT-WORKFLOW.md` | 대응 pair 전체 | `docs/HARNESS-QUICK-REFERENCE.md`, 관련 `docs/WORKFLOW-MANUAL.md` 섹션 | scaffold 복사 산출물 | 관련 Work/retrospective |
| `.claude/commands/repo-health.md` 또는 `.agents/skills/workflow-repo-health/SKILL.md` 변경 | `docs/AGENT-WORKFLOW.md` | SKILL mirror (또는 command mirror) | `docs/HARNESS-QUICK-REFERENCE.md` `/repo-health` 행, `docs/WORKFLOW-MANUAL.md` §5 `/repo-health` 셀 | scaffold 복사 산출물 health command/skill | — |
| `tools/git-hooks/**` 변경 | `docs/HARNESS-PROTOCOL.md` hook trigger section, `docs/AGENT-WORKFLOW.md` commit approval | `tools/git-hooks/install.sh` (설치 script), `tools/git-hooks/lib/gate-lists.sh` (protected 목록), `.harness/gate-config` | `docs/WORKFLOW-MANUAL.md` hook section, `docs/HARNESS-QUICK-REFERENCE.md` | `scripts/create-harness.sh` hook installation block | 관련 Work |
| **gate path-list parity** — `tools/git-hooks/lib/gate-lists.sh` · `.claude/rules/git-workflow.md` · `docs/GIT-WORKFLOW.md` · `scripts/templates/source-gitflow/docs/GIT-WORKFLOW.md` · `scripts/create-harness.sh` gate-config seed 중 변경 | `docs/AGENT-WORKFLOW.md` commit approval, branch isolation | `tools/git-hooks/lib/gate-lists.sh` (SSoT), `.claude/rules/git-workflow.md` | `docs/GIT-WORKFLOW.md` | `scripts/templates/source-gitflow/docs/GIT-WORKFLOW.md`, `scripts/create-harness.sh` gate-config seed | 관련 Work |

> **gate parity 실행 pointer:** 위 `gate path-list parity` 행의 5 surface 중 하나라도 변경되면 `docs/maintainer/VERIFICATION-COMMANDS.md` **Layer Q-static**(protected semantic-key matrix / finalization policy / seed section·add-only — Axis A/B/C)을 실행한다. grep 명령은 catalog에만 두고 여기엔 pointer만 둔다(중복 금지).
> **LIVE_TARGETS 경계:** `.harness/gate-config`는 source repo에 존재하지 않으므로(scaffold target 전용, create-harness.sh가 seed) 아래 LIVE_TARGETS에 추가하지 않는다 — phantom path 방지. scaffold-target의 gate-config 실동작은 Tier2/OB7(`VERIFICATION-COMMANDS.md`)가 커버한다.
> **runner 연계(F4):** gate parity의 executable 동반자는 `scripts/tests/run-harness-checks.sh`이나 현재 runner는 Q-static을 호출하지 않는다 — 통합은 후속 F4.

## Required Grep Pack

변경 파일 유형에 맞는 키워드를 골라 실행하고, 결과가 없으면 "no matches"로 보고한다.
기본 grep 대상은 live surface로 제한한다. `docs/archive/`, `docs/retrospectives/`, `docs/briefs/`, `docs/presentations/`, 과거 계획 snapshot은 변경 파일에 포함되었거나 사용자가 historical review를 요청한 경우에만 별도 검색한다.

```bash
# Live target set
LIVE_TARGETS=(
  AGENTS.md CLAUDE.md README.md
  docs/AGENT-WORKFLOW.md docs/HARNESS-PROTOCOL.md docs/HARNESS-QUICK-REFERENCE.md docs/WORKFLOW-MANUAL.md docs/STATUS.md
  docs/maintainer/migrations/canonical-adapter-rename.md
  docs/backlog docs/decisions docs/works
  .agents .codex .claude .cursor prompts scripts tools
)

# Common stale path / old term check
rg -n "State Update Gate|Commit Gate|Scope And Commit Approval|docs/harness-protocol|harness-protocol/" \
  "${LIVE_TARGETS[@]}"

# Command / rule / prompt alignment
rg -n "Approval Matrix|Quick Mode|Active Work|Done|Archived|/work-close|/session-summary|/repo-health|/record-decision|--cascade" \
  "${LIVE_TARGETS[@]}"

# User-facing drift
rg -n "/session-start|/work-select|/work-plan|/work-resume|/work-close|/session-summary|/repo-health|/record-decision|Quick Mode|Approval Matrix|cascade|scaffold" \
  docs/WORKFLOW-MANUAL.md docs/HARNESS-QUICK-REFERENCE.md README.md

# Scaffold drift
if test -f scripts/create-harness.sh; then
  rg -n "HARNESS-PROTOCOL|AGENT-WORKFLOW|WORKFLOW-MANUAL|Quick Mode|Approval Matrix|/repo-health|/record-decision|--cascade" \
    scripts/create-harness.sh
else
  echo "skip: scripts/create-harness.sh not present in this repository"
fi

# State / tracking finalization
rg -n "STATUS Finalization|Tracking Finalization|Active Work|status: Done|status: Active" \
  "${LIVE_TARGETS[@]}"

# Branch / scaffold policy
# source-gitflow 체크는 GIT-WORKFLOW.md 또는 scripts/templates/** 변경 시, 또는 --full/--cascade 실행 시 적용한다.
# default scaffold 기준 점검에서는 이 결과가 guarded implementation surface(commands/skills/rules)에
# 나타나는 것은 정상이며, user-facing policy 문서에 누출되는지만 확인한다.
rg -n "source-gitflow|policy_type: source-gitflow|Public Clean Baseline Gate|pre-commit" \
  docs/STATUS.md docs/BOOTSTRAP.md docs/PLAN-SUMMARY.md \
  docs/WORKFLOW-MANUAL.md docs/HARNESS-QUICK-REFERENCE.md README.md 2>/dev/null \
  && echo "WARN: check whether above are policy leakage or expected references" \
  || echo "no matches in user-facing policy docs"

# Context / load path — workflow context weight 점검
# command/skill/prompt이 trigger 없이 heavy docs를 상시 로드하도록 지시하지 않는지 확인한다.
rg -n "HARNESS-PROTOCOL|WORKFLOW-MANUAL|항상.*읽|전체.*로드|기본.*로드|always.*load" \
  .claude/commands/ .agents/skills/ prompts/ 2>/dev/null
```

Historical matches are not automatically drift. Report them separately as snapshot references unless they appear in live execution, guide, or scaffold surfaces.

## Required Simulation Matrix

| 변경 파일 유형 | 반드시 시뮬레이션할 흐름 |
| --- | --- |
| Canonical workflow/protocol | `/session-start`, `/work-select`, `/work-plan`, `/work-resume`, `/work-close`, `/session-summary`, archive trigger, state-change proposal, quick mode, scaffold |
| Command/rule/prompt | 해당 command 흐름, `/work-plan`, `/work-resume`, `/session-summary`, state-change proposal, tool surface cascade, scaffold |
| User-facing manual/quick reference/README | 사용자 설명과 실제 command/canonical 흐름 대조, quick mode, close/session-summary, scaffold |
| Scaffold source | 신규 프로젝트 scaffold, 기존 프로젝트 adoption, generated command/rule/prompt/manual 경로 검색 |
| Work/status/backlog/DR | `/session-start`, `/work-select`, `/work-plan`, `/work-resume`, `/work-close`, archive trigger, STATUS update gate |
| `docs/GIT-WORKFLOW.md` 또는 branch policy 변경 | source repo `develop`에서 Branch Isolation FAIL, `feature/*`에서 PASS; default scaffold에서 marker 없음 → gate 비활성화 |
| `scripts/create-harness.sh` 또는 `scripts/templates/**` 변경 | default scaffold 생성 — `docs/GIT-WORKFLOW.md` 미생성·source-gitflow marker 없음; source-gitflow scaffold 생성 — marker 있음·source-repo-only 참조 없음 |
| Workflow Context Weight (--full / --cascade) | session startup clean idle → STATUS current만 읽고 archive/history 미확장; `/work-plan` backlog candidate → Work ID 확정 필요 정보만; `/work-resume` → Work/STATUS/file state 우선, unrelated backlog·manual 기본 로드 없음; `/work-close` feature branch → Done 처리와 commit strategy 분리, release gate detail 불필요 시 skip; commit/PR finalization → STATUS/Tracking finalization 수행, 전체 protocol 반복 로드 없음; scaffold onboarding → STATUS Next Actions pointer 없이 BOOTSTRAP.md 자동 로드 없음 |

선택하지 않은 시나리오는 `Skipped / Not Applicable`에 이유를 적는다.

## Inspection Areas

### G. Cascade/Trigger Completeness (--cascade)

문서를 하나 고쳤을 때 어디까지 같이 봐야 하는지 점검한다.
기준은 `docs/HARNESS-PROTOCOL.md`이며, 실제 command/rule/prompt/manual/scaffold 표면이 이 기준을 필요한 만큼 반영하는지 확인한다.

- 변경된 파일을 Required Surface Matrix의 파일 유형으로 분류한다.
- 해당 행의 canonical / tool-specific / user-facing / scaffold / historical surface를 확인한다.
- Required Grep Pack에서 관련 명령을 실행하거나, 실행하지 않은 이유를 기록한다.
- Required Simulation Matrix에서 관련 흐름을 선택해 논리 시뮬레이션한다.
- scaffold source가 있고 그 파일이 바뀌었으면 `scripts/create-harness.sh --dry-run`과 필요 시 temp scaffold 생성으로 산출물 drift를 확인한다. scaffold source가 없는 적용 repository에서는 이 항목을 Skipped / Not Applicable로 보고한다.
- historical retrospective는 snapshot인지 live follow-up log인지 구분한다. snapshot이면 기존 내용을 덮어쓰지 않고 append 제안만 한다.
- 반복 문구를 다음으로 분류한다:
  - Required mirror — 도구 진입점에서 반드시 보여야 하는 반복
  - Acceptable reminder — 사용자 실수를 줄이는 짧은 반복
  - Excessive duplication — 같은 layer 안에서 의미 없이 반복되는 문구
  - Stale contradiction — canonical과 충돌하는 오래된 문구
- trigger/cascade 변경 시 loop risk를 확인한다:
  - 같은 문서군을 서로 재발동시키는가
  - Approval Matrix state rules를 우회하는가
  - Product track Quick Mode와 harness/workflow surface 기본 L2 경계를 흐리게 만드는가
  - scaffold 검증이 자기 자신을 무한히 요구하는가

Coverage rule:

- `--cascade`는 changed-surface 기준으로 범위를 줄일 수 있지만, 선택한 파일 유형의 layer coverage는 유지한다.
- `--full --cascade`는 전체 surface 감사이며 범위를 임의로 줄이지 않는다.
- 선택하지 않은 surface, grep, simulation은 반드시 `Skipped / Not Applicable`에 이유를 남긴다.
- 판단이 애매하면 통과 처리하지 말고 `Requires manual judgment`로 보고한다.
