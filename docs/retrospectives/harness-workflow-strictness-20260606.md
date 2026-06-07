---
date: 2026-06-06
track: harness
type: process
scope: source repo branch isolation + commit-time gate의 엄격성이 일반 관례 대비 적정한가
author: "agent:claude-opus-4-8"
related_work: []
---

# AI Workflow Harness — Source Repo Workflow 엄격성 평가

> 작성일: 2026-06-06
> 작성자: Claude Opus 4.8
> 범위: source repo의 branch isolation(feature→develop→main) + commit-time gate(branch-protected paths, DR-025 finalization bundling)의 "엄격성"이 일반 관례 대비 적정한가
> 목적: "소소한 변경까지 feature branch를 따는 게 과한 것 아닌가"라는 질문에 대한 정직한 평가와 결론을 남기고, 나중에 다시 판단할 revisit trigger를 기록한다

---

## 결론

**일반적인 1인 개발 관례 기준으로는 엄격한 쪽이 맞다. 그러나 이 repo에 한해선 내부 정합적이고 비용도 낮아 "과설계"는 아니다 — 단 한 곳(finalization gate가 standalone tracking-only commit까지 finalization-split으로 취급하는 부분)은 보정 가치가 있다.**

핵심은: 이 엄격성은 (1) AI agent가 변경 주체라는 점, (2) 이 repo 자체가 workflow를 증명하는 제품이라는 점에서 정당화되고, (3) generic scaffold target에는 상속되지 않도록 이미 source-only로 갇혀 있다. 비용은 branch/PR/merge를 agent가 자동 처리하므로 사실상 0에 가깝고, 체감 마찰은 시간이 아니라 "이것까지 PR을 따야 하나"라는 개념적 지점에 있다.

---

## 1. 일반 관례 대비 위치

| 환경 | 통상 관례 |
| --- | --- |
| 1인/개인 repo | trunk-based, `main` 직접 commit. 위험한 변경만 branch. PR 선택 |
| 소규모 팀 | 대부분 PR + review. 문서/오타는 직접 push 허용하기도 |
| 대규모/규제 | 전건 PR + required review + CI |

이 repo는 **1인 운영인데 "대규모/규제" 모델**을 적용한다. 객관적으로 solo 평균보다 무겁다. 보통이라면 4행짜리 backlog 정리는 `develop`/`main`에 직접 commit하고 끝낸다.

## 2. 이 repo가 특수한 이유

1. **변경 주체가 AI agent(Claude/Codex).** PR이 "agent가 무엇을 했는지" review surface + audit trail이 된다. 신중한 사람의 직접 commit과 달리 agent 직접 push는 리스크가 더 크므로, 여기서는 strictness의 실익이 일반 solo보다 크다.
2. **이 repo 자체가 workflow 제품이다.** 자기 규칙을 dogfooding하는 것이 목적의 일부다. 엄격함이 곧 데모이자 검증이다.

## 3. 엄격성은 source-only로 갇혀 있다

generic scaffold target은 이 hard gate(source-gitflow branch isolation + commit gate)를 상속하지 않는다(DR-021 source-vs-target boundary, c1 = CHORE-20260606-008). source-style 강제는 `--workflow source-gitflow` opt-in 또는 `policy_type: source-gitflow` marker가 있을 때만 적용된다. 즉 "보통 프로젝트엔 강요하지 않는다"는 판단을 이미 내려둔 상태라, 남에게 과한 규율을 퍼뜨리는 형태가 아니다.

## 4. 실제 비용

branch + PR + merge는 agent가 명령 몇 개로 자동 처리한다(사람이 PR 템플릿을 채우는 것이 아니다). 따라서 엄격성의 *시간* 비용은 낮다. 마찰은 주로 *개념적*("이 작은 것까지?")이며, 그 지점이 이 평가를 촉발한 질문이다.

## 5. 실제로 과한 곳 (보정 후보)

branch/PR 강제 자체보다, **DR-025 finalization gate가 "번들할 실질 변경이 없는 순수 tracking 정리"까지 finalization-split으로 취급**하는 것이 미세하게 miscalibrated돼 있다.

- 실제 사례: CHORE-20260606-010(backlog 정리, PR #85)은 `docs/backlog/HARNESS.md` 단독 변경이라 `awh_is_finalization_file`에 걸렸다. 이번엔 feature branch 첫 commit이라 parent가 published `develop` tip → `report-only`로 빠져 통과했지만, 같은 정리를 feature branch의 **두 번째 commit 이후**에 했다면 provably-local-only → hard-stop → override trailer가 실제로 필요했을 것이다.
- 즉 "번들할 substance가 애초에 없는 standalone tracking maintenance"는 gate가 막을 대상이 아닌데 현재 taxonomy로는 걸린다. 이는 slice (a)(CHORE-20260606-006) R1-N2의 "planning/tracking-only commit edge"와 동일 사안이다.

## 6. Revisit Triggers

이 평가를 다시 꺼내 재판단할 시점:

- 외부 기여자가 유입되어 audit trail 가치가 더 커지거나, 반대로 1인 운영 마찰이 누적으로 실측될 때
- agent 비중/사용 패턴이 바뀌어 "직접 push 허용 docs 경로"의 실익이 분명해질 때
- finalization gate의 standalone tracking-only 면제를 실제로 착수할 때(c4 또는 DR-025 보정)
- 이 repo를 source 운영에서 다른 모델로 전환하려 할 때(HRN-FUT-004 Gitflow vs GitHub Flow 결정과 연계)

## 연결

- 정책 근거: DR-020(repo ruleset, develop 직접 push 차단), DR-024(gate strictness 2D taxonomy), DR-025(commit gate runtime enforcement), DR-021(source-vs-target boundary)
- 실행 후보: `docs/backlog/HARNESS.md` Deferred Idea — "standalone tracking-only commit을 finalization gate에서 면제/advisory 처리"
- 동일 edge 최초 기록: CHORE-20260606-006 R1-N2
