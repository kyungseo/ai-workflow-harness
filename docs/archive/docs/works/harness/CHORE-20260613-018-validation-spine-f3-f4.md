---
id: CHORE-20260613-018
priority: P2
status: Archived
risk: L2
scope: `Validation Spine residual follow-ups`의 F3 + F4를 한 Work로 다룬다. F3은 mirror parity / prompt 정합 / language policy(DR-007) catalog 점검을 deterministic Tier 1 assertion으로 **승격할지 먼저 검토(Phase 0)** 하고, 검토 결과 승인된 subset만 구현한다(승격 0건도 정당한 결론). F4는 runner 결과를 `/repo-health`에 surface하되 기존 Layer K 표면을 우선 활용하는 최소 변경으로 한다. F1은 CHORE-20260613-017에서 종결, F2는 DR-036으로 무배선 종결. broad repo-health 재구조화·CI/pre-commit 배선 재논의는 비범위.
appetite: 0.5d
planned_start: 2026-06-13
planned_end: 2026-06-13
actual_end: 2026-06-13
related_dr: [DR-036]
related_troubleshooting: []
related_work: [CHORE-20260613-017, CHORE-20260611-005, CHORE-20260611-006, CHORE-20260613-004, CHORE-20260613-016]
---

# CHORE-20260613-018: Validation Spine residual F3 + F4 — Tier 1 승격 검토 + repo-health surface

## Top Summary

- **목표:** `Validation Spine residual`의 마지막 잔여 F3/F4를 닫는다. F3 = mirror/prompt/language catalog 점검을 deterministic assertion으로 승격할지 검토하고 정당한 subset만 구현. F4 = runner 결과를 `/repo-health`에 최소 surface.
- **왜 지금:** F1(CHORE-20260613-017)·F2(DR-036) 종결로 W4 잔여는 F3/F4만 남았다. 둘은 taxonomy §6에 후속 자리가 예약돼 있고, 닫으면 `Validation Spine residual` 항목 전체가 종결된다.
- **핵심 경계 (Red Team 반영):** 이 Work는 **구현 전제가 아니라 검토 전제**다. F3의 세 후보 각각이 (a) 실제 회귀 위험 (b) 기존 표면(repo-health Area A / Mirror Atomicity rule)으로 안 잡힘 (c) 낮은 false-positive — 셋을 모두 만족할 때만 승격한다. **승격 0건이 정당한 결론일 수 있다.** F4는 repo-health 비대화를 금지하고 기존 Layer K를 우선 활용한다.
- **역할:** Claude = author/driver + self red-team(plan + result 양쪽). 사용자 = 방향 승인 + 최종 commit 승인. Phase 0 검토 결과는 구현 착수 전 사용자에게 보고하고 승인받는다(구현 gate).

## Candidate Fit

1. W4 잔여의 유일한 concrete 미완 항목이고, 닫으면 `Validation Spine residual (F1-F4)` backlog 항목이 종결된다.
2. F1이 executable spine을 positive하게 강화한 직후라, F3/F4의 "더 승격할 가치가 있나"를 판정하기 좋은 시점이다.
3. 단, F2를 무배선으로 닫은 "중복만 만든다" 논리가 F3에도 적용될 위험이 커서, 검토 gate 없이 구현부터 들어가면 안 된다 — 그래서 Phase 0를 명시 단계로 둔다.

## Red Team — 착수 전 자기검토 (방향 의심)

| # | 공격 | 함의 |
| --- | --- | --- |
| RT1 | mirror assertion은 repo-health Area A + Mirror Atomicity rule에 이은 **세 번째 중복 표면**일 수 있다 | F2를 닫은 "중복만 만든다" 논리가 그대로 적용. 실제 회귀 공백을 증명 못 하면 승격 불가 |
| RT2 | backlog 문구는 "승격**할지 검토**·구현"인데 구현을 전제하면 검토를 건너뛴 것 | 승격 0건도 정당한 결론으로 열어둬야 함 |
| RT3 | F4가 runner(`--all`, tier2 scaffold 생성)를 repo-health에 박으면 Quick mode 경량성·Area H 원칙 위반 | F4는 "어느 tier를 언제" 경계를 좁게 정의하거나 Layer K pointer 보강 수준의 최소 변경 |
| RT4 | canonical↔adapter mirror는 source 전용 surface → adopter repo엔 무의미 | 새 script는 adopter-safe graceful skip 필요. 그 복잡도가 승격 가치를 깎는지 판단 |

## Context Manifest

| 순서 | 파일 | 섹션 | 왜 |
| --- | --- | --- | --- |
| 1 | `docs/backlog/HARNESS.md` | `Validation Spine residual follow-ups (F1-F4)` | F3/F4 원문 범위·Done Criteria |
| 2 | `docs/maintainer/HARNESS-TEST-TAXONOMY.md` | §1 경계, §3 Surface×Depth, §6 후속 | 승격 가치·경계 원칙 SSoT |
| 3 | `docs/maintainer/VERIFICATION-COMMANDS.md` | Layer F / P / S / K | F3 후보 3종 + F4가 닿을 Layer K 현황 |
| 4 | `scripts/tests/run-harness-checks.sh` | 전체 | runner tier 구조, graceful skip 패턴 |
| 5 | `scripts/tests/check-default-template-parity.sh` | 전체 | parity assertion 선례(승격 시 형태 참고) |
| 6 | `skills/workflow/repo-health.md` (+ `repo-health-full.md`) | Area A, Output Contract #6, Area H | F4 surface 지점·비대화 경계 |
| 7 | `docs/HARNESS-PARALLEL-WORK-CONTROLS.md` | Command/Skill Mirror Atomicity | RT1 중복 판정의 기존 표면 확인 |

## Current Facts

| Surface | Current Role | Observation |
| --- | --- | --- |
| Layer F | tool-surface 정렬 catalog | mirror 누락 탐지 loop는 deterministic하나, 과잉반복/adapter 비대는 judgment. `skills/workflow/`엔 mirror 없는 slice(`repo-health-full/cascade`)·`README`가 있어 glob 기반 assertion은 false-positive |
| Layer P | language policy catalog | "NO KOREAN" zero-check는 비교적 deterministic, "LOW ratio<3"은 명시적 false-positive 허용 screening. UTF-8 locale 전제 |
| Layer S | prompt 정렬 catalog | session-start 3종 존재·canonical 참조는 deterministic. 섹션헤더 매칭·독자규칙 의심(wc)은 loose/judgment |
| Layer K | repo-health 통합 실행 catalog | **이미 존재** — F4가 본문 신설 없이 여기에 정합/pointer 보강으로 닫힐 가능성 |
| `run-harness-checks.sh` | thin runner | tier0/closure/invariants/default-template-parity. graceful skip(adopter-safe) 패턴 확립됨 |

초기 read-only 사실:
1. F3 후보 3종 모두 **deterministic core + judgment tail**이 섞여 있다. 승격은 잘해야 core subset이며, glob이 아니라 명시적 집합을 인코딩해야 한다.
2. F4가 닿을 Layer K가 이미 있어, F4는 신설보다 정합·경계 명시에 가깝다.
3. mirror/prompt parity는 source 전용이라 adopter-safe skip이 필수다.

## Scope / Non-Goals

### Scope

1. **Phase 0 (검토, 구현 전):** F3 후보 3종을 (a)(b)(c) 기준으로 판정하고, 승격/보류를 근거와 함께 표로 산출한다. F4가 Layer K 보강으로 닫히는지 본문 변경이 필요한지 판정한다. **결과를 사용자에게 보고하고 승인받은 뒤에만 Phase 1로 넘어간다.**
2. **Phase 1 (F3 구현, 승인 시):** 승격 결정된 subset만 deterministic assertion으로 구현(adopter-safe skip 포함), runner에 배선, catalog 해당 Layer를 script pointer로 전환(미승격분은 명령 유지).
3. **Phase 2 (F4 구현, 승인 시):** runner 결과를 `/repo-health`에 최소 surface. 기존 Layer K·Output Contract #6 정합 우선, repo-health는 불변식 재구현 금지·호출/해석만.
4. taxonomy §3/§6, `SOURCE-REPO-OPERATIONS.md` Update Triggers 정합 마감.

### Non-Goals

- F3 후보의 judgment tail(과잉반복·adapter 비대·독자규칙 의심·LOW-ratio screening) 승격 — catalog/repo-health 유지
- 새 assertion의 pre-commit/CI 배선 (DR-036 무배선 기조 유지; 배선하려면 별도 DR)
- repo-health Required Surface Matrix / cascade slice 재구조화
- runner를 무거운 tier2까지 repo-health Quick mode에 강제 호출
- product/adopter Layer U 확장

## Done Criteria

- [x] **Phase 0 검토 결과 보고 + 사용자 승인** — F3 옵션 A(mirror+prompt존재 승격, language 보류) + F4 최소 변경 승인
- [x] (승격) `check-surface-mirror-parity.sh` 현재 repo PASS, drift 주입(SKIL 누락) FAIL, 복원 후 PASS 실측
- [x] (승격) adopter-safe skip 확인(`--root /tmp` → SKIP exit 0), runner `--all` 통과(tier0+closure+tier2 3모드 green)
- [x] (승격분) catalog Layer F/S deterministic core를 script pointer로 전환, judgment/screening 명령 유지
- [x] F4: repo-health.md + Layer K에 runner tier 호출/해석 경계 명시, 불변식 재구현 0, Quick=tier0/tier1(생성 없음)
- [x] taxonomy §1/§3/§6가 실제 `scripts/tests/` 자산과 정합, F3/F4 행 종결 표기
- [x] `Validation Spine residual (F1-F4)` backlog 항목 종결 — work-close에서 제거(STATUS/Work Done과 bundle)
- [x] 구현 결과 self red-team 수행 후 result review 보고

## Verification

- `bash scripts/tests/run-harness-checks.sh --all`
- (승격분) 새 script 단독 실행 PASS → drift 주입 FAIL → 복원
- adopter-safe: scaffold/maintainer script 부재 시 SKIP 동작 확인(temp scaffold 또는 경로 모킹)
- taxonomy §3/§6 ↔ `ls scripts/tests/` 정합 grep, catalog Layer F/P/S pointer 정합 grep
- repo-health 3종 adapter mirror 정합, DR-007 점검
- `git diff --check`

## Checkpoints

| CP | 내용 | 상태 |
| --- | --- | --- |
| CP0 | Work 파일 생성 + branch + STATUS Active pointer | 완료 |
| CP1 | Phase 0 검토 판정표 산출 → 사용자 승인(옵션 A + F4 최소) | 완료 |
| CP2 | F3 `check-surface-mirror-parity.sh` 구현 + runner tier0c 배선 + Layer F/S pointer 전환 | 완료 |
| CP3 | F4 Layer K + repo-health.md runner surface 최소 명시 | 완료 |
| CP4 | taxonomy §1/§3/§6 + SOURCE-REPO-OPS 정합 + result red-team | 완료 (backlog 제거는 work-close) |

## Result Red Team (구현 후 자기검토)

| # | 공격 | 판정 |
| --- | --- | --- |
| RR1 | 새 assertion이 pre-commit/CI에 배선돼 deny-list 누락 시 commit 차단? | **무위험.** pre-commit은 closure만, CI는 scaffold inline assertion만 호출. mirror parity는 tier0c(수동/마일스톤) + F4 repo-health surface에서만 실행 → deny-list 누락은 commit 차단이 아니라 수동 실행 시 FAIL로만 노출. DR-036 무배선 기조와 일관 |
| RR2 | prompt "존재"만 보므로 빈 cursor prompt도 PASS — 과장된 "parity"? | scope를 "존재만"으로 한정·taxonomy 명시. canonical 참조/섹션 정합은 catalog 유지. 정직한 경계 |
| RR3 | Layer F mirror loop를 appendix로 남긴 게 중복? | Layer Q helper+appendix 패턴 준용("수동 재현용" 명시). 일관 |
| RR4 | F4가 Execution Principles에만 있고 Mode Contract Quick Required엔 없어 호출 유도 약함 | **정직한 한계.** F4=강제 실행이 아니라 surface 명시(사용자가 "최소 변경" 선택, Area H 경량성 보호). 전역 Execution Principle이라 Quick에도 적용되나, 강제 gate는 아님 |

**종합:** mirror parity는 *hard gate*가 아니라 **수동/`/repo-health` 시점 회귀 탐지 자산**이다. Phase 0의 "저비용 회귀 잠금" 표현보다 정확히는 "탐지 도구 제공"이며, 이는 F2(DR-036) 무배선 기조의 의도된 설계다. language policy 보류 판정은 실측(rule 15건 NO-KOREAN)으로 뒷받침됨.

## Discovery

- backlog `Validation Spine residual follow-ups (F1-F4)` candidate 착수. F1/F2는 종결, 이 Work가 F3/F4를 담당.
- 착수 전 Claude self red-team으로 원래 계획(구현 전제)을 검토 전제로 조정함(RT1~RT4). Phase 0 검토 gate를 구조에 내장.

## Next Actions

1. Phase 0 검토 수행: F3 후보 3종 (a)(b)(c) 판정 + F4 변경 깊이 판정.
2. 검토 결과를 판정표로 보고하고 승인 대기(구현 gate).
