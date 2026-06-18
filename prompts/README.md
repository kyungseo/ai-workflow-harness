# Prompt Fallback Guide

이 디렉토리는 세션 시작 fallback prompt만 live surface로 유지한다.
반복 workflow는 각 도구의 command/adapter를 먼저 사용하고, command나 adapter를 사용할 수 없는 환경에서만 이 fallback prompt를 붙여넣는다.

## 1) Live Files

| 파일 | 역할 |
| --- | --- |
| `claude-session-start.md` | Claude Code slash command를 사용할 수 없는 환경의 fallback prompt |
| `codex-session-start.md` | `AGENTS.md`나 Codex workflow adapter를 사용할 수 없을 때 수동 복원에 쓰는 fallback prompt (Antigravity도 동일 surface를 쓰므로 이 fallback을 공유) |
| `cursor-session-start.md` | Cursor에서 현재 하네스 상태를 복원하는 session start prompt |

## 2) Prompt vs Command

| 구분 | 사용 위치 | 역할 |
| --- | --- | --- |
| `.claude/commands/` | Claude Code | `/session-start`, `/work-select`, `/work-plan`, `/work-close`, `/session-summary` 같은 반복 workflow 실행 |
| `.agents/skills/workflow-*` | Codex / Antigravity | canonical workflow procedure를 호출하는 adapter (Antigravity가 Codex surface 재사용) |
| `.cursor/rules/workflow.mdc` | Cursor | workflow intent routing |
| `prompts/*-session-start.md` | 여러 AI 도구 | command/adapter를 사용할 수 없을 때 세션을 시작하는 fallback |

Command와 adapter는 repo-local workflow를 실행한다.
이 디렉토리의 live prompt는 session-start fallback만 담당한다.

## 3) Archived Task Prompt Examples

기존 generic task prompt와 Spring/profile prompt 예시는 live prompt library에서 제외하고 `docs/archive/prompts/`에 보존한다.

- `scripts/create-harness.sh --with-optional`은 더 이상 generic `.prompt.md` bundle을 scaffold target에 복사하지 않는다.
- `scripts/create-harness.sh --profile spring-boot`은 더 이상 stack/profile `.prompt.md` bundle을 scaffold target에 복사하지 않는다.
- Archive 파일은 역사적 참고용이다. 일반 작업 flow나 scaffold target surface로 취급하지 않는다.

## 4) 사용 절차

1. 가능하면 도구별 command/adapter로 세션을 시작한다.
2. command/adapter를 사용할 수 없으면 해당 `*-session-start.md` 파일을 연다.
3. prompt 안의 repo path, branch, active work, review gate 정보를 현재 상태에 맞게 채운다.
4. AI 도구에 붙여넣고, 첫 응답에서 loaded docs와 현재 상태 요약을 확인한다.

## 5) 유지보수 규칙

- 이 디렉토리의 live file은 README와 session-start fallback prompt로 제한한다.
- 새 task prompt example은 live `prompts/`에 추가하지 않는다. 필요하면 별도 Work에서 example pack 정책을 먼저 정한다.
- 세션 시작 절차가 바뀌면 이 문서, `claude-session-start.md`, `cursor-session-start.md`, `codex-session-start.md`, `.claude/commands/`, `.agents/skills/workflow-*` 정합성을 함께 확인한다.
