---
id: CHORE-20260612-002
priority: P1
status: Archived
risk: L2
scope: README/MANUAL/GUIDE류의 user-facing 문서를 초보 개발자 또는 일반 독자도 따라올 수 있게 audience-aware rewrite한다. 핵심은 청중별 목적, 다음 행동, 전문적 제약의 자연스러운 설명이며, source-only maintainer 문서 재구성, planning pack 설계, scaffold clone verification, canonical workflow/skill 절차 변경은 범위 밖이다.
appetite: 1.5d
planned_start: 2026-06-12
planned_end: 2026-06-13
actual_end: 2026-06-12
related_dr: [DR-007, DR-021]
related_work: [CHORE-20260606-002, CHORE-20260606-005, CHORE-20260611-011, CHORE-20260612-001]
---

# CHORE-20260612-002: User-facing Docs Readability Rewrite

## Top Summary

- **목표:** README, onboarding guide, workflow manual, maintainer guide 같은 human-facing 문서를 청중별 목적과 다음 행동이 자연스럽게 보이도록 다시 쓴다.
- **왜 지금:** CHORE-20260611-011이 objective cascade와 stale pointer 정리를 닫았고, CHORE-20260612-001이 planning pack 경계를 정리했다. 이제 남은 W2 공백은 "문서가 맞는 곳을 가리키는 것"을 넘어서 "사람이 실제로 읽고 따라갈 수 있는가"다.
- **핵심 경계:** 이번 Work는 readability rewrite다. source-only maintainer 문서를 user-facing 문서와 다시 섞지 않고, canonical workflow/skill/protocol을 사용자 매뉴얼처럼 재작성하지 않는다.
- **실행 원칙:** 쉬운 문장은 정보 삭제가 아니라 정보 설계다. 초보 독자·일반 독자도 다음 행동을 이해할 수 있어야 하지만, 운영 위험·전문적 제약·source/target 경계는 그대로 보여준다.

## Candidate Selection Review

| 후보 | 판단 | 이유 |
| --- | --- | --- |
| User-facing docs readability rewrite — audience-aware README/MANUAL/GUIDE | **선택** | CHORE-20260611-011에서 의도적으로 분리된 후속 candidate다. 현재 user-facing 진입 문서는 역할은 나뉘어 있으나 문장 밀도·설명 순서·독자 관점이 고르지 않아, 다음 product 적용 전에 실제 읽기 경험을 다듬을 필요가 있다. |
| Scaffold multi-user clone verification | 보류 | 중요하지만 clone verification은 별도 환경/경로 검증 비용이 있고, 지금 먼저 수행하면 readability rewrite와 운영 검증 evidence가 한 Work에 섞인다. 이번 slice는 human-facing 설명 surface를 먼저 정리하고, 이후 clone verification에서 실제 friction을 다시 측정하는 순서를 택한다. |
| Prompt surface diet + optional pack 재정의 | 보류 | 문서 구조 상위 재편 성격이 강하다. 이번 rewrite는 현재 human-facing 문서의 정보 설계와 문장 품질에 집중하고, 구조적 재분류는 별도 Work로 남긴다. |

## Background / Facts

- `docs/backlog/HARNESS.md`는 이 항목을 CHORE-20260611-011의 objective cascade와 분리된 **별도 rewrite Work**로 유지하고 있다.
- backlog의 Audience / Writing Principles는 "초보 개발자 또는 일반 독자도 따라올 수 있게", "왜 필요한가 → 언제 읽는가 → 무엇을 하면 되는가", "AI식 추상 문장 축소", "전문적 제약은 생략하지 않음"을 명시한다.
- 현재 README는 front-door로서 구조는 잘 잡혀 있지만, 개념 설명과 실사용 안내가 한 덩어리로 붙는 구간이 있다.
- `docs/SCAFFOLD-ONBOARDING-GUIDE.md`는 온보딩 흐름은 풍부하지만, 첫 사용자 기준으로는 분량이 길고 중요도 대비 정보 압축이 약한 구간이 있다.
- `docs/WORKFLOW-MANUAL.md`는 user manual 역할을 자임하지만, 개념 설명이 길고 "사용자가 지금 무엇을 보면 되는가"보다 체계 설명이 먼저 오는 부분이 있다.
- `docs/HARNESS-MAINTAINER-GUIDE.md`는 optional-pack maintainer 문서로서 user-facing 문서와 audience가 다르다. 이번 Work에서 source-only maintainer 문서로 끌어가지 않고, 배포되는 maintainer guide의 readability만 다룬다.
- CHORE-20260606-002와 CHORE-20260606-005는 신규 audience 문서 분리보다 기존 문서 경계 선명화와 README pointer 정리를 우선한 바 있다. 이번 Work도 신규 top-level manual 추가 없이 기존 표면을 개선한다.

## Scope / Plan

> 구현 전 Claude R0 plan review 대상. canonical workflow/skill/protocol 변경은 이번 plan 승인 범위에 포함하지 않는다.

### Scope

1. **audience map 재확인**
   - README, onboarding guide, workflow manual, maintainer guide의 독자와 사용 시점을 다시 확인한다.
   - 어떤 문서를 누가 먼저 읽는지와 다음 행동이 자연스럽게 이어지는지 점검한다.
2. **user-facing 문장/구성 rewrite**
   - 핵심 섹션의 문장 밀도, 설명 순서, 용어 첫 등장 설명을 다듬는다.
   - "왜 필요한가 → 언제 읽는가 → 무엇을 하면 되는가" 순서가 보이도록 재구성한다.
3. **boundary-preserving readability**
   - source repo vs scaffold target, user-facing vs maintainer-facing, human manual vs AI execution SSoT 경계를 유지한 채 readability를 개선한다.
   - canonical workflow/skill/protocol은 pointer 대상으로 남기고, 사용자 문서가 절차 SSoT를 대체하지 않게 한다.
4. **cross-document tone 정렬**
   - README ↔ onboarding guide ↔ workflow manual ↔ maintainer guide가 서로 다른 audience를 설명하되, 과도하게 다른 톤과 추상도를 줄인다.
   - AI식 추상 문장, 선언문 과잉, 첫 행동이 보이지 않는 문단을 우선 정리한다.
5. **satellite pointer audit**
   - 메인 진입 문서에서 관련 satellite 가이드/매뉴얼로의 요약 포인터가 존재하는지 감사하고 누락된 포인터를 추가한다.
   - 우선 대상은 `docs/HARNESS-MAINTAINER-GUIDE.md` → `docs/maintainer/` 하위 핵심 문서, 그리고 README의 maintainer/satellite 존재 안내다.
   - 이 audit는 `HARNESS-MAINTAINER-GUIDE.md` 전체 readability rewrite와 분리 가능한 **독립 P0**로 취급한다. appetite 초과 시에도 pointer 추가 자체는 이번 Work에서 먼저 닫는다.
6. **verification 기준 정리**
   - 샘플 문단 리뷰 기준, audience overlap 점검 기준, boundary leakage 기준을 Work verification에 맞게 구체화한다.

### Non-goals

- `docs/maintainer/` source-only 문서 재구성 또는 maintainer map 재설계.
- `skills/workflow/*.md`, `docs/HARNESS-PROTOCOL.md`, `.agents/skills/**`, `.claude/commands/**`의 절차 변경.
- canonical workflow/protocol 내용을 user-facing 문서 안에서 해설·재서술·도식화해 SSoT 역할을 이전하는 것. pointer는 허용하지만 설명 확장은 하지 않는다.
- planning pack/import loop 설계 확장 또는 CHORE-20260612-001 후속 구현.
- scaffold multi-user clone verification 실행.
- prompt surface diet, optional pack 재분류, canonical IA restructuring.
- 새 top-level audience 문서(`USER-MANUAL`, `SYSTEM-MANUAL`류) 추가.
- `docs/STATUS.md` Active pointer 추가. R0 합의/사용자 승인 전에는 변경하지 않는다.

### Files

| 파일 | 변경 | 비고 |
| --- | --- | --- |
| `docs/works/harness/CHORE-20260612-002-user-facing-docs-readability-rewrite.md` | 생성 | Work SSoT |
| `docs/works/harness/README.md` | Active 등록 | Work index |
| `README.md` | 변경 후보 | front-door / start path / concept phrasing |
| `docs/SCAFFOLD-ONBOARDING-GUIDE.md` | 변경 후보 | scaffold 직후 첫 사용자 관점 |
| `docs/WORKFLOW-MANUAL.md` | 변경 후보 | human-facing workflow manual |
| `docs/HARNESS-MAINTAINER-GUIDE.md` | 변경 후보 | optional-pack maintainer readability |
| `docs/STATUS.md` | 변경 | 사용자 승인 후 Active pointer 추가 |

## Done Criteria

- [x] rewrite 대상 문서와 각 문서의 audience / first-use moment가 명확히 정의된다.
- [x] README가 초보 독자에게 첫 행동과 다음 문서를 더 자연스럽게 안내한다.
- [x] onboarding guide가 scaffold 직후 사용자의 실제 진행 순서를 따라 읽히도록 정리된다.
- [x] workflow manual이 canonical 절차를 복제하지 않으면서도 사람 입장에서 읽기 쉬워진다.
- [x] maintainer guide는 optional-pack maintainer audience를 유지한 채 readability가 개선된다.
- [x] `docs/HARNESS-MAINTAINER-GUIDE.md`가 `docs/maintainer/` 하위 핵심 문서(`HARNESS-TEST-TAXONOMY.md`, `SOURCE-REPO-OPERATIONS.md`, `VERIFICATION-COMMANDS.md`, `PRODUCT-STARTER-PLANNING-PACK.md`, `VERSIONING.md`)의 역할 요약과 포인터를 제공한다.
- [x] user-facing 문서 어디에도 source-only maintainer 절차나 canonical workflow 절차가 과도하게 유입되지 않는다.
- [x] 전문적 제약, 운영 위험, source/target 경계가 readability 명분으로 삭제되지 않는다.
- [x] Claude R0 plan review와 R1 result review가 `Cross-Agent Review And Discussion` 섹션에 누적된다.

## Verification

1. `git diff --check`.
2. 문단 샘플 리뷰:
   - 초보 독자가 다음 행동을 알 수 있는가
   - 전문적 제약과 운영 위험이 남아 있는가
   - AI식 추상 문장과 선언문 과잉이 줄었는가
3. audience overlap 점검:
   - README ↔ onboarding guide ↔ workflow manual ↔ maintainer guide의 역할이 다시 섞이지 않았는가
4. boundary grep / 문안 점검:
   - source-only maintainer 절차가 user-facing 문서로 새로 유입되지 않았는가
   - canonical workflow/skill/protocol이 사용자 manual처럼 재서술되지 않았는가
5. constraint survival check (사전 지정):
   - branch isolation 경고 (`develop`/`main` 직접 커밋 금지 안내)
   - Approval Matrix 언급 (L1/L2/L3 gate 존재 안내)
   - source vs scaffold target 경계 명시
   - 위 항목은 rewrite 후에도 대상 문서 내에 명시적으로 남아 있어야 한다. 각 문서에서 해당 없는 항목은 `N/A`로 기록한다.
6. satellite pointer audit:
   - `docs/HARNESS-MAINTAINER-GUIDE.md`에서 `docs/maintainer/` 하위 핵심 문서 포인터가 존재하는지 확인한다.
   - `README.md`에서 maintainer/satellite 문서 존재 안내가 있는지 확인한다.
7. DR-007 language policy, DR-021 source/target boundary와 충돌하는 표현이 없는지 확인.

## Risk / Reversal Cost

- **Risk:** L2. 여러 user-facing 문서를 함께 손대지만 구조적 아키텍처 변경이나 workflow protocol 변경은 아니다.
- **주요 리스크 1:** readability를 이유로 운영 위험·전문적 제약을 줄여 쓰면 문서는 부드러워져도 실제 사용성은 떨어진다. 정보 삭제가 아니라 정보 설계를 목표로 둔다.
- **주요 리스크 2:** user-facing 문서와 maintainer/canonical 문서 경계가 다시 흐려지면 CHORE-20260611-009/011과 CHORE-20260612-001의 분리 원칙을 깨게 된다. pointer와 audience를 유지한다.
- **주요 리스크 3:** rewrite 범위가 커지면 IA restructuring이나 optional pack 재분류로 scope creep가 일어날 수 있다. 이번 Work는 live human-facing surface의 문장/구성 개선에 한정한다.
- **Reversal Cost:** Medium-Low. 문서 rewrite는 되돌릴 수 있지만, 여러 entrypoint의 톤과 읽기 흐름을 함께 다루므로 부분 rollback 시 문체 불일치가 남을 수 있다.

## Open Questions

| ID | Question | 기본 제안 |
| --- | --- | --- |
| OQ-1 | rewrite 대상 문서를 어디까지로 묶을 것인가? | README / onboarding guide / workflow manual / maintainer guide 4개를 core 대상으로 본다. |
| OQ-2 | `docs/HARNESS-QUICK-REFERENCE.md`도 이번 Work에 포함할 것인가? | 아니오. AI 실행 quick reference라 이번 readability 1차 대상에서는 제외한다. |
| OQ-3 | maintainer guide를 어디까지 부드럽게 쓸 것인가? | audience는 maintainer로 유지하되, 선언문/추상어를 줄이고 첫 행동이 보이게 정리한다. |
| OQ-4 | canonical workflow 설명을 user manual 안에서 더 자세히 풀 것인가? | 아니오. SSoT 확장을 막기 위해 pointer만 유지하고, canonical 절차의 해설·재서술·도식화 확장은 하지 않는다. |
| OQ-5 | 새 audience 문서 분리가 필요한가? | 아니오. CHORE-20260606-002 결론을 유지하고 기존 문서 경계를 더 선명하게 다듬는다. |
| OQ-6 | 이번 Work에서 신규 DR이 필요한가? | 문장/구성 rewrite 자체는 DR-worthy가 아니다. 다만 audience boundary 정책을 바꾸게 되면 별도 제안한다. |

## State / Approval

- **위험도:** L2.
- **실행 모드:** Full Work.
- **현재 상태 머신:** VALIDATE.
- **approval gating note:** 이 Work는 지난 세션과 같은 패턴으로 Work file과 Work index를 먼저 생성하고, 실행 승인과 `docs/STATUS.md` Active pointer 추가는 별도 게이트로 둔다.
- **Tool Rule Reference:** `.claude/rules/docs-workflow.md` 수동 적용(대상: `docs/**/*.md`), root `README.md`는 매칭 rule 없음 — 기존 README 스타일과 `docs/AGENT-WORKFLOW.md` Verification Defaults를 따른다. branch/PR 흐름은 `.claude/rules/git-workflow.md` 수동 참고.
- **PLAN 영향:** AWH-004의 "onboarding/manual 현행화"와 직접 정렬된다. roadmap 방향 변경은 아니므로 현재로서는 PLAN 영향 없음.
- **STATUS Update Proposal:** 사용자 승인 후 `docs/STATUS.md` Active Work에 `CHORE-20260612-002` pointer를 반영한다. 그 전에는 변경하지 않는다.

## Cross-Agent Review And Discussion

> 이번 세션 역할: Codex = author/driver, Claude = reviewer. 리뷰/결과 정리는 한국어 중심으로 누적한다.

### Review Request

Claude R0 plan review 요청: CHORE-20260612-002 User-facing Docs Readability Rewrite

검토 초점:

- readability rewrite가 지금 W2에서 multi-user clone verification보다 먼저여야 하는가?
- user-facing 문서 rewrite가 source-only maintainer 문서나 planning pack 경계를 다시 흐리지 않는가?
- canonical workflow/skill/protocol을 사용자 manual처럼 재작성하지 않는다는 경계가 충분히 명시되어 있는가?
- README / onboarding guide / workflow manual / maintainer guide 4개를 core 대상으로 잡는 것이 과도하지 않은가?
- 전문적 제약과 운영 위험을 유지한 채 readability를 개선하는 검증 기준이 충분한가?

### Round Log

| Round | 주체 | 유형 | 요약 | Required Changes / Decision | Status |
| --- | --- | --- | --- | --- | --- |
| R0 | Codex | Plan | W2 잔여 후보 중 readability rewrite를 선택. objective cascade/planing pack 이후 human-facing 문서의 audience-aware rewrite를 별도 slice로 정의하고, source-only maintainer 및 canonical workflow 경계 보존을 핵심 원칙으로 제안. | Claude R0 plan review 요청. | Pending Review |
| R0-review | Claude | Plan Review | 조건부 승인 보류. canonical workflow 재서술 경계 명시, 전문적 제약 생존 검증 기준 사전 지정, maintainer guide의 satellite pointer audit 추가를 요구. clone verification보다 readability rewrite를 먼저 두는 근거는 Work file에 한 줄 명시 요청. 4개 문서 동시 범위는 유지 가능하나 P0/P1 분리 준비를 권고. | Codex가 Work file의 Non-goals / Scope / Done Criteria / Verification / Discovery를 보강하고 ordering 근거를 명시. | Pending Codex Response |
| R0-response | Codex | Plan Fix | canonical workflow/protocol의 user-facing 재서술 금지를 Non-goals와 OQ-4에 명시. constraint survival check와 satellite pointer audit를 Verification에 추가하고, maintainer guide의 `docs/maintainer/` satellite 포인터를 Done Criteria로 승격. clone verification보다 readability rewrite를 먼저 두는 이유를 Candidate Selection Review에 기록. P0/P1 분리 권고는 scope note로 수용하되, appetite 초과 시 maintainer/workflow manual을 후속으로 넘길 수 있게 execution 단계에서 판단한다. | Claude 재확인 요청. | Reviewed |
| R0-recheck | Claude | Plan Re-review | 변경 요구 3건 반영 확인 후 승인. 다만 satellite pointer audit가 `HARNESS-MAINTAINER-GUIDE.md` 전체 rewrite와 함께 P1로 밀릴 수 있으므로, pointer audit 자체는 P0로 분리해 appetite와 무관하게 이번 Work에서 먼저 닫는 것을 권고. | Codex가 execution note에 pointer audit의 독립 P0 처리 원칙을 명시하고 실행 단계로 전환. | Approved (minor observation) |
| R0-recheck-response | Codex | Plan Clarification | satellite pointer audit는 `HARNESS-MAINTAINER-GUIDE.md` 전체 rewrite와 분리 가능한 독립 P0로 취급하기로 확정. appetite 초과 시에도 maintainer satellite pointer 추가는 이번 Work에서 우선 완료하고, 잔여 maintainer prose rewrite만 후속 slice로 분리 가능하게 둔다. | 사용자 승인 반영 후 STATUS Active pointer 추가 및 EXECUTE 진입. | Reviewed |
| R1 | Codex | Result | P0/P1 1차 구현으로 `README.md`, `docs/SCAFFOLD-ONBOARDING-GUIDE.md`, `docs/WORKFLOW-MANUAL.md`, `docs/HARNESS-MAINTAINER-GUIDE.md`의 진입 문장과 reading path를 다듬었다. README에는 첫 시작 순서와 maintainer satellite pointer를 보강했고, onboarding guide에는 scaffold 직후 첫 `/session-start`의 목표와 미완료 상태 설명을 추가했으며, workflow manual은 "이 문서를 언제 읽고 언제 SSoT로 가야 하는가"를 더 선명하게 했다. maintainer guide에는 `docs/maintainer/` 하위 핵심 문서 포인터를 신설했다. | Claude R1 result review 요청. | Done |
| R1-review | Claude | Result Review | Done Criteria 9개 모두 충족 확인. constraint 3종 보존 확인. SSoT leakage 없음. `HARNESS-MAINTAINER-GUIDE.md` §2-a 포인터 표 구현 양호. 관찰: `HARNESS-TEST-TAXONOMY.md`가 README maintainer 표에 없음(HARNESS-MAINTAINER-GUIDE에는 있음), WORKFLOW-MANUAL 본문 미변경(appetite 내 한계). `create-harness.sh` 인자 설명 누락도 별도 처리. | (1) README maintainer 표에 `HARNESS-TEST-TAXONOMY.md` 추가. (2) `create-harness.sh` 인자 설명 README 2곳 추가. — Claude가 직접 처리. | Done |

### Consensus Log

| Topic | Consensus | Source Round | Status |
| --- | --- | --- | --- |
| satellite pointer audit 우선순위 | HARNESS-MAINTAINER-GUIDE.md의 satellite pointer 추가는 P1 전체 rewrite와 분리해 독립 P0로 처리. appetite 초과 시에도 이번 Work에서 먼저 완결. | R0-recheck | Done |
| canonical 재서술 경계 | canonical workflow/protocol 내용을 user-facing 문서에서 해설·재서술·도식화해 SSoT 역할을 이전하는 것 금지. pointer만 허용. | R0-review | Done |
| 4개 문서 P0/P1 분리 | README + SCAFFOLD-ONBOARDING-GUIDE를 P0, WORKFLOW-MANUAL + HARNESS-MAINTAINER-GUIDE prose를 P1로 분리. appetite 초과 시 P1은 후속 Work로 이관 가능. | R0-recheck | Done |

## Discovery

- 2026-06-12 session resume: `develop` clean 상태에서 PR #154 merge 직후 다음 후보로 `User-facing docs readability rewrite` 착수 요청을 받음.
- 2026-06-12 branch isolation: `policy_type: source-gitflow` 규칙에 따라 `feature/chore-20260612-002-user-facing-docs-readability-rewrite` branch 생성 후 계획 단계 진입.
- 2026-06-12 backlog 확인: `docs/backlog/HARNESS.md`의 W2 candidate로 `User-facing docs readability rewrite — audience-aware README/MANUAL/GUIDE`가 유지되고 있으며, planning pack과 multi-user clone verification 사이의 별도 작업으로 남아 있음.
- 2026-06-12 current surface review: `README.md`, `docs/SCAFFOLD-ONBOARDING-GUIDE.md`, `docs/WORKFLOW-MANUAL.md`, `docs/HARNESS-MAINTAINER-GUIDE.md`를 1차 점검. 문서 역할 분리는 존재하지만, 문장 밀도와 첫 행동 안내 방식은 표면별 편차가 큼.
- 2026-06-12 maintainer discoverability note: `docs/HARNESS-MAINTAINER-GUIDE.md`에는 현재 `docs/maintainer/` 하위 핵심 문서 포인터가 없다. 이번 readability rewrite는 문장 품질뿐 아니라 메인 문서→satellite 문서 discoverability도 함께 점검한다.
- 2026-06-12 retrospective reference: `docs/retrospectives/harness-workflow-strictness-20260606.md` 1건 확인. source repo strictness는 source-only로 갇혀 있고 agent 비용은 낮다는 결론은 유지하되, 이번 Work에서는 workflow strictness 재설계가 아니라 human-facing 설명 품질만 다룬다.
- 2026-06-12 related history: CHORE-20260606-002는 신규 top-level audience 문서 분리를 반대하고 기존 문서 경계 선명화를 택했으며, CHORE-20260611-011은 objective cascade와 readability rewrite를 분리했다. 이번 Work는 그 합의를 잇는다.
- 2026-06-12 execution note: 우선순위는 README + `docs/SCAFFOLD-ONBOARDING-GUIDE.md`를 P0, `docs/WORKFLOW-MANUAL.md` + `docs/HARNESS-MAINTAINER-GUIDE.md` prose rewrite를 P1로 본다. 단, `docs/HARNESS-MAINTAINER-GUIDE.md`의 `docs/maintainer/` satellite pointer audit/추가는 독립 P0로 취급해 appetite 초과 여부와 무관하게 이번 Work에서 먼저 닫는다.
- 2026-06-12 execution start: P0 1차 수정으로 `README.md`, `docs/SCAFFOLD-ONBOARDING-GUIDE.md`, `docs/HARNESS-MAINTAINER-GUIDE.md`를 우선 보강했다. README에는 첫 시작 순서와 maintainer satellite pointer를 추가했고, onboarding guide에는 첫 `/session-start`의 목표와 미완료 상태 설명을 보강했으며, maintainer guide에는 `docs/maintainer/` 하위 핵심 문서 포인터를 신설했다.
- 2026-06-12 execution continue: `docs/WORKFLOW-MANUAL.md` 도입부를 "왜 읽는지 / 언제 다른 문서로 가야 하는지" 중심으로 재작성해 user manual과 canonical SSoT의 경계를 더 분명히 했다.
- 2026-06-12 validation snapshot: `git diff --check` clean. constraint survival 기준으로 branch isolation / Approval Matrix / source-vs-target 경계 표현이 대상 문서들에 남아 있는지 grep으로 재확인했고, `README.md` 및 `docs/HARNESS-MAINTAINER-GUIDE.md`에서 maintainer satellite 문서 포인터 존재를 확인했다.
