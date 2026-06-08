---
id: CHORE-20260608-003
priority: P1
status: Archived
risk: L2
scope: VERIFICATION-COMMANDS.md 보완(#1~#7) + canonical pointer 배선(AGENT-WORKFLOW Verification Defaults, repo-health) + scaffold source-only 결정 기록. 릴리즈 Full Sweep 프리셋 신설 포함.
appetite: 1d
planned_start: 2026-06-08
planned_end: 2026-06-08
actual_end: 2026-06-08
related_dr: []
related_troubleshooting: []
related_work: [CHORE-20260608-002]
---

# CHORE-20260608-003: VERIFICATION-COMMANDS 보완 + pointer 배선

## Top Summary

- **목표:** 릴리즈 게이트로 의존할 `docs/VERIFICATION-COMMANDS.md`를 단단히 하고, 기존 P1 백로그 항목(pointer 연결)을 scope 확장해 한 Work로 처리.
- **범위 = 리뷰 #1~#7 + pointer 배선 + scaffold 결정:**
  - #1 Release Full Sweep 프리셋 신설 (게이트 Layer 셋 + 순서 + release-go 기준)
  - #2 Layer P `grep -P` → BSD/portable-safe 한글 탐지 (이식성: 기본 BSD grep 환경 실패 방지)
  - #3 line 27 dangling "Layer L" 참조 정정 + 메타 섹션 라벨 부여(결과분류=Layer L, 자체점검=Layer M)
  - #4 OB7(정리)↔OB8 순서 정렬
  - #5 Layer Q·R의 OB0 temp scaffold 전제 명시
  - #6 M3 concat `bash -n` placeholder false-positive 한계 주석
  - #7 Layer C "Invariant 5종" 표기 정정(6개)
  - pointer: `AGENT-WORKFLOW.md` Verification Defaults + `repo-health.md`
  - scaffold: source-only 유지 결정 공식화
- **확정 게이트 Layer 셋 (사용자 승인):** A → C → R → I → E → F → H → N → O → S → G → P → J+J-OB → Q. 제외: T(placeholder), K(/repo-health umbrella 별도).
- **비목표:** repo-health.md slice 분리(별도 P2), gate series 보강(별도 P1), Layer T 채우기(upgrade 구현 후).

## Scope / Plan

| 순서 | 대상 | 작업 |
| --- | --- | --- |
| 1 | `docs/VERIFICATION-COMMANDS.md` | #1~#7 반영 + Release Full Sweep 프리셋 섹션 |
| 2 | `docs/AGENT-WORKFLOW.md` | Verification Defaults에 VERIFICATION-COMMANDS pointer 추가 |
| 3 | `skills/workflow/repo-health.md` | VERIFICATION-COMMANDS 참조 추가 |
| 4 | `docs/HARNESS-QUICK-REFERENCE.md` | one-liner(선택) |
| 5 | `docs/backlog/HARNESS.md` | 해당 P1 항목 제거 (work-close 시) |

## Done Criteria

- [x] #1~#7 전부 반영
- [x] `grep -n "VERIFICATION-COMMANDS" docs/AGENT-WORKFLOW.md skills/workflow/repo-health.md` 각 ≥1 (+ QUICK-REFERENCE 1)
- [x] line 27 dangling 참조 0 (실재 섹션 가리킴)
- [x] Release Full Sweep 프리셋 = 승인된 Layer 셋(A→C→R→I→E→F→H→N→O→S→G→P→J+J-OB→Q)
- [x] scaffold source-only 결정 기록 + `--check` drift 0 (invariant [5] PASS)
- [ ] HARNESS.md 해당 backlog 항목 제거 (work-close 시)

## Checkpoints

- 2026-06-08: 구현·검증 완료. #1(프리셋)·#2(grep -P→-c, BSD 실증)·#3·#4(OB7↔OB8 swap)·#5·#6·#7 반영, pointer 3곳 배선. scaffold invariants OVERALL PASS, drift 0.
- **#3 처리 방식 deviation:** 당초 "메타 섹션에 Layer L/M 라벨 부여" 제안했으나, 두 메타 섹션이 모두 Layer T *뒤*에 위치(게다가 자체점검 946 < 결과분류 1039로 L/M 순서도 역전)해 라벨을 달면 오히려 순서 혼란. 실제 dangling은 line 27 단 1곳이었으므로 **해당 참조를 섹션명 직접 지시로 정정**하고 메타 섹션은 무라벨 유지(letter gap L·M은 무해). 대규모 renumber 회피 = Surgical/Simplicity 준수.

## Discovery

- 2026-06-08: 기존 P1 backlog "VERIFICATION-COMMANDS.md pointer 연결 및 통합" candidate를 scope 확장해 착수. recon에서 (a) `grep -P`는 sandbox ugrep shim 때문에 동작했을 뿐 BSD grep에선 실패, (b) dangling은 line 27 "Layer L" 1곳뿐(대규모 renumber 불요), (c) pointer 미연결 확인.
