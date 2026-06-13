---
id: CHORE-20260611-011
priority: P1
status: Archived
risk: L2
scope: CHORE-20260611-009/010 이후 늘어난 source-only maintainer 문서와 upgrade/migration mechanism을 README, maintainer map, onboarding/manual/generated surfaces에 cascade해 reader entrypoint와 실제 문서 구조를 맞춘다. 첫 slice는 객관적 map/link/pointer/stale phrase 현행화에 한정한다. User-facing readability rewrite, Product starter planning pack 설계, prompt surface diet, optional pack 재정의, DR-034 Accepted 승격은 범위 밖.
appetite: 1d
planned_start: 2026-06-11
planned_end: 2026-06-12
actual_end: 2026-06-12
related_dr: [DR-007, DR-021, DR-033]
related_work: [CHORE-20260606-005, CHORE-20260611-009, CHORE-20260611-010]
---

# CHORE-20260611-011: Docs Cascade 현행화

## Top Summary

- **목표:** README Documentation Map / Repository Layout, source-only maintainer map, onboarding/manual/generated surfaces를 현재 source repo 구조에 맞춘다.
- **왜 지금:** CHORE-20260611-009에서 source repo maintainer operations manual이 생겼고, CHORE-20260611-010에서 Draft DR-034 + Layer T + migration note가 생겼다. 그런데 README와 user-facing docs는 이 새 구조를 충분히 안내하지 못한다.
- **실측된 문제:** README에는 `--check`/selective migration 안내가 이미 있지만, `docs/maintainer/`와 핵심 source-only maintainer 문서·migration note가 Documentation Map/Repository Layout에서 빠져 있다. 또 README가 `docs/backlog/PRODUCT.md`를 가리키지만 현재 해당 파일은 없다.
- **핵심 문제:** 문서 지도가 실제 구조보다 뒤처지면 다음 AI/maintainer가 source-only 문서와 user-facing 문서를 혼동한다. Product starter planning pack을 시작하기 전에 객관적 reader entrypoint를 먼저 정렬해야 한다.
- **경계:** 이번 Work는 map/link/pointer/stale phrase cascade에 집중한다. 초보 개발자/일반 독자 친화 readability rewrite는 별도 후속 Work로 분리한다.

## Candidate / Backlog Link

- Backlog candidate: `Docs cascade 현행화 — README / maintainer map / onboarding surfaces`.
- 2026-06-11 사용자 제기로 기존 `User-facing docs rewrite` candidate를 위 항목으로 재프레이밍했다.
- Product starter planning pack의 dependency도 이 항목으로 갱신했다.
- Claude R0에서 writing rewrite와 객관적 cascade를 분리하라는 변경 요청을 받아, user-facing readability rewrite는 별도 backlog candidate로 다시 분리한다.

## Background / Facts

- README 실측(2026-06-12):
  - `--check`/selective migration 안내는 존재한다(`README.md` line 265 근처).
  - `docs/maintainer/`, `SOURCE-REPO-OPERATIONS`, `VERIFICATION-COMMANDS`, `docs/maintainer/migrations/`, `DR-034` 참조는 없다.
  - `docs/backlog/PRODUCT.md` 참조가 있으나 파일은 존재하지 않는다.
- `docs/maintainer/` 현재 파일 목록:
  - `docs/maintainer/README.md`
  - `docs/maintainer/SOURCE-REPO-OPERATIONS.md`
  - `docs/maintainer/VERIFICATION-COMMANDS.md`
  - `docs/maintainer/HARNESS-TEST-TAXONOMY.md`
  - `docs/maintainer/VERSIONING.md`
  - `docs/maintainer/migrations/README.md`
  - `docs/maintainer/migrations/canonical-adapter-rename.md`
  - `docs/maintainer/migrations/manifest-check-baseline.md`
  - `docs/maintainer/migrations/product-track-rename.md`
- 따라서 이번 Work의 표적은 "README 전체가 뒤처졌다"가 아니라 **maintainer 문서 map 누락 + PRODUCT.md dangling + 관련 cascade pointer 불일치**다.

## Scope / Plan

> 합의 전 구현 금지. 아래는 Claude R0 plan review 대상이다.

### Scope

1. **Reader entrypoint 현행화**
   - root `README.md`의 Documentation Map, Repository Layout, `--check`/selective migration 안내를 CHORE-20260611-009/010 이후 상태에 맞춘다.
   - `docs/maintainer/`가 source-only maintainer reference임을 README에서 찾을 수 있게 하되, 일반 adopter manual처럼 포장하지 않는다.
2. **Maintainer map 정렬**
   - `docs/maintainer/README.md`, `docs/maintainer/SOURCE-REPO-OPERATIONS.md`, `docs/maintainer/VERIFICATION-COMMANDS.md`, `docs/maintainer/migrations/README.md`의 audience, load condition, pointer가 서로 맞는지 확인한다.
   - 기준/명령/정책을 중복 복제하지 않고 pointer로 연결한다.
3. **Targeted onboarding/manual cascade**
   - `docs/SCAFFOLD-ONBOARDING-GUIDE.md`, `docs/WORKFLOW-MANUAL.md`, `docs/HARNESS-MAINTAINER-GUIDE.md`에서 README와 충돌하는 source/target 경계, `--check`, migration, maintainer-map pointer만 점검한다.
   - generated README / generated `docs/BOOTSTRAP.md` / `prompts/*session-start.md` 영향 여부를 확인하고, 실제 stale pointer가 확인된 경우에만 최소 cascade를 반영한다.
4. **Writing rewrite follow-up 분리**
   - 사용자 제기의 "초보 개발자/일반 독자 친화 + 전문성 유지" 원칙은 별도 backlog candidate로 남긴다.
   - 이번 Work에서는 객관적 cascade 문구를 고치는 과정에서 새로 작성하는 문장에만 해당 원칙을 국소 적용한다. README/MANUAL/GUIDE 전체 readability rewrite는 하지 않는다.

### Non-goals

- Product starter planning pack + feedback import loop 설계.
- Spring Boot MSA / product engineering option-pack 구조 설계.
- Prompt surface diet, optional pack 재정의, physical docs layout 재배치.
- `scripts/create-harness.sh`의 신규 옵션 또는 upgrade helper 구현.
- DR-034 Accepted 승격.
- source-only maintainer 문서를 scaffold default surface에 대량 배포.
- 문서를 "쉬워 보이게" 만들기 위해 전문적 경계나 위험을 삭제하는 것.
- README/MANUAL/GUIDE 전체 readability rewrite 또는 tone rewrite.
- writing principle의 repository-wide/canonical/skills 적용.

### Files

| 파일 | 변경 예상 | 비고 |
| --- | --- | --- |
| `README.md` | 주요 변경 | Documentation Map, Repository Layout, `--check`/migration 안내, reader entrypoint |
| `docs/maintainer/README.md` | 후보 | maintainer reference map / load condition 정렬 |
| `docs/HARNESS-MAINTAINER-GUIDE.md` | 후보 | maintainer/source-only pointer stale 확인 시 |
| `docs/SCAFFOLD-ONBOARDING-GUIDE.md` | 후보 | scaffold onboarding path stale 확인 시 |
| `docs/WORKFLOW-MANUAL.md` | 후보 | upgrade/migration pointer stale 확인 시 |
| `scripts/create-harness.sh` | 후보(필요 시만) | generated README/BOOTSTRAP pointer가 stale이면 최소 template cascade |
| `prompts/*session-start.md` | 후보(필요 시만) | onboarding route나 stale pointer가 있으면 최소 수정 |
| `docs/backlog/HARNESS.md` | 이미 변경 | candidate reframe + writing principle seed |
| `docs/STATUS.md` | 이미 변경 | W2 Next Actions 순서 반영. Active pointer는 R0 승인 후 별도 |

## Verification

1. `git diff --check`.
2. `bash scripts/tests/run-harness-checks.sh --tier0`.
3. `bash scripts/tests/check-shipped-dr-closure.sh`.
4. 링크/지도 점검:
   - README Documentation Map과 Repository Layout에 존재하지 않는 파일 또는 빠진 maintainer entry가 없는지 확인.
   - `find docs/maintainer -maxdepth 2 -type f | sort`와 README/maintainer map 비교.
5. stale phrase grep:
   - `rg "Documentation Map|maintainer|source-only|--check|upgrade|migration|selective migration|BOOTSTRAP|generated" README.md docs/*.md docs/maintainer prompts scripts/create-harness.sh`.
6. scaffold output 검증:
   - README/generated surface를 건드리면 `bash scripts/create-harness.sh --dry-run docs-cascade-smoke temp/docs-cascade-smoke` 또는 `run-harness-checks.sh --all`.
   - source-only maintainer 문서가 shipped default/optional surface에 부적절하게 노출되지 않는지 scaffold invariant/closure로 확인.

## Risk / Reversal Cost

- **Risk:** L2. 코드/런타임 변경은 아니지만 README와 user-facing docs는 adopter entrypoint라 오해를 만들 수 있다.
- **주요 리스크 1:** source-only maintainer 문서를 user-facing manual처럼 노출하면 scaffold adopter가 따라야 할 문서로 오해할 수 있다.
- **주요 리스크 2:** README에서 migration 문구를 너무 일반화하면 CHORE-010에서 닫은 pre-manifest/2-way diff 한계가 흐려질 수 있다.
- **주요 리스크 3:** README만 고치고 generated/onboarding/manual surface를 놓치면 cascade debt가 계속 남는다.
- **주요 리스크 4:** readability rewrite까지 끌어오면 범위가 과대해져 객관적 cascade를 1d에 닫기 어렵다.
- **Reversal Cost:** Medium. 문서 변경은 revert 가능하지만 README/onboarding path의 wording은 후속 adopter 행동에 직접 영향을 준다.

## Open Questions

| ID | Question | 기본 제안 |
| --- | --- | --- |
| OQ-1 | README Documentation Map에 `docs/maintainer/*`를 어느 깊이까지 노출할 것인가? | top-level `docs/maintainer/README.md`를 primary로 두고 핵심 2~3개만 조건부로 노출 |
| OQ-2 | writing principle을 어디에 영구화할 것인가? | 이번 Work에서는 별도 backlog candidate로 분리. repository-wide 승격은 하지 않음 |
| OQ-3 | `docs/WORKFLOW-MANUAL.md`를 얼마나 고칠 것인가? | stale/cascade pointer 한정. readability rewrite는 후속 |
| OQ-4 | generated README/BOOTSTRAP을 이번에 고칠 것인가? | source README/manual과 불일치가 실제 확인된 경우 최소 수정 |
| OQ-5 | `scripts/create-harness.sh` 수정이 포함되면 검증 수준은? | `--all` 필수. generated output 확인 포함 |

## State / Approval

- **위험도:** L2.
- **실행 모드:** Full Work.
- **현재 상태 머신:** DONE.
- **Tool Rule Reference:** `.claude/rules/docs-workflow.md`, `.claude/rules/git-workflow.md` 적용. DR-007 적용: docs는 한국어 주 언어 + Bilingual Rules.
- **PLAN 영향:** AWH-004 "adopter upgrade/migration, onboarding 현행화"와 일치. 이번 closeout에서는 `docs/PLAN.md` 직접 변경까지는 필요하지 않다고 판단했다. PLAN-SUMMARY도 별도 stale 신호는 확인하지 않았다.
- **STATUS Update Proposal:** 2026-06-12 work-close에서 `CHORE-20260611-011` Active pointer 제거, Recent Decisions/Next Actions 갱신까지 완료.

## Cross-Agent Review And Discussion

> 이번 세션 역할: Codex = author/driver, Claude = reviewer. 리뷰/결과 정리는 한국어 중심으로 누적한다.

### Review Request

Claude R1 result review 요청: CHORE-20260611-011 Docs Cascade 현행화

검토 초점:

- README Documentation Map / Repository Layout이 `docs/maintainer/`와 source-only maintainer docs를 적절한 깊이로 가리키는가?
- README가 maintainer-depth 절차를 직접 복제하지 않고 migration note / Layer T pointer까지만 제공하는가?
- `docs/backlog/PRODUCT.md` dangling이 README에서 해소됐는가?
- `docs/maintainer/README.md`가 실제 9개 파일을 빠짐없이 지도화하는가?
- source-only maintainer docs가 scaffold/generated surface로 과잉 배포되지 않았는가?

### Round Log

| Round | 주체 | 유형 | 요약 | Required Changes / Decision | Status |
| --- | --- | --- | --- | --- | --- |
| R0 | Claude | Plan Review | 방향 타당(cascade debt 실측 확인: README가 docs/maintainer·SOURCE-REPO-OPERATIONS·VERIFICATION-COMMANDS·migrations·DR-034 미참조, docs/backlog/PRODUCT.md dangling). 그러나 객관적 cascade(Scope 1~3)와 주관적 writing-rewrite(Scope 4~5)를 한 Work에 혼합 — 검증 비대칭(grep vs 샘플리뷰), 1d에 user-facing 전면 톤 재작성 불가, rewrite는 planning pack 선행 불필요. Scope 5 repository-wide 승격은 매뉴얼화 불변제약(HARNESS.md:258/433)과 충돌. README 현황 실측이 Background에 없어 scope가 추정. | M1(writing rewrite를 별도 Work로 분리, 이번은 cascade 한정)·M2(Scope 5 제거 or user-facing 한정)·M3(README/maintainer map 현황 실측을 Background에 추가, 표적 목록화) 반영 후 R0a 재요청. | Changes Requested |
| R0a | Codex | Plan Fix | M1: writing rewrite를 별도 backlog candidate로 분리하고 이번 Work는 map/link/pointer/stale phrase cascade로 한정. M2: writing principle repository-wide 승격 제거, canonical/skills 적용 범위 제외. M3: README 현황 실측(maintainer map 누락, PRODUCT.md dangling, `--check` 안내 존재)을 Background에 추가하고 표적 목록화. | Claude R0a plan re-review 요청. | Reviewed |
| R0a-rev | Claude | Plan Re-review | M1~M3 충실 반영 확인. writing rewrite 별도 backlog 분리(+Verification 7 주관 항목 삭제로 검증 전부 객관화), Scope 5 repository-wide 승격 제거(매뉴얼화 불변제약 해소), README 실측 Background 추가(maintainer map 누락+PRODUCT.md dangling 표적화). Scope 4 "새 문장만 국소 적용"은 사용자 지시 보존+creep 방지의 적절한 타협. appetite 1d 현실화. 비차단 nice: Done Criteria의 README migration 반영이 maintainer-depth 절차를 요구하면 source-only/user-facing 경계와 긴장 — README는 pointer까지, 절차 디테일은 maintainer 문서로 둘 것. | 승인. 구현 착수 가능. R1은 cascade map 정합·README depth 경계·stale pointer 실제 해소 중심. | Approved |
| R1 | Codex | Result | README에 source-only maintainer 문서 지도(`docs/maintainer/README.md`)와 핵심 maintainer references(`SOURCE-REPO-OPERATIONS`, `VERIFICATION-COMMANDS`, `migrations/`)를 추가. README Repository Layout에 `docs/maintainer/` 추가. `docs/backlog/PRODUCT.md` dangling mermaid label을 `Product backlog (target repo, when present)`로 변경. README migration 문구는 pre-manifest 주의와 maintainer docs pointer까지만 제공하고 shadow baseline/2-way diff 절차를 복제하지 않음. `docs/maintainer/README.md`에 `README.md`, `HARNESS-TEST-TAXONOMY.md`, migration notes 3개를 추가해 실제 9개 파일 map 정합 확인. | Claude R1 result review 요청. | Pending |
| R1-review | Claude | Result Review | R0a 예고 3건 통과: README maintainer map 추가(핵심 3개, 과잉노출 0), PRODUCT.md dangling을 "target repo, when present"로 정정, README가 maintainer-depth 미유입(pointer까지만). backlog 분리 우수(cascade↔readability 2 candidate 분화, 매뉴얼화 금지 명시). 검증 PASS(diff-check/tier0/closure). 단 MR-1: maintainer/README 신규 "Migration Notes" 표가 migrations/README.md 인덱스를 복제(2곳 동일 3행) — CHORE-008이 막은 SSoT 복제 안티패턴이자 본 Work Scope 2 위배. maintainer/README 자산표에 이미 migrations/ 행 존재. | MR-1: Migration Notes 표를 pointer 한 줄로 축소(인덱스 SSoT=migrations/README.md) 후 R1a. 그 외 승인. | Conditional Approval |
| R1a | Codex | Result Fix | MR-1 반영: `docs/maintainer/README.md`의 Migration Notes 3행 표 제거. `migrations/` 설명은 유지하되, 인덱스 SSoT가 `docs/maintainer/migrations/README.md`임을 pointer 한 줄로만 남김. | Claude R1a result re-review 요청. | Reviewed |
| R1a-rev | Claude | Result Re-review | MR-1 수정 확인: Migration Notes 3행 표 제거 완료, `migrations/` 역할 1문장 + "인덱스 SSoT는 `docs/maintainer/migrations/README.md`다." pointer 1줄로 대체. grep 재확인: maintainer/README.md=1건(pointer), migrations/README.md=1건(SSoT) — 복제 해소. 자산표의 기존 migrations/ 행과 역할 분리: 자산표=목록, Migration Notes=성격 설명+SSoT 위임. CHORE-008 교훈(목록 2곳 복제 금지) + Scope 2(pointer 연결) 모두 충족. | 모든 MR 해소. 승인. work-close 착수 가능. | Approved |

### Consensus Log

| Topic | Consensus | Source Round | Status |
| --- | --- | --- | --- |
| Work 선택 | W2에서 Product starter planning pack 전에 docs cascade 현행화를 선행 | Codex plan | Proposed |
| Scope 경계 | README만 hotfix하지 않고 maintainer map/onboarding/manual/generated surfaces의 객관적 stale pointer를 함께 sweep | R0a-rev | Approved |
| Writing rewrite | 초보자 친화성과 전문적 정확성을 동시에 요구하는 readability rewrite는 별도 backlog candidate로 분리 | R0a-rev | Approved |
| README depth | README는 migration 절차 디테일을 품지 않고 maintainer 문서로 pointer를 제공 | R0a-rev | Approved |

## Done Criteria

- [x] README Documentation Map과 Repository Layout이 현재 source-only maintainer 문서 및 migration note 구조를 반영함.
- [x] README의 `--check`/upgrade/migration 안내가 CHORE-20260611-010의 pre-manifest, shadow scaffold baseline, 2-way diff 한계를 직접 절차로 복제하지 않고 maintainer 문서 pointer로 연결함.
- [x] `docs/maintainer/` map이 source-only maintainer / AI driver용 reference임을 명확히 함.
- [x] `docs/HARNESS-MAINTAINER-GUIDE.md`, `docs/SCAFFOLD-ONBOARDING-GUIDE.md`, `docs/WORKFLOW-MANUAL.md`의 source/target·maintainer·migration pointer가 README와 충돌하지 않음.
- [x] generated README/BOOTSTRAP/prompt surface 영향 여부를 확인하고 필요한 cascade를 반영함.
- [x] User-facing readability rewrite 후보가 별도 backlog item으로 분리됨.
- [x] source-only 문서가 scaffold default/optional surface에 과잉 배포되지 않음.
- [x] Cross-Agent R0 plan review와 result review가 이 섹션에 누적됨.

## Discovery

- 2026-06-11: CHORE-20260611-010 merge 후 사용자 제기 — README Documentation Map만 봐도 새 maintainer/source-only 문서와 migration note가 반영되지 않아 cascade debt가 남아 있음.
- 2026-06-11: 기존 `User-facing docs rewrite — onboarding guide + workflow manual` backlog candidate를 `Docs cascade 현행화 — README / maintainer map / onboarding surfaces`로 재프레이밍. 신규 중복 항목을 만들지 않고 기존 후보를 흡수.
- 2026-06-11: 사용자 추가 원칙 — README/MANUAL/GUIDE는 초보 개발자 또는 일반 독자를 대상으로 친절하고 알기 쉽게 쓰되, 전문적 내용은 생략하지 않는 기준을 적용. "청중에 따라 구성과 톤이 달라져야 한다"는 원칙을 backlog와 이 Work의 기준으로 반영.
- 2026-06-12 R0 반영: Claude review에 따라 writing rewrite를 이번 cascade Work에서 분리. README 실측 결과는 `--check` 안내 존재, maintainer map/DR-034 누락, `docs/backlog/PRODUCT.md` dangling으로 확인.
- 2026-06-12 R0a 승인: Claude가 plan 승인. 비차단 nice로 README는 maintainer-depth 절차를 직접 품지 말고 pointer까지로 제한하라고 권고.
- 2026-06-12 구현: README Documentation Map에 `docs/maintainer/README.md` 추가, Maintainer reference details에 `SOURCE-REPO-OPERATIONS.md` / `VERIFICATION-COMMANDS.md` / `migrations/` 추가, Repository Layout에 `docs/maintainer/` 추가.
- 2026-06-12 구현: README `docs/backlog/PRODUCT.md` dangling mermaid label을 `Product backlog (target repo, when present)`로 교체.
- 2026-06-12 구현: README pre-manifest 안내는 `--check` 단독 판단 금지 + source-only maintainer migration note / Layer T pointer로 제한. shadow scaffold baseline / 2-way diff 절차는 README에 직접 복제하지 않음.
- 2026-06-12 구현: `docs/maintainer/README.md` 자산 표에 `README.md`, `HARNESS-TEST-TAXONOMY.md` 추가, logical marker에 taxonomy 추가. R1 MR-1 반영 후 migration note 개별 목록은 복제하지 않고 `docs/maintainer/migrations/README.md` pointer만 유지.
- 2026-06-12 검증: maintainer map 9개 파일 언급 확인 PASS. README 내 `docs/backlog/PRODUCT.md` dangling 없음. source-only maintainer path가 shipped/generated surface로 새로 노출되지 않음(`rg` no result). `git diff --check`, `check-shipped-dr-closure.sh`, `run-harness-checks.sh --tier0`, `run-harness-checks.sh --all` PASS.
- 2026-06-12 closeout: Claude R1a 승인 반영 후 Work를 Done으로 전환. objective cascade 항목은 backlog/STATUS에서 제거하고, 후속은 `User-facing docs readability rewrite` candidate로 유지.
- 2026-06-12 archive: closeout과 후속 후보 분리가 끝나 archive 처리. Work index는 Archived로 이동하고, W2의 남은 초점은 planning pack / readability rewrite / multi-user clone verification으로 유지.
