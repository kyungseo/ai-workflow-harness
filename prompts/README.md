# Prompt Library Guide

이 디렉토리는 반복 사용 가능한 task prompt와 세션 bootstrap prompt를 보관한다.
Claude Code에서는 기본적으로 `.claude/commands/`를 먼저 사용하고, 이 prompt들은 command를 쓸 수 없거나 다른 도구로 작업을 넘길 때 사용한다.

현재 구성:

- `00~22 *.prompt.md`: Claude, Cursor, ChatGPT, Gemini 등에서 재사용 가능한 task prompt
- `claude-session-start.md`: Claude Code slash command를 사용할 수 없는 환경의 fallback prompt
- `cursor-session-start.md`: Cursor에서 현재 하네스 상태를 복원하는 bootstrap prompt
- `codex-session-start.md`: `AGENTS.md`를 사용할 수 없거나 수동 복원이 필요한 환경의 fallback prompt

## 1) Prompt vs Command

| 구분 | 사용 위치 | 역할 |
| --- | --- | --- |
| `.claude/commands/` | Claude Code | `/start`, `/pick`, `/work`, `/close`, `/done` 같은 반복 workflow 실행 |
| `prompts/*.prompt.md` | 여러 AI 도구 | 기능 구현, 디버깅, 리팩토링, 리뷰 같은 portable task template |
| `claude-session-start.md` | Claude fallback | slash command를 사용할 수 없을 때 세션 시작 |
| `cursor-session-start.md` | Cursor | `.cursor/rules`와 하네스 상태를 함께 로드 |
| `AGENTS.md` | Codex | repo-level entry point. 전역 원칙은 `docs/BEHAVIOR-PRINCIPLES.md`, 공통 규칙은 `docs/AGENT-WORKFLOW.md`로 위임 |
| `codex-session-start.md` | Codex fallback | `.claude/commands`를 수동 절차로 해석해 세션 시작 |

Command는 repo-local workflow를 실행하고, prompt는 tool-independent task brief를 전달한다.
역할 경계가 애매한 항목은 HRN-004 기준에 따라 아래처럼 분류한다.

| 분류 | 기준 | 현재 항목 |
| --- | --- | --- |
| Keep as command | STATUS/backlog/Work/DR 상태를 읽거나 바꾸는 반복 workflow | `.claude/commands/*.md` 전체 |
| Keep as prompt | 다른 AI 도구로 넘겨도 의미가 유지되는 구현·리뷰·설계 task template | `00~22-*.prompt.md` 전체 |
| Session fallback prompt | tool entrypoint가 없거나 slash command를 쓸 수 없는 환경에서 bootstrap 복원 | `claude-session-start.md`, `cursor-session-start.md`, `codex-session-start.md` |
| Promote to command | 같은 prompt가 repo 상태 변경, Approval Matrix, Work lifecycle을 반복 실행하게 된 경우 | 현재 없음 |
| Archive/delete | command와 기능이 완전히 중복되고 portable task value가 없는 경우 | 현재 없음 |

## 2) 빠른 사용 절차

1. 작업 유형에 맞는 prompt를 고른다.
2. `{{...}}` 변수 자리에 프로젝트 정보와 요청을 채운다.
3. AI에 붙여넣는다.
4. 결과에서 `Scope`, `Verification`, `Risk`, `Reversal Cost`를 확인한다.
5. 구현이 필요한 작업은 승인 전 수정하지 않도록 명시한다.

## 3) Prompt 선택표

### 일반

| 상황 | Prompt |
| --- | --- |
| 일반 작업 시작 | `00-generic-task.prompt.md` |
| 신규 뼈대 생성 | `01-scaffold-project.prompt.md` |
| 기능 1개 추가 | `03-add-single-feature.prompt.md` |
| 에러 재현·수정 | `05-debug-error.prompt.md`, `17-reproduce-and-fix.prompt.md` |
| 테스트 먼저 작성 | `06-write-tests-first.prompt.md` |
| 구조 리팩토링 | `07-refactor-code.prompt.md` |
| API 연동 | `09-api-integration.prompt.md` |
| README 작성 | `15-write-readme.prompt.md` |
| 코드 리뷰 | `16-code-review.prompt.md` |
| 기능 설계 | `19-design-feature.prompt.md` |
| 변경사항 요약 | `20-summarize-work.prompt.md` |

### Spring Boot 백엔드 (`create-harness.sh --profile spring-boot` 사용 시)

| 상황 | Prompt |
| --- | --- |
| 서비스 신규 생성 | `02-scaffold-service.prompt.md` |
| 보안 검토 | `04-security-review.prompt.md` |
| 서비스 분리 | `08-split-service.prompt.md` |
| 입력 검증·예외 처리 | `10-add-validation.prompt.md` |
| Resilience4j | `11-add-resilience.prompt.md` |
| 성능 개선 | `12-performance-fix.prompt.md` |
| Micrometer 메트릭 | `13-add-metrics.prompt.md` |
| DB migration | `14-write-migration.prompt.md` |
| Redis cache | `18-add-cache.prompt.md` |
| 레이어별 코드 생성 | `21-create-layer.prompt.md` |
| 최소 변경 강제 | `22-minimal-diff.prompt.md` |

## 4) 세션 시작 기준

Claude Code에서는 slash command가 기준이다.

| Command | 역할 |
| --- | --- |
| `/start` | `docs/STATUS.md` 기준 현재 상태 요약 |
| `/pick` | product backlog 또는 harness backlog에서 작업 선택 |
| `/register [설명]` | 새 작업 항목 등록 — 긴급도·성격에 따라 적절한 위치에 라우팅 |
| `/work {ID}` | 특정 작업의 plan 수립 |
| `/resume {ID}` | 중단된 작업 재개 |
| `/debug` | 에러 분석 또는 리팩토링 진입 |
| `/doc [brief]` | 발표/보고 자료 생성 — brief, source, format, quality 기준 먼저 확정 |
| `/close` | Work Done 처리 전용. 세션 계속 |
| `/done` | 세션 종료 요약과 상태 갱신 점검 (세션 끝낼 때만 사용). Work Done 처리 없음 — 먼저 `/close` 실행 |
| `/record-decision` | 확정된 결정을 DR로 기록 |
| `/health` | command/rule/protocol/backlog 정합성 점검 |

공통 context routing:

1. 도구별 진입점(`CLAUDE.md` 또는 `AGENTS.md`), `docs/BEHAVIOR-PRINCIPLES.md`, `docs/AGENT-WORKFLOW.md`, `docs/STATUS.md` 확인
2. Product 작업은 `docs/backlog/PHASE{n}.md` 또는 현재 Phase backlog 확인
3. Harness 작업은 `docs/backlog/HARNESS.md` 확인
4. Workflow rule 변경은 `docs/HARNESS-PROTOCOL.md`만 확인
5. 아키텍처 세부 근거가 필요할 때만 `docs/PLAN.md` 확인

Codex 사용 시:

- repo root `AGENTS.md`를 기본 진입점으로 사용한다.
- `.claude/commands/*`는 직접 실행하지 않고 같은 절차를 수동으로 따른다.
- `codex-session-start.md`는 `AGENTS.md`를 사용할 수 없거나 수동 bootstrap이 필요한 환경의 fallback이다.

## 5) 품질 체크리스트

- 범위 밖 변경을 하지 않았는가?
- 기존 동작이 깨지지 않는가?
- 검증 방법이 구체적인가?
- 리스크와 되돌리기 비용이 적혀 있는가?
- State Update, DR, Work 파일, 문서 cascade 필요 여부를 확인했는가?

## 6) 유지보수 규칙

- 새 task prompt는 기존 frontmatter key를 유지한다: `id`, `purpose`, `portability`, `difficulty`, `inputs`, `output_contract`.
- 범용 task prompt와 도구 특화 session prompt를 섞지 않는다.
- 세션 시작 절차가 바뀌면 이 문서, `claude-session-start.md`, `cursor-session-start.md`, `codex-session-start.md`, `.claude/commands/` 정합성을 함께 확인한다.
- profile 특화 prompt는 해당 프로젝트의 package/module 규칙에 맞게 조정한다.
