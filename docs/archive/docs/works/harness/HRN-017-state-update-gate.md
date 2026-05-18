---
id: HRN-017
priority: P1
status: Archived
risk: Low
scope: DR-015 2계층 State Update Gate를 canonical workflow와 tool surface에 반영
appetite: 1d
planned_start: 2026-05-18
planned_end: 2026-05-18
actual_end: 2026-05-18
related_dr: [DR-015]
related_commits: []
related_troubleshooting: []
---

## Plan

DR-015의 Layer 1 / Layer 2 gate를 agent가 실제로 읽는 표면에 반영한다.
`docs/STATUS.md`는 dashboard로 유지하고, Work 파일 checkpoint/discovery 업데이트와 Work Done 전환을 구분한다.

## Done Criteria

- [x] `docs/AGENT-WORKFLOW.md`에 State Update Gate 반영
- [x] `docs/harness-protocol/01-session-state-machine.md`와 `06-recovery-and-validation.md`에 Layer 1/2 gate 반영
- [x] `.claude/commands/`의 work/resume/done/register/pick/health 계열에 State Update Gate 반영
- [x] `AGENTS.md`와 `.cursor/rules/*.mdc`에 State Update Gate 반영
- [x] `prompts/*session-start.md`와 `scripts/create-harness.sh`의 신규 프로젝트 안내 반영

## Verification

```bash
rg "State Update Gate|Layer 1|Layer 2" docs/AGENT-WORKFLOW.md docs/harness-protocol .claude/commands AGENTS.md .cursor/rules prompts scripts/create-harness.sh
```

## Checkpoints

| CP | Description | Status |
|----|-------------|--------|
| 1 | Canonical workflow/protocol 반영 | Done |
| 2 | Claude command 반영 | Done |
| 3 | Codex/Cursor/prompt/scaffold 반영 | Done |

## Discovery

- `STATUS Update Proposal` 문구는 Phase/focus/Recent Decisions 같은 고영향 `STATUS.md` 변경에는 계속 유효하다.
- Active Work pointer 추가/제거는 대상 Work ID를 명시한 1줄 State Update 제안으로 낮춘다.
- DR-015 2계층 State Update Gate를 commands/AGENTS.md/workflow.mdc/harness-protocol 모든 실행 표면에 반영 완료.
  HRF-002 심층 검증 과정에서 추가 누락 없음 확인. 2026-05-18 archive.
