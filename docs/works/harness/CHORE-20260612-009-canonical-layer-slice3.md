---
id: CHORE-20260612-009
priority: P1
status: Done
risk: L2
scope: AGENT-WORKFLOW.md 한 파일 — ## Work Item Routing 섹션의 ## Context Routing 테이블 중복 여부 감사 + 중복 해소 최소 변경. 다른 파일 수정 없음.
appetite: 0.5d
planned_start: 2026-06-12
planned_end: 2026-06-12
actual_end: 2026-06-12
related_dr: [DR-021, DR-023]
related_work: [CHORE-20260612-007, CHORE-20260612-008]
---

# CHORE-20260612-009: Canonical 계층화 Slice 3 — Work Item Routing 중복 감사 + 해소

## Top Summary

- **목표:** `## Work Item Routing` 7행이 `## Context Routing` 테이블과 중복되는지 감사하고, 중복이면 최소 변경으로 해소한다. 섹션 제거·통합·유지 중 하나를 감사 결과로 확정한다.
- **왜 지금:** Slice 1·2가 routing table을 제자리에 놓고 섹션 이중 역할을 분리했다. A3 overlap 잠금이 자연스럽게 해제되는 시점이다.
- **핵심 경계:** `docs/AGENT-WORKFLOW.md` 한 파일만. Slice 3에서 locking된 섹션 순서 재판단은 감사 결과에서 필요성이 보이면 Slice 4 후보로만 기록한다.
- **역할:** Claude = author/driver, Codex = red team reviewer.

## 왜 지금 이 Work인가 (PLAN §3-a 렌즈)

| Failure mode | 이 Work와의 연결 |
| --- | --- |
| ①라우팅 누락 | `## Work Item Routing`과 `## Context Routing` 간 역할 경계 명확화 |
| ②비대화 | 중복 6행 + 관련 pointer 1줄 제거 시 ~12줄 절감 가능 |
| ③선언-실행 괴리 | 두 라우팅 테이블이 같은 문서를 가리키면서 다른 질문에 답한다고 선언되지만, 실제 독자는 구분하기 어렵다 |

## Background / Facts

Slice 1·2 이후 AGENT-WORKFLOW.md 현재 상태:

```
## Context Routing (L34)
  routing table 15행 — "Need X → Load Y" (read/load 질문)

## Work Item Routing (L106)
  routing table 7행 — "Item X → Where Y" (write/register 질문)
  + 관련 prose 2줄 (/work-register 안내, Work ID 형식 pointer)
```

**overlap 분석:**

| 문서 | Context Routing | Work Item Routing | 비고 |
| --- | --- | --- | --- |
| `docs/STATUS.md` | "현재 상태" | "지금 진행 중인 작업" | **"문서 동일 but 질문 다름" 대표 예외** — load context vs Active Work 위치 (R0 NTH) |
| `docs/backlog/PRODUCT.md` | "Product track 작업 선택" | "다음 후보 Product track 작업" | 거의 동일 |
| `docs/backlog/HARNESS.md` | "harness, command/rule 작업 선택" | "하네스/명령/rule/hook 개선" | 거의 동일 |
| `docs/BOOTSTRAP.md` | "Scaffold 직후 프로젝트 부팅" | "Scaffold bootstrapping checklist" | 거의 동일 |
| `docs/works/{category}/...` | "큰 작업의 SSoT" | "큰 작업의 SSoT" | 동일 |
| `docs/decisions/DR-*.md` | "관련 기술 결정" | "결정 근거" | 거의 동일 |
| `docs/archive/` | "과거 Phase 맥락" | "완료된 과거 상태" | 거의 동일 |

Work Item Routing에만 있고 Context Routing에 없는 문서: **없음.**
Context Routing에만 있고 Work Item Routing에 없는 문서: 8개 (`SCAFFOLD-BOOTSTRAP.md`, `HARNESS-QUICK-REFERENCE.md`, `HARNESS-NAMING-RULES.md`, `HARNESS-RECOVERY-VALIDATION.md`, `HARNESS-PARALLEL-WORK-CONTROLS.md`, `PLAN-SUMMARY.md`, `PLAN.md`, `docs/retrospectives/`, `docs/troubleshooting/`)

Work Item Routing 후속 prose:
- L118: "새 작업 항목 등록은 `/work-register`로 수행한다…" (등록 절차 안내)
- L120: "Work ID 형식 상세 기준: `docs/HARNESS-NAMING-RULES.md`" (HARNESS-NAMING-RULES는 Context Routing에 이미 있음)

## Scope / Non-Goals

### Scope

1. `## Work Item Routing` 섹션 감사:
   - 7행의 고유 가치 판정 (Context Routing와 실질적으로 다른 정보를 제공하는가?)
   - 후속 prose 2줄의 귀속 판정 (섹션 제거 시 어디로 이전 또는 삭제할지)
2. 감사 결과 기반 최소 변경 제안 (R1 승인 대상). 기본 선호는 **B 또는 C 우선, A는 stricter gate** (R0 NTH):
   - **B) 섹션 유지 + 역할 명시:** 고유 관점이 있음 → 헤딩 아래 1줄 역할 설명 추가로 Context Routing과 구분
   - **C) 부분 정리:** 일부 행 제거 + prose 이전
   - **A) 섹션 제거:** L118/L120 prose가 **완전 삭제 가능할 때만** 허용. prose 이전이 필요하면 A는 보류 또는 후속 Slice로 분리 (R0 F3)

**방향 선택 기준 (R0 F1):**

| 축 | A 선택 조건 | B/C 선택 조건 |
| --- | --- | --- |
| 대상 문서 set이 완전 중복인가? | 7행 전부 중복 → A 후보 | 고유 행 있음 → B/C |
| 고유 문장이 남는가? (L118/L120) | 삭제 가능 → A 허용 | 삭제 불가 → A 불가 |
| 그 문장을 다른 섹션으로 옮기지 않고 닫힐 수 있는가? | 삭제만으로 해결 → A 허용 | 이전 필요 → A 불가, B/C |
| 질문 유형 차이가 독립 섹션을 유지할 만큼 실질적인가? | 차이 미미 → A/C | 차이 실질적 → B |

### Non-Goals

- `## Context Routing` 테이블 내용 변경
- `## Session Startup` 또는 다른 섹션으로 prose 이전 — 이번 Slice에서 `/work-register` prose(L118)를 Session Startup으로 이동하지 않는다. 그 이전이 필요해 보이면 방향 A는 보류 또는 후속 Slice로 분리한다. (R0 F2/F3)
- Approval Matrix / State And Closeout Rules / Verification Defaults 변경
- 섹션 순서 변경 — 감사 결과에서 필요성이 보이면 Slice 4 후보로만 기록
- 새 파일 생성
- **`## Work Item Routing` 섹션 본문을 R1 승인 전에 수정하지 않는다**

## Files

| 파일 | 계획 |
| --- | --- |
| `docs/AGENT-WORKFLOW.md` | Phase 2에서 승인된 항목만 최소 수정 |
| `docs/works/harness/README.md` | Active에 이 Work 등록 — tracking collateral |
| `docs/STATUS.md` | R0 합의 후 Active pointer 추가 — tracking collateral |
| 이 Work 파일 | plan, audit findings, Codex review Round Log SSoT |

## Plan

### Phase 1 — Audit (R0 승인 후)

1. `## Work Item Routing` 각 행의 고유 가치 판정 — Context Routing과 질문 유형이 실질적으로 다른가?
2. 후속 prose 2줄 처리 방안 판정
3. 방향 A/B/C 중 하나를 선택하고 구체적 변경안 작성
4. **R1 audit 결과 보고 + 제안 변경 → 승인 대기**

## Phase 1 Audit Findings (2026-06-12)

### 1. 7행 고유 가치 판정

| Item | 문서 | 판정 | 근거 |
| --- | --- | --- | --- |
| 지금 진행 중인 작업 | `docs/STATUS.md` Active Work | **UNIQUE** | Context Routing: "현재 상태" (read) vs Work Item Routing: "지금 진행 중인 작업 + Active Work 섹션 명시" (write/track) — 관점과 세부 위치가 다름 |
| 다음 후보 Product track 작업 | `docs/backlog/PRODUCT.md` | REDUNDANT | Context Routing에 "Product track 작업 선택"으로 동일 문서 있음 |
| 하네스/명령/rule/hook 개선 | `docs/backlog/HARNESS.md` | REDUNDANT | Context Routing에 "harness, command/rule 작업 선택"으로 동일 문서 있음 |
| Scaffold bootstrapping checklist | `docs/BOOTSTRAP.md` | REDUNDANT | Context Routing에 동일 조건부 로드 안내 있음 |
| 큰 작업의 SSoT | `docs/works/{category}/` | REDUNDANT | Context Routing에 동일 설명·경로 있음 |
| 결정 근거 | `docs/decisions/DR-*.md` | REDUNDANT | Context Routing에 "관련 기술 결정"으로 있음 |
| 완료된 과거 상태 | `docs/archive/` | REDUNDANT | Context Routing에 "과거 Phase 맥락"으로 있음 |

**UNIQUE 행: 1 (STATUS.md). REDUNDANT 행: 6.**

### 2. L118/L120 prose 처리 방안

| 줄 | 내용 | 판정 | 근거 |
| --- | --- | --- | --- |
| L120 | `docs/HARNESS-NAMING-RULES.md` pointer | **삭제 가능** | Context Routing table에 이미 "Work ID·OQ ID·DR ID 부여·검증, 파일명 규칙 → `docs/HARNESS-NAMING-RULES.md`" row 존재 |
| L118 | `/work-register` 등록 절차 안내 | **삭제 불가** | TYPE 판단(FEAT/PATCH/HOTFIX/CHORE), backlog slug-only 정책, Work ID는 `/work-plan`에서 확정 — 이 상세가 session 기본 로드 표면(HARNESS-QUICK-REFERENCE.md 포함) 어디에도 없음. HARNESS-QUICK-REFERENCE.md L34/L59는 `/work-register` 명칭만 언급, 절차 없음 |

### 3. 4축 방향 선택

| 축 | 판정 | 결과 |
| --- | --- | --- |
| 대상 문서 set이 완전 중복인가? | 완전 중복 (UNIQUE 행 1개, REDUNDANT 6개) | A 후보 |
| 고유 문장이 남는가? (L118) | **L118 삭제 불가** | **A 불가** |
| 그 문장을 다른 섹션으로 옮기지 않고 닫힐 수 있는가? | 이전 없이 불가 (Session Startup 이전 = OQ-2 잠금) | **A 불가** |
| 질문 유형 차이가 실질적인가? | STATUS.md 1행만 실질적 차이. 나머지 6행 미미 | C 선호 |

→ **선택 방향: C — Partial cleanup**

### 4. Direction C 구체적 변경안

```diff
 ## Work Item Routing

 이 섹션은 문서를 읽기 위한 load map이 아니라, 현재 작업을 어떤 tracker에서 관리하거나 갱신하는지 보여주는 write/track 관점 라우팅이다.

 | Item | Where |
 | --- | --- |
 | 지금 진행 중인 작업 | `docs/STATUS.md` Active Work |
-| 다음 후보 Product track 작업 | `docs/backlog/PRODUCT.md` |
-| 하네스/명령/rule/hook 개선 | `docs/backlog/HARNESS.md` |
-| Scaffold bootstrapping checklist | `docs/STATUS.md` Next Actions가 bootstrap/onboarding을 명시할 때 `docs/BOOTSTRAP.md` |
-| 큰 작업의 SSoT (실행 계획·세부 분해) | `docs/works/{category}/{ID}-{topic}.md` |
-| 결정 근거 | `docs/decisions/DR-*.md` |
-| 완료된 과거 상태 | `docs/archive/` |

 새 작업 항목 등록은 `/work-register`로 수행한다. 등록 시 TYPE(FEAT/PATCH/HOTFIX/CHORE)을 판단하고 backlog 후보는 제목/slug만 유지한다. Work ID는 `/work-plan` 착수 승인 후 Work 파일 생성 시 확정한다.

-Work ID 형식 상세 기준: `docs/HARNESS-NAMING-RULES.md`
```

**Net effect:** ~13줄 감소. Context Routing/Session Startup/타 섹션 변경 없음.
**Direction C 보강:** UNIQUE한 `docs/STATUS.md` 1행의 의미 보존을 위해 `## Work Item Routing` 역할 문장 1줄을 추가한다. prose-only 전환보다 table 유지가 더 작은 변경이다.

### 5. Slice-local implementability 확인

- Context Routing 변경 없음 ✓
- Session Startup 변경 없음 ✓
- L118 prose는 그 자리에 유지 (이전 없음) ✓
- 섹션 순서 변경 없음 ✓
- **완전 slice-local 구현 가능** ✓

### 6. 적용 결과

- REDUNDANT 6행 제거 (`PRODUCT`, `HARNESS`, `BOOTSTRAP`, `works`, `DR`, `archive`)
- UNIQUE한 `docs/STATUS.md` Active Work 1행 유지
- `## Work Item Routing` 역할 문장 1줄 추가
- L118 prose 재서술: `위 위치` 표현 제거, self-contained 문장으로 축소
- L120 `HARNESS-NAMING-RULES.md` pointer 삭제
- `## Context Routing` / `## Session Startup` / 섹션 순서 변경 없음

### Phase 2 — 최소 변경 적용 (R1 승인 후)

> **Hard stop: R1 결과 승인 전에는 `docs/AGENT-WORKFLOW.md` 본문을 수정하지 않는다.**

1. 승인된 방향(A/B/C) 적용
2. Verification 수행

### Phase 3 — Closeout

## Done Criteria

- [x] `## Work Item Routing` 각 행의 고유 가치 판정이 Work 파일에 기록된다
- [x] 후속 prose 2줄의 처리 방안이 기록된다
- [x] 방향 A/B/C 선택 근거가 명시된다
- [x] BEHAVIOR-PRINCIPLES §2/§3 위반 없음 (최소 변경 원칙)
- [x] **선택한 방향이 `## Context Routing` / `## Session Startup` / 타 섹션 수정 없이 이번 Slice 범위 안에서 구현 가능한지 확인된다.** (R0 F4)
- [x] Codex R0 plan review, R1 result review가 Work 파일에 기록됨
- [x] `docs/STATUS.md` Active pointer는 R0 합의/승인 전 변경하지 않는다

## Verification

```bash
wc -l docs/AGENT-WORKFLOW.md
grep -n "^##" docs/AGENT-WORKFLOW.md
git diff --check
```

## Risk / Reversal Cost

| 항목 | 내용 |
| --- | --- |
| Risk level | L2 — harness workflow surface |
| Reversal cost | Low — git reset으로 즉시 복원 |
| 주요 위험 | `/work-register` 안내 prose(L118)가 Work Item Routing 제거 시 참조 불명확해짐. 제거 방향이면 prose를 Context Routing 아래 또는 Session Startup에 이전하는지 판단 필요 |
| scope creep 위험 | 감사 중 Approval Matrix나 다른 섹션의 overlap 발견 시 Discovery만 기록, 건드리지 않음 |

## Open Questions

| ID | Question | Default Assumption |
| --- | --- | --- |
| OQ-1 | `## Work Item Routing`이 "write 관점 라우팅"으로 실질적 고유 가치가 있는가? | 감사 전 열린 질문. 판단 기준(R0 F1): 대상 문서 중복도 + 질문 유형 실질 차이 + 고유 문장 처리 가능성 3축으로 종합 판단. `docs/STATUS.md`처럼 "문서 동일 but 질문 다름"인 행이 다수면 B/C 선호. 7행 전부 삭제 가능하면 A 허용. |
| OQ-2 | `/work-register` 안내 prose(L118)를 어디로? | **잠금 (R0 F2/F3):** 이번 Slice에서 Session Startup 이전 금지. 방향 A 시 삭제 가능 여부 먼저 확인. 삭제 불가하면 A 보류. |

## Cross-Agent Review And Discussion

### Round Log

| Round | Reviewer | Status | Summary | Follow-Up |
| --- | --- | --- | --- | --- |
| R0 | Codex | **Conditional Hold → 반영 완료** | F1: A/B/C 선택 기준 추상적. F2: OQ-2 Session Startup 이전 금지 잠금. F3: 방향 A 실행 조건 명시(prose 삭제 가능할 때만). F4: Done Criteria에 slice-local implementability 확인 항목 추가. | Phase 1 Audit 진행 |
| R1 | Codex | **Approved** | Direction C 유지. 단, 1행 table 의미 보존을 위한 역할 문장 1줄 + L118 self-contained 재서술 필요 | 반영 후 closeout |

### R0 — Plan Review (Codex, 2026-06-12)

**Approval:** Conditional Hold → Must-fix 4건 반영 후 해소

**Findings**

- **F1 (Must-fix):** 방향 A/B/C 선택 기준이 추상적. OQ-1의 "read vs write 관점 차이" 판단 기준이 없어 감사자가 어떤 방향을 선택해야 할지 흔들린다. 4축 기준표(문서 중복도, 고유 문장 존재, 삭제 가능성, 질문 유형 차이) 추가 필요.
- **F2 (Must-fix):** OQ-2의 `/work-register` prose 귀속이 열린 상태. Session Startup 이전은 이번 Slice scope creep 성격이 강하다. 기본값은 "Session Startup 이전 금지, 이전 필요하면 A 보류"로 잠가야 한다.
- **F3 (Must-fix):** 방향 A(섹션 제거)의 실행 조건이 없다. "L118/L120 prose가 완전 삭제 가능할 때만 허용"이라는 gate 필요. 삭제 불가하면 A 보류 또는 후속 Slice 분리.
- **F4 (Must-fix):** Done Criteria에 "선택한 방향이 Context Routing/Session Startup/타 섹션 수정 없이 이번 Slice 범위 안에서 구현 가능한지 확인된다" 항목 누락.

**Nice-to-have**

- NTH-1: A/B/C 나열 시 기본 선호 방향 표시 (B/C 우선, A는 stricter gate)
- NTH-2: overlap 표에서 `docs/STATUS.md`를 "문서 동일 but 질문 다름" 대표 예외로 표시

**Claude 반영 계획**

- F1 → Scope에 방향 선택 기준 표 추가 (4축)
- F2 → Non-goals에 Session Startup 이전 금지 잠금. OQ-2 기본값 강화
- F3 → Scope에 방향 A 실행 가능 조건 명시 (prose 삭제 가능할 때만)
- F4 → Done Criteria에 slice-local implementability 확인 항목 추가
- NTH-1 → 방향 B/C 우선, A stricter gate 명시
- NTH-2 → overlap 표 STATUS.md 예외 표시

---

## Discovery

- 2026-06-12: CHORE-20260612-007 Slice 1에서 A3로 등록 ("Work Item Routing ↔ 라우팅 테이블 overlap, audit-only, relocation 금지"). Slice 2에서 "발견만, 수정 금지"로 유지. 이 Work에서 잠금 해제.
- 2026-06-12: overlap 사전 분석 — Work Item Routing 7행 전부 Context Routing에도 등장. Work Item Routing에만 있는 문서 없음. 단, 관점(read vs write/register)은 다를 수 있어 감사에서 고유 가치 판정 필요.
- 2026-06-12: Codex R1 result review 반영. Direction C는 유지하되, 1행 table 의미 보존을 위해 역할 문장 1줄을 추가하고 L118 prose를 self-contained 문장으로 재서술했다. prose-only 전환은 형식 변경이 더 커서 배제했다.

### R1 — Result Review (Codex, 2026-06-12)

**Approval:** Approved

**Findings**

- Direction C는 타당하다. REDUNDANT 6행 제거 후 `docs/STATUS.md` Active Work 1행만 남겨도 고유 가치가 있다.
- 다만 1행 table만 남으면 섹션 유지 이유가 약해지므로, `## Work Item Routing`이 load map이 아니라 write/track 관점이라는 역할 문장 1줄이 필요하다.
- L118 prose의 `위 위치` 표현은 row 삭제 후 의미가 무너지므로 self-contained 문장으로 재서술해야 한다.
- prose-only 전환보다 table 유지 + 역할 문장 보강이 더 작은 변경이다.
