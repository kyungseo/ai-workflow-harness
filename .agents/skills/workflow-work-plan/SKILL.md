---
name: "workflow-work-plan"
description: "backlog에서 지정 항목을 찾아 Work 파일 확인, Pre-check 3종, 계획 수립을 수행하고 승인 대기한다"
---

# workflow-work-plan

Use this skill when the user asks to invoke `/work-plan`, or uses intent phrases like "작업 계획을 세우자", "work 파일 작성하자", "작업을 시작하자", "플랜 짜줘", or clearly matches this workflow intent. Identify the target task from conversation context (recent Work ID, backlog item, or topic under discussion); if no specific task is identifiable, surface `/work-select` first.

## Step 0

먼저 `skills/workflow/work-plan.md`를 로드하고 그 절차를 따른다.

## Hard Stops

- `skills/workflow/work-plan.md`가 없거나 읽을 수 없으면 파일 수정, 상태 변경, commit, PR 생성, merge 전에 중단하고 누락된 canonical 파일을 보고한 뒤 사용자 확인을 받는다.
- 파일 수정, 상태 변경, commit, PR 생성, merge 전에 branch isolation, Approval Matrix, validation-before-commit/PR gate를 확인한다.
- 이 adapter에는 상세 checklist나 cascade matrix를 복제하지 않는다. 세부 판단은 canonical 절차를 따른다.

## Entry Mechanism

Codex는 `AGENTS.md`의 skill routing을 통해 이 adapter를 찾는다. Claude command 파일은 실행하지 않는다.
