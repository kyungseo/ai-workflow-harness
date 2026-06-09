---
id: CHORE-20260609-002
priority: P2
status: Done
risk: L2
scope: DR 등록 시 결정 성숙도 3-way triage(Accepted/Draft/OQ) 도입 + Draft DR 생명주기(생성·EXIT·hygiene) 명문화(DR-029, Accepted). 첫 Draft DR로 모국어/영어권 언어 규정 i18n 전략을 작성(DR-030, Draft). HARNESS.md P2(1) "DR-007 rule scope 명확화"를 DR-030으로 흡수.
appetite: 1d
planned_start: 2026-06-09
planned_end: 2026-06-09
actual_end: 2026-06-09
related_dr: [DR-007, DR-011, DR-013, DR-029, DR-030]
related_troubleshooting: []
related_work: []
---

# CHORE-20260609-002: Draft DR 체계 도입 + 언어 전략 Draft DR

## Top Summary

- **목표:** Draft DR을 처음으로 live 운영하기 위한 등록·생명주기 체계를 명문화하고(DR-029, Accepted), 그 체계를 첫 케이스(언어/i18n 전략, DR-030 Draft)로 실증한다.
- **핵심 결정 (사용자 승인):**
  - DR 등록은 **3-way triage**: ① 결정 완료 → Accepted DR / ② DR감이나 선택 보류 → Draft DR / ③ DR감 아님 → OQ(STATUS)·backlog. 첫 판정(DR-worthy 여부)은 기존 T1/work-plan 기준 **재사용**, 둘째 축(결정/보류)만 신설.
  - Draft DR EXIT 3종: promote→Accepted(필요 시 DR-007 amend) / Superseded by DR-XXX→archive / Draft(Dropped)→archive.
  - Draft 누적 hygiene = `/repo-health`에서 **soft surfacing**(Draft 목록+age 나열, hard gate 아님). cascade 감사는 Accepted-only 유지.
  - 결정 성격이 갈리므로: triage 체계 자체 = **Accepted(DR-029)**, 언어 전략 = **Draft(DR-030)** — 두 경로를 한 Work에서 동시 실증.
- **언어 전략(DR-030) 초점:** 모국어(한국어)/영어권 사용자에 대한 효율적 언어 규정을 어떻게 가져갈 것인가(DR-007 참고, i18n). "영어권 유입" 뉘앙스는 제외. 옵션에 scaffold `--lang en`(en-only artifact) 지원 포함.
- **비목표:** 언어 전략의 실제 채택/실행(DR-030은 Draft로 보류), DR-007 amend 실행(승격 시점), HARNESS.md P2(2)(3)(무관).

## Context Manifest

- 참조: `docs/decisions/DR-007`(언어 정책), `DR-011`(Recent Decisions rolling), `DR-013`(Work spec), `docs/decisions/README.md`(Status legend·cascade=Accepted-only), `docs/HARNESS-PROTOCOL.md` §383 DR lifecycle·T1 trigger, `skills/workflow/record-decision.md`, `skills/workflow/repo-health.md`, `docs/backlog/HARNESS.md:302` P2(1).
- 전제: Status legend에 `Draft — 초안`은 이미 존재하나 live DR로 사용된 적 없음(첫 사용).

## Scope / Plan

### Part A — DR 등록·생명주기 체계 (DR-029, Accepted)

| 순서 | 대상 | 작업 |
| --- | --- | --- |
| A1 | `docs/decisions/DR-029-*.md` (신규) | 3-way triage + Draft 생성/EXIT/hygiene + 완전성 항목 A~E 기록 (Accepted) |
| A2 | `skills/workflow/record-decision.md` (canonical) | 등록 절차에 3-way triage 1줄 제안 추가. DR-worthy 기준은 재서술 없이 참조 |
| A3 | cascade | `.claude/commands/record-decision.md`, `.agents/skills/workflow-record-decision/SKILL.md`, `.cursor/rules/workflow.mdc` 정합 점검(adapter는 포인터만) |
| A4 | `skills/workflow/repo-health.md` (+cascade) | Draft DR hygiene surfacing 추가. cascade 감사=Accepted-only와 **분리 명시** |
| A5 | `docs/decisions/README.md` | Draft index 표기 방식 확정(필요 시), DR-029 행 추가 |
| A6 | `docs/HARNESS-PROTOCOL.md` | Draft lifecycle 최소 보강(분석 결과 필요한 만큼만 — 과설계 금지) |

**DR-029 완전성 항목(접어넣음):** A) Draft content spec(Question/Options/Open Points/Promotion Conditions 필수, Decision/Consequences는 promote 시) B) Recent Decisions 연동(생성=미등재, promote=등재 후보) C) Discard 번호 retire(재사용 금지) D) repo-health 두 기능 분리 E) triage는 기존 DR-worthy 기준 재사용.

### Part B — 언어/i18n 전략 (DR-030, Draft)

| 순서 | 대상 | 작업 |
| --- | --- | --- |
| B1 | `docs/decisions/DR-030-*.md` (신규, Status: Draft) | Question + Options(①현행 ②source-facing 정리(P2(1) 포함) ③scaffold `--lang en` ④per-adopter i18n) + 비대칭 비용 분석 + Open Points + Promotion Conditions. "영어권 유입" 표현 미포함 |
| B2 | `docs/decisions/README.md` | DR-030(Draft) 행 추가 |
| B3 | `docs/backlog/HARNESS.md` | P2(1) "DR-007 rule scope 명확화"를 DR-030 흡수로 정리(develop merge 후 tracking-only 처리 가능) |

## Done Criteria

- [x] DR-029(Accepted): NET-NEW 5개(triage / 승격 프로세스 / Dropped / repo-health surfacing / 템플릿 섹션)만 기록, 기존 lifecycle은 참조
- [x] `record-decision`(canonical) §Procedure에 3-way triage + 승격 프로세스 반영 + cascade(commands/skill/cursor), DR-worthy 기준 재서술 없음
- [x] `DECISION-TEMPLATE.md`에 Open Points / Promotion Conditions 섹션 추가
- [x] `record-decision §DR Lifecycle`에 Dropped 상태 + 번호 retire 추가
- [x] `repo-health`에 Draft hygiene surfacing, cascade 감사 Accepted-only와 분리 명시
- [x] DR-030(Draft): 옵션 4종 + open points + 승격 조건, "영어권 유입" 미포함, scaffold `--lang en` 옵션 포함
- [x] HARNESS.md P2(1)을 DR-030으로 흡수 정리
- [x] decisions/README index에 DR-029(Accepted)·DR-030(Draft) 행 추가
- [x] **사용자 최종 리뷰** 후 Done (2026-06-09 리뷰 OK)
- [x] Scaffold dangling 방지: create-harness.sh에 DR-029 foundational 추가 (정적 검증, full dry-run은 실행 거부로 미수행)

## Verification

- `git diff --check`; DR-007 언어 정책 준수(DR 본문·README=Korean primary, rule/adapter 영어 규칙)
- cascade: canonical→adapter(record-decision/repo-health) 정합 grep; Draft 추가가 `/repo-health` Accepted-only 감사를 깨지 않는지 확인
- scaffold: record-decision/repo-health 변경이 `create-harness.sh` 산출물에 전파되는지 dry-run(해당 시)
- 링크 정합: DR-029 ↔ DR-030 ↔ DR-007 ↔ HARNESS.md

## Risk / Reversal

- L2. Risk: Draft lifecycle 명문화가 core 문서를 부풀릴 위험 → 최소 보강 원칙으로 억제. repo-health hygiene이 noise가 될 위험 → soft·Draft-only 나열로 제한.
- Reversal: Low — 문서·canonical 절차, revert 가능. DR-030은 Draft라 후속 행동 강제 없음.

## Checkpoints

- (착수) Work 생성, STATUS Active pointer 추가.
- (CP-1, 2026-06-09) Part A 완료: DR-029(Accepted) 생성, record-decision §Procedure triage + §Draft DR + §DR Lifecycle Dropped, DECISION-TEMPLATE Open Points/Promotion Conditions, repo-health Draft hygiene surfacing, decisions/README legend+index. adapter 3종 포인터-only 확인(변경 불요).
- (CP-2, 2026-06-09) Part B 완료: DR-030(Draft) 생성, README Draft 행, HARNESS.md P2(1) DR-030 흡수 표시.
- (CP-3, 2026-06-09) Scaffold 영향도: 복사 canonical이 DR-029 참조 → dangling 방지 위해 create-harness.sh에 DR-029 copy + 생성 README legend/index 추가. manifest는 adapt() 자동 누적. `bash -n` OK. full dry-run 생성은 실행 거부로 미수행(정적 검증으로 대체, 기존 DR-007/008/013/014/027 패턴과 동일하여 risk Low).

## Next Actions

- Part A(DR-029 + record-decision/repo-health) 먼저 → Part B(DR-030) 작성.

## Discovery

- 착수 시 backlog `HARNESS.md:302` P2(1) "DR-007 rule scope 명확화" candidate를 본 Work(DR-030)로 흡수.
- 직전 commit에서 `CHORE-20260609-001`이 tracking ID로 소비되어 본 Work는 `-002` 사용(ID 재사용 금지).
- **[2026-06-09 영향도 분석] Draft DR 인프라 상당수 기존재 → DR-029 re-scope:**
  - 기존재(참조만, 재서술 금지): Draft 상태 정의·"PR merge 전 유지"(`DECISION-TEMPLATE.md:4,11`, `record-decision §DR Lifecycle`), Draft에서 Decision 빈 칸(`DECISION-TEMPLATE.md:28`), Draft=PLAN cascade 미발동(`record-decision:51`), Draft=cascade 감사 제외(`HARNESS-PROTOCOL §390`), Superseded/archive/parent-child/linked, DR-worthy 기준(`record-decision §DR-Worthy Criteria`), Recent Decisions=Accepted마다 판정(`record-decision:32-36`).
  - NET-NEW(DR-029 실제 범위): ① 3-way 등록 triage(record-decision §Procedure가 "확정된 의사결정" 전제) ② 승격 프로세스 Draft→Accepted ③ Dropped 종료 상태+번호 retire ④ repo-health Draft hygiene surfacing ⑤ 템플릿 Open Points/Promotion Conditions 섹션.
  - 결론: DR-029는 기존 lifecycle 참조 + 위 5개만 다루는 focused DR. 편집 지점 = record-decision amend + DECISION-TEMPLATE 섹션 추가 + repo-health surfacing + DR-029/030.
