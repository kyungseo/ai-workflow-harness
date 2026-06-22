# DR-041: Pack Docs 경로 가정 부분 Supersede

Date: 2026-06-20
Status: Accepted
Track: harness
Linked DRs: DR-021

## Question

D-21 document-set design original §6.4가 pack 조건부 문서를 `docs/packs/*`에 둔다고 가정했지만, `spring-modular-template` code product evidence는 supported runnable pack 문서를 `pack/{name}/README.md`에 두었다. Source template의 pack 문서 표준 위치는 어디여야 하는가?

## Decision

Supported runnable pack의 canonical local documentation은 `pack/{name}/README.md`에 둔다.

`docs/packs/*`는 기본 pack 문서 위치로 lock하지 않는다. pack index, adopter-facing aggregate guide, 또는 여러 pack을 한 번에 탐색해야 하는 별도 수요가 실제 adopter evidence로 확인될 때만 생성한다.

`docs/TEMPLATE-ACCEPTANCE.md`는 pack README를 evidence pointer로 참조한다. pack별 실행·교체·제거 상세와 substrate/합성 조건은 해당 `pack/{name}/README.md`가 소유한다.

이 DR은 D-21 core decision 전체를 supersede하지 않는다. Design original §6.4의 "pack 조건부 문서 = `docs/packs/*`" 경로 가정만 부분 supersede한다.

## Evidence Scope

이 결정은 **code-product-informed**다.

근거는 `spring-modular-template`의 agent-mediated code product 적용 결과다. Manual external adopter 또는 no-code scaffold target 검증은 아직 없다. 첫 non-code/manual adopter에서 pack docs 위치와 ownership 기준을 재검토한다.

## Options Considered

| Option | 장점 | 단점 | 판단 |
| --- | --- | --- | --- |
| `pack/{name}/README.md`를 canonical local documentation으로 둠 | pack artifact와 사용법·acceptance evidence가 같은 위치에 있어 제거/교체 경계가 명확함. Product evidence와 일치 | adopter-facing 전체 pack catalog가 필요하면 별도 index가 필요 | **채택** |
| `docs/packs/*`를 canonical 위치로 유지 | 문서가 docs tree에 모여 있어 탐색이 단순함 | pack 제거 시 문서 drift가 생기기 쉽고, product evidence 없음. pack-local substrate/합성 조건과 멀어짐 | 비채택 |
| 둘 다 필수로 유지 | local README와 aggregate guide를 모두 제공 가능 | 중복·drift 비용. 아직 adopter 수요가 확인되지 않음 | 비채택 |

## Rationale

Pack은 code/config/orchestration과 acceptance evidence가 함께 움직이는 단위다. `spring-modular-template`의 `local-deploy`와 `observability-export`는 모두 `pack/{name}/README.md`에서 run/reset/observe/remove 경계와 non-goal을 설명했다. 특히 `observability-export`는 `local-deploy` substrate 위에 합성되는 pack이므로, pack 옆 README가 실제 실행 조건과 가장 가까운 SSoT가 된다.

반대로 `docs/packs/*`는 design original에는 있었지만 product evidence가 없다. 이를 지금 source standard로 lock하면 evidence 없는 aggregate doc을 제도화하고, pack-local README와 중복될 가능성이 크다.

따라서 source template은 pack-local README를 기본 문서 위치로 삼고, `docs/TEMPLATE-ACCEPTANCE.md`는 pack README를 가리키는 thin acceptance map으로 둔다.

## Consequences

- Supported runnable pack을 추가할 때 기본 문서 위치는 `pack/{name}/README.md`다.
- `docs/packs/*`는 생성하지 않는 것이 기본이다. 3개 이상 pack을 한 화면에서 안내해야 하거나 adopter-facing aggregate guide 수요가 확인되면 별도 candidate/DR로 검토한다.
- `docs/TEMPLATE-ACCEPTANCE.md`는 pack 상세를 복제하지 않고, acceptance row와 evidence pointer만 유지한다.
- D-21 document-set 설명을 업데이트할 때는 "pack 조건부 문서 = `docs/packs/*`"로 단정하지 않고, pack-local README 기본 + aggregate guide deferred로 표현한다.

## Reversal Cost

Medium — pack 문서 위치를 다시 `docs/packs/*`로 돌리면 pack template, acceptance pointer, adopter guide, scaffold seed 문서 위치를 함께 재정렬해야 한다.

## Linked Work

- CHORE-20260620-002
