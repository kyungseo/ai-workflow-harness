---
id: CHORE-20260621-006
priority: P1
status: Archived
risk: L2
scope: adopter upgrade/apply evidence의 source baseline 기준을 released main/tag 기본값으로 명시하고, develop/current checkout 예외 라벨 및 --check source-ref visibility를 보강한다.
appetite: 1d
planned_start: 2026-06-21
planned_end: 2026-06-21
actual_end: 2026-06-21
related_dr: [DR-028, DR-034]
related_troubleshooting: []
related_work: [CHORE-20260621-002, CHORE-20260621-003, CHORE-20260621-004, CHORE-20260621-005]
---

# CHORE-20260621-006: Upgrade Baseline Source-Ref Policy And Check Visibility

## Top Summary

이번 Work는 adopter upgrade/apply evidence가 어떤 source ref를 기준으로 측정됐는지 명확히 남기도록 정책과 도구 표면을 보강한다. 기본 baseline은 released `main` 또는 release tag로 두고, `develop`/current checkout 기준 probe는 의도적 예외 라벨을 필수로 한다.

시발점은 `spring-modular-template` walkthrough에서 드러난 blind spot이다. `VERSION` 문자열이 같아도 `main`과 `develop`은 다를 수 있고, `scripts/create-harness.sh --check`는 현재 source checkout을 비교하므로 operator가 어느 ref에 서 있는지에 따라 drift evidence가 달라진다.

R1 이후 권장 방향은 DR-028 amendment다. source-ref baseline은 ownership보다 release-line/versioning 문제이고, DR-028이 이미 "git release tag line = version SSoT"를 채택했기 때문이다. DR-034에는 manifest baseline과 source-ref baseline을 혼동하지 않도록 cross-pointer만 남긴다.

역할은 Codex A = author/driver, Claude B = red-team reviewer다. Claude B는 내적 정합성을 넘어 "released upgrade proof와 develop tracking evidence를 같은 말로 취급해도 되는가"를 의심하는 관점으로 검토한다.

## Collaboration Workflow

```text
사용자 지시
-> Codex A가 Work file + plan 작성
-> Claude B red-team review (R round, 필요시 반복)
-> 합의
-> Codex A가 DR/docs/script/test 구현
-> Claude B result review
-> 사용자 최종 승인
-> /work-close
-> commit
-> PR --base develop
-> merge
```

## Context Manifest

| 순서 | 파일 | 섹션 | 왜 |
| --- | --- | --- | --- |
| 1 | `docs/backlog/HARNESS.md` | `Upgrade baseline source-ref policy and --check ref visibility` | 직접 trigger와 scope |
| 2 | `docs/works/harness/CHORE-20260621-005-spring-adopter-upgrade-walkthrough.md` | Top Summary, Discovery, Cross-Agent Review | develop/current checkout 라벨 blind spot이 나온 근거 |
| 3 | `docs/decisions/DR-034-harness-upgrade-ownership-policy.md` | Draft Decision, Consequences | upgrade baseline/ownership policy의 현재 SSoT |
| 4 | `docs/decisions/DR-028-versioning-policy.md` | Decision | release tag line과 `VERSION` mirror 관계 |
| 5 | `docs/maintainer/ADOPTER-UPGRADE-MIGRATION-PLAYBOOK.md` | Phase 1-2 | target probe와 baseline 선택 절차 |
| 6 | `docs/maintainer/VERIFICATION-COMMANDS.md` | Layer D, Layer T | `--check`와 migration walkthrough 명령 카탈로그 |
| 7 | `scripts/create-harness.sh` | `do_check()` | 현재 source checkout 기준 drift 계산과 출력 표면 |
| 8 | `scripts/tests/check-scaffold-invariants.sh`, `scripts/tests/check-onboarding-flows.sh` | `--check` summary 소비부 | source-ref 출력 추가가 기존 grep을 깨지 않는지 확인 |

Trigger: user selected follow-up `1` after CHORE-20260621-005 closeout/merge: source-ref baseline policy first.

## Plan

### Slice A — Plan And Review Gate

- Work file과 Active index를 생성한다.
- `docs/STATUS.md` Active Work pointer는 별도 승인 없이는 수정하지 않는다.
- Claude B R1 red-team review를 요청한다.
- R1 finding이 있으면 Codex A response와 Consensus Log를 같은 Work 파일에 누적한다.

### Slice B — Policy Decision

결정할 정책 문장:

- adopter upgrade/apply evidence의 기본 source baseline은 released `main` 또는 release tag다.
- `develop`/current checkout 기준 probe는 internal dogfooding 또는 pre-release tracking으로 허용하되, evidence label에 source ref와 예외 사유를 명시한다.
- `VERSION` 문자열만으로 source baseline parity를 주장하지 않는다. `git describe`/branch/HEAD sha가 함께 기록되어야 한다.

권장 기록 위치:

| Option | 판단 |
| --- | --- |
| DR-028 amendment | 권장. source-ref baseline은 versioning/release-line 문제이고 DR-028이 tag-line SSoT |
| 신규 소형 DR | DR-028 amendment가 너무 넓어질 때만. 이 경우 DR-028을 version SSoT로 cite |
| DR-034 amendment | 비권장. DR-034의 baseline은 manifest baseline이라 source-ref baseline과 용어 충돌 |
| 문서만 수정 | 비권장. 다음 adopter에서 같은 drift ambiguity가 반복될 수 있음 |

### Slice C — Maintainer Docs Cascade

- `docs/maintainer/ADOPTER-UPGRADE-MIGRATION-PLAYBOOK.md` Phase 1/2에 source baseline 기록 checklist를 추가한다.
- `docs/maintainer/VERIFICATION-COMMANDS.md` Layer T에 released baseline 기본값과 develop exception label을 추가한다.
- 필요하면 `docs/maintainer/VERSIONING.md` 또는 DR-028 문구와 충돌하지 않는지 확인만 한다. release policy 자체는 바꾸지 않는다.

### Slice D — `--check` Source-Ref Visibility

- `scripts/create-harness.sh --check <target>` 출력에 source ref line을 추가한다.
- 우선 후보 출력:

```text
source ref       : <branch-or-detached> @ <short-sha> (<git describe --tags --always --dirty>)
```

- `git describe` 결과가 clean release tag가 아니면 한 줄 WARN을 추가한다. 예: tag 이후 commit(`-g<sha>`), dirty checkout(`-dirty`), 또는 tag 형식이 아닌 raw sha.
- WARN은 "released-tag baseline이 아니다"까지만 말한다. dirty가 framework 파일 때문인지 Work/index 파일 때문인지는 `--check`가 알 수 없으므로 framework drift로 과해석하지 않는다.
- git metadata가 없는 source snapshot에서도 스크립트가 실패하지 않도록 `unknown`으로 degrade한다.
- 기존 tests가 `summary:` line만 grep하므로 출력 추가가 소비부를 깨지 않는지 확인한다.

### Slice E — Validation And Closeout

- 문서/스크립트 변경 후 syntax와 whitespace를 확인한다.
- fresh scaffold 또는 기존 temp target에 대해 `--check` 출력이 source ref를 포함하고 summary 소비가 유지되는지 확인한다.
- source 정책 DR을 수정하면 shipped DR closure 검사를 실행한다.
- Claude B result review와 사용자 최종 승인 후 `/work-close`로 Done 처리한다.

## Done Criteria

- [x] Claude B R1 red-team review가 Cross-Agent Review에 기록된다.
- [x] DR-028 amendment vs 신규 DR 판단이 근거와 함께 기록된다.
- [x] released `main`/tag 기본 baseline과 `develop`/current checkout 예외 라벨 규칙이 정책 문서에 반영된다.
- [x] playbook probe checklist가 source branch/ref/HEAD/tag 또는 `git describe` 기록을 요구한다.
- [x] `scripts/create-harness.sh --check` 출력이 비교한 source ref를 report-only로 표시한다.
- [x] clean release tag가 아닌 source checkout에서 `--check`가 released-tag baseline이 아니라는 WARN을 출력한다.
- [x] source ref 출력 추가가 pre-manifest exit 3, invalid manifest exit 2, normal summary 출력 흐름을 깨지 않는다.
- [x] 관련 verification 문서가 새 출력/정책과 모순되지 않는다.
- [x] validation 결과가 기록된다.
- [x] Claude B result review와 사용자 최종 승인이 기록된다.

## Verification

Planning/file setup:

```bash
git diff --check
```

Script checks:

```bash
bash -n scripts/create-harness.sh
bash scripts/create-harness.sh --check temp/harness-tests/manual-ob-generic || true
```

Targeted test guards:

```bash
bash scripts/tests/check-scaffold-invariants.sh temp/harness-tests/manual-ob-generic
bash scripts/tests/check-onboarding-flows.sh
```

Policy/DR closure:

```bash
bash scripts/tests/check-shipped-dr-closure.sh
git diff --check
```

검증 대상 temp scaffold가 없으면, 생성형 테스트 전용 temp target을 새로 만들거나 `scripts/tests/run-harness-checks.sh --tier2`로 대체한다. 단, adopter target repo에는 이 Work에서 write하지 않는다.

## Risk

| Risk | Likelihood | Impact | Mitigation |
| --- | --- | --- | --- |
| released upgrade proof와 develop tracking evidence를 계속 혼용 | Medium | High | DR-028/playbook/Layer T에 source-ref label 필수화 |
| DR을 새로 만들어 정책 표면을 과분산 | Medium | Medium | 기본은 DR-028 amendment, DR-034에는 cross-pointer만 |
| `--check` 출력 변경으로 기존 grep 소비부가 깨짐 | Low | Medium | `summary:` line 유지, targeted scripts 실행 |
| git metadata 없는 packaged source에서 `--check` 실패 | Low | Medium | source ref helper는 `unknown` degrade |
| 이 Work가 full upgrade/apply automation으로 커짐 | Medium | Medium | `--check` visibility와 docs policy만 범위 |

Reversal cost: 문서 정책은 Medium(DR-028/Layer T가 후속 adopter 판단의 기준이 됨), `--check` 출력 추가는 Low(summary line 유지 시 되돌리기 쉬움).

## Checkpoints

| CP | Description | Status |
| --- | --- | --- |
| CP1 | Work file + plan 작성 | Done |
| CP2 | Claude B red-team review 합의 | Done — R1 F1/F2/F3 accepted |
| CP3 | Policy/docs/script 구현 | Done |
| CP4 | Validation | Done |
| CP5 | Claude B result review + 사용자 승인 | Done |
| CP6 | Work close / commit / PR / merge | Pending |

## Next Actions

- ✓ Branch isolation: `feature/upgrade-baseline-source-ref-policy`
- ✓ Work file + plan 작성
- ✓ Claude B R1 red-team review 요청
- ✓ R1 request changes 수용 및 계획 반영
- ✓ DR-028/docs/script 구현
- ✓ Validation
- ✓ Claude B result review 요청
- ✓ Codex A RR response 기록
- ✓ 사용자 최종 승인
- → Work close finalization

## Implementation Result

| Surface | Change |
| --- | --- |
| `docs/decisions/DR-028-versioning-policy.md` | Accepted (Amended 2026-06-21). upgrade/apply evidence source-ref baseline은 released `main`/release tag 기본, develop/current checkout은 명시 예외 라벨로 기록 |
| `docs/decisions/DR-034-harness-upgrade-ownership-policy.md` | DR-034의 baseline은 target manifest/shadow scaffold baseline이고, source-ref baseline은 DR-028 소관이라고 경계 추가 |
| `docs/maintainer/ADOPTER-UPGRADE-MIGRATION-PLAYBOOK.md` | Phase 1/2에 source branch, HEAD, `git describe`, `VERSION`, source baseline label 기록 추가 |
| `docs/maintainer/VERIFICATION-COMMANDS.md` | Layer T에 source-ref baseline 기본값과 `develop`/current checkout 예외 라벨 추가 |
| `scripts/create-harness.sh` | `--check` header에 source ref 출력 추가. clean release tag가 아니면 report-only WARN 출력. invalid manifest field extraction은 `set -euo pipefail`에서 명시 exit 2로 degrade |

## Verification Result

| Command | Result |
| --- | --- |
| `bash -n scripts/create-harness.sh` | PASS |
| `scripts/create-harness.sh --check temp/source-ref-check-006` | PASS: source ref + WARN 출력, `summary: 78 tracked, 78 in-sync, 0 drifted` 유지 |
| `scripts/create-harness.sh --check temp/source-ref-premanifest-006` | PASS: exit 3, source ref + WARN 출력 후 pre-manifest migration note |
| `scripts/create-harness.sh --check temp/source-ref-invalid-006` | PASS: exit 2, source ref + WARN 출력 후 invalid manifest error |
| `bash scripts/tests/check-scaffold-invariants.sh temp/source-ref-check-006` | PASS |
| `bash scripts/tests/check-onboarding-flows.sh` | PASS |
| `bash scripts/tests/check-shipped-dr-closure.sh` | PASS |
| `git diff --check` | PASS |

## Cross-Agent Review

### R1 Review Result — Claude B

Status: **Request changes** — 정책 premise와 도구 방향은 타당하나, **DR placement가 본령(DR-034)이 아닐 가능성이 크고(F1)**, visibility-only가 정책을 강제하지 못하는 honor-system gap(F2)이 남는다. read-only diligence로 tag/DR-028/`--check`만 확인했고 구현은 합의 후 Codex A 몫.

검증으로 확인한 사실:
- tag discipline 실재: 15 tags, `main`=`ai-workflow-v1.3.0`(`39807ec`), `git describe --tags --always --dirty` = `ai-workflow-v1.3.0-18-g99a3d17-dirty`(현재 feature branch, 미commit Work 파일 때문에 ahead/dirty), `main`은 `ai-workflow-v1.3.0` clean. → "released main/tag baseline"은 실존·정의된 기준.
- DR-028(Accepted)이 versioning SSoT: #1 "버전 SSoT = release tag line", #2 "develop `VERSION` = 다음 in-development 릴리즈 값", Consequences "upgrade 메커니즘 구현 시 semver 기준에 upgrade 호환성 편입 예고".

**F1 (Material — DR placement. DR-034가 아니라 DR-028이 본령일 가능성).**
이 Work가 박으려는 정책의 본질은 "adopter upgrade drift를 잴 때 어느 source 버전을 기준으로 보느냐"다. 이는 ownership(framework vs project)이 아니라 **versioning/release-line** 문제이고, 그 SSoT는 이미 DR-028이다.
- "VERSION 문자열 parity ≠ release parity"는 새 통찰이 아니라 **DR-028 #2의 직접 귀결**이다(develop VERSION은 의도적으로 "다음" 값). 이 Work는 그 원칙을 `--check`/upgrade evidence 맥락에 적용하는 것.
- DR-028 Consequences가 이미 "upgrade 메커니즘 구현 시 upgrade 호환성을 semver 기준에 편입(백로그에서 재확인)"을 예고 → 이 Work가 바로 그 재확인 지점. DR-028 쪽이 자연스러운 귀속.
- **용어 충돌 위험:** DR-034에서 "baseline"은 *manifest baseline*(adopter에 shipped된 snapshot)을 뜻하고, 이 Work의 "baseline"은 *source-ref baseline*(source 쪽 비교 버전)을 뜻한다. **같은 단어 다른 의미** — DR-034 한 문서에 우겨넣으면 promotion 조건까지 흐려진다.
→ **요구:** Slice B placement 표를 ownership(DR-034) 축이 아니라 versioning(DR-028) 축으로 다시 판단한다. 권장 후보: **(a) DR-028 amendment**, 또는 **(b) DR-028을 version-SSoT로 cite하는 신규 소형 DR**. DR-034에는 cross-pointer만 남긴다. (DR-028이 Accepted라 amend가 Draft보다 무겁다는 건 절차 비용일 뿐, 개념적 home을 바꿀 이유는 아니다.)

**F2 (Concrete — visibility-only는 honor-system gap. cheap WARN으로 닫을 수 있다).**
`--check`는 여전히 `TEMPLATE_ROOT`=current checkout을 hash한다. 즉 "main 기준" 정책은 **operator의 checkout discipline에 의존**하고, Slice D는 ref를 *보여줄* 뿐 *강제*하지 않는다. operator가 develop에서 돌리면 출력은 정직히 develop이라 적지만, 아무도 그 줄을 안 보면 같은 blind spot이 재발한다 — 그게 정확히 CHORE-005에서 실제로 일어난 일이다.
→ **요구(저비용):** `git describe --tags --always --dirty` 결과에 `-g<sha>`(tag 이후 commit) 또는 `-dirty`가 있으면 "이 `--check`는 released-tag baseline이 아니다(ahead/dirty)"라는 **한 줄 WARN**을 추가한다. read-only check라 실제 risk는 evidence mislabel뿐이므로, full ref-resolution(checkout/stash 후 비교)까지는 과하다 — WARN이 비용 대비 적정하고, Risk 표의 "full automation으로 커짐" 경계 안에 든다. WARN을 Slice D "visibility"의 명시 일부로 둔다.

**F3 (Minor — dirty 과해석 금지).**
현재 describe가 `-dirty`인 건 framework 변경이 아니라 미commit Work 파일 때문이다. `--check`의 dirty는 framework 파일 변경인지 Work/문서 변경인지 구분 못 한다. 따라서 WARN 문구는 "source checkout이 released tag가 아님(ahead/dirty)" 수준으로만 두고, "framework drift 있음"으로 과해석하지 않는다.

**Affirm.**
- 정책 premise(baseline = released main/tag): tag discipline 실재로 operationally grounded.
- Slice D `unknown` degrade(git metadata 없는 packaged source), `summary:` line 보존 + targeted test guard: 적절.
- "문서-only 비권장"(placement 표): 동의(반복 ambiguity 방지). 단 F1 때문에 "DR-034 amendment 권장" 부분만 재판단 필요.
- shipped-DR-closure: 정책 DR을 어디 두든 maintainer 문서(playbook/VERIFICATION-COMMANDS)는 source-only라 closure 면제 — Slice E의 closure 실행은 유지.

요약: 방향 유지. (a) DR placement를 DR-028 축으로 재판단(F1), (b) `--check`에 ahead/dirty WARN 추가(F2) 두 가지가 합의 조건. F3는 WARN 문구 가드, 나머지 affirm.

### R1 A Response — Codex A

Accepted.

- **F1 수용:** DR-034가 아니라 DR-028을 본령으로 삼는다. 이번 문제는 framework/project ownership보다 source release-line 기준 문제이며, DR-028의 "git release tag line = version SSoT"와 `develop VERSION = in-development mirror`의 직접 귀결이다. DR-034에는 manifest baseline과 source-ref baseline을 혼동하지 않도록 cross-pointer만 둔다.
- **F2 수용:** `--check`는 source ref를 보여주는 데서 멈추지 않고, clean release tag가 아니면 WARN을 낸다. 다만 checkout을 자동으로 바꾸거나 main/tag를 강제하지는 않는다.
- **F3 수용:** dirty WARN은 evidence label 경고로만 둔다. Work 파일 변경 때문에 dirty일 수 있으므로 "framework drift"라고 쓰지 않는다.

Plan 반영: Slice B의 placement 표를 DR-028 중심으로 수정했고, Slice D에 clean release tag WARN과 dirty 과해석 금지를 추가했다.

### Result Review (CP5) — Claude B

Status: **Approve** — R1 F1/F2/F3가 모두 구현에 충실히 반영됐고, script 동작을 live로 확인했다. 미해결 blocker 없음. 비차단 minor 관찰 2건만 남긴다.

구현 검증(실제 파일 + live):
- **F1 (DR placement) 해소.** DR-028 Status `Accepted (Amended 2026-06-21)` + Decision #6(source-ref baseline = released main/tag 기본, develop 예외 라벨) + Rationale/Consequences/Amendment History. DR-034 L18에 "이 문서의 baseline은 manifest/shadow scaffold baseline, source-ref는 DR-028 소관"이라는 cross-pointer 추가 → 내가 지적한 "baseline" 용어 충돌이 정확히 disambiguate됨.
- **F2 (WARN) 구현.** `print_source_ref_report`가 `source ref : <branch> @ <sha> (<git describe --tags --always --dirty>)` 출력 후, `is_clean_release_desc`(regex `^ai-workflow-v[0-9]+\.[0-9]+\.[0-9]+$`) 불일치 시 WARN. live(`temp/source-ref-check-006`, 현재 feature branch ahead+dirty)에서 WARN 정확 발화 + `summary` 보존 확인.
- **F3 (과해석 가드) 반영.** WARN 문구는 "not a clean release tag; ... pre-release/current-checkout evidence, not released upgrade proof"까지만 — framework drift라고 말하지 않음.
- **degrade/exit 정합.** non-git source tree → `unknown` degrade(WARN 미발화). invalid manifest는 `field ... || true`로 pipefail abort를 막고 명시 `return 2`. source ref/WARN은 normal·pre-manifest(exit 3)·invalid(exit 2) 세 경로 모두 header에서 먼저 출력되며 exit code/summary 소비부 영향 없음(invariants/onboarding/closure/diff-check PASS).
- **canonical 케이스 정확.** adopter가 release tag를 detached checkout(`git checkout ai-workflow-v1.3.0`)하면 branch는 `detached`로 표시되지만 desc=exact tag → WARN 미발화. 권장 released-baseline 동작을 올바르게 통과시킨다.

**RR-1 (Minor, non-blocking — tool이 정책 문구보다 strict).**
`is_clean_release_desc`는 **정확 tag만** clean으로 본다. DR-028 #6 문구는 "released `main` 또는 release tag"라 `main` 자체를 baseline으로 허용하는 듯 읽히지만, develop→main merge 후 tag를 끊기 전 짧은 구간에서 `main`은 tag보다 ahead라 WARN이 뜬다. DR-028 #1(tag line = version SSoT)과 tag-on-merge flow를 보면 이는 오히려 **정합**(tag 안 끊긴 main은 아직 released 아님)이고 report-only라 안전하다. 다만 #6 wording이 tool보다 느슨하므로, 원하면 DR-028에 "'released main' = release tag와 일치하는 main" 한 줄을 다는 게 깔끔하다. 선택 사항.

**RR-2 (Minor, non-blocking — unknown degrade 경로 미검증).**
git work tree가 아닌 packaged source에서의 `unknown` degrade는 코드상 `rev-parse --is-inside-work-tree` 가드로 안전하나 verification에 실측 케이스가 없다. 구성 비용이 크고 risk가 낮아 close 차단 사유는 아니다. 후속에 packaged-source 시나리오를 한 번 태우면 완결.

**Affirm.** 정책 premise, 도구 동작, DR 귀속, 문서 cascade(playbook Phase 1/2 + VERIFICATION Layer T), test guard 모두 건전. Done Criteria 9개 중 8개 충족, 마지막(result review + 사용자 승인)은 이 review + owner sign-off로 닫힌다.

권고: **이대로 close 가능.** RR-1/RR-2는 선택적 보완이며 별도 후속으로 빼도 무방.

### Result Review A Response — Codex A

Accepted.

- **RR-1:** 비차단 관찰로 수용한다. 현재 tool이 "clean release tag"를 기준으로 WARN을 판단하는 것은 DR-028의 tag-line SSoT와 정합적이다. "released main" 표현이 반복적으로 오독되면 DR-028에 "released main = release tag와 일치하는 main" 한 줄을 후속 보강한다. 이번 approved result 이후에는 추가 churn을 만들지 않는다.
- **RR-2:** 비차단 관찰로 수용한다. non-git packaged source `unknown` degrade는 코드상 안전 가드가 있으나 실측 fixture는 없다. packaged-source 배포 검증이 생기면 후속 test case로 추가한다.

판단: 미해결 blocker 없음. 사용자 최종 승인 후 `/work-close` 가능.

### Round Log

| Round | Reviewer | Result | Notes |
| --- | --- | --- | --- |
| R1 | Claude B | Request changes | F1 DR placement는 DR-034(ownership) 아니라 DR-028(versioning) 본령 — "baseline" 용어 충돌, DR-028이 이미 tag-line SSoT+upgrade feedback 예고. F2 visibility-only honor-system gap → ahead/dirty WARN 추가. F3 dirty 과해석 가드. premise/degrade/test-guard affirm |
| R1-A | Codex A | Accepted | F1/F2/F3 전부 수용. DR-028 amendment 중심, DR-034 cross-pointer, WARN+dirty 가드 반영 |
| RR | Claude B | Approve | 구현이 F1/F2/F3 충실 반영, live 검증 완료. RR-1(tool이 정책 문구보다 strict, 정합·선택보완) RR-2(unknown degrade 미실측) 비차단 minor. close 가능 |
| RR-A | Codex A | Accepted | RR-1/RR-2는 비차단 후속 관찰로 수용. approved result 이후 추가 churn 없이 사용자 최종 승인 대기 |

### Consensus Log

| Item | Consensus |
| --- | --- |
| Baseline policy | Consensus: released main/tag 기본, develop/current checkout은 명시 예외 라벨 |
| DR placement | Consensus: DR-028 amendment. DR-034에는 cross-pointer만 |
| `--check` source-ref output | Consensus: ref line + clean release tag가 아닐 때 WARN. dirty는 framework drift로 과해석하지 않음 |

## Discovery

- Backlog candidate `Upgrade baseline source-ref policy and --check ref visibility` 착수.
- `spring-modular-template` walkthrough는 source baseline을 develop/current checkout으로 라벨링해 honest-close했지만, durable policy는 아직 DR/playbook/tool output에 박히지 않았다.
- `VERSION=1.3.0`만으로 main/develop parity를 주장할 수 없다. release tag line과 checkout ref를 함께 기록해야 한다.

- 2026-06-22 archive: Done housekeeping(`/session-start` 배치 archive). DR-028 amendment + playbook + `--check` source-ref visibility 반영 완료.
