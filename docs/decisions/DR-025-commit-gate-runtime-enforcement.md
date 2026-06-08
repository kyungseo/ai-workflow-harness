# DR-025: Commit Gate Runtime Enforcement

Date: 2026-06-06
Status: Accepted

부모: DR-024 (Gate Strictness 2D Taxonomy). 이 DR은 DR-024가 child DR로 분리한 **causal finalization bundling의 commit gate runtime enforcement** 정책을 결정한다. **decision-only** — 실제 hook/config/CI/scaffold 구현은 downstream(`gate-enforcement-runtime-and-env`)에 위임한다.

## Question

DR-024는 causal finalization bundling(실질 변경 + Work Done/STATUS/tracker 변경을 같은 commit에 묶기)을 `conditional mandatory + hard-stop/explicit override`로 **분류**만 했다. 실제 런타임 정책 — **무엇이 대상인가, hard-stop을 언제 띄우나(OQ-14 예외), override를 어떻게 하나, 누가 집행하나** — 은 미정이다. 현행 규칙은 `.claude/rules/git-workflow.md`(same-commit prose)와 `skills/workflow/work-close.md`(push 기반 3-state 안내)에 흩어져 있어 drift 위험이 구조적으로 남는다.

## Decision

### 1. 적용 대상 (무엇을 묶나)

bundling gate는 **conditional**이다. 대상 = **`T15` STATUS Finalization + `T16` Tracking Finalization 산출물**(Work Done, STATUS, Work index, backlog, DR tracker)을 포함한 commit. state 변경 없는 순수 코드/문서 commit과 L1 Quick Mode(Work 파일 없음)는 대상이 아니다.

### 2. Context Applicability (N/A 판정이 먼저)

아래 context에서는 gate가 **Not Applicable**이며, 그 다음에야 §3 판정을 적용한다.

- git repository 없음 또는 `docs/BOOTSTRAP.md` §0 미완 → commit/PR 검증 자체가 N/A.
- generic(비-PR) 프로젝트 → push/PR 분기 N/A, 로컬 "same commit"만.
- no-remote → push/PR state N/A.
- bootstrap 다수 setup 편집 중 → DR-024 bootstrap gate(완화) 적용, bundling hard-stop 비강제.

### 3. Exception Judgment (OQ-14) — local-only 증명 기준

판정 기준은 "branch가 push됐나"가 아니라 **"amend 대상 commit을 안전하게 local-only로 고칠 수 있음을 증명할 수 있나"**다. **핵심 원칙(default-safe): local-only임을 확실히 증명할 수 없으면 hard-stop하지 않고 degrade한다.**

| 판정 | 조건 | Enforcement |
| --- | --- | --- |
| **provably local-only** | HEAD가 어떤 remote ref로도 push되지 않았음이 확실 + rebase/merge/cherry-pick 미진행 + detached HEAD 아님 | **hard-stop** — finalization 분리 시 중단(같은 commit 번들 또는 `--amend`) |
| **published / 공유됨** | HEAD push됨, PR open, shared branch | **report-only** — 별도 state-only finalization commit 허용(amend가 published history 재작성이라 금지) |
| **불확실 / 위험** | detached HEAD, rebase/merge/cherry-pick 진행 중, fork PR·no push rights·upstream mismatch, remote branch 있으나 HEAD만 unpushed, **force-push 가능한 shared branch** | **warning** — 분리 허용 + 사유 기록. local-only 증명 불가 → hard-stop 금지 |

force-push 가능 shared branch는 기술적으로 amend 가능하나 협업자 history를 깨므로 hard-stop 대상이 아니라 "불확실/위험"(warning)으로 둔다.

### 4. Override

override는 silent 통과가 아니라 **durable record가 남는 기록된 예외**여야 한다. `git --no-verify`는 모든 hook(whitespace 포함)을 우회하는 coarse override라 부적합하고, env var 단독은 commit에 기록이 남지 않아 부적합하다. **preferred form = commit-trailer sentinel** — 예: `AWH-Gate-Override: finalization-split` + `AWH-Gate-Reason: <한 줄 사유>`. 구체 토큰·구현은 downstream에 위임한다.

**Tracking-only commit convention (amend 2026-06-06, CHORE-20260606-016/c4):** 묶을 substantive 변경이 애초에 없는 **순수 tracking-only commit**(예: `/work-register` backlog row 추가, DR record-only, STATUS housekeeping)은 정당한 예외다. 이를 위해 신규 토큰을 추가하지 않는다(hook/문서 cascade 비대화 회피). 기존 `AWH-Gate-Override: finalization-split` trailer를 유지하되 reason에 `tracking-only registration: <대상>` 형식으로 사유를 남겨 흡수한다. gate 자체를 자동 예외로 약화시키지 않는다(외부화 ③ 선언-실행 괴리 재발 방지).

### 5. 집행 위치 (Ownership)

- gate 소유 = **commit 시점**: `.claude/rules/git-workflow.md` commit gate + downstream pre-commit hook.
- `/work-close`(`skills/workflow/work-close.md`)는 **commit-agnostic state edit**로 유지한다(OQ-12 확정). commit 전 `/work-close` 선행을 제안해 번들 가능 상태만 만든다.
- enforcement는 **hook-gated**: hard-stop은 hook 설치를 전제하며, **미설치 시 AI-advisory**(prose 규칙)다. 따라서 이 DR의 runtime hard enforcement claim은 **hook이 설치된 source/hook context에 한정**된다. target scaffold는 hook 미배포가 기본이라 그 환경에서는 advisory-only다(target hard enforcement는 downstream의 hook 배포 결정에 달림).
- DR-025 = 정책 SSoT. `git-workflow.md`/`work-close.md`는 이 정책을 가리키는 thin 적용 지점이며, 그 재배선은 downstream이 수행한다.

### 6. Extensibility

집행 대상 리스트(branch isolation protected paths, bundling 대상)는 harness default를 ship하되 **project-configurable**이다. product repo는 default를 유지하면서 자기 민감 파일을 확장할 수 있다. 가변 메커니즘(config SSOT)은 downstream가 소유한다.

### 7. Scope (decision-only)

이 DR은 원칙·경계·판정 기준만 결정한다. pre-commit hook hard-stop/sentinel 구현, target scaffold 배포·install·CI 대안, `.harness/config.json`, source-gitflow 환경 부트스트랩, `git-workflow.md`/`work-close.md` 재배선은 모두 단일 downstream 후보 `gate-enforcement-runtime-and-env`로 위임한다.

## Options Considered

| Option | Pros | Cons |
| --- | --- | --- |
| local-only provability + default-safe degrade (채택) | published/공유/위험 상태에서 hard-stop 오작동 방지, edge-state 일관 흡수 | 판정 로직이 push 단순비교보다 복잡(구현은 downstream) |
| push/PR 상태 기준 (R44 초안) | 단순 | published 판정이 거칠고 detached/rebase/fork/force-push 누락 |
| 항상 hard-stop bundling | 무결성 최대 | solo·shared·published에서 과도 마찰·history 손상 위험 |
| enforcement 없이 prose만 (현행) | 마찰 0 | 선언-실행 괴리 지속(DR-024가 지적한 외부화 ③) |

## Rationale

hard-stop의 마찰이 정당하려면 "되돌리기 쉬운 local amend"가 확실해야 한다. published history amend는 협업자 history를 깨므로 hard-stop 대상이 아니다. 흩어진 prose(`git-workflow.md:46-47`, `work-close.md` 3-state)를 단일 taxonomy SSoT로 모아 drift를 제거한다. DR-024 2D taxonomy 적용: causal finalization bundling = `conditional mandatory`, enforcement mode는 context에 따라 `hard-stop`/`warning`/`report-only`로 달라진다 — 이로써 평시 마찰과 commit 무결성을 독립 조정한다.

## Consequences

- `git-workflow.md`/`work-close.md`는 DR-025를 SSoT로 가리키는 thin 적용 지점이 된다(재배선은 downstream).
- 런타임 hook·config·CI·source-gitflow 환경은 downstream `gate-enforcement-runtime-and-env`가 소유한다.
- `/work-close`는 commit-agnostic으로 확정 유지된다.
- DR-022 closeout PLAN-impact 단계의 enforcement mode는 이 taxonomy를 따른다(정합).
- 부모 OQ-14(별도 state-only close commit 허용 예외)가 닫힌다. (OQ-12/13/16은 DR-024에서 닫힘)
- 이 DR은 scaffold target에 복사되지 않는 source-only decision이다. generated target runtime 문서에 DR-025 번호를 새로 인용하지 않는다(slice 4/9 재발 방지).

## Reversal Cost

Low — vocabulary와 판정 기준은 문서 결정이다. runtime 구현(downstream)은 적용 시 Medium 이상으로 재평가한다.

## Linked Backlog Items

- 부모: DR-024 (Gate Strictness 2D Taxonomy)
- 작성 Work: CHORE-20260606-004
- 닫는 OQ: CHORE-20260604-001/OQ-14
- 연계: DR-022 (closeout enforcement mode), DR-020 (branch ruleset), DR-015 (state update gate)
- Downstream 구현: `gate-enforcement-runtime-and-env` (구 HRN-002 + HRN-FUT-001 흡수)
