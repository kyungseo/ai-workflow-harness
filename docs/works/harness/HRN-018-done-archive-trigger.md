---
id: HRN-018
priority: P1
status: Done
risk: Low
scope: DR-016 Done/Archived 분리와 archive trigger를 command/rule/manual/index에 반영
appetite: 1d
planned_start: 2026-05-18
planned_end: 2026-05-18
actual_end: 2026-05-18
related_dr: [DR-016]
related_commits: []
related_troubleshooting: []
---

## Plan

`/done`이 Work 파일을 즉시 archive로 이동하던 흐름을 분리한다.
Done 처리는 완료 검증과 상태 정리이고, Archive 처리는 명시 승인 또는 `/start`·`/resume` trigger 후 수행하도록 정렬한다.

## Done Criteria

- [x] `.claude/commands/done.md`가 Done 처리와 Archive 처리를 분리
- [x] `.claude/commands/start.md`와 `resume.md`가 archive 대기 Work를 보고
- [x] `AGENTS.md`와 `.cursor/rules/workflow.mdc`가 즉시 `git mv`를 지시하지 않음
- [x] `docs/harness-protocol/03-work-items-and-naming.md` Work File Rules에 lifecycle/index/archive trigger 반영
- [x] `docs/works/{category}/README.md` index가 Candidate/Active/Done/Archived 구조로 정리됨
- [x] 현재 HRF-002 Done drift가 index/backlog/STATUS에서 정리됨

## Verification

```bash
rg "archive 대기|Archive 처리|status: Archived|Done \\(archive pending\\)" .claude/commands AGENTS.md .cursor/rules docs/harness-protocol docs/works
```

## Checkpoints

| CP | Description | Status |
|----|-------------|--------|
| 1 | Done/Archive command 분리 | Done |
| 2 | Start/resume archive trigger 반영 | Done |
| 3 | Work File Rules와 index 구조 반영 | Done |
| 4 | HRF-002 live drift 정리 | Done |

## Discovery

- HRF-002 Work 파일은 리뷰 결과 append와 후속 확인이 끝날 때까지 archive하지 않고 Done (archive pending)으로 둔다.
- Archive 수행 시에는 `status: Archived`를 먼저 기록한 뒤 `git mv`해야 archive 위치의 파일 상태가 올바르게 남는다.
