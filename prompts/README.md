# Prompt Library Guide

이 디렉토리는 반복 사용 가능한 task prompt와 세션 시작 prompt를 보관한다.
Claude Code에서는 기본적으로 `.claude/commands/`를 먼저 사용하고, 이 prompt들은 command를 쓸 수 없거나 다른 도구로 작업을 넘길 때 사용한다.

Prompt library는 두 층으로 나눈다.

- **Generic core prompts**: AI Workflow Harness의 기본 prompt set. 특정 framework를 전제하지 않는다.
- **Optional example packs**: 특정 stack에 맞춘 prompt 예시. public repo에서는 확장 방식의 sample로 유지한다.

## 1) Prompt vs Command

| 구분 | 사용 위치 | 역할 |
| --- | --- | --- |
| `.claude/commands/` | Claude Code | `/session-start`, `/work-select`, `/work-plan`, `/work-close`, `/session-summary` 같은 반복 workflow 실행 |
| `prompts/*.prompt.md` | 여러 AI 도구 | 기능 구현, 디버깅, 리팩토링, 리뷰 같은 portable task template |
| `claude-session-start.md` | Claude fallback | slash command를 사용할 수 없을 때 세션 시작 |
| `cursor-session-start.md` | Cursor | `.cursor/rules`와 하네스 상태를 함께 로드 |
| `AGENTS.md`, `.agents/skills/workflow-*` | Codex | repo-level entry point와 harness workflow skill. 전역 원칙은 `docs/BEHAVIOR-PRINCIPLES.md`, 공통 규칙은 `docs/AGENT-WORKFLOW.md`로 위임 |
| `codex-session-start.md` | Codex fallback | `.claude/commands`를 수동 절차로 해석해 세션 시작 |

Command는 repo-local workflow를 실행하고, prompt는 tool-independent task brief를 전달한다.

## 2) Generic Core Prompts

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
| 최소 변경 강제 | `22-minimal-diff.prompt.md` |

## 3) Optional Example Packs

### Spring Boot / Backend Example Pack

이 prompt들은 AI Workflow Harness core가 아니다.
Stack-specific prompt pack을 어떻게 구성할 수 있는지 보여주는 예시로 유지한다.
`scripts/create-harness.sh --profile spring-boot`를 사용할 때 참고하거나 복사해 조정한다.
scaffold 직후 `docs/PLAN-SUMMARY.md` Implementation Baseline이 비어 있으면 아래 task prompt를 바로 실행하지 말고 `docs/BOOTSTRAP.md` §8 prompt로 Project Initialization을 먼저 진행한다.

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

## 4) Session Start Prompts

| 파일 | 역할 |
| --- | --- |
| `claude-session-start.md` | Claude Code slash command를 사용할 수 없는 환경의 fallback prompt |
| `cursor-session-start.md` | Cursor에서 현재 하네스 상태를 복원하는 session start prompt |
| `codex-session-start.md` | `AGENTS.md`를 사용할 수 없거나 수동 복원이 필요한 환경의 fallback prompt |

## 5) 사용 절차

1. 작업 유형에 맞는 prompt를 고른다.
2. `{{...}}` 변수 자리에 project 정보와 요청을 채운다.
3. AI에 붙여넣는다.
4. 결과에서 `Scope`, `Verification`, `Risk`, `Reversal Cost`를 확인한다.
5. 구현이 필요한 작업은 승인 전 수정하지 않도록 명시한다.

## 6) 유지보수 규칙

- 새 task prompt는 기존 frontmatter key를 유지한다: `id`, `purpose`, `portability`, `difficulty`, `inputs`, `output_contract`.
- Generic core prompt와 optional example pack을 섞지 않는다.
- Optional example pack은 현재 repository의 core runtime이 아니라 reusable sample로 설명한다.
- 세션 시작 절차가 바뀌면 이 문서, `claude-session-start.md`, `cursor-session-start.md`, `codex-session-start.md`, `.claude/commands/` 정합성을 함께 확인한다.
