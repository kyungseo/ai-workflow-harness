# Cross-Review Manual

`/cross-review`는 두 개 이상의 AI agent를 연결해 review를 주고받을 때 쓰는 **선택적 relay workflow**다.
기본 process gate가 아니며, 모든 작업에 강제되지 않는다.

쉽게 말하면, 한 agent가 작업을 만든 뒤 다른 agent에게 "이 방향이 맞는지, 빠진 비용은 없는지, 위험한 전제가 없는지"를 물어보고, 그 답을 다시 driver가 정리해 사용자와 함께 닫는 절차다.

절차의 SSoT는 `skills/workflow/cross-review.md`다. 이 문서는 사용자가 언제, 어떤 방식으로 그 workflow를 쓰면 좋은지 설명하는 manual이다.

## What This Does Not Solve

`/cross-review`는 **manual relay protocol**이다.
agent orchestration이나 자동 handoff 기능이 아니다.

그래서 아래는 그대로 사용자 몫으로 남는다.

- 한 agent가 만든 relay packet을 다른 agent에게 전달하기
- reviewer 응답을 다시 driver에게 가져오기
- 다음 round를 돌릴지, 멈출지 결정하기
- commit, PR, merge 같은 lifecycle action 승인하기

이 workflow가 줄이는 것은 복붙 자체가 아니라 매번 즉흥으로 만들던 packet 형식, reviewer 태도, finding 정리, driver response 기록이다.
전달 자동화가 핵심 pain이라면 `/cross-review`가 아니라 별도 agent orchestration 후보로 검토해야 한다.

## Core Mechanism

| Element | Meaning |
| --- | --- |
| Driver | 작업을 진행하는 주 agent. plan, 구현, 문서, validation, reviewer 응답 처리를 맡는다. |
| Reviewer | 독립 검토자. 기본 태도는 red-team이다. 문장 정합성뿐 아니라 방향 자체와 숨은 비용을 의심한다. |
| Specialist | 필요할 때만 추가하는 특정 영역 검토자. 예: security, deployment, UX, docs IA. |
| Arbiter/User | 최종 판단자. scope 확장, 방향 선택, commit/PR/merge 승인은 사용자가 결정한다. |
| Relay Packet | reviewer에게 전달할 대상, 맥락, 검토축, 출력 형식을 묶은 요청문. |
| Findings | reviewer가 돌려주는 must-fix, nice-to-have, residual risk. |
| Driver Response | driver가 finding별로 `accept`, `revise`, `defend`, `needs-user` 중 하나로 응답한 기록. |
| Decision Gate | agent끼리 닫으면 안 되는 쟁점을 사용자 결정으로 올리는 지점. |

이 workflow는 사용자가 한 agent의 출력물을 다른 agent에게 전달해야 하는 상황에서, 전달 내용과 응답 정리를 표준화한다.

## When To Use

다음 상황에서 유용하다.

- 방향성 자체가 중요한 strategy brief, policy, architecture decision을 검토할 때
- 한 agent가 author/driver이고 다른 agent가 red-team reviewer 역할을 맡을 때
- PR 전 result review가 필요하지만, 리뷰어에게 보낼 맥락을 매번 새로 쓰기 귀찮을 때
- reviewer finding을 수용할지, 수정해 반영할지, 방어할지, 사용자 결정으로 올릴지 기록해야 할 때
- 2명 이상의 reviewer 또는 여러 round의 review 흐름을 나중에 복구해야 할 때

다음 상황에서는 보통 쓰지 않는다.

- 단순 오탈자, 짧은 문장 검토, 작은 code review
- 같은 agent 안에서 끝나는 일반 review
- 사용자가 명시적으로 cross-agent relay를 원하지 않는 경우
- commit/PR/merge gate를 대신하려는 경우

`red-team으로 봐줘`, `검토해줘` 같은 일반 표현만으로는 `/cross-review`가 자동 기동되지 않는다.
명시적으로 `/cross-review`를 호출하거나, "cross-agent review relay packet을 만들어줘/받은 reviewer 응답을 ingest해줘"처럼 relay를 요청해야 한다.

## Basic Flow

```text
Setup -> Relay Packet -> Reviewer Findings -> Driver Response -> User Decision Gate -> Close or Next Round
```

1. **Setup**
   - 대상 파일, Work, PR, brief를 정한다.
   - driver, reviewer, 필요 시 specialist를 정한다.
   - review 목적을 정한다. 예: plan review, result review, brief red-team.

2. **Relay Packet**
   - driver가 reviewer에게 전달할 prompt를 만든다.
   - 대상, 변경 요약, 현재 상태, 검증 결과, 반드시 볼 축, 재론하지 않을 범위를 넣는다.

3. **Reviewer Findings**
   - 사용자가 reviewer agent에 packet을 전달한다.
   - reviewer는 verdict, must-fix, nice-to-have, residual risk를 돌려준다.

4. **Driver Response**
   - driver가 finding별로 응답한다.
   - `accept`: 그대로 반영
   - `revise`: 취지는 수용하되 다른 방식으로 반영
   - `defend`: 반영하지 않고 근거 기록
   - `needs-user`: 사용자가 결정해야 함

5. **User Decision Gate**
   - P1을 방어하려는 경우, scope 확장, reviewer 간 충돌, commit/merge 보류 같은 쟁점은 사용자에게 올린다.
   - 사용자 선택 전에는 관련 state change를 진행하지 않는다.

6. **Close Or Next Round**
   - blocker가 닫히면 round를 종료한다.
   - conditional approval 확인, result review, reviewer disagreement가 남으면 다음 round를 제안한다.

## Minimal Path

가벼운 2자 1라운드 review라면 아래 3개만 있으면 된다.

1. `Cross-Agent Relay Packet`
2. `Reviewer Findings`
3. `Driver Response`

`Round Log`와 `Consensus Log`는 여러 reviewer, 여러 round, 또는 나중에 합의 과정을 추적해야 하는 작업에서만 쓰면 된다.

## How To Ask

target은 Work 파일, brief, PR, 코드 변경, 세션에서 방금 작성한 plan draft 등 어느 것이든 된다.
round log 저장 위치(Work 파일의 `Cross-Agent Review And Discussion`)와 review 대상(target)은 별개다.
reviewer의 red-team posture는 relay packet에 기본 포함되므로 invocation 프롬프트에 반복하지 않아도 된다.
custom focus, 재론 금지 범위, specialist 추가가 필요할 때만 명시한다.

### 필수 항목만

relay packet 생성 — 역할, 대상, review 종류만 지정한다:

```text
/cross-review 네가 driver, Codex가 reviewer야. 이 Work plan을 plan review로 시작해줘.
```

```text
/cross-review 네가 driver, Claude가 reviewer야. 방금 작성한 이 구현 계획을 plan review로 시작해줘.
```

```text
/cross-review 네가 driver, Codex가 reviewer야. 이 Work 결과물을 result review로 보낼 packet 만들어줘.
```

reviewer 응답 ingest:

```text
/cross-review 아래 reviewer 응답을 ingest해줘.
[reviewer 응답 붙여넣기]
```

follow-up round:

```text
/cross-review R0 must-fix 반영 확인만 하는 R1 follow-up packet 만들어줘.
```

### Custom Focus 포함

기본 red-team posture 외에 특정 축을 강조하거나, 재론 금지 범위를 지정하거나, specialist를 추가할 때 쓴다:

```text
/cross-review
네가 driver, Codex가 reviewer야.
docs/decisions/DR-042-....md를 plan review로 시작해줘.
custom focus: adopter namespace 충돌 영향과 scaffold cascade 누락을 집중적으로 봐줘.
재론 금지: DR-028 source-ref baseline 결정은 확정됨.
```

```text
/cross-review
네가 driver, Codex가 reviewer, Claude가 security specialist야.
이 구현 변경사항을 result review로 시작해줘.
specialist는 인증·세션 저장 방식만 봐줘.
```

## Reviewer Posture

Reviewer는 동의해주는 사람이 아니다.
기본 태도는 다음과 같다.

- 내적 정합성뿐 아니라 방향 자체를 의심한다.
- evidence가 약한 전제를 찾는다.
- priority가 과하거나 낮은지 본다.
- hidden cost, rollback cost, migration cost를 찾는다.
- cascade 누락과 scaffold/user-facing 영향 누락을 의심한다.
- Approval Matrix, source/scaffold/product 경계를 우회하지 않는지 본다.

좋은 reviewer output은 짧더라도 다음을 포함한다.

```markdown
Verdict: approve / conditional / request-changes / reject

Must-fix findings
- ID:
- Severity:
- Finding:
- Evidence:
- Recommendation:

Nice-to-have findings

Residual risk
```

## Driver Posture

Driver는 reviewer finding을 자동 수용하지 않는다.
각 finding에 대해 아래처럼 응답한다.

```markdown
| Finding | Decision | Response | Follow-up |
| --- | --- | --- | --- |
| R0-RevA-F1 | accept / revise / defend / needs-user | ... | ... |
```

Driver가 `defend`를 선택할 수는 있지만, P0/P1이나 scope expansion을 방어하려면 사용자에게 먼저 결정권을 올리는 편이 안전하다.

## Multi-Reviewer And Multi-Round

reviewer가 여러 명이면 finding ID에 reviewer key를 넣는다.

- `R0-RevA-F1`
- `R0-RevB-F1`
- `R1-RevA-F1`

round가 길어지면 `Round Log`와 `Consensus Log`를 남긴다.
아래의 Codex/Claude 이름은 예시일 뿐이며, 특정 tool을 driver/reviewer 역할로 고정하지 않는다.

```markdown
## Round Log

| Round | Driver | Reviewer(s) | Objective | Verdict | Status |
| --- | --- | --- | --- | --- | --- |
| R0 | Codex | Claude | plan review | conditional | addressed |
| R1 | Codex | Claude | follow-up | approve | closed |

## Consensus Log

| Topic | Status | Notes |
| --- | --- | --- |
| Optional workflow boundary | agreed | 기본 gate가 아니라 선택적 relay로 유지 |
```

## Common Situations

| Situation | Recommended Use |
| --- | --- |
| 전략 brief 초안 검토 | plan/result 둘 중 하나로 `brief red-team` packet 생성 |
| 구현 완료 후 PR 전 검토 | validation 결과와 changed files를 포함한 `result review` packet 생성 |
| reviewer가 P1 must-fix 제기 | driver response 작성 후 반영하거나, 방어하려면 user decision gate |
| reviewer 2명 이상 | finding ID에 reviewer key 사용, consensus log로 합의/불일치 정리 |
| 리뷰가 너무 무거워짐 | Minimal Path로 줄이고 round/consensus log 생략 |
| 단순 검토 요청 | `/cross-review`를 쓰지 않고 일반 review로 처리 |

## Relationship To Other Workflows

`/cross-review`는 다음을 대체하지 않는다.

- `/work-plan`: 작업 착수와 계획 승인
- `/work-close`: Work Done 처리
- Approval Matrix: scope/state/commit/PR/merge 승인
- validation: 실제 검증 명령
- `/repo-health`: workflow surface와 cascade drift 점검

cross-review가 `approve`여도 commit, PR, merge는 별도 승인과 Git workflow를 따라야 한다.
