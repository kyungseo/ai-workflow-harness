---
description: "product·harness 의사결정을 DR 파일로 기록한다"
argument-hint: "[decision-topic]"
disable-model-invocation: true
---

# /record-decision

이 파일은 Claude Code slash command adapter다. 상세 절차의 SSoT는 `skills/workflow/record-decision.md`다.

## Step 0

먼저 `skills/workflow/record-decision.md`를 로드하고 그 절차를 따른다.

## Hard Stops

- `skills/workflow/record-decision.md`가 없거나 읽을 수 없으면 파일 수정, 상태 변경, commit, PR 생성, merge 전에 중단하고 누락된 canonical 파일을 보고한 뒤 사용자 확인을 받는다.
- 파일 수정, 상태 변경, commit, PR 생성, merge 전에 branch isolation, Approval Matrix, validation-before-commit/PR gate를 확인한다.
- 이 adapter에는 상세 checklist나 cascade matrix를 복제하지 않는다. 세부 판단은 canonical 절차를 따른다.

## Entry Mechanism

Claude Code에서 `/record-decision` slash command로 호출된다. 전달된 인자는 canonical 절차의 `$ARGUMENTS`로 해석한다.
