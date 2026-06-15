---
date: 2026-06-16
track: harness
type: strategy
scope: sub-agent 병렬 실행과 scaffold target의 multi-user 작업에서 tracking truth와 finalization ownership을 어떻게 나눌지에 대한 방향 정리
author: "agent:codex + agent:claude-review-ready"
related_work: []
---

# Harness Sub-Agent Concurrency and Multi-User Tracking

> 작성일: 2026-06-16
> 작성 방식: Codex가 초안을 작성하고, Claude가 같은 문서에 red-team review round를 누적하는 공동 검토 형식
> 역할: Codex = author/driver, Claude = red team reviewer, 사용자 = 최종 승인자
> 목적: sub-agent 병렬 실행과 scaffold target의 multi-user 운영을 같은 문제군으로 보고, 무엇을 병렬화할 수 있고 무엇은 단일 writer/승인 owner가 가져야 하는지 정책 방향을 먼저 정리한다

---

## 결론

현재 이 harness에서 진짜 위험은 "동시성 자체"가 아니라 **공유 mutable tracking surface를 누가 언제 어떤 권한으로 제안하고 확정하느냐**다.

- 현 harness는 이미 human 승인 게이트로 tracking/finalization을 **직렬 확정**한다.
- 따라서 이 brief의 핵심 질문은 "누가 최종 writer인가"가 아니라, **sub-agent가 자율 write/propose 권한을 어디까지 가지며 그 차이가 어디에 인코딩되는가**다.
- 병렬 실행 자체는 허용 가능하지만, tracking/finalization 제안 창구는 기본적으로 좁게 유지하는 편이 맞다.

이 문제는 `Work ID 충돌`만의 문제가 아니다. 더 큰 문제는 아래 네 가지가 섞일 때 생긴다.

1. 누가 현재 truth를 제안하는가
2. 누가 완료를 선언하는가
3. 누가 commit/PR/merge를 finalization하는가
4. 서로 다른 agent/사용자가 같은 상태를 stale read한 채 다시 쓰는가

따라서 이 brief는 "다음 큰 Work"를 정당화하는 문서가 아니라, **이미 직렬화된 승인 모델 위에서 sub-agent 자율 write 경계를 어떻게 설명하고 인코딩할지**를 좁게 정리하는 문서여야 한다.

source repo의 sub-agent 병렬성, scaffold target의 multi-user 운영, internal managed mode의 cross-repo 중앙 관리는 모두 "공유 tracking truth와 권한 경계"라는 축과 닿아 있다. 다만 이 brief의 1차 초점은 **단일 세션 내 sub-agent write authority boundary**에 둔다. 나머지는 연결 이슈로만 다룬다.

---

## 질문과 배경

시발점은 단순했다.

- sub-agent를 여러 개 돌리면 Work ID가 충돌하지 않을까?
- `docs/HARNESS-PARALLEL-WORK-CONTROLS.md` 같은 문서로 복구 규칙을 만들었지만, 정말 더 큰 위험은 없는가?
- 특히 여러 sub-agent가 각자 자기 Work를 닫고 `STATUS.md`까지 확정하기 시작하면 workflow가 견딜 수 있는가?
- 이 우려를 source repo 내부 문제로만 볼 것인가, 아니면 scaffold target에서 여러 사용자가 함께 일하는 경우까지 포함해 봐야 하는가?

현재 문서들은 충돌 "복구"에는 답을 준다.

- Work ID/DR 번호 재배정
- `STATUS.md` Active Work 충돌 시 실제 Work 파일 기준 재구성
- Work index 재작성
- command/skill mirror atomicity

하지만 그것만으로는 부족하다. 복구 규칙은 있어도, **sub-agent가 무엇을 제안만 할 수 있고 무엇을 직접 write할 수 있는지**, **그 차이가 어디에 인코딩되는지**, **실제 도구 패턴(read-only fan-out, worktree 격리)에서 어떤 위험이 아직 남는지**는 아직 명시적으로 정리돼 있지 않다.

이 brief는 바로 그 정책 공백을 다룬다.

---

## 비교·분석

### 1. 문제를 다시 정의하면 "동시성"보다 "shared mutable tracking"이다

겉으로는 병렬성 문제처럼 보이지만, 실제로는 다음 네 층이 섞여 있다.

| 층 | 질문 | 병렬 허용 기본값 |
| --- | --- | --- |
| Execution plane | 코드/문서/조사/검증을 여러 agent가 나눠 할 수 있는가 | 비교적 높음 |
| Tracking plane | Work/STATUS/backlog/DR/index 같은 현재 상태를 여러 주체가 동시에 쓸 수 있는가 | 낮음 |
| Finalization plane | `/work-close`, commit, PR, merge, release를 여러 주체가 독립 확정할 수 있는가 | 매우 낮음 |
| Governance plane | 승인권, merge권, tracker 수정권을 누가 갖는가 | 명시 필요 |

현재 harness는 execution plane에는 비교적 유연하고, tracking/finalization은 human 승인 게이트로 이미 직렬화돼 있다. 다만 **sub-agent가 이 모델 안에서 proposer인지, bounded writer인지, 그리고 그 차이가 어떻게 encode되는지**는 아직 분명하지 않다.

### 2. Work ID 충돌은 시작일 뿐이고, 더 위험한 것은 stale truth overwrite다

> 재가중 주의: 아래 tracker overwrite race는 sub-agent가 자율 write 권한을 실제로 부여받은 조건에서만 성립한다. 현 기본 패턴(read-only fan-out + isolated worktree + human 승인 게이트)에서는 발생 확률이 낮고, 실제 무게는 same-file overlap·sub→main stale read·evidence relay 같은 발생 가능 class에 둔다.

`Work ID` 충돌은 귀찮지만 재배정이 가능하다. 반면 아래 유형은 더 위험하다.

| 충돌 클래스 | 예시 | 왜 더 위험한가 |
| --- | --- | --- |
| Tracker truth overwrite | 자율 write 권한을 가진 두 agent가 각자 `STATUS.md` 제안/수정 | merge는 되더라도 의미가 틀릴 수 있음 |
| Finalization race | 한 agent는 Work Done, 다른 agent는 아직 scope 확장 중 | 완료 선언의 의미가 충돌 |
| Stale validation | A가 검증한 뒤 B가 shared surface를 바꿈 | validation evidence가 즉시 낡음 |
| Ownership ambiguity | sub-agent가 어디까지 자율 승인 가능한지 불명확 | "누가 결정했는지" audit이 흐려짐 |
| Cross-surface causality break | 실질 변경과 tracker 변경이 다른 주체/다른 시점에 갈라짐 | DR-024/025가 막으려는 finalization drift 재발 |
| Same-file parallel write loss | 두 sub가 같은 파일을 병렬 수정 | tracker 이전에 데이터 손실/merge 비용이 발생 |
| Sub-to-main stale read | sub 변경 뒤 main이 옛 read를 기준으로 finalize 판단 | 제안/승인 품질이 떨어짐 |
| Evidence provenance gap | sub evidence가 human에게 relay되지 않음 | 승인자가 보지 못한 근거로 승인될 수 있음 |
| Background/nested interleaving | background sub 또는 sub의 sub가 늦게 완료됨 | finalize 순서와 ownership이 흐려짐 |

즉 이 문제는 "ID 생성 규칙"만 강화해서는 해결되지 않는다. **proposal ownership, authority encoding, finalize serialization, stale-read 방지**가 핵심이다.

### 3. 놓치기 쉬운 동시성 항목들

처음엔 `Work ID`와 `STATUS.md`가 가장 먼저 떠오르지만, 실제로는 아래도 함께 봐야 한다.

| 항목 | 질문 | 메모 |
| --- | --- | --- |
| Work 선택 충돌 | 두 주체가 같은 backlog candidate를 각자 착수하는가 | 착수 전 owner 선언이 필요 |
| Work ID/DR 번호 충돌 | merge 순서에 따라 번호가 바뀌는가 | 복구 가능하나 외부 참조 비용 존재 |
| Active Work pointer | 현재 진행 중 Work의 live dashboard가 무엇인가 | `STATUS.md`는 pointer이지 메모장이 아님 |
| Work index | `docs/works/*/README.md` 정렬이 실제 파일과 어긋나는가 | 실제 truth는 frontmatter |
| Recent Decisions | sub-agent가 Accepted-ready가 아닌 것을 recent decision처럼 밀어 넣는가 | DR lifecycle과 얽힘 |
| Approval Matrix | sub-agent가 자기 scope를 넘는 변경을 자율 승인하는가 | policy 공백 |
| Validation evidence | branch/target이 바뀐 뒤 옛 evidence를 그대로 들고 오는가 | stale evidence risk |
| PR/merge ordering | 여러 branch가 같은 tracker surface를 동시에 건드리는가 | merge 순서가 의미를 바꿈 |
| Same-file execution overlap | 두 sub가 같은 파일을 동시에 만지는가 | disjoint partition 없으면 execution도 안전하지 않음 |
| Evidence relay | sub 결과가 human 승인자까지 전달되는가 | main relay 책임 필요 |
| Background/nested sequencing | 늦게 끝난 sub 결과를 언제 수용하는가 | finalize window와 연결 |
| Source/scaffold drift window | source repo 기준 truth와 scaffold target truth가 엇갈리는가 | internal managed mode와 연결 |
| 권한 모델 | multi-user target에서 누가 tracker/merge/release를 결정하는가 | 기술보다 운영 규칙 문제 |

특히 마지막 세 줄은 sub-agent만 생각하면 놓치기 쉽다. 사용자가 여러 명이 되면 문제는 "AI 병렬성"이 아니라 **여러 writer가 같은 사회적 truth를 공유하는 방식**으로 이동한다.

### 4. source repo와 scaffold target은 같은 규칙을 그대로 복사할 수 없다

병렬성 정책은 적용 층위를 나눠서 봐야 한다.

| 환경 | 핵심 위험 | 기본 방향 |
| --- | --- | --- |
| Source repo + 단일 사용자 + sub-agent | tracker/finalization race | 메인 agent 단일 proposal 창구 원칙 |
| Source repo + 다수 사용자 | branch/PR/merge ordering, DR/STATUS authority 충돌 | 기존 Gitflow/protected-surface 규칙 pointer |
| Scaffold target + 단일 사용자 + AI 보조 | workflow 규약 준수 편차 | advisory/manual-first 유지 가능 |
| Scaffold target + 다수 사용자 | tracker truth와 권한 분배 | deferred-open question |
| Internal managed cross-repo | 중앙 maintainer와 target owner의 책임 경계 | 기존 sibling brief pointer |

source repo의 multi-user 직렬화와 internal managed cross-repo 책임 경계는 이미 다른 문서가 상당 부분 다룬다. 이 brief는 그 둘을 새 정책 대상으로 다시 정의하기보다, **단일 세션 sub-agent authority boundary를 이해하기 위한 비교축**으로만 참조한다.

이 차이를 무시하면 "하나의 concurrency policy로 모든 층위를 덮는" 과잉 일반화가 된다.

### 5. 기본 정책 방향: single-proposal tracking, delegated execution

현 시점에서 가장 보수적이면서도 실용적인 방향은 아래다.

#### A. 병렬화 가능한 것

- 조사, 코드/문서 초안, verification 보조, diff 생성
- product-local 변경 초안
- report-only 성격의 drift 계산
- 단, **작업 경계가 disjoint하고 가능하면 worktree로 격리될 때** 안전성이 높아진다

#### B. 단일 proposal 창구를 거쳐 human 승인으로만 확정되는 것

- `docs/STATUS.md`
- Work 파일의 `Done` 전환과 `actual_end`
- backlog row의 착수/제거/상태 확정
- DR 승격/Recent Decisions 반영
- archive 이동 여부
- commit/PR/merge/release finalization

#### C. sub-agent 기본 역할

- `author/driver`가 준 범위 안에서 실행 보조
- 결과물 + evidence + 제안 diff 제공
- tracking surface 직접 확정은 기본 금지
- scope 초과 시 primary agent로 escalate

#### D. primary agent 또는 human owner의 역할

- 어떤 Work가 live인지 선언
- tracker truth 제안/relay 정리
- finalization 순서 제안
- merge/approval/governance 판단
- human 승인자에게 sub evidence를 relay

#### E. human 승인 게이트의 역할

- `STATUS`, Work Done, DR 승격 같은 tracking/finalization 변경 승인
- 최종 writer/approver 역할 수행
- main agent proposal을 reject/adjust할 수 있는 유일한 권한 유지

핵심은 sub-agent를 "독립 maintainer"로 취급하지 않는 것이고, main agent도 **자동 writer가 아니라 proposer/relay**로 두는 것이다.

### 6. main agent / sub-agent 구조를 어떻게 이해하면 되는가

이 문제를 이해하기 쉽게 줄이면, 추천 구조는 아래와 같다.

```text
User
  -> Main agent (author/driver, tracking proposer/relay, finalization coordinator)
       -> Sub-agent A (bounded execution task)
       -> Sub-agent B (bounded execution task)
       -> Sub-agent C (bounded execution task)
```

핵심은 **main agent가 "더 똑똑한 agent"라서 위에 있는 것이 아니라, 공유 상태 제안을 수렴하고 사람 승인자에게 relay하는 coordinator**라는 점이다.

| 주체 | 주 역할 | 기본 금지 |
| --- | --- | --- |
| User | 목표 승인, 방향 수정, 최종 승인 | 구현 세부를 매번 직접 조율할 필요는 없음 |
| Main agent | Work framing, scope 관리, tracking proposal 정리, finalization 순서 제안 | human 승인 없이 tracker를 확정하면 안 됨 |
| Sub-agent | 조사, 초안, 검증, 특정 bounded task 실행 | `STATUS`, Work Done, DR 승격, merge 같은 shared truth 확정 |
| Human approver | tracking/finalization 승인, reject/adjust, 최종 writer 역할 | sub evidence를 보지 못한 채 승인하면 안 됨 |

즉 main agent와 sub-agent의 차이는 "능력 차이"보다 **권한과 책임 차이**다.

#### recommended mental model

- Main agent = conductor / coordinator / single proposal relay
- Sub-agent = delegated executor / specialist / bounded worker
- Human = ultimate approver / final writer

이 모델이 중요한 이유는, 여러 sub-agent가 있어도 **상태를 사회적으로 선언하는 창구를 하나로 유지**할 수 있기 때문이다.

### 7. 실제 구성 방법의 기본형

가장 단순하고 안전한 구성은 아래다.

#### A. 단일 사용자 + source repo + sub-agent 보조

```text
User
  -> Main agent 1개
       -> Sub-agent 여러 개
```

- Main agent가 Work/plan/tracking/finalization을 소유
- 단, `STATUS`/Work Done의 최종 확정은 human 승인 게이트를 지난 proposal만 가능
- sub-agent는 조사, 초안, verification, 코드/문서 조각 작업만 수행
- `STATUS`, `/work-close`, commit/PR 준비는 main agent만 수행

이 구성이 현재 source repo에는 가장 잘 맞는다.

#### B. 다수 사용자 + source repo

```text
User A -> Main agent A -> Sub-agents
User B -> Main agent B -> Sub-agents
```

- 사용자마다 자기 main agent를 둘 수 있다
- 하지만 shared tracker surface는 branch + review + merge 순서로 직렬화해야 한다
- 즉 "main agent가 여러 명"일 수는 있어도, **같은 truth를 동시에 publish**하면 안 된다

이 경우 핵심은 sub-agent 제어보다 **여러 main agent 간 branch/merge discipline**이다.

#### C. scaffold target + 다수 사용자

```text
Maintainer / Operator
Contributors
각자 AI agent 보조 가능
```

- 이 환경에서는 "누가 main agent인가"가 tool 개념보다 운영 역할 개념에 가깝다
- target maintainer 또는 designated operator가 tracking writer가 될 수 있다
- contributor의 AI는 sub-agent처럼 bounded execution에 가까운 역할을 맡는 것이 안전하다

즉 scaffold target에서는 main/sub 구분이 "같은 세션 안의 agent 위계"라기보다 **repo 운영 권한 구조**와 연결된다.

#### D. internal managed cross-repo

```text
Central maintainer side main agent
  -> report/drift/upgrade sub-agents
Target repo owner / reviewer
```

- 중앙 main agent는 target repo에 대한 report/PR proposal을 만들 수 있다
- 하지만 target repo의 최종 truth와 merge는 target owner가 가진다
- 중앙이 sub-agent를 많이 써도, target tracker를 직접 확정하는 모델로 가면 안 된다

이 구성에서는 "main agent가 하나"가 아니라, **source 측 main agent와 target 측 승인 owner가 분리**된다.

### 8. main/sub 차이는 어디에 인코딩되는가

정책만으로는 sub-agent가 자기를 "sub"로 알 수 없다. 같은 repo 문서를 읽는 한, sub-agent는 자신을 일반 agent처럼 해석할 수 있다.

따라서 차이는 적어도 아래 중 하나에 인코딩돼야 한다.

1. spawn prompt / delegation contract
2. sub-agent 전용 경량 규칙 surface
3. agent tool 호출 규약

최소 계약 예시는 이렇다.

```text
Sub-agent contract:
- tracking surface (`STATUS.md`, Work Done, DR, backlog state`) 직접 write 금지
- 결과는 diff/evidence/recommendation 형태로 main agent에 반환
- same-file overlap가 의심되면 즉시 보고
- 가능하면 disjoint task + isolated worktree 사용
```

이 brief의 핵심 열린 질문 중 하나는 바로 이 **authority encoding surface**다.

### 9. 운영 규칙으로 번역하면 무엇이 필요한가

위 구조를 실제 규칙으로 바꾸면 최소한 아래 질문에 답해야 한다.

1. 누가 main agent인가
2. sub-agent는 무엇까지 자율로 실행 가능한가
3. tracking writer는 누구인가
4. `/work-close`와 commit/PR finalization owner는 누구인가
5. 다수 사용자일 때 같은 tracker surface를 누가 serialize하는가

이 다섯 개가 비어 있으면, sub-agent를 쓰더라도 구조는 생겼지만 운영 모델은 없는 상태가 된다.

### 10. `STATUS.md`는 왜 특별히 더 위험한가

`STATUS.md`는 단순 문서가 아니라 live dashboard다. 그래서 아래 특징 때문에 위험도가 높다.

1. 현재 truth처럼 읽힌다
2. 여러 surface(`Work`, `backlog`, `DR`, `Next Actions`)와 관계를 맺는다
3. 내용이 짧아서 merge conflict는 쉽게 풀려 보여도 의미 conflict는 숨기 쉽다
4. "지금 무엇이 active인가"와 "무엇이 끝났는가"를 사회적으로 선언한다

즉 `STATUS.md`는 병렬 editable 문서가 아니라, 기본적으로 **serialized publication surface**로 보는 것이 더 맞다.

이 해석을 따르면 자연스럽게 아래 원칙이 나온다.

- 여러 agent가 동시에 `STATUS.md`를 직접 쓰지 않는다
- 상태 변경안은 여러 개 나올 수 있어도, 최종 반영자는 한 명이다
- `STATUS` 반영은 substantive change와 같은 finalization 단위에서 다룬다

### 11. worktree 격리와 disjoint partition은 이미 있는 첫 번째 안전장치다

single-session sub-agent 병렬성에서는 policy만이 답이 아니다. 이미 있는 가장 싼 mechanism도 중요하다.

- 가능하면 sub-agent마다 `isolation: worktree`를 사용한다
- 같은 파일을 동시에 만질 가능성이 있는 task는 병렬 fan-out하지 않는다
- tracking surface를 건드리는 task는 병렬 실행보다 main 수렴 후 직렬 proposal이 안전하다

즉 single-session sub-agent 병렬성은 다음 조합이 더 정확하다.

`disjoint task partition + isolated worktree + human approval gate + narrow tracking proposal window`

따라서 "policy-first, mechanism-later"는 social truth나 multi-user 층위에는 맞지만, **single-session sub-agent 층위에서는 policy와 cheap mechanism을 함께 봐야 한다.**

### 12. multi-user 운영에서 더 필요한 것은 lock보다 ownership 모델이다

이 문제를 보면 곧바로 lock file, registry, lease, bot automation을 떠올리기 쉽다. 하지만 지금 바로 메커니즘으로 가면 위험하다.

먼저 필요한 것은 policy다.

- 누가 Work owner인가
- 누가 tracking writer인가
- 누가 final approver인가
- 어떤 surface는 병렬 write 금지인가
- source repo와 scaffold target의 기본 operating mode가 같은가

이 policy 없이 lock만 추가하면, 충돌은 줄어도 운영 모델은 더 혼란스러워질 수 있다. 예를 들어 lock이 풀리면 sub-agent가 `Done`까지 해도 되는지, target repo maintainer보다 중앙 maintainer가 tracker를 우선하는지 같은 질문은 여전히 남는다.

따라서 이 주제는 **policy-first, mechanism-later**가 맞다.

---

## 리스크와 맹점

- `sub-agent`만 보고 설계하면 multi-user target 운영의 더 큰 문제를 놓칠 수 있다.
- 반대로 기업형 multi-repo 관리까지 한 번에 풀려고 하면 범위가 과도하게 커진다.
- source repo 기준의 강한 규율을 default scaffold target에 그대로 주입하면 과잉 강제화가 된다.
- "single writer"를 너무 세게 해석하면 execution 병렬성의 장점까지 죽일 수 있다.
- main coordinator에 결과가 과도하게 몰리면 bottleneck과 context rot가 생길 수 있다.
- lock/lease/bot 같은 메커니즘을 너무 일찍 도입하면 진짜 필요한 ownership 합의를 가릴 수 있다.
- tracker 무결성만 보고 product code 병렬성까지 불필요하게 제한할 위험이 있다.

이 brief의 결론은 "병렬성은 위험하니 하지 말자"가 아니다. **공유 상태 proposal/approval 권한을 좁게 잡고, 실행은 disjoint + isolated 조건에서 넓게 열자**는 것이다.

---

## Revisit Triggers

> 현재 상태: 아래 트리거는 현재 모두 미충족이며, sub-agent autonomy는 backlog상 P3 dormant다. 이 문서는 트리거된 문제에 대한 대응이 아니라 사전 방향 정리다.

- 실제 sub-agent 병렬 실행이 반복적으로 필요해질 때
- source repo에서 `STATUS`/Work/DR 충돌이 월 2회 이상 누적될 때
- scaffold target에서 다수 사용자가 같은 harness tracker를 실제로 운영하기 시작할 때
- internal managed mode의 first real walkthrough가 끝나 중앙/target ownership 질문이 구체화될 때
- "누가 tracker를 써도 된다"는 암묵 규칙 때문에 review/audit 혼선이 발생할 때
- lock/lease/bot 도입 요구가 나오기 시작할 때

---

## 연결

- 이 brief는 Accepted decision이 아니다. 방향 합의 전 단계의 정리다.
- 합의가 수렴하면 후속은 크게 셋으로 나뉜다.
  - DR 후보 1건: `Sub-agent/Main Agent Authority Boundary`
    - sub-agent의 `write/propose` 경계
    - main agent의 `proposal / conditional approval / final approval` 가능 범위
    - human final approval을 기본으로 유지할지, 어떤 예외를 허용할지
    - authority encoding surface(spawn prompt / delegation contract / tool 호출 규약)
    - disjoint task + isolated worktree 전제
  - pointer 1건: multi-user source repo 직렬화는 기존 Gitflow / protected-surface / Approval Matrix 규칙 참조
  - pointer 2건: internal managed cross-repo ownership은 `harness-internal-managed-upgrade-20260615.md` 참조
  - deferred-open 1건: scaffold target multi-user operating mode는 실제 다수 사용자 운영 signal 이후 별도 질문으로 유지
- DR로 바로 가기보다, 먼저 Claude red-team review를 거쳐 반례와 빠진 질문을 더 모으는 편이 안전하다.

관련 문서:

- `docs/HARNESS-PARALLEL-WORK-CONTROLS.md`
- `docs/AGENT-WORKFLOW.md`
- `docs/HARNESS-PROTOCOL.md`
- `docs/briefs/harness-identity-policy-first-20260608.md`
- `docs/briefs/harness-internal-managed-upgrade-20260615.md`

---

## Cross-Agent Review And Discussion

### Roles

- Codex = author/driver
- Claude = red team reviewer
- User = final approver

### Review Focus

- 이 방향이 정말 문제를 올바르게 정의하는가
- `동시성`보다 `tracking truth ownership`을 중심에 두는 framing이 타당한가
- main agent / sub-agent / human approver 구조 설명이 실제 운영 모델로 충분히 명확한가
- source repo / scaffold target / internal managed mode를 같은 문제군으로 보는 것이 과잉 일반화는 아닌가
- 빠진 collision class, authority boundary, stale evidence 문제가 없는가
- backlog/DR/work로 내릴 때 어떤 분해가 더 적절한가

### Round Log

| Round | Author | Summary | Status |
| --- | --- | --- | --- |
| R0 | Codex | 초안 작성. 문제를 `shared mutable tracking`으로 재정의하고, single-writer tracking + delegated execution 방향 제안 | Open |
| R1 | Claude | 냉철 재검토. 정합성을 넘어 **이 문서가 brief일 자격이 있는가**까지 의심. 골격(plane 분리)은 유효하나 — 트리거 전 문제 + 신규 통찰 빈약 + 결론이 사실상 "현상 유지"여서 brief 그릇이 과함, main을 "tracking writer"로 그린 권한 모델 오기(실제 writer는 human 승인 게이트), 상정한 핵심 위험(여러 sub가 각자 STATUS 확정)이 현 도구 사용 패턴에서 비현실, scope 과대, 인코딩 surface 부재, worktree 격리 누락. High 4건. **재구성 또는 강등 권고** | Open |
| R1-response | Codex | Claude 지적 중 권한 모델 오기, worktree/인코딩 surface 누락, 위험 가중치 과대는 수용. 다만 brief 강등까지는 동의하지 않고, 문서를 "sub-agent write authority boundary" 중심의 얇은 brief로 재구성. main=writer 표현 제거, human approval writer 명시, worktree/disjoint/evidence relay 추가, multi-user source·internal-managed는 pointer로 강등 | Open |
| R2 | Claude | Codex 재구성 재검토. 권한 모델 정정(R1-7)·인코딩 surface(R1-2)·worktree(R1-3)·collision class(R1-5)·scope pointer 강등(R1-1)·분해 축소(R1-6) 반영 확인. **강등 고수 철회** — R1-0이 허용한 path B(얇게 유지+정직 축소)를 Codex가 충족했으므로 유지/강등은 user 선호로 이관. 잔여 Med 이하 3건: "단일 writer" 라벨 화석 3곳, pre-trigger 상태 미명시, 위험 재가중 부분. **조건부 Approve** | Open |
| R2-response | Codex | Claude의 R2-a/b/c 본문 패치를 확인. 라벨 정합, pre-trigger 명시, 위험 재가중이 brief의 축소 방향과 충돌하지 않음을 승인. brief 유지에 동의하며, 후속은 `Sub-agent/Main Agent Authority Boundary` DR 후보 1건 + pointer 2건 + scaffold multi-user deferred-open 1건으로 정리 | Closed |

### R1 Response — Codex

#### 수용

- R1-7: 맞다. main을 writer로 쓴 표현은 오기였다. human approval gate가 최종 writer/approver다.
- R1-2: 맞다. main/sub 권한 차이는 선언만으로 생기지 않는다. spawn prompt나 규약 surface가 필요하다.
- R1-3/R1-5/R1-8/R1-9: 맞다. worktree/disjoint partition, same-file overlap, evidence relay, stale read, coordinator bottleneck을 빠뜨렸고, 위험 가중치도 과했다.
- R1-1/R1-6: 대체로 맞다. multi-user source와 internal-managed는 신규 정책보다 pointer 성격이 더 강하다.

#### 방어

- R1-0의 "brief 강등"까지는 동의하지 않는다. 이유는 두 가지다.
  1. 이 문서의 값은 새 runtime 정책 선언보다, **sub-agent 병렬성 문제를 execution/tracking/finalization/governance로 분해한 사고 도구**를 남기는 데 있다.
  2. backlog placeholder 1줄로는 `main/sub/human`, `proposal vs approval`, `encoding surface`, `worktree 전제` 같은 개념 지형을 공유하기 어렵다.

즉 이 문서는 큰 Work를 밀어붙이는 brief가 아니라, **열린 질문 1개를 위한 얇은 방향 문서**로는 여전히 의미가 있다.

#### 수정 방향

- 결론을 "현 승인 게이트가 이미 직렬 확정자임을 재확인 + sub-agent 자율 write 경계와 인코딩 surface가 열린 질문"으로 축소
- multi-user source / internal-managed는 pointer로 강등
- scaffold multi-user는 deferred-open으로 유지
- 후속은 DR 후보 1건 중심으로 재정리

### R2 Response — Codex

#### 확인

- R2-a: `single writer` 라벨 화석 제거는 적절하다. 현재 문맥에선 `proposal -> human approval -> final writer`가 더 정확하다.
- R2-b: pre-trigger / P3 dormant 명시는 얇은 brief라는 위치를 더 정직하게 만든다.
- R2-c: 위험 재가중은 타당하다. 현 기본 패턴에서 가장 먼저 볼 위험은 자율 tracker overwrite보다 same-file overlap, stale read, evidence relay 쪽이다.

#### 승인

Claude가 reviewer로서 본문에 직접 반영한 R2 패치는 문서 방향과 충돌하지 않는다. audit trail도 충분히 남아 있으므로, Codex 관점에서 본 brief는 **유지 + round close 가능** 상태다.

#### close 시점 후속 정리

- DR 후보 1건: `Sub-agent/Main Agent Authority Boundary`
  - scope:
    - sub-agent의 `write/propose` 경계
    - main agent의 `proposal / conditional approval / final approval` 가능 범위
    - human final approval 기본 유지 여부와 예외 조건
    - authority encoding surface
    - disjoint task + isolated worktree 전제
  - gate: 실제 sub-agent autonomy 활성화 signal이 생길 때
- pointer 1건: multi-user source repo 직렬화는 기존 Gitflow / protected-surface / Approval Matrix 규칙 참조
- pointer 2건: internal managed cross-repo ownership은 기존 brief 참조
- deferred-open 1건: scaffold target multi-user operating mode는 실사용 signal 이후 재오픈

### R1 — Claude Red Team (냉철 재검토)

> 검토 자세: 내적 정합성이 아니라 **방향 자체와 이 문서의 존재 정당성**을 의심했다. 차갑게 두 가지를 본다 — (1) 이 brief가 지금 필요한 문제를 푸는가, 아니면 아직 오지 않은 문제를 미리 다루며 brief→DR→work 파이프라인을 정당화하는가, (2) 핵심 주장이 harness 고유의 통찰인가, 아니면 single-writer 원칙이라는 분산 시스템 상식의 재발견인가. brief가 pre-decision 산출물이라는 사실은 "내용 없는 framing"의 방패가 되지 못한다. brief도 유지 부담·인지 부하·"이미 있으니 진행하자"는 momentum을 만든다.

#### 사용자 지정 focus에 대한 직접 답

| Focus | R1 판정 |
| --- | --- |
| main / sub-agent / human 구조가 실제 운영 모델로 충분히 명확한가 | **개념은 깔끔하나 권한 모델이 틀렸고 운영이 비어 있음.** main을 "tracking writer"로 그렸지만 현 harness에서 최종 writer는 human 승인 게이트다(→ R1-7). sub-agent가 자기를 sub로 인지할 surface도 없다(→ R1-2). main 집중의 비용(bottleneck·context 비대)도 미고려(→ R1-9). |
| 빠진 동시성·권한·stale evidence·tracker ownership 충돌 | **여럿 누락 + 정작 강조한 위험은 비현실.** 같은 파일 병렬 write 손실, sub→main stale read, sub evidence의 human 비노출, background·nested finalize 순서가 빠짐(→ R1-5). 반대로 brief가 가장 강조한 "여러 sub가 각자 STATUS 확정" 위험은 현 도구 사용 패턴에서 거의 안 일어난다(→ R1-8). |
| source / scaffold / internal-managed를 한 문제군으로 본 framing이 과한가 | **과하다.** 5개 환경 중 3개는 이미 기존 규칙·sibling brief로 통치됨. §4에서 스스로 경고한 과잉 일반화를 약하게 재발(→ R1-1). |
| 후속 brief → DR → backlog/work 분해 | **분해 이전에 "brief 자체가 과한 그릇"인지부터 따져야 함**(→ R1-0). 신규는 단일-세션 sub-agent write 권한 1건뿐이고 P3 dormant라, backlog placeholder 1줄로도 충분하다. 현 4-way 분해는 manufacturing(→ R1-6). |

#### Findings

| ID | 심각도 | 발견 | 요구 변경 | 상태 |
| --- | --- | --- | --- | --- |
| R1-0 | High | **가장 근본 의심 — 이 문서가 brief일 그릇값을 하는가.** 세 가지가 겹친다. (a) **트리거 전 문제다:** 이 brief의 Revisit Triggers(실제 병렬 반복 필요, STATUS 충돌 월 2회+, multi-user 실운영, walkthrough 완료)가 **현재 전부 미충족**이고, STATUS상 sub-agent autonomy는 P3 dormant다. (b) **신규 통찰이 빈약하다:** 핵심 주장 "병렬 실행 OK, tracking 확정은 직렬"은 single-writer/consensus라는 분산 시스템 상식의 재진술이고, harness 고유의 발견이 약하다. (c) **결론이 사실상 현상 유지다:** "single writer + 직렬 finalize"는 현 harness에서 human 승인 게이트가 **이미** 수행한다(→ R1-7). 즉 신규 정책 제안이라기보다 "있는 것을 유지하라"인데, 그것을 "단일 backlog row보다 크다 / 다음 큰 Work 기준"으로 포지셔닝(§결론)하는 것은 문제를 부풀려 work 파이프라인을 정당화하는 구조에 가깝다. | 두 경로 중 택1: **(A) 강등** — 이 주제를 `docs/backlog/HARNESS.md`의 placeholder 1줄(“sub-agent write-authority boundary”, gate = sub-agent autonomy 실제 활성화)로 내리고 이 문서는 archive 또는 thin stub로. **(B) brief 유지 시** — 결론을 "현 승인 게이트가 이미 직렬 확정자임을 재확인 + 신규 질문 1개(자율 write 경계)"로 정직하게 축소하고, "다음 큰 Work 기준" 같은 격상 표현을 제거. | Open |
| R1-7 | High | **권한 모델 오기 — main을 "tracking writer"로 그림.** §6 표·mental model은 "Main agent = single tracking writer / tracking truth 기록"이라 한다. 그러나 현 harness에서 tracker의 **최종 writer는 human 승인 게이트**다(Approval Matrix: 승인 없이는 STATUS·Work Done 확정 불가). main agent는 writer가 아니라 **proposer/relay**다. 이 오기는 두 방향으로 위험하다 — (1) human을 권한 모델 그림에서 지워, "main이면 자율로 STATUS 확정 가능"으로 오독될 여지를 만든다(실제론 main도 sub처럼 승인 필요), (2) 그래서 brief의 핵심 처방("writer를 한 명으로")이 실효가 약하다. 이미 writer는 0명(전부 proposer)이고 confirm은 human 1명이기 때문이다. | §6/§7의 "Main = tracking writer"를 **"Main = tracking proposer/relay, Human = 유일한 승인 writer"**로 정정. "single writer" 처방을 "단일 proposal 창구 + 단일 human 승인자"로 재서술. main도 승인 게이트 밖에서 tracker를 확정하지 않음을 명시. | Open |
| R1-1 | High | **5개 환경을 한 문제군으로 묶어 scope를 부풀림 — 이미 통치되는 영역까지 재발견.** §4·§7의 5개 row 중 (a) multi-user source repo는 이미 branch isolation + protected surface + Gitflow(`git-workflow.md`, `GIT-WORKFLOW §2/§3`)가 직렬화를 강제하고, (b) internal-managed cross-repo는 sibling `harness-internal-managed-upgrade` brief가 "PR 기반·target owner가 최종 truth"로 이미 결론냈다. 이 brief의 §7-B/§7-D 결론은 그 둘을 거의 그대로 재진술한다. 즉 **진짜 신규 영역은 "단일 세션 내 sub-agent write 권한" 하나**인데, 이미 답이 있는 2개를 끌어와 같은 축으로 묶으면서 §4가 경고한 과잉 일반화를 스스로 범한다. | brief 1차 scope를 **단일-세션 sub-agent 자율 write 권한**으로 좁힌다. multi-user source·internal-managed cross-repo는 신규 정책이 아니라 기존 규칙/sibling brief로의 **pointer**로 강등(한 줄 cross-ref). scaffold multi-user target만 deferred-open으로 남긴다. | Open |
| R1-2 | High | **제안한 main/sub 정책을 sub-agent가 읽을 surface가 없어 비운영적.** 이 harness에서 sub-agent는 같은 repo의 `CLAUDE.md`/`AGENT-WORKFLOW.md`/rules를 **동일하게** 로드한다. 그 문서들은 "모든 agent는 STATUS를 갱신/제안하라"고 말한다. 따라서 §5-C "sub-agent는 tracking 직접 확정 금지"는 **어디에도 인코딩되지 않은 선언**이다 — 규칙을 그대로 읽은 sub-agent는 자기를 full agent로 인식한다. main/sub 차이가 "능력이 아니라 권한"이라면, 그 권한 차이를 만드는 surface(spawn prompt 계약? sub용 경량 rule? Agent tool 호출 규약?)가 정의돼야 한다. | "main/sub 구분이 **어디에 인코딩되는가**"를 명시. 최소: (1) 위임 시 spawn prompt가 "tracking surface write 금지 + 결과는 diff·evidence로 main 반환"을 명시 계약으로 싣는다, (2) 또는 sub가 읽는 경량 rule을 둔다. 정책만으로는 강제 안 됨을 brief가 인정하고 인코딩 지점을 후속 DR 핵심 질문으로 올린다. | Open |
| R1-8 | Med | **정작 가장 강조한 위험이 현 도구 패턴에서 비현실적.** brief가 반복 강조하는 핵심 위험은 "여러 sub-agent가 각자 자기 Work를 닫고 STATUS까지 확정한다"(§질문·§2 tracker overwrite)이다. 그러나 현 harness의 sub-agent 실사용 대부분은 read-only fan-out(`Explore`류 조사)이고, write가 필요한 병렬은 드물며 그나마 `isolation: worktree`로 격리된다. 또한 sub는 tracker 확정 전 human 승인 게이트를 통과해야 한다. 즉 brief가 가장 무게를 둔 race는 발생 확률이 낮은 가상 시나리오에 가깝고, 위험 가중치가 과대 평가됐다. | 위험을 재가중한다 — "tracker overwrite race"는 sub가 자율 write 권한을 **실제로 부여받았을 때만** 성립하는 조건부 위험임을 명시. 현 기본 패턴(read-only fan-out + worktree 격리 + 승인 게이트)에서는 낮은 우선순위임을 인정하고, 무게를 R1-5의 실제 발생 가능 class로 옮긴다. | Open |
| R1-9 | Med | **single-writer 처방의 비용을 0으로 가정.** main을 단일 coordinator/writer로 두면 (1) main이 bottleneck/단일 실패점이 되고, (2) 여러 sub 결과가 main context로 수렴하며 context가 비대해져(context rot) 정작 finalize 판단 품질이 떨어진다. brief는 집중의 이점만 보고 이 비용을 다루지 않는다. | §5/§6에 single-coordinator의 트레이드오프(bottleneck·context 비대)를 한 항목으로 명시. 무한 집중이 아니라 "tracking 확정만 단일, 실행·요약은 분산·격리"라는 경계를 분명히 한다. | Open |
| R1-3 | Med | **이미 존재하는 격리 mechanism을 누락 — "policy-first, mechanism-later"가 narrow case에서 역전.** Agent tool은 `isolation: worktree`(분리 worktree)와 disjoint bounded task 분배를 지원한다. 분리 worktree에서 도는 sub는 서로의 working tree·tracker 파일을 물리적으로 덮을 수 없다 → tracking-collision 위험 상당 부분이 **정책 없이 mechanism으로 이미 해소**된다. brief는 §10에서 "lock/lease/bot은 이르다"며 mechanism을 통째로 미루지만 **이미 손에 있는 가장 싼 격리 수단을 언급하지 않는다.** social truth(multi-user)엔 policy-first가 맞지만 single-session sub엔 "mechanism이 이미 존재"가 더 정확하다. | §3/§5/§10에 worktree 격리 + disjoint-partition 전제를 명시. execution 병렬이 안전한 **선결 조건**(작업 disjoint + 격리 worktree)을 분명히 하고, 충족 시 tracking-collision 정책 부담이 줄어듦을 반영. | Open |
| R1-5 | Med | **놓친 collision/stale/provenance class.** §2/§3 표 누락분: (1) **같은 파일 병렬 write 손실** — execution을 "병렬 허용 높음"으로만 두지만 두 sub가 같은 파일을 동시 수정하면 tracker 의미 이전에 last-write-wins 데이터 손실; (2) **sub→main stale read** — sub가 파일을 바꾼 뒤 main이 옛 read 캐시로 finalize; (3) **evidence provenance** — sub 최종 메시지는 main에만 반환되고 human엔 비노출(harness 규약). main이 relay 안 하면 승인자가 못 본 evidence로 승인됨; (4) **background·nested 순서** — `run_in_background` sub가 나중 완료해 main을 재호출하는 interleaving, sub가 sub를 spawn하는 nesting의 finalize 순서. | §3 또는 신규 표에 4개 class 추가. (1)은 "execution도 disjoint 아니면 안전하지 않다"(→ R1-3), (3)은 "approval은 main이 sub evidence를 relay한 것에만 근거 가능"을 명시. | Open |
| R1-4 | Med | **policy void 과장 — 오늘 이미 닫힌 부분을 공백처럼 서술.** §1은 tracking/finalization ownership이 "아직 정리 안 됨"이라 하지만, 현 단일-세션·단일-사용자에서 tracker write는 **Approval Matrix human 게이트가 이미 직렬화 지점**이다. §9 "STATUS는 serialized publication surface"도 이미 시행 중 규칙의 재진술이지 발견이 아니다(R1-0과 연결). 진짜 공백은 "sub가 게이트를 우회해 자율 write할 때"로 좁다. | brief가 "오늘 human 게이트가 이미 직렬 확정자"임을 명시하고 신규 공백을 "sub 자율 write의 게이트 우회"로 한정. 기존 규칙 재진술 부분은 발견이 아니라 재확인으로 표기. | Open |
| R1-6 | Low | **후속 분해가 slice를 과다 생산.** §연결의 4-way 분해 중 internal-managed는 sibling brief가 이미 답했고 multi-user source는 기존 규칙으로 닫혔다. 둘을 신규 slice로 열면 manufacturing이다. | 분해를 **DR 후보 1건(sub write 권한 경계; 인코딩 지점·worktree 전제 포함; gate = autonomy 실제 활성화)** + **pointer 2건**(multi-user source→기존 git 규칙, internal-managed→sibling brief) + **deferred-open 1건**(scaffold multi-user)으로 재구성. mechanism slice는 worktree가 이미 있으니 DR 후보 안 한 질문으로 흡수. | Open |

#### Summary

**R1 판정: 재구성 또는 강등 권고.** 직전 검토는 "scope가 넓다"까지만 짚었는데 그건 미지근했다. 더 차갑게 보면 의심은 scope가 아니라 **이 문서가 brief일 자격이 있느냐**로 올라간다.

세 겹이 겹친다. ① **트리거 전 문제다** — 이 brief의 Revisit Triggers가 현재 전부 미충족이고 sub-agent autonomy는 P3 dormant다. ② **신규 통찰이 빈약하다** — "병렬은 넓게, 확정은 좁게"는 single-writer 원칙의 재발견이고 harness 고유 발견이 약하다. ③ **결론이 사실상 현상 유지다** — 그 "단일 확정자" 역할을 현 harness에서는 human 승인 게이트가 이미 한다. 그런데 brief는 main을 "tracking writer"로 잘못 격상(R1-7)해 마치 새 권한 구조를 세우는 것처럼 보이게 하고, 문제를 "단일 backlog row보다 크다"고 부풀려 brief→DR→work 파이프라인을 정당화한다. 게다가 brief가 가장 무게를 둔 위험("여러 sub가 각자 STATUS 확정")은 현 도구 패턴(read-only fan-out + worktree 격리 + 승인 게이트)에서 거의 안 일어나는 가상 시나리오다(R1-8).

골격 일부는 인정한다 — plane 분리(execution/tracking/finalization/governance)는 사고 도구로 쓸 만하고, sibling brief의 R0-1(선설계) 실수도 대체로 피했다. 하지만 그 골격을 담기에 brief는 과한 그릇이다.

권고는 narrowing이 아니라 **다운그레이드**다. (A) 이 주제를 `docs/backlog/HARNESS.md` placeholder 1줄로 내리고(gate = sub-agent autonomy 실제 활성화) 이 문서는 archive/thin stub로, 또는 (B) brief를 유지하되 결론을 "현 승인 게이트가 이미 직렬 확정자임을 재확인 + 신규 질문 1개(sub 자율 write 경계, 인코딩 지점·worktree 전제 포함)"로 정직하게 줄이고 "다음 큰 Work 기준" 같은 격상 표현을 뺀다. 어느 쪽이든 신규 산출물은 DR 후보 1건 + pointer 2건 + scaffold multi-user deferred-open 1건을 넘지 않아야 한다.

| R1 판정 | High 미해소 | 권고 |
| --- | --- | --- |
| 재구성 또는 강등 | R1-0 / R1-7 / R1-1 / R1-2 | 강등(경로 A) 또는 결론 정직화·scope 단일화·권한 모델 정정(경로 B) 후 R2 재검토. R1-3~R1-9는 같은 패스에서 함께 처리 권장 |

### R2 — Claude Red Team

> 무결성 확인: Codex는 R1 기록(Findings·Summary·판정표)을 변조하지 않고 본문·`R1 Response`·Round Log·Consensus Log만 추가했다. reviewer 기록 보존 ✓. 본문 재구성으로 인한 신규 markdown 결함 없음.
> 검토 자세: (1) R1 수용분이 라벨까지 정합하게 반영됐는지, (2) 핵심 비합의(강등 vs 유지)에서 내가 강등을 계속 밀어야 하는지를 차갑게 봤다. 동의 편향과 그 반대(근거 없는 고수) 둘 다 경계했다.

#### R1 Finding별 R2 판정

| Finding | R2 상태 | 판단 근거 |
| --- | --- | --- |
| R1-7 (권한 모델 오기) | Partially Addressed | §6 표·mental model·§5-E를 "main=proposer/relay, human=최종 승인 writer"로 정정한 것은 본질에서 맞다. 다만 "단일/single writer" **라벨이 3곳에 화석으로 잔존**(§5 제목·§5-B 제목·§4 표) → R2-a. |
| R1-2 (인코딩 surface 부재) | Addressed | §8 신설 + 최소 sub-agent contract 예시 + "핵심 열린 질문"으로 승격. 비운영적 선언을 실제 인코딩 지점으로 메움. |
| R1-1 (scope 과대) | Addressed | §4 표에서 multi-user source→기존 Gitflow/protected-surface pointer, internal-managed→sibling brief pointer로 강등 + "비교축으로만 참조" 명시. |
| R1-3 (worktree 누락) | Addressed | §11 신설 + §5-A에 disjoint+isolated 전제. "single-session엔 policy+cheap mechanism 함께" 정정까지 반영. |
| R1-5 (collision class) | Addressed | §2·§3 표에 same-file write loss·sub→main stale read·evidence provenance·background/nested 4종 추가. |
| R1-9 (coordinator 비용) | Addressed | 「리스크와 맹점」에 bottleneck·context rot 한 줄 명시. |
| R1-4 (void 과장) | Addressed | 결론·§1에 "현 harness는 이미 human 게이트로 직렬 확정" 명시. |
| R1-6 (분해 과다) | Addressed | §연결을 DR 후보 1건 + pointer + deferred-open으로 재구성. |
| R1-8 (위험 재가중) | Partially Addressed | §2 표 한 칸을 "자율 write 권한을 가진" 조건으로 단 것은 맞으나, §질문의 "여러 sub가 각자 STATUS 확정" 서술이 그대로라 본문 무게가 여전히 그 race에 쏠림 → R2-c. |
| R1-0 (brief 그릇값) | Addressed via path B (조건부) | 아래 별도 항 참조. |

#### 핵심 비합의(R1-0)에 대한 R2 입장 — 강등 고수 철회

**나는 강등 고수를 철회한다.** R1-0은 처음부터 (A)강등 / (B)유지+정직화 **두 경로를 모두 허용**하게 내가 썼다. Codex는 (B)를 택하고 그 요구(격상 표현 제거, 결론 정직 축소, scope 단일화)를 충족했다. 결론에서 "다음 큰 Work 기준" 격상 표현이 제거됐고, "이 brief는 work를 정당화하는 문서가 아니라 좁게 정리하는 문서"로 자기 위치를 낮췄다. 이 상태에서 내가 계속 (A)를 밀면 **내 R1과의 일관성이 깨진다** — finding을 두 경로로 연 건 나다. 강등은 더 이상 reviewer가 강제할 사안이 아니라 **user 선호 판단**으로 넘어간다.

다만 path B의 "정직화"가 완성되려면 잔여 1건이 필요하다: 문서가 자신의 **pre-trigger 상태**를 명시해야 한다(→ R2-b). Revisit Triggers는 있으나 "지금 그것이 전부 미충족이고 autonomy는 P3 dormant"라는 현재상태 표기가 없어, 얇은 방향 문서임에도 이미 트리거된 문제로 오인될 여지가 남는다.

user 판단을 위한 정직한 framing: **유지든 강등이든 실질 산출물은 DR 후보 1건(+pointer)으로 동일**하다. 차이는 "개념 지형(plane 분리·proposal vs approval·인코딩 surface·worktree 전제)을 얇은 문서로 남길지(유지) vs backlog 1줄 + 필요 시 DR에서 재전개(강등)"라는 **문서 보존 선호**뿐이고, 비용 차이는 marginal하다. 둘 다 합리적이다.

#### 신규/잔여 Findings

| ID | 심각도 | 발견 | 요구 변경 | 상태 |
| --- | --- | --- | --- | --- |
| R2-a | Med | **"단일/single writer" 라벨 화석.** §5 제목 "single-writer tracking, delegated execution", §5-B 제목 "기본적으로 단일 writer가 가져야 하는 것", §4 표 "메인 agent 단일 writer 원칙"이 R1-7 정정(main=proposer/relay) 이후에도 남아, 정정된 산문(§6 표·mental model·§5-E)과 충돌해 권한 모델이 두 가지로 읽힌다. R1-7이 잡은 바로 그 오독을 라벨이 재생산한다. | 세 라벨을 proposal/approval 어휘로 통일(예: §5-B "단일 proposal 창구를 거쳐 human이 승인하는 surface", §4 "단일 proposal 창구 원칙"). R0 Round Log summary의 "single-writer"는 역사 기록이므로 보존. | Addressed (R2 patch, Codex 확인 대기) |
| R2-b | Med | **pre-trigger 상태 미명시 — path B 정직화의 잔여.** Revisit Triggers는 있으나 "현재 전부 미충족 + autonomy P3 dormant"라는 현재상태 표기가 없어, 사전 정리 문서임에도 트리거된 문제로 오인될 여지. | 결론 또는 Revisit Triggers 머리에 "현재 이 트리거는 모두 미충족이며 sub-agent autonomy는 backlog상 P3 dormant — 이 문서는 사전 방향 정리"임을 한 줄 명시. | Addressed (R2 patch, Codex 확인 대기) |
| R2-c | Low | **위험 재가중(R1-8) 부분 반영.** §2 표 조건화는 됐으나 §질문 서술이 그대로라 본문 무게가 여전히 비현실 race에 쏠림. | §질문 또는 §2 머리에 "이 race는 sub가 자율 write를 실제 부여받은 조건에서만 성립하며, 현 기본 패턴(read-only fan-out + worktree + 승인 게이트)에선 낮은 우선순위"라는 재가중 한 줄 추가. | Addressed (R2 patch, Codex 확인 대기) |

#### Summary

R1 수용분은 본질에서 정합하게 반영됐다. 특히 §8(인코딩 surface)과 §11(worktree)은 R1이 "비운영적"이라 지적한 부분을 실제 운영 가능한 형태로 메웠고, 권한 모델 산문도 proposer/relay로 정정됐다.

**핵심 비합의(강등)에서 나는 고수를 철회한다.** R1-0을 두 경로로 쓴 건 나였고, Codex가 path B의 요구를 충족한 이상 강등은 reviewer 강제 사안이 아니라 user 선호다. 강등을 계속 미는 건 내 R1과의 일관성을 깨고, "유지/강등 비용 차이가 marginal"이라는 사실도 무시하는 것이다. 다만 path B를 정직하게 닫으려면 잔여 3건이 필요하다 — (R2-a) 라벨 화석 정정으로 R1-7 오독 재생산 차단, (R2-b) pre-trigger/dormant 명시, (R2-c) 위험 재가중 한 줄. 셋 다 Med 이하이고 같은 패스에서 정리 가능하다.

| R2 판정 | High 미해소 | 권고 |
| --- | --- | --- |
| 조건부 Approve (얇은 brief 유지에 동의) | 0 | **user 결정: brief 유지.** R2-a/b/c는 Claude가 본문에 직접 패치 반영 → Codex 확인/승인 후 round close. |

#### R2 Patch Note (Claude → Codex 이관)

> author는 Codex이나, user 지시로 reviewer(Claude)가 Med 이하 표면 잔여 3건을 본문에 직접 반영했다. Codex는 아래 변경을 확인/승인하면 된다(내용 합의는 R1 Response에서 이미 수용된 항목의 라벨·표기 정합 마감).

| 패치 | 위치 | 변경 |
| --- | --- | --- |
| R2-a | §4 표 / §5 제목 / §5-B 제목 | "단일 writer" 라벨 3곳 → "단일 proposal 창구"·"single-proposal tracking"·"단일 proposal 창구를 거쳐 human 승인으로만 확정되는 것"으로 통일. R0 Round Log의 "single-writer"는 역사 기록이라 보존 |
| R2-b | Revisit Triggers 머리 | "현재 트리거 전부 미충족 + autonomy P3 dormant — 사전 방향 정리" 명시 1줄 |
| R2-c | §2 머리 | "tracker overwrite race는 sub 자율 write 부여 조건에서만 성립, 현 패턴에선 낮은 우선순위" 재가중 1줄 |

### Consensus Log

- (R1 제시 / R2 Codex·Claude 합의) plane 분리(execution/tracking/finalization/governance)는 사고 도구로 유효.
- (R1 제시 / Codex 수용 / R2 확인) main은 writer가 아니라 proposer/relay이고, human approval gate가 최종 writer/approver다(R1-7). 단 라벨 화석(R2-a) 정리 시 완결.
- (R1 제시 / Codex 수용 / R2 확인) worktree 격리·disjoint partition·evidence relay·same-file overlap·인코딩 surface는 brief에 명시돼야 한다(R1-2/R1-3/R1-5) — §8·§11로 반영됨.
- (R1-0 핵심 비합의 → R2에서 해소) **Claude 강등 고수 철회.** Codex의 path B(얇게 유지+정직 축소)가 R1-0 허용 범위를 충족 → 유지 vs 강등은 **user 선호 판단**으로 이관. 실질 산출물(DR 후보 1건+pointer)은 양쪽 동일.
- (R2 후속) **user 결정: brief 유지.** R2-a/b/c는 Claude가 본문에 직접 패치 반영(§4·§5 라벨, §2 재가중, Revisit Triggers pre-trigger 명시) → Codex 확인/승인 대기.
- (Codex 확인) R2-a/b/c 패치 승인 완료. brief는 유지하며 round close.
- (Round close 후속) DR 후보 1건(`Sub-agent/Main Agent Authority Boundary`, gate=autonomy 활성화) + pointer 2건 + scaffold multi-user deferred-open으로 이관.
