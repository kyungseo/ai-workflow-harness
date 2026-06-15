---
id: CHORE-20260615-003
priority: P2
status: Done
risk: L2
scope: `docs/maintainer/VERSIONING.md`의 릴리즈 노트 템플릿을 보강해 `검증` 섹션을 필수화하고, 검증 command를 fenced code block으로 표기하는 가이드를 추가한다. `docs/GIT-WORKFLOW.md`와의 릴리즈 절차 포인터 정합만 확인하며, 새 release 메커니즘이나 i18n 전략 변경은 다루지 않는다.
appetite: 0.25d
planned_start: 2026-06-15
planned_end: 2026-06-15
actual_end: 2026-06-15
related_dr: [DR-028]
related_troubleshooting: []
related_work: []
---

# CHORE-20260615-003: 릴리즈 노트 `검증` 섹션 필수화 + command code-block guide

## Top Summary

- **목표:** release note 템플릿에 `검증` 섹션을 필수로 넣어, release evidence가 본문에서 빠지지 않게 한다.
- **왜 지금:** `v1.2.1` release note 작성 과정에서 검증 내용을 넣을지, 어디까지 적을지, 긴 command를 어떻게 보일지에 대한 판단이 세션 의존적으로 흔들렸다.
- **핵심 경계:** 새 검증 명령이나 release 절차를 추가하지 않는다. `VERSIONING.md`의 템플릿과 작성 원칙만 보강하고, 기존 `GIT-WORKFLOW.md` / `VERIFICATION-COMMANDS.md`를 SSoT로 유지한다.

## Context Manifest

| 순서 | 파일 | 섹션 | 왜 |
| --- | --- | --- | --- |
| 1 | `docs/maintainer/VERSIONING.md` | §3 Bump 절차, §5 릴리즈 노트 템플릿 | 직접 수정 대상, validation section 위치와 작성 원칙 확인 |
| 2 | `docs/GIT-WORKFLOW.md` | §3 Release Cycle, §3-1 Public Clean Baseline Gate | release note가 참조하는 verification evidence 문맥 정합 확인 |
| 3 | `docs/backlog/HARNESS.md` | `릴리즈 노트 검증 섹션 필수화 + command code-block guide` | backlog candidate 착수 기록 |

Trigger: backlog의 `릴리즈 노트 검증 섹션 필수화 + command code-block guide` candidate 착수 / user request: "versioning.md에 '검증'을 필수로 넣고, 관련 command는 코드 블럭으로 싼다".

## Scope

1. `docs/backlog/HARNESS.md`에 backlog candidate를 등록한다.
2. `docs/works/harness/README.md`와 이 Work 파일로 live tracking을 만든다. `docs/STATUS.md` 포인터는 별도 승인 없이는 수정하지 않는다.
3. `docs/maintainer/VERSIONING.md` §5 릴리즈 노트 템플릿에 `검증` 섹션을 필수로 추가한다.
4. 작성 원칙에 검증 command를 fenced code block으로 감싸고, code block 아래에는 결과를 짧게 요약한다는 규칙을 추가한다.

## Done Criteria

- [x] backlog candidate 등록 완료
- [x] `docs/works/harness/README.md` tracking 업데이트(Active 생성 후 Done으로 closeout)
- [x] `VERSIONING.md` 릴리즈 노트 템플릿에 필수 `검증` 섹션 추가
- [x] 검증 command code-block 가이드와 결과 요약 원칙 추가
- [x] `GIT-WORKFLOW.md` release-note pointer와 충돌 없음 확인
- [x] `git diff --check` clean

## Verification

- `git diff --check`
- `rg -n "릴리즈 노트 템플릿|### ✅ 검증|code block|fenced code block|GIT-WORKFLOW" docs/maintainer/VERSIONING.md docs/GIT-WORKFLOW.md docs/backlog/HARNESS.md docs/works/harness/README.md`

## Checkpoints

| CP | Description | Status |
| --- | --- | --- |
| 1 | backlog/work tracking 생성 | Done |
| 2 | `VERSIONING.md` 템플릿 + 작성 원칙 보강 | Done |
| 3 | validation 및 pointer 정합 확인 | Done |
| 4 | closeout 반영(Work/README/backlog/STATUS) | Done |

## Next Actions

- ✓ backlog candidate 등록
- ✓ Work 파일/인덱스 생성
- ✓ `VERSIONING.md` 릴리즈 노트 템플릿 보강
- ✓ `git diff --check` 및 release-note pointer 정합 확인
- ✓ `docs/STATUS.md` Recent Decisions 반영
- ○ archive 여부는 후속 승인 시 처리

## Discovery

- `docs/STATUS.md`는 현재 Active Work가 비어 있지만, 이 repo 규칙상 포인터 추가는 별도 승인 게이트가 있어 이번 실행에서는 보류한다.
- release note 검증 내용은 이미 `GIT-WORKFLOW.md` §3-1과 `VERSIONING.md` §3에 흩어져 있으므로, 이번 Work는 "새 규칙 추가"보다 "release note 표현 규칙 고정"에 가깝다.
- `GIT-WORKFLOW.md`의 release-note pointer는 그대로 유효했다. 이번 변경은 pointer 대상인 `VERSIONING.md` 템플릿만 보강하므로 추가 cascade 수정은 필요하지 않았다.
- 후속 정교화로 "`검증` 섹션의 command는 예시가 아니라 해당 릴리즈의 실제 최종 evidence set 전체"라는 기준을 채택했다. 대신 탐색·디버깅·재시도 명령은 제외해 릴리즈 노트가 승인 근거 중심으로 유지되게 한다.
- closeout 시 `STATUS.md` Active Work는 애초에 비어 있었으므로 pointer add/remove churn 없이 `Recent Decisions`만 갱신한다. 이 Work는 archive pending `Done` 상태로 유지한다.
