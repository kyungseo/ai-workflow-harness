---
date: 2026-06-22
track: harness
type: comparison
scope: harness/product DR namespace 분리 방식 비교 — 현행 high-band(DR-042) 유지 vs prefix vs directory vs track-only. spring renumber(CHORE-20260622-001) 방향 선회 검토의 결정 입력. R2 후 4축 분해로 재구성
author: "agent:claude-opus-4-8"
related_work: [CHORE-20260622-001]
---

# DR Namespace Redesign — 옵션 비교 (4축 분해판)

> **RESOLVED (2026-06-22) — 결정: ① high-band 유지.** R4 Codex B = Approve / decision-ready.
> 아래 "## R4 + 최종 결정" 섹션이 권위 있는 결과다. 그 아래 분석(결론~축4)은 결정에 이른 비교 기록으로 보존한다.

## R4 + 최종 결정 (2026-06-22)

**R4 Codex B: Approve / decision-ready.** blocking finding 없음. brief는 decision input으로 충분. Codex B 실무 추천 = "현재 피로도·매몰 비용·adopter 수·도구 blast radius를 고려하면 ①로 닫는 것이 가장 합리적. token-grammar spike는 나중에 fixture-driven으로."

**사용자 최종 결정: ① high-band 유지.**

- **결정:** product/adopter DR은 현행 DR-042대로 `DR-800~999` high-band 유지. spring product DR은 high-band renumber로 종료, ai-deck은 무변경 보존.
- **사용자 caveat:** 구조적으로는 ②b/③가 더 깔끔하고 high-band가 미학적으로 별로라는 데 동의한다. 그럼에도 **지금의 비용·위험·매몰 비용** 때문에 Codex B 의견을 받아들여 ①을 채택한다.
- **②b/③는 폐기가 아니라 deferred successor option**으로 남긴다.

### Regret Guardrails (후회 방지 장치 — 명시)

1. **high-band는 1.x 단기/현실 비용 최적화 정책**이다. 영구 최적해 주장이 아니다.
2. **`PDR-`/product-only prefix(②b)는 rejected가 아니라 deferred successor option**이다(②a full prefix·③ directory도 successor 후보로 보존).
3. **재검토 trigger:** product DR friction이 반복되거나, adopter 수가 늘거나, product DR이 일정 수 이상 누적되면 token-grammar spike를 재검토한다.
4. **prefix 전환을 열 경우 regex snippet 기반이 아니라 fixture-driven spike로 진행**한다. 특히 `PDR-001` 내부 `DR-001` 오인식 방지 fixture가 **선행**되어야 한다.
5. **축4 `--check product tracking`은 이번 결정에서 제외(Deferred).** namespace 결정에 끼워넣지 않는다.

### 결정 기록 위치

- 즉시: 이 brief(권위 결과) + Work `CHORE-20260622-001` Consensus/Discovery.
- 제안(사용자 승인 대기): DR-042에 "Policy Horizon / Deferred Successor" amendment로 위 guardrail을 durable하게 남길지. (승인 전 DR-042 본문 미수정)

## 결론 (두괄식)

**아직 ①/②/③ 중 확정하지 않는다.** R2 red-team(Codex B)이 지적한 대로, 이 결정은 단일 축이 아니라 **4개 독립 축**으로 분해해야 비용 비교가 흔들리지 않는다:

1. **ID namespace** — DR을 어떻게 발급/구분하나 (number-band / prefix / directory-path / track-field)
2. **Reference syntax** — 산문·commit·STATUS에서 DR을 어떻게 지칭하나 (bare `DR-001` / `product:DR-001` / `DR-001 (product)` / link-only)
3. **Index topology** — decision index를 어떻게 두나 (flat root / root+namespace column / namespace-local README + aggregate)
4. **`--check` product tracking** — `--check`가 product/project-owned decision surface를 보고할지 (**축 1과 독립된 별개 기능 결정 B**)

핵심 통찰(R2 P1-c): **ID namespace 선택이 reference syntax를 강제한다.** 파일 collision만 없애도 사람이 쓰는 텍스트 `DR-001`이 모호하면 분리는 미완이다. 이 커플링이 옵션의 진짜 비용을 가른다:

| ID namespace | 파일 collision | 텍스트 reference 모호성 | 결과 |
| --- | --- | --- | --- |
| ① number-band | 해소(번호대) | 해소(번호가 자체 식별) | bare 참조 OK, 추가 문법 불필요 |
| ② prefix | 해소 | **자동 해소**(prefix가 곧 qualifier) | reference syntax 공짜로 따라옴 |
| ③ directory | 해소(경로) | **미해소** → 별도 reference syntax 규약 필수 | path-aware check + reference 규약 둘 다 필요 |
| ④ track-only | **미해소** | 미해소 | 목표 미달 |

**재조정된 권고(조건부, 여전히 미확정):**

- "지금 안 깨진 문제" 관점 + 구조 분리 비투자 → **① high-band 유지**. 단 이는 축4(B)를 **하지 않을 때만** 도구 0(R2 P1-d). ①은 ai-deck의 기존 high-band 작업이 그대로 보존되는 유일한 옵션이기도 하다(아래 mapping table).
- "원천 분리"가 목표면 prefix를 **②a full prefix(HDR/PDR)**와 **②b product-only prefix(framework=DR 유지, product=PDR)**로 나눠 본다(R3 P1-f). ②a는 framework DR 전체 rename까지 열려 blast radius 최대. **②b는 framework seed 무변경 + product만 prefix화 + reference syntax 공짜**라 가장 현실적 구조 분리안 후보다.
- 따라서 구조 분리 비교는 이제 **②b(product-only prefix) vs ③ asymmetric directory**로 좁힌다. 둘 다 token/​path spike 필요하나, ②b는 index topology·reference syntax 추가 비용이 없고, ③은 그 둘을 별도로 풀어야 한다.
- ④는 collision 미해소로 탈락(high-band 보조 메타데이터로만 의미).
- **축4(`--check` product tracking)는 default No/Deferred로 둔다**(R3 P2-f). 지금 핵심은 collision/명료성이고, B는 namespace보다 큰 별도 기능 가치 판단이다. 선택할 namespace가 **나중에 B를 수용 가능한지만** 평가하고, 사용자가 명시적으로 "이번에 `--check`까지" 원할 때만 yes로 승격한다.

즉 진짜 fork는 **① 유지(무투자, ai-deck 작업 보존) vs 구조 분리 투자(②b vs ③)**이며, 축4(B)는 어느 쪽이든 **기본 deferred**로 분리한다.

## 질문 / 배경

DR-042(Accepted): product/adopter DR=`DR-800~999`, framework=`DR-001~799`. spring renumber(CHORE-20260622-001)가 2번째 real-apply였다.

사용자 의견(2026-06-22): adopter 적고 scaffold도 owner 프로젝트이니, 매번 800번대 renumber보다 harness/product DR을 **원천 분리**해 쌓고 `--check`도 namespace-aware하게.

제약: prefix(`PDR-001`)는 `DR-[0-9]{3}`가 내부 3자리 오인식 → parser 개조 전 채택 금지. 이번 선회는 hold pending decision(폐기 아님).

R2 reframe: 위 결론의 4축으로 분해. 특히 (A) ID namespace 충돌 해결과 (B) `--check` product tracking은 **서로 다른 목표**이므로 비용을 섞지 않는다.

## 축 1 — ID namespace 옵션 (도구 touchpoint 실측 기반)

도구 touchpoint(불변):

| Touchpoint | 현재 가정 |
| --- | --- |
| `check-shipped-dr-closure.sh` | `^adapt .*docs/decisions/DR-[0-9]{3}` seed 파생, body `grep -oE 'DR-[0-9]{3}'`, filename self-ref |
| `check-scaffold-invariants.sh` | [1] dangling `DR-[0-9]{3}`, [3] README index closure + `docs/decisions/DR-*.md` **flat glob** |
| `tools/git-hooks/*` | DR 참조 검사(regex token) |
| `create-harness.sh` adapt | `docs/decisions/DR-NNN` 경로로 framework DR seed |
| decision index | flat `docs/decisions/README.md`, `DR-[0-9]{3}` 행 |

### ① number-band (현행 high-band)

- **ID:** product=800~999, framework=1~799. **Reference:** bare `DR-851` (번호가 식별). **Index:** flat 그대로.
- **도구 비용(축1):** 0. `DR-[0-9]{3}`·flat glob·index 무변경.
- **단점:** 명료성 약(관습). framework가 799 상한, adopter가 800 시작을 기억해야. 시각적으로 harness/product 구분 안 됨.
- **이 옵션이면:** CHORE-001 R1 반영분 기준 재개 → spring 5개 renumber 종결.

### ②a full prefix (`HDR-` framework / `PDR-` product)

- **ID:** framework=`HDR-NNN`, product=`PDR-NNN`. **Reference:** prefix 내장 → 자동 해소. **Index:** flat 유지(prefix로 구분).
- **도구 비용(축1):** token-grammar spike + **framework DR 40+개 전체 rename + 전 repo·문서 참조 cascade**. blast radius **최대**.
- **판단:** 의미는 가장 대칭적이나, framework 대량 rename은 source repo 전체와 모든 adopter의 framework 참조를 흔든다. 비추천(과투자).

### ②b product-only prefix (`DR-` framework 유지 / `PDR-` product) — R3 신규 분리

- **ID:** framework=`DR-NNN`(무변경), product=`PDR-NNN`. **Reference:** `PDR-001` 내장 qualifier → **텍스트 모호성 자동 해소(축2 비용 0).** **Index:** flat 유지(`DR-`/`PDR-` 행 공존).
- **도구 비용(축1):** **boundary-aware token-grammar spike**가 핵심. `DR-[0-9]{3}`가 `PDR-001`의 내부 `DR-001`을 오인식하지 않도록 모든 check(closure seed/body/self-ref, invariants [1]/[3], hooks, scaffold, index)를 `\bP?DR-[0-9]{3}\b` 류로 boundary 처리. **framework seed는 무변경**이라 ②a보다 surface 훨씬 좁음.
- **장점:** framework 무이동 + product만 prefix화 + reference syntax/index 추가 비용 0. **R3가 지목한 "가장 현실적 구조 분리안."**
- **단점:** boundary 처리를 한 곳이라도 누락하면 `PDR-001`→`DR-001` 오인식 regression(DR-042가 경고한 바로 그 trap). spike 회귀 테스트가 관건.

### ③ directory (asymmetric: framework root 유지 + product만 `docs/decisions/product/`)

- **ID:** 경로가 namespace. framework 30+개 무이동, product만 이동. **Reference:** **별도 규약 + enforcement 필수**(축2). bare `DR-001`은 경로 없이 모호. **Index:** **미결정**(축3, 3a/3b).
- **도구 비용(축1):** flat glob→recursive + 모든 check **path-qualified**(같은 `DR-001` 토큰이 두 경로). closure self-ref/seed, invariants [1]/[3], scaffold adapt 경로, `dr_exists()` glob.
- **장점:** manifest framework-owned vs project-owned 경계와 정합 → 축4(`--check` namespace-aware)와 가장 싸게 맞물림.
- **단점(R2 P1-c):** path-aware check를 고쳐도 텍스트 reference 모호성은 별도 규약 없이 남음. ③은 "축1+축2(+enforcement)+축3"을 동시에 풀어야 완성 → ②b보다 spike 표면 분산.

### ④ track-field only

- **ID:** filename 규칙 동일 + `track:` frontmatter. **Reference:** 미해소. **Index:** flat.
- **치명:** 파일명 collision 미해소(`DR-014` framework vs product 동명). 단독 목표 미달. high-band 등 분리 축과 결합해야만 의미.

### Target-state ID mapping (R3 P1-e) — 옵션별 최종 ID

각 옵션 채택 시 4개 surface가 **최종적으로 어떤 ID**가 되는지. migration 비용·참조 혼란이 여기서 갈린다.

| Surface (현재) | ① high-band | ②a full prefix | ②b product-only prefix | ③ directory(asym) |
| --- | --- | --- | --- | --- |
| source framework DR (`DR-001`~`DR-042`…) | `DR-001`~ (무변경) | **`HDR-001`~ (전체 rename)** | `DR-001`~ (무변경) | `docs/decisions/DR-001`~ (무변경) |
| ai-deck product DR (현재 `DR-801`~`804`) | `DR-801`~`804` (무변경, **기존 작업 보존**) | `PDR-001`~`004` (**high-band 되돌림**) | `PDR-001`~`004` (**high-band 되돌림**) | `product/DR-001`~`004` (**high-band 되돌림**) |
| spring product DR (현재 `DR-001/030~033`) | `DR-800`~`804` (renumber) | `PDR-001`~`005` | `PDR-001`~`005` | `product/DR-001`~`005` (저번호 보존 가능) |
| future scaffold product DR | repo별 `DR-800`~`999` | repo별 `PDR-001`~ | repo별 `PDR-001`~ | repo별 `product/DR-001`~ |

**핵심 함의(decision-critical):**

- **① 만이 ai-deck의 기존 high-band 작업(CHORE-004)을 보존한다.** ②a/②b/③ 모두 ai-deck `DR-801~804`를 저번호(`PDR-00x`/`product/DR-00x`)로 **되돌리는** migration이 발생 → CHORE-004가 사실상 throwaway가 된다. 이 매몰 비용을 decision에서 명시 인지해야 한다.
- ②b/③ 채택 시 product는 high-band가 불필요해져 **자연 저번호**로 회귀(prefix/path가 disambiguate). spring은 어차피 미적용이라 손해 없음. ai-deck만 재작업.
- ②a는 framework rename 때문에 source+전 adopter framework 참조까지 흔들림 → 단독으로 비추천.

## 축 2 — Reference syntax (③ 채택 시 필수, ②는 자동)

`DR-001`이 framework/product 둘 다일 때 산문·commit·STATUS·backlog에서 어떻게 지칭하나:

| 방식 | 예 | 적합 옵션 | 비고 |
| --- | --- | --- | --- |
| bare | `DR-001` | ①(번호로 구분), ② 불필요 | ③엔 부적합(모호) |
| namespace prefix-in-text | `product:DR-001` / `harness:DR-001` | ③ | 사람이 매번 prefix 표기 — 누락 위험 |
| 괄호 한정 | `DR-001 (product)` | ③ | 가독성 ↑, 기계 파싱 ↓ |
| ID 자체가 prefix | `PDR-001` | ② | 표기·파싱 모두 일관(축2 비용 0) |
| link/path-only | `[DR-001](docs/decisions/product/DR-001-...md)` | ③ | 엄격하나 산문/commit에 무겁다 |

→ **③의 숨은 비용은 축2다.** ②(특히 ②b)는 ID가 곧 reference라 축2가 사라진다. 이 차이가 R2 P2-d의 핵심.

**Reference syntax enforcement level (R3 P2-e) — ③ 채택 시 spike scope에 포함:** 규약을 "정의"만 하면 bare `DR-001`이 다시 퍼진다. 강제 수준을 surface별로 못박아야 한다.

| Surface | enforcement | 검출 방법 |
| --- | --- | --- |
| `docs/STATUS.md`, `docs/backlog/**`, `docs/works/**`, `docs/decisions/README.md` | **강제(hard)** | check/hook에서 product-context bare `DR-NNN` 탐지 시 fail |
| 문서 본문(briefs/retrospectives/troubleshooting 등) | 권고(warn) | 선택적 lint |
| commit/PR body | 권고 | 비강제(가독성 우선) |
| DR 파일 내부 `Linked DRs:` | 경로 또는 namespace 한정 필수 | closure 검증과 연동 |

즉 ③의 tooling spike = path-aware check + index topology(3a/3b) + **이 enforcement 레이어**까지. ②b는 이 레이어가 불필요(prefix가 곧 강제).

## 축 3 — Index topology (③ 전용, tooling spike 범위 결정)

③ asymmetric에서 `docs/decisions/README.md`를 어떻게:

| 하위안 | 구조 | 영향 |
| --- | --- | --- |
| **3a. single root + path-qualified rows** | root README 1개에 framework/product 행을 경로/namespace 컬럼으로 구분 | invariants [3] closure를 path-qualified로만 고치면 됨. 탐색 1곳 |
| **3b. namespace-local README + aggregate pointer** | `docs/decisions/product/README.md` 별도 + root는 pointer | mirror/aggregate 검증 신규. 탐색 2곳. project-owned 경계와 더 정합 |

현재 `check-scaffold-invariants.sh` [3]/[4]는 **flat root README + flat `docs/decisions/DR-*.md`를 직접 가정**한다. 둘 중 무엇을 고르냐에 따라 invariant/closure/user 탐색 경로가 달라지므로, **③ 채택 전 3a/3b를 먼저 골라야 spike 범위가 확정**된다(R2 P2-c).

## 축 4 — `--check` product tracking (축1과 독립 / 별개 결정 B)

현재 `--check`는 manifest `framework_files[].path` 기반이라 **product DR을 아예 추적하지 않는다**(framework-owned만 in-sync/drift). R2 P1-d:

- high-band(①)로 "namespace만 닫는다"면 → `--check` product tracking은 **불필요**. ①의 "도구 0"은 이 경우에만 참.
- "product DR도 `--check`가 인지/보고해야 한다"가 목표라면 → **①도 비용 0이 아니다**(번호대 인지 로직 추가). ③ directory는 `docs/decisions/product/**`를 project-owned로 자연 매핑해 이 기능이 가장 싸다.

**결정 B를 축1과 분리하고, default를 No/Deferred로 둔다(R3 P2-f).** B(`--check`가 product DR을 추적/보고)는 namespace collision보다 큰 별도 기능 가치 판단이다. 이걸 "먼저 답"하면 namespace 결정이 과대해진다. 따라서: B 기본값=Deferred, **선택할 namespace가 나중에 B를 수용 가능한지만** 평가한다(③ directory가 manifest 경계와 정합돼 수용 최저비용). 사용자가 명시적으로 "이번에 `--check`까지"를 원할 때만 B를 yes로 승격한다. 이전 판은 B를 A의 자연 결과처럼 섞었다 — 교정 완료.

## 종합: 의사결정 순서 (구현 아님)

1. **축4(B)는 기본 Deferred.** 명시 요구가 없으면 namespace 결정에서 제외하고, 각 옵션의 "B 수용 가능성"만 메모(③≈저비용, ①≈번호대 로직, ②b≈prefix 로직).
2. **구조 분리 투자 여부:** "관습(번호)로 충분"이면 **① 확정 → CHORE-001 재개**(ai-deck 작업도 보존). "원천 분리"면 3으로.
3. **②b(product-only prefix) vs ③(asymmetric directory) 재비교** (②a는 framework rename 과투자로 제외):
   - 공통: 둘 다 ai-deck high-band 되돌림 migration 발생(매몰 비용 인지).
   - ②b = boundary-aware token-grammar spike 1건으로 ID+reference 동시 해결, index 무변경. 위험=boundary 누락 regression.
   - ③ = path-aware check + reference enforcement 레이어 + index topology(3a/3b) — spike 표면 분산. 강점=manifest/`--check` 정합.
   - 단순성·reference 선명성·index 무변경 → **②b 우세 가능**(R3 지목). manifest 정합·미래 B 저비용 → ③ 우세.
4. 채택 옵션 확정 후에만 DR-042 amend/supersede 결정 Work + (구조 분리 시) tooling spike Work + product DR migration apply.

## Revisit Triggers

- adopter 3개 초과 직전 — product DR migration 비용 본격화 전 ②/③ 여부 확정(지금이 최저점).
- 구조 분리 spike 견적이 "① 유지로 영구히 사는 비용"보다 크면 ① 회귀.
- 축4(B) 요구가 독립적으로 강해지면 옵션 무관 신규 기능으로 우선 평가.

## 연결

- 결정 입력 Work: `docs/works/harness/CHORE-20260622-001-spring-product-dr-renumber.md` (HOLD, C4·C5·C7)
- 현행 정책: `docs/decisions/DR-042-adopter-dr-namespace-allocation.md` (Accepted — 결정 전 미수정)
- 선례: `docs/works/harness/CHORE-20260621-004-adopter-dr-namespace-apply.md`(ai-deck high-band apply), `docs/HARNESS-NAMING-RULES.md` §DR ID
- 도구: `scripts/tests/check-shipped-dr-closure.sh`, `scripts/tests/check-scaffold-invariants.sh`, `scripts/create-harness.sh`, `tools/git-hooks/*`

## 제안: 후속 결정 slice (구현 아님)

R3 반영(mapping table + ②a/②b 분리 + ③ enforcement + B defer) 후 R4 red-team을 거쳐 합의되면:

- **결정 Work(신규 CHORE, decision-only)** — 구조 분리 여부 + (분리 시) **②b vs ③** 확정 + (③ 시) index topology(3a/3b) + reference enforcement level + 축4(B)는 기본 Deferred(명시 요구 시만 yes). 산출물=DR-042 amend/supersede 안 + spike scope + ai-deck 되돌림 migration 인지.
- 구조 분리 채택 시에만 → **tooling spike Work**(②b=boundary-aware token-grammar / ③=path-aware+reference enforcement+index) 선행, 그 뒤 product DR migration apply(ai-deck 되돌림 포함).
- ① 확정 시 → CHORE-20260622-001 재개로 종결(ai-deck 무변경).
