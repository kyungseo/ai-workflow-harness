---
id: CHORE-20260622-001
priority: P1
status: Active
risk: L2
scope: spring-modular-template adopter repo의 product-local DR(DR-001/030/031/032/033)을 DR-042 high-band(DR-800~804)로 real-apply renumber하고 reference cascade를 정합화한다. 실제 변경은 spring repo feature branch + PR에서 수행하고, source repo는 follow-up Work 등록과 closeout 기록만 한다.
appetite: 1d
planned_start: 2026-06-22
planned_end: 2026-06-22
related_dr: [DR-042, DR-034]
related_troubleshooting: []
related_work: [CHORE-20260621-004, CHORE-20260621-005]
---

# CHORE-20260622-001: spring-modular-template Product DR Namespace Renumber (DR-042 Apply)

> **RESUMED — 결정: ① high-band 유지 (2026-06-22, R4 Approve + 사용자 최종 결정).**
> namespace redesign 검토(`docs/briefs/dr-namespace-redesign-20260622.md`) 결과 ① high-band 유지로 확정.
> 이 Work는 high-band renumber Work로 재개(status Active). **R1 반영분(archive/live 분리, framework lineage allowlist exact,
> rename/heading 직접 검증) 유지.** ②b prefix·③ directory는 폐기가 아닌 **deferred successor option**(C9 regret guardrails).
> **spring real apply: 승인 전 미착수** — 별도 사용자 승인 후 재개. 이번 턴은 plan update까지만, spring 미착수.

## Top Summary

`spring-modular-template` adopter repo는 product-local DR을 framework 저번호 대역(`DR-001`~`DR-799`)에서 발급했다. DR-042(Accepted)는 product/adopter-local DR을 `DR-800`~`DR-999`로 분리하도록 정했고, ai-deck-compiler는 이미 `014/021/022/023 → 801/802/803/804`로 real-apply했다(PR #51). CHORE-20260621-005 read-only probe가 spring을 이 정책의 미적용 blocker로 분류했고, owner가 (1) real apply renumber, (2) DR-001 포함(5개 전부)을 승인했다.

성격을 정직하게 둔다: 이건 "지금 깨진 문제"가 아니라 convention 비준수 + 모호성 부채다. spring은 현재 clean이고, framework DR-030~033은 scaffold seed에 DR 파일로 ship되지 않아 실제 파일 충돌은 없다(ai-deck `DR-014` 공유 번호와 다름). 목적은 DR-042 완전 정합 + framework 번호 모호성(playbook "DR 번호 모호성" 트랩) 영구 제거 + ai-deck 선례와 일관성이다.

DR-034 promotion과는 분리한다. spring은 manifest target이라 DR-034 #1(pre-manifest shadow scaffold baseline)을 테스트하지 않는다. 이 Work는 DR-042 2nd real-apply evidence만 보수적으로 추가한다.

역할은 Claude A = author/driver, Codex B = red-team reviewer다. B는 내적 정합성뿐 아니라 "이 방향 자체가 맞는가"를 의심하는 관점으로 R round를 진행한다.

## Collaboration Workflow

Review/consensus flow:

```text
사용자 지시
-> Claude A가 Work file + plan 작성
-> Codex B red-team review (R round, 필요시 반복)
-> 합의
-> Claude A가 구현
-> Codex B result review
-> 사용자 최종 승인
```

Target repo flow (`spring-modular-template`) — 실 변경:

```text
feature/CHORE-20260622-001-product-dr-renumber (base: spring origin/develop)
-> DR rename + reference cascade
-> verify (--check, live grep=0, rename/heading, framework-untouched)
-> commit
-> PR --base develop (spring)
-> merge (spring GIT-WORKFLOW)
```

Source repo flow (`ai-workflow-harness`) — tracking/closeout only:

```text
spring PR merge 확인
-> /work-close (Work Done, README, STATUS pointer 제거)
-> DR-042 Linked Work 갱신 + evidence 기록
-> commit (feature/CHORE-20260622-001-...)
-> PR --base develop (source)
-> merge
```

두 repo flow는 독립적이다. source closeout commit/PR은 spring PR이 merge된 뒤에만 진행한다.

## Cross-Repo Execution Boundary

| Repo | Allowed In This Work | Owner Gate |
| --- | --- | --- |
| `ai-workflow-harness` (source) | 이 Work file, Work index, 승인된 STATUS pointer, DR-042 Linked Work 갱신(closeout), 결과 기록 | STATUS/DR 변경은 별도 승인 |
| `/Users/kyungseo/dev-home/vibe/spring-modular-template` (target) | feature branch에서 product DR rename + reference cascade + 검증 + PR | 합의 + 최종 승인 전 write 금지 |
| temp rehearsal tree | 비범위. 변경 단순(주석/문서 only)이므로 feature branch에서 직접 verify | — |

## Context Manifest

| 순서 | 파일 | 섹션 | 왜 |
| --- | --- | --- | --- |
| 1 | `docs/STATUS.md` | Next Actions | 이번 Work의 직접 trigger |
| 2 | `docs/decisions/DR-042-adopter-dr-namespace-allocation.md` | Decision, Consequences | high-band band allocation 정책과 renumber 의무 |
| 3 | `docs/maintainer/ADOPTER-UPGRADE-MIGRATION-PLAYBOOK.md` | Phase 6-10, literal DR-token 트랩, DR 번호 모호성 | renumber cascade 절차와 disambiguation 가드 |
| 4 | `docs/works/harness/CHORE-20260621-004-adopter-dr-namespace-apply.md` | Scope, Apply | ai-deck real-apply precedent (014/021~023→801~804) |
| 5 | `docs/works/harness/CHORE-20260621-005-spring-adopter-upgrade-walkthrough.md` | Ownership Classification, Gate Decision, Discovery | spring blocker 식별, follow-up shape |
| 6 | `docs/decisions/DR-034-harness-upgrade-ownership-policy.md` | Promotion Conditions | promotion evidence 경계(spring=manifest target, #1 UNMET) |

Trigger: `docs/STATUS.md` Next Actions의 "spring-modular-template product DR namespace renumber/apply follow-up — owner decision" 착수. owner는 real apply + DR-001 포함을 승인했다.

## Scope — Renumber Mapping

| 현재 (product) | 신규 | 주제 |
| --- | --- | --- |
| `DR-001` | `DR-800` | modular monolith boundary + ArchUnit + UserDirectory seam |
| `DR-030` | `DR-801` | Security/OpenAPI locked-core |
| `DR-031` | `DR-802` | Observability instrumentation locked-core |
| `DR-032` | `DR-803` | local-deploy pack & 첫 pack 레이아웃 |
| `DR-033` | `DR-804` | observability-export pack & multi-pack 합성 |

매핑은 original 번호 오름차순. 시작 번호 800은 trivial preference(조정 가능).

## Plan

### Slice A — Work Preparation And Review Gate (현재)

- Work file과 Active index를 생성한다.
- `docs/STATUS.md` Active Work pointer를 추가한다(승인된 plan 기반).
- Codex B R1 red-team review를 요청하고, finding/response/Consensus를 Cross-Agent Review에 누적한다.
- 합의 전 spring 실변경 착수 금지.

### Slice B — Spring Repo Renumber (합의 후)

target repo feature branch:

```bash
git -C <spring> fetch origin
git -C <spring> checkout -B feature/CHORE-20260622-001-product-dr-renumber origin/develop
```

1. **DR 파일 5개 rename**(`git mv`) + 각 파일 1행 제목 heading 번호 수정.
2. **product-context 참조 cascade** (disambiguation 준수):
   - `docs/decisions/README.md` index 5개 행.
   - 5개 DR 파일의 intra-product `Linked DRs:` 및 본문 상호참조.
   - `docs/STATUS.md` Recent Decisions product DR 행.
   - `docs/backlog/PRODUCT.md` 참조 라인.
   - `pack/local-deploy/README.md`, `pack/observability-export/README.md`.
   - 코드/설정 주석: `app/.../ModuleBoundaryTest.java`(`.because(...)`), `UserTodoSmokeTest.java`, `CorrelationIdFilterTest.java`, `SecurityConfig.java`, `DemoSeedRunner.java`, `MetricsConfig.java`, `app/build.gradle.kts`, `settings.gradle.kts`, `app/src/main/resources/application.yml`, `pack/*/docker-compose.yml`.
3. **archive Work refs는 live cascade에서 분리한다** (R1 P1 수정, playbook L211 "live refs와 archive refs 분리"):
   - `docs/archive/docs/works/product/FEAT-20260619-001`, `FEAT-20260620-001~005`는 작성 당시 의사결정 evidence를 가진 immutable historical record다.
   - **결정(default): archive 본문·frontmatter 전부 보존(미변경).** Done-immutability 원칙 우선. old product DR 번호는 작성 시점 기준으로 정확한 historical snapshot이므로 그대로 둔다. 현재 truth는 live `decisions/README.md` + renumber된 DR 파일이 보유한다.
   - 결과로 archive에는 old 번호 ref가 남는다 → grep-0은 **live(`docs/archive/**` 제외)에만 적용**한다.
   - 알려진 trade-off: archive frontmatter `related_dr: [DR-001]` 등이 stale pointer가 된다(archive=과거 스냅샷이라 수용). pointer 정합을 더 원하면 **frontmatter `related_dr:`만 갱신(본문 보존)** 옵션을 R round에서 재결정한다.

### Slice C — Verify + PR (합의 후)

- 검증(아래 Verification) 통과 후 commit, spring `develop` 기준 PR.
- actual-target evidence: `--check`, live grep=0, `git diff --check`, commit SHA, PR URL.

### Slice D — Result Review + Source Closeout

- Codex B result review → 합의 → 사용자 최종 승인.
- spring PR merge 후 source Work Done(`/work-close`), DR-042 `Linked Work`에 이 Work ID 추가.
- STATUS Next Actions의 spring renumber follow-up 항목 정리.
- DR-042 2nd real-apply evidence 1건 보수적 기록. DR-034는 변화 없음 명시.

## Disambiguation 가드레일 (필수)

- **naive `sed s/DR-030/DR-801/g` 금지.** 같은 번호가 framework lineage에도 존재한다.
- **건드리지 말 것:** framework-owned DR 파일 6개(`DR-007/008/013/014/027/029`)의 `Linked DRs:` 라인. spring의 `DR-007/029 → Linked DRs: DR-030`, `DR-013/014 → Linked DRs: DR-031`은 framework DR-030/031(i18n/track-structure) lineage이므로 그대로 둔다(renumber 후 모호성 자동 해소).
- **renumber 대상:** product DR 파일 5개 + 모든 product-owned 문서/코드/archive 참조. spring엔 framework DR-001/030~033 *파일*이 없어 product 문서·코드 참조는 product 의미로 명확하나, 반영 전 파일별 content로 재확인한다.
- adopter repo이므로 spring 자신의 `decisions/README.md`에 literal `DR-800` 사용은 정상(shipped-DR-closure는 source-only, N/A).

## Done Criteria

- [ ] Codex B R1 red-team review와 Codex A response, Consensus Log가 Cross-Agent Review에 기록된다.
- [ ] spring repo에서 DR-001/030/031/032/033 → DR-800/801/802/803/804 파일 rename + 제목 heading 수정 완료(V3).
- [ ] live product-context 참조 cascade(문서/코드, `docs/archive/**` 제외)가 disambiguation 가드 준수로 반영된다.
- [ ] archive Work 파일(FEAT-001~005)은 본문·frontmatter 보존(미변경)된다 — Done-immutability.
- [ ] framework DR 6개 파일은 diff에 나타나지 않음(byte-for-byte unchanged)을 확인한다(V2).
- [ ] 검증 통과: V1 live old-ref=0, V2 framework untouched, V3 rename/heading, V4 README 신규 5행 + `--check` drift 없음 + `git diff --check`.
- [ ] spring PR(`--base develop`)이 생성/merge되고 PR URL+merge SHA가 기록된다.
- [ ] Codex B result review + 사용자 최종 승인 후 `/work-close` 가능 상태.
- [ ] DR-042 Linked Work 갱신 + 2nd real-apply evidence 보수적 기록, DR-034 무변화 명시.

## Verification

spring repo(merge 전). `<spring>` = `/Users/kyungseo/dev-home/vibe/spring-modular-template`, `rg` 사용(`.gitignore` 존중).

**V1. live product-context old-ref = 0 (archive 제외)** — R1 P1:
- `rg -n -e 'DR-001' -e 'DR-030' -e 'DR-031' -e 'DR-032' -e 'DR-033' "<spring>" -g '!docs/archive/**'`
- 기대: hit는 framework lineage allowlist(아래 V2)에만 남는다. 그 외 product-context hit = 0.

**V2. framework lineage allowlist = byte-for-byte unchanged** — R1 P1:
- framework DR 6개(`DR-007/008/013/014/027/029`) 파일은 **이번 변경에서 절대 수정 대상이 아니다.**
- `git -C "<spring>" diff --name-only`에 `docs/decisions/DR-007*`, `DR-008*`, `DR-013*`, `DR-014*`, `DR-027*`, `DR-029*`가 **나타나지 않음**을 확인(= body·line·frontmatter 무오염을 exact 증명).
- 남아야 할 lineage: `DR-007/029 → Linked DRs: DR-030`, `DR-013/014 → Linked DRs: DR-031`(framework 의미).

**V3. rename + heading 직접 검증** — R1 P2:
- old absence: `for n in 001 030 031 032 033; do test ! -e "<spring>"/docs/decisions/DR-$n-*.md && echo "absent DR-$n"; done` → 5건.
- new existence: `for n in 800 801 802 803 804; do ls "<spring>"/docs/decisions/DR-$n-*.md; done` → 5건.
- heading: `rg -n '^# DR-80[0-4]:' "<spring>"/docs/decisions/DR-80*.md` → 5건.

**V4. index + drift + diff**:
- `rg -n 'DR-80[0-4]' "<spring>"/docs/decisions/README.md` → 5개 행 신규 번호.
- `bash <source>/scripts/create-harness.sh --check "<spring>"` → DR 관련 신규 drift 없음(framework-owned 파일 미변경).
- `git -C "<spring>" diff --check`.
- 주석만 변경이므로 동작 무영향. 선택적 `./gradlew test` smoke.

source repo: DR-042 Linked Work 갱신, Work Done, STATUS pointer 정리 후 finalization gate(문서/tracking 위주면 override trailer).

## Risk

- **Risk L2.** 모든 참조가 설명 주석/문서 — 동작 변경 없음. 주 위험은 disambiguation 실수(framework lineage 오염)이며 가드 + grep 검증으로 차단.
- **Reversal Cost Medium.** spring repo 내 reference cascade. ai-deck보다 light(`decisions/README.md` 이미 존재).
- cross-repo: source Work는 tracking, spring PR이 실 변경 — 두 repo state를 섞지 않는다.

## Cross-Agent Review

### Cross-Agent Review And Discussion

Codex B R1에서 특히 의심할 질문(red team):

- 방향 자체: renumber가 맞나, grandfather/defer가 더 합리적이지 않나? "지금 안 깨진다"는 점이 renumber를 미루는 근거가 되지 않나?
- DR-001 포함이 owner 명시 scope(DR-030~033)를 넘는 과확장인가, 아니면 정책상 당연 포함인가?
- archive Work refs(FEAT-001~005)까지 renumber하는 것이 Done-immutability 원칙 위반인가? annotate-only가 더 맞나?
- 시작 번호 800 / 매핑 순서가 ai-deck(801~804)과 불필요하게 어긋나 혼란을 만드나?
- cross-repo boundary 누수 위험(source/target state 혼합, source merge policy를 target에 가정)은 없나?
- disambiguation 가드가 실제로 충분한가 — framework lineage 오염을 막는 grep 검증이 완전한가?
- DR-042 evidence wording이 과장될 위험(2건으로 "정책 검증 완료" 선언 등)은 없나?

### Round Log

- **R1 Codex B — Request changes before implementation.** renumber 방향 자체는 수용(DR-042 Accepted, low-band product DR은 high-band renumber 대상; DR-001 포함 수용; DR-800 시작 수용·기록만; DR-034 evidence 경계 유지). 단 구현 전 4개 수정 요구:
  - **P1-a**: archive Work refs를 repo-wide grep-0 대상에 두면 Done/archive 역사 재작성 위험. playbook L211(live/archive 분리)에 위배. → archive를 live cascade에서 분리하고 처리(보존/frontmatter-only/note) 먼저 결정.
  - **P1-b**: old-ref grep 검증이 framework lineage allowlist와 product-context 0을 정확히 분리 못함. framework `Linked DRs: DR-030/031`은 남아야 함. → `live product (archive 제외)` + `framework allowlist exact(unchanged)`로 검증 분리.
  - **P2-a**: 상단 collaboration flow가 target PR과 source closeout 순서를 섞음. → target flow와 source tracking flow를 별도로 분리.
  - **P2-b**: rename/heading이 Done Criteria엔 있으나 Verification 명령엔 없음. → old absence/new existence/heading 직접 검증 추가.

- **R1 A 응답 — Claude A (accept all 4).** 네 finding 모두 plan의 실제 결함으로 수용하고 반영했다:
  - P1-a → Slice B를 step 3로 분리. **default 결정: archive 본문·frontmatter 전부 보존(미변경)**, Done-immutability 우선. grep-0은 live(`docs/archive/**` 제외)에만 적용. stale pointer trade-off 명시 + frontmatter-only 대안을 재결정 옵션으로 남김.
  - P1-b → Verification을 V1(live old-ref=0, archive 제외) + V2(framework 6파일 `git diff --name-only` 미출현 = byte-unchanged exact)로 분리. allowlist를 "6파일 미수정"으로 exact 증명.
  - P2-a → Collaboration Workflow를 review flow / target repo flow / source tracking flow 3블록으로 분리. source closeout은 spring PR merge 후에만.
  - P2-b → V3 추가: old absence(`test ! -e`), new existence(`ls`), heading(`rg '^# DR-80[0-4]:'`).
  - 결정 보류 1건(B 재검토 요청): archive를 full-preserve로 둘지 frontmatter `related_dr:` pointer만 갱신할지. 현재 default=full-preserve.

### Consensus Log

- C1: renumber 방향, DR-001 포함, DR-800 시작, DR-034 evidence 경계 — 합의.
- C2: archive=live grep-0에서 분리, framework allowlist=exact-unchanged 검증, cross-repo flow 분리, rename/heading 직접 검증 — A가 반영 완료, **B 재검토 대기**.
- C3 (open): archive 처리 default(full-preserve) 확정 여부 — B R2 판단 요청.
- **C5 (2026-06-22) — R2 Codex B on redesign brief: Request changes.** hold/spring-untouched/DR-042-untouched는 approve. 단 brief가 4개 쟁점을 덜 분리:
  - **P1-c**: directory namespace는 path-aware check만으로 불충분 — 사람이 쓰는 텍스트 참조(STATUS/backlog/Work/commit/PR)에서 `DR-001`이 경로 문맥 없이 다시 모호. → **canonical reference syntax**(`harness:DR-001`/`product:DR-001` 등)를 먼저 정의해야 함.
  - **P1-d**: brief가 namespace 결정(A)과 `--check` product tracking(B)을 혼합 → 비용 비교 흔들림. high-band가 "도구 0"인 것은 B를 안 할 때만 참. → A/B 분리.
  - **P2-c**: ③ asymmetric의 index topology 미결정(single root + path-qualified rows vs namespace-local README + aggregate). tooling spike 범위가 흐림.
  - **P2-d**: ② prefix를 너무 빨리 탈락. "원천 분리" 목표면 prefix가 reference syntax는 더 선명. ③도 어차피 parser/check/index 손봄 → "전체 regex 개조 vs path-qualified+reference syntax 개조"로 재비교. ②를 "금지"가 아니라 "token-grammar spike 뒤 유효 후보"로 격상.
  - A response: **4개 수용**, brief를 4축(ID namespace / reference syntax / index topology / --check product tracking)으로 재구성. ②/③ 재비교, B 디커플.
- **C7 (2026-06-22) — R3 Codex B on 4축 brief: Request changes.** 4축 분해·B 디커플은 approve. 단 결정 Work 이관 전 4건:
  - **P1-e**: 옵션별 **최종 target ID mapping 부재** → 비용 비교 흔들림. 최소 4행(source framework / ai-deck product / spring product / future scaffold product) mapping table 필요. (ai-deck의 기존 high-band `DR-801~804`를 보존/되돌림에 따라 비용 급변)
  - **P1-f**: ② prefix가 full(HDR/PDR)과 product-only(DR/PDR)를 한 덩어리로 묶음 → blast radius 다름. **②a full prefix** vs **②b product-only prefix(framework=DR 유지)**로 분리. ②b가 가장 현실적 구조 분리안 후보.
  - **P2-e**: ③ reference syntax는 "정의"만으로 부족 → **enforcement level**(어느 파일군 강제 / commit·PR 권고 / check·hook 검출 여부)을 spike scope에 포함.
  - **P2-f**: 축4(`--check` product tracking)를 "먼저 답"하면 namespace 결정이 과대해짐 → **default No/Deferred**, 선택한 namespace가 나중에 B를 수용 가능한지만 평가. 사용자가 명시적으로 원할 때만 yes 승격.
  - A response: **4개 수용.** mapping table 추가, ②a/②b 분리, ③ enforcement level 추가, 축4 default-deferred 재구성. 구조 분리 비교를 **②b vs ③**로 좁힘.
- **C8 (resolved by C9):** mapping table + ②b/③ 재비교 후 방향 — R4 Approve.
- **C9 (2026-06-22) — 최종 결정: ① high-band 유지 (decision-ready).** R4 Codex B = Approve / decision-ready, blocking 없음. Codex B 실무 추천 = 피로도·매몰 비용·adopter 수·blast radius 고려 시 ①. **사용자 최종 결정 = ① high-band 유지** (구조적으론 ②b/③가 깔끔하나 현재 비용/위험/매몰 비용 때문에 ① 채택). spring은 high-band renumber로 종료, ai-deck 무변경 보존.
  - **Regret guardrails(명시):** (1) high-band=1.x 단기 비용 최적화 정책, (2) `PDR-`/②b는 rejected 아닌 deferred successor(②a·③도 successor 보존), (3) 재검토 trigger=product DR friction 반복/adopter 증가/product DR 누적, (4) prefix 전환 시 regex snippet 아닌 **fixture-driven spike**(`PDR-001`→`DR-001` 오인식 방지 fixture 선행), (5) 축4 `--check product tracking`=Deferred.
  - **DR-042 amendment 판단:** 본문 직접 수정은 사용자 승인 대기. guardrail durability는 closeout evidence로도 가능하나, policy SSoT(DR-042)에 "Policy Horizon/Deferred Successor" amendment가 더 durable — 제안만 하고 미수정.
  - Work 재개: status Hold→Active(high-band renumber Work로). **R1 반영분(archive/live 분리, framework lineage allowlist exact, rename/heading 검증) 유지.** spring real apply는 **사용자 승인 후 재개**(이번 턴 미착수).

- **C6 (resolved by C7):** 4축 분리 후 방향 — R3에서 mapping/prefix-split/enforcement/B-defer 추가 요구.

- **C4 (2026-06-22) — 방향 선회 / HOLD.** 사용자 명시 의견: adopter 수가 적고 scaffold도 owner 프로젝트이므로, 단순 high-band renumber보다 harness/product DR namespace를 **원천 분리**하는 게 장기적으로 나을 수 있음. → 이 Work(spring real apply)는 **hold pending namespace redesign decision**(폐기 아님). C2/C3 R1 반영분은 보존하되 implementation은 결정 후로 미룬다. namespace 방향 비교는 신규 brief `docs/briefs/dr-namespace-redesign-20260622.md`에서 진행하고 Codex B R2 red-team을 받는다. DR-042는 이 결정 전 직접 수정하지 않는다. 결정이 "현행 high-band 유지"면 이 Work 재개.

## Checkpoints

- CP1 (2026-06-22): Work file + plan 작성, STATUS Active pointer 추가, R1 review 요청. — 완료
- CP2 (2026-06-22): R1 Codex B(Request changes) 4 finding 수용·반영(collaboration flow 분리, archive=live 분리+full-preserve default, framework allowlist exact 검증, rename/heading 직접 검증). — 완료
- CP3 (2026-06-22): 사용자 의견으로 방향 선회. status→Hold. spring real apply 미착수 유지. namespace redesign brief 작성으로 이관. — 완료
- CP4 (2026-06-22): R2 Codex B(brief revise 요구) 4 finding 수용. brief 4축 재구성, 축4(B) 디커플. — 완료
- CP5 (2026-06-22): R3 Codex B 4 finding 수용. mapping table 추가, ②a/②b 분리, ③ enforcement level, 축4 default-Deferred. — 완료
- CP6 (2026-06-22): R4 Approve + 사용자 최종 결정 = **① high-band 유지**. status Hold→Active로 재개. regret guardrails 기록(C9). plan update 완료, spring 미착수. — 진행 중

## Next Actions

- → **(사용자 승인 대기)** DR-042 amendment 여부: "Policy Horizon/Deferred Successor" caveat를 DR-042 본문에 durable로 남길지, Work closeout evidence로 충분한지 결정.
- → **(사용자 승인 후)** spring repo feature branch에서 high-band renumber 실행 — Slice B/C(R1 반영분 유지: archive/live 분리, framework lineage allowlist exact, rename/heading 직접 검증).
- → 이후 Slice D: Codex B result review → 사용자 최종 승인 → `/work-close` → spring PR(`--base develop`) merge → source closeout(DR-042 Linked Work, evidence + regret caveat).
- ai-deck: 무변경 보존(① 결정으로 기존 high-band 작업 유지).
- spring real apply: 승인 전 미착수 — 별도 사용자 승인 전 착수 금지(이번 턴 미착수).

## Discovery

- `/session-start` 정정: 최초 보고는 archive 대기 Work "없음"이었으나 실제로는 `CHORE-20260621-002~006` 5건이 README "Done (Archive Pending)"에 존재한다. 5건 이상이므로 PLAN 누적 드리프트 soft warning 대상. archive는 별도 housekeeping으로 분리하고 이 Work를 막지 않는다(승인 전 `git mv` 금지).
- owner decision: real apply renumber 승인 + DR-001 포함(5개 전부) 승인.
- scope 발견: spring product DR은 4개가 아니라 5개(DR-001 modular-monolith가 low-band product DR로 동일 위반).
- 실측: framework DR-030~033은 scaffold seed에 DR 파일로 ship되지 않음 → spring에 실제 파일 충돌 없음. ai-deck `DR-014`(seed 포함) 사례와 성격이 다름.
- 실측: spring framework DR 파일(`DR-007/029→DR-030`, `DR-013/014→DR-031`)의 `Linked DRs:`는 framework lineage. renumber 시 미변경 대상.
- 실측: DR 번호는 Java/Gradle/YAML/compose 주석에도 광범위 참조되나 모두 설명 주석(동작 무영향).
- branch: source repo `develop` + source-gitflow → `feature/CHORE-20260622-001-spring-product-dr-renumber` 생성.
- 2026-06-22 방향 선회(C4): 사용자 의견으로 high-band renumber 대신 harness/product DR namespace 원천 분리 가능성을 검토하기로 함. status→Hold. spring repo는 끝까지 미착수(read-only probe 결과만 보유). 후속은 `docs/briefs/dr-namespace-redesign-20260622.md`.
- 실측(tooling 비용 근거): `DR-[0-9]{3}` regex가 `check-shipped-dr-closure.sh`(seed parse·body grep·filename self-ref), `check-scaffold-invariants.sh`([1] dangling, [3] README index closure, `docs/decisions/DR-*.md` flat glob), `tools/git-hooks/*`, `create-harness.sh` adapt에 박혀 있음. `--check`는 manifest `framework_files[].path` 기반이라 product DR은 추적하지 않음(framework-owned만). `docs/decisions/`는 scaffold가 일부 framework DR을 seed하되 project-owned 추가 허용 디렉토리.
