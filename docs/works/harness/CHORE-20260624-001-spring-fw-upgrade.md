---
id: CHORE-20260624-001
priority: P2
status: Done
risk: L2
scope: spring-modular-template adopter repo의 framework surface drift(현재 12, source 1.4.0 기준)를 v1.4.0 release tag baseline으로 selective apply한다. 11건(source-updated 9 + hook 2) adapt-render apply + .harness/manifest.json은 v1.4.0 shadow manifest 통째 교체로 rebaseline, product-customized docs/AGENT-WORKFLOW.md는 콘텐츠 보존(accepted-drift). read-only delta probe로 신규/retired framework surface를 나열만 하고 별도 backlog route-out. cross-agent review(/cross-review, Claude driver / Codex reviewer)로 진행하고 spring develop→main까지 반영.
appetite: 1d
planned_start: 2026-06-24
planned_end: 2026-06-24
actual_end: 2026-06-24
related_dr: [DR-028, DR-034, DR-042]
related_troubleshooting: []
related_work: [CHORE-20260621-005, CHORE-20260622-001, CHORE-20260621-006]
---

# CHORE-20260624-001: spring-modular-template framework surface upgrade

## Top Summary

CHORE-20260622-001은 spring의 **product DR namespace renumber만** 적용했고, CHORE-20260621-005 probe가 식별한 **framework surface drift는 미반영**으로 남았다. 그 잔여 drift를 실제 apply해 spring을 released 1.4.0 framework surface에 맞춘다.

**착수 시점 실측 (backlog 기록과 다름):**

- backlog는 "7 drifted"로 기록(1.3.0 시절 probe)했으나, 그 사이 source가 1.4.0으로 올라가 **현재 drift = 12**다 (spring manifest 1.3.0).
- drifted 12 중 5건은 `ai-workflow-v1.4.0` 태그와 현재 `develop`(baff023, 11 commits ahead = cross-review 작업분)이 **다르다**. develop HEAD에서 apply하면 미출시 콘텐츠가 adopter에 누출된다.
- 따라서 **baseline = `ai-workflow-v1.4.0` release tag** (DR-028 amendment 기본값). 사용자 승인 완료.

## Scope

**baseline:** `ai-workflow-v1.4.0` release tag (validation `--check`도 tag checkout 상태로 실행)
**scope 경계:** drift apply only. 신규/retired surface inventory는 read-only probe로 나열만 하고 backlog route-out (CHORE 비범위).
**apply mechanism:** raw copy 아님. **shadow re-scaffold(v1.4.0 tag → temp, profile=spring-boot/workflow=source-gitflow/project=spring-modular-template)**. (R0-Codex-F1/F2)
- 11개 framework 파일: shadow 산출물(adapt-rendered)을 spring에 복사
- `.harness/manifest.json`: **shadow manifest 통째 교체**(path set 82/82 동일 — row splice/JSON pretty-print 금지, `--check` single-line parser가 깨짐. R0b-Codex-F1)
- `docs/AGENT-WORKFLOW.md`: **콘텐츠 보존**(shadow 산출물로 덮지 않음). whole-manifest 교체로 recorded hash는 v1.4.0이 되어 최종 `--check`에서 `locally-modified`(accepted)로 표시

**Classification table (DR-034, R0-Codex-F3):**

| Path | Classification | Action | Manifest handling |
| --- | --- | --- | --- |
| `docs/BEHAVIOR-PRINCIPLES.md` | framework-update | adapt-render v1.4.0 → 콘텐츠 교체 | recorded sha256 → v1.4.0 |
| `docs/HARNESS-PROTOCOL.md` | framework-update | 〃 | 〃 |
| `docs/HARNESS-NAMING-RULES.md` | framework-update | 〃 | 〃 |
| `docs/HARNESS-QUICK-REFERENCE.md` | framework-update | 〃 | 〃 |
| `skills/workflow/README.md` | framework-update | 〃 | 〃 |
| `skills/workflow/session-start.md` | framework-update | 〃 | 〃 |
| `skills/workflow/work-close.md` | framework-update | 〃 | 〃 |
| `.cursor/rules/behavior-principles.mdc` | framework-update | 〃 | 〃 |
| `.cursor/rules/workflow.mdc` | framework-update | 〃 (src=`scripts/templates/default/...`) | 〃 |
| `tools/git-hooks/install.sh` | framework-update / adapt-render | adapt-render v1.4.0 (identity `spring-modular-template`) | recorded sha256 → v1.4.0 |
| `tools/git-hooks/lib/gate-lists.sh` | framework-update / adapt-render | 〃 | 〃 |
| `docs/AGENT-WORKFLOW.md` | **preserve / accepted-drift** | **콘텐츠 보존(미변경)** | recorded sha256만 v1.4.0 → 최종 `--check`에서 `locally-modified`(의도된 product 분기)로 표시 |
| `.harness/manifest.json` | manifest rebaseline | `harness_version` 1.3.0→1.4.0 + 위 12개 recorded sha256 splice | — |
| 신규/retired surface | delta probe | **나열만**, backlog route-out | — |

## Plan

1. (done) feature branch 2개: harness `feature/chore-20260624-001-spring-fw-upgrade`, spring `feature/harness-upgrade-1.4.0`
2. (done) R0 plan review (/cross-review): relay packet → Codex request-changes → driver accept 전부 → conditional 해소, plan 갱신
3. EXECUTE: `ai-workflow-v1.4.0` tag를 temp로 shadow re-scaffold(profile spring-boot / workflow source-gitflow / project spring-modular-template) → 11개 adapt-rendered 파일을 spring에 복사 + `.harness/manifest.json` **shadow manifest 통째 교체**. `docs/AGENT-WORKFLOW.md` 콘텐츠 보존(shadow로 덮지 않음)
4. Delta probe (read-only): 신규/retired surface 나열 → backlog route-out (empty면 empty 기록)
5. VALIDATE: `ai-workflow-v1.4.0` **clean tag checkout/worktree**에서 `scripts/create-harness.sh --check <spring>`(source ref가 clean release tag로 찍혀야 함, R0b-Codex-F4) — 기대 `82 tracked / 81 in-sync / 1 drifted([locally-modified] docs/AGENT-WORKFLOW.md, accepted)`. 보조: 변경 11개가 in-sync인지 diff 확인. spring `git diff --check`, lineage/product 보존
6. R1 result review (/cross-review): diff + `--check` 결과 relay → Codex reviewer → driver response
7. Lifecycle finalization (R0-Codex-F4 순서): ① spring PR(develop→main) 반영 → ② harness Work에 result/links 반영 → ③ STATUS/backlog finalization proposal → ④ harness commit/PR 승인

## Done Criteria

- [x] 11건 adapt-rendered v1.4.0 apply + `.harness/manifest.json` shadow manifest 통째 교체, `docs/AGENT-WORKFLOW.md` 콘텐츠 보존
- [x] v1.4.0 clean tag worktree 기준 spring `--check` = `82 tracked / 81 in-sync / 1 drifted`(`[locally-modified] docs/AGENT-WORKFLOW.md` accepted)
- [x] delta probe 수행 → **empty**(82/82 동일) 기록
- [x] cross-review R0(plan)·R0b(pre-apply)·R1(result) 누적·종료 — R1 approve
- [x] spring `develop`→`main` PR 반영 — PR #13(feature→develop, squash) + PR #14(develop→main, merge) 모두 MERGED, develop/main 동기화

## Verification

spring `--check` 재실행(drift 0/accepted), framework lineage·product(`AGENT-WORKFLOW.md`) 보존 확인, spring `git diff --check`. Surface: adopter cascade · canonical · tool surface.

## Risk And Reversal

- 주 위험 = 보존 대상(`AGENT-WORKFLOW.md`) overwrite → scope 명시 제외로 차단.
- 미출시 콘텐츠 leak → v1.4.0 태그 baseline으로 차단.
- Reversal: 모두 feature branch + PR 경유 → revertable. **Medium-low**.

## Discovery

backlog의 "spring-modular-template framework surface upgrade (CHORE-005 잔여 drift apply)" candidate 착수.

착수 실측: drift 7→12 (source 1.4.0 bump 영향), v1.4.0 태그와 develop HEAD 간 5파일 차이 → baseline을 v1.4.0 태그로 확정.

### Source-side 보강 (이번 Work 범위 내, source-only)

R0 검증 중 발견: spring은 **구버전(1.3.0) manifest-target**인데 maintainer 절차가 이 케이스의 두 함정을 명시하지 않아 apply 안전성에 직접 위협이었다. 이번 적용에 직접 필요한 **최소 문구만** harness branch에서 보강(scope creep 차단).

| 파일 | 보강 | 왜 이번 Work에 필요 |
| --- | --- | --- |
| `docs/maintainer/ADOPTER-UPGRADE-MIGRATION-PLAYBOOK.md` Phase 4 | `framework-update`는 raw copy 아닌 **adapt-render**(identity 치환) 명시 | F2 함정 — hook raw copy 시 identity leak |
| `docs/maintainer/ADOPTER-UPGRADE-MIGRATION-PLAYBOOK.md` Phase 6 | `source-updated`는 manifest hash 신호 → **rebaseline 필요**(콘텐츠 복사만으론 drift 안 지워짐) 명시 | F1 함정 — manifest-target 업그레이드 핵심 |
| `docs/maintainer/VERIFICATION-COMMANDS.md` T2 | shadow scaffold는 project-name뿐 아니라 **profile/workflow_mode도 target manifest와 일치** | spring=`spring-boot` profile, `generic` shadow 시 framework 집합 어긋남 |

**shipped framework baseline 영향 없음:** 변경은 `docs/maintainer/*`(source-only maintainer 문서)에만 한정. `scripts/create-harness.sh`, shipped framework docs, workflow canonical, DR 정책은 **미변경**. 따라서 scaffold 산출물·adopter에 배포되는 baseline은 불변이며, v1.4.0 tag baseline apply와 충돌하지 않는다.

**route-out (이번 Work 비범위):** 구버전 manifest-target 전용 Layer/`--upgrade` helper, `--check`의 source-updated/locally-modified 분해 한계 등 구조 개선은 backlog residual로 분리(current develop 변경과 v1.4.0 tag apply를 섞지 않기 위해).

### EXECUTE + VALIDATE 결과 (2026-06-24)

**Apply:** v1.4.0 worktree(detached @ 8595176)에서 shadow scaffold(spring-boot/source-gitflow/spring-modular-template, 82 tracked) 생성 → 11개 framework 파일 복사 + `.harness/manifest.json` 통째 교체. `docs/AGENT-WORKFLOW.md` 미복사(보존).

**실제 diff = 7 파일** (`git diff --stat`): `.harness/manifest.json`, `docs/HARNESS-NAMING-RULES.md`, `docs/HARNESS-PROTOCOL.md`, `skills/workflow/session-start.md`, `skills/workflow/work-close.md`, `tools/git-hooks/install.sh`, `tools/git-hooks/lib/gate-lists.sh`. 나머지 5개(BEHAVIOR-PRINCIPLES, HARNESS-QUICK-REFERENCE, skills/workflow/README, .cursor/rules/behavior-principles·workflow)는 spring이 이미 v1.4.0 동일 콘텐츠 보유 → manifest hash만 stale했던 것(복사 시 no-op).

**Delta probe = empty:** shadow(1.4.0) vs spring(1.3.0) manifest path set **82/82 동일**, 신규(framework-add)·retired(source-retired) manifest-tracked 파일 0건.

**Validation (v1.4.0 clean tag worktree 기준):**
- `--check`: source ref `detached @ 8595176 (ai-workflow-v1.4.0)` clean tag, **`82 tracked / 81 in-sync / 1 drifted`** — 단일 `[locally-modified] docs/AGENT-WORKFLOW.md`(accepted, 의도된 product 분기)
- hook identity: leak 0(`ai-workflow-harness`/`base-spring-modular-template` 없음), `spring-modular-template`로 렌더됨
- `check-scaffold-invariants.sh`: **[1][2][3][4] OK, [5] FAIL** — `[5]`는 accepted-drift(AGENT-WORKFLOW.md) 때문이며 playbook Phase 6 "[1]~[4] 통과 시 expected"에 해당
- `git diff --check`: clean

## Cross-Agent Review And Discussion

Model: `/cross-review` manual relay. Driver = Claude, Reviewer = Codex, Arbiter = User. Max rounds: plan R0 + result R1.

### R0 — Plan Review (Cross-Agent Relay Packet)

**Role:** Driver = Claude / Reviewer = Codex / Arbiter = User

**Target:** Work plan `CHORE-20260624-001` (spring-modular-template framework surface upgrade)

**Current State:**
- harness branch `feature/chore-20260624-001-spring-fw-upgrade`, spring branch `feature/harness-upgrade-1.4.0` (둘 다 생성됨, apply 미수행)
- spring `--check` 실측: 82 tracked / 70 in-sync / **12 drifted**, manifest 1.3.0 vs source 1.4.0
- baseline = `ai-workflow-v1.4.0` release tag (DR-028, 사용자 승인)
- validation so far: drift 실측 + v1.4.0↔develop 5파일 차이 확인 (BEHAVIOR-PRINCIPLES, HARNESS-QUICK-REFERENCE, skills/workflow/README, .cursor/rules/behavior-principles, .cursor/rules/workflow)

**Delta Since Last Round:** R0 (first round)

**Review Objective:** apply 전 plan의 **방향·scope·baseline·누락**을 red-team.

**Must Check:**
1. baseline 선택(v1.4.0 태그)이 옳은가. develop HEAD apply가 미출시 leak이라는 판단이 맞는가. 태그 baseline에서도 놓치는 게 있나?
2. scope 경계 — drift 12 중 11 apply + AGENT-WORKFLOW.md 보존이 맞나. `--check`가 source-updated/locally-modified를 오분류했을 위험(특히 9 source-updated 중 product-customized가 섞여 있을 가능성)은?
3. hook 2파일(`install.sh`, `gate-lists.sh`)을 source overwrite로 처리하는 게 맞나. spring-local hook 설정/`base-spring-modular-template` 잔재 외의 product 변경이 섞였을 위험은?
4. spring manifest version bump(1.3.0→1.4.0) 절차/타이밍 — playbook 기준 누락 없나.
5. delta probe를 read-only로 분리하고 backlog route-out하는 게 적절한가, 아니면 이 Work에 포함해야 하나(under-scope 위험).
6. 2-repo lifecycle(harness tracking + spring apply/PR), cascade·rollback 누락 없나.

**Do Not Re-litigate:**
- cross-agent 역할(Claude driver / Codex reviewer) — 확정
- scope = drift apply only, inventory는 probe-나열만 — 사용자 결정 완료
- baseline = v1.4.0 태그 — 사용자 승인 완료 (단, 태그 baseline에서도 놓치는 리스크가 있으면 지적은 허용)

**Reviewer Posture:** 방향 자체를 의심. 전제·evidence·hidden cost·cascade·rollback·preservation 경계 점검. speculation은 speculation으로 표시.

**Output Contract:**
- Verdict: approve / conditional / request-changes / reject
- Must-fix findings
- Nice-to-have findings
- Residual risk
- Suggested wording (필요 시)

### R0 — Reviewer Findings (Codex)

Verdict: **request-changes** (F1/F2 plan 반영 시 conditional로 하향 가능)

| ID | Severity | Finding (요약) |
| --- | --- | --- |
| R0-Codex-F1 | P1 | `--check`는 manifest recorded sha256 vs 현재 source hash로 판정. 파일만 복사하고 manifest hash가 1.3.0이면 계속 drift. "version bump"가 아니라 "v1.4.0 기준 manifest rebaseline" 필요 |
| R0-Codex-F2 | P1 | hook 2파일 raw overwrite 금지. v1.4.0 source를 `ai-workflow-harness → spring-modular-template`로 adapt-render 후 apply해야 forward-render 모델과 일치 |
| R0-Codex-F3 | P2 | DR-034 보존 경계상 apply 전 path별 classification table(Path/Classification/Action/Reason/Manifest handling) 필요 |
| R0-Codex-F4 | P2 | 2-repo lifecycle에서 spring PR과 harness tracking finalization의 순서/승인 gate 분리 명시 필요 |
| R0-Codex-N1 | nice | baseline approve. validation `--check`는 v1.4.0 **tag checkout 기준**으로 source ref 기록 |
| R0-Codex-N2 | nice | delta probe read-only route-out approve. empty 여부·후보 backlog row만 R1에 기록 |
| R0-Codex-N3 | nice | AGENT-WORKFLOW.md 보존 approve. 최종 `--check`에서 어떻게 보일지(accepted-drift) 계획에 못박기 |

### R0 — Driver Response (Claude)

코드 검증: `adapt()` `create-harness.sh:208` = `s/ai-workflow-harness/${PROJECT_NAME}/g`. `do_check` `:340` = `cur_src_hash != recorded → source-updated` (target 내용 무관). **F1/F2 모두 사실 확인.**

| Finding | Decision | Response |
| --- | --- | --- |
| F1 | **accept** | "version bump" → "v1.4.0 manifest rebaseline"으로 변경. drift 0은 (a) adapt-rendered v1.4.0 콘텐츠 복사 **+** (b) manifest recorded sha256 v1.4.0 갱신 **둘 다** 필요 |
| F2 | **accept** | hook 처리를 raw overwrite → adapt-render(`ai-workflow-harness→spring-modular-template`)로 변경 |
| F3 | **accept** | apply 전 Classification table 추가(아래 Scope 갱신) |
| F4 | **accept** | lifecycle 순서 분리(아래 Plan 갱신) |
| N1 | **accept** | validation `--check`는 source를 **`ai-workflow-v1.4.0` tag checkout** 상태로 실행 |
| N2 | **accept** | delta probe empty/route-out R1 기록 |
| N3 | **accept** + **revise** | 단순 보존이 아니라 AGENT-WORKFLOW.md의 manifest recorded hash도 v1.4.0으로 갱신(콘텐츠는 보존). 그래야 `source-updated`(업그레이드 누락처럼 보임)가 아니라 `locally-modified`(의도된 product 분기)로 정직하게 표시됨 |

**Mechanism 확정 (rebaseline 정확성 보장):** raw 수기 hash 편집은 normalization(`hash_mode: normalized_source_template`) 오류 위험 → **shadow re-scaffold** 채택. `ai-workflow-v1.4.0` tag를 temp dir로 동일 project/profile/workflow 재scaffold → 생성된 (1) 11개 adapt-rendered 파일과 (2) 12개 manifest row(11 + AGENT-WORKFLOW.md) + `harness_version` 1.4.0을 spring `.harness/manifest.json`에 splice. spring의 나머지(product 파일, AGENT-WORKFLOW.md **콘텐츠**)는 보존. script 자체 hashing을 쓰므로 hash 정합 보장.

R0 verdict: request-changes → **모든 finding accept로 conditional 해소**. plan 갱신 반영 완료(아래).

### Round Log

| Round | Driver | Reviewer | Objective | Verdict | Status |
| --- | --- | --- | --- | --- | --- |
| R0 | Claude | Codex | plan review | request-changes → conditional(전부 accept) | closed |
| R0b | Claude | Codex | revised plan + source-only playbook 보강 review (pre-apply) | conditional(전부 accept) | closed |
| R1 | Claude | Codex | result review | approve | closed |

### R1 — Result Review Relay Packet

**Role:** Driver = Claude / Reviewer = Codex / Arbiter = User

**Target:** apply 결과 (spring branch `feature/harness-upgrade-1.4.0`, uncommitted)

**Delta Since R0b:** R0b must-fix 전부 반영 후 apply 수행. mechanism = whole shadow manifest replace.

**Current State:**
- spring 변경 7 파일: `.harness/manifest.json`, `docs/HARNESS-NAMING-RULES.md`, `docs/HARNESS-PROTOCOL.md`, `skills/workflow/session-start.md`, `skills/workflow/work-close.md`, `tools/git-hooks/install.sh`, `tools/git-hooks/lib/gate-lists.sh` (나머지 5개 framework 파일은 이미 v1.4.0 동일 → no-op)
- `docs/AGENT-WORKFLOW.md` 미변경(보존)
- harness branch: Work/STATUS/index/playbook×2/VERIFICATION×1 수정 (uncommitted)

**Validation Evidence (v1.4.0 clean tag worktree 기준):**
- `--check`: source ref `detached @ 8595176 (ai-workflow-v1.4.0)`, `82 tracked / 81 in-sync / 1 drifted([locally-modified] docs/AGENT-WORKFLOW.md)`
- invariants: [1][2][3][4] OK, [5] FAIL(accepted-drift expected per playbook Phase 6)
- hook identity leak 0, `git diff --check` clean
- delta probe: empty (82/82)

**Review Objective:** 결과가 plan/Done Criteria와 일치하는지, 누락/회귀 없는지 result red-team.

**Must Check:**
1. `82/81/1` + 단일 AGENT-WORKFLOW.md drift가 기대대로인가. `[5]` FAIL을 accepted-drift expected로 처리하는 게 맞는가.
2. 실제 변경이 7 파일(5개 no-op)인 점이 정상인가 — no-op 5개가 정말 v1.4.0 동일인지, 누락 적용은 아닌지.
3. hook identity 렌더(`spring-modular-template`)·manifest 메타(version/profile/workflow)가 올바른가.
4. AGENT-WORKFLOW.md 콘텐츠 보존이 실제로 지켜졌나(product 분기 손실 없음).
5. delta probe empty 결론이 타당한가(manifest-tracked 한정임을 감안).
6. finalization 전 남은 리스크: spring PR(develop→main) + harness tracking commit 순서·gate 누락.

**Do Not Re-litigate:** mechanism(whole manifest replace), baseline(v1.4.0), source 보강 3건 — 확정.

**Reviewer Posture:** 결과 회귀·누락·과장 의심. speculation 표시.

**Output Contract:** Verdict(approve/conditional/request-changes/reject) · must-fix · nice-to-have · residual risk.

### R1 — Reviewer Findings (Codex)

Verdict: **approve**. must-fix 없음. 독립 재현(clean v1.4.0 tag clone)으로 packet 핵심 주장 전부 일치 확인: `--check` 82/81/1 단일 AGENT drift, no-op 5개 = v1.4.0 shadow 동일, 변경 6개 = shadow 동일, manifest = shadow 동일, AGENT-WORKFLOW.md 미변경+shadow와 다름(product 분기 보존), hook leak 0, invariants `[1]~[4] OK / [5] FAIL`(accepted-drift 자기일관성 실패). spring CI는 `check-scaffold-invariants.sh`를 hard gate로 돌리지 않음(whitespace/hook syntax/commit subject 중심).

| ID | Severity | Finding |
| --- | --- | --- |
| R1-Codex-N1 | nice | `[5] FAIL`을 "accepted"로만 쓰지 말고, **정확히 `docs/AGENT-WORKFLOW.md` 1건 보존 때문에 `manifest+--check 자기일관성`만 실패, `[1]~[4] OK`** 라고 기록 |
| R1-Codex-RR | residual | `docs/AGENT-WORKFLOW.md` accepted-drift는 향후 source upgrade마다 `[5]`를 반복적으로 깸. PR 차단 아님. route-out의 "accepted-drift 표현/upgrade helper" 부채 유지 |

### R1 — Driver Response (Claude)

| Finding | Decision | Response |
| --- | --- | --- |
| N1 | **accept** | Validation Evidence/Completion에 정확한 문구 반영: **`[5]` FAIL은 `docs/AGENT-WORKFLOW.md` 단일 accepted-drift 보존으로 `manifest+--check 자기일관성`만 깨진 것이며 `[1]~[4]`는 OK. 회귀 실패 아님(의도된 drift).** |
| RR | **accept (route-out)** | backlog residual로 명시 등록 제안: "source upgrade 시 product-customized 파일(AGENT-WORKFLOW.md 등) accepted-drift가 `[5]`를 반복 깨는 구조 — manifest schema의 accepted-drift first-class 표현 또는 `--upgrade` helper" |

R1 verdict: **approve**. cross-review(R0/R0b/R1) 종료. nice-to-have 반영 완료.

### `[5]` 판정 메모 (R1-Codex-N1 반영 — 미래 독자용)

이 Work 적용 후 `check-scaffold-invariants.sh`가 `OVERALL: FAIL`로 끝나는 것은 **정상/의도**다. 원인은 **오직 `docs/AGENT-WORKFLOW.md` 1건의 product accepted-drift**이며, 이 때문에 `[5] manifest+--check 자기일관성`만 실패한다. `[1] no-dangling`, `[2] no-leak`, `[3] index closure`, `[4] README 일치`는 모두 OK다. 회귀가 아니라 의도된 product 분기 보존의 결과다.

### R0b — Pre-Apply Relay Packet (revised plan + source 보강)

**Role:** Driver = Claude / Reviewer = Codex / Arbiter = User

**Target:** 갱신된 Work plan + source-only maintainer 보강 (apply **전** 최종 검토)

**Delta Since R0:**
- R0 finding F1~F4 + N1~N3 전부 accept 반영 (Driver Response 참조)
- apply mechanism 확정: **shadow re-scaffold(v1.4.0 tag, profile=spring-boot, workflow=source-gitflow, project=spring-modular-template)** → 11 adapt-rendered 파일 + 12 manifest row(+version 1.4.0) splice, AGENT-WORKFLOW.md 콘텐츠 보존
- source-only 보강 3건 (playbook Phase 4·6, VERIFICATION T2) — Discovery `Source-side 보강` 표 참조
- Classification table(11 apply + 1 preserve + manifest) Scope에 반영

**Current State:**
- harness branch `feature/chore-20260624-001-spring-fw-upgrade`: Work 파일·STATUS·index·playbook 2건·VERIFICATION 1건 수정 (uncommitted)
- spring branch `feature/harness-upgrade-1.4.0`: **무변경** (apply 미시작)
- validation so far: F1/F2 코드 검증 완료(`adapt():208`, `do_check():340`)

**Review Objective:** apply **직전** 최종 red-team. 특히 보강이 과한지/누락인지, mechanism이 drift 0(+accepted 1)을 실제로 낼지.

**Must Check:**
1. shadow re-scaffold splice mechanism이 실제로 `--check` 11 in-sync + AGENT-WORKFLOW.md locally-modified(accepted)를 내는가. manifest splice 시 `src` anchor(예: `.cursor/rules/workflow.mdc` → `scripts/templates/default/...`)·hash_mode normalization 누락 위험은?
2. source-only 보강 3건이 "이번 apply 안전성에 직접 필요한 최소"를 넘지 않는가. 반대로 빠진 필수 문구는?
3. AGENT-WORKFLOW.md의 manifest recorded hash를 v1.4.0로 갱신(콘텐츠 보존)해 `locally-modified`로 표시하는 선택이 옳은가, 아니면 recorded hash도 보존해 `source-updated`로 둬야 하나?
4. profile/workflow 일치 요건(T2 보강)이 spring manifest(`spring-boot`/`source-gitflow`)와 정확히 맞는가. shadow가 만들어낼 framework_files 집합이 spring의 82 tracked와 어긋날 위험은?
5. 적용 순서(harness 보강 → spring apply → delta probe → validation → R1)와 2-repo finalization gate에 누락은?

**Do Not Re-litigate:**
- baseline = v1.4.0 tag, scope = drift apply only + probe route-out, 역할(Claude driver/Codex reviewer) — 확정
- R0 findings 자체 — 이미 accept

**Reviewer Posture:** 방향·mechanism 정확성·보강 scope 적정성 의심. apply가 비가역 영역(spring write)으로 가기 전 마지막 gate. speculation은 표시.

**Output Contract:**
- Verdict: approve / conditional / request-changes / reject
- Must-fix (apply 전 반드시)
- Nice-to-have
- Residual risk
- Suggested wording

### R0b — Reviewer Findings (Codex)

Verdict: **conditional**. Codex가 temp shadow scaffold 실제 생성·검증: `spring-boot`+`source-gitflow`+`spring-modular-template` = spring manifest와 **82 path 일치**, whole shadow manifest 교체 + 11 apply + AGENT 보존 시 `82 tracked / 81 in-sync / 1 drifted([locally-modified] docs/AGENT-WORKFLOW.md)` 확인. Must Check 1~5 approve(1은 F1 조건).

| ID | Severity | Must-fix |
| --- | --- | --- |
| R0b-Codex-F1 | P1 | manifest 부분 splice + JSON pretty-print 금지(`--check`는 single-line row grep 전제 → pretty화 시 82개 전부 source-missing). path set 82/82 동일하므로 **whole shadow manifest replace** |
| R0b-Codex-F2 | P2 | frontmatter `scope`가 아직 "11건 overwrite" — 본문과 충돌. adapt-render + manifest rebaseline + preserve로 수정 |
| R0b-Codex-F3 | P2 | validation 기대값을 full summary `82 tracked / 81 in-sync / 1 drifted`로. 11개 in-sync는 보조 diff |
| R0b-Codex-F4 | P2 | final validation은 `ai-workflow-v1.4.0` clean tag checkout/worktree에서 실행(source ref가 clean tag로 찍히게) |

### R0b — Driver Response (Claude)

| Finding | Decision | Response |
| --- | --- | --- |
| F1 | **accept** | mechanism을 row splice → **whole shadow manifest replace**로 변경(Scope/Plan 반영). path set 82/82 동일 근거. 부수 효과로 N3(AGENT recorded hash v1.4.0)도 자연 충족 |
| F2 | **accept** | frontmatter scope 수정 완료 |
| F3 | **accept** | Done Criteria/Plan 기대값 → `82/81/1` |
| F4 | **accept** | validation을 v1.4.0 clean tag worktree에서 실행 |

R0b verdict: conditional → **전부 accept로 해소**. manifest 적용 방식 확정(whole replace). **apply 진행 가능.**
