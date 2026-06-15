# DR-030: Language / i18n Strategy for Native and English Users

Date: 2026-06-09
Status: Draft
Track: harness
Linked DRs: DR-007, DR-021, DR-029

<!-- 이 DR은 DR-029의 3-way triage에서 "DR-worthy + 선택 보류"로 분기된 첫 Draft DR이다. Decision/Rationale/Consequences는 승격 시 작성한다. -->

## Question

모국어(한국어) 사용자와 영어권 사용자 모두에게 효율적인 언어 규정을 어떻게 가져갈 것인가? DR-007은 *source repo의 파일 유형별 언어*(Korean primary + 영어 전용 entry/rule)를 정의하지만, *adopter-facing / scaffold 출력 언어(i18n)* 층위는 다루지 않는다. 이 층위의 정책을 어떻게 정할 것인가?

## Scope Boundary Update (2026-06-15)

DR-007이 2026-06-15 amend로 **현재 효력을 가진 운영 언어 규칙의 단일 SSoT**가 되었다: 파일 유형 + commit message/PR body/agent 출력(behavioral) + "default 한국어 주체 / 단일 override 지점" 선언을 모두 흡수했다(CHORE-20260615-002). 따라서 본 DR의 범위는 **미결 전략 결정만** 남는다 — 1차 청중(primary audience), 양방향 i18n 수요 signal, scaffold 언어 출력 메커니즘(`--lang` 등). 운영 규칙 재서술·override 선언은 DR-007 소관이며 본 DR에서 다루지 않는다. (Open Point "DR-007 amend 범위"는 본 update로 해소 — adopter override 선언까지가 amend 범위였다.)

## Options Considered

| 선택지 | 장점 | 단점 |
|--------|------|------|
| ① 현행 유지 (DR-007 그대로) | 무비용, 저자 정밀도·velocity 유지 | scaffold가 adopter repo에 모국어 artifact 주입 — 영어권 adopter에겐 거부 트리거 |
| ② source-facing 정리 (DR-007 rule scope 명확화 포함, HARNESS.md P2(1) 흡수) | 적은 비용으로 평가 장벽 일부 완화 (예: `.claude/rules/*` 영어 전용 경계 명확화, user-facing 문서 영어 lead) | 주입 언어 문제 자체는 미해결 |
| ③ scaffold `--lang en` (en-only artifact 옵션) | 주입 artifact를 adopter 언어로 출력 → 양방향 오염 구조적 해소, source repo는 모국어 유지 | artifact 영어판 유지보수, 부분적 drift 표면 |
| ④ per-adopter full i18n (en/ko 2벌 전면) | 양방향 완전 해소 | 유지보수 2배 + drift 표면 2배, 양쪽 수요 증명 전엔 과설계 |

**비대칭 비용 (참고):** 한국 개발 생태계는 영어가 이미 default(코드·라이브러리·에러·툴)라 *한국어 사용자의 영어 관용도*가 *영어권 사용자의 한국어 관용도*보다 훨씬 높다. 따라서 주입 기본 언어 선택은 대칭 맞교환이 아니라 비대칭 거래다.

## Open Points

> 아래는 **여전히 미결인 전략 항목만** 남긴다. (2026-06-15 정리: "DR-007 amend 범위"와 "HARNESS.md P2(1)"은 위 Scope Boundary Update로 종결 — amend는 운영 규칙 + adopter override 선언까지였고, P2(1)은 이미 backlog에서 제거됨.)

- 1차 청중(primary audience)을 누구로 둘 것인가? (전략 결정, 미결)
- 양방향 i18n 수요의 실제 signal이 존재하는가? (현재 미확인 — 선제적 가설인지 확인 필요)
- ③ `--lang` 옵션 등 mirror 자동 동기화/생성 메커니즘을 택할 경우 artifact 유지 비용을 어디까지 감내할 것인가?

## Promotion Conditions

- 1차 청중과 수요 signal에 대한 판단이 내려지고, 옵션 ①~④ 중 택1(또는 조합)이 확정될 때 Accepted로 승격한다.
- 승격 시 작성: `Decision`(택한 옵션), `Rationale`, `Consequences`(선택 시 scaffold `--lang`/mirror 동기화 메커니즘 구현 backlog 등록). DR-007 amend 범위·P2(1)은 본 Draft 단계에서 이미 종결(위 Scope Boundary Update).

## Decision

(Draft — 승격 시 작성)

## Rationale

(Draft — 승격 시 작성)

## Consequences

(Draft — 승격 시 작성)

## Reversal Cost

Medium — 언어 정책은 파일 전수에 영향(DR-007 reversal cost와 동일선). 단 본 DR은 Draft이므로 채택 전 후속 행동을 강제하지 않는다.

## Linked Backlog Items

- CHORE-20260609-002
- HARNESS.md P2(1) "DR-007 rule scope 명확화" (본 DR로 흡수)
