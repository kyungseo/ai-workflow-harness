---
description: "선택적 cross-agent review relay를 운영한다. driver/reviewer 역할, round packet, findings, driver response, user decision gate를 표준화한다"
disable-model-invocation: true
---

# /cross-review

이 파일은 Claude Code slash command adapter다. 상세 절차의 SSoT는 `skills/workflow/cross-review.md`다.

## Step 0

먼저 `skills/workflow/cross-review.md`를 로드하고 그 절차를 따른다.

## Hard Stops

- `skills/workflow/cross-review.md`가 없거나 읽을 수 없으면 파일 수정, 상태 변경, commit, PR 생성, merge 전에 중단하고 누락된 canonical 파일을 보고한 뒤 사용자 확인을 받는다.
- 이 workflow는 optional review relay다. 기본 workflow gate처럼 강제하지 않는다.
- 파일 수정, 상태 변경, commit, PR 생성, merge 전에 branch isolation, Approval Matrix, validation-before-commit/PR gate를 확인한다.
- reviewer finding은 자동 적용하지 않는다. driver가 `accept / revise / defend / needs-user`로 응답하고, `needs-user`는 사용자 결정 전 진행하지 않는다.

## Entry Mechanism

Claude Code에서 `/cross-review` slash command로 호출된다. 전달된 인자는 canonical 절차의 `$ARGUMENTS`로 해석한다.
