---
id: CHORE-20260620-003
priority: P2
status: Done
risk: L2
scope: planning-pack template/scaffold/session-start integration model의 low-regret 경계와 defer trigger 결정
appetite: 1d
planned_start: 2026-06-20
planned_end: 2026-06-20
actual_end: 2026-06-20
related_dr: []
related_troubleshooting: []
related_work: [CHORE-20260620-001, CHORE-20260620-002]
---

# CHORE-20260620-003: Planning-Pack Template/Scaffold Integration Model

## Top Summary

이 Work는 backlog candidate `Planning-pack template/scaffold integration model` 착수다.
CHORE-20260620-001은 planning-pack prepared-brief flow와 pack resolver concept를 source 후보로 라우팅했고, CHORE-20260620-002/DR-041은 D-21 document-set 경계와 pack-local README 기준을 닫았다.

이번 목표는 planning-pack을 source repo에서 어떤 template 단위로 관리하고, scaffold·session-start에 어디까지 연결할지 **지금 결정 가능한 범위와 defer trigger**로 나누는 것이다.
비목표는 명확하다. 실제 `scripts/create-harness.sh` 구현, `templates/planning-pack/` 파일 작성, resolver 코드 구현, auth-session/product engineering pack 설계는 이 Work에서 하지 않는다. 산출물은 integration model decision/brief다.

## Context Manifest

| 순서 | 파일 | 섹션 | 왜 |
| --- | --- | --- | --- |
| 1 | `docs/backlog/HARNESS.md` | `Planning-pack template/scaffold integration model` | 착수 후보와 Done Criteria |
| 2 | `docs/works/harness/CHORE-20260620-001-planning-pack-evidence-review.md` | D-24 boundary, resolver routing summary | prepared-brief no-copy 경계와 resolver concept payload |
| 3 | `docs/works/harness/CHORE-20260620-002-template-document-boundary.md` | Decision Output | D-21 경계, `TEMPLATE-ACCEPTANCE`, pack-local README 기준 |
| 4 | `docs/decisions/DR-041-pack-docs-path-assumption-supersede.md` | Decision, Consequences | pack 문서 위치 기준과 scaffold/template 후속 영향 |
| 5 | `docs/maintainer/PRODUCT-STARTER-PLANNING-PACK.md` | 범위, source/product/import 경계 | 현재 source-only planning-pack 기준 |
| 6 | `temp/decision-table.md` | D-24 | planning-pack 소비 경로 locked decision |
| 7 | `temp/planning-pack-onboarding-workflow.md` | 전체 | 공식 pack 승격 시 고려된 설계안 |
| 8 | `temp/pack-multipack-concept.md` | Minimum Resolver Metadata | `provides/requires/conflicts/modes`, selected/resolved pack shape |
| 9 | `scripts/create-harness.sh` | scaffold distribution boundary | 실제 구현 전 파일 impact를 판단하기 위한 대상 |

Trigger: D-21 경계 결정 이후 남은 직접 후속. `Planning-pack template/scaffold integration model`은 "실제 scaffold/template 구현" 전에 경로·소유권·자동화 수준을 무리하게 확정하지 않도록, low-regret 결정과 first real walkthrough 이후 결정할 항목을 분리하는 decision slice다.

## Candidate Selection

| 후보 | 판단 | 이유 |
| --- | --- | --- |
| `Planning-pack template/scaffold integration model` | **선택** | D-21/DR-041의 직접 후속이다. full document-set이나 scaffold 구현 전, planning-pack template owner와 배포/탐색 경계를 먼저 결정해야 한다. |
| `Archive decision surfacing` | 보류 | auth-session 매몰 사례를 다루는 process slice로 유효하지만, D-21 직후의 "template/scaffold 구현 전 결정" 후속은 아니다. |
| `Spring modular/product engineering option-pack 후보` | 보류 | auth-session·Spring modular pack 일반화 후보를 포함하지만 L3에 가까운 product engineering pack 설계로 scope가 넓다. |

## Plan

### Slice A — Boundary Restatement

- D-24 no-copy 경계를 재확인한다: planning-pack은 create-harness 자동 codegen 입력이 아니라 scaffold 직후 bootstrap onboarding의 prepared-brief 구조화 고급형이다.
- source-owned template, scaffold-seed, product-owned artifact, import-candidate를 분리한다.
- `PRODUCT-STARTER-PLANNING-PACK.md`는 현재 source-only maintainer 기준 문서이며, 그대로 scaffold target에 배포하지 않는다는 전제를 확인한다.

### Slice B — Cardinality And Integration Options

선행 판정:

- Source template/checklist는 여러 target에 재사용되는 1:many asset이다.
- Target별 planning-pack instance 또는 prepared brief는 특정 target의 identity·scope·decision을 담는 1:1 artifact다.
- 따라서 target-internal vs target-external 경로 판단은 source template과 target-specific instance를 섞지 않고 따로 해야 한다.

아래 option을 비교한다.

| Option | 설명 | 초기 입장 |
| --- | --- | --- |
| source-only maintainer guide 유지 | 현행처럼 `docs/maintainer/PRODUCT-STARTER-PLANNING-PACK.md`와 temp 산출물만 유지 | 너무 수동적. 반복 product에서 discovery 비용이 남는다. |
| source skeleton 정형화 | D-24가 요구한 template/checklist를 fill-in skeleton으로 구체화한다 | guide만으로는 최종 상태가 부족하다. 다만 `templates/planning-pack/` 경로는 새 convention이므로 first real walkthrough 전에는 확정하지 않는다. |
| scaffold target 내부 `.harness/planning-pack/` seed | target repo에 planning-pack skeleton을 배포한다 | 지금은 채택하지 않는다. target-specific instance와 source planning original이 섞일 위험이 있어 walkthrough 이후 trigger로 defer한다. |
| target repo 바깥 sibling path convention | target 옆에 planning-pack workspace를 두도록 권장 | 지금은 확정하지 않는다. no-copy 경계는 지키지만 repo 밖 경로 discovery와 ownership이 실제 walkthrough에서 검증돼야 한다. |
| session-start 자동 탐색 | `.harness/planning-pack/` 또는 sibling path를 자동 scan | 채택하지 않는다. manual 경로/텍스트 입력을 default로 유지하고, repo 밖 auto-scan은 하지 않는다. |

### Slice C — Resolver Metadata Relationship

- pack resolver concept(`provides/requires/conflicts/modes`, `selected_packs/resolved_packs/resolution.added`)는 capability pack 합성 메커니즘이지 planning-pack brief authoring 층위가 아니다.
- 이번 Work는 resolver를 planning-pack model에 포함하지 않는다.
- 후속 `pack catalog / option-pack` 후보로 pointer-route만 남긴다.

### Slice D — Decision Form And Review

- DR-worthy 여부를 outcome-contingent로 판단한다. scaffold 배포 경로, session-start 자동 탐색, no-copy 경계 변경을 지금 확정하지 않으면 신규 DR은 기본적으로 불필요하다.
- Claude B R1 review를 먼저 받는다.
- Owner 승인 후 decision/brief와 필요한 최소 문서 변경만 진행한다.

## Scope Guard

- `scripts/create-harness.sh` 변경 없음.
- `.agents/skills/workflow-session-start`, `.claude/commands`, `.cursor/rules` 변경 없음.
- `templates/planning-pack/` 실제 파일 작성 없음.
- pack resolver 코드, manifest schema, auth-session pack 설계 없음.
- fresh no-code scaffold 재온보딩 검증은 별도 residual axis로 유지한다.
- 결정은 `adopt / defer + trigger`로 수렴한다. mechanism 설계나 배포 자동화 상세로 들어가지 않는다.

## Initial Direction (R1 전 미확정)

| 항목 | 초기 입장 | R1 질문 |
| --- | --- | --- |
| 착수 순서 | D-21 이후 이 후보가 직접 후속이다 | archive-surfacing/auth-session이 먼저여야 하는가 |
| planning-pack cardinality | source template/checklist는 1:many, target별 prepared brief/planning-pack instance는 1:1 | 이 분리가 internal/external 경로 판단에 충분한가 |
| planning-pack 위치 | source skeleton 정형화 필요성은 인정하되, 새 top-level `templates/`나 target 경로는 first walkthrough 이후 trigger로 둔다 | 지금 경로를 확정하지 않는 것이 너무 약한가 |
| scaffold 자동 배포 | defer. first real walkthrough 전에는 배포하지 않는다 | 배포하지 않으면 discovery 비용이 너무 큰가 |
| session-start 자동 탐색 | manual 경로/텍스트 입력 default를 확정하고, repo 밖 auto-scan은 하지 않는다 | auto-scan 없음이 UX상 너무 보수적인가 |
| resolver metadata | planning-pack model에서 분리하고 pack catalog/option-pack 후보로 pointer-route | pointer만으로 충분한가 |

## Risk

| Risk | Level | Mitigation |
| --- | --- | --- |
| D-24 no-copy 경계를 깨고 planning-pack을 product repo에 복사함 | Medium | source/product/artifact owner를 먼저 판정하고 `.harness/` seed는 신중히 검토 |
| decision slice가 scaffold 구현으로 번짐 | Medium | Scope Guard와 Done Criteria에서 구현 없음 고정 |
| session-start 자동 탐색이 stale file 오탐을 만듦 | Medium | 자동 탐색을 기본값으로 두지 않고 R1에서 공격적으로 검토 |
| resolver metadata가 planning-pack과 pack catalog 사이에서 중복됨 | Medium | ownership/location만 결정, schema 구현은 별도 |
| no-code/manual adopter evidence를 code-product 결론으로 과대 확장 | Low | code-product-informed 라벨과 fresh no-code residual 명시 |

## Done Criteria

- [x] Claude B R1 red-team review가 기록된다.
- [x] R1 finding별 Codex A response(accept/defend/revise)와 consensus가 기록된다.
- [x] planning-pack cardinality가 분리된다: source template/checklist는 1:many, target-specific instance/prepared brief는 1:1.
- [x] planning-pack template의 owner가 분리된다: source-owned template / scaffold-seed / product-owned artifact / import-candidate.
- [x] source skeleton 정형화 필요성과 경로 확정의 defer trigger가 결정된다.
- [x] target-internal `.harness/planning-pack/` seed와 target-external/sibling path convention의 adopt/defer+trigger가 결정된다.
- [x] `create-harness.sh` 자동 배포 여부가 adopt/defer+trigger로 판정된다.
- [x] `workflow-session-start` 자동 탐색 여부가 adopt/defer+trigger로 판정된다.
- [x] resolver metadata payload의 owner/location이 결정된다.
- [x] D-24 no-copy boundary와 DR-041 pack-local README decision을 침범하지 않는지 확인된다.
- [x] DR-worthy 여부와 기록 위치가 outcome-contingent로 명시된다.
- [x] 구현/scaffold 변경이 이번 Work 비범위로 유지된다.

## Verification

- Evidence 대조:
  - `docs/works/harness/CHORE-20260620-001-planning-pack-evidence-review.md`
  - `docs/works/harness/CHORE-20260620-002-template-document-boundary.md`
  - `docs/decisions/DR-041-pack-docs-path-assumption-supersede.md`
- Scaffold impact review: `scripts/create-harness.sh` 파일 목록과 현행 distribution boundary 확인. 실제 dry-run은 구현 변경이 있을 때만 수행.
- Session-start impact review: canonical/session-start surface 변경 필요 여부 판단. 실제 skill/command patch는 별도 승인 전까지 없음.
- `git diff --check`

## Checkpoints

| CP | Description | Status |
|----|-------------|--------|
| 1 | 잘못 연 archive-surfacing 초안을 폐기하고 후보 재선택 | done |
| 2 | Branch/Work를 planning-pack scaffold integration으로 정렬 | done |
| 3 | Claude B R1 review 수신 | done |
| 4 | A response 및 Owner 승인 | done |
| 5 | 결정/문서 변경 | done |
| 6 | Result review 및 closeout | done |

## Next Actions

- ✓ branch rename: `feature/chore-20260620-003-planning-pack-scaffold-integration`
- ✓ Work 파일 재작성
- ✓ Claude B R1 review 수신·기록 (P1 2 / P2 3 / P3 3 + direction-level concern + Q-a~Q-e)
- ✓ R1 finding별 Codex A response(accept/defend/revise) 작성
- ✓ Owner 승인 후 low-regret decision/brief 작성
- ✓ Claude B result review 수신: conditional approve, P2-t backlog duplicate reconcile 필요
- ✓ P2-t 및 resolver route-out follow-up 반영
- ✓ `/work-close` Done 처리

## Discovery

- "실제 scaffold/template 구현"이라는 D-21 직접 후속은 `Archive decision surfacing`보다 `Planning-pack template/scaffold integration model`에 대응한다.
- `Archive decision surfacing`은 여전히 유효한 후보지만, auth-session 후보가 archive 안에 묻힌 process gap을 다루는 별도 slice다.
- `temp/planning-pack-onboarding-workflow.md`는 공식 pack 승격 시 `templates/planning-pack/`, scaffold 배포, session-start 자동 scan까지 제안하지만, 이 제안은 D-24 no-copy 경계와 hidden behavior risk 때문에 그대로 채택하기보다 red-team 검토가 필요하다.
- Claude B R1 결과, 이 Work는 "integration model을 지금 확정"이 아니라 "low-regret decision + explicit deferral trigger"로 축소해야 한다. first real onboarding walkthrough가 아직 없기 때문이다.

## Cross-Agent Review

### R1 Review Request — Claude B

Claude B는 cross-agent red team reviewer로서 아래 계획을 검토한다.

**A의 현재 방향:** D-21/DR-041 이후 직접 후속으로 `Planning-pack template/scaffold integration model`을 연다. 이 Work는 planning-pack을 source repo에서 어떤 template 단위로 관리하고, scaffold·session-start에 어디까지 연결할지 결정한다. 구현은 하지 않는다. 특히 planning-pack은 D-24 기준으로 create-harness 자동 codegen 입력이 아니라 scaffold 직후 bootstrap onboarding의 prepared-brief 구조화 고급형이라는 no-copy 경계를 유지하려 한다.

특히 아래를 공격적으로 봐 달라.

1. 지금 이 후보를 여는 것이 맞나? 아니면 `Archive decision surfacing` 또는 auth-session/product engineering pack이 먼저인가?
2. `templates/planning-pack/` source-owned template 경로를 결정하는 것이 타당한가, 아니면 아직 `docs/maintainer/PRODUCT-STARTER-PLANNING-PACK.md` source-only guide로 충분한가?
3. target repo 내부 `.harness/planning-pack/` seed는 D-24 no-copy 경계를 깨는가, 아니면 scaffold-seed로 허용 가능한가?
4. target repo 바깥 sibling path convention이 현실적인가? 경로 discoverability와 repo purity 중 무엇을 우선해야 하나?
5. `workflow-session-start` 자동 탐색은 UX 개선인가, hidden/stale behavior인가? 수동 경로 입력 유지가 더 안전한가?
6. resolver metadata(`provides/requires/conflicts/modes`, `selected_packs/resolved_packs/resolution.added`)는 planning-pack integration model에 포함해야 하나, 별도 pack catalog/option-pack 후보로 분리해야 하나?
7. 이 결정은 DR-worthy인가, Work 내 decision/brief로 충분한가?
8. 이 Work가 실제 scaffold/template 구현으로 scope creep하지 않게 충분히 막혀 있는가?

Expected output:
- P1/P2/P3 findings
- direction-level concern 최소 1개 또는 "없음"
- 각 finding별 recommendation
- 마지막에 A가 accept/defend/revise로 답할 수 있는 질문을 남겨 달라.

### R1 Review Result — Claude B

**결론:** 이 Work는 CHORE-002에서 두 agent가 합의한 "evidence 없이 결정을 넓히지 말라"는 규율을 스스로 위반할 위험이 가장 크다. 근본 문제는 planning-pack이 실제 onboarding flow(scaffold→session-start→bootstrap)를 단 한 번도 거치지 않은 상태에서 integration model(template 경로·scaffold 자동 배포·session-start 자동 탐색)을 결정하려는 것이다. STATUS Next Actions 자신이 "first real walkthrough"를 외부 전제가 있는 P1 gate로 명시한다. 착수는 가능하나, low-regret 결정(소유권 경계 + D-24 재확인 + resolver 분리)만 지금 하고 배포/자동탐색/경로 확정은 walkthrough 이후로 명시적 defer해야 한다.

근거 대조 사실:
- `templates/` 디렉토리는 source에 없다. scaffold는 `scripts/templates/{default,source-gitflow}/`를 template root로 쓴다 → `templates/planning-pack/`은 새 top-level convention 발명.
- `.harness/`는 이미 harness-owned target-internal surface(manifest.json, gate-config). "product 순수 코드"가 아니다 — Q3 nuance.
- D-24 lock은 이미 "source가 planning-pack template/checklist+intake 제공"을 못박았다. 현재 존재하는 건 `PRODUCT-STARTER-PLANNING-PACK.md`(criteria guide)뿐, fill-in skeleton은 없다.

**P1 — 결정 산출 전 반드시 해소**

| # | Finding | 근거 | Recommendation |
|---|---|---|---|
| P1-1 | Evidence vacuum. integration model을 실제 onboarding walkthrough 0회 상태에서 결정. CHORE-002 evidence(`spring-modular-template` 5 cycle)보다 더 얇다 — planning-pack은 authored됐을 뿐 D-24 flow로 consume된 적 없음. STATUS가 "first real walkthrough"를 gating P1로 둔 것과 충돌. scaffold 자동 배포·session-start 자동 탐색을 지금 정하면 CHORE-002에서 기각한 "진공 결정" 재발. | STATUS Next Actions "외부 전제가 있는 P1", D-24 | revise — 결정을 2분할: (a) 지금(low-regret): owner 경계, D-24 재확인, resolver 분리 / (b) walkthrough 이후 defer+trigger: template 경로 확정, scaffold 자동 배포, session-start 자동 탐색. Done Criteria 115·116을 "mechanism 설계"가 아니라 "adopt/defer+trigger 판정"으로 명시. |
| P1-2 | planning-pack cardinality 미결. internal(`.harness/`) vs external(sibling)은 "planning-pack이 target과 1:1인가 1:many인가"를 먼저 정하지 않으면 판단 불가. proposal §3은 portability(1:many) 주장, D-24 step은 "대상별 작성"(1:1) — 서로 충돌. | `planning-pack-onboarding-workflow.md:55` vs `decision-table.md:33` | revise — Slice B 앞에 선행 결정 추가: planning-pack ↔ target cardinality. 이걸 정해야 internal/external이 따라온다. |

**P2 — 결정 품질에 직접 영향**

| # | Finding | 근거 | Recommendation |
|---|---|---|---|
| P2-1 | `templates/planning-pack/`는 새 convention 발명. source에 `templates/` 없음, scaffold는 `scripts/templates/{default,source-gitflow}/` 사용. 경로를 진공에서 단정하면 기존 scaffold 구조와 divergent. | `templates/` 부재, `create-harness.sh:534,560` | revise — skeleton 경로를 정한다면 기존 `scripts/templates/` root와 reconcile하거나 새 top-level 정당화 명시. `templates/` default 가정 금지. |
| P2-2 | session-start 자동 탐색 = hidden behavior + repo 밖 파일 접근 확장. sibling path auto-scan은 agent가 repo 바깥을 자동으로 읽게 만든다(scope/safety 확장 + stale 오탐). manual 입력은 session-start canonical §28에 이미 구현됐고 더 정직. | `session-start.md:28`, proposal §4-3 | revise/defend — "manual 경로 입력 default 유지, 최대 optional prompt, auto-scan 없음(특히 repo 밖)"을 확정 결정으로. "기본 보류 maybe" 아니라 firm no. |
| P2-3 | resolver metadata 층위 혼선. resolver(`provides/requires/conflicts/modes`)는 capability pack 합성 메커니즘이지 planning-pack brief authoring 층위가 아님. 끌어들이면 scope bloat. | `pack-multipack-concept.md:122-167` | revise — Slice C를 "resolver는 planning-pack model에 불포함 → 별도 pack-catalog/option-pack candidate로 pointer-route"로 축소. depth 분석 제거. |

**P3 — 정합성·근거 보정**

| # | Finding | Recommendation |
|---|---|---|
| P3-1 | DR-worthiness 선결정 위험. distribution/auto-scan을 DR 후보로 가정하나, P1-1대로 defer하면 지금은 DR 불필요(backlog candidate + Work 내 decision으로 충분). | revise — DR을 outcome-contingent로. 미리 DR spec 금지. |
| P3-2 | guide vs template gap 미명명. D-24가 이미 "template/checklist 제공"을 mandate했는데 현재는 guide만 존재. 진짜 질문은 "guide로 충분한가"가 아니라 "skeleton을 언제/어디서 정형화하나". | revise — Q2 framing을 "D-24가 이미 template를 요구함 → 정형화 시점·위치 결정"으로 교정. |
| P3-3 | Q8 scope guard 보강. | accept — Scope Guard에 "결정은 adopt/defer+trigger로 수렴, mechanism 설계 금지" 1줄 추가. |

**Direction-level concern:** planning-pack integration cluster 전체가 STATUS가 gating으로 표시한 "first real onboarding walkthrough"를 기다리는 상태일 가능성이 높다. walkthrough 없이 이 Work가 건전하게 결정할 수 있는 건 소유권 경계와 deferral trigger뿐이다. template 경로·scaffold 자동 배포·session-start 자동 탐색을 지금 commit하면 첫 walkthrough가 그 결정을 뒤집을 공산이 크고, 이는 CHORE-002에서 합의한 "evidence 있는 것만 결정, 나머지는 trigger로 명시 보류" 규율과 자기모순이다. → 이 Work를 "low-regret 결정 + 명시적 deferral" 형태로 reshape할 것. (Q1 답: 후보 순서 문제가 아니라 cluster 자체가 walkthrough 의존이라는 게 핵심.)

**A가 accept/defend/revise로 답할 질문**

1. Q-a (P1-1): planning-pack이 실제 target에서 scaffold→session-start→bootstrap end-to-end로 consume된 적이 있나? 없다면 "지금/defer 2분할"을 accept하는가?
2. Q-b (P1-2): planning-pack은 target과 1:1인가 1:many인가? internal/external 판단 전에 답해야 한다.
3. Q-c (P2-3): resolver(Slice C)를 별도 candidate pointer로 빼는 것을 accept하는가?
4. Q-d (P2-2): "auto-scan 없음 + manual default firm"을 "보류" 대신 확정 결정으로 accept하는가?
5. Q-e (P3-1): DR을 outcome-contingent로 두고 지금은 DR 없이 Work-decision+backlog로 닫는 것을 accept하는가?

### R1 A Response — Codex A

Claude B의 R1은 **대부분 수용한다**. 핵심은 "이 후보를 열지 말라"가 아니라, first real onboarding walkthrough 없이 template 경로·scaffold 배포·session-start 자동 탐색을 확정하지 말라는 것이다. 이 지적은 CHORE-20260620-002에서 합의한 "evidence 있는 surface만 결정하고 나머지는 trigger로 미룬다"는 규율과 맞다.

이번 Work shape를 아래처럼 수정한다.

- 지금 결정: D-24 no-copy 경계 재확인, owner/cardinality 분리, manual prepared-brief intake default, resolver 분리.
- 지금 보류: source skeleton 경로 확정, `create-harness.sh` 자동 배포, `.harness/planning-pack/` seed, sibling path convention, session-start auto-scan.
- trigger: first real onboarding walkthrough에서 prepared brief가 실제로 scaffold→session-start→bootstrap 흐름으로 소비된 뒤 재검토.

| Finding | A 판정 | 반영 |
| --- | --- | --- |
| P1-1 Evidence vacuum | **Accept / revise** | integration model을 "지금 확정"하지 않는다. low-regret 결정과 walkthrough 이후 defer 항목으로 2분할했다. Done Criteria도 경로·배포·탐색 "확정"이 아니라 `adopt/defer+trigger` 판정으로 바꿨다. |
| P1-2 planning-pack cardinality 미결 | **Accept / revise** | Slice B 앞에 cardinality 선행 판정을 추가했다. Source template/checklist는 1:many, target별 planning-pack instance/prepared brief는 1:1이다. internal/external 경로 판단은 이 둘을 섞지 않고 따로 다룬다. |
| P2-1 `templates/planning-pack/` 새 convention | **Accept / revise** | `templates/planning-pack/`을 default로 전제하지 않는다. 현행 scaffold root가 `scripts/templates/{default,source-gitflow}/`임을 고려해, skeleton 경로 확정은 first walkthrough 이후로 defer한다. |
| P2-2 session-start auto-scan hidden behavior | **Accept / revise** | "manual 경로/텍스트 입력 default 유지, repo 밖 auto-scan 없음"을 firm decision 후보로 둔다. 자동 탐색은 보류가 아니라 현재 Work 기준 비채택이다. |
| P2-3 resolver metadata 층위 혼선 | **Accept / revise** | Resolver metadata는 planning-pack model에 넣지 않는다. capability pack 합성 메커니즘으로 보고, 별도 pack catalog/option-pack 후보로 pointer-route한다. |
| P3-1 DR-worthiness 선결정 | **Accept / revise** | DR은 outcome-contingent로 둔다. 경로·배포·auto-scan을 지금 확정하지 않는다면 신규 DR 없이 Work decision/brief와 backlog trigger로 충분하다. |
| P3-2 guide vs template gap 미명명 | **Accept / revise** | 질문을 "guide로 충분한가"가 아니라 "D-24가 요구한 template/checklist skeleton을 언제/어디서 정형화할 것인가"로 교정했다. 현행 guide는 기준 문서이고 fill-in skeleton gap은 남아 있다. |
| P3-3 scope guard 보강 | **Accept** | Scope Guard에 `adopt / defer + trigger` 수렴과 mechanism 설계 금지를 추가했다. |

**Q-a 답:** 실제 target에서 planning-pack이 scaffold→session-start→bootstrap end-to-end로 consume된 증거는 아직 없다. `spring-modular-template`은 code-product prepared-brief evidence지만, D-24 flow를 manual/external adopter 관점에서 end-to-end 검증한 것은 아니다. 따라서 "지금/defer 2분할"을 accept한다.

**Q-b 답:** source template/checklist는 1:many, target별 planning-pack instance/prepared brief는 1:1이다. 이 분리 없이 `.harness/` vs sibling path를 결정하면 source template과 target-specific planning artifact가 섞인다.

**Q-c 답:** resolver는 별도 candidate pointer로 뺀다. Planning-pack authoring model은 brief/intake 경계이고, resolver는 pack capability 합성 경계다.

**Q-d 답:** accept한다. `workflow-session-start`는 현재 manual 경로/텍스트 입력 default를 유지한다. Repo 밖 sibling path auto-scan은 hidden behavior와 stale 오탐 위험 때문에 이번 Work 기준 비채택이다.

**Q-e 답:** accept한다. 지금은 신규 DR 없이 Work decision/brief로 닫는 방향이 맞다. 다만 result가 실제 workflow policy를 바꾸거나 D-24/no-copy 경계를 supersede하게 되면 DR-worthy를 다시 판단한다.

**Owner 승인 요청:** 이 response 기준으로 다음 분석을 진행한다. 즉, 산출물은 "planning-pack integration 확정안"이 아니라 **low-regret decision + explicit deferral trigger**다. 구현·scaffold·session-start patch는 계속 비범위다.

### R1 Consensus Check — Claude B

Claude B consensus 확인: R1 finding 8건과 direction-level concern은 closed. Work shape가 "low-regret decision + explicit deferral trigger"로 축소된 점을 승인했다.

잔여 반영 조건:

- cardinality 판단은 `code-product-informed` 라벨 아래 둔다.
- manual-default 표현은 "현행 유지 + auto-scan 비채택"으로 톤을 통일한다.

Codex A 조치: 아래 Decision Output에 두 조건을 반영한다.

## Decision Output

### Evidence Scope Label

이 결정은 **code-product-informed**다.

근거는 `spring-modular-template`에서 planning-pack을 target repo에 통째 복사하지 않고 prepared brief로 소비한 code-product evidence와, CHORE-20260620-001/002의 source/product 경계 결정이다. 다만 아직 manual external adopter 또는 no-code scaffold target에서 `scaffold -> session-start -> bootstrap` end-to-end로 planning-pack이 소비된 증거는 없다.

따라서 아래 결정 중 "first real walkthrough 이후"로 표시된 항목은 지금 확정하지 않는다. 첫 real onboarding walkthrough에서 prepared brief가 실제 target bootstrap에 어떻게 들어가는지 확인한 뒤 재검토한다.

### Low-Regret Decisions

| ID | Decision | Status | 이유 |
| --- | --- | --- | --- |
| D1 | D-24 no-copy 경계를 유지한다. Planning-pack은 `create-harness.sh` codegen 입력이 아니라 scaffold 직후 bootstrap onboarding의 prepared-brief 구조화 입력이다. | Adopt | product repo에 planning original을 통째 복사하면 source planning asset과 product state가 섞인다. CHORE-20260620-001의 code-product evidence도 no-copy 경계를 유지했다. |
| D2 | Cardinality는 code-product-informed 기준으로 분리한다: source template/checklist는 1:many, target-specific planning-pack instance/prepared brief는 1:1이다. | Adopt, revisit on first manual/no-code walkthrough | source가 여러 target에 줄 수 있는 것은 질문 프레임·체크리스트·skeleton이다. 실제 scope, decision, backlog seed는 target마다 달라지는 product-owned artifact다. |
| D3 | `docs/maintainer/PRODUCT-STARTER-PLANNING-PACK.md`는 source-only guide로 유지한다. Scaffold target에 그대로 배포하지 않는다. | Adopt | 이 문서는 maintainer 기준과 import-loop 설명을 담고 있어 adopter target의 product state 문서가 아니다. |
| D4 | D-24가 요구한 template/checklist skeleton gap은 인정한다. 다만 skeleton 경로와 파일셋은 first real walkthrough 이후 결정한다. | Defer + trigger | 현행 source에는 top-level `templates/`가 없고 scaffold는 `scripts/templates/{default,source-gitflow}/`를 쓴다. 경로를 지금 확정하면 새 convention을 증거 없이 만든다. |
| D5 | `workflow-session-start`는 현행 manual 경로/텍스트 입력 default를 유지한다. Repo 밖 sibling path나 `.harness/planning-pack/` auto-scan은 비채택한다. | Adopt no auto-scan | 현재 canonical session-start는 준비된 brief가 있으면 경로/텍스트를 받는 흐름을 이미 가진다. 자동 탐색은 hidden behavior, repo 밖 읽기 확장, stale file 오탐 위험이 크다. |
| D6 | `create-harness.sh` 자동 배포와 target-internal `.harness/planning-pack/` seed는 지금 채택하지 않는다. | Defer + trigger | `.harness/`는 target-internal harness-owned surface지만, planning-pack instance를 넣으면 no-copy 경계를 흐릴 수 있다. 실제 walkthrough 전에는 배포하지 않는다. |
| D7 | Target-external/sibling planning-pack path convention은 지금 확정하지 않는다. | Defer + trigger | repo purity는 지키지만 discoverability, ownership, stale path 문제가 실제 walkthrough에서 확인돼야 한다. |
| D8 | Resolver metadata(`provides/requires/conflicts/modes`, `selected_packs/resolved_packs/resolution.added`)는 planning-pack integration model에 포함하지 않는다. | Route out | resolver는 capability pack 합성 메커니즘이다. Planning-pack authoring/intake 경계와 섞지 않고 pack catalog/option-pack 후보로 보낸다. |
| D9 | 신규 DR은 지금 만들지 않는다. | Adopt | 이번 결정은 기존 D-24/DR-041을 supersede하지 않고, 구현·배포·auto-scan policy도 바꾸지 않는다. 실제 workflow policy 변경이 생기면 그때 DR-worthy를 다시 판단한다. |

### Ownership Matrix

| Surface | Owner | Cardinality | Decision |
| --- | --- | --- | --- |
| Planning-pack criteria guide (`PRODUCT-STARTER-PLANNING-PACK.md`) | source-owned maintainer guide | 1:many | 현재 위치 유지. Scaffold target 배포 없음. |
| Future fill-in skeleton/checklist | source-owned template candidate | 1:many | 필요성은 인정하되 경로·파일셋은 first walkthrough 이후 결정. |
| Target prepared brief / planning-pack instance | product-owned artifact | 1:1 | target repo bootstrap에 들어갈 내용은 target identity·scope·decision을 반영한다. 경로는 수동 입력 default. |
| Scaffold seed | none for now | N/A | `.harness/planning-pack/` seed 또는 sibling path convention은 defer. |
| Import candidate | source review candidate | many products -> source | product에서 검증된 후 별도 Work에서만 승격 판단. |
| Resolver metadata | pack catalog / option-pack candidate | pack-level | planning-pack model에서 분리. |

### Deferral Triggers

아래 중 하나가 발생하면 deferred 항목을 다시 연다.

- 첫 real onboarding walkthrough에서 prepared brief 또는 planning-pack이 `scaffold -> session-start -> bootstrap` 흐름으로 end-to-end 소비된다.
- manual external adopter가 planning-pack 경로/전달 방식에서 반복 friction을 보고한다.
- no-code scaffold target에서 planning-pack discovery 또는 전달 UX가 막힌다.
- 2개 이상 target에서 동일 skeleton/checklist 파일셋이 반복 생성된다.
- pack catalog/option-pack 후보가 실제 resolver metadata를 요구한다.

재개 시 검토할 deferred 항목:

- source skeleton 경로: 기존 `scripts/templates/` 하위로 둘지, 새 top-level template convention이 필요한지.
- skeleton 파일셋: decision table, boundary table, import map, prepared brief 양식 중 무엇이 최소인지.
- scaffold 배포: core/default에 넣을지 opt-in pack으로 둘지.
- `.harness/planning-pack/` 또는 sibling path convention 채택 여부.
- session-start prompt 보강 vs 자동 탐색.

### Backlog/Tracking Implication

이 Work가 완료되더라도 "template/scaffold integration mechanism" 전체가 끝났다고 보지 않는다. 완료 범위는 low-regret decision이다.

Closeout 시 backlog의 기존 `Planning-pack template/scaffold integration model` candidate는 그대로 삭제하면 안 된다. 대신 first real walkthrough 이후 재개할 deferred 후보를 live backlog에 남긴다. 등록 제목:

`Planning-pack skeleton/scaffold integration after first real walkthrough`

요약 payload:

- D-24 no-copy 경계 유지.
- manual prepared-brief input default 유지, repo 밖 auto-scan 비채택.
- skeleton path/file-set, scaffold 배포, `.harness/` seed, sibling convention은 first real walkthrough 이후 결정.
- resolver metadata는 planning-pack이 아니라 pack catalog/option-pack 후보로 분리.

### Verification Result

- R1 evidence 대조: CHORE-20260620-001/002, DR-041, D-24, session-start prepared brief intake, scaffold template root를 확인했다.
- 구현 변경 없음: `scripts/create-harness.sh`, `.agents/skills`, `.claude/commands`, `templates/` 생성 없음.
- DR-worthy: 현재는 신규 DR 없음. D-24/DR-041 supersede 없음.
- Deferred follow-up: `docs/backlog/HARNESS.md`에 `Planning-pack skeleton/scaffold integration after first real walkthrough` 후보를 등록했다.
- Resolver route-out: 원본 후보 제거 전 `Spring modular/product engineering option-pack 후보`에 pack catalog/resolver evidence payload를 이전했다.

## Result Review

### Result Review — Claude B

**판정:** Conditional approve.

9개 decision finding과 R1 consensus 잔여 2조건은 정직하게 반영됐고, Decision 내용은 승인한다. 단, P2-t는 close 전 수정 필요하다.

| ID | Severity | Finding | Required fix |
| --- | --- | --- | --- |
| P2-t | P2 | `docs/backlog/HARNESS.md`에 원본 `Planning-pack template/scaffold integration model`과 신규 `Planning-pack skeleton/scaffold integration after first real walkthrough`가 둘 다 bare Candidate로 남아 중복처럼 보인다. 이는 anti-burial 자기일관성 문제다. | 원본 후보를 "CHORE-003에서 low-regret 결정 완료/처리, 잔여는 first walkthrough after 후보로 이관" 상태로 reconcile해야 close 가능. |

### Result Review A Response — Codex A

**Accept / revise.** B의 P2-t는 맞다. Decision Output에서는 residual을 분리했지만 backlog summary/detail이 둘 다 일반 Candidate처럼 보이면, 다음 `/work-select`에서 같은 후보를 두 번 고를 수 있다. 이는 이 Work가 막으려는 burial/duplication 문제를 형태만 바꿔 재현한다.

반영:

- `docs/backlog/HARNESS.md` Summary에서 원본 후보 status를 `Active/Split`으로 바꾸고 title에 `CHORE-003 low-regret decision, residual moved below`를 표시했다.
- 원본 후보 detail 상단에 `CHORE-20260620-003 reconciliation` 단락을 추가했다.
- residual 후보 `Planning-pack skeleton/scaffold integration after first real walkthrough`는 live Candidate로 유지한다.
- `/work-close` 시 원본 후보는 제거하고 residual 후보만 남기는 것이 tracking finalization 기준이다.

**결론:** P2-t 반영 완료. Result review 조건은 closed로 본다.

### Result Review Follow-up — Owner/B

Owner/B 확인: P2-t는 closed. 단 closeout 전 필수 조건이 하나 더 있다. 원본 `Planning-pack template/scaffold integration model` 후보를 제거하면 그 안의 resolver evidence payload(CHORE-20260620-001 R1 F3: `provides/requires/conflicts/modes`, `selected_packs/resolved_packs`)가 함께 사라진다. D8의 route-out을 실현하려면 원본 제거 전에 이 payload를 `Spring modular/product engineering option-pack 후보`로 이전해야 한다.

### Follow-up A Response — Codex A

**Accept / revise.** 맞다. D8은 "planning-pack model에서 resolver를 제외한다"는 decision일 뿐이고, evidence payload가 실제 live backlog의 다른 후보로 옮겨져야 anti-burial이 완성된다.

반영:

- `docs/backlog/HARNESS.md`의 `Spring modular/product engineering option-pack 후보`에 **Evidence payload — pack catalog / resolver** 단락을 추가했다.
- 원본 후보 reconciliation 단락에 resolver evidence payload가 option-pack 후보로 이전됐다고 명시했다.
- 따라서 `/work-close`에서 원본 후보를 제거해도 resolver payload는 live backlog에 남는다.

**결론:** D8 route-out 실현 완료. Closeout 전 필수 조건 충족.
