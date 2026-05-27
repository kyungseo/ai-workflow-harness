---
id: CHORE-20260527-007
priority: P2
status: Done
risk: Low
scope: HARNESS-PROTOCOL.md §14 Triggers and Cascade를 docs/HARNESS-CASCADE-CHECKS.md로 추출할지 scope를 확정한다. health.md inline cascade table과의 관계 정리가 핵심. policy/runtime surface 변경 없음.
appetite: 0.5d
planned_start: 2026-05-27
planned_end: 2026-05-27
actual_end: 2026-05-27
related_dr: []
related_commits: []
related_troubleshooting: []
---

# CHORE-20260527-007: Cascade Checks Slice Scope Assessment

## Plan

### 목표

CHORE-20260527-006 audit에서 §14 Triggers and Cascade가 다음 추출 후보로 확인됐다.
바로 추출하지 말고 health.md inline cascade table과 HARNESS-PROTOCOL.md §14를 어떻게 정리할지 scope를 확정한다.

**핵심 질문:**
- §14를 `docs/HARNESS-CASCADE-CHECKS.md`로 추출하면 context load가 실제로 줄어드는가?
- health.md / workflow-health/SKILL.md에 inline embedded된 cascade table과 새 문서가 중복되지 않게 만들 수 있는가?
- §14의 각 subsection 중 무엇을 새 slice로 옮기고 무엇을 protocol pointer로 남길 것인가?

**특히 주의:**
§14는 context budget보다 drift risk가 더 큰 영역일 수 있다.
추출이 목적이 아니라, health inline table과 canonical §14 사이의 owner doc을 명확히 하는 것이 목표다.

### 구현하지 않는 것 (Out of Scope)

| 항목 | 이유 |
|---|---|
| `docs/HARNESS-CASCADE-CHECKS.md` 생성 | 다음 implementation Work |
| `health.md` / `HARNESS-PROTOCOL.md` 수정 | 이번 Work 범위 아님 |
| pointer 변경, 중복 제거 | implementation Work로 분리 |

---

## Scope

### CP-1: HARNESS-PROTOCOL.md §14 세부 구조 분해

§14 전체 내용을 읽고 subsection별로 분해한다.

```bash
rg -n "^## 14\.|^### " docs/HARNESS-PROTOCOL.md
# §14 범위(L422–L506) 직접 읽기
```

각 subsection에 대해:
- 이름과 줄 수
- 내용 성격 (trigger 조건 목록 / cascade 규칙 / 검증 체크리스트 / 매트릭스 등)
- health.md inline table과 중복 여부 예비 판정

### CP-2: health.md / workflow-health/SKILL.md inline cascade table과 §14 중복 비교

```bash
rg -n "Triggers and Cascade|Cascade Rule|Tool Surface Cascade|STATUS.*Section.*Deletion|Loop Safety|T[0-9]+ |Trigger Summary" \
  .claude/commands/health.md \
  .agents/skills/workflow-health/SKILL.md \
  docs/HARNESS-PROTOCOL.md
```

health.md / SKILL.md inline table이:
- §14 내용을 그대로 복사했는가 (완전 중복)
- §14의 일부만 embed했는가 (부분 중복)
- 독립적인 운영 뷰를 담고 있는가 (별도 목적)

mirror 정합성도 함께 확인 (health.md vs SKILL.md 동일 여부).

### CP-3: AGENT-WORKFLOW.md trigger/cascade conditional load 지점 확인

```bash
rg -n "trigger.*cascade|cascade.*section|Triggers and Cascade" docs/AGENT-WORKFLOW.md
```

- L167 "trigger/cascade section을 조건부 로드" 지점의 실제 로드 범위 재확인
- 추출 시 이 지점이 `docs/HARNESS-CASCADE-CHECKS.md`를 가리키도록 변경 가능한지 확인

### CP-4: 영향도 확인

```bash
rg -n "Triggers and Cascade|Cascade Rule|Tool Surface Cascade|§14|HARNESS-CASCADE" \
  .claude .agents docs prompts scripts \
  --glob '*.md' --glob '*.mdc' \
  --glob '!docs/archive/**' \
  --glob '!docs/works/**' \
  --glob '!docs/HARNESS-PROTOCOL.md'
```

확인 대상:
- `docs/HARNESS-QUICK-REFERENCE.md` — §14 직접 참조 여부
- `docs/WORKFLOW-MANUAL.md` — cascade trigger 설명 섹션
- `prompts/` — §14 직접 load 지시 여부
- `.claude/rules/`, `.cursor/rules/` — cascade 관련 rule
- `scripts/create-harness.sh` — 추출 시 adapt 행 추가 필요 여부

scaffold 관점 메모 (implementation Work 진행 시 영향 범위):
- `scripts/create-harness.sh`에 `HARNESS-CASCADE-CHECKS.md` adapt 행 추가 필요
- generated `health.md` / `workflow-health/SKILL.md`의 inline cascade table이 새 파일과 중복되지 않도록 처리 필요
- (이번 Work에서는 dry-run 생략, implementation Work에서 필수)

### CP-5: 구현 방향 결정

판정은 아래 중 하나로 명확히 기록한다:

- **A. HARNESS-CASCADE-CHECKS.md 추출 진행**
  조건: §14와 health inline table 중복이 크고, 새 owner doc으로 통합하면 drift risk가 줄어드는 경우
  → 다음 Work (CHORE-20260527-008)의 Scope, Files, Verification, Risk, Reversal Cost를 제안한다.

- **B. health.md inline table 유지 + protocol §14 pointer/owner 기준만 개선**
  조건: health inline table은 실행용 요약으로 유지하면 충분하고, §14는 pointer만 정리하면 drift risk가 해소되는 경우
  → "추가 다이어트 종료 가능" 선언. AGENT-WORKFLOW.md pointer 보정만 별도 소규모 fix로 제안하거나 종료.

- **C. 추가 분리 보류**
  조건: 추출이나 pointer 변경이 context 절감보다 drift/fragmentation을 키우는 경우
  → "추가 다이어트 종료 가능" 선언 또는 재평가 조건(예: §14 내용이 크게 바뀌거나 새 consumer가 생길 때) 명시.

### CP-6: Verification

```bash
git diff --check
```

scaffold dry-run은 이번 assessment에서는 생략 (구현 Work에서 필수).

---

## Done Criteria

- [x] §14 subsection별 구조 분해표 Discovery 기록 (CP-1)
- [x] health.md / SKILL.md inline table과 §14 중복 비교 결과 Discovery 기록 (CP-2)
- [x] health.md vs SKILL.md mirror 정합성 확인 (CP-2)
- [x] AGENT-WORKFLOW.md L167 conditional load 지점 재확인 (CP-3)
- [x] 영향도 분류표 Discovery 기록 (CP-4)
- [x] 구현 방향 A/B/C 판정 및 Discovery 기록 (CP-5)
- [x] A 선택 시 다음 Work 후보 Scope/Files/Verification/Risk/Reversal Cost 제안 (CP-5) — C 판정으로 불필요
- [x] `git diff --check` 통과 (CP-6)

---

## Verification

CP-6 명령어 참조.
이번 Work는 policy/runtime surface 변경이 없다.

---

## Checkpoints

| CP | Description | Status |
|----|-------------|--------|
| 1  | §14 세부 구조 분해 | Done |
| 2  | health.md / SKILL.md inline table과 §14 중복 비교 | Done |
| 3  | AGENT-WORKFLOW.md conditional load 지점 확인 | Done |
| 4  | 영향도 확인 | Done |
| 5  | 구현 방향 결정 | Done |
| 6  | Verification | Done |

---

## Discovery

**CP-1: §14 세부 구조 분해**

§14 Triggers and Cascade (L422–L506, 85줄):

| Subsection | 줄 범위 | 줄 수 | 내용 성격 |
|---|---|---|---|
| Trigger Summary | L424–L445 | 22 | T1–T17 trigger 조건표 |
| Loop Safety | L446–L461 | 16 | 각 trigger의 루프 방지 규칙 |
| Cascade Rule | L462–L477 | 16 | cascade 수준(A/B/C/D) 정의 |
| Tool Surface Cascade Matrix | L478–L493 | 16 | 변경 대상 → 확인 surface 매트릭스 |
| STATUS.md Section Deletion Cascade Checklist | L494–L506 | 13 | STATUS 섹션 삭제 전 확인 항목 |

---

**CP-2: health.md / SKILL.md inline cascade table과 §14 중복 비교**

| 항목 | health.md 포함 여부 | 판정 |
|---|---|---|
| T1-T17 Trigger Summary table | 없음 | 중복 없음 |
| Loop Safety | 없음 | 중복 없음 |
| Cascade Rule (A/B/C/D) | 없음 | 중복 없음 |
| Tool Surface Cascade Matrix | **Required Surface Matrix**(L102–L118)로 존재 | **독립 작성** — 구조·목적·행 구성 모두 다름 |
| STATUS.md Section Deletion Cascade Checklist | rolling window 언급(L292) 외 없음 | 중복 없음 |

**핵심 발견:** health.md의 Required Surface Matrix는 §14의 Tool Surface Cascade Matrix 복사본이 아니다.
- §14 Tool Surface Cascade Matrix: canonical cascade rule — "변경 대상 → 반드시 확인할 표면" (2열)
- health.md Required Surface Matrix: health 실행용 audit 테이블 — "변경 파일 유형 → Canonical/Tool-specific/User-facing/Scaffold/Historical" (6열)
- 행 구성과 세분화 수준이 다르며, health.md 테이블은 audit 흐름에 맞게 독립 발전된 상태.

**mirror 정합성:** health.md와 SKILL.md의 cascade 관련 내용은 동일하게 유지됨(mirror 이상 없음).

---

**CP-3: AGENT-WORKFLOW.md conditional load 지점**

L167: `workflow/doc/tool/scaffold/status 표면을 변경할 때는 docs/HARNESS-PROTOCOL.md의 trigger/cascade section을 조건부 로드하고, 필요한 surface만 확인한다.`

- "trigger/cascade section"을 직접 지목하는 유일한 load directive
- 이미 조건부(표면 변경 시에만) + section-specific — broad full load 아님
- 추출 시 이 포인터를 `docs/HARNESS-CASCADE-CHECKS.md`로 변경 가능하나, 실익 대비 복잡도 증가

---

**CP-4: 영향도 확인**

§14 섹션명("Triggers and Cascade", "Cascade Rule", "Tool Surface Cascade") 직접 참조:
- live surface에서 0건 — HARNESS-PROTOCOL.md 외부에 §14를 직접 지목하는 참조 없음
- `WORKFLOW-MANUAL.md`의 §14는 "테스트 전략" 맥락 — 다른 context

**scaffold 관점 (implementation Work 진행 시 영향 범위):**
- `scripts/create-harness.sh`에 `HARNESS-CASCADE-CHECKS.md` adapt 행 추가 필요
- generated `health.md` / `workflow-health/SKILL.md`의 inline cascade table 처리 방식 결정 필요
- (이번 Work에서는 dry-run 생략; implementation Work에서 필수)

---

**CP-5: 구현 방향 판정**

**판정: C — 추가 분리 보류**

근거:
1. drift risk 없음 — health.md Required Surface Matrix는 §14 Tool Surface Cascade Matrix의 복사본이 아니라 독립 작성된 별도 목적 문서
2. §14 context 압력 이미 최소화 — AGENT-WORKFLOW.md L167이 section-specific 조건부 로드로 범위 제한
3. extraction 실익 없음 — 새 파일 + 포인터 체인이 생기나 직접 consumer가 없음

**추가 다이어트 종료 선언:**
CHORE-20260527-003(§9), CHORE-20260527-005(§15) 두 slice 추출로 HARNESS-PROTOCOL.md 602줄 → 519줄 경량화 완료.
남은 §13(104줄), §14(84줄)는 추출 실익이 없으므로 현행 유지. context optimization series 종료.

**재평가 조건:**
- §14 Tool Surface Cascade Matrix가 크게 개정되어 health.md Required Surface Matrix와 동기화 필요성이 생길 때
- §14를 직접 로드하는 새 consumer가 등장할 때

---

**CP-6: Verification**

- `git diff --check`: PASS
