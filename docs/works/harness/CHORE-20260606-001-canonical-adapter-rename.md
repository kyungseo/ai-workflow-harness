---
id: CHORE-20260606-001
priority: P1
status: Done
risk: High
scope: Phase 2 slice #13 - DR-023 Canonical + hybrid adapter 적용과 no-alias command rename을 같은 breaking slice로 수행했다. Codex 구현, Claude R31 결과 검토, Work Done 처리가 완료되었고 commit/PR/merge는 별도 승인 후 진행한다.
appetite: 1w
planned_start: 2026-06-06
planned_end: 2026-06-13
actual_end: 2026-06-05
related_dr: [DR-007, DR-019, DR-021, DR-023]
related_troubleshooting: [docs/troubleshooting/agent-scope-approval-drift.md]
related_work: [CHORE-20260604-001]
---

# CHORE-20260606-001: Canonical Adapter + No-Alias Command Rename

## Top Summary

- **목표:** workflow 절차를 canonical SSoT 1벌로 모으고, `.claude/commands/` + `.agents/skills/` + `.cursor/rules/`는 hybrid adapter로 전환한다. 동시에 legacy runtime alias 없이 command 이름을 session/work/repo 대상이 드러나는 체계로 변경한다.
- **이번 턴 산출:** canonical `skills/workflow/` 신설, 3개 tool adapter 전환, no-alias rename, scaffold/manifest/test 반영, migration note 작성, Codex 자체 검증 PASS, Claude R31 결과 검토 PASS, Work Done 처리 완료.
- **Breaking 성격:** old command/skill 이름을 runtime surface에 남기지 않는다. old -> new mapping은 migration note에만 둔다.
- **순서 제약:** DR-023과 부모 Work §10-a에 따라 canonical+adapter 전환과 no-alias rename은 같은 breaking slice로 묶는다. Q4 `.harness/manifest.json` + `create-harness.sh --check` 최소 경로가 이미 충족되어 선행 제약은 해제됐다.
- **비목표:** user-facing manual 전면 재작성(slice #11), `--upgrade` 3-way merge, active target repo 직접 migration, commit/PR/merge 자동 진행.
- **상태 변경:** `docs/STATUS.md` Active Work pointer는 의도적으로 추가하지 않았으므로 제거할 pointer도 없다. Work 파일과 Work index만 Done으로 정리한다.

## Context Manifest

| 순서 | 파일 | 확인 내용 | 왜 |
| --- | --- | --- | --- |
| 1 | `docs/decisions/DR-023-canonical-hybrid-adapter.md` | canonical SSoT + hybrid adapter, adapter minimum hard-stop, Q4 `--check` 선행 조건 | 이 slice의 직접 적용 결정 |
| 2 | `docs/decisions/DR-019-codex-skill-naming-standard.md` | `.claude/commands/{name}.md` <-> `.agents/skills/workflow-{name}/SKILL.md` suffix mapping | rename 후에도 Codex skill naming 정합 유지 |
| 3 | `docs/works/harness/CHORE-20260604-001-harness-phase2-refactor-planning.md` | §5 canonical+adapter, §10-a rename 전파 순서, OQ-11/OQ-15/OQ-17 | 부모 planning SSoT |
| 4 | `.claude/commands/work.md`, `.agents/skills/workflow-work/SKILL.md`, `.claude/commands/close.md`, `.agents/skills/workflow-close/SKILL.md`, `.cursor/rules/workflow.mdc` | self-contained mirror 구조와 tool-specific 차이 | adapter 두께 설계 근거 |
| 5 | `scripts/create-harness.sh` | `adapt()`, `copy_prompt`, manifest rows, `--check`, command/skill/rule copy loop | scaffold와 manifest 반영 범위 |
| 6 | `docs/HARNESS-PROTOCOL.md` | Work File Decomposition, T11/T12/T14 cascade | canonical 도입 후 cascade 의미 변경 대상 |
| 7 | `docs/decisions/DR-007-language-policy.md` | docs/commands/skills/rules 언어 정책 | 신규 canonical `skills/workflow/*.md` 언어 기준 확인 필요 |
| 8 | `.claude/rules/docs-workflow.md`, `.claude/rules/git-workflow.md` | docs/rule/git workflow path-scoped guidance | 수정 대상 rule reference |
| 9 | `docs/retrospectives/harness-pre-public-review-codex-20260524.md` | 이전 `workflow-*` rename의 scaffold 검증과 fresh-session trigger 리스크 | rename 재발 리스크와 검증 기준 |
| 10 | `scripts/tests/check-scaffold-invariants.sh` | 1b invariant test, manifest + `--check` 자기일관성 | 회귀 검증 대상 |

## Defect And Scope Inventory

| ID | 항목 | 근거 | 이번 slice 처리 |
| --- | --- | --- | --- |
| D1 | workflow 절차가 command/skill/rule에 self-contained mirror로 반복된다 | 현재 11 command + 11 skill + Cursor workflow rule 합계 2559 lines. `/work` + `/close` 쌍만 command/skill/rule 합계 약 610 lines | canonical 추출 + adapter 전환 |
| D2 | T11이 tool surface 변경 시 수동 cascade를 요구하지만, canonical이 없어 drift 비용이 구조적으로 남는다 | `docs/HARNESS-PROTOCOL.md` T11/T12/T14 | T11 의미를 "adapter/canonical cascade"로 재정의 |
| D3 | command 이름이 대상 계층을 잘 드러내지 않는다 | `start`, `done`, `health`, `record-decision` 등 target/session/work/repo-state 구분이 약함 | no-alias rename mapping 제안(PQ-A) |
| D4 | scaffold가 현재 command/skill/rule 전체 mirror를 복사한다 | `scripts/create-harness.sh`가 `.claude/commands/*.md`, `.agents/skills/*/SKILL.md`, `.cursor/rules/*.mdc`를 동적/목록 복사 | canonical 1벌 + hybrid adapter 복사로 전환 |
| D5 | 이미 scaffold된 target migration은 source repo가 직접 수행할 수 없다 | 부모 OQ-17, DR-021 A/B boundary | source는 migration note + `--check` 안내만 제공 |
| D6 | root `skills/`가 신규 doc type이므로 DR-007 적용 경계가 명시돼야 한다 | DR-007은 `.agents/skills/*/SKILL.md`만 직접 언급 | plan에서 language policy 보강 여부 포함 |

## Plan

### Execution Classification

| 항목 | 판단 |
| --- | --- |
| Risk Level | L2+ breaking harness/workflow surface. Architecture/infra/DB 변경은 아니지만 reversal cost가 High라 L3-grade plan/review로 운영 |
| Execution Mode | Full Work |
| State Machine | INIT -> PLAN -> APPROVAL -> EXECUTE -> VALIDATE -> CHECKPOINT -> END. 현재는 PLAN/R22 review 전 단계 |
| Branch | `feature/chore-20260606-001-canonical-adapter-rename` |
| Approval | 구현 전 Claude R-round 합의 + 사용자 승인 필요. commit 전 별도 Approval Matrix 승인 필요 |
| Rollback Strategy | 한 PR 안에서 단계별 commit을 제안하되 partial merge 금지. canonical add, adapter/rename, scaffold/test 반영을 rollback 단위로 분리 검토 |

### PQ-A. New Command Name Mapping

이름 규칙 제안: `session-*`, `work-*`, `repo-*` 세 prefix로 command 대상 계층을 먼저 드러낸다. Claude command suffix와 Codex skill suffix는 계속 1:1로 맞춘다.

| Old command | New command | New Codex skill | Target | 근거 |
| --- | --- | --- | --- | --- |
| `start` | `session-start` | `workflow-session-start` | session | 세션 시작 시 STATUS current sections와 next candidate를 요약한다 |
| `done` | `session-summary` | `workflow-session-summary` | session | Work Done 처리가 아니라 세션 요약/handoff summary다. R23: `session-report`는 `/doc` 산출물과 의미 충돌 |
| `pick` | `work-select` | `workflow-work-select` | work | backlog 후보 비교와 다음 Work 추천이다 |
| `register` | `work-register` | `workflow-work-register` | work | 새 작업 항목을 backlog/STATUS 진입로에 등록한다 |
| `work` | `work-plan` | `workflow-work-plan` | work | 특정 Work 착수 전 pre-check와 plan을 만든다 |
| `resume` | `work-resume` | `workflow-work-resume` | work | Active Work drift 확인 후 이어서 계획한다 |
| `close` | `work-close` | `workflow-work-close` | work | Work Done state edit 전용이다 |
| `debug` | `work-debug` | `workflow-work-debug` | work | 지정 대상의 원인 좁히기와 최소 변경 계획을 Work 맥락에서 수행한다 |
| `doc` | `work-doc` | `workflow-work-doc` | work | 발표/보고/decision brief 산출물을 Work 맥락의 document artifact로 만든다. R23: 3분류 유지 + 기존 muscle memory 일부 보존 |
| `health` | `repo-health` | `workflow-repo-health` | repo | repository workflow/docs/scaffold 건강 상태 점검이다 |
| `record-decision` | `repo-decision` | `workflow-repo-decision` | repo | repository decision record를 생성/갱신한다. R23: `record` 동작은 command intent로 충분히 자명 |

User decision: 최빈 command가 길어지는 ergonomics 비용을 감수하고 **전체 일관 prefix(A)**로 진행한다. `start`/`work`/`close` 일부 단축을 유지하는 **부분 prefix(B)**는 채택하지 않는다.

### PQ-B. Canonical Location And Structure

제안: 루트 `skills/workflow/{new-command}.md`를 canonical SSoT로 둔다.

| 선택 | 판단 |
| --- | --- |
| 위치 | `skills/workflow/` |
| 구조 | command별 11개 canonical 파일 + `skills/workflow/README.md` index |
| 이유 | `ai-deck-compiler`에서 root `skills/` canonical 패턴이 이미 검증됐다. `.claude/`와 `.agents/`의 자동 인식 경로 안에 canonical을 두면 특정 도구에 소유권이 기울어진다 |
| Naming collision guard | `skills/workflow/`는 canonical SSoT이고 `.agents/skills/workflow-*`는 Codex adapter임을 `skills/workflow/README.md`와 각 adapter Step 0에 명시한다 |
| DR-007 처리 | root `skills/workflow/*.md`는 workflow skill document로 보고 Korean primary + Bilingual Rules 적용. DR-007 Consequences에 신규 경로 1줄을 추가한다 |
| Scaffold 분류 | DR-021 기준 A-owned framework file. default scaffold에 포함하고 manifest에서 추적한다 |

파일 1개 통합안은 `health`/`doc`/`close`처럼 절차 길이가 큰 command가 한 파일에 누적되어 context weight를 다시 키울 위험이 있다. command별 canonical 파일이 더 작고 adapter가 특정 파일을 명시적으로 로드하기 쉽다.

### PQ-C. Adapter Minimum Scope

adapter에 남길 내용은 DR-023 최소 범위로 제한한다.

| Adapter 자체 보유 | Canonical 위임 |
| --- | --- |
| Step 0: 해당 `skills/workflow/{new-command}.md`를 먼저 로드하라는 지시 | 세부 절차, 체크리스트, routing table |
| Hard-stop summary: branch isolation, Approval Matrix, validation-before-commit/PR | Approval Matrix 전문, T11/T12 cascade matrix 전문, validation 세부 명령 |
| Action blocking condition: canonical을 못 읽으면 mutating workflow는 FAIL/사용자 확인 | Work file format, status/index 세부 편집 순서 |
| Tool-specific entry mechanism | cross-agent review, troubleshooting, PLAN/DR 판단 상세 |
| Fallback: canonical missing/unreadable 시 read-only report만 허용하고 state-changing edit/commit/PR은 중단 | user-facing/manual 설명 |

Hard-stop summary 문장은 짧게 유지한다. adapter가 full checklist를 복제하면 DR-023의 "canonical SSoT 1벌"을 깨므로 금지한다.

Adapter fallback은 추상 원칙이 아니라 실행 가능한 문장으로 둔다. 예: "If `skills/workflow/{new-command}.md` is missing or unreadable, stop before editing files, changing state, committing, opening a PR, or merging; report the missing canonical file and ask the user how to proceed."

### PQ-D. Tool Adapter Differences

| Surface | Adapter 방식 | Thin하게 남길 tool-specific 내용 |
| --- | --- | --- |
| Claude Code | `.claude/commands/{new}.md` slash command. `disable-model-invocation` 유지 여부는 기존 command별로 보존 | argument-hint, slash 자동 호출, Step 0 canonical load, hard-stop summary |
| Codex | `.agents/skills/workflow-{new}/SKILL.md` + `AGENTS.md` skill routing | skill frontmatter, "Use this skill..." trigger, Step 0 canonical load, Codex는 command 파일을 실행하지 않는다는 fallback |
| Cursor | `.cursor/rules/workflow.mdc` 단일 rule | intent recognition table old 없이 new names만, canonical file pointer, Cursor는 slash command가 아니라 rule-based라는 설명 |

`.claude/rules/docs-workflow.md`, `AGENTS.md`, `CLAUDE.md`, prompts의 command-name 언급은 rename과 함께 cascade한다. `.claude/commands/*.md`와 `.agents/skills/workflow-*/SKILL.md`는 같은 suffix set을 유지한다.

### PQ-E. Migration Note And Cross-Repo Boundary

제안: source repo에 전용 migration note `docs/MIGRATION-CANONICAL-ADAPTER-RENAME.md`를 둔다.

| 항목 | 계획 |
| --- | --- |
| 내용 | old -> new command/skill mapping, no runtime alias 정책, `--check` 출력 해석, `--check`가 못 잡는 신규 command 목록, target 수용 절차 |
| 위치 | source repo 문서. default scaffold runtime 문서에는 복사하지 않는다 |
| README 반영 | 이번 slice에서는 과한 user-facing rewrite를 피하고, 필요 시 README에 한 줄 pointer만 검토한다. 전면 개편은 slice #11 |
| `--check` 안내 | old target manifest의 old adapter path가 `source-missing`으로 뜰 수 있음을 설명한다. old manifest에 없는 new path는 `source-added`로 자동 감지되지 않으므로 migration note가 신규 command/canonical paths를 명시적으로 열거한다 |
| OQ-17 경계 | source는 rename PR + canonical/adapters + `--check` + migration note를 제공한다. active target은 자기 repo의 별도 migration Work로 수용한다 |

주의: scaffold target에 복사되는 runtime 문서에는 target에 복사되지 않는 DR 번호를 새로 인용하지 않는다. provenance와 DR link는 source Work/DR/migration note에만 둔다.

### PQ-F. Scaffold And Manifest Reflection

| 대상 | 변경 계획 |
| --- | --- |
| Directory creation | `skills/workflow/` 생성 경로 추가 |
| Canonical copy | `skills/workflow/*.md`를 `adapt()`로 복사하여 manifest `framework_files`에 추적 |
| Claude commands | old filenames 삭제/rename, new adapter filenames만 복사 |
| Codex skills | `workflow-{new}` directories만 생성. DR-019 suffix mapping 유지 |
| Cursor rule | new command names와 canonical pointer로 갱신 |
| Manifest | new canonical + adapter paths를 framework file로 추적. old paths는 신규 scaffold manifest에서 사라진다 |
| `--check` | pre-rename target은 old paths가 `source-missing`으로 보고될 수 있다. old manifest에 없던 new canonical/adapter path는 자동 감지되지 않으므로 migration note가 source-added gap을 보완한다 |
| 1b invariant test | core files 목록에 `skills/workflow` 추가, command/skill mapping 검증을 new suffix로 갱신, default + `--with-optional` 양쪽 PASS |

검증은 `bash -n`/`sh -n`, fresh scaffold 양쪽 모드, `scripts/tests/check-scaffold-invariants.sh`, `create-harness.sh --check` 자기일관성, `git diff --check`를 포함한다.

### PQ-G. OQ-11 User-Facing Canonical Reference Boundary

제안: 이번 slice에서는 user-facing manual/guide의 canonical 참조를 0까지 줄이지 않는다. **중복 없는 단방향 위임 pointer**만 유지하고, 대규모 rewrite는 slice #11로 분리한다.

근거:

- command/skill/rule/scaffold rename만으로도 blast radius가 크다.
- manual/guide를 동시에 전면 재작성하면 canonical 적용 결함과 user-facing 문장 결함이 같은 diff에 섞인다.
- 부모 §10-b 합의가 user-facing 대대적 개편을 하류 별도 Work로 둔다.

이번 slice의 user-facing 변경은 stale command name 제거와 migration pointer 수준으로 제한한다.

### Proposed Implementation Stages

| Stage | 내용 | 검증 | Rollback |
| --- | --- | --- | --- |
| S1 | canonical `skills/workflow/{new}.md` 11개 + README 초안 작성 | link/name grep, DR-007 언어 확인 | canonical dir 삭제로 되돌림 가능 |
| S2 | `.claude/commands/`, `.agents/skills/`, `.cursor/rules/`를 hybrid adapter로 전환하면서 no-alias rename 적용 | suffix mapping check, old command path 없음 확인 | S2는 breaking. S1과 함께 되돌리는 것이 안전 |
| S3 | `AGENTS.md`/`CLAUDE.md`/rules/prompts/protocol quick refs의 command name cascade | stale old-name grep | 문서 cascade commit revert |
| S4 | `scripts/create-harness.sh` + manifest/test 반영 | `bash -n`, `sh -n`, scaffold invariant 양쪽 모드, `--check` | scaffold commit revert |
| S5 | migration note 작성, final validation, Claude result review | `git diff --check`, generated target stale search | note/doc revert |

Commit boundary 제안: S1, S2+S3, S4+S5를 분리 commit 후보로 둔다. S2와 S3는 stage는 분리해 검토하되 commit은 하나로 묶어 중간 stale-grep/1b FAIL 상태를 commit하지 않는다. PR은 한 번에 merge하고 partial merge는 금지한다.

## Done Criteria

- [x] Claude R22+ plan review에서 PQ-A~G와 stage/rollback 단위가 합의된다.
- [x] canonical `skills/workflow/` 구조가 신설되고 command별 canonical 절차가 1벌로 정리된다.
- [x] 11개 Claude command와 11개 Codex skill이 new suffix로 rename되고 old runtime alias/path가 남지 않는다.
- [x] `.cursor/rules/workflow.mdc`, `AGENTS.md`, `CLAUDE.md`, relevant rules/prompts/protocol/quick-reference가 new command names와 canonical pointer로 정렬된다.
- [x] adapter는 Step 0 + hard-stop summary/action blocking + entry mechanism + fallback만 보유하고 상세 checklist/cascade matrix는 canonical에 위임한다.
- [x] `scripts/create-harness.sh`가 canonical 1벌 + hybrid adapter만 scaffold하고 manifest `framework_files`가 new paths를 추적한다.
- [x] migration note가 old -> new mapping과 active target 책임 경계를 설명한다. runtime alias는 생성하지 않는다.
- [x] migration note가 `--check`의 `source-missing` 신호와 `source-added` 미감지 한계를 함께 설명하고, 신규 canonical/adapter path를 명시적으로 열거한다.
- [x] migration note가 rename 직후 기존 AI session command/skill cache가 stale할 수 있으며 fresh session 또는 reload로 검증해야 함을 설명한다.
- [x] scaffold runtime 문서에 target 미복사 DR 번호를 새로 인용하지 않는다.
- [x] 1b invariant test 양쪽 모드, `--check` 자기일관성, shell syntax, stale old-name grep, `git diff --check`가 PASS한다.
- [x] Claude 결과 검토 완료 후 `/work-close`로 Work Done 처리한다. commit 승인, PR `--base develop`, merge는 별도 Approval Matrix 단계로 진행한다.

## Verification

Plan 검증:

- `git branch --show-current`
- `git status --short --branch`
- Claude R22+ review response 반영 여부 확인

Implementation 검증:

- `bash -n scripts/create-harness.sh`
- `sh -n scripts/create-harness.sh`
- `bash -n scripts/tests/check-scaffold-invariants.sh`
- `scripts/tests/check-scaffold-invariants.sh`
- fresh default scaffold 생성 후 `scripts/create-harness.sh --check <target>` summary `0 drifted`
- fresh `--with-optional` scaffold 생성 후 `scripts/create-harness.sh --check <target>` summary `0 drifted`
- old-name stale grep: runtime alias/path가 남지 않았는지 확인. migration note의 old -> new mapping은 예외
- command/skill suffix mapping: `.claude/commands/{new}.md` <-> `.agents/skills/workflow-{new}/SKILL.md`
- generated target no dangling DR reference / no source-only leakage
- `git diff --check`

Actual verification snapshot:

- PASS: `bash -n scripts/create-harness.sh`
- PASS: `sh -n scripts/create-harness.sh`
- PASS: `bash -n scripts/tests/check-scaffold-invariants.sh`
- PASS: `scripts/tests/check-scaffold-invariants.sh` default minimal + `--with-optional`
- PASS: `git diff --check`
- PASS: old-name stale grep. Old slash/skill names remain only in `docs/MIGRATION-CANONICAL-ADAPTER-RENAME.md` mapping/policy note.
- PASS: corruption grep for `docs/work-plans`, `work-planflow`, `archive/work-docs`, and accidental `work-plan-*` tokens.
- PASS: grammar grep for `session-summary으로`, `session-summary은`, `work-plan로`.
- PASS: targeted no-diff check for `docs/STATUS.md`, `docs/backlog/HARNESS.md`, DR-019, and DR-023.
- NOTE: fresh AI session discovery는 현재 열린 Codex/Claude session에서 검증하지 않는다. migration note에 stale command/skill cache 가능성과 fresh session/reload 검증 요구를 명시했다.

## Checkpoints

| CP | 내용 | 상태 |
| --- | --- | --- |
| CP0 | Branch isolation check, required docs read, Work 파일 + R22 plan 초안 작성 | Done |
| CP1 | Claude R22/R23 plan review + R24 반영 + user ergonomics decision(A) | Done |
| CP2 | S1 canonical extraction 구현 | Done |
| CP3 | S2 adapter 전환 + no-alias rename 구현 | Done |
| CP4 | S3 cascade 문서/rule/prompt/protocol 정렬 | Done |
| CP5 | S4 scaffold/manifest/test 반영 | Done |
| CP6 | S5 migration note + final validation | Done |
| CP7 | Claude result review -> `/work-close` 완료. commit approval -> PR `--base develop` -> merge는 별도 승인 후 진행 | Done |

## Cross-Agent Review

이 섹션은 Claude와 Codex의 review round를 누적하는 SSoT다.
직전 slice가 R21에서 종료했으므로 이번 slice는 R22부터 시작한다.

### Round Log

| Round | 주체 | 요지 | 반영 |
| --- | --- | --- | --- |
| R22 | Codex | Plan 초안. `session-*`/`work-*`/`repo-*` rename taxonomy, root `skills/workflow/` canonical, adapter minimum scope, migration note, scaffold/manifest 반영, OQ-11 단방향 pointer 유지 제안 | 본 문서 |
| R23 | Claude | 검토: PQ-C/D/E/G·bundling·staging 동의. PQ-A 이름 3건 조정 요청, PQ-B canonical/adapter naming 충돌 경고, PQ-F `--check` source-added 미감지 gap, 5개 minor | R23 review 블록 |
| R24 | Codex | R23 반영: `session-summary`/`work-doc`/`repo-decision` 수용, canonical-vs-adapter naming guard 추가, migration note source-added gap 추가, adapter fallback 문장화, S2+S3 single commit 명료화. `status: Active`는 DR-013 스펙상 유지 | R24 response + Plan 반영 |
| R25 | User | Rename ergonomics 결정: no-alias 목적과 target-reveal 효과를 확인한 뒤 A(전체 일관 prefix)를 채택 | PQ-A 확정 |
| R26 | Codex | 구현 완료: canonical 11개+index, Claude/Codex/Cursor hybrid adapters, no-alias rename, scaffold/manifest/test, migration note 반영. 자체 검증 PASS | Claude 결과 검토 요청 대상 |
| R27 | User/Codex | 기존 AI session이 rename 전 command/skill inventory를 cache할 수 있다는 운영 리스크 확인. migration note에 fresh session/reload 검증과 기존 session의 direct path load fallback을 추가 | migration note + Verification 반영 |
| R28 | Codex | Self-review: shared canonical에 남은 Codex-specific rule reference와 `repo-health` entrypoint 표현을 tool-neutral로 수정. user-facing rename cascade의 `workflow(start/...)`, `work-plan spec` 오염도 수정. 검증 재실행 PASS | Claude 결과 검토 전 자체 수정 |
| R29 | User/Codex | `ai-deck-compiler` target migration 사전 리스크 확인: product-specific `create-deck` 계열 command/skill/custom routing이 이미 존재하므로 scaffold overwrite 금지, workflow-only selective migration 필요 | migration note Customized Target Note + Discovery 반영 |
| R30 | User/Codex | 사용자 리뷰: manifest 없는 target은 inventory 먼저 작성하라는 migration note가 `--check` 출력에도 반영되어야 함. `scripts/create-harness.sh --check`의 no-manifest/invalid-manifest 안내에 inventory 선행 문구 추가 | script behavior + migration note 정합화 |
| R31 | Claude | 구현 결과 검토 + 직접 재검증. 7대 기준 전부 PASS, P0/P1 결함 없음. canonical/adapter/no-alias/scaffold/manifest/1b/migration note 합의. CP7(`/work-close` -> commit approval -> PR `--base develop`) 진행 권장. P2 2건은 비차단 | R31 review 블록 |

### R22 Codex Plan Draft

Claude 검토 요청:

1. **PQ-A:** old -> new mapping이 command 대상 계층을 충분히 드러내는가? 특히 `work-document`, `repo-record-decision` 이름을 유지할지 조정할지 검토해 달라.
2. **PQ-B:** root `skills/workflow/{new}.md` 11개 + index 구조가 적절한가? 통합 파일 또는 docs 하위 canonical보다 나은지 반박해 달라.
3. **PQ-C:** adapter minimum scope가 너무 두껍거나 얇지 않은가? hard-stop summary/action blocking과 canonical 위임의 경계를 확인해 달라.
4. **PQ-D:** Claude/Codex/Cursor adapter 차이가 각 도구 entry mechanism을 충분히 반영하는가?
5. **PQ-E:** migration note 위치를 source-only `docs/MIGRATION-CANONICAL-ADAPTER-RENAME.md`로 두는 것이 OQ-17 cross-repo boundary에 맞는가?
6. **PQ-F:** scaffold/manifest/test 반영 계획이 Q4 `--check`와 1b invariant를 충분히 보호하는가?
7. **PQ-G:** user-facing canonical reference는 이번 slice에서 단방향 pointer만 유지하고 전면 rewrite를 slice #11로 미루는 것이 맞는가?
8. **Rollback/commit boundary:** S1, S2+S3, S4+S5 분리가 리뷰와 rollback에 적절한가?

### R23 Claude Plan Review

**결론:** plan 방향 견고. PQ-C/D/E/G·bundling(canonical+adapter+rename 한 slice)·staging(S1/S2+S3/S4+S5) 동의. 아래 3개 쟁점 조정 + 5개 minor 반영 후 구현 착수 권장.

**쟁점 1 — PQ-A 이름 조정 (3건):**
- `done`→`session-report`: `/doc`(report·brief 산출물)과 의미 충돌. `/done`은 산출물이 아니라 세션 마감 요약 → **`session-summary` 또는 `session-end`** 권장.
- `record-decision`→`repo-record-decision`(skill: `workflow-repo-record-decision`): 과도하게 김. **`repo-decision`** 권장(record는 동작 자명).
- `doc`→`work-document`: 가장 약한 매핑(artifact가 Work 종속 아닐 수 있음, Codex도 인지). 4번째 prefix는 taxonomy 흐림 → **`work-doc`**(짧고 기존 muscle memory 보존) 권장. 단, 3분류 유지가 우선이면 `work-document` 수용 가능.
- 추가 tradeoff 제기(사용자 판단 필요): 최빈 command(`start`/`work`/`close`/`done`)가 길어지는 ergonomics 비용. no-alias·target-reveal 목표상 일관 prefix가 맞으나, 입력 빈도 비용을 사용자에게 1줄로 확인할 것.

**쟁점 2 — PQ-B canonical/adapter naming 충돌:** root `skills/workflow/`와 기존 `.agents/skills/workflow-*`(Codex adapter)가 **둘 다 "skills/workflow"** → 혼동 위험 큼. canonical(SSoT)과 adapter(mirror)가 한눈에 구분되게 할 것. 옵션: ① canonical을 `skills/workflow/`로 두되 README·adapter Step 0에서 "canonical SSoT vs `.agents/skills` adapter" 구분을 명시, ② canonical 경로를 더 또렷한 이름으로(예 `skills/`만, 또는 `workflow/`). per-command 파일+index 구조 자체는 동의. DR-007 경계는 **DR-007 Consequences에 신규 경로 1줄 추가**(SSoT 유지)가 canonical README에만 적는 것보다 낫다.

**쟁점 3 — PQ-F `--check` 한계 명시:** `--check`는 manifest에 기록된 파일의 `source-missing`(rename/삭제)만 감지하고 **source-added(신규 command 추가)는 감지 못 함**(old target manifest엔 new path가 없음). 따라서 migration note는 "사라진 old → 대응 new" 매핑뿐 아니라 **신규 추가된 command 목록도 명시적으로 열거**해야 함(--check가 못 알려줌). PQ-E/PQ-F에 이 요구를 박을 것.

**Minor (5):**
1. frontmatter `status: Active` → 기존 Work 관례는 `Planning`/`In Progress`/`Done`. 표준 어휘로 정렬(`In Progress` 등).
2. `related_dr`에 DR-024 포함했으나 이 slice는 DR-024 적용 아님(adapter hard-stop은 DR-023). 관련은 약하니 빼거나 "참고"로 표기.
3. S2+S3를 한 commit으로(권장) — rename과 doc cascade가 갈리면 그 중간 commit이 stale-grep/1b FAIL. 한 commit이면 validation 일관. plan의 "S2+S3 분리 commit"보다 **S2+S3 단일 commit** 권장.
4. adapter fallback("canonical 없으면 read-only, state-change 차단")은 원칙 동의 — 단 adapter 본문에 **실행 가능한 문장**으로 박을 것(추상 원칙만으론 자연어 로드 실패 시 무력).
5. 과거 함정 재확인: copied runtime(command/skill/rule/protocol)에 target 미복사 DR 번호 인용 금지(slice 4·9 1b FAIL 재발). Done Criteria에 이미 있음 — 유지.

**검토 안 한 것/위임:** 구체 canonical 파일 내용·adapter 문안은 구현(S1/S2) 후 결과 검토에서 본다. 이름 최종 확정은 사용자 1건(ergonomics) 확인 후.

### R24 Codex Response To R23

**수용:**
- PQ-A 이름 3건 조정 수용: `done` -> `session-summary`, `doc` -> `work-doc`, `record-decision` -> `repo-decision`.
- PQ-B naming collision guard 수용: `skills/workflow/`는 canonical SSoT, `.agents/skills/workflow-*`는 Codex adapter임을 canonical README와 adapter Step 0에 명시한다. DR-007 Consequences에 `skills/workflow/*.md` 언어 정책 1줄 추가.
- PQ-F `source-added` gap 수용: `--check`는 old manifest에 없는 new path를 자동 감지하지 못하므로 migration note가 신규 command/canonical/adapter paths를 명시적으로 열거한다.
- Minor 3/4/5 수용: S2+S3는 single commit 후보로 명료화, adapter fallback은 실행 가능한 차단 문장으로 작성, target 미복사 DR 인용 금지 유지.
- Minor 2 수용: frontmatter `related_dr`에서 DR-024 제거. DR-024는 배경 참고일 수 있으나 이번 slice 직접 적용 DR은 DR-023이다.

**반박/유지:**
- Minor 1의 `status: Active` 변경 제안은 반영하지 않는다. DR-013 Work file spec의 status lifecycle은 `Active -> Done -> Archived`이고, 최근 Work 파일들도 `Active`로 생성 후 `Done` 처리한다. 따라서 현재 frontmatter는 repo 표준과 일치한다.

**사용자 결정 완료:**
- Rename ergonomics: **A. 전체 일관 prefix**로 확정. 최빈 command 입력 길이는 늘지만, 이번 slice의 no-alias/target-reveal 목적과 가장 잘 맞고 command taxonomy가 오래 간다는 판단이다.

### R31 Claude Implementation Review

**결론:** 구현 승인. DR-023 canonical+hybrid adapter + no-alias rename이 7대 검토 기준을 모두 충족하고, Codex가 R26에서 주장한 검증 결과를 fresh scaffold 2모드까지 직접 재현해 PASS를 확인했다. **P0/P1 결함 없음.** P2 2건은 commit을 막지 않는 비차단 항목이다. 다음 단계 `/work-close` -> commit approval -> PR `--base develop` 진행에 동의한다.

**7대 기준 판정:**

| # | 기준 | 판정 | 근거 |
| --- | --- | --- | --- |
| 1 | canonical 완전성 + adapter thinness | PASS | canonical 11개(+README) 1350 lines로 절차 SSoT 1벌. Claude/Codex adapter 각 ~22 lines, Cursor rule도 thin. adapter는 Step 0 + Hard Stops + Entry Mechanism만 보유. Approval Matrix는 "확인한다" 참조일 뿐 전문 복제 없음, "상세 checklist/cascade matrix 복제하지 않는다" 명시 |
| 2 | canonical↔adapter 구분 실효성 | PASS | `skills/workflow/README.md` Boundary 표가 4 surface 역할을 구분하고 "`.agents/skills/workflow-*`와 비슷하지만 역할 다름"을 명시. 각 canonical 파일 상단 Tool/Adapter 표 + 각 adapter Step 0가 canonical을 SSoT로 가리킴 |
| 3 | fallback 실행 가능성 | PASS | adapter 본문에 실행 문장으로 박힘: "missing/unreadable면 파일 수정·상태 변경·commit·PR·merge 전 중단, 누락 canonical 보고, 사용자 확인". 추상 원칙 아님 |
| 4 | no-alias 완전성 | PASS | runtime surface(commands/skills/cursor/AGENTS/CLAUDE/prompts/protocol/quick-ref/rules) bare old slash-call grep = 0, true old token = 0. old 이름은 source-only DR-015/019/024 + retrospective(immutable 역사 기록, runtime surface 아님)와 migration note에만 잔존 |
| 5 | DR 인용 함정(slice 4·9 재발) | PASS | 복사 runtime surface(canonical/adapter/rule/prompt/protocol/quick-ref)에 DR-019/021/022/023/024 인용 0. fresh scaffold target 전수 grep도 0. target에는 curated DR(007/008/013/014)만 복사되고 old 이름/source-only DR 없음 |
| 6 | scaffold/manifest/1b 회귀 | PASS | copy loop이 glob(`*.md`,`*/`) 기반이라 new 이름 자동 반영, hardcoded old 이름 없음. manifest가 `skills/workflow/` + 신규 adapter 추적. `--check` default+optional 68 tracked / 0 drifted. 1b OVERALL PASS(both modes) |
| 7 | migration note | PASS | old->new 11행 매핑 + 신규 canonical 12개 **명시 열거**(source-added gap 보완) + source-only 경계 + AI session cache note + Customized Target Note(R29) + no-manifest inventory 선행(R30) |

**직접 재검증(Codex 통과 주장 재현):**

- PASS `bash -n` / `sh -n scripts/create-harness.sh`
- PASS `bash -n scripts/tests/check-scaffold-invariants.sh`
- PASS `scripts/tests/check-scaffold-invariants.sh` OVERALL (default minimal + `--with-optional`)
- PASS fresh scaffold 2모드 생성 후 `--check`: 68 tracked, 68 in-sync, **0 drifted** (자기일관성)
- PASS `git diff --check` (whitespace 0)
- PASS old-name stale grep: runtime surface 0, 잔존은 migration note + source-only DR/retrospective 역사 기록뿐
- PASS DR 인용 함정: target 전수 grep에서 DR-015/019/021/022/023/024 누수 0
- NOTE fresh AI session command/skill discovery는 현재 열린 session에서 재현 불가. migration note가 stale cache + fresh session/reload 검증 요구를 명시함(R27)

**R28 tool-neutrality 재확인:** canonical의 tool-specific 매칭은 각 파일 상단 adapter 매핑 표와 `repo-health.md`의 전 surface 감사 명령(`ls .agents/skills`, `ls .cursor/rules`, `ls .codex`)뿐으로, 단일 도구 전제 편향 없음. R28 수정이 반영됨.

**Findings (P0/P1/P2):**

- **P0:** 없음.
- **P1:** 없음.
- **P2-a (비차단, 권장 무변경):** source-only 역사 DR가 old 경로를 현재형으로 참조한다 — `DR-015`가 `.claude/commands/work.md`·`done.md`·`resume.md`를, `DR-024`가 `.claude/commands/start.md:11-13`을 인용. 이들은 immutable 결정 기록이고 target에 복사되지 않으며 runtime surface도 아니므로 **수정하지 않는 것을 권장**(Done/DR immutability 우선). 추적 목적의 참고 사항으로만 남긴다.
- **P2-b (commit 단계 process):** 이 Work의 STATUS Active pointer가 아직 미추가다(Work 파일 §Top Summary 주의에 따라 의도적 보류). CP7 흐름이 review -> `/work-close`로 이어지면 `/work-close`가 pointer를 추가하지 않고 종료 처리하므로 STATUS `Active Work`는 빈 상태가 정상 종착이다. commit 단계에서 STATUS Finalization 판단 시 이 점을 확인할 것.

**위임/미검토:** commit message 문안, PR 본문, merge 실행은 사용자 승인 후 별도 단계. 이 라운드는 결과 검토와 findings까지다.

### Consensus Log

| Date | Round | 합의 | 남은 리스크 |
| --- | --- | --- | --- |
| 2026-06-06 | R22 | Pending Claude review | command taxonomy와 adapter 두께가 가장 큰 결정점 |
| 2026-06-06 | R23 | Claude 검토 완료: 방향·PQ-C/D/E/G·bundling·staging 동의. PQ-A 이름 3건 조정·PQ-B naming 충돌·PQ-F `--check` source-added gap·5 minor 반영 요청. 이름 ergonomics는 사용자 확인 1건 | rename 이름 최종 확정(사용자), canonical/adapter naming 구분 명료화 |
| 2026-06-06 | R24 | Codex가 R23 대부분 수용. `status: Active`는 DR-013과 충돌하므로 유지. `session-summary`/`work-doc`/`repo-decision`, naming guard, source-added gap, executable fallback, S2+S3 single commit 반영 | 사용자 ergonomics 선택 A/B |
| 2026-06-06 | R25 | 사용자 결정: A(전체 일관 prefix) 채택. no-alias는 old command runtime alias를 남기지 않고 migration note에만 old -> new mapping을 둔다 | 구현 착수 전 사용자 scope approval |
| 2026-06-06 | R26 | Codex 구현과 자체 검증 완료. old alias는 migration note에만 남고 scaffold invariant/default+optional 및 `--check` 자기일관성이 PASS했다 | Claude 결과 검토, `/work-close`, commit approval |
| 2026-06-06 | R27 | 사용자 질문으로 AI session stale cache 리스크를 확인. Codex가 migration note에 fresh session/reload 검증 요구를 추가했다 | Claude 결과 검토 시 운영 note 확인 |
| 2026-06-06 | R28 | Codex self-review에서 canonical tool-neutrality와 user-facing rename cascade 오염 2건을 발견해 수정했다. 정적 검증과 scaffold invariant를 재실행했다 | Claude 결과 검토 |
| 2026-06-06 | R29 | 사용자 제안으로 `ai-deck-compiler` migration 사전조사 내용을 기록했다. target-local product skill과 workflow framework migration은 분리해야 한다 | Claude 결과 검토 |
| 2026-06-06 | R30 | 사용자 리뷰로 migration note와 `--check` output gap을 발견. no manifest / invalid manifest target에 inventory 선행 안내를 출력하도록 수정했다 | Claude 결과 검토 |
| 2026-06-06 | R31 | Claude 구현 결과 검토 완료: 7대 기준 PASS, fresh scaffold 2모드 `--check` 0 drifted까지 직접 재현. P0/P1 없음, P2 2건 비차단. CP7(`/work-close` -> commit approval -> PR `--base develop`) 진행 합의 | commit/PR/merge는 사용자 승인 후 |

## Discovery

- Branch Isolation Check: `develop` + source-gitflow mode에서 protected workflow edit 금지 확인 후 `feature/chore-20260606-001-canonical-adapter-rename` branch로 전환했다.
- STATUS current sections: Active Work 없음. Next Actions가 slice #13 착수를 명시하고 Q4 전제조건 충족을 확인한다.
- Work index: 착수 전 Active 없음이었고, 이 Work 생성과 함께 Active row를 추가했다. Done archive pending이 다수 있지만 이번 `/work` 착수에는 blocking conflict가 아니다.
- Existing surface inventory: 11 Claude commands, 11 Codex skills, 1 Cursor workflow rule. line count 합계 2559 lines라 mirror 부피가 실측된다.
- `/work` + `/close` 정독 결과: command와 skill이 거의 같은 절차를 반복하고 Cursor rule이 공통 흐름을 별도 요약한다. canonical 부재로 T11 수동 cascade 비용이 남는다는 DR-023 진단과 일치한다.
- Retrospective risk: 이전 HRN-028/029 rename에서도 fresh Codex session trigger와 scaffold stale search가 리스크였다. 이번 no-alias rename은 더 큰 breaking이므로 generated target grep과 command/skill mapping 검증을 Done Criteria에 포함했다.
- Troubleshooting reference: `agent-scope-approval-drift.md`가 scope expansion과 workflow surface 변경 승인 drift를 지적한다. 이 slice는 구현 전 plan approval, scope expansion 보고, commit 전 별도 approval을 hard requirement로 둔다.
- Date note: user-provided Work ID와 branch가 `CHORE-20260606-001`/`feature/chore-20260606-001-canonical-adapter-rename`이므로 파일과 frontmatter도 2026-06-06 기준으로 맞췄다.
- Implementation note: canonical은 `skills/workflow/{new-command}.md` 11개 + `README.md`로 생성했고, `.claude/commands/{new}.md`, `.agents/skills/workflow-{new}/SKILL.md`, `.cursor/rules/workflow.mdc`는 Step 0 canonical load + hard-stop summary + tool entry/fallback 중심의 hybrid adapter로 축소했다.
- No-alias note: old runtime command/skill paths는 삭제했고, old -> new mapping은 source-only `docs/MIGRATION-CANONICAL-ADAPTER-RENAME.md`에만 남겼다.
- Scaffold note: `scripts/create-harness.sh`는 `skills/workflow/*.md`를 `adapt()`로 복사하고 manifest `framework_files`에 추적한다. 1b invariant test는 core file 목록에 canonical directory를 포함하도록 갱신했다.
- Safety note: broad mechanical rename 중 `docs/works` -> `docs/work-plans`, `harness/workflow` -> `harness/work-planflow` 같은 토큰 오염 가능성을 발견해 되돌리고, 후속 grep으로 관련 패턴이 남지 않음을 확인했다.
- Sandbox note: `.agents/`와 `.codex/` 일부 write는 sandbox 제한으로 실패해 승인된 escalation 또는 `apply_patch`로 처리했다.
- Validation note: `scripts/tests/check-scaffold-invariants.sh`가 default minimal과 `--with-optional` 양쪽에서 PASS했고, `docs/STATUS.md`/backlog/DR-019/DR-023에는 의도치 않은 diff가 없다.
- Session cache note: 현재 열린 Codex/Claude session은 rename 전 command/skill inventory를 계속 들고 있을 수 있다. 새 command/skill discovery 검증은 fresh AI session 또는 workspace reload 기준으로 수행해야 한다.
- Self-review note: canonical `work-plan.md`의 Codex-only rule reference와 `repo-health.md`의 AGENTS-only entrypoint 표현을 tool-neutral로 바꿨다. `docs/WORKFLOW-MANUAL.md`의 `workflow(start/...)`와 `work-plan spec` 잘못된 rename도 수정했다.
- Target migration preflight note: `ai-deck-compiler`에는 product-specific `create-deck`, `review-deck`, `export-pdf`, `generate-architecture-slide` command/skill과 `AGENTS.md` product skill routing이 이미 있다. 따라서 후속 target migration은 `.claude/commands/` 또는 `.agents/skills/` 전체 overwrite가 아니라 old workflow surface만 교체하는 selective migration이어야 한다. root `skills/workflow/*.md` canonical은 기존 `skills/create-deck.md` 같은 product canonical과 병존 가능하다.
- Check behavior note: `scripts/create-harness.sh --check`는 manifest 없는 target과 invalid/old manifest target에서 command/skill/rule inventory를 먼저 작성하라는 안내를 출력한다. `--check` 결과만으로 customized target migration 범위를 판단하지 않게 하기 위함이다.
- Closeout note: R31 Claude result review 승인 후 Work Done 처리했다. STATUS Active pointer는 이 Work 착수 때 추가하지 않았으므로 `docs/STATUS.md` 변경 없이 Work file과 Work index만 정리한다. `actual_end`는 현재 실행 환경 날짜 `2026-06-05` 기준으로 기록했다.
