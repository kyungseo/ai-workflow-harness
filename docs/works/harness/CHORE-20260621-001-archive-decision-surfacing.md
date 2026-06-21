---
id: CHORE-20260621-001
priority: P2
status: Done
risk: L2
scope: closeout/archive 시 deferred·non-goal·extraction-trigger 성격의 forward-relevant 결정을 live backlog candidate로 surfacing하는 최소 규약을 정의한다. auth-session 사례를 dry-run 기준으로 사용하며, pack 구현이나 resolver 설계로 넓히지 않는다.
appetite: 1d
planned_start: 2026-06-21
planned_end: 2026-06-21
actual_end: 2026-06-21
related_dr: [DR-013, DR-014]
related_troubleshooting: []
related_work: [CHORE-20260620-001]
---

# CHORE-20260621-001: Archive Decision Surfacing

## Top Summary

CHORE-20260620-001이 `spring-modular-template` evidence review를 하면서 하나의 acute gap을 드러냈다. archived Work 안에 이미 근거가 충분한 forward-relevant 결정이 있어도, live backlog로 자동 surfacing되지 않으면 다음 세션은 archive를 다시 파야 한다.

이 Work는 그 gap을 **process slice**로 닫는다. 범위는 `auth-session pack` 자체가 아니라, 그런 후보가 archive에 묻히지 않게 하는 closeout/archive 규약이다. 따라서 pack 구현, resolver metadata, product engineering option-pack 일반화는 비범위다.

산출물은 구현보다 먼저 **판정 가능한 규약**이다. 어떤 종류의 결정만 surfacing 대상인지, 어느 단계(`/work-close`, archive step, session-start 안내)에서 다룰지, backlog candidate로 남기는 최소 형태가 무엇인지 정한다.

## Collaboration Workflow

| Role | Agent | Responsibility |
| --- | --- | --- |
| A | Codex | author/driver. Work 파일, plan, 구현, Claude review response 작성 |
| B | Claude | red team reviewer. 내적 정합성을 넘어 이 slice의 존재 이유, 과잉 자동화 위험, 잘못된 일반화 가능성을 의심 |
| Owner | User | 방향 승인, 구현 승인, 최종 승인, `/work-close`, commit, PR, merge 승인 |

절차: 사용자 지시 → Codex A가 Work 파일+plan 작성 → Claude B가 red-team review(R round) → 합의 → Codex A 구현 → Claude B 결과 검토 → 사용자 최종 승인 → `/work-close` → commit → PR(`--base develop`) → merge.

Cross-agent 라운드와 합의는 아래 `Cross-Agent Review And Discussion`에 누적한다.

## Context Manifest

| 순서 | 파일 | 섹션 | 왜 |
| --- | --- | --- | --- |
| 1 | `docs/backlog/HARNESS.md` | `Archive decision surfacing` | 후보 정의, Done Criteria, verification 기준 |
| 2 | `docs/archive/docs/works/harness/CHORE-20260620-001-planning-pack-evidence-review.md` | Top Summary, Routing summary, Cross-Agent Review | auth-session 사례와 durable-routing 요구의 직접 근거 |
| 3 | `skills/workflow/work-close.md` | 전체 | closeout 단계에서 어떤 state change가 이미 정의돼 있는지 확인 |
| 4 | `docs/HARNESS-PROTOCOL.md` | Work File Rules, trigger T10/T14/T17, cascade | archive / work-close / tool-surface cascade 규칙 |
| 5 | `docs/decisions/DR-014-archive-policy.md` | 전체 | archive 구조/이동 정책 |
| 6 | `docs/decisions/DR-013-work-file-spec.md` | Status Lifecycle, Done/Archived 분리 | Work lifecycle 경계 확인 |
| 7 | `docs/retrospectives/harness-v1-2-readiness-retrospective-20260615.md` | W4, scope restraint, optional 후보 보류 | 과잉 자동화/과잉 일반화 방지 기준 |

Trigger: CHORE-20260620-001이 auth-session 사례를 근거로 live backlog에 `Archive decision surfacing` 후보를 등록했고, 사용자가 그 후보와 auth-session pack을 비교해 첫 착수 작업으로 선택했다.

## Scope

### Slice A — Trigger Surface Inventory

- 어떤 종류의 archived decision이 surfacing 대상인지 좁힌다.
- 기본 대상은 `extraction-trigger`, `deferred`, `non-goal` 중 **forward-relevant token이 명시된 결정**으로 좁힌다.
- `follow-up`은 기본 대상에서 제외한다. 다만 "다음 Work로 분리"가 명시된 경우에만 예외 후보로 검토한다.
- **모든 결정**을 backlog로 복제하는 자동화는 비범위다. "명시적 trigger가 붙은 결정만" 대상으로 삼는 경계를 우선 검토한다.

### Slice B — Insertion Point Decision

- surfacing 책임 위치를 **record**와 **surface**로 나눠 정한다.
  - record primary: `/work-close` Done 처리 직후 triage prompt
  - record fallback: optional archive step 직전/직후
  - surface fallback: 다음 `/session-start`에서 archive-pending Work 경고와 함께 안내
- push-side(record)와 pull-side(surface)를 모두 두되, 어느 쪽이 canonical primary인지 정한다.
- 기존 canonical 절차를 깨지 않고 넣을 수 있는 최소 편집점을 찾는다.

### Slice C — Minimum Tracking Payload

- surfacing 결과를 backlog에 어떻게 남길지 정한다.
- 최소 payload는 "후속 후보가 다시 archive를 파지 않아도 되는 검색 가능 상태"여야 한다.
- 단, backlog는 curated portfolio view이므로 **기계적 auto-row 생성**은 기본안에서 제외한다.
- 후보 payload는 `needs-triage` 성격의 prompt/annotation으로 먼저 제안하고, 정식 candidate 승격은 owner 승인 하에서만 수행하는 경로를 우선 검토한다.

### Slice D — auth-session Dry-Run

- `spring-modular-template` auth-session 사례를 가지고 규약을 역적용한다.
- 이 규약이 있었으면 사용자가 질문하기 전에 무엇이, 어디에, 어떤 문구로 surfacing됐어야 하는지 dry-run한다.
- dry-run에는 **deployment locus**를 함께 표기한다. 이 사례는 product repo closeout이므로, source harness canonical 수정이 즉시 지배하지 않는다는 한계를 output에 명시한다.
- false positive도 함께 본다. 어떤 종류의 non-goal은 승격하지 말아야 하는가?

### Slice E — Trigger Gate And Deployment Boundary

- 현재 evidence가 source harness 독립 반복 사례인지, adopter repo 1건인지 구분한다.
- 규약이 단일 사례 복구 뒤에 너무 빨리 굳지 않도록, stronger rule/automation은 **2nd occurrence gate**를 붙일지 판단한다.
- 이번 slice의 구현이 source harness self-governance만 다루는지, adopter repo rollout 전제가 필요한지를 명시한다.

## Scope Guard

- `auth-session pack` 자체 설계/구현은 비범위다.
- `Spring modular/product engineering option-pack 후보`의 principle/impl 일반화는 비범위다.
- planning-pack resolver, manifest schema, scaffold 구현은 비범위다.
- archive 전수 자동화 스크립트 추가는 기본 비범위다. 먼저 규약과 문서 절차를 정한다.
- `docs/STATUS.md`의 phase/focus/Recent Decisions 수정은 비범위다. 이번 단계에서는 Active Work 포인터만 다룬다.
- source harness 변경이 adopter repo의 이미-archive된 Work를 retroactively govern한다고 주장하지 않는다.

## Initial Direction (A 제안, B review 전 미확정)

| 항목 | 초기 입장 | B가 의심해볼 질문 |
| --- | --- | --- |
| 문제 정의 | pack 후보 부재가 아니라 archive-burial process gap | 정말 process 문제인가, 단일 사례 과대해석인가 |
| 대상 결정 범위 | `extraction-trigger` 우선, `deferred`/`non-goal`은 forward-relevant token이 있을 때만. `follow-up`은 기본 제외 | 너무 넓거나 너무 좁지 않은가 |
| 삽입 위치 | `/work-close`는 record primary, `/session-start`는 pull-side fallback 경고 | work-close에 넣으면 closeout이 과중해지지 않는가 |
| 산출물 형식 | backlog auto-row가 아니라 triage prompt/annotation 우선 | Work 내부 기록만으로 충분한가, 아니면 backlog 반영이 필수인가 |
| deployment boundary | 현재 evidence는 adopter repo 1건, source harness self-case는 아직 없음 | 단일 사례에 규약화가 성급하지 않은가 |
| DR 여부 | 아직 lightweight prompt/triage 수준이면 DR 보류 가능, stronger mechanism은 2nd occurrence 이후 재검토 | reversal cost가 Medium 이상이면 DR이 먼저 필요한가 |

## Risk

| Risk | Level | Mitigation |
| --- | --- | --- |
| 단일 auth-session 사례를 일반 규약으로 과대 일반화 | Medium | dry-run은 하되, "현재 evidence는 단일 code-product 사례"라는 한계를 명시 |
| closeout 절차가 과중해져 `/work-close` 사용성이 나빠짐 | Medium | 필수 자동화가 아니라 lightweight prompt/annotation 수준으로 제한 |
| 모든 non-goal을 backlog로 복제하는 false positive | Medium | explicit trigger label이 있는 결정만 대상으로 좁히는 기본안을 검토 |
| candidate surfacing과 pack/feature 일반화가 섞여 scope sprawl | Medium | pack 구현/option-pack 설계 비범위 고정 |
| source harness 수정이 adopter repo buried case를 즉시 해결하는 것처럼 과대 주장 | Medium | deployment locus를 dry-run/output에 명시하고 source-governance vs rollout을 분리 |
| curated backlog를 기계적 승격으로 오염 | Medium | `needs-triage` prompt/annotation 우선, owner 승인 전 정식 candidate 생성 금지 |
| canonical 편집이 adapter cascade 비용을 숨김 | Low | 구현 범위에 canonical + adapter cascade 점검을 명시 |

## Done Criteria

- [x] Claude B R1 red-team review가 기록된다.
- [x] R1 finding에 대한 Codex A response와 consensus가 기록된다.
- [x] surfacing 대상 결정의 최소 판정 기준이 정리된다.
- [x] 삽입 위치(`/work-close`, archive step, session-start 안내)의 primary/fallback 구성이 결정된다.
- [x] backlog에 남길 최소 tracking payload 형식이 정리된다(`needs-triage`/annotation vs 정식 candidate 경계 포함).
- [x] auth-session 사례 dry-run 결과가 기록된다.
- [x] false positive 경계(무엇은 surfacing하지 않을지)가 기록된다.
- [x] 구현 시 수정할 canonical/tool-surface/docs 범위가 확정된다(canonical + adapter cascade 포함).
- [x] Claude B result review와 Codex A response가 기록된다.
- [x] 사용자 최종 승인 후 `/work-close` 가능한 상태가 된다.

## Verification

- `auth-session` 사례 역적용 dry-run: "이 규약이 있었다면 무엇이 backlog에 남았어야 하는가" 확인
- `skills/workflow/work-close.md`와 `docs/HARNESS-PROTOCOL.md`의 trigger/cascade 정합 확인
- 문서 변경 후 `git diff --check`
- scope self-check: pack 구현/resolver/scaffold 변경이 새지 않았는지 확인

## Implementation Output

### Agreed Lightweight Rule

- **기본 triage 대상**: `extraction-trigger`, 또는 forward-relevant token이 명시된 `deferred`/`non-goal`
- **기본 제외**: 일반 `follow-up`, "그냥 안 하기로 한" 비목표, 근거 없는 막연한 후속 아이디어
- **강도**: hard-stop이나 auto-surfacing mechanism이 아니라 lightweight soft prompt

### Record vs Surface

- **record primary**: `/work-close`에서 Work `Discovery`에 `Needs-Triage:` 한 줄 메모 기록
- **record fallback**: archive step 직전/직후에 같은 메모 유지
- **surface fallback**: `/session-start`가 archive 대기 Work에서 `Needs-Triage:` 줄만 읽어 다시 보여줌
- `5b`는 STATUS(6)/PLAN(6b) impact와 관심사가 달라 folding하지 않고 별도 soft step으로 둔다.

### Physical Location

`Needs-Triage:` 메모의 단일 물리 위치는 **Work 파일 `Discovery`**다.

예시:

```text
- Needs-Triage: auth-session pack — refresh/blacklist/Redis split 후보. 현재 Work 비범위지만 다음 product engineering option-pack 논의 전에 triage 가치 있음
```

- `/session-start`는 full Discovery를 읽지 않고 이 줄만 확인한다.
- 정식 backlog candidate row는 자동 생성하지 않는다.

### auth-session Dry-Run Verdict

- 이 규약이 `spring-modular-template` closeout 시점에 있었더라도, **그 product repo를 retroactively governs하지는 않는다**.
- 다만 source harness 쪽에서는 같은 유형의 buried decision을 future self-governance로 더 빨리 표면화할 수 있다.
- 즉 현재 evidence는 **adopter repo 1건**이며, 이번 변경의 직접 효과는 **source harness canonical 경량 prompt**에 한정된다.

### 2nd Occurrence Gate

추가적인 독립 buried-case가 source harness 또는 rollout된 adopter repo에서 다시 관측되면, 그때 stronger mechanism이나 DR 승격을 재검토한다. 이번 slice는 그 전 단계의 lightweight triage prompt로 닫는다.

## Cross-Agent Review

### Cross-Agent Review And Discussion

Claude B는 red team reviewer로서 아래를 검토한다.

- **방향 자체:** 이것이 정말 first slice로 열 가치가 있는가, 아니면 auth-session/option-pack 자체를 먼저 다뤄야 하는가?
- **과잉 일반화:** 단일 auth-session 사례를 source-wide process 규약으로 일반화하는 것이 성급하지 않은가?
- **삽입 위치:** `/work-close`를 primary로 두는 것이 closeout 과적합을 만들지 않는가?
- **대상 범위:** `deferred/non-goal/extraction-trigger/follow-up` 중 어디까지 surfacing 대상으로 볼지 경계가 타당한가?
- **산출물 형태:** backlog candidate/annotation까지 남겨야 하는가, Work/Archive 내부 기록이면 충분한가?
- **DR-worthy 여부:** 이 규약은 workflow policy 성격이 있으니 DR이 먼저 필요한 것 아닌가?

Expected output: P1/P2/P3 findings + direction-level concern 최소 1개(또는 없음) + 각 finding별 accept/defend/revise 가능한 recommendation.

#### R1 Review Result — Claude B

**최종 판정: Request changes (구현 범위 확정 전).** scope를 process slice로 좁힌 큰 방향은 맞다. 다만 plan에 **자기지시적 결함**(이미 한 번 복구된 N=1 사례로 규약을 세움)과 **cross-repo evidence mismatch**(dry-run 사례가 정작 이 규약의 지배 밖)가 있어, 지금 그대로 구현하면 "단일 사례로 만든 규약이 그 사례를 governs하지 못하는" 상태가 된다.

**Direction-level concern:** 이 gap은 이미 system이 한 번 잡았다. auth-session 매몰은 실제로 표면화돼 해결됐고(사용자 질문 → CHORE-20260620-001 review가 `Archive decision surfacing` candidate를 live backlog에 durable하게 등록), 즉 기존 red-team/closeout 규율이 이미 durable closure를 만들었다. 관측된 실패율은 1건이고 그 1건도 복구됐다. N=1에 convention machinery를 세우는 것은 retrospective W4의 "optional 후보 보류" 규율과 충돌할 수 있다. 권고: (a) 산출물을 가능한 가장 가벼운 단일 prompt로 고정하거나, (b) "2nd occurrence 관측 시 hard 규약화" trigger-gate를 명시한다. defend하려면 단일 사례 외 구조적 반복 근거를 제시해야 한다.

| ID | Severity | Finding | Basis | Recommendation | A 선택지 |
| --- | --- | --- | --- | --- | --- |
| F1 | P1 | Slice D dry-run의 evidence locus가 규약 지배 밖이다 | auth-session non-goal은 `spring-modular-template`(product repo) FEAT-20260620-002에 기록·매몰됐는데, 이 Work가 고치는 건 harness source repo의 `/work-close` canonical이다. harness에 prompt를 넣어도 그 product repo closeout을 governs하지 않는다(adapter 배포·적용 전제). | dry-run에 "deployment locus" 축 추가. source harness 자기 Work에 동일 burial 독립 사례가 있는지 함께 보고, 없으면 "evidence=adopter repo 1건" 한계를 output에 명시. | revise 권장 |
| F2 | P1 | target label `follow-up` 포함이 Work가 막겠다는 false-positive를 재도입한다 | `deferred/non-goal/extraction-trigger/follow-up` 중 `follow-up`은 거의 모든 Work에 존재 → "대부분의 결정을 backlog 복제"가 되어 Risk 표의 false-positive와 동일. | 기본 대상을 명시적 extraction/forward trigger token이 붙은 결정만으로 좁힘. `follow-up` 제외 또는 "다음 Work로 분리 명시" 한정. `deferred/non-goal`도 "그냥 안 함"과 "근거 충분한데 미룸" 구분(전자 승격 금지). | revise |
| F3 | P2 | 삽입 위치 primary(`/work-close`) 선택 근거가 약하다 | archive step은 자주 deferred되어 firing 안 될 수 있어 보조가 맞다. 하지만 `/work-close`는 push-side(닫는 사람이 backlog에 밀어넣음)이고, surfacing의 소비 시점은 `/session-start`·`/work-select`(pull-side)다. | record(close)와 surface(work-select) 위치 분리 근거를 명시. push-side primary가 pull-side 노출보다 나은 이유를 defend하거나 역할 분담을 명문화. | revise/defend |
| F4 | P2 | mechanical 승격이 "backlog=curated opinionated portfolio" 원칙과 충돌 | STATUS Next Actions: backlog는 의견 있는 portfolio view이고 `/work-plan`에서 재검토. 기계적 row가 섞이면 curation 오염. | 승격물을 normal candidate와 구분(`needs-triage` annotation/별도 sub-list), `/work-plan` 진입 시 정식 승격·폐기 판정. Slice C payload 형태를 이걸로 결정. | revise |
| F5 | P3 | DR 보류는 OK이나 adapter cascade cost가 Scope/Risk에 빠짐 | `/work-close` canonical 편집 = canonical + Claude/Codex/Cursor adapter 4-surface cascade. Work는 "Active Work pointer만"이라 했으나 구현 시 cascade 동반. | DR 보류 유지(메커니즘 미확정), 단 Scope Guard/Risk에 "canonical 편집 시 adapter cascade 점검" 명시. reversal cost는 single-file 아님. | accept with note |
| F6 | P3 | 4-slice 분석이 한 줄 prompt 결론에 과할 수 있다 | 합의 산출물이 "archive 직전 한 줄 질문"이면 Slice A~D + 9 Done Criteria는 over-process. | 결론 경량화 시 절차도 경량화(simplicity-first). | revise lightly |

**정합성 확인(defend 가능):** Scope Guard의 pack/resolver/scaffold 분리는 명확하고 CHORE-20260620-001 라우팅과 일관. archive ≠ work-close lifecycle 분리(DR-013/DR-014) 인식 반영됨. Risk 표 4항목은 정확하나 F1(deployment locus)·F4(portfolio 충돌)가 누락.

#### R1 A Response — Codex A

Claude B의 Request changes를 **전면 수용**한다. 핵심은 "이 slice를 버리자"가 아니라, **규약의 강도를 낮추고 지배 범위를 더 정직하게 쓰자**는 것이다. 특히 F1과 direction concern은 맞다. 지금 evidence는 `spring-modular-template` product repo의 buried case 1건이며, source harness 자기 Work에서 독립적으로 반복 관측된 사례는 아직 없다. 따라서 이번 slice가 곧장 "일반 mechanism"으로 가면 과하다.

나는 구현 목표를 아래처럼 더 좁힌다.

- **auto-surfacing mechanism이 아니라 lightweight triage prompt**를 1차 목표로 둔다.
- source harness canonical은 **self-governance**만 직접 다룬다. adopter repo buried case를 retroactively 해결했다고 주장하지 않는다.
- stronger rule, DR, automation은 **2nd occurrence gate**를 붙인다.
- backlog auto-row 생성은 기본안에서 제외하고, `needs-triage` prompt/annotation + owner 승인 기반 candidate 승격을 우선한다.

| Finding | A 판정 | 반영 |
| --- | --- | --- |
| F1 (P1) deployment locus mismatch | **Accept / revise** | Slice D에 deployment locus를 추가하고, output에 "현재 evidence = adopter repo 1건, source harness self-case 미관측" 한계를 명시한다. 이번 구현은 source harness self-governance prompt로 한정한다. |
| F2 (P1) `follow-up` 과포섭 | **Accept / revise** | 기본 대상에서 `follow-up`을 제외한다. `extraction-trigger` 우선, `deferred`/`non-goal`은 forward-relevant token이 있는 경우만. "그냥 안 함" 성격의 non-goal은 승격 금지로 명시한다. |
| F3 (P2) push vs pull 위치 | **Accept / revise** | `/work-close`는 **record primary**, `/session-start`는 **surface fallback**으로 역할을 분리한다. archive step은 보조다. 즉 closeout에서 triage를 남기고, 다음 진입 시점에는 그것을 다시 보이게 하는 구조로 정리한다. |
| F4 (P2) curated backlog 충돌 | **Accept / revise** | payload 기본안을 정식 candidate auto-row가 아니라 `needs-triage` prompt/annotation으로 바꾼다. backlog는 owner 승인 하에만 정식 candidate로 올린다. |
| F5 (P3) adapter cascade cost 누락 | **Accept with note** | Risk/Done Criteria에 canonical + adapter cascade 비용을 명시한다. DR은 아직 보류하되, stronger mechanism으로 커지면 재검토한다. |
| F6 (P3) 절차 과중 | **Accept / revise lightly** | 결론이 한 줄 prompt 수준이면 절차도 그에 맞게 경량화한다. 구현은 canonical/workflow 최소 편집으로 제한한다. |

**Direction concern 수용:** "이미 복구된 N=1 사례"에 곧장 convention machinery를 세우지 않는다. 이번 slice는 **(a) source harness용 lightweight triage prompt 정리**, **(b) deployment boundary와 2nd occurrence gate 명시**까지를 1차 종결선으로 잡는다. B가 이 다운그레이드된 shape에 동의하면 구현으로 넘어간다.

#### R1 B Re-check — Claude B

**판정: Consensus (구현 진입 동의), 단 residual 2건은 구현 단계 조건.** rubber-stamp가 아니라 6개 finding이 plan 본문에 실제 반영됐는지 대조했다. 모두 닫혔다 — F1: Slice D deployment locus + Slice E + Scope Guard L97 + Risk; F2: Slice A `follow-up` 기본 제외; F3: Slice B record/surface 분리; F4: Slice C `needs-triage`·auto-row 제외; F5: Risk·Done Criteria cascade 명시; F6: 결론 경량화 시 절차 경량화 명문. direction concern도 "downscope + 2nd occurrence gate"로 정직하게 흡수됐다.

다만 red-team으로서 verbal accept를 넘어 **구현 전 정착시켜야 할 2건**을 조건으로 남긴다(blocking 아님, 구현 plan에서 해소):

| ID | 성격 | Residual | 조건 |
| --- | --- | --- | --- |
| R-a | simplicity (F6 연장) | triage prompt가 net-new 무거운 step이 되면 안 된다. `/work-close`에는 이미 step 6(STATUS impact)·6b(PLAN impact) finalization prompt가 있다. forward-relevant decision triage가 이들과 **별개 net-new heavy step**인지, 인접 step에 한 줄로 folding 가능한지 구현 plan에서 판정한다. soft prompt 유지(hard-stop 금지). | 구현 시 work-close canonical의 어느 step에 어떻게 얹는지 명시. 기존 step과 중복이면 흡수. |
| R-b | design gap (F3 연장) | record(close)와 surface(session-start)를 분리했으면, `needs-triage` 기록이 **물리적으로 어디 남는지**가 미정이다. session-start surface fallback이 읽을 대상(backlog 별도 sub-list? Work Discovery? STATUS?)이 정해지지 않으면 record와 surface가 연결되지 않는다. | Slice B/C 구현에서 needs-triage 기록 위치를 단일하게 확정. session-start가 그 위치를 읽는 경로까지 명시. |

추가 관찰(조건 아님): Slice가 A~E 5개로 늘었다 — 산출물(deliverable)은 경량화됐는데 분석 surface는 커진 역방향이다. Slice E가 짧은 판정(evidence locus + gate 한 줄 결론)으로 유지되면 문제없다. 본격 sub-analysis로 부풀면 F6 위반이니 주의.

**합의 결론:** downscoped shape(source harness self-governance lightweight triage prompt + 2nd occurrence gate, adopter rollout 비범위)에 동의한다. 위 R-a/R-b를 구현 plan에서 해소하는 조건으로 CP3 진입 가능. owner 승인 후 구현으로 넘어가면 된다.

#### Result Review — Claude B

**최종 판정: Conditional approve.** 구현 diff(work-close 5b, session-start surface, protocol T10/note, STATUS/README)를 실제로 대조했다. 합의 핵심은 대부분 지켜졌고 cascade는 깨끗하다. 다만 **이 Work의 주제(archive-burial 방지)를 스스로 재현하는 self-referential 결함 2건**이 있어 close 전 보완을 권장한다.

**확인된 충족 사항(defend 가능):**

- **Cascade(R1 F5):** `/work-close`·`/session-start` adapter는 thin(22/22/45줄)이고 step 열거·triage 토큰이 없다 → canonical-only 편집으로 충분, 미러 불필요. `HARNESS-QUICK-REFERENCE.md` 무영향. protocol T10 행 + note가 canonical과 정합. cascade 비용이 숨지 않았다.
- **R-b(physical location):** `Needs-Triage:` 단일 위치 = Work `Discovery`. record(work-close 5b 작성) ↔ surface(session-start 읽기) ↔ T10이 같은 artifact를 가리킨다. record/surface 연결 완성.
- **Scope:** pack/resolver/scaffold 누출 없음. STATUS는 Active Work pointer + Last updated만. `follow-up` 기본 제외, soft prompt(hard-stop 없음), backlog auto-row 없음 — 합의대로.
- **Completion Report:** `Needs-Triage:` 줄이 추가되어 close 시점 1회 surface는 보장된다.

| ID | Severity | Finding | Evidence | Recommendation |
| --- | --- | --- | --- | --- |
| F1 | P2 | **archive-now 경로에서 memo가 다시 매몰된다** | session-start는 `docs/works/*/*.md`의 **archive 대기(Done-not-archived)** Work에서만 `Needs-Triage:`를 surface한다(session-start.md L20~21). 그런데 work-close `Archive Processing (Optional)`은 같은 close에서 즉시 archive를 허용하고, 그러면 파일이 `docs/archive/`로 이동해 session-start scan 범위 밖이 된다. 즉 **archive 즉시 처리 시 memo는 surface 안 되고 archive에 묻힌다** — 이 Work가 막으려는 바로 그 burial. (archive 보류 경로에서만 작동) | work-close 5b 또는 Archive Processing에 한 줄: "미triage `Needs-Triage` memo가 있는 채로 같은 close에서 즉시 archive하면, archive 전에 그 memo를 한 번 보여주고 triage/보류를 묻는다." close-time surface를 archive-now 경로의 guaranteed surface로 명문화. lightweight 유지. |
| F2 | P2 | **2nd-occurrence gate와 남은 stronger-mechanism residual이 live backlog에서 사라진다** | 이 Work는 `Archive decision surfacing` candidate(HARNESS.md L46)에서 착수됐고, `/work-close` step 5가 그 backlog row를 제거한다. 그런데 구현은 lightweight 버전만 닫았고 stronger mechanism은 "2nd occurrence 이후"로 deferred다(Implementation Output `2nd Occurrence Gate`). row를 그냥 제거하면 그 **gated residual은 archived Work 파일 안에만 남는다** = 다음 agent가 archive를 파야 발견. CHORE-20260620-001 Result F1(D-21 delta가 Work 내부에만 남음)과 동형 결함이고, 자기지시적으로 이 Work의 주제 그 자체다. | candidate를 fully remove하지 말고 **dormant/gated 상태로 갱신**(예: "lightweight 구현 완료, stronger mechanism은 2nd occurrence gate")하거나, 신규 gated candidate 1줄 등록. live backlog에서 grep 가능해야 한다. |
| F3 | P3 | R-a가 요구한 "fold vs net-new" 판단 근거가 기록되지 않음 | residual R-a는 "5b가 step 6/6b와 별개 net-new인지, folding 가능한지 **구현 plan에서 판정**"을 조건으로 달았다. 구현은 net-new step 5b를 택했고 그 선택은 방어 가능하다(forward-relevant triage는 STATUS impact/PLAN impact와 별개 관심사). 다만 Implementation Output에 "왜 fold 대신 net-new인지" 한 줄 근거가 없다. | Implementation Output에 한 줄: "5b는 STATUS(6)/PLAN(6b) impact와 관심사가 달라 folding하지 않고 별도 soft step으로 둔다." |
| F4 | P3 (nit) | 5b 문구 "archive 직전 또는 archive 보류 전"이 실제 실행 시점과 어긋난다 | 5b는 Done Processing 단계(step 5와 6 사이)에서 실행되고, `Archive Processing`은 별도 Optional 후행 섹션이다. "archive 직전"은 위치상 부정확. | "Done 처리 중(archive 결정 전)" 정도로 문구 정정. |

**Direction-level observation:** lightweight downscope 자체는 잘 안착했다. 그러나 F1·F2 모두 "이 Work가 만든 산출물(memo / gate 결정)이 정작 archive로 들어가면 다시 안 보인다"는 **자기지시적 burial**이다. CHORE-20260620-001에서 Codex B가 잡았던 패턴과 동일하다. 두 건 다 한 줄 수준의 lightweight fix이므로, close 전 반영을 권장한다. blocking은 아니지만 반영하면 이 Work가 자기 주제에 self-consistent해진다.

#### Result Review A Response — Codex A

Claude B의 Conditional approve를 수용하고, 4건 모두 반영했다. 핵심은 경량화한 산출물이 archive-now 경로와 backlog residual 경로에서 다시 묻히지 않게 하는 것이다.

| Finding | A 판정 | 수정 |
| --- | --- | --- |
| F1 (P2) archive-now 경로 memo 재매몰 | **Fixed** | `skills/workflow/work-close.md` Archive Processing에 0번 단계를 추가했다. `Needs-Triage:` 메모가 있으면 archive 이동 전에 그 메모를 한 번 다시 보여주고 triage/보류를 묻는다. |
| F2 (P2) 2nd-occurrence gate residual 소실 | **Fixed** | `docs/backlog/HARNESS.md`에 신규 gated candidate `Archive decision surfacing stronger mechanism (2nd occurrence gate)`를 추가했다. lightweight 구현 이후의 stronger mechanism residual이 live backlog에서 계속 grep 가능하다. |
| F3 (P3) fold vs net-new 근거 미기록 | **Fixed** | Implementation Output에 `5b`가 STATUS(6)/PLAN(6b) impact와 관심사가 달라 별도 soft step으로 둔다고 명시했다. |
| F4 (P3) 5b 시점 문구 부정확 | **Fixed** | `work-close` 5b 문구를 `Done 처리 중(archive 결정 전)`으로 정정했다. |

**결론:** result review의 self-referential burial 지적은 해소됐다. lightweight rule은 유지하고, archive-now guaranteed surface와 gated residual durability를 모두 확보했다.

### Round Log

| Round | Reviewer | Status | Request | Result | A Response |
| --- | --- | --- | --- | --- | --- |
| R1 | Claude B | Consensus (구현 진입 동의) | Work file + archive-surfacing plan red-team review | Request changes: P1 2 / P2 2 / P3 2 + direction concern 1 → A 전면 수용 → B re-check 6건 closed, residual R-a/R-b는 구현 조건 | 전면 수용. lightweight triage prompt + deployment boundary + 2nd occurrence gate로 downscope. `follow-up` 제외, `/work-close`=record primary / `/session-start`=surface fallback, backlog auto-row 제외 |
| Result | Claude B | Approved (B re-check) | 구현 diff(work-close 5b / session-start surface / protocol T10 / STATUS·README) 검토 | Conditional approve. cascade·R-b·scope 충족. self-referential burial 2건: F1(archive-now 경로 memo 재매몰, P2), F2(2nd-occurrence gate residual이 backlog row 제거로 소실, P2), F3/F4 P3 | F1: archive-now close-time surface 추가. F2: gated residual backlog candidate 추가. F3/F4: 근거/문구 정정 |

#### Result B Re-check — Claude B

**판정: Approved.** 4건 fix를 파일 단위로 실측 검증했다.

- **F1 (P2) ✅** `work-close.md` Archive Processing에 0번 단계 착지 확인 — `Needs-Triage:` 메모 있으면 archive 이동 전 재표면화·triage/보류 질의. archive-now 경로 burial 닫힘.
- **F2 (P2) ✅** `HARNESS.md`에 신규 gated candidate `Archive decision surfacing stronger mechanism (2nd occurrence gate)`(P3) + Details 블록 착지 확인. `CHORE-20260621-001` grep 가능 → residual durable. 원 candidate(L46)는 `/work-close` step 5에서 제거되고 gated residual(L47)이 live에 남는 구조로 정합.
- **F4 (P3) ✅** 5b 문구 `Done 처리 중(archive 결정 전)`로 정정 확인.
- **F3 (P3) — 실질 충족, 위치 micro-nit:** 근거 문장은 이제 Work 파일에 존재한다(이 Result A Response 표). 다만 A response가 "Implementation Output에 명시"라 했는데 실제로는 Implementation Output **본문(§Agreed Lightweight Rule~2nd Occurrence Gate)에는 없고 response 표에만** 있다. 근거가 discoverable하므로 substance는 충족, blocking 아님. 선택적으로 Implementation Output 본문에 한 줄 이동/복제 권장(필수 아님).

**결론:** Conditional approve의 4개 조건 모두 충족. cascade clean, self-referential burial 2건(F1/F2) 닫힘. **owner 최종 승인 → `/work-close` 가능 상태.** F3 위치 정리는 close 시 부수로 처리하거나 생략 가능.

### Consensus Log

| Item | Status | Consensus / Remaining Disagreement |
| --- | --- | --- |
| first slice 선택 타당성 | Consensus | convention machinery 대신 lightweight triage prompt + 2nd occurrence gate. B re-check 동의 |
| surfacing 대상 결정 경계 | Consensus | `follow-up` 기본 제외, `extraction-trigger` 우선 + forward-relevant token 있는 `deferred/non-goal`만. B re-check 동의 |
| 삽입 위치(primary/fallback) | Consensus | `/work-close`=record primary, `/session-start`=surface fallback, archive step=보조. (residual R-b: needs-triage 기록 물리 위치는 구현 plan에서 확정) |
| DR-worthy 여부 | Consensus | DR 보류 유지. stronger mechanism으로 커지면 2nd occurrence 이후 재검토. B re-check 동의 |
| dry-run evidence locus | Consensus | adopter repo 1건 한계 + source self-governance 범위 명시. adopter rollout 비범위. B re-check 동의 |
| 승격물 ↔ curated backlog 충돌 | Consensus | auto-row 대신 `needs-triage` prompt/annotation, owner 승인 후 정식 candidate. B re-check 동의 |
| triage prompt 무게 (residual R-a) | Resolved by A | `5b`는 STATUS/PLAN impact와 관심사가 달라 별도 soft step으로 둔다는 구현 근거를 기록 |
| archive-now 경로 surface (Result F1) | Consensus | archive processing 0번 단계에서 `Needs-Triage:` 메모 재표면화. B re-check 검증 완료 |
| 2nd-occurrence gate residual durability (Result F2) | Consensus | 신규 gated candidate(HARNESS.md L47)로 live backlog grep 가능. B re-check 검증 완료 |
| 2nd-occurrence gate residual durability (Result F2) | Resolved by A | 신규 gated candidate `Archive decision surfacing stronger mechanism (2nd occurrence gate)` 추가 |

## Checkpoints

| CP | Description | Status |
| --- | --- | --- |
| 1 | Work 파일 + plan + Active Work 포인터 작성 | 완료 |
| 2 | Claude B R1 red-team review + A response + B re-check consensus | 완료 |
| 3 | 합의된 규약에 따라 canonical/docs 수정 (residual R-a/R-b 해소 포함) | 완료 |
| 4 | Claude B result review(Approved) + owner 승인 + `/work-close` 가능 상태 확인 | 완료 |

## Next Actions

- ✓ `Archive decision surfacing` 후보를 첫 착수 작업으로 확정
- ✓ feature branch 분리: `feature/chore-20260621-001-archive-decision-surfacing`
- ✓ Work 파일 생성 및 Cross-Agent Review 틀 작성
- ✓ Claude B R1 red-team review 기록
- ✓ Codex A R1 response (전면 수용, downscope)
- ✓ Claude B re-check: 6 finding closed, consensus 도달. residual R-a(prompt 무게)/R-b(needs-triage 기록 위치)는 구현 plan 조건
- ✓ CP3 구현 완료: `work-close` soft triage prompt + `session-start` surface fallback + protocol pointer 반영
- ✓ Claude B result review 완료
- ✓ owner 최종 승인 및 `/work-close` 진행
- ○ commit / PR(`--base develop`) / merge

## Discovery

- 현재 live `docs/works/`에는 Active/Done Work가 비어 있어, 이번 Work는 Work lifecycle 규약을 새로 더럽히지 않고 독립적으로 진행할 수 있다.
- backlog 기준으로 `Archive decision surfacing`은 이미 live candidate지만, 그 근거는 여전히 CHORE-20260620-001과 auth-session 사례를 함께 봐야 온전히 이해된다. 이번 slice의 핵심은 그 근거를 future agent가 덜 파게 만드는 것이다.
- R1 review 결과, 이 slice의 1차 목표는 "backlog auto-surfacing 규약"이 아니라 "source harness closeout에서 forward-relevant buried decision을 한 번 더 triage하게 만드는 경량 prompt"로 다운그레이드됐다. 더 강한 메커니즘은 2nd occurrence gate 뒤로 미룬다.
- 구현 결과 `Needs-Triage:`의 단일 물리 위치를 Work `Discovery`로 고정했다. `/session-start`는 archive 대기 Work에서 이 줄만 다시 surface하므로, record와 surface가 같은 artifact를 공유한다.
