---
id: CHORE-20260605-003
priority: P1
status: Archived
risk: Medium
scope: Phase 2 slice 1a(현존 결함 수선) + 1b(불변식 테스트) 병행. 방향(DR-021~024)과 무관하게 영구 참인 항목만. breaking change·minimal-output 적용은 제외
appetite: 2d
planned_start: 2026-06-05
planned_end: 2026-06-07
actual_end: 2026-06-05
related_dr: [DR-021, DR-022]
related_troubleshooting: []
related_work: [CHORE-20260604-001]
---

# CHORE-20260605-003: Slice 1a/1b — Defects + Invariants

## Top Summary (결론 먼저)

- **목표:** breaking change 없는 고확실성 결함 수선(1a) + 방향 불변 테스트(1b)를 병행. DR-021~024 적용(minimal output/canonical 전환/rename)은 **제외**.
- **1a 대상(R8 확정):** ① core 문서 dangling(`HARNESS-NAMING-RULES`→DR-011) **참조 조정** ② scaffold target `decisions/README` seed 생성. **③ PLAN ID drift는 이번 slice 제외 — DR-022 하류 PLAN lifecycle slice로 이관(R8).**
- **1b 대상(R8 확정):** scaffold 출력에 대한 ① no-dangling-reference ② no-source-only-leakage assertion 스크립트 신설. **core A-class scope 한정** — Optional-pack 후보(heavy docs/확장 prompt/profile)는 hard-fail 제외, report-only/discovery로 known debt 보존.
- **합의:** heavy-doc dangling(`MAINTAINER-GUIDE`→DR-020, `WORKFLOW-MANUAL`→DR-001)은 DR-021 minimal-output 하류가 제거로 해소 → 1b는 이들을 hard-fail하지 않고 report-only.

## Context Manifest

| 순서 | 파일 | 섹션 | 왜 |
| --- | --- | --- | --- |
| 1 | `docs/decisions/DR-021-source-target-boundary.md` | Consequences(reference integrity) | dangling 처리 방향(A-class 동반/참조 조정) |
| 2 | `docs/decisions/DR-022-plan-lifecycle.md` | Consequences | PLAN 본문 rewrite=하류 경계(1a ID drift와 충돌 주의) |
| 3 | `scripts/create-harness.sh` | L219-226(DR 복사), L176-196(디렉토리) | scaffold 복사 대상 |
| 4 | `docs/works/harness/CHORE-20260604-001-...md` | Follow-Up Slicing 1a/1b | slice 정의 |

## Defect Inventory (실측 근거)

| # | 결함 | 근거 | 분류 |
| --- | --- | --- | --- |
| D1 | `HARNESS-NAMING-RULES`(core, 복사됨)가 DR-011 참조하나 scaffold는 DR-007/008/013만 복사 | `grep DR- docs/HARNESS-NAMING-RULES.md` = DR-011; `create-harness.sh:219-226` | 1a (core dangling) |
| D2 | scaffold가 `docs/decisions/README.md`를 복사/생성하지 않음. 그러나 `HARNESS-PROTOCOL`은 README index 규칙을 규정 | `create-harness.sh`에 decisions/README 없음 | 1a (missing index) |
| D3 | source `PLAN.md` Roadmap이 `AWH-001~004`, 실작업은 `CHORE-*` | `docs/PLAN.md:116-119` | **하류 이관(R8)** — DR-022 PLAN lifecycle slice. 이번 slice는 Discovery pointer만 |
| D4 | heavy-doc dangling: `MAINTAINER-GUIDE`→DR-020, `WORKFLOW-MANUAL`→DR-001 | `grep DR-` 결과 | **하류(minimal-output)** — 1b가 감지만 |

## Plan

### 1a — 현존 결함 수선 (non-breaking, direction-aligned) — R8 확정

1. **D1 (NAMING-RULES→DR-011):** **참조 조정.** `HARNESS-NAMING-RULES.md`의 DR-011 예시를 copied foundational DR(007/008/013) 중 하나 또는 DR 번호 없는 generic example로 바꾼다. DR-011을 scaffold에 동반 복사하지 않는다. **원칙:** scaffold 동반 framework DR은 generated target의 runtime/spec 참조 무결성에 꼭 필요한 foundational DR(현재 007/008/013)로 제한. DR-011(예시)·DR-021~024(source Phase 2 direction)는 제외.
2. **D2 (decisions/README):** scaffold가 target용 seed `docs/decisions/README.md` 생성(복사된 framework DR 007/008/013 목록 + target 자체 DR 추가 안내). B-class project-state seed. 생성 후 "index 존재"를 1b invariant로 둘 수 있다.
3. **D3 (PLAN ID drift): 이번 slice 제외(R8).** DR-022가 PLAN 본문 rewrite·AWH↔CHORE drift 수선을 하류로 명시(`DR-022:42`). 이번 slice는 Discovery에 stale 사실 + 후속 slice pointer만 남기고 `PLAN.md`는 수정하지 않는다.

### 1b — 불변식 테스트 (direction-invariant) — R8 확정

4. **no-dangling-reference test (core A-class scope):** temp scaffold 생성 후, **core A-class** target 문서의 `DR-NNN` reference가 실제 존재 파일을 가리키는지 assert. **(R11/PQ-4)** 이번 slice는 `DR-NNN` reference closure로 좁힌다. 일반 internal markdown link existence 검사는 하류 확장으로 남긴다. Optional-pack 후보(`HARNESS-ARCHITECTURE`·`HARNESS-MAINTAINER-GUIDE`·`WORKFLOW-MANUAL`·session-start 외 prompt·Spring profile)는 hard-fail 제외, **report-only**로 known debt(D4) 보존. **(R10/R11)** 추가 invariant: D2 seed `decisions/README` index의 row↔file closure(나열 DR 실재 + 복사 DR 등재) assert.
5. **no-source-only-leakage test (core A-class scope):** `ai-workflow-harness` 문자열 자체가 아니라(adapt가 project name으로 치환), **source-only ownership/policy/path/link 누수**를 판정. hard-fail 대상: core docs/entrypoints/rules/skills에 남은 source 전용 GitHub settings, source release/public-baseline policy, absolute local path, source-only maintainer file requirement, 존재하지 않는 source-only DR/file link.
6. 두 테스트를 `scripts/tests/`(신설) 또는 동급에 둔다. **CI 연동은 이번 slice 제외(optional follow-up).** verification은 temp scaffold 생성 후 test 실행으로 충분.

### 결정 합의 (R8 — Resolved)

- **PQ-1:** (i) core A-class scope 한정. allowlist는 개별 예외가 아니라 DR-021 class 기반 scope 제외.
- **PQ-2:** NAMING-RULES 참조 조정. DR-011/DR-021~024 scaffold 동반 제외.
- **PQ-3:** D3는 이번 slice 미구현, DR-022 하류 이관.

## Done Criteria

- [x] 1a D1(NAMING-RULES 참조 조정) + D2(decisions/README seed) 수선 (D3는 하류 이관)
- [x] 1b no-dangling / no-source-leakage 테스트 신설(core A-class scope), temp scaffold에서 green
- [x] Verification: `bash -n scripts/create-harness.sh`, generic dry-run, temp scaffold 생성 후 두 테스트 실행
- [x] Codex cross-agent 합의 (plan R8 + 구현 결과)
- [x] **사용자 최종 리뷰** 후 Done

## Verification

- `bash -n scripts/create-harness.sh`; `scripts/create-harness.sh --dry-run` generic; temp scaffold 실제 생성 후 1b 테스트 실행.
- documentation 변경분 `git diff --check`.
- scaffold cascade: `create-harness.sh` 변경이므로 T12/Tool Surface Cascade(SCAFFOLD-BOOTSTRAP 동기화) 점검.

## Checkpoints

| CP | Description | Status |
| --- | --- | --- |
| 1 | Plan Codex 검토(R8) + 결정 PQ-1~3 합의 | Done |
| 2 | 1a D1(참조 조정) + D2(README seed) + D1' DR-014 closure 수선 | Done |
| 3 | 1b 테스트 신설(core scope) + temp scaffold green | Done |
| 4 | cascade 점검 + Codex R10/R11 합의 + 사용자 리뷰 | Done |

## Cross-Agent Review And Discussion

slice 0~DR authoring의 R0~R6를 이어, 이 slice는 **구현 전 plan**을 먼저 검토한다(결정 A/B/C). 구현 결과도 후속 라운드로 검토.

### Round Log

| Round | 작성자 | 단계 | 요약 |
| --- | --- | --- | --- |
| R7 | Claude | Plan | 1a/1b defect inventory + plan + 결정 A/B/C 제기. Codex 검토 대기 |
| R8 | Codex | Plan Review | PQ-1~3 검토. 1b는 core A-class scope 한정, D1은 참조 조정 우선, D3는 DR-022 하류로 이연 권장 |
| R9 | Claude | Plan Finalize | R8 권장 5건 전부 반영 — D3 제외, D1 참조조정, 1b core scope, leakage 기준, CI 제외. 구현 착수 준비 |
| R10 | Codex | Result Review | 구현 결과 검토. DR-014 추가는 foundational reference closure로 조건부 동의. 1b test는 PASS하나 internal link/index seed invariant 범위 정렬 보강 요청 |
| R11 | Claude | Reflect | PQ-4를 DR-NNN closure로 좁힘(plan wording 정렬), seed README row↔file closure invariant를 테스트 [3]으로 추가. 재실행 PASS |

### Codex Plan Review

작성: Codex, 2026-06-05. 이 리뷰는 구현 전 plan 검토다. 코드·스크립트·문서 실제 수선은 하지 않고, slice 1a/1b의 scope와 검증 경계를 정한다.

#### Summary

Plan의 큰 방향에는 **조건부 동의**한다. slice 1a/1b를 한 PR로 묶는 것은 타당하다. 이유는 D1/D2 같은 작은 scaffold/reference defect를 고친 직후, 1b invariant test로 같은 산출물을 검증해야 회귀 방지 효과가 생기기 때문이다. 다만 D3(`PLAN.md` AWH→CHORE ID drift)는 DR-022가 명시적으로 하류로 둔 `PLAN 본문 rewrite` 경계에 걸리므로, 이번 slice의 구현 대상에서 빼고 Discovery/후속 PLAN lifecycle slice로 넘기는 편이 안전하다(`docs/decisions/DR-022-plan-lifecycle.md:36-42`).

권장 범위:

- 1a: D1은 **참조 조정 우선**, D2는 target seed `docs/decisions/README.md` 생성.
- 1b: no-dangling/no-source-only-leakage는 **core A-class scope 한정**으로 green을 만든다.
- 제외: heavy-doc 제거, minimal output, manifest schema, PLAN lifecycle rewrite, command/canonical/rename 적용.

#### PQ별 권장안

| PQ | 권장안 | 근거 | Plan 반영 제안 |
| --- | --- | --- | --- |
| PQ-1: 1b test scope | **(i) core A-class scope 한정**. Optional-pack 후보인 heavy docs는 no-dangling hard-fail 범위에서 제외한다. | DR-021은 heavy docs·확장 prompt·profile의 default 제외를 하류로 둔다(`docs/decisions/DR-021-source-target-boundary.md:36-42`). 현재 scaffold는 maintainer/manual docs를 아직 복사한다(`scripts/create-harness.sh:215-217`), 그래서 D4를 지금 hard-fail하면 minimal-output 하류 작업을 선행하게 된다. | no-dangling test는 A-class core 파일만 검사한다. Optional-pack 후보(`HARNESS-ARCHITECTURE`, `HARNESS-MAINTAINER-GUIDE`, `WORKFLOW-MANUAL`, session-start 외 prompt, Spring profile)는 이번 1b에서 제외한다. 다만 D4는 report-only discovery로 남겨 하류 minimal-output slice가 제거해야 할 known debt로 보존한다. |
| PQ-2: D1 fix | **NAMING-RULES 참조 조정 우선.** DR-011을 scaffold에 추가 복사하지 않는다. | D1의 실제 `DR-011`은 file naming 예시다(`docs/HARNESS-NAMING-RULES.md:85-92`). 반면 scaffold가 복사하는 foundational DR은 현재 DR-007/008/013뿐이다(`scripts/create-harness.sh:219-226`). DR-021은 exact file-list를 고정하지 않고 reference integrity를 하류에서 "A-class 필수 동반" 또는 "참조 조정" 중 하나로 해결한다고 했다(`docs/decisions/DR-021-source-target-boundary.md:42`). | `HARNESS-NAMING-RULES.md`의 예시를 copied foundational DR 중 하나로 바꾸거나, DR 번호 없는 generic example로 조정한다. 원칙: scaffold에 동반 복사할 framework DR은 generated target의 runtime/spec 참조 무결성에 꼭 필요한 foundational DR로 제한한다. 현재는 DR-007/008/013 유지. DR-011은 예시라 제외, DR-021~024는 source Phase 2 direction DR이라 default scaffold 동반 제외. |
| PQ-3: D3 PLAN ID drift | **이번 slice에서는 구현하지 않는다.** 최소선은 Discovery에 drift를 남기고 후속 PLAN lifecycle slice에서 처리하는 것이다. | `docs/PLAN.md` Roadmap은 실제로 AWH-001~004에서 정지해 있다(`docs/PLAN.md:116-119`). 그러나 DR-022 Consequences는 `PLAN 본문 rewrite, AWH↔CHORE ID drift 수선, 실제 phase archive`를 하류로 명시한다(`docs/decisions/DR-022-plan-lifecycle.md:42`). | D3를 1a 구현 대상에서 제외하거나 "하류 이관"으로 바꾼다. 이번 slice에서 허용 가능한 최대치는 Work Discovery에 stale 사실과 후속 slice pointer를 남기는 것뿐이다. `PLAN.md` Roadmap 행 수정, phase/archive drain, AWH→CHORE 재구성은 하지 않는다. |

#### 1a/1b 묶음 판단

**한 slice/PR로 묶는 것에 동의**한다. D1/D2는 작은 non-breaking reference/scaffold seed 수선이고, 1b invariant test가 바로 그 수선의 회귀를 막는다. 1a와 1b를 분리하면 결함 수선 PR은 테스트 없이 끝나고, 테스트 PR은 이미 바뀐 산출물을 사후 해석해야 한다. 단, D3는 제외해야 이 묶음이 선명해진다.

분리해야 하는 조건은 다음뿐이다.

- no-dangling/no-leakage test가 current scaffold 구조 때문에 대규모 allowlist나 parser 설계를 요구할 때.
- D2 `decisions/README.md` seed가 target DR lifecycle 설계까지 확장될 때.
- CI 연동이 별도 정책 논의로 커질 때.

현재 plan에서는 위 조건이 아니므로 `D1/D2 + scoped invariant tests` 한 PR이 적절하다.

#### no-source-only-leakage 판정 기준

이번 1b의 leakage test는 "source repo 이름이 보이는가"보다 **target에 ship되면 안 되는 source-only ownership/policy가 A-class core output에 섞였는가**를 본다.

권장 기준:

- 정상: `ai-workflow-harness` 문자열은 `adapt()`가 project name으로 치환한다(`scripts/create-harness.sh:137-143`). 치환 후 target project name이 보이는 것은 leakage가 아니다.
- hard-fail(core A-class scope): generated core docs/entrypoints/rules/skills에 source repo 전용 GitHub settings, source release/public-baseline policy, absolute local path, source-only maintainer file requirement, 존재하지 않는 source-only DR/file link가 남는 경우.
- 이번 slice에서 제외/report-only: Optional-pack 후보 문서 내부의 DR-020/DR-001 같은 dangling. 예: `HARNESS-MAINTAINER-GUIDE`는 DR-020을 참조한다(`docs/HARNESS-MAINTAINER-GUIDE.md:19`, `:204`), `WORKFLOW-MANUAL`은 DR-001 예시를 포함한다(`docs/WORKFLOW-MANUAL.md:1028`). 이들은 DR-021 minimal-output 하류에서 default 제외될 후보이므로 지금 hard-fail하지 않는다.
- seed/index 확인: scaffold는 `docs/decisions` directory를 만들고(`scripts/create-harness.sh:176-195`) DR-007/008/013만 복사한다(`scripts/create-harness.sh:219-226`). `docs/decisions/README.md`는 현재 생성되지 않으므로 D2 수선 후 index 존재를 invariant로 둘 수 있다.

#### Plan 수정 요청

1. `Top Summary`와 `Done Criteria`에서 D3를 "1a 대상"에서 빼거나 "하류 이관"으로 표시한다.
2. PQ-1 선택지를 (i)로 확정한다. allowlist는 individual known exception list가 아니라 DR-021 class 기반 scope 제외로 둔다.
3. PQ-2 선택지를 "NAMING-RULES 참조 조정"으로 확정한다. DR-011/DR-021~024를 scaffold 기본 DR 복사 목록에 추가하지 않는다.
4. 1b leakage test 설명에서 `ai-workflow-harness` 문자열 자체가 아니라 "source-only ownership/policy/path/link leakage"를 판정한다고 명확히 한다.
5. CI 연동은 이번 plan에서 제외하거나 optional follow-up으로 둔다. 이번 slice verification은 temp scaffold 생성 후 test 실행이면 충분하다.

### Codex Result Review (R10)

작성: Codex, 2026-06-05. 이 리뷰는 R10 구현 결과의 정합성 검토다. 직접 수정 범위는 이 Work 파일로 제한하고, 코드/스크립트/DR 파일의 보강은 Claude 합의 반영 단계로 넘긴다.

#### Summary

전체 판단은 **조건부 동의**다. D1 참조 조정, D2 `decisions/README.md` seed 생성, D3 이관, README mermaid 동기화는 slice 1a/1b 경계 안에 있다. D1'로 발견된 DR-014 추가도 R8의 "DR 추가 말라"를 단순 위반한 것이 아니라, copied foundational DR의 substantive dependency를 닫는 조치라 PQ-2 원칙에 부합한다.

다만 1b test는 현재 PASS하지만, Work plan이 말한 `DR-NNN/내부 링크` 중 실제 구현은 `DR-NNN` 존재성에 한정된다. 또 D2 seed README의 "존재 + 복사 DR row closure"는 아직 명시 invariant가 아니다. 이 둘은 이번 slice의 불변식 이름과 검증 surface를 맞추기 위해 보강하거나, Work wording을 `DR reference invariant`로 좁혀야 한다.

검증 재실행: `bash -n scripts/create-harness.sh` PASS, `bash -n scripts/tests/check-scaffold-invariants.sh` PASS, `scripts/tests/check-scaffold-invariants.sh` generic temp scaffold PASS. Optional-pack은 계획대로 `DR-020`/`DR-001`을 report-only로 표시했다.

#### 검토 결과

| 대상 | 판단 | 근거 | 조건/수정 요청 |
| --- | --- | --- | --- |
| D1 `HARNESS-NAMING-RULES` DR-011→DR-013 | **동의** | DR naming 예시는 copied foundational DR인 `DR-013`으로 바뀌어 target dangling을 만들지 않는다(`docs/HARNESS-NAMING-RULES.md:85-92`). | 없음. DR-011을 동반 복사하지 않는 R8 원칙을 유지한다. |
| D1' DR-014 복사 추가 | **조건부 동의** | DR-008은 archive mirror 예외를 `DR-014`로 직접 참조하고(`docs/decisions/DR-008-docs-filename-standard.md:52`), DR-013은 Work archived 경로에 `DR-014` 적용을 명시한다(`docs/decisions/DR-013-work-file-spec.md:17`). DR-014 자체는 archive mirror 정책의 본문 근거다(`docs/decisions/DR-014-archive-policy.md:12`, `:41-44`). DR-021도 reference integrity를 "A-class 필수 동반" 또는 "참조 조정"으로 풀 수 있다고 열어 두었다(`docs/decisions/DR-021-source-target-boundary.md:42`). | reference-closed 집합은 `{DR-007, DR-008, DR-013, DR-014}`로 고정한다. DR-014는 NAMING-RULES의 DR-011 예시와 달리 substantive dependency라 복사가 맞지만, DR-021~024 같은 source Phase 2 direction DR까지 확장하지 않는다. |
| D2 `docs/decisions/README.md` seed | **조건부 동의** | scaffold는 `docs/decisions` directory를 만들고(`scripts/create-harness.sh:176-195`), foundational DR 4개와 README seed를 생성한다(`scripts/create-harness.sh:219-245`). HARNESS-PROTOCOL은 cascade 감사가 `docs/decisions/README.md` index의 Accepted DR을 확인한다고 규정한다(`docs/HARNESS-PROTOCOL.md:390-394`). | 1b에 `docs/decisions/README.md` 존재와 row-to-file closure를 가볍게 assert하거나, Verification에 수동 확인으로 명시한다. 지금 스크립트는 `find docs/decisions`에 잡히는 파일을 검사할 뿐, README 누락 자체를 실패로 만들지는 않는다(`scripts/tests/check-scaffold-invariants.sh:49-52`). |
| 1b core A-class scope | **동의** | hard-fail core는 entrypoint/protocol/rule/command/skill/cursor/session-start/decisions로 제한되어 있고(`scripts/tests/check-scaffold-invariants.sh:38-53`), heavy docs와 확장 prompts는 report-only로 분리되어 있다(`scripts/tests/check-scaffold-invariants.sh:55-62`). DR-021은 heavy docs·profile 제외와 exact file-list를 하류로 둔다(`docs/decisions/DR-021-source-target-boundary.md:38-42`). | future profile test가 추가되면 profile-specific optional files는 이번 core hard-fail에 섞지 않는다. |
| no-source-only-leakage pattern | **조건부 동의** | `adapt()`가 source repo name을 target project name으로 치환한다(`scripts/create-harness.sh:137-143`). 현재 hard-fail pattern은 un-substituted `ai-workflow-harness`와 local absolute path(`/Users/`, `/home/[a-z]`)만 본다(`scripts/tests/check-scaffold-invariants.sh:93-109`). | 이번 slice의 minimal invariant로는 충분하다. 단, `/home/...` generic 예시가 core에 생기면 false positive가 가능하고, repo name 없이 남은 source-only release/public-baseline policy는 false negative가 가능하다. richer taxonomy는 DR-021 manifest/--check 하류에서 다루는 편이 맞다. |
| no-dangling-reference 구현 범위 | **수정 요청** | Work plan은 `DR-NNN/내부 링크`를 검사한다고 되어 있으나(`docs/works/harness/CHORE-20260605-003-slice1ab-defects-invariants.md:52`), 스크립트는 `grep -ohE 'DR-[0-9]{3}'`만 검사한다(`scripts/tests/check-scaffold-invariants.sh:71-80`). | PQ-4로 남긴다. 이번 slice에서 internal markdown link 존재성까지 검사할지, 아니면 계획 문구를 `DR reference`로 좁히고 internal link check를 하류로 뺄지 결정이 필요하다. |
| D3 PLAN ID drift 이관 | **동의** | PLAN Roadmap은 실제로 `AWH-001~004`에서 정지해 있지만(`docs/PLAN.md:116-119`), DR-022는 `PLAN 본문 rewrite, AWH↔CHORE ID drift 수선`을 하류로 명시한다(`docs/decisions/DR-022-plan-lifecycle.md:42`). | Discovery pointer만 남긴 처리가 맞다. |
| README mermaid 열거 | **동의** | README scaffold 열거가 `decisions(DR-007/008/013/014 + README)`로 copy matrix와 동기화되었다(`README.md:496-505`). | DR copy set 변경 시 README mermaid와 `create-harness.sh` seed를 함께 갱신한다. |

#### 빠진 불변식 제안

1. **D2 index seed invariant:** `docs/decisions/README.md`가 존재하고, seed table의 DR-007/008/013/014 row가 실제 copied DR 파일을 가리키는지 확인한다.
2. **scope wording 정렬:** no-dangling을 이번 slice에서 `DR-NNN` reference closure로 제한한다면 Work/스크립트 설명에서 "내부 링크"를 제거한다. 내부 markdown link existence까지 유지하려면 core A-class markdown link checker를 추가한다.

### Plan-Level Open Questions

| ID | Question | Owner | Status |
| --- | --- | --- | --- |
| CHORE-20260605-003/PQ-1 | 1b 테스트 scope 긴장(A): core-only scope vs known-exception allowlist vs 지금 heavy 제거? | Codex + Claude | Resolved (R8) — core A-class scope 한정, Optional-pack 후보는 report-only/discovery |
| CHORE-20260605-003/PQ-2 | D1 fix: DR-011 A-class 동반 복사 vs NAMING-RULES 참조 조정? framework DR 동반 원칙은? | Codex + Claude | Resolved (R8) — NAMING-RULES 참조 조정 우선, DR-011/DR-021~024는 default DR 복사 제외 |
| CHORE-20260605-003/PQ-3 | D3 PLAN ID 표기 수선이 DR-022 "본문 rewrite 하류"를 침범하지 않는 최소선은? | Codex + Claude | Resolved (R8) — 이번 slice에서 구현하지 않고 후속 PLAN lifecycle slice로 이관 |
| CHORE-20260605-003/PQ-4 | 1b `no-dangling-reference`가 internal markdown link existence까지 검사할지, 이번 slice는 `DR-NNN` reference closure로 좁힐지? | Codex + Claude | Resolved (R11) — 이번 slice는 `DR-NNN` closure로 좁히고 plan wording 정렬. internal-link 검사는 하류 확장. 추가로 seed README row↔file closure invariant 구현 |

### Consensus Log

| Date | Topic | Consensus | Remaining Risk |
| --- | --- | --- | --- |
| 2026-06-05 | R8 plan review | Codex 권장: 1b는 core A-class scope 한정, D1은 NAMING-RULES 참조 조정, D3는 DR-022 하류로 이관. 1a(D1/D2)+1b scoped invariant tests는 한 PR로 묶어도 적절하다. | Claude/user 합의 반영 전까지 D3가 1a 구현 대상으로 남아 있으면 PLAN lifecycle rewrite 경계 침범 위험 |
| 2026-06-05 | R10 result review | DR-014 추가는 copied foundational DR의 substantive dependency를 닫는 조치라 PQ-2 원칙에 부합. D1/D2/D3/README 동기화와 core A-class scope는 방향상 동의. | 1b test가 internal markdown link와 README seed row closure를 아직 직접 assert하지 않음(PQ-4). leakage pattern은 minimal invariant라 richer policy leakage는 하류 taxonomy 필요 |
| 2026-06-05 | R11 reflect | PQ-4 Resolved — 이번 slice는 `DR-NNN` closure로 좁힘, internal-link 검사는 하류. seed README row↔file closure invariant를 test [3]으로 추가, 재실행 PASS. | richer policy-leakage taxonomy와 internal-link existence는 하류 slice 확장 항목으로 남음 |

## Discovery

- **D3 PLAN ID drift 이관(R8/R9):** `docs/PLAN.md:116-119` Roadmap이 `AWH-001~004`로 정지(stale), 실작업은 `CHORE-*`. 이번 slice에서 수정하지 않음. → **후속 PLAN lifecycle slice(DR-022 적용)에서 AWH↔CHORE 정합 + archive drain + T5 배선과 함께 처리.**
- **D4 heavy-doc dangling known debt:** `MAINTAINER-GUIDE`→DR-020, `WORKFLOW-MANUAL`→DR-001. 1b가 report-only로 감지. → minimal-output 하류 slice(#9, DR-021 적용)가 heavy docs를 default 제외하면 해소.
- **D1' 신규 발견(1b 테스트가 잡음, R8 미인지):** 복사되는 foundational DR-008·DR-013이 **DR-014**(archive 정책)를 substantive 참조하나 DR-014 미복사 → core A-class dangling. 참조 폐쇄 분석 결과 reference-closed 집합은 {007,008,013,014}(DR-014는 추가 참조 없음). **조치:** PQ-2 원칙("참조 무결성에 꼭 필요한 foundational DR")에 따라 DR-014를 scaffold 복사 집합에 추가(NAMING-RULES 예시 같은 단순 mention과 달리 substantive 의존). seed README·README.md mermaid 열거도 갱신. → **Codex R10 검토 대상(R8 "007/008/013 유지"에서 1건 확장).**
- **검증 결과:** `scripts/tests/check-scaffold-invariants.sh` PASS (core green, Optional-pack D4 report-only). `bash -n` OK, generic dry-run OK. SCAFFOLD-BOOTSTRAP는 decisions를 enumerate하지 않아 cascade 영향 없음.
