# AI Workflow Harness Refactor Plan

Last updated: 2026-05-14

## 1. Purpose

Phase1 이후 누적된 AI Workflow Harness를 백업한 뒤, Phase2 진입 전에 경량 상태 머신 기반 운영 체계로 재편한다.

이 작업의 목적은 문서를 늘리는 것이 아니라, 세션 시작부터 종료까지 Agent가 현재 상태를 잃지 않고 통제된 실행을 하도록 만드는 것이다.

핵심 목표:

- Deterministic Execution: 같은 상태에서 같은 절차로 재개 가능
- Stateful Workflow: `STATUS.md` 중심으로 현재 작업 상태 유지
- Controlled Execution: Plan → Approval → Implement 게이트 유지
- Failure-first Design: 실패 조건과 복구 경로를 명시
- Reversibility: 기존 Phase2 후보와 DR은 백업 후 재편

## 2. Current Assessment

### 2.1 What Works

| Area | Assessment |
| --- | --- |
| Context tiering | `STATUS.md` → backlog/summary/plan 순서의 최소 로드 철학이 이미 있음 |
| Decision records | DR-001~010까지 결정 기록 구조가 존재함 |
| Approval gate | Plan 후 승인받고 구현한다는 원칙이 반복 선언되어 있음 |
| Cross-tool awareness | Claude/Cursor 규칙을 맞추려는 시도가 있음 |
| Archive habit | Phase1 status/plan archive가 이미 존재함 |

### 2.2 Main Problems

| Problem | Impact | Evidence |
| --- | --- | --- |
| State is mixed | 다음 세션에서 무엇을 해야 하는지 흐려짐 | `STATUS.md` Active Work에 완료 항목, PRE, P2, HRN이 혼재 |
| Backlog is mixed | MSA 기능 개발과 Harness 개선 우선순위가 충돌 | `docs/backlog/PHASE2.md`에 `P2-*`와 `HRN-*`가 같은 테이블에 있음 |
| Status drift exists | STATUS를 신뢰하기 어려움 | `P2-006`이 STATUS에서는 Candidate, backlog에서는 In Progress |
| Manual is too heavy | 일상 실행 규칙으로 사용되기 어려움 | `WORKFLOW-MANUAL.md` 985 lines |
| Enforcement is weak | 규칙이 부탁으로 남음 | 평가 문서에서 hard enforcement 부재 지적 |

## 3. Refactor Strategy

이번 리팩터링은 L3 작업으로 분류한다.

이유:

- AI 운영 구조와 문서 생명주기를 변경한다.
- STATUS/backlog의 역할을 재정의한다.
- 향후 hook/CI enforcement의 기반이 된다.

작업 방식:

1. 기존 상태를 백업한다.
2. 현재 운영 상태를 백지에 가깝게 재정의한다.
3. 기존 작업 후보는 새 계획에 바로 이식하지 않고 재분류한다.
4. Manual-first 운영 규칙을 먼저 안정화한다.
5. 자동화 후보는 별도 backlog로 분리한다.

## 4. Target Model

### 4.1 Session State Machine

```text
INIT -> PLAN -> APPROVAL -> EXECUTE -> VALIDATE -> CHECKPOINT -> END
                 ^              |
                 |              v
              RECOVER <- FAIL <-+
```

### 4.2 State Rules

| Rule | Meaning | Failure if Broken |
| --- | --- | --- |
| `STATUS.md` is current state | 세션 시작과 종료의 기준 | 다음 세션이 잘못된 작업을 선택 |
| Code is truth on conflict | 문서와 실제 파일이 다르면 실제 파일 우선 | 잘못된 문서를 기준으로 계획 수립 |
| No implementation without plan | 구현 전 scope/files/verification/risk 보고 | scope creep 발생 |
| No commit without validation | 검증 실패 상태로 저장 금지 | 깨진 상태가 기준점이 됨 |
| No silent status drift | 상태 불일치 발견 시 보고 | SSOT 신뢰도 하락 |

### 4.3 Risk Classification

| Level | Scope | Gate |
| --- | --- | --- |
| L1 Safe | 문서, 테스트, 국소 버그 수정 | 간단 plan 후 진행 |
| L2 Normal | 기능 구현, 설정 변경 | scope/files/verification/risk 보고 후 승인 |
| L3 Critical | 아키텍처, 인프라, 보안, DB schema, harness 구조 | AS-IS/TO-BE, rollback, DR 영향 보고 후 승인 |

## 5. Document Model

### 5.1 Operating Documents

| Document | Role | Load Rule |
| --- | --- | --- |
| `docs/STATUS.md` | 현재 상태 SSOT | 세션 시작 시 상단 필수 |
| `docs/backlog/PHASE2.md` | Phase2 후보 작업 | 작업 선택 필요 시 |
| `docs/PLAN-SUMMARY.md` | 아키텍처 요약 | 구조 맥락 필요 시 |
| `docs/PLAN.md` | WHY, 결정 근거 | L3 작업 또는 DR 영향 시 |
| `docs/ARCHITECTURE.md` | WHAT, 현재 구조 | 구조 변경 시 |
| `docs/DEVELOPER-GUIDE.md` | HOW, 개발 절차 | 개발 방식 변경 시 |
| `docs/HARNESS-PROTOCOL.md` | 하네스 설명서 허브 | 온보딩/정비 시 |
| `docs/harness-protocol/` | 카테고리별 상세 규칙 | 필요한 세부 영역만 선택 로드 |

### 5.2 Proposed Additions

| Document | Purpose |
| --- | --- |
| `docs/HARNESS-QUICK-REFERENCE.md` | 일상 세션용 1~2페이지 실행 규칙 |
| `docs/backlog/HARNESS.md` | `HRN-*` 전용 backlog |
| `docs/archive/harness-refactor-20260514/` | 재편 전 상태 백업 |
| `docs/HARNESS-PROTOCOL.md` | legacy manual을 대체하는 summary hub |
| `docs/harness-protocol/` | 세부 workflow reference |

## 6. Execution Plan

### Step 1. Backup Current State

Status: Done

Outputs:

- `docs/archive/harness-refactor-20260514/STATUS-before-refactor.md`
- `docs/archive/harness-refactor-20260514/PHASE2-backlog-before-refactor.md`
- `docs/archive/harness-refactor-20260514/decisions/`
- `docs/archive/harness-refactor-20260514/TODO-PHASE1/`
- `docs/archive/harness-refactor-20260514/MANIFEST.md`

### Step 2. Define Blank-State Operating Baseline

Status: Done

Planned changes:

- Rewrite `docs/STATUS.md` around the current harness refactor only.
- Move completed Phase1/PRE/P2 planning residue out of Active Work.
- Keep only current phase, active task, blockers, next action, and validation state.

### Step 3. Separate Product Backlog and Harness Backlog

Status: Done

Planned changes:

- Keep product Phase2 candidates in `docs/backlog/PHASE2.md`.
- Move `HRN-*` candidates to `docs/backlog/HARNESS.md`.
- Add a short pointer from `STATUS.md` to both backlogs.

### Step 4. Create Quick Reference

Status: Done

Planned changes:

- Add `docs/HARNESS-QUICK-REFERENCE.md`.
- Keep it short and operational.
- Do not duplicate the full manual; link to `HARNESS-PROTOCOL.md` and `docs/harness-protocol/` for deep reference.

### Step 5. Update Workflow Manual

Status: Done

Planned changes:

- Add `HARNESS-PROTOCOL.md` as the active harness protocol hub.
- Keep `WORKFLOW-MANUAL.md` as the user-facing workflow manual.
- Move detailed categories into `docs/harness-protocol/`.

### Step 6. Validate

Manual validation checklist:

- `STATUS.md` can answer current phase, active task, blocker, next action.
- `PHASE2.md` contains product work only.
- `HARNESS.md` contains harness work only.
- Backup manifest exists and includes original current state, backlog, DRs, Phase1 TODOs.
- No orphan new document: new documents are linked from `STATUS.md`, `HARNESS-PROTOCOL.md`, or `docs/harness-protocol/`.

## 7. Rollback Plan

If the refactor makes the harness harder to use:

1. Restore `docs/STATUS.md` from `docs/archive/harness-refactor-20260514/STATUS-before-refactor.md`.
2. Restore `docs/backlog/PHASE2.md` from `docs/archive/harness-refactor-20260514/PHASE2-backlog-before-refactor.md`.
3. Remove newly introduced documents only after confirming no new decisions depend on them.

Rollback cost: Low before Step 2, Medium after Step 3.

## 8. Open Decisions

| ID | Question | Recommendation |
| --- | --- | --- |
| HRF-OQ-001 | Should `HRN-*` be separated from `PHASE2.md`? | Yes. Harness work has different lifecycle and validation. |
| HRF-OQ-002 | Should `STATUS.md` be reset to blank-state baseline? | Yes, after backup. Keep only current refactor state. |
| HRF-OQ-003 | Should `.harness/config.json` be introduced now? | No. Defer until manual protocol proves stable. |
| HRF-OQ-004 | Should all existing DRs remain active? | Keep files, but re-link only relevant DRs in the new plan. |

## 9. Next Recommended Action

Validate the documentation refactor:

- Confirm `docs/STATUS.md` only contains current live state.
- Confirm `docs/backlog/PHASE2.md` contains product/preparation work only.
- Confirm `docs/backlog/HARNESS.md` contains harness work.
- Confirm `docs/HARNESS-QUICK-REFERENCE.md` is linked from `docs/HARNESS-PROTOCOL.md`.

Risk: L3 because it changes workflow state structure.
