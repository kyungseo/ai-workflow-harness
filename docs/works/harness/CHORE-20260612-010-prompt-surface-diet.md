---
id: CHORE-20260612-010
priority: P1
status: Done
risk: L2
scope: Prompt surface diet + optional pack redefinition planning. R0에서는 inventory/decision grid/implementation boundary만 확정하고, prompts 이동·삭제·scaffold rewiring은 수행하지 않는다.
appetite: 0.5d
planned_start: 2026-06-12
planned_end: 2026-06-12
actual_end: 2026-06-12
related_dr: [DR-014, DR-021, DR-023]
related_work: [CHORE-20260612-007, CHORE-20260612-008, CHORE-20260612-009]
---

# CHORE-20260612-010: Prompt Surface Diet + Optional Pack 재정의

## Top Summary

- **목표:** `prompts/` task prompt surface와 `--with-optional` pack의 현재 의미를 inventory-first로 감사하고, live core / optional example pack / archive 보존 / 유지 중 어느 방향이 맞는지 결정 grid를 만든다.
- **왜 지금:** CHORE-20260612-007/008/009가 `docs/AGENT-WORKFLOW.md`의 canonical 계층화를 작은 slice로 정리했다. 다음 병목은 canonical workflow 이후에도 남아 있는 task prompt library와 optional pack 의미의 중복·cascade 비용이다.
- **핵심 경계:** R0 review 전에는 구현하지 않는다. 이번 plan은 "무엇을 옮길지"가 아니라 "무엇을 어떤 기준으로 판정할지"를 review-ready로 만든다.
- **역할:** Codex = author/driver, Claude = red team reviewer.

## Candidate Comparison

1. **Prompt surface diet + optional pack 재정의**가 가장 직접적이다. P1이고 W3의 "canonical weight 경량화"에 바로 연결된다.
2. 직전 007/008/009 흐름은 `AGENT-WORKFLOW.md` 내부 라우팅을 줄였고, 이 후보는 남은 prompt surface의 core 여부를 묻는다.
3. tracking hygiene가 아니라 실제 W3 구조 정리에 기여한다. archive pending 정리와도 분리 가능하다.
4. 위험은 있다. `docs/` 물리 레이아웃, scaffold wiring, README/MANUAL cascade로 번질 수 있다.
5. 그래서 이번 slice는 inventory + decision grid + no-implementation boundary로 자르면 작게 닫을 수 있다.
6. `trigger family simplification`은 아직 broad rewrite 위험이 크고, `repo-health`/`work-doc` slice는 prompt/optional pack 방향 결정 뒤가 더 자연스럽다.

## Background / Facts

Backlog 기준 W3 후보:

| Candidate | Priority | Risk | Fit |
| --- | --- | --- | --- |
| Canonical 개념 계층화 잔여 slice | P1 | L3 가능 | 007/008/009로 일부 진행. 지금 바로 상위 restructure를 다시 열면 broad rewrite 위험이 높음 |
| Prompt surface diet + optional pack 재정의 | P1 | L2 | canonical 이후 남은 prompt/example pack 경계를 정리. 작은 decision slice로 분해 가능 |
| Harness protocol trigger family simplification | P2 | L2 | trigger regrouping은 canonical restructure의 하위. 지금 열면 HARNESS-PROTOCOL 대형 재작성 위험 |
| `skills/workflow/repo-health.md` slice 분리 | P2 | L2 | W1 F4와 연결. 다만 Q-static / runner / repo-health 경계를 다시 건드릴 수 있음 |
| `skills/workflow/work-doc.md` class 재검토 | P2 | L2 | Prompt surface diet 방향과 강하게 연결. 후속으로 두는 편이 더 작음 |

Relevant source facts:

- `docs/backlog/HARNESS.md`는 이 후보를 W3/P1로 두고, `prompts/*session-start.md` 3종 + `prompts/README.md`를 제외한 task prompt `00~22`의 live surface 유지 여부를 결정하라고 한다.
- 같은 backlog 항목은 `--with-optional`의 남은 의미와 `docs/` 물리 레이아웃 재검토 가능성을 함께 언급한다.
- DR-021은 source/target boundary와 optional source pack 경계를 다룬다. 2026-06-10 note는 물리 이동 보류를 유지하되, hardcoded flat-path 참조 비용을 manifest/anchor indirection과 함께 재검토할 수 있다고 남겼다.
- DR-014는 archive path 보존 정책을 가진다. prompt를 live surface에서 제거하더라도 이력 보존 방식은 삭제보다 archive/pack 격리가 우선이다.
- DR-023은 canonical workflow + thin adapter 모델이다. task prompt library가 canonical workflow와 같은 core인지 다시 판정해야 한다.

## Scope / Non-Goals

### Scope

1. `prompts/` inventory:
   - session-start fallback 3종
   - `prompts/README.md`
   - task prompt `00~22` 및 stack/profile prompt
2. current reference map:
   - `rg "prompts/"` 기반 source reference
   - scaffold copy/adapt 경로
   - maintainer verification references
3. decision grid 작성:
   - keep live core
   - move to optional example pack
   - archive under `docs/archive/`
   - defer/no change
4. `--with-optional` 의미 재정의 초안:
   - heavy docs
   - example prompt/rule pack
   - profile/stack pack
   - source-only maintainer material (classification only)
5. implementation slice 분해:
   - prompt archive/pack move가 필요한지
   - scaffold wiring 변경이 필요한지
   - `work-doc.md` class 재검토를 별도 Work로 유지할지

### Non-Goals

- R0 review 전 prompt 파일 이동·삭제·내용 수정 없음.
- `docs/STATUS.md` Active pointer는 R0 합의/승인 전 변경하지 않음.
- archive pending 정리 없음. 이번 Work의 archive 판단은 prompt surface에 한정한다.
- README/MANUAL/GUIDE류 readability rewrite 재개 없음.
- `docs/HARNESS-PROTOCOL.md` trigger family simplification 없음.
- `skills/workflow/repo-health.md` slice 분리 없음.
- `skills/workflow/work-doc.md` 이동·수정 없음. 단, prompt diet 결과의 dependency로 판단만 기록한다.
- `docs/` 물리 레이아웃 이동 없음. 이번 slice에서는 "판정 기준과 reversal cost"만 정리한다.
- DR-021의 source/target boundary 자체를 재논의하지 않는다. `source-only maintainer material`은 `--with-optional` 후보가 아니라 boundary 확인용 classification axis로만 사용한다.

## Files

### R0 Plan Files

| File | Plan |
| --- | --- |
| `docs/works/harness/CHORE-20260612-010-prompt-surface-diet.md` | Work SSoT. plan, review log, decision grid를 기록 |
| `docs/works/harness/README.md` | Active Work index row 추가 |

### Inspection Files

| File / Path | Purpose |
| --- | --- |
| `prompts/` | live prompt inventory |
| `prompts/README.md` | prompt surface 설명과 fallback 역할 확인 |
| `scripts/create-harness.sh` | scaffold copy/adapt matrix에서 prompt/optional pack 경로 확인 |
| `README.md` | public/adopter prompt 또는 optional pack reference 확인 |
| `docs/WORKFLOW-MANUAL.md` | user-facing prompt/optional reference 확인 |
| `docs/PLAN.md`, `docs/PLAN-SUMMARY.md` | W3/optional pack 방향 영향 여부 확인 |
| `docs/maintainer/README.md` | docs layout 재검토 pointer 확인 |
| `docs/maintainer/VERIFICATION-COMMANDS.md` | prompt verification layer와 stale reference 확인 |
| `skills/workflow/work-doc.md` | class 재검토 dependency만 확인 |
| `docs/decisions/DR-014-archive-policy.md` | archive 보존 방식 확인 |
| `docs/decisions/DR-021-source-target-boundary.md` | optional source pack 경계 확인 |
| `docs/decisions/DR-023-canonical-workflow.md` | canonical workflow/core 경계 확인 |

## Plan

### Phase 0 — R0 Plan Review

1. Work file + Active index row만 생성한다.
2. Claude R0 review를 요청한다.
3. R0 findings를 `Cross-Agent Review And Discussion`에 기록한다.
4. R0 승인 또는 must-fix 반영 전 구현·파일 이동을 하지 않는다.

### Phase 1 — Inventory And Reference Map

1. `find prompts -maxdepth 1 -type f | sort`로 prompt inventory를 작성한다.
2. `rg "prompts/|--with-optional|optional pack|session-start"`로 source reference map을 만든다.
3. `scripts/create-harness.sh`에서 default/optional/profile/stack prompt wiring을 확인한다.
4. source repo surface와 scaffold target surface를 분리해서 표기한다.

### Phase 2 — Decision Grid

각 prompt/document surface를 아래 축으로 판정한다.

| Axis | Question |
| --- | --- |
| Core workflow? | canonical `skills/workflow/*.md` 또는 entry fallback에 필수인가? |
| Target-shipped? | scaffold default 또는 `--with-optional`로 target에 배포되는가? |
| Example value? | product adopter가 예시로 참고할 가치가 있는가? |
| Cascade cost? | 유지 시 README/manual/scaffold/verification cascade 비용이 큰가? |
| Archive fit? | live surface에서 빠져도 이력 보존만으로 충분한가? |
| Reversal cost | 이동 후 되돌리기 비용이 Low/Medium/High 중 무엇인가? |

### Phase 3 — Direction Proposal

Direction은 R1 전 아래 중 하나로 제안한다.

| Direction | Meaning | Implementation Boundary |
| --- | --- | --- |
| A. Keep live core | task prompt library를 현행 live surface로 유지 | stale reference만 정리 |
| B. Optional example pack | task prompts를 optional/example pack으로 재분류 | scaffold `--with-optional` 의미와 docs를 함께 갱신 |
| C. Archive preserve | task prompts를 `docs/archive/`로 이동해 이력만 보존 | archive index/reference 정리 필요 |
| D. Decision-only defer | 판정 기준만 기록하고 이동은 후속 Work로 분리 | 이번 Work는 implementation 없이 종료 |

Codex 작성 시점 선호는 **D 또는 B**다. 실제 파일 이동은 cascade가 넓으므로 R1 result review 이후 별도 승인 없이는 하지 않는다.

### Phase 4 — Implementation (R1 Approval 후)

R1에서 승인된 최소 변경만 적용한다.

- 가능하면 decision documentation + backlog follow-up으로 닫는다.
- 파일 이동이 승인되면 source/scaffold boundary를 먼저 고정한다.
- archive 또는 optional pack 이동은 `scripts/create-harness.sh`와 generated scaffold 검증까지 포함한다.

## Done Criteria

- [x] prompt inventory가 session-start / README / task prompts / stack-profile prompts로 분류된다.
- [x] `prompts/` references가 source-only / scaffold-shipped / maintainer verification / user-facing docs로 분류된다.
- [x] `--with-optional`의 현재 의미와 재정의 후보가 기록된다.
- [x] task prompt `00~22`에 대해 keep / optional pack / archive / defer decision grid가 작성된다.
- [x] source repo와 scaffold target 경계가 분리되어 기록된다.
- [x] `work-doc.md` class 재검토를 이번 Work에 포함할지, follow-up으로 둘지 결정된다.
- [x] Claude R0 plan review와 R1 result review가 기록된다.

## Verification

### Plan Verification

```bash
git status --short --branch
git diff --check
```

### Inventory / Implementation Verification

```bash
find prompts -maxdepth 1 -type f | sort
rg -n "prompts/|--with-optional|optional pack|session-start" README.md docs prompts scripts skills .agents .claude .cursor
bash -n scripts/create-harness.sh
```

If prompt/scaffold movement is approved:

```bash
scripts/create-harness.sh --dry-run /tmp/awh-prompt-diet-generic
scripts/create-harness.sh --dry-run --with-optional /tmp/awh-prompt-diet-optional
```

## Risk / Reversal Cost

| Item | Assessment |
| --- | --- |
| Risk level | L2 — harness workflow surface, prompt/scaffold/user-facing docs may be affected |
| Reversal cost | Low for decision-only plan. Medium if prompt files move because scaffold wiring and references must move together |
| Main risk | scope creep into broad W3 restructure, docs physical layout move, or README/MANUAL readability rewrite |
| Control | inventory-first, no implementation before R0, source/scaffold boundary table, explicit Non-Goals |

## Open Questions

| ID | Question | Default Assumption |
| --- | --- | --- |
| OQ-1 | Are task prompts `00~22` still core workflow surface after canonical workflow extraction? | No. Treat as example/optional candidate until inventory proves otherwise |
| OQ-2 | Should `--with-optional` mean "heavy docs", "example prompt pack", "profile/stack pack", or a combination? | Split meanings in the grid; avoid one overloaded flag unless existing scaffold behavior requires it |
| OQ-3 | Should docs physical layout move now? | No. Record criteria/reversal cost only; physical move is a separate Work unless R0 finds it unavoidable |
| OQ-4 | Is `work-doc.md` class recategorization part of this Work? | Decision dependency only. Implementation remains follow-up unless narrowly required |
| OQ-5 | If task prompts leave live surface, archive or optional pack? | Prefer optional/example pack if adopter value remains; archive if value is historical only |
| OQ-6 | Are session-start fallback prompts part of the diet target? | No by default. `prompts/*session-start.md` are entry fallback surfaces and remain Core unless inventory disproves that role |
| OQ-7 | Do stack/profile prompts use the same criteria as task prompts `00~22`? | Not automatically. Phase 2 must classify them as profile/stack pack, separate criteria, or out-of-scope before applying the `00~22` decision |

## Approval / State

| Item | Status |
| --- | --- |
| 위험도 | L2 |
| 실행 모드 | Standard Work |
| Branch Isolation | PASS — `feature/chore-20260612-010-prompt-surface-diet` |
| Tool rule reference | `.claude/rules/docs-workflow.md`, `.claude/rules/git-workflow.md`, DR-007 applied manually for Codex |
| Troubleshooting | Not Applicable |
| PLAN impact | `docs/PLAN-SUMMARY.md` Current Surface Policy 갱신 완료. `docs/PLAN.md` 변경은 필요 없음 |
| STATUS finalization | `docs/STATUS.md` Active Work가 이미 비어 있어 transient pointer add/remove를 하지 않음 |
| State machine | END — Work Done 처리 완료 |

## Claude R0 Review Request

Claude R0 plan review 요청: CHORE-20260612-010 Prompt Surface Diet + Optional Pack 재정의

Review focus:

1. 이 Work를 지금 시작하는 것이 W3 우선순위상 타당한가?
2. Scope / Non-goals가 prompt diet를 broad docs restructure로 번지지 않게 충분히 막는가?
3. Files 목록이 source repo / scaffold target 경계를 흐리지 않는가?
4. Verification이 R0 plan 단계와 implementation 단계로 충분히 분리되어 있는가?
5. Open Questions가 실제 decision grid를 만들기에 충분한가?
6. Round Log 구조에 Claude findings와 Codex 반영 내역을 누적하기에 충분한가?

Please respond in this format:

```text
Approval: Approved | Conditional Hold | Hold

Findings
- F1 (Must-fix/Nice-to-have): ...

Open Questions
- OQ-...

Review Questions
| Question | Answer |
| --- | --- |
| 지금 가장 먼저 필요한가? | ... |
| CHORE-20260612-007/008/009 흐름과 자연스럽게 이어지는가? | ... |
| tracking hygiene보다 W3 구조 정리에 직접 기여하는가? | ... |
| broad restructure 위험을 작게 자를 수 있는가? | ... |

Round Log Entry
| Round | Reviewer | Status | Summary | Follow-Up |
| --- | --- | --- | --- | --- |
| R0 | Claude | ... | ... | ... |
```

## Cross-Agent Review And Discussion

### Round Log

| Round | Reviewer | Status | Summary | Follow-Up |
| --- | --- | --- | --- | --- |
| R0 | Claude | **Conditional Hold → 반영 완료** | Must-fix 2개(F1 Done Criteria semantics, F2 session-start fallback/stack-profile OQ 누락), Nice-to-have 3개(F3 boundary guard, F4 preference framing, F5 finding traceability). Scope/Files/Verification은 대체로 적절. | F1: constraint를 Approval/State로 이동. F2: OQ-6/7 추가. F3: DR-021 boundary guard 추가. F4: 선호 framing label 보강. F5: Follow-Up에 Finding ID 연결. Phase 1 진입 가능 |
| R1 | Claude | **Approved → NTH 반영 완료** | R0 F1~F5 전원 반영 확인. 3분류(session-start / optional generic task / profile-stack)가 scaffold wiring과 일치. classification-only scope 적절. | R1-F1(NTH): generated README default/optional 문구를 즉시 보정. 다음 scaffold 작업으로 미루는 것도 가능했으나, 같은 row를 이미 수정 중이고 scope/reversal cost가 작아 현 Work에서 반영 |

### R0 — Plan Review (Claude, 2026-06-12)

**Approval:** Conditional Hold → Must-fix 반영 완료

**Findings**

- **F1 (Must-fix):** `docs/STATUS.md` Active pointer 변경 금지는 Done Criteria가 아니라 시간 조건부 constraint다. Done Criteria에 두면 closeout 시 체크 의미가 반전된다.
- **F2 (Must-fix):** Scope에는 session-start fallback 3종과 stack/profile prompt가 있으나 Open Questions는 task prompt `00~22`에만 집중한다. Phase 2 decision grid에서 row 누락 또는 오분류 위험이 있다.
- **F3 (Nice-to-have):** `--with-optional` 재정의에 `source-only maintainer material`을 열면 DR-021 source/target boundary 재논의로 번질 수 있다.
- **F4 (Nice-to-have):** "기본 선호는 D 또는 B" framing은 R0 독립성을 약화할 수 있다.
- **F5 (Nice-to-have):** Round Log의 Follow-Up에 Finding ID를 명시해 multi-round 추적성을 유지하는 편이 좋다.

**Codex 반영**

- F1: Done Criteria에서 제거하고 `Approval / State`의 `STATUS constraint`로 이동.
- F2: OQ-6(session-start fallback core 보존 기본값), OQ-7(stack/profile prompt 별도 판정 기본값) 추가.
- F3: Non-Goals에 DR-021 source/target boundary 재논의 제외와 `source-only maintainer material` classification-only 경계 추가.
- F4: Direction 선호 문장을 "Codex 작성 시점 선호"로 레이블링.
- F5: Round Log Follow-Up에 Finding ID별 반영 내역 기록.

## Phase 1 Inventory And Decision

### Prompt Inventory

| Class | Files | Source status | Scaffold target status |
| --- | --- | --- | --- |
| Session start fallback | `claude-session-start.md`, `codex-session-start.md`, `cursor-session-start.md` | Core fallback | Always copied with `prompts/README.md` |
| Prompt README | `prompts/README.md` | Index / classification SSoT | Always copied |
| Optional generic task prompts | `00`, `01`, `03`, `05`, `06`, `07`, `09`, `15`, `16`, `17`, `19`, `20`, `22` | Live reusable examples, not core runtime | Copied only with `--with-optional` |
| Profile / stack prompts | `02`, `04`, `08`, `10`, `11`, `12`, `13`, `14`, `18`, `21` | Spring Boot example pack | Copied only with `--profile spring-boot` |

### Reference Map

| Surface | Finding |
| --- | --- |
| `prompts/README.md` | Called `00/01/03/.../22` "Generic core prompts" even though scaffold treats them as `--with-optional` extended generic prompts |
| `scripts/create-harness.sh` | Already has the intended three-way wiring: always session-start+README, `--with-optional` generic task prompts, `--profile spring-boot` stack prompts |
| generated README block in `scripts/create-harness.sh` | Described `prompts/` as "세션 시작 및 태스크 프롬프트 라이브러리", which overstates default scaffold contents |
| `docs/PLAN-SUMMARY.md` | Listed extended task prompt library under "유지 여부 검토" even though this Work resolves it as optional/example |
| `docs/WORKFLOW-MANUAL.md` / source `README.md` / `docs/HARNESS-ARCHITECTURE.md` | Broad "fallback/task templates" wording is acceptable because these source/optional docs describe the repo surface, not default scaffold contents |
| `docs/maintainer/VERIFICATION-COMMANDS.md` | Layer S covers session-start fallback; Layer U stack marker checks cover representative Spring profile prompt leakage |

### Decision Grid

| Surface | Decision | Rationale |
| --- | --- | --- |
| Session-start fallback 3종 | Keep core | Entry fallback이고 default scaffold에 항상 필요 |
| `prompts/README.md` | Keep core index | Always copied; classification wording must be current |
| Generic task prompts 13개 | Optional generic task prompt pack | Useful portable examples, but not canonical workflow runtime; keep source live and `--with-optional` target opt-in |
| Spring Boot prompts 10개 | Profile/stack example pack | `portability: spring-boot-example`; scaffold already gates them behind `--profile spring-boot` |
| `work-doc.md` class recategorization | Follow-up, not this Work | prompt README/scaffold wording can be corrected without moving or reclassifying canonical workflow files |
| docs physical layout | Defer | No file movement needed; DR-021 boundary remains unchanged |

### Implementation Direction

Selected direction: **B. Optional example pack, classification-only**.

This Work does not move prompt files. It aligns wording with existing scaffold behavior:

- `prompts/README.md`: rename "Generic core prompts" to optional generic task prompts and distinguish session-start fallback / generic task / profile-stack packs.
- `scripts/create-harness.sh`: generated README describes `prompts/` as session-start fallback, with generic task prompt library explicitly marked optional.
- `docs/PLAN-SUMMARY.md`: move extended generic task prompt library from "유지 여부 검토" to "Optional/example로 유지".

### Verification Results

```bash
git diff --check
bash -n scripts/create-harness.sh
scripts/create-harness.sh --dry-run prompt-diet-generic /private/tmp/awh-prompt-diet-generic
scripts/create-harness.sh --dry-run --with-optional prompt-diet-optional /private/tmp/awh-prompt-diet-optional
rg -n "Generic core prompt|Generic core prompts|Optional Generic Task Prompts|optional task prompt library|extended generic task prompt library|유지 여부 검토|Optional/example" prompts/README.md scripts/create-harness.sh docs/PLAN-SUMMARY.md README.md docs/WORKFLOW-MANUAL.md docs/HARNESS-ARCHITECTURE.md docs/HARNESS-MAINTAINER-GUIDE.md
```

Result:

- `git diff --check`: PASS
- `bash -n scripts/create-harness.sh`: PASS
- dry-run default: PASS, task prompts excluded, session-start prompts + README only
- dry-run `--with-optional`: PASS, generic task prompt 13개 included
- stale wording grep: PASS, `Generic core prompt(s)` 없음. Remaining hits are intended new wording and `PLAN-SUMMARY` unresolved rows for unrelated items.

## Claude R1 Review Request

Claude R1 result review 요청: CHORE-20260612-010 Prompt Surface Diet + Optional Pack 재정의

Changed files:

- `prompts/README.md`
- `scripts/create-harness.sh`
- `docs/PLAN-SUMMARY.md`
- `docs/works/harness/CHORE-20260612-010-prompt-surface-diet.md`
- `docs/works/harness/README.md`

Review focus:

1. R0 F1/F2/F3/F4/F5가 충분히 반영됐는가?
2. `prompts/README.md`의 session-start fallback / optional generic task prompt / profile-stack example pack 3분류가 현재 scaffold wiring과 맞는가?
3. `scripts/create-harness.sh` generated README 문구가 default scaffold와 `--with-optional` 양쪽에서 과장 없이 맞는가?
4. `docs/PLAN-SUMMARY.md`의 "Optional/example로 유지" 행이 W3 decision을 과하게 확정하거나 PLAN drift를 만들지 않는가?
5. 파일 이동 없는 classification-only 구현이 이번 scope에 맞는가?
6. 누락된 verification 또는 source/scaffold boundary risk가 있는가?

Please respond in this format:

```text
Approval: Approved | Conditional Hold | Hold

Findings
- F1 (Must-fix/Nice-to-have): ...

Review Questions
| Question | Answer |
| --- | --- |
| R0 findings are resolved? | ... |
| Source/scaffold boundary is preserved? | ... |
| Classification-only scope is sufficient? | ... |
| Verification is sufficient? | ... |

Round Log Entry
| Round | Reviewer | Status | Summary | Follow-Up |
| --- | --- | --- | --- | --- |
| R1 | Claude | ... | ... | ... |
```

### R1 — Result Review (Claude, 2026-06-12)

**Approval:** Approved

**Findings**

- **F1 (Nice-to-have):** generated README row is better than before but still prints identically in default and `--with-optional` scaffold. More exact wording: `세션 시작 fallback prompt (optional: generic task prompt library)`.

**Challenge Check / Codex Disposition**

| Finding | Disposition | Rationale |
| --- | --- | --- |
| R1-F1 | Accepted now | Deferring was acceptable, but the same row is already in scope and the proposed wording improves default scaffold accuracy without file movement or scaffold wiring change. Reversal cost is a one-line text revert. |

**Review Questions**

| Question | Answer |
| --- | --- |
| R0 findings are resolved? | Yes. F1~F5 resolved. |
| Source/scaffold boundary is preserved? | Yes. `source-only maintainer material` is classification-only, not a `--with-optional` candidate. |
| Classification-only scope is sufficient? | Yes. No prompt files moved; wording drift only. |
| Verification is sufficient? | Yes for scope. `run-harness-checks.sh --all` is nice-to-have, not blocking. |

## Discovery

- 2026-06-12: session-start/work-plan entry contract 확인. `develop...origin/develop` clean, PR #162 merge commit `67c64c4` 확인.
- 2026-06-12: Branch Isolation Check 결과 source-gitflow mode. `develop`에서 protected docs를 직접 편집하지 않기 위해 `feature/chore-20260612-010-prompt-surface-diet` 생성.
- 2026-06-12: 후보 비교 결과 `Prompt surface diet + optional pack 재정의` 선택. R0 전 implementation 금지, Work file + index only로 시작.
- 2026-06-12: Claude R0 Conditional Hold 반영. Done Criteria semantic correction, OQ-6/7 추가, DR-021 boundary guard, preference framing label, Finding ID 추적성을 Work file에 반영했다.
- 2026-06-12: Phase 1 inventory 결과 source `prompts/README.md` 용어와 scaffold wiring 사이 drift 확인. 구현은 파일 이동 없이 classification wording 정렬로 제한했다.
- 2026-06-12: verification PASS. Claude R1 result review 요청 작성. `docs/STATUS.md` Active pointer는 아직 미수정(별도 state-change approval 필요).
- 2026-06-12: Claude R1 Approved. Nice-to-have generated README wording은 같은 row의 정확도 개선이라 즉시 반영하고, Challenge Check / Codex Disposition을 남겼다.
- 2026-06-12: Work Done 처리. `docs/STATUS.md`는 이미 Active Work가 비어 있어 transient pointer add/remove churn을 피하고 변경하지 않음.
