---
date: 2026-06-15
track: harness
type: milestone-retrospective
scope: AI Workflow Harness v1.2.0 readiness — W1~W5 완료 후 설계·운영·제품성 평가
author: "agent:codex + agent:claude-opus-4-8"
related_work: [CHORE-20260611-005, CHORE-20260611-010, CHORE-20260612-001, CHORE-20260613-006, CHORE-20260613-020]
---

# AI Workflow Harness v1.2.0 Readiness Retrospective

> 작성일: 2026-06-15
> 작성 방식: Codex 초안 작성, Claude가 같은 파일에 별도 review round를 추가할 수 있는 공동 회고 형식
> 범위: W1 Validation Spine, W2 Adopter Transition, W3 Workflow IA Diet, W4 Lifecycle Hygiene, W5 Optional/Future
> 목적: v1.2.0 전후의 현재 하네스 수준을 과장 없이 평가하고, 잘 된 점·미비한 점·다음 보완 방향을 기록한다

---

## 결론

이 하네스는 이제 "AI workflow 아이디어 모음"이나 "prompt bundle" 수준은 넘었다.
현재 상태는 **manual-first AI 운영체계의 source repository**에 가깝다. 상태판, Work lifecycle, approval gate, branch isolation, scaffold, migration note, validation spine, archive policy까지 한 축으로 연결되어 있다.

다만 아직 "누구나 부담 없이 쓰는 공개 제품"은 아니다. 더 정확히 말하면, 검증된 것은 **source repo 내부 운영 기반**이고, 내부 조직 표준화는 **구조적으로 유망하지만 미검증인 후보**다. 실제 다팀 운용 사례, live adopter 장기 운영, 반복 upgrade flow는 아직 없다.

반대편 리스크도 같은 무게로 봐야 한다. 최근 산출 에너지의 큰 비중이 product delivery보다 하네스 자체 governance에 쓰였고, 이 회고 자체도 단일 maintainer + AI review 루프 안에서 작성됐다. 이 메타 작업 일부는 배포 가능한 framework 내용을 만든 것이지만, 하네스가 자기 자신의 주 고객이 되는 self-referential 최적화 위험은 남아 있다.

냉정한 종합 판단:

| 관점 | 현재 판단 | Evidence / Gap | Band |
| --- | --- | --- | --- |
| 설계 성숙도 | source/scaffold/product 경계를 구조적으로 다루며, 실제 운영 실패 모드를 많이 흡수했다 | W1~W5 산출물과 회귀 검증 체계 존재 | Strong |
| 운영 안정성 | 승인 게이트, branch isolation, validation spine, closeout 절차가 강하다 | source repo 내부 운영에는 적용됨. 다팀 운영 stress test는 부족 | Strong but local |
| 자동화 완성도 | 검증 자동화는 강해졌지만 upgrade/apply/fleet 운영 자동화는 아직 초기다 | deterministic checks는 증가. 반복 upgrade PR flow 없음 | Adequate |
| 신규 사용자 온보딩 | 문서는 좋아졌지만 처음 온 사람에게는 여전히 무겁다 | docs 약 42k줄, md 287개, 비공식 용어 DSL 부담 | Weak |
| 내부 조직 표준화 잠재력 | 구조적으로는 높지만 실제 다팀 운용 사례 0건이다 | "표준화 기반"이 아니라 "표준화 후보"로만 판단 가능 | Unproven |
| Product delivery proof | 하네스가 실제 product delivery를 줄였다는 증거는 아직 없다 | live adopter 장기 운영 / release complete 사례 없음 | None yet |
| 공개 범용 제품성 | 가치가 분명하나 학습 비용과 운영 전제가 높다 | happy path와 packaging 부족 | Unproven |

한 문장으로 요약하면:

> v1.2.0의 AI Workflow Harness는 "잘 아는 maintainer가 책임지고 굴리면 강한 source 운영 프레임워크"다. 하지만 내부 조직 표준화와 product delivery 효용은 아직 미검증이다. 다음 단계는 문서를 더 늘리는 것이 아니라, 첫 실제 adopter walkthrough와 초심자 happy path로 이 정교한 모델이 현실에서 어디서 깨지는지 관측하는 것이다.

---

## 1. 이번 W1~W5가 실제로 만든 것

### W1 — Validation Spine

W1의 가장 큰 성과는 "검증을 해야 한다"는 선언에서 벗어나, 어떤 surface를 어떤 깊이로 확인할지 분류한 점이다.

특히 다음 변화는 품질을 실제로 올렸다.

- source repo maintainer 전용 검증 문서와 runner 체계를 만들었다.
- scaffold 생성, invariant, shipped DR closure, onboarding flow, surface mirror parity를 각각 다른 층위로 분리했다.
- `temp/harness-tests/`를 실 scaffold 검증 장소로 정렬해 검증 artifact가 repo를 오염시키지 않게 했다.
- 모든 검사를 CI hard gate로 밀어 넣지 않고, manual runner / repo-health / release sweep의 역할을 나눴다.

좋은 점:

검증 체계가 "문서상 체크리스트"에서 "재현 가능한 운영 자산"으로 올라갔다.

미비한 점:

검증 자동화가 강해진 만큼, 어떤 검사를 언제 실행해야 하는지 이해하는 비용도 생겼다. maintainer에게는 유용하지만, adopter에게는 아직 대부분 source-only 배경지식이다.

### W2 — Adopter Transition

W2는 이 하네스가 실제 project repo로 나갈 때 가장 위험한 지점을 다뤘다. 핵심은 upgrade/migration, onboarding, planning pack, clone verification이다.

잘 된 점:

- pre-manifest target을 단순히 "old target"으로 뭉개지 않고 inventory-first로 다뤘다.
- shadow scaffold baseline을 통해 manifest 없는 target도 현재 source와 비교할 수 있는 길을 만들었다.
- source-owned, product-owned, import-candidate 경계를 product starter planning pack에 명시했다.
- multi-user clone verification으로 "내 로컬에서는 된다"보다 강한 협업 진입 경로를 검증했다.

미비한 점:

아직 실제 target repo에 대한 반복 가능한 upgrade PR flow는 없다. `--check`와 migration note는 기준을 주지만, 중앙에서 여러 repo를 책임지고 올리는 도구는 아니다. 즉 W2는 "manual selective migration의 신뢰도"를 만들었고, "managed fleet upgrade"는 아직 만들지 않았다.

### W3 — Workflow IA Diet

W3는 좋은 방향의 절제였다. 큰 구조 변경을 더 벌리기보다 routing, trigger, prompt surface, repo-health slice를 줄이고 명확히 했다.

잘 된 점:

- live `prompts/` surface를 fallback-only로 줄여 prompt library와 운영 surface를 분리했다.
- Protocol Load Map / Context Routing을 더 작은 읽기 경로로 정리했다.
- repo-health를 하나의 과중한 절차가 아니라 canonical slice로 분리했다.
- trigger family를 핵심 workflow 중심으로 정렬했다.

미비한 점:

IA diet가 성공했지만, 전체 시스템은 여전히 처음 보는 사람에게 작지 않다. "덜 복잡해졌다"와 "쉽다"는 다르다. W3는 maintainer load를 줄였지만, adopter UX를 획기적으로 낮춘 것은 아니다.

### W4 — Lifecycle Hygiene

W4의 성과는 운영 실수를 모두 hard gate로 만들지 않고, hard gate가 맞는 것과 behavioral rule로 남길 것을 나눈 점이다.

잘 된 점:

- branch isolation을 실제 hook/runtime 수준으로 강화했다.
- protected workflow surface를 class-sensitive하게 분류했다.
- archive 누적 정책을 정리해 live README가 archive index로 비대해지는 문제를 줄였다.
- runner / CI / pre-commit 배선에서 "무배선" 결정을 내려 중복 강제를 피했다.

미비한 점:

정책 분류가 정교해진 만큼, 새 maintainer가 I0/T1/S1/P1/P2 같은 분류를 빠르게 내면화하기는 어렵다. 현재는 강한 내부 운영자에게는 안정성을 주지만, 새 팀에게는 용어 부담으로 보일 수 있다.

### W5 — Future / Optional

W5는 잘 참은 영역이다. Spring Boot MSA TDD option-pack, template pack, Windows, CLI naming audit 같은 후보를 당장 만들지 않고 실제 product 운용 후로 미뤘다.

잘 된 점:

옵션을 만들 수 있다는 이유로 만들지 않았다. 이건 중요한 성숙도다.

미비한 점:

W5 후보가 "언젠가 필요할 수 있음" 상태로 오래 남으면 다시 portfolio noise가 될 수 있다. 실제 product 운용 signal이 없으면 주기적으로 drop 또는 hold 이유를 갱신해야 한다.

---

## 2. 가장 잘 된 점

### 2.1 문제 정의가 실제 운영에서 나온다

이 하네스는 추상적인 "AI agent best practice"가 아니라, 반복 세션에서 실제로 터지는 문제를 다룬다.

- 상태 drift
- approval 없이 scope가 커지는 문제
- scaffold source와 target project의 ownership 혼동
- tool-specific command/rule drift
- Done work와 archive 누적
- migration에서 project-owned 파일을 덮어쓸 위험

그래서 문서가 많아도 공허하지 않다. 대부분은 실제 실패 모드에 대응한다.

### 2.2 source / scaffold / product 경계를 포기하지 않았다

이번 v1.2.0 근처의 가장 큰 품질은 경계 감각이다.

- source repo는 framework를 유지보수한다.
- scaffold target은 project state를 가진다.
- product-owned 산출물은 source로 바로 흡수하지 않고 import candidate로 분류한다.
- source-only maintainer 문서는 scaffold로 새지 않게 한다.

이 경계를 계속 유지한 덕분에 하네스가 단순 template repo나 product monorepo로 흐르지 않았다.

### 2.3 수동 절차와 자동 검증의 균형이 좋아졌다

초기에는 manual-first가 약점처럼 보일 수 있었다. W1~W4 이후에는 조금 다르다.

지금은 모든 것을 자동화하지 않는 대신, 자동화할 가치가 있는 검증만 deterministic check로 승격하고 있다. 반대로 language policy처럼 false-positive가 큰 영역은 보류했다. 이 판단은 건강하다.

### 2.4 Claude / Codex 역할 분담이 실제 품질을 올렸지만, 외부 검증은 아니다

여러 Work에서 author/driver와 reviewer를 분리한 것은 형식이 아니라 실질적으로 효과가 있었다.

특히 upgrade/migration 계획에서 처음에는 freshness 동어반복에 가까운 검증이 있었고, reviewer가 이를 잡아 "manifest만 심기 → drift 분포 관측 → selective 반영" 순서로 교정했다. 이런 round가 없었다면 문서는 그럴듯하지만 실제 migration 증명은 약했을 가능성이 높다.

다만 이것은 독립 외부 검증이 아니다. 같은 maintainer 맥락 안에서 Codex와 Claude가 역할을 나눈 것이며, 실제 팀·다중 maintainer·외부 adopter가 주는 압력과는 다르다.

### 2.5 scope를 줄이는 결정을 여러 번 했다

이번 구간에서 좋은 결정은 만든 것만이 아니라 만들지 않은 것도 포함한다.

- full `--upgrade` apply 구현을 미뤘다.
- runner를 CI required check로 무리하게 배선하지 않았다.
- archive cleanup을 자동 확장하지 않았다.
- option-pack을 실수요 전까지 보류했다.
- 독립 post-release 절차 블록을 만들지 않고 기존 절차에 최소 검증만 흡수했다.

이런 "안 하는 결정"이 없었다면 하네스는 훨씬 빨리 무거워졌을 것이다.

---

## 3. 가장 미비한 점

### 3.1 신규 사용자의 첫 30분은 아직 무겁다

README, onboarding guide, quick reference가 좋아졌지만, 처음 온 사용자는 여전히 다음 질문 앞에서 멈출 가능성이 있다.

- 그래서 오늘 내가 뭘 먼저 해야 하지?
- 이 많은 문서 중 사람이 읽을 것은 무엇이고 AI가 읽을 것은 무엇이지?
- Quick Mode와 Work file 사용의 경계는 언제지?
- source repo maintainer 문서는 내 target repo에도 필요한가?

문서 정합성은 높지만, "첫 화면 UX"는 아직 충분히 낮지 않다. 현재 사용자는 운영 전에 docs 약 42k줄, md 287개, 그리고 Work·DR·Tier·Layer·I0/T1/S1/P1/P2 같은 작은 bespoke DSL을 마주한다.

### 3.2 upgrade/migration은 정책은 생겼지만 운영 도구는 부족하다

현재 방식은 외부 adopter나 단일 target 수동 migration에는 정직하다. 하지만 사내 여러 프로젝트에 중앙 하네스를 표준 적용하는 상황에서는 부족하다.

지금 필요한 다음 단계는 `--upgrade`를 무작정 만드는 것이 아니다. 더 적절한 방향은 internal managed fleet mode다.

중앙 source repo가 target registry를 알고, 각 target을 clone/fetch하고, framework-owned drift를 계산하고, target repo에 upgrade PR을 생성하는 방식이다. 직접 push가 아니라 PR 기반이어야 한다. 그래야 인증, 감사, review, rollback이 git workflow에 남는다.

### 3.3 제품성보다 maintainer-brain이 강하다

현재 문서들은 정확하지만, 종종 "하네스를 만든 사람의 사고 흐름"을 공유한다. 내부 maintainer에게는 큰 장점이다. 그러나 adopter에게는 과하게 깊은 배경으로 느껴질 수 있다.

다음 개선은 문서를 더 줄이는 것만으로 해결되지 않는다. 같은 정보를 다음 세 층으로 다시 포장해야 한다.

- 10분 happy path
- daily operator guide
- maintainer deep reference

### 3.4 용어 체계가 강하지만 학습 비용이 있다

Work, DR, OQ, Layer, Tier, W1~W5, I0/T1/S1/P1/P2, source-gitflow, source-only, shipped surface 같은 용어는 운영 정확도를 높인다.

하지만 처음 보는 사람에게는 이 자체가 작은 DSL이다. DSL이 나쁜 것은 아니지만, 제품화하려면 glossary와 "모르면 일단 이렇게 하라"는 escape path가 필요하다.

### 3.5 실제 product delivery 검증은 아직 부족하다

하네스 자체는 많이 검증됐다. 그러나 이 하네스를 적용한 product가 장기간 개발되고, 여러 명이 참여하고, release까지 도달한 사례는 아직 제한적이다.

따라서 현재 평가는 "source repo 운영 프레임워크로서의 성숙도"가 높다는 뜻이지, "모든 product team이 바로 생산성 향상을 얻는다"는 뜻은 아니다.

### 3.6 하네스가 자기 자신의 주 고객이 되는 리스크

Claude R0 기준 수치로는 커밋 635개 중 docs 240개 + chore 168개, 총 408개가 하네스 자체 governance와 문서화에 가까운 작업이었다. 이것은 하네스가 실제 product delivery보다 자기 자신의 운영 모델을 더 많이 최적화하고 있을 수 있다는 신호다.

단, 이 메타 작업 전부가 낭비라는 뜻은 아니다. 이 repo는 framework source이므로 문서·workflow·scaffold 자체가 배포 deliverable이다. 문제는 meta 작업이 product value 검증을 계속 대체할 때 생긴다.

### 3.7 리뷰 루프가 단일 maintainer 맥락 안에 닫혀 있다

Codex 작성 + Claude 리뷰는 실제 결함을 잡았다. 하지만 author와 reviewer가 모두 같은 maintainer의 목표·문맥·선호 안에서 움직인다. 이 회고 자체도 같은 루프의 산물이며 external validation이 아니다.

다자 운영, 권한이 다른 contributor, 실제 adopter team은 아직 충분히 stress-test하지 않았다. 최근 multi-user clone verification에서 G1/G2 Critical gap이 발견된 것도 이 경계가 아직 약하다는 근거다.

---

## 4. 앞으로 보완해야 할 점

### 4.1 First Product Walkthrough

`ai-deck-compiler` 같은 실제 target에 대해 다음을 끝까지 해봐야 한다.

- current source 기준 drift plan 작성
- target-local customization 분류
- upgrade PR 생성 또는 수동 equivalent 수행
- target repo CI / docs validation 확인
- DR-034를 Draft에서 Accepted로 승격할지 판단

이 작업이 끝나야 W2의 upgrade/migration은 "정책과 simulation"에서 "실제 target 운영 경험"으로 넘어간다.

이것이 다음 work의 선행 gate다. 첫 실제 upgrade 경험 없이 fleet orchestration을 먼저 설계하면, 관측 0인 상태에서 다시 meta 최적화를 쌓는 일이 된다.

### 4.2 Internal Managed Fleet Upgrade Mode

방향은 유망하지만, 첫 실제 walkthrough 1건 이상이 끝난 뒤 opt-in 탐색으로 다뤄야 한다.

목표:

중앙 harness source가 사내 target repo 목록을 알고, 각 repo의 framework-owned drift를 계산해 upgrade PR을 생성한다.

기본 원칙:

- target repo는 독립 repo로 유지한다.
- 중앙은 직접 push보다 PR을 만든다.
- registry에는 repo URL, workflow mode, profile, owner, upgrade policy, accepted drift만 둔다.
- 인증은 repo에 저장하지 않고 GitHub App 또는 CI secret로 관리한다.
- project-owned 파일은 자동 overwrite하지 않는다.
- PR 본문에는 drift report, changed framework files, manual-merge candidate, skipped accepted drift를 남긴다.

이 방향은 기존 외부 adopter selective migration과 충돌하지 않는다. 외부 adopter 경로는 그대로 두고, 내부 조직용 opt-in mode로 추가할 수 있다. 다만 real walkthrough 전에는 "가장 중요한 다음 후보"가 아니라, walkthrough 결과가 반복 운영 필요를 증명할 때 꺼내는 후속 후보로 둔다.

### 4.3 Happy Path 압축

새 사용자에게는 다음 한 장이 필요하다.

- 새 project에 적용할 때: 1-2-3
- 이미 적용된 project를 시작할 때: 1-2-3
- 뭔가 수정하고 싶을 때: Quick Mode vs Work file
- AI에게 첫 메시지로 무엇을 말할지

현재 문서는 정확하지만, happy path는 더 얇아져야 한다.

### 4.4 Glossary / Concept Map

용어가 많아진 것은 어느 정도 불가피하다. 대신 처음 보는 사람이 시스템을 머릿속에 올릴 수 있는 concept map이 필요하다.

우선순위 높은 용어:

- source repo / scaffold target / product repo
- framework-owned / project-owned / accepted drift
- Work / DR / STATUS / backlog
- Tier / Layer / runner
- shipped surface / source-only surface

### 4.5 Product Track 실전 검증

하네스 자체 개선만 계속하면 자기참조적 안정성은 올라가지만, product delivery 효용은 검증되지 않는다.

다음 product track 검증에서는 하네스를 고치는 것보다, 하네스가 제품 작업을 얼마나 덜 흔들리게 만드는지 봐야 한다.

관찰할 것:

- 계획 수립이 빨라졌는가?
- scope drift가 실제로 줄었는가?
- 두 번째 contributor가 들어왔을 때 마찰이 줄었는가?
- Work/DR 작성 비용이 얻는 가치보다 크지 않은가?
- AI가 같은 설명을 반복해서 요구하는 일이 줄었는가?

---

## 5. 유지해야 할 원칙

### 5.1 문서를 늘리기 전에 routing을 먼저 보라

문제가 생겼을 때 새 문서를 만들기 쉽다. 하지만 W3가 보여준 교훈은 반대다.

먼저 물어야 한다.

- 기존 문서의 어느 조건부 섹션으로 라우팅할 수 있는가?
- core 문서에 들어갈 내용인가, source-only maintainer 문서인가?
- target repo에 ship되어야 하는가?
- 이 절차는 반복되는가, 한 번의 migration note인가?

### 5.2 자동화는 "반복되고 피해가 큰 실수"부터 한다

모든 규칙을 hook/CI로 강제하면 하네스가 workflow engine 흉내를 내기 시작한다.

이 하네스의 현재 입장은 다음처럼 명시해야 한다. 검증 **저작**은 자동화하고, **집행**은 기존 CI/pre-commit choke point에 한정하며, **판단**은 수동으로 둔다. runner 무배선은 자동화 회피가 아니라 이 경계의 결과다.

자동화 후보의 기준은 계속 엄격해야 한다.

- 위반 피해가 큰가?
- 기계적으로 판단 가능한가?
- false positive가 낮은가?
- 사람이 매번 놓치는 반복성이 있는가?

### 5.3 source와 target의 경계를 섞지 않는다

이 repo의 가장 중요한 자산은 경계 감각이다.

source repo가 product 내용을 대신 작성하거나, target repo가 source-only maintainer 지식을 기본으로 요구하거나, scaffold가 source 내부 결정을 과하게 ship하기 시작하면 하네스의 장점이 흐려진다.

### 5.4 "Done"을 존중한다

Done Work는 계속 수정하지 않는다. 후속 보정은 새 Work로 분리한다.

이 원칙은 작은 것 같지만, 장기 운영에서는 중요하다. 완료된 작업을 계속 덧칠하기 시작하면 회고와 추적이 흐려진다.

---

## 6. 에이전트 독립 평가

> §6은 Codex와 Claude가 각자 독립적으로 내린 standalone 평가다. §7(Codex 초안을 대상으로 한 Claude의 리뷰 라운드)과는 성격이 다르다. 두 평가 모두 같은 maintainer 루프 안에서 작성됐으며 external validation은 아니다(§3.7).

### 6.1 Codex

Codex 관점의 현재 평가는 다음과 같다.

#### 총평

처음 보는 repo라고 가정해도, 이 하네스는 장난감이 아니다. 운영 문제를 실제로 겪고, 그 문제를 문서·검증·gate·scaffold 구조로 흡수하려는 수준이 높다.

동시에 이 repo는 아직 "친절한 제품"이라기보다 "강한 운영자가 있는 source framework"다. 현재의 정교함은 장점이지만, adopter의 첫 경험에서는 부담이 될 수 있다.

#### 가장 인상적인 점

- 실패 모드를 숨기지 않는다.
- scope expansion을 인간 승인으로 묶는다.
- source/scaffold/product 경계를 반복해서 확인한다.
- 검증을 무작정 hard gate로 만들지 않고 비용과 false positive를 따진다.
- cross-agent review가 실제 결함을 잡는 프로세스로 작동한다.

#### 가장 걱정되는 점

- 문서가 정확한 만큼, "정확히 알아야 쓸 수 있다"는 느낌을 줄 수 있다.
- internal fleet 운영처럼 실제 기업 환경에서 필요한 다음 자동화는 아직 없다.
- product delivery 효용은 아직 source repo 운영 효용만큼 증명되지 않았다.

#### Codex의 한 줄 판단

> 이 하네스는 v1.2.0 기준으로 내부 조직 표준화 후보로는 충분히 강하다. 공개 범용 도구가 되려면 다음 라운드는 문서 정교화가 아니라 운영 UX와 managed upgrade가 중심이어야 한다.

### 6.2 Claude (Opus 4.8) 독립 평가

> 이 세션에서 사용자 요청으로 작성한 Claude의 독립 첫 평가다. repo 구조 실측(320 files / 635 commits / docs+chore 408)에 기반하며, Codex 초안을 보기 전 관점이다.

한 줄 결론: **공예품·참조 설계로는 상위권, 가동 중인 프로세스로는 미검증 + 과축조 의심.** SSoT-mirror + gate + DR 규율은 대부분의 "AI workflow" 결과물보다 한 체급 위지만, 그 정교함이 외부 부하 없이 자기 내적 정합성을 최적화하는 쪽으로 기운다.

| 축 | Band | 한 줄 근거 |
| --- | --- | --- |
| 설계·아키텍처 | Strong | canonical↔adapter mirror + parity check로 규칙 drift를 구조적으로 차단 |
| 정책 실집행력 | Strong | pre-commit hook이 gate-config를 읽어 branch isolation을 실제 차단 |
| 의사결정 추적성 | Strong | DR 30건 + reversal cost 기록 |
| 단순성(시스템 차원) | Weak | line 단위는 minimal을 설교하나 system 차원은 self-customer(메타 408/635) |
| 신규 온보딩 | Weak | bespoke DSL(Work·DR·Tier·Layer·I0/T1/S1/P1/P2) + 287 docs |
| 실전 검증 | None yet | 실제 adopter 0, archived works 0 |
| 거버넌스 견고성(다자) | Unproven | 단일 author + 자기 AI 루프, 다자 부하 미경험 |

세 핵심 리스크는 §7 리뷰와 **독립적으로 동일하게 수렴**했다 — ① 하네스가 자기 자신의 주 고객(self-referential 최적화), ② 진공 속 내적 정합성 최적화(실 adopter 0), ③ manual-first↔automation 입장 미선언. 세부 finding·근거·교정 방향은 §7을 참조한다.

한 문장: 이 모델의 가장 높은 한계효용 지점은 새 거버넌스 레이어를 더 쌓는 것이 아니라, 단 하나의 실제 adopter walkthrough로 어디서 깨지는지 관측하는 것이다(§4.1).

---

## 7. Claude Review Round

> 이 섹션은 Claude R0 review round다. 목적은 Codex 평가에 동의 표시를 하는 것이 아니라,
> 과장·논리 비약·빠진 리스크를 잡아내는 것이다. 칭찬은 §6 Codex 총평으로 충분하므로 여기서는 반박과 누락에 집중한다.
> 판정 기준: High finding이 하나라도 미해소면 approve-as-is 불가, R1로 넘기지 않는다.

### Review Questions

| 질문 | Claude 검토 |
| --- | --- |
| v1.2.0 readiness 평가가 현재 산출물 대비 과장되어 있지 않은가? | **부분적으로 과장.** 강점 측 점수(내부 표준화 9/10, 운영 안정성 8)는 archived works 0 · live adopter 0 · 반복 upgrade flow 0 상태에서 **검증되지 않은 역량을 측정값처럼 제시**한다. 약점 측 서술은 evidence-backed지만 강점 측은 aspirational. (R0-1, R0-4) |
| "internal managed fleet upgrade mode"를 다음 핵심 후보로 보는 판단이 합리적인가? | **방향은 합리적이나 "다음 핵심 후보"로서는 priority inversion.** §4.2 First Product Walkthrough가 §4.1의 논리적 전제다. 단 한 번의 실제 upgrade도 없이 fleet orchestration을 1순위에 두는 것은 이 회고가 §3.5에서 경고하는 "진공 속 최적화"의 재발. fleet mode는 ≥1 real walkthrough 뒤로 gate해야 한다. (R0-3) |
| 신규 사용자 온보딩 부담을 충분히 냉정하게 봤는가? | **방향은 맞으나 강도가 약하고 점수가 후하다.** §3.1/§3.4가 문제를 정확히 짚지만 구체 규모(docs 약 42k줄 · md 287개 · 여러 문서가 다른 문서를 설명 · 비공식 용어 DSL)를 수치로 박지 않아 체감이 약하다. 6/10은 charitable — 실측 기준 5/10에 가깝다. (R0-7) |
| W1~W5의 미비점 중 빠진 것이 있는가? | **세 가지 누락.** ① meta/value 비율 — 커밋 635개 중 docs+chore 408개로 하네스가 *자기 자신의 주 고객*이 된 구조 리스크가 §3 어디에도 없다(R0-2). ② reflexivity — author + 자기 AI는 독립 적대자가 아니며 multi-contributor 경로는 최근에야 G1/G2 Critical gap으로 *발견*됐는데 §2.4는 cross-agent review를 검증된 강점으로만 서술(R0-5). ③ manual-first↔automation 입장이 명시 선언되지 않음 — 무배선은 국소 방어 가능하나 "저작=자동/집행=choke point/판단=수동" 경계가 정체성에 박혀 있지 않음(R0-6). |
| 점수 평가가 실제 운영 evidence와 어긋나는가? | **Yes.** 가장 큰 어긋남은 "내부 조직 표준화 잠재력 9/10" — 이를 뒷받침할 실제 내부 팀 운용 사례가 0이다. decimal precision(8.5/6.5) 전반이 측정 근거 없는 false precision. (R0-1, R0-4) |

### Claude Findings

| ID | Severity | Finding | Required Change | Status |
| --- | --- | --- | --- | --- |
| R0-1 | High | "내부 조직 표준화 잠재력 9/10"을 adopter 0명·archived works 0·반복 upgrade flow 0 상태에서 부여. 검증 안 된 역량을 측정값으로 제시 — 이 회고의 단일 최대 과장. §결론 "강한 내부 운영 표준에 잘 맞는다"도 같은 evidence-ahead. | 점수를 unproven 표기와 함께 하향하거나 evidence를 명시. "강한 내부 표준화 **후보**"(미검증)와 "강한 내부 표준화 **기반**"(proven)을 분리. 문장 제안: "내부 조직 표준화 잠재력은 구조적으로 높으나 실제 다팀 운용 사례 0건으로 *미검증 잠재력*이다(점수 대신 Unproven 표기)." | Addressed (R1) |
| R0-2 | High | meta/value 비율 리스크 전면 누락. 커밋 635개 중 docs 240 + chore 168 = 408개가 하네스가 하네스를 governing하는 작업(feat 50 / fix 19). 시스템 차원에서 자기 §2 Simplicity를 위반하며 self-referential 최적화에 빠질 위험. §3.5는 이를 "아직 product에 안 써봤다"로만 약하게 다룸. | §3에 신규 weakness로 추가: "하네스가 자기 자신의 주 고객이 됐다 — 산출 에너지의 대부분이 자기 governance에 투입." §결론에도 한 줄 반영. | Addressed (R1) |
| R0-3 | High | §4.1 fleet mode를 "가장 중요한 다음 후보"로 두고 §4.2 First Product Walkthrough를 후순위에 둔 priority inversion. §3.5/§4.5에서 product delivery 미검증을 인정하면서 더 많은 upgrade 인프라 축조를 1순위로 둠 — 회고 자신의 경고와 모순. | §4.2를 §4.1보다 앞에 배치하고, §4.1을 "단 1개 real walkthrough 완료를 gate로 한 opt-in 탐색"으로 격하. 문장 제안: "fleet mode는 첫 실제 upgrade 경험 이전에는 설계하지 않는다 — 관측 0인 상태의 orchestration은 또 다른 진공 최적화다." | Addressed (R1) |
| R0-4 | Med | decimal 점수(8.5 / 6.5 등)가 존재하지 않는 측정을 암시하는 false precision. 가장 중요한 사실(real adopter 0)이 중간값 6.5 안에 묻혀 gating unknown으로 드러나지 않음. | 정량 점수를 질적 band(예: Strong / Adequate / Unproven)로 대체하거나 각 점수에 1줄 evidence 근거 부착. "Product delivery proof: none yet"을 표에 독립 행으로 노출. | Addressed (R1) |
| R0-5 | Med | reflexivity / single-author bus-factor 미기재. §2.4는 author/reviewer 분리를 검증된 강점으로 서술하나, author + 자기 AI는 독립 적대자가 아님. 다자 충돌은 설계 목적인데 G1/G2로 최근에야 발견됨 = 거버넌스가 본래 대상 부하로 stress-test된 적 없음. | §3에 weakness 추가: "리뷰 루프가 단일 maintainer + 그의 AI에 닫혀 있어 독립 검증 부재. 이 회고(Codex 작성 + Claude 검토)조차 동일 루프 산물이며 external validation이 아님." | Addressed (R1) |
| R0-6 | Med | manual-first↔automation 입장이 **명시 선언·방어되지 않음**(모순이 아니라 미선언). DR-036 무배선은 그 자체로 국소 방어 가능 — runner 개별 검사는 이미 `ci.yml`·`pre-commit` choke point에서 강제 중이라 집계 runner 별도 게이트는 중복이다. 따라서 "집행 머신리를 짓고 집행을 사양함"이라는 초안-리뷰 1차 프레이밍은 부정확했다. 진짜 결함은 deterministic check 6종·hook·runner tier를 두고도 "검증 저작=자동 / 집행=기존 choke point / 판단=수동"이라는 의도된 입장이 정체성에 한 문장으로 박혀 있지 않다는 점. §2.3/§2.5/§5.2가 무배선을 virtue로만 서술하고 이 입장 선언을 대신하지 못함. | §5.2(또는 §결론)에 입장을 1문장으로 명시: "이 하네스는 검증 *저작*은 자동화하고, *집행*은 기존 CI/pre-commit choke point에 한정하며, *판단*은 수동으로 둔다 — 무배선은 이 경계의 결과이지 자동화 회피가 아니다." (open tension 노출이 아니라 deliberate position 선언) | Addressed (R1) |
| R0-7 | Low-Med | 온보딩 weakness의 강도·구체성 부족. §3.1/§3.4가 정성적으로만 서술되어 체감이 약하고 6/10이 후함. | 구체 규모 삽입: docs ~42k줄 / md 287개 / 여러 메타 문서 / 비공식 용어 DSL. 점수 5/10 검토. 문장 제안: "처음 온 사용자는 운영 전에 작은 bespoke DSL(Work·DR·Tier·Layer·I0/T1/S1/P1/P2)과 287개 문서 표면을 마주한다." | Addressed (R1) |
| R0-8 | Low | §6/§결론의 "장난감이 아니다 / toy 수준 넘었다"는 타당하나, 같은 강도의 반대편 사실(self-customer·미검증)이 동급으로 병기되지 않아 톤이 한쪽으로 기욺. | §결론 종합 판단을 균형화: 성숙도 주장과 self-referential·unproven 리스크를 같은 무게로 병기. | Addressed (R1) |

### Claude Summary

**R0 판정: Changes Requested (approve-as-is 불가).** High 3건(R0-1 내부 표준화 9/10 과장 · R0-2 meta/value 비율 누락 · R0-3 fleet priority inversion) 미해소 상태로는 R1로 넘기지 않는다.

초안의 **약점 *서술*은 정직하고 구조가 좋다** — §3.1~3.5와 §4의 방향은 대체로 옳고, "공개 범용 제품성은 무겁다"는 결론의 *약점 측*은 evidence로 잘 받쳐진다(README 42k줄, DSL, onboarding 비용). 칭찬은 여기까지.

문제는 세 곳이다. ① **scorecard가 미검증 역량을 과대 청구**한다 — 특히 내부 표준화 9/10은 실제 운용 0건이라 회고가 스스로 경고하는 evidence-ahead의 표본이다. ② **단일 최대 구조 리스크(하네스가 자기 자신의 주 고객 = self-referential 최적화)가 통째로 빠졌고**, reflexive single-author 루프도 강점으로만 다뤄졌다. ③ **fleet mode를 1순위 후보로 둔 것이 회고 자신의 "진공 최적화 경고"와 모순**한다 — 첫 real walkthrough가 선행 gate여야 한다.

종합하면, 회고의 결론 *방향*("강한 내부 표준화 후보 / 무거운 공개 제품성")은 유지 가능하나, **"후보"를 "검증된 기반"처럼 들리게 하는 점수·문장을 걷어내고, self-customer·reflexivity·priority-ordering 세 리스크를 추가**해야 한다. 다음 핵심은 인프라(fleet)를 더 쌓는 것이 아니라 **단 하나의 실제 adopter walkthrough로 이 정교한 모델이 외부 현실에서 어디서 깨지는지 관측**하는 것 — 이 점은 §4.2에 이미 있으나 우선순위에서 §4.1에 밀려 있다. 그 역전만 바로잡으면 회고의 행동 함의가 정합해진다.

| R0 verdict | High 미해소 | 권고 |
| --- | --- | --- |
| Changes Requested | R0-1 / R0-2 / R0-3 | 위 3건 반영 후 R1 재검토. R0-4~R0-8은 같은 패스에서 함께 처리 권장 |

### Codex R0 Response

| Finding | 반영 내용 | 위치 |
| --- | --- | --- |
| R0-1 | 내부 조직 표준화를 "검증된 기반"이 아니라 "구조적으로 유망하지만 미검증인 후보"로 낮췄고, 실제 다팀 운용·live adopter 장기 운영·반복 upgrade flow가 없음을 결론에 명시했다. | §결론 |
| R0-2 | meta/value 비율 리스크를 결론과 weakness에 추가했다. 하네스 자체 governance 작업 비중이 높다는 점과, 그중 일부는 framework deliverable이라는 점을 함께 병기했다. | §결론, §3.6 |
| R0-3 | First Product Walkthrough를 §4.1로 올리고, fleet mode는 real walkthrough 1건 이후 opt-in 탐색으로 격하했다. | §4.1, §4.2 |
| R0-4 | decimal 점수를 제거하고 qualitative band로 교체했다. `Product delivery proof`를 별도 행으로 노출했다. | §결론 |
| R0-5 | cross-agent review 강점에 외부 검증 아님을 추가하고, single-maintainer + AI reflexive loop를 weakness로 추가했다. | §2.4, §3.7 |
| R0-6 | manual-first와 automation의 의도된 경계를 "검증 저작=자동 / 집행=CI·pre-commit choke point / 판단=수동"으로 명시했다. | §5.2 |
| R0-7 | onboarding weakness에 docs 약 42k줄, md 287개, bespoke DSL 부담을 추가했고 qualitative band를 `Weak`로 낮췄다. | §결론, §3.1 |
| R0-8 | 성숙도 주장과 self-referential·unproven 리스크를 결론에서 같은 무게로 병기했다. | §결론 |

### Claude R1 Re-Review

> R0 Changes Requested에 대한 Codex 대응을 재검토했다. §7 Claude 기록(Review Questions / Findings / Summary)은 변조되지 않았고, Codex는 본문만 개정 후 `Codex R0 Response` audit trail만 추가했다(§7 reviewer 기록 무결성 ✓).

| Finding | R1 Status | 판단 근거 |
| --- | --- | --- |
| R0-1 | Addressed | §결론에서 "검증된 source 운영 기반 vs 미검증 표준화 후보"를 명시 분리, scorecard Band=Unproven, 한 줄 요약까지 일관. 9/10 과장 제거됨 |
| R0-2 | Addressed | §결론 self-referential 위험 1줄 + §3.6 신설(408/635 수치 + framework deliverable nuance 병기). 결론·§3 양쪽 노출 충족 |
| R0-3 | Addressed | §4.1 First Product Walkthrough를 선행 gate로 승격, §4.2 fleet를 "walkthrough 1건 이후 opt-in 후속 후보"로 격하. "가장 중요한 다음 후보" 표현 철회 |
| R0-4 | Addressed | decimal 점수 전면 제거 → qualitative Band, `Product delivery proof = None yet` 독립 행 노출. (대응 중 표 separator 열 결함 발생 → R1에서 직접 수정) |
| R0-5 | Addressed | §2.4 제목·본문에 "외부 검증 아님" 추가 + §3.7 신설(single-maintainer reflexive loop, G1/G2 근거) |
| R0-6 | Addressed | §5.2에 "저작=자동 / 집행=CI·pre-commit choke point / 판단=수동" 입장 명시, 무배선=경계의 결과로 재정의. refine 방향 정확히 반영 |
| R0-7 | Addressed | §3.1에 docs ~42k줄·md 287개·bespoke DSL 구체화, scorecard onboarding Band=Weak |
| R0-8 | Addressed | §결론 반대편 리스크 단락 + 한 줄 요약에서 미검증을 동급 병기 |

**R1 verdict: Approved.** High 3건(R0-1/2/3) 포함 8건 전부 Addressed. R1에서 직접 수정한 항목: 결론 scorecard 표 separator 열 수 3→4(rendering 결함, Codex 대응 중 유입). 그 외 본문은 over-correction(과도하게 harsh) 없이 균형 유지 — "강한 source 운영 프레임워크 / 미검증 제품성" 결론 방향은 evidence와 정합.

남은 후속(회고 범위 밖, 별도 work): §9의 신규 후보 2건(First Product Walkthrough / Internal Managed Fleet Mode, Happy-path compression) backlog 등록 판단.

---

## 8. Revisit Triggers

이 회고는 다음 조건에서 다시 열어본다.

- v1.2.0 release 이후 첫 실제 target upgrade가 끝났을 때
- `ai-deck-compiler` actual upgrade walkthrough가 완료됐을 때
- internal managed fleet upgrade mode를 backlog/Work로 등록할 때
- 신규 contributor가 scaffold target을 처음 clone해서 작업했을 때
- product track이 실제 delivery milestone을 한 번 통과했을 때
- onboarding/happy path 문서를 줄였는데도 사용자 혼란이 반복될 때

---

## 9. 연결

관련 현재 후보:

- `ai-deck-compiler` actual upgrade walkthrough + DR-034 acceptance judgment
- First concrete product planning-pack exercise + import candidate review
- Internal managed fleet upgrade mode (신규 후보로 등록 검토)
- Happy path / onboarding compression (신규 후보로 등록 검토)

관련 문서:

- `docs/STATUS.md`
- `docs/backlog/HARNESS.md`
- `docs/decisions/DR-034-harness-upgrade-ownership-policy.md`
- `docs/maintainer/PRODUCT-STARTER-PLANNING-PACK.md`
- `docs/maintainer/VERIFICATION-COMMANDS.md`
- `docs/maintainer/HARNESS-TEST-TAXONOMY.md`

---

## 10. 최종 메모

이번 회고의 의도는 하네스를 칭찬하는 것이 아니다. 지금 수준을 있는 그대로 보고, 다음에 어디를 고쳐야 하는지 선명하게 남기는 것이다.

좋은 소식은 방향이 틀리지 않았다는 점이다.

더 중요한 소식은 다음 병목이 명확하다는 점이다.

> v1.2.0 이후의 핵심은 "하네스를 더 정확하게 설명하기"가 아니라, "하네스가 실제 여러 repo를 덜 힘들게 운영하게 만들기"다.
