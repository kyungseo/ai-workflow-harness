---
id: CHORE-20260713-008
priority: P1
status: Archived
risk: L2
scope: Happy path / glossary / operator layering compression — 2-surface bounded cascade. source README Start Here(새 적용 1-2-3 + target Quick Reference pointer) + shipped docs/HARNESS-QUICK-REFERENCE.md(재진입·Quick vs Work·AI 첫 메시지), README 비규범 Orientation Glossary(회고 §4.4 5그룹), Documentation Map 3그룹 재배치(최소 재포장 1차). Quick Reference는 shipped surface — scaffold cascade 포함. 신규 문서 생성·WORKFLOW-MANUAL/ONBOARDING-GUIDE/generated README 재작성·3층 full 재포장은 비범위 (0.5-day bounded slice).
appetite: 0.5d
planned_start: 2026-07-13
planned_end: 2026-07-13
actual_end: 2026-07-13
related_dr: []
related_work: [CHORE-20260612-002]
---

# CHORE-20260713-008: Happy path / glossary / operator layering compression

## Top Summary

v1.2.0 readiness 회고(`harness-v1-2-readiness-retrospective-20260615.md`)가 지적한 신규 사용자 부담 3가지를 **bounded하게 압축한다** — ① happy path가 얇지 않음(§4.3)과 ② 용어 DSL(§3.4/§4.4)은 이 slice에서 닫고, ③ maintainer-brain(§3.3 — 3층 재포장)은 **최소 재포장 1차(3그룹 재배치)까지만** 수행한다(full repack은 revisit trigger 대기).

**현행 실측:** README `Start Here`는 사용자 유형 routing + "새 project 적용 1-2-3"을 이미 보유. 부재: ② 이미 적용된 project 재진입 경로, ③ Quick Mode vs Work file 경계(Core Concepts에 묻힘), ④ AI 첫 메시지 안내, glossary 전체.

**Slice 경계:** 회고 §3.3의 full 3층 재포장은 이 slice 초과 — Documentation Map **3그룹 재배치(primary entry + load condition)를 "최소 재포장 1차"**로 수행하고, 반복 혼란이 실측되면 full repack을 별도 후보로 분리한다. 문서 수는 늘리지 않는다(회고 결론: "다음 단계는 문서를 더 늘리는 것이 아니라").

## Scope

**포함 (R0 개정 — 2-surface bounded cascade):**

- **D1a. source `README.md` Start Here 재구성 (R0-F1):** 새 project 적용 1-2-3(기존 유지·정돈) + **"이미 적용된 project 안에 있다면 → 그 repo의 `docs/HARNESS-QUICK-REFERENCE.md`" pointer**를 한 화면에. 협업 정체성·"이 repo를 workspace로 쓰지 말라" warning 보존(R0-F6).
- **D1b. shipped `docs/HARNESS-QUICK-REFERENCE.md`에 daily operator 진입 보강 (R0-F1):** target 재진입 1-2-3 + Quick Mode vs Work file 1줄 경계 + AI 첫 메시지 escape path("모르면 `/session-start`"). Quick Reference가 target-side 재진입 질문의 주인.
- **D2. source README `Orientation Glossary` (R0-F2):** **비규범 orientation 요약** 명시 — 5그룹 각 "무엇을 구분하는 말인가/어디로 가는가" 1줄 + SSoT pointer. threshold·판정 절차 재서술 금지. Quick Reference에는 5그룹 복제 없이 escape path만.
- **D3. README Documentation Map을 3그룹 재배치 (R0-F3):** label-only가 아니라 10-minute(Start Here/첫 적용) / daily operator(Quick Reference 중심) / maintainer deep reference(기존 `<details>`) 그룹 + 각 primary entry 1개 + load condition. **"최소 재포장 1차"로만 주장** — full 3-layer rewrite 완료 표현 금지, 반복 혼란 관측 시 별도 full repack 후보(회고 §8 revisit trigger 승계).
- source-only/target 문서 혼합 여부 확인.

**비포함 (R0-F5):**

- 신규 문서 생성(별도 GLOSSARY.md·HAPPY-PATH.md 비채택), WORKFLOW-MANUAL·ONBOARDING-GUIDE·**target generated README** 재작성(현행 generated README가 Quick Reference를 이미 파일표에서 가리킴 — create-harness README 본문 수정 불필요), 3층 full 재포장, 용어 개명. glossary 정의 논쟁·3층 본문 재작성으로 번지면 slice 중단 후 분리.

## Plan

1. Work 파일 + plan → **R0 Codex plan review** → consensus
2. source README Start Here 재구성(D1a) → Quick Reference daily operator 진입 보강(D1b) → Orientation Glossary(D2) → Documentation Map 3그룹 재배치(D3)
3. Verification → **R1 Codex result review** → 사용자 최종 승인
4. `/work-close` → commit → PR(`--base develop`) → merge

## Done Criteria

- [x] 4개 질문이 **실제 독자 위치에서** 해결: 새 적용(source README 한 화면) / 재진입·Quick vs Work·AI 첫 메시지(shipped Quick Reference) + source→target pointer (D1a/D1b, CP1)
- [x] Orientation Glossary — 회고 §4.4 5그룹, 비규범 1줄+pointer, source README (D2, CP1)
- [x] Documentation Map 3그룹 재배치 + primary entry + load condition — "최소 재포장 1차" (D3, CP1)
- [x] happy path가 source-only maintainer 문서를 요구하지 않음 + source/target 문서 혼합 없음 (CP1 two-scenario self-check)
- [x] scaffold 검증: fresh generic scaffold에서 수정된 Quick Reference + generated README 기존 pointer 공존 확인 (R0-F4, CP1)
- [x] cross-agent consensus: R0(plan) + R1(result, R1b 포함) 종결 — R1b approve, reviewer 독립 routing simulation 양 시나리오 PASS
- [x] 사용자 최종 리뷰 후 Done (2026-07-13 arbiter 최종 승인 — work-close·commit·PR·merge 지시)

## Verification

- README routing diff review (기존 정보 손실 없이 재구성 — R0-F6 보존 항목 포함), anchor/link 정합(TOC에 Glossary anchor 반영, Start Here↔Core Concepts Quick Mode 문구 정합, Documentation Map link)
- stale phrase grep, `git diff --check`, `bash scripts/tests/run-harness-checks.sh --tier0`
- **two-scenario routing simulation (R0-F4):** ⓐ source-new-adopter — README만으로 적용 경로 도달, ⓑ target-returning-operator — Quick Reference만으로 재진입·Quick/Work·첫 메시지 답 도달
- **fresh generic scaffold 확인 (R0-F4 — N/A 철회):** 수정된 `docs/HARNESS-QUICK-REFERENCE.md`가 target에 복사되고 generated README의 기존 Quick Reference pointer와 공존하는지
- Surface: README/GUIDE/MANUAL · **scaffold(Quick Reference shipped)** · adopter cascade(기존 adopter는 다음 upgrade에서 수용 — "현재 모든 target 개선됨" 과장 금지)

## Risk / Reversal Cost

- **Low** — 문서 2파일(source README + shipped Quick Reference) 표면, revert 용이. Quick Reference는 shipped라 다음 릴리즈부터 신규/upgrade target에 전파. 주 리스크는 압축 중 기존 정확 정보 손실 → 삭제 없이 재구성·추가 중심으로 완화.
- glossary 1줄 정의가 SSoT 문서와 어긋날 위험 → 정의는 요약+pointer로, 재서술 최소화.

## Discovery

- Archived: 2026-07-13 — 당일 완료 3건(-006/-007/-008) batch archive (arbiter 지시).
- 착수: 2026-07-13, backlog W2 "Happy path / glossary / operator layering compression" candidate 착수. branch `feature/happy-path-compression`.
- Done: 2026-07-13, cross-review R0/R1(request-changes)→R1b(approve) + reviewer 독립 routing simulation 2건 PASS + arbiter 최종 승인.
- Needs-Triage: full 3-layer repack — 이번 slice는 "최소 재포장 1차"(3그룹 재배치)까지만 수행. 회고 §8 trigger("줄였는데도 혼란 반복") 관측 시 별도 후보로 개봉할 가치.

## Checkpoints

### CP1 — EXECUTE 완료 (2026-07-13)

| 대상 | 변경 |
| --- | --- |
| `README.md` Start Here (D1a) | 유형 표에 **재진입 행 신설**(→ target repo `docs/HARNESS-QUICK-REFERENCE.md` §1), "새 프로젝트에 적용하기 1-2-3" 정돈(AI 첫 메시지 = step 2에 `/session-start`+fallback), workspace 경고·정체성 문구 보존(R0-F6) |
| `docs/HARNESS-QUICK-REFERENCE.md` §1 (D1b, shipped) | 서두에 **재진입 1-2-3** 신설 — `/session-start`, Active Work/`/work-select`, Quick Mode vs Work 파일 1줄 경계(SSoT pointer 유지) + "모르면 일단 `/session-start`" escape. AI 실행 규칙 본문과 구분선 분리 |
| `README.md` Orientation Glossary (D2) | 신설 — **비규범 명시**, 5그룹 각 "무엇을 구분하나/정확한 기준은 어디에" 1줄+pointer(source-only pointer는 라벨 표기), escape 1줄. TOC anchor 추가 |
| `README.md` Documentation Map (D3) | flat 17행 → **3그룹 재배치**: 10-Minute Path(primary: Start Here) / Daily Operator(primary: 적용 repo Quick Reference) / Maintainer Deep Reference(primary: maintainer README + 기존 `<details>` 유지). "최소 재포장 1차" 명시 |

**검증:** `git diff --check` OK, tier0 PASS. **fresh generic scaffold 확인(R0-F4):** 수정된 Quick Reference가 target에 복사되고(재진입 블록 존재) generated README의 기존 Quick Reference pointer 2곳과 공존. **two-scenario routing self-check:** ⓐ 새 적용 — README 한 화면에서 1-2-3 도달, ⓑ 재진입 — Quick Reference §1 서두에서 3개 질문 답 도달, source-only 문서 요구 없음. Glossary anchor 4개소 정합.

**잔여:** temp probe 2건(`temp/harness-tests/{hp-probe,delta-probe}`, gitignored) — rm 권한 보류로 잔존. **revisit trigger 승계(R0-F4):** 회고 §8 "줄였는데도 혼란 반복 시" → full 3-layer repack 별도 후보로 개봉.

## Cross-Agent Review And Discussion

Model: manual relay (`/cross-review`). Driver = Claude, Reviewer = Codex (red-team), Arbiter = User.
Max Rounds: plan 1 + result 1 기본.

### R0 — Plan Review (Cross-Agent Relay Packet)

**Role:** Driver = Claude / Reviewer = Codex / Arbiter = User

**Target:** 이 Work 파일 (§Scope D1~D3, slice 경계). 입력: 회고 §3.3·§3.4·§4.3·§4.4, README 현행 Start Here(10~49행)·Core Concepts(366~423행)·Documentation Map(466행~), backlog Done Criteria.

**Current State:** branch `feature/happy-path-compression`, PLAN 단계. validation 없음.

**Review Objective (red-team):**
1. **위치 판단:** 4개 질문의 happy path와 glossary를 README에 두는 것이 맞는가 — 재진입 사용자(②)는 target repo에 있어서 source README를 안 볼 수 있다. target-side 표면(QUICK-REFERENCE 또는 scaffold 생성 README)에도 두어야 하는가, 그러면 slice가 커지는가.
2. **D2 glossary 형태:** README 섹션 vs 별도 파일 — 회고 "문서 늘리지 말라"와 발견 가능성의 trade-off. 5그룹 1줄 정의가 SSoT 재서술 drift를 만들지 않는 경계.
3. **D3 압축 적정성:** 3층 full 재포장을 라벨링으로 대체하는 것이 회고 취지를 충족하는가, 아니면 라벨만으로는 §3.3이 다시 열리는가.
4. scope 누락·hidden cost: TOC/anchor cascade, backlog Done Criteria 항목("AI에게 첫 메시지" 등) 대비 커버리지, revisit trigger(회고 491행 "줄였는데도 혼란 반복 시") 처리.

**Do Not Re-litigate:** 회고 자체의 판정, W2 우선순위, cross-agent 역할, 문서 신규 대량 생성 금지 방향.

**Output Contract:** Verdict + must-fix/nice-to-have + residual risk를 `### R0 — Reviewer Findings (Codex)`에 기록, Round Log 갱신. 1번(위치 판단)에 명시적 의견 포함.

### R0 — Reviewer Findings (Codex)

**Verdict: request-changes.** happy path compression 방향과 문서 무증설 원칙은 타당하지만, source README 한 파일로 4개 질문을 닫는 현재 위치 설계는 목적과 맞지 않는다. 새 project 적용자는 source README를 보지만, 이미 적용된 project의 재진입 사용자는 target repo 안에 있고 source README를 보지 않는다. D1의 위치와 D3의 완료 주장, scaffold cascade를 먼저 교정한 뒤 구현해야 한다.

#### Must-Fix Findings

**R0-F1 — 위치 판단: source README 단독은 부적합하며, source/target 2-surface가 최소 정답이다.** 새 project 적용 1-2-3은 source `README.md` Start Here가 맞다. 반면 이미 적용된 project 재진입, Quick Mode vs Work file, AI 첫 메시지는 target에 기본 ship되는 `docs/HARNESS-QUICK-REFERENCE.md`의 daily operator 경로가 맞다. generated target README는 product README로 보강·교체될 수 있어 장기 canonical로 삼기 어렵고, 현행 generated README가 Quick Reference를 이미 파일표에서 가리키므로 `create-harness.sh`의 README 본문까지 고칠 필요는 없다. 권고 구조는 (a) source README가 새 적용 경로와 “이미 target 안에 있다면 Quick Reference” pointer를 한 화면에 제시하고, (b) Quick Reference가 target 재진입 1-2-3 + Quick/Work 경계 + 첫 메시지 escape path를 보유하는 것이다. 이는 무제한 scope 확장이 아니라 목표를 실제 독자 위치에 배치하는 2파일 bounded cascade다. README-only를 고수한다면 Work 목표를 source adopter onboarding으로 좁히고 “적용 project 재진입” 완료 주장은 철회해야 한다.

**R0-F2 — D2는 별도 glossary 파일보다 source README의 compact orientation glossary가 적정하지만, normative SSoT로 만들면 안 된다.** 5그룹을 위해 새 파일을 만들면 discovery를 한 hop 늘리고 회고의 문서 무증설 방향에도 역행한다. README에는 용어별 상세 규칙이 아니라 “무엇을 구분하는 말인가 / 어디로 가야 하는가”만 한 줄로 둬라. Quick Mode criteria, ownership 판정 절차, Tier/Layer 세부 정의 같은 threshold는 재서술하지 않고 각각 `AGENT-WORKFLOW`, ownership/current architecture, maintainer taxonomy로 pointer한다. 섹션을 `Orientation Glossary`처럼 비규범 요약으로 명시하고, target Quick Reference에는 5그룹 전체를 복제하지 말고 “모르면 `/session-start`; 작은 변경 여부가 불명확하면 Work 경로” 같은 operator escape path만 둬라.

**R0-F3 — D3의 label-only 변경은 회고 §3.3의 “3층 재포장”을 닫았다고 주장하기에 부족하다.** 기존 flat Documentation Map에 `10분/daily/maintainer` 열만 붙이면 독자는 여전히 어느 문서 하나를 먼저 읽어야 하는지 선택해야 한다. bounded 대안은 새 문서 없이 map을 세 그룹으로 실제 재배치하고 각 그룹에 primary entry 1개와 load condition을 두는 것이다: 10-minute = Start Here/첫 적용, daily operator = Quick Reference 중심, maintainer = 기존 `<details>` deep reference. 이 수준까지 하면 “최소 재포장 1차”로 인정할 수 있다. 단 full 3-layer rewrite가 완료됐다는 표현은 피하고, 반복 혼란 trigger가 관측되면 별도 full repack 후보로 올린다는 경계를 Work에 남겨라.

**R0-F4 — target-side 편입에 맞춰 Done Criteria와 Verification의 scaffold N/A를 교정해야 한다.** Quick Reference는 `create-harness.sh`가 default target으로 복사하는 framework-owned surface이므로 scaffold 영향은 N/A가 아니다. source-new-adopter와 target-returning-operator 두 시나리오를 각각 fresh-session routing simulation으로 검증하고, fresh generic scaffold에서 수정된 Quick Reference와 generated README의 기존 pointer가 함께 존재하는지 확인하라. README 새 Glossary anchor의 TOC 반영, Start Here/Core Concepts 간 Quick Mode 문구 정합, Documentation Map link/anchor 정합도 명시해야 한다. 회고는 Done 문서이므로 수정하지 말고, 회고 8절의 “줄였는데도 혼란 반복” 조건을 이 Work의 residual/revisit trigger로 승계하라.

#### Nice-To-Have Findings

**R0-F5 — 0.5-day 경계를 지키려면 target generated README·WORKFLOW-MANUAL·ONBOARDING-GUIDE 재작성은 계속 제외하라.** source README와 shipped Quick Reference 두 파일에서 routing만 압축하고, 상세 절차는 기존 SSoT로 pointer한다. 구현 중 glossary 정의 논쟁이나 3층별 본문 재작성으로 번지면 이 slice를 멈추고 후속 work로 분리하는 것이 맞다.

**R0-F6 — 기존 README의 협업 정체성과 source/target 경계 문구를 압축 과정에서 보존하라.** Start Here를 재구성하더라도 repository 자체를 product workspace로 쓰지 말라는 warning과 Human-AI collaboration 설명을 제거하지 말고, user routing만 더 얇게 만들어야 한다.

#### Residual Risk

- source README glossary는 기존 target에 자동 도달하지 않는다. 이번 slice는 target에 operator escape path만 제공하므로, target 사용자가 broader DSL에서 계속 막히는지는 실제 feedback으로 재평가해야 한다.
- Quick Reference 변경도 기존 adopter에는 다음 upgrade 전까지 도달하지 않는다. “현재 모든 target의 재진입 UX가 개선됨”으로 과장하면 안 된다.
- 3-group Documentation Map은 navigation 개선이지 실제 novice comprehension 증명은 아니다. fresh-session simulation은 routing 증거일 뿐 외부 사용자 검증이 아니다.
- source/target 두 표면에 `/session-start`가 등장하더라도 문구 목적이 다르다. source README는 routing pointer, Quick Reference는 daily action으로 제한해 drift를 억제해야 한다.

### R0 — Driver Response (Claude)

| Finding | Decision | Response |
| --- | --- | --- |
| R0-F1 | accept (원안 README-only 철회) | 2-surface bounded cascade 채택 — source README(새 적용 + target pointer) / shipped Quick Reference(재진입·Quick/Work·첫 메시지). generated README 본문은 비대상(기존 pointer 활용) |
| R0-F2 | accept | README `Orientation Glossary` 비규범 명시, 1줄+SSoT pointer, threshold 재서술 금지. Quick Reference에는 escape path만 |
| R0-F3 | accept | label-only 철회 — 3그룹 재배치 + primary entry + load condition. "최소 재포장 1차"로만 주장, full repack은 revisit trigger 승계 |
| R0-F4 | accept | scaffold N/A 철회 — fresh generic scaffold 확인 + two-scenario routing simulation을 Verification에 편입. 회고 문서는 불변, revisit trigger만 승계 |
| R0-F5 (nice) | accept | 비포함 목록에 generated README·slice 중단 조건 명시 |
| R0-F6 (nice) | accept | 협업 정체성·workspace 경고 보존을 D1a에 명시 |

### Round Log / Consensus Log

| Round | Date | Driver | Reviewer | Verdict | 기록 |
| --- | --- | --- | --- | --- | --- |
| R0 | 2026-07-13 | Claude (Work+plan 작성, packet 발행) | Codex (plan review) | request-changes | 위치를 source README + target Quick Reference 2-surface로 교정하고 D3/cascade 완료 주장 축소 필요 — driver response 대기 |
| R0-resp | 2026-07-13 | Claude (F1~F6 전부 accept, Plan 개정) | — | **consensus (arbiter 확정 대기)** | 2-surface 구조(F1), 비규범 glossary(F2), 3그룹 재배치(F3), scaffold 검증 편입(F4), slice 경계·보존 항목(F5·F6) |
| R1 | 2026-07-13 | Claude (EXECUTE+검증, result packet 발행) | Codex (result review + 독립 routing simulation) | request-changes | routing/D3/Quick Reference는 PASS, Work metadata·glossary 정의/pointer 좁은 교정 필요 — driver response 대기 |
| R1-resp | 2026-07-13 | Claude (F1·F2 accept, 교정 완료) | — | R1b static 재확인 대기 | frontmatter/Top Summary/Risk current-truth 동기화(F1), Glossary 열 제목·구분·pointer 교정(F2), tier0 재실행 PASS |
| R1b | 2026-07-13 | Claude (R1 F1·F2 교정) | Codex (static confirmation) | **approve** | F1 current-truth 동기화와 F2 비규범 glossary 정의·pointer 교정 충실 — cross-agent consensus 종결, 사용자 최종 승인 대기 |

| Topic | Status | Notes |
| --- | --- | --- |
| 위치 | agreed | source README(새 적용) + shipped Quick Reference(재진입·daily) 2-surface |
| glossary | agreed | README 비규범 Orientation Glossary, 별도 파일 비채택 |
| D3 수준 | agreed | 3그룹 재배치 = "최소 재포장 1차", full repack은 trigger 대기 |
| scaffold | agreed | Quick Reference shipped — fresh scaffold 검증 필수, 기존 adopter는 다음 upgrade 수용 |

### R1 — Result Review (Cross-Agent Relay Packet)

**Role:** Driver = Claude / Reviewer = Codex / Arbiter = User

**Target:** working tree diff (미commit): `README.md`(Start Here·Orientation Glossary·Documentation Map 3그룹·TOC), `docs/HARNESS-QUICK-REFERENCE.md`(§1 재진입 블록). 이 Work 파일 CP1.

**Current State:** branch `feature/happy-path-compression`, EXECUTE 완료. `git diff --check` OK, tier0 PASS, fresh generic scaffold에서 Quick Reference 전파 + generated README pointer 공존 확인.

**Review Objective (red-team):**
1. **R0 반영 충실도:** F1 2-surface 배치가 실제 독자 위치에 맞는가 — README 재진입 행과 Quick Reference §1 서두가 상호 모순 없는가. F2 glossary가 비규범 경계(threshold 재서술 금지)를 지켰는가. F6 보존 항목 확인.
2. **정보 손실:** Documentation Map 재배치에서 기존 17행이 전부 3그룹 어딘가에 살아 있는가, 그룹 배정이 오독을 만드는 곳은 없는가.
3. **Quick Reference 성격 충돌:** AI 실행 규칙 문서 서두에 사람용 재진입 블록을 둔 것이 문서 정체성·auto-load 소비(예: Codex가 세션 중 로드 시 노이즈)에 부작용이 없는가.
4. **routing simulation 독립 재현:** 두 시나리오(ⓐ 새 적용 — README만, ⓑ 재진입 — Quick Reference만)를 reviewer 관점에서 재현해 답 도달 여부 기록.
5. 과장 여부: "최소 재포장 1차"·adopter 미도달(다음 upgrade 수용) 경계 준수.

**Do Not Re-litigate:** R0 consensus(2-surface·비규범 glossary·3그룹 수준), 회고 판정.

**Output Contract:** Verdict + must-fix/nice-to-have + residual risk를 `### R1 — Reviewer Findings (Codex)`에 기록, Round Log 갱신.

### R1 — Reviewer Findings (Codex)

**Verdict: request-changes.** 2-surface routing, Documentation Map 3그룹, Quick Reference 사람용 block은 R0 취지대로 구현됐고 독립 routing simulation도 양쪽 PASS다. 다만 Work frontmatter와 Top Summary가 아직 README-only/label-only/scaffold N/A 원안을 남겨 결과 경계를 과장하며, Orientation Glossary의 일부 정의와 “정확한 기준” pointer가 실제 SSoT를 가리키지 않는다. 추가 설계 round 없이 이 두 묶음만 교정하면 된다.

#### Must-Fix Findings

**R1-F1 — Work current-truth metadata와 결과 표현을 2-surface 결정에 맞춰야 한다.** frontmatter `scope`는 여전히 “README Start Here에 4개 질문”, “Documentation Map 3층 라벨”, “scaffold 표면 변경 비범위”라고 적어 실제 구현(D1a/D1b, 3그룹 재배치, shipped Quick Reference)과 모순된다. Top Summary 첫 문장의 “신규 사용자 부담 3가지를 ... 닫는다”도 D3를 “최소 재포장 1차”로 제한한 현재 경계보다 강하다. frontmatter를 2-surface + 3-group + shipped Quick Reference cascade로 고치고, Top Summary는 “3가지를 bounded하게 압축하되 D3는 최소 재포장 1차”로 제한하라. Risk의 “source README 중심” 표현도 2파일 표면으로 동기화하면 충분하다.

**R1-F2 — Orientation Glossary의 1줄 정의와 pointer를 SSoT 소유권에 맞게 교정해야 한다.** 비규범 선언과 source-only label 자체는 좋지만 다음 세부가 부정확하다.

- `source repo / scaffold target / product repo` 행은 source와 “적용 repo”만 대비해 scaffold target과 product repo를 하나로 합친다. target은 framework를 받는 적용 위치, product repo는 product code/state의 소유 repo이며 보통 같은 물리 repo일 수 있다는 차이를 한 줄 안에서 보존하라.
- `framework-owned / project-owned / accepted drift`의 정확한 기준을 manifest + `--check`만으로 가리키면 accepted-drift의 보존 판단·기록 owner가 빠진다. manifest/`--check`는 tracked baseline과 drift signal을 제공할 뿐이고, accepted-drift 판정은 upgrade ownership 절차가 소유한다. source-only upgrade entry/playbook pointer를 함께 두거나 “정확한 기준” 열의 표현을 “더 볼 곳”으로 낮춰라.
- `Work / DR / STATUS / backlog`는 `#core-concepts`가 아니라 실제 `#state-storage` anchor로 직접 연결하는 편이 약속한 exact pointer에 맞다.
- `Tier / Layer / runner`는 taxonomy 한 문서만으로 Layer command catalog까지 소유하지 않는다. Tier/runner는 `HARNESS-TEST-TAXONOMY`, Layer는 `VERIFICATION-COMMANDS`로 pointer를 분리하라.

#### Confirmed / No Blocking Finding

- **R0 2-surface 정합:** source README는 새 적용 1-2-3과 target Quick Reference pointer만, Quick Reference는 재진입·Quick/Work·첫 메시지만 소유한다. 두 표면의 `/session-start` 역할이 상충하지 않는다.
- **F6 보존:** source/workspace 경고는 그대로 있고 기존 collaboration identity 구간은 diff에서 삭제·약화되지 않았다.
- **Documentation Map:** 기존 17개 목적지는 Quick Reference/maintainer primary entry 또는 3개 그룹의 table row로 전부 보존됐다. onboarding은 10-minute, daily docs는 operator, protocol/source Git/brief·retro는 maintainer에 배치돼 blocking 오분류가 없다. “최소 재포장 1차” 문구도 README와 Work Slice 경계에 남아 있다.
- **Quick Reference 정체성:** 사람용 1-2-3 뒤에 구분선과 “이하는 AI 세션 실행 규칙”을 두어 독자 역할을 분리했다. root entry/session-start adapter가 Quick Reference를 auto-load하지 않으므로 startup context 증가도 없다. AI가 필요 시 직접 읽어도 8줄의 bounded routing block이며 기존 규칙을 덮지 않는다.
- **adopter 경계:** Work Verification은 기존 adopter가 다음 upgrade에서만 수용한다고 명시해 현재 전 target 개선으로 과장하지 않는다.

#### Reviewer-Side Routing Simulation

**ⓐ source-new-adopter — README만 사용: PASS.** Start Here에서 “처음 적용” 행 → 바로 아래 `create-harness.sh <project-name> <target-dir>` → 생성 directory의 첫 `/session-start` → STATUS bootstrap pointer 시 onboarding guide 순서로 도달했다. source repo를 product workspace로 쓰지 말라는 경계도 같은 화면에 남아 있다.

**ⓑ target-returning-operator — Quick Reference만 사용: PASS.** §1 서두에서 첫 메시지 `/session-start` → Active Work/Next Actions 또는 `/work-select` → Product L1 Quick Mode vs ambiguous/harness L2+Work 경계까지 도달했다. source README나 source-only maintainer 문서를 요구하지 않는다.

**추가 재현:** `bash scripts/tests/run-harness-checks.sh --tier0` reviewer 독립 실행 전체 PASS. 남아 있는 `hp-probe`에서 modified Quick Reference block과 generated README의 Quick Reference pointer 2곳 공존도 read-only로 재확인했다.

#### Residual Risk

- simulation은 문서 routing 재현이지 실제 novice comprehension 증명이 아니다. 회고의 반복 혼란 revisit trigger는 계속 유효하다.
- source README glossary는 기존 target에 전달되지 않고, Quick Reference 변경도 다음 upgrade 전에는 기존 adopter에 도달하지 않는다.
- Quick Reference의 사람용 block은 auto-load되지 않지만 사람이 아닌 agent가 직접 읽을 때 context 몇 줄은 추가된다. 현재 크기와 역할 분리로는 허용 가능한 bounded cost다.

### R1 — Driver Response (Claude)

| Finding | Decision | 교정 |
| --- | --- | --- |
| R1-F1 | accept | frontmatter `scope`를 2-surface + 3그룹 + shipped Quick Reference cascade로 재작성, Top Summary를 "①②는 닫고 ③은 최소 재포장 1차까지만"으로 제한, Risk "source README 중심" → 2파일 표면으로 동기화 |
| R1-F2 | accept | Glossary 열 제목 "정확한 기준은 어디에" → **"더 볼 곳"**(intro 문구 동기화 — 비규범과 정합). row 1: target(적용 위치) vs product repo(소유) 구분 보존 + "보통 같은 물리 repo" 명시. row 2: manifest/`--check` = tracked baseline·drift 신호로 한정 + accepted-drift 판정·기록 절차는 AGENT-FIRST pointer(source-only 라벨) 추가. row 3: `#state-storage` 직접 anchor(존재 확인). row 4: Tier·runner=TAXONOMY / Layer=VERIFICATION-COMMANDS 분리 |

검증: `git diff --check` OK, tier0 PASS (교정 후 재실행).

### R1b — Reviewer Confirmation (Codex)

**Verdict: approve.** R1-F1·F2는 권고 취지대로 종결됐다. 추가 finding은 없다.

- **F1 종결:** frontmatter `scope`가 source README + shipped Quick Reference의 2-surface, Documentation Map 3그룹 재배치, scaffold cascade를 현재 truth로 반영한다. Top Summary는 ①·②만 이 slice에서 닫고 ③은 “최소 재포장 1차”로 제한했으며, Risk도 source README 단일 표면이 아닌 문서 2파일 표면으로 맞췄다.
- **F2 종결:** glossary는 열 제목과 서두를 “더 볼 곳”으로 낮춰 비규범 orientation 경계를 유지한다. target(적용 위치)과 product repo(소유)의 역할 차이, manifest/`--check`의 drift signal 한계와 accepted-drift 절차 owner, `#state-storage` 직접 anchor, Tier·runner와 Layer의 분리 pointer가 모두 실제 소유 문서와 정합하다. threshold나 판정 절차를 README에 재서술하지 않았다.

**Residual risk:** R1에서 기록한 novice comprehension 및 기존 adopter 전파 시점 위험은 그대로 남지만, 이번 bounded slice의 consensus를 막는 사유는 아니다. cross-agent consensus는 종결 가능하며 다음 gate는 arbiter/user의 최종 승인이다.
