---
date: 2026-06-17
track: harness
type: position
scope: harness source repo posture와 adopter 진입 표면 — public 유지 vs private 회수, 단일 distribution vs 변형 N개
author: "agent:claude-opus-4-8 | human"
related_work: []
---

# Harness 배포 포지셔닝 — source posture와 adopter 진입 표면

## 1. 결론

**source repo는 public으로 유지하고, adopter용 클린 진입 표면(scaffold 출력 기반)을 별도 1개만 추가한다. source를 private으로 돌리거나 option-pack 변형별 public repo를 N개 만드는 방향은 권하지 않는다.**

- 동인은 *adopter UX 정리*와 *전략/포지셔닝 재설계*이며, secret/privacy 노출이나 history 부담이 아니다. 따라서 source를 회수할 근거가 없다.
- 두 동인은 **repo 구조를 바꾸지 않고** 해소된다: UX는 distribution 표면 1개로, 포지셔닝은 두 표면의 **역할 분리 서술**로 해결된다.
- 권고 = 옵션 (B). 변형 N개(옵션 C 일부)는 실제 수요 신호가 생긴 뒤에만 분기한다.

## 2. 질문 / 배경

처음 검토했던 방향은 "source repo는 private 유지, scaffold 결과를 general·option-pack 버전별 public repo로 공개"였다. 동기는 "복잡한 이력을 굳이 공개하지 말자"였다.

그러나 두 가지 관측이 이 전제를 약화시킨다.

1. **이미 public이고 릴리즈됐다.** `github.com/kyungseo/ai-workflow-harness` visibility=PUBLIC, tag `ai-workflow-v1.1.0/v1.2.0/v1.2.1` 배포 완료. 즉 "지금 조정"은 "공개 전 설계"가 아니라 "공개된 것의 회수"다. fork/clone/archive가 존재할 수 있어 private 전환으로 이력이 회수되지 않으며, privacy 이득은 대부분 이미 소진됐다.
2. **진짜 동인은 privacy가 아니다.** 확인 결과 동인은 *adopter UX 정리* + *전략/포지셔닝 재설계*였다. secret 노출도, messy-history 부담도 아니다. privacy를 위해 구조를 바꾸는 선택지(private 회수)는 동인과 정렬되지 않는다.

따라서 질문은 "어떻게 회수하나"가 아니라 **"public source를 유지하면서 adopter 진입 표면을 어떻게 깔끔하게 줄 것인가, 그리고 두 표면의 역할을 어떻게 포지셔닝할 것인가"**로 재정의된다.

## 3. 비교 · 분석

적용 층위를 분리해 본다: **source repo posture**(public/private) × **adopter 진입 표면**(직접 source / 단일 distribution / 변형 N개).

| 축 | (A) 현행 유지 | (B) source public + distribution 1개 ★권고 | (C) source private + 변형 N개 public |
| --- | --- | --- | --- |
| source posture | public (그대로) | public (그대로) | private 회수 |
| adopter 진입 | source repo 직접 탐색 / fork | scaffold 출력 distribution(template repo 1순위) | 변형별 public repo |
| adopter UX | 노이즈(CHORE/DR/retrospective) 노출 | **클린 진입점 확보** | 클린하나 분산 |
| 유지비(sync) | 0 (단일 표면) | 낮음 — distribution 1개만 주기 동기화 | **높음 — 변형 N개를 매 변경마다 재scaffold·재push** |
| auto-upgrade 전제 | 무관 | 무관 | **없음**(`--check`만 존재) → 수동 sync 세금이 N배 |
| 신뢰 신호(dogfooding) | 강함(자기 harness를 자기가 운영) | 강함 유지 + 클린 표면 병행 | **약화** — 이력 없는 출력은 보일러플레이트로 보임 |
| fork-adopter 경로 | 보존 | 보존 | **소멸**("Forked harness source" 모드가 private에서 불가) |
| reversal cost | — | Low(표면 추가, 가역) | **High** — 이미 public·release된 것 회수 + 아키텍처 전반의 "public source" 전제 정합성 정리 |

핵심 비대칭:
- **(C)의 비용은 영구적이고 구조적이다.** auto-upgrade가 없으므로 변형 N개는 harness가 바뀔 때마다 N번 재생성·재배포해야 하는 sync 세금이다. source 1개 → 유지 표면 N개로 비용 구조가 악화된다.
- **(B)의 비용은 일회성이고 가역적이다.** distribution 표면 1개 추가는 되돌리기 쉽고, GitHub *template repo* 기능을 쓰면 별도 sync repo보다 유지비가 더 낮다.
- **dogfooding은 자산이지 부채가 아니다.** OSS workflow framework에서 "자기 harness로 자기를 운영한 이력"은 작동 증거이자 신뢰 신호다. 이걸 숨기면 차별화 근거가 약해진다.

## 4. 리스크와 맹점

- **distribution 표면도 0은 아니다.** template repo든 별도 repo든 출력이 source와 drift할 위험은 있다. 단 1개이므로 N개 대비 관리 가능하고, "릴리즈 시점에만 재생성" 규율로 억제할 수 있다.
- **"public 유지" 결정이 history 위생 책임을 면제하지 않는다.** secret/private-info scan은 이미 릴리즈 게이트에 있다(별도 동인 아님으로 확인됨). 다만 향후 commit/문서 위생은 계속 source 측 책임으로 남는다.
- **권고가 "변형 N개 영구 거부"는 아니다.** 특정 option-pack에 대한 실수요(외부 adopter 요청, 반복되는 동일 scaffold 패턴)가 관측되면 그 변형만 distribution으로 승격한다. 지금 선제적으로 N개를 만드는 것이 과잉이라는 의미다.
- **이 brief는 탐색적이다.** "distribution을 별도 repo로 둘지 template repo 기능으로 둘지"의 메커니즘 결정은 아직 미확정이며, 실제 착수 시 비교가 필요하다.

## 5. Revisit Triggers

- 특정 option-pack scaffold가 외부 adopter에게 반복 요청되어 변형 표면 승격이 정당화될 때 → (C) 일부 재평가.
- scaffold auto-upgrade/migration 메커니즘이 도입되어 N개 sync 세금 가정이 무너질 때 → 변형 N개 비용 재산정. (관련: [[harness-distribution-plugin-model-20260608]] — 병목은 배포 방식이 아니라 upgrade/migration 로직이라는 기존 판단과 연결.)
- distribution 메커니즘(별도 repo vs template repo vs release artifact)을 확정해야 할 때 → 후속 비교 brief 또는 DR.
- source posture를 바꿔야 할 새로운 privacy/secret 동인이 실제로 식별될 때 → 이 brief 전제 재검토.

## 6. 연결

- 관련 기존 brief: [[harness-distribution-plugin-model-20260608]] (배포·업그레이드 방식 한계).
- Follow-up surface 후보(이 brief는 강제하지 않음):
  - 권고 (B)가 Accepted로 수렴하면 `/record-decision`으로 DR화(source posture = public 유지 + adopter distribution 표면 정책).
  - distribution 표면 도입은 `README.md` Adopter Modes 섹션과 scaffold 흐름에 영향 → backlog 항목 후보.
  - 현재는 탐색 단계이므로 brief + Revisit Triggers로 유지한다.
