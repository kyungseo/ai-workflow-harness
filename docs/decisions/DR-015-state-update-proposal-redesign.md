# DR-015: State Update Proposal — 2계층 게이트 모델

Date: 2026-05-18
Status: Accepted

## Question

Work 파일이 작업 단위의 SSoT가 된 이후, 기존 "STATUS Update Proposal" 게이트가 적절한가?
멀티 Active Work 환경과 Work 파일 상태 변경을 어떻게 통제할 것인가?

## Context

HRF-001(DR-012)에서 STATUS.md 직접 수정 금지와 STATUS Update Proposal 게이트를 도입했다.
당시 STATUS.md는 작업 내용·Checkpoints·이력 전부를 담고 있었으므로 게이트 비용이 정당했다.

HRF-002(DR-013)로 Work 파일이 작업 SSoT가 되면서 상황이 역전됐다:
- Work 파일 Checkpoint 업데이트 → 게이트 없음 (AI가 자유롭게 수정)
- STATUS.md 포인터 한 줄 추가 → 무거운 Proposal 필요

게이트 비용이 실질 위험과 반비례하는 구조가 됐다.

멀티 Active Work 시나리오에서의 추가 문제:
- AI가 어느 Work 파일을 수정하는지 명시 없음
- Work 완료(Done→Archive) 흐름에서 STATUS 포인터 제거 승인 구조 불명확

## Decision

"STATUS Update Proposal"을 **"State Update Proposal"**로 확장하고,
변경 레이어와 위험도에 따라 게이트 무게를 차등 적용한다.

### Layer 1 — Work 파일 변경 (실행 중 추적)

| 변경 유형 | 게이트 |
|-----------|--------|
| Checkpoint 상태 업데이트 | 없음 — 실행 후 보고 |
| Discovery 섹션 추가 | 없음 — 실행 후 보고 |
| Done Criteria 전체 충족 확인 | 간단 확인 ("기준 다 충족됨, Done 처리할까요?") |
| `status: Done`, `actual_end` 기입 | 명시적 사용자 확인 필요 (Phase 전환 게이트) |

### Layer 2 — STATUS.md 변경 (대시보드)

| 변경 유형 | 게이트 |
|-----------|--------|
| Active Work 포인터 추가/제거 | 인라인 1줄 제안 ("HRF-002 행 추가할게요") |
| Phase 완료 기준 체크 | 현행 Proposal 유지 (Phase 진입 고영향) |
| Recent Decisions 추가 | DR-011 rolling window 정책 적용 |
| Current phase/focus 변경 | 현행 Proposal 유지 (전체 방향 변경) |

### 멀티 Active Work 규칙

- AI가 State Update를 제안할 때 대상 Work 파일 ID를 항상 명시한다.  
  예: "HRF-002 CP5 Done으로 업데이트하겠습니다"
- STATUS.md Active Work 테이블이 진행 중인 Work 목록의 single view.  
  우선순위(P0 > P1 > P2)로 작업 순서 결정.
- 각 Work는 독립 게이트 — Work A 완료가 Work B에 자동 영향을 주지 않는다.
- Done→Archive 흐름은 `/done` 명령 절차에 명시된 순서를 따른다.

## Options Considered

| 선택지 | 장점 | 단점 |
|--------|------|------|
| 2계층 게이트 (채택) | 실질 위험에 비례한 게이트 비용, 멀티 Work 명확 | 규칙 복잡도 소폭 증가 |
| 현행 STATUS Update Proposal 유지 | 변경 없음 | Work 파일 변경 보호 없음, 포인터 1줄에 과한 게이트 |
| 게이트 완전 제거 | 마찰 최소 | 사용자 인지 없는 상태 변경 위험 |

## Rationale

Work 파일이 실질 작업 이력의 SSoT가 됐으므로, Work 파일 상태 전환(Done 처리 등)은 명시적 확인이 필요하다.
반면 STATUS.md 포인터 추가/제거는 실질 위험이 낮으므로 인라인 1줄 제안으로 충분하다.
게이트 비용을 실질 위험에 비례시키면 AI-사용자 협업의 마찰이 줄고, 중요한 전환점은 더 명확하게 보호된다.

## Consequences

- `.claude/commands/work.md`, `done.md`, `resume.md`의 게이트 설명을 이 정책에 맞게 점진적으로 갱신한다.
- `docs/HARNESS-PROTOCOL.md`와 `docs/AGENT-WORKFLOW.md`의 STATUS Rules 섹션에 2계층 게이트를 반영한다.
- `AGENTS.md`, `.cursor/rules/workflow.mdc`도 동일하게 갱신한다.
- 갱신은 별도 HRN 항목으로 추적한다.

## Reversal Cost

Low — 게이트 규칙은 문서 변경만으로 원복 가능.

## Linked Backlog Items

- HRN-002 (Hard enforcement 강화) — 이 DR과 연계 검토 필요
