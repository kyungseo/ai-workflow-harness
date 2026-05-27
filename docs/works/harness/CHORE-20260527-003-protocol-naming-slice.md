---
id: CHORE-20260527-003
priority: P2
status: Done
risk: Medium
scope: HARNESS-PROTOCOL.md §9 Naming Rules를 HARNESS-NAMING-RULES.md로 추출하고, 조건부 routing model을 AGENT-WORKFLOW.md에 정의하여 agent가 /start, /pick 등 일반 흐름에서 전체 protocol을 로드하지 않도록 한다.
appetite: 1d
planned_start: 2026-05-27
planned_end: 2026-05-28
actual_end: 2026-05-27
related_dr: [DR-013]
related_commits: []
related_troubleshooting: []
---

# CHORE-20260527-003: Protocol Context Budget Optimization — Naming Rules First Slice

## Plan

### 목표

`docs/HARNESS-PROTOCOL.md` (677줄)는 현재 여러 책임을 단일 파일로 들고 있다.
이 Work의 목표는 파일을 보기 좋게 쪼개는 것이 아니라, **하나의 신뢰 가능한 routing model을 유지하면서 agent가 필요한 policy slice만 조건부로 로드**하도록 하는 것이다.

첫 slice로 §9 Naming Rules를 `docs/HARNESS-NAMING-RULES.md`로 추출하고, `docs/AGENT-WORKFLOW.md` Context Loading 테이블에 명시적 로드 조건과 스킵 조건을 정의한다.

### 왜 §9 Naming Rules를 첫 slice로?

| 판단 기준 | §9 Naming Rules 평가 |
| --- | --- |
| 다른 section과 독립적인가? | Yes — section 내용상 근거·관련 DR은 DR-008이며 section 내 cross-dependency 없음. live pointer(AGENT-WORKFLOW.md, GIT-WORKFLOW.md, HARNESS-QUICK-REFERENCE.md, source-gitflow template)는 CP-1에서 별도 측정한다 |
| 트리거가 명확한가? | Yes — Work ID 부여·검증, OQ/DR ID, 파일명 확인 시에만 필요 |
| 최근 가장 크게 확장된 section인가? | Yes — CHORE-20260527-001에서 신규 Work ID 형식, Historical Prefix, external tracker override 등 대폭 확장 |
| 불필요한 full-load 사례가 있는가? | Yes — `/start`, `/pick` 흐름에서 protocol 전체 참조 지시가 남아있으며 naming detail은 불필요 |
| two-track에서 같은 의미로 동작하는가? | Yes — Naming은 harness-owned. 외부 tracker override(Jira 등)는 §9 내부에 이미 기술되어 있어 project-specific override 범위가 명확 |

**결론: `docs/HARNESS-NAMING-RULES.md`가 첫 policy slice로 적절하다.**

### Two-Track 구성 관리 검토 축

- **Source harness repo**: `docs/HARNESS-NAMING-RULES.md`가 canonical. routing map은 `AGENT-WORKFLOW.md`에서 정의.
- **Scaffold product repo**: 동일한 naming semantics 적용. external tracker override는 HARNESS-NAMING-RULES.md 내 기술로 충분.
- **Scaffold template** (`scripts/templates/source-gitflow/docs/GIT-WORKFLOW.md`): 현재 `HARNESS-PROTOCOL.md §9` pointer 포함 → 새 파일로 갱신 필요.
- **Project-specific override 가능 영역**: branch naming convention (`feature/*` vs project policy). Naming Rules는 Work ID, OQ ID, DR ID, File Naming 등 harness-owned 규칙만 담으며 project policy override가 필요한 내용은 `docs/GIT-WORKFLOW.md`가 이미 담당하고 있음.
- **확인 대상**: source-repo-only rule과 project-repo rule이 `HARNESS-NAMING-RULES.md` 안에 섞이지 않는지 확인. 섞이면 이번 Work에서 해결하지 않고 follow-up 후보로 기록.

### 구현하지 않는 것 (Out of Scope)

아래는 실제 context pressure가 확인되거나 반복 수정이 발생한 뒤 별도 Work로 분리한다.

| Follow-up 후보 | 추출 전 정의 필요 사항 |
| --- | --- |
| `docs/HARNESS-CASCADE-CHECKS.md` | Trigger 조건, owner doc, mirror surfaces, scaffold behavior |
| `docs/HARNESS-WORK-LIFECYCLE.md` | Trigger 조건, owner doc, /close·archive routing |
| `docs/HARNESS-RECOVERY.md` | validation failure 전용, failure 후 재개 시점만 로드 |
| two-track 구성 관리 전면 리팩토링 | source-repo-only rule과 project-override rule의 완전한 경계 정의 |
| scaffold 구조 변경 | 이번 Work에서는 create-harness.sh copy list 갱신만 허용 |
| AI surface(command/skill/rule) 리팩토링 | pointer 갱신 외 로직 변경 없음 |

---

## Scope

### CP-1: Context Hotspot 측정 (사전 검증)

구현 전 현재 상태를 측정한다.

```bash
# canonical doc 규모
wc -l docs/HARNESS-PROTOCOL.md docs/AGENT-WORKFLOW.md docs/HARNESS-QUICK-REFERENCE.md

# §9 외부 참조 (HARNESS-PROTOCOL.md 본문 제외)
rg -n "HARNESS-PROTOCOL.*§9|§9.*[Nn]aming" \
  docs .claude .agents scripts \
  --glob '*.md' --glob '*.mdc' \
  --glob '!docs/HARNESS-PROTOCOL.md' \
  --glob '!docs/archive/**'

# Naming 관련 전체 참조
rg -n "HARNESS-PROTOCOL|HARNESS-NAMING" \
  docs .claude .agents scripts \
  --glob '*.md' --glob '*.mdc' \
  --glob '!docs/HARNESS-PROTOCOL.md' \
  --glob '!docs/archive/**'

# /start, /pick, /register, /work command/skill에서
# HARNESS-PROTOCOL 전체 로드를 강제하는 지시 위치
rg -n "HARNESS-PROTOCOL" \
  .claude/commands/start.md \
  .claude/commands/pick.md \
  .claude/commands/register.md \
  .claude/commands/work.md \
  .agents/skills/workflow-start/SKILL.md \
  .agents/skills/workflow-pick/SKILL.md \
  .agents/skills/workflow-register/SKILL.md \
  .agents/skills/workflow-work/SKILL.md 2>/dev/null
```

예상 결과: §9 외부 pointer는 아래 3곳이며 이것이 갱신 대상이다.

| 파일 | 현재 참조 | 갱신 후 |
| --- | --- | --- |
| `docs/AGENT-WORKFLOW.md:117` | `HARNESS-PROTOCOL.md §9` | `HARNESS-NAMING-RULES.md` |
| `docs/GIT-WORKFLOW.md:71` | `HARNESS-PROTOCOL.md §9` | `HARNESS-NAMING-RULES.md` |
| `scripts/templates/source-gitflow/docs/GIT-WORKFLOW.md:68` | `HARNESS-PROTOCOL.md §9` | `HARNESS-NAMING-RULES.md` |

`docs/HARNESS-QUICK-REFERENCE.md:240`은 `HARNESS-PROTOCOL.md` 일반 참조 → `HARNESS-NAMING-RULES.md`로 갱신.

### CP-2: Routing Map 정의 (content 이동 전)

`docs/AGENT-WORKFLOW.md` Context Routing 테이블에 아래 행을 추가하고, 기존 §9 pointer를 갱신한다.

| Need | Load |
| --- | --- |
| Work ID 부여·검증, OQ/DR ID, 파일명 규칙 확인 | `docs/HARNESS-NAMING-RULES.md` |

**명시적 스킵 조건**을 같은 문서에 기술한다.

| Command / 흐름 | HARNESS-NAMING-RULES.md 필요 여부 | 이유 |
| --- | --- | --- |
| `/start` (일반 세션 시작) | 불필요 | 현재 상태 확인만 수행 |
| `/pick` (backlog 비교) | 불필요 | candidate title/slug만 비교. ID 미확정 |
| `/register` (등록 시 ID 확정) | **필요** | Work ID `<TYPE>-<YYYYMMDD>-<NNN>` 형식 부여 |
| `/work` (착수 시 ID 확정) | **필요** | Work 파일 생성·ID 최종 확정 |
| `/close` (Done 처리) | 불필요 (원칙) | ID는 이미 확정됨. Work ID 검증이 필요한 경우에만 로드 |
| branch/release 대화 (branch 이름 + Work ID 연결 논의) | **필요** | Work ID ↔ branch slug 관계 확인 |
| branch/release 대화 (단순 PR open, merge 논의) | 불필요 | branch naming은 GIT-WORKFLOW.md가 담당 |

### CP-3: §9 추출 — `docs/HARNESS-NAMING-RULES.md` 생성

`docs/HARNESS-PROTOCOL.md §9` (L223–L295) 전체를 `docs/HARNESS-NAMING-RULES.md`로 이동한다.

`docs/HARNESS-PROTOCOL.md §9`에는 아래 pointer section만 남긴다.

```markdown
## 9. Naming Rules

ID 형식, File Naming, Historical Prefix 기준은`docs/HARNESS-NAMING-RULES.md`를 따른다.
Work ID, OQ ID, DR ID 부여 또는 검증이 필요할 때만 로드한다.
```

**주의 사항:**
- §9 본문 prose를 HARNESS-PROTOCOL.md에 중복 유지하지 않는다.
- HARNESS-NAMING-RULES.md 상단에 위치 설명과 참조 목적을 1–2줄로 기재한다.
- 관련 없는 protocol prose는 rewrite하지 않는다.

### CP-4: Pointer 갱신

| 파일 | 변경 내용 |
| --- | --- |
| `docs/AGENT-WORKFLOW.md` | Context Routing 테이블에 HARNESS-NAMING-RULES.md 행 추가; `§9` → `HARNESS-NAMING-RULES.md`; 스킵 조건 기술 |
| `docs/HARNESS-QUICK-REFERENCE.md` | L240 HARNESS-PROTOCOL.md 참조 → HARNESS-NAMING-RULES.md |
| `docs/GIT-WORKFLOW.md` | L71 `§9` → `HARNESS-NAMING-RULES.md` |
| `.claude/commands/register.md` | Work ID 부여·검증 단계에 `docs/HARNESS-NAMING-RULES.md` 조건부 로드 pointer 추가 (기존 §9 ref 있으면 교체, 없으면 신규 추가) |
| `.claude/commands/work.md` | 동일 — Work ID 확정 단계에 pointer 추가 |
| `.agents/skills/workflow-register/SKILL.md` | 동일 — register.md와 mirror 유지 |
| `.agents/skills/workflow-work/SKILL.md` | 동일 — work.md와 mirror 유지 |

### CP-5: Scaffold 갱신

| 파일 | 변경 내용 |
| --- | --- |
| `scripts/create-harness.sh` | `HARNESS-NAMING-RULES.md` copy 행 추가 (HARNESS-PROTOCOL.md 행 인접) |
| `scripts/templates/source-gitflow/docs/GIT-WORKFLOW.md` | L68 `§9` → `HARNESS-NAMING-RULES.md` |

scaffold output에 `HARNESS-NAMING-RULES.md`가 포함되어야 한다.
scaffold output의 `AGENT-WORKFLOW.md`가 naming rules load 조건을 가리켜야 한다.

### CP-6: Verification

```bash
# 1. stale §9 reference가 의도된 pointer section 외에 남아있는지
rg -n "HARNESS-PROTOCOL.*§9|§9.*[Nn]aming" \
  docs .claude .agents scripts \
  --glob '*.md' --glob '*.mdc' \
  --glob '!docs/HARNESS-PROTOCOL.md' \
  --glob '!docs/archive/**'

# 2. diff check
git diff --check

# 3. scaffold script syntax
bash -n scripts/create-harness.sh

# 4. scaffold dry-run (generic)
bash scripts/create-harness.sh --dry-run naming-generic /private/tmp/awh-naming-generic

# 5. scaffold actual generation (temp)
bash scripts/create-harness.sh naming-actual /private/tmp/awh-naming-actual
ls /private/tmp/awh-naming-actual/docs/HARNESS-NAMING-RULES.md

# 6. scaffold dry-run (source-gitflow)
bash scripts/create-harness.sh --workflow source-gitflow --dry-run naming-gitflow /private/tmp/awh-naming-gitflow

# 7. scaffold dry-run (spring-boot profile)
bash scripts/create-harness.sh --profile spring-boot --dry-run naming-springboot /private/tmp/awh-naming-springboot
```

**Routing model 검증 (문서 읽기 기반):**

| 검증 항목 | 방법 |
| --- | --- |
| `/start`, `/pick` 흐름이 naming rules 로드를 요구하지 않는가 | `start.md`, `pick.md`, `workflow-start/SKILL.md`, `workflow-pick/SKILL.md`에서 HARNESS-NAMING-RULES.md 또는 §9 load 지시 없음을 확인 |
| `/register`, `/work`가 ID 부여 시 naming rules를 route하는가 | `register.md`, `work.md`, 대응 SKILL.md에서 `HARNESS-NAMING-RULES.md` load 조건이 Work ID 확정 단계에만 위치하는지 확인 |
| branch/release 대화 (단순 PR)가 naming rules를 강제하지 않는가 | `GIT-WORKFLOW.md`에서 naming rules 참조가 Work ID ↔ branch slug 필요 시에만 나타나는지 확인 |
| 신규 scaffold에 HARNESS-NAMING-RULES.md가 포함되는가 | temp scaffold output에서 파일 존재 확인 |
| scaffold AGENT-WORKFLOW.md가 새 routing 행을 포함하는가 | scaffold AGENT-WORKFLOW.md에 HARNESS-NAMING-RULES.md load 조건 확인 |

**Two-track 검증:**

| 검증 항목 | 방법 |
| --- | --- |
| HARNESS-NAMING-RULES.md 내 source-repo-only 규칙이 없는가 | 파일 본문에서 "source harness repo only" 또는 Gitflow-고정 표현이 있으면 flag |
| Project-specific override 내용이 HARNESS-NAMING-RULES.md가 아닌 GIT-WORKFLOW.md에 위치하는가 | 두 파일 대조 |
| scaffold template GIT-WORKFLOW.md pointer 갱신 완료 | `scripts/templates/source-gitflow/docs/GIT-WORKFLOW.md`에 stale §9 ref 없음 |

### CP-7: Two-Track 구성 관리 점검 결과 기록

위 검증에서 중복·충돌·모순이 발견되면 이번 Work에서 해결하지 않고 Discovery 섹션에 follow-up 후보로 기록한다.

---

## Done Criteria

- [x] Context hotspot 측정 완료 (CP-1 grep 결과 검토)
- [x] Routing map이 `docs/AGENT-WORKFLOW.md`에 명시됨 — load 조건과 스킵 조건 포함 (CP-2)
- [x] `docs/HARNESS-NAMING-RULES.md` 생성 완료 — §9 전체 내용 포함 (CP-3)
- [x] `docs/HARNESS-PROTOCOL.md §9`에 pointer section만 남음 (CP-3)
- [x] 외부 §9 pointer 3곳 갱신 완료 (AGENT-WORKFLOW, GIT-WORKFLOW, source-gitflow template) (CP-4)
- [x] HARNESS-QUICK-REFERENCE.md 참조 갱신 (CP-4)
- [x] register.md, work.md, workflow-register/SKILL.md, workflow-work/SKILL.md에 Work ID 부여·검증 시 HARNESS-NAMING-RULES.md 조건부 로드 pointer 추가 (CP-4)
- [x] `scripts/create-harness.sh`에 HARNESS-NAMING-RULES.md copy 행 추가 (CP-5)
- [x] stale §9 reference가 의도된 pointer section 외에 남지 않음 (CP-6 grep 통과)
- [x] `git diff --check` 통과 (CP-6)
- [x] `bash -n scripts/create-harness.sh` 통과 (CP-6) — Codex 환경에서 확인
- [x] scaffold dry-run + actual generation 완료, HARNESS-NAMING-RULES.md 포함 확인 (CP-6) — Codex 환경에서 generic/source-gitflow/spring-boot dry-run 및 actual generation 통과
- [x] Routing model 검증 완료 — /start, /pick 흐름에 naming rules load 없음, /register·/work Work ID 단계에 pointer 추가 확인 (CP-6)
- [x] Two-track 점검 결과 기록 완료 (CP-7)
- [x] two-track 문제 미발견 — source-only rule과 project-override rule 혼재 없음 (CP-7)

---

## Verification

CP-6의 명령어 목록 참조.
검증 실행 불가 시 이유와 남은 risk를 Discovery에 기록한다.

---

## Checkpoints

| CP | Description | Status |
|----|-------------|--------|
| 1  | Context hotspot 측정 | Done |
| 2  | Routing map 정의 및 AGENT-WORKFLOW.md 갱신 | Done |
| 3  | §9 추출 — HARNESS-NAMING-RULES.md 생성 | Done |
| 4  | Pointer 갱신 (AGENT-WORKFLOW, HARNESS-QR, GIT-WORKFLOW, commands, skills) | Done |
| 5  | Scaffold 갱신 (create-harness.sh, source-gitflow template) | Done |
| 6  | Verification 전체 실행 | Done — Codex 환경에서 전체 통과 |
| 7  | Two-track 구성 관리 점검 결과 기록 | Done |

---

## Discovery

### CP-1 Hotspot 측정 결과 (2026-05-27)

**Canonical doc 규모:**

| 파일 | 줄 수 |
| --- | --- |
| `docs/HARNESS-PROTOCOL.md` | 677 |
| `docs/AGENT-WORKFLOW.md` | 188 |
| `docs/HARNESS-QUICK-REFERENCE.md` | 248 |

**§9 live pointer 위치 (갱신 대상 3곳 + 1곳):**

| 파일:줄 | 현재 참조 | 갱신 후 |
| --- | --- | --- |
| `docs/AGENT-WORKFLOW.md:117` | `HARNESS-PROTOCOL.md §9` | `HARNESS-NAMING-RULES.md` |
| `docs/AGENT-WORKFLOW.md:170` | `HARNESS-PROTOCOL.md` (Trigger And Naming Pointers 섹션) | `HARNESS-NAMING-RULES.md` |
| `docs/GIT-WORKFLOW.md:71` | `HARNESS-PROTOCOL.md §9` | `HARNESS-NAMING-RULES.md` |
| `scripts/templates/source-gitflow/docs/GIT-WORKFLOW.md:68` | `HARNESS-PROTOCOL.md §9` | `HARNESS-NAMING-RULES.md` |
| `docs/HARNESS-QUICK-REFERENCE.md:240` | `HARNESS-PROTOCOL.md` (naming context) | `HARNESS-NAMING-RULES.md` |

**register.md / workflow-register SKILL.md:** §9 pointer 없음. Work ID 형식 인라인 기술만 존재 → pointer 신규 추가 대상.

**work.md / workflow-work SKILL.md:** Work ID 확정 단계(2a)에 §9 pointer 없음 → pointer 신규 추가 대상. `work.md:60` HARNESS-PROTOCOL.md 참조는 harness 구조 변경 시 로드 지시이며 naming rules와 무관 — 유지.

**변경하지 않는 파일:** `health.md`, `workflow-health/SKILL.md` (cascade/recovery 섹션 참조, 정당), `WORKFLOW-MANUAL.md` (user-facing), 각종 decisions·retrospectives (불변).

**Two-track 점검 (CP-1 수준):** §9 본문에 source-repo-only 규칙 미발견. external tracker override 항목은 이미 project-specific으로 범위가 한정되어 있음. `scripts/templates/source-gitflow/docs/GIT-WORKFLOW.md`의 §9 ref만 갱신하면 두 track에서 동일하게 동작할 것으로 판단됨.

### CP-7 Two-Track 구성 관리 점검 결과 (2026-05-27)

- **Source-only rule 혼재**: 없음. `docs/HARNESS-NAMING-RULES.md` 본문에 source-repo-only 규칙 미발견.
- **Project-override 범위**: external tracker override(Jira, Linear 등) 항목이 이미 "project-specific tracker policy가 하네스 기본값보다 우선할 수 있다"로 범위가 한정되어 있음. 혼재 없음.
- **Scaffold template 갱신**: `scripts/templates/source-gitflow/docs/GIT-WORKFLOW.md` §9 ref를 `HARNESS-NAMING-RULES.md`로 갱신 완료.
- **동일 의미 동작 확인**: naming slice는 harness-owned이며 source harness repo와 scaffold product repo 양쪽에서 같은 의미로 동작할 것으로 판단.
- **다른 scaffold template 점검**: `scripts/templates/` 하위에 `default`와 `source-gitflow` 두 디렉토리 존재. `default` template에는 §9 또는 naming-rules ref 없음. 추가 갱신 불필요.

### Follow-up 후보 (Pre-populated from planning)

| 후보 | 조건 |
| --- | --- |
| `docs/HARNESS-CASCADE-CHECKS.md` 추출 | trigger/cascade section의 실제 context pressure가 확인될 때 |
| `docs/HARNESS-WORK-LIFECYCLE.md` 추출 | /close, archive 흐름에서 full-protocol load가 반복될 때 |
| `docs/HARNESS-RECOVERY.md` 추출 | failure/recovery 규칙이 일반 흐름 load를 오염할 때 |
| Two-track 구성 관리 경계 정의 Work | 이번 점검에서 source-only rule과 project-override rule의 혼재가 확인될 때 |
| Harness Adoption/Upgrade Model (08번 draft) | public 사용자의 upgrade 수요 또는 manifest 기반 drift detection 필요 시 |
