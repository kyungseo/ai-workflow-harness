# DR-032: Phase Model De-formalization — Descriptive Optional Label

Date: 2026-06-10
Status: Accepted
Track: harness
Linked DRs: DR-015, DR-022, DR-031, DR-014

## Question

`Current Milestone Criteria`(= `Phase completion criteria`) STATUS 필드가 2026-05-25 제거됐다. 그런데 canonical 문서·tool surface는 여전히 그 필드를 STATUS-update 게이트 대상으로 참조하고, T3 트리거는 "Phase 완료"를 전제로 archive를 건다. 완료 판정 기준이 사라진 채 기계장치만 남아 dangling 상태다. harness "Phase"를 어떻게 정의하고 전환을 어떻게 처리할 것인가? (backlog HRN-030)

## Decision

harness "Phase"를 **descriptive + optional 라벨**로 de-formalize한다. 완료 criteria 게이트를 두지 않고, 전환을 **기록 행위**로 처리한다.

**1. Phase = descriptive optional 라벨.** `Current phase`(STATUS Current State)는 macro lifecycle/milestone을 가리키는 서술 라벨이다. 완료 criteria 체크리스트가 전진을 게이트하지 않는다. 단계를 운영하지 않는 프로젝트는 focus/목표 라벨로 쓰거나 최소값으로 둔다.

**2. 전환 = 기록.** phase/milestone 전환은 **결정**이며 STATUS `Recent Decisions`에 기록한다(roadmap이 함께 움직이면 `docs/PLAN.md` Roadmap Lifecycle). 게이트형 criteria 체크가 아니다.

**3. Work Done = 진실 단위.** Work는 phase 경계에 정렬할 의무가 없다. phase는 Work 경계와 독립적으로 결정에 따라 전진한다. Work가 phase 경계를 가로질러도 정상이며, 별도 보정 절차를 두지 않는다.

**4. T3 재정의.** "Phase 완료 또는 새 Phase 시작" → **"phase/milestone 전환 선언 시"**: Recent Decisions 기록 + (해당 시) archive drain + T5(PLAN 영향) 확인. completion-criteria 게이트 제거.

**5. dangling 참조 정정.** `Phase completion criteria`/`Phase criteria`/`Current Milestone Criteria`를 STATUS-update 게이트 대상에서 제거한다. STATUS-field 게이트 대상은 `Current phase/focus`, `Recent Decisions`로 한정한다(`Current phase/focus` 변경은 방향 변경이므로 `STATUS Update Proposal` 유지).

**6. 4-용어 disambiguation (혼선 차단).**

| 용어 | 의미 | 위치 | 성격 |
| --- | --- | --- | --- |
| `Current phase` (STATUS field) | macro lifecycle/milestone 라벨 | STATUS Current State | descriptive, optional, de-formalized |
| Product phasing (`PRODUCT-P{n}`) | adopter 제품 로드맵 단계 | backlog/works/product | optional (DR-031) |
| 절차 "Phase 1-6" | 명령 실행 step 라벨 | work-doc/repo-health | 무관, 보존 |
| state-machine phase | INIT/PLAN/EXECUTE… | 상태머신 | 무관, 보존 |

**7. Optional/extensible 보장.** 모델은 phaseless·phased 양쪽에서 동작한다. 단계를 운영하면 `Current phase`에 라벨(예: "Phase 2")을 두고 product track은 `PRODUCT-P{n}`(DR-031)로 연결한다. 단계를 운영하지 않으면 descriptive 라벨로 충분하다. scaffold 기본 출력은 phaseless-default(DR-031 정합)로 단계를 강제하지 않는다.

## Options Considered

| 선택지 | 장점 | 단점 |
|--------|------|------|
| **A. descriptive label로 de-formalize (채택)** | dangling 해소, DR-031 optional 철학과 정렬, Work Done 단위 명확, phaseless·phased 모두 수용 | 광범위 참조 cascade 정정 필요 |
| B. 명시적 phase + 경량 criteria 복원 | 전환 형식화 | 2026-05-25 제거 결정 부분 되돌림, 게이트 마찰 재유입 |
| C. 하이브리드(특정 milestone만 게이트) | 절충 | 분기 규칙 복잡, 판정 모호 |

## Rationale

`Current Milestone Criteria` 제거(2026-05-25)와 DR-031의 product phasing optional화는 모두 phase 형식주의를 줄이는 방향이었다. 그런데 기계장치(criteria 게이트 참조, T3 전제)가 남아 "선언-실행 괴리"를 만들었다. de-formalize는 이 괴리를 제거하고 모델을 단순화한다. Work Done을 진실 단위로 삼으면 "Work Done과 phase 경계 불일치"라는 HRN-030의 난제가 소멸한다 — 경계 불일치가 더 이상 처리 대상이 아니라 정상 상태가 되기 때문이다. 개념 변경은 작지만 dangling 참조 표면이 넓어 cascade 정정이 핵심 작업이다.

## Consequences

- canonical(`HARNESS-PROTOCOL`/`AGENT-WORKFLOW`/`HARNESS-QUICK-REFERENCE`)·tool surface(`skills/workflow/*`)에서 `Phase (completion )?criteria` STATUS-field 참조 제거.
- T3 트리거 재정의(criteria 게이트 → 전환 기록).
- `WORKFLOW-MANUAL` phase 표현을 descriptive로 정리(`/repo-health` 사용 시점 문구는 유지 — 전환은 여전히 이벤트).
- DR-031 §5의 보존-필드 목록에서 `Phase completion criteria` 제거(해당 필드 부재 정정). DR-015 §Layer2 "Phase 완료 기준 체크" 행은 폐지 표시(strikethrough + DR-032 pointer)로 audit trail 보존.
- scaffold(`create-harness.sh`) 생성 STATUS의 `Phase 1` 강제 제거 → `Current phase` phaseless-default, PLAN phasing optional화.
- routing(`docs/works/{category}/{ID}-{topic}.md`)을 "큰 작업의 SSoT(실행 계획 + 세부 분해)"로 framing 통일. "work 쪼개기"는 §10 Decomposition 기준으로 신규 Work ID 분리이며 phase와 무관.
- `Current phase` 라벨 자체, 절차 "Phase 1-6", state-machine phase, harness "Phase 2" refactor 이력은 불변.

## Reversal Cost

Medium — 개념은 단순하나 참조 표면이 넓다. revert 시 DR-032 폐기 + 제거된 참조 재기입 필요. branch 단위 revert는 단순.

## Linked Backlog Items

- HRN-030 (CHORE-20260610-003로 착수)
