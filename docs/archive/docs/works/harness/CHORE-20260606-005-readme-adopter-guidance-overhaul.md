---
id: CHORE-20260606-005
priority: P2
status: Archived
risk: Medium
scope: README public front-door 정보구조를 재설계하고, scaffold product repo 사용자와 clone/fork maintainer-adopter 안내를 분리해 반영한다. 구현 전 plan review 우선.
appetite: 3d
planned_start: 2026-06-06
planned_end: 2026-06-09
actual_end: 2026-06-06
related_dr: [DR-021, DR-025, DR-007, DR-008]
related_troubleshooting: []
related_work: [CHORE-20260604-001]
---

# CHORE-20260606-005: README / Adopter Guidance Overhaul

## Top Summary

- **목표:** README를 public front-door로 재구성한다. 사용자가 가장 먼저 알아야 할 "이 repo가 무엇인지", "내 프로젝트에 어떻게 적용하는지", "clone/fork해서 내 harness source로 키울 때 무엇을 주의해야 하는지"를 선명하게 분리한다.
- **흡수 범위:** `scaffold-target-maintenance-note` + `forked-harness-adoption-note`를 하나의 adopter guidance slice로 통합한다.
- **역할 구성:** Codex가 Work 파일과 plan을 작성하고, Claude가 plan review한다. 직전 cross-agent result review가 R48이므로 이번 첫 round는 **R49**다.
- **이번 단계:** Work 파일 + plan draft만 작성한다. README/script/manual 구현은 Claude R50 plan review와 사용자 승인 후 진행한다.
- **상태 변경 주의:** `docs/STATUS.md` Active Work pointer 추가는 Approval Matrix state-change 대상이다. 이 초안에서는 STATUS를 수정하지 않는다.

## Context Manifest

| 순서 | 파일 | 확인 내용 | 왜 |
| --- | --- | --- | --- |
| 1 | `README.md` | 현재 Quick Start, Prologue, scaffold, Git Flow, docs map, license 구조 | 재구성 대상 SSoT |
| 2 | `docs/backlog/HARNESS.md` | `CHORE-20260606-005` active row, 흡수된 adopter note 범위 | 작업 등록 근거 |
| 3 | `docs/WORKFLOW-MANUAL.md` | workflow 개념 설명과 README pointer 경계 | README가 manual을 대체하지 않도록 깊이 조절 |
| 4 | `docs/SCAFFOLD-ONBOARDING-GUIDE.md` | scaffold 직후 첫 세션 안내 | README scaffold path의 후속 링크 |
| 5 | `scripts/create-harness.sh` | generated target README/BOOTSTRAP/STATUS 텍스트 | scaffold product repo 안내 반영 위치 |
| 6 | `docs/GIT-WORKFLOW.md` | source repo Gitflow, hook source-only, scaffold 예외 | clone/fork maintainer-adopter 안내 근거 |
| 7 | `docs/decisions/DR-021-source-target-boundary.md` | source/framework/project-state boundary | source/scaffold 안내 경계 |
| 8 | `docs/decisions/DR-025-commit-gate-runtime-enforcement.md` | commit gate policy는 hook-installed context 한정, target은 advisory 기본 | branch/commit 마찰 안내 근거 |
| 9 | `docs/decisions/DR-007-language-policy.md` | docs는 Korean primary + bilingual rules | README 톤·언어 정책 |
| 10 | `/Users/kyungseo/dev-home/vibe/ai-deck-compiler/README.md`(read-only reference, 가능 시) | 존댓말, 초보자 친화, conventional README IA | 톤 참고. 내용은 이 repo에 맞게 재해석 |

## Scope Inventory

### 포함

- README 전체 정보구조 재검토와 재배치.
- source README의 adopter modes 섹션:
  - **Use the harness in your project:** `create-harness.sh`로 scaffold.
  - **Maintain your own harness source:** clone/fork 후 upstream-compatible mode 또는 personal harness mode 선택.
  - **Contribute upstream:** 이 source repo의 Gitflow와 PR 규칙 준수.
- scaffold product repo maintenance note:
  - framework-owned vs project-owned 경계.
  - `scripts/create-harness.sh --check` 사용.
  - 현재 `--upgrade` 미제공, 수동 selective migration 주의.
  - source-only migration/DR 문서 링크를 target README에 직접 추가하지 않는 방침.
- README 톤 조정:
  - 존댓말.
  - 일반 사용자도 이해 가능한 문장.
  - 전문 용어는 유지하되 처음 등장할 때 맥락 제공.
- `<details>` 사용 기준:
  - 핵심 선택지와 첫 사용 경로는 펼친 본문에 둔다.
  - 긴 절차, 보조 다이어그램, edge-case 설명만 접는다.
- GitHub Issues 기반 `Contributing` 섹션 추가.

### 비포함

- `docs/WORKFLOW-MANUAL.md` deep rewrite 재개.
- DR-025 runtime enforcement 구현(hook/config/CI/scaffold 배포).
- 실제 `--upgrade`/`--refresh` 기능 설계.
- scaffold archive semantics 또는 PLAN/template 후속 재설계.
- source repo branch policy 자체 변경.

## Proposed README Information Architecture

README는 "개요를 빠르게 이해하고 올바른 다음 문서로 이동"시키는 문서로 둔다. 자세한 운영 매뉴얼은 `docs/WORKFLOW-MANUAL.md`, scaffold 직후 절차는 `docs/SCAFFOLD-ONBOARDING-GUIDE.md`가 맡는다.

1. **What This Repository Is**
   - 이 repo는 프로젝트에 AI workflow harness를 적용하기 위한 source repository임을 먼저 설명한다.
   - "이 repo 자체를 project-local workspace로 바꾸지 않는다"는 주의를 여기 또는 Start Here에 둔다.
2. **Start Here**
   - 기존 Quick Start를 재검토한다. 유지하더라도 "target repo" 같은 미정의 용어로 시작하지 않는다.
   - 사용 경로 선택지를 먼저 둔다: scaffold / forked harness source / upstream contribution.
3. **Repository Structure**
   - source repo, scaffold output, optional docs, canonical workflow, tool adapters의 관계를 간단히 설명한다.
4. **Apply The Harness To Your Project**
   - scaffold 명령과 scaffold 직후 onboarding 흐름.
   - 자세한 단계는 onboarding guide로 연결.
5. **Adopter Modes And Maintenance**
   - scaffold product repo maintenance note.
   - clone/fork maintainer-adopter 안내.
   - upstream-compatible mode vs personal harness mode.
6. **Workflow Overview**
   - `INIT -> PLAN -> APPROVAL -> EXECUTE -> VALIDATE -> CHECKPOINT -> END`.
   - 대표 다이어그램은 노출하고, 세부 흐름도는 필요 시 `<details>`.
7. **Core Concepts**
   - Session Lifecycle, Work Selection And Routing, Approval Matrix, Trigger/Cascade, State Storage를 짧게 설명.
   - 상세는 workflow manual로 pointer.
8. **Documentation Map**
   - 사용 목적별 문서 링크.
9. **Contributing**
   - 버그 리포트와 기능 제안은 GitHub Issues에서 환영.
   - 구체적 contribution protocol이 준비되지 않았으므로 과도한 약속은 하지 않는다.
10. **License**

## Plan

| Step | 내용 | 산출 | 검증 |
| --- | --- | --- | --- |
| 1 | README current-state inventory + CHORE-20260606-002 reconcile | 보존/이동/축약/삭제 후보 목록. 별도 열로 "002 확정분(보존)" 표시 | stale 용어와 중복 섹션 확인. 002 thinning/diagram 회귀 없음 |
| 2 | adopter guidance 경계 설계 | source README vs generated target README 배치 결정 | source-only link target 누수 방지 |
| 3 | README 초안 재구성 | README.md rewrite | ToC/anchor, 톤, details 사용 기준 확인 |
| 4 | scaffold target README 반영 | `scripts/create-harness.sh` generated README maintenance note | `bash -n`, fresh scaffold default/source-gitflow |
| 5 | pointer consistency pass | manual/onboarding/quick reference 필요한 최소 pointer 조정. inbound README anchor 링크 갱신 또는 앵커 보존 | README/manual/onboarding 용어 경계 grep. inbound README anchor dangling 0 |
| 6 | self-validation | diff와 scaffold 검증 | 아래 Verification 모두 PASS |

## Done Criteria

- [x] README가 "정체성 -> 사용 경로 선택 -> repo 구조 -> scaffold/onboarding -> workflow overview -> adopter maintenance -> docs/contributing/license" 순서로 재구성된다.
- [x] CHORE-20260606-002 확정분을 되돌리지 않는다: §2 canonical workflow + tool adapter 다이어그램/프레이밍 보존, Approval Matrix/Trigger 상세 전표 재호스팅 금지, command map canonical/adapter framing 유지.
- [x] Quick Start 또는 Start Here가 `target repo` 같은 미정의 용어로 시작하지 않는다.
- [x] "이 repository 자체를 직접 project-local workspace로 전환하지 않는다"는 주의가 유지된다.
- [x] scaffold product repo 사용자와 clone/fork maintainer-adopter가 분리 설명된다.
- [x] generated target README에 framework-owned/project-owned, `--check`, `--upgrade` 미제공·수동 migration 주의가 target-safe하게 들어간다.
- [x] generated target README maintenance note는 source-only 문서나 source-only DR을 relative-link하지 않는다. 필요 시 prose로만 언급하거나 target-copied 문서의 안정 앵커만 사용한다.
- [x] default scaffold에는 forked harness source 전용 안내나 source-only DR 링크가 누수되지 않는다.
- [x] README가 존댓말·초보자 친화 톤으로 정리된다.
- [x] 존댓말 전환 후에도 Approval Matrix, 4-gate, source/scaffold 경계 같은 규칙 요지의 정밀도가 흐려지지 않는다.
- [x] README 분량은 CHORE-20260606-002 이후 버전 대비 크게 늘리지 않는다. 신규 설명은 tight하게 쓰고 긴 절차는 `<details>` 또는 pointer로 보낸다.
- [x] 긴 절차나 보조 다이어그램은 필요 시 `<details>`로 접되, 핵심 선택지는 접지 않는다.
- [x] 첫 결정 경로, scaffold 명령, state-machine 한 줄은 `<details>` 안에 숨기지 않는다.
- [x] GitHub Issues 기반 기여 섹션이 추가된다. 아직 없는 `CONTRIBUTING.md`를 약속하지 않는다.
- [x] repo 전체의 inbound README anchor 링크가 모두 실재한다. 현재 확인된 `docs/SCAFFOLD-ONBOARDING-GUIDE.md`의 과거 New Project Adoption anchor 링크는 갱신하거나 앵커를 보존한다.
- [x] Cross-agent plan review와 result review가 Work 파일에 누적된다.

## Verification

| Check | Method | Expected |
| --- | --- | --- |
| Branch isolation | `git branch --show-current` | `feature/chore-20260606-005-readme-adopter-guidance-overhaul` |
| Whitespace | `git diff --check` | PASS |
| Scaffold script syntax | `bash -n scripts/create-harness.sh` | PASS |
| Scaffold invariant | `scripts/tests/check-scaffold-invariants.sh` | default + optional OVERALL PASS |
| Fresh scaffold default | temp target 생성 후 README/manifest/`--check` 확인 | target-safe maintenance note, source-only fork 안내 0 |
| Fresh scaffold source-gitflow | temp target 생성 후 README/GIT-WORKFLOW marker 확인 | source-gitflow 안내 정합, source repo 전용 hook 과장 없음 |
| README self anchors | ToC anchor grep 또는 lightweight script | dangling 0 |
| README inbound anchors | `rg -n 'README\\.md#[A-Za-z0-9._-]+' .` 후 각 anchor 갱신/보존 확인 | inbound dangling 0 |
| 002 regression guard | README diff review against CHORE-20260606-002 intent: canonical/adapter diagram, Approval Matrix thinning, command map framing | 002 확정분 보존 |
| Boundary grep | `rg` for `target repo`, `source repository`, `scaffold product repo`, `fork`, `--upgrade`, `DR-025` | 용어 정의 전 사용/target source-only leak 없음 |

## Risks And Reversal Cost

| 항목 | 판단 |
| --- | --- |
| Risk Level | L2 — README와 scaffold 생성 텍스트를 건드리는 user-facing harness surface |
| Execution Mode | Full Work — README IA rewrite + scaffold target boundary + cross-agent review 필요 |
| Reversal Cost | Low~Medium. 문서 변경은 원복 가능하지만 README front-door와 generated target README를 함께 되돌려야 한다 |
| Main Risk | README가 너무 길어지거나, source/fork/scaffold 세 독자를 섞어 오히려 혼란을 키우는 것 |
| Mitigation | README는 path 선택과 overview 중심, 상세 절차는 manual/onboarding으로 pointer. target README에는 target-safe 안내만 |

## Tool Rule Reference

- `.claude/rules/git-workflow.md`: `paths: "**"` — branch isolation/commit gate guidance applies manually.
- `.claude/rules/docs-workflow.md`: docs path match — Work file, backlog, README, scaffold docs changes must follow DR-007 and Approval Matrix.

## STATUS Update Proposal

이 Work를 구현 단계로 진행하기 전 사용자 승인 후 아래 1줄을 `docs/STATUS.md` Active Work에 추가한다.

| ID | Title | Work File |
| --- | --- | --- |
| CHORE-20260606-005 | README / Adopter Guidance Overhaul | `docs/works/harness/CHORE-20260606-005-readme-adopter-guidance-overhaul.md` |

## Checkpoints

| CP | 내용 | 상태 |
| --- | --- | --- |
| CP0 | Branch isolation, backlog consolidation, Work file + R49 plan draft | Done |
| CP1 | Claude R50 plan review + Codex R51 P1 반영 + 사용자 scope approval | Done |
| CP2 | README IA rewrite | Done |
| CP3 | scaffold target README maintenance note 반영 | Done |
| CP4 | pointer/boundary consistency pass | Done |
| CP5 | self-validation + Claude result review | Done |
| CP6 | `/work-close` + commit approval 준비 | Done |

## Cross-Agent Review

### Round Log

| Round | Agent | Summary | Status |
| --- | --- | --- | --- |
| R49 | Codex | Plan draft. README를 public front-door로 재구성하고, `scaffold-target-maintenance-note` + `forked-harness-adoption-note`를 하나의 adopter guidance slice로 흡수하는 방향 제안. 핵심 경로는 펼친 본문, 긴 절차/보조 다이어그램만 `<details>` 사용. 구현 전 Claude plan review 요청 | Claude review requested |
| R50 | Claude | Plan review: 조건부 승인. 방향 타당(사용자 명시 요청 blank-page README). P1 2건(002 README 재구조화와 reconcile·thinning 보존, 섹션 renumber 시 inbound README 앵커 cascade 검증) + P2 4건 구현 전 반영 | Codex 반영 |
| R51 | Codex | R50 P1/P2를 Plan/Done Criteria/Verification에 반영. 002 regression guard, inbound README anchor cascade, target relative-link 금지, 톤/길이/details 가드를 구현 전 gate로 승격 | 사용자 scope approval 대기 |
| R52 | Codex | 구현 완료. README IA rewrite, generated target README maintenance note, onboarding inbound anchor, STATUS Active pointer 반영. self-validation PASS | Claude result review requested |
| R53 | Claude | Result review: 승인. P0/P1 없음. R50 P1 2건(002 보존·inbound 앵커)+P2 4건 모두 반영 확인, self-validation 재현 PASS(default 68/0, source-gitflow 69/0), target-safe 확인. P2 2건(target README의 Apache attribution 줄, 002 Prologue 제거)은 의도 확인 FYI | 사용자 확인 후 /work-close |
| R54 | Codex | R53 P2 확인 반영. generated target README attribution은 framework file 범위 고지로 유지. 002 Prologue의 사람+복수 AI 협업 모델은 README `Workflow Overview`에 compact diagram으로 복원 | 추가 self-validation 후 /work-close 준비 |
| R55 | Claude | Follow-up review: 승인. P0/P1 없음. 협업 모델 복원·target footer·archive snapshot 모두 R50 P1 승인 무회귀, footer target-safe, self-validation 재현 PASS. P2 1건(archive snapshot 배너 권장, 기존 관례 일치) 비차단 | 사용자 확인 후 /work-close |
| R56 | Codex | R55 P2 반영. archive snapshot 상단에 historical-only 배너 추가, SHA-match provenance 기록은 git history provenance 설명으로 교체 | /work-close 준비 |

### R49 Codex Plan Draft

**결론:** 다음 slice는 `README / Adopter Guidance Overhaul`로 진행하는 것이 좋다. `gate-enforcement-runtime-and-env`로 실제 마찰을 만들기 전에, README에서 사용자 유형별 기대 마찰과 적용 경로를 먼저 분리해야 한다.

검토 요청(P0/P1 우선):

1. README 전체 IA rewrite를 이 slice에 포함하는 것이 적정한가, 아니면 adopter note만 먼저 좁혀야 하는가?
2. source README와 generated target README의 경계가 맞는가?
   - source README: clone/fork maintainer-adopter, upstream-compatible/personal harness mode.
   - target README: framework-owned/project-owned, `--check`, upgrade 미제공·수동 migration 주의.
3. `docs/WORKFLOW-MANUAL.md`와 `docs/SCAFFOLD-ONBOARDING-GUIDE.md`는 pointer consistency만 만지고 deep rewrite를 비목표로 두는 것이 맞는가?
4. `<details>` 사용 기준이 적절한가? 핵심 선택지는 노출하고 긴 절차/보조 다이어그램만 접는 원칙이 맞는가?
5. README 톤을 ai-deck-compiler README처럼 존댓말·초보자 친화로 바꾸되, 과도한 설명으로 길어지는 리스크를 어떻게 제어할 것인가?
6. Verification이 충분한가: stale term grep, ToC/anchor, fresh scaffold default/source-gitflow, source-only fork 안내 target 누수 0, `bash -n`, scaffold invariant.

### R50 Claude Plan Review

**결론: 조건부 승인.** 방향은 타당하고, 무엇보다 사용자가 blank-page README 재검토를 명시 요청했으므로 full IA rewrite를 narrow로 되돌리라고 하지 않는다. adopter modes 분리·target maintenance note·Contributing 추가는 실제 공백을 채운다. 다만 아래 P1 2건은 구현 전 plan에 박아야 안전하다.

**6대 질문 직답:**

1. **Full IA rewrite 적정?** 적정 — 사용자 명시 요청 + 실제 신규 가치(adopter modes/maintenance/contributing) + front-door 재프레이밍. narrow로 강제하지 않는다. 단 P1-1(002 reconcile) 전제.
2. **source/target 경계?** 맞다. adopter modes=source README, framework/project·`--check`·upgrade 미제공=target README 분리가 003/004에서 세운 target-safe 원칙과 정합. `<details>`/Done Criteria/Verification에 source-only link 미누수가 들어가 있어 좋다.
3. **manual/onboarding deep rewrite 비목표?** 정확히 맞다 — 003이 manual을 막 deep-rewrite했으므로 pointer consistency만. 강하게 동의.
4. **`<details>` 기준?** 적정 — 핵심 선택지/scaffold 명령/state-machine은 펼쳐두고 긴 절차·보조 다이어그램만 접는 원칙 동의(P2-3 가드 참고).
5. **톤/길이?** 존댓말 전환은 human front-door로 적절. 길이 제어는 P2-2 참고.
6. **Verification?** 대체로 좋으나 **inbound anchor cascade 누락**(P1-2).

**P1 (구현 전 반영):**

- **P1-1 — 002와 reconcile, thinning 보존.** README는 2일 전 slice #11(CHORE-20260606-002)에서 이미 재구조화됐다(§2 Document Layers에 canonical workflow + tool adapter subgraph 추가, §5 Approval Matrix 전표→개념+pointer 축약, Quick Start 5-step beginner flow, command map canonical/adapter framing). "blank page"로 다시 쓰는 과정에서 이 deliverable을 **무심코 되돌리지 말 것** — 특히 Approval Matrix/Trigger 전표 재호스팅 부활 금지, §2 canonical+adapter 다이어그램 보존. Plan Step 1 inventory에 "002가 이미 확정한 것(보존)" 열을 추가하고, Done Criteria에 "002의 thinning/diagram을 되돌리지 않는다"를 명시할 것. (IA는 재배치하되 002의 SSoT-위임 결정은 유지)
- **P1-2 — 섹션 renumber 시 inbound README 앵커 cascade.** 현재 Verification은 README 자체 ToC 앵커만 본다. 그러나 section 이름/번호를 바꾸면 **다른 파일이 README 섹션을 앵커로 가리키는 inbound 링크**가 깨진다. 실측: `docs/SCAFFOLD-ONBOARDING-GUIDE.md:35`가 과거 New Project Adoption section을 가리킴. (현재 1건이라 작지만 section rename 시 즉시 dangling) → Verification에 **전 repo inbound README anchor grep + 갱신 또는 앵커 보존**을 추가하고, Done Criteria에 "inbound README 앵커 dangling 0"을 넣을 것. (manual은 003 R41/R45에서 prose로 바꿔 안전 — 회귀만 확인)

**P2:**

- **P2-1 톤 vs 정밀도.** README는 human front-door이자 일부 AI 참조 대상(manual/AGENT-WORKFLOW가 가리킴; CLAUDE.md가 자동 로드하진 않음). 존댓말 전환 시 개념 요약의 정밀도(예: Approval Matrix 4-gate 요지)가 흐려지지 않게. 톤은 서술문, 규칙 요지는 정확히.
- **P2-2 길이 규율.** adopter modes+maintenance+contributing 추가로 길어진다. 명시 목표: **README를 002 대비 크게 늘리지 않는다** — 신규 섹션은 tight하게, overview는 더 압축, 긴 절차는 `<details>`/pointer. "blank page"가 분량 증가 핑계가 되지 않게.
- **P2-3 `<details>` 가드.** 첫 결정 경로(adopter mode 선택), scaffold 명령, state-machine 한 줄은 접지 않는다. AI/초보가 default load에서 봐야 할 것은 펼친 채로.
- **P2-4 target maintenance note 안전.** generated target README maintenance note는 source-only 문서(MIGRATION note, SCAFFOLD-ONBOARDING-GUIDE, source-only DR)를 **relative-link하지 않는다**(R41/R45 교훈). 링크가 필요하면 target-copied 문서의 안정 앵커만. Plan에 이미 source-only link 미추가가 있으나 "relative-link 금지 + prose 참조"로 명시 강화 권장.

**위임/미검토:** 실제 README 문장·IA 최종 배치는 구현 후 result review에서. ai-deck-compiler README(Context Manifest #10)는 **톤 참고 한정** — 그 product-specific 구조를 그대로 들여오지 말 것(Plan에 "재해석" 명시돼 있어 동의).

### R51 Codex Response To R50

**R50 조건부 승인 전면 수용.** 구현 전 plan gate에 아래를 반영했다.

- **P1-1 반영:** Plan Step 1을 `README current-state inventory + CHORE-20260606-002 reconcile`로 강화했다. Done Criteria와 Verification에 002 확정분 보존을 추가했다 — canonical workflow + tool adapter diagram/framing, Approval Matrix thinning, command map canonical/adapter framing을 되돌리지 않는다.
- **P1-2 반영:** Verification에 repo 전체 inbound README anchor grep을 추가하고, Done Criteria에 inbound README anchor dangling 0을 추가했다. 현재 확인된 `docs/SCAFFOLD-ONBOARDING-GUIDE.md`의 과거 New Project Adoption anchor 링크는 갱신하거나 앵커를 보존해야 한다.
- **P2 반영:** 존댓말 전환 시 규칙 정밀도 유지, README 길이 규율, 핵심 선택지/scaffold 명령/state-machine 미접기, generated target README에서 source-only relative-link 금지를 Done Criteria로 승격했다.

이제 사용자 scope approval 후 README/script 구현으로 진행한다.

### R52 Codex Implementation Summary

구현 완료. Claude result review를 요청한다.

**변경 파일:**

- `README.md`: public front-door 재구성. Start Here 경로 선택, repository identity, scaffold 적용, adopter modes/maintenance, workflow overview, core concepts, command map, Git Flow, docs map, contributing/license 순서.
- `scripts/create-harness.sh`: generated target README에 `Framework Files & Updating` 섹션 추가. framework-owned/project-owned, `--check`, 자동 upgrade 미제공, 수동 selective migration 주의. README footer에 harness origin/source link/license/copyright notice 추가(프로젝트 자체 copyright로 오인되지 않도록 framework file 범위로 제한).
- `docs/SCAFFOLD-ONBOARDING-GUIDE.md`: inbound README anchor를 `#apply-the-harness-to-your-project`로 갱신.
- `docs/STATUS.md`: CHORE-20260606-005 Active Work pointer 추가, 흡수된 scaffold maintenance Next Action 제거.
- `docs/backlog/HARNESS.md`, `docs/works/harness/README.md`: Work 등록/통합 상태 유지.

**Self-validation PASS:**

- `git diff --check` PASS.
- `bash -n scripts/create-harness.sh` PASS.
- `scripts/tests/check-scaffold-invariants.sh` OVERALL PASS(default minimal + `--with-optional`).
- fresh default scaffold: `summary: 68 tracked, 68 in-sync, 0 drifted`; generated README maintenance note 확인; `fork`, `source-only`, `DR-025`, `SCAFFOLD-ONBOARDING-GUIDE`, `MIGRATION` 누수 0.
- fresh source-gitflow scaffold: `summary: 69 tracked, 69 in-sync, 0 drifted`; `docs/GIT-WORKFLOW.md`에 `policy_type: source-gitflow` 확인; generated README maintenance note 확인.
- README ToC headings 존재 확인.
- inbound README anchor grep: 실제 외부 링크는 `docs/SCAFFOLD-ONBOARDING-GUIDE.md` -> `#apply-the-harness-to-your-project`로 갱신. Work 파일 내부 검토 기록은 historical context.
- README line count: 477 lines(기존 710 lines에서 감소).

**R52 addendum — user follow-up 반영:**

- `workflow-manual` 등 source 문서의 README inbound anchor를 재확인했다. live 문서 기준 `README.md#...` 링크는 `docs/SCAFFOLD-ONBOARDING-GUIDE.md` 1건이며, 갱신된 `#apply-the-harness-to-your-project` anchor가 README에 존재한다. Work 파일 내부 historical 검증 로그는 live dangling 판단에서 제외한다.
- generated target README 하단 footer를 보강했다: `AI Workflow Harness` source origin URL, target-local workflow reference, Apache-2.0/copyright notice를 제공한다. 해당 notice는 scaffolded harness framework files에만 적용된다고 명시해 target project's own product code/content와 경계를 둔다.
- 추가 검증 PASS: `bash -n scripts/create-harness.sh`, `git diff --check`, `scripts/tests/check-scaffold-invariants.sh`, fresh default scaffold `summary: 68 tracked, 68 in-sync, 0 drifted`, target README footer 확인, target README source-only term leak 0(`SCAFFOLD-ONBOARDING-GUIDE`, `MIGRATION`, `DR-025`, `source-only`).

Claude R52 review focus:

1. R50 P1-1: CHORE-20260606-002 확정분 보존 여부 — canonical/adapter diagram/framing, Approval Matrix thinning, command map framing.
2. R50 P1-2: inbound README anchor cascade가 실제로 닫혔는지.
3. source README vs generated target README 경계 — target README에 forked harness source 안내나 source-only DR/link 누수 없음.
4. README tone/length/details guard — 존댓말·초보자 친화이면서 규칙 정밀도 유지, 핵심 선택지/scaffold 명령/state-machine 노출.
5. self-validation 재현 가능성.

### R53 Claude Result Review

**결론: 승인.** R50 P1 2건 + P2 4건이 모두 정확히 반영됐고, self-validation을 직접 재현해 PASS를 확인했다. **P0/P1 결함 없음.** P2 2건은 "의도 확인" FYI(비차단)다. `/work-close` → commit 승인으로 진행 가능.

**검토 기준별 판정:**

| 기준 | 판정 | 근거 |
| --- | --- | --- |
| **R50 P1-1 (002 보존)** | PASS | Repository Structure에 canonical workflow + tool adapter mermaid 보존(`CANON`/`ADAPTERS` subgraph). Approval Matrix 전표 재호스팅 없음 — 개념 + `AGENT-WORKFLOW SSoT` pointer 유지. Command Map canonical/adapter framing 보존 |
| **R50 P1-2 (inbound 앵커)** | PASS | `SCAFFOLD-ONBOARDING-GUIDE.md:35`가 `#apply-the-harness-to-your-project`(실재)로 갱신됨. repo 전체 inbound `README.md#` dangling 0. README 내부 앵커 12개 dangling 0 |
| **source/target 경계** | PASS | fresh target README에 forked/personal-harness 안내 0, source-only DR 0, source-only relative-link 0. maintenance note(Framework Files & Updating)는 framework/project-owned 표 + `--check` + `--upgrade` 미제공·수동 migration을 target-safe prose로만 |
| **tone/length/details** | PASS | 존댓말(입니다/합니다 55회), README 710→**477줄(−233, P2-2 초과 달성)**, `<details>` 2곳은 "첫 세션 흐름"·"maintainer reference"만 접고 scaffold 명령·state-machine·첫 결정 경로는 노출, project-local workspace 경고 보존, `target repo` 미정의 용어 없음 |
| **self-validation 재현** | PASS | `git diff --check`·`bash -n`·scaffold invariants OVERALL PASS, fresh default **68/0 drifted**, source-gitflow **69/0 drifted** — Codex 주장 그대로 재현 |

**P2 (의도 확인 FYI, 비차단):**

- **P2-a:** generated target README의 maintenance note 끝에 **Apache-2.0 framework attribution 한 줄**(`Harness framework origin: AI Workflow Harness, Copyright (c) Kyungseo Park ...`)이 추가됐다. Apache-2.0 notice 보존 측면에서 적절하나, 이제 **모든 scaffold target README가 이 attribution 줄을 갖는다.** 의도된 정책이면 그대로 두고, 원치 않으면 위치를 LICENSE/별도 NOTICE로 옮기는 선택지. 사용자 확인 권장.
- **P2-b:** 002의 **Prologue(여정 요약 + 협업 구조 다이어그램)**가 제거됐다. front-door 간결화(−233줄)로 의도된 것으로 보이며 규칙 자산은 아니지만, "사람+복수 AI 협업 모델" 서사는 고유 콘텐츠였다. 제거 의도면 OK, 보존 원하면 별도 문서나 축약 형태로 옮기는 선택지. 사용자 확인 권장.

**위임/미검토:** 실제 문장 표현의 미세 품질은 사용자 최종 리뷰 영역. P2 2건은 정책 판단이라 사용자 확인 사항으로 남긴다.

다음: P2 확인 후 `/work-close` → commit 승인 → PR `--base develop`. commit/PR/merge는 사용자 승인 후.

### R54 Codex Response To R53

R53 P0/P1 없음 확인. P2 2건은 사용자 피드백과 함께 아래처럼 처리했다.

- **P2-a target README attribution:** 유지한다. 모든 scaffold target README에 harness source origin/license/copyright notice가 들어가는 것은 의도된 정책으로 본다. 단, target project의 자체 product code/content copyright로 오인되지 않도록 "scaffolded harness framework files" 범위로 제한하는 문장을 포함했다.
- **P2-b Prologue 협업 모델:** 제거하지 않고 축약 복원했다. 과거 Prologue 전체(여정 요약/태그 history)는 되살리지 않고, README `Workflow Overview`에 `Human-AI Collaboration Model` subsection을 추가해 사용자 중심, 복수 AI 역할 전환, Work file 공유 SSoT를 compact mermaid diagram으로 설명한다.
- README line count는 511 lines로, 기존 710 lines 대비 여전히 감소 상태다.
- **Archive preservation:** pre-rewrite README 전체를 `docs/archive/snapshots/README-before-CHORE-20260606-005.md`에 보존했다. 이는 rollback SSoT가 아니라, Prologue/협업 서사 등 축약된 문서 자산의 historical snapshot이다. 최초 생성 시 `git show HEAD:README.md`와 archive snapshot의 SHA-256 동일성을 확인했고, 이후 R55에 따라 historical-only 배너를 추가했다.

### R55 Claude Follow-Up Review

**결론: 승인. P0/P1 없음.** R53 P2 2건 처리와 P2 follow-up 3종(협업 모델 복원, target footer, archive snapshot)이 모두 R50 P1-1/P1-2 승인 상태를 깨지 않고 깨끗하게 반영됐다. self-validation 재현 PASS. P2 1건만 비차단 제안으로 남긴다.

**변경 초점별 판정:**

| 초점 | 판정 | 근거 |
| --- | --- | --- |
| 1. Human-AI Collaboration Model | PASS | `Workflow Overview` 아래 compact subsection(42줄, mermaid 1개). README 477→**511줄**(여전히 710 대비 −199). front-door 흐름·길이 해치지 않음. (P2-b 참고: 보조 다이어그램이라 `<details>` 선택지도 있으나 사용자가 복원 요청한 고유 자산이라 펼침 유지 수용) |
| 2. generated target README footer | PASS | fresh target 확인 — origin URL + `docs/HARNESS-QUICK-REFERENCE.md`(target-copied) 링크 + Apache notice. notice가 **"scaffolded harness framework files, not this project's own product code or content"**로 한정됨(R53 P2-a 정확 해소). source-only DR/link/fork 안내 누수 0 |
| 3. pre-rewrite README archive snapshot | PASS(+P2 제안) | `docs/archive/snapshots/`에 historical로 보존. 단 **기존 snapshot 관례와 불일치**(아래 P2) |
| 4. 회귀 | PASS | README 내부 앵커 dangling 0, canonical+adapter diagram 보존, Approval Matrix 전표 재호스팅 없음, inbound `README.md#` dangling 0, scaffold invariants OVERALL PASS. `bash -n`·`git diff --check` PASS |

**P2 (비차단 제안):**

- **P2 — archive snapshot에 historical 배너 권장.** 새 `README-before-CHORE-20260606-005.md`는 verbatim(`# ai-workflow-harness`로 바로 시작, SHA가 HEAD README와 일치)이라 **헤더 배너가 없다.** 그러나 기존 snapshot 관례는 배너가 있다 — `docs/archive/snapshots/harness-refactor-20260514/`는 "# Harness Refactor Backup Manifest — 2026-05-14 / 이 디렉터리는 ... 백업 스냅샷이다" 헤더를 둔다. 일관성과 "live SSoT 오인 방지"를 위해 상단에 1줄 배너(예: `> ARCHIVED snapshot of README.md before CHORE-20260606-005. Historical only — live front-door는 repo root README.md.`) 추가 권장. **단 SHA-match provenance는 깨진다** — git history(`git show <commit>:README.md`)가 이미 provenance를 제공하므로 SHA-match보다 discoverability를 택하는 편을 권장. (경로/파일명이 이미 historical을 어느 정도 시사하므로 비차단)

**위임:** 실제 문장 미세 품질은 사용자 최종 리뷰. P2는 정책/스타일 판단이라 사용자 결정 사항.

다음: P2(배너) 적용 여부 결정 후 `/work-close` → commit 승인 → PR `--base develop`. 적용 생략해도 승인에는 영향 없음.

### R56 Codex Response To R55

R55 P2를 반영했다.

- `docs/archive/snapshots/README-before-CHORE-20260606-005.md` 상단에 historical-only 배너를 추가했다.
- 배너 문구는 live front-door가 repository root `README.md`임을 명시해 snapshot이 현재 SSoT처럼 읽히지 않게 한다.
- SHA-match provenance는 의도적으로 포기했다. 원본 provenance는 git history(`git show <pre-rewrite-ref>:README.md`)로 확인 가능하며, archive 파일은 discoverability와 오인 방지를 우선한다.

## Discovery

- Branch renamed from `feature/forked-harness-adopter-note` to `feature/chore-20260606-005-readme-adopter-guidance-overhaul` because scope expanded from one backlog note to README IA + adopter guidance.
- User explicitly requested that README be reconsidered from a blank-page perspective while preserving core context.
- User preference: README should be friendly, Korean 존댓말, beginner-readable, closer in tone to `ai-deck-compiler` README.
- User concern: "target repo" in Quick Start may be unclear before definitions. Plan should either remove Quick Start or replace it with a path-selection "Start Here".
- User concern: this repo should not be directly converted into a project-local workspace; keep this warning.
- Details blocks are useful, but only for secondary flow diagrams/procedures. Do not hide the user's first decision path.
- Previous backlog candidate `scaffold-target-maintenance-note` and just-added `forked-harness-adoption-note` are now consolidated into this Work to avoid duplicate adopter guidance slices.
