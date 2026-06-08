# DR-024: Gate Strictness 2D Taxonomy

Date: 2026-06-05
Status: Accepted

## Question

gate가 늘었으나(archive, finalization, close, branch isolation) 강제성과 enforcement가 ad hoc하게 섞여 조건부 강제 gate가 평시 workflow에 마찰을 샌다. 어떻게 일관되게 분류하는가?

## Decision

gate를 **2D taxonomy**로 분류한다.

- **Strictness 축:** `mandatory` / `conditional mandatory` / `recommended` / `optional hygiene`
- **Enforcement mode 축:** `hard-stop` / `warning` / `report-only` / `silent`

필수 대표 범주는 **archive / commit / release / bootstrap** 네 개다(category-level example).

| Gate | Strictness | Enforcement |
| --- | --- | --- |
| causal finalization bundling (Work 변경 + Work Done/STATUS/index 같은 commit) | conditional mandatory | hard-stop / explicit override |
| archive cleanup | optional hygiene | silent 또는 threshold report-only |
| public release gate | conditional mandatory | hard-stop |
| bootstrap completion | conditional mandatory | warning 또는 hard-stop |

`clean baseline`은 release 직전 escalation 후보인 **보조 예시**이며, 위 네 범주와 같은 레벨의 primary requirement는 아니다.

scope 변경 gate는 비대칭: 확장=승인, 축소=보고, Done Criteria 축소=별도 확인, split=신규 Work/register.

## Options Considered

| 선택지 | 장점 | 단점 |
|--------|------|------|
| 2D taxonomy (채택) | 강제성·집행을 분리해 평시 마찰과 release 안전을 동시 조정 | vocabulary 도입 후 각 gate 재분류 필요 |
| 1D(강제성만) | 단순 | "어떻게 집행하나"가 강제성에 뭉개져 ad hoc 튜닝 반복 |
| gate별 개별 조정 유지 | 즉시성 | 일관 기준 없음, archive를 부채처럼 취급 |

## Rationale

`STATUS.md:41` Recent Decision(2026-05-29)이 "solo에서 housekeeping마다 PR 강제는 과도한 마찰"로 `main` hard block / `develop` warning을 즉흥 조정했다 — taxonomy가 아니라 gate별 ad hoc 튜닝이다. `.claude/commands/start.md:11-13`(Idle-State Rule)은 archive 대기 Work 없음을 clean idle 조건으로 둬, optional hygiene을 부채처럼 만든다. "mandatory인가"(강제 대상)와 "어떻게 집행하나"(hard-stop/warning)를 한 축에 뭉개면 이런 누수가 반복된다. 두 축을 분리하면 archive=optional hygiene+silent, causal finalization=conditional mandatory+hard-stop처럼 평시 마찰과 안전을 독립 조정할 수 있다.

외부화 3대 실패모드 매핑: ③ 선언-실행 괴리(주, enforcement mode 축이 "권장만 하고 런타임 무시"를 명시 집행으로 환원), ② 비대화(archive optional 강등), ① 라우팅 누락(gate vocabulary 명확화).

## Consequences

- archive는 평시 clean idle 차단 조건에서 제외된다(optional hygiene). 누적 임계 report 기준은 하류.
- `/close`는 commit-agnostic state edit으로 제한되고, commit bundling 판단은 commit gate가 소유한다.
- **Commit gate runtime enforcement(causal finalization bundling의 hard-stop/override 실제 정책)는 별도 child DR**로 분리한다. exception table(OQ-14), override UX, hook/command 구현은 하류.
- OQ-12(/close commit 책임), OQ-13(causal finalization 분류), OQ-16(archive clean idle 제외) 닫힘.

## Reversal Cost

Low — vocabulary와 대표 분류는 문서 결정. runtime 구현(child DR)은 적용 시 Medium 이상으로 재평가.

## Linked Backlog Items

- CHORE-20260605-001 (slice 0 CP4 / DR-D)
- 부모: CHORE-20260604-001 §9
- 연계: child DR(Commit gate runtime enforcement, CHORE-20260606-004 → DR-025), DR-022(closeout enforcement mode), `gate-enforcement-runtime-and-env`(구 HRN-002+HRN-FUT-001 흡수, runtime hook/config/env)
