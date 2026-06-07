---
id: CHORE-20260607-001
priority: P1
status: Active
risk: L2
scope: DR-022 T5 배선 확장(work-plan/repo-decision) + PLAN-SUMMARY lifecycle 흡수 + Intent Recognition 보완(work-close/session-summary) + 등록·착수 정합성 hardening 연계
appetite: 3d
planned_start: 2026-06-07
planned_end: 2026-06-10
actual_end:
related_dr: [DR-022, DR-024]
related_troubleshooting: []
---

# CHORE-20260607-001: PLAN Trigger Coverage 확장

## Top Summary (결론 먼저)

- **목표:** T5(PLAN 영향 판단) 배선이 `work-close`에만 연결된 갭을 해소. `work-plan`(착수) · `repo-decision`(DR 등록) 시점에도 T5 soft step 추가. PLAN-SUMMARY stale check 통합. Intent Recognition 보완.
- **시발점:** 2026-06-07 세션 사용자 관찰 — (a) 작업 등록·착수 시 PLAN 범위 검증 없음, (b) "close 처리하고 commit/PR 해라" 자연어 발화 시 T5 작동 보장 안 됨. 이 두 갭이 이 작업의 직접 출발점이다.
- **흡수 backlog:** PLAN-SUMMARY derived-cache lifecycle (P2, Candidate) — T5 배선 확장과 직접 연결되므로 이 Work에 흡수.
- **비목표:** hard-stop 추가 없음. T5는 recommended/warning soft 수준 유지(DR-022/DR-024). Intent Recognition 전체 재설계 없음.
- **연계 Next Work:** 등록·착수 시점 정합성 hardening (P2, Candidate) — 이 Work 완료 후 착수.

## Context Manifest

| 순서 | 파일 | 섹션 | 왜 |
| --- | --- | --- | --- |
| 1 | `docs/decisions/DR-022-plan-lifecycle.md` | Decision, Consequences | T5 배선 원출처 + soft gate 근거 |
| 2 | `docs/works/harness/CHORE-20260605-004-plan-lifecycle-wiring.md` | Done Criteria, Discovery | T5 배선 구현 이력 (work-close 배선 결과) |
| 3 | `skills/workflow/work-plan.md` | 전체 | T5 step 추가 대상 |
| 4 | `skills/workflow/repo-decision.md` | 전체 | T5 step 추가 대상 |
| 5 | `skills/workflow/work-close.md` | §5b | PLAN-SUMMARY stale check 보완 대상 |
| 6 | `.claude/rules/docs-workflow.md` | Intent Recognition 테이블 | work-close/session-summary 추가 대상 |
| 7 | `docs/HARNESS-PROTOCOL.md` | T5(line ~447), T15-17 | 배선 범위 명시 보완 대상 |
| 8 | `docs/PLAN-SUMMARY.md` | 전체 | derived-cache lifecycle 규정 추가 대상 |

## Defect/Scope Inventory (실측 갭)

| # | 항목 | 근거 |
| --- | --- | --- |
| D1 | work-plan 착수 시 T5 없음 — "이 작업이 PLAN 방향과 일치하는가?" 확인 없음 | `skills/workflow/work-plan.md` 전체 grep "T5\|PLAN impact" |
| D2 | repo-decision 등록 시 T5 없음 — DR이 PLAN roadmap을 바꾸는지 확인 없음 | `skills/workflow/repo-decision.md` 전체 grep "T5\|PLAN impact" |
| D3 | 자연어 "close/마무리/PR 해라" 시 work-close 절차 미실행 — T5 작동 보장 안 됨 | `.claude/rules/docs-workflow.md` Intent Recognition 테이블에 work-close 없음 |
| D4 | session-summary 자연어 의도 인식 없음 — "세션 마무리/요약" 발화 시 skill 미로드 | `.claude/rules/docs-workflow.md` Intent Recognition 테이블에 session-summary 없음 |
| D5 | PLAN 변경 시 PLAN-SUMMARY stale check 미배선 | `skills/workflow/work-close.md:63` — PLAN만 언급, PLAN-SUMMARY 없음 |
| D6 | PLAN-SUMMARY derived-cache 역할 미규정 — 자체 이력 누적 방지 기준 없음 | `docs/PLAN-SUMMARY.md` 전체 |

## Plan

### Slice A — Gap 진단 + 방향 확정

**목표:**
- D1~D6 실측 확인(grep 기반)
- PLAN-SUMMARY lifecycle 규정 방향 확정
- Intent Recognition 추가 후보 평가: work-select(context 의존도 높음, 오탐 위험 검토)
- work-plan/repo-decision T5 step 문구 초안(enforcement mode DR-024 정합 확인)

**검증:** gap 목록 grep 결과 + 방향 문서. Slice B 착수 조건 명시.

**→ 이후 예측:** Slice B — work-plan/repo-decision T5 배선 구현 + cascade

---

### Slice B — T5 배선 확장 구현

**목표:**
- `skills/workflow/work-plan.md`: 착수 시 T5 soft step 추가 (PLAN 영향 있으면 proposal, 없으면 1줄 보고)
- `skills/workflow/repo-decision.md`: DR 등록 시 T5 soft step 추가
- T5 step에 PLAN-SUMMARY stale check 포함 (PLAN 변경 시 PLAN-SUMMARY도 함께 판정)
- cascade: canonical → command adapter → cursor mirror → codex adapter
- `docs/HARNESS-PROTOCOL.md` T5 배선 범위 명시 보완

**검증:** `git diff --check`. cascade 정합. "work-plan 착수 → T5 step 동작" 시나리오 시뮬레이션.

**→ 이후 예측:** Slice C — Intent Recognition 보완

---

### Slice C — Intent Recognition 보완

**목표:**
- `.claude/rules/docs-workflow.md` Intent Recognition 테이블:
  - work-close 추가: "작업 마무리/완료/close/PR 요청 의도 → work-close skill 로드"
  - session-summary 추가: "세션 마무리/요약/오늘 끝 의도 → session-summary skill 로드"
- work-select 평가 결과 반영 (추가 또는 명시적 제외 justification 기록)
- 각 추가 항목의 제외 기준 재검토 및 justification 기록

**검증:** 자연어 패턴 시뮬레이션 — "close 처리해줘", "세션 마무리", "오늘 끝내자" 3종 이상.

**→ 이후 예측:** Slice D — PLAN-SUMMARY lifecycle 규정 + backlog 정리

---

### Slice D — PLAN-SUMMARY lifecycle 규정 + backlog 정리

**목표:**
- `docs/PLAN-SUMMARY.md`: derived-cache lifecycle 규정 추가 (역할 명시, 자체 이력 누적 금지 기준)
- backlog PLAN-SUMMARY 흡수 행 제거 (CHORE-20260607-001 Done 시)
- 등록·착수 정합성 hardening을 Next Actions 다음 Work로 명시
- T5 self-check: 이 Work의 결과가 PLAN roadmap/milestone 방향에 영향을 주는지 판정

**검증:** backlog 정합 확인. PLAN-SUMMARY lifecycle 시뮬레이션(PLAN 변경 시 stale check 동작).

**→ 이후:** `/work-close` → 등록·착수 시점 정합성 hardening 착수

## Done Criteria

- [ ] A: work-plan 착수 시 T5 soft step 배선됨 (canonical + cascade 정합)
- [ ] B: repo-decision 등록 시 T5 soft step 배선됨 (canonical + cascade 정합)
- [ ] C: T5 step에 PLAN-SUMMARY stale check 포함됨
- [ ] D: Intent Recognition 테이블에 work-close + session-summary 추가됨, justification 기록됨
- [ ] E: `docs/PLAN-SUMMARY.md` derived-cache lifecycle 규정 추가됨
- [ ] F: backlog PLAN-SUMMARY 흡수 행 제거됨
- [ ] G: 등록·착수 정합성 hardening이 Next Actions 다음 Work로 명시됨
- [ ] cascade 점검(canonical → skill → command → cursor → codex) PASS
- [ ] **사용자 최종 리뷰** 후 Done

## Verification

- `git diff --check`, 링크/stale phrase 점검
- cascade: `skills/workflow/` → `.claude/commands/` → `.cursor/rules/workflow.mdc` → `.agents/skills/` 동기화 확인
- intent recognition 시뮬레이션: "close 처리해줘" / "세션 마무리" / "오늘 끝내자" 패턴 확인
- PLAN-SUMMARY stale check: PLAN 변경 시나리오에서 T5 step이 PLAN-SUMMARY도 함께 판정하는지 확인

## Checkpoints

| CP | Description | Status |
| --- | --- | --- |
| 1 | ○ Slice A: Gap 진단 + 방향 확정 | ○ Pending |
| 2 | ○ Slice B: T5 배선 확장 구현 + cascade | ○ Pending |
| 3 | ○ Slice C: Intent Recognition 보완 | ○ Pending |
| 4 | ○ Slice D: PLAN-SUMMARY lifecycle + backlog 정리 | ○ Pending |
| 5 | ○ cascade 점검 + 사용자 최종 리뷰 | ○ Pending |

## Next Actions

1. ○ **Slice A 착수** — Gap 진단(grep 기반 D1~D6 실측) + 방향 확정
2. ○ Slice B — T5 배선 확장 구현
3. ○ Slice C — Intent Recognition 보완
4. ○ Slice D — PLAN-SUMMARY lifecycle + backlog 정리
5. ○ `/work-close` 후 → **등록·착수 시점 정합성 hardening** 착수

## Cross-Agent Review And Discussion

이 Work는 구현 전 Slice A 방향 확정 후 Codex cross-review를 거친다.

### Round Log

| Round | 작성자 | 단계 | 요약 |
| --- | --- | --- | --- |
| R1 | Claude | Plan | 초기 계획 작성. Slice A~D 구조, D1~D6 갭 목록, Intent Recognition 후보 평가 방향 제시 |

## Discovery

- **흡수 backlog:** PLAN-SUMMARY derived-cache lifecycle (P2, Candidate) — T5 배선 확장과 직접 연결되어 이 Work Slice D에서 처리. backlog에 흡수 표시 완료(2026-06-07).
- **시발점 대화:** 2026-06-07 세션에서 사용자가 "두 지점 모두 현재는 갭이 있다" — (a) 등록 시 PLAN 검증 없음, (b) 자연어 close 요청 시 T5 보장 안 됨 — 을 직접 관찰하여 이 Work 착수로 이어짐.
