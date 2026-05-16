# DR-012: Agent Entrypoint Symmetry — CLAUDE.md / AGENTS.md / docs/AGENT-WORKFLOW.md

Date: 2026-05-15
Status: Accepted

## Question

Claude Code, Codex, Cursor가 공통 운영 규칙을 공유하면서도 도구별 진입점을 분리하려면 어떤 구조를 취해야 하는가?

## Decision

- `CLAUDE.md` (루트): Claude Code 전용 진입점. 얇게 유지하고 `@docs/AGENT-WORKFLOW.md`로 공통 규칙을 import.
- `AGENTS.md` (루트): Codex 전용 진입점. `CLAUDE.md`와 동등한 peer. 공통 규칙은 `docs/AGENT-WORKFLOW.md`를 읽도록 위임.
- `docs/AGENT-WORKFLOW.md`: Claude Code와 Codex가 공유하는 공통 운영 규칙 단일 출처.
- Cursor: `.cursor/rules/*.mdc` + session bootstrap prompt로 동일 운영 규칙을 참조.

기존 `docs/CLAUDE.md`는 `docs/AGENT-WORKFLOW.md`로 rename하여 Claude 전용으로 오해되지 않도록 한다.

## Options Considered

| 선택지 | 장점 | 단점 |
| --- | --- | --- |
| 진입점 분리 + 공통 파일 위임 (채택) | 도구별 특화 지시 가능. 공통 규칙 중복 없음 | 파일 수 증가 (CLAUDE.md + AGENTS.md + AGENT-WORKFLOW.md) |
| CLAUDE.md 단일 파일 | 단순 | Codex가 CLAUDE.md를 "Claude 전용"으로 오해할 가능성. 도구별 차이 기술 불가 |
| 모든 규칙을 각 진입점에 복제 | 자급자족 | 규칙 변경 시 양쪽 동기화 필요. drift 위험 |
| 공통 파일만 유지, 진입점 없음 | 파일 수 최소 | 도구별 auto-load 메커니즘 활용 불가. context routing 불명확 |

## Rationale

Claude Code는 `CLAUDE.md`를 세션 시작 시 자동 로드하고, Codex는 `AGENTS.md`를 자동 참조한다. 각 도구의 auto-load 메커니즘을 활용하면서 공통 운영 규칙의 중복을 없애려면 "얇은 진입점 + 공유 규칙 파일" 구조가 최적이다. `docs/CLAUDE.md`라는 이름은 공통 파일임에도 Claude 전용으로 오해될 여지가 있어 `docs/AGENT-WORKFLOW.md`로 rename했다.

## Consequences

- 운영 규칙 수정은 `docs/AGENT-WORKFLOW.md` 한 곳에서 관리.
- 도구별 특화 지시(명령 매핑, 금지 사항 등)는 각 진입점 파일에서 관리.
- Cursor는 별도 진입점 파일 없이 `.cursor/rules/*.mdc`와 session prompt로 동일 규칙을 참조.
- `AGENTS.md` 부재 환경에서는 `prompts/codex-session-start.md`가 fallback.

## Reversal Cost

Medium — 진입점 구조 변경 시 20개 이상의 참조 파일 cascade 업데이트 필요 (이미 한 차례 경험).

## Linked Backlog Items

- HRN-008 (Done)
