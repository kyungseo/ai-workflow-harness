---
id: CHORE-20260607-002
priority: P2
status: Done
risk: L2
scope: 등록·착수 시점 정합성 hardening — workflow prompt 보강 + 인덱스 신규 생성 + 기존 README 현행화
appetite: 2d
planned_start: 2026-06-07
planned_end: 2026-06-09
actual_end: 2026-06-07
related_dr: [DR-013, DR-023]
related_troubleshooting: []
related_work: [CHORE-20260607-001, CHORE-20260607-005]
---

# CHORE-20260607-002: 등록·착수 시점 정합성 Hardening

## Top Summary (결론 먼저)

- **목표:** (1) work-plan/work-register/repo-decision/session-summary에 정합성 prompt 경량 추가. (2) 인덱스 없는 archive 디렉토리 2곳에 신규 README 생성. (3) 기존 README 5종 stale 확인 및 현행화.
- **시발점:** CHORE-20260607-001 work-close 후 연계 작업으로 착수. 등록·착수 시 중복 점검·상태 동기화·인덱스 갱신 prompt가 없고, docs/archive/docs/decisions·retrospectives에 인덱스가 없음.
- **구현 원칙:** 모든 workflow prompt는 경량 prompt-level 체크만. 자동 유사도 감지·참조그래프 자동화는 별도 L3 deferred.
- **비목표:** docs/backlog/, docs/archive/snapshots/, docs/presentations/ 인덱스 추가 없음. hard-stop 추가 없음.

## Scope

### Slice A — Workflow Prompt Hardening

| 파일 | 추가 내용 |
|---|---|
| `skills/workflow/work-plan.md` | backlog candidate→Active 상태 동기화 prompt + 유사 항목 경량 안내 1줄 |
| `skills/workflow/work-register.md` | 유사·중복 항목 확인 prompt (primary duplicate gate) |
| `skills/workflow/repo-decision.md` | DR 생성 후 `docs/decisions/README.md` 갱신 prompt |
| `skills/workflow/session-summary.md` | 회고 추가 시 `docs/retrospectives/README.md` 갱신 prompt |
| `.claude/rules/docs-workflow.md` | general index pairing 원칙 |

### Slice B — 신규 인덱스 생성

| 파일 | 내용 |
|---|---|
| `docs/archive/docs/decisions/README.md` | Superseded DR 8개 목록 (DR-001~006, 009, 010) |
| `docs/archive/docs/retrospectives/README.md` | archived 회고 4개 목록 |

### Slice C — 기존 README 현행화

| 파일 | 확인 항목 |
|---|---|
| `docs/decisions/README.md` | DR-019, DR-020 포함 여부 + 전체 현행 확인 |
| `docs/retrospectives/README.md` | 현행 확인 |
| `docs/works/harness/README.md` | 현행 확인 |
| `docs/troubleshooting/README.md` | 현행 확인 |
| `docs/works/README.md` | 현행 확인 |

## Done Criteria

- [x] A1: work-plan에 backlog 상태 동기화 + 유사 항목 경량 안내 추가됨 (3a/3b)
- [x] A2: work-register에 유사·중복 항목 확인 prompt 추가됨 (Duplicate Check 섹션)
- [x] A3: docs-workflow.md MUST에 general index pairing rule 추가됨 (모든 indexed directory 커버)
- [x] A4: HARNESS-PROTOCOL.md에 Index Pairing Rule 섹션 추가됨 (decisions/retrospectives/troubleshooting/works)
- [x] B1: docs/archive/docs/decisions/README.md 신규 생성됨 (8개 목록, 공개 전 archive 사유 포함)
- [x] B2: docs/archive/docs/retrospectives/README.md 신규 생성됨 (4개 목록)
- [x] C1: docs/decisions/README.md 현행 확인 완료 (DR-019~025 포함) + archive README 링크 추가
- [x] C2: docs/retrospectives/README.md 현행 확인 완료 + archive README 링크 추가
- [x] C3: docs/works/harness/README.md 현행 확인 완료 (CHORE-20260607-002 Active ✓)
- [x] C4: docs/troubleshooting/README.md 현행 확인 완료
- [x] C5: docs/works/README.md 현행 확인 완료
- [x] cascade 점검 — canonical Step 0 포인터 구조 유지, adapter 수정 불필요. AGENTS.md docs-workflow.md 위임으로 Codex 커버.
- [x] **사용자 최종 리뷰** 후 Done

## Verification

- `git diff --check`, 링크/stale phrase 점검
- cascade: `skills/workflow/` → `.claude/commands/` → `.agents/skills/` 동기화 확인 (adapter는 Step 0 포인터라 수정 불필요)
- 시뮬레이션: "착수 시 중복 항목 존재" 시나리오, "회고 추가 시 README 미갱신 경고" 시나리오

## Checkpoints

| CP | Description | Status |
|---|---|---|
| 1 | Slice A: Workflow prompt hardening | → 진행 중 |
| 2 | Slice B: 신규 인덱스 생성 | ○ 대기 |
| 3 | Slice C: 기존 README 현행화 | ○ 대기 |
| 4 | cascade 점검 + 사용자 최종 리뷰 | ○ 대기 |

## Next Actions

1. → Slice A — Workflow prompt hardening
2. ○ Slice B — 신규 인덱스 생성
3. ○ Slice C — 기존 README 현행화
4. ○ `/work-close` 후 → **Work 파일 계층화 규칙 도입 (DR-013 개선)** 즉시 착수 (HARNESS.md P1, ★ 0순위)

## Discovery

- work-close 후 연계 착수. CHORE-20260607-001에서 Intent Recognition 보완 완료 후 정합성 hardening으로 이어짐.
