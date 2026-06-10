---
date: 2026-06-08
track: harness
type: reference
scope: 검증 명령 카탈로그 — 백로그 Verification 작성, cascade 점검, scaffold 생성 후 user action 시뮬레이션
status: active
related_work: []
---

# VERIFICATION-COMMANDS.md

검증 명령 참조 카탈로그. 백로그 항목 Verification 작성, Work 실행 중 cascade 점검, `/repo-health` 보완 목적으로 사용한다.

이 파일은 source repo 전용 maintainer 참조 문서다. scaffold 대상 아님.

**경계:** 이 파일은 **실행 명령 카탈로그(HOW — 어떤 명령으로 검증하나)**다. 실패 보고·복구 흐름, Validation Checklist, Commit Approval 같은 **판단·정책(WHETHER/WHEN — 진행해도 되나)**은 `docs/HARNESS-RECOVERY-VALIDATION.md`를 따른다.

관련 문서:
- `docs/AGENT-WORKFLOW.md` Verification Defaults — 변경 유형별 기본 검증 규칙
- `skills/workflow/repo-health.md` — `/repo-health` 전체 절차 및 Required Surface Matrix
- `docs/HARNESS-RECOVERY-VALIDATION.md` — 실패/복구·Validation Checklist·Commit Approval **판단 정책** (이 파일=명령, 그쪽=판단)

---

## 사용 원칙

- surface label("scaffold 점검") 대신 **grep 결과**로 확인한다. 결과가 검증 증거다.
- 각 Layer는 독립 실행 가능하다. 변경 범위에 맞는 Layer만 선택한다.
- 발견 항목은 문서 말미 **결과 분류 기준** 섹션 형식으로 보고한다.

> **이식성 주의:** 이 카탈로그의 명령은 maintainer가 직접 셸에서 실행하는 것을 전제한다. macOS 기본 `/usr/bin/grep`(BSD)은 일부 GNU 옵션을 지원하지 않는다. 해당 Layer에 호환 대안을 병기한다.

---

## Release Full Sweep (릴리즈 게이트 프리셋)

버전을 올려 릴리즈하기 전, 출하 표면 전수를 아래 순서로 점검한다.
변경 범위에 맞춰 Layer를 고르는 일반 사용과 달리, 릴리즈 시점에는 **출하 표면에 적용되는 Layer 전수**가 게이트다.

**실행 순서:**

| # | Layer | 점검 |
| --- | --- | --- |
| 1 | A | syntax / script 무결성 |
| 2 | C | scaffold invariant |
| 3 | R | VERSION ↔ manifest 일관성 |
| 4 | I | DR / README closure |
| 5 | E | canonical source 최신성 |
| 6 | F | tool-specific surface 정렬 |
| 7 | H | stale phrase / source-only 누수 |
| 8 | N | state consistency |
| 9 | O | file spec compliance |
| 10 | S | prompt surface 정렬 |
| 11 | G | user-facing docs 정합 |
| 12 | P | language policy |
| 13 | J + J-OB | scaffold + onboarding simulation (최고점) |
| 14 | Q | hook functional test (source-gitflow scaffold) |

**게이트 밖 (제외):**

- **Layer T** — upgrade/migration (미구현 placeholder). 구현 후 편입.
- **Layer K** — `/repo-health` 통합 실행. 위 전수를 포괄하는 umbrella이므로 개별 sweep과 병행 또는 대체로 선택.
- **Layer B · D · M** — 보조 진단 / 자체 점검. 필요 시 ad-hoc.

**release-go 판정:** 출하 표면 발견 항목을 분류한다.

| 분류 | 처리 |
| --- | --- |
| 출하 표면의 결함/회귀 | 릴리즈 전 반드시 수정 (release-block) |
| 미구현 기능의 갭 (Layer T 등) | 용인, 백로그 추적 |
| 품질 개선 / wording | 릴리즈 후 또는 별도 |

출하 표면 P0/P1이 **0**이면 release-go. 등급 기준은 문서 말미 "결과 분류 기준".
J / J-OB / Q는 temp scaffold를 생성하므로 각 Layer의 정리 단계(OB8 / J11)로 `/tmp` 산출물을 제거한다.

---

## Layer A. Syntax / Script 무결성

```bash
bash -n scripts/create-harness.sh
bash scripts/create-harness.sh --dry-run test-proj /tmp/awh-dryrun
```

---

## Layer B. Scaffold 템플릿 패턴 전수 — write_text() 일괄 나열

소스 파일만 수정하고 스크립트를 미반영했을 때를 탐지한다.
grep 결과를 한눈에 비교해 불일치를 직접 확인한다.

```bash
# write_text로 생성되는 backlog 파일 전체 위치
grep -n "write_text.*backlog\|write_text.*PRODUCT\|write_text.*HARNESS" \
  scripts/create-harness.sh

# 모든 Verification 라인 (PRODUCT·HARNESS 템플릿 포함)
grep -n "Verification\|검증 방법" scripts/create-harness.sh

# Details 섹션 포맷 comment 전수
grep -n "항목 등록 형식\|### Details\|## Details" scripts/create-harness.sh

# 소스 파일 vs 스크립트 3자 비교 (한 줄이라도 다르면 drift)
grep -n "Verification\|검증 방법" \
  docs/backlog/HARNESS.md \
  skills/workflow/work-register.md \
  scripts/create-harness.sh
```

---

## Layer C. Scaffold 실물 생성 + Invariant 5종 (+ 1 report-only)

```bash
bash scripts/tests/check-scaffold-invariants.sh
# [1]  core A-class DR 참조 실재 (hard-fail)
# [1r] optional-pack DR dangling (report-only)
# [2]  core A-class source-only 경로 누수 (hard-fail)
# [3]  decisions/README ↔ DR 파일 closure (hard-fail)
# [4]  root README 파일표 ↔ optional docs on-disk (hard-fail)
# [5]  manifest + --check 자기일관성, drift 0 (hard-fail)
```

---

## Layer D. Manifest drift (--check)

```bash
bash scripts/create-harness.sh --check <target-dir>
# summary: N tracked, M drifted
# drifted 파일 = 소스 수정 후 스크립트 미반영의 증거
```

---

## Layer E. Canonical Source 최신성 확인

파일 존재가 아니라 규칙이 현행 기준인지 확인한다.

```bash
# 변경된 canonical 파일 (최근 30일)
git log --since="30 days ago" --name-only --pretty="" -- \
  docs/AGENT-WORKFLOW.md docs/HARNESS-PROTOCOL.md "docs/decisions/DR-*.md" \
  | sort -u

# 해당 canonical을 참조하는 tool surface 목록
grep -rl "AGENT-WORKFLOW\|HARNESS-PROTOCOL" \
  .claude/commands/ .claude/rules/ .agents/skills/ .cursor/rules/ skills/workflow/

# DR Status 현황 (Accepted/Superseded 혼재 여부)
grep -n "^status:" docs/decisions/DR-*.md | sort

# Superseded DR을 여전히 참조하는 live 파일 탐지
SUPERSEDED=$(grep -l "^status: Superseded" docs/decisions/DR-*.md 2>/dev/null \
  | xargs grep -ohE 'DR-[0-9]{3}' | sort -u | tr '\n' '|' | sed 's/|$//')
[ -n "$SUPERSEDED" ] && grep -rn -E "$SUPERSEDED" \
  .claude/ .agents/ .cursor/ skills/ \
  docs/AGENT-WORKFLOW.md docs/HARNESS-PROTOCOL.md
```

---

## Layer F. Tool-specific Surface 정렬 — 필수반복 / 과잉반복 / 누락

단순 존재 여부가 아니라 반복 품질을 판단한다.

```bash
# skills/workflow ↔ .claude/commands 쌍 목록
echo "=== canonical ===" && ls skills/workflow/*.md
echo "=== claude adapter ===" && ls .claude/commands/*.md
echo "=== agents skills ===" && ls .agents/skills/ 2>/dev/null || echo "(없음)"
echo "=== cursor rules ===" && ls .cursor/rules/*.mdc 2>/dev/null

# 과잉반복 후보: 같은 규칙이 3개 이상 surface에 있으면 과잉 여부 검토
grep -rn "Approval Matrix\|Quick Mode\|state-change proposal" \
  .claude/commands/ .claude/rules/ .cursor/rules/ skills/workflow/ \
  | awk -F: '{print $1}' | sort | uniq -c | sort -rn

# adapter 비대 탐지 (adapter는 Step 0 + hard-stop + entry mechanism만 허용)
wc -l .claude/commands/*.md | sort -rn | head -10

# mirror 누락 탐지
for f in skills/workflow/*.md; do
  name=$(basename "$f" .md)
  mirror=".agents/skills/workflow-${name}/SKILL.md"
  [ ! -f "$mirror" ] && echo "MISSING mirror: $mirror"
done
```

---

## Layer G. User-facing Docs 정합 — 실행 흐름 관점

사용자가 문서를 보고 실제 실행했을 때 어긋나는 부분을 탐지한다.

```bash
# WORKFLOW-MANUAL / QUICK-REFERENCE command 설명 확인
grep -n "/session-start\|/work-plan\|/work-close\|/work-register\|/repo-health" \
  docs/WORKFLOW-MANUAL.md docs/HARNESS-QUICK-REFERENCE.md

# QUICK-REFERENCE command 행 vs 실제 command 파일 교차 확인
# slash command만 추출(앞이 비영숫자 + 하이픈 포함) → 경로 segment·절대경로 오탐 제외
grep -oE '([^a-zA-Z0-9]|^)/[a-z]+-[a-z-]+' docs/HARNESS-QUICK-REFERENCE.md \
  | grep -oE '/[a-z-]+' | sort -u | while read cmd; do
  name="${cmd#/}"
  [ ! -f ".claude/commands/${name}.md" ] && echo "QUICK-REF에 있으나 command 없음: $cmd"
done

# README optional docs 섹션 vs 실제 파일
grep -n "with-optional\|WORKFLOW-MANUAL\|HARNESS-ARCHITECTURE\|HARNESS-MAINTAINER" README.md

# Snapshot vs live doc: archive가 live surface에서 직접 참조되는지 탐지
grep -rn "docs/archive/" \
  .claude/commands/ .claude/rules/ .cursor/rules/ skills/workflow/ \
  docs/AGENT-WORKFLOW.md docs/HARNESS-PROTOCOL.md
# → 결과가 있으면 snapshot 오염 의심
```

---

## Layer H. Stale Phrase / Source-only Path 누수

```bash
# source-only 경로 누수
grep -rn "ai-workflow-harness\|/Users/\|/home/[a-z]" \
  .claude/ .agents/ .cursor/ skills/ prompts/

# 구버전 용어
grep -rn "HRN-0[0-9][0-9]\b\|/repo-decision\|repo-decision" \
  .claude/commands/ skills/workflow/ docs/HARNESS-QUICK-REFERENCE.md

# whitespace 오류
git diff --check
```

---

## Layer I. DR / README Closure

```bash
grep -oE 'DR-[0-9]{3}' docs/decisions/README.md | sort > /tmp/readme_drs.txt
ls docs/decisions/DR-*.md | grep -oE 'DR-[0-9]{3}' | sort > /tmp/file_drs.txt
diff /tmp/readme_drs.txt /tmp/file_drs.txt
# 출력 없으면 OK
```

**Shipped DR reference closure (정책: `docs/decisions/DR-033-shipped-dr-reference-closure.md`).**
shipped 표면 문서가 scaffold seed 밖 DR을 인용하면 target에서 dangling이 된다. scaffold 생성 없이 source만으로 사전 검출:

```bash
bash scripts/tests/check-shipped-dr-closure.sh
# OK = closed, 위반 출력 시 mode-a(self-describe) 또는 mode-b(Linked DRs frontmatter)로 처리
```

- seed SSoT는 `scripts/create-harness.sh` 기본 adapt 블록에서 파생한다(하드코딩 사본 금지).
- `Linked DRs:` frontmatter 라인은 검사에서 제외한다(source lineage 메타데이터). 동일 제외 규칙을 scaffold 생성 후 검사인 `check-scaffold-invariants.sh [1]`도 적용한다.
- 작성 시점 규약은 `.claude/rules/docs-workflow.md`와 `docs/HARNESS-PROTOCOL.md` cascade 절을 따른다.

---

## Layer J. Simulation — Scaffold 후 User Action 케이스별 검증

파일 존재 여부가 아니라 scaffold 후 사용자가 실제로 취하는 action 흐름을 케이스별로 검증한다.
**이것이 scaffold 검증의 최고점이다.**

### J0. 준비: temp scaffold 생성

```bash
bash scripts/create-harness.sh sim-proj /tmp/awh-sim
cd /tmp/awh-sim
```

### J1. 새 세션 시작 (`/session-start`)

```bash
# 필요 파일 실재 확인
ls docs/STATUS.md docs/AGENT-WORKFLOW.md docs/BEHAVIOR-PRINCIPLES.md \
   skills/workflow/session-start.md .claude/commands/session-start.md

# STATUS.md 기본 구조
grep -n "## Active Work\|## Next Actions\|## Blockers" docs/STATUS.md

# session-start가 참조하는 파일 모두 실재하는가
grep -oE '`docs/[^`]+`' skills/workflow/session-start.md \
  | tr -d '`' | while read f; do
      [ ! -f "$f" ] && echo "MISSING: $f"
    done
```

### J2. 작업 등록 (`/work-register`)

```bash
ls docs/backlog/HARNESS.md
grep -n "### Summary\|### Details\|## Deferred Ideas\|Verification 작성 기준" \
  docs/backlog/HARNESS.md
ls skills/workflow/work-register.md .claude/commands/work-register.md
grep -n "work-register" .cursor/rules/workflow.mdc
```

### J3. 작업 계획 및 시작 (`/work-plan`)

```bash
ls -d docs/works/harness/ docs/works/product/ 2>/dev/null || echo "MISSING works dirs"
ls docs/decisions/DR-013-*.md    # Work file spec
ls docs/HARNESS-NAMING-RULES.md  # Work ID 형식 참조
ls skills/workflow/work-plan.md .claude/commands/work-plan.md
```

### J4. L1 Quick Mode 작업

```bash
# branch isolation 보호 파일 목록이 최신인지
grep -n "AGENTS.md\|CLAUDE.md\|docs/STATUS.md\|docs/backlog" \
  .claude/rules/git-workflow.md | head -20

# gate-config protected 파일 목록
grep -n "\[protected\]\|\[finalization\]" .harness/gate-config 2>/dev/null
```

### J5. Work Done 처리 (`/work-close`)

```bash
ls skills/workflow/work-close.md .claude/commands/work-close.md

# work-close가 참조하는 파일 실재
grep -oE '`docs/[^`]+`\|`\.claude/[^`]+`' skills/workflow/work-close.md \
  | tr -d '`' | while read f; do
      [ ! -f "$f" ] && echo "MISSING: $f"
    done

# Work index README 실재 (Done → Active 이동 대상)
ls docs/works/harness/README.md docs/works/product/README.md 2>/dev/null
```

### J6. Done → Archived 처리

```bash
ls -d docs/archive/ 2>/dev/null || echo "MISSING: docs/archive/"
grep -n "archive\|git mv" .claude/rules/docs-workflow.md
```

### J7. STATUS.md 업데이트 필요 / 불필요 케이스

```bash
# STATUS Finalization gate 존재 여부
grep -n "STATUS Finalization\|Tracking Finalization" .claude/rules/git-workflow.md

# STATUS.md가 pointer만 갖고 상세를 담지 않는지
grep -c "^|" docs/STATUS.md
```

### J8. Command / Rule / Scaffold 변경 시 Cascade (T11)

```bash
# T11 trigger 명시 여부
grep -n "T11\|tool surface\|cascade" \
  .claude/rules/docs-workflow.md .cursor/rules/workflow.mdc 2>/dev/null

# scaffold 변경 시 invariant 재실행 경로 명시 여부
grep -rn "check-scaffold-invariants\|invariant" docs/AGENT-WORKFLOW.md docs/HARNESS-PROTOCOL.md
```

### J9. `record-decision` 흐름

```bash
ls .claude/commands/record-decision.md skills/workflow/record-decision.md 2>/dev/null
grep -n "decisions/README" skills/workflow/record-decision.md 2>/dev/null
```

### J10. `/repo-health` 흐름

```bash
ls .claude/commands/repo-health.md skills/workflow/repo-health.md

# repo-health가 참조하는 파일 실재
grep -oE 'docs/[A-Z][A-Z-]+\.md' skills/workflow/repo-health.md | sort -u | while read f; do
  [ ! -f "$f" ] && echo "repo-health 참조 MISSING: $f"
done
```

### J11. 정리

```bash
cd -
rm -rf /tmp/awh-sim
```

---

## Layer J-OB. Onboarding Simulation — Scaffold 직후 최초 온보딩

scaffold 직후 실제 사용자가 처음 마주하는 흐름을 케이스별로 시뮬레이션한다.
단순 파일 존재가 아니라 **절차가 올바르게 안내되고 사용자의 선택/예외 상황에서도 안착하는지**를 검증한다.

### OB0. 준비: 옵션별 scaffold 생성

```bash
# default (generic workflow)
bash scripts/create-harness.sh onboard-generic /tmp/awh-ob-generic

# source-gitflow workflow
bash scripts/create-harness.sh --workflow source-gitflow onboard-gitflow /tmp/awh-ob-gitflow

# with-optional
bash scripts/create-harness.sh --with-optional onboard-optional /tmp/awh-ob-optional

# existing project overlay
mkdir -p /tmp/awh-ob-existing && touch /tmp/awh-ob-existing/my-existing-file.md
bash scripts/create-harness.sh --existing onboard-existing /tmp/awh-ob-existing
```

---

### OB1. 최초 온보딩 — generic workflow (정상 경로)

신규 프로젝트 scaffold 후 AI가 처음 `/session-start`를 실행했을 때 BOOTSTRAP 안내까지 올바르게 이어지는지 확인한다.

```bash
cd /tmp/awh-ob-generic

# 1. BOOTSTRAP.md 존재 + 기본 섹션 구조
ls docs/BOOTSTRAP.md
grep -n "^## \|^### " docs/BOOTSTRAP.md | head -20

# 2. STATUS.md Next Actions가 bootstrap onboarding을 가리키는지
grep -n "BOOTSTRAP\|bootstrap\|onboarding" docs/STATUS.md

# 3. session-start가 Next Actions bootstrap pointer를 감지하면 BOOTSTRAP.md 로드를 안내하는가
grep -n "bootstrap\|BOOTSTRAP" skills/workflow/session-start.md

# 4. BOOTSTRAP.md §0 → git 초기화 흐름: no-git 상태 탐지 안내 존재
grep -n "git status\|git init\|not a git repository\|no-git" docs/BOOTSTRAP.md

# 5. BOOTSTRAP.md 완료 후 STATUS.md 갱신 안내 존재 (bootstrap → real work 전환)
grep -n "STATUS.md\|Next Actions.*제거\|다음 실제 작업" docs/BOOTSTRAP.md

# 6. /work-register 진입 안내 (BOOTSTRAP 완료 후)
grep -n "work-register\|work-select" docs/BOOTSTRAP.md
```

---

### OB2. 최초 온보딩 — generic workflow (예외 경로)

```bash
cd /tmp/awh-ob-generic

# 예외 1: 사용자가 BOOTSTRAP.md를 건너뛰고 바로 /work-register 실행
# → session-start idle-state rule이 /work-register 또는 /work-select로 안내하는가
grep -n "idle\|Active Work.*없\|clean idle\|work-select\|work-register" \
  skills/workflow/session-start.md

# 예외 2: BOOTSTRAP.md §0 완료 전 commit 시도
# → git-workflow rule의 pre-commit 체크가 BOOTSTRAP 미완료 상태에서도 동작하는가
grep -n "BOOTSTRAP\|bootstrap" .claude/rules/git-workflow.md

# 예외 3: 사용자가 docs/BOOTSTRAP.md 없이 /session-start (파일 삭제 시뮬레이션)
# → session-start hard-stop 또는 graceful fallback 여부
mv docs/BOOTSTRAP.md docs/BOOTSTRAP.md.bak
grep -oE '`docs/BOOTSTRAP\.md`' skills/workflow/session-start.md | wc -l
# → 0이면 BOOTSTRAP 없어도 session-start 진행 가능 (정상)
mv docs/BOOTSTRAP.md.bak docs/BOOTSTRAP.md

# 예외 4: 사용자가 STATUS.md의 bootstrap pointer를 수동으로 제거한 채 세션 시작
# → idle-state rule이 활성화되어 /work-select, /work-register로 안내하는가
grep -n "Active Work\|Next Actions" skills/workflow/session-start.md
```

---

### OB3. --workflow source-gitflow 온보딩

source-gitflow는 CI gate + 브랜치 정책이 추가되므로 사용자가 처음 만나는 제약을 올바르게 안내받는지 확인한다.

```bash
cd /tmp/awh-ob-gitflow

# 1. source-gitflow 전용 파일 존재
ls docs/GIT-WORKFLOW.md
ls .github/workflows/harness-validate.yml 2>/dev/null || echo "MISSING: harness-validate.yml"

# 2. GIT-WORKFLOW.md에 policy_type: source-gitflow 마커 존재
grep -n "policy_type\|source-gitflow" docs/GIT-WORKFLOW.md

# 3. gate hook 파일 존재 (설치 전 pre-deploy 상태)
ls tools/git-hooks/ 2>/dev/null || echo "hook files 없음"
grep -n "install.sh\|git-hooks" docs/GIT-WORKFLOW.md

# 4. branch isolation: develop 직접 commit → WARN (hard block 아님)
grep -n "develop.*warn\|WARN.*develop\|develop.*direct" .claude/rules/git-workflow.md

# 5. branch isolation: main 직접 commit → HARD FAIL
grep -n "main.*FAIL\|FAIL.*main\|hard.block\|hard block" .claude/rules/git-workflow.md

# 6. feature/* → develop PR 흐름 안내 존재
grep -n "feature/\|base develop\|--base develop" \
  docs/GIT-WORKFLOW.md .claude/rules/git-workflow.md

# 7. BOOTSTRAP.md에 source-gitflow 전용 hook 설치 안내 존재
grep -n "hook\|install.sh\|GIT-WORKFLOW" docs/BOOTSTRAP.md

# 8. generic scaffold에 GIT-WORKFLOW.md가 없는지 (source-only marker 누수 없음)
ls /tmp/awh-ob-generic/docs/GIT-WORKFLOW.md 2>/dev/null && echo "LEAK: GIT-WORKFLOW in generic"
```

---

### OB4. --with-optional 온보딩

optional docs가 추가될 때 README, invariant, 사용자 안내가 일관성 있는지 확인한다.

```bash
cd /tmp/awh-ob-optional

# 1. optional docs 존재
ls docs/HARNESS-ARCHITECTURE.md docs/HARNESS-MAINTAINER-GUIDE.md docs/WORKFLOW-MANUAL.md

# 2. root README optional docs 목록과 on-disk 일치 (invariant [4])
grep -n "HARNESS-ARCHITECTURE\|HARNESS-MAINTAINER\|WORKFLOW-MANUAL" README.md

# 3. BOOTSTRAP.md에서 optional docs 안내 여부
grep -n "WORKFLOW-MANUAL\|HARNESS-ARCHITECTURE\|--with-optional" docs/BOOTSTRAP.md

# 4. generic scaffold에는 optional docs 없음 (누수 없음)
ls /tmp/awh-ob-generic/docs/HARNESS-ARCHITECTURE.md 2>/dev/null && echo "LEAK"
ls /tmp/awh-ob-generic/docs/WORKFLOW-MANUAL.md 2>/dev/null && echo "LEAK"

# 5. invariant [4] 직접 실행
bash "$OLDPWD/scripts/tests/check-scaffold-invariants.sh" /tmp/awh-ob-optional
```

---

### OB5. --existing overlay 온보딩

기존 프로젝트에 harness를 덧씌울 때 사용자 파일이 보존되고 충돌 없이 안착하는지 확인한다.

```bash
cd /tmp/awh-ob-existing

# 1. 기존 파일 보존 확인
ls my-existing-file.md || echo "LOST: user file overwritten"

# 2. manifest 생성 확인
ls .harness/manifest.json
grep -n "harness_version\|framework_files" .harness/manifest.json | head -5

# 3. --check drift 0 (갓 생성한 target은 clean해야 함)
bash "$OLDPWD/scripts/create-harness.sh" --check /tmp/awh-ob-existing \
  | grep "summary:"

# 4. BOOTSTRAP.md에 --existing 관련 안내 (기존 프로젝트 특이사항)
grep -n "existing\|기존\|overlay" docs/BOOTSTRAP.md
```

---

### OB6. 사용자 행동 변형 시나리오

정해진 절차를 벗어나는 사용자 선택에 대해 harness가 올바르게 안내하거나 차단하는지 검증한다.

```bash
cd /tmp/awh-ob-generic

# 시나리오 A: Happy path — 절차 전체 흐름 파일 체인 검증
# session-start → work-register → work-plan → implement → work-close 순서로
# 각 단계에서 필요한 파일이 존재하는가
for skill in session-start work-register work-plan work-close session-summary; do
  ls skills/workflow/${skill}.md .claude/commands/${skill}.md 2>/dev/null \
    || echo "MISSING chain: ${skill}"
done

# 시나리오 B: work-plan 건너뛰고 바로 구현
# → docs-workflow rule의 intent recognition이 /work-plan으로 유도하는가
grep -n "work-plan\|착수\|플랜\|시작하자" .claude/rules/docs-workflow.md | head -10

# 시나리오 C: develop 직접 commit (source-gitflow 미사용 일반 프로젝트)
# → git-workflow rule이 branch isolation check를 실행하는가
grep -n "develop\|Branch Isolation" .claude/rules/git-workflow.md | head -10

# 시나리오 D: main 직접 commit 시도
# → FAIL + feature/* 브랜치 이동 제안 여부
grep -n "main\|FAIL.*staged\|propose.*feature" .claude/rules/git-workflow.md | head -10

# 시나리오 E: 문서를 전혀 읽지 않은 사용자 (처음부터 임의 질문)
# → session-start idle-state rule이 /work-select 또는 /work-register로 수렴하는가
grep -n "idle\|clean idle\|work-select\|work-register" skills/workflow/session-start.md

# 시나리오 F: Approval Matrix 없이 STATUS.md 직접 수정 시도
# → docs-workflow rule이 proposal 먼저 요구하는가
grep -n "STATUS.md.*수정\|explicit.*user.*approval\|Approval Matrix" \
  .claude/rules/docs-workflow.md | head -10

# 시나리오 G: 같은 세션에서 두 번 /session-start 호출
# → session-start가 중복 실행에도 STATUS.md를 안전하게 re-read하는가
grep -n "idempotent\|re-read\|다시 읽\|최신" skills/workflow/session-start.md
```

---

### OB7. Post-scaffold config 수정 후 동작 검증

scaffold 직후 사용자가 config 파일을 커스터마이징했을 때 시스템이 올바르게 반응하는지 검증한다.
"기본 동작 OK"와 "커스터마이징 후에도 OK"는 별개다.

```bash
# ── .harness/gate-config 수정 ──────────────────────────────────────────────

cd /tmp/awh-ob-gitflow  # source-gitflow scaffold (hook 있음)

# 1. gate-config 형식 확인 (inline comment 불가, glob 패턴)
cat .harness/gate-config

# 2. 새 protected 경로 추가 (올바른 형식)
cat >> .harness/gate-config << 'EOF'

[protected]
# project-specific sensitive path
infra/**
EOF

# 3. gate-config 파싱 이상 없이 hook이 읽는가 확인
# (source-gitflow: hook이 gate-config를 직접 읽음)
grep -n "gate-config\|gate_config" tools/git-hooks/lib/gate-lists.sh 2>/dev/null \
  | head -5 || echo "gate-config 참조 경로 확인 필요"

# 4. 추가한 경로에 파일 생성 후 develop 직접 commit 시도 → WARN 확인
mkdir -p infra && echo "test" > infra/test.tf
git add infra/test.tf
git commit -m "test: infra file on develop" 2>&1 \
  | grep -i "warn\|protected\|isolation" \
  || echo "WARN: gate-config 추가 경로가 반영되지 않음"
git rm infra/test.tf && git checkout .harness/gate-config

# 5. generic scaffold에서는 gate-config가 advisory — claude rule이 읽는가
cd /tmp/awh-ob-generic
grep -n "gate-config\|gate_config\|\[protected\]" .claude/rules/git-workflow.md | head -5


# ── CLAUDE.md / AGENTS.md 수정 ─────────────────────────────────────────────

cd /tmp/awh-ob-generic

# 6. CLAUDE.md에 커스텀 내용 추가 후 기존 entry contract 유지 여부
echo "" >> CLAUDE.md
echo "## Custom Section" >> CLAUDE.md
echo "Project-specific rules here." >> CLAUDE.md

# entry contract 필수 참조 (@docs/BEHAVIOR-PRINCIPLES, @docs/AGENT-WORKFLOW) 유지
grep -n "@docs/BEHAVIOR-PRINCIPLES\|@docs/AGENT-WORKFLOW" CLAUDE.md \
  || echo "MISSING: entry contract references removed from CLAUDE.md"

# AGENTS.md 동일 확인
grep -n "BEHAVIOR-PRINCIPLES\|AGENT-WORKFLOW" AGENTS.md \
  || echo "MISSING: entry contract references in AGENTS.md"

# 원복
git checkout CLAUDE.md


# ── .claude/settings.json 수정 ────────────────────────────────────────────

# 7. permission 추가 후 JSON 문법 유효성
cat .claude/settings.json 2>/dev/null | python3 -m json.tool > /dev/null \
  && echo "OK: settings.json valid JSON" \
  || echo "INVALID JSON: .claude/settings.json"

# 8. hook 추가 시 기존 hook과 충돌 없는 구조인지 (key 중복 탐지)
python3 -c "
import json, sys
with open('.claude/settings.json') as f:
    d = json.load(f)
hooks = d.get('hooks', {})
print('hooks keys:', list(hooks.keys()))
" 2>/dev/null || echo "settings.json hook 구조 확인 필요"


# ── .codex/hooks.json 수정 ────────────────────────────────────────────────

# 9. hooks.json 존재 및 JSON 유효성
cat .codex/hooks.json 2>/dev/null | python3 -m json.tool > /dev/null \
  && echo "OK: .codex/hooks.json valid" \
  || echo "MISSING or INVALID: .codex/hooks.json"


# ── manifest drift: config 수정 후 --check 영향 없는가 ────────────────────

# 10. gate-config, CLAUDE.md는 B-class(write_text) — manifest 미추적, drift 0 유지
bash "$OLDPWD/scripts/create-harness.sh" --check /tmp/awh-ob-generic \
  | grep "summary:" \
  | grep -q ", 0 drifted" \
  && echo "OK: config 수정이 manifest drift 없음" \
  || echo "WARN: config 수정이 manifest drift 유발 — framework 파일 오염 의심"
```

---

### OB8. 정리

```bash
cd -
rm -rf /tmp/awh-ob-generic /tmp/awh-ob-gitflow /tmp/awh-ob-optional /tmp/awh-ob-existing
```

---

## Layer K. repo-health 통합 실행

```bash
/repo-health --cascade          # 변경 surface 기준 cascade 감사
/repo-health --full --cascade   # 전체 surface + cascade (Phase 전환 / 대형 변경 후)
```

---

## Layer N. State Consistency — STATUS ↔ Work 파일 ↔ index README

STATUS.md dashboard, Work 파일 실물, Work index README 세 곳의 상태가 일치하는지 확인한다.

```bash
# 1. STATUS.md Active Work 행 → Work 파일 링크 실재
grep -oE 'docs/works/[^|)]+\.md' docs/STATUS.md | tr -d ' ' | while read f; do
  [ ! -f "$f" ] && echo "MISSING Work file (STATUS pointer broken): $f"
done

# 2. docs/works/ status:Active 파일 → STATUS.md 등재 여부
grep -rl "^status: Active" docs/works/ 2>/dev/null | while read f; do
  id=$(grep "^id:" "$f" | head -1 | awk '{print $2}')
  grep -q "$id" docs/STATUS.md || echo "NOT IN STATUS Active Work: $id ($f)"
done

# 3. docs/works/ status:Done 파일 → Work index README Done 섹션 등재 여부
grep -rl "^status: Done" docs/works/ 2>/dev/null | while read f; do
  id=$(grep "^id:" "$f" | head -1 | awk '{print $2}')
  dir=$(dirname "$f")
  grep -q "$id" "${dir}/README.md" 2>/dev/null \
    || echo "NOT IN README Done section: $id (${dir}/README.md)"
done

# 4. STATUS.md Active Work에 Done Work 파일이 잔류하는지
grep -oE 'docs/works/[^|)]+\.md' docs/STATUS.md | tr -d ' ' | while read f; do
  [ -f "$f" ] && grep -q "^status: Done" "$f" \
    && echo "STALE STATUS pointer (Done Work still in Active): $f"
done

# 5. docs/works/에 archived 마커가 있는 파일 잔류 여부
grep -rl "^archived:" docs/works/ 2>/dev/null | while read f; do
  echo "WARN: archived Work still in docs/works/ (not moved): $f"
done
```

---

## Layer O. File Spec Compliance

Work 파일(DR-013), DR 파일, retrospective/troubleshooting(DR-027) 필수 frontmatter 필드 존재 여부를 확인한다.

```bash
# Work 파일 DR-013 필수 필드: id, status, risk, scope, planned_start
for f in docs/works/**/*.md; do
  for field in "^id:" "^status:" "^risk:" "^scope:" "^planned_start:"; do
    grep -q "$field" "$f" || echo "MISSING field ($field): $f"
  done
done

# DR 파일 필수 필드: date 또는 Date, status 또는 Status
for f in docs/decisions/DR-*.md; do
  grep -qiE "^(date|Date):" "$f" || echo "MISSING date: $f"
  grep -qiE "^(status|Status):" "$f" || echo "MISSING status: $f"
  grep -q "^## Decision" "$f"   || echo "MISSING ## Decision section: $f"
done

# retrospective/troubleshooting DR-027 필수 frontmatter: date, track, type, scope
for dir in docs/retrospectives docs/troubleshooting; do
  [ -d "$dir" ] || continue
  for f in "${dir}"/*.md; do
    [[ "$f" == *README* ]] && continue
    for field in "^date:" "^track:" "^type:" "^scope:"; do
      grep -q "$field" "$f" || echo "MISSING DR-027 field ($field): $f"
    done
  done
done

# related_work 필드 — 참조 Work ID가 실제 파일로 존재하는가
grep -rn "^related_work:" docs/works/ | grep -v '\[\]' | while IFS=: read file _ val; do
  echo "$val" | grep -oE '[A-Z]+-[0-9]{8}-[0-9]+' | while read ref_id; do
    ls docs/works/*/"${ref_id}"*.md 2>/dev/null | grep -q . \
      || echo "BROKEN related_work ref: $ref_id in $file"
  done
done
```

---

## Layer P. Language Policy (DR-007)

command/rule/prompt 파일이 Korean primary 원칙을 따르는지 확인한다.
완전 영어 문장 또는 영어 주어 사용이 과도한 파일을 탐지한다.

> **이식성:** `[가-힣]` 한글 range는 GNU grep과 BSD grep(macOS 기본) 양쪽에서 동작하나, UTF-8 locale(`LC_CTYPE`/`LANG`이 `*.UTF-8`)을 전제한다. `grep -P`(PCRE)는 BSD grep에서 `invalid option`으로 실패하므로 사용하지 않는다.

```bash
# command/skill 파일에서 한국어가 전혀 없는 파일 탐지 (순수 영어 파일 의심)
for f in .claude/commands/*.md skills/workflow/*.md; do
  ko_count=$(grep -c '[가-힣]' "$f" 2>/dev/null || echo 0)
  [ "$ko_count" -eq 0 ] && echo "NO KOREAN (check DR-007): $f"
done

# rule 파일 동일 점검
for f in .claude/rules/*.md .cursor/rules/*.mdc; do
  ko_count=$(grep -c '[가-힣]' "$f" 2>/dev/null || echo 0)
  [ "$ko_count" -eq 0 ] && echo "NO KOREAN (check DR-007): $f"
done

# commit message format: type prefix는 영어인가 (DR-007 + git-workflow rule)
grep -n "^type.*feat\|^type.*fix\|^type.*docs\|Conventional Commits" \
  .claude/rules/git-workflow.md | head -5

# prompt 파일 언어 확인
for f in prompts/*.md; do
  ko_count=$(grep -c '[가-힣]' "$f" 2>/dev/null || echo 0)
  total=$(wc -l < "$f")
  [ "$total" -gt 10 ] && [ "$ko_count" -lt 3 ] \
    && echo "LOW KOREAN ratio (check DR-007): $f (${ko_count} Korean lines / ${total} total)"
done
```

---

## Layer Q. Hook Functional Test

> **전제:** Layer J-OB의 OB0에서 생성한 `/tmp/awh-ob-gitflow`(source-gitflow scaffold)가 필요하다. 단독 실행 시 OB0를 먼저 수행한다.

hook 파일 존재를 넘어 실제 commit 시 WARN/FAIL이 올바르게 발생하는지 검증한다.
source-gitflow scaffold에서만 실행한다.

```bash
cd /tmp/awh-ob-gitflow  # OB0에서 생성한 source-gitflow scaffold

# 1. hook 설치
bash tools/git-hooks/install.sh 2>/dev/null || echo "install.sh 없음 — hook 수동 확인"

# 2. git 초기화 + 초기 commit (main branch)
git init && git add . && git commit -m "chore: initial scaffold" 2>&1 | head -5

# 3. main 직접 commit → HARD FAIL 확인
echo "test" > /tmp/test-main.txt && cp /tmp/test-main.txt test-main.txt
git add test-main.txt
git commit -m "test: direct commit to main" 2>&1 | grep -i "fail\|block\|protected\|error" \
  || echo "WARN: main hard-block이 발생하지 않음 — hook 미설치 또는 rule 미작동"

# 4. develop branch에서 protected 파일 commit → WARN 확인
git checkout -b develop 2>/dev/null || git checkout develop
cp .claude/commands/session-start.md /tmp/sc_backup.md
echo "# test" >> .claude/commands/session-start.md
git add .claude/commands/session-start.md
git commit -m "test: protected file on develop" 2>&1 | grep -i "warn\|protected\|isolation" \
  || echo "INFO: develop WARN이 발생하지 않음 — generic workflow이거나 hook 미설치"
cp /tmp/sc_backup.md .claude/commands/session-start.md
git checkout .claude/commands/session-start.md

# 5. feature branch에서 정상 commit → PASS 확인
git checkout -b feature/hook-test
echo "test" > hook-test.txt
git add hook-test.txt
git commit -m "test: normal commit on feature branch" 2>&1 \
  | grep -iv "fail\|block\|error" && echo "OK: feature branch commit passed"

cd -
```

---

## Layer R. VERSION ↔ Manifest 버전 일관성

> **전제:** Layer J-OB의 OB0에서 생성한 `/tmp/awh-ob-generic`이 필요하다. 단독 실행 시 OB0를 먼저 수행하거나 임의 temp scaffold 경로로 치환한다.

source repo의 `VERSION` 파일과 scaffold 생성 시 manifest에 기록되는 `harness_version`이 일치하는지 확인한다.

```bash
# 1. source VERSION 파일 확인
SOURCE_VERSION=$(cat VERSION 2>/dev/null || echo "MISSING")
echo "source VERSION: ${SOURCE_VERSION}"

# 2. 갓 생성한 scaffold manifest의 harness_version 확인
MANIFEST_VERSION=$(grep '"harness_version"' /tmp/awh-ob-generic/.harness/manifest.json \
  2>/dev/null | grep -oE '[0-9]+\.[0-9]+\.[0-9][^"]*')
echo "manifest harness_version: ${MANIFEST_VERSION}"

# 3. 일치 여부
[ "${SOURCE_VERSION}" = "${MANIFEST_VERSION}" ] \
  && echo "OK: VERSION == manifest harness_version" \
  || echo "MISMATCH: VERSION(${SOURCE_VERSION}) != manifest(${MANIFEST_VERSION})"

# 4. create-harness.sh가 VERSION 파일을 읽는 로직 존재 확인
grep -n "VERSION\|HARNESS_VERSION" scripts/create-harness.sh | grep -v "^.*#" | head -5

# 5. --check 출력에 version delta 표시 여부 확인 (source와 target이 다를 때)
grep -n "version delta\|version.*current source" scripts/create-harness.sh
```

---

## Layer S. Prompt Surface 정렬

`prompts/*session-start.md` 3종(claude/codex/cursor)이 `skills/workflow/session-start.md` canonical과 정합하는지 확인한다.

```bash
# 1. 3종 prompt 파일 존재 확인
ls prompts/claude-session-start.md \
   prompts/codex-session-start.md \
   prompts/cursor-session-start.md

# 2. canonical session-start의 핵심 섹션 헤더가 각 prompt에도 존재하는가
for section in "Procedure\|절차" "Hard Stop\|hard.stop" "형식\|format"; do
  echo "=== ${section} ==="
  for f in prompts/*session-start.md; do
    grep -qi "$section" "$f" && echo "  OK: $f" || echo "  MISSING: $f"
  done
done

# 3. prompt 파일이 canonical skill을 참조하는가 (Load 경로 명시 여부)
grep -n "skills/workflow/session-start\|session-start.md" prompts/*session-start.md

# 4. prompt 파일에 canonical에 없는 독자 규칙이 있는지 (중량 확인)
wc -l prompts/*session-start.md skills/workflow/session-start.md \
  | sort -rn | head -5
# → prompt가 canonical보다 훨씬 길면 독자 규칙 삽입 의심

# 5. scaffold 시 prompt가 올바른 경로에 생성되는가
grep -n "write_text.*session-start\|adapt.*session-start" scripts/create-harness.sh

# 6. generic scaffold에서 prompt 파일 존재 확인
ls /tmp/awh-ob-generic/prompts/*session-start.md 2>/dev/null \
  || echo "MISSING: session-start prompts in generic scaffold"
```

---

## Layer T. Scaffold Upgrade / Migration 검증

> **현재 상태: Placeholder** — 구현이 완료되면 이 섹션을 채운다.
> 선행 작업: `docs/backlog/HARNESS.md` P1 항목 "Harness upgrade/migration 메커니즘" (`--upgrade`/`--refresh` 구현).

upgrade/migration 완료 후 아래 항목을 검증한다.

### T0. 준비: 구버전 scaffold + 현재 source 준비

```bash
# 구버전 scaffold 생성 (VERSION을 낮춰서 시뮬레이션)
# TODO: 구버전 archive 또는 git tag 기반으로 이전 scaffold 생성 방법 확정
```

### T1. Framework 파일 갱신 확인

```bash
# upgrade 실행 후 manifest drift 0
bash scripts/create-harness.sh --check <upgraded-target> | grep "summary:.*0 drifted"

# harness_version이 현재 source VERSION으로 갱신됐는가
grep '"harness_version"' <upgraded-target>/.harness/manifest.json
cat VERSION
```

### T2. 사용자 커스터마이징 보존 확인

```bash
# .harness/gate-config 프로젝트 추가 경로 유지
grep "\[protected\]" -A5 <upgraded-target>/.harness/gate-config | grep -v "^#\|^$"

# CLAUDE.md 커스텀 섹션 유지
grep "Custom Section" <upgraded-target>/CLAUDE.md

# BOOTSTRAP.md 프로젝트 기입 내용 유지
# TODO: upgrade 정책상 B-class(write_text) 파일은 덮어쓰지 않는지 확인
```

### T3. Source-only 누수 없음 (invariant [2])

```bash
bash scripts/tests/check-scaffold-invariants.sh <upgraded-target>
# [2] no-source-only-leakage PASS 확인
```

### T4. upgrade 후 onboarding 시뮬레이션

```bash
# Layer J-OB의 OB1~OB6을 upgraded target에 재실행
# 신규 scaffold와 동일한 흐름이 성립하는가
# TODO: upgraded target 경로를 OB 시나리오 TARGET으로 치환하는 방법 확정
```

### T5. 역방향 cascade — 이 파일 갱신 트리거

upgrade 구현이 변경될 때 아래 섹션을 갱신한다:

| 변경 사항 | 갱신 대상 |
| --- | --- |
| `--upgrade` 옵션 추가 | T0 준비 명령, M5 역방향 cascade 표 |
| upgrade 시 B-class 파일 덮어쓰기 정책 변경 | T2 커스터마이징 보존 확인 |
| manifest version 비교 로직 변경 | T1, Layer R |

---

## 이 파일 자체 점검

`docs/VERIFICATION-COMMANDS.md`를 수정했을 때 이 파일 자체의 정합성을 확인한다.

### M1. 파일 내 경로 참조 실재 확인

```bash
# 이 파일에서 참조하는 docs/ 경로 전수 확인
grep -oE 'docs/[A-Za-z0-9/_-]+\.md' docs/VERIFICATION-COMMANDS.md | sort -u | while read f; do
  [ ! -f "$f" ] && echo "MISSING: $f"
done

# skills/, .claude/, .agents/, .cursor/, scripts/ 경로 참조 확인
grep -oE '(skills|\.claude|\.agents|\.cursor|scripts)/[A-Za-z0-9/_.-]+' \
  docs/VERIFICATION-COMMANDS.md | sort -u | while read f; do
  [ ! -e "$f" ] && echo "MISSING: $f"
done
```

### M2. 명령 stale 탐지

```bash
# 이 파일에서 참조하는 command/skill 이름이 실제로 존재하는가
# slash command만 추출(앞이 비영숫자 + 하이픈 포함) → 경로 segment·절대경로 오탐 제외
grep -oE '([^a-zA-Z0-9]|^)/[a-z]+-[a-z-]+' docs/VERIFICATION-COMMANDS.md \
  | grep -oE '/[a-z-]+' | sort -u | while read cmd; do
  name="${cmd#/}"
  [ ! -f ".claude/commands/${name}.md" ] \
    && [ ! -f "skills/workflow/${name}.md" ] \
    && echo "STALE command ref: $cmd"
done

# 구버전 용어 자기 참조 탐지
grep -n "HRN-0[0-9][0-9]\b\|/repo-decision\|repo-decision" docs/VERIFICATION-COMMANDS.md
```

### M3. bash 명령 기본 문법 확인

> **한계 (참고용):** 아래는 모든 ```bash 블록을 concat해 `bash -n`에 넣는다. `<target-dir>`·`<upgraded-target>` 같은 placeholder 토큰과 블록 간 문맥 단절(미정의 변수, 독립 `cd`/redirect)이 **false positive**를 만든다. 출력은 "명백한 구조적 오류" 1차 스크리닝으로만 쓰고, 진짜 문법 오류 여부는 해당 블록을 개별 확인한다.

```bash
# 코드 블록 내 bash 명령에서 명백한 문법 오류 탐지 (1차 스크리닝)
# (셸 스크립트로 추출하여 bash -n 실행 — placeholder 토큰은 false positive 가능)
grep -A999 '```bash' docs/VERIFICATION-COMMANDS.md \
  | grep -v '```' | bash -n 2>&1 | head -20
```

### M4. repo-health Required Surface Matrix 등재 여부

```bash
# repo-health.md가 이 파일을 참조하는가
grep -n "VERIFICATION-COMMANDS" skills/workflow/repo-health.md

# AGENT-WORKFLOW.md Verification Defaults가 이 파일을 참조하는가
grep -n "VERIFICATION-COMMANDS" docs/AGENT-WORKFLOW.md
```

### M5. 양방향 cascade 범위

**이 파일이 변경됐을 때** 점검 대상:

| Surface | 이유 |
| --- | --- |
| `skills/workflow/repo-health.md` | Required Surface Matrix pointer 유효성 |
| `docs/AGENT-WORKFLOW.md` | Verification Defaults pointer 유효성 |
| `docs/HARNESS-QUICK-REFERENCE.md` | one-liner 참조 유효성 |
| 이 파일 내부 (M1~M4) | 경로·명령 stale, bash 문법, cascade 등재 여부 |

**다른 파일이 변경됐을 때 이 파일도 점검 대상:**

| 변경 파일 | 영향 범위 | 갱신 필요 섹션 |
| --- | --- | --- |
| `scripts/create-harness.sh` — 옵션 추가/변경 (`--with-*`, `--workflow`, `--profile`) | 새 옵션에 대한 OB 시나리오 누락 가능 | OB0 준비 명령, 해당 옵션 전용 OBn 시나리오 추가 |
| `scripts/create-harness.sh` — write_text() 템플릿 변경 | Layer B grep 패턴 stale 가능 | Layer B |
| `skills/workflow/*.md` — command 흐름 변경 | J 시나리오 내 파일 체인 stale 가능 | J1~J10 해당 command 시나리오 |
| `docs/AGENT-WORKFLOW.md` — Verification Defaults 변경 | Layer A/E 기준 변경 | Layer A, E |
| `docs/HARNESS-PROTOCOL.md` — T-series trigger 변경 | Layer F/J8 cascade 기준 변경 | Layer F, J8 |
| `.claude/rules/git-workflow.md` — branch isolation 규칙 변경 | OB6 시나리오 C/D stale 가능 | OB6 시나리오 C, D |
| `docs/BOOTSTRAP.md` 템플릿 변경 (`create-harness.sh` 내) | OB1/OB2 흐름 stale 가능 | OB1, OB2 |
| `docs/decisions/DR-013-*.md` Work file spec 변경 | Layer O Work 파일 spec 점검 기준 변경 | Layer O |
| `docs/decisions/DR-007-*.md` 언어 정책 변경 | Layer P 탐지 패턴 변경 필요 | Layer P |
| `tools/git-hooks/` hook 로직 변경 | Layer Q functional test 결과 변경 가능 | Layer Q |
| `VERSION` 파일 변경 | Layer R version 일치 여부 재확인 | Layer R |
| `prompts/*session-start.md` 변경 | Layer S prompt ↔ canonical 정합 | Layer S |
| `.harness/gate-config` 형식/파싱 로직 변경 | OB7 gate-config 수정 후 동작 검증 | OB7 |
| `--upgrade`/`--refresh` 구현 완료 | Layer T placeholder → 실 명령으로 채우기 | Layer T |

```bash
# 역방향 탐지: create-harness.sh 옵션 목록과 OB 시나리오 커버리지 비교
grep -oE '\-\-[a-z-]+' scripts/create-harness.sh | sort -u > /tmp/script_opts.txt
grep -oE '\-\-[a-z-]+' docs/VERIFICATION-COMMANDS.md | sort -u > /tmp/doc_opts.txt
comm -23 /tmp/script_opts.txt /tmp/doc_opts.txt
# → 결과에 --with-* 또는 --workflow 관련 옵션이 있으면 OB 시나리오 갱신 필요
```

---

## 결과 분류 기준

발견 항목은 아래 형식으로 보고한다.

```
[P0/P1/P2] 위치: <파일:라인>
  drift 이유: <왜 어긋났는지>
  canonical:  <어느 문서가 기준인지>
  수정안:     <변경 내용>
  처리:       지금 / 다음 세션 / Deferred
```

| 등급 | 기준 |
| --- | --- |
| P0 | 흐름 단절 / 상태 오염 / scaffold 사용 불가 |
| P1 | surface drift / mirror 누락 / 생산성 저하 |
| P2 | wording 불일치 / optional 단순화 |
