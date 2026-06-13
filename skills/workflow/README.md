# Workflow Canonical Skills

이 디렉토리는 workflow 상세 절차의 canonical SSoT다.

## Boundary

| Surface | Role |
| --- | --- |
| `skills/workflow/*.md` | 상세 절차, checklist, cascade 판단을 담는 canonical SSoT |
| `.claude/commands/*.md` | Claude Code slash command adapter |
| `.agents/skills/workflow-*/SKILL.md` | Codex skill adapter |
| `.cursor/rules/workflow.mdc` | Cursor rule adapter |

`.agents/skills/workflow-*`와 이름이 비슷하지만 역할이 다르다. `skills/workflow/`는 공통 절차 원본이고, `.agents/skills/`는 Codex가 discover하는 adapter다.

## Commands

| Command | Canonical | Claude Adapter | Codex Adapter | Summary |
| --- | --- | --- | --- | --- |
| `/session-start` | `skills/workflow/session-start.md` | `.claude/commands/session-start.md` | `.agents/skills/workflow-session-start/SKILL.md` | 세션 시작 시 STATUS.md 현재 섹션과 Done 미archive Work를 요약하고 다음 후보를 제안한다 |
| `/session-summary` | `skills/workflow/session-summary.md` | `.claude/commands/session-summary.md` | `.agents/skills/workflow-session-summary/SKILL.md` | 세션 전체 요약을 출력한다. Work Done 처리 없음 — Work 완료는 /work-close로 먼저 처리할 것 |
| `/work-select` | `skills/workflow/work-select.md` | `.claude/commands/work-select.md` | `.agents/skills/workflow-work-select/SKILL.md` | backlog에서 우선순위 후보를 비교하고 착수할 작업 1개를 추천한다 |
| `/work-register` | `skills/workflow/work-register.md` | `.claude/commands/work-register.md` | `.agents/skills/workflow-work-register/SKILL.md` | 새 작업 항목을 적절한 backlog 또는 STATUS.md에 등록한다 |
| `/work-plan` | `skills/workflow/work-plan.md` | `.claude/commands/work-plan.md` | `.agents/skills/workflow-work-plan/SKILL.md` | backlog에서 지정 항목을 찾아 Work 파일 확인, Pre-check 3종, 계획 수립을 수행하고 승인 대기한다 |
| `/work-resume` | `skills/workflow/work-resume.md` | `.claude/commands/work-resume.md` | `.agents/skills/workflow-work-resume/SKILL.md` | 중단된 Active Work를 재개한다. drift 확인 후 남은 계획을 제안한다 |
| `/work-close` | `skills/workflow/work-close.md` | `.claude/commands/work-close.md` | `.agents/skills/workflow-work-close/SKILL.md` | Work Done 처리 전용. Done Criteria 확인, status/actual_end 기입, README Active→Done, STATUS pointer 제거 제안. 세션 종료 없음 |
| `/work-debug` | `skills/workflow/work-debug.md` | `.claude/commands/work-debug.md` | `.agents/skills/workflow-work-debug/SKILL.md` | 지정 대상의 원인을 코드/로그 근거로 좁히고 최소 변경 계획을 보고한다 |
| `/work-doc` *(--with-optional)* | `skills/workflow/work-doc.md` | `.claude/commands/work-doc.md` | `.agents/skills/workflow-work-doc/SKILL.md` | 발표/보고 산출물 제작 workflow. Presentation, Report, Decision Brief 등 고품질 산출물을 생성한다. scaffold default 미포함 — `--with-optional` 로 설치 |
| `/repo-health` | `skills/workflow/repo-health.md` | `.claude/commands/repo-health.md` | `.agents/skills/workflow-repo-health/SKILL.md` | 프로젝트 워크플로우와 문서 건강 상태를 점검하고 보고한다. 옵션: --full, --cascade |
| `/record-decision` | `skills/workflow/record-decision.md` | `.claude/commands/record-decision.md` | `.agents/skills/workflow-record-decision/SKILL.md` | product·harness 의사결정을 DR 파일로 기록한다 |

## Supporting Slices

| Slice | Loaded By | Role |
| --- | --- | --- |
| `skills/workflow/repo-health-full.md` | `/repo-health --full` | full mode 전용 reading order와 Inspection Areas C/D/F |
| `skills/workflow/repo-health-cascade.md` | `/repo-health --cascade` | cascade mode 전용 Required Surface Matrix, Grep Pack, Simulation Matrix, Area G |
