# DR-034: Harness Upgrade Ownership Policy

Date: 2026-06-11
Status: Draft
Track: harness
Linked DRs: DR-021, DR-028, DR-029, DR-033, DR-043

<!-- Draft: CHORE-20260611-010에서 실 adopter 1건(ai-deck-compiler)을 기준으로 작성. 두 번째 adopter 또는 실제 target apply 후 Accepted 승격을 검토한다. -->

## Question

이미 harness가 적용된 target repo를 새 source version으로 올릴 때, framework-owned 파일과 project-owned/customized 파일의 ownership을 어떻게 보존하고, pre-manifest target은 어떤 방식으로 manifest baseline을 획득해야 하는가?

## Context

`scripts/create-harness.sh --check <target-dir>`는 `.harness/manifest.json`을 읽어 framework-owned 파일의 source 대비 상태를 보고한다. manifest는 scaffold 생성 시점에 만들어지며, 기존 target에 manifest만 사후 주입하는 별도 command는 아직 없다.

이 문서에서 말하는 baseline은 target 쪽 manifest/shadow scaffold baseline이다. source repo의 어느 ref를 비교 기준으로 삼는지는 DR-028이 맡는다. released upgrade proof의 기본 source-ref baseline은 released `main` 또는 release tag이며, `develop`/current checkout probe는 pre-release tracking 예외로 라벨링해야 한다.

실 adopter `/Users/kyungseo/dev-home/vibe/ai-deck-compiler`는 `.harness/manifest.json`이 없는 pre-manifest target이다. 따라서 `--check`만으로는 upgrade 범위와 drift를 알 수 없고, command/skill/rule/document inventory와 manifest baseline 획득 정책이 먼저 필요하다.

## Draft Decision

1. **Pre-manifest target은 inventory-first로 다룬다.**
   - `.harness/manifest.json`이 없으면 `--check` 결과를 migration 범위로 해석하지 않는다.
   - 먼저 target의 entrypoint, command, skill, rule, prompt, workflow docs, decision index, project-owned docs를 inventory한다.
2. **Manifest baseline은 shadow scaffold에서 획득한다.**
   - 같은 project-name, workflow, profile 옵션으로 fresh shadow scaffold를 만든다.
   - shadow scaffold의 `.harness/manifest.json`을 현재 source 기준 baseline으로 사용한다.
   - 같은 project-name은 필수다. `adapt()`가 project-name을 치환하므로 이름이 다르면 false `locally-modified`가 대량 발생할 수 있다.
   - pre-manifest target에는 먼저 manifest만 심어 drift 분포를 관측한다. framework 파일을 복사하기 전에 `--check`를 실행해야 실제 drift를 볼 수 있다.
3. **Framework-owned 파일은 manifest path 기준으로 selective migration한다.**
   - target에 반영할 framework-owned 파일은 shadow manifest의 `framework_files[].path`를 기준으로 판단한다.
   - 자동 overwrite helper는 아직 제공하지 않는다. temp simulation 또는 target migration Work에서 파일별로 diff를 보고 `target-missing`, hard invariant-breaking drift, manual-merge candidate, accepted drift로 분류한 뒤 반영한다.
4. **Project-owned/customized 파일은 자동 overwrite하지 않는다.**
   - `docs/STATUS.md`, `docs/PLAN.md`, backlog, Work, product DR, product code, package/build files, `.harness/gate-config` 같은 target-local state는 보존한다.
   - `CLAUDE.md`, `AGENTS.md`, `.gitignore`, session-start prompt처럼 manifest에는 framework-owned path로 잡히지만 adopter가 project identity와 local workflow를 보정하기 쉬운 entrypoint는 customized framework entrypoint로 분류한다.
   - customized framework entrypoint가 `locally-modified`로 나타나면 blind overwrite하지 않고 manual merge candidate로 다룬다. 이 파일들을 current source baseline으로 덮어써서 얻은 `0 drift`는 preservation-safe evidence가 아니라 overwrite-convergence evidence다.
   - 다만 invariant가 요구하는 index/seed 파일은 project-owned 보강이 필요할 수 있다. 예: target에 product DR이 있는데 `docs/decisions/README.md`가 없으면 index를 생성하고 product DR row를 등록한다.
5. **첫 `--check`는 drift 분포를 허용한다.**
   - pre-manifest target에 baseline을 심은 직후 `--check`가 반드시 drift 0이어야 하는 것은 아니다.
   - drift 0은 "framework-owned 파일이 current source baseline과 일치"할 때만 기대한다.
   - target customization 보존 때문에 남는 차이는 accepted drift로 기록한다.
   - source repo invariant 전체를 통과시키려면 manifest-tracked drift는 최종적으로 in-sync 또는 명시적 accepted drift로 정리되어야 한다. accepted drift를 남기면 `check-scaffold-invariants.sh`의 manifest 자기일관성은 실패할 수 있다.
6. **신규 CLI는 후속 signal 전까지 만들지 않는다.**
   - `manifest-init`, `--upgrade-plan`, full `--upgrade`/`--refresh`는 이번 Draft의 기본 경로가 아니다.
   - 반복 adopter에서 shadow scaffold 절차가 너무 반복적이거나 오류가 잦으면 별도 Work에서 command화한다.

## Options Considered

| Option | 장점 | 단점 | Draft 판단 |
| --- | --- | --- | --- |
| A. full re-scaffold / overlay | current source 파일을 빠르게 얻음 | target customization 훼손 위험, `--existing`과 upgrade 의미 혼동 | 채택 안 함 |
| B. `manifest-init` 신규 command | UX 명확, 재사용 가능 | 스크립트 기능 추가가 먼저 필요, 정책 확정 전 과조기 | 후속 후보 |
| C. current source 기준 manifest 수동 작성 | 스크립트 변경 없음 | hash/path 실수 위험 큼 | 채택 안 함 |
| D. shadow scaffold baseline | 스크립트 변경 없음, 실제 scaffold manifest와 동일 | project-name/options 정합 필요, manual 절차 | **Draft 채택** |

## Promotion Conditions

- 두 번째 adopter 또는 실제 target migration에서 shadow scaffold baseline 방식이 재현 가능함을 확인한다.
- project-owned/customized 파일 보존 기준이 추가 사례에서도 유지된다.
- customized framework entrypoint(`CLAUDE.md`, `AGENTS.md`, `.gitignore`, session-start prompt 등)의 merge-not-overwrite 기준이 실제 adopter migration에서 작동함을 확인한다. 단순 `0 drift`가 아니라 adopter identity 보존 여부를 함께 확인해야 한다.
- `manifest-init` 또는 `--upgrade-plan` 같은 helper가 필요하다는 반복 signal이 생기면 Accepted 승격 전 별도 결정으로 분리한다.

## Consequences

- pre-manifest migration은 먼저 inventory를 작성한 뒤 shadow scaffold baseline을 심는다.
- `--check`는 baseline 심기 후부터 유효한 drift tool로 사용한다.
- `docs/maintainer/VERIFICATION-COMMANDS.md` Layer T는 shadow scaffold baseline 방식과 inventory-first 분류를 검증한다.
- target-specific product state는 source repo가 자동으로 판단하지 않는다. target repo AI/maintainer가 accepted drift와 project-owned 보존 결정을 기록한다.
- pre-manifest target에는 과거 source baseline이 없으므로 `locally-modified`는 3-way merge가 아니라 current source vs adopter의 2-way diff로만 판단한다. 이 한계는 Accepted 승격 전 baseline 보관 또는 helper 필요성의 근거가 된다.
- `0 drift`는 충분조건이 아니다. locally-modified customized framework entrypoint를 덮어써서 drift를 없앤 경우, manifest 자기일관성은 맞아도 adopter customization 보존은 검증되지 않는다.

## Reversal Cost

Medium — Draft이므로 정책 강제력은 낮지만, 후속 adopter migration note와 Layer T 검증이 이 방식을 전제로 작성된다. 다른 방식(`manifest-init`, full helper 등)을 채택하면 Layer T와 migration note를 함께 고쳐야 한다.

## Linked Work

- CHORE-20260611-010
- CHORE-20260621-002
