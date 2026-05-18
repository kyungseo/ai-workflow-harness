---
id: HRN-021-S3
priority: P1
status: Done
risk: Medium
scope: Work lifecycle Candidate 상태 제거
appetite: 1d
planned_start: 2026-05-19
planned_end: 2026-05-19
actual_end: 2026-05-19
related_dr: [DR-013]
related_commits: []
related_troubleshooting: []
---

# HRN-021-S3 — Work Lifecycle Candidate Removal

## Plan

`docs/retrospectives/ai-workflow-complexity-review-20260518.md`의 Simplification Candidates S3를 실행한다.
Backlog의 `Candidate` 상태는 후보 pool로 유지하고, Work 파일 lifecycle에서는 `Candidate` 상태와 category index `Candidate` 섹션을 제거한다.

반영 순서는 canonical → tool-specific → user-facing → scaffold다.

## Done Criteria

- [x] Canonical 문서가 Work lifecycle을 `Active → Done → Archived`로 설명한다.
- [x] Tool-specific command/checklist가 Candidate Work 파일 또는 Candidate index 섹션을 요구하지 않는다.
- [x] 사용자 매뉴얼이 착수 전 계획은 backlog에 남기고 Work 파일은 Active부터 생성한다고 설명한다.
- [x] Scaffold 산출물이 Candidate Work lifecycle을 생성하지 않는다.
- [x] Backlog 후보 상태의 `Candidate`는 유지된다.

## Verification

- `rg`로 live workflow surface의 Candidate Work lifecycle 잔여 문구 확인
- `git diff --check`
- `scripts/create-harness.sh --dry-run --profile generic harness-s3-review /private/tmp/harness-s3-review`

## Checkpoints

| CP | Description | Status |
|----|-------------|--------|
| 1 | Candidate Work lifecycle 잔여 표면 식별 | Done |
| 2 | Canonical/tool/user/scaffold 반영 | Done |
| 3 | 검증 및 closeout | Done |

## Discovery

- S3는 backlog의 `Candidate` 상태를 제거하는 작업이 아니다. Backlog 후보 pool은 유지하고 Work 파일 생성 시점만 Active 착수 이후로 단순화한다.
- Live workflow surface에서 Work lifecycle `Candidate` 요구 문구는 제거됐다. 남은 `Candidate` 검색 결과는 backlog 후보 의미 또는 이 Work 파일 자체의 검증 문구다.
- Generic scaffold 실제 생성 결과의 `docs/works/README.md`도 `Active/Done/Archived` lifecycle을 생성한다.
