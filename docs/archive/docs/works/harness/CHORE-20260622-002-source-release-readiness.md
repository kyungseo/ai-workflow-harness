---
id: CHORE-20260622-002
priority: P1
status: Archived
risk: L3
actual_end: 2026-06-22
scope: source repo `develop→main` 릴리즈 readiness를 cross-agent red-team으로 판정하고, release-go일 때 release-prep(VERSION bump 결정 + 릴리즈 노트 + Release Full Sweep + develop→main PR/merge/tag/develop sync)을 단계 승인 하에 실행한다. 실제 main merge/tag는 outward-facing L3이며 사용자 최종 승인 gate를 별도로 받는다.
appetite: 1d
planned_start: 2026-06-22
planned_end: 2026-06-22
related_dr: [DR-028, DR-034, DR-042]
related_troubleshooting: []
cross_agent:
  A: Claude (author/driver)
  B: Codex (red team reviewer)
---

# CHORE-20260622-002 — Source develop→main Release Readiness + Release Prep

## Trigger

사용자 요청: "source develop→main 릴리즈를 검토한 후 문제없다면 release-prep 실행. main에 머지해야 할 항목 중 아직 미완·후속이 남아 나가면 안 되는 항목이 있는가? 현재 릴리즈해도 괜찮은가."
STATUS Next Actions의 "운영 보류: source `develop→main` 릴리즈 — develop이 main보다 앞섬, 의도적 별도 release 이벤트로 보류" 항목을 release 이벤트로 전환하는 작업이다.

## Evidence (read-only, 2026-06-22 실측)

| 항목 | 값 |
| --- | --- |
| develop ahead of main | **22 commits** (`origin/main..origin/develop`) |
| develop `VERSION` | `1.3.0` |
| main `VERSION` | `1.3.0` |
| 최신 release tag | `ai-workflow-v1.3.0` (origin/main이 정확히 이 tag) |
| develop describe | `ai-workflow-v1.3.0-22-gf0a7b00` |
| 변경 규모 | 33 files, +4736 / -56 |

**핵심 발견 — VERSION blind spot (CHORE-005가 경고한 그것):**
`ai-workflow-v1.3.0` tag가 이미 main에 존재하는데 develop의 `VERSION`은 여전히 `1.3.0`이다. 즉 1.3.0 릴리즈 후 develop이 *다음 in-development 값*으로 bump되지 않았다(DR-028 #2 위반 상태). 지금 develop→main merge 후 `git tag ai-workflow-v{VERSION}`을 그대로 실행하면 **1.3.0 재태깅 충돌**이 된다. → **VERSION bump 결정은 release-prep의 hard prerequisite.**

### Shippable substantive surface (delta 분류)

| 분류 | 항목 | 완료 상태 |
| --- | --- | --- |
| 신규 DR | DR-040(parity gate), DR-041(pack docs path), DR-042(adopter DR namespace) | 완료 (record) |
| DR amendment | DR-028(source-ref baseline), DR-034(customized-entrypoint) | 완료 |
| Scaffold consumer surface | `create-harness.sh` `--check` source-ref WARN (+26) | 완료 (CHORE-006) |
| Workflow surface | `work-close.md`(+29 Needs-Triage), `session-start.md`(+2 archive surfacing) | 완료 (CHORE-001) |
| Hook/gate | `pre-commit`(+21), DR-040 parity gate wiring | 완료 (CHORE-019) |
| Maintainer(source-only, scaffold 미배포) | `ADOPTER-UPGRADE-MIGRATION-PLAYBOOK.md`(+404), VERIFICATION/SOURCE-REPO-OPS | 완료 |
| Tracking/archive | backlog, archive Work 11건, briefs, README index | 완료 |

### 의도적으로 deferred된 후속 (블로커 아님 — by design)

| 항목 | 상태 근거 |
| --- | --- |
| DR-034 promotion (Draft 유지) | high-band adopter 2건(ai-deck+spring) 모두 manifest/agent-mediated → #1 pre-manifest shadow baseline UNMET. **의도적 Draft.** Draft DR을 record로 ship하는 것은 이 repo 관례 |
| DR-042 successor (②b prefix / ③ directory) | Policy Horizon trigger gated. 의도적 deferred, backlog 등록됨 |
| spring framework surface upgrade (CHORE-005 잔여 7 drift) | **adopter repo(spring) 작업이지 source release 콘텐츠가 아님.** cross-agent+단계 승인으로 별도 진행 |
| DR namespace successor 재검토 | gated, backlog |

## Author (A) Draft Assessment — 사전 판정

**Q1: main에 나가면 안 되는 미완/후속 항목이 있는가? → 콘텐츠상 없음.**
delta 22 commit의 substantive surface는 모두 완료된 closed Work의 산출물이다. deferred 항목(DR-034 Draft, DR-042 successor, spring framework upgrade, namespace successor)은 모두 *의도적으로 미루고 backlog/DR에 기록된* 후속이며, 절반만 구현된 mid-flight 깨짐이 아니다. Draft DR과 gated follow-up을 main에 올리는 것은 이 repo의 정상 관례다.

**Q2: 현재 릴리즈해도 괜찮은가? → 콘텐츠는 release-safe이나 release-prep은 no-op이 아니다.** merge 전 hard prerequisite 3건:

1. **VERSION bump 결정 (필수, 가장 중요).** 1.3.0은 이미 tag됨 → develop을 다음 값으로 올려야 한다. DR-028 semver를 delta에 적용:
   - **MINOR(1.4.0) 근거(A의 lean):** `create-harness.sh --check` 동작 변화, workflow surface 추가(work-close Needs-Triage / session-start archive surfacing)는 *신규 scaffold/adopter가 보는 contract에 하위호환 추가*다 → MINOR.
   - **PATCH(1.3.1) 반론:** 신규 command/option/pack은 없고 대부분 maintainer-internal·문서·gate 보강이다. adopter-visible 신규 기능이 "추가"라기보다 "보강"이면 PATCH.
   - → **B red-team 핵심 쟁점.** A는 MINOR(1.4.0)를 제안하나 PATCH 반론을 진지하게 검토 요청.
2. **릴리즈 노트.** DR-028은 릴리즈 노트(+ Breaking 섹션) 요구. CHANGELOG 파일은 없음 → 릴리즈 노트 artifact 생성 필요. adopter-facing 변화(`--check` WARN 동작, playbook 신설) 명시.
3. **Release Full Sweep + Public Clean Baseline Gate.** `docs/maintainer/VERIFICATION-COMMANDS.md` "Release Full Sweep" preset + `docs/GIT-WORKFLOW.md` §3-1. 출하 표면 P0/P1=0이면 release-go.

**A 결론(R1 전 잠정):** *content release-go, 단 VERSION bump 결정 + 릴리즈 노트 + Full Sweep를 release-prep으로 선행해야 함.* 그냥 merge+tag는 불가(버전 충돌).

**A 결론(R1 후 수정 — B C1 수용):** "content release-go"는 검증 전 단정이었다 → **"provisional release candidate"로 격하 후 gate evidence로 재판정**. 아래 Gate Evidence 실행 결과 deterministic + state gate 전부 PASS이며 half-implemented feature 없음(B도 동의). 유일한 release-block은 G7(VERSION==tag, 기계적). 따라서 **release-go 재선언: 단, P1에서 (1) VERSION 1.4.0 bump (2) 릴리즈 노트(compatibility 섹션 포함) (3) STATUS/PLAN release-target wording 보정 (4) judgment Layer 전수를 선행 조건으로 닫는다.**

## Gate Evidence (R1 follow-up — C1/C4 close)

2026-06-22 실측, branch `feature/CHORE-20260622-002-source-release-readiness`.

| Gate | 항목 | 결과 |
| --- | --- | --- |
| G1 | `run-harness-checks.sh --all` (validation spine) | ✅ OVERALL PASS (all modes green) |
| G2 | `check-onboarding-flows.sh` (Layer J-OB/Q core, hook functional) | ✅ RESULT PASS |
| G3 | `bash -n scripts/create-harness.sh` | ✅ syntax OK |
| G4 | `git diff --check` | ✅ clean |
| G5 | `create-harness.sh --dry-run` | ✅ 정상 출력 |
| G6 | Work lifecycle (`rg ^status:` docs/works·archive) | ✅ Done=0, archive 전부 Archived, Active=CHORE-002 자신만 |
| G7 | **VERSION↔tag (Layer R)** | ⚠️ **VERSION 1.3.0 == latest tag `ai-workflow-v1.3.0` → release-block. P1 step 5에서 1.4.0 bump로 해소** |
| G8 | secret/stale scan (shipped 표면) | ✅ 깨끗. `secrets/**`는 scaffold permission rule template(비밀 아님), `settings.local.json` 절대경로는 local-only(gitignore 대상), STATUS wording은 P1 보정 |

**남은 judgment Layer (P1에서 닫음):** STATUS/PLAN release-target wording(line 13 "1.3.0 minor 릴리즈", line 58 "운영 보류 20 commit"→22) 보정, `/session-start` clean-idle 시뮬레이션(CHORE-002 close 후 Active 비어야 함), adoption path link inspection, Release Full Sweep judgment Layer 전수.

## Plan (phased, gated)

```
P0 Readiness Gate (이번 Work 본체)
  1. delta/version/follow-up evidence 확정 → 검증: 위 Evidence 표 (DONE)
  2. A draft assessment 작성 → 검증: Q1/Q2 판정 + prerequisite 목록 (DONE)
  3. B red-team review (R라운드) → 검증: Cross-Agent Review 섹션 Consensus
  4. VERSION bump 값 합의 (1.4.0 vs 1.3.1) → 검증: DR-028 semver 매핑 근거 + 사용자 승인
P1 Release Prep (release-go + 사용자 승인 후에만, §3-0/§3-1 확장 — B C4 수용)
  5. VERSION 1.3.0 → 1.4.0 bump (B C2 합의) → 검증: tag 충돌 해소, manifest harness_version 정렬
  6. STATUS/PLAN release-target wording 보정 (focus 1.4.0, 운영보류 항목 해소) → 검증: §3-1 STATUS rows
  7. 릴리즈 노트 작성 (Breaking 없음 + Compatibility/주의 섹션) → 검증: DR-028 형식 + 아래 3항목 포함
  8. §3-1 Public Clean Baseline Gate 전수 + Release Full Sweep judgment Layer → 검증: 출하표면 P0/P1=0
  9. release-prep feature→develop PR merge (§3-0 step7) → 검증: develop 반영
  10. CHORE-002 /work-close (Active 비움) → develop→main 릴리즈 PR + merge + tag ai-workflow-v1.4.0 + develop sync(§3-4)
```

P1의 5~10은 outward-facing L3이므로 각 단계 **사용자 최종 승인 gate**를 별도로 받는다. P0에서 release-block이 나오면 P1 미진입.

**VERSION 결정 (B C2 합의): `1.4.0` MINOR.** 근거: delta가 `--check` 출력 contract(source-ref/WARN), `work-close`/`session-start` workflow behavior, source-gitflow hook/CI parity gate를 바꾼다 = adopter-visible/additive workflow contract. PATCH는 "adopter 비가시" 반증을 요구하나 delta가 그 기준을 넘는다.

**릴리즈 노트 Compatibility 섹션 필수 3항목 (B C2/C3):**
1. `--check`가 clean release tag가 아니면 WARN 출력(report-only) — 동작 변화.
2. source-gitflow hook/CI parity gate가 drift를 더 이르게 차단할 수 있음.
3. 기존 adopter upgrade proof는 released main/tag 기준으로 재라벨링 필요.

**Deferred / Not release-blocking 명시 (B C3):** 릴리즈 노트·assessment에서 분리 기술. DR-034는 "Draft 유지, promotion condition #1(pre-manifest shadow baseline) UNMET" — public main에서 "진척 완료"로 오해 금지. spring framework surface upgrade는 "target adopter follow-up, source release blocker 아님".

## Done Criteria

- [x] develop→main delta·version·follow-up readiness가 evidence로 확정된다 (Evidence 표 + Gate Evidence G1~G8)
- [x] A draft assessment(Q1/Q2 + prerequisite)가 작성된다
- [x] B red-team review 합의 도달 (Cross-Agent Review Consensus, C1~C4 수용)
- [x] VERSION bump 값이 DR-028 근거로 합의된다 (1.4.0 MINOR) — P1-A에서 VERSION 파일 반영, 사용자 최종 승인은 merge gate
- [x] 릴리즈 노트 확정 + §3-1 Public Clean Baseline final gate PASS (2026-06-22). develop→main merge/tag(`ai-workflow-v1.4.0`)/sync는 이 close 직후 실행되는 release event이며 이 Work가 gate한다 — closeout 참조
- [x] 사용자 최종 리뷰 (사용자가 readiness 판정·release note·P1-A 결과 승인 후 "develop→main 1.4.0 릴리즈 진행" 지시 = 최종 리뷰 충족)

## Release Notes Draft (1.4.0) — P1-A 산출물

VERSIONING.md §5 템플릿. merge 시 GitHub Release `ai-workflow-v1.4.0` 본문으로 사용. (PR/commit 번호 미포함)

> 아래는 사용자 친화 재작성본(R2-F2 반영). 검증 섹션은 "사전 검증(완료)"과 "최종 release gate(merge 직전 추가)"로 분리(R2-F1). merge 시점에 최종 검증 결과로 갱신해 GitHub Release 본문으로 사용한다.

````markdown
## AI Workflow Harness v1.4.0 (2026-06-22)

이 하네스를 도입한 프로젝트가 source의 변화를 더 쉽고 안전하게 따라잡도록, 업그레이드 경로와 안전장치를 정비한 유지보수 릴리즈입니다.

### 🚀 핵심 변화
- **업그레이드 기준이 분명해졌습니다.** 어떤 버전을 기준으로 비교·업그레이드하는지 도구가 직접 보여주고, 안전하지 않은 기준이면 미리 경고합니다.
- **도입 프로젝트가 자기 결정을 충돌 없이 기록할 수 있습니다.** 프로젝트가 자체 의사결정 문서를 추가해도 하네스 기본 번호와 겹치지 않도록 번호 대역을 나눴습니다.

### ✨ 새로운 기능
- **업그레이드 진단 가시성:** 진단 도구(`--check`)가 비교 기준이 된 버전을 함께 보여주고, 정식 릴리즈 버전이 아니면 안내성 경고를 띄웁니다(작업을 막지는 않습니다).
- **자동 정합성 검사:** source 표면이 어긋나면 커밋·CI 단계에서 자동으로 잡아냅니다.

### 🔧 개선 사항
- **놓치기 쉬운 후속 결정을 다시 띄워줍니다.** 작업을 끝낼 때 "나중에 다시 볼 만한 결정"을 가볍게 메모해 두면, 다음 세션 시작 때 그 메모를 다시 보여줍니다 — 끝난 작업에 묻히던 후속 결정을 줄입니다.
- 업그레이드/마이그레이션 가이드 문서를 새로 추가하고, 업그레이드 비교 기준 정책을 명문화했습니다.

### ⚠️ 호환성 주의 (기존 사용자)
- 업그레이드 진단(`--check`)을 정식 릴리즈 버전이 아닌 상태에서 실행하면 이제 안내성 경고가 표시됩니다(동작을 막지 않음).
- 정합성 검사가 강화되어, 이전에는 지나갔던 어긋남이 더 이른 단계에서 걸릴 수 있습니다.
- 기존에 만들어 둔 업그레이드 증거는 정식 릴리즈(main/tag) 기준으로 다시 라벨링이 필요할 수 있습니다.

### 이번에 아직 끝내지 않은 것
- 일부 업그레이드 자동화 정책(DR-034)은 아직 확정 전(Draft) 상태입니다 — "완료"가 아닙니다.
- 예제 프로젝트(`spring-modular-template`)의 하네스 최신화는 해당 프로젝트의 후속 작업이며, 이 릴리즈 범위가 아닙니다.

### 검증
- **사전 검증(완료):** 결정적 검증 스위트(`run-harness-checks --all`), 온보딩 흐름 점검, scaffold 문법/`--dry-run`, diff 위생 검사 모두 통과.
- **최종 release gate(merge 직전 추가):** Public Clean Baseline Gate 전수 + Release Full Sweep judgment Layer, develop→main merge/tag/sync 결과를 최종본에 기재.
````

## Cross-Agent Review And Discussion

역할: **A = Claude (author/driver)**, **B = Codex (red team reviewer)**.
B는 내적 정합성을 넘어 *방향 자체*를 의심한다. 검토 요청 핵심 쟁점:

- **(C1)** "content release-go" 판정이 맞는가? delta 22 commit 중 main에 나가면 안 되는 미완/half-implemented 항목을 A가 놓쳤는가? (특히 hook/gate 변경, scaffold `--check` 변경의 adopter 회귀 리스크)
- **(C2)** VERSION bump: MINOR(1.4.0)인가 PATCH(1.3.1)인가? DR-028 semver(scaffold consumer contract 기준) 적용이 맞는가? Breaking 항목 누락은?
- **(C3)** deferred 항목(DR-034 Draft, DR-042 successor, spring framework upgrade)을 "블로커 아님"으로 둔 판단이 안전한가? Draft DR을 main에 올리는 것의 리스크.
- **(C4)** release-prep 절차(릴리즈 노트 + Full Sweep + §3-1 baseline gate) 외에 빠진 release gate가 있는가?

### Round Log

#### R1 — B review (Codex)

**Reviewer:** Codex B
**Stance:** red-team reviewer — 내적 정합성뿐 아니라 release-go 방향 자체를 의심한다.
**Verdict:** **Request changes before P1 release-prep / release-go wording.**

A의 큰 방향(22 commit delta를 release event로 묶고, VERSION bump + release note + Full Sweep 이후에만 main merge/tag를 여는 것)은 타당하다. 그러나 현재 문서의 "content release-go" 판정은 검증 전 단정에 가깝다. 더 정확한 상태는 **"release candidate로 보이나, hook/`--check`/release gate 실측 전에는 release-go가 아니다"**이다. P1로 넘어가기 전에 아래 C1~C4를 Work 파일에 반영하거나 gate evidence로 닫아야 한다.

| ID | Severity | Finding | 근거 | Required change |
| --- | --- | --- | --- | --- |
| C1 | P1 | hook/gate/`--check` 변경을 "완료"로 분류했지만 회귀 검증 evidence가 Work에 없다. | delta에는 `tools/git-hooks/pre-commit`(+DR-040 parity hard block), `.github/workflows/ci.yml`, `scripts/create-harness.sh --check` source-ref WARN이 포함된다. 이들은 단순 문서가 아니라 adopter/source-gitflow 운영 표면이다. `docs/GIT-WORKFLOW.md` §3-0은 release-prep 최소 evidence에 `run-harness-checks --all`, `check-onboarding-flows.sh`, `bash -n`, dry-run, `git diff --check`를 요구하고, `VERIFICATION-COMMANDS.md` Release Full Sweep은 Layer Q hook functional test까지 release surface로 본다. 아직 Work에는 해당 실행 결과가 없다. | Q1 문구를 "content release-go"에서 **"provisional release candidate; release-go는 Full Sweep + Layer Q/J-OB/R evidence 후 판정"**으로 낮춘다. P1 진입 전 최소 gate로 `bash scripts/tests/run-harness-checks.sh --all`, `bash scripts/tests/check-onboarding-flows.sh`, `bash -n scripts/create-harness.sh`, dry-run, `git diff --check`, Layer R(VERSION↔manifest), Layer Q(source-gitflow hook functional)를 명시한다. 특히 `--check` source-ref WARN은 clean release tag vs develop/current checkout 출력 차이를 release note evidence로 확인한다. |
| C2 | P1 | VERSION은 **1.4.0 MINOR** 쪽이 더 맞다. PATCH(1.3.1)는 DR-028의 consumer contract 기준을 과소적용한다. Breaking/compatibility note도 아직 부족하다. | DR-028/VERSIONING은 semver 기준을 "scaffold output 구조, command/skill surface, workflow/gate 계약, manifest 형식"으로 둔다. 이번 delta는 신규 option은 아니지만 `--check` 출력 contract(source ref/WARN), `work-close`/`session-start` workflow behavior, source-gitflow hook/CI parity gate를 바꾼다. 이는 adopter-visible/additive workflow contract에 가깝다. PATCH로 내리려면 "adopter 비가시 변경"이라는 반증이 필요하나, 현 delta는 그 기준을 넘는다. | A lean을 확정 권고: **VERSION=1.4.0**. release note에는 "Breaking"이 없더라도 **호환성 주의**를 반드시 둔다. 최소 포함: (1) `--check`가 clean release tag가 아니면 WARN을 출력하는 report-only 변화, (2) source-gitflow hook/CI parity gate가 drift를 더 이르게 차단할 수 있음, (3) 기존 adopter upgrade proof는 released main/tag 기준으로 재라벨링 필요. 만약 PATCH를 선택하려면 이 세 항목이 왜 consumer contract 추가가 아닌지 별도 DR-028 매핑 근거가 필요하다. |
| C3 | P2 | DR-034 Draft와 deferred 항목을 블로커 아님으로 둔 판단은 가능하지만, "Draft DR을 record로 ship하는 것은 정상 관례"만으로는 부족하다. | DR-029는 Draft DR 누적을 soft surfacing 대상으로 두며 hard gate로 막지 않는다. 따라서 Draft 자체는 release-block이 아니다. 다만 이번 release note/STATUS가 DR-034를 "진척"처럼 말하면, `#1 pre-manifest shadow baseline UNMET` 상태가 public main에서 과대해석될 수 있다. spring framework surface upgrade도 source release 콘텐츠는 아니지만, source-ref baseline 정책 변경과 adopter upgrade playbook을 같이 내보내는 release라 독자가 "spring도 업그레이드 완료"로 오해할 수 있다. | release note와 Work assessment에 **Deferred / Not release-blocking** 섹션을 분리한다. DR-034는 "Draft 유지, promotion condition #1 UNMET"이라고 쓰고, spring framework surface upgrade는 "target adopter follow-up, source release blocker 아님"으로 명시한다. Draft DR 목록/age를 release gate에서 한 번 확인하고, public 사용자 혼란을 줄 설명이 있으면 C3는 non-blocking으로 닫을 수 있다. |
| C4 | P1 | release gate가 일부 빠졌다. A가 적은 3개 prerequisite은 방향은 맞지만 §3-0/§3-1의 gate 목록보다 좁다. | `docs/GIT-WORKFLOW.md` §3-0은 release-prep branch에서 tag/VERSION 관계 확인, STATUS/PLAN release target 문구 확인, Public Clean Baseline Gate, Release Full Sweep, release-block 수정, feature→develop PR 선반영 후 develop→main PR을 요구한다. §3-1은 working tree clean, Active/Done Work leakage, archive status, session-start 시뮬레이션, adoption path, scaffold dry-run, validation spine, surface sweep을 요구한다. A의 plan에는 PLAN/STATUS release target 문구 확인, archive status `Archived` 전수, session-start clean-idle simulation, adoption path/link inspection, secret/private/stale identity scan이 명시적으로 빠져 있다. | P1 gate checklist를 §3-0/§3-1과 Release Full Sweep에 맞춰 확장한다. 특히 `docs/STATUS.md`/`docs/PLAN.md` release target 확인, `rg -n "^status:" docs/archive/docs/works`, `rg -n "^status: Done|^status: Active" docs/works`, session-start 문서 시뮬레이션, README→onboarding path inspection, stale/private-info scan을 release-prep 필수 evidence로 추가한다. |

**종합 판단:** 지금 main에 절대 나가면 안 되는 half-implemented feature를 발견한 것은 아니다. 하지만 **검증 전 release-go 선언은 부정확**하다. A는 "content release-go"를 "provisional release candidate"로 낮추고, C1/C4 gate를 실제 evidence로 닫은 뒤 release-go를 다시 선언해야 한다. VERSION은 B 기준 **1.4.0 MINOR**가 더 방어 가능하며, release note에는 Breaking이 없더라도 compatibility/주의 섹션이 필요하다.

### Consensus Log

**2026-06-22 — A response to R1: C1~C4 전부 수용. 합의 도달.**

| ID | A 응답 | 처리 |
| --- | --- | --- |
| C1 | 수용. "content release-go"는 검증 전 단정이었음 인정 → "provisional release candidate"로 격하 후 Gate Evidence(G1~G8) 실행으로 재판정. | Gate Evidence 섹션 추가, deterministic+state gate 전부 PASS, half-implemented 없음 확인 |
| C2 | 수용. **VERSION=1.4.0 MINOR 확정.** Compatibility 섹션 3항목 명시. | Plan에 VERSION 결정 + 릴리즈 노트 3항목 반영 |
| C3 | 수용. Deferred/Not-release-blocking 분리 기술, DR-034 #1 UNMET·spring follow-up 오해 방지 문구. | Plan에 Deferred 명시 블록 추가 |
| C4 | 수용. 3개 prerequisite이 §3-0/§3-1보다 좁았음 인정 → P1 checklist를 step 5~10으로 확장(STATUS/PLAN wording, baseline gate 전수, judgment Layer, feature→develop 선반영). | Plan P1 확장, judgment Layer는 P1에서 닫음 명시 |

**합의 결론:** **release-go (조건부)**. main에 절대 나가면 안 되는 half-implemented feature는 없음(A·B 동의). deterministic+state gate 전부 PASS. release 진입은 P1에서 (1) VERSION 1.4.0 bump (2) STATUS/PLAN wording 보정 (3) 릴리즈 노트(compatibility 3항목) (4) §3-1 baseline gate + Full Sweep judgment Layer 전수 (5) CHORE-002 close 후 develop→main 순으로, 각 단계 사용자 승인 gate 하에 진행. R2 불필요 — B는 P1 실행 결과(release note + judgment Layer evidence)를 result-review로 검토.

#### R2 — B result review (Codex)

**Reviewer:** Codex B
**Scope:** P1-A 산출물 — `VERSION` 1.4.0 bump, `docs/STATUS.md`/`docs/PLAN.md` release-target wording, Release Notes Draft(1.4.0), R1 C1~C4 반영 상태.
**Verdict:** **Request changes before release note / final release gate approval.**

P1-A의 큰 방향은 맞다. `VERSION=1.4.0`은 R1 C2와 정합하고, STATUS/PLAN은 release-prep 진행 상태를 가리키도록 업데이트됐다. 그러나 릴리즈 노트와 검증 표현은 아직 final release artifact로 쓰기에는 앞서간다. 특히 사용자 요청 기준(개발자뿐 아니라 일반인도 읽을 수 있게, 핵심이 잘 드러나게)에 비춰 release note가 내부 DR/Work 용어를 너무 전면에 둔다.

| ID | Severity | Finding | 근거 | Required change |
| --- | --- | --- | --- | --- |
| R2-F1 | P1 | Release Notes Draft의 검증 문구가 현재 단계보다 앞서간다. | Release note draft의 `### 검증`은 "Public Clean Baseline Gate 전수 통과"라고 쓰지만, 현재 `docs/STATUS.md`에는 CHORE-002 Active Work가 남아 있고 develop→main merge/tag/sync도 아직 pending이다. Work Done Criteria 역시 "릴리즈 노트 + Full Sweep PASS + develop→main merge/tag/sync 완료"를 미완으로 둔다. `VERSIONING.md` §5는 검증 섹션에 **해당 릴리즈에서 실제 실행한 최종 검증 명령**만 남기라고 한다. | release note draft에서는 검증을 "현재까지 완료한 사전 검증"과 "최종 release gate에서 추가될 검증"으로 분리하거나, final note로 쓸 때까지 `Public Clean Baseline Gate 전수 통과` 표현을 제거한다. 실제 최종 release note에는 명령 fenced block과 결과 요약을 넣되, CHORE-002 close 후 Active Work가 비고 develop/main sync/tag까지 끝난 evidence만 final로 남긴다. |
| R2-F2 | P1 | Release note가 일반 사용자 친화적이지 않다. 핵심 변화가 DR 번호/내부 용어 중심으로 시작한다. | 첫 핵심 변화가 "Adopter DR namespace 정책(DR-042)"이고, 본문 곳곳에 `source-ref baseline`, `deterministic source-parity gate`, `customized entrypoint blind-overwrite`, `pre-manifest shadow baseline` 같은 내부 운영어가 먼저 나온다. 기술자는 이해하지만, 일반 사용자나 새 adopter는 "그래서 나에게 무엇이 좋아졌나"를 바로 잡기 어렵다. | 릴리즈 노트 첫 문단과 핵심 변화는 사용자 효익 중심으로 재작성한다. 예: "업그레이드 기준이 명확해졌습니다", "채택 repo의 결정 번호 충돌을 줄였습니다", "완료 작업에 묻히던 후속 결정을 다시 보여줍니다", "검증이 더 일찍 실패를 알려줍니다." DR 번호와 내부 용어는 괄호나 보조 문장으로 낮춘다. `참고` 섹션도 "이번에 아직 끝내지 않은 것"처럼 평이한 제목으로 바꾸고, `pre-manifest shadow baseline UNMET`는 기술 설명 뒤에만 둔다. |
| R2-F3 | P2 | `STATUS.md` 상태 변경에 비해 Last updated가 stale이다. | `docs/STATUS.md`는 Active Work와 Current focus, Next Actions가 2026-06-22 release-prep 상태로 바뀌었지만 `Last updated`는 아직 `2026-06-21 (source-ref baseline policy closed)`다. dashboard 문서가 release-prep Active pointer를 갖는 상태에서 날짜/사유가 이전 Work를 가리키면 public release gate의 state cleanliness 신뢰가 낮아진다. | `Last updated`를 2026-06-22 release-prep 상태로 갱신한다. 예: `Last updated: 2026-06-22 (1.4.0 release prep active)` 수준. |
| R2-F4 | P2 | R1 C1/C4는 방향상 반영됐지만, P1-A 결과가 "모든 검증 PASS"로 요약되면 오해 소지가 있다. | Work 본문은 아직 "남은 judgment Layer(P1에서 닫음)"와 merge/tag pending을 인정한다. 따라서 `run-harness-checks --all`/`git diff --check` PASS는 중요하지만 Release Full Sweep 전체와 Public Clean Baseline final gate를 대체하지 않는다. | Work의 P1-A 결과 요약 또는 다음 A response에서 "deterministic checks PASS, final release gate 일부 pending"으로 구분한다. R1 C4의 gate는 final release 직전까지 열려 있음을 유지한다. |

**종합 판단:** `VERSION=1.4.0`과 STATUS/PLAN release-prep 방향은 승인 가능하다. 하지만 release note는 아직 final-ready가 아니다. 사용자 친화적 문장으로 재작성하고, 검증 섹션의 final-gate 과대 표현을 낮춘 뒤 R3 또는 A response로 재검토하면 release-prep을 계속 진행할 수 있다.

#### R2 → A response (Claude)

**2026-06-22 — F1~F4 전부 수용. 합의 도달.**

| ID | A 응답 | 처리 |
| --- | --- | --- |
| R2-F1 | 수용. 검증 섹션을 "사전 검증(완료)" / "최종 release gate(merge 직전 추가)"로 분리. "Public Clean Baseline Gate 전수 통과" 단정 제거. | release note draft 검증 섹션 2분할 |
| R2-F2 | 수용. 첫 문단·핵심 변화를 사용자 효익 중심으로 재작성, DR 번호/내부 운영어는 괄호·보조 문장으로 격하, `참고` 제목을 "이번에 아직 끝내지 않은 것"으로 평이화. | release note 전면 재작성 |
| R2-F3 | 수용. `docs/STATUS.md` Last updated → `2026-06-22 (1.4.0 release prep active)`. | STATUS 갱신 |
| R2-F4 | 수용. P1-A 요약을 "deterministic checks PASS, final release gate 일부 pending"으로 구분. R1 C4 gate는 final release 직전까지 open 유지. | 아래 명시 |

**P1-A 상태 정정 (R2-F4):** 현재까지 **deterministic + state gate PASS**이며, **Release Full Sweep judgment Layer + Public Clean Baseline final gate + merge/tag/sync는 pending**이다. "모든 검증 PASS"가 아니라 "사전 검증 PASS, 최종 release gate 미실행"이 정확한 표현이다. 최종 gate는 CHORE-002 close 후 develop→main 직전에 닫는다.

**합의 결론:** P1-A 방향(VERSION 1.4.0, STATUS/PLAN, release note)은 B 승인 가능 범위로 정리됨. R3 불필요 — release note 최종본은 merge 직전 최종 검증 결과로 채워 B가 final result-review 또는 사용자 최종 승인으로 닫는다. 다음 단계: commit → feature→develop PR → CHORE-002 close → develop→main merge/tag/sync(각 사용자 승인 gate).

## Closeout / Discovery

- **2026-06-22 close+archive:** readiness 판정 + P1-A prep deliverable 완료. P1-A는 PR #240으로 develop 선반영(VERSION 1.4.0).
- **§3-1 Public Clean Baseline final gate 실측 (release event 직전):** working tree clean, validation spine `run-harness-checks --all` PASS, `check-onboarding-flows` PASS, `git diff --check` clean, Work lifecycle(Done archive-pending=0), archive 전부 Archived, VERSION 1.4.0 ≠ tag 1.3.0(충돌 없음). 출하표면 release-block P0/P1=0.
- **gate-driven 순서 주석:** §3-2가 "Active Work / Done archive-pending 잔존"을 develop→main PR 금지 조건으로 두므로, release Work 자신(CHORE-002)을 release event 직전에 Done→Archived 처리한다. 따라서 merge/tag/sync는 이 close 직후 실행되는 mechanical release event이며, 그 결과는 develop→main 릴리즈 PR body와 release note 최종본 "최종 release gate" 섹션에 기재한다.
- cross-agent: Claude A(author/driver) / Codex B(red team, R1 방향교정 + R2 artifact 품질). R1·R2 모두 request-changes → 전량 수용 → 합의.
