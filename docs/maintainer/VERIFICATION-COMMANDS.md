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

**executable assertion과의 경계:** deterministic하게 PASS/FAIL이 갈리고 회귀로 잠글 가치가 있는 점검은 `scripts/tests/**`(executable assertion)가 SSoT다. 이 카탈로그는 그보다 넓은(판단 개입·false-positive 가능) 점검을 human-run 명령으로 유지하며, executable로 승격된 항목은 **스크립트를 pointer로만** 보유한다(명령 중복 금지 — Layer C→`check-scaffold-invariants.sh`, Layer I→`check-shipped-dr-closure.sh`). surface별 검증 기준·Tier·runner는 `docs/maintainer/HARNESS-TEST-TAXONOMY.md`를 따른다.

관련 문서:
- `docs/AGENT-WORKFLOW.md` Verification Defaults — 변경 유형별 기본 검증 규칙
- `docs/maintainer/HARNESS-TEST-TAXONOMY.md` — surface별 검증 기준(무엇/어느 깊이)·Tier 정의·3층 수단 경계
- `scripts/tests/run-harness-checks.sh` — Tier별 deterministic 검증 runner(`--tier0|--tier1 <target>|--tier2|--all`)
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

- **Layer T** — adopter upgrade/migration walkthrough. source-only·target-specific 검증이므로 릴리즈 full sweep에는 기본 편입하지 않고, migration 관련 변경 또는 실제 adopter 전환 때 실행한다.
- **Layer U** — product starter/import (U2~U4는 criteria placeholder, U1 boundary smoke만 실재). W2/W5 산출물 확정 후 편입.
- **Layer K** — `/repo-health` 통합 실행. 위 전수를 포괄하는 umbrella이므로 개별 sweep과 병행 또는 대체로 선택.
- **Layer B · D · M** — 보조 진단 / 자체 점검. 필요 시 ad-hoc.

**release-go 판정:** 출하 표면 발견 항목을 분류한다.

| 분류 | 처리 |
| --- | --- |
| 출하 표면의 결함/회귀 | 릴리즈 전 반드시 수정 (release-block) |
| 미구현 기능의 갭 (Layer U2~U4 등) | 용인, 백로그 추적 |
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
# 인자 없으면 default minimal + --with-optional + --workflow source-gitflow 세 모드 생성·검사
# [1]  core A-class DR 참조 실재 (hard-fail; core_files)
# [1r] optional-pack DR dangling (report-only)
# [2]  source-only 경로 누수 (hard-fail; leak_scan_files = core_files + source-gitflow shipped set)
# [3]  decisions/README ↔ DR 파일 closure (hard-fail; core_files)
# [4]  root README 파일표 ↔ optional docs on-disk (hard-fail)
# [5]  manifest + --check 자기일관성, drift 0 (hard-fail)
```

> `[2] leak-scan`만 source-gitflow shipped adapt text set(`GIT-WORKFLOW.md` + `.github/workflows/harness-validate.yml` + `tools/git-hooks/{pre-commit,commit-msg,install.sh,lib/gate-lists.sh}`)까지 포함한다. `[1]`/`[3]`은 core A-class만 본다(closure 범위 과다 확장 방지). 기준·Tier는 `HARNESS-TEST-TAXONOMY.md`.

> **runner 실행 기준:** PR merge 전 또는 harness 마일스톤 완료 시 `bash scripts/tests/run-harness-checks.sh --all`(scaffold 3모드 + closure + syntax 전수)을 권장한다.

> **`scripts/tests/**` 변경 시 cascade (source-side surface):** `check-scaffold-invariants.sh`·`check-shipped-dr-closure.sh`·`run-harness-checks.sh`는 검증 척추의 executable SSoT다. 변경 시 ① `bash -n scripts/tests/*.sh`(runner `--tier0`에 포함) ② `run-harness-checks.sh --all`로 회귀 확인 ③ `HARNESS-TEST-TAXONOMY.md`(기준·Tier·matrix)와 이 카탈로그(Layer C) pointer 정합을 점검한다. 이들은 **source-only maintainer surface**이므로 scaffold target leak-scan 대상이 아니다(target leak-scan은 framework-owned ship 파일 중심). repo-health 영향 surface 반영은 F4로 둔다.

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
- **자동 강제:** source repo `tools/git-hooks/pre-commit`이 commit 시 이 check를 자동 실행한다(hard gate). 위반 시 commit이 차단된다. check 스크립트가 없는 adopter repo에서는 존재 가드로 no-op.

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

## Layer Q-static. Gate Path-List Parity (static, 생성 없음)

Layer Q(hook **functional** test, scaffold 생성)와 분리된 **static parity** 점검이다. 같은 protected/finalization 정책을 서술하는 **5개 source-실재 surface**가 서로 drift하지 않는지 본다. 생성·hook 실행 없이 grep만 수행한다.

비교 surface: `tools/git-hooks/lib/gate-lists.sh`(SSoT) · `.claude/rules/git-workflow.md`(rule) · `docs/GIT-WORKFLOW.md`(source user-facing) · `scripts/templates/source-gitflow/docs/GIT-WORKFLOW.md`(shipped template) · `scripts/create-harness.sh`의 `.harness/gate-config` seed.

> **설계 원칙:** raw glob(`docs/backlog/*` vs `**` vs `*.md`) 직접 diff 금지 — **semantic key 대표 토큰**으로 정규화한다. protected/finalization/seed는 성격이 달라 **3축으로 분리**한다.

### Axis A — Protected-path semantic-key parity (surface별 expected matrix)

surface마다 기대 key가 다르다(정책 차이 ≠ drift). 아래 **expected matrix가 SSoT**다.

| semantic key | gate-lists.sh | git-workflow.md rule | docs/GIT-WORKFLOW.md | source-gitflow template |
| --- | --- | --- | --- | --- |
| workflow-status | ✓ | ✓ | ✓ | ✓ |
| ai-entrypoint | ✓ | ✓ | ✓ | ✓ |
| canonical-workflow | ✓ | ✓ | ✓ | ✓ |
| tool-surface | ✓ | ✓ | ✓ | ✓ |
| hooks | ✓ | ✓ | ✓ | ✓ |
| scaffold (`scripts/create-harness.sh`) | ✓ | ✓ | ✓ | **N/A** (target 미ship) |
| project-gate-config (`.harness/gate-config`) | ✓ | ✓ | **N/A** (user doc) | **N/A** |

각 surface를 자기 expected 열과 대조한다 — expected ✓인데 누락이면 DRIFT, N/A면 비교 제외.

```bash
GL=tools/git-hooks/lib/gate-lists.sh
RULE=.claude/rules/git-workflow.md
GWF=docs/GIT-WORKFLOW.md
TPL=scripts/templates/source-gitflow/docs/GIT-WORKFLOW.md

# key → 대표 regex (glob 표현 차이 무시한 정규화 토큰)
key_rx() {
  case "$1" in
    workflow-status)     echo 'docs/STATUS\.md' ;;
    ai-entrypoint)       echo 'CLAUDE\.md' ;;
    canonical-workflow)  echo 'AGENT-WORKFLOW' ;;
    tool-surface)        echo '\.claude/(commands|rules)|\.agents/skills' ;;
    hooks)               echo 'tools/git-hooks' ;;
    scaffold)            echo 'scripts/create-harness\.sh' ;;
    project-gate-config) echo '\.harness/gate-config' ;;
  esac
}
# check_surface <label> <file> <expected-key...>
#   label 명시: source/template GIT-WORKFLOW.md는 basename이 같아 구분이 안 되므로 label로 분리한다.
#   "$@" 전개는 bash/zsh 양쪽 portable(scalar 분리는 zsh에서 비동작).
check_surface() {
  _lbl="$1"; _f="$2"; shift 2
  for _k in "$@"; do
    if grep -qE "$(key_rx "$_k")" "$_f"; then echo "  OK    [$_lbl] $_k"
    else echo "  DRIFT [$_lbl] $_k expected but 누락"; fi
  done
}

check_surface "gate-lists.sh" "$GL"   workflow-status ai-entrypoint canonical-workflow tool-surface hooks scaffold project-gate-config
check_surface "rule"          "$RULE" workflow-status ai-entrypoint canonical-workflow tool-surface hooks scaffold project-gate-config
check_surface "GWF(source)"   "$GWF"  workflow-status ai-entrypoint canonical-workflow tool-surface hooks scaffold
check_surface "GWF(template)" "$TPL"  workflow-status ai-entrypoint canonical-workflow tool-surface hooks
```

### Axis B — Finalization parity (policy/pointer, path-list 아님)

`awh_is_finalization_file` default(STATUS/backlog/works/decisions/README)를 SSoT로 두고, 문서는 finalization을 **bundling 정책/pointer**로 참조한다(같은 path-list를 재나열하지 않음). **expected surface는 모두 참조해야 한다** — 누락은 INFO가 아니라 DRIFT다(그렇지 않으면 "검증한다 말하지만 실패하지 않는 검사"가 된다). expected surface: gate-lists.sh(SSoT set), rule, docs/GIT-WORKFLOW.md(source), source-gitflow template. label은 source/template basename 충돌을 피하려 pair로 명시한다.

```bash
GL=tools/git-hooks/lib/gate-lists.sh
# B1. SSoT 집합이 gate-lists.sh에 보존되는가
for t in 'docs/STATUS\.md' 'docs/backlog' 'docs/works' 'docs/decisions/README'; do
  grep -qE "$t" "$GL" && echo "  OK    [gate-lists] finalization set: $t" \
    || echo "  DRIFT [gate-lists] finalization set 누락: $t"
done
# B2. expected 문서 surface가 finalization bundling 정책/pointer를 참조 — 누락=DRIFT
for pair in \
  "rule:.claude/rules/git-workflow.md" \
  "GWF(source):docs/GIT-WORKFLOW.md" \
  "GWF(template):scripts/templates/source-gitflow/docs/GIT-WORKFLOW.md"; do
  lbl="${pair%%:*}"; f="${pair#*:}"
  grep -qiE 'finalization|bundling' "$f" \
    && echo "  OK    [$lbl] finalization 정책 참조" \
    || echo "  DRIFT [$lbl] finalization bundling 정책 pointer 누락(expected surface)"
done
```

### Axis C — Seed section + add-only 안내 parity

```bash
GL=tools/git-hooks/lib/gate-lists.sh
SEED=scripts/create-harness.sh

# c1: seed [protected]/[finalization] 섹션 ↔ gate-lists.sh section args 정합
for s in protected finalization; do
  grep -qE "\[$s\]" "$SEED" && echo "  OK    seed [$s] 섹션 존재" || echo "  DRIFT seed [$s] 섹션 누락"
  grep -qE "$s" "$GL"       && echo "  OK    gate-lists section arg '$s'" || echo "  DRIFT gate-lists section arg '$s' 누락"
done

# c2: anti-drift — shipped doc이 project 경로를 framework-owned gate-lists.sh에 직접 추가하라고
#     안내하지 않는다(add-only .harness/gate-config로 유도해야 함). 한국어+영어/식별자형 모두 포착.
#     단, "편집하지 말고 …" 같은 부정문(add-only로 유도하는 올바른 문구)은 오탐하지 않도록 EXCL로 제외.
BAD='동일한 목록|동일 목록|두 곳을 함께|case 패턴에 추가|edit .{0,25}gate-lists|gate-lists[^ ]*\.sh.{0,25}case|awh_is_[a-z_]+.{0,40}case|add .{0,40}awh_is_|awh_is_[a-z_]+.{0,15}추가'
EXCL='편집하지|편집 금지|do not edit|add-only|gate-config'
for pair in "GWF(source):docs/GIT-WORKFLOW.md" "GWF(template):scripts/templates/source-gitflow/docs/GIT-WORKFLOW.md"; do
  lbl="${pair%%:*}"; f="${pair#*:}"
  hits=$(grep -nE "$BAD" "$f" | grep -vE "$EXCL")
  if [ -n "$hits" ]; then
    echo "  DRIFT [$lbl] gate-lists.sh 직접 편집 안내 — add-only gate-config로 정정 필요:"
    echo "$hits" | sed 's/^/        /'
  else
    echo "  OK    [$lbl] gate-lists 직접편집 안내 없음(add-only 정합)"
  fi
done
```

> **Surface Matrix 연계:** 위 5 surface 중 하나라도 변경되면 이 Q-static을 실행한다(`skills/workflow/repo-health.md` Surface Matrix가 pointer로 연결). **runner와의 관계(F4):** gate parity의 executable 동반자는 `run-harness-checks.sh`이나, 현재 runner는 이 static parity를 호출하지 않는다 — 통합은 후속 F4. 이번에는 catalog Q-static + repo-health pointer까지만.

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

기존 scaffold target을 현재 source baseline으로 올리는 upgrade/migration 검증이다.
full `--upgrade`/`--refresh` helper는 아직 없다. pre-manifest target은 inventory-first + shadow scaffold baseline 방식으로 검증한다.

### T0. target probe

manifest 유무를 먼저 확인한다.

```bash
TARGET="<target-dir>"

test -f "${TARGET}/.harness/manifest.json" \
  && echo "manifest target" \
  || echo "pre-manifest target"

bash scripts/create-harness.sh --check "${TARGET}" || true
```

판정:

- manifest target: `--check` report를 drift input으로 사용한다.
- pre-manifest target: `--check`는 exit 3이 정상이다. 이 결과를 migration 범위로 해석하지 않고 T1 inventory로 이동한다.

### T1. inventory-first 분류

pre-manifest target은 먼저 file ownership을 분류한다.

```bash
TARGET="<target-dir>"

# 1. tool/workflow surface 후보
find "${TARGET}" \
  \( -path "${TARGET}/.git" -o -path "${TARGET}/node_modules" \) -prune -o \
  \( -path "*/.claude/commands/*" -o -path "*/.agents/skills/*" -o \
     -path "*/.cursor/rules/*" -o -path "*/skills/*" -o -path "*/prompts/*" -o \
     -name AGENTS.md -o -name CLAUDE.md -o -path "*/docs/GIT-WORKFLOW.md" -o \
     -path "*/docs/AGENT-WORKFLOW.md" -o -path "*/docs/HARNESS-PROTOCOL.md" \) \
  -print | sort

# 2. project-owned state 후보
find "${TARGET}" \
  \( -path "${TARGET}/.git" -o -path "${TARGET}/node_modules" \) -prune -o \
  \( -path "*/docs/STATUS.md" -o -path "*/docs/PLAN.md" -o \
     -path "*/docs/backlog/*" -o -path "*/docs/works/*" -o \
     -path "*/package.json" -o -path "*/src/*" \) \
  -print | sort
```

Layer T walkthrough 결과에는 `framework-owned / project-owned / customized / accepted drift` 분류를 남긴다.

### T2. shadow scaffold baseline 생성

shadow scaffold는 target과 **동일 project-name**을 사용한다. `adapt()`가 project-name을 치환하므로 이름이 다르면 hash 비교가 오염된다.

```bash
PROJECT_NAME="<target-project-name>"
TARGET_COPY="temp/upgrade-target-copy"
SHADOW="temp/upgrade-shadow"

# 예: source-gitflow + generic
bash scripts/create-harness.sh --workflow source-gitflow --profile generic "${PROJECT_NAME}" "${SHADOW}"

test -f "${SHADOW}/.harness/manifest.json"
```

### T3. manifest baseline 심기 + drift 관측

먼저 manifest만 target copy에 심고 `--check`로 실제 drift 분포를 관측한다. framework 파일을 복사하기 전에 실행해야 한다.

```bash
TARGET_COPY="temp/upgrade-target-copy"
SHADOW="temp/upgrade-shadow"

mkdir -p "${TARGET_COPY}/.harness"
cp "${SHADOW}/.harness/manifest.json" "${TARGET_COPY}/.harness/manifest.json"

bash scripts/create-harness.sh --check "${TARGET_COPY}" \
  | tee temp/upgrade-check-before.txt
```

### T4. selective migration

`target-missing`은 신규 framework 파일 후보로 복사할 수 있다. `locally-modified`는 바로 덮지 말고 diff/manual-merge 후보로 분류한다. pre-manifest target에는 과거 baseline이 없으므로 이 판단은 3-way merge가 아니라 current source vs adopter의 2-way diff 한정이다.

```bash
TARGET_COPY="temp/upgrade-target-copy"
SHADOW="temp/upgrade-shadow"

awk '/\[target-missing\]/ {print substr($0, index($0,$2))}' \
  temp/upgrade-check-before.txt > temp/upgrade-target-missing.txt

while IFS= read -r line; do
  mkdir -p "${TARGET_COPY}/$(dirname "${line}")"
  cp "${SHADOW}/${line}" "${TARGET_COPY}/${line}"
done < temp/upgrade-target-missing.txt

awk '/\[locally-modified\]/ {print substr($0, index($0,$2))}' \
  temp/upgrade-check-before.txt > temp/upgrade-locally-modified.txt

# locally-modified 파일은 여기서 diff를 보고 copied / merged / accepted drift / skipped로 분류한다.
```

### T5. verify baseline

```bash
TARGET_COPY="temp/upgrade-target-copy"

bash scripts/create-harness.sh --check "${TARGET_COPY}"
bash scripts/tests/check-scaffold-invariants.sh "${TARGET_COPY}"
```

첫 `--check`는 drift 분포가 나오는 것이 정상이다. drift 0을 강제하지 말고, framework drift와 accepted drift를 분류한다. 단 source repo invariant 전체를 통과시키려면 manifest-tracked drift는 최종적으로 in-sync 또는 명시적 accepted drift로 정리되어야 한다.

실측(CHORE-20260611-010, `ai-deck-compiler` temp copy):

- shadow scaffold project-name: `ai-deck-compiler` (동일 이름)
- workflow/profile: `source-gitflow` / `generic`
- manifest tracked files: 76
- manifest만 심은 첫 `--check`: `76 tracked, 9 in-sync, 67 drifted` (`target-missing` 37, `locally-modified` 30)
- 1차 selective 반영: `target-missing` 37개 신규 framework 파일 복사
- 2차 selective 반영: hard invariant를 깨는 locally-modified 3개(`docs/HARNESS-NAMING-RULES.md`, `docs/AGENT-WORKFLOW.md`, `docs/HARNESS-PROTOCOL.md`)와 project-owned decision index 보강
- 중간 `--check`: `76 tracked, 49 in-sync, 27 drifted`
- 남은 27개는 manifest-tracked locally-modified manual-merge/copy candidates로 분류. temp simulation에서는 current framework baseline으로 반영
- 최종 `--check`: `76 tracked, 76 in-sync, 0 drifted`
- invariant 1차: `docs/decisions/README.md` 부재로 FAIL(decision index closure)
- target-local accepted DR rows(DR-021~023) index 보강 후 invariant PASS

### T6. accepted drift / project-owned 보존 기록

target migration Work는 아래 표를 남긴다.

| Path | Classification | Action | Reason |
| --- | --- | --- | --- |
| `docs/STATUS.md` | project-owned | preserved | target state |
| `docs/decisions/README.md` | project-owned index | updated | target-local DR index closure |
| `docs/AGENT-WORKFLOW.md` | framework-owned locally-modified | copied / merged | source-only leakage hard invariant |

### T7. 역방향 cascade — 이 파일 갱신 트리거

upgrade 구현이 변경될 때 아래 섹션을 갱신한다:

| 변경 사항 | 갱신 대상 |
| --- | --- |
| `--upgrade`/`--refresh` 옵션 추가 | T0~T5 명령, M5 역방향 cascade 표 |
| `manifest-init` 또는 `--upgrade-plan` 추가 | T2/T3 shadow baseline 절차 |
| upgrade 시 project-owned 파일 덮어쓰기 정책 변경 | T1/T5 보존 분류 |
| manifest version 비교 로직 변경 | T4, Layer R |

---

## Layer U. Product Starter / Option-pack Import 검증

신규 product 착수 흐름 — ① product starter planning pack 산출물 ② core scaffold ↔ stack/profile pack 경계 ③ product repo → source repo import 후보 — 의 검증 기준이다.

> **Layer T와의 분리:** Layer T는 *기존 scaffold를 새 harness 버전으로 올리는* upgrade/migration 검증이다. Layer U는 *새 product를 시작·반입하는* 흐름 검증으로, 관심사가 다르므로 분리한다.
>
> **범위 경계 (중요):** 이 흐름의 핵심 산출물(planning pack, import format, product engineering option-pack)은 아직 **설계 전**이다(backlog W2 `Product starter planning pack + feedback import loop`, W5 `Spring Boot MSA TDD option-pack`). 따라서 이 Layer는 **criteria/checklist 우선**이며, concrete 명령은 *오늘 실재하는 surface(stack/profile↔core 경계)*에만 둔다. 미설계 산출물(U2~U4)은 Layer T처럼 **판정 기준 + placeholder**로 두고, W2/W5 산출물이 확정되면 concrete 명령으로 승격한다.

### U1. Core ↔ Stack/Profile Pack 경계 (concrete — boundary smoke check)

> **이 점검의 정확한 의미:** "현 stack/profile-specific 콘텐츠가 core(generic)에 누수되지 않고, 선택 시에만 등장하는가"를 본다. **`--profile spring-boot`의 산출물을 보존·검증하려는 것이 아니다** — 현 spring-boot profile은 효용이 낮아 교체될 수 있다(W5). 검증하는 일반 원칙은 **① stack 콘텐츠 비누수 ② 미래 어떤 product pack이 들어와도 동등한 core↔pack 경계를 가질 것**이며, spring-boot은 그 원칙의 *현재 유일한 구체 사례*로만 인용한다. (source-only 경로 누수는 invariant `[2]`, optional docs 표 일치는 invariant `[4]`가 담당 — 여기서는 **stack-content-in-core**라는 별도 축을 본다.)
>
> **검사 방식 주의:** stack 콘텐츠는 **파일 단위**로 추가된다(현 spring-boot: `.claude/rules/java-spring.md`, `.cursor/rules/java-spring.mdc`). 문자열 `spring-boot` grep은 generic의 BOOTSTRAP/PROTOCOL이 옵션을 *안내 문구로 언급*하는 것까지 잡는 **false positive**가 되므로 쓰지 않는다 — **stack-marker 파일 존재 여부**로 본다.

```bash
# U0. 준비: profile/option별 scaffold 생성 (Tier 2 정책 §5 — repo-local temp/)
mkdir -p temp/awh-pp
G=temp/awh-pp/generic; S=temp/awh-pp/spring; O=temp/awh-pp/optional
bash scripts/create-harness.sh pp-generic "$G"
bash scripts/create-harness.sh --profile spring-boot pp-spring "$S"
bash scripts/create-harness.sh --with-optional pp-optional "$O"

# 현재 stack 표면 식별용 진단(파일 단위): spring profile에만 있는 파일 목록
comm -13 <(cd "$G" && find . -type f | sort) <(cd "$S" && find . -type f | sort)

# stack-marker 경계 검사 (현 spring-boot 사례 — rule 파일을 대표 marker로 사용).
#   리스트는 for 루프에 literal로 둔다(unquoted scalar 분리는 zsh에서 동작하지 않음 — bash/zsh 양쪽 portable).
#   각 marker에 대해 ① generic core 부재 ② spring profile 존재를 한 루프에서 본다.
for m in \
  .claude/rules/java-spring.md \
  .cursor/rules/java-spring.mdc; do
  [ -e "$G/$m" ] && echo "LEAK: ${m} in generic core" || echo "OK: ${m} absent in generic"
  [ -e "$S/$m" ] && echo "OK: ${m} present with --profile spring-boot" \
    || echo "WARN: ${m} 누락 in spring profile — profile/경계 로직 확인"
done

# 3. optional docs는 --with-optional에서만 (generic 누수 없음)
ls "$O"/docs/HARNESS-ARCHITECTURE.md "$O"/docs/WORKFLOW-MANUAL.md >/dev/null 2>&1 \
  && echo "OK: optional docs present with --with-optional"
ls "$G"/docs/HARNESS-ARCHITECTURE.md 2>/dev/null \
  && echo "LEAK: optional docs in generic core" \
  || echo "OK: generic core가 optional-clean"

# U0c. 정리
rm -rf temp/awh-pp
```

### U2. Product Starter Planning Pack 산출물 (criteria — structured checklist)

기준 문서: `docs/maintainer/PRODUCT-STARTER-PLANNING-PACK.md`

W2 planning pack이 산출되면 아래 **존재·역할·owner**를 확인한다. 내용 품질의 깊은 검토는 해당 Work 범위이며, Layer U는 "산출물이 빠짐없이 있고 source/product 경계가 맞는가"를 본다.

| 그룹 | 산출물 | 역할 확인 기준 | owner 기대값 |
| --- | --- | --- | --- |
| source-first seed | Product brief / PRD template | 질문 프레임 또는 skeleton 존재 | source seed |
| source-first seed | TRD / architecture brief template | 구조/제약 질문 skeleton 존재 | source seed |
| source-first seed | Delivery plan / task map skeleton | tranche/task 분해 틀 존재 | source seed |
| source-first seed | Test structure seed | unit/integration/e2e 계층 제안 존재 | source seed |
| source-first seed | `loop.md` skeleton 또는 동등 절차 | 반복 실행 + human gate 기본 구조 존재 | source seed |
| source-first seed | Open questions / assumptions starter | 미결정 질문 starter와 검증 경로 틀 존재 | source seed |
| product-local expansion | code conventions | source seed와 product-local concrete 구분 | product-owned with source seed |
| product-local expansion | user flow | 실제 사용자 흐름 정의 존재 | product-owned |
| product-local expansion | DB design | logical/physical 모델 경계 명시 | product-owned |
| product-local expansion | screen / screen flow | 실제 화면/상태 전이 정의 존재 | product-owned |

**판정 포인트:**

- source-first seed가 product-specific 내용을 완성본으로 끌어안지 않는가
- product-local expansion이 source option-pack으로 오인되지 않는가
- `loop.md`가 자동/인간개입 경계를 분리하는가
- 아직 검증된 실제 import candidate 사례가 없다는 점이 문서에 명시되어 있는가

> **승격 조건:** W2가 위 산출물의 실제 경로/파일명을 확정하면, 이 표를 concrete path 존재 검사로 승격한다. 그 전까지는 checklist로 유지한다.

### U3. Template 분석 범위 (criteria — structured boundary)

기준 문서: `docs/maintainer/PRODUCT-STARTER-PLANNING-PACK.md`

template 분석은 아래 include/exclude/reference-only 경계를 따른다. 특정 repo의 실제 파일/경로 inventory는 해당 Work Discovery 또는 작업 메모에 남긴다.

| 분류 | 포함 경로 예시 | 목적 |
| --- | --- | --- |
| include | root README, plan/summary, architecture/developer guide, coding conventions, build graph, module/service 디렉토리, infra/test 예시 | planning pack seed와 module/test/infra shape 추출 |
| exclude | harness/agent 운영 문서, status/works/harness backlog, archive/retrospectives, historical decisions 원문 | 운영 흔적과 historical tracking 제외 |
| reference-only | product backlog, troubleshooting, archived plans/snapshots | enterprise gap / 미완료 hardening / rationale 참고 |

**판정 포인트:**

- harness 운영 문서를 product starter pack seed로 잘못 끌어오지 않는가
- product backlog와 open gap을 "현재 template의 미완료 영역" 근거로만 쓰고, pack seed 자체로 복사하지 않는가

### U4. Product → Source Import 후보 Mapping (review aid — structured review aid)

product repo에서 검증된 산출물을 source repo option-pack 후보로 정리할 때 쓰는 **검토 보조 표(review aid)**다. 형식 규약이 아니라 **승격 심사 표**이며, 실제 source 반영은 별도 Work에서만 수행한다.
아직 검증된 실제 사례가 없으므로, 첫 concrete product use 후 열 구성과 판단 기준을 재검토한다.

| artifact | owner | generalizable? | proof of generality | product-specific residue | proposed source target | promotion blocker |
| --- | --- | --- | --- | --- | --- | --- |
| (예: test structure) | source/product/shared | Y/N | 다른 product에도 재사용 가능한 이유 | 제거해야 할 도메인 흔적 | `docs/maintainer/` / optional pack / helper candidate | 지금 바로 올리면 안 되는 이유 |

**판정 포인트:**

- generalizable 근거 없이 "잘 됐다"만으로 승격하려 하지 않는가
- source target이 `docs/maintainer/`, optional pack, helper candidate 중 어디인지 명시되는가
- product-specific residue 제거 계획이 없는 항목을 승격 후보로 올리지 않는가

> **승격 조건:** 두 번째 product에서도 반복 패턴이 확인되면, 이 review aid를 형식 규약 또는 helper candidate로 승격할지 판단한다.

### U5. 역방향 cascade — 이 Layer 갱신 트리거

| 변경 사항 | 갱신 대상 |
| --- | --- |
| product engineering pack 옵션 추가 (예: `--with-spring-boot-msa`) 또는 profile 교체 | U1 경계 검사(새 옵션 대상), U0 준비 명령 |
| W2 planning pack 산출물 경로/파일명 확정 | U2 표 → concrete 존재 검사로 승격 |
| W2 import loop 형식 확정 | U4 review aid → 형식 규약/helper 판단 |

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
| `scripts/create-harness.sh` — product engineering pack 옵션 추가/변경 (예: `--with-spring-boot-msa`, profile 교체) | 새 stack/profile↔core 경계·pack 산출물 검증 누락 가능 | Layer U (U1 경계 검사 + U2~U4 criteria) |
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
| `--upgrade`/`--refresh`/`manifest-init` 구현 | Layer T 실행 명령·shadow baseline 절차 갱신 | Layer T |

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
