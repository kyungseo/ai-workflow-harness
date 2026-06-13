---
id: CHORE-20260613-001
priority: P1
status: Archived
risk: L2
scope: Prompt task library archive + scaffold prompt copy pruning. `prompts/*-session-start.md`와 `prompts/README.md`만 live fallback surface로 남기고, `.prompt.md` task/profile prompt는 archive 보존으로 전환한다.
appetite: 0.5d
planned_start: 2026-06-13
planned_end: 2026-06-13
actual_end: 2026-06-13
related_dr: [DR-014, DR-021, DR-023]
related_work: [CHORE-20260612-010, CHORE-20260612-011]
---

# CHORE-20260613-001: Prompt Task Library Archive + Scaffold Pruning

## Top Summary

- **목표:** `prompts/` live surface를 session-start fallback 3종 + README로 줄이고, task/profile `.prompt.md` 23개는 `docs/archive/prompts/`로 이동해 이력 보존으로 전환한다.
- **왜 지금:** CHORE-20260612-010은 prompt surface diet를 classification-only로 닫았고, 사용자는 `*-session-start.md`, README 외 prompt archive를 명시했다. CHORE-20260612-011 이후 본류 W3에서 가장 작게 닫을 수 있는 실제 surface diet 후속이다.
- **핵심 경계:** prompt archive는 archive pending Work 정리가 아니다. 이번 scope는 prompt task library에 한정하고, `docs/works/**` archive pending은 건드리지 않는다.
- **역할:** Codex = author/driver, Claude = red team reviewer.

## Candidate Comparison

1. **Prompt task library archive**가 지금 가장 직접적이다. CHORE-010의 decision-only 결과를 실제 live surface 정리로 닫는다.
2. CHORE-011이 남긴 `Project Constants`/`Load Map` 후속은 중요하지만, 다시 `AGENT-WORKFLOW`/`HARNESS-PROTOCOL` 구조로 들어가면 broad W3 restructure 위험이 크다.
3. `Harness protocol trigger family simplification`은 W3 본류지만 trigger 재그룹화가 protocol 전체 rewrite로 번질 수 있어 지금 한 세션 작업으로는 위험하다.
4. `repo-health`/`work-doc` slice는 Prompt surface diet 이후가 자연스럽다. 특히 `work-doc` class 판단은 prompt/example pack 경계와 연결된다.
5. archive pending 정리는 tracking hygiene라 이번 본류와 다르다. 사용자가 명시한 archive는 prompt surface 자체의 live/archive 판정이다.
6. 따라서 이번 Work는 prompt 파일 이동 + scaffold copy matrix 정리 + generated prompt surface 검증으로 작게 자른다.

## Background / Facts

Current prompt inventory:

| Group | Files | Current Role |
| --- | --- | --- |
| Session-start fallback | `claude-session-start.md`, `codex-session-start.md`, `cursor-session-start.md` | Core fallback surface. Live 유지 |
| Prompt README | `README.md` | prompt directory guide. Live 유지, 내용 축소 필요 |
| Generic task prompts | `00`, `01`, `03`, `05`, `06`, `07`, `09`, `15`, `16`, `17`, `19`, `20`, `22` | `--with-optional`일 때 scaffold target에 복사됨 |
| Spring/profile prompts | `02`, `04`, `08`, `10`, `11`, `12`, `13`, `14`, `18`, `21` | `--profile spring-boot`일 때 scaffold target에 복사됨 |

Current scaffold wiring:

- Always copies `prompts/README.md`, `claude-session-start.md`, `codex-session-start.md`, `cursor-session-start.md`.
- `--with-optional` copies generic `.prompt.md` bundle.
- `--profile spring-boot` copies stack/profile `.prompt.md` bundle.

## Scope / Non-Goals

### Scope

1. Move all `prompts/*.prompt.md` files to `docs/archive/prompts/` using archive path mirror policy.
2. Keep only:
   - `prompts/README.md`
   - `prompts/claude-session-start.md`
   - `prompts/codex-session-start.md`
   - `prompts/cursor-session-start.md`
3. Update `prompts/README.md` so it describes session-start fallback only and points to archive history for removed task examples.
4. Update `scripts/create-harness.sh` prompt copy matrix:
   - default: unchanged session-start fallback + README
   - `--with-optional`: no task prompt bundle copy
   - `--profile spring-boot`: no stack prompt bundle copy
   - generated README row should no longer advertise optional task prompt library in `prompts/`
5. Update source references that would become stale:
   - README prompt description
   - `docs/PLAN-SUMMARY.md` current surface policy
   - `docs/WORKFLOW-MANUAL.md` Appendix A prompt file list and prompt library usage text
   - any prompt verification/reference text found by grep
6. Validate fresh scaffold default, `--with-optional`, and `--profile spring-boot` prompt output.

### Non-Goals

- Archive pending Work movement.
- `docs/archive/` retention policy redesign.
- Deleting prompt history from git. Use archive move, not deletion.
- Rewriting session-start fallback prompts unless a direct stale reference is caused by this archive.
- README/MANUAL readability rewrite.
- `docs/WORKFLOW-MANUAL.md` prose/style rewrite. Appendix A factual correction is in scope because archived prompt files must not remain listed as live files.
- `skills/workflow/work-doc.md` class move; only preserve it as follow-up context if needed.
- Adding a new scaffold flag such as `--with-prompts` or `--with-spring-boot-msa`.
- Changing `--with-optional` heavy-doc behavior except removing archived task prompt copy.

## Files

### Plan / Tracking

| File | Plan |
| --- | --- |
| `docs/works/harness/CHORE-20260613-001-prompt-task-library-archive.md` | Work SSoT |
| `docs/works/harness/README.md` | Active Work index row |

### Expected Implementation Files

| File / Path | Plan |
| --- | --- |
| `prompts/*.prompt.md` | Move to `docs/archive/prompts/` |
| `prompts/README.md` | Reduce to live session-start fallback guide |
| `scripts/create-harness.sh` | Remove optional/profile prompt bundle copy, update generated README prompt row/output text |
| `README.md` | Update repository layout / prompts description if stale |
| `docs/PLAN-SUMMARY.md` | Update current surface policy from optional prompt library to archived prompt examples |
| `docs/PLAN.md`, `docs/HARNESS-ARCHITECTURE.md` | Update live prompt surface descriptions from broad prompt template to session-start fallback |
| `docs/WORKFLOW-MANUAL.md` | Replace Appendix A task prompt file list/usage with live session-start fallback + archive pointer |
| `docs/HARNESS-MAINTAINER-GUIDE.md`, `docs/SCAFFOLD-BOOTSTRAP.md`, `docs/maintainer/VERIFICATION-COMMANDS.md` | Update live maintainer/scaffold guidance that still expected task/profile prompt examples |
| `scripts/tests/check-scaffold-invariants.sh` | Update optional-pack comment to remove archived prompt bundle wording |
| `docs/archive/prompts/` | Archive destination for prompt task library |

## Plan

### Phase 0 — R0 Review

1. Work file + Work index Active row only.
2. Claude R0 plan review.
3. R0 findings 반영 전 prompt 이동·scaffold rewiring 없음.

### Phase 1 — Atomic Archive + Scaffold Pruning Patch

Phase 1 and Phase 2 must land in the same working-tree patch and the same commit. `scripts/create-harness.sh` currently fails hard if its prompt copy list references a moved file, so archive move without scaffold pruning creates a broken-window state.

1. Prune `scripts/create-harness.sh` optional/profile prompt copy loops first or in the same patch as the move.
2. Use `git mv prompts/*.prompt.md docs/archive/prompts/`.
3. Rewrite `prompts/README.md` around live fallback prompts.
4. Update source references that still claim task prompt library is live or shipped.
5. Shrink `docs/WORKFLOW-MANUAL.md` Appendix A to live session-start fallback + archive pointer. Do not rewrite manual style beyond factual correction.
6. Update live maintainer verification guidance that would otherwise check archived prompt examples as current scaffold output.
7. Do not commit or checkpoint between prompt move and scaffold pruning.

### Phase 2 — Scaffold Copy Matrix Verification

1. Confirm always-copied session-start prompt set remains.
2. Confirm `--with-optional` no longer copies generic `.prompt.md`.
3. Confirm `--profile spring-boot` no longer copies stack/profile `.prompt.md`.
4. Confirm generated README and console text do not advertise prompt bundles.

### Phase 3 — Verification + R1 Review

1. Run source stale checks.
2. Run `bash -n scripts/create-harness.sh`.
3. Generate default, `--with-optional`, and `--profile spring-boot` scaffolds in `/private/tmp`.
4. Verify each generated target has only prompt README + session-start fallback prompts.
5. Ask Claude R1 result review before closeout.

## Done Criteria

- [x] `prompts/` live directory contains only README + 3 session-start fallback prompts.
- [x] All `.prompt.md` files are preserved under `docs/archive/prompts/`.
- [x] `scripts/create-harness.sh` no longer copies archived `.prompt.md` files for default, `--with-optional`, or `--profile spring-boot`.
- [x] Generated default, `--with-optional`, and `--profile spring-boot` scaffolds contain no archived `.prompt.md` files.
- [x] README / PLAN-SUMMARY / prompts README no longer advertise live optional task prompt library.
- [x] `docs/WORKFLOW-MANUAL.md` Appendix A no longer lists archived `.prompt.md` files as live prompt library files.
- [x] Source/scaffold boundary is explicit: archived examples are source history, not target-shipped prompt surface.
- [x] Claude R0/R1 review and Codex disposition are recorded.

## Verification

```bash
git diff --check
find prompts -maxdepth 1 -type f -print | sort
find docs/archive/prompts -maxdepth 1 -type f -name '*.prompt.md' -print | sort
rg -n --glob '!docs/archive/**' "optional task prompt|generic task prompt|profile/stack|\\.prompt\\.md|--with-optional|spring-boot.*prompt|prompts/" README.md docs prompts scripts
bash -n scripts/create-harness.sh
scripts/create-harness.sh --dry-run prompt-archive-default /private/tmp/awh-prompt-archive-default-dry
scripts/create-harness.sh prompt-archive-default /private/tmp/awh-prompt-archive-default
scripts/create-harness.sh --with-optional prompt-archive-optional /private/tmp/awh-prompt-archive-optional
scripts/create-harness.sh --profile spring-boot prompt-archive-spring /private/tmp/awh-prompt-archive-spring
find /private/tmp/awh-prompt-archive-default/prompts -maxdepth 1 -type f -print | sort
find /private/tmp/awh-prompt-archive-optional/prompts -maxdepth 1 -type f -print | sort
find /private/tmp/awh-prompt-archive-spring/prompts -maxdepth 1 -type f -print | sort
```

Expected generated prompt files:

```text
prompts/README.md
prompts/claude-session-start.md
prompts/codex-session-start.md
prompts/cursor-session-start.md
```

## Risk / Reversal Cost

| Item | Assessment |
| --- | --- |
| Risk level | L2 — prompt/scaffold/user-facing docs surface |
| Reversal cost | Medium. `git mv` is reversible, but scaffold option meaning changes and must be verified |
| Main risk | `--with-optional` or `--profile spring-boot` users expecting prompt examples lose generated files unexpectedly |
| Control | R0 review before implementation, archive not delete, generated scaffold verification for all three modes |

## Open Questions

| ID | Question | Default Assumption |
| --- | --- | --- |
| OQ-1 | Should `--with-optional` continue to ship generic task prompts? | No. Archive request means task prompt examples leave target-shipped surface |
| OQ-2 | Should `--profile spring-boot` continue to ship stack prompt examples? | No. User requested all non-session-start prompt files archive; profile prompt shipping should be removed unless R0 blocks |
| OQ-3 | Should archived prompt examples be referenced from `prompts/README.md`? | Brief historical pointer only. Do not make archive part of normal task flow |
| OQ-4 | Should `docs/archive/prompts/README.md` be created? | No by default. DR-014 mirrors paths; add only if R0 requests an archive index |
| OQ-5 | Does this require `docs/PLAN.md` update? | Probably no. `docs/PLAN-SUMMARY.md` surface policy may need update; PLAN direction is unchanged |
| OQ-6 | Is this a breaking scaffold change? | Soft breaking for optional/profile prompt examples. Treat as L2 with fresh scaffold evidence |
| OQ-7 | Should archive grep hits count as stale references? | No. `docs/archive/**` hits are expected historical content and should be excluded from stale-reference grep unless specifically auditing archive |

## Approval / State

| Item | Status |
| --- | --- |
| 위험도 | L2 |
| 실행 모드 | Standard Work |
| Branch Isolation | PASS — `feature/chore-20260613-001-prompt-task-library-archive` |
| STATUS proposal | R0 합의 전 `docs/STATUS.md` 변경 없음 |
| State machine | PLAN → APPROVAL. R0 승인 전 EXECUTE 금지 |

## Claude R0 Review Request

Claude R0 plan review 요청: CHORE-20260613-001 Prompt Task Library Archive + Scaffold Pruning

Review focus:

1. `prompts/*.prompt.md` 전체 archive가 CHORE-010/사용자 의도와 맞는가?
2. `--with-optional`과 `--profile spring-boot`에서 prompt copy를 제거하는 것이 source/scaffold boundary를 해치지 않는가?
3. `prompts/README.md`를 session-start fallback guide로 축소하는 것이 충분한가?
4. `docs/archive/prompts/README.md` 같은 archive index가 필요한가, 아니면 파일 이동만으로 충분한가?
5. Verification이 default / `--with-optional` / `--profile spring-boot` target prompt surface를 충분히 확인하는가?
6. 이번 scope가 archive pending cleanup이나 broad optional-pack redesign으로 번지지 않게 충분히 막혀 있는가?

Please respond in this format:

```text
Approval: Approved | Conditional Hold | Hold

Findings
- F1 (Must-fix/Nice-to-have): ...

Review Questions
| Question | Answer |
| --- | --- |
| Matches user intent? | ... |
| Scaffold boundary preserved? | ... |
| Scope controlled? | ... |
| Verification sufficient? | ... |

Round Log Entry
| Round | Reviewer | Status | Summary | Follow-Up |
| --- | --- | --- | --- | --- |
| R0 | Claude | ... | ... | ... |
```

## Cross-Agent Review And Discussion

### Round Log

| Round | Reviewer | Status | Summary | Follow-Up |
| --- | --- | --- | --- | --- |
| R0 | Claude | Conditional Hold | Must-fix 2개: F1(archive move와 scaffold pruning이 분리 commit이면 scaffold hard-fail), F2(`docs/WORKFLOW-MANUAL.md` Appendix A stale 위험). Nice-to-have 1개: F3(rg archive false positive). | F1/F2/F3 반영 후 Phase 1 진입 가능 |
| R1 | Claude | Approved | R0 F1/F2/F3 전원 반영 확인. 23개 archive move + scaffold loop 제거 + source doc stale-reference 정정이 atomic working-tree patch에 포함됐다. 3-mode scaffold 생성 검증 PASS. | F1 nice-to-have: 다음 Work의 stale-reference grep 템플릿에는 `.claude`, `.cursor`, `.agents` 경로도 포함 권장. 현재 Work는 commit/close 가능 |

### Finding Disposition

| Finding | Codex Disposition | Rationale / Action |
| --- | --- | --- |
| R0-F1 | Accepted | `copy_prompt` source가 없으면 `scripts/create-harness.sh`가 hard-fail한다. archive move와 scaffold pruning은 같은 working-tree patch/commit에 포함하고 중간 checkpoint/commit을 금지한다고 Plan에 명시했다. |
| R0-F2 | Accepted | `docs/WORKFLOW-MANUAL.md` Appendix A는 live `.prompt.md` 목록과 사용 절차를 담고 있어 archive 후 사실 오류가 된다. Files/Scope/Done Criteria에 Appendix A 축소 계획을 추가했다. |
| R0-F3 | Accepted | stale reference grep에서 `docs/archive/**`를 제외하도록 verification command를 수정하고 OQ-7에 archive hit 처리 기준을 추가했다. |
| R1-F1 | Accepted as follow-up hygiene | Current Work 검증에는 영향 없음. Claude가 `.claude`, `.cursor`, `.agents`를 독립 확인해 stale hit 없음으로 검증했다. 다음 stale-reference grep 템플릿에는 tool adapter 경로를 포함한다. |

## Discovery

- 2026-06-13: PR #164 merge 후 `develop...origin/develop` clean 확인. Active Work 없음.
- 2026-06-13: CHORE-010 classification-only 결과와 사용자 명시 요청을 근거로 prompt task/profile `.prompt.md` archive implementation slice를 선택.
- 2026-06-13: Claude R0 Conditional Hold 반영. archive move + scaffold pruning atomicity, WORKFLOW-MANUAL Appendix A factual correction, archive grep false positive 방지를 Plan에 추가.
- 2026-06-13: Phase 1/2 구현 완료. `prompts/*.prompt.md` 23개를 `docs/archive/prompts/`로 이동하고, `scripts/create-harness.sh`의 `--with-optional`/`--profile spring-boot` prompt copy loop를 제거했다.
- 2026-06-13: live docs/maintainer verification surface에서 task/profile prompt bundle을 현재 scaffold output으로 가정하던 표현을 session-start fallback / archived examples 기준으로 정정했다.

## Implementation Notes

### Phase 1 / 2 Result

| Area | Result |
| --- | --- |
| Live prompt directory | `prompts/README.md`, `prompts/claude-session-start.md`, `prompts/codex-session-start.md`, `prompts/cursor-session-start.md` only |
| Archive preservation | 23 `.prompt.md` files moved to `docs/archive/prompts/` |
| Scaffold copy matrix | default, `--with-optional`, `--profile spring-boot` now copy only prompt README + session-start fallback prompts |
| Generated README / console | no longer advertises generic task prompt library or Spring Boot prompt bundle |
| Source docs | README, PLAN, PLAN-SUMMARY, WORKFLOW-MANUAL, HARNESS-ARCHITECTURE, HARNESS-MAINTAINER-GUIDE, SCAFFOLD-BOOTSTRAP, VERIFICATION-COMMANDS updated to live fallback/archive boundary |
| Verification scripts | `check-scaffold-invariants.sh` optional-pack comment no longer mentions archived prompt bundle |

### Phase 2 Verification Notes

| Command | Result |
| --- | --- |
| `git diff --check` | PASS |
| `bash -n scripts/create-harness.sh` | PASS |
| `find prompts -maxdepth 1 -type f -print \| sort` | PASS — 4 live files only |
| `find docs/archive/prompts -maxdepth 1 -type f -name '*.prompt.md' -print \| wc -l` | PASS — 23 archived prompt files |
| stale-term `rg` excluding `docs/archive/**`, `docs/works/**`, `docs/retrospectives/**` | PASS — no live stale hits for optional/generic prompt bundle terms |
| `scripts/create-harness.sh --dry-run prompt-archive-default /private/tmp/awh-prompt-archive-default-dry-001` | PASS |
| `scripts/create-harness.sh prompt-archive-default /private/tmp/awh-prompt-archive-default-001` | PASS |
| `scripts/create-harness.sh --with-optional prompt-archive-optional /private/tmp/awh-prompt-archive-optional-001` | PASS |
| `scripts/create-harness.sh --profile spring-boot prompt-archive-spring /private/tmp/awh-prompt-archive-spring-001` | PASS |
| generated target prompt file check for all three actual targets | PASS — each target has only README + 3 session-start fallback prompts |
| generated target `.prompt.md` search | PASS — no `.prompt.md` files in generated `prompts/` directories |
| `bash scripts/tests/check-scaffold-invariants.sh` | PASS — default minimal, `--with-optional`, `--workflow source-gitflow`; optional DR-025 report-only unchanged |

### Claude R1 Review Request

Claude R1 result review 요청: CHORE-20260613-001 Prompt Task Library Archive + Scaffold Pruning

Review focus:

1. R0 F1 atomicity가 충분히 해소됐는가? (`git mv` archive와 scaffold prompt copy loop 제거가 같은 working-tree patch에 포함됨)
2. R0 F2 `docs/WORKFLOW-MANUAL.md` Appendix A factual correction이 충분한가?
3. `--with-optional`과 `--profile spring-boot` scaffold output에서 `.prompt.md` 제거가 source/scaffold boundary를 보존하는가?
4. live maintainer/reference docs 추가 정정 범위가 scope-local인가, 아니면 broad rewrite로 번졌는가?
5. Verification evidence가 closeout 전 충분한가?

Suggested Round Log Entry:

| Round | Reviewer | Status | Summary | Follow-Up |
| --- | --- | --- | --- | --- |
| R1 | Claude | Approved / Conditional Hold / Hold | ... | ... |
