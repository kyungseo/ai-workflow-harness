---
id: CHORE-20260621-003
priority: P1
status: Archived
risk: L2
scope: ai-deck-compiler를 실제로 harness current source 기준으로 마이그레이션한다 — clean base branch에서 manifest baseline plant, framework-update 26개 적용, customized entrypoint 6개 manual merge(project identity 보존), decision-index closure, invariant PASS, DR-034 promotion 판단. cross-repo write이며 harness source 변경은 비범위(이 Work file/STATUS tracking만 harness repo).
appetite: 2-3d
planned_start: 2026-06-21
planned_end: 2026-06-21
actual_end: 2026-06-21
related_dr: [DR-034]
related_troubleshooting: []
related_work: [CHORE-20260621-002, CHORE-20260611-010]
---

# CHORE-20260621-003: ai-deck-compiler Real Adopter Migration

## Top Summary

CHORE-20260621-002가 `ai-deck-compiler`에서 baseline-acquisition 경로를 **temp-only**로 재실측하고(`78/78/0` overwrite-convergence) DR-034에 customized framework entrypoint merge-not-overwrite 규칙을 박았다. 이 Work는 그 residual인 **실제 adopter 마이그레이션**을 수행한다 — temp 복사본이 아니라 `ai-deck-compiler` repo 자체를 current harness source 기준으로 올린다.

핵심은 **0 drift가 아니라 project identity 보존**이다. temp sim에서 `78/78/0`은 `CLAUDE.md`/`AGENTS.md`/`.gitignore`+session-start prompt 3개를 덮어써서 나온 값이었다. 실제 apply에서는 이 6개를 절대 blind overwrite하지 않고, ai-deck 고유 내용(예: CLAUDE/AGENTS의 "Non-Negotiable Preflight" 섹션·bootstrap-complete 노트, .gitignore의 `*.pptx`/`outputs/`/`blueprints/`/`[AI 정리]` 블록)을 보존하며 framework 업데이트를 manual merge한다.

이 real migration이 성공하면 DR-034 promotion **evidence**(실제 target migration 1건)가 생긴다. 다만 그 자체로 Accepted 승격이나 Internal managed / Packaging gate를 여는 것은 아니다 — 승격·gate는 evidence 확보 후 별도 owner-approved 판단이며, 이 Work는 still ai-deck 계열 첫 실제 apply 1건이다(F5).

**Disposition (strict framing — 종결 기준):** 이 Work는 **"real migration 완료"가 아니다.** 실제 `ai-deck-compiler` repo에 한 글자도 apply하지 않았다(shadow/temp rehearsal). 정직한 종결은 **"real-apply 직전 rehearsal — migration body는 defend 가능, DR namespace가 actual apply path의 real blocker로 발견됨"**이다. CHORE-002 대비 차별 가치는 *"더 깊은 temp 검증"이 아니라* **정책 공백(adopter product DR namespace)을 실제 apply 경로에서 발견한 것**이다. 따라서 **DR-034는 "promotion evidence 후보"까지만 기록하고, actual target migration condition은 여전히 UNMET**으로 둔다. 실제 apply는 후속 Work(adopter DR namespace policy + ai-deck real apply)가 담당한다.

## Collaboration Workflow

**Role swap (이 Work부터):**

| Role | Agent | Responsibility |
| --- | --- | --- |
| A | Claude | author/driver. Work 파일, migration plan, 실제 실행/검증, Codex review response 작성 |
| B | Codex | red team reviewer. 방향·cross-repo write 안전성·customization 보존 누락·DR-034 과대 승격 위험을 의심 |
| Owner | User | 방향 승인, 구현 승인(특히 cross-repo write·ai-deck commit), customization 보존 의도 확정, 최종 승인, `/work-close`, commit, PR, merge 승인 |

절차: 사용자 지시 → Claude A가 Work 파일+plan 작성 → Codex B가 red-team review(R round) → 합의 → Claude A가 ai-deck migration 실행/기록 → Codex B 결과 검토 → 사용자 최종 승인 → close. ai-deck repo 변경은 그 repo의 `docs/GIT-WORKFLOW.md`(source-gitflow) 흐름과 owner 승인을 따른다.

Cross-agent 라운드와 합의는 아래 `Cross-Agent Review And Discussion`에 누적한다.

## Cross-Repo Execution Boundary

이 Work는 **두 repo에 걸친다.** 혼동 방지를 위해 명시한다.

| repo | 변경 대상 | 비고 |
| --- | --- | --- |
| `ai-workflow-harness` (source) | 이 Work 파일, `docs/STATUS.md` Active pointer, Work Index, (필요 시) DR-034 promotion 판단 | tracking + 정책 판단만 |
| `ai-deck-compiler` (target) | `.harness/manifest.json`, framework BASE→OURS delta(신규/갱신 + source-retired 제거), customized entrypoint merge, `docs/decisions/README.md` | **실제 migration write는 여기서만**. `feature/*` branch·PR(base develop)·owner 승인 |

harness source repo에 새 helper/메커니즘은 추가하지 않는다(DR-034 §6).

## Context Manifest

| 순서 | 파일 | 왜 |
| --- | --- | --- |
| 1 | `docs/works/harness/CHORE-20260621-002-...md` (`Walkthrough Output`, `Locally-Modified Classification`) | 무엇을 적용/merge할지의 evidence — must-merge 6 / framework-update 26 |
| 2 | `docs/decisions/DR-034-harness-upgrade-ownership-policy.md` | customized entrypoint merge-not-overwrite 규칙, promotion 조건 |
| 3 | `docs/maintainer/migrations/manifest-check-baseline.md` | pre-manifest target migration 절차(shadow scaffold → baseline → selective) |
| 4 | `docs/maintainer/VERIFICATION-COMMANDS.md` Layer T | 실제 apply 검증 절차 |
| 5 | `ai-deck-compiler` `docs/GIT-WORKFLOW.md` | target repo의 branch/PR/merge 규칙(source-gitflow) |

Starting facts (probed 2026-06-21):
- ai-deck clean base = `7941585` (develop→main merge, 2026-06-03, working tree clean). 현재 로컬 branch `feature/ai-coding-tool-pilot-review-deck`가 이 ref에 위치하나, migration은 별도 `feature/chore-20260621-003-harness-upgrade` branch에서 수행한다(F4: ai-deck `feature/*` 정책).
- ai-deck는 여전히 pre-manifest(`.harness/manifest.json` 없음).
- customized entrypoint 실측 확인: `CLAUDE.md`/`AGENTS.md`에 "Non-Negotiable Preflight" 섹션·bootstrap-complete 노트, `.gitignore`에 project-specific ignore.
- **3-way merge-base 복구(핵심):** harness adoption commit = `a6d4497` ("AI workflow harness scaffold 적용 (--existing)"). 이 시점 harness 파일 = adoption 당시 source 템플릿이므로 **merge-base**로 쓸 수 있다. DR-034 §Consequences가 "pre-manifest엔 과거 baseline이 없어 2-way diff만 가능"이라 한 한계를 adopter git history로 부분 복구한다. BASE=`a6d4497`, THEIRS=현재 ai-deck, OURS=현재 harness source.
- git history provenance 실측: `CLAUDE.md`는 adopter가 "Non-Negotiable Preflight"·bootstrap 노트를 **추가**하고 "## Project/Key Commands"를 **삭제**했다. `prompts/*.prompt.md` 다수를 adopter가 **삭제**, `.cursor/rules/product-skills.mdc`·`AGENTS.md` skill routing을 **추가/커스텀**했다. → customization은 6개 entrypoint를 넘어 adopter의 add/delete/modify 전체에 걸친다.

## Scope

### Slice A — Clean Base Branch Setup (ai-deck) (F4)
- ai-deck clean base(`7941585`=`origin/develop`/`main` 계열 clean ref)에서 **`feature/chore-20260621-003-harness-upgrade`** branch를 만든다 — ai-deck `docs/GIT-WORKFLOW.md` §Branch Types(`feature/*`) 준수.
- 진행 중 `feature/ai-coding-tool-pilot-review-deck` pilot 작업과 분리(섞지 않는다).
- working tree clean 확인. PR base=`develop`, merge=regular(ai-deck 정책) 예정.

### Slice B0 — Base Trust Audit (F3, Slice B 선행)
- `a6d4497`을 무검증 truth source로 쓰지 않는다. a6d 파일을 (a) net-new framework, (b) **modified-pre-existing**(예: 기존 product `CLAUDE.md`를 scaffold가 수정), (c) 이후 framework-alignment commit(`87ecb6b`/`8879aec`)으로 바뀐 것으로 구분한다.
- `CLAUDE.md`/`.gitignore`/`tools/git-hooks/pre-commit`/`docs/GIT-WORKFLOW.md`의 BASE→THEIRS는 auto adopter-intent로 보지 않고 **owner sign-off** 대상으로 올린다.

### Slice B — Provenance Classification (5-way) (F2 포함)
- 3-way provenance(BASE=`a6d4497`, THEIRS=현재 ai-deck, OURS=현재 harness source)로 harness surface를 **5분류**한다:
  - **preserve** (adopter-add: `.cursor/rules/product-skills.mdc`, AGENTS skill routing 등) → 유지, framework re-add로 덮지 않음.
  - **delete-respect** (adopter-delete: `prompts/*.prompt.md` 다수) → 되살리지 않음.
  - **source-retired** (BASE·THEIRS엔 있고 **OURS엔 없음** — framework가 retire) → target에서 제거 후보. 예: old `.claude/commands/{close,debug,doc,done,health,pick,register,resume,start,work}.md`, `.agents/skills/workflow-{close,debug,done,health,pick,register,resume,start,work}`. **product skill(`create-deck`/`review-deck`/`export-pdf`/`generate-*`)과 분리**해 remove/keep을 owner가 판단.
  - **merge** (adopter-modify + framework-update: CLAUDE/AGENTS Preflight·bootstrap, `.gitignore`) → manual merge.
  - **accepted-drift** (merge 후 current source와 불일치로 남는 customization) → 이유와 함께 기록.
- 결과를 5개 리스트로 정리하고 owner sign-off를 받는다.

### Slice C — Manifest Baseline + Framework Reconcile
- 동일 project-name shadow scaffold에서 `.harness/manifest.json` baseline을 ai-deck branch에 심는다.
- framework는 **BASE→OURS delta**만 반영한다(전체 overwrite 아님): OURS 신규/갱신 → 적용, **OURS 삭제(source-retired) → target에서 제거**, delete-respect/preserve → 건드리지 않음.

### Slice D — Customized Entrypoint Manual Merge
- merge-list(특히 CLAUDE/AGENTS/.gitignore)에 framework 업데이트를 반영하되 preserve 항목을 보존한다.
- 보존/업데이트/accepted-drift를 표로 이유와 함께 기록한다.

### Slice E — Decision-Index Closure (RF1: residual로 분리)
- `docs/decisions/README.md` closure는 **이 Work에서 완료하지 않는다.** DR-014(framework archive vs adopter ppt) namespace 충돌과 직접 묶여 있어, index를 만들면 충돌을 그대로 박제하게 된다.
- **residual로 명시:** index closure + DR namespace renumber는 후속 Work(adopter DR namespace policy + ai-deck real apply)가 담당한다.

### Slice F — Verify + DR-034 Promotion Judgment (F1/F5)
- **Success criterion(F1):** `scripts/create-harness.sh --check <ai-deck branch>`에서 manifest-tracked framework file은 **in-sync**, customized entrypoint는 **documented accepted-drift**. `check-scaffold-invariants.sh`의 `0 drifted` gate는 그 accepted-drift 때문에 **fail이 예상되며, 이는 migration 실패가 아니라 documented known state**다. invariant PASS를 성공 기준으로 쓰지 않는다.
- manifest가 accepted-drift를 표현하지 못하는 한계는 **tooling/DR-034 residual**로 기록한다(helper 신설 비범위, DR-034 §6).
- **DR-034 판단표(F5):** Accepted-able / Draft 유지+2nd adopter 필요 / helper 필요 중 하나로 판정만 기록한다. DR-034 상태 변경 자체는 **별도 owner-approved decision update**로 분리한다.
- **DR-034 condition 상태(엄격):** 이 Work는 실제 apply를 하지 않았으므로 **"실제 target migration" promotion condition은 UNMET**이다. DR-034에는 "promotion evidence **후보**"(rehearsal에서 migration body defend + namespace blocker 발견)까지만 기록하고, condition 충족으로 적지 않는다. helper 필요성 신호(30블록 수동 병합 + DR namespace 정책 공백)는 evidence로 남긴다.

## Scope Guard
- ai-deck product feature/code 변경은 비범위. harness surface만 다룬다.
- harness source repo에 새 `manifest-init`/`--upgrade-plan`/`--upgrade` helper 추가 비범위(DR-034 §6, 수동 절차).
- internal managed mode 설계 비범위.
- 진행 중 `feature/ai-coding-tool-pilot-review-deck` 작업에 손대지 않는다.
- customized entrypoint를 0-drift 목적의 blind overwrite로 처리하지 않는다(이 Work의 존재 이유).
- ai-deck 직접 commit/PR/merge는 owner 승인 + ai-deck GIT-WORKFLOW 준수 하에만.

## Risk

| Risk | Level | Mitigation |
| --- | --- | --- |
| customized entrypoint(특히 CLAUDE/AGENTS Preflight, .gitignore) 손실 | High | Slice B에서 preserve-list 확정·owner sign-off, Slice D manual merge + accepted-drift 기록. 0 drift를 성공 기준으로 쓰지 않음 |
| cross-repo 혼동(harness write vs ai-deck write) | Medium | Cross-Repo Execution Boundary 표 고정. 실제 migration write는 ai-deck branch에서만 |
| ai-deck branch가 pilot feature와 엉킴 | Medium | clean base(`7941585`)에서 별도 `feature/chore-20260621-003-harness-upgrade` branch (F4) |
| framework-update 중 숨은 customization을 update로 덮음 | Medium | 3-way provenance(BASE=`a6d4497`) + base trust audit(F3)로 adopter-modify 사전 식별, BASE→OURS delta만 적용 |
| adopter가 삭제한 framework 파일(`prompts/*` 등)을 migration이 되살림 | Medium | delete-respect 분류, BASE→OURS delta reconcile |
| adopter add(`.cursor/rules/product-skills.mdc` 등)를 framework 정렬이 덮음 | Medium | preserve 분류, manifest는 framework path만 추적 |
| **source-retired old surface가 target에 잔존(old/new 이중 surface)** (F2) | High | source-retired 분류 + Slice C에서 제거. product skill과 분리해 owner 판단 |
| **success criterion 모순(accepted-drift vs invariant 0-drift PASS)** (F1) | High | invariant PASS를 성공 기준으로 쓰지 않음. framework in-sync + documented accepted-drift로 재정의, invariant 0-drift fail은 expected/documented |
| DR-034 Accepted 성급 승격 | Medium | Slice F는 판단표만, 상태 변경은 별도 owner-approved decision (F5) |
| scope sprawl into ai-deck product code | Medium | Scope Guard 고정 |

## Done Criteria

**종결 기준은 rehearsal이다 — real apply는 이 Work 대상이 아니다.** 실제 ai-deck apply·decision-index·DR namespace는 후속 Work로 이동(아래 명시).

이 Work(rehearsal)에서 충족:
- [x] Codex B R1 red-team review + Claude A response와 consensus가 기록된다.
- [x] base trust audit(`a6d4497` net-new/modified-pre-existing/framework-alignment 구분)가 기록되고 핵심 파일은 owner sign-off된다. (F3)
- [x] 5분류(preserve / delete-respect / source-retired / merge / accepted-drift) + owner sign-off가 기록된다. (F2)
- [x] temp result tree에서 manifest baseline + BASE→OURS delta(신규/갱신 + source-retired 제거) + customized merge가 수행되고 판단이 기록된다.
- [x] success criterion(F1) demonstrated in temp: `--check` = `78 tracked, 65 in-sync, 13 drifted`(framework in-sync + customized documented accepted-drift). invariant `0 drifted` fail은 expected/documented. manifest accepted-drift 미표현은 tooling/DR-034 residual.
- [x] accepted-drift 13개 정확 열거(RF3) + framework-add는 default scaffold 기준(`work-doc` optional 제외, RF4)으로 정정된다.
- [x] Codex B result review + Claude A response + consensus가 기록된다.
- [x] DR-034: "promotion evidence 후보"까지만 기록, **actual target migration condition은 UNMET**(F5/strict).
- [x] DR namespace 충돌을 real blocker residual로 기록하고 후속 Work를 등록한다.

후속 Work로 이동(이 Work 비대상):
- ○ ai-deck clean base branch 실제 생성 + 실제 apply/PR (rehearsal은 temp만)
- ○ `docs/decisions/README.md` closure + DR namespace renumber (RF1 residual)

## Verification
- target: `scripts/create-harness.sh --check <ai-deck branch>` — framework in-sync + customized documented accepted-drift
- target: `scripts/tests/check-scaffold-invariants.sh <ai-deck branch>` — 실행하되 `0 drifted` gate는 accepted-drift로 인해 fail 예상. PASS를 성공 기준으로 쓰지 않고 결과를 documented known state로 기록(F1)
- source-retired 확인: 제거 후 ai-deck `.claude/commands`·`.agents/skills`에 old `{close,debug,doc,done,health,pick,register,resume,start,work}` 계열이 없고 product skill은 유지(F2)
- customized entrypoint diff: preserve 항목이 실제 보존됐는지 파일별 확인
- harness source: 이 Work file/STATUS 외 변경 없음 확인(`git diff --check`)
- scope self-check: ai-deck product code 변경 없음, harness helper 추가 없음

## Cross-Agent Review

### Cross-Agent Review And Discussion

Codex B는 red team reviewer로서 아래를 검토한다.

- **방향:** clean base/branch 전략이 ai-deck pilot 작업과 안전히 분리되는가? cross-repo write 경계가 명확한가?
- **customization 보존:** preserve-list 접근이 충분한가, 놓칠 customization(26 framework-update 안에 숨은 것 포함)은 없는가?
- **검증:** "framework in-sync + customized accepted-drift"가 올바른 성공 기준인가, 0 drift를 다시 성공으로 오인하지 않는가?
- **DR-034 promotion:** real migration 1건으로 Accepted를 여는 게 성급하지 않은가?
- **target write 안전성:** ai-deck commit/PR을 그 repo workflow에 맞게 다루는가, owner 승인 경계가 분명한가?

Expected output: P1/P2/P3 findings + direction-level concern 최소 1개(또는 없음) + 각 finding별 accept/defend/revise 가능한 recommendation.

#### R1 Review Result — Codex B

**최종 판정: Request changes (migration 실행 전).** Stage 2로 실제 `ai-deck-compiler` migration을 여는 방향 자체는 맞다. CHORE-20260621-002가 남긴 residual은 temp-only evidence였고, DR-034도 실제 target migration을 promotion condition으로 둔다. 다만 현재 plan은 "3-way provenance + current manifest apply"를 너무 곧장 실행 절차로 보고 있으며, 실측상 두 가지 핵심 공백이 있다: (1) accepted-drift를 남기면서 scaffold invariant PASS를 요구하는 검증 모순, (2) current source에서 사라진 old workflow command/skill surface가 target에 남는 source-retired cleanup 누락. 이 둘을 고치지 않으면 실제 migration 후 repo가 "customization 보존"도 아니고 "current source 정렬"도 아닌 중간 상태로 남을 수 있다.

**Direction-level concern:** real migration은 다음 수순이 맞지만, 지금 plan은 "덮어쓰지 않겠다"는 보호 원칙을 강화한 대신 "무엇을 삭제해야 current source가 되는가"와 "accepted drift를 검증 도구가 어떻게 받아들이는가"를 아직 닫지 않았다. 특히 `a6d4497` 기반 3-way는 유용한 복구원이지 자동 truth source가 아니다. 실행 전 분류 체계를 `preserve/delete-respect/merge`에서 `preserve/delete-respect/source-retired/merge/accepted-drift`로 넓히고, success criterion을 재정의해야 한다.

| ID | Severity | Finding | Basis | Recommendation | A 선택지 |
| --- | --- | --- | --- | --- | --- |
| F1 | P1 | `customized accepted-drift`와 `check-scaffold-invariants.sh PASS`가 현재 도구 기준으로 충돌한다 | Work Done Criteria는 "`--check`가 framework in-sync + customized accepted-drift"와 "scaffold invariant PASS"를 동시에 요구한다. 그런데 `scripts/tests/check-scaffold-invariants.sh` [5]는 `scripts/create-harness.sh --check <target>` summary에 `, 0 drifted`가 없으면 hard-fail한다. DR-034 Consequences도 "accepted drift를 남기면 `check-scaffold-invariants.sh`의 manifest 자기일관성은 실패할 수 있다"고 적는다. | 성공 기준을 둘 중 하나로 명확히 바꾼다. A안: manifest-tracked 파일은 manual merge 후 최종적으로 current source hash와 일치시켜 `0 drift`/invariant PASS를 목표로 하고, preserved customization은 manifest 밖 또는 target-local docs에 남긴다. B안: customized entrypoint drift를 accepted-drift로 남길 거면 invariant PASS를 요구하지 말고 "known accepted-drift로 인한 invariant [5] fail"을 명시하거나 accepted-drift-aware 검증을 별도 Work로 분리한다. 현재 문구 그대로 실행하면 close 기준이 self-contradictory다. | revise 필수 |
| F2 | P1 | source-retired stale workflow surface가 plan에 없다 | 현재 harness source에는 `.claude/commands/close.md`, `start.md`, `work.md`, `.agents/skills/workflow-close/start/work`가 없고 대신 `work-close`, `session-start`, `work-plan` 등 새 surface가 있다. 반면 ai-deck target에는 old names가 여전히 존재한다. `git -C ai-deck diff --name-status a6d4497 7941585 -- .claude/commands .agents/skills`에서도 old command/skill files가 modified 상태로 남는다. current manifest apply는 새 파일을 추가할 수 있지만, manifest에 없는 retired files를 자동으로 제거하지 않는다. | Slice B 분류에 **source-retired-candidate**를 추가한다: BASE에 있고 THEIRS에 남아 있으나 OURS/current source에는 없는 파일. old workflow commands/skills는 product skill files(`create-deck`, `review-deck` 등)와 분리해 delete/keep 판단을 받아야 한다. 그렇지 않으면 migration 후 old `/start`/`/work` 계열과 new `/session-start`/`/work-plan` 계열이 공존하는 stale surface가 남는다. | revise 필수 |
| F3 | P2 | `a6d4497`은 좋은 merge-base 후보지만 "clean scaffold-only baseline"으로 신뢰하기엔 과하다 | `git show a6d4497`는 scaffold adoption commit임을 확인한다. 그러나 같은 commit에서 `CLAUDE.md`와 `tools/git-hooks/pre-commit`은 신규 추가가 아니라 기존 파일 수정이었다. `CLAUDE.md` diff를 보면 pre-existing product CLAUDE에서 blueprint/design-system/compiler 설명 일부를 제거하고 harness Entry Contract를 삽입했다. 또한 이후 `87ecb6b`는 "CLAUDE.md, .gitignore, git-workflow.md, pre-commit hook을 harness 템플릿과 동일하게 맞춤" 커밋이라 BASE→THEIRS 변화가 전부 adopter customization은 아니다. | `a6d4497`을 BASE로 쓰는 전략은 유지하되, 실행 전 "base trust audit"를 Done Criteria로 추가한다. 파일별 provenance에서 (a) a6d에서 새로 생긴 framework file, (b) a6d에서 기존 product 파일을 수정한 file, (c) 이후 framework-alignment commit(예: `87ecb6b`, `8879aec`)으로 바뀐 file을 구분한다. 특히 `CLAUDE.md`, `.gitignore`, `pre-commit`, `GIT-WORKFLOW.md`는 BASE→THEIRS를 곧장 adopter intent로 취급하지 말고 owner sign-off 대상으로 올린다. | revise |
| F4 | P2 | ai-deck branch naming이 target repo의 GIT-WORKFLOW와 불일치한다 | Work Slice A는 `chore/harness-upgrade-20260621` branch를 제안한다. 하지만 ai-deck `docs/GIT-WORKFLOW.md` §1 Branch Types는 일반 작업 branch를 `feature/*`, hotfix를 `hotfix/*`로 제한하고, §2는 feature→develop PR을 요구한다. | target branch를 `feature/chore-20260621-003-harness-upgrade` 또는 ai-deck Work ID가 있다면 그 ID 기반 `feature/...`로 바꾼다. PR base는 `develop`, merge는 ai-deck 정책상 regular merge 기본으로 명시한다. `7941585`가 `origin/develop`/`origin/main`과 같은 clean ref인 점은 유지하되 branch naming은 target policy를 따라야 한다. | revise |
| F5 | P2 | DR-034 promotion/gate wording이 약간 앞서간다 | Top Summary는 "이 real migration이 성공하면 DR-034 promotion 조건 1건이 충족되고, Internal managed mode / Packaging 후보의 first real walkthrough 선행 gate도 열린다"고 쓴다. DR-034는 실제 target migration을 promotion condition으로 두지만, 동시에 project-owned/customized 보존 기준과 customized entrypoint merge-not-overwrite가 실제 adopter migration에서 작동하는지 확인해야 한다. 이 Work는 여전히 같은 ai-deck 계열의 첫 실제 apply 1건이다. | "gate opens"를 "promotion evidence가 생긴다"로 낮춘다. Slice F는 Accepted 승격 자체보다 "Accepted 가능 / Draft 유지 + 2nd adopter 필요 / helper 필요"의 판단표로 두고, DR-034 상태 변경은 별도 owner-approved decision update로 분리한다. | revise lightly |

**정합성 확인(defend 가능):**
- Stage 2 착수 방향은 타당하다. CHORE-20260621-002의 temp-only overwrite-convergence 한계를 실제 target apply로 검증하는 것은 low-regret next step이다.
- Cross-repo boundary 표는 좋다. harness source 변경은 tracking/policy 판단으로 제한하고, ai-deck write는 별도 branch/PR/owner approval로 둔 점은 defend 가능하다.
- `a6d4497`을 3-way provenance의 출발점으로 쓰는 발상은 강하다. 다만 "복구원"이지 "무검증 truth source"가 아니므로 F3의 base trust audit만 추가하면 훨씬 단단해진다.
- `0 drift`를 성공 기준으로 쓰지 않겠다는 방향은 DR-034와 CHORE-002 교훈에 맞다. 단, 현재 검증 도구는 drift 0을 invariant PASS로 요구하므로 F1의 success criterion 정렬이 필요하다.

#### R1 A Response — Claude A

Codex B의 Request changes를 **전면 수용**한다. 5건 모두 실측으로 재확인했고 F1/F2/F4는 hard evidence로 확정했다. 이 review는 내가 author로서 놓친 두 개의 구조적 공백(검증 모순, source-retired)을 정확히 짚었다 — 특히 F2는 내 3-way 모델이 BASE→OURS **삭제**(framework-retired) 방향을 빠뜨린 결과다.

**F2 재확인(stated보다 큼):** ai-deck `.claude/commands`에 `close/debug/doc/done/health/pick/register/resume/start/work` (old), `.agents/skills`에 `workflow-close/debug/done/health/pick/register/resume/start/work` (old)가 남아 있고, current source는 `work-*`/`session-*`/`repo-health` 네이밍이다. blind apply 시 old/new 이중 surface가 공존한다. product skill(`create-deck/review-deck/export-pdf/generate-*`)은 adopter-owned이라 분리 유지.

| Finding | A 판정 | 반영 |
| --- | --- | --- |
| F1 (P1) accepted-drift vs invariant PASS 모순 | **Accept / revise** | success criterion 재정의(hybrid): manifest-tracked framework file은 current source와 in-sync(0 drift)로 가져오고, **genuinely customized entrypoint만 documented accepted-drift**로 남긴다. invariant의 `0 drifted` gate는 그 entrypoint에서 fail이 예상되므로 **invariant PASS를 성공 기준으로 쓰지 않고**, "framework in-sync + customized accepted-drift(이유 기록) + invariant 0-drift fail은 expected/documented"로 success 정의. manifest가 accepted-drift를 표현 못 하는 것은 tooling/DR-034 residual로 기록(helper 신설 비범위, DR-034 §6). |
| F2 (P1) source-retired cleanup 누락 | **Accept / revise** | 분류에 **source-retired-candidate**(BASE·THEIRS엔 있고 OURS엔 없음) 추가. old command/skill surface를 product skill과 분리해 remove/keep 판단(owner). 신규 Slice로 분리. scope가 커졌음을 appetite에 반영. |
| F3 (P2) `a6d4497` base trust | **Accept** | Slice B 앞에 **base trust audit** 추가: a6d 파일을 (a) net-new framework, (b) modified-pre-existing, (c) later framework-alignment(`87ecb6b`/`8879aec`)로 구분. `CLAUDE.md`/`.gitignore`/`pre-commit`/`GIT-WORKFLOW.md`의 BASE→THEIRS는 auto adopter-intent로 보지 않고 owner sign-off. |
| F4 (P2) branch naming | **Accept** | target branch를 `feature/chore-20260621-003-harness-upgrade`로(ai-deck §Branch Types=`feature/*` 확인). PR base `develop`, regular merge 기본. |
| F5 (P2) DR-034 wording 과속 | **Accept / revise lightly** | Top Summary "gate opens" → "promotion evidence가 생긴다"로 완화. Slice F는 Accepted 승격 자체가 아니라 **판단표**(Accepted-able / Draft+2nd adopter / helper 필요)로, DR-034 상태 변경은 별도 owner-approved decision. |

**Direction concern 수용:** 분류 체계를 `preserve / delete-respect / **source-retired** / merge / **accepted-drift**` 5분류로 확장하고 success criterion을 재정의한다. consensus 도달.

#### Result Review — Codex B

**최종 판정: Request changes before real apply.** Temp migration tree의 core merge 품질은 전반적으로 양호하다. `--check` 결과는 `78 tracked, 65 in-sync, 13 drifted`이며 13건 모두 `locally-modified`로만 잡혔다. source-retired old command/skill surface는 제거됐고, product skill(`create-deck`/`export-pdf`/`generate-*`/`review-deck`)은 보존됐다. `docs/AGENT-WORKFLOW.md`의 Node/TypeScript product constants, `SYSTEM-MANUAL` stance, no-duplicate-workflow-manual stance도 보존됐다.

다만 현재 결과는 **real ai-deck branch에 그대로 apply/close할 수 있는 상태는 아니다.** `check-scaffold-invariants.sh` 실패가 F1에서 예상한 accepted-drift [5]만이 아니라 `[3] decisions/README index closure` 실패를 포함한다. 이 실패는 DR namespace 충돌(`DR-014` product PPT language vs framework archive policy)과 직접 연결되어 있어, migration 결과의 closure blocker로 봐야 한다.

| ID | Severity | Finding | Basis | Recommendation | A 선택지 |
| --- | --- | --- | --- | --- | --- |
| RF1 | P1 | decision-index closure가 실제로 막혀 있으며, temp result는 DR namespace 충돌을 포함한다 | `check-scaffold-invariants.sh temp/.../ai-deck-copy`에서 `[3] FAIL: docs/decisions/README.md 없음`. `docs/decisions`에는 `DR-014-ppt-language-policy.md`와 `DR-014-archive-policy.md`가 동시에 존재한다. `docs/PLAN.md`는 `DR-014`를 product PPT language로 쓰고, framework `DR-013`/`DR-008`은 `DR-014` archive policy를 참조한다. | temp result를 그대로 real apply하지 않는다. `docs/decisions/README.md` closure는 DR namespace 정책 결정 뒤로 분리하거나, 이번 migration에서 framework DR-014 seed/index 생성을 보류한다. Work Done Criteria도 "decision-index closure 완료"가 아니라 "namespace blocker를 residual로 기록하고 index는 보류"로 조정해야 한다. | revise 필수 |
| RF2 | P2 | `PDR-` prefix는 의미상 깨끗하지만 현재 closure 도구와 바로 호환되지 않는다 | harness source의 `scripts/tests/check-scaffold-invariants.sh`, `scripts/tests/check-shipped-dr-closure.sh`, `docs/maintainer/VERIFICATION-COMMANDS.md`가 `DR-[0-9]{3}` regex와 `docs/decisions/DR-*.md` 파일명을 전제로 삼는다. `PDR-014`는 이 검사들에서 누락되거나 별도 cascade 없이는 closure 대상이 되지 않는다. | `PDR-`를 택하려면 별도 Work에서 도구·문서·template·grep 규칙을 함께 확장한다. 이번 migration의 빠른 fix로는 쓰지 않는다. 단기적으로 더 안전한 대안은 product/adopter DR을 예약 고대역(`DR-8xx`/`DR-9xx`)으로 옮기는 방식이다. 기존 도구 호환성이 좋지만, 이것도 namespace policy DR 없이는 시작하지 않는다. | revise/decide separately |
| RF3 | P2 | accepted-drift 13건은 대체로 맞지만, record가 정확한 파일 집합을 아직 못 박지 않았다 | `--check` drift는 `CLAUDE.md`, `AGENTS.md`, `.gitignore`, 3개 core docs, 3개 cursor rules, `prompts/README.md`, `prompts/codex-session-start.md`, `prompts/cursor-session-start.md`다. `prompts/claude-session-start.md`는 drift가 아니며, 반대로 `prompts/README.md`가 drift다. Work의 기존 표현은 "session-start prompt 3개"로 읽힐 여지가 있다. | result record에 13개 drift 파일을 정확히 열거하고, 각 drift가 accepted customization인지 확인한다. 특히 `prompts/README.md`는 live prompt surface라 "accepted" 또는 "reword" 판단을 명시한다. | revise |
| RF4 | P2 | default framework-add surface 기록에 optional `work-doc`이 섞여 있다 | temp `ai-deck-copy`와 `ai-deck-shadow` 모두 `.claude/commands/work-doc.md` 및 `.agents/skills/workflow-work-doc/SKILL.md`가 없다. `scripts/create-harness.sh`는 `work-doc`을 B-class optional(`--with-optional`)로 취급한다. 반면 Work의 5-way Classification은 framework-add에 `work-doc` 11개 command/skill을 포함한다. | temp result에서 `work-doc` 부재는 bug가 아니라 defend 가능하다. Work classification/count를 default scaffold 기준으로 정정하고, optional-pack은 별도 scope라고 명시한다. | revise lightly |
| RF5 | P3 | leak rework는 core에서는 통과했지만 live prompt README의 literal source repo mention은 의도 판단이 필요하다 | invariant [2]는 OK이고 core docs는 `source workflow repo` 표현으로 정리됐다. `README.md`의 public link와 archive의 `ai-workflow-harness` 참조는 history/public attribution이라 허용 가능하다. 다만 `prompts/README.md:7`은 live prompt surface에서 `source workflow repo인 ai-workflow-harness`를 직접 언급한다. | public README/archives는 defend. `prompts/README.md`는 일반 표현으로 맞추거나, source prompt library를 명시 링크로 가리키는 intentional exception으로 기록한다. blocker는 아니다. | defend or revise |

**정합성 확인(defend 가능):**
- source-retired 제거는 양호하다. old `.claude/commands/{close,debug,doc,done,health,pick,register,resume,start,work}.md` 및 대응 old `.agents/skills/workflow-*`는 temp result에 남지 않았다.
- product skill 보존은 양호하다. `create-deck`/`export-pdf`/`generate-architecture-slide`/`generate-blueprint`/`review-deck` command와 skill은 유지됐다.
- 3-way merge의 큰 방향은 defend 가능하다. `a6d4497`이 `CLAUDE.md`/`tools/git-hooks/pre-commit`을 modified-pre-existing으로 다뤄야 한다는 R1 base-trust 우려는 맞았고, temp result는 `CLAUDE` Preflight, `.gitignore` product ignore, Node/TypeScript project constants를 보존했다.
- F1의 accepted-drift [5] fail은 expected/documented state로 볼 수 있다. 단 RF1 때문에 현재 invariant failure 전체를 "예상된 실패"로 묶어서는 안 된다.

**Direction opinion — DR namespace:**
- A의 `①+③` 방향(정책은 별도 DR로, 구현은 별도 Work)은 맞다. 단, `PDR-` prefix를 "간단한 정책 선택"으로 보면 안 된다. 현재 harness validation과 maintainer commands가 `DR-[0-9]{3}`를 전제로 하므로, `PDR-`는 tool/schema cascade 없이는 closure blind spot을 만든다.
- 내 lean은 **이번 migration은 decision-index/DR namespace에서 끊고, 별도 Work에서 namespace 정책을 먼저 정하는 것**이다. 이번 PR이 있다면 "framework surface migration + documented accepted-drift + source-retired cleanup"까지만 검증하고, decision-index closure는 explicit residual로 남긴다.
- namespace 정책의 단기 안전안은 product/adopter decisions에 예약 고대역(`DR-8xx` 또는 `DR-9xx`)을 부여하는 것이다. 기존 `DR-` 도구가 그대로 작동하므로 operational risk가 낮다. 장기적으로는 `PDR-`가 더 의미론적으로 선명하지만, 그 경우 `check-scaffold-invariants`, `check-shipped-dr-closure`, `VERIFICATION-COMMANDS`, decision template/index rule을 함께 바꾸는 별도 harness Work가 선행돼야 한다.
- 단순 `DR-024` renumber band-aid는 반대한다. 현재 `DR-014`만 보이는 문제가 아니라 framework seed 확대 시 `DR-021`/`DR-022`/`DR-023`도 충돌하는 번호 공간 문제라, 다음 충돌을 예약할 뿐이다.

#### Result A Response — Claude A

Codex B의 **Request changes를 5건 전면 accept**한다. core migration body(framework surface + source-retired + customization 보존)가 defend 가능하다는 판정은 일치하고, RF1·RF2가 정확히 close blocker를 짚었다. 특히 RF2는 내 PDR- 권장의 실무 맹점(`DR-[0-9]{3}` regex·`check-shipped-dr-closure`·`VERIFICATION-COMMANDS` cascade)을 잡았다 — supersede 수용.

| Finding | A 판정 | 반영 |
| --- | --- | --- |
| RF1 (P1) decision-index/DR namespace close blocker | **Accept** | temp result를 그대로 real-apply하지 않는다. decision-index closure + DR namespace를 **별도 Work로 분리**하고, 이번 CHORE-003은 "framework migration body 검증 + namespace blocker residual"로 종결선 조정. Slice E/Done Criteria를 "index closure 완료"→"residual로 기록, index 보류"로 수정. |
| RF2 (P2) PDR- vs DR-도구 호환 | **Accept (supersede 내 PDR 권장)** | 단기 안전안 = product/adopter DR을 **예약 고대역(`DR-8xx`/`DR-9xx`)**으로 — 기존 `DR-` 도구 그대로 작동. 장기 PDR은 `check-scaffold-invariants`/`check-shipped-dr-closure`/`VERIFICATION-COMMANDS`/template·index rule cascade까지 묶는 **별도 harness Work**. `DR-024` band-aid는 반대(021/022/023 재충돌)에 동의. |
| RF3 (P2) accepted-drift 정확 목록 | **Accept** | 13 drift 파일 정확 열거: `CLAUDE.md`, `AGENTS.md`, `.gitignore`, `docs/AGENT-WORKFLOW.md`, `docs/HARNESS-PROTOCOL.md`, `docs/HARNESS-QUICK-REFERENCE.md`, `docs/HARNESS-RECOVERY-VALIDATION.md`, `.cursor/rules/{coding,debugging,execution}.mdc`, `prompts/README.md`, `prompts/codex-session-start.md`, `prompts/cursor-session-start.md`. **`prompts/claude-session-start.md`는 framework로 정렬돼 in-sync(drift 아님)**. |
| RF4 (P2) optional `work-doc` | **Accept** | `work-doc`은 B-class optional(`--with-optional`)이라 default scaffold 부재가 정상. shadow/manifest가 옳고, Work classification 문구의 "framework-add"에서 `work-doc`을 default add로 세지 않게 정정(optional-pack은 별도 scope). |
| RF5 (P3) live prompt README literal mention | **Accept (revise)** | `prompts/README.md`의 `source workflow repo인 \`ai-workflow-harness\``를 일반 표현으로 reword 완료. public `README.md`·archive의 attribution은 defend(history/public link). |

**Direction consensus:** A의 ①+③를 B가 정교화한 형태에 합의 — **이번 migration은 decision-index/DR namespace에서 끊는다.** framework surface migration + documented accepted-drift + source-retired cleanup까지가 CHORE-003의 검증 대상이고, decision-index closure는 explicit residual. namespace 정책은 별도 Work(단기 reserved high-band, 장기 PDR+tool cascade). **단, real apply는 framework DR-014-archive seed가 ai-deck DR-014-ppt와 파일 충돌을 새로 만들므로, namespace Work 전에는 real apply하지 않거나 DR seed surface를 제외하고 적용해야 한다**(owner decision).

### Round Log

| Round | Reviewer | Status | Request | Result | A Response |
| --- | --- | --- | --- | --- | --- |
| R1 | Codex B | A responded (consensus) | Work file + real-migration plan red-team review | P1 2 / P2 3 + direction concern 1. 핵심은 accepted-drift vs invariant PASS 검증 모순, source-retired stale surface 누락, `a6d4497` base trust audit 필요, ai-deck branch naming 불일치, DR-034 promotion wording 과속 | 5건 전면 accept. F1 success criterion 재정의, F2 source-retired slice 추가(stated보다 큼), F3 base trust audit, F4 feature/* branch, F5 wording 완화+판단표. 5분류 체계로 확장 |
| Result | Codex B | A responded (consensus, owner decision 대기) | temp migration result review + DR namespace direction opinion | Request changes before real apply. core merge/source-retired/product skill preservation은 대체로 defend 가능하나, decision-index closure 실패와 `DR-014` namespace 충돌은 blocker. accepted-drift 13건·optional `work-doc`·live prompt README 예외도 record 정렬 필요 | 5건 accept. migration을 decision-index/namespace에서 끊고 별도 Work로 분리, 단기 reserved high-band·장기 PDR+cascade, accepted-drift 13 정확 열거, work-doc optional 정정, prompts/README reword |

### Consensus Log

| Item | Status | Consensus / Remaining Disagreement |
| --- | --- | --- |
| Direction: real migration timing | Consensus | 다음 수순 타당. 분류를 5분류(preserve/delete-respect/source-retired/merge/accepted-drift)로 확장 + success criterion 재정의 합의 |
| F1 accepted-drift vs invariant PASS | Consensus | success를 invariant PASS가 아니라 "framework in-sync + customized accepted-drift(이유 기록), invariant 0-drift fail은 expected/documented"로 재정의. manifest accepted-drift 미표현은 tooling/DR-034 residual |
| F2 source-retired stale surface | Consensus | source-retired-candidate 분류 + 전용 cleanup slice. old command/skill을 product skill과 분리해 owner 판단. (실측상 stated보다 큼) |
| F3 `a6d4497` base trust | Consensus | base 유지하되 base trust audit 추가. modified-pre-existing·later framework-alignment 구분, 핵심 파일은 owner sign-off |
| F4 target branch policy | Consensus | `feature/chore-20260621-003-harness-upgrade` + PR base `develop` + regular merge (ai-deck §Branch Types 확인) |
| F5 DR-034 promotion wording | Consensus | "gate opens" → "promotion evidence", Slice F는 판단표, DR-034 상태 변경은 별도 owner-approved decision |
| Result RF1 decision-index / DR namespace | Consensus | close blocker 동의. decision-index closure + DR namespace를 별도 Work로 분리, CHORE-003은 migration body 검증 + residual로 종결선 조정. A accept |
| Result RF2 namespace policy direction | Consensus | 단기 안전안=예약 고대역 `DR-8xx/9xx`(기존 도구 호환), 장기 PDR=별도 harness Work(tool cascade 포함). `DR-024` band-aid 반대 동의. A의 PDR 권장 supersede |
| Result RF3 accepted-drift exact list | Consensus | 13 drift 정확 열거(A Response). `claude-session-start.md`=in-sync, `prompts/README.md`/`codex`/`cursor`-session-start=drift |
| Result RF4 optional work-doc | Consensus | `work-doc`=B-class optional, default 부재 정상. classification에서 default add로 세지 않게 정정 |
| Result RF5 live prompt README source mention | Consensus | `prompts/README.md` reword 완료. public README·archive attribution은 defend |

## Checkpoints

| CP | Description | Status |
| --- | --- | --- |
| 1 | Work 파일 + Active pointer + cross-agent frame (Claude A / Codex B) | 진행 중 |
| 2 | Codex B R1 red-team review + A response + consensus | 완료 (5건 accept, 5분류·success criterion 재정의) |
| 3 | ai-deck clean branch + customization preserve-list (owner sign-off) | 대기 |
| 4 | manifest baseline + framework-update apply + customized merge + index closure | 대기 |
| 5 | Codex B result review + A response + owner decision (path A) | 완료 (5건 accept, rehearsal로 종결 결정) |
| 6 | rehearsal close: strict framing + 후속 Work re-scope + STATUS/commit | 진행 중 (STATUS·commit gate 승인 대기) |

## Next Actions
- ✓ CHORE-20260621-002 close에서 backlog 후보를 real-apply residual로 re-scope
- ✓ ai-deck 전제 probe: clean base `7941585` 확인, customization 실재 확인
- ✓ feature branch `feature/chore-20260621-003-ai-deck-real-migration` 생성
- ✓ Work 파일 + cross-agent frame 작성 (role swap: Claude A / Codex B)
- ✓ STATUS Active pointer 추가 (owner 승인 후) + Codex B R1 red-team review 요청
- ✓ Codex B R1 red-team review 기록 (Request changes: P1 2 / P2 3 + direction concern)
- ✓ Claude A R1 response + consensus (5건 accept: F1 success criterion 재정의, F2 source-retired slice, F3 base trust audit, F4 feature/* branch, F5 wording 완화)
- → owner 승인 후 CP3 migration 실행: base trust audit → 5분류 owner sign-off → branch → reconcile → merge → index → verify
- ✓ Codex B result review 기록 (Request changes: RF1 P1 / RF2-RF4 P2 / RF5 P3)
- ✓ Claude A result response + consensus (5건 accept, RF3 13 정확 열거·RF5 reword 반영)
- ✓ owner decision: path A — rehearsal로 종결, 실제 apply는 후속 Work
- ✓ strict framing 반영(Disposition/Done Criteria/Rehearsal Result), 후속 Work로 backlog 후보 re-scope
- → STATUS Active pointer 제거 + Recent Decisions (승인 후), commit(`--base develop` PR)
- ○ 후속: `adopter DR namespace 정책 + ai-deck real apply` 착수 시 `/work-plan`

## Discovery
- ai-deck clean base는 `7941585`(2026-06-03 develop→main merge). 현재 로컬 branch가 이 ref에 있고 working tree clean이라, dirty feature 우려는 낮으나 migration은 전용 branch에서 분리 수행한다.
- customization 실측: CLAUDE/AGENTS "Non-Negotiable Preflight" 섹션 + bootstrap-complete 노트, .gitignore project-specific ignore. 이들은 보존 대상이며 CHORE-002가 temp에서 덮어쓴 것을 실제로는 merge해야 한다.
- **(owner 제안 채택) adopter git history로 3-way merge-base를 복구한다.** adoption commit `a6d4497`을 BASE로 쓰면 "adopter 의도 변경 vs framework 진화"가 정확히 분리된다 — CHORE-002의 2-way locally-modified 분류(must-merge 6 / framework-update 26)는 snapshot이라 adopter delete(`prompts/*`)·add(`product-skills.mdc`)를 못 봤다. 이 발견은 DR-034 refinement signal이기도 하다(promotion 판단 Slice F에서 "adopter history=merge-base 복구원" 반영 검토).
- **R1 consensus(Codex B, 5건 accept):** plan을 5분류(preserve/delete-respect/source-retired/merge/accepted-drift)로 확장하고 success criterion을 재정의했다. 실측으로 확정된 핵심 두 공백 — (F1) `check-scaffold-invariants.sh` L211이 `, 0 drifted` 없으면 hard-fail이라 accepted-drift와 invariant PASS가 동시 성립 불가 → invariant PASS를 성공 기준에서 제외; (F2) ai-deck에 retired old command/skill surface(`close/debug/doc/done/health/pick/register/resume/start/work` 계열)가 잔존, current source엔 없음 → source-retired 제거 필요. 추가로 F3 base trust audit, F4 ai-deck `feature/*` branch 정책, F5 DR-034 wording 완화 반영.

## Migration Classification (CP3 — owner sign-off pending)

실측: BASE=`a6d4497`, THEIRS=ai-deck@`7941585`, OURS=current harness source. **아직 ai-deck write 없음.**

### Base Trust Audit (F3)

| 파일 | `a6d4497` status | BASE 신뢰도 | 처리 |
| --- | --- | --- | --- |
| `AGENTS.md`, `docs/AGENT-WORKFLOW.md`, `docs/BEHAVIOR-PRINCIPLES.md`, `docs/GIT-WORKFLOW.md`, `.cursor/rules/behavior-principles.mdc` | **A (net-new)** | 높음 | BASE→THEIRS = adopter intent로 신뢰 가능 |
| `CLAUDE.md` | **M (pre-existing product 수정)** | 낮음 | BASE→THEIRS를 auto adopter-intent로 보지 않음 → **owner sign-off** |
| `tools/git-hooks/pre-commit` | **M** | 낮음 | **owner sign-off** |
| `.gitignore` | a6d 미변경(pre-existing project file) | 낮음 | project ignore preserve → **owner sign-off** |

### 5-way Classification

| 분류 | 항목 | 처리 |
| --- | --- | --- |
| **source-retired (REMOVE)** | `.claude/commands/{close,debug,doc,done,health,pick,register,resume,start,work}.md` (10) · `.agents/skills/workflow-{close,debug,doc,done,health,pick,register,resume,start,work}` (10) | OURS에 없음(framework retire) → target에서 제거 |
| **framework-add (ADD)** | `.claude/commands/{repo-health,session-start,session-summary,work-brief,work-close,work-debug,work-doc,work-plan,work-register,work-resume,work-select}.md` (11) · 대응 `.agents/skills/workflow-*` (11) | 신규 surface 추가 (대부분 old→new rename: close→work-close, debug→work-debug, doc→work-doc, health→repo-health, register→work-register, resume→work-resume, start→session-start, work→work-plan, pick→work-select; done은 후속 없이 retire) |
| **preserve (KEEP, product-owned)** | `.claude/commands/{create-deck,export-pdf,generate-architecture-slide,generate-blueprint,review-deck}.md` · 대응 skills · `.cursor/rules/product-skills.mdc` · `record-decision`(공통, update) | adopter-owned → 유지 |
| **merge (customized entrypoint)** | `CLAUDE.md`(Preflight·bootstrap·Project 제거) · `AGENTS.md`(skill routing·English-only) · `.gitignore`(project ignore) · `prompts/{claude,codex,cursor}-session-start.md` | framework update 흡수 + adopter 내용 보존 |
| **delete-respect / no-op** | `prompts/*.prompt.md` (00~22) | adopter-delete **AND** source-retired 일치 → 이미 양쪽 부재, 무동작 |

### accepted-drift (예상)

merge 후 `CLAUDE.md`/`AGENTS.md`/`.gitignore`/session-start prompt는 current source와 불일치로 남는다(보존된 customization 때문). → `--check`에서 documented accepted-drift, invariant `0 drifted` fail은 expected(F1).

### Owner Sign-off (2026-06-21 — 확정)

1. **source-retired 20개 제거: 승인.** old `.claude/commands`·`.agents/skills` 20개 제거, product skill·`record-decision` 유지.
2. **CLAUDE.md: 보존.** "Non-Negotiable Preflight" 섹션 + bootstrap-complete 노트 유지하며 framework update merge.
3. **.gitignore: 보존+merge.** `*.pptx`/`outputs/`/`blueprints/`/`[AI 정리]` 등 project ignore 보존, framework ignore와 merge.
4. **pre-commit: framework로 업데이트.** ai-deck 수정본을 current framework hook으로 교체.

## Migration Rehearsal Result (temp — ai-deck 무수정)

**판정: migration body defend 가능 + DR namespace가 real-apply blocker.** 실제 ai-deck repo write 없음. 결과 트리는 `temp/chore-20260621-003/ai-deck-copy`.

### 수행 결과
- **framework-add:** default scaffold(manifest 78 tracked) 기준 신규 surface 적용. `work-doc`은 B-class optional(`--with-optional`)이라 default 부재가 정상 — framework-add count에 포함하지 않음(RF4).
- **source-retired 20 제거:** old `.claude/commands/{close,debug,doc,done,health,pick,register,resume,start,work}.md` + `.agents/skills/workflow-{동일}`. product skill(`create-deck`/`export-pdf`/`generate-architecture-slide`/`generate-blueprint`/`review-deck`)·`record-decision` 유지.
- **3-way merge 30블록 해소:** option 1(stance 보존 + framework rename/구조). CLAUDE Preflight·.gitignore project ignore·AGENT-WORKFLOW Project Constants(Node/TS)·SYSTEM-MANUAL stance·no-duplicate-manual stance 보존.
- **leak 0:** pre-existing `ai-workflow-harness` 명시 참조를 core 2개(AGENT-WORKFLOW, HARNESS-PROTOCOL) + `prompts/README.md`에서 "source workflow repo" 일반 표현으로 reword. public README·archive attribution은 defend(RF5).

### `--check` 결과 (F1 success criterion)
`78 tracked, 65 in-sync, 13 drifted`. invariant `[5]` 0-drift hard-fail = expected/documented(F1).

**accepted-drift 13 (정확 열거, RF3):** `CLAUDE.md`, `AGENTS.md`, `.gitignore`, `docs/AGENT-WORKFLOW.md`, `docs/HARNESS-PROTOCOL.md`, `docs/HARNESS-QUICK-REFERENCE.md`, `docs/HARNESS-RECOVERY-VALIDATION.md`, `.cursor/rules/coding.mdc`, `.cursor/rules/debugging.mdc`, `.cursor/rules/execution.mdc`, `prompts/README.md`, `prompts/codex-session-start.md`, `prompts/cursor-session-start.md`. (`prompts/claude-session-start.md`는 framework로 정렬돼 **in-sync**.)

### Real-Apply Blocker (residual)
- **invariant `[3]` decision-index closure FAIL**: `docs/decisions/README.md` 부재. ai-deck pre-existing 조건.
- **DR namespace 충돌**: framework `DR-014-archive` seed가 adopter `DR-014-ppt`와 파일 충돌. 추가로 product `DR-021/022/023`이 framework `DR-021/022/023`과 번호 공간 충돌(시한폭탄). → real apply 차단.

### DR-034 (strict)
- **promotion evidence 후보**: rehearsal에서 migration body가 defend 가능했고, 실제 apply 경로에서 **adopter product DR namespace 정책 공백**이 발견됨(helper/정책 필요 신호 = 30블록 수동 병합 + namespace 충돌).
- **actual target migration condition: UNMET** — 실제 apply 미수행. DR-034 상태는 Draft 유지.

### 후속 Work (등록 대상)
`adopter DR namespace policy + ai-deck real apply`: ① reserved high-band `DR-8xx/9xx` 정책 결정(단기, 장기 PDR은 tool cascade 별도) ② ai-deck product DR 4개 renumber cascade(PLAN.md/create-deck.md 등 product 참조 포함) ③ decision-index 생성 ④ 실제 ai-deck `feature/*` branch apply/PR.

- 2026-06-22 archive: Done housekeeping(`/session-start` 배치 archive). 후속(high-band 정책 + ai-deck real apply)은 CHORE-20260621-004에서 완료(PR #51).
