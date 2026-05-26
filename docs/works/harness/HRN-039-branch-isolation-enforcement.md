---
id: HRN-039
priority: P1
status: Active
risk: L2
scope: Git/branch isolation enforcement — develop/main 직접 수정 방지, release promotion gate 강화
appetite: 1d
planned_start: 2026-05-28
planned_end: 2026-05-28
actual_end:
related_dr: []
related_commits: []
related_troubleshooting: []
---

# HRN-039: Git/Branch Isolation Enforcement

## Context

오늘(2026-05-27) HRN-036/037 변경이 의도보다 빠르게 main까지 merge되었다.
작업별 feature branch 분리 원칙을 세웠지만, develop/main 직접 수정이나
main 조기 promotion을 막는 gate가 weak하다.

`temp/work-plans/02-id-rule-registration-policy.md`에 branch isolation enforcement
후보가 정리되어 있으나, ID rule 전체보다 Git/branch enforcement를 먼저 분리해서 처리한다.

현재 `tools/git-hooks/pre-commit`은 diff hygiene과 shell syntax만 검사한다.
`.claude/rules/git-workflow.md`와 skills/commands에는 branch 위치를 확인하는 gate가 없다.

## Problem Statement

| 문제 | 영향 |
| --- | --- |
| develop/main에서 직접 tracking/workflow 파일 수정 가능 | 작업별 feature branch 원칙 형식화 위험 |
| main promotion이 release-ready 여부와 무관하게 진행 가능 | public snapshot 오염 |
| hotfix/patch 예외 절차가 명시되지 않음 | 긴급 상황에서 임시방편 처리 |
| AI tool commit gate에 branch check 없음 | 실수 방지 불가 |
| pre-commit hook에 branch check 없음 | AI 우회 시 최후 방어선 없음 |

## Goal

- develop/main에서 protected files 직접 수정을 AI rule FAIL + hook warning으로 이중 차단한다.
- feature/hotfix 예외를 명확히 정의하고 절차화한다.
- release promotion(develop → main)은 Public Clean Baseline Gate 통과 후에만 수행하도록 강화한다.

## Scope

### In Scope

- `docs/GIT-WORKFLOW.md` — §0 Branch Isolation Rule 신규 섹션
- `docs/AGENT-WORKFLOW.md` — Session Startup branch isolation awareness 1줄
- `.claude/rules/git-workflow.md` — commit gate에 branch check MUST 추가
- `.agents/skills/workflow-work/SKILL.md` — Pre-check에 Branch Isolation Check 추가
- `.claude/commands/work.md` — 동일 mirror
- `.agents/skills/workflow-done/SKILL.md` — commit gate에 branch check 추가
- `.claude/commands/done.md` — 동일 mirror
- `.agents/skills/workflow-close/SKILL.md` — commit 전략 안내 전 branch check 추가
- `.claude/commands/close.md` — 동일 mirror
- `tools/git-hooks/pre-commit` — develop/main protected file staging warning 추가 (merge commit 면제)

### Out Of Scope

- Work/OQ/DR ID rule 변경 (`temp/02` 후반부 — 후속 Work로 분리)
- Hook hard block 전환 (OQ-2, 운영 안정화 후 검토)
- Scaffold protected branch 오버라이드 (`GITFLOW_PROTECTED_BRANCHES`, OQ-3)

## Protected Files

develop 또는 main에서 직접 staged 금지 대상:

| 범주 | 경로 |
| --- | --- |
| Workflow/status tracking | `docs/STATUS.md`, `docs/backlog/**`, `docs/works/**`, `docs/decisions/**` |
| AI entrypoint | `AGENTS.md`, `CLAUDE.md` |
| Canonical workflow | `docs/AGENT-WORKFLOW.md`, `docs/HARNESS-PROTOCOL.md`, `docs/HARNESS-QUICK-REFERENCE.md`, `docs/GIT-WORKFLOW.md` |
| Tool surface | `.claude/commands/*.md`, `.claude/rules/*.md`, `.cursor/rules/*.mdc`, `.agents/skills/**`, `prompts/**` |
| Scaffold | `scripts/create-harness.sh` |

## Allowed Exceptions

| 예외 유형 | Branch | 조건 |
| --- | --- | --- |
| Release sync | `develop` | merge commit 한정 (`.git/MERGE_HEAD` 존재). 파일 직접 편집 아님 |
| Emergency hotfix | `hotfix/*` | 사용자 명시 승인 후. main 직접 수정 금지 — `hotfix/*` branch 먼저 생성 |
| Read-only validation | any | staged 없음. inspection/rg/diff만 수행 |
| Release prepare | `develop` | OQ-1 해소 전까지 별도 feature branch 권장 |

## Proposed Design

### Hard Block vs Warning + Approval

| Approach | Pro | Con | 채택 |
| --- | --- | --- | --- |
| AI rule FAIL state | workflow 내 강제, 오탐 없음 | AI 우회 시 무효 | ✅ Primary |
| Hook warning (exit 0) | merge commit 면제 가능, 오탐 없음 | 의지 약하면 무시 가능 | ✅ Secondary |
| Hook hard block (exit 1) | 완전 방지 | merge commit 오탐, 절차 복잡화 | OQ-2로 보류 |

**Two-tier 채택:** AI FAIL (primary) + hook warning exit 0 (secondary)

### docs/GIT-WORKFLOW.md 신규 §0 섹션 구조

```
## 0. Branch Isolation Rule

작업 유형에 따른 branch 분기:
- 일반 작업: feature/* (항상)
- 긴급 수정: hotfix/* (main 기준, 명시 승인 필요)
- 운영 보정: chore/* 또는 feature/* (STATUS/tracking 포함)

Protected files: (위 목록)
Allowed exceptions: (위 표)
```

### AI Rule / Skill Branch Check 표현 (예시)

```
Before committing, check current branch:
- If branch is `develop` or `main` AND protected files are staged:
  → FAIL. Report: which files, which branch.
  → Propose: create feature/* or hotfix/* branch and move changes.
- Exception: merge commit (.git/MERGE_HEAD exists) → skip check.
```

### pre-commit hook warning 예시

```sh
BRANCH=$(git branch --show-current 2>/dev/null || echo "")
if [ -f ".git/MERGE_HEAD" ]; then
  : # merge commit — skip branch check
elif [ "$BRANCH" = "develop" ] || [ "$BRANCH" = "main" ]; then
  PROTECTED=$(echo "$STAGED_FILES" | grep -E \
    "^(AGENTS\.md|CLAUDE\.md|docs/STATUS\.md|docs/backlog/|docs/works/|docs/decisions/|docs/AGENT-WORKFLOW\.md|docs/HARNESS-PROTOCOL\.md|docs/HARNESS-QUICK-REFERENCE\.md|docs/GIT-WORKFLOW\.md|\.claude/commands/|\.claude/rules/|\.cursor/rules/|\.agents/skills/|prompts/|scripts/create-harness\.sh)" \
    || true)
  if [ -n "$PROTECTED" ]; then
    echo "WARNING: Committing protected workflow files directly on '$BRANCH'."
    echo "Consider using a feature/* or hotfix/* branch instead."
    echo "Affected files:"
    echo "$PROTECTED" | sed 's/^/  /'
    # exit 0 intentional — warning only
  fi
fi
```

### Scaffold Applicability

모든 변경 파일이 `adapt "${TEMPLATE_ROOT}/..."` 방식으로 복사 → scaffold 적용 repo에 자동 반영.
hook의 protected branch 이름(`develop`, `main`)은 단기 Gitflow 하드코딩 허용.
비 Gitflow repo 대응은 OQ-3으로 보류.

## Plan

### Step 1 — Canonical 정의

- `docs/GIT-WORKFLOW.md`에 §0 Branch Isolation Rule 추가
- `docs/AGENT-WORKFLOW.md` Session Startup MUST에 branch isolation awareness 1줄 추가

### Step 2 — AI rule commit gate 보강

- `.claude/rules/git-workflow.md` — Commit Approval에 branch check MUST 추가

### Step 3 — workflow-work pre-check 추가

- `.agents/skills/workflow-work/SKILL.md` Pre-check §4 Branch Isolation Check 추가
- `.claude/commands/work.md` 동일 mirror

### Step 4 — workflow-done / workflow-close commit gate 추가

- `.agents/skills/workflow-done/SKILL.md` commit gate에 branch check 추가
- `.claude/commands/done.md` 동일 mirror
- `.agents/skills/workflow-close/SKILL.md` commit 전략 안내 전 branch check 추가
- `.claude/commands/close.md` 동일 mirror

### Step 5 — pre-commit hook 보강

- `tools/git-hooks/pre-commit` — develop/main + protected files staged → warning (exit 0), merge commit 면제

### Step 6 — Validation

```bash
# 잔여 stale reference 없음
rg "branch isolation|protected branch" docs .claude .agents prompts
# syntax
git diff --check
bash -n tools/git-hooks/pre-commit
# scaffold
bash -n scripts/create-harness.sh
```

## Done Criteria

- [ ] `docs/GIT-WORKFLOW.md` §0 Branch Isolation Rule 섹션 추가 — protected files, 예외, feature/hotfix 절차 명시.
- [ ] `docs/AGENT-WORKFLOW.md` Session Startup에 branch isolation awareness 반영.
- [ ] `.claude/rules/git-workflow.md` commit gate에 branch isolation MUST 추가.
- [ ] `workflow-work/SKILL.md` + `work.md` Pre-check에 Branch Isolation Check 추가.
- [ ] `workflow-done/SKILL.md` + `done.md` commit gate에 branch check 추가.
- [ ] `workflow-close/SKILL.md` + `close.md` commit 전략 안내 전 branch check 추가.
- [ ] `tools/git-hooks/pre-commit` develop/main warning 추가 (merge commit 면제 포함).
- [ ] scaffold 영향 확인 완료.
- [ ] Verification 시나리오 5종 통과.
- [ ] `git diff --check`, `bash -n tools/git-hooks/pre-commit`, `bash -n scripts/create-harness.sh` 통과.

## Open Questions

| ID | Question | Decision Needed |
| --- | --- | --- |
| OQ-1 | develop→main PR 직전 `docs/STATUS.md` Last Updated 수정을 develop 직접 허용할지, 별도 feature로 강제할지 | 운영 편의 vs 원칙 일관성 |
| OQ-2 | hook warning → hard block 전환 시점 기준 | 운영 안정화 후 결정 |
| OQ-3 | scaffold 적용 repo의 protected branch 이름 오버라이드 필요 여부 | 비 Gitflow repo 도입 시 결정 |

## Checkpoints

| CP | Description | Status |
| --- | --- | --- |
| CP-1 | Work 파일 작성 및 착수 등록 | Done |
| CP-2 | Canonical + AI rule + skill/command 패치 (Step 1~4) | Pending |
| CP-3 | Hook 보강 + Validation (Step 5~6) | Pending |

## Discovery

- 2026-05-27: HRN-036/037 변경이 의도보다 빠르게 main까지 반영되면서 branch isolation gate 부재가 명확히 드러남. `temp/02` 초안의 branch isolation enforcement 부분을 별도 HRN-039로 승격.
