---
id: FEAT-20260527-001
priority: P1
status: Done
risk: L2
scope: create-harness.sh --workflow source-gitflow opt-in 추가, default scaffold branch isolation drift 수정, command/skill/rule surface 분리
appetite: 1-2w
planned_start: 2026-05-27
planned_end: 2026-06-10
actual_end: 2026-05-27
related_dr: []
related_commits: []
related_troubleshooting: []
---

# FEAT-20260527-001: Source-style Scaffold Workflow Profile

## Plan

### Background

`temp/work-plans/06-source-style-scaffold-workflow-profile.md` 기반 후속 Work다.

현재 `scripts/create-harness.sh`는 모든 profile(generic, spring-boot)에 동일한 `.claude/rules/git-workflow.md`를 복사한다.
이 파일에는 source repo(ai-workflow-harness) 전용 branch isolation rule이 포함되어 있다:
- `develop`/`main` 직접 수정 금지
- Protected file 목록 (`AGENTS.md`, `CLAUDE.md`, `docs/STATUS.md`, `docs/works/**` 등)
- PR Base Rule: `feature/* → develop`, `develop → main`

**핵심 발견 (사전 audit):**
- `create-harness.sh` line 215: `git-workflow.md`를 모든 profile에 그대로 복사함
- `create-harness.sh` line 224-225: `.claude/commands/*.md` 전체를 복사 — `work.md`, `close.md`에 Branch Isolation Check(develop/main → FAIL) 포함
- `create-harness.sh` line 229-232: `.agents/skills/*/SKILL.md` 전체 복사 — `workflow-work`, `workflow-close`에 동일 check 포함

결과: trunk-based 또는 GitHub Flow 프로젝트에서 default scaffold를 사용하면 `/work`, `/close` 등 핵심 command가 항상 FAIL을 낸다.

이 Work는 두 문제를 함께 해결한다:
- **문제 A**: default scaffold에서 source-style branch isolation 제거 (기존 drift 수정)
- **문제 B**: `--workflow source-gitflow` opt-in mode 추가 (신규 기능)

### Approach

1. **Default scaffold 수정**: `git-workflow.md`를 generic/source 두 레이어로 분리. Branch Isolation 섹션을 source-gitflow 전용으로 이동.
2. **Marker 기반 gate 설계**: Branch Isolation Check 활성화 조건으로 `docs/GIT-WORKFLOW.md` 존재 여부를 사용하지 않는다. project-specific GIT-WORKFLOW.md를 직접 작성하는 사용자가 의도치 않게 source-gitflow policy를 적용받는 drift가 생기기 때문이다. 대신 명시적 marker를 사용한다. 후보 방식: `docs/GIT-WORKFLOW.md` frontmatter에 `policy_type: source-gitflow` 필드. 이 값이 있을 때만 gate 활성화.
3. **`--workflow` 파라미터 추가**: `create-harness.sh`에 `WORKFLOW_MODE` 변수 추가. `source-gitflow` 선택 시 추가 surface 생성.
4. **Source-gitflow 추가 생성물 정의**: marker 포함 `docs/GIT-WORKFLOW.md` template, branch isolation 포함 full git-workflow, Public Clean Baseline Gate guidance.
5. **Command/skill mirror 정합성 유지**: `work.md` ↔ `workflow-work/SKILL.md`, `close.md` ↔ `workflow-close/SKILL.md` 동기화 필수.
6. **Surface Strategy (source repo live vs template)**:
   - `.claude/rules/git-workflow.md`: 전략 A — `scripts/templates/default/.claude/rules/git-workflow.md` 신규 파일(commit naming/format 전용)을 생성하고 default scaffold 시 이 파일을 복사. **source repo 원본은 수정하지 않음.**
   - `.claude/commands/work.md`, `close.md`, `.agents/skills/workflow-work/SKILL.md`, `workflow-close/SKILL.md`: 전략 B — source repo 파일을 수정해 marker check 로직을 추가. source repo는 `docs/GIT-WORKFLOW.md`에 `policy_type: source-gitflow`를 보유하므로 source repo의 live branch isolation 동작은 유지됨.
   - `docs/GIT-WORKFLOW.md` (source repo): `policy_type: source-gitflow` frontmatter 추가.
   - 전략 최종 확정 후 DR Draft 승격 여부 재판단.

### Scope

#### Default scaffold (현행 generic/spring-boot)

| Surface | 변경 내용 |
|---|---|
| `.claude/rules/git-workflow.md` (scaffold output) | 신규 template 파일(`scripts/templates/default/`)에서 복사. Commit naming/format 규칙만 유지. **source repo 원본 수정 없음** |
| `.claude/commands/work.md` | Branch Isolation Check gate 조건 변경: `docs/GIT-WORKFLOW.md` 존재 여부 → `policy_type: source-gitflow` marker 확인. marker 없으면 건너뜀. **source repo 파일 수정 (전략 B)** |
| `.claude/commands/close.md` | 동일. **source repo 파일 수정 (전략 B)** |
| `.agents/skills/workflow-work/SKILL.md` | 동일. **source repo 파일 수정 (전략 B)** |
| `.agents/skills/workflow-close/SKILL.md` | 동일. **source repo 파일 수정 (전략 B)** |
| `prompts/claude-session-start.md`, `codex-session-start.md`, `cursor-session-start.md` | develop/feature 강제 문구 audit 후 필요 시 수정 |
| `.cursor/rules/*.mdc` | audit 대상. branch isolation 가정 포함 여부 확인. 수정 불필요 시 근거를 Done Criteria에 기록 |

#### Source-gitflow opt-in (`--workflow source-gitflow`)

Default scaffold 생성물에 추가로 생성:

| Surface | 내용 |
|---|---|
| `docs/GIT-WORKFLOW.md` | `policy_type: source-gitflow` frontmatter 포함 template. feature→develop→main 전체 설명 |
| `.claude/rules/git-workflow.md` (scaffold output) | source repo 원본 파일 그대로 복사. Branch Isolation Rule 포함 full 버전 |
| `.claude/commands/work.md` | 전략 B 수정 후 marker check → source-gitflow marker 존재 시 Branch Isolation Check 활성화 |
| `.agents/skills/workflow-work/SKILL.md` | 동일 |
| Public Clean Baseline Gate guidance | `docs/STATUS.md` 또는 `docs/BOOTSTRAP.md`에 반영 |
| pre-commit hook 안내 | optional/manual step 텍스트만. 자동 설치 없음 |
| `develop` branch 생성 안내 | 자동 생성 없음. 안내 텍스트만 |

#### Out of Scope

- pre-commit hook 자동 설치
- `--existing` + `--workflow source-gitflow` 조합 완전 구현 (gate 안내만 추가, 전체 구현은 OQ-4로 defer)
- 기존 archive Work 파일 소급 수정
- Cursor rules 수정 (단, audit은 포함. 수정 불필요 시 근거 기록)

### Files

| 변경 | 파일 | 비고 |
|---|---|---|
| 수정 | `scripts/create-harness.sh` | `--workflow` 파라미터, `WORKFLOW_MODE` 분기, template 선택 로직 |
| **수정 없음** | `.claude/rules/git-workflow.md` (source repo 원본) | scaffold copy 대상 파일만 변경 |
| 수정 | `docs/GIT-WORKFLOW.md` | `policy_type: source-gitflow` frontmatter 추가 |
| 수정 | `.claude/commands/work.md` | gate 로직: marker check (전략 B) |
| 수정 | `.claude/commands/close.md` | 동일 |
| 수정 | `.agents/skills/workflow-work/SKILL.md` | 동일 |
| 수정 | `.agents/skills/workflow-close/SKILL.md` | 동일 |
| 수정 | `prompts/claude-session-start.md` | audit 후 필요 시 |
| 수정 | `prompts/codex-session-start.md` | audit 후 필요 시 |
| 수정 | `prompts/cursor-session-start.md` | audit 후 필요 시 |
| 신규 | `scripts/templates/default/.claude/rules/git-workflow.md` | commit naming/format 전용 minimal 버전 |
| 신규 | `scripts/templates/source-gitflow/docs/GIT-WORKFLOW.md` | marker 포함 full template |

추가 audit 대상 (변경 여부 실행 중 판단):
- `.claude/commands/register.md`, `record-decision.md`, `pick.md`, `resume.md`
- `.cursor/rules/*.mdc` (특히 `workflow.mdc`, `git-commit.mdc`)

### Done Criteria

- [x] `bash -n scripts/create-harness.sh` 통과
- [x] default generic dry-run 출력에 Gitflow/develop/main 강제 문구 없음
- [x] default spring-boot dry-run 출력에 Gitflow/develop/main 강제 문구 없음
- [x] `--workflow source-gitflow` generic dry-run에서 `docs/GIT-WORKFLOW.md` 생성 확인
- [x] `--workflow source-gitflow` spring-boot dry-run에서 동일 확인
- [x] source-gitflow 생성 scaffold의 `work.md`가 branch isolation gate 포함 버전임을 확인
- [x] default 생성 scaffold의 `work.md`/SKILL.md에 "marker 없으면 Branch Isolation skip" 분기가 존재함을 확인
- [x] `work.md` ↔ `workflow-work/SKILL.md` mirror 정합성 확인
- [x] `close.md` ↔ `workflow-close/SKILL.md` mirror 정합성 확인
- [x] pre-commit hook이 어떤 mode에서도 자동 설치되지 않음을 확인
- [x] **source repo 동작 보존**: source repo 자체에서 `docs/GIT-WORKFLOW.md` marker가 유효하고 `work.md` Branch Isolation Check가 정상 동작함을 확인 (develop에서 FAIL, feature/*에서 PASS)
- [x] **Cursor rules audit 결과**: `.cursor/rules/*.mdc` 및 `prompts/cursor-session-start.md`에 branch isolation 강제 문구가 없거나, 있으면 수정 완료. 수정 불필요 시 이 항목에 근거 기록
- [x] `git diff --check` 통과

### Verification

```bash
# ── 1. Syntax check ───────────────────────────────────────────────────────────
bash -n scripts/create-harness.sh

# ── 2. Dry-run (생성 계획 확인, 파일 미생성) ──────────────────────────────────
scripts/create-harness.sh --dry-run default-check
scripts/create-harness.sh --dry-run --workflow source-gitflow source-check
scripts/create-harness.sh --dry-run --profile spring-boot default-sb-check
scripts/create-harness.sh --dry-run --workflow source-gitflow --profile spring-boot source-sb-check

# ── 3. 실제 temp 생성 ─────────────────────────────────────────────────────────
bash scripts/create-harness.sh --profile generic default-check /private/tmp/awh-default-check
bash scripts/create-harness.sh --profile generic --workflow source-gitflow source-check /private/tmp/awh-source-check

# ── 4. Default scaffold 검증 ──────────────────────────────────────────────────

# 4-a. docs/GIT-WORKFLOW.md 미생성 또는 source-gitflow marker 부재 확인
test ! -f /private/tmp/awh-default-check/docs/GIT-WORKFLOW.md \
  && echo "PASS: GIT-WORKFLOW.md 미생성" \
  || { grep -q "policy_type: source-gitflow" /private/tmp/awh-default-check/docs/GIT-WORKFLOW.md \
       && echo "FAIL: source-gitflow marker가 default scaffold에 존재" \
       || echo "PASS: GIT-WORKFLOW.md 있으나 marker 없음"; }

# 4-b. default work.md / workflow-work SKILL.md —
#      guarded 버전이 복사되므로 policy_type 문자열은 존재할 수 있음.
#      확인 기준: marker 없으면 Branch Isolation을 skip한다는 분기/안내가 존재하는지.
#      실제 생성물 문구:
#        "generic mode — Branch Isolation Check 비활성화"  (grep echo 결과)
#        "marker 없음 → generic mode. Branch Isolation Check 건너뜀."  (불릿 설명)
rg -n "generic mode — Branch Isolation Check 비활성화|marker 없음.*건너뜀|Branch Isolation Check 건너뜀" \
  /private/tmp/awh-default-check/.claude/commands/work.md \
  && echo "PASS: skip 분기 존재" \
  || echo "FAIL: skip 경로 안내 없음"
rg -n "generic mode — Branch Isolation Check 비활성화|marker 없음.*건너뜀|Branch Isolation Check 건너뜀" \
  /private/tmp/awh-default-check/.agents/skills/workflow-work/SKILL.md \
  && echo "PASS: SKILL mirror skip 분기 존재" \
  || echo "FAIL: SKILL skip 경로 안내 없음"

# 4-c. user-facing/generated policy 문서에서 source-style 강제 문구 누출 확인
#      guarded implementation surface(.claude/commands/*, .agents/skills/*, .claude/rules/)는 제외.
#      HARNESS-PROTOCOL.md, HARNESS-QUICK-REFERENCE.md는 Gitflow 패턴을 설명 맥락으로 참조하며
#      "scaffold product repo는 project-specific release criteria 적용"을 명시하므로 제외.
AWH_D=/private/tmp/awh-default-check
rg -rn "Public Clean Baseline Gate|feature.*→.*develop|develop.*→.*main|feature/\* →|→ develop\b" \
  "${AWH_D}/docs/STATUS.md" \
  "${AWH_D}/docs/BOOTSTRAP.md" \
  "${AWH_D}/docs/PLAN-SUMMARY.md" \
  "${AWH_D}/docs/GIT-WORKFLOW.md" \
  "${AWH_D}/prompts" \
  "${AWH_D}/.cursor/rules" \
  "${AWH_D}/README.md" \
  2>/dev/null \
  && echo "FAIL: user-facing policy 문서에 source-style 강제 문구 발견" \
  || echo "PASS: user-facing policy 문서에 source-style 강제 문구 없음"

# ── 5. Source-gitflow scaffold 검증 ──────────────────────────────────────────

# 5-a. docs/GIT-WORKFLOW.md에 policy_type: source-gitflow 포함 확인
grep -q "policy_type: source-gitflow" /private/tmp/awh-source-check/docs/GIT-WORKFLOW.md \
  && echo "PASS: source-gitflow marker 존재" \
  || echo "FAIL: marker 없음"

# 5-b. source-gitflow work.md와 workflow-work SKILL.md에 marker check 로직 존재 확인
rg -n "policy_type" /private/tmp/awh-source-check/.claude/commands/work.md \
  && echo "PASS: marker check 로직 확인" \
  || echo "FAIL: marker check 없음"
rg -n "policy_type" /private/tmp/awh-source-check/.agents/skills/workflow-work/SKILL.md \
  && echo "PASS: mirror 정합성 확인" \
  || echo "FAIL: mirror 불일치"

# 5-c. source-gitflow 생성물에서 Branch Isolation Check 경로(develop→FAIL)가 존재하는지 확인
rg -n "develop.*FAIL\|FAIL.*develop\|Branch Isolation" \
  /private/tmp/awh-source-check/.claude/commands/work.md \
  /private/tmp/awh-source-check/.claude/commands/close.md \
  || echo "FAIL: Branch Isolation Check 문구 없음"

# ── 6. Diff check ─────────────────────────────────────────────────────────────
git diff --check

# ── 7. 정리 ──────────────────────────────────────────────────────────────────
rm -rf /private/tmp/awh-default-check /private/tmp/awh-source-check
```

### Risk

| 리스크 | 설명 | 대응 |
|---|---|---|
| Source repo live 동작 파괴 | `work.md`/`close.md`/skill 파일 수정(전략 B) 시 marker check 로직 오류로 source repo branch isolation이 깨질 수 있음 | Done Criteria에 source repo 동작 보존 검증 명시. `docs/GIT-WORKFLOW.md`에 marker를 추가해 source repo가 marker를 보유하도록 유지 |
| Default scaffold용 template 파일 drift | `scripts/templates/default/git-workflow.md`와 source repo `.claude/rules/git-workflow.md`가 서로 다른 commit 주기를 가져 drift 발생 | commit naming/format 섹션은 source repo에서 단방향으로 생성. 변경 시 cascade 확인 |
| Command/skill mirror drift | `work.md`와 `workflow-work/SKILL.md` 변경이 어긋날 경우 Codex/Claude 불일치 | Done Criteria에 mirror 정합성 검증 명시 |
| Marker 오사용 | project-specific GIT-WORKFLOW.md에 실수로 `policy_type: source-gitflow` 추가 시 의도치 않게 gate 활성화 | `policy_type` 필드는 scaffold 생성물에서만 명시적으로 삽입. 일반 사용자가 임의로 추가하지 않도록 GIT-WORKFLOW.md template에 주석 안내 포함 |
| `--workflow` 잘못된 조합 | `--existing` + `--workflow source-gitflow` 시 기존 branch policy 충돌 | gate 안내 텍스트만 추가. 완전 구현은 defer |
| Prompt 잔류 강제 문구 | `*-session-start.md`와 `.cursor/rules/*.mdc`에 develop/feature 강제 문구가 남아 있을 수 있음 | CP-1 audit에서 확인 후 판단 |

### Reversal Cost: Medium

- `--workflow source-gitflow` option 제거 시 create-harness.sh 파라미터 분기만 롤백
- default scaffold branch isolation 제거는 source repo 자체에 영향 없음
- command/skill 변경은 git revert로 복구 가능

### Open Questions

| ID | Question | Default Direction | Status |
|---|---|---|---|
| OQ-1 | option name은 `--workflow source-gitflow`가 적절한가? | Yes | Decided |
| OQ-2 | source-style mode가 `develop` branch 생성을 자동으로 안내해야 하는가? | 안내는 하되 자동 생성 없음 | Decided |
| OQ-3 | pre-commit hook install을 자동화할 것인가? | No. optional/manual step | Decided |
| OQ-4 | `--existing` + `--workflow source-gitflow` 조합 | 가능하되 gate 안내만. 완전 구현 defer | Deferred |

### DR-worthy Decisions (구현 착수 전 확인)

| 결정 | DR-worthy 근거 | 상태 |
|---|---|---|
| Branch Isolation Check는 `docs/GIT-WORKFLOW.md` 존재 여부가 아니라 명시적인 workflow mode/source-gitflow marker(`policy_type: source-gitflow`)에 의해 활성화한다 | 복수 command/skill/rule surface 영향, reversal cost Medium, project-specific GIT-WORKFLOW.md와의 충돌 방지 정책 | DR Draft 대상 |
| source-gitflow template을 `scripts/templates/` 별도 directory로 관리 (전략 A/B 선택 포함) | scaffold 구조 아키텍처 결정 — 구현 중 확장성/rollback 비용 확인 후 확정 | **보류**: 구현 중 확정 후 DR Draft 승격 여부 재판단 |

---

## Checkpoints

### CP-1: Default scaffold audit 완료

- [x] 모든 `.claude/commands/*.md`에서 branch isolation 가정 audit 완료
- [x] 모든 `.agents/skills/workflow-*/SKILL.md`에서 동일 audit 완료
- [x] `prompts/claude-session-start.md`, `codex-session-start.md`, `cursor-session-start.md` audit 완료
- [x] `.cursor/rules/*.mdc` audit 완료 — 수정 불필요. 근거: Discovery CP-1 항목 참조

### CP-2: git-workflow.md 분리 완료

- [x] `scripts/templates/default/.claude/rules/git-workflow.md` (commit naming/format 전용 minimal 버전) 생성
- [x] `docs/GIT-WORKFLOW.md` (source repo)에 `policy_type: source-gitflow` frontmatter 추가
- [x] `create-harness.sh`에서 default/source-gitflow 별 template 선택 분기 반영

### CP-3: Marker 기반 gate 구현 완료

- [x] `work.md` — `policy_type: source-gitflow` marker check 로직 추가. marker 없으면 Branch Isolation Check 건너뜀
- [x] `close.md` — 동일
- [x] `workflow-work/SKILL.md`, `workflow-close/SKILL.md` mirror 동기화
- [x] source repo에서 marker → FAIL 정상 동작, default scaffold에서 marker 없음 → 건너뜀 확인

### CP-4: source-gitflow template 생성 완료

- [x] `scripts/templates/source-gitflow/docs/GIT-WORKFLOW.md` 작성 (scaffold-safe, source-repo-only 참조 제거)
- [x] `create-harness.sh --workflow source-gitflow` dry-run 검증 (사용자 직접 실행)
- [x] Done 메시지에 `workflow: ${WORKFLOW_MODE}` 추가
- [x] create-harness.sh source-gitflow extras가 신규 scaffold-safe template 경로 사용

### CP-5: 전체 Done Criteria 통과

- [x] Done Criteria 전체 체크 (2026-05-27 — 사용자 직접 실행 결과 + agent rg/syntax 체크로 전항목 확인)

---

## Discovery

착수 전 사전 audit (2026-05-27):

- `create-harness.sh` line 215에서 `.claude/rules/git-workflow.md`를 모든 profile에 동일하게 복사. Branch Isolation Rule, Protected file 목록, PR Base Rule 포함.
- `create-harness.sh` line 224-226에서 `.claude/commands/*.md` 전체 복사. `work.md`/`close.md`의 Branch Isolation Check(develop/main → FAIL)가 default scaffold에 포함됨.
- `create-harness.sh` line 229-232에서 `.agents/skills/*/SKILL.md` 전체 복사. `workflow-work`, `workflow-close` SKILL.md에 동일 check 포함.
- 결론: default scaffold에서 trunk-based 또는 GitHub Flow 프로젝트는 `/work`, `/close` 실행 시 항상 FAIL을 받게 됨. 즉각 수정 필요.

CP-1 Cursor/Prompt audit (2026-05-27):

- `.cursor/rules/workflow.mdc`: branch merge intent 안내가 "if this repository has `docs/GIT-WORKFLOW.md`, load it... Otherwise, check the project-specific branch/release policy first" 조건부 언어로 이미 작성됨. **수정 불필요.**
- `.cursor/rules/git-commit.mdc`, `execution.mdc`: branch isolation 강제 문구 없음. CI trigger 설명과 commit approval 규칙만 포함. **수정 불필요.**
- `prompts/claude-session-start.md`, `codex-session-start.md`, `cursor-session-start.md`: develop/feature 강제 문구 없음. **수정 불필요.**

4-c rg 검증 범위 결정 (2026-05-27):

- `docs/HARNESS-PROTOCOL.md`, `docs/HARNESS-QUICK-REFERENCE.md`는 Gitflow 패턴(`develop → main`)을 설명 맥락에서 참조하며, "scaffold product repo는 project-specific release criteria 적용"을 명시함. policy 강제 아님.
- 4-c 검증 대상을 HARNESS-PROTOCOL.md, HARNESS-QUICK-REFERENCE.md에서 제외하고 README, BOOTSTRAP, STATUS, PLAN-SUMMARY, GIT-WORKFLOW, prompts, .cursor/rules로 제한함. 이 범위에서 source-style 강제 문구 없음 확인.

구현 완료 (2026-05-27):

- `docs/GIT-WORKFLOW.md`에 `policy_type: source-gitflow` frontmatter 추가 (source repo 및 source-gitflow scaffold 활성화)
- `.claude/commands/work.md`, `close.md`: Branch Isolation Check/확인을 marker 기반 gate로 변경
- `.agents/skills/workflow-work/SKILL.md`, `workflow-close/SKILL.md`: 동일 (mirror 정합성 확인)
- `scripts/create-harness.sh`: `--workflow` 파라미터 추가, git-workflow.md 분기 로직, source-gitflow extras 블록, Done 메시지에 `workflow: ${WORKFLOW_MODE}` 추가
- `scripts/templates/default/.claude/rules/git-workflow.md`: minimal 버전 신규 생성 (commit naming/format 전용, branch isolation 없음)
- `scripts/templates/source-gitflow/docs/GIT-WORKFLOW.md`: 신규 생성 — scaffold-safe, source-repo-only 참조(HRN-FUT-004, `.github/workflows/ci.yml`, `tools/git-hooks`, `HARNESS-MAINTAINER-GUIDE`) 제거, §6 hook 문구 "자동 설치하지 않으며, 필요하면 project-specific hook으로 별도 정의"로 정리, `create-harness.sh`가 source repo 원본 대신 이 template을 사용하도록 변경

문서 현행화 (2026-05-27):

- `README.md` §10: `--workflow source-gitflow` 예시 추가, `--profile`/`--workflow` 역할 분리 설명 추가
- `docs/WORKFLOW-MANUAL.md`: Quick Start intro에 `--workflow` 옵션 설명 추가, 케이스 A 코드블록에 source-gitflow 예시 추가, 포함 파일 표에 `docs/GIT-WORKFLOW.md` 조건부 행 추가, `--workflow source-gitflow` 추가 포함 섹션 추가
- `docs/HARNESS-MAINTAINER-GUIDE.md`: Validation 표와 §6 Scaffold Development에 source-gitflow dry-run 예시 추가
- `docs/SCAFFOLD-ONBOARDING-GUIDE.md`, `docs/SCAFFOLD-BOOTSTRAP.md`: `GIT-WORKFLOW.md` 참조 없음 — 변경 불필요

검증 결과 (2026-05-27, 사용자 직접 실행 + agent rg/syntax 체크):

- `bash -n scripts/create-harness.sh`: pass
- default/source-gitflow generic dry-run: pass (사용자 직접 확인)
- default/source-gitflow spring-boot dry-run: pass (사용자 직접 확인)
- default/source-gitflow 실제 생성 (검증 경로 예시: `/private/tmp/awh-default-check`, `/private/tmp/awh-source-check`): pass (사용자 직접 확인)
- default 생성물에 `docs/GIT-WORKFLOW.md` 없음: pass
- source-gitflow 생성물에 `policy_type: source-gitflow` 있음: pass
- source-gitflow `GIT-WORKFLOW.md`에서 source-only 참조 없음 (HRN-FUT, `tools/git-hooks`, `pre-commit`, `.github/workflows`, `scripts/create-harness.sh`): pass (rg 확인)
- `git diff --check`: pass
- Verification 4-b rg pattern — 실제 생성물 문구(`generic mode — Branch Isolation Check 비활성화`, `marker 없음.*건너뜀`)와 정합하도록 수정 완료
