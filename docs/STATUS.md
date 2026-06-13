# STATUS.md

AI Workflow Harness repository의 현재 프로젝트 상태 문서다.
이 파일은 dashboard로 유지하고, 작업별 세부 계획과 기록은 `docs/works/`에 둔다.

Last updated: 2026-06-13 (세션: CHORE-20260613-011 F2 wiring decision Done)

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
| 2026-06-13 | CHORE-20260613-011 / DR-036: Runner / CI / F2 wiring을 **무배선**으로 종결 — `run-harness-checks.sh`를 CI required check·pre-commit gate에 배선하지 않고 manual-only 유지. runner 검사는 이미 `ci.yml`·`pre-commit`에서 강제되고 tier2는 과중, 고유가치(invariants SSoT 호출)는 F4 repo-health surface 대상. **DR-035 follow-up split(3종) 전체 완료** | runner 배선이 enforcement 공백을 메우지 않고 중복만 만들며, 2026-06-08부터 3회 deferral된 F2를 재론 없이 닫기 위해. CI↔invariants SSoT parity residual은 별도 candidate로 분리. Claude self red-team R0 | Low |
| 2026-06-13 | CHORE-20260613-010: project-protected extension classification 완료 — `.harness/gate-config`에 `[tracking-state]` section을 신설해 custom protected path를 P2-T1(develop warning)으로 선언하는 최소 mechanism 구현. `awh_is_branch_isolation_tracking_path()` custom fallthrough와 protected union 확장, `create-harness.sh` seed / source rule / doc cascade 정렬 | DR-035에서 고정한 P1/P2 class를 runtime에 반영하고, adopter target repo가 project-specific tracking-state path를 T1 warning 예외로 선언할 수 있는 최소 add-only 메커니즘을 제공하기 위해. Claude R0/R1 승인 | Medium |
| 2026-06-13 | CHORE-20260613-007 / DR-035: protected workflow enforcement exception classes를 `I0/T1/S1/P1/P2`로 고정. Quick Mode/product L1은 독립 예외 클래스가 아니며, DR-025 finalization trailer는 branch isolation에서 재사용하지 않음 | `문서-only 규칙 강제화`를 broad implementation으로 열기 전에, 상태 파일 / 구조 파일 / project extension / override boundary를 선행 결정으로 고정해 후속 slice를 runtime hardening / custom classification / F2 wiring으로 분해하기 위해. Claude R0/R1 승인 | Medium |
| 2026-06-13 | CHORE-20260613-008: framework default branch-isolation hardening 완료 — `tools/git-hooks/pre-commit`이 `develop`에서 `T1 tracking-state-only` staged set만 warning 예외로 허용하고, `S1 structural-policy` 또는 mixed staged set은 hard-stop하도록 정렬. `gate-lists.sh` helper 추가, `.claude/rules/git-workflow.md` / `docs/GIT-WORKFLOW.md` class-sensitive 설명 동기화 | DR-035에서 고정한 `I0/T1/S1` class split을 runtime과 rule/doc cascade에 반영해, local signal과 policy 서술의 불일치를 해소하기 위해. Claude R0/R1 승인 | Medium |
| 2026-06-13 | CHORE-20260613-006: trigger family simplification 완료. trigger family를 `/work-select`, `/work-plan`, `/work-close`, `/session-summary` 중심으로 정리하고 STATUS/Next Actions 정합까지 마쳐 **W3 Workflow IA Diet**를 종료 | 구조 변경을 더 벌리지 않고도 workflow 진입면과 종료면의 naming/load 흐름을 단순화하고, W3를 decision/minimal realignment 범위 안에서 깔끔하게 닫기 위해 | Low |
| 2026-06-12 | CHORE-20260612-001: source-only maintainer 문서 `docs/maintainer/PRODUCT-STARTER-PLANNING-PACK.md`를 신설해 product starter planning pack의 seed/template 경계, source-owned vs product-owned vs import-candidate 분류, source→product→source provisional loop, generic template 분석 기준을 정리. `VERIFICATION-COMMANDS.md` Layer U의 U2~U4는 executable 승격 없이 structured checklist/review aid로 구체화 | 다음 product 착수 전에 source repo가 먼저 제공할 planning skeleton과 product-local concreteization 경계를 명확히 하고, 실사례 없는 import loop를 과장 없이 provisional skeleton로 남기기 위해. CHORE-20260611-007/009/010/011 후속 구조 공백 해소 — Claude R0~R1a 합의 | Medium |
| 2026-06-12 | CHORE-20260611-011: Docs cascade 현행화 완료 — README Documentation Map/Repository Layout에 source-only maintainer map을 반영하고, `docs/backlog/PRODUCT.md` dangling을 제거. maintainer README의 migration 인덱스는 SSoT 복제를 피하고 `docs/maintainer/migrations/README.md` pointer로만 유지. readability/tone rewrite는 별도 backlog candidate로 분리 | CHORE-20260611-009/010 이후 reader entrypoint가 실제 구조보다 뒤처지던 cascade debt를 객관적 map/link/pointer 정리로 해소. user-facing tone rewrite와 source-only maintainer depth를 섞지 않기 위해 scope를 분리 — Claude R0a~R1a 합의 | Low |
| 2026-06-11 | CHORE-20260611-010: pre-manifest adopter upgrade/migration mechanism 정립 — ai-deck-compiler가 manifest 없는 pre-manifest target임을 실측하고, Draft DR-034로 inventory-first + shadow scaffold manifest baseline + project-owned 보존 정책을 기록. manifest-check-baseline.md per-change note 신설, SOURCE-REPO-OPERATIONS.md adopter migration entry 추가, VERIFICATION-COMMANDS.md Layer T를 실행형 검증으로 승격. R1a 재실측에서 첫 drift 분포 76 tracked, 9 in-sync, 67 drifted 확인 후 selective 수렴 경로 기록 | W2 Adopter Transition 첫 gap인 upgrade/migration 경로 부재 해소. `--existing`은 upgrade가 아니며, pre-manifest target은 manifest 심기 전 `--check`가 무력하다는 실측 기반 정책 필요 — Claude R0~R1a 합의 | Medium |

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
   - ✓ **DR-035 follow-up split 전체 완료** — CHORE-20260613-008(framework default) / -010(P1/P2 classification) / -011(F2 wiring, 무배선·DR-036) 종결
   - 잔여: `Validation Spine residual`의 F1/F3/F4 (F2는 DR-036으로 종결), 신규 `CI inline assertion ↔ invariants SSoT parity` candidate, Archive 누적 관리 정책
   - Spring Boot MSA TDD option-pack, template pack, CLI naming, Windows, `/exit` gap은 실제 product 운용 후 필요성 재판단
