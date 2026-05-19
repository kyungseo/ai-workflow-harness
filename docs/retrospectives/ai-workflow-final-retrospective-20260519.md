# AI Workflow Final Retrospective — 2026-05-19

## Purpose

AI Workflow의 큰 개선 라운드를 마무리하면서 현재 복잡도, Agent memory 부담, 운영 완성도를 평가한 회고 기록이다.

이 문서는 실행 규칙이 아니다. 향후 workflow 변경 여부를 판단할 때 참고하는 multi-agent retrospective다.
각 Agent는 자신의 관점에서 독립 의견을 추가할 수 있으며, 기존 의견을 덮어쓰지 않는다.

## How To Add An Agent Review

새 의견은 `Agent Reviews` 아래에 다음 형식으로 추가한다.

```md
### {Agent Name} — YYYY-MM-DD

#### Summary

#### Complexity Assessment

#### Agent Memory Assessment

#### Completion Assessment

#### Risks

#### Recommendations
```

## Overall Snapshot

현재 workflow는 평이한 구조라기보다 정교한 구조다.
다만 복잡도가 무작위로 쌓인 것은 아니며, 장기 세션 복구, 상태 변경 통제, tool surface 정렬, scaffold 전파를 위해 의도적으로 생긴 복잡도다.

핵심 판단:

- 현재 복잡도는 감당 가능하다.
- 하지만 더 복잡해지면 안 되는 상한선에 가까워졌다.
- 앞으로의 개선 방향은 새 규칙 추가가 아니라 규칙 감량, 조건부 로딩, drift 방지다.
- 큰 workflow 개선은 여기서 마무리하고, 이후에는 실제 반복 실패가 관측될 때만 국소 보정한다.

## Agent Reviews

### Codex — 2026-05-19

#### Summary

현재 AI Workflow는 **소규모 프로젝트 팀 기준으로는 성숙도가 높고 적용 가능한 workflow**다.
점수로 표현하면 **86/100** 정도다.

단, 이 점수는 1인 개인 프로젝트 기준이 아니라 **2~5명 정도의 소규모 팀 또는 1~3명 개발자 + 여러 AI Agent가 함께 쓰는 운영 모델**을 기준으로 한 평가다.
현재처럼 1인이 운용할 때는 overhead가 크게 느껴질 수 있지만, 목표가 소규모 팀 적용이라면 이 정도의 governance density는 더 타당하다.

일반적인 vibe coding workflow와 비교하면 현재 구조는 훨씬 엄격하다.
대부분의 vibe coding은 자연어 요청 -> AI 생성 -> 개발자 수동 확인 -> 수정 반복에 가깝다.
이 repository의 workflow는 여기에 상태판, Work 파일, 승인 gate, multi-tool alignment, scaffold 전파, archive lifecycle까지 얹은 형태다.

따라서 완성도는 높지만, 단순함은 낮다.
개인 생산성만 기준으로 보면 과한 편이고, 팀 handoff와 반복 세션 복구까지 기준에 넣으면 꽤 적절한 편이다.
지금부터는 새 규칙을 추가하는 순간 이익보다 비용이 커질 가능성이 높다.

#### Evaluation Framework

이 회고에서는 다음 8개 축으로 평가한다.
각 축은 최근 AI-assisted development 관행에서 반복적으로 등장하는 기준을 이 repository 상황에 맞게 정리한 것이다.

| Axis | Good State | Why It Matters |
| --- | --- | --- |
| Intent Capture | 작업 목표, 제약, Done Criteria가 명확하다 | AI가 잘못된 문제를 빠르게 풀어버리는 일을 줄인다 |
| Context Discipline | 필요한 문서와 코드만 읽는다 | Agent memory와 token 비용을 통제한다 |
| Scope Control | 승인된 범위 밖 변경을 멈춘다 | AI의 선의의 scope drift를 막는다 |
| Validation | 테스트, diff, 링크, scaffold 검증이 명확하다 | AI-generated output을 신뢰 가능한 변경으로 바꾼다 |
| Human Gate | 계획, 상태 변경, commit에 사람 승인 지점이 있다 | 인간이 high-leverage point에서 판단한다 |
| State Continuity | 다음 세션이 현재 상태를 복구할 수 있다 | 긴 작업과 multi-agent handoff를 가능하게 한다 |
| Tool Portability | Claude, Codex, Cursor, scaffold가 같은 계약을 본다 | 도구 전환 시 drift를 줄인다 |
| Cognitive Load | 규칙을 이해하고 적용하는 비용이 낮다 | workflow가 product work를 잡아먹지 않게 한다 |

#### Industry Baseline Comparison

이 평가는 2026-05-19 현재 공개된 일반 관행을 기준으로 한 정성 비교다.
참고 기준은 다음 정도다.

- GitHub는 AI-generated code도 인간이 직접 review/test해야 한다고 강조한다.
- GitHub의 AI code review guide는 AI 결과를 structured artifact로 남겨 다음 generation/review context로 쓰는 흐름을 권장한다.
- Google Cloud의 AI coding assistant guidance는 초기에 문서와 project-specific instruction file을 만들어 AI 세션 품질을 높이는 방향을 권한다.
- Copilot coding agent류의 agentic workflow는 사람이 최종 PR review/approval을 수행하는 human-in-the-loop 구조를 기본으로 둔다.

참고:

- <https://docs.github.com/en/copilot/responsible-use/code-review>
- <https://docs.github.com/en/enterprise-cloud@latest/copilot/tutorials/review-ai-generated-code>
- <https://cloud.google.com/blog/topics/developers-practitioners/five-best-practices-for-using-ai-coding-assistants/>
- <https://awesome-copilot.github.com/learning-hub/using-copilot-coding-agent/>

일반 vibe coding 대비:

| Dimension | Typical vibe coding | This workflow | Gap |
| --- | --- | --- | --- |
| Intent capture | Prompt 중심, Done Criteria가 종종 암묵적 | `/work`, Work file, Done Criteria 명시 | 이 workflow가 강함 |
| Context | IDE/session context에 의존 | Context Routing으로 조건부 로드 | 이 workflow가 강함 |
| Scope control | 개발자 감각에 의존 | Approval Matrix와 scope expansion gate | 이 workflow가 훨씬 엄격함 |
| Validation | 테스트/수동 확인이 작업자 습관에 의존 | Verification, diff check, scaffold simulation | 이 workflow가 강함 |
| Continuity | 대화 기록 또는 commit history 의존 | STATUS + Work file + archive lifecycle | 이 workflow가 강함 |
| Portability | 특정 도구에 묶임 | Claude/Codex/Cursor/scaffold alignment | 이 workflow가 강함 |
| Speed | 빠름 | 느림 | 일반 vibe coding이 강함 |
| Cognitive load | 낮거나 중간 | 높음 | 이 workflow가 약함 |

Agentic coding best practice 대비:

| Dimension | Good agentic workflow | This workflow | Gap |
| --- | --- | --- | --- |
| Plan before execute | 필요 | 강함 | 충족 |
| Test/review loop | 필요 | 강함 | 충족 |
| Human approval | 필요 | 강함 | 충족 |
| Reusable instructions | 필요 | 강함 | 충족 |
| Automated enforcement | 있으면 좋음 | 약함, manual-first | 미흡 |
| Metrics/feedback loop | 있으면 좋음 | 약함 | 미흡 |
| Low-friction daily use | 중요 | 중간 이하 | 미흡 |

#### Complexity Assessment

현재 복잡도는 **7.5/10** 정도다.
처음 평가했던 7/10보다 약간 높게 본다.
이유는 `BEHAVIOR-PRINCIPLES.md` 복원 이후 원칙 계층은 좋아졌지만, 동시에 canonical/tool/user/scaffold cascade surface가 하나 더 늘었기 때문이다.

소규모 팀 기준으로는 이 복잡도는 **높지만 수용 가능**하다.
개인 프로젝트라면 "조금 과하다"에 가깝고, 팀 프로젝트라면 "handoff 비용을 줄이기 위한 적정 수준의 운영 장치"에 가깝다.

평시 작업자가 이해해야 할 핵심은 많지 않다.

1. `docs/BEHAVIOR-PRINCIPLES.md`
2. `docs/AGENT-WORKFLOW.md`
3. `docs/STATUS.md` current sections
4. 현재 작업의 Work 파일, 있을 때만

그러나 workflow/process 변경이 들어오면 복잡도가 급격히 오른다.
canonical, tool-specific, user-facing, scaffold까지 cascade를 확인해야 하기 때문이다.
이 구조는 안전하지만, 자주 쓰면 무겁다.

복잡도 세부 평가:

| Area | Score | Assessment |
| --- | --- | --- |
| Daily product work | 6/10 | 팀 공통 기준이 생겨 안정적이지만, 작은 작업에는 overhead가 있다 |
| Harness/workflow work | 8/10 | cascade 때문에 무겁다 |
| New Agent onboarding | 6/10 | 초기 학습은 필요하지만 handoff 기준이 명확하다 |
| Multi-session recovery | 3/10 | 구조가 잘 잡혀 있어 부담이 낮다 |
| Multi-tool alignment | 8/10 | 강하지만 관리 비용이 높다 |
| Scaffold maintenance | 7/10 | 유용하지만 drift 가능성이 있다 |

감당 가능한 이유:

- 평시 로드 경로가 짧다.
- `HARNESS-PROTOCOL.md`, `WORKFLOW-MANUAL.md`, prompts, scaffold는 조건부 로드 대상이다.
- Quick Mode가 product surface의 작은 작업을 빠르게 닫을 수 있게 한다.
- STATUS와 Work 파일 역할 분리가 명확하다.
- 팀원이 바뀌거나 Agent가 바뀌어도 같은 상태판과 Done Criteria로 이어받을 수 있다.

위험한 이유:

- workflow 문서 변경은 거의 항상 L2 cascade 작업이 된다.
- 문서 수가 많아 신규 Agent가 핵심과 참고 자료를 혼동할 수 있다.
- `WORKFLOW-MANUAL.md`와 scaffold는 drift가 생기기 쉬운 표면이다.
- `/health --cascade`를 과사용하면 점검 비용이 실제 작업 비용을 앞지를 수 있다.
- 팀원이 규칙을 다르게 해석하면 문서가 많을수록 오히려 합의 비용이 커질 수 있다.

#### Agent Memory Assessment

Agent memory 부담은 현재 **조건부로 수용 가능**하다.
단, 조건부 로딩 discipline이 무너지면 빠르게 무거워진다.

좋은 상태의 기본 로드:

```text
BEHAVIOR-PRINCIPLES.md
AGENT-WORKFLOW.md
STATUS.md current sections
current Work file, only when relevant
```

피해야 할 패턴:

- 세션 시작마다 `docs/archive/`를 뒤진다.
- 세션 시작마다 모든 retrospective를 읽는다.
- `.claude/commands/*.md` 전체를 매번 읽는다.
- workflow 변경이 아닌데 `WORKFLOW-MANUAL.md` 전체를 읽는다.
- 불안하다는 이유로 protocol, manual, backlog, DR, prompts, scaffold를 한 번에 확인한다.

현재 구조의 성공 조건은 간단하다.
**많은 문서가 존재하되, 매번 읽지 않는 것**이다.

Memory budget 관점의 냉정한 평가:

| Load Set | Expected Use | Assessment |
| --- | --- | --- |
| `BEHAVIOR + AGENT-WORKFLOW + STATUS` | every session | 적절 |
| Work file 1개 | active work only | 적절 |
| `HARNESS-PROTOCOL.md` | disputed workflow judgment | 조건부로 적절 |
| `WORKFLOW-MANUAL.md` | user-facing/cascade only | 평시 로드하면 과함 |
| all prompts / all commands | audit only | 평시 로드 금지 |
| archive / all retrospectives | historical review only | 평시 로드 금지 |

가장 큰 리스크는 문서 총량이 아니라 **로드 판단 비용**이다.
Agent가 "무엇을 읽어야 하지?"를 매번 고민하기 시작하면 workflow가 이미 무거워진 것이다.

#### Completion Assessment

현재 workflow의 완성도는 **소규모 팀 기준으로 높지만 균형은 여전히 아슬아슬하다**.

성숙도 모델로 보면 다음과 같다.

| Level | Description | Status |
| --- | --- | --- |
| L0 | AI를 단순 autocomplete/chat로 사용 | 초과 |
| L1 | prompt -> code -> manual review 반복 | 초과 |
| L2 | project instruction + tests + commit discipline | 초과 |
| L3 | stateful work tracking + explicit approval gates | 충족 |
| L4 | multi-agent/tool alignment + scaffold propagation | 거의 충족 |
| L5 | automated enforcement + metrics + self-healing workflow | 미충족 |

현재 위치는 **L4** 정도다.
L4의 핵심인 multi-tool alignment와 scaffold propagation은 충족했다.
다만 L5로 가려는 것은 지금은 추천하지 않는다.
자동 enforcement, metrics, self-healing까지 넣으면 complexity budget을 넘을 가능성이 높다.

강점:

- 행동 원칙과 실행 절차가 분리되었다.
- `BEHAVIOR-PRINCIPLES.md`가 최상위 태도와 판단 기준을 담당한다.
- `AGENT-WORKFLOW.md`가 평시 실행 계약을 담당한다.
- `HARNESS-PROTOCOL.md`가 상세 판단을 담당한다.
- `STATUS.md`는 live dashboard로 축소되었다.
- Work 파일은 작업 단위 SSoT 역할을 한다.
- Claude, Codex, Cursor, scaffold가 같은 원칙을 참조하도록 정렬되었다.
- output contract 예외 문장으로 최상위 Communication Standards와 하위 prompt/command 형식 충돌도 완화되었다.
- industry baseline에서 중요하게 보는 human review, test/review loop, project-specific instruction, structured artifacts 측면을 대부분 충족한다.
- 소규모 팀에서 특히 중요한 handoff, 승인 지점, 공통 용어, 작업 종료 기준이 repo-visible하게 남는다.

약점:

- 구조가 이미 꽤 정교하다.
- workflow 변경 시 cascade 비용이 높다.
- 사용자 매뉴얼과 scaffold는 계속 drift 감시가 필요하다.
- 규칙이 더 늘면 Agent가 작업보다 규칙 운영에 더 많은 시간을 쓸 수 있다.
- 자동화된 quality gate나 준수율 측정은 약하다.
- product delivery throughput 관점의 feedback metric이 없다.
- 팀 단위 onboarding ritual이 없으면 문서는 있어도 실제 습관으로 정착하지 못할 수 있다.
- workflow steward 또는 rotating owner가 없으면 canonical/tool/user/scaffold drift를 누가 책임지는지 흐려진다.

냉정한 결론:

| Criterion | Score | Comment |
| --- | --- | --- |
| Safety | 9/10 | 승인 gate와 validation이 강하다 |
| Continuity | 9/10 | STATUS와 Work file 모델이 좋다 |
| Tool alignment | 8/10 | Claude/Codex/Cursor/scaffold 정렬 완료 |
| Simplicity | 5/10 | 평이하지 않다 |
| Speed | 5/10 | product work에는 overhead가 있다 |
| Memory efficiency | 7/10 | 조건부 로딩을 지키면 괜찮다 |
| Maintainability | 7/10 | 구조는 명확하지만 surface가 많다 |
| Practical maturity | 8.5/10 | 소규모 팀 기준으로는 충분히 성숙 |
| Team handoff | 8.5/10 | 상태, 결정, Done Criteria가 repo에 남는다 |

#### Risks

| Risk | Severity | Comment |
| --- | --- | --- |
| 규칙 추가 관성 | High | 새 문제가 생길 때마다 새 규칙을 추가하면 곧 감당 불가능해진다. |
| cascade 과사용 | Medium | workflow 변경 후에는 필요하지만, 평시 작업에 끌고 오면 생산성이 낮아진다. |
| Agent memory 팽창 | Medium | 조건부 로딩이 깨질 때 발생한다. |
| user-facing/scaffold drift | Medium | manual과 scaffold는 자주 확인하지 않기 때문에 늦게 어긋날 수 있다. |
| product work 지연 | Medium | workflow 개선이 계속되면 Phase 2 product work가 밀릴 수 있다. |
| best-practice 과잉적용 | Low/Medium | 개인 기준으로는 과하지만 소규모 팀 기준으로는 대체로 적정하다. 다만 early product phase에서는 과사용을 경계해야 한다. |
| team adoption inconsistency | Medium/High | 팀원이 일부만 따르거나 Agent마다 해석이 갈리면 workflow 신뢰도가 빠르게 떨어진다. |
| workflow owner 부재 | Medium | canonical/tool/user/scaffold drift를 누가 정리하는지 명확하지 않으면 시간이 지나며 구조가 무뎌진다. |
| 준수율 착각 | Medium | 문서화된 규칙이 실제 준수를 보장하지 않는다. |

#### Recommendations

앞으로의 운영 원칙:

- 큰 workflow 개선은 여기서 종료한다.
- 새 규칙은 기존 규칙을 대체하거나 줄일 때만 추가한다.
- 평시 시작 경로는 `BEHAVIOR -> AGENT-WORKFLOW -> STATUS`로 고정한다.
- `HARNESS-PROTOCOL.md`는 판단이 갈릴 때만 본다.
- `WORKFLOW-MANUAL.md`는 user-facing 변경 또는 cascade 감사 때만 본다.
- `/health --cascade`는 workflow/process 변경 후에만 쓴다.
- product surface의 작은 작업은 Quick Mode로 닫는다.
- retrospective는 실행 규칙으로 즉시 승격하지 않는다.
- 실제 반복 실패가 관측될 때만 국소 보정한다.
- 다음 작업은 workflow가 아니라 PRE-B 같은 product/pre-entry work로 전환한다.
- 새 workflow rule 제안은 "반복 실패 3회 이상 또는 high-impact incident" 기준을 넘을 때만 검토한다.
- 소규모 팀 적용 시 30분 이내 walkthrough와 Quick Reference 중심 onboarding을 먼저 둔다.
- workflow steward를 1명 지정하거나 sprint 단위로 rotating owner를 둔다.
- workflow 품질은 앞으로 문서 수가 아니라 product work 처리 속도, validation 실패율, scope drift 재발 여부, handoff recovery time으로 판단한다.

#### Final Grade

| Category | Grade |
| --- | --- |
| Overall maturity | A- |
| Safety and recoverability | A- |
| Simplicity | C+ |
| Daily usability | B |
| Multi-agent portability | A- |
| Team handoff | A- |
| Long-term maintainability | B+ |

최종 판단:

> 현재 workflow는 일반적인 vibe coding workflow보다 훨씬 엄격하고 성숙하다.
> 개인 프로젝트 기준으로는 다소 과하지만, 소규모 팀 기준으로는 꽤 적절한 governance다.
> 다만 그만큼 느리고 무거워질 수 있다.
> 지금은 감당 가능하지만, 더 복잡해지면 안 되는 지점에 거의 도달했다.
> 이제 품질은 규칙을 더 촘촘히 만드는 것이 아니라, 팀이 적은 context로 product work를 안정적으로 이어받고 끝내는 데 달려 있다.

## Open Slots For Additional Reviews

### Claude — 2026-05-19

#### Summary

점수로 먼저 말한다: **82/100**. 소규모 팀(2~5인 + 복수 AI Agent) 기준이다.

이 workflow는 일반 vibe coding 대비 State continuity, Scope control, Multi-tool alignment에서 압도적으로 앞선다. 소규모 팀이 AI Agent와 협업하는 운영 모델로서 현재 구조는 타당하고 충분히 성숙하다.

감점 요인은 두 가지다. 첫째, **Rule compliance가 전적으로 AI 자율 준수에 의존**한다. 문서화된 규칙이 실제로 지켜지는지 확인할 수단이 없다. 둘째, workflow 규칙 변경 시 **cascade surface가 넓어 수정 비용이 높다.** 규칙을 바꾸기 어려운 구조는 틀린 규칙을 오래 유지하게 만든다.

#### Evaluation Framework

Codex의 8축과 관점을 달리하여 **결과 중심 5축**으로 평가한다. 구조가 좋은지가 아니라, 소규모 팀 운영에서 의도한 결과를 내는지를 본다.

| Axis | 측정 기준 | 소규모 팀 기준 점수 |
| --- | --- | --- |
| **Output quality** | AI 변경이 scope 밖을 침범하지 않고 validation을 통과하는 비율 | 8/10 |
| **Team continuity** | 팀원/Agent가 교체되거나 세션이 중단돼도 상태를 복구할 수 있는 비율 | 9/10 |
| **Rule compliance** | 문서화된 규칙이 실제 세션에서 지켜지는 비율 | 6/10 |
| **Delivery throughput** | product work가 workflow overhead 없이 진행되는 속도 | 6/10 |
| **Cognitive overhead** | 팀원이 workflow를 이해하고 운용하는 데 쓰는 초기 비용 | 5/10 |

Team continuity는 이 workflow의 핵심 강점이다. Rule compliance와 Cognitive overhead가 개선 여지다. Delivery throughput은 소규모 팀 기준으로는 수용 가능한 수준이다.

#### Vibe Coding 현황 대비 비교

2026년 현재 vibe coding 팀이 실제로 사용하는 방식을 세 층위로 구분하면:

**Tier 1 — 기본 vibe coding 팀** (다수)

자연어 prompt → AI 생성 → 개발자 수동 확인 → 커밋. 팀 공통 instruction 없음. 세션 간 상태 없음. AI가 만든 코드를 팀원이 각자 다르게 해석. 빠르지만 drift와 충돌이 빈번.

**Tier 2 — 중급 vibe coding 팀** (소수)

공유 `.cursorrules` 또는 `CLAUDE.md` 작성. PR 기반 리뷰. 테스트 실행 습관. 세션 간 context는 대화 기록 또는 PR description에 의존. 팀 공통 기준이 있지만 AI 도구마다 해석이 다름.

**Tier 3 — 고급 vibe coding 팀** (극소수)

project-specific instruction + commit convention + 간단한 상태 추적. 단일 AI 도구 기준으로 정렬. Work 파일 lifecycle, Approval Matrix, multi-tool alignment까지 갖춘 경우는 거의 없음.

이 workflow는 **Tier 3 수준이며, 소규모 팀 기준으로 현재 공개된 best practice에 근접한다.**

| Dimension | Tier 1 팀 | Tier 2 팀 | Tier 3 팀 | 이 workflow | 평가 |
| --- | --- | --- | --- | --- | --- |
| 팀 공통 instruction | 없음 | 기본 | 상세 | 계층화 + 우선순위 체계 | 이 workflow가 앞섬 |
| Scope control | 개인 감각 | 부분적 | diff 리뷰 | Approval Matrix (L1/L2/L3) | 이 workflow가 앞섬 |
| 세션 간 상태 복구 | 없음 | PR history | 간단한 노트 | STATUS + Work 파일 + archive | 이 workflow가 압도적으로 앞섬 |
| Multi-tool alignment | 없음 | 없음~약함 | 단일 도구 | Claude/Codex/Cursor/scaffold | 이 workflow만 보유 |
| 의사결정 근거 보존 | 없음 | commit message | 간단한 노트 | DR 체계 | 이 workflow가 앞섬 |
| Validation discipline | 없음~약함 | 테스트 실행 | diff + test | Verification + cascade check | 이 workflow가 앞섬 |
| 팀원 onboarding 비용 | 낮음 | 중간 | 중간~높음 | 높음 | 이 workflow가 뒤처짐 |
| Rule compliance 보장 | N/A | 습관 의존 | 습관 의존 | 문서 의존 | **이 workflow의 맹점** |
| Speed | 빠름 | 중간 | 중간 | 느림 | 이 workflow가 뒤처짐 |

마지막 두 행이 핵심이다. Tier 1~3 팀은 규칙이 적은 대신 습관과 PR 리뷰로 준수를 보장한다. 이 workflow는 규칙이 많고 문서에 의존한다. **문서화된 규칙은 팀의 공유 습관을 대체하지 못한다.** 특히 AI Agent가 규칙을 자율적으로 지키는 데 의존하는 구조는 검증 수단이 없다.

#### Complexity Assessment

**7.5/10. 소규모 팀 기준으로 높지만 수용 가능한 복잡도다.**

평시 팀원이 이해해야 할 핵심 경로는 짧다.

1. `docs/BEHAVIOR-PRINCIPLES.md` — 태도와 판단 기준
2. `docs/AGENT-WORKFLOW.md` — 실행 절차
3. `docs/STATUS.md` current sections — 현재 상태
4. 담당 작업의 Work 파일 — 작업 단위 SSoT

소규모 팀에서 이 구조가 갖는 실질적 가치:
- 팀원이 바뀌어도 Work 파일과 STATUS로 상태 인계 가능
- 여러 AI 도구를 사용해도 동일 원칙 참조
- Approval Matrix로 일방적 결정 방지
- DR 체계로 결정 근거 보존

그러나 workflow/process 변경이 발생하면 복잡도가 급격히 오른다. canonical → tool-specific → user-facing → scaffold까지 cascade를 확인해야 하기 때문이다. **이 cascade 비용이 변경을 억제하는 관성으로 작용할 수 있다.** 규칙을 바꾸기 어려운 workflow는 틀린 규칙을 오래 유지하게 된다.

| Area | Score | 소규모 팀 기준 평가 |
| --- | --- | --- |
| 일상 product work | 6/10 | Quick Mode로 감당 가능, 작은 작업에 overhead 있음 |
| Harness/workflow 변경 | 8/10 | cascade 때문에 무겁다 |
| 신규 팀원 onboarding | 6/10 | 초기 학습 비용이 있으나 이후 handoff 기준이 명확 |
| 세션 중단 후 복구 | 3/10 | STATUS + Work 파일로 부담이 낮다 (낮을수록 좋음) |
| Multi-tool alignment | 8/10 | 강하지만 관리 비용이 높다 |
| Scaffold 유지 | 7/10 | 유용하지만 drift 가능성이 있다 |

#### Agent Memory Assessment

**로드 총량은 수용 가능하다. Rule compliance 신뢰성이 더 큰 문제다.**

기본 로드 경로(`BEHAVIOR-PRINCIPLES + AGENT-WORKFLOW + STATUS`)는 적절하다. 문제는 이 규칙들이 실제로 지켜지는지 확인할 수단이 없다는 것이다.

규칙의 양과 준수율은 비례하지 않는다. 규칙이 많아질수록 각 규칙의 실효 준수율은 낮아진다. 이는 AI의 결함이 아니라 **인지 부하의 물리적 한계**다. 세션마다 "무엇을 로드해야 하는지 판단"하는 비용 자체도 규칙이 많아질수록 증가한다.

| 로드 대상 | 실제 필요 빈도 | 평가 |
| --- | --- | --- |
| BEHAVIOR-PRINCIPLES + AGENT-WORKFLOW + STATUS | 매 세션 | 적절 |
| Work 파일 1개 | active 작업 시 | 적절 |
| HARNESS-PROTOCOL | 판단 분기 시 | 조건부 적절 |
| command 파일 | 해당 command 실행 시 | 조건부 적절 |
| WORKFLOW-MANUAL / scaffold | cascade 감사 시만 | 평시 로드 금지 |
| archive / 전체 retrospective | 역사 검토 시만 | 평시 로드 금지 |

가장 위험한 패턴: **"불안하니까 더 읽는다."** 규칙이 많은 workflow일수록 AI가 더 읽으려는 경향이 생긴다. 그 경향 자체가 복잡도의 증거이며 해결책이 아니다.

#### Completion Assessment

구조적 완성도: **높음.** 소규모 팀 실용성: **양호.**

**소규모 팀 운영에서 이 workflow가 실제로 해결하는 문제:**

| 문제 | 일반 팀 vibe coding의 현실 | 이 workflow의 해결 |
| --- | --- | --- |
| AI가 scope 밖을 변경함 | 흔함. PR에서 사후 발견 | Approval Matrix가 사전에 차단 |
| 팀원 교체 시 상태 소실 | 매우 흔함 | STATUS + Work 파일로 인계 가능 |
| AI 도구마다 다른 결과 | 팀에서 매우 흔함 | 3개 도구 동일 원칙 참조 |
| AI의 과잉 설계 | 흔함 | BEHAVIOR-PRINCIPLES 원칙 1·2 |
| 결정 근거 소실 | 팀에서 흔함 | DR 체계 |
| commit 승인 없는 배포 | 팀에서 발생 가능 | Approval Matrix commit gate |

**이 workflow가 아직 해결하지 못한 문제:**

| 문제 | 현재 상태 |
| --- | --- |
| Rule compliance 자동화 | AI 자율 준수에만 의존. 지켜지는지 확인 불가 |
| 준수율 측정 | 없음. 잘 지켜지는지 알 방법이 없음 |
| 신규 팀원 onboarding 비용 | 학습 곡선이 있음. 문서가 많아 진입 장벽 존재 |
| Workflow 변경 비용 | cascade surface가 넓어 수정이 비쌈 |

#### Risks

| Risk | Severity | 근거 |
| --- | --- | --- |
| Rule compliance 착각 | **High** | 문서화 = 준수가 아니다. 규칙 수와 실효 준수율은 반비례할 수 있다. 지켜지는지 확인할 수단이 없다. |
| 변경 관성 | **High** | cascade surface가 많아 workflow 규칙을 수정하는 비용이 높다. 틀린 규칙을 오래 유지하게 된다. |
| 신규 팀원 onboarding 마찰 | **Medium** | 문서 계층이 깊다. 핵심 경로는 짧지만 전체를 파악하는 데 시간이 걸린다. |
| Scaffold drift | **Medium** | scaffold와 운영 문서 간 drift는 늦게 발견된다. |
| 새 규칙 추가 관성 | **Medium** | 문제가 생길 때마다 새 규칙을 추가하면 complexity budget을 넘는다. |

#### Recommendations

1. **Rule compliance를 신뢰하지 말고 검증하라.** AI가 규칙을 지켰는지 확인하는 가장 실효성 있는 방법은 사람의 diff 리뷰다. 문서를 늘리는 것보다 PR 리뷰 습관이 준수율을 높인다.

2. **새 규칙 추가 기준을 올린다.** "있으면 좋겠다"는 이유로 규칙을 추가하지 않는다. 동일한 실패가 3회 이상 반복됐을 때만 규칙 보정을 검토한다.

3. **cascade surface 확장을 경계한다.** 새로운 원칙/문서를 추가할 때마다 cascade 대상이 늘어난다. 추가 전에 반드시 "이것을 cascade 해야 하는가"를 질문한다.

4. **팀원 onboarding 경로를 단순화한다.** 신규 팀원이 처음 봐야 할 문서를 3개로 제한하고 나머지는 필요 시 참조로 분류한다. 현재 핵심 경로(`BEHAVIOR → AGENT-WORKFLOW → STATUS`)는 올바르지만 이를 명시적으로 강조해야 한다.

5. **L5(자동화 enforcement)는 고려하지 않는다.** compliance 문제의 해결책은 더 많은 자동화가 아니라 팀의 리뷰 습관이다.

#### Final Grade

| Category | Grade | Comment |
| --- | --- | --- |
| 구조 설계 | A- | 계층화, SSoT 분리, cascade 정렬 모두 의도적이고 일관됨 |
| Team continuity | A | STATUS + Work 파일 모델은 팀 handoff에 실질적으로 작동함 |
| Multi-tool alignment | A- | Claude/Codex/Cursor/scaffold 정렬은 소규모 팀에서 차별화 요소 |
| Rule compliance | B- | 문서화 ≠ 준수. 검증 수단 없음 |
| Workflow 변경 비용 | C+ | cascade surface가 넓어 규칙 수정이 비쌈 |
| Onboarding 용이성 | B- | 핵심 경로는 짧지만 전체 문서 계층이 깊음 |
| **종합** | **B+** | 소규모 팀 기준으로 성숙하고 타당한 구조. Rule compliance와 변경 비용이 개선 여지 |

최종 판단:

> 이 workflow는 소규모 팀이 복수의 AI Agent와 협업하는 운영 모델로서 현재 공개된 best practice에 근접한다.
> State continuity, Scope control, Multi-tool alignment는 일반 vibe coding 팀이 갖추지 못한 수준이다.
> 남은 과제는 구조를 더 정교하게 만드는 것이 아니라,
> 지켜지는지 확인하고, 규칙 변경 비용을 낮게 유지하며, 팀이 실제로 사용하기 쉬운 상태로 유지하는 것이다.

### Other Agent — Pending

필요 시 다른 Agent 또는 외부 리뷰어의 의견을 이 섹션 아래에 추가한다.
