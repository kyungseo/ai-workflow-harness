# DR-011: STATUS.md Recent Decisions Rolling Window Policy

Date: 2026-05-15
Status: Accepted

## Question

STATUS.md의 Recent Decisions 섹션이 무한히 누적되는 것을 어떻게 관리할 것인가?

## Decision

Recent Decisions는 **최근 8개 rolling window**로 유지한다. 초과분은 drop한다. 별도 decisions-log.md를 생성하지 않는다. DR-worthy 결정은 `docs/decisions/DR-*.md`가 canonical 기록이고, 그 외 이력은 git history로 충분하다.

Recent Decisions에는 후속 행동을 바꾸는 운영/기술 판단만 남긴다. 단순 완료 사실은 Active Work, Checkpoints, commit history에 둔다.

## Options Considered

| 선택지 | 장점 | 단점 |
| --- | --- | --- |
| Rolling window (채택) | 유지 비용 없음. STATUS.md 항상 짧음 | 오래된 non-DR 결정은 STATUS.md에서 사라짐 |
| decisions-log.md 누적 | 모든 결정 이력 보존 | 파일 무한 증가. 관리 부담 대비 실제 참조 빈도 낮음 |
| 시간 기반 window (예: 최근 3일) | 직관적 | 세션 간격이 길면 섹션이 비어 컨텍스트 복원 불가 |
| 건수 + 시간 혼합 기준 | 유연 | 규칙이 복잡해져 agent 적용 오류 위험 |

## Rationale

Recent Decisions의 목적은 새 세션 시작 시 agent의 **빠른 컨텍스트 복원**이다. 영구 audit log가 아니다. 중요한 결정은 DR 파일이 담당하고, 그 외 운영 판단은 git commit history에 남는다. decisions-log.md는 "관리 부담 > 활용 가치" 구조가 되어 결국 방치될 가능성이 높다. 8개라는 건수 기준은 단순하고 세션 간격에 무관하게 항상 최소한의 컨텍스트를 보장한다.

## Consequences

- Recent Decisions에서 9번째 이상 오래된 항목은 STATUS.md에서 사라진다.
- rolling window 초과분을 제거하기 전, 해당 항목이 DR-worthy이면 대응 DR이 있는지 확인한다.
- 삭제된 항목이 DR-worthy였다면 이미 DR 파일에 있으므로 손실 없음.
- DR-worthy가 아닌 결정은 git log에서 커밋 메시지로 추적 가능.
- `/health` 점검 시 Recent Decisions는 최근 8개 rolling window, 항목 품질, DR-worthy 항목의 대응 DR 존재 여부를 대상으로 한다.

## Reversal Cost

Low — rolling window 기준을 변경하거나 decisions-log.md를 추가 도입하는 데 큰 비용 없음.

## Linked Backlog Items

없음
