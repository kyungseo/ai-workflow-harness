---
name: "workflow-cross-review"
description: "선택적 cross-agent review relay를 운영한다. driver/reviewer 역할, round packet, findings, driver response, user decision gate를 표준화한다"
---

# workflow-cross-review

Use this skill only when the user explicitly invokes `/cross-review` or explicitly asks to prepare or ingest a cross-agent review relay. Do not auto-trigger merely because the user mentions "review" or "red-team" in passing. This is an optional relay, not a default gate.

## Step 0

먼저 `skills/workflow/cross-review.md`를 로드하고 그 절차를 따른다.

## Hard Stops

- `skills/workflow/cross-review.md`가 없거나 읽을 수 없으면 파일 수정, 상태 변경, commit, PR 생성, merge 전에 중단하고 누락된 canonical 파일을 보고한 뒤 사용자 확인을 받는다.
- 이 workflow는 optional review relay다. 기본 workflow gate처럼 강제하지 않는다.
- 파일 수정, 상태 변경, commit, PR 생성, merge 전에 branch isolation, Approval Matrix, validation-before-commit/PR gate를 확인한다.
- reviewer finding은 자동 적용하지 않는다. driver가 `accept / revise / defend / needs-user`로 응답하고, `needs-user`는 사용자 결정 전 진행하지 않는다.

## Entry Mechanism

Codex는 `AGENTS.md`의 skill routing을 통해 이 adapter를 찾는다. Claude command 파일은 실행하지 않는다.
Antigravity는 이 Codex adapter를 재사용한다.
