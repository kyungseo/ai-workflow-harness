---
id: CHORE-20260615-005
priority: P2
status: Archived
actual_end: 2026-06-15
risk: L2
scope: `/work-brief` canonical 절차에 brief→DR 핸드오프 hook을 명시 강화한다. brief가 Accepted-ready 결정으로 수렴하면 `/record-decision`을 제안(강제 아님)하도록 Phase 5/6을 sharpen한다. adapter는 thin pointer라 변경하지 않는다.
appetite: 0.1d
planned_start: 2026-06-15
planned_end: 2026-06-15
related_dr: [DR-007]
related_troubleshooting: []
related_work: [CHORE-20260615-004]
---

# CHORE-20260615-005: Brief→DR Handoff Hook (B-lite)

## Top Summary

- **목표:** brief 작업에서 DR-worthy 결정이 수렴했을 때 누락되지 않도록, `/work-brief` canonical에 "Accepted-ready 수렴 시 `/record-decision` 제안(강제 아님)" hook을 명시한다.
- **왜:** brief는 본질적으로 pre-decision이라 수렴된 결정이 brief에 묻히는 silent drift(manual-first 약점)가 가능하다. 단 강제 trigger는 premature crystallization·진공 최적화 위험이 있어 soft prompt로만 둔다.
- **경계:** 새 command·새 protocol trigger·hard gate 신설하지 않는다. canonical 1파일 문구 강화만 한다.

## Scope

1. `skills/workflow/work-brief.md` Phase 6 follow-up 보고 항목을 brief→DR 조건부 제안으로 sharpen.
2. 같은 파일 Phase 5 Validation Checklist에 DR 수렴 점검 1행 추가.

## Non-Goals

- adapter(`.claude/commands/work-brief.md`, `.agents/skills/workflow-work-brief/SKILL.md`, `.cursor/rules/workflow.mdc`) 변경 — thin pointer라 절차 detail은 canonical에만 둔다.
- HARNESS-PROTOCOL trigger family 추가, 자동/hard gate화.
- brief→DR 전환 규칙 자체의 DR 기록(향후 실제 전환 사례 누적 시 재판단).
- `docs/STATUS.md` Active pointer 추가(승인 게이트, close 시 Recent Decisions 제안).

## Files

| 파일 | 계획 |
| --- | --- |
| `skills/workflow/work-brief.md` | Phase 5 checklist 1행 추가 + Phase 6 item 3 강화 |
| `docs/works/harness/CHORE-20260615-005-brief-dr-handoff.md` | Work SSoT |
| `docs/works/harness/README.md` | Active row 추가 |

## Done Criteria

- [x] `work-brief.md` Phase 6에 brief→DR 조건부 제안(강제 아님) 문구 반영
- [x] `work-brief.md` Phase 5에 DR 수렴 점검 checklist 1행 추가
- [x] adapter 무변경 확인 (mirror parity PASS 유지)
- [x] `git diff --check`, `check-shipped-dr-closure.sh` 통과

## Verification

```bash
git diff --check
bash scripts/tests/check-surface-mirror-parity.sh
bash scripts/tests/check-shipped-dr-closure.sh
```

## Risk / Reversal Cost

| Item | Assessment |
| --- | --- |
| Risk level | L2 — harness workflow surface(canonical) |
| Reversal cost | Low — 단일 문서 문구 강화, 단순 revert |
| Main risk | soft hook이 강제처럼 읽혀 premature DR을 유도하는 것 → "강제 아님" 명시로 완화 |

## Approval / State

| Item | Status |
| --- | --- |
| 위험도 | L2 |
| Branch Isolation | PASS — `feature/chore-20260615-005-brief-dr-handoff` |
| PLAN 영향 | 없음 |
| STATUS proposal | close 시 Recent Decisions 1행 제안 예정 |
| State machine | EXECUTE → VALIDATE → Done (closeout) |

## Discovery

- 2026-06-15: B-lite 채택 근거 — 순수 사용자 판단(A)은 silent drift, 자동/hard trigger(B-hard)는 premature crystallization·진공 최적화. soft prompt(B-lite)가 균형점. `harness-workflow-engine-vs-manual-first` brief의 selective-hardening 논리와 정합.
- 2026-06-15: 조사 결과 canonical Phase 6에 이미 "DR 필요 여부" follow-up hook 존재 → 신설이 아니라 sharpen으로 충분. adapter는 thin이라 canonical-only로 종결.
- 2026-06-15: closeout(PR #198) 후 archive 처리. `status: Archived`로 전환·`docs/archive/docs/works/harness/`로 이동, live index 제거·archive-side 등재.
