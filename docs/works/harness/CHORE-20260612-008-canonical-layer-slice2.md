---
id: CHORE-20260612-008
priority: P1
status: Done
risk: L2
scope: AGENT-WORKFLOW.md 한 파일의 구조 분리 — routing table을 ## Context Routing 아래로 이동, ## Operating Tracks를 트랙 설명 전용으로 정리. 다른 파일 수정 없음.
appetite: 0.5d
planned_start: 2026-06-12
planned_end: 2026-06-12
actual_end: 2026-06-12
related_dr: [DR-021, DR-023]
related_work: [CHORE-20260612-007]
---

# CHORE-20260612-008: Canonical 계층화 Slice 2 — Context Routing / Operating Tracks 구조 분리

## Top Summary

- **목표:** Slice 1이 남긴 구조적 부채 해소. `## Context Routing` 빈 헤딩을 채우고 `## Operating Tracks`의 이중 역할을 제거한다. routing table을 `## Context Routing` 아래로 이동, `## Operating Tracks`는 트랙 설명만 유지.
- **왜 지금:** Slice 1이 Optional pack 경고 블록을 제거하면서 `## Context Routing` 헤딩이 body 없는 빈 상태가 됐다. 이 상태는 ③선언-실행 괴리 후보이며 Slice 2에서 해결하기로 명시적으로 잠근 사안이다.
- **핵심 경계:** AGENT-WORKFLOW.md 한 파일만. `## Work Item Routing` ↔ routing table overlap(A3)은 Slice 3으로 잠금.
- **역할:** Claude = author/driver, Codex = red team reviewer.

## 왜 지금 이 Work인가 (PLAN §3-a 렌즈)

| Failure mode | 이 Work와의 연결 |
| --- | --- |
| ①라우팅 누락 | routing table이 `## Context Routing` 아래로 정착 → 섹션 의도와 내용이 일치 |
| ②비대화 | 순 줄 수 변화 없음. 구조 명확화 |
| ③선언-실행 괴리 | **주 효과.** `## Context Routing` 헤딩이 존재하지만 내용이 없는 상태 해소. `## Operating Tracks`가 "라우팅 테이블도 담당"하는 혼재 상태 해소 |

## Background / Facts

Slice 1(CHORE-20260612-007) 이후 AGENT-WORKFLOW.md 현재 상태 (195줄):

```
L34: ## Context Routing        ← body 없는 빈 헤딩 (Slice 1 부채)
L36: ## Operating Tracks       ← 이중 역할
L38-44:   tracks description (Product/Harness 트랙 설명 + note 2줄)
L46-63:   routing table (18행 — Context Routing 내용)
L65:   post-table prose L1: "조건이 없으면 추가 문서를 로드하지 않는다."
L66:   post-table prose L2: "core 문서에 조건부로만 실행되는 상세 절차·체크리스트가 축적될 경우..."
L67:   post-table prose L3: "회고는 backlog를 대체하지 않는다..."
```

post-table prose 귀속 판정(OQ-1)은 Phase 1 line-by-line 분류에서 확정한다.

`## Context Routing` 헤딩이 존재하지만 routing table은 `## Operating Tracks` 아래에 있다. Slice 1 R1 F1이 헤딩 삭제를 막고 구조 정비를 Slice 2로 잠근 것이 이 상태.

Anchor cascade 확인 결과 (Phase 1 pre-check): `#context-routing` / `#operating-tracks` 직접 anchor 참조 live surface 없음. `HARNESS-ARCHITECTURE.md`, `HARNESS-PROTOCOL.md`, `WORKFLOW-MANUAL.md`는 각자 동명 섹션을 보유하거나 텍스트 참조만 있음.

## Scope / Non-Goals

### Scope

1. `docs/AGENT-WORKFLOW.md` 구조 분리:
   - routing table(18행) + post-table prose(3줄) → `## Context Routing` 아래로 이동
   - `## Operating Tracks` → 트랙 설명(~8줄)만 유지

### Non-Goals

- `## Work Item Routing` 내용·위치·주변 문구 변경 — **overlap이 보여도 이번 Slice에서는 본문/위치/주변 문구를 수정하지 않는다. Discovery에만 기록한다.** (R0 F2)
- 섹션 순서 변경 — 이동 후에도 `## Context Routing` → `## Operating Tracks` 현 순서를 유지한다. 순서 변경 필요성이 보이면 Slice 3 후보로만 기록한다. (R0 F3)
- Approval Matrix / State And Closeout Rules / Verification Defaults 변경
- 다른 파일 수정, 새 파일 생성
- 내용 변경·재작성 (이동만 수행. 단, post-table prose 귀속은 Phase 1 line-by-line 판정 후 결정)

## Files

| 파일 | 계획 |
| --- | --- |
| `docs/AGENT-WORKFLOW.md` | routing table + post-table prose를 `## Context Routing`으로 이동. `## Operating Tracks`는 트랙 설명만 유지 |
| `docs/backlog/HARNESS.md` | 완료 시 parent item row 유지 (Slice 2 완료지만 parent item 미소진) — **tracking collateral** |
| `docs/works/harness/README.md` | Active에 이 Work 등록 — **tracking collateral** |
| `docs/STATUS.md` | R0 합의 후 Active pointer 추가 — **tracking collateral** |
| 이 Work 파일 | plan, audit, Codex review Round Log SSoT |

## Plan

### Phase 1 — Pre-move 점검 (R0 승인 후)

1. `## Context Routing` → `## Operating Tracks` 사이 정확한 내용 재확인 (현재 blank 2줄)
2. routing table row target 전원 존재 확인 (Slice 1에서 확인 완료이나 재확인)
3. post-table prose 3줄이 routing 맥락에 속하는지 확인 → `## Context Routing`으로 함께 이동 대상 여부 최종 판단
4. **R1 point-check 결과 Codex/사용자에게 보고 → 승인 대기**

### Phase 2 — 구조 분리 적용 (R1 승인 후)

> **Hard stop: R1 점검 결과 승인 전에는 `docs/AGENT-WORKFLOW.md` 본문을 수정하지 않는다. 섹션 순서 결정·변경도 R1 승인 전 금지한다. (R0 F3)**

1. routing table + post-table prose → `## Context Routing` 아래로 이동
2. `## Operating Tracks` → 트랙 설명만 남김
3. Verification 수행

### Phase 3 — Closeout

1. Done Criteria 체크
2. `/work-close` 절차 실행

## Done Criteria

- [x] `## Context Routing` 헤딩 아래에 실제 routing table이 위치한다
- [x] `## Operating Tracks` 섹션이 트랙 설명만 포함한다 (routing table 없음)
- [x] routing table row target 전원 존재 확인 기록
- [x] BEHAVIOR-PRINCIPLES §2/§3 위반 없음 (이동만, 내용 변경 없음)
- [x] adapter cascade 확인 — anchor 직접 참조 없음 기록
- [x] **post-table prose 각 줄의 귀속(Context Routing / Operating Tracks / 후속 Slice)이 기록된다.** (R0 F5)
- [x] Codex R0 plan review, R1 result review가 Work 파일에 기록됨
- [x] `docs/STATUS.md` Active pointer는 R0 합의/승인 전 변경하지 않는다

## Verification

```bash
# 1. 줄 수 (이동이므로 net 변화 최소)
wc -l docs/AGENT-WORKFLOW.md

# 2. 헤딩 구조 확인
grep -n "^##" docs/AGENT-WORKFLOW.md

# 3. routing table target 존재 확인
grep -oP "\`docs/[^']+\.md\`" docs/AGENT-WORKFLOW.md | tr -d '`' | sort -u | xargs -I{} sh -c '[ -f "{}" ] && echo "OK: {}" || echo "MISSING: {}"'

# 4. git diff --check
git diff --check

# 5. anchor 참조 재확인
grep -rn "#context-routing\|#operating-tracks" .claude/ .agents/ skills/ prompts/ docs/*.md 2>/dev/null | grep -v "CHORE-20260612-008\|works\|archive"
```

## Risk / Reversal Cost

| 항목 | 내용 |
| --- | --- |
| Risk level | L2 — harness workflow surface |
| Reversal cost | Low — 내용 변경 없는 이동; git reset으로 즉시 복원 |
| 주요 위험 | "이동만 수행" 전제가 조건부임. post-table prose 귀속 재판정 + 섹션 의미 재그룹 자체가 micro-taxonomy decision 포함. Phase 1 line-by-line 판정이 핵심 게이트 (R0 F4) |
| scope creep 위험 | `## Work Item Routing` overlap 발견 시 Discovery에만 기록. 본문/위치/주변 문구 수정 금지 (R0 F2) |

## Open Questions

| ID | Question | Default Assumption |
| --- | --- | --- |
| OQ-1 | post-table prose 3줄이 routing 맥락인가, Operating Tracks 맥락인가? | **약화 (R0 F1):** 앞 2줄("조건이 없으면…", "core 문서에 조건부로…")은 routing 후보. 마지막 1줄("회고는 backlog를 대체하지 않는다")은 broader operating rule에 가까워 보류. Phase 1 line-by-line 판정에서 확정 |
| OQ-2 | 이동 후 섹션 순서를 바꿀 필요가 있는가? (`## Context Routing`을 먼저?) | **잠금 (R0 F3):** 순서 변경은 이번 Slice 범위 밖. 이동 후 현 순서(`## Context Routing` → `## Operating Tracks`) 유지. 순서 변경 필요성이 보이면 Slice 3 후보로만 기록 |

## Phase 1 Audit Findings

### routing table target 확인

| Target | 상태 | 비고 |
| --- | --- | --- |
| `docs/STATUS.md` | OK | |
| `docs/BOOTSTRAP.md` | OK | |
| `docs/SCAFFOLD-BOOTSTRAP.md` | OK | |
| `docs/HARNESS-QUICK-REFERENCE.md` | OK | |
| `docs/HARNESS-NAMING-RULES.md` | OK | |
| `docs/HARNESS-RECOVERY-VALIDATION.md` | OK | |
| `docs/HARNESS-PARALLEL-WORK-CONTROLS.md` | OK | |
| `docs/backlog/PRODUCT.md` | MISSING (expected) | source-only 설계 의도 일치 — Slice 1 A2 재확인 |
| `docs/backlog/HARNESS.md` | OK | |
| `docs/PLAN-SUMMARY.md` | OK | |
| `docs/PLAN.md` | OK | |
| `docs/decisions/DR-*.md` | glob — 확인 불필요 | |
| `docs/works/{category}/...` | template — 확인 불필요 | |
| `docs/retrospectives/`, `docs/troubleshooting/`, `docs/archive/` | 디렉토리 — 확인 불필요 | |

### post-table prose 3줄 귀속 판정 (OQ-1 line-by-line)

| 줄 | 내용 | 귀속 판정 | 근거 |
| --- | --- | --- | --- |
| L65 | "조건이 없으면 추가 문서를 로드하지 않는다." | **Context Routing** | routing rule의 직접적 결론. "로딩하지 않는다"는 context loading 동작 규칙 |
| L66 | "core 문서에 조건부로만 실행되는 상세 절차·체크리스트가 축적될 경우, 별도 slice 파일로 분리하고 조건부 pointer로 교체한다." | **Context Routing** | context loading 관리 원칙. "조건부 pointer로 교체"는 routing mechanism 관련 |
| L67 | "회고는 backlog를 대체하지 않는다. 작업 선택, 계획 수립, 아이디어 도출, 반복 리스크 확인이 필요할 때 최신 또는 관련 회고 1개만 선택적으로 확인한다." | **잠정 Context Routing** | routing table의 `docs/retrospectives/` row 사용 제약으로 읽히나, R0가 "broader operating rule"로 지적. R1에서 확정 요청 |

### 섹션 순서 (OQ-2)

`## Context Routing` → `## Operating Tracks` 현 순서 유지. 변경 불필요.
Context Routing이 먼저, Operating Tracks가 나중 — 개념 흐름이 자연스럽다.

### 제안 변경 (R1 승인 대상)

**이동 대상:**
- routing table (현 L46-63, 18행 + 헤더)
- blank line
- post-table prose L65-L66 (Context Routing 귀속 확정)
- post-table prose L67 (잠정 포함, R1에서 귀속 확정)

**이동 후 구조:**

```
## Context Routing

| Need | Load |
| --- | --- |
... (18행 routing table)

조건이 없으면 추가 문서를 로드하지 않는다.
core 문서에 조건부로만 실행되는 상세 절차·체크리스트가 축적될 경우, ...
회고는 backlog를 대체하지 않는다. ... [R1 귀속 확정 후 포함 여부]

## Operating Tracks

이 harness는 적용 대상 repository 안에서 두 개의 작업 트랙을 함께 운영하도록 설계한다.
- **Product track**: ...
- **Harness track**: ...
이 repository를 harness 자체 개발용 source로 운영하는 경우 ...
반면 `scripts/create-harness.sh`로 scaffold한 신규/기존 프로젝트는 ...
```

**순 줄 수:** 이동이므로 net 0 (blank line 처리에 따라 ±1 가능)

---

## Cross-Agent Review And Discussion

### Round Log

| Round | Reviewer | Status | Summary | Follow-Up |
| --- | --- | --- | --- | --- |
| R0 | Codex | **Conditional Hold → 반영 완료** | F1: post-table prose 3줄 자동이동 성급. F2: Work Item Routing 잠금 더 강화. F3: 섹션 순서 결정도 R1 전 금지. F4: "이동만" 전제 조건부로 약화. F5: Done Criteria에 prose 귀속 기록 추가. | Phase 1 Audit 진행 |
| R1 | Codex | **Approved** | L67 Context Routing 귀속 확정. Operating Tracks 보강 불필요. Slice 3 잠금 그대로. | Phase 2 구현 진행 |

### R1 — Result Review (Codex, 2026-06-12)

**Approval:** Approved

**L67 귀속 확정:**
L67("회고는 backlog를 대체하지 않는다…")은 broader operating rule처럼 보일 수 있으나, 이 파일 안에서는 `docs/retrospectives/` row의 선택적 load/use constraint 역할이므로 **Context Routing 귀속으로 확정**.

**이동 후 `## Operating Tracks` 단독성:**
트랙 설명만 남은 상태가 얇지만, 단일 역할 섹션으로 충분하다. 문장 보강이나 예시 추가 불필요.

**Slice 3 잠금:**
Work Item Routing overlap, 섹션 순서 재판단 — 현 상태 그대로 잠금 유지.

---

### R0 — Plan Review (Codex, 2026-06-12)

**Approval:** Conditional Hold → Must-fix 4건 반영 후 해소

**Findings**

- **F1 (Must-fix):** post-table prose 3줄 전체를 "routing 맥락"으로 보는 OQ-1 기본값이 성급하다. 앞 2줄("조건이 없으면…", "core 문서에 조건부로…")은 routing 후보지만, 마지막 1줄("회고는 backlog를 대체하지 않는다")은 broader operating rule에 가깝다. line-by-line 판정으로 전환 필요.
- **F2 (Must-fix):** `## Work Item Routing` Non-goal 잠금이 불충분. "overlap이 보여도 이번 Slice에서는 본문/위치/주변 문구를 수정하지 않는다. Discovery에만 기록한다"라는 hard wording 추가 필요.
- **F3 (Must-fix):** R1 hard stop이 "본문 수정 금지"만 있고 "섹션 순서 결정/변경 금지"가 빠져 있다. OQ-2가 살아 있는 한 R1 전에 author가 구조 결론을 먼저 정해놓을 여지가 있다.
- **F4 (Must-fix):** "이동만 수행" 전제가 확정형으로 쓰였으나, post-table prose 귀속 재판정과 섹션 의미 재그룹은 micro-taxonomy decision이 포함된다. "이동만 수행"을 조건부 문장으로 낮춰야 한다.
- **F5 (Must-fix):** Done Criteria에 "post-table prose 각 줄의 귀속(Context Routing / Operating Tracks / 후속 Slice)이 기록된다" 항목 추가 필요.

**Nice-to-have**

- NTH-1: Files 표에 tracking collateral 명시 (substantive scope와 구분)
- NTH-2: Background/Facts에 post-table prose 3줄 번호(L65-67) 각각 기재

**Claude 반영 계획 (Must-fix 4건)**

- F1 → OQ-1 기본값: "3줄 모두 routing" → "앞 2줄 routing 후보, 마지막 1줄 보류"로 약화. Phase 1 line-by-line 판정으로 확정
- F2 → Non-Goals: `## Work Item Routing` 잠금에 "발견만 하고 절대 수정 안 함" hard wording 추가
- F3 → Phase 2 hard stop: "본문 수정 금지" + "섹션 순서 결정·변경도 R1 승인 전 금지" 추가. OQ-2는 "순서 변경 = Slice 3 후보"로 잠금
- F4 → Risk: "이동만 수행" → "이동만 수행. 단, post-table prose 귀속은 Phase 1 판정 후 결정"으로 조건부 표현
- F5 → Done Criteria: prose 귀속 기록 항목 추가
- NTH-1, NTH-2 → Files 표 tracking collateral 명시 + Background prose 번호 추가

---

## Discovery

- 2026-06-12: CHORE-20260612-007(Slice 1) 완료 직후 착수. Slice 1 R1 F1이 "헤딩 유지, 구조 정비는 Slice 2"로 명시적 잠금. 이 Work가 그 후속.
- 2026-06-12: anchor cascade pre-check 완료 — `#context-routing` / `#operating-tracks` 직접 anchor 참조 live surface 없음. HARNESS-ARCHITECTURE.md(§3), HARNESS-PROTOCOL.md(§Operating Tracks), WORKFLOW-MANUAL.md(§Operating Tracks)는 자체 섹션이므로 AGENT-WORKFLOW.md 구조 변경과 독립.
- 2026-06-12: parent backlog item "Canonical 개념 계층화 + context-routing restructure" 유지 (Slice 2 완료로 exhausted되지 않음 — Slice 3+ 남음).
