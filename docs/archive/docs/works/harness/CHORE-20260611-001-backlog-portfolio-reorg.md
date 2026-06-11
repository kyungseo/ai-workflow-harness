---
id: CHORE-20260611-001
priority: P1
status: Archived
risk: L2
scope: HARNESS backlog를 이번 주 하네스 마무리와 다음 주 실제 product scaffold 운영 전환 기준으로 portfolio 재구성한다. 기존 detail은 보존하되 오래된 PR #93 이후 재검증 항목은 검증 spine의 regression asset으로 흡수하고, onboarding guide/workflow manual 전면 재작성 필요성을 user-facing docs rewrite 클러스터에 반영한다.
appetite: 0.5d
planned_start: 2026-06-11
planned_end: 2026-06-11
actual_end: 2026-06-11
related_dr: [DR-007, DR-021, DR-023, DR-031, DR-033]
related_troubleshooting: []
related_work: [CHORE-20260610-010, CHORE-20260610-011]
---

# CHORE-20260611-001: Harness backlog portfolio 재구성

## Top Summary

- **목표:** `docs/backlog/HARNESS.md`를 단순 후보 목록이 아니라 "하네스 큰 작업 마무리 → 실제 product 적용" 전환 로드맵으로 재구성한다.
- **사용자 추가 조건:** README 전면 재작성 때의 기준과 유사하게 `docs/SCAFFOLD-ONBOARDING-GUIDE.md`, `docs/WORKFLOW-MANUAL.md` 등 user-facing docs도 전면 재작성 후보로 반영한다.
- **판단:** PR #93 이후 전체 Work 파일을 하나씩 재검증하는 것은 비용 대비 효율이 낮으므로 생략하고, 문제가 생기면 후속 조정한다. 대신 대표 regression asset을 검증 spine에 넣는다.

## Scope / Plan

1. HARNESS backlog를 관심사별 portfolio cluster로 재분류한다.
2. Summary table을 cluster 목표와 우선순위에 맞게 재배열한다.
3. `Scaffold/tool-surface regression alignment 체계화`의 오래된 PR #93 이후 재검증 과제를 현재 시점에 맞게 재해석한다.
4. user-facing docs rewrite 항목을 명확히 추가/확장한다.
5. `docs/STATUS.md` Next Actions를 새 cluster 순서와 이번 주 cutoff에 맞게 갱신한다.

## Done Criteria

- [x] HARNESS backlog가 검증 spine, adopter 전환, user-facing docs rewrite, IA diet, enforcement, lifecycle hygiene, future/options로 분류됨.
- [x] 기존 backlog detail의 의미가 누락되지 않고 재배치 또는 흡수 근거가 남음.
- [x] STATUS Next Actions가 새 우선순위와 다음 작업 선택 기준을 반영함.
- [x] `git diff --check` 및 shipped DR closure check 통과.

## Verification

- `git diff --check`
- `bash scripts/tests/check-shipped-dr-closure.sh`
- `rg` 기반으로 새/기존 항목 제목 정합 확인

## Risk / Reversal

- **리스크:** 백로그는 실행 계획의 입력이므로, 분류가 너무 확정적으로 보이면 실제 Work 계획 시 의사결정 여지를 줄일 수 있다.
- **완화:** backlog를 "확정 순서"가 아니라 "의견 있는 portfolio view"로 명시하고, 각 Work 착수 시 논리성·합리성을 다시 검토한다.
- **되돌리기 비용:** Low~Medium. 문서 재배열 중심이며 branch 단위 revert 가능.

## Checkpoints

- 2026-06-11 — branch `feature/chore-20260611-001-backlog-portfolio-reorg` 생성. 사용자 추가 조건(온보딩 가이드/workflow manual 전면 재작성)을 scope에 포함.
- 2026-06-11 — HARNESS backlog에 Portfolio View(W1~W5)를 추가하고 Summary/Details를 재배열. 오래된 PR #93 이후 전수 재검증은 regression asset으로 흡수. STATUS Next Actions를 이번 주 마무리/다음 주 product 적용 기준으로 갱신. `git diff --check`, shipped DR closure 통과.

## Discovery

- 명시적 backlog candidate가 아니라 사용자 직접 지시로 착수한 portfolio 정리 Work.
- Archived 2026-06-11: Done work 정리(routine), `/work-close` archive step.
