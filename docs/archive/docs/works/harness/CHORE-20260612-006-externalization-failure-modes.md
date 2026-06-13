---
id: CHORE-20260612-006
priority: P1
status: Archived
risk: L2
scope: W3 진입 전에 "AI 맥락 외부화의 3대 실패모드"를 현재 source-of-truth에 다시 고정한다. 기본 가정은 `새 L3 결정을 채택`하는 것이 아니라, 이미 Accepted인 DR-021~025와 slice 0 합의를 현재 horizon 문서에 explanatory framing으로 복원하는 것이다. 따라서 우선 `docs/PLAN.md` framing을 검토하되, drafting 중 새 규범/정책 채택이 필요해지면 이 Work 안에서 DR를 직접 쓰지 않고 `DR 분리 제안 + 후속 Work/DR 등록`까지만 수행한다. canonical restructure, prompt diet, trigger family 재배열의 실제 적용 설계는 범위 밖이다.
appetite: 0.5d
planned_start: 2026-06-12
planned_end: 2026-06-12
actual_end: 2026-06-12
related_dr: [DR-021, DR-022, DR-023, DR-024, DR-025]
related_work: [CHORE-20260604-001, CHORE-20260605-001, CHORE-20260605-002]
---

# CHORE-20260612-006: 외부화 실패모드 통합 설계 원칙 명문화

## Top Summary

- **목표:** W3 구조 작업의 상위 판단축으로 `외부화 3대 실패모드 → 보완 매핑`을 현재 live source-of-truth에 명시한다.
- **왜 지금:** `Backlog row lifecycle SSoT` 같은 작은 hygiene가 닫혔고, 다음 후보들이 전부 W3 구조 작업이다. 큰 구조 변경에 들어가기 전에 어떤 실패를 먼저 방지해야 하는지 기준을 고정하는 게 순서상 맞다.
- **핵심 경계:** 이 Work는 방향 결정/정합성 명문화다. canonical 재배열, prompt 정리, trigger regrouping, repo-health slice 분리는 이번 Work에서 구현하지 않는다.
- **표면 기본값:** `PLAN framing`은 `새 결정 채택`이 아니라 `기존 결정의 설명적 복원`일 때만 사용한다. 구현 시점 판단으로 `§4 Current Milestone`보다 `§3 Core Surfaces` 하위 compact subsection이 더 자연스러우면 그 위치를 우선한다. 공통 원칙은 동일하다: `docs/PLAN.md`의 새 독립 원칙 장은 만들지 않고 compact framing만 추가한다. `docs/PLAN.md §7-a` 기준을 넘는 새 규범이 필요하면, 그 시점에서 DR 경로로 분리 제안한다.
- **역할 분리:** Codex는 author/driver, Claude는 red team reviewer다. review 결과는 `Cross-Agent Review And Discussion`에 누적한다.

## Why This First

| 후보 | 지금 먼저 필요한가? | 이유 | 판단 |
| --- | --- | --- | --- |
| 외부화 실패모드 통합 설계 원칙 명문화 | 높음 | 다음 W3 후보들의 판단 기준을 먼저 고정할 수 있다 | **착수** |
| Canonical 개념 계층화 + context-routing restructure | 중요하지만 넓음 | 기준 없이 들어가면 scope가 퍼질 가능성이 크다 | 다음 순서 |
| Archive 누적 관리 정책 | 지금은 낮음 | bounded harm 정의가 먼저고, W3 framing보다 급하지 않다 | 보류 |

**결론:** 구조를 바꾸기 전에 "무엇을 실패로 보고 무엇으로 닫을지"를 먼저 명시하는 편이 더 안전하다.

## Background / Facts

- backlog는 이 항목을 "`Phase 2 slice 0 방향 결정의 상위 프레임`"으로 정의한다.
- archived `CHORE-20260605-001`의 PQ-6 합의는 **umbrella/meta-DR 없이 `PLAN framing + 4 primary DR 정합성 기준`**을 권장한다.
- `docs/PLAN.md §7-a`는 "L3 결정 근거는 PLAN에 누적하지 않고 `docs/decisions/DR-*.md`로 분리"한다고 명시한다. 따라서 이 Work는 `새 결정 채택`과 `기존 합의 explanatory framing`을 구분해야 한다.
- `docs/PLAN.md`는 현재 AWH-004 상태와 Phase 2 종료를 요약하지만, 외부화 실패모드 자체를 현재 live framing으로 명시하지는 않는다.
- `docs/PLAN-SUMMARY.md`는 derived summary이며, `PLAN.md`에 실질 변경이 생기면 stale 여부를 같이 판정해야 한다.
- `docs/retrospectives/harness-identity-policy-first-20260608.md`는 canonical이 tool-agnostic해야 resilience가 유지된다고 정리한다. 이는 실패모드 ① 라우팅 누락/② 비대화와 직접 연결된다.
- `CHORE-20260611-010` R1 review는 "선언-실행 괴리"를 실제 결함으로 재확인했고, R1a에서 해소됐다. 실패모드 ③은 추상 원칙이 아니라 최근에도 재발했고 교정 가능성까지 실측된 패턴이다.

## Scope / Non-Goals

### Scope

- `외부화 3대 실패모드`를 현재 live 문서에 명시한다.
- 각 실패모드와 대응 보완을 1:1 또는 주된 매핑으로 정리한다.
- Phase 2 slice 0 / DR-021~025와 이 프레임의 관계를 추적 가능하게 만든다.
- `새 L3 결정 채택`이 아니라 `기존 합의 explanatory framing`으로 처리 가능한지 먼저 판정한다.
- explanatory framing으로 처리 가능하면 `PLAN.md`를 live surface로 사용하되, 새 독립 장이 아니라 `§3 Core Surfaces` 또는 `§4 Current Milestone` 하위 compact subsection으로 제한한다. 구현 기본값은 구조 rationale에 더 가까운 쪽을 택한다.
- 새 규범/정책 채택이 필요하다고 판정되면 이 Work 안에서 직접 DR를 작성하지 않고, `DR 분리 제안 + 후속 Work/DR 등록`까지만 수행한다.
- `PLAN.md`가 바뀌면 `PLAN-SUMMARY.md` stale 여부를 함께 판정한다.
- §5~§9 정합 확인 중 gap이 발견되면 이번 Work 안에서 즉시 restructure하지 않고, **보고 + 필요 시 backlog/Work 후보 등록**까지만 처리한다.

### Non-Goals

- `docs/HARNESS-PROTOCOL.md`, `skills/workflow/*.md`, adapter/rule/prompt의 실제 재배열.
- `Canonical 개념 계층화 + context-routing restructure` 구현.
- `Prompt surface diet + optional pack 재정의` 구현.
- 새 runtime enforcement나 test 추가.
- archived slice 0 Work 본문 수정.
- `STATUS.md` Active pointer 수정. R0 합의 전에는 건드리지 않는다.

## Candidate Files

| 파일 | 계획 |
| --- | --- |
| `docs/PLAN.md` | 주 변경 후보. 단, `새 결정 채택`이 아니라 `기존 DR/slice 0 합의의 explanatory framing`으로 처리 가능한 경우에만 수정. 수정 위치는 `§3 Core Surfaces` 또는 `§4 Current Milestone` 하위 compact subsection이며, 구현 시 더 자연스러운 쪽을 택한다 |
| `docs/PLAN-SUMMARY.md` | `PLAN.md` 실질 변경 시 stale 여부 판정. 필요 시 최소 동기화 |
| `docs/decisions/DR-*.md` | 직접 편집 기본값은 아님. explanatory framing을 넘는 새 규범이 필요하다고 판정될 때 DR 분리 제안 대상 |
| `docs/backlog/HARNESS.md` | closeout 시 candidate 제거 대상. 구현 중에는 참조만 |
| `docs/archive/docs/works/harness/CHORE-20260605-001-phase2-slice0-direction.md` | 근거 문서. 편집 대상 아님 |
| `docs/retrospectives/harness-identity-policy-first-20260608.md` | 근거 문서. 편집 대상 아님 |
| 이 Work 파일 | plan / review log SSoT |

## Plan

1. **R0 Plan Review 요청** — Claude가 방향 자체가 타당한지 red team으로 검토한다.
2. **Decision-vs-framing 판정** — `docs/PLAN.md §7-a` 기준으로 이것이 `새 L3 결정 채택`인지 `기존 합의 explanatory framing`인지 먼저 판정한다.
3. **Output surface 확정** — explanatory framing이면 `PLAN.md`의 기존 장 하위 compact subsection(구조 rationale이면 `§3`, 현재 horizon framing이면 `§4`), 새 규범 채택이 필요하면 `DR 분리 제안`으로 방향을 고정한다.
4. **Failure-mode matrix 초안** — 아래 3개 실패모드와 보완 매핑을 현재 문서 근거와 연결한다.
   - 라우팅 누락 → manifest / canonical / 명시적 routing
   - 비대화 → SSoT 단일화 / thin pointer / archive drain
   - 선언-실행 괴리 → test / hard-stop / validation gate
5. **문서 수정 또는 분리 제안** — 선택된 surface에 framing 문단/표를 추가하거나, 새 규범이 필요하면 DR/후속 Work 제안만 남긴다.
6. **§5~§9 trace check** — DR-021~025 또는 slice 0 결정과 이 framing이 서로 모순되지 않는지 확인한다. gap 발견 시 이번 Work에서 즉시 restructure하지 않고 보고/분리한다.
7. **PLAN-SUMMARY stale 판정** — `PLAN.md` 변경 시 갱신 필요 여부를 판단한다.
8. **R1 Result Review 요청** — Claude가 결과 surface와 과잉 일반화 여부를 검토한다.
9. **Closeout** — 승인 후 Work Done, backlog row 제거, STATUS proposal 여부 확인.

## Done Criteria

- [x] 외부화 3대 실패모드와 대응 보완이 current live source-of-truth에 문서화된다.
- [x] 이 원칙이 `slice 0 방향 결정의 상위 프레임`이라는 backlog 의도가 현재 문서에서 추적 가능해진다.
- [x] `새 L3 결정 채택`이 아니라 `기존 합의 framing`으로 처리했는지, 또는 DR 분리가 필요한지 판정 근거가 남는다.
- [x] umbrella/meta-DR를 새로 만들지 않을 경우 그 이유가 명시된다.
- [x] DR-021~025 또는 slice 0 결정과 충돌하지 않는다는 근거가 남는다.
- [x] §5~§9 정합 확인 중 gap이 발견되면 이번 Work 안에서 즉시 restructure하지 않고, 보고 또는 후속 항목 분리로 처리한다는 경계가 유지된다.
- [x] `PLAN.md` 변경 시 `PLAN-SUMMARY.md` stale 여부가 함께 판정된다.
- [x] Claude R0 / R1 review 결과가 Work 파일에 기록된다.
- [x] `docs/STATUS.md` Active pointer는 R0 합의 전 변경하지 않는다.

## Verification

- `rg -n "외부화|실패모드|thin|SSoT|단방향|manifest|hard-stop|validation" docs/PLAN.md docs/PLAN-SUMMARY.md`
- `rg -n "외부화 실패모드|PQ-6|umbrella|PLAN framing|4 primary DR" docs/archive/docs/works/harness/CHORE-20260605-001-phase2-slice0-direction.md docs/backlog/HARNESS.md`
- `rg -n "L3 결정 근거|docs/decisions/DR-\\*.md|Roadmap Lifecycle" docs/PLAN.md`
- `git diff --check`
- trace check:
  - failure mode ①, ②, ③ 각각이 어느 live 문구로 반영됐는지 표시
  - DR-021~025 또는 slice 0 합의와 모순 없음 확인
  - gap이 있으면 즉시 수정이 아니라 보고/후속 분리로 기록
- `PLAN-SUMMARY.md`는 변경이 없더라도 stale 판정 결과를 Work 파일 Discovery에 기록

## Risk / Reversal Cost

- **Risk:** framing work가 곧바로 W3 restructure 설계로 미끄러지면 scope가 커진다.
- **Risk:** umbrella DR를 만들지 않겠다는 기존 합의를 놓치면 중복 SSoT를 추가할 수 있다.
- **Risk:** `docs/PLAN.md §7-a`와 충돌하는 표면 선택을 하면 구현 도중 DR 경로로 갈아타야 한다.
- **Risk:** 실패모드 정의가 너무 추상적이면 후속 W3 작업에서 실제 판단 기준으로 못 쓴다.
- **Reversal Cost:** Low to Medium. 문서 결정이지만 W3 후속 항목들의 framing을 바꾸므로 잘못 쓰면 여러 backlog 후보의 방향을 다시 정리해야 한다.

## Open Questions

| ID | Question | Default Assumption |
| --- | --- | --- |
| OQ-1 | 이 원칙의 live surface는 `docs/PLAN.md`가 맞는가? | Yes — 단 explanatory framing으로 충분할 때만, 기존 장 하위 compact subsection (`§3` 또는 `§4`) |
| OQ-2 | `PLAN-SUMMARY.md`까지 즉시 갱신할 필요가 있는가? | `PLAN.md` 변경 후 stale 판정 |
| OQ-3 | 별도 umbrella/meta-DR가 필요한가? | No, current default는 PLAN framing. 단 새 규범 채택이 필요하면 DR 분리 제안 |
| OQ-4 | 이 Work에서 archived slice 0 Work를 수정해야 하는가? | No, 근거로만 사용 |
| OQ-5 | §5~§9 trace check에서 gap이 나오면 이 Work 안에서 바로 고치는가? | No, 보고 + 후속 분리 기본 |

## Sequencing Note

- 이 Work는 W3 후보 전체의 **hard blocker**는 아니다.
- 다만 `Canonical 개념 계층화 + context-routing restructure`처럼 범위가 큰 후보에는 좋은 선행 framing이다.
- 반대로 `skills/workflow/repo-health.md` slice 분리처럼 더 좁은 후보는 독립 진행도 가능하다. 이번 세션에서는 W3 첫 진입 후보로 우선 실행한다.

## Claude R0 Plan Review Request

Claude R0 plan review 요청: CHORE-20260612-006 외부화 실패모드 통합 설계 원칙 명문화

검토 포인트:

- 이 항목을 W3 첫 진입 작업으로 두는 판단이 타당한가?
- umbrella/meta-DR 없이 `PLAN framing`으로 두는 방향이 현재 합의와 맞는가?
- `docs/PLAN.md §7-a`와 충돌하지 않도록 explanatory framing vs 새 결정 채택을 구분한 plan이 충분한가?
- 이 Work 범위가 실제 restructure 구현으로 번지지 않도록 충분히 잘렸는가?
- `docs/PLAN.md`가 live surface로 적절한가, 아니면 다른 surface가 더 맞는가?
- 실패모드 ③ 선언-실행 괴리를 최근 실사례(`CHORE-20260611-010`)와 연결하는 방식이 과하지 않은가? 실사례라면 R1a 해소까지 함께 적는 framing이 맞는가?

## Cross-Agent Review And Discussion

### Round Log

| Round | Reviewer | Status | Summary | Follow-Up |
| --- | --- | --- | --- | --- |
| R0 | Claude | Conditional hold | `PLAN.md §7-a`와 표면 선택 충돌 가능성, gap 처리 경계 보강 필요 | plan 보강 후 재제출 |
| R0a | Claude | Approved | `§4`는 다소 이질적일 수 있으나 non-blocking, `§3 Core Surfaces` 대안 허용 | 구현 진행 |
| R1 | Claude | Approved | 마지막 문장은 후속 W3 review gate처럼 읽힐 수 있으나 non-blocking, 수정 불필요 | Done 진행 |

### R0 — Plan Review (Claude, 2026-06-12)

**Approval:** Conditional hold

**Finding**

- `PLAN.md §7-a`는 L3 결정 근거를 DR로 분리하라고 명시하므로, 이 Work가 `설계 원칙 채택`인지 `기존 결정 framing`인지 먼저 판정해야 한다.
- `PLAN.md`를 쓰더라도 기존 장 하위 compact framing으로 제한하고, 새 독립 원칙 장 신설은 피하는 편이 §7-a와 범위 통제 양쪽에 더 안전하다.
- §5~§9 정합 확인 중 gap 발견 시 이번 Work에서 바로 고칠지, 보고만 할지 경계가 없으면 W3 restructure로 번질 수 있다.
- "Phase 2 slice 0 상위 프레임"과 "W3 forward guidance"가 섞여 있어 산출물 위치를 분명히 해야 한다.
- `CHORE-20260611-010` 연결은 적절하나, failure pattern만이 아니라 R1a에서 해소된 결말까지 함께 적는 편이 framing상 안전하다.

**Must-fix**

1. `PLAN.md §7-a` 충돌을 직접 인정하고, 새 결정 vs explanatory framing을 먼저 판정하는 plan으로 바꾼다.
2. §5~§9 정합 확인에서 gap이 발견되면 이번 Work에서 즉시 restructure하지 않고 보고/후속 분리로 처리한다는 경계를 명시한다.

**Nice-to-have**

- 이 Work가 W3 전체의 hard blocker는 아니라는 sequencing note를 남긴다.
- `CHORE-20260611-010`은 "실사례 + R1a 해소"까지 같이 적어 failure pattern framing을 완결한다.

**Codex 반영 계획**

- `PLAN.md §7-a` 기준으로 `새 L3 결정 채택`과 `기존 합의 explanatory framing`을 구분하는 단계를 Plan에 추가한다.
- explanatory framing 경로를 택할 경우 `docs/PLAN.md` 기존 장 하위 compact subsection을 기본 착지 위치로 명시하고, 구현 시 더 자연스러운 `§3`/`§4`를 선택한다.
- explanatory framing을 넘는 새 규범이 필요하면 DR를 직접 쓰지 않고 `DR 분리 제안`까지만 이 Work 범위로 제한한다.
- §5~§9 trace check의 gap 처리 기본값을 `보고 + 후속 분리`로 고정한다.

### R0a — Re-Review Approval (Claude, 2026-06-12)

**Approval:** Approved

**Observation (non-blocking)**

- `§4 Current Milestone`는 "지금 무엇을 하고 있는가" 맥락이고, 3대 실패모드 framing은 `AWH-003` 결정들의 추상화에 더 가깝다.
- 구현 중 `현재 마일스톤 설명`보다 `아키텍처 설계 맥락`으로 느껴지면 `§3 Core Surfaces` 하위 compact subsection이 더 자연스러울 수 있다.
- 이 관찰은 구현자 판단 사항이며, Work 진행을 막지 않는다.

### R1 — Result Review Approval (Claude, 2026-06-12)

**Approval:** Approved

**Observation (non-blocking)**

- subsection 마지막 문장이 W3 후속 작업에 framing 요건을 부과하는 쪽으로 읽힐 수 있다.
- "해야 한다"가 실제 gate를 의미하는지 모호하면, 후속 Work 저자가 형식적 실패모드 언급을 추가하는 식으로 흐를 가능성은 있다.
- 현재 운용상 risk는 낮고, 이 Work를 막을 정도의 문제는 아니다. 추후 W3 review에서 이 문장을 근거로 과잉 반려가 생기면 그때 기준 과함으로 재판정하면 된다.

## Discovery

- 2026-06-12: branch isolation check 결과 `develop` + `policy_type: source-gitflow`였으므로 `feature/chore-20260612-006-externalization-failure-modes` branch에서 계획 작성.
- 2026-06-12: backlog candidate와 archived `CHORE-20260605-001` PQ-6를 대조한 결과, 기본 방향은 umbrella DR가 아니라 `PLAN framing + primary DR 정합성 기준`이다.
- 2026-06-12: `docs/PLAN.md`에는 AWH-004와 Phase 2 종료 요약은 있으나 외부화 실패모드 framing 자체는 아직 live 문구로 명시돼 있지 않다.
- 2026-06-12: `docs/PLAN.md §7-a` 확인 결과, 이 Work는 `새 결정 채택`과 `기존 결정 explanatory framing`을 구분하지 않으면 PLAN surface 선택이 충돌한다. 구현 전 판정 단계를 추가한다.
- 2026-06-12: Claude R0a non-blocking observation 반영. 실제 삽입 위치는 `§4 Current Milestone`보다 `§3 Core Surfaces` 하위 compact subsection이 더 자연스럽다고 판단했다. 이 framing은 "지금의 milestone 설명"보다 "현재 구조가 무엇을 막도록 설계되었는가"에 더 가깝다.
- 2026-06-12: `docs/PLAN.md`에 `3-a. Externalization Failure Modes Framing` compact subsection을 추가했다. 새 독립 원칙 장이나 umbrella DR는 만들지 않고, 기존 `AWH-003`/`§7-a`를 현재 구조 관점에서 다시 읽는 explanatory framing으로 제한했다.
- 2026-06-12: `docs/PLAN-SUMMARY.md`는 **변경하지 않음**으로 판정했다. 이 파일은 세션 context용 derived summary이며, 이번 framing은 독립 결정/이력 추가가 아니라 `PLAN.md`의 구조 rationale 보강이므로 summary까지 복제하면 오히려 derived surface가 과밀해진다.
- 2026-06-12: Claude R1 result review 승인. 마지막 문장의 future-review gate처럼 읽힐 수 있는 여지는 non-blocking observation으로만 남기고 문구는 유지했다. 현재 Work 범위에서는 추가 수정 없이 닫는다.
- 2026-06-12: 사용자 승인으로 archive 처리. Work Done 상태를 추가로 유지할 이유가 없고, 후속 W3 후보들과 분리된 completed framing work로 판단해 `docs/archive/docs/works/harness/`로 이동한다.
