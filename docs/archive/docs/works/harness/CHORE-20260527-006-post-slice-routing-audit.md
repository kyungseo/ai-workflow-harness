---
id: CHORE-20260527-006
priority: P2
status: Archived
risk: Low
scope: CHORE-20260527-003(Naming Rules)와 CHORE-20260527-005(Recovery/Validation) 이후 HARNESS-PROTOCOL.md context load 압력 재측정 및 live reference 분류. 신규 slice 생성 없음.
appetite: 0.5d
planned_start: 2026-05-27
planned_end: 2026-05-27
actual_end: 2026-05-27
related_dr: []
related_commits: []
related_troubleshooting: []
---

# CHORE-20260527-006: Post-slice Context Routing Audit

## Plan

### 목표

CHORE-20260527-003(Naming Rules slice)와 CHORE-20260527-005(Recovery/Validation slice) 이후,
HARNESS-PROTOCOL.md의 실제 context load 압력이 줄었는지 확인하고 남은 heavy references를 재평가한다.

**핵심 질문:** 두 번의 slice 추출 후에도 HARNESS-PROTOCOL.md를 불필요하게 로드하게 만드는 live surface가 남아 있는가?

### 구현하지 않는 것 (Out of Scope)

| 항목 | 이유 |
|---|---|
| 신규 policy slice 생성 | audit 결과에 따라 별도 Work로 제안 |
| HARNESS-PROTOCOL.md 구조 변경 | 이번 Work 범위 아님 |
| command/skill/prompt pointer 수정 | drift 발견 시 별도 scope로 제안 |

---

## Scope

### CP-1: HARNESS-PROTOCOL.md 줄 수·section별 규모 재측정

```bash
wc -l docs/HARNESS-PROTOCOL.md
grep -n "^## " docs/HARNESS-PROTOCOL.md
```

두 slice 추출 후 현재 총 줄 수와 section별 규모를 Discovery에 기록한다.

### CP-2: live surface HARNESS-PROTOCOL.md reference 분류

```bash
rg -n "HARNESS-PROTOCOL" \
  .claude .agents docs prompts scripts \
  --glob '*.md' --glob '*.mdc' \
  --glob '!docs/archive/**' \
  --glob '!docs/works/**'
```

결과를 아래 4분류로 판정 (실제 context pressure와 단순 문서 링크를 구분하기 위함):
- **broad reference**: 파일 전체 로드를 유발하는 지시 (예: "read docs/HARNESS-PROTOCOL.md", "로드한다")
- **section-specific reference**: 특정 섹션 또는 특정 판단만 로드 (예: "§5를 따른다", "Work File Rules 섹션만")
- **routing/pointer reference**: routing table, file map, user-facing pointer — 로드 지시 없음 (예: PLAN-SUMMARY.md 파일 목록, STATUS.md 링크)
- **scaffold/generated reference**: create-harness.sh output에서 반복되는 참조 — actual context pressure 없음

### CP-3: command/prompt 기준 불필요한 full protocol load 잔존 여부 확인

각 진입점별로 HARNESS-PROTOCOL.md full load 유발 여부 확인:

| Surface | 확인 대상 |
|---|---|
| `/start`, `/pick` | 불필요한 broad reference 없는가 |
| `/work`, `/close`, `/done` | 일반 흐름에서 불필요한 broad reference 없는가 |
| `/health` | 조건부 load 이외 full load 유발 없는가 |
| `prompts/codex-session-start.md` | failure path 이외 broad reference 없는가 |
| `prompts/cursor-session-start.md` | broad reference 없는가 |
| `prompts/claude-session-start.md` | broad reference 없는가 |

### CP-4: §13/§14 추가 추출 재평가

CHORE-20260527-004 assessment 결론(§13/§14 추출 불필요) 재확인:
- §13 Document Lifecycle: load 압력 재측정 — broad reference로 유발되는 경우가 있는가
- §14 Triggers and Cascade: health.md inline embed 상태 유지가 적합한가

판정은 아래 중 하나로 명확히 기록한다:
- **추가 분리 불필요** (현행 유지)
- **§13 Work/File Lifecycle 추출 후보 등록**
- **§14 Cascade Checks 추출 후보 등록**
- **기타 drift 발견으로 별도 fix Work 제안**

### CP-5: scaffold output 검증

```bash
# 경로 충돌 여부 확인 후 고유 경로 사용
TARGET=/private/tmp/awh-rv-audit-006
ls "$TARGET" 2>/dev/null && echo "COLLISION — 경로 변경 필요" || echo "OK"

# actual generation
./scripts/create-harness.sh rv-audit-006 "$TARGET"

# harness 핵심 파일 포함 확인
ls "$TARGET/docs/HARNESS-PROTOCOL.md"
ls "$TARGET/docs/HARNESS-NAMING-RULES.md"
ls "$TARGET/docs/HARNESS-RECOVERY-VALIDATION.md"
ls "$TARGET/docs/AGENT-WORKFLOW.md"
ls "$TARGET/.claude/commands/health.md"
ls "$TARGET/.agents/skills/workflow-health/SKILL.md"
ls "$TARGET/prompts/codex-session-start.md"

# routing pointer 확인
grep -n "HARNESS-NAMING-RULES\|HARNESS-RECOVERY-VALIDATION" \
  "$TARGET/docs/AGENT-WORKFLOW.md" \
  "$TARGET/.claude/commands/health.md" \
  "$TARGET/.agents/skills/workflow-health/SKILL.md" \
  "$TARGET/prompts/codex-session-start.md" 2>/dev/null
```

### CP-6: Verification

```bash
# 1. git diff --check
git diff --check

# 2. scaffold dry-run x3
./scripts/create-harness.sh --dry-run rv-audit-generic /private/tmp/awh-rv-audit-generic
./scripts/create-harness.sh --workflow source-gitflow --dry-run rv-audit-gitflow /private/tmp/awh-rv-audit-gitflow
./scripts/create-harness.sh --profile spring-boot --dry-run rv-audit-springboot /private/tmp/awh-rv-audit-springboot
```

---

## Done Criteria

- [x] HARNESS-PROTOCOL.md 현재 줄 수와 section별 규모 Discovery 기록 (CP-1)
- [x] live surface reference 분류표 Discovery 기록 (CP-2)
- [x] command/prompt 기준 불필요한 full load 잔존 여부 판정 및 Discovery 기록 (CP-3)
- [x] §13/§14 추가 추출 재평가 결과 Discovery 기록 (CP-4)
- [x] scaffold output에서 신규 slice 파일 포함 및 routing pointer 정합성 확인 (CP-5)
- [x] `git diff --check` 통과 (CP-6)
- [x] scaffold dry-run (generic/source-gitflow/spring-boot) 통과 (CP-6)
- [x] 다음 Work 후보 제안 또는 "추가 분리 불필요" 판정 기록 (CP-4)

---

## Verification

CP-6 명령어 목록 참조.
이번 Work는 policy/runtime surface 변경이 없다. drift 발견 시 별도 scope 제안만 한다.

---

## Checkpoints

| CP | Description | Status |
|----|-------------|--------|
| 1  | HARNESS-PROTOCOL.md 줄 수·section별 규모 재측정 | Done |
| 2  | live surface reference 분류 | Done |
| 3  | command/prompt 기준 full load 잔존 여부 확인 | Done |
| 4  | §13/§14 추가 추출 재평가 | Done |
| 5  | scaffold output 검증 | Done |
| 6  | Verification | Done |

---

## Discovery

**CP-1: HARNESS-PROTOCOL.md 현재 규모**

두 slice 추출(§9 → HARNESS-NAMING-RULES.md, §15 → HARNESS-RECOVERY-VALIDATION.md) 이후:
- 총 줄 수: **519줄** (추출 전 602줄 → 83줄 감소)

| Section | 줄 수 |
|---|---|
| §1 Purpose | 12 |
| §2 Quick Start | 9 |
| §3 Document Map | 24 |
| §4 Session State Machine | 31 |
| §5 Approval Matrix | 29 |
| §6 Checkpoint Rules | 16 |
| §7 Context Loading | 60 |
| §8 Item Location Reference | 24 |
| §9 Naming Rules | 4 (pointer only) |
| §10 Work File Decomposition | 13 |
| §11 Quick Mode | 25 |
| §12 Work File Rules | 48 |
| **§13 Document Lifecycle** | **104** |
| **§14 Triggers and Cascade** | **84** |
| §15 Failure And Recovery | 4 (pointer only) |
| §16 Operating Principles | 7 |

§13(104줄)과 §14(84줄)가 전체의 약 36% 차지 — 남은 가장 큰 두 섹션.

---

**CP-2: HARNESS-PROTOCOL.md live reference 분류**

*Broad reference (파일 전체 로드 유발)*

| Surface | 내용 | 판정 |
|---|---|---|
| `prompts/claude-session-start.md` L10 | "필요한 경우 `docs/HARNESS-PROTOCOL.md`만 읽는다" | 조건부 broad — "필요한 경우" 제한 있음 |
| `prompts/claude-session-start.md` L139 | 파일 구조 목록 | routing/pointer (새 프로젝트 초안 제안 섹션) |

*Section-specific reference (특정 섹션·판단만 로드)*

| Surface | 내용 |
|---|---|
| `docs/AGENT-WORKFLOW.md` L157 | Triggers, Work File Rules 섹션 |
| `docs/AGENT-WORKFLOW.md` L166-167 | "trigger/cascade section을 조건부 로드" — **§14 직접 지목** |
| `.claude/commands/work.md` L22 | Work File Decomposition, Quick Mode 기준 |
| `.claude/commands/work.md` L60 | "필요한 범위만 로드" (harness/command/rule 변경 시) |
| `.agents/skills/workflow-work/SKILL.md` L27, L65 | 동일 mirror |

*Routing/pointer reference (로드 지시 없음)*

`docs/AGENT-WORKFLOW.md` L6/L13, `docs/STATUS.md`, `docs/PLAN-SUMMARY.md`, `docs/PLAN.md`, `docs/HARNESS-STRUCTURE.md`, `docs/GIT-WORKFLOW.md`, `docs/HARNESS-MAINTAINER-GUIDE.md`, `.claude/rules/git-workflow.md`, `docs/decisions/DR-*.md`, `docs/WORKFLOW-MANUAL.md`, `prompts/codex-session-start.md` L18, `prompts/cursor-session-start.md` L4/L14, `docs/HARNESS-RECOVERY-VALIDATION.md` L7

*Scaffold/generated reference*

`scripts/templates/source-gitflow/docs/GIT-WORKFLOW.md`, `health.md`/`SKILL.md` cascade table 내 파일명 (load 조건 판단용, 직접 로드 지시 아님)

---

**CP-3: command/prompt 기준 불필요한 full load 잔존 여부**

| Surface | 판정 |
|---|---|
| `/start`, `/pick` | HARNESS-PROTOCOL 참조 없음 ✓ |
| `/work` | section-specific 조건부 (Work File Decomposition, Quick Mode) — 적절 ✓ |
| `/close`, `/done` | 0 참조 ✓ |
| `/health` | cascade table은 로드 대상 목록, 직접 HARNESS-PROTOCOL 로드 지시 아님 ✓ |
| `prompts/codex-session-start.md` | "필요할 때" 조건부 — L18 routing/pointer 수준 ✓ |
| `prompts/cursor-session-start.md` | routing/pointer only ✓ |
| `prompts/claude-session-start.md` | "필요한 경우" 조건부 broad — fallback prompt 용도, 허용 범위 내 ✓ |

**결론: 불필요한 unconditional full load 없음.** 모든 HARNESS-PROTOCOL 참조는 조건부, section-specific, 또는 routing/pointer 수준.

---

**CP-4: §13/§14 추가 추출 재평가**

*§13 Document Lifecycle (104줄)*
- 직접 지목 load directive 없음
- "Work File Rules" 섹션 참조 시 §12(48줄)와 함께 로드될 수 있으나, 두 섹션 모두 Work 파일 운영의 핵심 — 분리 시 fragmentation 우려
- 현재 load pressure는 간접적 (broad ref 없이 §12 참조 시 §13까지 스캔)

*§14 Triggers and Cascade (84줄)*
- `docs/AGENT-WORKFLOW.md` L167에 "trigger/cascade section을 조건부 로드"라는 **직접 지목 directive 존재**
- health.md cascade table은 §14 내용의 일부를 inline embed — 이미 부분적 분리 진행 중
- 84줄 전체 로드 vs. 조건부 섹션 로드의 압력 실재

**판정:**
- §13: **추가 분리 불필요** — 직접 load directive 없고 §12와 연계성 높음
- §14: **§14 Cascade Checks 추출 후보 등록** — AGENT-WORKFLOW.md에 직접 지목 directive 존재, health.md 인라인 embed와 통합 가능성 있음

---

**CP-5: scaffold output 검증**

- 경로 충돌 없음 (`/private/tmp/awh-rv-audit-006`)
- 7개 핵심 파일 모두 생성 확인 (HARNESS-PROTOCOL.md, HARNESS-NAMING-RULES.md, HARNESS-RECOVERY-VALIDATION.md, AGENT-WORKFLOW.md, health.md, workflow-health/SKILL.md, codex-session-start.md)
- AGENT-WORKFLOW.md: HARNESS-NAMING-RULES.md, HARNESS-RECOVERY-VALIDATION.md routing pointer 정상
- health.md / SKILL.md: HARNESS-RECOVERY-VALIDATION.md pointer 정상 (L68/L73, L201/L206)
- codex-session-start.md: HARNESS-RECOVERY-VALIDATION.md failure path 2곳 정상 (L391, L408)

---

**CP-6: Verification**

- `git diff --check`: PASS
- scaffold dry-run (generic): PASS
- scaffold dry-run (source-gitflow): PASS
- scaffold dry-run (spring-boot): PASS
