# cross-review

Canonical workflow procedure for `/cross-review`.

이 파일은 multi-agent review를 **선택적으로** 운영하기 위한 relay 절차의 SSoT다.
Tool-specific surface는 아래 adapter만 가진다.

| Tool | Adapter |
| --- | --- |
| Claude Code | `.claude/commands/cross-review.md` |
| Codex | `.agents/skills/workflow-cross-review/SKILL.md` |
| Antigravity | Codex adapter 재사용: `.agents/skills/workflow-cross-review/SKILL.md` |
| Cursor | `.cursor/rules/workflow.mdc` |

Adapter는 Step 0, hard-stop 요약, entry mechanism만 보유한다. 상세 절차, checklist, cascade 판단은 이 canonical 파일을 따른다.

## Boundary

`/cross-review`는 review relay protocol이다. 기본 workflow gate가 아니다.

### Manual Relay Limit

`/cross-review`는 **manual relay protocol**이다.
agent 간 메시지 전달, reviewer 호출, 응답 수집, round 진행을 자동화하지 않는다.
사용자가 여전히 packet을 다른 agent에게 전달하고, reviewer 응답을 다시 driver에게 가져와야 한다.

이 workflow가 줄이는 것은 전달 노동 자체가 아니라 아래의 즉흥성이다.

- relay packet 구성 방식
- reviewer의 red-team posture 누락
- finding과 driver response 기록 방식
- user decision gate로 올릴 쟁점의 분류

agent 간 자동 전달, durable orchestration, tool 간 runtime coordination이 필요하면 이 workflow가 아니라 별도 orchestration 후보로 다룬다.

MUST:

- 사용자가 cross-agent review를 요청했거나 Work plan/Done Criteria가 cross-review를 명시한 경우에만 사용한다.
- 단순히 "review"나 "red-team"을 언급했다는 이유만으로 자동 기동하지 않는다. 명시적 `/cross-review` 호출 또는 cross-agent review relay 작성/수신 요청이 있어야 한다.
- agent 이름이 아니라 역할로 표현한다: `driver`, `reviewer`, `specialist`, `arbiter/user`.
- review 라운드와 합의는 Work 파일 또는 대상 문서의 `Cross-Agent Review And Discussion`에 누적한다. 이는 `SOURCE-REPO-OPERATIONS.md`의 `Cross-Agent Review` 섹션 관례와 같은 대상이다.
- reviewer 기록은 가능한 한 변조하지 않고, driver response를 별도로 남긴다.
- Approval Matrix를 우회하지 않는다. scope expansion, state change, Work Done, commit, PR, merge는 기존 승인 규칙을 따른다.

MUST NOT:

- 모든 작업에 cross-agent review를 강제하지 않는다.
- 특정 tool을 고정 역할로 박지 않는다. 예: "Claude는 항상 reviewer", "Codex는 항상 driver" 금지.
- reviewer 의견을 자동 적용하지 않는다. driver가 `accept / revise / defend / needs-user` 중 하나로 응답한다.
- user decision이 필요한 쟁점을 agent끼리 닫지 않는다.

## Role Defaults

| Role | 기본 태도 | 책임 |
| --- | --- | --- |
| Driver | author/owner. 범위·근거·변경 책임을 진다 | relay packet 작성, reviewer finding 분류, 수정/방어/사용자 결정 요청 |
| Reviewer | red-team. 내적 정합성뿐 아니라 방향 자체를 의심한다 | 설계 방향, evidence, scope, hidden cost, reversal cost, 누락 검토 |
| Specialist | 특정 영역 검토자. 필요한 경우에만 추가한다 | 보안, 배포, UX, docs IA 등 제한된 관점의 finding 제공 |
| Arbiter/User | 최종 승인자 | 방향 선택, scope 확장, state change, commit/merge 승인 |

Reviewer는 "잘 썼는지"보다 "틀렸을 가능성"을 먼저 본다.
특히 아래를 확인한다.

- 방향 자체가 옳은가
- 전제와 evidence가 충분한가
- scope가 과하거나 부족하지 않은가
- hidden cost, rollback, migration, cascade가 빠지지 않았는가
- 기존 Approval Matrix나 source/scaffold/product 경계를 우회하지 않는가

Driver는 reviewer finding을 자동 수용하지 않고 아래 중 하나로 응답한다.

| Decision | Meaning |
| --- | --- |
| `accept` | 그대로 반영한다 |
| `revise` | 취지는 수용하되 다른 방식으로 고친다 |
| `defend` | 반영하지 않고 근거를 기록한다 |
| `needs-user` | user decision gate로 올린다 |

## Round State Machine

```text
INIT -> REQUEST -> REVIEW -> DRIVER_RESPONSE -> DECISION_GATE -> NEXT_ROUND or CLOSE
```

기본 라운드 수는 고정하지 않는다. Work plan 또는 user request가 `max_rounds`를 정할 수 있다.
정하지 않으면 보통 plan review 1회 + result review 1회를 권장한다.

Hard-stop 또는 user decision gate:

- reviewer가 P0/P1 또는 must-fix를 제기했고 driver가 defend하려는 경우
- reviewer가 scope expansion, Work 분해, DR, STATUS 변경, commit/merge 보류를 요구하는 경우
- reviewers 간 결론이 충돌하는 경우
- `max_rounds`에 도달했지만 convergence가 없는 경우
- Approval Matrix상 사용자 승인이 필요한 state change가 생긴 경우

## Procedure

### Minimal Path

2자 1라운드의 가벼운 review라면 아래 3개만 사용해도 된다.

1. `Cross-Agent Relay Packet`
2. `Reviewer Findings`
3. `Driver Response`

`Round Log`와 `Consensus Log`는 여러 reviewer, 여러 round, 또는 나중에 합의 과정을 복구해야 하는 Work에서 사용한다.

### 1. Start

대상과 역할을 정한다.

```markdown
## Cross-Review Setup

Target:
- file/path or PR/work item:

Purpose:
- plan review / result review / brief red-team / implementation review / closeout review

Participants:
- Driver:
- Reviewer(s):
- Specialist(s), optional:
- Arbiter/User:

Max Rounds:
- default: plan 1 + result 1, unless user asks otherwise

Non-Goals:
- ...
```

### 2. Request

reviewer에게 보낼 relay packet을 만든다.

```markdown
## Cross-Agent Relay Packet

Role:
- Driver:
- Reviewer:
- Arbiter/User:

Target:
- ...

Current State:
- branch/status:
- relevant files:
- validation so far:

Delta Since Last Round:
- ...

Review Objective:
- ...

Must Check:
1. ...
2. ...
3. ...

Do Not Re-litigate:
- ...

Reviewer Posture:
- Red-team the direction, not only the prose.
- Question assumptions, priority, hidden cost, cascade, and rollback.
- Mark speculation as speculation.

Output Contract:
- Verdict: approve / conditional / request-changes / reject
- Must-fix findings
- Nice-to-have findings
- Residual risk
- Suggested wording, if needed
```

### 3. Ingest

reviewer 응답을 받으면 finding table로 정리한다.

```markdown
## Reviewer Findings

| ID | Severity | Finding | Evidence | Recommendation |
| --- | --- | --- | --- | --- |
| Rn-RevA-F1 | P1/P2/P3 | ... | ... | ... |

Verdict:
- approve / conditional / request-changes / reject
```

reviewer 원문을 보존해야 하는 Work라면 원문을 먼저 붙이고, 정리는 별도 `Driver Triage`로 둔다.
reviewer가 여러 명이면 finding ID에 reviewer key를 포함한다. 예: `R0-RevA-F1`, `R0-RevB-F1`.

### 4. Respond

driver response를 작성한다.

```markdown
## Driver Response

| Finding | Decision | Response | Follow-up |
| --- | --- | --- | --- |
| Rn-F1 | accept / revise / defend / needs-user | ... | ... |
```

`needs-user`가 하나라도 있으면 다음 단계로 넘어가기 전에 user decision gate를 출력한다.

### 5. User Decision Gate

```markdown
## User Decision Needed

Reason:
- ...

Options:
1. ...
2. ...
3. ...

Recommended:
- ...

Impact:
- Scope:
- Risk:
- Reversal cost:
```

사용자가 선택하기 전에는 관련 파일 수정, state change, commit/PR/merge를 진행하지 않는다.

### 6. Close Or Next Round

라운드를 닫을 때는 아래를 남긴다.

```markdown
## Round Log

| Round | Driver | Reviewer(s) | Objective | Verdict | Status |
| --- | --- | --- | --- | --- | --- |
| R0 | ... | ... | plan review | conditional | closed |

## Consensus Log

| Topic | Status | Notes |
| --- | --- | --- |
| ... | agreed / deferred / user-decided | ... |
```

다음 중 하나면 다음 라운드를 제안한다.

- result review가 아직 남음
- conditional approval의 must-fix 반영 여부 확인 필요
- reviewer 간 disagreement가 남음
- user가 추가 red-team을 요청함

## Validation And Closeout

`/cross-review` 자체는 Work Done 처리나 commit gate를 대체하지 않는다.
작업 완료 시에는 원래 workflow에 따라 `/work-close`, validation, STATUS/Tracking Finalization, commit approval을 별도로 수행한다.
