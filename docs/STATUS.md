# STATUS.md

AI Workflow Harness repository의 현재 프로젝트 상태 문서다.
이 파일은 dashboard로 유지하고, 작업별 세부 계획과 기록은 `docs/works/`에 둔다.

Last updated: 2026-06-15 (release-prep 1.2.1 patch + CHORE-20260615-002 archive)

## Current State

| Field | Value |
| --- | --- |
| Current phase | AWH-004 — Maintenance & Adoption |
| Current focus | 1.2.1 patch 릴리즈, adopter upgrade/migration, onboarding 현행화 |
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
| 2026-06-15 | CHORE-20260615-002 / DR-007 amend: 언어 정책을 DR-007 단일 authoritative SSoT로 통합 — Non-File Surfaces(commit/PR/agent console behavioral)+Default·Override 흡수, 산재 정의 정리(MAINTAINER-GUIDE=pure pointer, WORKFLOW-MANUAL Appendix C=최소 digest, GIT-WORKFLOW §5/rules=directive+pointer), AGENTS.md commit/PR/console inline(Codex 도달 fix), BEHAVIOR §5 console convention, README adopter note. DR-030은 전략-only로 경계 정리(Draft). Cross-agent(A=Claude/B=Codex) R1~R3: B P1(단일 override 모순)·P2(DR-030 내부 모순) 수용→DR-007 "authoritative SSoT+mirror 목록 규정"으로 재구성. 릴리즈=독립 PATCH(정합성 복구). 사용자 최종 승인 | Medium |
| 2026-06-14 | CHORE-20260614-001: post-release 결과 검증 최소 보완 — release "절차 수행"이 아니라 "결과 정합"을 잡는 1줄씩을 기존 절차에 흡수. sync 검증(`develop..main` empty)은 generic이라 루트 `GIT-WORKFLOW.md` §3-4 + scaffold 템플릿 §3-4 양쪽에 범용문, tag 정합(`ai-workflow-v{VERSION}`)은 source-only라 `VERSIONING.md` §3 step5에만. 독립 절차 블록 신설은 과잉으로 기각(§3-4/§2-5/VERSIONING 중복). release-prep §3-0 템플릿 반영도 leak-safe 재확인. Claude red-team(plan+result)+사용자 승인 | Low |
| 2026-06-13 | CHORE-20260613-020: W1~W5 완료 후 전체 정렬 검토 — `HARNESS-MAINTAINER-GUIDE.md` §5 Validation에 validation spine runner row, §9에 version-release sweep pointer(§3-1/Release Full Sweep/VERSIONING) 추가, `VERIFICATION-COMMANDS.md` scripts/tests cascade note를 3→6 스크립트로 현행화. 산출물 역추적 매트릭스(검증스크립트 6×3 문서, DR 30/30, command 등재) 검증 — gap은 MAINTAINER-GUIDE에 집중, README 2건(PLAN-SUMMARY/SCAFFOLD-BOOTSTRAP)은 의도된 제외/무관으로 비범위. **CHORE-20260613-017/018/019 archive 처리 동반.** Claude red-team(plan+result)+사용자 승인 | Low |
| 2026-06-13 | CHORE-20260613-019: release 검증 두 체계 연결 — 루트 `GIT-WORKFLOW.md` §3-1 Public Clean Baseline Gate에 `Validation spine`(`run-harness-checks.sh --all`)·`Surface sweep`(Release Full Sweep P0/P1=0) evidence row 추가 + §3-1↔Release Full Sweep 상호 pointer. scaffold 템플릿은 의도적 분리 유지(adopter §3-1 미변경), CI/pre-commit 무배선(DR-036). Claude self red-team(plan+result) + 사용자 승인 | Low |
| 2026-06-13 | CHORE-20260613-018: `Validation Spine residual F3+F4` 종결 — F3은 mirror parity(canonical↔claude↔agents 3자)+session-start prompt 3종 존재를 `check-surface-mirror-parity.sh`로 Tier 1 승격(runner `--tier0c`, adopter-safe skip), language policy는 정당한 영어 rule 다수(실측 15건)로 deterministic 승격 시 false-positive→**보류**. F4는 Layer K+`repo-health.md`에 runner tier 호출/해석 경계 최소 명시(Quick=tier0/tier1 생성 없음). **`Validation Spine residual (F1-F4)` backlog 항목 전체 종결.** mirror parity는 hard gate가 아닌 수동/repo-health 시점 회귀 탐지 자산(DR-036 무배선 기조). Claude self red-team(plan+result) + 사용자 승인 | Low |
| 2026-06-13 | CHORE-20260613-017: `Validation Spine residual F1` — Layer J-OB(OB0/OB1/OB3/OB4/OB5) + Layer Q core를 `check-onboarding-flows.sh`로 deterministic 승격, Layer J는 human-run catalog 유지, J~S `/tmp/awh-*`→`temp/harness-tests/` 정렬 완료. backlog F1 ✅종결, F3/F4만 잔존. Claude R0/R1 승인 | Low |
| 2026-06-13 | CHORE-20260613-016: `CI inline assertion ↔ invariants SSoT parity`를 **no-action with explicit rationale**로 종결하고 archive 처리 | Phase 1 분류 결과 CI inline assertions와 `check-scaffold-invariants.sh`는 "같은 검사의 중복 구현"보다 "같은 scaffold surface를 다른 altitude에서 본다"에 가깝고, 실제 overlap이 작아 parity helper/partial convergence가 boundary를 흐릴 가능성이 더 컸기 때문. invariant-only [1]/[3]/[4]는 maintainer-facing structural correctness라 CI required gate 대상이 아님. Claude R0/R1 승인 | Low |
| 2026-06-13 | CHORE-20260613-015: default template canonical parity guard를 `scripts/tests/check-default-template-parity.sh` + `run-harness-checks.sh --tier0`로 추가하고, related archive pending Work `CHORE-20260613-014`와 함께 archive 처리 | default tracked template pair(`workflow.mdc`, `git-workflow.md`)가 canonical 변경 후 조용히 stale해지는 drift를 source-level deterministic check로 즉시 드러내고, live Work queue를 archive-side index 기준으로 정리하기 위해. Claude R0/R1 review 승인 | Low |

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
   - Spring Boot MSA TDD option-pack, template pack, CLI naming, Windows은 실제 product 운용 후 필요성 재판단 (HRN-016 `/exit` gap은 2026-06-14 drop — action 없는 외부 감시, Stop hook이 이미 커버)
