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
| feature branch pre-PR | `git branch --show-current`가 `feature/*` 패턴이고 `git log develop..HEAD`에 commit이 존재 | 번들 권장 — 마지막 work commit에 포함 제안 |
| develop/main 직접 작업 | 현재 branch가 develop 또는 main | 별도 close commit (현행 유지) |
| feature branch post-merge | feature branch지만 develop과 동기화된 상태 | 별도 close commit (현행 유지) |
| 감지 불가 또는 git 없음 | branch 정보를 확인할 수 없음 | 별도 close commit (현행 유지) |

### 번들 안내 문구 (feature pre-PR 감지 시)

```
현재 feature branch에서 아직 develop에 merge되지 않은 상태입니다.
close state 변경(Work Done, Work Index, STATUS pointer)을 마지막 work commit에
번들하면 PR history가 더 깔끔해집니다.

[권장] 마지막 work commit에 번들 — git add + git commit --amend로 포함
[대안] 별도 close commit 생성 (현행 방식)

어떻게 진행하시겠습니까?
```

### 주의사항

- `--amend`는 이미 push된 commit에는 위험하다. 번들 안내 시 "아직 push하지 않은 경우에만 --amend 권장"을 함께 안내한다.
- push된 경우에는 별도 close commit을 기본으로 안내한다.

## Plan

### Step 1 - 현행 분석

- `.claude/commands/close.md` 번들 섹션 현문구 확인 (이미 읽음)
- `.agents/skills/workflow-close/SKILL.md` 번들 섹션 현문구 확인 (이미 읽음)
- 세 시나리오의 감지 명령 확인: `git branch --show-current`, `git log develop..HEAD --oneline`

### Step 2 - Patch

- `.claude/commands/close.md`: 번들 섹션을 "시나리오별 기본 안내"로 교체
- `.agents/skills/workflow-close/SKILL.md`: 동일 변경 mirror

### Step 3 - Validation

세 시나리오 문서 기준 시뮬레이션:

1. feature branch pre-PR, 미push — 번들 권장 안내 확인
2. feature branch pre-PR, 이미 push — 별도 commit 안내 확인
3. develop 직접 작업 — 별도 commit 안내 확인 (현행 유지)

```bash
git diff --check
```

## Done Criteria

- [ ] feature branch pre-PR(미push) 시 `/close`가 번들을 기본으로 안내한다.
- [ ] feature branch pre-PR(push됨) 시 별도 close commit을 안내한다.
- [ ] develop/main 직접 작업 시 별도 close commit을 안내한다 (현행 유지).
- [ ] `.agents/skills/workflow-close/SKILL.md` mirror 정렬 완료.
- [ ] 세 시나리오 시뮬레이션 통과.

## Open Questions

| ID | Question | Decision Needed |
| --- | --- | --- |

## Checkpoints

| CP | Description | Status |
| --- | --- | --- |
| CP-1 | Work 파일 작성 및 plan 승인 | In Progress |
| CP-2 | close.md + SKILL.md patch | Pending |
| CP-3 | 시나리오 시뮬레이션과 검증 | Pending |

## Discovery

- 2026-05-26: HRN-036 /close 실행 시 feature branch pre-PR에서 별도 close commit이 생성되어 PR에 노이즈 발생. STATUS.md 변경이 실질 변경 commit 이후 별도 분리 — HARNESS-PROTOCOL.md "STATUS.md는 실질 변경과 같은 commit" 규칙과 불일치.
- 2026-05-26: --amend는 push 여부에 따라 위험할 수 있어 감지 조건에 push 여부도 포함해야 한다.
