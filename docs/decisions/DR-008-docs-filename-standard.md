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
- `docs/archive/` 자동 생성 파일은 기존 lowercase-hyphenated 유지.
- `docs/coding-conventions.md` → `docs/CODING-CONVENTIONS.md` 이름 변경 완료 (참조 8곳 업데이트).
- `docs/decisions/PHASE2-BACKLOG.md` (pointer 파일, 참조 없음) 삭제 완료.

## HRN-009 Audit Addendum (2026-05-20)

2026-05-20 `find docs -maxdepth 3` 기준 재검토 결과, DR-008의 기본 방향은 유지한다.

| 대상 | 판정 | 이유 |
| --- | --- | --- |
| `docs/` root markdown | UPPERCASE-HYPHENATED 유지 | 기존 root 문서와 context routing이 이미 이 규칙에 맞음 |
| `docs/backlog/`, `docs/decisions/` | 현행 유지 | `PHASE2.md`, `HARNESS.md`, `DR-{NNN}-{topic}.md`가 명확함 |
| `docs/works/{category}/` | 현행 유지 | DR-013의 `{ID}-{lowercase-topic}.md`가 Work ID 추적에 적합함 |
| `docs/archive/docs/` | DR-014 mirror 예외 | archive mirror는 원본 상대 경로와 파일명을 보존해야 추적성이 높음 |
| `docs/archive/snapshots/` | lowercase topic-date 유지 | snapshot bundle은 사람이 읽는 시점 기록이므로 root 문서 규칙과 분리함 |
| `docs/retrospectives/` | lowercase topic-date 유지 | 회고 문서는 시계열 기록이며 대량 rename 이익이 낮음 |
| `docs/presentations/` | 산출물 naming 유지 | generated artifact와 deck version 이름은 presentation workflow가 관리함 |
| `docs/VSCode-DevContainer구조.png` | 기존 media 예외로 유지 | 비문서 이미지 asset이며 rename 대비 참조·의미 개선 효과가 낮음 |
| `.DS_Store` | ignore 상태 확인 | git tracked 파일이 아니며 `.gitignore`가 제외함 |

`harness` 용어도 유지한다. 이 저장소에서 harness는 테스트 도구가 아니라 AI-assisted workflow를 감싸는 lightweight operating harness를 뜻하며, `workflow harness` 또는 `AI workflow harness`로 함께 쓰면 의미 충돌이 낮다. 전면 rename은 context/rule/문서 참조 비용에 비해 이익이 낮다.

## Reversal Cost

Low — 파일명 변경과 참조 업데이트만 필요. 기능·동작에 영향 없음.

## Linked Backlog Items

- HRN-009
