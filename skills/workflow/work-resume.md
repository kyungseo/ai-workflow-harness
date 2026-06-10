# work-resume

Canonical workflow procedure for `/work-resume`.

이 파일은 workflow 상세 절차의 SSoT다. Tool-specific surface는 아래 adapter만 가진다.

| Tool | Adapter |
| --- | --- |
| Claude Code | `.claude/commands/work-resume.md` |
| Codex | `.agents/skills/workflow-work-resume/SKILL.md` |
| Cursor | `.cursor/rules/workflow.mdc` |

Adapter는 Step 0, hard-stop 요약, entry mechanism, fallback만 보유한다. 상세 절차, checklist, cascade 판단은 이 canonical 파일을 따른다.

## Procedure

docs/STATUS.md를 읽어줘.
Active Work 중 $ARGUMENTS 을 이어서 진행하려고 해.

먼저 실제 파일·코드 상태와 docs/STATUS.md가 일치하는지 확인하고,
불일치가 있으면 바로 수정하지 말고 보고해줘.

Active Work에 Work 파일 포인터가 있으면 해당 Work 파일도 읽어줘.
Work 파일의 Checkpoints(마지막 Done CP)와 실제 파일 상태가 일치하는지 함께 확인하고,
불일치가 있으면 함께 보고해줘.

대상 작업 상태가 `Done`이면 재개하지 말고, 후속 보정 작업을 신규 작업으로 분리할지 제안해줘.
(Active Work를 이 세션에서 완료할 예정이면 작업 후 `/work-close`를 실행한다. `/work-close`는 Work Done 처리만 수행하고 세션은 계속된다.)
Done 상태의 Work 파일이 `docs/works/{category}/`에 남아 있으면 archive 대기 상태로 보고하고, 사용자에게 archive 승인 여부를 물어봐.
승인 전에는 `git mv`를 실행하지 마.
대상 작업 상태가 `Failed`이면 재시도 계획을 새 작업으로 분리할지 제안해줘.
대상 작업이 Active Work에 없으면 backlog 후보인지 확인하고 `/work-plan` 흐름으로 계획을 세우도록 제안해줘.

불일치 처리 원칙:
- 코드·파일을 진실로 삼는다 — STATUS.md가 아닌 실제 상태가 기준
- 불일치 내용과 STATUS.md 수정 제안을 함께 보고하고, 승인 후 수정 진행
- 실패 상태로 판단되면 `Failed`로 기록하고 재시도는 신규 작업으로 분리 제안

docs/STATUS.md 변경은 즉시 수행하지 말고 Approval Matrix state rules에 맞게 먼저 제안해줘.
Active Work pointer 추가/제거는 대상 Work ID를 명시한 1줄 제안으로 충분하다.
Current phase/focus, Recent Decisions 변경은 `STATUS Update Proposal`로 보고해줘.
사용자가 명시적으로 승인한 뒤에만 STATUS.md를 수정해줘.

그다음 남은 작업 계획과 검증 방법을 제안해줘.
계획에는 현재 상태 머신 단계와 다음 전이 조건을 포함해줘.
