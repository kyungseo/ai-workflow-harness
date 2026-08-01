---
id: CHORE-20260801-001
priority: P1
status: Archived
risk: L2
scope: v1 source repository의 maintenance-only 상태와 blocking defect exception을 명시한다
appetite: 1d
planned_start: 2026-08-01
planned_end: 2026-08-01
actual_end: 2026-08-01
related_dr: []
related_troubleshooting: []
related_work: []
---

# CHORE-20260801-001 — v1 Maintenance Freeze Disposition

## Top Summary

Owner 결정에 따라 이 v1 source를 maintenance-only로 전환한다. 기존 backlog·UF·DR·brief는 historical
operational evidence로 보존하지만 신규 feature/intake의 착수 권한을 뜻하지 않는다. v1 변경은 evidence 수집·
upgrade·안전한 운영을 막거나 data/security integrity를 위협하는 blocking defect에 한정하며 매번 별도 Owner
승인을 받는다. 이 public-intent repository에는 maintenance 상태와 exception boundary만 기록한다.

## Context Manifest

| 순서 | 파일 | 섹션 | 왜 |
| --- | --- | --- | --- |
| 1 | `docs/STATUS.md` | Current State, Recent Decisions, Next Actions | maintenance-only disposition의 public source SSoT |
| 2 | `docs/backlog/HARNESS.md` | live candidates | 보존되지만 자동 착수되지 않는 evidence pool |
| 3 | `docs/AGENT-WORKFLOW.md` | Approval Matrix | blocking exception의 기존 승인 경계 |

Trigger: 2026-08-01 Owner가 v1 maintenance-only disposition과 freeze marker를 승인했다.

## Plan

- STATUS Current focus를 maintenance-only로 바꾼다.
- Recent Decisions에 freeze 범위와 blocking exception을 기록한다.
- Next Actions에 기존 후보가 실행 authorization이 아니라는 guard를 둔다.
- backlog·DR·brief·scaffold·canonical workflow는 수정하지 않는다.

## Done Criteria

- [x] v1 maintenance-only와 blocking defect 기준이 STATUS에 명시됨
- [x] 기존 backlog·UF·DR이 보존 evidence이며 자동 착수 대상이 아님을 명시함
- [x] unapproved product roadmap·private repository·local path가 public source에 노출되지 않음
- [x] archive index와 STATUS lifecycle pointer가 정합함

## Verification

- `git diff --check`.
- `rg -n "maintenance-only|blocking defect|execution authorization" docs/STATUS.md docs/archive/docs/works/harness/CHORE-20260801-001-v1-maintenance-freeze.md`.
- secret·private path·external repository identifier가 diff에 없는지 확인.
- 기존 backlog·DR·canonical/scaffold diff 0건 확인.

## Checkpoints

| CP | Description | Status |
| --- | --- | --- |
| CP1 | Work·README·STATUS disposition | ✓ 완료 |
| CP2 | documentation validation·public disclosure check | ✓ 완료 |

## Next Actions

- ✓ STATUS marker 적용과 validation 완료.
- ✓ Claude R1B approve, 신규 blocking finding 0건.
- ✓ Owner가 Work close·archive와 upstream commit·PR·merge lifecycle bundle을 승인.

## Discovery

- 현 STATUS의 Next Actions는 maintenance freeze 전제 없이 읽으면 여전히 실행 후보로 보인다. 후보를 삭제하지
  않고 authorization boundary를 앞에 두는 최소 변경이 필요하다.
- 신규 diff에는 unapproved product roadmap·private repository·local path가 없고 기존 public history의 고유명사는
  변경하지 않았다.
- Archive: 2026-08-01 — neutral maintenance-only marker의 final review와 lifecycle 승인을 마쳐 같은 변경에서
  archive한다. forward-relevant deferred decision은 없으며 STATUS의 public disposition이 운영 SSoT로 남는다.
