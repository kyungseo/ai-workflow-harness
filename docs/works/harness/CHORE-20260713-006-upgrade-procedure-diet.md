---
id: CHORE-20260713-006
priority: P1
status: Done
risk: L2
scope: Upgrade 절차 diet — agent-first 경로를 정식 문서 표면으로 승격(체크리스트 정식 위치 결정·문서화), ADOPTER-UPGRADE-MIGRATION-PLAYBOOK의 procedural duplication 축소(제거/유지 목록 열거 후 실행), default 경로 전환 명문화, bounded heuristic DR 승격 여부 결정. contract·`--check`·blocker handling·evidence boundary는 유지·강화. DR-034 amend 실행, script 변경, adopter repo 변경은 비범위.
appetite: 1d
planned_start: 2026-07-13
planned_end: 2026-07-13
actual_end: 2026-07-13
related_dr: [DR-028, DR-034, DR-042]
related_work: [CHORE-20260713-001, CHORE-20260713-002, CHORE-20260713-003, CHORE-20260713-005]
---

# CHORE-20260713-006: Upgrade 절차 diet — agent-first 경로 정식화 + playbook 축소

## Top Summary

축② 해제(CHORE-20260713-002)와 toolstead fresh-session canary(PR #41 — `--check` 83/83/0, 질문 0회, rebaseline 해법 독립 재발명)로 **diet 착수 gate가 충족됐다** (R0-Codex-F1: R1-Codex-F6의 착수 gate와 최종 default 전환 gate를 구분 — canary는 agent-first 경로의 실행 가능성을 검증했으나 축소된 문서 IA·fallback discoverability는 검증하지 않았다. **default 전환·기존 절차 삭제의 최종 승인은 축소 후 two-route simulation + R1 result review에서 판정한다**). 이 Work는 그 착수 gate가 열어준 두 가지를 실행한다:

1. **agent-first 경로의 정식화** — 현재 agent-first 체크리스트는 archive된 Work 파일(CHORE-20260713-002 §Scope)·brief·STATUS에만 존재하고 `docs/maintainer/` 정식 표면에는 없다. 정식 위치를 결정하고 문서화한다.
2. **playbook 축소** — `docs/maintainer/ADOPTER-UPGRADE-MIGRATION-PLAYBOOK.md`(419줄, Phase 0~10)의 procedural duplication을 축소한다. R1-Codex-F6 경계 유지: 제거 후보 surface와 fallback을 먼저 열거하고, contract/`--check`는 유지·강화하며, procedural duplication만 축소한다.

추가 decision 항목: brief의 **bounded heuristic**("deterministic contract·verification이 있을 때 agent 위임을 기본 후보로") DR 승격 여부 — canary gate 충족으로 재평가 trigger 발동 상태.

## Scope

**포함:**

- agent-first 최소 체크리스트의 정식 위치 결정 + 문서화 (아래 Plan D1)
- playbook 제거/유지 대상 목록 열거 → 사용자·reviewer 확인 → 축소 실행
- default 경로 전환 명문화 (agent-first = default, 잔여 절차 = fallback/contract reference)
- bounded heuristic DR 승격 여부 결정 (승격 시 `/record-decision` 흐름, 별도 승인)
- 조건부 cascade 실행 scope (R0-Codex-F5): ① 후보 B 채택 시 `docs/maintainer/README.md` index 갱신(필수), ② playbook 역할이 fallback으로 바뀌므로 `VERIFICATION-COMMANDS.md` Layer T entry pointer·route wording 검토 + stale phrase grep, ③ backlog residual(upgrade helper 축ⓐ) trigger/설명 stale 여부 확인 — residual 변경은 별도 tracking proposal로 사용자 승인 후 실행

**비포함:**

- DR-034 amendment 실행 (별도 P3 backlog — 이 Work 결과가 입력)
- `scripts/create-harness.sh` / `--check` 코드 변경 (contract는 CHORE-20260713-003에서 정비 완료)
- adopter repo 변경 (fleet 4/4 완료 상태)
- scaffold 표면 변경 (playbook은 source-only maintainer 문서)

## Plan

Driver 제안 (R0 반영 개정 — 원안은 R0 packet·git history 참조):

- **D1. 체크리스트 정식 위치 = 후보 B (R0-Codex-F2 accept, 원안 A 철회):** `docs/maintainer/ADOPTER-UPGRADE-AGENT-FIRST.md`를 default entry/dispatcher로 신설 — 짧은 manifest-target checklist + fallback 진입 조건만 보유. 현 playbook은 manual/pre-manifest fallback으로 축소. 계약 상세는 중복 복사하지 않고 `--check`/Layer T/playbook authoritative section을 **pointer-only**로 연결 (pointer-only 경계는 R1에서 재검증). 원안 A 철회 사유: default agent가 짧은 checklist를 찾으려 fallback 절차까지 일괄 로딩하게 되어 conditional slice+pointer 원칙(BEHAVIOR-PRINCIPLES §2, docs-workflow slice rule)과 상충.
- **D2. route별 retain/remove matrix를 EXECUTE 전 Plan 산출물로 승격 (R0-Codex-F3 accept):** `procedural duplication`과 `safety gate/ownership decision/evidence contract`를 별도 열로 판정한다. **Phase 2 shadow baseline·Phase 5 temp rehearsal은 삭제 대상이 아닌 fallback safety surface** — 전자는 pre-manifest residual의 유일한 baseline acquisition 경로, 후자는 target write 전 result tree 검증 장치이므로 Layer T 명령 pointer + 조건부 prose로 압축만 한다. 유지 목록에 Target Probe/source-ref, Base Trust Audit, Ownership Classification, DR-043 값 보존 gate, Verification 해석, Real Apply/Closeout evidence 추가. 기존 유지 대상(Evidence Boundary, manifest contract·hash 세대 함정, Phase 7 Blocker Handling, Phase 8 Owner Sign-off, Minimal Report Template, Adopter-Specific Notes) 유효.
- **D3. bounded heuristic 범용 DR 승격 보류 (R0-Codex-F4 accept, 원안 승격 철회):** 두 evidence(ai-deck replay + toolstead canary)는 operator freshness는 다르나 모두 manifest 보유 harness upgrade domain에 한정 — 범용 policy evidence가 아니다. 범용 heuristic은 brief 가설로 유지하고, D3 산출물은 **"승격 보류 + 향후 DR-034 amendment 입력 문구"**로 닫는다: "manifest 보유 target에서 released source baseline, file-level preservation classification, fail-closed 독립 검증이 모두 가능할 때 agent-first selective upgrade를 default 실행 경로로 둔다" (pre-manifest, external manual, ownership 불명확, verification failure, security/unattended mechanism 명시 제외).

실행 순서:

1. Work 파일 + plan → **R0 Codex plan review** → driver response → consensus — (R0 완료, request-changes 반영)
2. route별 retain/remove matrix 산출 (Checkpoint 기록) → D1 후보 B 구조로 실행: AGENT-FIRST 신설 + playbook fallback 축소
3. D3 산출물 기록 (승격 보류 + DR-034 amendment 입력 문구 — DR 파일 생성 없음)
4. Verification (아래, two-route simulation 포함) → **R1 Codex result review** (default 전환 최종 승인 gate 포함) → 사용자 최종 승인
5. `/work-close` → commit → PR(`--base develop`) → merge

## Done Criteria

- [x] agent-first 체크리스트의 정식 위치 결정·문서화 (D1 — 후보 B: `ADOPTER-UPGRADE-AGENT-FIRST.md` 신설, CP3)
- [x] route별 retain/remove matrix + playbook fallback 축소 실행 (D2 — CP1 matrix + CP3)
- [x] bounded heuristic DR 승격 여부 결정 기록 (D3 — 승격 보류 + DR-034 amendment 입력 문구, CP2)
- [x] default 경로 전환 명문화 (agent-first default + fallback 경계 — two-route simulation 2건 PASS + R1c 가 판정으로 gate 통과)
- [x] cross-agent consensus: R0(plan) + R1(result, R1b/R1c 포함) 종결 — R1c approve
- [x] 사용자 최종 리뷰 후 Done (2026-07-13 arbiter 최종 승인 — work-close·commit·PR·merge 지시)

## Verification

- playbook diff review (제거 항목이 retain/remove matrix와 1:1 대응하는지; **성공 기준은 line count가 아니라 default entry 필수 context + fallback으로 이동한 safety semantics 전후 비교** — R0 nice-to-have)
- `git diff --check`
- shipped DR closure check: 신규 DR 생성 시 `bash scripts/tests/check-shipped-dr-closure.sh` (D3 보류 시 N/A)
- `bash scripts/tests/run-harness-checks.sh --tier0` (문서 변경 회귀)
- **two-route simulation (R0-Codex-F1/F5):** (a) manifest-target default route — AGENT-FIRST entry + contract만으로 upgrade 경로 유도 확인, (b) pre-manifest/manual fallback route — fallback 진입 조건에서 playbook 발견 가능성 확인
- maintainer `README.md` index 갱신 (후보 B 신규 파일 — 필수), Layer T entry pointer·stale phrase grep (`rg "playbook" docs/maintainer/VERIFICATION-COMMANDS.md` 등)
- Surface: canonical(maintainer docs) · adopter cascade(없음 — source-only 문서이므로 N/A 확인만)

## Risk / Reversal Cost

- **과축소 리스크:** canary는 1건 — 절차 중복만 축소하고 계약·검증·blocker handling은 유지·강화하는 경계로 완화. fallback 상실 시 pre-manifest·external manual adopter 경로(unobserved residual)가 무방비가 됨 → Evidence Boundary에 residual 명시 유지.
- **Reversal Cost: Low~Medium.** 문서 revert는 용이하나, 그 사이 신규 upgrade 세션이 축소된 경로를 소비하면 혼선 가능. DR 승격은 amend/supersede로 되돌림 가능.

## Discovery

- 착수: 2026-07-13, backlog W6 "Upgrade 절차 diet — agent-first 경로 정식화 + playbook 축소" candidate 착수. branch `feature/upgrade-procedure-diet`.
- 실측: `agent-first` 문자열이 `docs/maintainer/`·`docs/decisions/`·`skills/`·`scripts/`·`prompts/`에 부재 — 정식 표면 승격이 이 Work의 실체임을 확인.
- Done: 2026-07-13, cross-review R0/R1/R1b(request-changes)→R1c(approve, default 전환 가) + two-route fresh-session simulation 2건 PASS + arbiter 최종 승인.
- Needs-Triage: root README upgrade default-entry pointer — R1 nice-to-have defer(승인 scope 밖). source front door에서 AGENT-FIRST 발견 가능성 보강 여부를 별도 판단할 가치.

## Checkpoints

### CP1 — Route별 retain/remove matrix (2026-07-13, EXECUTE 산출물)

판정 열 분리(R0-Codex-F3): `procedural duplication` vs `safety gate / ownership decision / evidence contract`.

| Playbook section | 판정 | 처리 |
| --- | --- | --- |
| Intro("운동 기록지" positioning) | positioning stale | **재작성** — fallback 역할 명시 + AGENT-FIRST default entry pointer |
| Evidence Boundary | evidence contract | 유지 + evidence 현행화(ai-deck replay·toolstead canary 반영) |
| Standard Flow | fallback 판단 순서 | 유지 (fallback route 한정 라벨) |
| Phase 0 Work 준비 | safety gate (cross-repo write gate) | 유지 |
| Phase 1 probe 명령 블록 | **부분 중복** (R1-Codex-F2 정정: target status·log·branch policy 확인은 T0에 없었음) | **명령 SSoT를 Layer T T0로 이동** — T0에 누락 명령 3종 추가 후 playbook은 pointer 압축 유지 |
| Phase 2 Baseline 선택 | safety surface — pre-manifest 유일 baseline acquisition 경로 (F3) | 유지, manifest-target 행에 AGENT-FIRST pointer 추가 |
| Phase 3 Base Trust Audit | ownership decision | 유지 |
| Phase 4 Classification + adapt-render trap + DR-043 gate | evidence contract + safety gate | 유지 — 양 route가 pointer로 소비하는 authoritative section |
| Phase 5 Temp Rehearsal | safety surface — target write 전 result tree 검증 (F3) | 유지 (삭제 아님) |
| Phase 6 Verification 해석·manifest field 계약 | evidence contract (authoritative) | 유지 |
| Phase 7 Blocker Handling | safety gate | 유지 |
| Phase 8 Owner Sign-off | safety gate | 유지 |
| Phase 9 Real Apply | safety gate + evidence 목록 | 유지 |
| Phase 10 Source Closeout | evidence contract | 유지 |
| Adopter-Specific Notes | 기록 — 일부 stale ("예상 패턴"이 실측 완료됨) | 유지 + fleet 4/4 현행화 최소 라벨 |
| Minimal Report Template | evidence contract | 유지 |

**정직한 관측:** F3 재분류 후 실제 remove 대상은 원안 추정보다 작다 — playbook의 대부분이 safety/evidence surface로 판정됐고, 순수 procedural duplication은 Phase 1 명령 블록(Layer T T0 중복)과 intro positioning 정도다. diet의 실질은 "삭제"가 아니라 **① default entry 신설(AGENT-FIRST), ② playbook의 fallback 재배치, ③ Layer T 중복 압축**이다. line count 목표는 성공 기준이 아니다(R0 nice-to-have).

**default 전환 문구 상태:** AGENT-FIRST를 default entry로 기술하되, 최종 default 전환·잔여 절차 추가 삭제는 two-route fresh-session simulation + R1 통과 후 별도 승인 (arbiter 지시 2026-07-13).

### CP2 — D3 결정 기록: bounded heuristic 범용 DR 승격 **보류** (2026-07-13)

- **결정:** 범용 bounded heuristic("deterministic contract·verification이 있을 때 agent 위임을 기본 후보로")은 **brief 가설로 유지**한다. 신규 DR 생성 없음 (arbiter 승인 범위에서도 제외됨).
- **근거 (R0-Codex-F4 consensus):** evidence 2건(ai-deck replay·toolstead canary)은 operator freshness는 다르나 모두 manifest 보유 harness upgrade domain·release-tag baseline·`--check`에 의존 — 재평가 trigger는 충족했으나 security·unattended/fleet·다른 판단 절차를 포괄하는 범용 policy evidence가 아니다.
- **향후 DR-034 amendment 입력 문구 (별도 P3 Work에서 소비):** "manifest 보유 target에서 released source baseline, file-level preservation classification, fail-closed 독립 검증이 모두 가능할 때 agent-first selective upgrade를 default 실행 경로로 둔다. pre-manifest, external manual, ownership 불명확, verification failure, security/unattended mechanism은 명시적으로 제외한다."

### CP3 — D1/D2 실행 완료 (2026-07-13)

변경 파일 5개 (모두 source-only maintainer 표면 + 이 Work 파일):

| 파일 | 변경 |
| --- | --- |
| `docs/maintainer/ADOPTER-UPGRADE-AGENT-FIRST.md` | **신설** — default entry: 진입 조건, fallback 조건, non-negotiable gate 4(한 화면), 최소 체크리스트 8단계, Evidence Boundary. 계약 상세는 playbook Phase 4·6/Layer T pointer-only (복제 없음) |
| `docs/maintainer/ADOPTER-UPGRADE-MIGRATION-PLAYBOOK.md` | fallback 재배치: intro 재작성(운동 기록지 → fallback 역할 + AGENT-FIRST pointer), Evidence Boundary 현행화, Phase 1 probe 명령 블록 → Layer T(T0) pointer 압축, Phase 2 manifest-target 행에 default pointer, Adopter-Specific Notes 현행화 라벨. **Phase 2/5 포함 전 Phase 유지** (CP1 matrix 대로) |
| `docs/maintainer/README.md` | 자산 표에 AGENT-FIRST 행 추가 + playbook 역할 갱신, 문서 표면 분류 표에 AGENT-FIRST 추가 |
| `docs/maintainer/VERIFICATION-COMMANDS.md` | Layer T 서두 route wording 갱신 (default=AGENT-FIRST / fallback=playbook / Layer T=공용 카탈로그) |
| `docs/maintainer/SOURCE-REPO-OPERATIONS.md` | §G entry에 default/fallback 분기 반영 (flow diagram 포함) |

- backlog residual(upgrade helper 축ⓐ) 참조는 `docs/backlog/HARNESS.md:120` 1곳 — 변경은 별도 tracking proposal로 보류 (arbiter 지시).
- archive/brief의 playbook 참조는 역사 기록이므로 불변.

## Cross-Agent Review And Discussion

Model: manual relay (`/cross-review`). Driver = Claude, Reviewer = Codex (red-team), Arbiter = User.
Max Rounds: plan 1 + result 1 기본, 필요 시 반복.

### R0 — Plan Review (Cross-Agent Relay Packet)

**Role:** Driver = Claude / Reviewer = Codex / Arbiter = User

**Target:**
1. 이 Work 파일 전체 (특히 §Plan D1~D3, §Scope 경계)
2. `docs/maintainer/ADOPTER-UPGRADE-MIGRATION-PLAYBOOK.md` (축소 대상 문서, 현행 419줄)
3. 배경: brief `harness-longterm-durability-review-20260713.md` 축② amendment, CHORE-20260713-002 R1-Codex-F6, CHORE-20260713-005·toolstead canary 측정(STATUS Recent Decisions 2026-07-13 첫 행)

**Current State:**
- branch: `feature/upgrade-procedure-diet` (source repo), Work 파일만 생성된 PLAN 단계
- canary gate 충족 확인됨 (R1-Codex-F6 조건 — fresh-session canary 1건)
- validation: 아직 없음 (plan review 단계)

**Delta Since Last Round:** 신규 Work — 직전 관련 라운드는 CHORE-20260713-002 R1(축② 해제 consensus)과 CHORE-20260713-005 canary 기록.

**Review Objective (red-team):**
1. **방향 자체:** canary 1건 + informed replay 1건으로 playbook 축소 default 전환을 지금 실행하는 것이 과속인가. gate 조건(R1-Codex-F6)을 네가 설계했다 — 충족 해석이 타당한가.
2. **D1 위치 결정:** 후보 A(playbook 내 재구성) vs B(별도 문서). A의 숨은 비용(문서 정체성 혼합 — default 경로와 fallback 절차가 한 파일에 공존할 때의 로딩 비용)을 포함해 판단해줘.
3. **D2 축소/유지 경계:** 열거된 제거 후보가 R1-Codex-F6의 "procedural duplication만"을 넘는가. 유지 목록에 누락이 있는가 (특히 pre-manifest·external manual adopter residual의 fallback 표면).
4. **D3 heuristic DR 승격:** evidence 2건(ai-deck replay + toolstead canary)으로 bounded heuristic을 DR로 승격하는 것이 적정한가, 아니면 brief 가설 유지가 맞는가. 승격 시 wording 경계 제안.
5. scope 누락·hidden cost·cascade (VERIFICATION-COMMANDS grep 기대 문자열, backlog residual downscope 등).

**Do Not Re-litigate:** 축② 해제 자체(-002 R1 consensus), canary 수행·측정 자체(-005 종결), cross-agent 역할 배분, W6 우선순위.

**Reviewer Posture:** Red-team the direction, not only the prose. Question assumptions, priority, hidden cost, cascade, and rollback. Mark speculation as speculation.

**Output Contract:** Verdict(approve / conditional / request-changes / reject) + must-fix / nice-to-have findings + residual risk. 이 파일 `### R0 — Reviewer Findings (Codex)` 섹션에 기록하고 Round Log를 갱신해줘. D1·D3에 대한 명시적 의견 포함.

### R0 — Reviewer Findings (Codex)

**Verdict: request-changes**

Work 방향과 축소 착수 자체는 타당하다. 다만 현 Plan은 canary가 닫은 gate 범위를 넓게 해석하고, D2에서 fallback safety surface를 procedural duplication과 함께 제거할 여지가 있으며, D3는 동일 upgrade domain의 evidence를 범용 workflow policy로 일반화한다. 아래 must-fix를 Plan에 반영하기 전에는 축소 실행안을 승인하기 어렵다.

#### Must-Fix Findings

| ID | Finding | Evidence | Recommendation |
| --- | --- | --- | --- |
| R0-Codex-F1 | **R1-Codex-F6는 diet Work의 착수 gate와 최종 default 전환 gate를 구분해 해석해야 한다.** toolstead canary는 playbook 없이 contract+tool만으로 artifact·보존 분류를 재검증했으므로 agent-first 경로의 실행 가능성과 diet 착수에는 충분하다. 그러나 F6 원문은 제거 후보·fallback 열거와 procedural duplication 축소 **후** canary 재검증을 default 전환·기존 playbook 삭제의 조건으로 뒀다. 현재 canary는 축소된 문서 IA와 fallback discoverability를 검증하지 않았다. | CHORE-20260713-002 R1-Codex-F6, 이 Work §Verification의 "축소 후 신규 세션 시뮬레이션 1회" | Top Summary와 Plan에서 `canary gate 충족`을 **diet 착수 가능**으로 한정한다. default 전환·기존 절차 삭제는 축소 후 simulation에서 manifest-target default route와 fallback route 발견 가능성을 재검증한 뒤 R1에서 승인한다. |
| R0-Codex-F2 | **D1은 후보 B를 권고한다.** 후보 A는 파일 수는 줄이지만, default agent가 짧은 checklist를 찾기 위해 pre-manifest·external manual·blocker 절차까지 한 번에 loading하게 한다. 이는 조건부 상세 runbook을 별도 slice+pointer로 분리한다는 repo 원칙과 반대이고, 한 파일 SSoT가 곧 낮은 cognitive load라는 전제도 성립하지 않는다. | `docs/BEHAVIOR-PRINCIPLES.md` §2, `.claude/rules/docs-workflow.md`의 conditional slice rule, 현 playbook 419줄 | `ADOPTER-UPGRADE-AGENT-FIRST.md`를 default entry/dispatcher로 신설하고, 짧은 manifest-target checklist와 fallback 진입 조건만 둔다. 현 playbook은 manual/pre-manifest fallback으로 축소한다. 계약 상세는 중복 복사하지 말고 `--check`/Layer T/playbook의 authoritative section을 pointer로 연결한다. |
| R0-Codex-F3 | **D2 제거 초안은 procedural duplication 경계를 넘는다.** Phase 2 shadow baseline은 pre-manifest residual의 유일한 baseline acquisition 경로이고, Phase 5 temp rehearsal은 tag-pinned source worktree와 다른 안전 장치다. 전자는 source provenance를 고정하고 후자는 target write 전 result tree와 classification mapping을 검증한다. 둘을 대체 관계로 보면 external manual adopter·pre-manifest·ownership 불확실 target의 fallback이 사라진다. 유지 목록에도 Target Probe/source-ref, Base Trust Audit, Ownership Classification, DR-043 값 보존 gate, Verification 해석, Actual Apply/Closeout evidence가 빠져 있다. | 현 playbook Phase 1~6·9~10, DR-034 Draft의 pre-manifest shadow baseline, CHORE-20260713-002 R1-Codex-F1/F5 residual | route별 retain/remove matrix를 EXECUTE 전 Plan 산출물로 승격한다. manifest-target default에서는 중복 step-by-step을 제거하되, fallback에는 위 safety semantics를 유지한다. Phase 2/5는 삭제가 아니라 Layer T 명령 pointer와 조건부 prose로 압축한다. `procedural duplication`과 `safety gate/ownership decision/evidence contract`를 별도 열로 판정한다. |
| R0-Codex-F4 | **D3의 범용 bounded heuristic DR 승격은 보류해야 한다.** ai-deck replay와 toolstead canary는 operator freshness는 다르지만 모두 같은 harness upgrade domain, manifest contract, release-tag baseline, `--check`에 의존한다. 이는 heuristic의 재평가 trigger는 충족하지만 security, unattended/fleet, 다른 판단 절차까지 포괄하는 policy evidence는 아니다. | brief는 heuristic을 가설로 분류하고 mechanism 예외를 둔다. 두 신규 evidence가 직접 검증한 범위는 manifest 보유 harness upgrade다. | 범용 heuristic은 brief 가설로 유지한다. durable decision이 필요하면 별도 범용 DR 대신 향후 DR-034 amendment에 좁은 문구로 기록한다: `manifest 보유 target에서 released source baseline, file-level preservation classification, fail-closed 독립 검증이 모두 가능할 때 agent-first selective upgrade를 default 실행 경로로 둔다.` pre-manifest, external manual, ownership 불명확, verification failure, security/unattended mechanism은 명시적으로 제외한다. 이번 Work는 DR-034 amendment 실행이 비범위이므로 D3 결과는 `승격 보류 + 후속 입력`으로 닫는다. |
| R0-Codex-F5 | **cascade를 확인 항목이 아니라 변경 조건별 실행 scope로 명시해야 한다.** 후보 B면 maintainer index 추가가 필수이고, playbook의 책임이 fallback으로 바뀌면 Layer T의 "전체 판단 순서와 real apply gate는 playbook" 문구도 다시 판정해야 한다. backlog residual은 playbook/Layer T가 절차를 닫는다는 전제를 사용하므로 default 경로 전환 뒤 trigger/설명이 stale할 수 있다. | `docs/maintainer/VERIFICATION-COMMANDS.md` Layer T 서두·T7, `docs/backlog/HARNESS.md` upgrade helper residual, `docs/maintainer/README.md` index 규칙 | Plan Files/Verification에 조건부 cascade를 구체화한다: 후보 B 채택 시 maintainer README index 갱신, playbook 역할 변경 시 Layer T entry pointer·route wording 검토 및 stale phrase grep, backlog residual 변경은 별도 STATUS/tracking proposal로 사용자 승인 후 실행. 신규 simulation은 (a) manifest-target default route, (b) pre-manifest/manual fallback route 두 진입점을 검사한다. |

#### Nice-To-Have Findings

- line count를 성공 기준으로 삼지 말고, default entry의 필수 context와 fallback으로 이동한 safety semantics 목록을 전후 비교하면 과축소를 더 잘 탐지할 수 있다.
- `agent-first`라는 이름만으로 tool autonomy를 암시하지 않도록 checklist에 source ref 고정, ownership/preservation 분류, post-hoc `--check`, owner sign-off의 네 non-negotiable gate를 한 화면에 둔다.

#### Residual Risk

- 현재 fleet 4/4는 모두 manifest target이므로 pre-manifest·external manual fallback은 여전히 unobserved다. 이번 Work는 그 경로를 최적화하거나 폐기할 evidence가 없다.
- toolstead canary는 default agent route의 가능성을 강하게 지지하지만, 축소된 문서의 routing 품질이나 다른 agent/tool의 동일 행동까지 증명하지는 않는다.
- 후보 B는 파일 1개와 index pointer를 늘리지만, default/fallback의 conditional loading 경계를 명확히 해 reversal cost와 context cost를 낮춘다. 계약 문구를 양쪽에 복제하면 이 장점이 사라지므로 pointer-only 경계를 R1에서 재검증해야 한다.

### R0 — Driver Response (Claude)

| Finding | Decision | Response | Follow-up |
| --- | --- | --- | --- |
| R0-Codex-F1 | accept | 착수 gate와 default 전환 gate 구분 수용. Top Summary 한정 문구로 교정, default 전환 최종 승인을 two-route simulation + R1 gate로 이동 | Verification에 two-route simulation 반영 완료 |
| R0-Codex-F2 | accept | 원안 A 철회, 후보 B 채택. A의 "한 파일 SSoT = 낮은 cognitive load" 전제가 conditional slice+pointer 원칙과 상충함을 인정 | Plan D1 개정 완료. pointer-only 경계는 R1 재검증 항목 |
| R0-Codex-F3 | accept | Phase 2/5를 procedural duplication이 아닌 fallback safety surface로 재분류. retain/remove matrix를 EXECUTE 전 Plan 산출물로 승격, 유지 목록 6개 항목 추가 | matrix는 Checkpoint로 기록 후 축소 실행 |
| R0-Codex-F4 | accept | 원안 승격 철회. evidence 2건은 domain-limited(manifest 보유 harness upgrade) — 범용 policy evidence 아님. D3 = 승격 보류 + DR-034 amendment 입력 문구로 종결 | 신규 DR 파일 생성 없음. amendment 문구는 Checkpoint에 기록 |
| R0-Codex-F5 | accept | cascade를 확인 항목에서 조건별 실행 scope로 승격 (Scope 개정). backlog residual 변경은 별도 tracking proposal gate 유지 | Layer T pointer 검토 + stale grep을 Verification에 반영 완료 |
| nice-to-have ×2 | accept | line count 성공 기준 배제 + AGENT-FIRST entry에 4 non-negotiable gate(source ref 고정, ownership/preservation 분류, post-hoc `--check`, owner sign-off) 한 화면 배치 | D1 실행 시 반영 |

### R1 — Result Review (Cross-Agent Relay Packet)

**Role:** Driver = Claude / Reviewer = Codex / Arbiter = User

**Target:**
1. working tree diff (미commit — 리뷰 후 commit): `docs/maintainer/ADOPTER-UPGRADE-AGENT-FIRST.md`(신설), `ADOPTER-UPGRADE-MIGRATION-PLAYBOOK.md`, `README.md`, `VERIFICATION-COMMANDS.md`(Layer T 서두), `SOURCE-REPO-OPERATIONS.md`(§G)
2. 이 Work 파일 CP1(matrix)·CP2(D3 기록)·CP3(실행 기록)

**Current State:** branch `feature/upgrade-procedure-diet`, EXECUTE 완료. 검증: `git diff --check` OK, `run-harness-checks.sh --tier0` PASS, stale phrase("운동 기록지") 제거 확인.

**Delta Since Last Round:** R0 consensus(D1=후보 B, D2=matrix 선행+Phase 2/5 유지, D3=보류) 실행 결과.

**Review Objective (red-team):**
1. **R0 must-fix 반영 충실도:** F2 pointer-only 경계 — AGENT-FIRST에 계약 문구가 복제되지 않았는가 (특히 gate ②③ 요약이 playbook Phase 4·6과 중복 서술인지 pointer인지). F3 — playbook에서 safety semantics가 실제로 전부 보존됐는가.
2. **routing 정합:** 진입점 3곳(maintainer README·SOURCE-REPO-OPERATIONS §G·Layer T 서두)의 default/fallback 분기 서술이 상호 모순 없는가. AGENT-FIRST 진입 조건과 playbook fallback 조건 사이에 빈틈(어느 쪽도 담당하지 않는 case)이 있는가.
3. **AGENT-FIRST 체크리스트 자체:** canary·replay가 실제 수행한 것과 체크리스트 8단계가 어긋나는 부분이 있는가 (특히 6단계 shadow scaffold rebaseline vs canary의 tag-pinned worktree 재생성 — 동일 해법인지).
4. **과축소 여부:** CP1 matrix "유지" 판정 항목 중 diff에서 실제로 약화된 것이 있는가.
5. default 전환 최종 승인 가부 의견 (two-route fresh-session simulation 결과와 함께 arbiter가 확정).

**Do Not Re-litigate:** R0 consensus 항목(D1=B, D2 경계, D3 보류), 축② 해제·canary 측정 자체.

**Output Contract:** Verdict + must-fix/nice-to-have findings + residual risk를 이 파일 `### R1 — Reviewer Findings (Codex)` 섹션에 기록, Round Log 갱신. **default 전환 가/부 의견 명시** (최종 확정은 arbiter).

### CP4 — Two-route fresh-session simulation 결과 + R1 교정 (2026-07-13)

**Simulation (비오염 새 세션, "STATUS/Work 파일 확인 없이 upgrade 절차 문서만 기준" 조건):**

- **(a) manifest-target route: PASS** — AGENT-FIRST를 default entry로 판정, Entry Conditions 4개 전건 열거·확인, gate ①~④와 체크리스트 8단계를 정확히 재구성, 중도 fallback trigger(blocker→Phase 7, 고위험→playbook 전체 흐름)까지 자가 서술.
- **(b) pre-manifest fallback route: PASS** — manifest 부재로 Entry Conditions 미충족 판정 → playbook Phase 0~10 전체 흐름 정확 서술 (3-way vs shadow scaffold 분기, adapt-render trap, DR-043 gate, temp rehearsal 필수, blocker handling 포함).
- **경계 명시:** 프롬프트가 두 문서를 직접 지정했으므로 이 simulation이 검증한 것은 **두 문서의 route 판정·절차 유도 품질**이다. 상위 진입점(README·§G·Layer T)에서의 discoverability는 프롬프트 조건상 미검증 — 단 그 표면은 R1-Codex-F1 교정으로 predicate 재열거가 제거되어 drift 여지가 줄었다.

**R1 F1~F3 교정 실행:**

| Finding | 교정 |
| --- | --- |
| F1 | 상위 진입점 3곳(maintainer README·SOURCE-REPO-OPERATIONS §G flow·Layer T 서두) + playbook intro를 "AGENT-FIRST **Entry Conditions**(SSoT) 전부 충족 → default / 하나라도 실패 또는 fallback override → playbook"으로 통일. AGENT-FIRST Entry Conditions 섹션에 SSoT 선언 1줄 추가 (조건 재열거 금지 명시) |
| F2 | Layer T T0에 `git -C target status --short --branch`·최근 log·`docs/GIT-WORKFLOW.md` 조건부 확인 추가 + executable surface 설명 1줄. playbook pointer 압축은 유지. CP1 matrix 판정 정정 |
| F3 | AGENT-FIRST heading 교정: `## Entry Conditions`, `## Minimum Checklist (manifest-target upgrade)` |
| nice #2 | Evidence Boundary에 evidence 축 분리 반영 (fallback 경로 = informed-driver walkthrough evidence만) |
| nice #1 | **defer** — root `README.md` AGENT-FIRST pointer는 승인 scope(maintainer 5개 문서) 밖. 필요 시 후속 판단 |

### R1 — Reviewer Findings (Codex)

**Verdict: request-changes**

R0의 핵심 방향은 충실히 반영됐다. 후보 B 분리, pointer-only 구조, Phase 2/5와 ownership·verification safety semantics의 보존, D3 승격 보류 모두 확인했다. 다만 default 전환 전에 routing predicate와 executable probe를 정합화하고 신규 문서의 DR-007 위반을 고쳐야 한다.

#### Must-Fix Findings

| ID | Finding | Evidence | Recommendation |
| --- | --- | --- | --- |
| R1-Codex-F1 | **세 진입점이 AGENT-FIRST의 진입 조건을 부분적으로 복제해 routing predicate가 갈린다.** AGENT-FIRST는 manifest·released tag·실행 가능한 `--check`·clean target을 모두 요구하고, ownership 불명확·blocker·고위험이면 fallback으로 보낸다. 반면 `SOURCE-REPO-OPERATIONS.md` §G flow는 `manifest + released tag`만으로 default route에 보내고, Layer T 서두와 maintainer README는 manifest target 전체를 default로 표현한다. `--check` 불가나 dirty target처럼 manifest+tag이지만 추가 조건을 실패한 case에서 상위 진입점과 authoritative entry의 판정이 달라진다. | `ADOPTER-UPGRADE-AGENT-FIRST.md` §진입 조건·Fallback, `SOURCE-REPO-OPERATIONS.md` §G, `VERIFICATION-COMMANDS.md` Layer T 서두, maintainer README 자산 표 | 상위 세 진입점은 조건을 재열거하지 말고 **`AGENT-FIRST의 Entry Conditions를 모두 충족하면 default, 하나라도 실패하거나 fallback override에 해당하면 playbook`**으로 통일한다. §G flow도 `entry conditions all pass? → yes: AGENT-FIRST / no: playbook`으로 바꿔 predicate SSoT를 AGENT-FIRST 한 곳에 둔다. |
| R1-Codex-F2 | **Phase 1 probe 명령 블록은 Layer T T0와 완전 중복이 아니어서, 현재 압축은 clean-target safety gate의 executable surface를 약화한다.** 제거된 블록에는 target `status`, 최근 log, target `GIT-WORKFLOW.md` 확인이 있었지만 T0에는 source 상태·manifest 유무·`--check`만 있다. AGENT-FIRST Step 1과 fallback playbook이 모두 T0를 명령 카탈로그로 가리키므로, 진입 조건인 target clean/branch policy를 실제로 확인하는 명령이 authoritative catalog에서 빠졌다. | playbook Phase 1 diff, `VERIFICATION-COMMANDS.md` T0, AGENT-FIRST Entry Conditions·Step 1 | playbook에 중복 블록을 되돌리기보다 Layer T T0에 `git -C "${TARGET}" status --short --branch`, 최근 log, target `docs/GIT-WORKFLOW.md` 조건부 확인을 추가한다. 이후 playbook pointer 압축은 유지한다. CP1의 판정도 `부분 중복 → T0로 명령 SSoT 이동`으로 정정한다. |
| R1-Codex-F3 | **신규 AGENT-FIRST 문서의 section heading 두 개가 DR-007을 위반한다.** 신규 문서는 현 정책을 따라야 하며, 기존 문서의 historical inconsistency는 이번 finding 범위가 아니다. | `## 진입 조건 (이 경로를 쓸 수 있는가)`, `## 최소 체크리스트 (manifest-target upgrade)`; DR-007 Bilingual Rules의 Section & Title 규칙 | 각각 `## Entry Conditions`, `## Minimum Checklist` 같은 English Title Case로 교정한다. 본문 한국어 주 언어는 유지한다. |

#### Nice-To-Have Findings

- root `README.md`의 Scaffold Product Repo 안내는 selective migration 자체와 충돌하지는 않지만 manifest-target default entry를 직접 가리키지 않는다. source repo front door에서 새 경로의 발견 가능성을 높이려면 AGENT-FIRST pointer를 추가할 수 있다. 이는 현재 5개 maintainer 문서 scope 밖이므로 별도 scope 판단 대상으로 둔다.
- Evidence Boundary의 `pre-manifest ... 검증되지 않은 범위/unobserved residual`은 이번 agent-first replay/canary evidence에 한정하면 맞지만, playbook이 과거 ai-deck walkthrough evidence에서 일반화됐다는 서술과 함께 읽으면 전역 미관측처럼 보인다. `fresh-session agent-first evidence는 없음; informed-driver fallback evidence만 있음`처럼 evidence 축을 분리하면 더 정확하다.

#### Default Transition Opinion

**현재는 부.** F1~F3가 남아 있고 two-route fresh-session simulation 결과도 아직 없으므로 최종 default 전환을 승인하지 않는다. 다만 구조와 safety semantics는 대체로 적합하므로, F1~F3 교정 후 두 simulation이 각각 AGENT-FIRST와 shadow-baseline fallback을 정확히 선택하면 **가**로 전환할 수 있다. 추가 설계 round는 필요하지 않고 좁은 수정 확인으로 충분하다.

#### Residual Risk

- pointer-only 구조 자체는 지켜졌지만, pointer 상위 문서가 조건을 부분 복제하면 이후 진입 조건 변경 때 다시 drift할 수 있다. F1은 이번 문구 정합뿐 아니라 predicate ownership을 한 곳으로 고정하는 문제다.
- pre-manifest/manual route의 safety prose는 보존됐으나 실제 fresh-session discoverability는 이 review가 아니라 별도 simulation이 확인해야 한다.
- Tier 0와 `git diff --check`는 통과했지만 DR-007 heading과 route predicate 의미 차이는 현재 자동 검증이 잡지 못한다.

### R1b — Reviewer Confirmation (Codex)

**Verdict: request-changes**

R1-Codex-F2와 F3는 권고 취지대로 닫혔다. Layer T T0가 target status·최근 log·target branch policy 확인의 명령 SSoT를 보유하고, playbook은 pointer 압축을 유지한다. AGENT-FIRST의 신규 heading도 DR-007에 맞게 교정됐다. CP4의 simulation (a)/(b)는 명시된 evidence boundary 안에서 각각 AGENT-FIRST default route와 pre-manifest shadow-baseline fallback route를 정확히 유도했으므로 PASS로 인정한다.

다만 R1-Codex-F1은 한 가지 predicate drift가 남아 완전히 닫히지 않았다.

| ID | Finding | Evidence | Recommendation |
| --- | --- | --- | --- |
| R1b-Codex-F1 | **`4개 Entry Conditions 전부 충족`과 `fallback override 없음`이 함께 default 조건이어야 하는데, maintainer README와 Layer T는 전자만 표현한다.** ownership 불명확·고위험·진행 중 blocker는 manifest/released tag/실행 가능한 `--check`/clean target 네 조건을 모두 만족할 수 있지만 AGENT-FIRST 본문에서는 playbook override 대상이다. `SOURCE-REPO-OPERATIONS.md`와 playbook intro는 override를 포함했지만 README의 `Entry Conditions 미충족 시`, Layer T의 `전부 충족 시 default, 아니면 fallback`은 이를 누락한다. 따라서 CP4의 “상위 진입점 3곳 predicate 통일” 기록은 실제 diff보다 넓다. | AGENT-FIRST Entry Conditions의 Fallback 문단, maintainer README 자산 표, Layer T 서두, SOURCE-REPO-OPERATIONS §G | AGENT-FIRST에서 canonical route predicate를 `4개 조건 전부 충족 AND fallback override 없음 → default`로 한 줄 명시한다. 상위 진입점은 결과 논리를 다시 축약하지 말고 `AGENT-FIRST Entry Conditions의 route 판정을 따른다`고만 쓴다. README/playbook 역할 설명이 필요하면 `canonical route 판정에서 fallback인 경우`로 표현한다. CP4 F1 기록도 이 최종 wording에 맞춘다. |

**Default 전환 의견: 현재는 부.** 두 simulation은 재실행할 필요가 없고 추가 설계 round도 필요하지 않다. 위 canonical predicate와 두 상위 pointer를 좁게 교정한 뒤 static diff로 일치가 확인되면 default 전환은 **가**로 판정할 수 있다. CP4가 명시했듯 simulation은 직접 지정된 upgrade 문서의 route 유도 품질을 검증했으며, 상위 진입점 discoverability를 별도로 증명한 것은 아니라는 residual은 유지한다.

### R1c — Reviewer Confirmation (Codex)

**Verdict: approve**

R1b 잔여 1건은 권고 취지대로 종결됐다.

- canonical predicate는 `ADOPTER-UPGRADE-AGENT-FIRST.md`의 Entry Conditions 한 곳에 `4개 조건 전부 충족 AND Fallback override 해당 없음 → default, 그 외 전부 fallback`으로 명문화됐다.
- maintainer README, `SOURCE-REPO-OPERATIONS.md` §G prose/flow, Layer T 서두, playbook intro는 조건을 재열거하거나 축약하지 않고 canonical 판정식과 그 결과만 가리킨다.
- R1에서 확인한 T0 executable probe와 DR-007 heading 교정도 유지된다.
- CP4의 two-route fresh-session simulation (a)/(b)는 명시된 evidence boundary 안에서 PASS이며 재실행이 필요 없다.

**Default 전환 판정: 가.** R0/R1 must-fix가 모두 닫혔고, manifest-target default와 pre-manifest fallback의 route 유도도 확인됐다. 최종 전환은 arbiter/user 승인 대상이며, 이 approval은 Work Done·commit·PR·merge 승인을 대신하지 않는다.

**Residual Risk:** simulation은 직접 지정된 upgrade 문서의 route 유도 품질을 검증했으며 상위 진입점 discoverability 자체는 static pointer 정합으로만 확인됐다. root README pointer는 승인 scope 밖에서 defer됐지만 현 selective-migration 안내와 충돌하지 않으므로 이번 default 전환의 blocker는 아니다. pre-manifest/manual fallback의 fresh-session operational evidence가 제한적이라는 Evidence Boundary도 유지한다.

### Round Log / Consensus Log

| Round | Date | Driver | Reviewer | Verdict | 기록 |
| --- | --- | --- | --- | --- | --- |
| R0 | 2026-07-13 | Claude (Work+plan 작성, packet 발행) | Codex (plan review) | request-changes | F1~F5 must-fix 기록; D1=B 권고, D3=범용 DR 승격 보류; driver response 대기 |
| R0-resp | 2026-07-13 | Claude (F1~F5 + nice-to-have 전부 accept, Plan 개정) | — | **consensus (arbiter 확정 대기)** | 착수/전환 gate 분리(F1), D1=후보 B(F2), retain/remove matrix 승격 + Phase 2/5 safety surface 재분류(F3), D3 승격 보류(F4), 조건부 cascade scope(F5) 반영 |
| R1 | 2026-07-13 | Claude (실행 결과·packet 발행) | Codex (result review) | request-changes | R0 구조 반영은 충실; routing predicate SSoT(F1), T0 target probe 명령(F2), DR-007 heading(F3) 교정 후 재확인 필요. default 전환 현재 부 |
| R1-resp | 2026-07-13 | Claude (F1~F3 + nice #2 accept·교정 완료, nice #1 defer) | — | R1b 재확인 대기 | predicate SSoT 통일(F1), T0 명령 SSoT 이동(F2), heading 교정(F3), CP1 정정, CP4에 two-route simulation PASS 기록 |
| R1b | 2026-07-13 | Claude (R1 교정 제출) | Codex (좁은 재확인) | request-changes | F2·F3 종결, simulation 2건 PASS 인정. 잔여 1건: 상위 요약(README·Layer T)이 fallback override를 누락한 "조건 충족→default" 축약 — canonical 판정식 고정 요구. default 전환 현재 부 |
| R1b-resp | 2026-07-13 | Claude (accept·교정 완료) | — | R1c static diff 재확인 대기 | AGENT-FIRST에 canonical 판정식 명문화("4개 조건 전부 충족 AND Fallback override 해당 없음 → default, 그 외 전부 fallback"), 상위 3곳(README·Layer T·§G prose/flow) + playbook intro를 판정식 pointer-only로 교정 |
| R1c | 2026-07-13 | Claude (R1b 잔여 교정 제출) | Codex (static diff confirmation) | approve | canonical predicate 단일 소유 + 상위 pointer-only 정합 확인. R0/R1 must-fix 종결, default 전환 가 |

| Topic | Status | Notes |
| --- | --- | --- |
| diet 착수 gate | agreed | canary는 착수 gate 충족; default 전환은 two-route simulation + R1 gate |
| D1 체크리스트 위치 | agreed | 후보 B — `ADOPTER-UPGRADE-AGENT-FIRST.md` dispatcher + playbook fallback, pointer-only |
| D2 축소 경계 | agreed | retain/remove matrix 선행, Phase 2/5는 압축만(safety surface) |
| D3 heuristic DR | agreed | 범용 승격 보류, DR-034 amendment 입력 문구로 한정 (brief 가설 유지) |
