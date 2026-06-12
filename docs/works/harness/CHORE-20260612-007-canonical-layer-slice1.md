---
id: CHORE-20260612-007
priority: P1
status: Active
risk: L2
scope: AGENT-WORKFLOW.md 한 파일의 비대화 점검 + context routing 테이블 구조 개선. README, HARNESS-PROTOCOL.md trigger family, docs/ 물리 레이아웃, skills/workflow/*, scaffold, adapter는 Non-goals다.
appetite: 1d
planned_start: 2026-06-12
planned_end: 2026-06-12
related_dr: [DR-021, DR-023]
related_work: [CHORE-20260611-005, CHORE-20260611-009]
---

# CHORE-20260612-007: Canonical 개념 계층화 Slice 1 — AGENT-WORKFLOW.md 비대화 점검 + context routing 개선

## Top Summary

- **목표:** `docs/AGENT-WORKFLOW.md`의 현재 구조를 감사하고, context routing 테이블과 상시 로드 섹션에서 ②비대화 실패모드를 줄이는 최소 변경을 수행한다.
- **왜 지금:** W1/W2 완결 후 Active Work 없는 시점. PLAN.md §3-a (2026-06-12 merged)가 W3 판단 기준("어느 실패모드를 실제로 줄이는가")을 공식화했고, 그 렌즈로 가장 먼저 점검해야 할 파일이 AGENT-WORKFLOW.md다. 모든 세션에서 로드되는 가장 무거운 canonical 파일이며, W1/W2에서 조건부 pointer 패턴이 추가됐지만 기존 인라인 블록은 아직 정리되지 않았다.
- **핵심 경계:** AGENT-WORKFLOW.md 한 파일만. 이 Work는 Slice 1이다. 나머지 W3 대상(README, trigger family, Approval Matrix 내용, scaffold 등)은 Non-goals에 명시한다.
- **역할:** Claude = author/driver, Codex = red team reviewer. Codex review 결과와 Round Log는 이 파일의 `Cross-Agent Review And Discussion`에 누적한다.

## Candidate Comparison

| 후보 | 지금 먼저인가? | PLAN §3-a 실패모드 | scope 번짐 위험 | 판단 |
| --- | --- | --- | --- | --- |
| **Canonical 계층화 Slice 1** (AGENT-WORKFLOW.md audit) | 높음. W1/W2 완결 후 첫 W3 진입점. 모든 세션 로드 대상 | ②비대화 직접. ①라우팅 pointer 명확화도 부수 효과 | 중 — Non-goals 명시로 관리 가능 | **착수.** 단, Slice 1 경계를 엄수 |
| Prompt surface diet + optional pack 재정의 | 중. docs/ 물리 레이아웃 결정을 포함해 더 복잡함 | ②비대화 + ①라우팅 | 높음 — DR-021 reversal, docs/ 이동 등 결정이 많음 | W3 Slice 2로 순서 대기 |
| repo-health.md slice 분리 | 중. F4 residual로 독립 항목 | ②비대화 (422줄 → 조건부) | 낮음 — 파일 1개 | Slice 1 이후 or 병행. warmup으로도 유효하지만 필수 아님 |
| Archive 누적 관리 정책 | 낮음. 해악 정량화부터 필요 | ①라우팅 누락(N/A 수준) | 낮음 | W4로 유지 |

**결론:** Slice 1 경계 엄수 전제로 W3 직접 진입 타당.

## 왜 지금 이 Work인가 (PLAN §3-a 렌즈)

PLAN.md §3-a(2026-06-12 merged)는 이후 W3 구조 작업이 "새 surface를 더 추가하는가"보다 "어느 실패모드를 실제로 줄이는가"를 먼저 설명해야 한다고 명시한다.

| Failure mode | 이 Work와의 연결 |
| --- | --- |
| ①라우팅 누락 | context routing 테이블 pointer 조건 명확화 → 어떤 문서가 언제 로드되는지 불명확한 row 제거 |
| ②비대화 | AGENT-WORKFLOW.md 인라인 중복·경고 블록 제거 → 상시 로드 context weight 절감 |
| ③선언-실행 괴리 | 기본 목적 아님. audit에서 실제 선언-실행 mismatch가 발견된 경우에만 부수 기여로 인정. adapter 변경은 Non-goals이므로 ③ 기여를 정당화 근거로 쓰지 않는다. |

주 효과는 ②이고 ①이 부수 효과다. ③은 감사 결과에 따라 개선 가능성이 있는 선택 항목이다.

## Background / Facts

- `docs/AGENT-WORKFLOW.md` 는 CLAUDE.md와 AGENTS.md에서 `@docs/AGENT-WORKFLOW.md`로 로드된다 — 세션 시작 시 무조건 전체 로드.
- Context Routing 테이블 상단에 "Optional pack 참조 주의" 인라인 경고 블록이 있다. 이 블록은 `docs/HARNESS-ARCHITECTURE.md`, `docs/HARNESS-MAINTAINER-GUIDE.md`가 minimal scaffold에 없을 수 있다는 경고인데, 테이블 밖에 별도 paragraph로 위치해 있다.
- W1/W2 완결 후 조건부 pointer 패턴이 일부 섹션에 추가됐지만, 기존 인라인 설명 블록은 아직 정리되지 않아 비대화 패턴이 누적됐다.
- AGENT-WORKFLOW.md는 Approval Matrix, Work Item Routing, Risk Levels, STATUS Rules, State And Closeout Rules, Trigger And Naming Pointers, Project Constants, Verification Defaults 섹션을 포함한다. 일부는 상시 필요하지만 일부는 조건부일 수 있다.
- CHORE-20260611-005(검증 척추)와 CHORE-20260611-009(SOURCE-REPO-OPERATIONS.md)가 이 파일에 Update Trigger pointer를 추가했다.
- HARNESS.md backlog에서 이 항목은 P1/L3로 등록됐으나, Slice 1 범위(단일 파일 감사)는 L2로 평가한다. 감사 결과 L3 변경(파일 분리, 역할 변경 등)이 필요하다고 판단되면 R1에서 scope 조정 후 진행한다.

## Scope / Non-Goals

### Scope

1. `docs/AGENT-WORKFLOW.md` 현재 구조 감사
   - 섹션별 대략 라인 수 / 상시 vs 조건부 분류
   - 중복 표현 식별 (다른 파일에 이미 있거나 redundant한 내용)
   - Context Routing 테이블 각 row: 로딩 조건 명확성, 중복 pointer, stale reference 점검
2. Context Routing 테이블 개선 (감사 결과 기반)
   - "Optional pack 참조 주의" 인라인 경고 블록 처리 (pointer화 또는 경량화)
   - 각 row의 로딩 조건 명세 명확화
   - 중복·stale row 제거 또는 통합
3. (감사 결과에 따라) 명백한 중복 prose 경량화 또는 제거
   - 편집 허용 범위: Context Routing 테이블 + 그 직전 "Optional pack 참조 주의" 인라인 블록 + audit에서 "명백히 중복"으로 판정된 로컬 prose만
   - 새 파일 생성 금지 (이 Slice에서 파일 분리·추가 없음)
   - conditional pointer 전환은 Context Routing 인라인 블록에만 허용

### Non-Goals

- `README.md` 구조 변경 — W3 Slice 2 또는 별도 Work
- `docs/HARNESS-PROTOCOL.md` trigger family 재그룹화 — 별도 backlog 항목
- `docs/AGENT-WORKFLOW.md` Approval Matrix / State And Closeout Rules / Verification Defaults / Work Item Routing 섹션의 위치 변경, 내용 변경, conditional pointer 전환 — 이번 Slice에서 **audit-only, relocation 금지** (R0 F1)
- `docs/` 물리 레이아웃 분리 — Prompt surface diet Work와 연계 판단
- `skills/workflow/*.md` 파일 변경 (repo-health.md slice 분리는 별도 항목)
- `.claude/commands/`, `.agents/skills/` adapter 변경 (cascade 판정이 필요하면 R1에서 scope 추가 제안 후 처리)
- `scripts/create-harness.sh` scaffold 변경
- readability rewrite / tone 변경

## Files

| 파일 | 계획 |
| --- | --- |
| `docs/AGENT-WORKFLOW.md` | Audit 주 대상. 감사 후 승인된 항목만 최소 수정 |
| `docs/PLAN.md` | Read-only 참조 — §3-a 실패모드 평가 기준 확인 |
| `docs/backlog/HARNESS.md` | 완료 시 candidate row 제거 대상 |
| `docs/works/harness/README.md` | Active에 이 Work 등록 (feature branch commit 시) |
| `docs/STATUS.md` | R0 합의/승인 후 Active pointer 추가 |
| 이 Work 파일 | plan, audit findings, Codex review Round Log SSoT |

> `docs/works/harness/README.md`, `docs/STATUS.md`는 tracking collateral이다 — "한 파일 Slice" 표현은 AGENT-WORKFLOW.md 편집 대상 기준이고, 이 두 파일은 Work 진행·closeout에 따라 별도 업데이트된다. (R0 NTH-1)
>
> adapter cascade(`.claude/commands/`, `.agents/skills/`) 변경이 audit 결과 필요하다면 R1에서 scope 추가 제안 후 승인받는다.

## Plan

### Phase 1 — Audit (R0 승인 후, 구현 전)

1. AGENT-WORKFLOW.md 섹션별 라인 수 측정
2. Context Routing 테이블 전체 row 점검:
   - 로딩 조건이 명확한가?
   - 다른 row 또는 다른 파일과 중복인가?
   - stale (존재하지 않거나 경로 변경된 target) 없는가?
3. "Optional pack 참조 주의" 블록: 테이블 row에 이미 N/A 조건이 있는지 확인 → 인라인 경고 블록이 추가 정보를 제공하는지 아니면 중복인지 판단
4. 섹션별 "상시 로드 필요 vs 조건부" 분류표 작성
5. 개선 후보 목록 작성 (항목별 ①②③ 실패모드 mapping, 예상 라인 절감)
6. **R1 audit 결과 보고 + 개선안 제시 → Codex/사용자 승인 대기**

### Phase 2 — Minimal restructure (R1 승인 후)

> **Hard stop: R1 audit 결과 승인 전에는 `docs/AGENT-WORKFLOW.md` 본문을 수정하지 않는다. (R0 F2)**

1. 승인된 항목만 순서대로 적용
2. 각 변경 후 pointer 정합 확인
3. BEHAVIOR-PRINCIPLES §2(Simplicity First) / §3(Surgical Changes) 위반 자체 점검
4. Verification 수행

### Phase 3 — Closeout

1. Done Criteria 전체 체크
2. `/work-close` 절차 실행

## Done Criteria

- [ ] AGENT-WORKFLOW.md 감사 결과가 이 Work 파일에 기록된다.
- [ ] Context Routing 테이블에서 중복·stale row 또는 인라인 경고 블록이 제거되거나 pointer화된다 (감사 결과 필요한 경우).
- [ ] 감사 결과 "현행 유지"가 맞는 항목은 그 근거가 기록된다. 변경 없음도 유효한 결과다.
- [ ] PLAN.md §3-a 3대 실패모드 중 ①/② 중 하나 이상이 실질적으로 개선됐거나, 개선 없음의 근거가 명시된다.
- [ ] BEHAVIOR-PRINCIPLES §2 / §3 위반 없음 확인.
- [ ] adapter cascade가 필요한지 확인하고, 필요하면 scope 추가 제안 후 처리 또는 후속 Work로 분리.
- [ ] **R1 audit 결과 승인 전에는 `docs/AGENT-WORKFLOW.md` 본문이 수정되지 않는다. (R0 F2 hard stop)**
- [ ] AGENT-WORKFLOW.md 변경 후 changed-surface cascade audit 결과, adapter 수정 불필요 또는 후속 분리 결정이 기록된다. (R0 NTH-2)
- [ ] Codex R0 plan review가 `Cross-Agent Review And Discussion`에 기록된다.
- [ ] `docs/STATUS.md` Active pointer는 R0 합의/승인 전 변경하지 않는다.

## Verification

```
# 1. 라인 수 before/after
wc -l docs/AGENT-WORKFLOW.md

# 2. Context Routing 테이블 target 정합 — 존재하지 않는 파일 참조 없음
rg -n "docs/HARNESS-ARCHITECTURE|docs/HARNESS-MAINTAINER-GUIDE" docs/AGENT-WORKFLOW.md

# 3. stale pointer 점검
rg -rn "AGENT-WORKFLOW" docs/ .claude/commands/ .agents/skills/ skills/workflow/ | grep -v "\.md:#"

# 4. git diff --check
git diff --check

# 5. 검증 척추 (있으면)
bash scripts/tests/run-harness-checks.sh 2>/dev/null || echo "N/A or error — report result"

# 6. PLAN §3-a 3대 실패모드 self-check (서술)
# — ①라우팅 누락 개선 여부, ②비대화 라인 절감량, ③조건부 로딩 명세 강화 여부를 기록
```

## Risk / Reversal Cost

| 항목 | 내용 |
| --- | --- |
| Risk level | L2 (harness workflow surface; audit phase는 L1, 실제 변경은 L2. L3 변경 필요 판단 시 R1에서 scope 조정) |
| Reversal cost | Low — git reset으로 복원 가능. 단, 모든 tool이 AGENT-WORKFLOW.md를 참조하므로 pointer 삭제는 cascade 확인 후만 수행 |
| 주요 위험 ① | Audit 없이 직관으로 "정리"하다 실제 context에서 필요한 정보를 삭제함 → **Phase 1 Audit 완료가 Phase 2 필수 선행 조건** |
| 주요 위험 ② | "Optional pack 참조 주의" 블록 제거 시 adopter가 없는 파일을 참조해 세션 오류 발생 → row별 N/A 조건이 이미 충분한지 확인 필수 |
| scope creep 위험 | Non-goals 목록 엄수. AGENT-WORKFLOW.md 감사 중 "이것도 고치자"가 발생하면 Discovery에 기록하고 후속 Work로 분리 |

## Open Questions

| ID | Question | Default Assumption |
| --- | --- | --- |
| OQ-1 | "Optional pack 참조 주의" 블록을 테이블 밖 paragraph에서 제거하면 테이블 row 조건만으로 충분한가? | 감사 후 판단. row에 "(N/A if not in scaffold)" 조건이 있으면 충분하다고 본다 |
| OQ-2 | Phase 1 audit에서 "조건부 로드 섹션"이 발견될 경우, 새 slice 파일로 분리할 것인가 아니면 pointer-only 교체로 충분한가? | pointer-only 교체를 우선 검토. 분리는 근거가 명확할 때만 |
| OQ-3 | Approval Matrix가 상시 로드 필수인가, 아니면 일부 섹션은 조건부로 이동 가능한가? | **Resolved (R0 F1):** 상시 유지, audit-only로 잠김. 이 Slice에서 relocation 금지 |
| OQ-4 | adapter cascade(`.claude/commands/`, `.agents/skills/`)가 AGENT-WORKFLOW.md 내용에 종속된 섹션을 직접 참조하는가? | audit 중 `rg "AGENT-WORKFLOW"` 로 확인 |
| OQ-5 | 이 Slice 1이 완료된 뒤 Slice 2의 범위는? | Slice 2 후보: Prompt surface diet + optional pack 재정의, 또는 README 흐름 검토. 이 Work 완료 후 결정 |

## Cross-Agent Review And Discussion

### Round Log

| Round | Reviewer | Status | Summary | Follow-Up |
| --- | --- | --- | --- | --- |
| R0 | Codex | **Conditional Hold → 반영 완료** | F1~F4 지적: Scope 과잉 개방·audit gate 미흡·③ 과장·006 사실 오류. Must-fix 4건 + NTH-2건 반영. | Phase 1 Audit 진행 |

### R0 — Plan Review (Codex, 2026-06-12)

**Approval:** Conditional Hold → Must-fix 4건 반영 후 해소

**Findings**

- **F1 (Must-fix):** Scope 3의 "조건부 섹션 → conditional pointer 전환"이 Approval Matrix / State And Closeout Rules / Verification Defaults까지 열어두고 있어, "한 파일 audit"가 아니라 L3 canonical 계층 재설계로 성격이 바뀔 위험. Non-goals에 "Approval Matrix 내용 변경" 금지만 있고 위치 정리는 허용으로 남아 있었음.
- **F2 (Must-fix):** Phase 1→2 gate가 Plan에만 있고 Done Criteria에 hard-stop 문장이 없어, audit와 동시 수정이 자연스럽게 일어날 여지가 있음.
- **F3 (Must-fix):** ③선언-실행 괴리 기여 주장이 과장됨. adapter가 Non-goals인 상태에서 ③을 기본 정당화 근거로 쓰는 건 무리. audit에서 실제 mismatch 발견 시에만 인정으로 한정해야 함.
- **F4 (Must-fix):** Discovery에서 CHORE-20260612-006을 "Work 파일 없는 Quick Mode"로 오기. 실제로는 archived Work 파일 있음 (`docs/archive/docs/works/harness/CHORE-20260612-006-externalization-failure-modes.md`). lifecycle 사실관계 검증 습관 문제 지적.

**Nice-to-have**

- NTH-1: Files 섹션에 docs/works/README.md / STATUS.md가 tracking collateral임을 한 줄로 명시하면 "한 파일 Slice" 표현의 오해를 줄임.
- NTH-2: Done Criteria에 "AGENT-WORKFLOW.md 변경 후 changed-surface cascade audit 결과, adapter 수정 불필요 또는 후속 분리 결정이 기록된다" 추가.

**Review Questions 답변**

| 질문 | 답변 |
| --- | --- |
| Scope 제한성 | 불충분 (F1). conditional pointer 전환 범위가 너무 넓었음 |
| Audit → restructure gate | 방향은 맞지만 hard-stop 문장 부족 (F2) |
| PLAN §3-a 정당성 | ②는 충분, ①은 약하게 충분, ③은 과장 (F3) |
| L2 risk | F1 수정 전 상태면 사실상 L3로 미끄러질 수 있었음. 수정 후 L2 유지 가능 |
| 감사 전 선결정 OQ | OQ-3(Approval Matrix 상시 로드 여부)를 이 Slice에서 "상시 유지, audit-only"로 먼저 잠가야 함 |
| Done Criteria 누락 | "R1 audit 승인 전 무편집", "changed-surface cascade 판정 기록" 누락 |

**Claude 반영 계획 (Must-fix 4건)**

- F1 → Scope 3을 "Context Routing + 인라인 블록 + 명백 중복 prose"로 제한. Non-goals에 Approval Matrix / State / Verification Defaults / Work Item Routing "audit-only, relocation 금지" 명시.
- F2 → Phase 2 hard-stop 문장 추가 + Done Criteria에 "R1 승인 전 무편집" 항목 추가.
- F3 → ③ 행 "기본 목적 아님. audit에서 실제 mismatch 발견 시에만 부수 기여로 인정"으로 약화.
- F4 → Discovery 006 서술을 "archived Work 파일 있음"으로 정정.
- NTH-2 → Done Criteria에 cascade 판정 기록 항목 추가.
- OQ-3 → "Resolved (R0 F1): 상시 유지, audit-only로 잠김"으로 닫음.

## Discovery

- 2026-06-12: 세션 시작 확인 — Active Work 없음, Open Blocker 없음. Done archive pending Work 6개(≥5) PLAN 누적 드리프트 soft warning 대상이나, archive 처리는 이번 Work 범위 외.
- 2026-06-12: git status — `develop` branch, origin과 동기화됨.
- 2026-06-12: Work ID CHORE-20260612-007 부여. CHORE-20260612-006은 archived Work 파일 있음 (`docs/archive/docs/works/harness/CHORE-20260612-006-externalization-failure-modes.md`). 초안에서 "Quick Mode, Work 파일 없음"으로 오기했고 R0 Codex review에서 지적됨 (F4).
- 2026-06-12: PLAN.md §3-a 확인 — 3대 실패모드 framing이 W3 판단 기준으로 명문화됨. 이 Work의 "왜 지금" 정당화에 반영.
