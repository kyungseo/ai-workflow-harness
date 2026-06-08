---
id: CHORE-20260607-005
priority: P1
status: Done
risk: L2
scope: DR-013 Work 파일 스펙 확장 — Top Summary/Next Actions 공식화, Context Manifest 신규, Slice 기준 명문화, Backlog ID-less 정책 명문화 + 영향 문서 현행화
appetite: 1d
planned_start: 2026-06-07
planned_end: 2026-06-07
actual_end: 2026-06-07
related_dr: [DR-013]
related_troubleshooting: []
related_work: [CHORE-20260607-002]
---

# CHORE-20260607-005: Work 파일 스펙 확장 (DR-013 개선)

## Top Summary (결론 먼저)

- **목표:** DR-013 Work 파일 섹션 스펙을 실제 관행과 정합시키고, Context Manifest·Slice 기준·ID-less 정책을 명문화한다.
- **시발점:** CHORE-20260607-002/003 연계 — backlog에서 ★ 0순위로 지정.
- **비목표:** Cross-Agent Review / Round Log 스펙화, scaffold Work 파일 템플릿 생성, Quick Mode 기준 변경.

## Context Manifest

| 순서 | 파일 | 섹션 | 왜 |
|---|---|---|---|
| 1 | `docs/decisions/DR-013-work-file-spec.md` | Work 파일 섹션 구성 | 1차 수정 대상 |
| 2 | `docs/HARNESS-PROTOCOL.md` | §12 Work File Rules | DR-013 포인터 — stale 여부 확인 |
| 3 | `docs/WORKFLOW-MANUAL.md` | line 264, 272 | 섹션 목록 현행화 |
| 4 | `docs/HARNESS-QUICK-REFERENCE.md` | Work 파일 섹션 목록 | 현행화 |
| 5 | `docs/decisions/README.md` | DR-013 행 | 요약 갱신 |

## Scope

### Slice A — DR-013 스펙 확장
| 항목 | 내용 |
|---|---|
| Top Summary 공식화 | 이미 관행(CHORE-20260605-004 등). "Executive Summary" 불일치 명시 후 Top Summary로 통일 |
| Next Actions 공식화 | 이미 관행. 형식(✓ 완료 / → 진행 중 / ○ 대기) 명시 |
| Context Manifest 신규 | CHORE-20260605-004에서 검증된 패턴. 세션 재개 시 읽을 파일·섹션·이유 테이블. Trigger Source 포함 |
| Slice 체계 기준 | 적용 기준 + Plan 내 A/B/C 패턴 명문화. 아주 간단한 작업엔 불필요함을 명시 |
| ID-less 정책 | feature branch에서 backlog row에 Work ID 역기입 금지. work-plan.md 3a와 정합 확인 |

### Slice B — 영향 문서 현행화
`docs/WORKFLOW-MANUAL.md`, `docs/HARNESS-QUICK-REFERENCE.md`, `docs/HARNESS-PROTOCOL.md` §12, `docs/decisions/README.md`

## Done Criteria

- [x] DR-013 섹션 구성에 Top Summary, Next Actions 공식화됨 (Executive Summary 불일치 주석 포함)
- [x] Context Manifest(Trigger Source 포함) 신규 섹션 규칙이 DR-013에 추가됨
- [x] Slice 기준(적용 조건, 불필요 조건, Plan 내 A/B/C 패턴) DR-013에 추가됨
- [x] Backlog candidate ID-less 정책 DR-013에 명문화됨
- [x] WORKFLOW-MANUAL, HARNESS-QUICK-REFERENCE 섹션 목록 현행화됨
- [x] HARNESS-PROTOCOL §12 stale 없음 확인됨
- [x] decisions/README DR-013 요약 갱신됨
- [x] cascade 점검 — work-plan.md 3a/3b와 충돌 없음

## Verification

- `git diff --check`
- stale 섹션명 grep: `grep -rn "Plan, Done Criteria, Verification, Checkpoints, Discovery"`
- work-plan.md 3a/3b 충돌 확인

## Checkpoints

| CP | Description | Status |
|---|---|---|
| 1 | Slice A: DR-013 스펙 확장 | → 진행 중 |
| 2 | Slice B: 영향 문서 현행화 | ○ 대기 |
| 3 | cascade 점검 + validation | ○ 대기 |

## Next Actions

1. → Slice A — DR-013 스펙 확장
2. ○ Slice B — 영향 문서 현행화
3. ○ cascade 점검 + validation → `/work-close`

## Discovery

- backlog 항목의 (5) Backlog candidate ID-less 정책은 CHORE-20260607-002에서 work-plan.md 3a로 이미 반영됨. DR-013 스펙에 명문화만 남음.
- CHORE-20260604-001은 "Executive Summary", CHORE-20260605-004는 "Top Summary" 사용 — 불일치 존재. Top Summary로 통일.
- Cross-Agent Review / Round Log는 개취 영역, 스펙 밖 자유 섹션으로 둠.
