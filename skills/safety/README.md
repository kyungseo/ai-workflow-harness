# skills/safety/

Stack-agnostic safety rule layer의 canonical SSoT 디렉토리다.

**이 파일들은 canonical rule document다 — `.agents/skills/`의 호출형 Codex skill이 아니다.**
workflow(`skills/workflow/`)가 호출형 procedure의 SSoT이듯, 이 디렉토리는 always/path-scoped **적용형 rule**의 SSoT다.
언어는 DR-007에 따라 English Only다(도구가 instruction으로 직접 소비하는 표면).

| Canonical | 층 | 적용 |
| --- | --- | --- |
| `safety-critical.md` | A1 실행 안전 (destructive/privileged/secret) | always — 모든 경로 |
| `infra.md` | A2 infra 안전 (infra/deploy/environment) | path-scoped — infra 파일 작업 시 |

## Tool Adapters (thin projection)

Adapter는 canonical load directive + fail-closed bootstrap guard만 보유한다. guard 전문은 이 디렉토리만 보유한다.

| Tool | A1 | A2 |
| --- | --- | --- |
| Claude Code | `.claude/rules/safety-critical.md` (`paths: "**"`) | `.claude/rules/infra.md` (path-scoped) |
| Cursor | `.cursor/rules/safety-critical.mdc` (`alwaysApply: true`) | `.cursor/rules/infra.mdc` (globs) |
| Codex / Antigravity | root `AGENTS.md` Safety Rule Layer 절 (session start 로드) | 동일 절 (infra 작업 시 조건부 로드) |

정합 검증: `bash scripts/tests/check-rule-surface-parity.sh`
