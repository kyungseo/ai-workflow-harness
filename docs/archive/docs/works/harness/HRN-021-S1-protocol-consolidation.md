---
id: HRN-021-S1
priority: P1
status: Archived
risk: L2
scope: AI Workflow simplification S1 — 6개 상세 protocol 문서를 HARNESS-PROTOCOL.md로 단일 통합
appetite: 0.5d
planned_start: 2026-05-19
planned_end:
actual_end: 2026-05-19
related_dr: []
related_commits: []
related_troubleshooting: []
---

## Plan

`docs/retrospectives/ai-workflow-complexity-review-20260518.md`의 Simplification Candidates S1을 실행한다.

현재 `docs/HARNESS-PROTOCOL.md`는 hub이고, 실제 상세 규칙은 6개 세부 protocol 파일에 나뉘어 있다.
S1은 세션 중 탐색 비용과 canonical source 분산을 줄이기 위해 6개 상세 문서를 `docs/HARNESS-PROTOCOL.md`의 섹션으로 흡수한다.

`docs/AGENT-WORKFLOW.md`는 세션 시작 문서로 계속 얇게 유지한다.
S6 `/health --cascade` checklist화와 S3 Candidate lifecycle 제거는 이번 범위에 포함하지 않는다.

## Done Criteria

- [x] `docs/HARNESS-PROTOCOL.md`가 6개 상세 protocol의 내용을 단일 canonical 문서로 포함한다.
- [x] 이전 `docs/harness-protocol/` 상세 문서 참조가 live AI/tool/scaffold surface에서 제거되거나 `docs/HARNESS-PROTOCOL.md`로 대체된다.
- [x] `docs/AGENT-WORKFLOW.md`가 상세 protocol 로드 기준을 단일 문서 기준으로 설명한다.
- [x] Claude/Codex/Cursor command/rule/prompt surface가 단일 protocol 경로와 충돌하지 않는다.
- [x] `scripts/create-harness.sh` scaffold 산출물이 단일 protocol 구조를 생성한다.
- [x] Work 파일과 STATUS/Work index lifecycle pointer가 `HRN-021-S1` 상태를 반영한다.
- [x] `git diff --check` 통과.
- [x] scaffold dry-run 또는 temp scaffold 검증 통과.

## Verification

```bash
rg -n "docs/harness-protocol|harness-protocol/|01-session|02-context|03-work|04-document|05-triggers|06-recovery" \
  AGENTS.md CLAUDE.md README.md docs .claude .cursor prompts scripts
git diff --check
scripts/create-harness.sh --dry-run --profile generic harness-s1-review /private/tmp/harness-s1-review
```

## Checkpoints

| CP | Description | Status |
|----|-------------|--------|
| 1 | Work 파일 생성 및 Active pointer 추가 | Done |
| 2 | 6개 protocol 상세 문서 HARNESS-PROTOCOL.md로 통합 | Done |
| 3 | canonical/tool/user/scaffold 참조 정렬 | Done |
| 4 | Verification 및 diff review | Done |

## Discovery

### 착수 메모 (2026-05-19)

사용자 승인에 따라 HRN-021 simplification series의 S1을 시작한다.
S4, S2, S5는 Done archive pending 상태이며, S1 완료 전 참조 대기 상태다.

### 검증 메모 (2026-05-19)

6개 `docs/harness-protocol/` 상세 문서를 `docs/HARNESS-PROTOCOL.md`로 흡수하고 live AI/tool/user/scaffold surface의 경로를 단일 protocol 기준으로 정렬했다.
`rg` 기준 옛 `docs/harness-protocol/` 참조는 이 Work 파일의 검증 문구에만 남아 있다.
`git diff --check`, scaffold dry-run, temp scaffold 생성 및 temp target stale reference 검색을 통과했다.

### 영향 검토 반영 메모 (2026-05-19)

S1 영향 검토 결과 P0/P1 없음.
P2로 `prompts/claude-session-start.md`의 `HARNESS-PROTOCOL.md` 중복 항목을 단일 상세 protocol 설명으로 정리했고, 파일 삭제 후 남은 빈 `docs/harness-protocol/` 로컬 디렉토리를 제거했다.
재검증 결과 live surface의 옛 상세 protocol 경로는 이 Work 파일의 검증 기록에만 남아 있다.

### Close 메모 (2026-05-19)

Done Criteria 충족 및 `git diff --check` 통과를 확인했다.
STATUS Active Work pointer는 제거하고, Work index는 Done archive pending으로 이동한다.
