---
id: HRN-038
priority: P2
status: Active
risk: L2
scope: AGENTS.md thin entrypoint 정비 — 중복 rule 제거 및 skill routing pointer로 교체
appetite: 0.5d
planned_start: 2026-05-27
planned_end: 2026-05-27
actual_end:
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
| Document Language Policy | 유지 (English Only rule만 inline, Bilingual Rules 삭제 후 DR-007 pointer) | path-scoped 미로딩 이슈 — English Only는 inline 필수. Bilingual Rules 상세는 DR-007 pointer로 충분 |
| Branch Flow | 유지 (현행과 동일) | Codex-specific 로드 트리거 |
| Git Commit Format | 제거 → Entry Contract 또는 Branch Flow에 1줄 pointer | `docs/GIT-WORKFLOW.md` §5가 canonical |
| Command Intent Recognition | 제거 | `docs/AGENT-WORKFLOW.md`에 있음 |
| Approval Matrix State Rules | 제거 | `docs/AGENT-WORKFLOW.md`에 있음 |
| Failure And Recovery | 제거 → Entry Contract에 1줄 pointer | `docs/HARNESS-PROTOCOL.md`에 있음 |

### Codex Skill Routing 새 표현 (예시)

```
## Codex Skill Routing

When a workflow command is invoked or its intent is matched,
load `.agents/skills/workflow-{name}/SKILL.md` and follow the procedure.
Skill name maps directly to command name (e.g., `/start` → `workflow-start`).

Available skills: start, pick, register, work, resume, close, done, health, debug, doc, record-decision
```

### prompts/codex-session-start.md 갱신 방향

현재: `AGENTS.md Codex Command Mapping의 /start 절차에 따라 세션을 시작해줘.`
변경: `AGENTS.md skill routing에 따라 \`.agents/skills/workflow-start/SKILL.md\`를 로드하고 /start 절차에 따라 세션을 시작해줘.`

동일 패턴을 모든 command 참조 (~12개)에 적용한다.
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

- `bash -n scripts/create-harness.sh`
- scaffold 산출 AGENTS.md 확인 (dry-run 또는 grep)
- 필요 시 scaffold template 수정 및 dry-run 재검증

### Step 5 — Validation

```bash
rg "Codex Command Mapping|AGENTS.md command index|Failure And Recovery 절차" \
  AGENTS.md docs prompts .agents .claude .cursor scripts
git diff --check
bash -n scripts/create-harness.sh
```

잔여 참조가 없으면 통과.

## Done Criteria

- [ ] `AGENTS.md`에서 Command Intent Recognition, Approval Matrix State Rules, Git Commit Format 섹션 제거 완료.
- [ ] `AGENTS.md` Codex Command Mapping이 skill routing pointer로 교체됨.
- [ ] `AGENTS.md` Document Language Policy가 English Only rule + DR-007 pointer로 축약됨.
- [ ] `AGENTS.md` Failure And Recovery가 1줄 pointer로 축약됨.
- [ ] `prompts/codex-session-start.md`의 "AGENTS.md Codex Command Mapping의 /{command} 절차" 참조가 skill 경로 직접 표현으로 갱신됨.
- [ ] `docs/HARNESS-PROTOCOL.md` cascade 테이블 "AGENTS.md command index" 2곳 갱신됨.
- [ ] scaffold 확인 완료 (변경 있으면 반영, 없으면 Not Applicable).
- [ ] `rg` 잔여 참조 없음 확인.
- [ ] `git diff --check` 통과.

## Open Questions

| ID | Question | Decision Needed |
| --- | --- | --- |

## Checkpoints

| CP | Description | Status |
| --- | --- | --- |
| CP-1 | Work 파일 작성 및 착수 등록 | Done |
| CP-2 | AGENTS.md 축소 + cascade 3종 패치 | Pending |
| CP-3 | Validation 및 잔여 참조 확인 | Pending |

## Discovery

- 2026-05-26: HRN-037 정합성 패치 중 AGENTS.md가 thin entrypoint 선언과 달리 여전히 6개 섹션을 직접 보유하고 있음을 확인. prompts/codex-session-start.md가 "AGENTS.md Codex Command Mapping" 표현을 12회 이상 직접 참조하여 cascade 범위가 예상보다 넓음.
