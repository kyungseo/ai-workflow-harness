# STATUS.md

AI Workflow Harness repository의 현재 프로젝트 상태 문서다.
이 파일은 dashboard로 유지하고, 작업별 세부 계획과 기록은 `docs/works/`에 둔다.

Last updated: 2026-06-11 (세션: CHORE-20260611-006 Scaffold/tool-surface regression alignment Done — leak-scan을 source-gitflow shipped 6파일로 확장, invariants/runner 3모드 parity, scripts/tests source-side surface, inject-revert·set -e 버그 수정. Codex R0~R1 합의. Active 없음, archive 대기 2건(CHORE-005·006))

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
| _(none)_ | | |

## Blockers And Open Questions

| ID | Status | Question | Decision Needed |
| --- | --- | --- | --- |

## Recent Decisions

| Date | Decision | Reason | Reversal Cost |
| --- | --- | --- | --- |
| 2026-06-11 | CHORE-20260611-006: scaffold leak-scan을 source-gitflow shipped 표면 6개까지 확장(`leak_scan_files`, `[2]`만 분리). invariants/runner 3모드 parity, `--tier0` test-script syntax, `scripts/tests/**` source-side surface 등록. leak_scan_files set -e 버그 수정 | "PR #93 전수 재검증" 대신 leak-scan coverage gap을 닫아 검증 척추에 흡수. source-only path 누수 미검출 사각지대 제거 — Codex R0~R1 합의 | Low |
| 2026-06-11 | CHORE-20260611-005: harness 검증 척추(Validation Spine Slice 1) 도입 — `HARNESS-TEST-TAXONOMY.md` 신설(3층 수단 경계·Surface×Depth·Tier·temp/ 정책) + `run-harness-checks.sh` tier runner + AGENT-WORKFLOW/VERIFICATION-COMMANDS pointer. invariants exit-code 버그 수정. F1~F5 후속 분해, F5 maintainer ops manual backlog 등록 | 변경마다 들쭉날쭉하던 surface 검증을 test-backed로 일관·정확화. Codex R0~R2 합의 | Low |
| 2026-06-11 | CHORE-20260611-004: BEHAVIOR-PRINCIPLES §6 (Harness Context Discipline) 신설 — harness 운영 행동을 agent-side 지속 컨텍스트(Claude memory/Codex profile/Cursor user rules)에 저장 금지. Claude memory 2건 pointer 축소 | harness 동작이 "문서만으로" 유도되는지 검증하려면 agent-side 컨텍스트 보정이 없어야 함. cross-agent 검증 조건 균등화 — Codex R0/R1 합의 | Low |
| 2026-06-10 | CHORE-20260610-011: backlog Seq 포맷 거버넌스 (B) 채택 — Seq 열·Sequencing Guide·항목 주석 제거. derived data(의존성=`Dependencies`, 시퀀싱뷰=STATUS)를 손유지 열로 복제하지 않음 | reorg가 ad-hoc 도입한 Seq가 scaffold 템플릿·work-register 5열·PRODUCT 대칭(DR-031)과 divergent + drift 부채. churn·cascade 비용이 at-a-glance 이점 상회 | Low |
| 2026-06-10 | DR-033: shipped 표면은 scaffold seed에 닫힌 DR만 참조. mode-a(canonical) self-describe / mode-b(DR 파일) `Linked DRs:` 격리. source-only static check로 작성 시점 사전 강제 | 비-seed DR 인용이 target dangling을 만들고 뒤늦게 발견되는 반복 패턴 차단. invariant 사상 첫 OVERALL PASS — CHORE-20260610-005 | Medium |
| 2026-06-10 | DR-032: harness "Phase"를 descriptive+optional 라벨로 de-formalize. 완료 criteria 게이트 제거, 전환=Recent Decisions 기록, Work Done=진실 단위 | 제거된 `Phase completion criteria` 필드의 dangling 기계장치 정리, DR-031 optional 철학 정렬 — CHORE-20260610-003 | Medium |
| 2026-06-09 | DR-031: Product track을 harness와 대칭(`PRODUCT.md`/`works/product/`)으로 전환, phase는 optional migration. source-only migration note는 `docs/migrations/` | `PHASE{n}` backlog가 harness 내부 "Phase"와 네이밍 충돌. 대칭화로 충돌 제거 + phase 강제 폐지 — CHORE-20260609-005 | Medium |
| 2026-06-09 | DR-029: DR 등록 3-way triage(Accepted/Draft/OQ·backlog) + Draft DR lifecycle(승격·Dropped·repo-health hygiene surfacing) | 미결 질문의 Accepted DR 위장 차단, Draft 누적 soft 관리. 기존 lifecycle 참조 — CHORE-20260609-002 | Low |
| 2026-06-07 | DR-027: troubleshooting·retrospective 파일 최소 frontmatter 스펙 도입. `track: harness \| product` 필드 신설 | 분류·상태를 파일 열람 없이 파악하기 위한 최솟값 정형화. 기존 파일 소급 적용, T11 cascade 완료 | Low |
| 2026-06-07 | DR-026: `/repo-decision` → `/record-decision` 원복. `track: harness \| product` 메타데이터 도입 | `repo-decision` 명칭이 harness repo 한정 coverage로 오해 유발. 원래 이름으로 복원 + product decision 명시 — CHORE-20260607-006 | Low |
| 2026-06-05 | slice 0 4축 방향 DR 채택 — DR-021(source/target boundary), DR-022(PLAN lifecycle), DR-023(canonical+hybrid adapter), DR-024(gate 2D taxonomy) | Phase 2 리팩토링 4축 TO-BE 확정. cross-agent R0~R6 합의, decision-only(적용은 하류 slice) — CHORE-20260605-001/002 | DR별 상이(Low~High) |
| 2026-05-29 | pre-commit: main만 hard block, develop은 warning 유지. commit-msg build type 추가, 두 hook 설치 | GitHub ruleset이 develop direct push를 이미 차단. solo 프로젝트에서 housekeeping마다 PR 강제는 과도한 마찰 — CHORE-20260529-003 + fix | Low |

## Next Actions

> backlog는 확정 실행 계획이 아니라 의견 있는 portfolio view다. 각 항목 착수 시 `/work-plan`에서 논리성·합리성·현재 product 적용 맥락을 다시 검토한다. 별도 Seq 축은 유지하지 않는다(CHORE-20260610-011 (B)).

1. **W1 — Validation Spine** (이번 주 마무리 전 최우선):
   - ✓ **harness workflow 검증 테스트 체계 정립** — CHORE-20260611-005에서 검증 척추 Slice 1 도입 완료(taxonomy + tier runner + temp/ 정책). 후속은 F1~F4 + F5(`Source repo maintainer operations manual`)
   - ✓ **Scaffold/tool-surface regression alignment 체계화** — CHORE-20260611-006에서 leak-scan을 source-gitflow shipped 6파일로 확장 + 검증 척추 흡수 완료. 잔여 deep 통합은 F4(`repo-health gate series 보강`)
   - **Product pack verification layer 보강** — product starter/import loop와 product engineering option-pack 검증 layer를 maintainer catalog에 추가
   - **repo-health gate series 보강** — `.harness/gate-config`와 gate list 정합을 health/cascade에 연결
2. **W2 — Adopter Transition** (다음 주 실제 product 적용 준비):
   - **Harness upgrade/migration 메커니즘** — `--check` + selective migration guide를 먼저 정리
   - **Product starter planning pack + feedback import loop** — source repo에서 product plan을 먼저 만들고, scaffold repo 산출물을 source option-pack 후보로 반입하는 loop 설계
   - **User-facing docs rewrite** — README rewrite 기준으로 onboarding guide/workflow manual/generated onboarding surface 전면 재작성
   - **Scaffold multi-user clone verification** — generic/source-gitflow target에서 clone·branch·hook·CI 경로 점검
3. **W3 — Workflow IA Diet** (큰 구조 변경은 결정/최소 정리까지만):
   - Canonical 개념 계층화, Prompt surface diet, trigger family simplification, repo-health/work-doc slice/class 검토
4. **W4/W5 — Lifecycle hygiene 및 optional 확장**:
   - Backlog row lifecycle SSoT는 짧게 닫을 수 있는 hygiene 후보
   - Archive policy, Spring Boot MSA TDD option-pack, template pack, CLI naming, Windows, `/exit` gap은 실제 product 운용 후 필요성 재판단
