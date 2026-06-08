---
id: CHORE-20260608-001
priority: P2
status: Archived
risk: L2
scope: docs/backlog/HARNESS.md 백로그 포맷을 단일 표 행에서 요약 표 + 상세 섹션 2단 구조로 전환. work-register/work-close canonical 절차 반영, T11 cascade 확인, scaffold 템플릿 일관성 평가.
appetite: 1d
planned_start: 2026-06-08
planned_end: 2026-06-08
actual_end: 2026-06-08
related_dr: [DR-021, DR-023]
related_troubleshooting: []
related_work: []
---

# CHORE-20260608-001: HARNESS.md 백로그 포맷 2단 구조 전환

## Top Summary

- **목표:** HARNESS.md 백로그 항목을 요약 표(스캔용) + `####` 상세 블록(읽기용) 2단 구조로 전환. 단일 셀에 모든 내용을 넣던 방식을 분리해 가독성 확보.
- **포맷 결정 (Option A):**
  - 요약 표: `| ID | Priority | Status | Risk | Title |` (한 줄 요약)
  - 상세 블록: `#### {Title}` 헤더 + `**Task:**`, `**Dependencies:**`, `**Done Criteria:**`, `**Verification:**` 필드
- **사전 발견:** scaffold가 생성하는 HARNESS.md 템플릿은 이미 comment-block 형식(표 아님). source ↔ scaffold target 포맷이 이미 달랐음. 이번 작업은 source HARNESS.md만 대상. scaffold 템플릿 일관성은 별도 평가.
- **비목표:** PHASE{n}→PROD-P{n} 네이밍 전환(별도 P2 백로그), scaffold 템플릿 전면 개편.

## Scope / Plan

| 순서 | 대상 | 작업 |
| --- | --- | --- |
| 1 | `docs/backlog/HARNESS.md` | 13개 항목 전체를 2단 구조로 변환 |
| 2 | `skills/workflow/work-register.md` | 신규 항목 등록 시 2단 포맷 출력하도록 절차 수정 |
| 3 | `skills/workflow/work-close.md` | Done 처리 시 표 행 + 상세 블록 양쪽 제거하도록 수정 |
| 4 | T11 adapter cascade | `.claude/commands/work-register.md`, `.agents/skills/workflow-work-register/`, `.claude/commands/work-close.md`, `.agents/skills/workflow-work-close/` 확인 |
| 5 | scaffold 템플릿 평가 | source 2단 포맷 vs. scaffold comment-block 포맷 gap 보고, 추가 작업 필요 시 별도 등록 |
| 6 | 문서 정렬 | README, GUIDE/MANUAL, HARNESS-QUICK-REFERENCE 등 포맷 참조 언급 있으면 갱신 |

## Done Criteria

- [x] HARNESS.md 전체 항목이 요약 표 + 상세 섹션 구조로 전환됨
- [x] work-register canonical에 2단 포맷 등록 절차 반영됨
- [x] work-close canonical에 표 행 + 상세 블록 양쪽 제거 절차 반영됨
- [x] T11 cascade 확인 완료 (adapter 변경 필요 없음 — 모두 thin wrapper)
- [x] scaffold 템플릿 2-tier 구조로 갱신 완료 (`scripts/create-harness.sh` HARNESS.md + PHASE1.md template, BOOTSTRAP.md `Active Candidates` 참조 수정)
- [x] `bash -n scripts/create-harness.sh` PASS
- [x] 관련 README/GUIDE 포맷 참조 이상 없음

## Checkpoints

## Discovery

- 2026-06-08: backlog 항목 내용이 길어지면서 표 셀 1줄 렌더링으로 읽기 어려워짐. Option A(요약 표 + 상세 섹션) 채택.
- scaffold-generated HARNESS.md는 이미 comment-block 비표 형식 사용 중. source와 포맷이 원래부터 달랐음.
