---
id: CHORE-20260527-008
priority: P2
status: Done
risk: Low
scope: CHORE-20260527-003~007 series develop merge 이후 release gate 점검. archive cleanup, 영향도 체크, scaffold 검증, develop → main PR 준비.
appetite: 1d
planned_start: 2026-05-27
planned_end: 2026-05-27
actual_end: 2026-05-27
related_dr: []
related_commits: []
related_troubleshooting: []
---

# CHORE-20260527-008: Context Budget Optimization Series Release Prep

## Plan

### 목표

develop에 merge된 CHORE-20260527-003~007 영향도를 release gate 관점에서 점검하고,
main release 전에 필요한 archive cleanup과 검증을 수행한다.

**핵심 범위:**
- 003~007 Work 파일 5개 archive 처리
- release 영향도 체크 (slice 문서 포함, routing, scaffold)
- Public Clean Baseline Gate 확인
- develop → main PR 준비

**이 작업은 새 context diet가 아니다. 추가 slice 추출 금지.**

### 구현하지 않는 것 (Out of Scope)

| 항목 | 이유 |
|---|---|
| 추가 policy slice 추출 | series는 CHORE-20260527-007에서 종료 |
| HARNESS-PROTOCOL.md 내용 변경 | 영향도 확인만, 수정 없음 |
| 신규 routing 변경 | 검증만 수행 |

---

## Scope

### CP-1: Work 파일 + STATUS 등록

feature branch 생성 + Work 파일 생성 + STATUS Active Work 등록.

### CP-2: 003~007 Work 파일 archive 처리

```bash
rg -n "^status: Done" docs/works/harness/
```

5개 Work 파일:
- CHORE-20260527-003-protocol-naming-slice.md
- CHORE-20260527-004-protocol-slice-assessment.md
- CHORE-20260527-005-protocol-recovery-validation-slice.md
- CHORE-20260527-006-post-slice-routing-audit.md
- CHORE-20260527-007-cascade-checks-scope-assessment.md

각 파일:
1. frontmatter `status: Archived` 변경
2. `git mv docs/works/harness/{file} docs/archive/docs/works/harness/`

`docs/works/harness/README.md`:
- Done (Archive Pending) 5개 → Archived 테이블로 이동
- 파일 경로 `docs/archive/docs/works/harness/` 로 업데이트

### CP-3: Release 영향도 체크

```bash
# 새 slice 문서 존재 확인
ls docs/HARNESS-NAMING-RULES.md docs/HARNESS-RECOVERY-VALIDATION.md

# stale §9/§15 직접 참조 grep (live surface only)
rg -n "§9|Naming Rules.*PROTOCOL|§15|Recovery.*And.*Validation.*PROTOCOL" \
  .claude .agents docs prompts scripts \
  --glob '*.md' --glob '*.mdc' \
  --glob '!docs/archive/**' \
  --glob '!docs/works/**'

# AGENT-WORKFLOW routing table 신규 행 존재 확인
grep -n "HARNESS-NAMING-RULES\|HARNESS-RECOVERY-VALIDATION" docs/AGENT-WORKFLOW.md

# health / SKILL mirror 포인터 확인
grep -n "HARNESS-RECOVERY-VALIDATION" \
  .claude/commands/health.md \
  .agents/skills/workflow-health/SKILL.md

# prompts 포인터 확인
grep -n "HARNESS-RECOVERY-VALIDATION\|HARNESS-NAMING-RULES" prompts/*.md

# scaffold copy 행 확인
grep -n "HARNESS-NAMING-RULES\|HARNESS-RECOVERY-VALIDATION" scripts/create-harness.sh
```

### CP-4: Public Clean Baseline Gate 확인

```bash
# private/internal reference scan
rg -n "kyungseo\|private.*origin\|internal.*only\|TODO.*public\|FIXME.*public" \
  docs prompts .claude .agents scripts \
  --glob '*.md' --glob '*.mdc' --glob '*.sh' \
  --glob '!docs/archive/**' \
  --glob '!docs/works/**'

# stale project identity (Spring Boot / template 잔재)
rg -n "spring.boot\|SpringBoot\|my-app\|sample-project" \
  docs prompts .claude .agents scripts \
  --glob '*.md' --glob '*.mdc' --glob '*.sh' \
  --glob '!docs/archive/**' \
  --glob '!docs/works/**'
```

### CP-5: Scaffold 검증

```bash
# syntax check
bash -n scripts/create-harness.sh

# dry-run x3
./scripts/create-harness.sh --dry-run release-prep-generic /private/tmp/awh-rp-008-generic
./scripts/create-harness.sh --workflow source-gitflow --dry-run release-prep-gitflow /private/tmp/awh-rp-008-gitflow
./scripts/create-harness.sh --profile spring-boot --dry-run release-prep-springboot /private/tmp/awh-rp-008-springboot

# actual generation: collision 확인 후 실행
TARGET=/private/tmp/awh-rp-008-actual
ls "$TARGET" 2>/dev/null && echo "COLLISION" || echo "OK"
./scripts/create-harness.sh rp-008-actual "$TARGET"

# 신규 slice 파일 포함 확인
ls "$TARGET/docs/HARNESS-NAMING-RULES.md"
ls "$TARGET/docs/HARNESS-RECOVERY-VALIDATION.md"

# routing pointer 확인
grep -n "HARNESS-NAMING-RULES\|HARNESS-RECOVERY-VALIDATION" \
  "$TARGET/docs/AGENT-WORKFLOW.md" \
  "$TARGET/.claude/commands/health.md" \
  "$TARGET/.agents/skills/workflow-health/SKILL.md" \
  "$TARGET/prompts/codex-session-start.md" 2>/dev/null
```

### CP-6: Verification

```bash
# Work 파일 archive 상태 확인
rg -n "^status: Done" docs/works/ 2>/dev/null || echo "No Done-pending files"
rg -n "^status: Active" docs/works/
rg -rn "^status:" docs/archive/docs/works/harness/ | grep -v "Archived" || echo "All Archived"

# git check
git diff --check

# STATUS Active Work 정합성
grep -A5 "## Active Work" docs/STATUS.md
```

### CP-7: STATUS finalization + commit + develop → main PR 준비

STATUS.md:
- Last updated 갱신
- Active Work → 완료 후 pointer 제거 (via /close)

develop → main release PR body:
- CHORE-20260527-003~007 변경 요약
- 새 slice 파일 목록
- scaffold 검증 결과
- gate checklist 결과

---

## Done Criteria

- [x] feature branch 생성 + Work 파일 Active 등록 (CP-1)
- [x] 003~007 Work 파일 5개 status: Archived + git mv 완료 (CP-2)
- [x] docs/works/harness/README.md Done → Archived 이동 완료 (CP-2)
- [x] release 영향도 체크 결과 Discovery 기록 — stale ref 없음 또는 fix 완료 (CP-3)
- [x] Public Clean Baseline Gate 통과 — private ref / stale identity 없음 (CP-4)
- [x] bash -n 통과 + scaffold dry-run 3종 통과 (CP-5)
- [x] actual scaffold 생성 확인 — HARNESS-NAMING-RULES.md, HARNESS-RECOVERY-VALIDATION.md 포함 (CP-5)
- [x] rg status 확인 + git diff --check 통과 (CP-6)
- [x] STATUS.md 최종 갱신 + /close 처리 (CP-7)
- [x] develop → main release PR body 준비 완료 (CP-7)

---

## Verification

CP-6 명령어 참조.
policy/runtime surface 변경 없음. archive 이동 + release gate 확인 중심.

---

## Checkpoints

| CP | Description | Status |
|----|-------------|--------|
| 1  | Work 파일 + STATUS 등록 | Done |
| 2  | 003~007 archive 처리 | Done |
| 3  | Release 영향도 체크 | Done |
| 4  | Public Clean Baseline Gate | Done |
| 5  | Scaffold 검증 | Done |
| 6  | Verification | Done |
| 7  | STATUS + commit + PR 준비 | Done |

---

## Discovery

**CP-2: 003~007 Work 파일 archive 처리**

5개 Work 파일 status: Archived + git mv 완료:
- CHORE-20260527-003~007 → `docs/archive/docs/works/harness/`
- `docs/works/harness/README.md`: Done (Archive Pending) → Archived 이동 완료

---

**CP-3: Release 영향도 체크**

| Surface | 결과 |
|---|---|
| 신규 slice 문서 존재 | HARNESS-NAMING-RULES.md, HARNESS-RECOVERY-VALIDATION.md 확인 ✓ |
| stale §9/§15 live 참조 | expected/non-blocking matches reviewed: HARNESS-NAMING-RULES.md / HARNESS-RECOVERY-VALIDATION.md self-reference 정상, SCAFFOLD-ONBOARDING-GUIDE §9는 BOOTSTRAP.md §9 맥락, WORKFLOW-MANUAL §15는 K8s 맥락 — 모두 무관 ✓ |
| AGENT-WORKFLOW routing table | 2개 신규 행 정상 (L52, L53) ✓ |
| health.md / SKILL.md mirror | HARNESS-RECOVERY-VALIDATION pointer L68/L201, L73/L206 ✓ |
| prompts/codex-session-start.md | failure path L391, L408 ✓ |
| scripts/create-harness.sh | adapt 행 L210-211 ✓ |

---

**CP-4: Public Clean Baseline Gate**

- private/internal reference scan: reviewed non-blocking — docs/PLAN.md의 `kyungseo/base-msa-template`은 migration history 설명 맥락 ✓
- stale Spring Boot / template project identity: reviewed non-blocking — spring-boot / my-app matches는 optional profile 및 manual examples 맥락 ✓

---

**CP-5: Scaffold 검증**

- bash -n: PASS
- dry-run generic: PASS (HARNESS-NAMING-RULES.md, HARNESS-RECOVERY-VALIDATION.md 포함 확인)
- dry-run source-gitflow: PASS
- dry-run spring-boot: PASS
- actual generation `/private/tmp/awh-rp-008-actual`: PASS
  - HARNESS-NAMING-RULES.md, HARNESS-RECOVERY-VALIDATION.md 생성 확인
  - routing pointer 5개 surface 모두 정상

---

**CP-6: Verification**

- `rg "^status: Done" docs/works/`: 없음 ✓
- `rg "^status: Active" docs/works/`: CHORE-20260527-008 1개 ✓
- archive status 전체 Archived ✓
- `git diff --check`: PASS
- STATUS Active Work: CHORE-20260527-008 ✓

---

**Side-effect validation: Context Budget Optimization Series(003~007) policy 누락·stale pointer·scaffold 누락·command-skill mismatch 확인**

**1. /start, /pick**

| 확인 항목 | 결과 |
|---|---|
| HARNESS-NAMING-RULES.md 불필요 로드 | start.md / pick.md 모두 참조 없음 ✓ |
| HARNESS-RECOVERY-VALIDATION.md 불필요 로드 | start.md / pick.md 모두 참조 없음 ✓ |
| AGENT-WORKFLOW.md routing 명시 | L52: HARNESS-NAMING-RULES — `/start`, `/pick`, 일반 status 확인에서 로드 금지 명시 ✓ |
| | L53: HARNESS-RECOVERY-VALIDATION — `/start`, `/pick` 에서 로드 금지 명시 ✓ |
| STATUS current sections만으로 clean idle 판단 | start.md: STATUS.md Current State·Active Work·Blockers·Next Actions만 확인하는 구조 ✓ |

**2. /work, /register**

| 확인 항목 | 결과 |
|---|---|
| Work ID 확정 시 HARNESS-NAMING-RULES routing | work.md L27, register.md L48/L62 — `docs/HARNESS-NAMING-RULES.md` 직접 지목 ✓ |
| SKILL mirror (workflow-work, workflow-register) | 동일 라인 구조 — mirror 정합 ✓ |
| stale §9 직접 참조 | work.md HARNESS-PROTOCOL 참조는 Work File Decomposition(§10)/Quick Mode(§11) section-specific — §9 참조 없음 ✓ |

**3. /health**

| 확인 항목 | 결과 |
|---|---|
| HARNESS-RECOVERY-VALIDATION 조건부 로드 | health.md L66-68: "Validation/Approval Matrix/Commit Approval 정합성 확인이 필요하면" 조건부 명시 ✓ |
| health.md ↔ workflow-health/SKILL.md mirror | L68/L73, L201/L206 — 동일 pointer, mirror 정합 ✓ |

**4. /close, /done**

| 확인 항목 | 결과 |
|---|---|
| 일반 lifecycle에서 recovery slice 불필요 로드 없음 | close.md / done.md 모두 HARNESS-RECOVERY-VALIDATION 참조 없음 ✓ |
| commit approval / validation failure 경로 연결 | AGENT-WORKFLOW.md L53 + L157: "validation failure·recovery·commit approval 판단이 필요한 경우에만 로드" — State and Closeout Rules에서 HARNESS-RECOVERY-VALIDATION.md 연결 명시 ✓ |

**5. prompts**

| Surface | 확인 항목 | 결과 |
|---|---|---|
| codex-session-start.md | failure path → HARNESS-RECOVERY-VALIDATION.md | L391, L408 정상 ✓ |
| claude-session-start.md | §9/§15 stale ref | 없음 — HARNESS-PROTOCOL 참조는 "필요한 경우" 조건부 broad (L10) + routing/pointer (L139) ✓ |
| cursor-session-start.md | §9/§15 stale ref | 없음 — HARNESS-PROTOCOL 참조는 routing/pointer only (L4, L14) ✓ |

**6. scaffold** (CP-5에서 확인 완료)

| 확인 항목 | 결과 |
|---|---|
| create-harness.sh 두 slice 복사 | adapt 행 L210(HARNESS-NAMING-RULES), L211(HARNESS-RECOVERY-VALIDATION) ✓ |
| temp 산출물 두 파일 존재 | `/private/tmp/awh-rp-008-actual/docs/` 양쪽 확인 ✓ |
| 산출물 routing pointer (AGENT-WORKFLOW / health / SKILL / codex prompt) | source와 동일 — 5개 surface 전체 정합 ✓ |

**7. stale reference scan 종합** (CP-3 결과 + 추가 확인)

| Match | 맥락 | 판정 |
|---|---|---|
| HARNESS-NAMING-RULES.md self-ref (헤더 L3) | §9 추출 출처 명시 | reviewed non-blocking ✓ |
| HARNESS-RECOVERY-VALIDATION.md self-ref (헤더 L7) | §15 추출 출처 명시 | reviewed non-blocking ✓ |
| SCAFFOLD-ONBOARDING-GUIDE §9 | BOOTSTRAP.md §9 Completion Rule 맥락 | reviewed non-blocking ✓ |
| WORKFLOW-MANUAL §15 | K8s section 맥락 | reviewed non-blocking ✓ |
| claude-session-start.md HARNESS-PROTOCOL (L10, L139) | 조건부 broad + new project draft routing pointer | reviewed non-blocking ✓ |
| cursor-session-start.md HARNESS-PROTOCOL (L4, L14) | routing/pointer only | reviewed non-blocking ✓ |
| work.md / workflow-work HARNESS-PROTOCOL | Work File Decomposition/Quick Mode section-specific conditional | reviewed non-blocking ✓ |

**판정: 전 항목 PASS — policy 누락, stale pointer, scaffold 누락, command-skill mismatch 없음**
