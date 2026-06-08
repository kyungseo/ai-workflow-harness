---
name: "workflow-session-start"
description: "세션 시작 시 STATUS.md 현재 섹션과 Done 미archive Work를 요약하고 다음 후보를 제안한다"
---

# workflow-session-start

Use this skill when the user asks to invoke `/session-start` or clearly matches this workflow intent.

## Step 0

먼저 `skills/workflow/session-start.md`를 로드하고 그 절차를 따른다.

## Hard Stops

- `skills/workflow/session-start.md`가 없거나 읽을 수 없으면 파일 수정, 상태 변경, commit, PR 생성, merge 전에 중단하고 누락된 canonical 파일을 보고한 뒤 사용자 확인을 받는다.
- 파일 수정, 상태 변경, commit, PR 생성, merge 전에 branch isolation, Approval Matrix, validation-before-commit/PR gate를 확인한다.
- 이 adapter에는 상세 checklist나 cascade matrix를 복제하지 않는다. 세부 판단은 canonical 절차를 따른다.

## Entry Mechanism

Codex는 `AGENTS.md`의 skill routing을 통해 이 adapter를 찾는다. Claude command 파일은 실행하지 않는다.
