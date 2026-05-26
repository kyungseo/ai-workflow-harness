---
id: HRN-038
priority: P2
status: Archived
risk: L2
scope: AGENTS.md thin entrypoint 정비 — 중복 rule 제거 및 skill routing pointer로 교체
appetite: 0.5d
planned_start: 2026-05-27
planned_end: 2026-05-27
actual_end: 2026-05-27
related_dr: [DR-007]
related_commits: []
related_troubleshooting: []
---

# HRN-038: AGENTS.md Thin Entrypoint 정비

## Context

`.agents/skills/workflow-*` 도입 이후 AGENTS.md가 여전히 command mapping table,
Command Intent Recognition, Approval Matrix State Rules, Git Commit Format,
Document Language Policy Bilingual Rules, Failure And Recovery 절차를 직접 들고 있다.

`CLAUDE.md`는 thin entrypoint로 유지되고 있다. `AGENTS.md`도 같은 수준으로 줄이고
shared rule은 `docs/AGENT-WORKFLOW.md`와 `.agents/skills/`로 위임하는 것이 맞다.

현재 `AGENTS.md`는 122줄. `CLAUDE.md` 수준(40줄 내외)으로 줄이는 것이 목표다.

## Problem Statement

| 섹션 | AS-IS | 문제 |
| --- | --- | --- |
| Codex Command Mapping | 11-command 상세 table | `.agents/skills/` 1:1 mapping이 생겼는데 table을 별도 유지 — drift 위험 |
| Command Intent Recognition | 4-row table | `docs/AGENT-WORKFLOW.md`와 `.claude/rules/docs-workflow.md`에 동일 내용 — 중복 |
| Approval Matrix State Rules | 2개 table + routing table | `docs/AGENT-WORKFLOW.md` 중복 — MUST 조항에 "Follow Approval Matrix" 포인터만 있으면 됨 |
| Git Commit Format | type/subject/body 상세 규칙 | `docs/GIT-WORKFLOW.md` §5, `.claude/rules/git-workflow.md` 중복 |
| Document Language Policy | English Only + Bilingual Rules 전체 | English Only inline rule은 path-scoped 미로딩 문제로 필요하나 Bilingual Rules 상세는 DR-007로 위임 가능 |
| Failure And Recovery | 보고 형식 상세 + 절차 | `docs/HARNESS-PROTOCOL.md`에 있음 — 1줄 pointer로 축약 가능 |

## Goal

`AGENTS.md`를 `CLAUDE.md` 수준의 thin entrypoint로 축소한다.
Codex-specific rule만 남기고, 나머지는 canonical docs로 위임한다.

## Scope

### In Scope

- `AGENTS.md` — 중복 섹션 제거 및 routing pointer로 교체
- `prompts/codex-session-start.md` — "AGENTS.md Codex Command Mapping의 /{command} 절차" 표현 갱신
- `docs/HARNESS-PROTOCOL.md` cascade 테이블 — "AGENTS.md command index" → "AGENTS.md skill routing pointer"
- `scripts/create-harness.sh` — scaffold AGENTS.md 출력에 동일 변경 반영 여부 확인

### Out Of Scope

- ID rule 변경
- `.agents/skills/` 내용 변경
- `docs/AGENT-WORKFLOW.md` 내용 변경
- Gitflow 전략 변경

## Proposed Design

### TO-BE AGENTS.md 섹션 구조

| 섹션 | 처리 방향 | 근거 |
| --- | --- | --- |
| Entry Contract | 유지 (현행과 동일) | Codex 진입 계약의 core |
| Codex Skill Routing | 유지 (table 제거, routing rule만) | Codex-specific: 어떤 skill 파일을 로드할지 지침 필요 |
| Document Language Policy | **수정** — English Only inline + "문서/prompt/command/rule/hook 편집 시 DR-007 확인" trigger inline 유지. Bilingual Rules 상세만 DR-007 pointer로 교체 | path-scoped 미로딩 이슈 — English Only와 DR-007 edit trigger는 inline 필수. 과거 Codex/Cursor drift 재발 방지 |
| Branch Flow | **trim** — "branch/PR/merge intent 시 GIT-WORKFLOW.md §2-§3 로드" + "feature를 main에 직접 PR 금지" guard만 남김. 나머지 NEVER 목록 제거 | Codex의 강한 on-demand trigger이므로 섹션 유지. 단 상세 금지 목록 반복은 thin entrypoint 취지에 맞지 않음 |
| Git Commit Format | 제거 → Branch Flow에 1줄 pointer ("commit format: docs/GIT-WORKFLOW.md §5") | `docs/GIT-WORKFLOW.md` §5가 canonical. canonical coverage 확인 후 제거 |
| Command Intent Recognition | 제거 | `docs/AGENT-WORKFLOW.md`에 있음 |
| Approval Matrix State Rules | 제거 | `docs/AGENT-WORKFLOW.md`에 있음 |
| Failure And Recovery | 제거 → Entry Contract에 1줄 pointer. canonical coverage(`docs/HARNESS-PROTOCOL.md`) 확인 후 제거 | `docs/HARNESS-PROTOCOL.md`에 있음 |

### Codex Skill Routing 새 표현 (예시)

```
## Codex Skill Routing

When a workflow command is invoked or its intent is matched,
load `.agents/skills/workflow-{name}/SKILL.md` and follow the procedure.
Skill name maps directly to command name (e.g., `/start` → `workflow-start`).

Available skills: start, pick, register, work, resume, close, done, health, debug, doc, record-decision
```

### prompts/codex-session-start.md 갱신 방향

skill 경로를 각 prompt에 하드코딩하면 skill naming 변경 시 prompt 전체가 다시 drift된다.
대신 AGENTS.md의 routing rule을 참조하는 표현을 사용한다.

현재: `AGENTS.md Codex Command Mapping의 /start 절차에 따라 세션을 시작해줘.`
변경: `AGENTS.md Codex Skill Routing에 따라 /start에 대응하는 workflow skill을 로드하고 절차를 수행해줘.`

동일 패턴을 모든 command 참조 (~12개)에 적용한다.
`/start → workflow-start` 같은 mapping 예시는 AGENTS.md Codex Skill Routing 섹션에 1회만 둔다.
"AGENTS.md Failure And Recovery 절차" 참조는 `docs/HARNESS-PROTOCOL.md`의 Failure 처리 절차를 따르는 표현으로 변경한다.

### HARNESS-PROTOCOL.md cascade 테이블

현재 2곳:
- line 506: `.claude/commands/*.md` cascade에 `AGENTS.md command index` → `AGENTS.md skill routing pointer`
- line 507: `.agents/skills/*/SKILL.md` cascade에 `AGENTS.md command index` → `AGENTS.md skill routing pointer`

### scripts/create-harness.sh

scaffold 산출 AGENTS.md에 동일 thin 구조가 반영되는지 확인한다.
변경이 필요하면 scaffold template 내 AGENTS.md 생성 로직을 수정한다.

## Plan

### Step 1 — AGENTS.md 축소

- 섹션별 제거/유지/교체 적용
- 목표 분량: 50줄 내외

### Step 2 — prompts/codex-session-start.md 갱신

- "AGENTS.md Codex Command Mapping의 /{command} 절차" → skill 경로 명시 표현으로 교체
- "AGENTS.md Failure And Recovery 절차" 참조 갱신

### Step 3 — HARNESS-PROTOCOL.md cascade 테이블 갱신

- "AGENTS.md command index" 2곳 → "AGENTS.md skill routing pointer"

### Step 4 — Scaffold 확인 및 갱신

- `scripts/create-harness.sh`는 AGENTS.md를 source에서 복사하므로 AGENTS.md 변경은 scaffold 산출물에 자동 반영 가능성이 높음
- `bash -n scripts/create-harness.sh` + dry-run으로 확인
- `prompts/codex-session-start.md`, `docs/HARNESS-PROTOCOL.md`, generated README/manual에 old phrase 잔여 여부를 targeted `rg`로 확인
- 잔여 있으면 수정, 없으면 Not Applicable

### Step 5 — Validation

```bash
rg "Codex Command Mapping|AGENTS\.md command index" \
  AGENTS.md docs prompts .agents .claude .cursor scripts
# "Failure And Recovery 절차"는 docs/HARNESS-PROTOCOL.md pointer 표현으로 prompts에 남아 있는 것이 정상
rg "AGENTS\.md Failure And Recovery 절차" \
  AGENTS.md docs prompts .agents .claude .cursor scripts
git diff --check
bash -n scripts/create-harness.sh
```

stale live references(운영 파일 내 구 표현)가 없으면 통과. Work 파일 내 이력 기록과 `docs/HARNESS-PROTOCOL.md`를 명시한 새 표현은 허용.

## Done Criteria

- [x] `AGENTS.md`에서 Command Intent Recognition, Approval Matrix State Rules, Git Commit Format 섹션 제거 완료.
- [x] `AGENTS.md` Codex Command Mapping이 skill routing pointer로 교체됨.
- [x] `AGENTS.md` Document Language Policy가 English Only rule + DR-007 pointer로 축약됨.
- [x] `AGENTS.md` Failure And Recovery가 1줄 pointer로 축약됨.
- [x] `prompts/codex-session-start.md`의 "AGENTS.md Codex Command Mapping의 /{command} 절차" 참조가 `AGENTS.md Codex Skill Routing` 참조 표현으로 갱신됨.
- [x] `docs/HARNESS-PROTOCOL.md` cascade 테이블 "AGENTS.md command index" 2곳 갱신됨.
- [x] scaffold 확인 완료 — `adapt "${TEMPLATE_ROOT}/AGENTS.md"` 패턴으로 source 직접 복사. stale phrase 없음. Not Applicable (별도 scaffold 변경 불필요).
- [x] `rg` stale live references 없음 확인 — Work 파일 내 이력 기록 및 `prompts`의 의도된 새 표현(`docs/HARNESS-PROTOCOL.md의 Failure And Recovery 절차`)은 제외.
- [x] `git diff --check` 통과.
- [x] 행동 gap 없음 시뮬레이션 통과 — `/start`, `/work`, `/close`, branch/PR intent, document edit intent에서 AGENTS.md 축소 후에도 Codex가 기존과 같은 판단을 한다.

## Open Questions

| ID | Question | Decision Needed |
| --- | --- | --- |

## Checkpoints

| CP | Description | Status |
| --- | --- | --- |
| CP-1 | Work 파일 작성 및 착수 등록 | Done |
| CP-2 | AGENTS.md 축소 + cascade 3종 패치 | Done |
| CP-3 | Validation 및 잔여 참조 확인 | Done |

## Discovery

- 2026-05-26: HRN-037 정합성 패치 중 AGENTS.md가 thin entrypoint 선언과 달리 여전히 6개 섹션을 직접 보유하고 있음을 확인. prompts/codex-session-start.md가 "AGENTS.md Codex Command Mapping" 표현을 12회 이상 직접 참조하여 cascade 범위가 예상보다 넓음.
- 2026-05-27: 작업 완료. archive 처리.

## Codex Review Opinion

2026-05-27 Codex 검토 의견:

- HRN-038로 승격한 범위는 적절하다. `AGENTS.md`는 tool-specific entrypoint로 남고, 실제 workflow 절차는 `.agents/skills/workflow-*`와 canonical docs로 위임하는 방향이 맞다.
- `Document Language Policy` 축약은 신중해야 한다. `STATUS.md` Recent Decisions에 따르면 Codex/Cursor가 DR-007을 놓치는 구조적 결함 때문에 `AGENTS.md`에 inline rule을 넣었던 이력이 있다. 따라서 Bilingual Rules 상세를 삭제하더라도, 최소한 "문서/prompt/command/rule/hook message 편집 시 DR-007을 확인한다"는 trigger는 `AGENTS.md`에 남겨야 한다. English Only 대상도 `AGENTS.md`, `CLAUDE.md`, `.claude/rules/*.md`, `.cursor/rules/*.mdc` 정도는 inline 유지가 안전하다.
- `Branch Flow`는 "Codex-specific"이라기보다는 Codex가 과거 PR base/develop sync를 놓치지 않게 하는 강한 on-demand trigger다. 섹션을 유지하되 상세 금지 목록을 길게 반복하기보다 "branch/PR/merge intent 시 `docs/GIT-WORKFLOW.md` §2-§3 로드"와 "feature branch를 main에 직접 PR하지 않음" 정도의 guard만 남기는 편이 thin entrypoint 취지와 맞다.
- `prompts/codex-session-start.md`의 새 표현은 너무 긴 절대 절차를 12회 반복하지 않는 쪽을 권한다. 각 prompt마다 `.agents/skills/workflow-{name}/SKILL.md` 경로를 직접 쓰면 향후 skill naming 변경 시 prompt 전체가 다시 drift된다. 더 나은 문구는 "AGENTS.md Codex Skill Routing에 따라 `/start`에 대응하는 workflow skill을 로드"처럼 routing rule을 참조하되, 최초 1곳에만 mapping 예시(`/start` -> `workflow-start`)를 둔다.
- `scripts/create-harness.sh`는 AGENTS.md를 source에서 복사하므로 AGENTS.md 자체 변경은 scaffold 산출물에 반영될 가능성이 높다. 다만 `prompts/codex-session-start.md`, `docs/HARNESS-PROTOCOL.md`, generated README/manual에 남은 old phrase가 없는지는 dry-run 또는 targeted `rg`로 확인해야 한다.
- `docs/AGENT-WORKFLOW.md`를 Out Of Scope로 둔 것은 일단 타당하다. 단, AGENTS.md에서 제거한 내용 중 canonical에 없는 trigger가 발견되면 scope expansion으로 보고하고 승인 후 최소 보강해야 한다. 특히 commit format pointer, DR-007 edit trigger, failure recovery pointer는 canonical coverage를 확인한 뒤 제거해야 행동 gap이 없다.
- Done Criteria에 "AGENTS.md를 줄인 뒤에도 Codex가 `/start`, `/work`, `/close`, branch/PR intent, document edit intent에서 기존과 같은 판단을 한다"는 시뮬레이션 항목을 추가하는 것을 권한다. 이 작업의 핵심은 줄 수가 아니라 행동 gap 없음이다.
