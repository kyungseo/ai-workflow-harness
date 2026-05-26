---
id: HRN-037
priority: P2
status: Active
risk: Low
scope: /close command bundle default improvement for feature branch pre-PR scenario
appetite: 0.25d
planned_start: 2026-05-26
planned_end: 2026-05-26
actual_end:
related_dr: []
related_commits: []
related_troubleshooting: []
---

# HRN-037: /close 번들 기본값 개선

## Context

HRN-036 작업 중 `/close`를 feature branch에서 PR merge 전에 실행했을 때 별도 close commit이 생성되어 PR에 work commit + close commit + backlog commit 3개가 담겼다.

현재 `/close` command의 번들 옵션은 "사용자가 명시적으로 번들 요청 시에만 적용"이 기본값이다.
그러나 feature branch pre-PR 시나리오에서는 close state 변경(Work Done, Work Index, STATUS pointer 제거)을 별도 commit으로 분리하는 것이 git history noise가 된다.

하네스 프로토콜에는 "STATUS.md 변경은 실질 변경과 같은 commit에 포함한다"는 규칙이 있는데, 현재 `/close` 기본값이 이 방향과 맞지 않는다.

## Risk And Mode

- 위험도: L2
- 실행 모드: Standard Work (command surface 변경)
- 이유: `.claude/commands/close.md`와 `.agents/skills/workflow-close/SKILL.md`는 harness tool surface다.

## Problem Statement

현재 `/close`의 번들 섹션:

```
[옵션] close 상태 변경을 마지막 작업 커밋에 번들하기
- 적용 시점: 마지막 작업 커밋 직전 + 사용자가 명시적으로 번들 요청 시
- 기본값: 별도 close 커밋
```

이 기본값은 develop/main에서 직접 작업하거나 feature가 이미 merge된 뒤 /close를 실행하는 경우에는 맞다.
그러나 **feature branch에서 아직 develop에 merge되지 않은 상태(pre-PR)**로 /close를 실행하면:

1. close state 변경이 별도 commit이 된다.
2. PR에 "work commit + close commit"이 나뉘어 들어가 git history가 지저분해진다.
3. STATUS.md 변경이 실질 변경 commit 이후 별도 commit으로 분리된다 — 하네스 프로토콜 방향과 불일치.

## Goal

`/close`는 lifecycle finalization gate이며, 이번 변경 범위는 그 안의 commit 전략 안내(번들 vs 별도 commit)에 한정한다.

`/close` command가 현재 context(feature branch pre-PR vs. 기타)를 판단하여 번들 여부를 **기본값으로 안내**하도록 개선한다.

자동으로 번들을 강제하는 것이 아니라, 상황에 맞는 기본값을 먼저 제시하고 사용자가 조정할 수 있게 한다.

## Scope

### In Scope

- `.claude/commands/close.md` — 번들 섹션 기본값 및 감지 조건 개선
- `.agents/skills/workflow-close/SKILL.md` — 동일 변경 mirror

### Out Of Scope

- 번들 자동 실행 (사용자 확인 없는 자동화)
- commit 내용 자동 수정
- PR 생성 자동화

## Proposed Design

### 시나리오별 기본 안내

| 시나리오 | 감지 조건 | 기본 안내 |
| --- | --- | --- |
| feature branch, 미push | `feature/*` + `git log develop..HEAD` 있음 + `git rev-parse --verify --quiet "origin/<branch>"` 실패 (remote branch 없음) | 번들(amend) 권장 — 마지막 work commit에 포함 제안 |
| feature branch, push됨, PR 없음 | push됨 + `gh pr list --head <branch>` 결과 없음 (optional check) | 사용자 선택 유도 — amend 가능하나 신중 안내 |
| feature branch, PR 열림/공유/확인 불가 | PR 개설 확인됨 OR 공유 branch (사용자 확인) OR gh 실패/미설치 | 별도 close commit 또는 squash merge 권장 |
| develop/main 직접 작업 | 현재 branch가 develop 또는 main | 별도 close commit (현행 유지) |
| 감지 불가 또는 git 없음 | branch 정보를 확인할 수 없음 | 별도 close commit (현행 유지) |

### gh optional detection

`gh pr list --head <branch>`는 선택적 보조 감지다.

- gh CLI가 없거나 네트워크 실패 시 → "PR opened 여부 확인 불가" 상태로 fallback
- fallback 시 별도 close commit을 기본으로 안내하거나, 사용자에게 push/PR/공유 여부를 직접 확인하도록 요청한다
- gh 실패는 validation failure가 아니다 — 안전한 기본값으로 이동하는 감지 불가 fallback이다

"공유 branch" 여부는 git 상태만으로 안정적으로 자동 감지할 수 없다. 번들 안내 전 사용자 확인 항목으로 다룬다.

### 번들 안내 문구 예시

미push 감지 시:
```
현재 feature branch에서 아직 push되지 않은 상태입니다.
close state 변경(Work Done, Work Index, STATUS pointer)을 마지막 work commit에
번들하면 PR history가 더 깔끔해집니다.

[권장] 마지막 work commit에 번들 — git add + git commit --amend로 포함
[대안] 별도 close commit 생성

어떻게 진행하시겠습니까?
```

PR 열림/공유/확인 불가 시:
```
이미 push되었거나 PR이 열려 있거나 공유 branch일 수 있는 상태입니다.
--amend는 위험할 수 있으므로 별도 close commit 또는 squash merge를 권장합니다.

[권장] 별도 close commit 생성
[대안] PR merge 시 Squash merge로 정리

어떻게 진행하시겠습니까?
```

## Plan

### Step 1 - 현행 분석

- `.claude/commands/close.md` 번들 섹션 현문구 확인 (이미 읽음)
- `.agents/skills/workflow-close/SKILL.md` 번들 섹션 현문구 확인 (이미 읽음)
- 세 시나리오의 감지 명령 확인: `git branch --show-current`, `git log develop..HEAD --oneline`

### Step 2 - Patch

- `.claude/commands/close.md`: 번들 섹션을 "시나리오별 기본 안내"로 교체
- `.agents/skills/workflow-close/SKILL.md`: 동일 변경 mirror

### Step 3 - Validation

5개 케이스 문서 기준 시뮬레이션:

1. feature branch, 미push (remote branch 없음) — 번들(amend) 권장 안내 확인
2. feature branch, push됨, PR 없음 (gh 성공, 빈 결과) — 사용자 선택 유도 안내 확인
3. feature branch, push됨, PR 열림 (gh 성공, PR 확인) — 별도 close commit 또는 squash merge 권장 확인
4. feature branch, push됨, gh 실패/미설치 — 감지 불가 fallback, 사용자 직접 확인 요청 확인
5. develop 직접 작업 — 별도 close commit 안내 확인 (현행 유지)

```bash
git diff --check
```

## Done Criteria

- [ ] feature branch 미push 시 `/close`가 번들(amend)을 기본으로 안내한다.
- [ ] feature branch push됨, PR 없음 시 사용자 선택을 유도한다 (amend 가능하나 신중 안내).
- [ ] PR opened/shared branch/확인 불가 시 amend 대신 별도 close commit 또는 squash merge를 안내한다.
- [ ] develop/main 직접 작업 시 별도 close commit을 안내한다 (현행 유지).
- [ ] `.agents/skills/workflow-close/SKILL.md` mirror 정렬 완료.
- [ ] 5개 케이스 시뮬레이션 통과 (미push / push+PR없음 / push+PR열림 / gh실패 / develop직접).

## Open Questions

| ID | Question | Decision Needed |
| --- | --- | --- |

## Checkpoints

| CP | Description | Status |
| --- | --- | --- |
| CP-1 | Work 파일 작성 및 plan 승인 | Done |
| CP-2 | close.md + SKILL.md patch | Done |
| CP-3 | 시나리오 시뮬레이션과 검증 | Done |

## Discovery

- 2026-05-26: HRN-036 /close 실행 시 feature branch pre-PR에서 별도 close commit이 생성되어 PR에 노이즈 발생. STATUS.md 변경이 실질 변경 commit 이후 별도 분리 — HARNESS-PROTOCOL.md "STATUS.md는 실질 변경과 같은 commit" 규칙과 불일치.
- 2026-05-26: --amend는 push 여부에 따라 위험할 수 있어 감지 조건에 push 여부도 포함해야 한다.

## Codex Review Opinion

2026-05-26 Codex 검토 의견:

- HRN-037을 AGENTS.md thin entrypoint 정비와 ID rule 정비보다 먼저 처리하는 순서에 동의한다. `/close`의 commit/PR 단위 기준이 흔들리면 이후 Work 단위 feature 운영 규칙도 계속 애매해진다.
- 계획의 핵심 방향인 "feature branch pre-PR에서는 close state 변경을 마지막 work commit에 번들하도록 기본 안내"는 타당하다. 다만 "STATUS.md 변경은 실질 변경과 같은 commit" 규칙을 모든 `/close`에 기계적으로 적용하면 과하다. 이 규칙은 별도 follow-up commit으로 STATUS만 늦게 처리하는 것을 막는 취지로 해석하고, `/close` finalization 전체를 항상 실질 commit에 강제 번들하는 규칙으로 확장하지 않는 편이 안전하다.
- 시나리오 구분은 유지하되 `push 여부`만으로 결정하지 말고 `PR 생성 여부`와 `remote 공개 여부`를 함께 고려하는 문구가 필요하다. 이미 push되었더라도 아직 PR 전이고 history rewrite가 허용되는 개인 feature라면 amend/squash 제안이 가능할 수 있다. 반대로 PR이 열렸거나 협업자가 볼 수 있는 branch라면 별도 close commit 또는 squash merge 안내가 더 안전하다.
- "feature branch post-merge" 감지는 주의가 필요하다. local branch가 develop과 동기화되어 보여도 실제 PR merge 완료 여부를 git만으로 항상 안전하게 판단하기 어렵다. command 문구는 자동 판정보다 "감지 결과를 근거로 권장안을 제시하고 사용자가 선택"하는 방식이 맞다.
- `/close`의 실효성은 아직 있다. 다만 실효성의 중심은 commit 생성이 아니라 Done Criteria 확인, Work frontmatter `Done` 처리, Work Index 이동, STATUS Active pointer 제거 제안, archive 보류/처리 판단이다. 따라서 HRN-037은 `/close`를 약화하거나 제거하는 방향이 아니라, `/close`가 lifecycle finalization gate이고 commit 전략은 별도 gate라는 점을 더 명확히 해야 한다.
- close commit을 항상 금지하는 규칙은 반대한다. work가 이미 develop에 merge된 뒤 사후 `/close`하는 경우, develop/main 직접 작업인 경우, 또는 amend가 위험한 경우에는 별도 close commit/PR이 자연스럽다. 기본값만 "feature branch pre-PR에서는 번들 우선"으로 바꾸는 것이 적절하다.
- Done Criteria에는 세 번째 시나리오에 더해 "PR opened/shared branch에서는 amend 대신 별도 close commit 또는 squash merge 안내"가 포함되면 좋다. 이 케이스가 빠지면 `--amend` 위험을 충분히 줄이지 못한다.
