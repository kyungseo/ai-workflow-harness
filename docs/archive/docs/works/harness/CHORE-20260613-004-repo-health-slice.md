---
id: CHORE-20260613-004
priority: P2
status: Archived
risk: L2
scope: `skills/workflow/repo-health.md`의 Quick/default path와 `--full`/`--cascade` 상세 checklist를 분리해 context load weight를 줄이는 최소 slice split. R0 승인 전 구현 변경은 하지 않는다.
appetite: 0.5d
planned_start: 2026-06-13
planned_end: 2026-06-13
actual_end: 2026-06-13
related_dr: [DR-007, DR-021, DR-023, DR-024]
related_work: [CHORE-20260611-005, CHORE-20260611-006, CHORE-20260611-008, CHORE-20260612-010, CHORE-20260613-002, CHORE-20260613-003]
---

# CHORE-20260613-004: Repo-Health Canonical Slice Split

## Top Summary

- **목표:** `skills/workflow/repo-health.md`를 Quick/default 실행에 필요한 계약과 `--full`/`--cascade` 조건부 상세로 분리해, 일상 workflow에서 불필요한 장문 checklist 로드를 줄인다.
- **왜 지금:** CHORE-20260613-002/003이 `AGENT-WORKFLOW`와 `HARNESS-PROTOCOL`의 load path 중복을 줄였다. 다음으로 가장 무거운 canonical workflow 파일인 `/repo-health`의 mode-specific detail을 작게 분리하는 것이 W3 Workflow IA Diet 흐름에 직접 이어진다.
- **핵심 경계:** `/repo-health`의 의미·모드·report-only 성격은 바꾸지 않는다. trigger family 재그룹화, work-doc class 재검토, archive cleanup은 다루지 않는다.
- **역할:** Codex = author/driver, Claude = red team reviewer.

## Candidate Comparison

1. **repo-health slice split**은 436줄 canonical 파일의 load weight를 직접 줄이고, `--full`/`--cascade` 조건부 경계가 이미 문서 안에 존재해 작게 닫을 수 있다.
2. **trigger family simplification**은 W3 본류지만 `HARNESS-PROTOCOL.md` T1~T17 전체 재그룹화로 번질 위험이 커서 R0 설계만으로도 커질 수 있다.
3. **work-doc class 재검토**는 CHORE-20260612-010 후속이지만 Optional pack 이동과 scaffold/user-facing cascade가 붙으면 반나절 범위를 넘기 쉽다.
4. **Project Constants discoverability**는 CHORE-20260613-002에서 startup pointer가 보강되어 지금 추가 Work로 열 우선도는 낮다.
5. 따라서 이번 Work는 `repo-health.md`의 mode-specific detail extraction만 다루고, 다른 W3 후보는 후속으로 둔다.

## Scope / Non-Goals

### Scope

1. `skills/workflow/repo-health.md`를 section 단위로 `Always-needed / Quick / --full only / --cascade only / Shared reference`로 분류한다.
2. R0 승인 후, 필요한 경우 slice 파일을 추가한다.
   - 선호안: `skills/workflow/repo-health-full.md`
   - 선호안: `skills/workflow/repo-health-cascade.md`
3. `repo-health.md`에는 Procedure, Execution Principles, Mode Contract, Output Contract, 기본 reading order, Quick Areas(A/B/E), conditional pointer만 남긴다.
4. `skills/workflow/README.md`에 새 slice 파일의 역할을 인덱싱한다.
5. `scripts/create-harness.sh`가 `skills/workflow/*.md`를 glob 복사한다는 점을 확인하고, 추가 파일이 scaffold에 포함되는 효과를 명시적으로 검토한다.
6. health 관련 주변 문서가 `repo-health.md` 단일 파일 또는 Required Matrix 위치를 직접 가리키는지 감사하고, 필요한 최소 pointer만 갱신한다.
7. Work 파일에 Claude R0/R1 review와 Codex disposition을 누적한다.

### Non-Goals

- `/repo-health` report format, severity taxonomy, mode semantics 변경.
- `docs/HARNESS-PROTOCOL.md` trigger family simplification.
- `skills/workflow/work-doc.md` class 재검토.
- `.claude/commands/repo-health.md` 또는 `.agents/skills/workflow-repo-health/SKILL.md` adapter 구조 변경. 단, pointer가 깨지는지 read-only 확인은 가능하다.
- `docs/STATUS.md` Active pointer 변경. R0 합의 전에는 변경하지 않는다.
- archive pending cleanup.
- README/MANUAL/GUIDE readability rewrite.
- scaffold behavior 정책 변경. 새 slice 파일이 glob 복사되는지 확인만 한다.

## Files

### Plan / Tracking

| File | Plan |
| --- | --- |
| `docs/works/harness/CHORE-20260613-004-repo-health-slice.md` | Work SSoT |
| `docs/works/harness/README.md` | Active Work index row only |

### Expected Audit / Implementation Surfaces

| File | Plan |
| --- | --- |
| `skills/workflow/repo-health.md` | main canonical workflow. R0 이후 mode-specific detail을 pointer로 축소 |
| `skills/workflow/repo-health-full.md` | R0 승인 시 `--full` 전용 reading/detail/inspection slice 후보 |
| `skills/workflow/repo-health-cascade.md` | R0 승인 시 `--cascade` 전용 surface matrix/grep/simulation slice 후보 |
| `skills/workflow/README.md` | slice 파일 추가 시 index 갱신 |
| `.agents/skills/workflow-repo-health/SKILL.md`, `.claude/commands/repo-health.md` | read-only adapter pointer check |
| `docs/HARNESS-QUICK-REFERENCE.md`, `scripts/create-harness.sh` | read-only cascade/scaffold inclusion check |
| `README.md`, `docs/WORKFLOW-MANUAL.md` | read-only user-facing command summary check. semantics unchanged이면 No action |
| `docs/maintainer/HARNESS-TEST-TAXONOMY.md`, `docs/maintainer/VERIFICATION-COMMANDS.md` | health verification/catalog pointer impact check. Required Matrix 위치가 바뀌면 최소 pointer 갱신 가능 |

## Plan

### Phase 0 — R0 Review Package

1. Work file과 Work index Active row만 생성한다.
2. `docs/STATUS.md` Active pointer는 R0 합의 전 변경하지 않는다.
3. Claude R0 plan review를 요청한다.
4. R0 승인 전 `skills/workflow/repo-health.md` 구현 변경은 하지 않는다.

### Phase 1 — Section Classification

1. `repo-health.md`의 모든 top-level/second-level section을 `Always-needed / Quick / --full only / --cascade only / Shared reference`로 분류한다.
2. `--full`과 `--cascade`가 공유하는 `Workflow Context Weight`는 main summary + slice detail 중 어느 쪽이 더 안전한지 별도 판정한다.
3. `Required Surface Matrix`, `Required Grep Pack`, `Required Simulation Matrix`가 `--cascade` 전용으로 이동 가능한지 확인한다.
4. `Inspection Areas C/D/F`가 `--full` 전용으로 이동 가능한지 확인한다.
5. `Inspection Areas A/B/E`는 Quick/default path에 남겨야 하는지 확인한다.
6. `scripts/create-harness.sh`의 `skills/workflow/*.md` glob 복사로 새 slice 파일이 scaffold target에 포함되는지 기록한다.
7. `/repo-health`를 설명하거나 `Required Surface Matrix` 위치를 검증하는 주변 health 문서를 live surface 중심으로 감사한다.
8. 주변 audit에서 adapter section heading 참조가 깨지면, 이 Work 안에서 고칠 수 있는 main pointer 문구와 Non-goal로 막힌 adapter 구조 변경을 구분한다. adapter 구조 변경은 P1 finding + follow-up Work로 분리한다.

### Phase 2 — Minimal Slice Split

R0 승인 및 Phase 1 audit 결과가 모두 충족될 때만 아래 중 필요한 최소 변경을 수행한다.

1. `repo-health.md`에서 `--full` 전용 장문 세부 항목을 `repo-health-full.md`로 이동하고 conditional pointer로 교체한다.
2. `repo-health.md`에서 `--cascade` 전용 surface matrix / grep pack / simulation matrix / cascade area를 `repo-health-cascade.md`로 이동하고 conditional pointer로 교체한다.
3. `repo-health.md`의 Quick/default path는 self-contained로 유지한다.
4. 새 slice 파일이 늘어났더라도 command/adapter naming을 새 command처럼 보이게 하지 않는다.
5. `skills/workflow/README.md`에는 "Supporting Slices" 또는 동등 섹션으로 역할만 인덱싱한다.
6. 주변 health 문서 중 semantics가 아니라 file-location pointer만 stale해지는 항목은 최소 갱신한다. README/MANUAL readability rewrite는 하지 않는다.

### Phase 3 — Review / Closeout Prep

1. 검증 명령을 실행한다.
2. Claude R1 result review를 요청한다.
3. 승인되면 `/work-close`로 Done 처리하고, commit 전 STATUS / Tracking finalization을 별도로 보고한다.

## Done Criteria

- [x] `repo-health.md` section이 `Always-needed / Quick / --full only / --cascade only / Shared reference`로 분류된다.
- [x] Quick/default `/repo-health` path가 slice 파일 없이도 실행 계약과 report format을 이해할 수 있다.
- [x] `--full`과 `--cascade` 상세는 conditional pointer로 접근 가능하다.
- [x] `/repo-health` report-only / STATUS 보호 / mode semantics가 변경되지 않는다.
- [x] 새 slice 파일이 생기면 `skills/workflow/README.md` index가 갱신된다.
- [x] health 관련 주변 문서의 `repo-health.md` 단일-file pointer가 stale해지는지 감사하고 필요한 최소 갱신 여부를 기록한다.
- [x] scaffold glob 복사 효과가 확인되고, source repo / scaffold target 경계가 흐려지지 않는다.
- [x] R0 승인 전 구현 변경이 없다.
- [x] Claude R0/R1 review와 Codex disposition이 누적된다.

## Verification

Planned commands:

```bash
wc -l skills/workflow/repo-health.md skills/workflow/repo-health-full.md skills/workflow/repo-health-cascade.md 2>/dev/null || true
rg -n "repo-health-full|repo-health-cascade|--full|--cascade|Quick|report-only|STATUS 보호|Required Surface Matrix|Required Grep Pack|Required Simulation Matrix" skills/workflow .agents/skills/workflow-repo-health/SKILL.md .claude/commands/repo-health.md docs/HARNESS-QUICK-REFERENCE.md scripts/create-harness.sh
rg -n "repo-health|Required Surface Matrix|Required Grep Pack|Required Simulation Matrix|Workflow Context Weight" README.md docs/HARNESS-QUICK-REFERENCE.md docs/WORKFLOW-MANUAL.md docs/maintainer/HARNESS-TEST-TAXONOMY.md docs/maintainer/VERIFICATION-COMMANDS.md skills/workflow/README.md .cursor/rules/workflow.mdc
git diff --check
bash scripts/tests/run-harness-checks.sh --tier0
```

Hand-trace:

- Quick path: `repo-health.md`만 읽고 Quick mode의 required input, output contract, A/B/E inspection 방향을 이해할 수 있으면 PASS.
- Full path: `repo-health.md`에서 `repo-health-full.md`로 조건부 이동해 C/D/F/H 상세를 찾을 수 있으면 PASS.
- Cascade path: 변경 파일 기준으로 `repo-health-cascade.md`를 조건부 로드해 surface matrix, grep pack, simulation matrix를 찾을 수 있으면 PASS.
- Scaffold path: fresh scaffold에 새 slice 파일이 포함되더라도 adapter/command가 새 command로 오해되지 않으면 PASS.

## Risk / Reversal Cost

| Item | Assessment |
| --- | --- |
| Risk level | L2 — canonical workflow surface |
| Reversal cost | Low to Medium. 문서 이동 중심이지만 canonical procedure라 lookup path가 깨지면 productivity regression |
| Main risk | Quick path가 너무 얇아져 `/repo-health` 실행자가 필요한 report contract를 놓치는 것 |
| Secondary risk | 새 slice 파일이 scaffold에 포함되며 downstream file count가 늘어나는 것 |
| Control | R0 review 전 구현 금지, section-level classification, mode hand-trace, tier0 validation |

## Open Questions

| ID | Question | Default Assumption |
| --- | --- | --- |
| OQ-1 | slice 파일은 2개(`full`, `cascade`)가 적절한가? | Yes. mode별 조건부 로드와 가장 직접 대응 |
| OQ-2 | Area H `Workflow Context Weight`는 어디에 두는가? | Main 유지. 21줄 공유 섹션이라 cross-pointer 누락 위험보다 main 잔류 비용이 낮음 |
| OQ-3 | `repo-health.md`를 200줄 이하로 줄이는 목표가 의미 보존보다 우선인가? | No. 의미 보존 우선. 200줄 이하가 위험하면 R1에서 residual로 보고 |
| OQ-4 | 새 slice 파일이 scaffold에 포함되는 것이 문제인가? | 기본값은 No. `skills/workflow/*.md` canonical source가 glob 복사되므로 adopter도 조건부 detail을 볼 수 있어야 함 |
| OQ-5 | DR-worthy 결정인가? | 기본값은 No. command semantics 변경 없이 canonical 파일 분리만 수행 |

## Approval / State

| Item | Status |
| --- | --- |
| 위험도 | L2 |
| 실행 모드 | Standard Work |
| Branch Isolation | PASS — `feature/chore-20260613-004-repo-health-slice` |
| Tool rule reference | `.claude/rules/docs-workflow.md` 적용. DR-007 확인 필요 |
| PLAN 영향 | 없음. W3 backlog slice 실행이며 roadmap 방향 변경 아님 |
| STATUS proposal | R0 합의 전 `docs/STATUS.md` 변경 없음 |
| State machine | DONE. R1 승인 후 Work Done 처리 완료 |

## Cross-Agent Review And Discussion

### Round Log Structure

| Round | Reviewer | Type | Findings | Codex Disposition | Status |
| --- | --- | --- | --- | --- | --- |
| R0 | Claude | Plan Review | Conditional Hold. F1 hard: Phase 2 전 Area H disposition 명시. F2 nice-to-have: cascade content 이동 시 N/A handling 문구 동반 이동 확인. User concern: health 관련 주변 문서 영향도 검토 필요. R0 재확인: Area H main 유지로 F1 해소, 주변 audit 추가 적절, Phase 2 승인 | 반영. Area H를 main 유지로 확정. 주변 문서 audit에서 adapter 구조 변경은 Non-goal/follow-up으로 분리하고, file-location pointer만 이 Work에서 최소 갱신하도록 방침 추가 | Approved |
| R1 | Claude | Result Review | Approved. F1 nice-to-have: Report Format explicit template이 behavioral bullets로 축소되어 운영상 format drift가 생기면 Area Summary table template 복원 후속 조치 권장 | 반영. 이번 Work는 승인 상태로 close. Report Format template 복원은 운용상 문제가 관찰될 때 후속 후보로 처리 | Approved |

### Claude R0 Review Request

Claude R0 plan review 요청: CHORE-20260613-004 Repo-Health Canonical Slice Split

Review focus:

1. 이 Work가 `repo-health.md` slice split만 다루도록 충분히 좁은가?
2. `repo-health-full.md` / `repo-health-cascade.md` 2파일 split이 적절한가, 아니면 1파일 또는 3파일이 더 안전한가?
3. Quick/default path가 너무 얇아져 `/repo-health` 실행 계약을 잃을 위험은 무엇인가?
4. 새 slice 파일이 `scripts/create-harness.sh` glob 복사로 scaffold에 포함되는 것이 source/scaffold boundary와 충돌하지 않는가?
5. Verification과 hand-trace가 mode별 lookup 보존을 검증하기에 충분한가?

## Discovery

- 2026-06-13: CHORE-20260613-003 PR #167 merge 완료 후 `develop...origin/develop` clean 확인. 다음 W3 후보 중 `repo-health.md` slice split을 CHORE-20260613-004로 선택했다.
- 2026-06-13: `skills/workflow/repo-health.md`는 436줄. `scripts/create-harness.sh`는 `skills/workflow/*.md`를 glob 복사하므로, 새 slice 파일은 scaffold에도 포함된다.
- 2026-06-13: Claude R0 Conditional Hold 반영. Area H는 main 유지로 기본 disposition을 확정했다. `--full`/`--cascade` 양쪽에서 쓰이는 21줄 공유 섹션이라 별도 slice 이동 시 cross-pointer 누락 위험이 더 크다.
- 2026-06-13: 사용자 의견 반영. `/repo-health` 관련 주변 문서도 영향도 검토 대상에 포함한다. 단, README/MANUAL readability rewrite가 아니라 stale pointer 여부와 health verification catalog 정합만 본다.
- 2026-06-13: Claude R0 재확인 Approved. 조건: Phase 1 결과표에 Area H main 유지 명시, 주변 audit에서 fix 범위를 main pointer vs adapter 구조 follow-up으로 구분. 두 조건 모두 Work 파일에 반영 후 Phase 2 착수.
- 2026-06-13: Phase 2 구현. `repo-health.md` main은 195줄로 축소하고 Quick/default 계약, Output Contract, A/B/E, Area H를 유지했다. `repo-health-full.md`에는 `--full` 전용 Phase 4-5와 Areas C/D/F를 이동했고, `repo-health-cascade.md`에는 Phase 6, Required Surface/Grep/Simulation Matrix, Area G를 이동했다.
- 2026-06-13: 주변 health 문서 최소 갱신. `skills/workflow/README.md` Supporting Slices 추가, `HARNESS-TEST-TAXONOMY.md`와 `VERIFICATION-COMMANDS.md`의 Required Surface Matrix pointer를 cascade slice 기준으로 갱신. README/WORKFLOW-MANUAL/HARNESS-QUICK-REFERENCE/adapters는 semantics와 entrypoint가 유지되어 No action.
- 2026-06-13: Claude R1 Approved. F1 nice-to-have로 Report Format explicit template 축소에 따른 format drift 가능성을 기록했다. 현재는 승인 상태이며, 운영상 문제가 생기면 Area Summary table template 복원을 후속 후보로 다룬다.
- 2026-06-13: `/work-close` 처리. Done Criteria 전부 충족, status Done, actual_end 기입. backlog candidate `skills/workflow/repo-health.md slice 분리`는 완료되어 `docs/backlog/HARNESS.md` Summary/Details에서 제거.

## Phase 1 Audit Results

### R0 Disposition

| Finding | Codex Disposition |
| --- | --- |
| F1 Hard: Area H disposition 명시 필요 | 반영. Area H는 main `repo-health.md`에 유지한다. `--full` 상시 활성화와 `--cascade` 조건부 활성화가 겹치는 공유 섹션이므로 slice 이동보다 main 유지가 안전하다 |
| F2 Nice-to-have: N/A handling 문구 동반 이동 확인 | 반영 예정. cascade slice 생성 시 Optional pack / source-only / script absence N/A 문구가 matrix·grep과 함께 이동하는지 확인한다 |
| User concern: health 관련 다양한 문서 영향도 검토 필요 | 반영. live surface 중심 영향도 audit을 Phase 1/Verification에 추가한다 |

### Section Classification

| Section | Classification | Keep in main? | Planned disposition |
| --- | --- | --- | --- |
| Header / adapter table / Procedure | Always-needed | Yes | main 유지 |
| Execution Principles | Always-needed | Yes | report-only, STATUS 보호, context 절약 원칙 유지 |
| Mode Contract | Always-needed | Yes | main 유지 |
| Output Contract | Always-needed | Yes | main 유지 |
| File Reading Order Phase 1-3 | Quick / Shared | Yes | main 유지 |
| File Reading Order Phase 4-5 | `--full only` | No | `repo-health-full.md` 후보 |
| File Reading Order Phase 6 | `--cascade only` | No | `repo-health-cascade.md` 후보 |
| Required Surface Matrix | `--cascade only` | No | `repo-health-cascade.md` 후보 |
| Required Grep Pack | `--cascade only` | No | `repo-health-cascade.md` 후보. Optional/source-only N/A 문구 동반 이동 필요 |
| Required Simulation Matrix | `--cascade only` | No | `repo-health-cascade.md` 후보 |
| Inspection Areas A/B | Quick | Yes | main 유지 |
| Inspection Area E | Quick | Yes | main 유지 |
| Inspection Areas C/D/F | `--full only` | No | `repo-health-full.md` 후보 |
| Inspection Area G | `--cascade only` | No | `repo-health-cascade.md` 후보 |
| Inspection Area H | Shared reference (`--full` + conditional `--cascade`) | Yes | main 유지. cross-pointer 없는 안전한 default |
| Report Format | Always-needed | Yes | main 유지 |

### Health Surface Impact Audit

| Surface | Current role | Impact disposition |
| --- | --- | --- |
| `skills/workflow/README.md` | command canonical index | 새 slice 파일 추가 시 Supporting Slices index 필요 |
| `.claude/commands/repo-health.md`, `.agents/skills/workflow-repo-health/SKILL.md` | adapter가 main canonical을 로드 | main에서 conditional pointer를 제공하면 adapter 변경 불필요 예상 |
| `.cursor/rules/workflow.mdc` | Repository health / cascade audit → `repo-health.md` pointer | main이 entrypoint로 남으므로 변경 불필요 예상 |
| `docs/HARNESS-QUICK-REFERENCE.md` | `/repo-health --cascade`, `--full`, Area H 설명 | semantics 유지 시 변경 불필요 예상. pointer 명시가 필요해지면 최소 갱신 |
| `docs/WORKFLOW-MANUAL.md` | user-facing `/repo-health` summary/cadence | semantics 유지 시 변경 불필요. readability rewrite 금지 |
| `README.md` | `/repo-health` 한 줄 command map | 변경 불필요 예상 |
| `docs/maintainer/HARNESS-TEST-TAXONOMY.md` | `repo-health.md`가 Required Surface Matrix를 가진다고 설명 | Matrix가 cascade slice로 이동하면 pointer 갱신 필요 가능성 높음 |
| `docs/maintainer/VERIFICATION-COMMANDS.md` | J10/M4가 `repo-health.md` 참조 실재와 Required Matrix pointer를 검증 | slice 파일 추가 후 grep 대상 또는 pointer 설명 갱신 필요 가능성 높음 |
| `scripts/create-harness.sh` | `skills/workflow/*.md` glob 복사 | 동작 변경 없음. 새 slice가 scaffold에 포함되는 것을 expected로 기록 |

### Phase 2 Result

| File | Change | Boundary Check |
| --- | --- | --- |
| `skills/workflow/repo-health.md` | Quick/default main canonical을 195줄로 축소. mode-specific slice pointer 추가. A/B/E, Area H, Output Contract 유지 | report-only, STATUS 보호, mode semantics 유지 |
| `skills/workflow/repo-health-full.md` | `--full` 전용 File Reading Order Phase 4-5와 Inspection Areas C/D/F 이동 | full mode에서만 조건부 로드 |
| `skills/workflow/repo-health-cascade.md` | `--cascade` 전용 Phase 6, Required Surface Matrix, Required Grep Pack, Required Simulation Matrix, Area G 이동 | Optional/source-only/scaffold N/A 문구 동반 이동 |
| `skills/workflow/README.md` | Supporting Slices index 추가 | 새 command처럼 보이지 않도록 Loaded By/Role만 명시 |
| `docs/maintainer/HARNESS-TEST-TAXONOMY.md` | repo-health Required Surface Matrix 위치를 cascade slice로 최소 갱신 | source-only maintainer pointer 정합 |
| `docs/maintainer/VERIFICATION-COMMANDS.md` | J10/M4/Q-static/M5 pointer를 cascade slice 포함 구조로 갱신 | health catalog 자체검증 stale 방지 |

### Validation Results

| Check | Result | Notes |
| --- | --- | --- |
| `wc -l skills/workflow/repo-health*.md` | PASS | main 195줄, full slice 77줄, cascade slice 154줄 |
| planned slice/pointer `rg` | PASS | main conditional pointer, slice headings, Area H main 유지 확인 |
| surrounding health docs `rg` | PASS | adapter 구조 변경 필요 없음. taxonomy/catalog pointer만 최소 갱신 |
| `git diff --check` | PASS | whitespace error 없음 |
| `bash scripts/tests/run-harness-checks.sh --tier0` | PASS | syntax/무결성 PASS |
| scaffold dry-run | PASS | `repo-health-full.md`, `repo-health-cascade.md`가 `skills/workflow/*.md` glob으로 포함됨 |
| Quick path hand-trace | PASS | `repo-health.md`만으로 Quick mode input, Output Contract, A/B/E, Area H activation rule 확인 가능 |
| Full path hand-trace | PASS | `repo-health.md` → `repo-health-full.md` 조건부 pointer로 C/D/F 상세 접근 가능 |
| Cascade path hand-trace | PASS | `repo-health.md` → `repo-health-cascade.md` 조건부 pointer로 Matrix/Grep/Simulation/Area G 접근 가능 |
| Scaffold path hand-trace | PASS | 새 slices가 scaffold에 포함되지만 adapters는 main entrypoint만 가리켜 새 command로 오해되지 않음 |

### Claude R1 Review Request

Claude R1 result review 요청: CHORE-20260613-004 Repo-Health Canonical Slice Split

Review focus:

1. `repo-health.md` main이 Quick/default path를 self-contained로 유지하면서 195줄로 줄었는가?
2. `repo-health-full.md`와 `repo-health-cascade.md` split이 mode별 조건부 로드와 잘 맞고 cross-dependency가 없는가?
3. Area H가 main에 남아 `--full`/context-related `--cascade`에서 누락되지 않는가?
4. 주변 health 문서 영향도 처리가 충분한가? adapter 구조 변경 없이 taxonomy/catalog pointer만 최소 갱신한 판단이 맞는가?
5. scaffold glob 포함, N/A handling 문구 이동, validation 결과가 R1 승인에 충분한가?
