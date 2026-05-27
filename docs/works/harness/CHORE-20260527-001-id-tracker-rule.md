---
id: CHORE-20260527-001
priority: P2
status: Done
risk: Medium
scope: Work ID·OQ ID·DR ID 책임과 범위 정의, 병렬 feature 충돌 규칙, /register·/work workflow 반영, cascade 확인
appetite: 1w
planned_start: 2026-05-27
planned_end: 2026-06-03
actual_end: 2026-05-27
related_dr: [DR-013]
related_commits: [89bb0e4]
related_troubleshooting: []
---

# CHORE-20260527-001: Work/OQ/Tracker ID Rule And Registration Policy

## Plan

### Background

HRN-036~040에서 branch isolation, release gate, scaffold/source boundary를 정비했다.
다음 과제는 Work ID, OQ ID, DR ID 규칙이 전역 순번 중심으로 남아 있어 병렬 feature, main patch/hotfix, scaffold product repo 운영과 충돌할 수 있다는 점이다.

### Approach

1. **canonical 정의 먼저**: `docs/HARNESS-PROTOCOL.md`에 새 ID 규칙을 확정하고, 이 Work 자체가 첫 적용 사례(`CHORE-20260527-001`)가 된다.
2. **workflow surface 반영**: `/register`, `/work` workflow에 TYPE 판단과 next-ID 제안 로직을 반영한다.
3. **cascade 확인**: 나머지 commands(pick/resume/close/done), HARNESS-QUICK-REFERENCE.md, AGENT-WORKFLOW.md, GIT-WORKFLOW.md, scaffold 생성물을 확인하고 필요한 곳만 수정한다.
4. **Out of Scope 엄수**: 기존 HRN-### archive 보존, DR-### 체계 유지, branch isolation enforcement 강화는 제외한다.

### Decision Baseline

**Work ID 형식:**
```
<TYPE>-<YYYYMMDD>-<NNN>
```

**TYPE semantics (routing 기준):**

| TYPE | 대상 | branch guidance (default) |
|------|------|--------------------------|
| FEAT | product/user-visible feature work | 프로젝트 통합 branch 기준 feature/* |
| PATCH | non-emergency correction, release-prep patch | 프로젝트 통합 branch 기준 feature/* 또는 feature/release-prep-* |
| HOTFIX | urgent fix (security, data integrity, service outage) | 프로젝트 release branch 기준 hotfix/* (있는 경우) |
| CHORE | harness/process/docs/tooling maintenance (user-visible 기능 변화 없음) | 프로젝트 통합 branch 기준 feature/* |

※ source repo는 Gitflow(feature/* → develop → main) 사용. scaffold product repo는 project-specific GIT-WORKFLOW.md로 override 가능. canonical 반영: HARNESS-PROTOCOL.md §9.

- `feature/release-prep-*` branch의 Work: 기본 CHORE. non-emergency public release correction이면 PATCH. urgent main/release-line fix이면 HOTFIX. (검증 대상 가설)
- PATCH와 HOTFIX 구분 기준: production 영향 즉시성. HOTFIX는 서비스 중단·보안·데이터 정합성 긴급 상황만.

**PATCH TYPE 혼동 방지:**
TYPE `PATCH`는 작업 성격(non-emergency correction)이고, branch는 기존 `feature/*` 또는 `feature/release-prep-*`를 사용한다. `patch/*` branch family는 이번 Work에서 도입하지 않는다. 긴급 main 기준 수정은 HOTFIX + `hotfix/*`로 처리한다. TYPE-to-branch 권장 매핑을 명시적으로 문서화한다.

**OQ ID:**
- Work 파일 내부: `OQ-1`, `OQ-2` (Work-local)
- 전역 참조: `<WORK-ID>/OQ-1`
- Global OQ registry 없음. STATUS Blockers 또는 DR 승격 시에만 별도 ID.

**DR ID:**
- `DR-###` 유지. Work frontmatter `related_dr` 또는 본문 링크로 연결.

**Backlog 후보 ID (B안 채택):**
- backlog candidate는 제목/slug만 유지. 착수 승인 후 Work 파일 생성 시 ID 확정.
- `/pick` 단계: 후보는 제목/slug 기준 비교. ID는 없음.
- `/register` 단계: candidate row 생성, ID 없음.
- `/work` 단계: ID 확정, backlog row 갱신.
- 이유: 착수 전 ID 선점은 병렬 branch 충돌 가능성을 높이고, 미착수 후보에 phantom ID를 만든다.

**병렬 충돌 조정:**
- NNN 우선 > 날짜 조정.
- 날짜는 착수/등록일 의미를 보존해야 하므로 변경하지 않는다. 충돌은 같은 날 다음 NNN을 재배정해 해결한다.
- 이미 리뷰 진행 중 또는 외부 참조가 있으면 변경 비용을 보고하고 사용자 승인 후 조정.

**Backlog 후보 등록 위치:**
- 현재 active feature 진행 중 발견한 후속 아이디어는 Work Discovery 섹션에 임시 기록.
- merge/close 이후 backlog 반영. develop 직접 수정은 불허.

**HRN-* 신규 생성:** 중단. 기존 archive 보존. rewrite 없음.

### Impact Surface

**Primary (rule 정의):**
- `docs/HARNESS-PROTOCOL.md` — Work ID naming section
- `docs/AGENT-WORKFLOW.md` — Work Item Routing
- `docs/GIT-WORKFLOW.md` — branch naming과 Work ID 관계

**Secondary (workflow 업데이트):**
- `.claude/commands/register.md`
- `.agents/skills/workflow-register/SKILL.md`
- `.claude/commands/work.md`
- `.agents/skills/workflow-work/SKILL.md`
- `docs/HARNESS-QUICK-REFERENCE.md`

**Cascade 확인 대상 (변경 여부 현장 판단):**
- `.claude/commands/pick.md`, `resume.md`, `close.md`, `done.md`
- `.agents/skills/workflow-pick/`, `workflow-resume/`, `workflow-close/`, `workflow-done/`
- `.cursor/rules/workflow.mdc`
- `prompts/*session-start.md`
- `docs/WORKFLOW-MANUAL.md`
- `README.md` — public-facing command/branch overview 변경 여부
- `scripts/create-harness.sh` generated templates
- `docs/HARNESS-MAINTAINER-GUIDE.md` (존재 여부 CP-3 전 pre-check)
- `docs/decisions/DR-008-docs-filename-standard.md` — 파일명 규칙과 새 ID compatibility (직접 수정 신중, 검토만)
- `docs/decisions/DR-013-work-file-spec.md` — Work ID 예시 업데이트 여부 검토

## Done Criteria

- [x] Work ID rule `<TYPE>-<YYYYMMDD>-<NNN>`이 `docs/HARNESS-PROTOCOL.md`에 canonical 정의됨
- [x] TYPE semantics(FEAT/PATCH/HOTFIX/CHORE) 경계와 HRN-* 관계 문서화됨
- [x] TYPE-to-branch 권장 매핑이 명시적으로 문서화됨 (PATCH TYPE 혼동 방지)
- [x] `/register` workflow가 TYPE 판단 + next-ID 제안 포함 (ID-less candidate 처리 포함)
- [x] `/work` workflow가 Work ID 확정 + backlog row 갱신 포함
- [x] OQ ID / DR ID 관계 문서화됨
- [x] 병렬 feature conflict handling 문서화됨 (NNN 우선 + 날짜 불변 원칙)
- [x] Branch naming recommendation이 Work ID와 정합됨 (`docs/GIT-WORKFLOW.md` 포함)
- [x] Backlog 후보 ID B안(착수 시 ID 확정)이 /pick, /register 동작과 일관됨
- [x] Scaffold 신규 ID rule 반영 여부 확인됨
- [x] HRN archive/history migration 수행하지 않음 명시됨
- [x] 기존 `HRN-*` 참조가 archive/history에는 남고 live 신규 생성 경로에서는 사라졌는지 구분 확인됨
- [x] Work 파일명 규칙 `{ID}-{lowercase-topic}.md`와 새 ID 형식 compatibility 확인됨
- [x] STATUS.md, Work README, backlog, DR related fields의 새 ID 예시가 서로 일관됨
- [x] generic + spring-boot scaffold validation 통과 — dry-run 및 실제 생성 검증 완료 (2026-05-27)
- [x] `git diff --check` 통과
- [x] `bash -n scripts/create-harness.sh` 통과 (사용자 직접 확인)

## Verification

```bash
# 1. ID rule 정의 확인
rg -n "TYPE|YYYYMMDD|CHORE|FEAT|PATCH|HOTFIX" docs/HARNESS-PROTOCOL.md

# 2. /register workflow TYPE 판단 + next-ID 포함 여부
rg -n "TYPE|CHORE|FEAT|candidate" .claude/commands/register.md
rg -n "TYPE|CHORE|FEAT|candidate" .agents/skills/workflow-register/SKILL.md

# 3. /work workflow Work ID 확정 + backlog row 갱신 포함 여부
rg -n "Work ID|backlog row|확정|ID 확정" .claude/commands/work.md

# 4. cascade 확인 — 변경 필요 없음 판단 근거 기록 대상
#    pick/resume/close/done 각각 ID 참조 방식이 B안(착수 시 확정)과 충돌하지 않는지
rg -n "Work ID|HRN-|registration|next.*ID" \
  .claude/commands/pick.md \
  .claude/commands/resume.md \
  .claude/commands/close.md \
  .claude/commands/done.md

# 5. HRN-* live 생성 경로 잔존 여부 (archive 제외)
rg -n "HRN-" docs .claude .agents prompts scripts \
  -g '*.md' -g '*.mdc' -g '!docs/archive/**'

# 6. 새 ID 예시 일관성
rg -n "CHORE-|FEAT-|PATCH-|HOTFIX-" \
  docs/STATUS.md \
  docs/works/harness/README.md \
  docs/HARNESS-QUICK-REFERENCE.md

# 7. scaffold syntax check
bash -n scripts/create-harness.sh

# 8. scaffold dry-run — 실제 생성 없이 plan 출력 (generic + spring-boot 둘 다)
bash scripts/create-harness.sh --dry-run --profile generic test-project /private/tmp/test-harness-generic
bash scripts/create-harness.sh --dry-run --profile spring-boot test-project /private/tmp/test-harness-springboot

# 9. scaffold 실제 생성 확인 — generic + spring-boot (dry-run 이후 별도 단계)
bash scripts/create-harness.sh --profile generic test-project /private/tmp/test-harness-generic && \
  echo "generic OK" && rm -rf /private/tmp/test-harness-generic
bash scripts/create-harness.sh --profile spring-boot test-project /private/tmp/test-harness-springboot && \
  echo "spring-boot OK" && rm -rf /private/tmp/test-harness-springboot

# 10. diff check
git diff --check
```

**Verification Scenarios:**

| # | Scenario | 기대 결과 |
|---|----------|-----------|
| 1 | 신규 harness chore 등록 | `CHORE-YYYYMMDD-NNN` 제안 |
| 2 | 신규 product feature 등록 | `FEAT-YYYYMMDD-NNN` 제안 |
| 3a | non-emergency correction 등록 | `PATCH-YYYYMMDD-NNN` + `feature/*` or `feature/release-prep-*` 안내 |
| 3b | urgent main fix 등록 | `HOTFIX-YYYYMMDD-NNN` + `hotfix/*` branch 안내 |
| 4 | 병렬 branch 같은 날짜/NNN 충돌 | NNN 재배정 안내, 날짜 불변 |
| 5 | Work-local OQ full reference | `CHORE-20260527-001/OQ-1` 형식 |
| 6 | DR 연결 | `related_dr: [DR-014]` frontmatter 형식 |
| 7 | HRN archive rewrite 없음 | `docs/archive/` 변경 없음 |
| 8 | scaffold 신규 ID 포함 | generic/spring-boot 생성물 확인 |

## Checkpoints

| CP | Description | Status |
|----|-------------|--------|
| 1 | feature branch `feature/chore-20260527-001-id-tracker-rule` 생성 | Done |
| 2 | Work 파일 생성, STATUS.md Active Work 갱신 | Done |
| 2a | Work 파일 리뷰 보완 (TYPE semantics, Backlog B안, Impact Surface, Verification 강화) | Done |
| 2b | 최종 재검토 반영 (patch/* 제거, Scenario 3 분리, scaffold 번호 정리) | Done |
| 3 | Pre-check: `HARNESS-MAINTAINER-GUIDE.md` 존재 여부 + DR-008/DR-013 cascade 범위 확인 | Done |
| 4 | `docs/HARNESS-PROTOCOL.md` ID rule section 작성 | Done |
| 5 | `docs/AGENT-WORKFLOW.md` Work Item Routing 갱신 | Done |
| 6 | `docs/GIT-WORKFLOW.md` branch naming ↔ Work ID 매핑 추가 | Done |
| 7 | `/register` command + skill TYPE 판단 + next-ID 로직 반영 | Done |
| 8 | `/work` command + skill Work ID 확정 + backlog row 갱신 반영 | Done |
| 9 | Cascade 확인: pick/resume/close/done — 변경 필요 없음 판단 근거 기록 | Done |
| 10 | HARNESS-QUICK-REFERENCE.md 갱신 | Done |
| 11 | WORKFLOW-MANUAL.md cascade 확인 (변경 여부 판단) | Done |
| 12 | README.md cascade 확인 | Done |
| 13 | DR-008, DR-013 영향 검토 (직접 수정 신중) | Done |
| 14 | scaffold 생성물 반영 확인 + dry-run/actual generation 검증 | Done |
| 15 | 1차 리뷰 반영 (P1 TYPE routing, P1 scaffold ID-less, P2 HRN 잔존 + rg flags, P3 branch naming) | Done |
| 15b | 2차 리뷰 반영 (P1 ONBOARDING-GUIDE + WORKFLOW-MANUAL + pick + prompts ID-less, P1 DR-013 track mapping, P2 external tracker override, P2 collision check) | Done |
| 15c | 3차 리뷰 반영 (P1 Gitflow decoupling — PROTOCOL/register TYPE table, P2 잔존 P1-004/P1-010 제거, P2 Work file 검증 결과 갱신) | Done |
| 16 | Commit 전 STATUS Finalization + Tracking Finalization 보고 | Done |

## Deferred Ideas

CHORE-20260527-001 closeout 시점에 도출된 후속 검토 후보. 이번 Work Done Criteria에는 포함하지 않는다. HARNESS.md Deferred Ideas에 등록됨.

| 주제 | 개요 | 결정 조건 |
|------|------|----------|
| Work ID collision 자동화 | 병렬 feature 증가 시 `/health`, git hook, script로 `docs/works/**` ID 중복 검사 자동화 | 병렬 Active Work가 3개 이상 반복되거나 collision이 실제 발생할 때 |
| STATUS/Work README merge conflict 규칙 | 병렬 feature가 Active Work pointer나 Work index를 동시 수정 시 conflict 처리 방침. Work frontmatter SSoT + STATUS/README 재생성 방식 검토 | 병렬 feature PR merge 시 conflict가 반복될 때 |
| DR-### global sequence 충돌 | 병렬 Draft DR 번호 충돌. `DR-DRAFT-{slug}` 허용 또는 Accepted 직전 번호 재확인 절차 검토 | 동시 진행 DR이 실제로 충돌하는 시점 |
| Command/skill mirror atomicity | Claude command와 Codex skill 한쪽만 수정 시 도구별 동작 차이. `/health --cascade` 또는 validation checklist 강화 검토 | command/skill mirror drift가 실제 운영 버그로 이어질 때 |
| Scaffold template drift window 관리 | ID rule 같은 template-level policy 변경 후 source repo main release 전 drift window. 소형 maintenance release 기준 검토 | 외부 적용 프로젝트가 늘어나고 drift 비용이 명확해질 때 |

## Open Questions

| ID | Question | Status |
|----|----------|--------|
| OQ-1 | CHORE TYPE이 너무 광범위해질 경우 sub-categorization 필요 여부 | Deferred — 이번 Work는 TYPE 4개 단순 유지. 필요 시 별도 Work |

## Discovery

### CP-15c Pre-Commit Review Round 3 (2026-05-27)

**[P1] Gitflow decoupling — 공통 canonical/command surface:**
- `docs/HARNESS-PROTOCOL.md §9` TYPE table: `develop 기준`, `main 기준` 등 Gitflow 고정 표현 → `프로젝트 통합 branch 기준`, `프로젝트 release branch 기준` (generic). Gitflow는 source-only default임을 명시하는 Note 추가.
- `.claude/commands/register.md` + `.agents/skills/workflow-register/SKILL.md`: `FEAT` 행 `develop → release 경로` → `프로젝트 통합 branch 기준 feature branch`.

**[P2] SCAFFOLD-ONBOARDING-GUIDE.md 잔존 P1 예시 제거:**
- L578: `Security + 인증 구현 (P1-004)` → `Security + 인증 구현` (P1-004 제거).
- L689: OQ 예시 `P1-010 착수 전` → `서비스 간 연계 착수 전`.

**[P2] Work 파일 검증 결과 갱신:**
- Done Criteria: scaffold validation 항목 — 사용자 직접 확인(dry-run + 실제 생성) 통과 결과 반영.
- Discovery CP-14: "수동 실행 필요" → 실제 실행 결과 기록.

### CP-15 Pre-Commit Review Round 1 (2026-05-27)

**[P1] TYPE routing 수정 — `.claude/commands/work.md`, `.agents/skills/workflow-work/SKILL.md`:**
- 기존: `CHORE-*`, `PATCH-*`, `HOTFIX-*` → 모두 HARNESS.md (오류)
- 수정: `FEAT-*`, `PATCH-*`, `HOTFIX-*` → track 기반 (product → PHASE{n}.md, harness → HARNESS.md); `CHORE-*` → HARNESS.md (항상)
- TYPE ≠ track 구분 명확화.

**[P1] ID-less candidate 반영 — scaffold surfaces:**
- `scripts/create-harness.sh` L377/L419/L473/L650/L657/L772: `P1-001~` 선점 문구 → "Work ID는 /work 착수 시 확정" 패턴으로 교체.
- `docs/SCAFFOLD-BOOTSTRAP.md` L31/L32/L46: product backlog `P1-001~` + harness backlog `HRN-001~` 신규 생성 경로 문구 → ID-less 언어로 교체.
- `docs/SCAFFOLD-ONBOARDING-GUIDE.md` L501: template row `**P1-001**` → `**[Project Initialization]**`.
- `prompts/claude-session-start.md` L46: `P1-001~ 후보를 먼저 제안해줘` → ID-less + timing note 추가.

**[P2] HRN-* live 잔존 정정:**
- CP-14 Discovery에서 "HRN-*" 잔존 없음으로 보고했으나, `docs/SCAFFOLD-BOOTSTRAP.md` L32/L46이 새 프로젝트에서 `HRN-001~` ID를 생성하도록 지시하는 실제 신규 생성 경로였음 — 이번 CP-15에서 ID-less 수정으로 제거 완료.
- Verification 명령 #5 rg flags: `--include="*.md"` → `-g '*.md' -g '*.mdc' -g '!docs/archive/**'` 수정 (zsh/rg 호환).
- Done Criteria L119 `[x]` 보류: SCAFFOLD-BOOTSTRAP.md 수정 후 재검증 필요 → 이번 수정으로 충족 확인됨.

**[P3] GIT-WORKFLOW.md branch naming 명시화:**
- Work ID uppercase, branch segment lowercase 규칙을 별도 Note로 추가.

### CP-15b Pre-Commit Review Round 2 (2026-05-27)

**[P1] SCAFFOLD-ONBOARDING-GUIDE.md ID-less 확장:**
- L247 Mermaid: `P1-001~ 후보 도출` → `초기 작업 후보 도출 (Work ID는 /work 착수 시 확정)`.
- L521-537 dependency tree: `P1-NNN` 식별자 제거 → 제목만, legacy example 주의 Note 추가.
- L541, 546, 559, 570-571, 575, 745: 신규 scaffold 경로 모두 ID-less 언어로 교체 (`P1-XXX` → `[title-or-slug]`, `FEAT-YYYYMMDD-NNN-topic.md`).

**[P1] WORKFLOW-MANUAL.md ID-less 확장:**
- L1421, L1495, L1507, L1528: `P1-001~` 및 `/work P1-001` → ID-less 언어 + timing note.

**[P1] pick.md / SKILL.md ID-less 확장:**
- `P1-001~ feature 후보` → `feature 후보` + ID-less timing note.

**[P1] prompts/codex-session-start.md, cursor-session-start.md ID-less 확장:**
- `P1-001~` → `초기 작업 후보` + Work ID timing note.

**[P1] DR-013 work directory mapping 수정:**
- `docs/works/harness/`: TYPE 기반(CHORE-* 고정) → track 기반 명시 (CHORE-*; harness-track FEAT-*/PATCH-*/HOTFIX-*).
- `docs/works/phase2/` + `docs/works/phase{n}/` → `docs/works/phase{n}/` 단일 행으로 통합, product-track FEAT-*/PATCH-*/HOTFIX-* 명시.

**[P2] HARNESS-PROTOCOL.md §9 external tracker override 추가:**
- Work ID 규칙 끝에 escape hatch note 추가: external tracker 사용 시 project-level override 허용, SSoT 매핑 기준 명시 조건.

**[P2] HARNESS-PROTOCOL.md Tracking Finalization collision check 추가:**
- Validation Checklist에 한 줄 추가: `Work ID collision 확인 — target branch docs/works/ 파일과 충돌 없음 확인 (병렬 branch NNN 충돌 방지)`.

### CP-14 Scaffold Validation (2026-05-27)

- `scripts/create-harness.sh` 내 `HRN-001~` 등록 안내(L487)와 HARNESS.md 템플릿 주석(L678) 2곳 업데이트 완료.
- `bash -n scripts/create-harness.sh`: 통과.
- dry-run generic/spring-boot: 통과.
- 실제 생성 generic/spring-boot (`/private/tmp/review-generic-final-20260527`, `/private/tmp/review-spring-final-20260527`): 성공. 생성된 scaffold에서 신규 생성 경로의 `P1-001~`, `HRN-001~`, `/work P1-001`, `P1-XXX` 잔존 없음 확인.
- `git diff --check`: 통과 (출력 없음).
- `HRN-*` live 잔존 여부: archive 외 `docs .claude .agents prompts scripts` 에서 `HRN-032` 산문 참조(README.md) 외 없음 — OK.
- 새 ID 예시 일관성: STATUS.md, harness README, HARNESS-QUICK-REFERENCE.md 모두 `CHORE-20260527-001` 형식 — OK.

### CP-3 Pre-check (2026-05-27)

- `HARNESS-MAINTAINER-GUIDE.md` 존재 확인. hook/branch naming 맥락에서 1행만 언급 — cascade 확인 대상 유지, 직접 수정 가능성 낮음.
- `HARNESS-PROTOCOL.md §9 Naming Rules` (L223-252): ID Prefix 테이블(L227-236)에 `HRN-*`, `HRF-*`, `PRE-*`, `DOC-*` 구 prefix 체계가 있고, `OQ-*` row가 `docs/STATUS.md` 전역으로 되어 있음. File Naming 예시(L246)도 `HRF-002-*` 구 형식. **CP-4의 직접 수정 대상** 확정.
- `DR-008`: `{ID}-{lowercase-topic}.md` 패턴을 DR-013에 위임. 새 `<TYPE>-<YYYYMMDD>-<NNN>` ID와 호환 — 변경 불필요.
- `DR-013`: `id:` frontmatter 예시가 `HRF-002, PRE-C1, P2-001`. 신규 형식 예시 추가 권장(minor). 직접 수정은 신중하게 처리.
