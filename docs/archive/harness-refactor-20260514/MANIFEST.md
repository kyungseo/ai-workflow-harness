# Harness Refactor Backup Manifest — 2026-05-14

이 디렉터리는 Phase1 종료 후 AI Workflow Harness를 백지 재편하기 전에 만든 백업 스냅샷이다.

목적:

- 현재 등록된 작업, 예정 작업, 체크포인트, DR, Phase1 TODO를 보존한다.
- 새 `STATUS.md`와 backlog를 경량 상태 머신 기준으로 재편할 때 기존 맥락 손실을 방지한다.
- Phase2 계획 수립 시 기존 후보 작업과 결정 기록을 재검토할 수 있게 한다.

## Snapshot Contents

| Path | Source | Purpose |
| --- | --- | --- |
| `STATUS-before-refactor.md` | `docs/STATUS.md` | Phase2 planning 진입 직전 current state, active work, checkpoints, open questions, recent decisions 백업 |
| `PHASE2-backlog-before-refactor.md` | `docs/backlog/PHASE2.md` | Phase2 기능 후보와 Harness Hardening 후보 백업 |
| `decisions/` | `docs/decisions/*.md` | DR-001~010 및 template 백업 |
| `TODO-PHASE1/` | `docs/TODO/PHASE1/*.md` | Phase1 block TODO 원본 백업 |

## Use Rules

- 이 백업은 복구와 참조 목적이다.
- 새 운영 문서를 만들 때 이 파일들을 직접 수정하지 않는다.
- Phase2 본계획을 다시 세울 때 `PHASE2-backlog-before-refactor.md`와 `decisions/`를 검토한다.
- Phase1 구현 맥락이 필요할 때만 `TODO-PHASE1/`를 참조한다.

## Known Issues Preserved

백업 시점에 다음 상태 불일치가 있었다.

| Issue | Detail |
| --- | --- |
| `P2-006` status drift | `docs/STATUS.md`에서는 `Candidate`, `docs/backlog/PHASE2.md`에서는 `In Progress` |
| Mixed active work | Phase2 기능 개발, PRE 작업, Harness Hardening 항목이 한 Active Work 흐름에 섞여 있음 |
| Heavy manual | `docs/WORKFLOW-MANUAL.md`가 985줄로 일상 실행 규칙으로 쓰기에는 무거움 |
| Harness backlog mixed with product backlog | `HRN-*` 항목이 `P2-*` 기능 backlog와 동일 테이블에 있음 |

## Reversal

백지 재편이 실패하면 다음 순서로 복구한다.

1. `STATUS-before-refactor.md`를 기준으로 `docs/STATUS.md`를 복구한다.
2. `PHASE2-backlog-before-refactor.md`를 기준으로 `docs/backlog/PHASE2.md`를 복구한다.
3. DR 또는 Phase1 TODO 손실이 있으면 이 디렉터리의 `decisions/`, `TODO-PHASE1/`에서 복구한다.
