# DR-008: docs/ 파일명 대소문자 표준

Date: 2026-05-12
Status: Accepted

## Question

`docs/` 디렉토리 내 파일명의 대소문자 규칙을 통일할 것인가? 통일한다면 어떤 표준을 채택할 것인가?

## Decision

디렉토리별로 다음 표준을 채택한다.

| 위치 | 표준 | 예시 |
|------|------|------|
| `docs/` 루트, `docs/backlog/`, `docs/decisions/` | UPPERCASE-HYPHENATED | `HARNESS-PROTOCOL.md`, `PHASE2.md`, `DR-008-*.md` |
| `docs/works/{category}/` | `{ID}-{lowercase-topic}.md` | `HRF-002-work-system-refactor.md`, `PRE-C1-architecture-audit.md` |
| `docs/harness-protocol/` | `{NN}-{lowercase-topic}.md` | `03-work-items-and-naming.md` |
| `docs/archive/` | lowercase-hyphenated | `phase1-status.md`, `phase1-plan.md` |

## Options Considered

| 선택지 | 장점 | 단점 |
|--------|------|------|
| 전체 lowercase-hyphenated | 현대 표준, 타이핑 편리 | 기존 파일 대량 rename 필요 (10+), 참조 전수 수정 |
| **UPPERCASE 유지 + 예외 정규화 (채택)** | 기존 다수 파일 변경 없음, 최소 수정 | UPPERCASE가 현대 docs 관행과 다소 상이 |
| 혼용 유지 | 변경 없음 | 신규 파일 생성 시 기준 부재 |

## Rationale

- `docs/` 루트 파일 8개가 이미 UPPERCASE 패턴이었고, `coding-conventions.md` 1개만 이번 세션에서 생성된 예외였다.
- 최소 변경 원칙에 따라 1개 파일만 rename하는 UPPERCASE 표준화를 선택했다.
- `docs/archive/`는 STATUS → archive 이동 절차(`docs/AGENT-WORKFLOW.md`)에서 `phase{n}-status.md` 형식을 명시하므로 lowercase 유지가 자연스럽다.
- 파일명 대소문자 혼용은 macOS(case-insensitive) 환경에서 git 추적 오류를 유발할 수 있다.

## Consequences

- 신규 `docs/` 루트 파일, `backlog/`, `decisions/` 파일은 UPPERCASE-HYPHENATED로 작성한다.
- 신규 `docs/works/{category}/` Work 파일은 ID 기반 파일명을 사용한다 (DR-013 참조).
- 신규 `docs/harness-protocol/` 파일은 번호 prefix가 있는 lowercase-hyphenated 파일명을 사용한다.
- `docs/archive/` 자동 생성 파일은 기존 lowercase-hyphenated 유지.
- `docs/coding-conventions.md` → `docs/CODING-CONVENTIONS.md` 이름 변경 완료 (참조 8곳 업데이트).
- `docs/decisions/PHASE2-BACKLOG.md` (pointer 파일, 참조 없음) 삭제 완료.

## Reversal Cost

Low — 파일명 변경과 참조 업데이트만 필요. 기능·동작에 영향 없음.

## Linked Backlog Items

없음 (운영 규칙 결정).
