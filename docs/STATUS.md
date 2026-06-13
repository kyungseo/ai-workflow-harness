# STATUS.md

AI Workflow Harness repository의 현재 프로젝트 상태 문서다.
이 파일은 dashboard로 유지하고, 작업별 세부 계획과 기록은 `docs/works/`에 둔다.

Last updated: 2026-06-13 (세션: CHORE-20260613-020 정렬 검토 Done + 017/018/019 archive)

## Current State

| Field | Value |
| --- | --- |
| Current phase | AWH-004 — Maintenance & Adoption |
| Current focus | 1.1.0 릴리즈, adopter upgrade/migration, onboarding 현행화 |
| Project plan | `docs/PLAN.md` |
| Harness backlog | `docs/backlog/HARNESS.md` |
| Quick reference | `docs/HARNESS-QUICK-REFERENCE.md` |
| Harness protocol | `docs/HARNESS-PROTOCOL.md` |
| Repository visibility | Public release ready |

## Work Context Rule

이 파일은 현재 작업 상태의 dashboard다.
세션 시작 시에는 `Current State`, `Active Work`, `Blockers And Open Questions`, `Next Actions`만 확인한다.
상세 실행 흐름은 `docs/AGENT-WORKFLOW.md`를 따른다.

## Active Work

| ID | Title | Work File |
| --- | --- | --- |

## Blockers And Open Questions

| ID | Status | Question | Decision Needed |
| --- | --- | --- | --- |

## Recent Decisions

| Date | Decision | Reason | Reversal Cost |
| --- | --- | --- | --- |
| 2026-06-13 | CHORE-20260613-020: W1~W5 완료 후 전체 정렬 검토 — `HARNESS-MAINTAINER-GUIDE.md` §5 Validation에 validation spine runner row, §9에 version-release sweep pointer(§3-1/Release Full Sweep/VERSIONING) 추가, `VERIFICATION-COMMANDS.md` scripts/tests cascade note를 3→6 스크립트로 현행화. 산출물 역추적 매트릭스(검증스크립트 6×3 문서, DR 30/30, command 등재) 검증 — gap은 MAINTAINER-GUIDE에 집중, README 2건(PLAN-SUMMARY/SCAFFOLD-BOOTSTRAP)은 의도된 제외/무관으로 비범위. **CHORE-20260613-017/018/019 archive 처리 동반.** Claude red-team(plan+result)+사용자 승인 | Low |
| 2026-06-13 | CHORE-20260613-019: release 검증 두 체계 연결 — 루트 `GIT-WORKFLOW.md` §3-1 Public Clean Baseline Gate에 `Validation spine`(`run-harness-checks.sh --all`)·`Surface sweep`(Release Full Sweep P0/P1=0) evidence row 추가 + §3-1↔Release Full Sweep 상호 pointer. scaffold 템플릿은 의도적 분리 유지(adopter §3-1 미변경), CI/pre-commit 무배선(DR-036). Claude self red-team(plan+result) + 사용자 승인 | Low |
| 2026-06-13 | CHORE-20260613-018: `Validation Spine residual F3+F4` 종결 — F3은 mirror parity(canonical↔claude↔agents 3자)+session-start prompt 3종 존재를 `check-surface-mirror-parity.sh`로 Tier 1 승격(runner `--tier0c`, adopter-safe skip), language policy는 정당한 영어 rule 다수(실측 15건)로 deterministic 승격 시 false-positive→**보류**. F4는 Layer K+`repo-health.md`에 runner tier 호출/해석 경계 최소 명시(Quick=tier0/tier1 생성 없음). **`Validation Spine residual (F1-F4)` backlog 항목 전체 종결.** mirror parity는 hard gate가 아닌 수동/repo-health 시점 회귀 탐지 자산(DR-036 무배선 기조). Claude self red-team(plan+result) + 사용자 승인 | Low |
| 2026-06-13 | CHORE-20260613-017: `Validation Spine residual F1` — Layer J-OB(OB0/OB1/OB3/OB4/OB5) + Layer Q core를 `check-onboarding-flows.sh`로 deterministic 승격, Layer J는 human-run catalog 유지, J~S `/tmp/awh-*`→`temp/harness-tests/` 정렬 완료. backlog F1 ✅종결, F3/F4만 잔존. Claude R0/R1 승인 | Low |
| 2026-06-13 | CHORE-20260613-016: `CI inline assertion ↔ invariants SSoT parity`를 **no-action with explicit rationale**로 종결하고 archive 처리 | Phase 1 분류 결과 CI inline assertions와 `check-scaffold-invariants.sh`는 "같은 검사의 중복 구현"보다 "같은 scaffold surface를 다른 altitude에서 본다"에 가깝고, 실제 overlap이 작아 parity helper/partial convergence가 boundary를 흐릴 가능성이 더 컸기 때문. invariant-only [1]/[3]/[4]는 maintainer-facing structural correctness라 CI required gate 대상이 아님. Claude R0/R1 승인 | Low |
| 2026-06-13 | CHORE-20260613-015: default template canonical parity guard를 `scripts/tests/check-default-template-parity.sh` + `run-harness-checks.sh --tier0`로 추가하고, related archive pending Work `CHORE-20260613-014`와 함께 archive 처리 | default tracked template pair(`workflow.mdc`, `git-workflow.md`)가 canonical 변경 후 조용히 stale해지는 drift를 source-level deterministic check로 즉시 드러내고, live Work queue를 archive-side index 기준으로 정리하기 위해. Claude R0/R1 review 승인 | Low |
| 2026-06-13 | CHORE-20260613-013 / DR-038: Archive 누적 관리 정책 종결 — 누적 cost≈0(archive 미로드) 정량 확인, 유일 실비용인 live README hot-path 인덱스(106행)를 archive-side mirrored README로 이전. retention=keep-all(prune/rollup/미이동 기각), 전 category 일관, works/harness outlier를 decisions/retro 기존 패턴에 정합. cascade(DR-016/013 amend, HARNESS-PROTOCOL, work-close/plan, repo-health, scaffold) 정렬 | live working 파일에 무한 증가 archived 인덱스를 두는 구조 모순 해소 + backlog 항목·AWH-OQ-001 종결. tier2 검증 중 pre-existing scaffold cursor manifest-src 버그를 발견·등록. Claude self red-team R0/result review | Medium |
| 2026-06-13 | CHORE-20260613-012 / DR-037: broad 테마 `문서-only 규칙 강제화`를 종결 — doc-only 규칙 전반 enforcement landscape를 기록하고, (위반-피해 + 기계강제 가능 + gate 부재) 동시 만족은 branch-isolation 유일=강제화 완료, 나머지는 기존강제 또는 behavioral(hard-gate 부적합)로 판정. parent backlog 제거 + dangling 3건 repoint | criterion #1("강제화 후보 규칙 목록 + 수단 매핑")을 실제 산출물 없이 체크하는 것을 막고, "다른 규칙도 hard-gate하자" 재론을 차단하기 위해. Claude self red-team R0 | Low |
| 2026-06-13 | CHORE-20260613-011 / DR-036: Runner / CI / F2 wiring을 **무배선**으로 종결 — `run-harness-checks.sh`를 CI required check·pre-commit gate에 배선하지 않고 manual-only 유지. runner 검사는 이미 `ci.yml`·`pre-commit`에서 강제되고 tier2는 과중, 고유가치(invariants SSoT 호출)는 F4 repo-health surface 대상. **DR-035 follow-up split(3종) 전체 완료** | runner 배선이 enforcement 공백을 메우지 않고 중복만 만들며, 2026-06-08부터 3회 deferral된 F2를 재론 없이 닫기 위해. CI↔invariants SSoT parity residual은 별도 candidate로 분리. Claude self red-team R0 | Low |
| 2026-06-13 | CHORE-20260613-010: project-protected extension classification 완료 — `.harness/gate-config`에 `[tracking-state]` section을 신설해 custom protected path를 P2-T1(develop warning)으로 선언하는 최소 mechanism 구현. `awh_is_branch_isolation_tracking_path()` custom fallthrough와 protected union 확장, `create-harness.sh` seed / source rule / doc cascade 정렬 | DR-035에서 고정한 P1/P2 class를 runtime에 반영하고, adopter target repo가 project-specific tracking-state path를 T1 warning 예외로 선언할 수 있는 최소 add-only 메커니즘을 제공하기 위해. Claude R0/R1 승인 | Medium |
| 2026-06-13 | CHORE-20260613-007 / DR-035: protected workflow enforcement exception classes를 `I0/T1/S1/P1/P2`로 고정. Quick Mode/product L1은 독립 예외 클래스가 아니며, DR-025 finalization trailer는 branch isolation에서 재사용하지 않음 | `문서-only 규칙 강제화`를 broad implementation으로 열기 전에, 상태 파일 / 구조 파일 / project extension / override boundary를 선행 결정으로 고정해 후속 slice를 runtime hardening / custom classification / F2 wiring으로 분해하기 위해. Claude R0/R1 승인 | Medium |
| 2026-06-13 | CHORE-20260613-008: framework default branch-isolation hardening 완료 — `tools/git-hooks/pre-commit`이 `develop`에서 `T1 tracking-state-only` staged set만 warning 예외로 허용하고, `S1 structural-policy` 또는 mixed staged set은 hard-stop하도록 정렬. `gate-lists.sh` helper 추가, `.claude/rules/git-workflow.md` / `docs/GIT-WORKFLOW.md` class-sensitive 설명 동기화 | DR-035에서 고정한 `I0/T1/S1` class split을 runtime과 rule/doc cascade에 반영해, local signal과 policy 서술의 불일치를 해소하기 위해. Claude R0/R1 승인 | Medium |
| 2026-06-13 | CHORE-20260613-006: trigger family simplification 완료. trigger family를 `/work-select`, `/work-plan`, `/work-close`, `/session-summary` 중심으로 정리하고 STATUS/Next Actions 정합까지 마쳐 **W3 Workflow IA Diet**를 종료 | 구조 변경을 더 벌리지 않고도 workflow 진입면과 종료면의 naming/load 흐름을 단순화하고, W3를 decision/minimal realignment 범위 안에서 깔끔하게 닫기 위해 | Low |
| 2026-06-12 | CHORE-20260612-001: source-only maintainer 문서 `docs/maintainer/PRODUCT-STARTER-PLANNING-PACK.md`를 신설해 product starter planning pack의 seed/template 경계, source-owned vs product-owned vs import-candidate 분류, source→product→source provisional loop, generic template 분석 기준을 정리. `VERIFICATION-COMMANDS.md` Layer U의 U2~U4는 executable 승격 없이 structured checklist/review aid로 구체화 | 다음 product 착수 전에 source repo가 먼저 제공할 planning skeleton과 product-local concreteization 경계를 명확히 하고, 실사례 없는 import loop를 과장 없이 provisional skeleton로 남기기 위해. CHORE-20260611-007/009/010/011 후속 구조 공백 해소 — Claude R0~R1a 합의 | Medium |

## Next Actions

> backlog는 확정 실행 계획이 아니라 의견 있는 portfolio view다. 각 항목 착수 시 `/work-plan`에서 논리성·합리성·현재 product 적용 맥락을 다시 검토한다. 별도 Seq 축은 유지하지 않는다(CHORE-20260610-011 (B)).

1. **W1 — Validation Spine** (이번 주 마무리 전 최우선):
   - ✓ **harness workflow 검증 테스트 체계 정립** — CHORE-20260611-005에서 검증 척추 Slice 1 도입 완료(taxonomy + tier runner + temp/ 정책). 후속은 F1~F4 + F5(`Source repo maintainer operations manual`)
   - ✓ **Scaffold/tool-surface regression alignment 체계화** — CHORE-20260611-006에서 leak-scan을 source-gitflow shipped 6파일로 확장 + 검증 척추 흡수 완료. 잔여 deep 통합은 F4(runner→repo-health, CHORE-20260611-008 후속)
   - ✓ **Product pack verification layer 보강** — CHORE-20260611-007에서 `VERIFICATION-COMMANDS.md` Layer U 신설 완료(stack/profile↔core 경계 concrete + planning pack/import criteria). 후속: W2 산출물 확정 시 concrete 승격, executable 승격은 F3
   - ✓ **repo-health gate series 보강** — CHORE-20260611-008에서 gate path-list parity Q-static 신설 + source GIT-WORKFLOW finalization pointer·template add-only 정정 완료. `hook exit(1) enforcement`의 framework default slice는 CHORE-20260613-008에서 완료. 잔여: runner→repo-health deep 통합 F4, project extension classification / F2 wiring follow-up
   - ✓ **Source repo maintainer operations manual** — CHORE-20260611-009에서 `docs/maintainer/SOURCE-REPO-OPERATIONS.md` 신설(변경 lifecycle 순서축 runbook, pointer-only, 배포 surface 0). **W1 Validation Spine 완결.** 잔여 후속은 F1~F4(완료 시 runbook B/C절 update trigger)
2. **W2 — Adopter Transition** (다음 주 실제 product 적용 준비):
   - ✓ **Harness upgrade/migration 메커니즘** — CHORE-20260611-010에서 pre-manifest adopter inventory-first + shadow scaffold manifest baseline + Layer T 실행형 검증 정립 완료. 후속: 실제 target 적용 또는 두 번째 adopter 검증 후 DR-034 Accepted 승격 판단
   - ✓ **Docs cascade 현행화** — CHORE-20260611-011에서 README Documentation Map / maintainer map / onboarding surfaces의 objective cascade 정리 완료. 후속 톤/청중 재작성 작업은 별도 candidate(`User-facing docs readability rewrite`)로 유지
   - ✓ **Product starter planning pack + feedback import loop** — CHORE-20260612-001에서 source-only planning pack seed/template 기준, ownership 분류, provisional import loop, Layer U structured review aid 정리 완료. 후속: 첫 concrete product use 후 U2~U4 재검토 및 import candidate 실사례 평가
   - ✓ **User-facing docs readability rewrite** — CHORE-20260612-002 완료
   - ✓ **Scaffold multi-user clone verification** — CHORE-20260612-003 완료. 발견: G1/G2 Critical gap → "source-gitflow second-contributor entry path 보강" backlog 등록. **W2 Adopter Transition 완결.**
3. **W3 — Workflow IA Diet** (큰 구조 변경은 결정/최소 정리까지만):
   - ✓ **Prompt surface diet** — CHORE-20260612-010 완료
   - ✓ **Protocol Load Map / Context Routing 최소 정합** — CHORE-20260613-002 완료
   - ✓ **Operating Tracks 경계 최소 정합** — CHORE-20260613-003 완료
   - ✓ **repo-health canonical slice 분리** — CHORE-20260613-004 완료
   - ✓ **work-doc.md B-class 분류** — CHORE-20260613-005 완료
   - ✓ **Canonical 개념 계층화** — CHORE-20260613-002~005로 핵심 목표 달성, 별도 Work 없이 종료
   - ✓ **trigger family simplification** — CHORE-20260613-006 완료. **W3 Workflow IA Diet 전부 완결.**
4. **W4/W5 — Lifecycle hygiene 및 optional 확장**:
   - ✓ **`문서-only 규칙 강제화` 테마 종결 (DR-037)** — doc-only enforcement landscape 검토 결과 branch-isolation만 강제화 대상이었고 완료. 나머지는 기존강제 또는 behavioral(hard-gate 부적합)
   - ✓ **DR-035 follow-up split 전체 완료** — CHORE-20260613-008 / -010 / -011(F2 무배선·DR-036)
   - ✓ **Archive 누적 관리 정책 종결 (DR-038)** — archive-side index relocation, retention=keep-all. works/harness 106행 archive-side 이전 + cascade 정렬
   - ✓ **Validation Spine residual 전부 종결** — F1=CHORE-20260613-017, F2=DR-036, F3/F4=CHORE-20260613-018(mirror/prompt parity Tier 1 승격, language policy 보류, repo-health runner-surface). **W4 잔여 concrete 항목 없음.**
   - Spring Boot MSA TDD option-pack, template pack, CLI naming, Windows, `/exit` gap은 실제 product 운용 후 필요성 재판단
