# DR-022: PLAN Lifecycle — T5 배선 + Archive Drain

Date: 2026-06-05
Status: Accepted

## Question

`PLAN.md`가 living document로 작동하지 않고(좀비), 살아나면 비대화 위험이 있다. 새 gate를 만들지 않고 어떻게 lifecycle을 배선하는가?

## Decision

PLAN을 분할하지 않고 **lifecycle을 배선**한다. 신규 hard gate를 만들지 않는다.

| 문 | 조치 | 막는 증상 |
| --- | --- | --- |
| **들어오는 문** | 기존 `T5`(PLAN 영향 결정)를 closeout(`T15`/`T16`/`T17`)·phase-transition(`T3`)에 배선 — closeout에서 "이 결정이 PLAN 방향에 영향을 주는가?" 확인 | 좀비(죽음) |
| **나가는 문** | PLAN **archive-drain 규칙 신설** — 닫힌 phase 상세는 `docs/archive/`로, PLAN은 현재+미래+archive 링크 한 줄만 유지(Recent Decisions rolling-window와 동형) | 비대화 |
| **옆문** | L3 근거는 PLAN에 누적하지 않고 DR로 분리 | 계층 비대화 |

generated repo에서 `PLAN.md` 작성 완료를 feature work의 **hard gate로 두지 않는다**(soft T5 배선). target-local harness 방향 기록처는 default Work/DR로 두고, 반복 시 optional plan 검토(OQ-7 잔여).

## Options Considered

| 선택지 | 장점 | 단점 |
|--------|------|------|
| Lifecycle 배선(T5+archive drain) (채택) | 죽음·비대화 동시 해결, 파일 수 불변, 기존 trigger 재사용 | PLAN 본문 rewrite·실제 archive는 별도 |
| PLAN hard gate 신설 | 작성 강제 | content/no-code 프로젝트 거짓 차단, bootstrap 이중 마찰 |
| Charter/roadmap 파일 분할 | 변경 주기 분리 | 작은 target에서 관리 파일만 늘어 더 빨리 죽음 |

## Rationale

`T5`는 이미 존재하나(`docs/HARNESS-PROTOCOL.md:423`) commit/PR 전 finalization gate(`:433-435` T15/16/17)와 phase-transition(`:421` T3)이 T5를 호출하지 않아 closeout에 PLAN 반영 단계가 없다. Recent Decisions에는 rolling-window 배출 규칙(`:496`)이 있으나 PLAN에는 동형 archive drain이 없다. 실증: `docs/PLAN.md` `v0.1`/작성일 `2026-05-22`, Roadmap이 `AWH-003/004`에서 정지(`:112-119`)했고 실작업은 `CHORE-*`로 진행 → 단절. 죽음과 비대화는 같은 뿌리(lifecycle 부재)의 두 증상이므로 한 처방(배선 + 배출구)으로 동시 해결한다.

외부화 3대 실패모드 매핑: ① 라우팅 누락(T5 배선으로 기록처 생존), ② 비대화(archive drain으로 상수 크기), ③ 선언-실행 괴리(미배선 자체가 표본 — 배선이 집행).

## Consequences

- closeout(`/close`)·commit finalization·phase-transition 절차에 PLAN impact 확인 단계가 추가된다(enforcement mode는 DR-024 taxonomy 따름).
- PLAN에 archive-drain 규칙이 생긴다. 닫힌 phase 상세는 `docs/archive/`로 이동, PLAN은 링크만 유지.
- L3 근거는 DR로 분리하는 규율 강화.
- OQ-3 닫힘. OQ-7(target-local harness plan) 잔여 유지.
- PLAN 본문 rewrite, AWH↔CHORE ID drift 수선, 실제 phase archive는 하류.

## Reversal Cost

Low — trigger 배선과 drain 규칙은 문서 변경. 되돌리기 쉽다.

## Linked Backlog Items

- CHORE-20260605-001 (slice 0 CP2 / DR-B)
- 부모: CHORE-20260604-001 §7
- 연계: HRN-030(Phase lifecycle), DR-024(closeout enforcement mode)
