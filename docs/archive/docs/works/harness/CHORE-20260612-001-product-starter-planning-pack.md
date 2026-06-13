---
id: CHORE-20260612-001
priority: P1
status: Archived
risk: L3
scope: source repo 기준의 product starter planning pack과 source->scaffolded project->source feedback import loop 설계에 한정한다. planning pack 산출물 구조, source/scaffold 경계, base-msa-template 분석 범위, human-in-the-loop 경계, verification placeholder 구체화까지 다룬다. user-facing readability rewrite, multi-user clone verification, helper/script 자동화 확장, 실제 product repo 적용 구현은 범위 밖이다.
appetite: 1.5d
planned_start: 2026-06-12
planned_end: 2026-06-13
actual_end: 2026-06-12
related_dr: [DR-031]
related_work: [CHORE-20260611-007, CHORE-20260611-009, CHORE-20260611-010, CHORE-20260611-011]
---

# CHORE-20260612-001: Product Starter Planning Pack + Feedback Import Loop

## Top Summary

- **목표:** 다음 실제 product 착수 전에, source repo가 먼저 제공할 planning template/skeleton의 산출물과 순서를 정의하고, scaffolded project에서 검증된 산출물을 source option-pack 후보로 검토하는 provisional import loop를 설계한다.
- **왜 지금:** W2의 선행 과제였던 upgrade/migration(CHORE-20260611-010)과 docs cascade(CHORE-20260611-011)가 닫혔다. 이제 실제 product 적용 전 남은 핵심 gap은 "무엇을 source에서 먼저 만들고, 무엇을 product repo에서 검증한 뒤 다시 source에 반입할지"를 구조적으로 정하는 것이다.
- **핵심 경계:** 이번 Work는 planning pack 설계다. user-facing docs readability rewrite와 혼합하지 않고, scaffold multi-user clone verification이나 helper/script 자동화 확장도 조기 포함하지 않는다.
- **실행 원칙:** source-only maintainer 문서는 pointer 중심을 유지하고, product-local harness 산출물은 scaffolded project에서 실제 검증된 뒤에만 source option-pack 후보로 승격 검토한다. 아직 검증된 실제 import candidate 사례는 없으므로, loop 자체도 첫 product use 후 재검토 대상이다.

## Candidate Selection Review

| 후보 | 판단 | 이유 |
| --- | --- | --- |
| Product starter planning pack + feedback import loop | **선택** | 다음 실제 product 착수 직전의 가장 큰 불확실성이다. CHORE-20260611-007의 Layer U가 아직 criteria placeholder라, planning pack 설계가 있어야 후속 concrete verification과 option-pack 판단이 가능하다. |
| User-facing docs readability rewrite | 보류 | CHORE-20260611-011에서 의도적으로 분리한 항목이다. 이번 Work에 섞으면 청중/톤 재작성과 planning pack 구조 설계가 혼합되어 검증 기준이 흐려진다. |
| Scaffold multi-user clone verification | 보류 | 중요하지만 planning pack보다 하위 검증 성격이 강하다. planning pack이 실제 scaffold repo 주입 경로를 정의한 뒤 그 경로를 대상으로 검증하는 편이 순서가 맞다. |

## Background / Facts

- `docs/STATUS.md`와 `docs/backlog/HARNESS.md` 모두 W2 잔여 항목을 planning pack / readability rewrite / multi-user clone verification 세 갈래로 정리하고 있다.
- CHORE-20260611-010은 pre-manifest adopter upgrade/migration 경로를 inventory-first로 정립했고, Layer T를 실행형 검증으로 승격했다. 따라서 이번 Work는 "기존 adopter를 현재 source에 맞추는 법" 다음 단계로 "새 product를 source에서 어떻게 시작하게 할지"를 다룬다.
- CHORE-20260611-011은 README / maintainer map / onboarding surface의 cascade debt를 닫았고, readability rewrite는 별도 candidate로 유지하기로 합의됐다. 따라서 이번 Work에서 README/MANUAL/GUIDE의 문체 개선을 다시 끌어오면 직전 합의를 깨게 된다.
- `docs/maintainer/VERIFICATION-COMMANDS.md`의 Layer U는 product pack verification 자리만 잡아둔 상태다. planning pack 산출물과 source/scaffold/import loop가 정의되어야 U2~U4를 structured checklist 수준으로 구체화할 수 있다.
- `/Users/kyungseo/dev-home/vibe/base-msa-template`는 이번 Work의 참고 자산이지만, template-specific 파일/경로 inventory는 generic 기준 문서가 아니라 Work Discovery에 남기는 것이 맞다.
- 세션 시작 실측 기준 `develop == origin/develop`였고, archive pending은 `CHORE-20260611-010` 1건만 남아 있다. 새 Work는 이 archive pending hygiene와 분리한다.

## Scope / Plan

> 구현 전 Claude R0 plan review 대상. helper/script 자동화는 이번 plan 승인 범위에 포함하지 않는다.

### Scope

1. **planning pack problem framing**
   - source repo가 실제 product 착수 전에 제공해야 하는 planning template/skeleton의 목적, 대상 독자, 사용 시점, product-local harness와의 경계를 정의한다.
   - planning pack이 user-facing docs rewrite와 다른 이유를 명시한다.
2. **pack artifact set 정의**
   - PRD, TRD, architecture, code conventions, user flow, DB design, screen flow, tasks, test structure, `loop.md` 후보를 비교하되, source가 먼저 둘 수 있는 template/skeleton과 product repo에서 채워야 하는 실제 내용을 분리한다.
   - 자동처리와 인간개입 경계를 각 산출물별로 선언한다.
3. **source -> scaffolded project -> source import loop 설계**
   - source에서 planning template/skeleton 작성 -> scaffold repo 주입 -> product repo에서 concrete화 -> 일반화 가능한 산출물 선별 -> source option-pack 후보 검토의 단계별 계약을 정의한다.
   - "무엇이 source-owned / product-owned / shared candidate인가"를 분류한다.
   - 아직 검증된 실제 사례가 없다는 점과 첫 product use 후 재검토가 필요하다는 점을 명시한다.
4. **template 분석 프레임 정의**
   - 어떤 문서/코드를 planning pack seed로 읽고, 어떤 harness 운영 잔재를 제외할지 generic checklist로 정리한다.
   - 특정 template의 실제 파일/경로 inventory는 Work Discovery에 남긴다.
   - enterprise-grade gap 분석의 범위를 정하되, 실제 리팩토링 구현이나 example pack 작성은 하지 않는다.
5. **verification placeholder 구체화**
   - Layer U와 충돌하지 않도록 planning pack 검증 항목을 concrete criteria 수준으로 정리한다.
   - 실제 script/helper 추가는 후속 Work 후보로 남긴다.

### Non-goals

- README / WORKFLOW-MANUAL / GUIDE류의 readability/tone rewrite.
- generic/source-gitflow multi-user clone 시뮬레이션 실행.
- `scripts/create-harness.sh` 또는 신규 helper/script 구현.
- 실제 scaffolded product repo 생성/주입/개발 수행.
- `/Users/kyungseo/dev-home/vibe/base-msa-template`의 대규모 코드 리팩토링.
- option-pack 실제 생성 또는 source repo 반영.
- `docs/STATUS.md` Active pointer 추가. R0 합의/사용자 승인 전에는 변경하지 않는다.

### Files

| 파일 | 변경 | 비고 |
| --- | --- | --- |
| `docs/works/harness/CHORE-20260612-001-product-starter-planning-pack.md` | 생성 | Work SSoT |
| `docs/works/harness/README.md` | Active 등록 | Work index |
| `docs/maintainer/PRODUCT-STARTER-PLANNING-PACK.md` | 생성 | source-only 기준 문서 |
| `docs/maintainer/VERIFICATION-COMMANDS.md` | 변경 | Layer U criteria concrete화 |
| `docs/maintainer/SOURCE-REPO-OPERATIONS.md` | 변경 | source repo runbook에 product starter/import row 추가 |
| `docs/maintainer/README.md` | 변경 | maintainer map에 planning pack 기준 문서 등록 |
| `docs/backlog/HARNESS.md` | 기본 제외 | 이번 slice에서는 backlog candidate 문구 자체는 변경하지 않음 |
| `docs/STATUS.md` | 변경 | 사용자 승인 후 Active pointer 추가 |

## Done Criteria

- [x] planning pack의 필수/선택 산출물과 작성 순서가 정의된다.
- [x] planning pack과 user-facing docs rewrite의 경계가 명시된다.
- [x] source-owned / scaffolded-product-owned / import-candidate 산출물 분류가 정의된다.
- [x] template 분석 범위와 제외 범위가 generic 기준으로 명시되고, template-specific inventory는 Work 기록으로 분리된다.
- [x] 자동처리 vs 인간개입 경계가 loop 절차에 포함된다.
- [x] verification 항목이 criteria 수준으로 구체화되고, helper/script 조기 확장 금지가 유지된다.
- [x] import loop가 아직 실사례 없는 provisional skeleton이며 첫 product use 후 재검토 대상임을 명시한다.
- [x] Claude R0 plan review와 R1 result review가 `Cross-Agent Review And Discussion` 섹션에 누적된다.

## Verification

1. `git diff --check`.
2. planning pack artifact matrix가 W2 후보(readability rewrite, multi-user clone verification)와 scope overlap 없이 구분되는지 grep 및 문안 검토.
3. `base-msa-template` 분석 checklist가 "현재 읽을 것 / 제외할 것 / 후속 검증할 것"을 구분하는지 확인.
4. source vs scaffolded project boundary 점검:
   - source-only maintainer 문서에 product-local manual 성격이 섞이지 않는지
   - user-facing rewrite 요구가 이번 diff에 침투하지 않는지
5. Layer U 관련 변경이 생기면 placeholder를 성급한 명령으로 치환하지 않았는지 확인.

## Risk / Reversal Cost

- **Risk:** L3. planning pack은 다음 product 시작 방식, source/scaffold 경계, option-pack 반입 기준을 정하는 구조 설계다.
- **주요 리스크 1:** planning pack과 readability rewrite가 다시 섞이면 문체 논의가 구조 설계를 가리고, 검증 기준이 주관화된다. 이번 Work에서는 문체 재작성 금지를 명시한다.
- **주요 리스크 2:** helper/script를 너무 일찍 확장하면 CHORE-20260611-007의 "criteria placeholder 우선" 원칙을 깨고 premature automation이 된다. 이번 slice는 문서/절차 설계까지만 제한한다.
- **주요 리스크 3:** base-msa-template를 기준 자산으로 삼되 legacy/harness 잔재를 걸러내지 못하면 source option-pack이 과거 결함을 가져올 수 있다. 분석 checklist를 먼저 만든다.
- **주요 리스크 4:** source-owned와 product-owned 경계가 흐리면 source repo가 product-local 결정을 빨아들이는 anti-pattern이 생긴다. import candidate 기준을 별도로 둔다.
- **Reversal Cost:** Medium. Work 파일과 설계 문서, verification criteria 변경은 되돌릴 수 있지만, 이후 product starter와 option-pack 판단의 기준이 되므로 되돌리기 비용이 단순 문서 수정보다 높다.

## Open Questions

| ID | Question | 기본 제안 |
| --- | --- | --- |
| OQ-1 | planning pack의 최소 산출물은 어디까지인가? | PRD/TRD/architecture/tasks/test structure를 core로 두고, 나머지는 optional 후보로 비교한다. |
| OQ-2 | `loop.md`는 source pack 기본 산출물인가, product-local 산출물인가? | source는 skeleton/policy만, concrete loop는 product-local 쪽에 둔다. |
| OQ-3 | `base-msa-template`에서 code까지 읽을 것인가? | 읽되, 초기 harness 잔재를 제외하는 checklist를 먼저 정의한다. |
| OQ-4 | verification Layer U를 이번에 executable로 올릴 것인가? | 아니오. criteria concrete화까지만 하고 executable 승격은 후속 Work 후보로 남긴다. |
| OQ-5 | planning pack 산출물을 source option-pack으로 자동 반입할 것인가? | 아니오. product repo에서 검증된 일반화 가능 산출물만 별도 Work에서 승격 판단한다. |
| OQ-6 | 이번 Work에서 신규 DR이 필요한가? | source/scaffold/import ownership 정책이 Medium 이상 결정으로 굳어지면 Draft DR 후보를 closeout 전에 제안한다. |

## State / Approval

- **위험도:** L3.
- **실행 모드:** Full Work.
- **현재 상태 머신:** DONE.
- **approval gating note:** 이 Work는 사용자의 "Work 파일 + plan 먼저, STATUS Active pointer는 R0 합의/승인 전까지 미변경" 지시에 맞춰 Work file과 Work index를 먼저 생성했다. frontmatter `status: Active`와 Work index Active 등록은 Work SSoT 초안 추적용이며, 실행 승인과 `docs/STATUS.md` Active pointer 추가는 별도 승인 게이트로 유지한다.
- **Tool Rule Reference:** `.claude/rules/docs-workflow.md`, `.claude/rules/git-workflow.md` 수동 적용. DR-007 적용: docs는 한국어 주 언어 + Bilingual Rules.
- **risk rationale:** 실제 변경 파일 수는 적지만, 이번 Work는 source/scaffold/import ownership 경계와 다음 product starter의 구조를 정의하는 policy/architecture 설계다. 파일 수보다 결정의 파급 범위를 기준으로 L3로 유지한다.
- **PLAN 영향:** AWH-004의 "adopter upgrade/migration, onboarding 현행화" 다음 단계와 정렬된다. 다만 planning pack 결과가 source option-pack 방향을 바꾸면 closeout 시 `docs/PLAN.md`/`docs/PLAN-SUMMARY.md` 영향 여부를 재확인해야 한다.
- **STATUS Update Note:** 사용자 승인 후 `docs/STATUS.md` Active Work에 `CHORE-20260612-001` pointer를 반영했고, work-close 승인 후 closeout에서 pointer를 제거했다.

## Cross-Agent Review And Discussion

> 이번 세션 역할: Codex = author/driver, Claude = reviewer. 리뷰/결과 정리는 한국어 중심으로 누적한다.

### Review Request

Claude R0 plan review 요청: CHORE-20260612-001 Product Starter Planning Pack + Feedback Import Loop

검토 초점:

- 지금 실제로 planning pack이 readability rewrite / multi-user clone verification보다 먼저여야 하는가?
- source repo와 scaffolded project의 경계가 산출물/loop 설계에서 충분히 분리되어 있는가?
- `base-msa-template` 분석 범위가 과도하지 않고, helper/script 조기 확장을 막는가?
- Layer U placeholder를 성급한 실행 명령으로 바꾸지 않고 criteria concrete화 수준에 머무르는가?
- product-local harness 산출물의 source import 기준이 충분히 보수적인가?

### Round Log

| Round | 주체 | 유형 | 요약 | Required Changes / Decision | Status |
| --- | --- | --- | --- | --- | --- |
| R0 | Codex | Plan | W2 잔여 3후보를 비교한 뒤 planning pack을 우선 선택. docs rewrite와 clone verification을 의도적으로 분리하고, source/scaffold/import ownership 경계와 Layer U criteria concrete화를 이번 slice의 핵심으로 제안. | Claude R0 plan review 요청. | Reviewed |
| R0-review | Claude | Plan Review | 순서·경계·범위·Layer U 처리·import 보수성 5개 검토 초점 모두 승인. 변경 요구 없음. 다만 frontmatter `status: Active` vs `PLAN -> APPROVAL` 표기 불일치, risk L3 vs L2 분류 근거 2건 확인 요청. | Codex가 확인-1 의도와 확인-2 위험도 확정 근거를 기록. | Pending Codex Response |
| R0-response | Codex | Plan Clarification | 확인-1: 사용자의 "Work 파일 + plan 먼저, STATUS Active pointer는 R0 합의/승인 전까지 미변경" 지시에 맞춰 Work file과 Work index를 먼저 생성했고, 실행 승인/STATUS pointer는 별도 게이트로 유지한다는 점을 `State / Approval`에 명시. 확인-2: 실제 변경 파일 수는 적지만 source/scaffold/import ownership 경계와 next product starter policy를 정하는 구조 설계이므로 파급 범위 기준 L3를 유지. | 사용자 승인 시 STATUS Active pointer proposal 후 EXECUTE로 전환. | Reviewed |
| R1 | Codex | Result | source-only 기준 문서 `docs/maintainer/PRODUCT-STARTER-PLANNING-PACK.md`를 신설해 source-first seed pack / product-local expansion / import candidate 분류, 작성 순서, source->product->source loop skeleton, human gate, template 분석 기준, 승격 금지 신호를 정리. `VERIFICATION-COMMANDS.md` Layer U의 U2~U4를 이 기준 문서에 맞춰 structured checklist/review aid로 구체화하고, `SOURCE-REPO-OPERATIONS.md`와 `docs/maintainer/README.md`에 진입 pointer를 추가. | Claude R1 result review 요청. | Reviewed |
| R1-review | Claude | Result Review | 내적 정합성은 높으나 방향 이의 2건(import loop premature, source-first 전제 역전 가능성)과 변경 요구 1건(template-specific 경로가 generic 문서에 포함됨)을 제기. import loop는 아직 실사례 없는 provisional skeleton임을 명시하고, source-first를 template/skeleton 제공으로 해석할지 결정 요청. | Codex가 generic 문서에서 template-specific inventory를 제거/일반화하고, import loop와 source-first 전제를 더 보수적으로 재기록. | Changes Requested |
| R1-response | Codex | Result Fix | template-specific `base-msa-template` 파일/경로 inventory를 generic maintainer 문서에서 제거하고 generic template 분석 기준으로 축소. source-first를 "product 내용을 source에서 먼저 쓰는 것"이 아니라 "template/skeleton을 source가 먼저 제공하는 것"으로 재정의. import loop와 review aid는 아직 실사례 없는 provisional skeleton이며 첫 concrete product use 후 재검토 대상임을 명시. Layer U의 U2~U4 표현도 `concrete`에서 `structured`로 낮춰 과장 가능성을 줄임. | Claude R1a result re-review 요청. | Reviewed |
| R1a-review | Claude | Result Re-review | R1 피드백 3건 대부분 실질 반영 확인. 잔여 minor 1건으로 generic 기준 문서 Section 2에 남아 있는 local path 하드코딩 제거 요청. Section 5의 OQ 순서는 관찰 사항으로만 기록. | Codex가 Section 2 bullet을 generic 표현으로 수정. | Changes Requested |
| R1a-response | Codex | Result Fix | `docs/maintainer/PRODUCT-STARTER-PLANNING-PACK.md` Section 2의 local path bullet을 `template 분석 include/exclude 기준`으로 일반화해 generic 기준 문서와 실제 내용을 일치시킴. Section 5 OQ 순서 관찰은 non-blocking 메모로 유지. | Claude 승인 또는 work-close 판단 가능. | Reviewed |

### Consensus Log

| Topic | Consensus | Source Round | Status |
| --- | --- | --- | --- |
| Work 선택 | planning pack이 W2의 다음 1순위 후보 | R0-review | Approved |
| Scope 경계 | readability rewrite와 multi-user clone verification은 이번 Work에 섞지 않음 | R0-review | Approved |
| Source/target ownership | source-owned / product-owned / import-candidate를 분리 설계 | R0-review | Approved |
| Approval gating | Work file/frontmatter와 Work index는 초안 추적용으로 먼저 둘 수 있지만, 실행 승인과 `docs/STATUS.md` Active pointer는 별도 게이트로 유지 | R0-response | Clarified |
| Risk level | 이 Work는 파일 수가 아니라 source/scaffold/import ownership 정책의 파급 범위를 기준으로 L3로 유지 | R0-response | Clarified |
| Durable surface | planning pack 결과는 user-facing 문서가 아니라 `docs/maintainer/` source-only 기준 문서로 유지 | R1 | Implemented |
| Layer U 방향 | executable 승격 없이 U2~U4를 structured checklist/review aid로 구체화 | R1-response | Clarified |
| Source-first 의미 | source maintainer가 product 내용을 대신 쓰는 것이 아니라 template/skeleton을 먼저 제공하는 뜻으로 해석 | R1-response | Clarified |
| Import loop 성격 | 아직 실사례 없는 provisional skeleton이며 첫 concrete product use 후 재검토 필수 | R1-response | Clarified |

## Discovery

- 2026-06-12 session start: `develop == origin/develop`, working tree clean 확인 후 branch isolation rule에 따라 `feature/chore-20260612-001-product-starter-planning-pack` 생성.
- 2026-06-12 session start: `docs/works/harness/README.md` 기준 archive pending은 `CHORE-20260611-010` 1건만 남아 있음. 이번 Work와 분리 유지.
- 2026-06-12 candidate review: W2 잔여 후보는 planning pack / readability rewrite / multi-user clone verification 3건이며, planning pack이 다음 실제 product 시작 전 구조적 공백을 가장 직접적으로 메운다고 판단.
- 2026-06-12 Claude R0 review: 변경 요구 없이 승인 가능. frontmatter `status: Active`와 `PLAN -> APPROVAL`의 관계, risk L3 유지 근거를 명시해달라는 확인 요청 2건을 받음.
- 2026-06-12 Codex clarification: Work file/frontmatter와 Work index는 사용자 지시에 맞춘 초안 추적용으로 유지하고, 실행 승인 및 `docs/STATUS.md` Active pointer는 별도 승인 후 반영하기로 명시. risk는 artifact 수가 아니라 source/scaffold/import ownership 정책의 파급 범위를 기준으로 L3 유지.
- 2026-06-12 user approval: plan 및 `docs/STATUS.md` Active pointer proposal 승인. 실행 단계 진입.
- 2026-06-12 state update: `docs/STATUS.md` Active Work에 `CHORE-20260612-001` pointer 추가.
- 2026-06-12 implementation: `docs/maintainer/PRODUCT-STARTER-PLANNING-PACK.md` 신설. source-first core pack, product-local expansion, import candidate 분류와 source->product->source loop, human-in-the-loop 경계, `base-msa-template` include/exclude/reference-only 기준을 정리.
- 2026-06-12 implementation: `VERIFICATION-COMMANDS.md` Layer U의 U2~U4를 placeholder에서 concrete checklist/review aid로 구체화. 아직 executable path check로 승격하지는 않고, 실제 경로/파일명 확정 전까지 criteria/checklist로 유지.
- 2026-06-12 implementation: `SOURCE-REPO-OPERATIONS.md` 변경 유형 매트릭스에 product starter planning pack / import loop row 추가. `docs/maintainer/README.md`에 새 기준 문서를 source-only maintainer 자산으로 등록.
- 2026-06-12 Claude R1 review: import loop가 아직 실사례 없는 상태에서 premature할 수 있고, source-first가 product 내용을 source에서 먼저 쓰는 뜻으로 읽힐 수 있다고 지적. generic 기준 문서에 template-specific `base-msa-template` 경로가 들어간 점은 변경 요구로 접수.
- 2026-06-12 Codex fix: generic maintainer 문서에서 template-specific inventory를 제거하고 generic template 분석 기준으로 축소. source-first는 template/skeleton seed 제공 의미로 재정의. import loop와 review aid는 첫 concrete product use 후 재검토가 필요한 provisional skeleton임을 명시. Layer U의 표현도 `structured`로 낮춰 executable 의미 오해를 줄임.
- 2026-06-12 Claude R1a re-review: 주요 지적은 해소됐고, Section 2에 local path 하드코딩 1건만 남았다고 확인. Section 5의 OQ/assumptions 순서는 관찰 사항으로 기록.
- 2026-06-12 Codex fix: `docs/maintainer/PRODUCT-STARTER-PLANNING-PACK.md` Section 2 bullet을 generic 표현으로 수정해 local path 하드코딩 제거.
- 2026-06-12 work-close: 사용자 승인 후 Done Criteria 전부 충족으로 확정. Work frontmatter를 `Done`으로 닫고, Work index/STATUS/backlog closeout 반영 진행.
