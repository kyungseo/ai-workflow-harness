---
id: CHORE-20260527-004
priority: P2
status: Archived
risk: Medium
scope: HARNESS-PROTOCOL.md의 남은 heavy section(cascade, lifecycle, recovery)에서 실제 context budget 효과가 큰 다음 policy slice를 선정하고, 구현 scope를 제안한다. 실제 slice 추출은 이번 Work에서 수행하지 않는다.
appetite: 1d
planned_start: 2026-05-27
planned_end: 2026-05-28
actual_end: 2026-05-27
related_dr: []
related_commits: []
related_troubleshooting: []
---

# CHORE-20260527-004: Harness Protocol Remaining Slice Assessment

## Plan

### 목표

`docs/HARNESS-PROTOCOL.md`에 남은 heavy section 중 conditional routing model 적용 효과가 큰 다음 policy slice를 평가하고, 구현 순서와 scope를 제안한다.

CHORE-20260527-003에서 Naming Rules를 첫 slice로 추출해 routing model이 실제로 작동함을 확인했다. 이번 Work는 그 다음 후보(cascade, lifecycle, recovery)의 load pressure와 two-track 영향도를 측정하고 우선순위를 결정하는 **assessment** 단계다.

**Risk 구분:** workflow surface assessment이므로 risk level은 L2/Medium. 단, 이번 Work에서 실제로 변경하는 파일은 Work 파일·README·STATUS.md pointer뿐이므로 실제 변경의 reversal cost는 Low다.

### 구현하지 않는 것 (Out of Scope)

| 항목 | 이유 |
|---|---|
| `docs/HARNESS-CASCADE-CHECKS.md` 등 새 policy slice 생성 | assessment 완료 후 별도 Work |
| `docs/HARNESS-PROTOCOL.md` 구조 변경 | assessment만 수행 |
| command/skill/rule 수정 | pointer 갱신도 다음 Work |

이번 Work에서 생성·수정하는 파일은 Work 파일(`docs/works/harness/CHORE-20260527-004-*.md`), Work Index(`docs/works/harness/README.md`), `docs/STATUS.md` Active Work pointer뿐이다.

### CHORE-20260527-003 follow-up 후보 인계

| 후보 | CHORE-20260527-003 Discovery 기록 |
|---|---|
| `docs/HARNESS-CASCADE-CHECKS.md` | trigger/cascade section의 실제 context pressure가 확인될 때 |
| `docs/HARNESS-WORK-LIFECYCLE.md` | /close, archive 흐름에서 full-protocol load가 반복될 때 |
| `docs/HARNESS-RECOVERY.md` | failure/recovery 규칙이 일반 흐름 load를 오염할 때 |

---

## Scope

### CP-1: HARNESS-PROTOCOL.md section 규모 측정

```bash
# 전체 줄 수
wc -l docs/HARNESS-PROTOCOL.md

# section 헤더 위치 확인
grep -n "^## " docs/HARNESS-PROTOCOL.md
```

section별 줄 수를 계산해 Discovery에 표(Section | 줄 범위 | 줄 수 | Heavy?) 형식으로 기록한다.
`§12 Work File Rules`, `§13 Document Lifecycle`, `§14 Triggers and Cascade`, `§15 Failure And Recovery`는 후보 비교 대상이므로 반드시 개별 행으로 구분한다.

### CP-2: Full-protocol load 반복 지점 측정

아래 대상 파일에서 `HARNESS-PROTOCOL` 참조 위치를 측정한다.

**Command/Skill pair:**

| Command | Skill |
|---|---|
| `.claude/commands/health.md` | `.agents/skills/workflow-health/SKILL.md` |
| `.claude/commands/close.md` | `.agents/skills/workflow-close/SKILL.md` |
| `.claude/commands/work.md` | `.agents/skills/workflow-work/SKILL.md` |
| `.claude/commands/done.md` | `.agents/skills/workflow-done/SKILL.md` |

**Branch/release workflow:**

| 파일 |
|---|
| `docs/GIT-WORKFLOW.md` |
| `scripts/templates/source-gitflow/docs/GIT-WORKFLOW.md` |

**Cascade surface (필요 시 grep 대상):**

| 파일 |
|---|
| `docs/HARNESS-QUICK-REFERENCE.md` |
| `.cursor/rules/workflow.mdc` |
| `prompts/` 하위 session-start 문서 |

```bash
# full-protocol load 강제 지점 전체 측정
rg -n "HARNESS-PROTOCOL|Recovery|Cascade|Work File Rules|Validation Checklist|Commit Approval" \
  .claude .agents docs prompts scripts \
  --glob '*.md' --glob '*.mdc' \
  --glob '!docs/HARNESS-PROTOCOL.md' \
  --glob '!docs/archive/**' \
  --glob '!docs/works/**'
```

결과를 command/skill별로 분류해 Discovery에 기록한다.
HARNESS-PROTOCOL 참조가 모두 full-load 강제는 아니므로 아래 기준으로 판정한다.

| 판정 | 기준 |
|---|---|
| full-load risk | 전체 문서 로드 지시 또는 section 한정 없는 broad reference |
| section-load acceptable | 특정 section만 읽으라는 명시적 지시 |
| pointer/reference only | 문서명 언급뿐, load 지시 없음 |
| historical/not-live | archive/works 제외, 이미 적용 제외 |

### CP-3: 후보 3종 비교 평가

각 후보를 아래 7개 축으로 평가한다.

| 평가 축 | 내용 |
|---|---|
| Trigger | 어느 command/workflow에서 로드가 발생하는가 |
| Default skip condition | 어느 흐름에서 로드를 건너뛸 수 있는가 |
| Owner doc | 현재 내용이 HARNESS-PROTOCOL.md 어느 section에 위치하는가 |
| Mirror surfaces | command, skill, rule, QUICK-REFERENCE 등 pointer 갱신이 필요한 surface |
| Scaffold behavior | scaffold output에 포함 여부, source-gitflow template 영향 |
| Reversal Cost | 추출 후 되돌리기 비용 |
| Two-track | source harness repo 전용인지 / scaffold product repo에도 동일 적용인지 / project-specific override와 충돌 여부 |

**후보별 평가 대상:**

| 후보 | 관련 HARNESS-PROTOCOL.md section |
|---|---|
| Cascade slice | Trigger, Validation Checklist, cascade 관련 section |
| Work Lifecycle slice | Work File Rules, Done/Archive 관련 section |
| Recovery slice | FAIL/RECOVER state, validation failure 관련 section |

### CP-4: 결론 문서화

아래 네 가지 중 하나를 Discovery에 선정 이유와 함께 기록한다.

- **Cascade slice 추천** — 다음 구현 Work scope 포함
- **Work Lifecycle slice 추천** — 다음 구현 Work scope 포함
- **Recovery slice 추천** — 다음 구현 Work scope 포함
- **현 시점 추가 분리 보류** — 이유와 재평가 조건 기록

---

## Done Criteria

- [x] HARNESS-PROTOCOL.md heavy section 규모 측정 완료 — section별 줄 수 Discovery 기록 (CP-1)
- [x] command/skill pair 전체에서 HARNESS-PROTOCOL full-load 강제 지점 식별 완료 (CP-2)
- [x] branch/release workflow에서 full-load 지점 식별 완료 (CP-2)
- [x] cascade surface(QUICK-REFERENCE, cursor rule, prompts) grep 결과 Discovery 기록 (CP-2)
- [x] 후보 3종 비교 평가 완료 — 7개 축 전체 (CP-3)
- [x] two-track 분석 포함 — source-only / project-override / scaffold 영향 (CP-3)
- [x] 다음 slice 추천 또는 보류 결론 + 이유 + (추천 시) 구현 scope 제안 문서화 완료 (CP-4)
- [x] `git diff --check` 통과, Work 파일·README·STATUS.md 외 변경 없음 확인
- [x] commit 전 STATUS Finalization 제안 완료 (Last updated 갱신 여부 포함)

---

## Verification

이 Work의 주요 검증 산출물은 코드 실행이 아닌 **분석 결과 자체**다.
아래 항목이 Discovery에 모두 기록되면 verification 통과로 간주한다.

| 검증 항목 | 기록 위치 |
|---|---|
| CP-1: section별 줄 수 표 | Discovery CP-1 |
| CP-2: grep 결과 + command/skill pair별 판정표 (4분류) | Discovery CP-2 |
| CP-3: 후보 3종 비교표 (7개 축) | Discovery CP-3 |
| CP-4: 최종 추천 또는 보류 결론 + 이유 + (추천 시) 구현 scope | Discovery CP-4 |

```bash
# diff check (Work 파일·README·STATUS.md 외 변경 없는지)
git diff --check
git diff --name-only HEAD
```

측정 결과가 기대치와 다르면 CP-3 평가 기준을 조정하고 이유를 Discovery에 기록한다.

---

## Checkpoints

| CP | Description | Status |
|----|-------------|--------|
| 1  | HARNESS-PROTOCOL.md section 규모 측정 | Done |
| 2  | Full-protocol load 반복 지점 측정 | Done |
| 3  | 후보 3종 비교 평가 (7개 축) | Done |
| 4  | 결론 문서화 | Done |

---

## Discovery

### CP-1: HARNESS-PROTOCOL.md section 규모 (2026-05-27)

전체: 609줄 (§9 Naming Rules 추출 후)

| Section | 줄 범위 | 줄 수 | Heavy? |
|---|---|---|---|
| §1 Purpose | 10–22 | 13 | — |
| §2 Quick Start | 23–32 | 10 | — |
| §3 Document Map | 33–57 | 25 | — |
| §4 Session State Machine | 58–89 | 32 | — |
| §5 Approval Matrix | 90–119 | 30 | — |
| §6 Checkpoint Rules | 120–136 | 17 | — |
| §7 Context Loading | 137–197 | 61 | ▲ |
| §8 Item Location Reference | 198–222 | 25 | — |
| §9 Naming Rules | 223–227 | 5 | (추출 완료) |
| §10 Work File Decomposition | 228–241 | 14 | — |
| §11 Quick Mode | 242–267 | 26 | — |
| **§12 Work File Rules** | 268–316 | **49** | — |
| **§13 Document Lifecycle** | 317–421 | **105** | ★ 최대 |
| **§14 Triggers and Cascade** | 422–506 | **85** | ★ |
| **§15 Failure And Recovery** | 507–601 | **95** | ★ |
| §16 Operating Principles | 602–609 | 8 | — |

후보 3종(§13·§14·§15) 합계: 285줄 — 전체의 47%

---

### CP-2: Full-protocol load 반복 지점 측정 (2026-05-27)

**grep 명령어:**
```bash
rg -n "HARNESS-PROTOCOL|Recovery|Cascade|Work File Rules|Validation Checklist|Commit Approval" \
  .claude .agents docs prompts scripts \
  --glob '*.md' --glob '*.mdc' \
  --glob '!docs/HARNESS-PROTOCOL.md' \
  --glob '!docs/archive/**' \
  --glob '!docs/works/**'
```

**Command/Skill pair별 판정표:**

| Command / Surface | 참조 수 | 판정 | 근거 |
|---|---|---|---|
| `/health` (health.md) | 22 | **section-load acceptable** | "문서 지도·아이템 위치 결정표만" 명시(§3/§8). §15는 "Recovery And Validation 섹션만" 조건부. §14 cascade table은 health.md 내부 **inline 임베드** — 런타임 로드 없음 |
| `/work` (work.md) | 2 | **section-load acceptable** | Work 파일 없을 때 §10/§11 조건부, harness 변경 시 "필요한 범위만" 명시 |
| `/close` (close.md) | **0** | **pointer/reference only** | HARNESS-PROTOCOL 참조 없음 — load 압력 없음 |
| `/done` (done.md) | **0** | **pointer/reference only** | HARNESS-PROTOCOL 참조 없음 — load 압력 없음 |
| `/doc` (doc.md) | 1 | **pointer/reference only** | 참조 테이블 등장뿐, load 지시 없음 |
| `prompts/codex-session-start.md` | 3 | **section-load acceptable** (failure path) + **pointer/reference only** (session init 1건) | failure 경로에서 "Failure And Recovery 절차" + "Failure And Recovery와 Validation Checklist" 섹션 명시 참조 |
| `prompts/cursor-session-start.md` | 2 | **pointer/reference only** | session init 시 "필요할 때" 조건부 언급뿐 |
| `docs/AGENT-WORKFLOW.md` | 4 | **section-load acceptable** | "필요한 조건이 생길 때만", "trigger/cascade section을 조건부 로드" 등 모두 조건부 지시 |
| `docs/HARNESS-QUICK-REFERENCE.md` | 2 | **pointer/reference only** | user-facing 참조, AI 로드 대상 아님 |
| `docs/GIT-WORKFLOW.md` | 1 | **pointer/reference only** | Protected Files 목록에 파일명 등장뿐 |
| `scripts/templates/source-gitflow/docs/GIT-WORKFLOW.md` | 1 | **pointer/reference only** | 동일 |

**핵심 발견:**
- `/close`, `/done` — HARNESS-PROTOCOL 참조 0. §13 Document Lifecycle 추출해도 이 command들의 load 압력 변화 없음.
- `/health` — 이미 partial load 구조 완성. §14 내용은 health.md 내부 inline 임베드. §15만 조건부 load 대상으로 남음.
- `prompts/codex-session-start.md` — failure path에서 §15를 직접 섹션명으로 참조. full-protocol load 없이 §15만 slim file로 대체 가능한 구조.
- `full-load risk` 판정 해당 없음 — 모든 live 참조가 조건부 또는 section-specific.

---

### CP-3: 후보 3종 비교 평가 (2026-05-27)

| 평가 축 | §14 Triggers and Cascade (85줄) | §13 Document Lifecycle (105줄) | §15 Failure And Recovery (95줄) |
|---|---|---|---|
| **Trigger** | workflow/doc/tool/scaffold 변경 시 (AGENT-WORKFLOW.md 조건부) | /close·/done·/work 연관 — 그러나 이 command들은 현재 참조 0 | failure state 진입 시, /health 조건부, prompts/codex-session-start failure path |
| **Default skip** | 이미 조건부 (AGENT-WORKFLOW L166에 명시) | 이미 command level에서 미참조 — skip이 아니라 애초에 load 없음 | 이미 조건부. "failure 경로에서만" 지시 |
| **Owner doc** | §14 | §13 | §15 |
| **Mirror surfaces (갱신 필요)** | health.md cascade table(inline 임베드), workflow-health/SKILL.md, WORKFLOW-MANUAL.md §7 Trigger Cascade Overview | close.md(ref 0), work.md(2), done.md(ref 0), DR-013, DR-016, HARNESS-QUICK-REFERENCE | health.md(조건부), workflow-health/SKILL.md, prompts/codex-session-start.md, prompts/cursor-session-start.md(간접), HARNESS-QUICK-REFERENCE |
| **Scaffold behavior** | cascade 규칙이 health.md에 inline 임베드되어 scaffold 별도 파일 불필요 | lifecycle 규칙은 scaffold BOOTSTRAP.md와 연관. scaffold output에 포함 필요 | prompts가 scaffold 산출물 — pointer 갱신 필요. HARNESS-RECOVERY.md를 scaffold copy 목록에 추가 |
| **Reversal Cost** | Medium — cascade table inline 임베드 재정렬 필요 | Medium — DR-013·DR-016·HARNESS-QUICK-REFERENCE 갱신 필요 | **Low** — 직접 consumer 3종(health.md, prompts 2종)만 |
| **Two-track** | harness-owned. project-specific trigger 확장 가능. source-only rule 없음 | harness-owned. archive path 두 track 공통. source-only rule 없음 | harness-owned. failure/recovery 규칙 두 track 동일. source-only rule 없음 |
| **실제 load 절감 효과** | **낮음** — §14는 health.md inline 임베드. 추출해도 runtime load 패턴 변화 없음 | **낮음** — /close·/done이 §13 현재 미참조. 추출해도 압력 해소 없음 | **중간** — prompts 2종 failure path의 §15 직접 참조를 slim file 로 대체 가능 |

---

### CP-4: 결론 및 구현 scope 제안 (2026-05-27)

**결론: §15 Failure And Recovery → `docs/HARNESS-RECOVERY.md` 추출 추천**

**선정 근거:**

1. **실제 load 압력이 존재하는 유일한 후보.** `prompts/codex-session-start.md`가 failure path에서 §15를 섹션명으로 직접 참조한다. prompts는 context 비용이 높으며, 95줄을 slim file로 대체하면 실질적 효과가 있다.

2. **§14 추출 실익 없음.** health.md cascade table이 §14 내용을 이미 inline 임베드하고 있어, §14 분리 시 cascade table과 HARNESS-CASCADE-CHECKS.md 간 중복 유지 문제가 발생할 수 있다.

3. **§13 load 압력 부재.** /close·/done이 HARNESS-PROTOCOL을 현재 전혀 참조하지 않으므로 §13 분리의 context budget 효과 없음. 재평가 조건: /close·/done이 §13을 강제 로드하는 흐름이 추가될 때.

4. **Reversal Cost 최저.** 직접 consumer가 health.md + prompts 2종으로 가장 좁다.

**파일명 주의 — `HARNESS-RECOVERY.md`는 범위가 좁음:**

§15 실제 구성을 확인한 결과, Failure/Recovery(L507–534)뿐 아니라 **Validation Checklist**(L535–551), **Commit Approval**(L552–573), **CI/Manual/Hook 책임 경계**(L575–601)까지 포함된다. Validation Checklist와 Commit Approval은 failure 경로뿐 아니라 매 commit/close에서 참조되는 규칙이다.

따라서 다음 Work에서 파일명을 `HARNESS-RECOVERY-VALIDATION.md`로 확정할 것을 권장한다. `HARNESS-RECOVERY.md`는 실제 scope를 오해하게 만든다. 최종 확정은 다음 Work 착수 시 결정한다.

**Consumer 정밀화:**

| Consumer | 판정 | 직접 pointer 갱신 대상 |
|---|---|---|
| `health.md` / `workflow-health/SKILL.md` | section-load acceptable — "Recovery And Validation 섹션만" 조건부 | Yes |
| `prompts/codex-session-start.md` | section-load (failure path) — "Failure And Recovery 절차", "Failure And Recovery와 Validation Checklist" 직접 섹션명 참조 | Yes |
| `prompts/cursor-session-start.md` | pointer/reference only — "필요할 때" 조건부 언급뿐, 섹션명 참조 없음 | **확인 필요** — 다음 Work에서 재확인 |
| `docs/AGENT-WORKFLOW.md` | pointer/reference only + conditional — 조건부 지시, section 특정 없음 | Context Routing 테이블 추가만 |

**다음 구현 Work scope 제안 (`CHORE-20260527-005` 예정):**

| 항목 | 내용 |
|---|---|
| 추출 대상 | `docs/HARNESS-PROTOCOL.md §15` (507–601, 95줄) |
| 생성 파일 | `docs/HARNESS-RECOVERY-VALIDATION.md` (또는 착수 시 최종 확정) |
| §15 처리 | pointer section만 남김 (CHORE-20260527-003 패턴 동일) |
| Pointer 갱신 대상 (확정) | `docs/AGENT-WORKFLOW.md` Context Routing 테이블, `health.md`, `workflow-health/SKILL.md`, `prompts/codex-session-start.md`, `docs/HARNESS-QUICK-REFERENCE.md` |
| Pointer 갱신 대상 (확인 필요) | `prompts/cursor-session-start.md` — 직접 섹션명 참조 없음, 갱신 필요 여부 다음 Work에서 재확인 |
| Scaffold | `scripts/create-harness.sh` — 신규 파일 copy 행 추가 |
| Skip 조건 명시 | `/start`, `/pick`, `/work`, `/close`, `/done`, 일반 cascade — 로드 불필요. failure state 진입 시, /health 조건부 validation 확인 시에만 로드 |
| Two-track | Failure/Recovery: harness-owned, 두 track 동일. CI/Manual/Hook 책임 경계 중 "source repo 전용" 표기 항목(Hook 섹션) 확인 필요 |
| Reversal Cost | Low |

**보류 후보 재평가 조건:**

| 후보 | 재평가 조건 |
|---|---|
| §14 Cascade | cascade table이 health.md 외부로 빠져나가거나, §14 독립 로드 압력이 측정될 때 |
| §13 Document Lifecycle | /close 또는 /done이 §13을 강제 로드하는 흐름이 추가될 때 |
