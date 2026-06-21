---
id: CHORE-20260621-005
priority: P1
status: Done
risk: L2
scope: spring-modular-template adopter upgrade walkthrough를 playbook 기준 read-only target probe와 ownership classification slice로 착수하고, temp rehearsal/real apply는 owner gate로 분리한다.
appetite: 1d
planned_start: 2026-06-21
planned_end: 2026-06-21
actual_end: 2026-06-21
related_dr: [DR-034, DR-042]
related_troubleshooting: []
related_work: [CHORE-20260621-002, CHORE-20260621-003, CHORE-20260621-004]
---

# CHORE-20260621-005: spring-modular-template Adopter Upgrade Walkthrough

## Top Summary

이번 Work는 `spring-modular-template`를 다음 adopter probe로 삼아 `docs/maintainer/ADOPTER-UPGRADE-MIGRATION-PLAYBOOK.md`의 순서를 실제로 다시 탄다. 단, 현재 slice의 범위는 **read-only target probe + ownership classification**까지다.

핵심 가드는 세 가지다. 첫째, 최신 scaffold에 가까워 보여도 customization이 없다고 가정하지 않는다. 둘째, `0 drift` 또는 low drift를 preservation-safe evidence로 과장하지 않는다. 셋째, temp rehearsal과 real target apply는 각각 별도 owner gate를 통과하기 전에는 실행하지 않는다.

R1 review에서 `spring-modular-template`는 manifest target(`.harness/manifest.json` 존재, manifest `harness_version: 1.3.0`)임이 확인됐다. 따라서 이 Work는 DR-034의 pre-manifest shadow scaffold baseline 재현 조건(#1)을 전진시키지 않는다. 전진 가능성이 있는 것은 project-owned/customized 보존 기준(#2)과 customized framework entrypoint merge-not-overwrite 기준(#3)뿐이며, probe 결과가 thin하면 "manifest-target parity 확인, DR-034 promotion 기여 낮음"으로 약하게 닫는다.

R3 baseline correction: 이번 Work의 source baseline은 **develop/current checkout 기준**이다(`feature/spring-adopter-upgrade-walkthrough` HEAD `5a60d2d`, `develop` `5a60d2d`, `main` `39807ec`, `VERSION=1.3.0`). 따라서 이번 결과는 released `main`/tag 기준 upgrade proof가 아니라 develop-based probe/rehearsal evidence로만 기록한다. 이후 adopter upgrade/apply evidence의 기본 기준은 released `main` 또는 release tag로 분리 제안한다.

역할은 Codex A = author/driver, Claude B = red-team reviewer다. Claude B는 내적 정합성뿐 아니라 "이 방향 자체가 맞는가"를 의심하는 관점으로 R round를 진행한다.

## Collaboration Workflow

```text
사용자 지시
-> Codex A가 Work file + plan 작성
-> Claude B red-team review (R round, 필요시 반복)
-> 합의
-> Codex A가 read-only probe + classification 실행
-> Claude B result review
-> 사용자 최종 승인
-> temp rehearsal owner gate 판단
-> real apply owner gate 판단
-> /work-close
-> commit
-> PR --base develop
-> merge
```

## Cross-Repo Execution Boundary

| Repo | Allowed In This Slice | Owner Gate |
| --- | --- | --- |
| `ai-workflow-harness` | 이 Work file, Work index, 승인된 STATUS pointer 제안/반영, 결과 기록 | STATUS 변경은 별도 승인 |
| `/Users/kyungseo/dev-home/vibe/spring-modular-template` | read-only probe, branch policy inspection, manifest/check result inspection, ownership classification draft | target write 금지 |
| temp rehearsal tree | 비범위. Classification 합의 후 owner가 승인하면 별도 CP에서 생성 | owner gate 필요 |
| real target branch/apply/PR | 비범위. Rehearsal result review + owner final sign-off 후에만 가능 | owner gate 필요 |

## Context Manifest

| 순서 | 파일 | 섹션 | 왜 |
| --- | --- | --- | --- |
| 1 | `docs/STATUS.md` | Next Actions | 이번 Work의 직접 trigger |
| 2 | `docs/maintainer/ADOPTER-UPGRADE-MIGRATION-PLAYBOOK.md` | Phase 0-4, Adopter-Specific Notes | 표준 probe/classification 순서와 gate |
| 3 | `docs/decisions/DR-034-harness-upgrade-ownership-policy.md` | Draft Decision, Promotion Conditions | pre-manifest/ownership 정책과 promotion 조건 |
| 4 | `docs/backlog/HARNESS.md` | W2 Adopter Transition candidates | 후속 candidate와 gate 관계 |
| 5 | `docs/briefs/harness-internal-managed-upgrade-20260615.md` | Candidate A/B/C, Claude Review | internal managed mode를 walkthrough 후속 gate로 제한한 근거 |
| 6 | `docs/works/harness/CHORE-20260621-002-ai-deck-compiler-upgrade-walkthrough.md` | Top Summary, Walkthrough Output, Cross-Agent Review | overwrite-convergence와 baseline-acquisition caution |
| 7 | `docs/works/harness/CHORE-20260621-003-ai-deck-real-migration.md` | Scope, Verification, Review | real apply gate와 evidence wording precedent |
| 8 | `docs/works/harness/CHORE-20260621-004-adopter-dr-namespace-apply.md` | Scope, DR-034 Judgment | DR-042 이후 product/adopter DR namespace closure precedent |

Trigger: `docs/STATUS.md` Next Actions의 "`spring-modular-template` adopter upgrade walkthrough — playbook 기준 read-only target probe + ownership classification부터 시작" 착수.

## Plan

### Slice A — Work Preparation And Review Gate

- Work file과 Active index를 생성한다.
- `docs/STATUS.md` Active Work pointer 추가는 별도 승인 제안으로 둔다.
- Claude B R1 red-team review를 요청한다.
- R1 finding이 있으면 Codex A response와 Consensus Log를 같은 Work 파일에 누적한다.

### Slice B — Read-Only Target Probe

Playbook Phase 1만 실행한다. target repo write, temp copy, branch creation은 하지 않는다. `scripts/create-harness.sh --check <target>`는 report-only이므로 read-only boundary 안에서 실행 가능하다.

기록 대상:

- source baseline: branch/ref, `main`/`develop` SHA, `VERSION`, released 기준인지 develop 기준인지
- target current branch, dirty 여부, `HEAD`, `origin/develop`/`origin/main` 관계
- target `docs/GIT-WORKFLOW.md` 존재 여부와 branch/PR policy
- `.harness/manifest.json` 존재 여부
- manifest `harness_version`과 source `VERSION` 비교
- `scripts/create-harness.sh --check <target>` 결과 요약. 단, 이 결과는 proof가 아니라 classification input으로만 취급한다.

Hard stop:

- target working tree가 dirty이면 owner가 mixed state probe를 명시 승인하기 전 classification을 멈춘다.
- branch/base가 불명확하면 baseline 선택을 보류한다.
- source baseline ref가 불명확하면 `--check` 결과를 upgrade evidence로 쓰지 않는다.

### Slice C — Baseline And Ownership Classification

Probe 결과 기준 이 target은 manifest 경로로 좁힌다. R1 diligence에서 `.harness/manifest.json` 존재가 확인됐으므로 shadow scaffold baseline은 이 target에는 적용하지 않는다.

| Baseline Candidate | 사용 조건 | 이번 Work 판단 |
| --- | --- | --- |
| manifest target | `.harness/manifest.json` 존재 | 적용. `--check`가 직접 유효 |
| 3-way adoption commit | target history에서 clean adoption commit 확인 | 이 target에는 비적용. 필요하면 참고 audit만 |
| shadow scaffold | manifest 부재 또는 history 신뢰 낮음 | 이 target에는 비적용. DR-034 condition #1 증거로 쓰지 않음 |

모든 후보 변경은 아래 classification 중 하나로만 기록한다.

| Classification | Action | Notes |
| --- | --- | --- |
| `source-retired` | 제거 후보 | old command/skill/prompt surface가 target에 남은 경우 |
| `framework-add` | current source scaffold file 추가 후보 | 신규 adapter/rule/docs surface |
| `framework-update` | current source 반영 후보 | customization 없는 framework surface만 |
| `merge` | manual merge 후보 | `CLAUDE.md`, `AGENTS.md`, `.gitignore`, session-start prompts 등 |
| `preserve` | target 유지 | product docs, product code, product decisions, backlog/work/status |
| `delete-respect` | no-op | adopter delete와 source retire가 일치할 때 |
| `accepted-drift` | divergence 유지 + 이유 기록 후보 | owner sign-off 전 확정 금지 |
| `blocker` | 멈춤 | policy/index/namespace/branch blocker |

Manifest target에서는 `--check`의 3-status를 classification 입력으로 매핑한다.

| `--check` Status | 기본 Classification | Review Rule |
| --- | --- | --- |
| `in-sync` | no-op | 현재 source와 manifest-tracked target이 같으므로 migration action 없음 |
| `source-updated` | `framework-update` candidate | per-file diff로 adopter-side edit 부재가 확인될 때만 확정. edit이 있거나 판별 불가하면 `merge`로 강등. Entry point path heuristic은 보조 근거일 뿐 단독 근거로 쓰지 않음 |
| `locally-modified` | `merge` / `preserve` | entrypoint·prompt·docs·product state별 owner judgment 필요. owner sign-off 전 `accepted-drift` 확정 금지 |

### Slice D — Gate Decision, Not Rehearsal

이번 Work의 기본 완료 지점은 classification table과 gate 판단이다.

- temp rehearsal을 열지 말지는 owner가 classification table을 보고 결정한다.
- real apply는 temp rehearsal result review와 owner final sign-off 이후 별도 gate다.
- DR-034 promotion wording은 per-condition으로 둔다. manifest target 결과는 #2/#3 보존 기준 evidence가 될 수 있으나, #1 pre-manifest shadow scaffold baseline 재현은 전진시키지 않는다.
- probe 결과 `source-updated`/`locally-modified`가 거의 없으면 "manifest-target parity 확인, DR-034 promotion 기여 낮음"으로 honest-close한다.
- manifest target도 `source-updated` 파일은 at-generation snapshot 부재로 source evolution과 adopter-side edit을 clean separation할 수 없다. 따라서 #2/#3 evidence 강도는 per-file diff와 owner judgment로 bound한다.
- 이번 Work는 develop/current checkout 기준 probe로 라벨링한다. released `main`/tag 기준 upgrade proof가 아니므로 DR-034 promotion evidence 강도는 그만큼 낮춘다.
- internal managed mode는 이 Work에서 설계하지 않는다. 반복 비용 또는 중앙 관리 필요가 실제로 보이면 backlog gate 판단으로만 연결한다.

## Done Criteria

- [x] Claude B R1 red-team review가 Cross-Agent Review에 기록된다.
- [x] R1 finding에 대한 Codex A response와 Consensus Log가 기록된다.
- [x] target read-only probe 결과가 기록된다: branch/base, dirty 여부, manifest 상태, branch policy, `--check` 요약.
- [x] source baseline이 기록된다: 이번 Work는 develop/current checkout 기준이며 released `main`/tag upgrade proof가 아님.
- [x] manifest baseline 적용 사유와 shadow scaffold/3-way baseline 비적용 사유가 기록된다.
- [x] ownership classification draft가 path/action/reason 기준으로 기록된다.
- [x] `--check` status(`in-sync` / `source-updated` / `locally-modified`)가 classification(`framework-update` / `merge` / `preserve` 등)으로 매핑된다.
- [x] temp rehearsal gate와 real apply gate가 명시적으로 분리된다.
- [x] DR-034 condition #1/#2/#3별 evidence contribution과 thin-evidence honest-close 여부가 과장 없이 정리된다.
- [x] Internal managed/Packaging/Happy path 후속 후보에 대한 evidence boundary가 과장 없이 정리된다.
- [x] 사용자 최종 승인 후 `/work-close` 가능한 상태가 된다.

## Verification

Planning/file setup:

- `git diff --check`

Read-only target probe:

```bash
TARGET="/Users/kyungseo/dev-home/vibe/spring-modular-template"
git branch --show-current
git rev-parse --short HEAD
git rev-parse --short main
git rev-parse --short develop
cat VERSION
git -C "${TARGET}" status --short --branch
git -C "${TARGET}" log --oneline -n 12
test -f "${TARGET}/docs/GIT-WORKFLOW.md" && sed -n '1,180p' "${TARGET}/docs/GIT-WORKFLOW.md"
test -f "${TARGET}/.harness/manifest.json" && echo "manifest target" || echo "pre-manifest target"
bash scripts/create-harness.sh --check "${TARGET}" || true
```

Classification self-check:

- 모든 변경 후보가 `source-retired` / `framework-add` / `framework-update` / `merge` / `preserve` / `delete-respect` / `accepted-drift` / `blocker` 중 하나에 들어갔는지 확인한다.
- `--check` status 매핑: `in-sync` -> no-op, `source-updated` -> `framework-update` candidate(per-file diff 확인 전에는 확정 금지), `locally-modified` -> `merge`/`preserve`(owner judgment 필요).
- `source-updated`는 source evolution이 primary signal이라는 뜻일 뿐 adopter-side edit 부재 증명이 아니다. per-file diff로 edit 부재가 확인될 때만 `framework-update`로 확정하고, edit이 있거나 판별 불가하면 `merge`로 강등한다.
- `preserve`와 `accepted-drift`는 owner sign-off 전 확정값으로 쓰지 않는다.
- `0 drift`가 나와도 customized framework entrypoint overwrite-convergence 가능성을 별도로 점검한다.
- `source-updated`와 `locally-modified`를 서로 오독하지 않았는지 path별 reason을 남긴다.

## Risk

| Risk | Likelihood | Impact | Mitigation |
| --- | --- | --- | --- |
| 최신 scaffold에 가까워 보인다는 이유로 classification을 생략 | Medium | High | playbook Phase 1-4를 그대로 적용 |
| read-only probe 결과를 upgrade proof로 과장 | Medium | Medium | proof가 아니라 classification input으로만 기록 |
| target dirty state 위에서 migration 판단 | Low | High | dirty면 hard stop |
| product-owned docs/code를 framework drift로 오분류 | Medium | High | `preserve` 기본값 + owner sign-off |
| temp rehearsal/real apply가 scope creep으로 들어옴 | Medium | High | Slice D gate 외에는 실행 금지 |
| DR-034 Accepted 또는 internal managed gate 과속 | Medium | Medium | evidence 1건/2nd signal 후보로 보수 표기 |

Reversal cost: Work/index 기록은 Low, target write는 이번 slice에서 금지하므로 target reversal cost는 발생하지 않는다. 이후 temp rehearsal은 temp tree 삭제로 Low, real apply는 target PR/commit revert가 필요하므로 Medium 이상이다.

## Plan Checklist

| Required Item | Current Plan |
| --- | --- |
| 위험도 | L2 |
| 실행 모드 | Standard Work |
| 확인 파일 | Context Manifest + target read-only probe |
| 변경 범위 | source Work file/index; 승인 시 STATUS pointer; target은 read-only |
| Done Criteria | 위 Done Criteria |
| Verification | `git diff --check`, read-only probe commands, classification self-check |
| 리스크와 되돌리기 비용 | Risk 섹션 |
| Tool rule reference | `.claude/rules/docs-workflow.md` matched for `docs/**/*.md`; DR-007 적용 |
| STATUS 반영 제안 | `CHORE-20260621-005` Active Work pointer 추가 제안 |
| 상태 머신 단계 | INIT 완료, PLAN 진행 중, 다음은 APPROVAL |

T5 PLAN direction alignment: PLAN 자체 변경은 예상하지 않는다. 다만 결과가 DR-034 promotion, internal managed mode, packaging revisit, happy path/glossary 후보의 gate 판단에 영향을 줄 수 있으므로 closeout에서 PLAN/PLAN-SUMMARY stale 여부를 확인한다.

## Read-Only Probe Output

### Source Baseline

이번 probe는 released `main`/tag 기준이 아니라 develop/current checkout 기준이다.

| Item | Value |
| --- | --- |
| source branch | `feature/spring-adopter-upgrade-walkthrough` |
| source HEAD | `5a60d2d` |
| source `develop` | `5a60d2d` |
| source `main` | `39807ec` |
| source `VERSION` | `1.3.0` |
| evidence label | develop/current checkout based probe, not released upgrade proof |

### Target Probe

| Item | Value |
| --- | --- |
| target | `/Users/kyungseo/dev-home/vibe/spring-modular-template` |
| target branch | `develop...origin/develop` |
| dirty state | clean |
| target HEAD | `50d7058` (`release: develop 변경분 main 반영`) |
| branch policy | source-gitflow, feature branches required for writes, read-only validation exception allowed |
| manifest | present |
| manifest `harness_version` | `1.3.0` |
| manifest profile/workflow | `spring-boot` / `source-gitflow` |

`scripts/create-harness.sh --check /Users/kyungseo/dev-home/vibe/spring-modular-template`:

```text
harness --check: /Users/kyungseo/dev-home/vibe/spring-modular-template
  manifest version : 1.3.0   (current source: 1.3.0)
  enforcement      : hook-capable (source-gitflow hook files present; run tools/git-hooks/install.sh to activate)
  gate config      : .harness/gate-config present (0 project path(s))

  [locally-modified] docs/AGENT-WORKFLOW.md
  [source-updated] docs/HARNESS-PROTOCOL.md
  [source-updated] docs/HARNESS-NAMING-RULES.md
  [source-updated] skills/workflow/session-start.md
  [source-updated] skills/workflow/work-close.md
  [locally-modified] tools/git-hooks/install.sh
  [locally-modified] tools/git-hooks/lib/gate-lists.sh

summary: 82 tracked, 75 in-sync, 7 drifted
  (source-updated=primary signal, locally-modified=advisory)
```

## Ownership Classification Draft

This is a draft classification only. No target write, temp rehearsal, accepted-drift finalization, or real apply has been approved.

| Path | `--check` Status | Classification | Reason / Owner Decision |
| --- | --- | --- | --- |
| `docs/AGENT-WORKFLOW.md` | `locally-modified` | `preserve` | Target has product-specific Project Constants and Java/Spring verification defaults. Treat as project-owned/customized operational context, not framework overwrite. |
| `docs/HARNESS-PROTOCOL.md` | `source-updated` | `framework-update` candidate | Source adds `Needs-Triage` archive-burial behavior. Visible diff is source-side addition to older framework text; no product-specific target content observed. Still candidate until owner gate because `source-updated` cannot cleanly separate local edits. |
| `docs/HARNESS-NAMING-RULES.md` | `source-updated` | `blocker` | File is framework-update candidate, but the embedded DR-042 high-band policy triggers downstream product DR namespace work. Target already has indexed product DRs `DR-030`~`DR-033`; owner decision is product DR renumber/index update vs grandfather/defer, not blind naming-rules copy. |
| `skills/workflow/session-start.md` | `source-updated` | `framework-update` candidate | Source adds archive-pending `Needs-Triage` surfacing. Visible diff is source-side addition to older framework text; no product-specific target content observed. Candidate only; no direct apply before owner gate. |
| `skills/workflow/work-close.md` | `source-updated` | `framework-update` candidate | Source adds forward-relevant decision triage and Next Actions review. Visible diff is source-side addition to older framework text; no product-specific target content observed. Candidate only; no direct apply before owner gate. |
| `tools/git-hooks/install.sh` | `locally-modified` | `framework-update` / rename-cleanup candidate | Diff is comment identity only. Target manifest `project_name` is `spring-modular-template`, but file still says `base-spring-modular-template`; this is stale scaffold rename artifact, not adopter logic to preserve. Candidate action is re-render/rename cleanup, not manual merge. |
| `tools/git-hooks/lib/gate-lists.sh` | `locally-modified` | `framework-update` / rename-cleanup candidate | Same stale `base-spring-modular-template` comment artifact as `install.sh`; `gate-lists.sh` remains framework-owned. Candidate action is re-render/rename cleanup, not manual merge. |

### Gate Decision

- Temp rehearsal: **not recommended now**. The probe already surfaced the main blocker; product DR renumber/index update is real-apply scope and should be split to a follow-up Work.
- Real apply: **not approved**. Requires temp rehearsal result review and owner final sign-off.
- DR-034 evidence: #1 remains unmet for this target because manifest path does not test pre-manifest shadow scaffold baseline. #2/#3 get only bounded evidence because source baseline is develop/current checkout and `source-updated` cannot cleanly separate source evolution from adopter-side edits.
- Internal managed / Packaging: no gate opens from this probe alone. The result is useful as a manifest-target classification sample, not released upgrade proof.
- Follow-up shape if owner chooses apply later: `docs/HARNESS-NAMING-RULES.md` adoption requires product DR `030`~`033` renumber/index cascade or explicit grandfather/defer decision. Unlike ai-deck, `docs/decisions/README.md` already exists, so this should be lighter than CHORE-20260621-004.

## Cross-Agent Review

### Cross-Agent Review And Discussion

Claude B R1에서 특히 의심할 질문:

- target 선택 자체가 맞는가? `spring-modular-template`가 "latest scaffold에 가까운 adopter"라면 net-new evidence가 낮지 않은가?
- read-only probe + classification만으로 Work를 닫는 게 충분한가, 아니면 temp rehearsal까지 열어야 의미가 생기는가?
- classification table이 실제 owner decision을 만들 만큼 path-level로 충분히 세밀한가?
- `0 drift` 또는 low drift를 preservation-safe로 오판할 risk가 남아 있는가?
- DR-034 promotion/internal managed/packaging gate를 약한 evidence 위에서 다시 열 가능성은 없는가?

#### R1 Review Result — Claude B

Status: **Request changes** (방향은 유효하나 evidence framing과 classification 입력 매핑을 고쳐야 함). review diligence로 target meta만 read-only 확인했고 Slice B probe(`--check` 실행)는 합의 후 Codex A 몫으로 남겨둠.

Review diligence로 확인한 사실(probe deliverable 아님, 검증용 meta read만):
- target `/Users/kyungseo/dev-home/vibe/spring-modular-template`는 **manifest target**이다(`.harness/manifest.json` 존재). 이는 ai-deck(pre-manifest)와 **다른 adopter class**다.
- target manifest `harness_version: 1.3.0` == source `VERSION: 1.3.0`. branch는 `develop` clean, `docs/GIT-WORKFLOW.md` 존재.
- `--check`(source `create-harness.sh:223-330`)는 manifest 기록 hash(scaffold 시점 source) + current source를 비교해 `in-sync / source-updated / locally-modified`로 분류한다. report-only("writes nothing", L224) — Cross-Repo read-only 경계는 안전 확인됨.

**F1 (Material — 방향 framing 오류). DR-034 "second adopter signal" 주장은 condition #1을 전진시키지 못한다.**
DR-034 Promotion Conditions #1 = "shadow scaffold baseline 방식이 재현 가능함을 확인". manifest target은 shadow scaffold baseline 경로를 **전혀 타지 않는다**(native manifest `--check` 사용). 즉 이 adopter는 DR-034 핵심 메커니즘(#1)에 대해서는 여전히 1-adopter evidence다. 전진 가능한 것은 #2(project-owned/customized 보존)와 #3(customized framework entrypoint merge-not-overwrite)뿐이다.
→ **요구:** Top Summary와 Slice D, Done Criteria에서 "second adopter signal"을 무조건적으로 쓰지 말고, "manifest-target 계열에서 #2/#3만 전진, #1(pre-manifest shadow scaffold)는 미전진"으로 per-condition 매핑을 명시한다. 그렇지 않으면 후속 세션에서 이 Work가 DR-034 일괄 promotion 근거로 느슨하게 인용될 risk가 있다(plan 자신이 R1 질문으로 던진 risk와 동일).

**F2 (Material — net-new evidence가 plan 가정보다 낮을 수 있음, honest-close 조건 필요).**
target manifest version == source version. version 문자열이 같다고 in-sync는 아니지만(per-file hash가 결정), 동일 버전대 scaffold면 `source-updated` 집합이 작을 개연성이 있다. 그러면 upgrade-migration 자체의 net-new evidence가 thin해진다 — plan이 스스로 의심한 "latest scaffold에 가까운 adopter면 net-new 낮음" 질문이 여기서 현실화된다.
→ **요구:** Slice B probe 후 `source-updated`/`locally-modified`가 거의 0이면, Work를 "강한 2nd signal"로 닫지 말고 "manifest-target parity 확인, DR-034 promotion 기여 낮음"으로 **정직하게 약하게 닫는다**는 분기를 Done Criteria/Slice D에 미리 박는다.

**F3 (Concrete — `--check` status→classification 매핑이 누락. manifest-target 고유 실패모드).**
plan의 guard는 전부 ai-deck의 "0 drift = overwrite-convergence" 함정(preservation-safe 과장)에 맞춰져 있다. 그러나 manifest target의 고유 실패모드는 그 **거울상**이다: `source-updated`(framework가 source에서 전진 = framework-update 후보)를 `locally-modified`(adopter customization = merge/preserve 후보)로, 또는 그 반대로 오독하는 것. 현재 classification taxonomy(8종)는 `--check` 3-status와 연결되어 있지 않아 free-floating이다.
→ **요구:** Verification "Classification self-check"에 status→classification 매핑을 명시한다: `source-updated`→`framework-update`(단 customized entrypoint면 `merge`로 강등), `locally-modified`→`merge`/`preserve`(entrypoint judgment 필요), `in-sync`→no-op. 또한 probe 기록에 manifest version line(`manifest version` vs `current source`)을 포함해 upgrade gap을 bound한다.

**F4 (Minor — Slice C baseline table 정리).**
probe로 baseline 불확실성이 해소됐다(manifest 존재 → baseline = manifest, `--check` 직접 유효, DR-034 §5). Slice C 표의 `3-way adoption commit`/`shadow scaffold` fallback row는 이 target에 N/A다. shadow scaffold를 새로 만들 필요 없음.
→ **권고:** 합의 후 Slice C를 manifest 경로 단일로 좁히고 fallback row는 "이 target 비적용"으로 표기.

**F5 (Affirm — 유지해도 되는 결정).**
- Slice D의 temp rehearsal / real apply owner gate 분리: 타당. 변경 불필요.
- classification + gate에서 닫는 것: manifest target은 `--check`가 직접 유효하므로 ai-deck 때보다 **더** 방어 가능. 단 F1/F2/F3 반영 조건부.
- Cross-Repo read-only 경계: `--check` report-only 확인됨, source repo에서 target 대상 실행도 write 없음. 안전.

요약: 방향(2nd adopter probe)은 유지. 단 (a) DR-034 per-condition 매핑(F1), (b) thin-evidence honest-close 분기(F2), (c) `--check` status→classification 매핑(F3)을 plan에 반영해야 R1 합의 가능. F4는 cleanup, F5는 affirm.

#### R1 A Response — Codex A

Status: **Accept / revise**. F1-F4를 모두 수용한다. F5는 유지한다.

| Finding | A Response | Plan Revision |
| --- | --- | --- |
| F1 DR-034 per-condition framing | **Accept.** `spring-modular-template`가 manifest target이면 pre-manifest shadow scaffold baseline 재현 조건(#1)을 전진시키지 않는다. 이 Work의 DR-034 기여는 #2(project-owned/customized 보존)와 #3(customized framework entrypoint merge-not-overwrite) 후보로 제한한다. | Top Summary, Slice C, Slice D, Done Criteria에 condition #1/#2/#3 매핑을 추가 |
| F2 thin-evidence honest-close | **Accept.** manifest version이 source version과 같아 probe 결과가 얇을 수 있다. 그 경우 강한 2nd signal이 아니라 "manifest-target parity 확인, DR-034 promotion 기여 낮음"으로 닫는다. | Slice D와 Done Criteria에 honest-close 분기 추가 |
| F3 `--check` status→classification mapping | **Accept.** ai-deck의 overwrite-convergence risk만으로는 manifest target 고유 실패모드를 덮지 못한다. `source-updated`와 `locally-modified` 오독 방지를 명시한다. | Slice C와 Verification에 status mapping 표와 self-check 추가 |
| F4 baseline table cleanup | **Accept.** manifest 존재가 확인됐으므로 this target은 manifest baseline 경로로 좁힌다. 3-way/shadow scaffold는 비적용으로 낮춘다. | Slice C baseline table 수정 |
| F5 affirm | **Keep.** temp rehearsal/real apply owner gate와 read-only boundary는 유지한다. | 변경 없음 |

R1 이후 현재 판정: plan은 probe 실행 전 B re-check 또는 owner 확인을 받을 수 있는 상태로 수정됐다. 아직 target `--check`는 실행하지 않았다.

#### R2 Review Result — Claude B

Status: **Conditional agree** — F1-F4 반영을 plan 본문에서 확인했고(아래 위치), F5 유지에 동의한다. 다만 F3에서 새로 들어온 `--check` 매핑이 script 실제 동작과 만나는 지점에서 **하나의 구조적 gap(R2-1)**이 남아, 이것만 정리하면 R round 합의 가능하다.

R1 반영 확인(plan 본문 직접 검증):
- F1: Top Summary(manifest target + #1 미전진 + #2/#3 only), Slice D("per-condition으로 둔다 … #1 … 전진시키지 않는다"), Done Criteria("condition #1/#2/#3별 evidence contribution") — 반영됨.
- F2: Slice D("source-updated/locally-modified 거의 없으면 … honest-close"), Done Criteria 동일 줄 — 반영됨.
- F3: Slice C status 매핑 표 + Verification self-check(`source-updated`/`locally-modified` 오독 방지 path별 reason), Slice B에 manifest version line 추가 — 반영됨.
- F4: Slice C baseline table에서 3-way/shadow scaffold를 비적용·"#1 증거로 쓰지 않음"으로 강등 — 반영됨.

**R2-1 (Concrete, Medium — `source-updated`가 동시 local edit을 구조적으로 가린다. 매핑 default가 그만큼 안전하지 않다).**
`create-harness.sh` `do_check()`(L318-337)의 status는 **if/else 단일·상호배타**다. `cur_src_hash != recorded`이면 `status=source-updated`로 확정하고 **거기서 멈춘다** — 그 파일이 adopter에 의해 추가로 local-modify됐는지는 더 보지 않는다. script 주석 자신이 명시한다(L321-323): *"Local edits cannot be cleanly separated without an at-generation snapshot, so report source-updated."* summary도 `source-updated=primary, locally-modified=advisory`라고만 한다(L351).
→ 결과: framework 파일이 **source-updated인 동시에 adopter-customized**이면 `--check`는 `source-updated`로만 보고하고 local edit은 보이지 않는다. 현재 Slice C 매핑 `source-updated → framework-update(기본)`는 entrypoint path carve-out(`CLAUDE.md`/`AGENTS.md` 등 → merge 강등)만 가진다. 그런데 **entrypoint가 아닌** framework 파일(예: 특정 rule·workflow doc)을 adopter가 손댔는데 source도 전진한 경우, path heuristic에 안 걸려 `framework-update=blind overwrite`로 떨어진다 — 이것이 정확히 DR-034 §4가 막으려는 preservation 실패다. 이는 DR-034 §Consequences L69가 pre-manifest 2-way 한계로 적은 것과 같은 문제가, **manifest target의 source-updated 집합 안에서도** 재발하는 것이다. 즉 version-parity manifest target조차 source-updated 파일에 대해서는 clean 3-way 분리를 주지 못한다.
→ **요구(1줄급 수정):**
  1. Slice C 매핑에서 `source-updated`를 "default `framework-update`"가 아니라 "**`framework-update` candidate — 단 per-file diff로 adopter-side edit 부재가 확인될 때만 확정. edit이 있거나 판별 불가면 `merge`로 강등**"으로 바꾼다. entrypoint path heuristic은 보조일 뿐 단독 근거로 쓰지 않는다.
  2. DR-034 evidence note에 "manifest target도 source-updated 파일은 at-generation snapshot 부재로 clean separation 불가 → #2/#3 evidence 강도를 그만큼 bound"을 한 줄 남긴다(F2 honest-close와 연결).

참고: 이번 probe는 manifest `1.3.0` == source `1.3.0`이라 source-updated 집합이 작을 개연이 커서 **실제 노출은 제한적**이다. 그러나 Slice C 매핑은 playbook이 재사용하는 일반 규칙이므로, 이 thin probe 한 건을 넘어 규칙 자체를 안전하게 적어두는 게 맞다.

나머지(F1/F2/F4, entrypoint carve-out 추가분, version line)는 affirm. R2-1만 반영되면 Consensus를 Agreed로 올린다.

#### R2 A Response — Codex A

Status: **Accept / revise**. R2-1을 전면 수용한다.

| Finding | A Response | Plan Revision |
| --- | --- | --- |
| R2-1 `source-updated`가 동시 local edit을 구조적으로 가림 | **Accept.** `create-harness.sh --check`는 `cur_src_hash != recorded`일 때 `source-updated`로 멈추며, adopter-side edit을 분리하지 못한다. 따라서 `source-updated`를 바로 `framework-update`로 확정하면 preservation failure가 생길 수 있다. | Slice C 매핑을 `framework-update candidate`로 낮추고, per-file diff로 adopter-side edit 부재가 확인될 때만 확정하도록 수정. 판별 불가 또는 edit 존재 시 `merge`로 강등. Slice D에 manifest target의 `source-updated` clean-separation 한계를 DR-034 evidence bound로 추가 |

R2 이후 현재 판정: R1/R2 finding은 모두 plan에 반영됐다. target write, temp rehearsal, real apply는 여전히 owner gate 뒤에 있다. 다음 실행은 owner 승인 하 `docs/STATUS.md` Active pointer 반영 여부 확인 후 read-only probe다.

#### R3 Baseline Correction — Owner + Claude B + Codex A

Status: **Agree / capture in current Work; split policy follow-up**.

사용자와 Claude B가 같은 blind spot을 지적했다. `scripts/create-harness.sh --check`는 source ref 개념이 없고, 스크립트를 실행하는 source repo 현재 checkout(`TEMPLATE_ROOT`)을 기준으로 hash를 계산한다. 따라서 operator가 `main`에 있느냐 `develop`에 있느냐에 따라 drift가 달라질 수 있다. R1/R2의 manifest `harness_version: 1.3.0` parity 표현도 `main`/`develop`이 같은 version 문자열을 공유하는 상황에서는 release-line parity 증거가 아니다.

Codex A 판단:

- 이번 Work는 이미 ai-deck 흐름과 같은 develop/current source 계열 rehearsal이므로 **develop 기준으로 계속 진행**한다.
- 단, 결과 라벨은 `develop/current checkout based probe`로 낮춘다. released upgrade proof, DR-034 Accepted evidence, external adopter upgrade evidence로 과장하지 않는다.
- 다음 adopter upgrade/apply evidence의 기본 기준은 released `main` 또는 release tag가 되어야 한다.
- 의도적으로 develop을 볼 때는 baseline label(`source branch/ref`, `main`/`develop` SHA, `VERSION`)을 반드시 기록한다.
- 별도 후속 후보: DR-034 amendment 또는 신규 DR로 "upgrade baseline = released main/tag, develop은 명시적 예외 라벨 필수"를 기록하고, playbook probe checklist와 `--check` source-ref 출력 gap을 캡처한다.

이번 Work 반영:

- Top Summary, Slice B, Slice D, Done Criteria, Verification에 develop/current checkout 기준 라벨을 추가했다.
- Discovery에 future policy follow-up을 남긴다. 단, DR/backlog 정책 변경은 이 Work scope에 끌어들이지 않고 별도 owner approval 대상으로 둔다.

#### Result Review (CP5) — Claude B

Status: **Approve with refinements** — probe와 classification draft는 건전하고, **blocker는 독립 검증 결과 실재**한다. 단 인접 classification 2건은 정밀화가 필요하고, source-updated candidate 3건은 R2-1 per-file 확인이 아직 기록되지 않았다. owner gate는 "temp rehearsal 보류, blocker 기록 후 close"를 권고한다.

독립 검증 결과(read-only):
- **Blocker 실재 확인.** source `docs/HARNESS-NAMING-RULES.md`(develop 5a60d2d) L73-78에 DR-042 대역 정책 존재(001–799 framework, 800–999 product/adopter). target `docs/decisions/`에 product DR `DR-030`(security-openapi)·`DR-031`(observability)·`DR-032`(local-deploy-pack)·`DR-033`(observability-export-pack)가 **저대역(030~033)**에 존재 → DR-042 적용 시 namespace 위반. Codex 판정 정확.
- target framework DR(`DR-001/007/008/013/014/027/029`)은 저대역이 정상이라 충돌 없음. 충돌은 product DR 4건뿐.

**RR-1 (Refine — `install.sh`/`gate-lists.sh`는 adopter 로직이 아니라 stale rename artifact).**
검증: manifest `project_name = "spring-modular-template"`(현행)인데, target `tools/git-hooks/lib/gate-lists.sh` L2 주석은 `base-spring-modular-template`(구명). source는 `ai-workflow-harness`(SOURCE_IDENTITY). 즉 이 두 `locally-modified`는 **scaffold 후 project rename( base-spring-modular-template → spring-modular-template )에서 주석이 안 따라온 false positive**다(정확히 DR-034 §2가 경고한 project-name 치환 불일치). `gate-lists.sh`는 CLAUDE.md가 "직접 수정 금지, upgrade 시 overwrite"로 못박은 framework-owned 파일이라 보존할 adopter 로직이 없다.
→ Codex의 "merge / owner decision"은 방향은 맞지만 과보존이다. 정확한 action은 **현행 project_name으로 re-render(framework-update 계열) = stale 주석 정정**이지 수동 merge가 아니다. owner decision 문구를 "보존 vs 정정"이 아니라 "rename-cleanup re-render"로 좁히는 게 맞다.

**RR-2 (Minor — blocker classification 정밀화 + ai-deck 대비 경량).**
`HARNESS-NAMING-RULES.md` 파일 자체는 `framework-update` candidate다. 막히는 건 파일 텍스트가 아니라 그것이 트리거하는 **downstream product DR renumber**(030~033 → 800~803, CHORE-004의 014/021/022/023→801-804와 동형). 즉 owner decision은 "naming-rules 텍스트 보류"가 아니라 "product DR renumber + index 갱신"으로 scope해야 한다.
→ 추가 사실: target `docs/decisions/README.md`(decision-index) **이미 존재**하고 product DR이 STATUS/PRODUCT/README에 indexed. ai-deck(CHORE-004)은 index를 새로 만들어야 했으나 이 target은 renumber + index 갱신만 필요 → **apply 비용이 ai-deck보다 가볍다**(owner 판단 정보).

**RR-3 (Minor/completeness — source-updated candidate 3건 R2-1 확인 미기록).**
`HARNESS-PROTOCOL.md`/`session-start.md`/`work-close.md`는 framework-update candidate로 보수적으로 남겨 R2-1을 존중했다. 다만 "adopter-side edit 부재" per-file diff 확인이 result에 명시 기록되지 않았다. 세 파일 모두 adopter가 통상 손대지 않는 protocol/skill surface라 framework-update 가능성이 높지만, **apply 전 per-file diff로 edit 부재를 확인했다는 한 줄**이 있어야 R2-1 self-check가 닫힌다. 이번 probe-close에는 영향 없음(apply 안 함).

**Affirm.**
- honest-close framing(Slice D L284-285): #1 unmet, #2/#3 bounded, develop-basis label — 정확.
- 이 결과는 thin이 아님(drift 7, 실 blocker 1건)이라 "manifest-target classification sample"로서 유용. 단 released upgrade proof/DR-034 promotion으로 과장 안 한 것 정합.

**Owner gate 권고:**
1. **Temp rehearsal 지금 열지 말 것.** 핵심 미해결은 product DR renumber 정책 결정(grandfather / renumber 800-803 / defer)이고 이건 real-apply 성격(reversal Medium+)이라 별도 apply Work가 맞다. probe의 임무(classification + blocker 표면화)는 완료됐다.
2. 이 Work는 **blocker 기록 후 close** 가능 상태. renumber 결정 + 실제 apply는 CHORE-004 선례를 템플릿으로 한 후속 Work로 분리.
3. close 전 RR-1/RR-2 문구 정정과 RR-3 한 줄은 author(Codex A)가 반영 권고(경미, blocker 아님).

#### Result Review A Response — Codex A

Status: **Accept / revise**. RR-1/RR-2/RR-3를 모두 수용한다.

| Finding | A Response | Work Revision |
| --- | --- | --- |
| RR-1 `install.sh`/`gate-lists.sh` 과보존 | **Accept.** 두 파일의 diff는 product logic이 아니라 stale rename artifact다. manifest project name은 `spring-modular-template`인데 주석만 `base-spring-modular-template`로 남았다. | Classification을 `merge / owner decision`에서 `framework-update / rename-cleanup candidate`로 수정 |
| RR-2 blocker scope 정밀화 | **Accept.** blocker는 naming-rules 파일 자체가 아니라 DR-042 high-band policy가 요구하는 downstream product DR renumber/index cascade다. Target은 decision index가 이미 있으므로 ai-deck보다 적용 비용이 낮다. | Classification reason과 Gate Decision에 product DR `030`~`033` renumber/index update vs grandfather/defer owner decision으로 정리 |
| RR-3 source-updated 후보 3건 per-file 확인 | **Accept.** `HARNESS-PROTOCOL.md`, `session-start.md`, `work-close.md` visible diff는 source-side additions against older framework text이며 product-specific target content는 관측되지 않았다. 다만 R2 한계상 apply 전에는 계속 candidate로 둔다. | Classification reason에 per-file visible diff 확인 문구 추가 |

Codex A gate proposal:

- **Temp rehearsal 보류.**
- 이 Work는 "manifest-target read-only probe + classification + blocker surfacing"으로 close 가능하다.
- 후속 apply Work를 열 경우, 첫 owner decision은 product DR low-band(`DR-030`~`DR-033`)을 high-band로 renumber할지, grandfather/defer할지다.
- real apply는 별도 Work에서 target feature branch, product DR renumber/index cascade, framework-update candidates, rename-cleanup candidates를 함께 다룬다.

### Round Log

| Round | Reviewer | Status | Scope | Summary |
| --- | --- | --- | --- | --- |
| R1 | Claude B | Request changes | Work file + plan red-team review | 방향 유효. F1 DR-034 per-condition 매핑(manifest target은 #1 미전진), F2 thin-evidence honest-close 분기, F3 `--check` status→classification 매핑 반영 요구. F4 cleanup, F5 affirm |
| R1-A | Codex A | Response recorded | Plan revision | F1-F4 accept/revise, F5 keep. B re-check 또는 owner 확인 대기 |
| R2 | Claude B | Conditional agree | R1 반영 re-check + script 대조 | F1-F4 반영 확인, F5 affirm. 신규 R2-1: `--check` source-updated가 동시 local edit을 구조적으로 가림(script L318-337 if/else, 주석 L321-323) → 매핑 default를 "framework-update candidate, 미확인 시 merge 강등"으로 수정 요구 |
| R2-A | Codex A | Response recorded | Final plan revision | R2-1 accept/revise. `source-updated`는 candidate로 낮추고 per-file diff 없이는 확정 금지. Consensus Agreed로 전환 |
| R3 | Owner + Claude B + Codex A | Baseline correction | Source baseline policy blind spot | 이번 Work는 develop/current checkout 기준으로 라벨링하고, released main/tag upgrade proof로 쓰지 않음. 이후 기본 기준은 main/tag로 분리 제안 |
| RR | Claude B | Approve with refinements | CP5 probe/classification result review | Blocker 독립 검증=실재(DR-042 vs target product DR-030~033). RR-1 install/gate-lists는 rename false-positive=re-render(과보존 정정), RR-2 blocker scope=product DR renumber(index 이미 존재, ai-deck보다 경량), RR-3 source-updated 3건 per-file 확인 미기록. 권고: temp rehearsal 보류, blocker 기록 후 close |
| RR-A | Codex A | Response recorded | CP5 revision + gate proposal | RR-1/RR-2/RR-3 accept/revise. Temp rehearsal 보류, blocker 기록 후 close 권고 |

### Consensus Log

| Topic | Status | Consensus |
| --- | --- | --- |
| Scope | Agreed | manifest-target read-only probe + conservative status-to-classification mapping까지 |
| Source baseline | Agreed | 이번 Work는 develop/current checkout based probe. 이후 adopter upgrade/apply evidence 기본 기준은 released main/tag로 분리 제안 |
| DR-034 evidence framing | Agreed | condition #1(pre-manifest shadow scaffold)은 미전진, #2/#3만 evidence 후보. Thin result면 약하게 close. `source-updated`도 clean separation 불가하고 develop 기준이므로 evidence 강도 bound |
| Temp rehearsal gate | Agreed | Classification 결과와 owner 승인 후 판단 |
| Real apply gate | Agreed | Temp rehearsal result review + owner final sign-off 이후 판단 |
| CP5 result | Agreed | Probe/classification completed. Blocker is real. Temp rehearsal should stay closed; close this Work after owner final approval and split apply/renumber to follow-up if desired |

## Checkpoints

| CP | Description | Status |
| --- | --- | --- |
| CP1 | Branch isolation + Work file/index setup | 완료 |
| CP2 | Claude B R1 review + Codex A response + consensus | 완료 |
| CP3 | Read-only target probe | 완료 |
| CP4 | Ownership classification draft | 완료 |
| CP5 | Result review + owner gate proposal | 완료 |

## Next Actions

- ✓ feature branch 생성: `feature/spring-adopter-upgrade-walkthrough`
- ✓ Work ID 확정: `CHORE-20260621-005`
- ✓ Work file + Active index 작성
- ✓ policy follow-up lightweight backlog candidate 등록: `Upgrade baseline source-ref policy and --check ref visibility`
- ✓ `docs/STATUS.md` Active Work pointer 추가
- ✓ Claude B R1 red-team review 기록
- ✓ Codex A R1 response + plan revision 기록
- ✓ Claude B R2 re-check 기록
- ✓ Codex A R2 response + final plan revision 기록
- ✓ R3 source baseline correction 기록
- ✓ read-only target probe 실행
- ✓ probe 결과 기반 ownership classification draft 작성
- ✓ Claude B result review 기록
- ✓ Codex A result response + classification refinement 기록
- → owner final approval: temp rehearsal 보류 + blocker 기록 후 close 여부 결정

## Discovery

- `/session-start` 결과 Active Work는 비어 있고, Next Actions의 P1은 `spring-modular-template` adopter upgrade walkthrough다.
- Done archive-pending Work는 `CHORE-20260621-002`, `CHORE-20260621-003`, `CHORE-20260621-004` 3건이다. 5개 미만이라 PLAN 누적 드리프트 soft warning 조건에는 걸리지 않는다.
- backlog row는 ID-less Candidate로 유지한다. 이 Work는 STATUS Next Actions 착수이며, W2 Adopter Transition 후보군과 DR-034/DR-042 후속 evidence boundary에 연결된다.
- Branch isolation check: `develop` + source-gitflow mode에서 feature branch가 필요해 `feature/spring-adopter-upgrade-walkthrough`를 생성했다. Work ID는 branch 생성 후 확정했으므로 branch rename은 하지 않고 Work file/STATUS가 ID SSoT를 맡는다.
- Claude B R1 diligence에서 `spring-modular-template`는 manifest target이고 manifest `harness_version: 1.3.0` == source `VERSION: 1.3.0`임이 확인됐다. 이 meta read는 probe deliverable이 아니라 plan correction input이다.
- R1 수정 후 이 Work는 DR-034 promotion evidence를 condition별로 분해한다. #1(pre-manifest shadow scaffold baseline)은 이 target에서 미전진, #2/#3만 후보로 본다.
- R2에서 `source-updated`가 adopter-side local edit을 구조적으로 가릴 수 있음이 확인됐다. 따라서 `source-updated`는 `framework-update` 확정값이 아니라 candidate로만 다루고, per-file diff로 edit 부재가 확인되지 않으면 `merge`로 강등한다.
- R3 baseline correction: `--check`는 source ref 개념이 없고 현재 checkout을 기준으로 계산한다. 이번 Work는 `feature/spring-adopter-upgrade-walkthrough` / `develop` HEAD `5a60d2d` 기준이며, `main`은 `39807ec`이다. `VERSION`은 모두 1.3.0이라 version 문자열 parity는 release-line parity 증거가 아니다.
- Future policy follow-up(별도 승인 필요): adopter upgrade/apply evidence의 기본 기준을 released `main` 또는 release tag로 정하고, develop 기준 probe는 명시 라벨을 필수화한다. 후보 산출물은 DR-034 amendment 또는 신규 DR, playbook probe checklist 보강, `--check` source-ref 출력 gap backlog 등록이다.
- Owner 승인 후 source-ref policy follow-up을 `docs/backlog/HARNESS.md`에 lightweight candidate로 등록했고, `docs/STATUS.md` Active Work pointer를 추가했다.
- Read-only probe result: manifest target, clean `develop`, `82 tracked / 75 in-sync / 7 drifted`. Drift = 4 `source-updated`, 3 `locally-modified`.
- Primary blocker: `docs/HARNESS-NAMING-RULES.md` source update carries DR-042 high-band product/adopter DR policy, while `spring-modular-template` already has product DRs `DR-030`~`DR-033`. This requires owner decision before temp rehearsal/real apply.
- Result review refinement: hook scripts' `base-spring-modular-template` comments are stale rename artifacts, not product logic. Candidate action is rename-cleanup re-render.
- Result review refinement: naming-rules blocker scope is downstream product DR renumber/index cascade. Target already has `docs/decisions/README.md`, so a future apply Work should be lighter than ai-deck CHORE-004 but still owner-gated.
- CP5 gate proposal: do not open temp rehearsal in this Work. Close after owner final approval, then split product DR renumber/apply to a follow-up Work if desired.
- 2026-06-21 closeout: owner final approval received. Work Done 처리. Temp rehearsal/real apply는 열지 않는다.
- Needs-Triage: `spring-modular-template` product DR namespace renumber/apply follow-up — CHORE-005 blocker(`DR-030`~`DR-033` product low-band vs DR-042 high-band policy)를 실제 target apply로 풀지, grandfather/defer할지 owner decision 필요.
