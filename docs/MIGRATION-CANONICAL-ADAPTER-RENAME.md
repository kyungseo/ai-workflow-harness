# Canonical Adapter And Command Rename Migration

이 문서는 canonical workflow 전환과 no-alias command rename을 적용한 source repo 변경을 target repo가 수용할 때 참고하는 migration note다.

## Summary

- workflow 상세 절차는 `skills/workflow/*.md`가 canonical SSoT다.
- `.claude/commands/*.md`, `.agents/skills/workflow-*/SKILL.md`, `.cursor/rules/workflow.mdc`는 hybrid adapter다.
- legacy runtime alias는 제공하지 않는다. old command는 실행 surface에 남지 않고, 이 문서의 mapping으로만 안내한다.
- source repo는 변경된 framework surface와 migration note를 제공한다. 이미 scaffold된 target repo는 자기 repository에서 별도 migration Work로 수용한다.

## Command Mapping

| Old | New | Codex Skill |
| --- | --- | --- |
| `/start` | `/session-start` | `workflow-session-start` |
| `/done` | `/session-summary` | `workflow-session-summary` |
| `/pick` | `/work-select` | `workflow-work-select` |
| `/register` | `/work-register` | `workflow-work-register` |
| `/work` | `/work-plan` | `workflow-work-plan` |
| `/resume` | `/work-resume` | `workflow-work-resume` |
| `/close` | `/work-close` | `workflow-work-close` |
| `/debug` | `/work-debug` | `workflow-work-debug` |
| `/doc` | `/work-doc` | `workflow-work-doc` |
| `/health` | `/repo-health` | `workflow-repo-health` |
| `/record-decision` | `/repo-decision` | `workflow-repo-decision` |

## New Canonical Files

`create-harness.sh --check <target>`는 target manifest에 이미 기록된 파일만 비교한다. 삭제되었거나 rename된 old file은 `source-missing`으로 보고할 수 있지만, old target manifest에 없던 신규 path는 자동으로 발견하지 못한다.

따라서 target migration에서는 아래 신규 canonical files를 명시적으로 추가해야 한다:

- `skills/workflow/README.md`
- `skills/workflow/session-start.md`
- `skills/workflow/session-summary.md`
- `skills/workflow/work-select.md`
- `skills/workflow/work-register.md`
- `skills/workflow/work-plan.md`
- `skills/workflow/work-resume.md`
- `skills/workflow/work-close.md`
- `skills/workflow/work-debug.md`
- `skills/workflow/work-doc.md`
- `skills/workflow/repo-health.md`
- `skills/workflow/repo-decision.md`

## Target Migration Checklist

1. source repo에서 `scripts/create-harness.sh --check <target>`를 실행한다.
2. `source-missing`으로 보고된 old command/skill file은 rename/delete 후보로 판단한다.
3. 위에 열거한 신규 canonical files를 추가한다.
4. old Claude command files를 신규 adapter files로 교체한다.
5. old Codex skill directories를 신규 `workflow-{new}` adapter directories로 교체한다.
6. `.cursor/rules/workflow.mdc`를 업데이트한다.
7. old command names를 언급하는 target prompts/docs를 업데이트한다.
8. command/skill discovery 검증 전 fresh AI session을 열거나 workspace를 reload한다.
9. target repository의 validation commands를 실행한다.

## AI Session Cache Note

이미 열려 있는 AI session은 rename 전 command 또는 skill inventory를 cache하고 있을 수 있다.

- Claude Code session은 old slash command 목록을 계속 알고 있을 수 있다.
- Codex session은 old `.agents/skills/workflow-*` skill 목록을 계속 보여줄 수 있다.
- Cursor workspace도 rule reload 시점에 따라 old intent hint가 남을 수 있다.

따라서 rename 적용 직후 검증은 fresh AI session 또는 workspace reload 후 수행한다.
기존 session에서 이어서 작업해야 한다면 old command/skill을 호출하지 말고, 새 adapter path 또는 canonical path를 직접 열어 확인한다.

target이 harness policy를 의도적으로 fork하는 경우가 아니라면 `/start`, `/done`, `/work`, `/close` 등 old commands를 runtime alias로 남기지 않는다.

## Customized Target Note

이미 적용된 target repo는 workflow surface 외에 product-specific command, skill, rule을 가질 수 있다. 이 경우 migration은 scaffold 재적용이 아니라 selective framework migration으로 수행한다.

- `AGENTS.md`, `CLAUDE.md`, `.claude/commands/`, `.agents/skills/`, `.cursor/rules/`를 통째로 덮어쓰지 않는다.
- old workflow command/skill만 새 이름으로 교체한다.
- product-specific commands/skills는 보존한다. 예: `/create-deck`, `/review-deck`, `/export-pdf`, `/generate-architecture-slide` 같은 target-local product skill.
- root `skills/workflow/*.md` canonical은 target-local `skills/{product-skill}.md`와 병존한다.
- target에 `.harness/manifest.json`이 없거나 old manifest가 없으면 `--check` 결과만으로 migration 범위를 판단하지 말고, command/skill/rule inventory를 먼저 작성한다.
