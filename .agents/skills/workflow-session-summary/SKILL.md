---
name: "workflow-session-summary"
description: "세션 전체 요약을 출력한다. Work Done 처리 없음 — Work 완료는 /work-close로 먼저 처리할 것"
---

# workflow-session-summary

Use this skill when the user asks to invoke `/session-summary` or clearly matches this workflow intent.

## Step 0

먼저 `skills/workflow/session-summary.md`를 로드하고 그 절차를 따른다.

## Hard Stops

- `skills/workflow/session-summary.md`가 없거나 읽을 수 없으면 파일 수정, 상태 변경, commit, PR 생성, merge 전에 중단하고 누락된 canonical 파일을 보고한 뒤 사용자 확인을 받는다.
- 파일 수정, 상태 변경, commit, PR 생성, merge 전에 branch isolation, Approval Matrix, validation-before-commit/PR gate를 확인한다.
- 이 adapter에는 상세 checklist나 cascade matrix를 복제하지 않는다. 세부 판단은 canonical 절차를 따른다.

## Entry Mechanism

Codex는 `AGENTS.md`의 skill routing을 통해 이 adapter를 찾는다. Claude command 파일은 실행하지 않는다.
