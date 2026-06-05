---
id: CHORE-20260606-004
priority: P1
status: Done
risk: Medium
scope: DR-024 child DR (DR-025) 작성 - causal finalization bundling의 commit gate runtime enforcement 정책(OQ-14 예외 테이블 + override + 집행 위치)을 형식화한다. decision-only, 실제 hook/command 구현은 하류.
appetite: 3d
planned_start: 2026-06-06
planned_end: 2026-06-09
actual_end: 2026-06-06
related_dr: [DR-024, DR-022, DR-020, DR-007]
related_troubleshooting: []
---

# CHORE-20260606-004: Commit Gate Runtime Enforcement Child DR (DR-025)

## Top Summary

- **목표:** DR-024가 명시적으로 child DR로 분리한 **commit gate runtime enforcement**(causal finalization bundling의 hard-stop/explicit override 실제 정책)를 DR-025로 작성한다. 핵심은 미해결 **OQ-14**(별도 state-only close commit 허용 예외 조건)를 닫는 것.
- **최종 산출:** `docs/decisions/DR-025-commit-gate-runtime-enforcement.md`(Accepted) — 7개 결정. decisions/README index·backlog 통폐합·DR-024/015 dangling 정리 cascade 완료. R44 draft → R45 Codex(P1 2건) → R46 반영 → R47 구현 → R48 Codex 승인.
- **역할 구성:** Claude 작성, Codex 리뷰. cross-agent round R44~R48(직전 slice R43에 이어).
- **decision-only:** DR 텍스트만 작성했다. pre-commit hook/sentinel·config·CI·scaffold env 구현은 downstream `gate-enforcement-runtime-and-env`로 위임.
- **상태 변경 주의:** `docs/STATUS.md` Active Work pointer 추가는 Approval Matrix state-change 대상. 이 초안에서는 STATUS 미수정.

## Context Manifest

| 순서 | 파일 | 확인 내용 | 왜 |
| --- | --- | --- | --- |
| 1 | `docs/decisions/DR-024-gate-strictness-taxonomy.md` | 2D taxonomy, causal finalization bundling = conditional mandatory + hard-stop/override, "Commit gate runtime enforcement는 별도 child DR" | 부모 DR, 이 child의 직접 근거 |
| 2 | `docs/works/harness/CHORE-20260604-001-harness-phase2-refactor-planning.md` §9, OQ-12/13/14 | OQ-12(/close commit-agnostic, DR-024로 닫힘), OQ-13(bundling 분류, DR-024로 닫힘), **OQ-14(예외 조건 → DR-025로 닫힘)** | child DR이 닫은 OQ |
| 3 | `.claude/rules/git-workflow.md` (line 46-47) | same-commit bundling 규칙 + `/work-close` 선행 제안이 이미 prose로 존재 | 형식화 대상 현행 규칙 |
| 4 | `skills/workflow/work-close.md` (line 85-108) | push 여부 기반 3-state commit 전략(미push→amend 번들 / 대안 별도 close commit) — HRN-037 | OQ-14 예외의 현행 구현 |
| 5 | `docs/decisions/DR-022-*.md` | closeout PLAN-impact 단계의 enforcement mode를 "DR-024 taxonomy 따름"으로 위임 | DR-025와 enforcement mode 정합 |
| 6 | `docs/backlog/HARNESS.md` `gate-enforcement-runtime-and-env` | 통합 downstream 후보(구 HRN-002+HRN-FUT-001 흡수) | DR-025 enforcement의 하류 구현 연계 |
| 7 | `docs/decisions/DECISION-TEMPLATE.md`, `DR-008` | DR 구조·파일명 규칙 | DR-025 형식 |
| 8 | `docs/decisions/DR-007-language-policy.md` | 한국어 primary + Bilingual Rules | DR-025 언어 |

## Problem (무엇을 닫는가)

DR-024는 causal finalization bundling을 `conditional mandatory + hard-stop/explicit override`로 **분류만** 했다. 실제 런타임 정책 3가지가 미정이다:

1. **OQ-14 — 예외 테이블:** 실질 변경과 finalization(Work Done/STATUS/index)을 같은 commit에 묶는 것이 원칙인데, 언제 **별도 state-only finalization commit**이 허용되나? (PR opened / shared branch / pushed history에서는 마지막 commit amend가 불가능하거나 위험)
2. **Override 판정:** hard-stop이 떴을 때 사용자가 어떻게 명시적으로 override하나? override 흔적은 어디에 남기나?
3. **집행 위치:** 이 gate를 누가 소유하나? (OQ-12에서 `/work-close`는 commit-agnostic으로 확정 → gate는 commit 시점 = `git-workflow.md` rule + pre-commit hook이 소유)

현재 `git-workflow.md:46-47`(prose 규칙)과 `work-close.md:85-108`(3-state 안내)가 흩어져 같은 내용을 부분적으로 다룬다. drift 위험이 구조적으로 남는다.

## Plan (DR-025가 결정할 내용 — R44 draft)

### Execution Classification

| 항목 | 판단 |
| --- | --- |
| Risk Level | L2 harness/workflow surface (decision-only DR). reversal cost Low(DR 텍스트), 단 commit 무결성 gate를 규율하므로 cross-agent review 필수 |
| Execution Mode | Full Work (단일 DR이지만 OQ-14 결정 + 기존 surface 정합) |
| Branch | `feature/chore-20260606-004-commit-gate-enforcement-dr` |
| Approval | 사용자 plan scope 승인 + Codex R45 review 후 DR 작성. commit 전 별도 승인 |
| 비목표 | pre-commit hook/sentinel 실제 구현, target hook 배포·install·CI, `.harness/config.json` 메커니즘, source-gitflow 환경 부트스트랩, surface 재배선 — 전부 consolidated downstream 후보로 위임(PQ-D). DR은 원칙·결정만 |

### PQ-A0. Gate 적용 대상 (무엇을 묶나)

bundling gate는 **conditional** mandatory다 — 조건 = "묶을 finalization이 commit에 존재함". 대상 집합을 명시한다:

- **적용:** **T15 STATUS Finalization + T16 Tracking Finalization 산출물**(Work Done, STATUS, Work index, backlog, DR tracker)을 포함한 commit.
- **미적용:** state 변경 없는 순수 코드/문서 commit, L1 Quick Mode(Work 파일 없음).

→ "모든 commit"이 아니라 `{T15, T16}` 산출물 동반 commit만 대상. (R44 보강 — 현행 규칙이 STATUS만 명시해 backlog/DR tracker가 모호했던 점 해소)

### PQ-A1. Context Applicability (N/A 0축 — 마찰 방지)

3-state 적용 **이전에** "이게 git/PR context인가"를 먼저 판정한다. 아니면 gate 비활성(유연):

| Context | 판정 |
| --- | --- |
| git repo 없음 / bootstrap §0 미완 | **N/A** — commit/PR 검증 자체가 Not Applicable(BOOTSTRAP §0 기존 규칙) |
| generic(비-PR) 프로젝트 | push/PR 분기 N/A — 로컬 "same commit"만 적용 |
| no-remote | push/PR state N/A — 미push 경로로만 판정 |
| bootstrap 다수 setup 편집 중 | DR-024 bootstrap gate(완화) 적용 — bundling hard-stop 비강제 |

근거: 마찰이 정당하려면 "되돌리기 쉽고 + 실제 git/PR을 쓰는" context에서만 hard-stop이 떠야 한다.

### PQ-A2. Exception Judgment (OQ-14 핵심 결정 — 위 N/A를 통과한 git context 한정)

bundling 원칙 = **실질 변경 + finalization을 같은 commit**. 예외 판정의 진짜 기준은 "branch가 push됐나"가 아니라 **"amend 대상 commit을 안전하게 local-only로 고칠 수 있음을 증명할 수 있나"**다. (R45 P1-1 반영)

**핵심 원칙(default-safe degrade):** **local-only임을 확실히 증명할 수 없으면 hard-stop하지 않고 warning/report-only로 degrade한다.** hard-stop은 "amend가 published history를 건드리지 않음이 확실한" 경우에만.

| 판정 | 조건 | Enforcement |
| --- | --- | --- |
| **provably local-only** | HEAD commit이 어떤 remote ref로도 push되지 않았음이 확실 + rebase/merge/cherry-pick 미진행 + detached HEAD 아님 | **hard-stop** — finalization 분리 시 중단(같은 commit 번들/`--amend`) |
| **published / 공유됨** | HEAD가 push됨, PR open, shared branch | **report-only** — 별도 state-only finalization commit 허용(amend가 history 재작성이라 금지) |
| **불확실/위험 상태** | detached HEAD, rebase/merge/cherry-pick 진행 중, fork PR·no push rights·upstream mismatch, remote branch 있으나 HEAD만 unpushed, **force-push 가능한 shared branch** | **warning(분리 허용 + 사유 기록)** — local-only 증명 불가 → hard-stop 금지(default-safe) |

근거: hard-stop의 마찰이 정당하려면 "되돌리기 쉬운 local amend"가 확실해야 한다. force-push 가능 shared branch는 기술적으로 amend 가능하나 협업자 history를 깨므로 hard-stop 대상이 아니다(불확실/위험 → warning). (R45 P1-1: force-push shared branch를 검토 항목에서 결정으로 승격)

### PQ-B. Override UX

- override는 silent 통과가 아니라 **durable record가 남는 "기록된 예외"** 여야 한다(외부화 ③ 선언-실행 괴리 방지). (R45 P2-1)
- **메커니즘 주의:** git `--no-verify`는 모든 hook(whitespace 포함) 우회라 coarse. bundling만 정밀 우회 + 사유 강제는 별도 sentinel이 낫다. **env var 단독은 commit에 기록이 남지 않아 부적합** → preferred form = **commit trailer**(예: `AWH-Gate-Override: finalization-split` + `AWH-Gate-Reason: ...`). DR-025는 **"override = durable commit-trailer sentinel + 사유" 원칙**만 정하고, 구체 sentinel 토큰/구현은 downstream(PQ-D)에 위임한다.

### PQ-C. 집행 위치 (Ownership) — 원칙만, 메커니즘은 위임

- gate 소유 = **commit 시점**: `.claude/rules/git-workflow.md`(Commit gate). `/work-close`는 OQ-12대로 **commit-agnostic state edit** 유지(commit 전 `/work-close` 선행을 제안해 번들 가능 상태만 만든다).
- **enforcement는 hook 한 수단:** hard-stop은 pre-commit hook 설치를 전제한다. **미설치 시 AI-advisory**(prose 규칙). hook의 실제 구현·scaffold 배포·install·CI 대안·N/A-aware 로직은 **DR-025가 만들지 않고 아래 consolidated downstream로 위임**한다.
- **과장 방지(R45 P2-2):** DR-025의 runtime hard enforcement claim은 **hook이 설치된 source/hook context에 한정**된다. target scaffold는 hook 미배포가 기본이라 그 환경에서는 advisory-only임을 DR 본문에 명시한다.
- DR-025 = 정책 SSoT. git-workflow.md/work-close.md는 그 정책을 가리키는 thin 적용 지점.

### PQ-D. Downstream 위임 (consolidated, 중복 항목 방지)

DR-025는 **decision-only**. 실제 런타임 집행·환경·config은 흩어진 항목 대신 **단일 consolidated backlog 후보**로 모은다(기존 HRN-002 hook + HRN-FUT-001 config 흡수, 두 항목 삭제). DR-025/DR-024/DR-020을 그 후보에 연계.

위임 대상: pre-commit hook hard-stop/sentinel 구현, target scaffold 배포·install·CI, project-configurable 리스트(protected/bundling 대상)용 `.harness/config.json`, source-gitflow 환경 부트스트랩(develop/main/origin/branch-protection) + no-remote N/A 후속 추적.

### PQ-E. Extensibility 원칙 (싸게 결정, 메커니즘은 위임)

집행 대상 리스트(branch isolation protected paths, bundling 대상)는 harness default를 ship하되 **project-configurable**임을 원칙으로 둔다. product repo는 default를 유지하면서 자기 민감 파일을 확장할 수 있다. **가변 메커니즘(config SSOT)은 위 consolidated downstream**가 소유한다 — DR-025는 원칙 1줄만.

### PQ-F. DR-022 정합

DR-022 closeout PLAN-impact 단계의 enforcement mode가 "DR-024 taxonomy 따름"이므로, DR-025 taxonomy 적용 예시에 closeout PLAN-impact를 한 줄 포함해 모드 일관성만 확인(구현은 비목표).

## Done Criteria

- [x] DR-025가 생성되고 DR-024 child로 명시(Linked + 부모 참조)된다.
- [x] gate 적용 대상이 `{T15 STATUS Finalization, T16 Tracking Finalization}` 산출물로 명시된다(PQ-A0).
- [x] Context N/A 0축(no-git/bootstrap/generic/no-remote)이 3-state보다 먼저 판정됨이 명시된다(PQ-A1).
- [x] OQ-14가 닫힌다 — exception 판정 기준이 "push 여부"가 아니라 **"local-only 증명 가능성"**으로 정의되고, **증명 불가 시 hard-stop 금지·degrade**(default-safe) 원칙 + edge-state(detached HEAD, rebase/merge/cherry-pick 진행, fork PR/no push rights/upstream mismatch, force-push 가능 shared branch)가 형식화된다(PQ-A2, R45 P1-1).
- [x] override = durable commit-trailer sentinel + 사유 원칙으로 정의된다(env-var 단독 거부, `--no-verify` coarse 회피, 구현은 위임)(PQ-B, R45 P2-1).
- [x] 집행 위치가 commit gate로 명시되고 `/work-close`는 commit-agnostic 유지, enforcement는 hook-gated(미설치=advisory)이며 **runtime hard enforcement claim은 hook 설치 context 한정**임이 명시된다(PQ-C, R45 P2-2).
- [x] Extensibility 원칙(집행 대상 리스트는 project-configurable, default ship)이 1줄로 기록된다(PQ-E).
- [x] 런타임 집행·환경·config은 **단일 consolidated downstream 후보**로 위임되고, DR-025/DR-024/DR-020이 연계된다(PQ-D).
- [x] DR-022 enforcement mode 정합이 한 줄 확인된다(PQ-F).
- [x] `docs/decisions/README.md` index에 DR-025 행이 추가된다(closure 유지). parent OQ-14 closure는 DR-025 Consequences에 기록(Done parent Work 미수정, DR-024가 OQ-12/13/16을 처리한 관례 따름).
- [x] DR-025는 target 미복사 DR(자신 포함)을 runtime 문서에 새로 인용하지 않는다(DR-024처럼 source-only decision).
- [x] Codex result review(R48) 승인 — `/work-close` 처리. commit/PR/merge는 별도 단계.

## Verification

| Check | Method | Expected |
| --- | --- | --- |
| Branch isolation | `git branch --show-current` | feature/chore-20260606-004-... |
| DR 형식 | DECISION-TEMPLATE 구조 + DR-008 파일명 | 정합 |
| Index closure | `scripts/tests/check-scaffold-invariants.sh` [3] decisions/README closure | PASS |
| Whitespace/link | `git diff --check`, DR 내부 링크 존재 | PASS / dangling 0 |
| Scaffold invariant | `check-scaffold-invariants.sh` default+`--with-optional` | PASS (DR-025는 source-only, target 미복사 — 누수 0) |
| OQ closure | parent OQ-14가 DR-025로 Closed 처리됨 | OQ table 갱신 제안 |
| Cross-agent | Codex R45 plan review, result review | P0/P1 none or resolved |

## Checkpoints

| CP | 내용 | 상태 |
| --- | --- | --- |
| CP0 | Branch isolation, DR-024/OQ-14/현행 surface 조사, Work + R44 draft | Done |
| CP1 | Codex R45 plan review(Changes requested) + R46 반영 + 사용자 scope approval | Done |
| CP2 | DR-025 작성 (대상/N/A/local-only exception/override/ownership/extensibility) | Done |
| CP3 | decisions/README index + OQ-14 closure 기록 + backlog/DR dangling 정리 | Done |
| CP4 | self-validation PASS + Codex result review | self-validation Done, review Pending |
| CP5 | `/work-close`(Done, index 이동, STATUS finalization) + commit approval | Done |

## Cross-Agent Review

### Round Log

| Round | Agent | Summary | Status |
| --- | --- | --- | --- |
| R44 | Claude | Plan draft + 사용자 Q&A 보강. DR-025 = decision-only: 대상 {T15,T16}, context N/A 0축, OQ-14 3-state, override sentinel 원칙, extensibility 원칙, 런타임/환경/config은 consolidated downstream로 위임 | Codex review requested |
| R45 | Codex | Plan review: 수정 요청(P1 2건). P1-1 exception 기준을 "push 여부"→"local-only 증명 가능성"으로, 증명불가 시 degrade + edge-state 결정. P1-2 backlog 통폐합 미완(기존 pre-commit/commit-msg 후보 overlap). P2: override durable record(commit trailer), runtime claim 한정, sub-slice 분해 전제 | Claude 반영 |
| R46 | Claude | R45 전면 수용·반영. PQ-A2를 local-only provability + default-safe degrade + edge-state(detached/rebase/fork/force-push shared)로 재작성, PQ-B commit-trailer preferred(env-var 거부), PQ-C runtime claim hook-context 한정, backlog 기존 hook 후보를 "현행 hook hygiene"으로 좁히고 consolidated를 SSoT 명시 + sub-slice 분해 명문화 | DR-025 작성 진행 |
| R47 | Claude | 구현 완료: `DR-025-commit-gate-runtime-enforcement.md` 작성(7개 결정), decisions/README index 추가, parent OQ-14 closure는 DR-025에 기록(Done parent 미수정, DR-024 관례 따름). self-validation PASS | Codex result review 요청 |

### R44 Claude Plan Draft

**결론:** DR-024가 분리한 commit gate runtime enforcement를 DR-025(decision-only)로 작성한다. 사용자 Q&A로 scope를 정밀화했다 — DR은 **원칙·경계만** 정하고, 모든 메커니즘(hook 구현·배포·CI·config·source-gitflow 환경)은 **단일 consolidated downstream 후보**로 위임(기존 HRN-002+HRN-FUT-001 흡수·삭제, DR-020/024/025 연계).

Codex 검토 요청(P0/P1 우선):

1. **PQ-A0/A1/A2 — 대상·N/A·예외:** gate 대상을 `{T15,T16}`로, 3-state 앞에 context N/A 0축(no-git/bootstrap/generic/no-remote)을 둔 구조가 타당·완전한가? 누락 상태(force-push 가능 shared branch, rebase, fork-PR 등)?
2. **PQ-B override:** 정밀 sentinel + 사유 기록 원칙(`--no-verify` coarse 회피)이 "선언-실행 괴리" 방지에 적정한가? DR에서 원칙까지만 두고 구현 위임이 맞나?
3. **PQ-C ownership:** commit gate 소유 + `/work-close` commit-agnostic 유지 + **enforcement=hook-gated(미설치=advisory)**가 OQ-12와 정합인가? target에 hook 미배포 시 advisory-only가 수용 가능한가?
4. **PQ-D 위임/통폐합:** 런타임·환경·config을 단일 downstream로 모으고 HRN-002/HRN-FUT-001을 흡수·삭제하는 backlog 정리가 적절한가? source-gitflow 환경 부트스트랩을 같은 후보에 넣는 게 맞나, 분리가 맞나?
5. **PQ-E extensibility:** "집행 대상 리스트 project-configurable, 메커니즘은 위임"을 DR 원칙 1줄로 두는 수준이 적정한가(과소/과대)?
5. **DR-022 정합:** closeout PLAN-impact enforcement mode를 DR-025 예시에 한 줄 포함하는 수준이 적절한가?

### R45 Codex Plan Review

**결론: 수정 요청(P1 2건).** 방향 좋고 decision-only 경계 대체로 깨끗. DR 본문 작성 전 2건 처리 권장.

- **P1-1:** A2의 3-state가 "push/PR 상태" 중심이라 published-history 판정이 거칠다. hard-stop 기준은 "branch가 push됐나"보다 **"amend 대상 commit을 안전하게 local-only로 고칠 수 있나"** 여야 한다. 원칙 추가: **local-only 증명 불가 시 hard-stop 대신 warning/report-only로 degrade.** detached HEAD, rebase/merge/cherry-pick 진행, fork PR/no push rights/upstream mismatch, remote 있으나 HEAD만 unpushed, force-push 가능 shared branch를 별도 상태로 언급하거나 흡수. force-push shared branch는 검토 항목→결정으로 승격.
- **P1-2:** downstream 통폐합이 backlog에서 미완 — 기존 "Pre-commit/commit-msg hook 검토·정비·설치" 후보가 남아 hard block/install 범위가 통합 후보와 겹친다. 흡수하거나 좁게 재정의 + 통합 후보를 SSoT로 명시할 것.
- **P2:** ① override sentinel은 durable record 필요 — env var 단독 부적합, commit trailer(`AWH-Gate-Override`/`AWH-Gate-Reason`) preferred. ② "미설치=advisory"는 target hard enforcement 없음이므로 runtime claim을 설치된 source/hook context로 한정 명시(과장 방지). ③ source-gitflow를 단일 downstream에 넣는 건 OK, 단 (a)~(d) sub-slice 분해 전제. ④ scaffold-target-maintenance-note는 별개로 존재(FYI).

### R46 Claude Response To R45

**R45 전면 수용.** 2 P1 + P2 모두 반영:

- **P1-1:** PQ-A2를 **local-only provability** 기준으로 재작성. 핵심 원칙 = "local-only 증명 불가 시 hard-stop 금지·degrade(default-safe)". 판정 3분류(provably local-only=hard-stop / published=report-only / 불확실·위험=warning)로 형식화하고 edge-state(detached HEAD, rebase/merge/cherry-pick, fork PR·no push rights·upstream mismatch, remote 있으나 HEAD만 unpushed, force-push shared branch)를 "불확실/위험" 행에 명시 흡수. force-push shared branch를 결정으로 승격.
- **P1-2:** backlog 기존 "Pre-commit/commit-msg hook" 후보를 **"기존 source hook hygiene + commit-msg relation 점검"**으로 좁히고, 새 enforcement(bundling/validation/config/scaffold)는 `gate-enforcement-runtime-and-env`가 SSoT임을 양쪽에 명시(Option B).
- **P2:** override를 **durable commit-trailer sentinel**(`AWH-Gate-Override`/`AWH-Gate-Reason`) preferred·env-var 단독 거부로 명시(PQ-B). runtime hard enforcement claim을 hook 설치 context 한정으로 명시(PQ-C). consolidated 항목에 "단일 PR 아님 — (a)~(d) 별도 slice" 명문화.

P1이 plan 단계에서 모두 해소됐으므로(Codex "DR 작성 전 2건 처리" 충족) DR-025 본문 작성으로 진행.

### R47 Claude Implementation Summary

구현 완료. Codex result review를 요청한다.

**산출:** `docs/decisions/DR-025-commit-gate-runtime-enforcement.md` (Accepted, DR-024 child, decision-only).

**7개 결정:** (1) 대상 = `{T15, T16}` 산출물 동반 commit, (2) Context N/A 0축(no-git/bootstrap/generic/no-remote), (3) **Exception = local-only 증명 기준** + default-safe degrade + edge-state(detached/rebase/merge/cherry-pick/fork/no-push-rights/upstream-mismatch/HEAD-only-unpushed/force-push shared), (4) override = durable commit-trailer sentinel(`AWH-Gate-Override`/`AWH-Gate-Reason`, env-var 거부), (5) 집행 = commit gate + hook-gated(미설치=advisory, runtime claim은 hook context 한정), `/work-close` commit-agnostic 유지, (6) Extensibility = project-configurable(메커니즘 위임), (7) Scope = decision-only, 모든 메커니즘은 `gate-enforcement-runtime-and-env` downstream.

**Cascade:** decisions/README index에 DR-025 행 추가, DR-024/DR-015의 HRN-002 dangling 참조를 consolidated slug로 재지정, backlog 통폐합(HRN-002+HRN-FUT-001 흡수·삭제, 기존 hook 후보 좁힘).

**Self-validation PASS:**
- `git diff --check` OK
- scaffold invariants OVERALL PASS, [3] decisions/README index closure OK
- DR-025 source-only 확인: `create-harness.sh` 미복사(0), 참조처는 source docs(backlog/README/DR-024/DR-025 자신)만, fresh `--with-optional` target에 DR-025 누수 0
- DR 형식: DECISION-TEMPLATE 구조(Question/Decision/Options/Rationale/Consequences/Reversal Cost/Linked) + DR-008 파일명 정합
- OQ-14 closure: DR-025 Consequences에 기록(parent Work는 Done이라 미수정 — DR-024가 OQ-12/13/16을 같은 방식으로 처리한 관례 따름)

Codex result review = R48. commit/PR/merge는 사용자 승인 후 별도 단계.

## Discovery

- Branch Isolation Check: develop clean에서 protected edit 금지 확인 후 `feature/chore-20260606-004-commit-gate-enforcement-dr` 생성.
- Round 연속성: 직전 slice(003) R43 종료 → 이번 첫 cross-agent 기여 = 이 Claude plan draft = R44. Codex plan review R45, 이후 작성 요약 R46, Codex result review R47.
- 부모 DR-024가 OQ-12/13/16을 닫고 OQ-14 + runtime enforcement를 child DR로 명시 분리. 이 Work가 그 child.
- 현행 surface 실측: bundling 규칙은 이미 `git-workflow.md:46-47`(same-commit) + `work-close.md:85-108`(3-state push 기반 commit 전략, HRN-037)에 prose로 존재. DR-025는 이를 단일 taxonomy SSoT로 형식화하되, surface 재배선은 하류로 분리해 decision/implementation 혼합을 피한다.
- DR 번호: DR-025 free 확인(현재 최고 DR-024).
- Work ID 날짜: 직전 slice가 `CHORE-20260606-001~003`이라 sequence 연속성을 위해 `-004`/2026-06-06으로 맞췄다.
- 우선순위: STATUS Next Actions #2(이 Work)는 #1(scaffold maintenance note, P2)보다 구조적으로 위 — commit 무결성 gate이고 DR-024 open thread이며 enforcement 구현 slice를 unblock한다. 사용자가 "중요한 걸 먼저"로 이 Work를 선택.
- R44 보강(사용자 Q&A): 현행 surface 실측 결과 — pre-commit hook은 whitespace+branch isolation만 강제하고 bundling은 미강제(AI prose 의존), hook은 source 전용(target 미배포), source-gitflow scaffold는 GIT-WORKFLOW.md(develop/main/origin 전제)만 복사하고 git init/develop/origin은 생성 안 함(BOOTSTRAP §0는 generic). 이로부터 (a) DR-025를 decision-only 원칙으로 좁히고 context N/A 0축·대상 {T15,T16}·sentinel override·extensibility 원칙을 추가, (b) 메커니즘은 흩어진 항목 대신 단일 consolidated downstream로 통폐합(HRN-002+HRN-FUT-001 흡수·삭제, DR-020/024/025 연계)하기로 결정.
- 통폐합 방침(사용자): 아직 실행 안 된 관련 항목은 한 줄 메모를 흩뿌리기보다 하나로 합쳐 맥락을 유지한다. backlog 정리는 이 Work commit에 동반(별도 backlog candidate 추가 + HRN-002/HRN-FUT-001 삭제).
