---
id: CHORE-20260612-007
priority: P1
status: Done
risk: L2
scope: AGENT-WORKFLOW.md 한 파일의 비대화 점검 + context routing 테이블 구조 개선. README, HARNESS-PROTOCOL.md trigger family, docs/ 물리 레이아웃, skills/workflow/*, scaffold, adapter는 Non-goals다.
appetite: 1d
planned_start: 2026-06-12
planned_end: 2026-06-12
actual_end: 2026-06-12
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

- [x] AGENT-WORKFLOW.md 감사 결과가 이 Work 파일에 기록된다.
- [x] Context Routing 테이블에서 중복·stale row 또는 인라인 경고 블록이 제거되거나 pointer화된다 (감사 결과 필요한 경우).
- [x] 감사 결과 "현행 유지"가 맞는 항목은 그 근거가 기록된다. 변경 없음도 유효한 결과다.
- [x] PLAN.md §3-a 3대 실패모드 중 ①/② 중 하나 이상이 실질적으로 개선됐거나, 개선 없음의 근거가 명시된다.
- [x] BEHAVIOR-PRINCIPLES §2 / §3 위반 없음 확인.
- [x] adapter cascade가 필요한지 확인하고, 필요하면 scope 추가 제안 후 처리 또는 후속 Work로 분리.
- [x] **R1 audit 결과 승인 전에는 `docs/AGENT-WORKFLOW.md` 본문이 수정되지 않는다. (R0 F2 hard stop)**
- [x] AGENT-WORKFLOW.md 변경 후 changed-surface cascade audit 결과, adapter 수정 불필요 또는 후속 분리 결정이 기록된다. (R0 NTH-2)
- [x] Codex R0 plan review가 `Cross-Agent Review And Discussion`에 기록된다.
- [x] `docs/STATUS.md` Active pointer는 R0 합의/승인 전 변경하지 않는다.

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

## Phase 1 Audit Findings

### 섹션별 라인 분류표

| 섹션 | 줄 | 범위 | 상시/조건부 | 비고 |
| --- | --- | --- | --- | --- |
| Preamble | 7 | L1–7 | 상시 | 필수 진입 설명 |
| Session Startup | 26 | L8–33 | 상시 | MUST/MUST NOT 실행 규칙 |
| **Context Routing** | **4** | **L34–37** | **△ 제거 대상** | **헤딩 + Optional pack 경고만. 라우팅 테이블 없음 — section-local stale warning** |
| Operating Tracks + 라우팅 테이블 | 32 | L38–69 | 상시 | 트랙 설명(10줄) + 라우팅 테이블(18행) + post-table(3줄) |
| State Machine | 12 | L71–83 | 상시 | 다이어그램 + 3개 규칙 |
| Approval Matrix | 24 | L84–107 | 상시 (locked) | 핵심 게이트. audit-only per R0 F1 |
| Work Item Routing | 15 | L108–122 | 상시 (locked) | 라우팅 테이블과 overlap 존재 — Slice 2 Discovery |
| Risk Levels | 10 | L124–133 | 상시 | 표 + 2개 주석 |
| STATUS Rules | 12 | L135–145 | 상시 | MUST 규칙 |
| State And Closeout Rules | 18 | L147–164 | 상시 (locked) | 핵심 closeout 절차. audit-only per R0 F1 |
| Trigger And Naming Pointers | 10 | L166–175 | 조건부 | 변경 시에만 필요한 HARNESS-PROTOCOL pointer |
| Project Constants | 9 | L177–184 | 낮음 | 정적 메타정보. 실행 중 거의 참조 안 함 |
| Verification Defaults | 12 | L186–197 | 조건부 (locked) | audit-only per R0 F1 |
| **합계** | **197줄** | | | |

### Key Findings

**A1 — section-local stale warning (ACTIONABLE, Slice 1 scope 안):** `## Context Routing` 헤딩(L34) 아래의 Optional pack 경고 블록(L36)이 이 파일의 라우팅 테이블과 연결되지 않는다. 경고가 참조하는 `HARNESS-ARCHITECTURE.md`, `HARNESS-MAINTAINER-GUIDE.md`의 routing row가 이 파일 라우팅 테이블에 없고, `HARNESS-PROTOCOL.md`가 동일 경고 + 실제 routing row를 보유. → 이 파일의 경고는 section-local stale warning으로 제거 가능. ②비대화 개선(noise 제거). ①라우팅에는 약하게 기여(section 내 mismatch 제거). **`## Context Routing` 헤딩 자체는 유지한다.**

**A2 — `docs/backlog/PRODUCT.md` row 없음 (NOT a bug):** `ls docs/backlog/` → HARNESS.md만 존재. 단, source repo 설계 의도(Operating Tracks: "Product track이 비어있을 수 있다")와 일치하는 expected 상태. 변경 불필요.

**A3 — Work Item Routing ↔ 라우팅 테이블 overlap (Discovery, Slice 2 후보):** 같은 대상 문서가 두 테이블에 중복 등장. Work Item Routing은 R0 F1에 의해 audit-only, relocation 금지. Slice 2에서 검토.

**A4 — `## Operating Tracks` 이중 역할 (Discovery, **Slice 2로 잠금**):** 트랙 설명(L38–47) + 라우팅 테이블(L48–65)이 한 섹션. 개념적으로 다른 두 내용. 이번 Slice에서 건드리지 않는다. `## Context Routing` 헤딩의 empty body 문제도 이 구조 문제와 맞물리며 Slice 2에서 함께 해결한다.

### 개선안 (R1 승인 요청 대상)

변경 1건: **Optional pack 경고 블록 + trailing blank 삭제 (L36–37만. `## Context Routing` 헤딩 L34 유지)** (R1 F1 반영)

```diff
 ## Context Routing

-> **Optional pack 참조 주의:** `docs/HARNESS-ARCHITECTURE.md`, `docs/HARNESS-MAINTAINER-GUIDE.md`는 Optional source pack이라 minimal scaffold에는 없을 수 있다. 이들을 가리키는 routing 항목은 해당 문서가 없으면 N/A이며, 필요하면 `scripts/create-harness.sh --with-optional`로 재생성하거나 source repo 문서를 참조한다.
-
 ## Operating Tracks
```

- **근거:** 경고가 가리키는 두 파일의 routing row가 이 파일에 없어 stale. `HARNESS-PROTOCOL.md`가 동일 경고 + 실제 routing row 보유. `## Context Routing` 헤딩 자체는 Slice 2 구조 정비 전까지 유지.
- 순 라인 변화: −2줄 (197 → 195줄)
- Reversal cost: git reset으로 즉시 복원 가능
- cascade: live surface에서 `#context-routing` anchor 직접 참조 케이스 없음

> **이번 Slice에서 건드리지 않는 것:** `## Context Routing` 헤딩, `## Operating Tracks`의 이중 역할(트랙 설명 + 라우팅 테이블 혼재), Work Item Routing ↔ 라우팅 테이블 중복. 이 구조 문제들은 Slice 2로 잠금. (R1 F1/F3)

### 실패모드 mapping (PLAN §3-a 기준)

| Failure mode | 이 변경의 기여 |
| --- | --- |
| ①라우팅 누락 | 약하게 개선 — section-local stale warning 제거로 section 내 mismatch 감소. 헤딩 구조 문제는 Slice 2 (R1 F2) |
| ②비대화 | **개선됨** — 2줄 삭제 + row 없는 stale 경고 제거로 noise 절감 |
| ③선언-실행 괴리 | 기여 없음 (예상 결과, plan 대로) |

---

## Cross-Agent Review And Discussion

### Round Log

| Round | Reviewer | Status | Summary | Follow-Up |
| --- | --- | --- | --- | --- |
| R0 | Codex | **Conditional Hold → 반영 완료** | F1~F4 지적: Scope 과잉 개방·audit gate 미흡·③ 과장·006 사실 오류. Must-fix 4건 + NTH-2건 반영. | Phase 1 Audit 진행 |
| R1 | Codex | **Conditional Hold → 반영 완료** | F1: 헤딩 유지, 경고 블록만 삭제로 scope 재정의. F2: "구조적 버그" 표현 하향. F3: Slice 2 잠금 명시. | Phase 2 구현 진행 |

### R1 — Result Review (Codex, 2026-06-12)

**Approval:** Conditional Hold → Must-fix 3건 반영 후 해소

**Findings**

- **F1 (Must-fix):** 제안 변경이 Optional pack 경고 블록 + `## Context Routing` 헤딩을 함께 삭제했는데, 헤딩 삭제는 Slice 1 scope를 벗어남. `## Operating Tracks` 이중 역할(Discovery A4/A5)을 아직 해결하지 않은 상태에서 헤딩만 먼저 제거하면 routing section 자체가 소거된 것처럼 읽힌다. 경고 블록만 삭제, 헤딩 유지로 범위 재정의.
- **F2 (Must-fix):** "구조적 버그 (①라우팅 누락)" 표현이 과함. live surface에서 `#context-routing` anchor 직접 참조는 없으나, archived Work/retrospective들에서 섹션명으로 계속 참조됨. 실제 문제는 section이 완전히 깨진 것이 아니라 "section 내부 배치가 어색하고 stale 경고가 붙어 있다" 수준. "section-local stale warning / section-local mismatch"로 하향.
- **F3 (Must-fix):** Result summary 또는 Discovery에 "Operating Tracks ↔ routing table 구조 문제는 Slice 2로 잠금", "이번 Slice는 경고 블록 삭제까지만 수행"을 명시.

**Review Questions 답변**

| 질문 | 답변 |
| --- | --- |
| `## Context Routing` 삭제가 anchor 참조되는가? | live surface 기준 직접 `#context-routing` anchor 참조 없음. archived Work/retrospective에서 섹션명으로 개념 참조는 존재. anchor breakage는 비블로킹이나 헤딩 삭제는 개념 일관성 차원에서 비추천 |
| Optional pack 경고 제거 시 다른 곳에서 필요한가? | AGENT-WORKFLOW.md 라우팅 테이블에 해당 파일 row 없으므로 제거 타당. HARNESS-PROTOCOL.md가 실제 row + 경고 보유 |
| Discovery 중 Slice 1에서 먼저 처리할 게 있는가? | 없음. `## Operating Tracks` 이중 역할은 건드리지 않음 |
| 변경 1건으로 Done Criteria 닫히는가? | 가능. 단 그 1건은 Optional pack 경고 블록 삭제여야 함 |

**Claude 반영 계획 (Must-fix 3건)**

- F1 → 변경 범위를 "경고 블록(L36) + trailing blank(L37) 삭제, 헤딩(L34) 유지"로 재정의
- F2 → Audit A1 표현을 "section-local stale warning / section-local mismatch"로 하향
- F3 → 개선안 Note에 "이번 Slice는 경고 블록 삭제까지만, Slice 2로 잠금" 명시

---

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
- 2026-06-12: **BEHAVIOR-PRINCIPLES §2/§3 자체 점검** — 변경 2줄 삭제, scope creep 없음. §2(Simplicity First): 최소 변경. §3(Surgical Changes): 경고 블록만 제거, 인접 섹션 미변경. 위반 없음.
- 2026-06-12: **adapter cascade 확인** (`rg "AGENT-WORKFLOW"` in `.claude/commands/`, `.agents/skills/`, `skills/workflow/`) — 모든 참조가 파일명 단위 generic 참조이며, 삭제된 Optional pack 경고 블록에 종속된 section-specific 참조 없음. adapter 수정 불필요. 후속 Work로 분리할 cascade 항목 없음.
- 2026-06-12: **backlog 처리** — 부모 항목 "Canonical 개념 계층화 + context-routing restructure"(P1/L3)는 Slice 2+ 잔여 작업 포함. Slice 1 완료 후 이 항목 자체는 유지. 삭제 N/A.
- 2026-06-12: **PLAN.md 영향** — W3 roadmap 방향 변경 없음. 2줄 제거는 W3 내 첫 micro-step. PLAN-SUMMARY.md stale 아님.
