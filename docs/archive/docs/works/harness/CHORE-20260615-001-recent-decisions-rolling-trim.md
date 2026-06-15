---
id: CHORE-20260615-001
priority: P2
status: Archived
risk: L2
scope: STATUS.md Recent Decisions의 "rolling window 최근 8건" 규칙이 지켜지지 않는 구조 결함을 닫는다. (1) 추가 경로인 `/work-close`(`skills/workflow/work-close.md` step 6)에 trim 단계가 없어 누적이 발생 — trim 한 줄 추가. (2) 현재 누적분(15건)을 8건으로 정리. 함께 대기 중이던 archive 1건(CHORE-20260614-001) drain. Out of scope: Next Actions W4/W5 가독성 재배치, record-decision/session-summary/repo-health 기존 trim 문구.
appetite: 0.1d
planned_start: 2026-06-15
planned_end: 2026-06-15
actual_end: 2026-06-15
related_dr: []
related_troubleshooting: []
related_work: [CHORE-20260614-001]
---

# CHORE-20260615-001: Recent Decisions rolling-8 trim 구조 보정

## Top Summary

- **목표:** Recent Decisions 8건 rolling 규칙(`docs/WORKFLOW-MANUAL.md:232`)이 실제로 유지되도록 구조를 고치고, 누적분을 정리한다.
- **왜 (근본 원인):** 항목 **추가 경로**(`/work-close`)와 **trim 경로**(record-decision/session-summary/repo-health)가 분리되어 있다. Recent Decisions에 들어가는 항목 대부분은 DR 없는 CHORE work-close 항목인데, work-close에는 trim 단계가 없어 DR 없이 CHORE만 연속 close하면 추가만 누적된다. 실제 15건 중 13건이 `2026-06-13` 하루에 몰림.
- **해결:** trim을 가장 빈번한 추가 경로(work-close)에 직접 넣어 add-path가 곧 trim-path가 되도록 한다.

## Scope / Non-Goals

### Scope
1. `skills/workflow/work-close.md` step 6: Recent Decisions 추가 시 8건 rolling 유지 + DR-worthy 확인 1줄 추가 (canonical-only).
2. `docs/STATUS.md` Recent Decisions 15 → 8건 정리 (최신 8건 유지, 오래된 7건 drop).
3. CHORE-20260614-001 archive drain (git mv + 양쪽 README index).

### Non-Goals
- Next Actions 4번 W4/W5 deferred 묶음 가독성 재배치 (사용자 지시로 제외).
- record-decision/session-summary/repo-health-full의 기존 trim 문구 수정.
- trim 규칙의 adapter mirror 복제 (기존 패턴대로 canonical-only).

## Done Criteria

- [x] work-close.md step 6에 rolling-8 trim 1줄 추가, 문구가 `record-decision.md:48`과 의미 정합
- [x] STATUS Recent Decisions 행 수 = 8 (drop된 DR-worthy 항목 DR-035/036/037 canonical 파일 존재 확인)
- [x] CHORE-20260614-001 archive: 파일 이동 + live README 행 제거 + archive-side README 행 추가 + frontmatter `Archived`
- [x] `git diff --check` clean, mirror parity 무영향 확인

## Verification

- `git diff --check`
- `awk '/^## Recent Decisions/{f=1;next}/^## /{f=0}f&&/^\| 2026/{c++}END{print c}' docs/STATUS.md` → 8
- archive 정합 육안 확인, work-close trim 문구 정합 확인
- mirror/cascade: trim은 canonical-only — adapter 미변경이 기존 패턴(record-decision/session-summary)과 일치

## Discovery

- `/session-start` 직후 사용자 질문("롤링 8건이 안 되는 이유")에서 출발. 추가/trim 경로 분리가 근본 원인임을 코드 추적으로 확인.
- W4/W5 릴리즈 우려는 별건 — deferred optional 항목이라 릴리즈 정합성 문제 없음. 가독성 재배치는 사용자 지시로 비범위.
- 2026-06-15 archive: 동일 작업/commit에서 in-session 완료되어 Done→Archived로 즉시 drain(queue clean 유지).
