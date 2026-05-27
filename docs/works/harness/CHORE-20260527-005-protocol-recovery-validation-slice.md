---
id: CHORE-20260527-005
priority: P2
status: Done
risk: Medium
scope: HARNESS-PROTOCOL.md §15(Failure And Recovery, Validation Checklist, Commit Approval, CI/Manual/Hook 책임 경계)를 docs/HARNESS-RECOVERY-VALIDATION.md로 추출하고, conditional routing model을 적용한다. 실제 변경 reversal cost는 Low.
appetite: 1d
planned_start: 2026-05-27
planned_end: 2026-05-28
actual_end: 2026-05-27
related_dr: [DR-013]
related_commits: []
related_troubleshooting: []
---

# CHORE-20260527-005: Harness Protocol §15 Recovery/Validation Slice Extraction

## Plan

### 목표

`docs/HARNESS-PROTOCOL.md §15`(507–601, 95줄)를 `docs/HARNESS-RECOVERY-VALIDATION.md`로 추출하고, 직접 consumer의 pointer를 갱신한다.

CHORE-20260527-003(Naming Rules)에서 검증한 routing model 패턴을 그대로 적용한다.
CHORE-20260527-004 assessment에서 §15가 load 압력이 실재하는 유일한 후보임을 확인했다.

**Risk 구분:** workflow surface 변경이므로 risk level은 L2/Medium. 실제 변경 reversal cost는 Low(pointer 복원으로 즉시 rollback 가능).

### 파일명 확정: `docs/HARNESS-RECOVERY-VALIDATION.md`

§15 실제 구성:
- Failure Conditions + Recovery Flow — failure path 전용
- **Validation Checklist** — commit/close 시 매번 참조
- **Commit Approval** — 모든 commit에서 참조
- **CI/Manual/Hook 책임 경계** — enforcement 구조

`HARNESS-RECOVERY.md`는 Validation Checklist와 Commit Approval을 포함하는 실제 scope를 오해시킨다.

### 구현하지 않는 것 (Out of Scope)

| 항목 | 이유 |
|---|---|
| 다른 section 추출 (§13, §14 등) | 별도 Work |
| `docs/HARNESS-PROTOCOL.md` §15 외 구조 변경 | 이번 Work 범위 아님 |
| command/skill/rule 로직 변경 | pointer 갱신만 허용 |

### Consumer 범위

| Consumer | 판정 | 처리 |
|---|---|---|
| `.claude/commands/health.md` | **직접 갱신** | L68 "Recovery And Validation 섹션만" → 새 파일 |
| `.agents/skills/workflow-health/SKILL.md` | **직접 갱신** | L73 mirror 유지 |
| `prompts/codex-session-start.md` | **직접 갱신** | L391/L408 §15 섹션명 참조 |
| `prompts/cursor-session-start.md` | **확인 후 결정** | pointer/reference only — 섹션명 참조 없음. 갱신 불필요 시 Discovery에 "확인 후 미변경" 기록 |
| `docs/AGENT-WORKFLOW.md` | **routing 갱신** | Context Routing 테이블 추가, L156 pointer 보완 |
| `docs/HARNESS-QUICK-REFERENCE.md` | **확인 후 갱신** | recovery/validation 참조 포인터 |
| `scripts/create-harness.sh` | **scaffold 갱신** | copy 행 추가 |

### Routing model (AGENT-WORKFLOW.md에 추가할 스킵 조건)

| Command / 흐름 | HARNESS-RECOVERY-VALIDATION.md | 이유 |
|---|---|---|
| `/start`, `/pick` | 불필요 | 현재 상태 확인만 |
| `/work`, `/close`, `/done` | 일반 흐름 불필요 / validation failure·commit approval·recovery 판단 필요 시 **조건부** | §15에 Validation Checklist와 Commit Approval 포함 — 판단이 필요한 상황에서는 로드 가능 |
| `/health` | **조건부** — Validation/Recovery 확인 필요 시만 | 이미 "섹션만 읽는다" 패턴 존재 |
| failure state 진입 | **필요** | 직접 적용 대상 |
| prompts failure path (codex) | **필요** | L391/L408 직접 참조 |

---

## Scope

### CP-1: §15 live pointer 위치 확정 (hotspot 재측정)

```bash
rg -n "Failure And Recovery|Recovery And Validation|§15|Validation Checklist|Commit Approval|CI.*Manual.*Hook|HARNESS-RECOVERY" \
  .claude .agents docs prompts scripts \
  --glob '*.md' --glob '*.mdc' \
  --glob '!docs/HARNESS-PROTOCOL.md' \
  --glob '!docs/archive/**' \
  --glob '!docs/works/**'
```

결과를 아래 분류로 판정:
- **직접 갱신 필요**: 섹션명 또는 새 파일명 pointer 갱신이 필요한 live 참조
- **pointer/reference only**: 문서명 언급뿐, 갱신 불필요
- **historical/not-live**: archive/works 제외

### CP-2: `docs/HARNESS-RECOVERY-VALIDATION.md` 생성

`docs/HARNESS-PROTOCOL.md §15`(L507–L601) 전체를 이동한다.

상단에 위치 설명과 참조 조건을 1–2줄로 기재한다:
```
docs/HARNESS-PROTOCOL.md §15에서 추출한 Recovery/Validation policy slice다.
failure state 진입, /health 조건부 validation 확인, commit approval 판단 시에만 로드한다. /start, /pick, 일반 /work·/close·/done 흐름에서는 로드하지 않는다.
```

**Two-track 주의:** CI/Manual/Hook 책임 경계 내 "Hook — local pre-commit warning (source repo 전용)" 표현이 있다. 새 파일에 그대로 옮기되, 이미 내부에 "source repo 전용" scope가 명시되어 있으므로 추가 분리 없이 유지한다. Discovery에 확인 결과 기록.

### CP-3: `docs/HARNESS-PROTOCOL.md §15` pointer section으로 교체

아래 내용만 남긴다:

```markdown
## 15. Failure And Recovery

Failure Conditions, Recovery Flow, Validation Checklist, Commit Approval, CI/Manual/Hook 책임 경계는 `docs/HARNESS-RECOVERY-VALIDATION.md`를 따른다.
failure state 진입, validation failure 판단, commit approval 확인 시에만 로드한다.
```

### CP-4: `docs/AGENT-WORKFLOW.md` 갱신

Context Routing 테이블에 아래 행 추가:

| Need | Load |
| --- | --- |
| failure state 진입, Validation Checklist, Commit Approval 판단, /health 조건부 recovery 확인 | `docs/HARNESS-RECOVERY-VALIDATION.md` — `/start`, `/pick`, 일반 `/work`·`/close`·`/done` 흐름에서는 로드하지 않는다. validation failure·recovery·commit approval 판단이 필요한 경우에만 로드한다 |

L156 `HARNESS-PROTOCOL.md`의 Validation Checklist 참조:
- 현재: `docs/HARNESS-PROTOCOL.md`의 Triggers, Validation Checklist, Work File Rules
- 변경: `docs/HARNESS-RECOVERY-VALIDATION.md` (Validation Checklist, Commit Approval), `docs/HARNESS-PROTOCOL.md` (Triggers, Work File Rules)

### CP-5: `health.md` + `workflow-health/SKILL.md` pointer 갱신

| 파일 | 현재 | 변경 |
|---|---|---|
| `.claude/commands/health.md` L68 | `docs/HARNESS-PROTOCOL.md`의 Recovery And Validation 섹션만 읽는다 | `docs/HARNESS-RECOVERY-VALIDATION.md`를 읽는다 |
| `.claude/commands/health.md` L201 | `docs/HARNESS-PROTOCOL.md`의 Validation Checklist, Approval Matrix, Commit Approval 정합성 | `docs/HARNESS-RECOVERY-VALIDATION.md`의 Validation Checklist, Approval Matrix, Commit Approval 정합성 |
| `.agents/skills/workflow-health/SKILL.md` L73 | 동일 (mirror) | 동일 (mirror) |
| `.agents/skills/workflow-health/SKILL.md` L206 | 동일 (mirror) | 동일 (mirror) |

### CP-6: `prompts/codex-session-start.md` pointer 갱신

| 줄 | 현재 | 변경 |
|---|---|---|
| L391 | `docs/HARNESS-PROTOCOL.md의 Failure And Recovery 절차에 따라` | `docs/HARNESS-RECOVERY-VALIDATION.md의 Failure And Recovery 절차에 따라` |
| L408 | `docs/HARNESS-PROTOCOL.md의 Failure And Recovery와 Validation Checklist를 따라줘` | `docs/HARNESS-RECOVERY-VALIDATION.md의 Failure And Recovery와 Validation Checklist를 따라줘` |

### CP-7: `prompts/cursor-session-start.md` 확인

현재 참조(L4, L14)는 pointer/reference only — 섹션명 참조 없음. 갱신 불필요로 판단 시 Discovery에 "확인 후 미변경" 기록.

### CP-8: `docs/HARNESS-QUICK-REFERENCE.md` 확인

§6 Validation, §7 Recovery And Recovery 섹션에서 HARNESS-PROTOCOL.md를 직접 참조하는 live load 지시가 있으면 갱신한다. pointer/reference only이면 유지.

### CP-9: `scripts/create-harness.sh` 갱신

HARNESS-PROTOCOL.md adapt 행 인접에 추가:
```bash
adapt "${TEMPLATE_ROOT}/docs/HARNESS-RECOVERY-VALIDATION.md"  "${TARGET_ROOT}/docs/HARNESS-RECOVERY-VALIDATION.md"
```

### CP-10: Two-track 점검

| 확인 항목 | 방법 |
|---|---|
| HARNESS-RECOVERY-VALIDATION.md 내 source-only 규칙 혼재 없는가 | CI/Manual/Hook 섹션 내 "source repo 전용" 표현이 scope-qualified인지 확인 |
| scaffold product repo에서 오해 없이 적용 가능한가 | "source repo 전용" 항목은 이미 내부 명시이므로 별도 분리 불필요인지 확인 |
| scaffold AGENT-WORKFLOW.md가 새 routing 행을 포함하는가 | actual generation 후 파일 확인 |

### CP-11: Verification 전체

```bash
# 1. stale §15 reference 측정 (확장 패턴 포함)
rg -n "Failure And Recovery|Recovery And Validation|HARNESS-PROTOCOL.*§15|§15[^0-9]|Validation Checklist|Commit Approval|CI.*Manual.*Hook" \
  .claude .agents docs prompts scripts \
  --glob '*.md' --glob '*.mdc' \
  --glob '!docs/HARNESS-PROTOCOL.md' \
  --glob '!docs/HARNESS-RECOVERY-VALIDATION.md' \
  --glob '!docs/archive/**' \
  --glob '!docs/works/**'

# 2. diff check
git diff --check

# 3. scaffold syntax
bash -n scripts/create-harness.sh

# 4. scaffold dry-run (generic)
./scripts/create-harness.sh --dry-run rv-generic /private/tmp/awh-rv-generic

# 5. scaffold actual generation
./scripts/create-harness.sh rv-actual /private/tmp/awh-rv-actual
ls /private/tmp/awh-rv-actual/docs/HARNESS-RECOVERY-VALIDATION.md

# 6. scaffold dry-run (source-gitflow)
./scripts/create-harness.sh --workflow source-gitflow --dry-run rv-gitflow /private/tmp/awh-rv-gitflow

# 7. scaffold dry-run (spring-boot)
./scripts/create-harness.sh --profile spring-boot --dry-run rv-springboot /private/tmp/awh-rv-springboot

# 8. generated scaffold 검증 (actual generation 결과에서)
grep -n "HARNESS-RECOVERY-VALIDATION" \
  /private/tmp/awh-rv-actual/docs/AGENT-WORKFLOW.md \
  /private/tmp/awh-rv-actual/prompts/codex-session-start.md 2>/dev/null
```

---

## Done Criteria

- [x] §15 live pointer 위치 확정, 판정표 Discovery 기록 (CP-1)
- [x] `docs/HARNESS-RECOVERY-VALIDATION.md` 생성 완료 — §15 전체 내용 + 상단 load 조건 기재 (CP-2)
- [x] Two-track 점검 완료 — CI/Manual/Hook source-only 표현 scope-qualified 확인 (CP-2/CP-10)
- [x] `docs/HARNESS-PROTOCOL.md §15` pointer section만 남음 (CP-3)
- [x] `docs/AGENT-WORKFLOW.md` Context Routing 갱신 + L156 pointer 보완 (CP-4)
- [x] `health.md` + `workflow-health/SKILL.md` pointer 갱신 (CP-5)
- [x] `prompts/codex-session-start.md` L391/L408 pointer 갱신 (CP-6)
- [x] `prompts/cursor-session-start.md` 확인 후 처리 결과 Discovery 기록 (CP-7)
- [x] `docs/HARNESS-QUICK-REFERENCE.md` 확인 후 처리 (CP-8)
- [x] `scripts/create-harness.sh` copy 행 추가 (CP-9)
- [x] stale §15 reference grep 통과 (CP-11)
- [x] `git diff --check` 통과 (CP-11)
- [x] `bash -n scripts/create-harness.sh` 통과 (CP-11)
- [x] scaffold dry-run (generic/source-gitflow/spring-boot) 통과 (CP-11)
- [x] scaffold actual generation 완료, HARNESS-RECOVERY-VALIDATION.md 포함 확인 (CP-11)
- [x] generated scaffold에서 AGENT-WORKFLOW.md, prompts/codex-session-start.md가 새 파일명 참조 확인 (CP-11)

---

## Verification

CP-11 명령어 목록 참조.
검증 실행 불가 시 이유와 남은 risk를 Discovery에 기록한다.

---

## Checkpoints

| CP | Description | Status |
|----|-------------|--------|
| 1  | §15 live pointer 위치 확정 | Done |
| 2  | HARNESS-RECOVERY-VALIDATION.md 생성 | Done |
| 3  | HARNESS-PROTOCOL.md §15 → pointer section | Done |
| 4  | AGENT-WORKFLOW.md routing 갱신 | Done |
| 5  | health.md + workflow-health/SKILL.md pointer 갱신 | Done |
| 6  | prompts/codex-session-start.md pointer 갱신 | Done |
| 7  | cursor-session-start.md 확인 | Done |
| 8  | HARNESS-QUICK-REFERENCE.md 확인 | Done |
| 9  | scripts/create-harness.sh 갱신 | Done |
| 10 | Two-track 점검 | Done |
| 11 | Verification 전체 | Done |

---

## Discovery

**CP-1: §15 live pointer 위치 확정**

rg 결과 분류:
- 직접 갱신: `.claude/commands/health.md` (L68, L201), `.agents/skills/workflow-health/SKILL.md` (L73, L206), `prompts/codex-session-start.md` (L391, L408), `docs/AGENT-WORKFLOW.md` (L156)
- pointer/reference only (미변경): `prompts/cursor-session-start.md` (L4, L14 — 섹션명 없는 일반 파일명 언급), `.claude/rules/git-workflow.md` (plain "Commit Approval:" 섹션 헤더), `.claude/commands/doc.md` / `.agents/skills/workflow-doc/SKILL.md` ("Validation Checklist" 표 항목 — load directive 없음)
- historical/not-live: `docs/troubleshooting/` 파일, `docs/WORKFLOW-MANUAL.md` §15 K8s 참조 (별도 context)

**CP-2: Two-track 주의 확인**

`docs/HARNESS-RECOVERY-VALIDATION.md`의 CI/Manual/Hook 책임 경계 섹션에 "Hook — local pre-commit warning (source repo 전용)" 표현 포함. 섹션 내부에 scope가 명시되어 있으므로 별도 분리 불필요. scaffold product repo에서도 오해 없이 적용 가능.

**CP-7: cursor-session-start.md 확인 후 미변경**

L4, L14의 `HARNESS-PROTOCOL.md` 참조는 섹션명 없는 일반 파일 포인터. `§15` 또는 "Failure And Recovery" 섹션 직접 참조 없음 — 갱신 불필요.

**CP-11: Verification 결과**

- stale §15 reference grep: 잔여 stale 없음. 나머지는 모두 갱신된 참조, non-live 참조, 또는 다른 맥락의 §15 언급.
- `git diff --check`: PASS
- `bash -n scripts/create-harness.sh`: PASS
- scaffold dry-run (generic): PASS
- scaffold dry-run (source-gitflow): PASS
- scaffold dry-run (spring-boot): PASS
- scaffold actual generation: `/private/tmp/awh-rv-actual/docs/HARNESS-RECOVERY-VALIDATION.md` 생성 확인
- generated scaffold AGENT-WORKFLOW.md, codex-session-start.md: `HARNESS-RECOVERY-VALIDATION.md` 참조 확인
