# DR-029: DR Registration Triage + Draft DR Lifecycle Completion

Date: 2026-06-09
Status: Accepted
Track: harness
Linked DRs: DR-007, DR-011

## Question

DR 등록 시 결정 성숙도를 어떻게 분기하고, Draft DR의 생성·승격·폐기·누적 관리를 어떻게 완성할 것인가?

## Decision

Draft 상태 자체의 정의(`record-decision.md §DR Lifecycle`, `DECISION-TEMPLATE.md`), Draft의 PLAN cascade 보류(`record-decision.md`), cascade 감사 Accepted-only(`HARNESS-PROTOCOL §390`), parent-child/linked, DR-worthy 기준(`record-decision.md §DR-Worthy Criteria`)은 **기존 정의를 그대로 참조**한다. 본 DR은 아래 공백만 채운다.

**1. 3-way 등록 triage.** `/record-decision`은 입력을 다음으로 분기한다. DR-worthy 판정은 기존 §DR-Worthy Criteria를 재사용한다(재서술하지 않는다).

- DR-worthy + 결정 완료 → **Accepted DR**
- DR-worthy + 선택 보류(signal/data/논의 대기) → **Draft DR**
- DR-worthy 아님 → OQ 또는 backlog (아래 routing table)

**2. Question Routing Table.** triage가 "DR이 아닌 질문"을 보낼 곳을 명확히 한다.

| 입력 성격 | 목적지 |
| --- | --- |
| DR-worthy + 결정 완료 | Accepted DR |
| DR-worthy + 선택 보류 | Draft DR |
| non-DR-worthy + 운영·근시일·blocking | STATUS `Blockers And Open Questions` |
| non-DR-worthy + 전략·roadmap horizon | PLAN `§9 Open Questions` |
| non-DR-worthy + 실행 후보 작업 | backlog (`PRODUCT.md` / `HARNESS.md`) |

Open Question은 두 층위에 존재한다: 전략/roadmap = PLAN §9, 운영/라이브 = STATUS. Blocker는 운영 전용 개념이므로 STATUS에만 두고 PLAN에는 두지 않는다(의도된 비대칭).

**3. Draft DR 필수 섹션.** Draft는 `Question`, `Options Considered`, `Open Points`, `Promotion Conditions`를 채운다. `Decision` / `Rationale` / `Consequences`는 승격 시 작성한다(기존 `DECISION-TEMPLATE.md`의 "Draft에서 빈 칸" 확장).

**4. 승격 프로세스 (Draft → Accepted).**

1. `Promotion Conditions` 충족 확인, `Open Points` 해소
2. `Decision` / `Rationale` / `Consequences` 작성, Status를 `Accepted`로 변경
3. Recent Decisions 등재 판정 발동(기존 `record-decision.md` step 5)
4. Draft 동안 보류됐던 PLAN cascade 발동(기존 `record-decision.md`)
5. 필요 시 관련 DR amend 연결(예: 본 정책 라인의 DR-030 승격 시 DR-007 amend)

**5. EXIT — `Draft (Dropped)`.** 결정하지 않기로 한 Draft는 폐기 사유 1줄을 본문에 남기고 `Status: Draft (Dropped)`로 표기 후 `docs/archive/docs/decisions/`로 이동한다. 번호는 retire한다(재사용 금지, 시퀀스 gap 허용). 기존 `Superseded`(다른 DR로 대체)와 구분된다.

**6. 누적 관리 (hygiene).** `/repo-health`는 Draft DR 목록과 age를 **soft surfacing**한다(나열 + promote/supersede/drop? 안내). hard gate(만료 강제) 아님. 이는 cascade 감사(Accepted-only)와 **별개 기능**이며 Draft 내용은 감사·강제 대상이 아니다.

## Options Considered

| 선택지 | 장점 | 단점 |
|--------|------|------|
| A. 수동 판단만(surfacing 0) | 무비용 | Draft 누적·망각 → drift (Done Work 미archive, Next Actions 잔류와 동일 패턴) |
| B. hard gate(N일 만료 강제 resolution) | 강제 정리 | Draft 본질(외부 signal 대기) 위배, 과설계 |
| **C. triage + soft surfacing + 명시 EXIT/promotion (채택)** | 등록 시점 분기로 "미결 질문의 Accepted DR 위장" 차단, harness soft-warning 패턴과 정합, 기존 인프라 참조로 경량 | 등록 시 1단계 추가 |

## Rationale

기존에 Draft 상태·PLAN cascade 보류·Accepted-only 감사는 이미 존재했으나, (1) 등록 시 결정/보류/비-DR을 가르는 triage, (2) Draft→Accepted 승격 절차, (3) 폐기(Dropped) 종료 상태, (4) 누적 가시성, (5) Draft 전용 섹션이 비어 있었다. 등록 시점 triage가 미결 질문이 Accepted DR로 위장돼 cascade·Recent Decisions를 오염시키는 실패 모드를 차단한다. 누적 관리는 강제(hard gate)가 아니라 soft surfacing으로 두어, 외부 signal 대기 중인 Draft의 본질과 충돌하지 않게 한다.

## Consequences

- `skills/workflow/record-decision.md`: §Procedure에 triage + 승격 sub-절차, §DR Lifecycle에 `Draft (Dropped)` 행 추가.
- `docs/decisions/DECISION-TEMPLATE.md`: `Open Points` / `Promotion Conditions` 섹션 추가(Draft용).
- `skills/workflow/repo-health.md`: Draft hygiene surfacing 1항목(Accepted-only 감사와 분리).
- `docs/decisions/README.md`: Status legend에 `Draft (Dropped)` 추가.
- adapter(`.claude/commands/record-decision.md`, `.agents/skills/workflow-record-decision/SKILL.md`, `.cursor/rules/workflow.mdc`)는 포인터만 유지(상세는 canonical).
- record-decision/repo-health/template는 scaffold로 adopter repo에 전파된다.
- PLAN §9 Open Questions / STATUS Blockers And Open Questions 구조는 변경하지 않는다(현행이 routing table 목적지로 유효).

## Reversal Cost

Low — 문서와 canonical 절차 변경. revert 가능.

## Linked Backlog Items

- CHORE-20260609-002
