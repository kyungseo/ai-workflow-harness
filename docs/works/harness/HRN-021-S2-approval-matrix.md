---
id: HRN-021-S2
priority: P1
status: Done
risk: L2
scope: AI Workflow simplification S2 — Scope Approval, State Update Gate, Commit Gate를 Approval Matrix로 통합
appetite: 0.5d
planned_start: 2026-05-19
planned_end:
actual_end: 2026-05-19
related_dr: []
related_commits: []
related_troubleshooting: []
---

## Plan

`docs/retrospectives/ai-workflow-complexity-review-20260518.md`의 Simplification Candidates S2를 실행한다.

현재 승인 규칙은 Scope And Commit Approval, State Update Gate, Commit Gate가 각자 존재해서 "언제 멈춰야 하는가"를 여러 곳에서 다시 판단하게 만든다.
이번 작업은 세 규칙을 Risk Gate와 정렬한 단일 Approval Matrix로 통합한다.

S5 manual 역할 재정의, S1 protocol 통합, S6 health checklist화, S3 Candidate 제거는 이번 범위에 포함하지 않는다.

## Done Criteria

- [x] `docs/AGENT-WORKFLOW.md`가 Approval Matrix를 canonical gate로 설명한다.
- [x] `docs/HARNESS-QUICK-REFERENCE.md`가 같은 기준을 짧게 반영한다.
- [x] `docs/harness-protocol/01-session-state-machine.md`, `03-work-items-and-naming.md`, `06-recovery-and-validation.md`의 State Update/Commit 설명이 Approval Matrix와 충돌하지 않는다.
- [x] Claude/Codex/Cursor entrypoint, command, rule, prompt surface의 approval 문구가 충돌하지 않는다.
- [x] `/work`, `/pick`, `/close`, scaffold Stop hook 흐름이 Approval Matrix와 충돌하지 않는다.
- [x] Work 파일과 STATUS/Work index lifecycle pointer가 `HRN-021-S2` 상태를 반영한다.
- [x] `git diff --check` 통과.

## Verification

```bash
rg -n "State Update Gate|Commit Gate|Scope And Commit Approval" \
  AGENTS.md CLAUDE.md README.md .claude .cursor prompts \
  docs/AGENT-WORKFLOW.md docs/HARNESS-PROTOCOL.md docs/HARNESS-QUICK-REFERENCE.md \
  docs/WORKFLOW-MANUAL.md docs/harness-protocol scripts
rg -n "Approval Matrix" \
  docs/AGENT-WORKFLOW.md docs/HARNESS-QUICK-REFERENCE.md docs/harness-protocol \
  docs/WORKFLOW-MANUAL.md AGENTS.md CLAUDE.md .claude .cursor prompts
scripts/create-harness.sh --dry-run --profile generic harness-s2-review /private/tmp/harness-s2-review
git diff --check
```

## Checkpoints

| CP | Description | Status |
|----|-------------|--------|
| 1 | Work 파일 생성 및 Active pointer 추가 | Done |
| 2 | Canonical/quick reference/protocol Approval Matrix 통합 | Done |
| 3 | Claude/Codex/Cursor command/rule/prompt surface 정렬 | Done |
| 4 | Verification 및 diff review | Done |

## Discovery

### 착수 메모 (2026-05-19)

사용자 요청에 따라 HRN-021 simplification series 중 S4 다음 단계인 S2를 진행한다.
STATUS Active Work에는 기존 PRE-B를 유지하고 `HRN-021-S2`를 병렬 Active Work로 추가한다.

### 검증 메모 (2026-05-19)

실행 표면 기준 `State Update Gate`, `Commit Gate`, `Scope And Commit Approval` 잔여 표현 없음.
남은 과거 용어는 troubleshooting, archive, retrospective, backlog, 현재 Work 파일의 이력/작업 설명 문맥에만 있다.

### Review 반영 메모 (2026-05-19)

사용자 요청으로 workflow/process 영향 리뷰 후 P1/P2 보정 반영.
`/work` 위험도 표에 harness/workflow 기본 L2를 명시하고, `/close`의 Layer 용어를 Approval Matrix state detail로 정렬했다.
`/pick`, 사용자 매뉴얼 표현, scaffold Stop hook 생성 문자열도 새 Matrix 기준으로 정리했다.

### Close 메모 (2026-05-19)

Done Criteria 충족 및 `git diff --check` 통과를 확인했다.
STATUS Active Work pointer는 제거하고, Work index는 Done archive pending으로 이동한다.
