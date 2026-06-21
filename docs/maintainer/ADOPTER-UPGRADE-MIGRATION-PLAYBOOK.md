# ADOPTER-UPGRADE-MIGRATION-PLAYBOOK.md (source-only)

이미 harness가 적용된 adopter repository를 최신 source baseline으로 올릴 때 쓰는 maintainer playbook이다.
이 문서는 `ai-workflow-harness` **source repo 전용**이며 scaffold target으로 배포되지 않는다.

> 지금은 "업그레이드 기능을 만든다"보다 **"업그레이드 판단 근육을 만든다"**에 가깝다. 이 playbook은 그 운동 기록지이고, 다음 adopter walkthrough들은 반복 훈련이다. 어느 순간 같은 판단이 2~3번 반복되면, 그때 자동화하거나 정책으로 승격한다.

## Evidence Boundary

이 playbook은 `ai-deck-compiler` walkthrough(CHORE-20260621-002/003/004)에서 확인된 절차를 일반화한 것이다.
Claude/Codex가 실제로 어떤 임시 shell 조합을 몇 번 시도했는지까지 재현하는 문서가 아니라, 다음 adopter(`spring-modular-template`, `rfx-hub` 등)에서 반복 가능한 **판단 순서와 gate**를 정리한다.

중요한 교훈:

- `0 drift`는 성공 증거가 아닐 수 있다. customized entrypoint를 덮어써서 나온 `0 drift`라면 preservation-safe하지 않다.
- 실제 target repo write 전에 temp rehearsal을 먼저 끝낸다.
- batch copy/merge는 가능하지만, 모든 batch는 classification table에 매핑돼야 한다.
- product/adopter-owned surface는 source framework 정합보다 보존과 owner sign-off가 먼저다.
- policy/index/namespace blocker가 나오면 real apply를 멈추고 별도 Work/DR로 분리한다.

## 표준 흐름 (Standard Flow)

```text
Work plan
  -> target read-only probe
  -> baseline 선택
  -> ownership classification
  -> temp rehearsal
  -> result review / owner sign-off
  -> real target apply
  -> target PR / merge
  -> source closeout
```

| 단계 | 산출물 | 멈춤 기준 |
| --- | --- | --- |
| 0. Work 준비 | Work file, 역할 분리, owner gate | 명시 승인 전 cross-repo write 금지 |
| 1. Target probe | clean base, target branch policy, manifest 상태 | dirty target 또는 base 불명확 |
| 2. Baseline 선택 | 3-way base 또는 shadow scaffold baseline | audit 없는 untrusted base |
| 3. Classification | file/action table | 미분류 overwrite |
| 4. Temp rehearsal | temp result tree + verification | policy/index blocker |
| 5. Sign-off | owner-approved mapping/action list | product-owned 변경 미승인 |
| 6. Real apply | target feature branch + commit/PR | rehearsal 이후 source/target drift |
| 7. Closeout | Work/STATUS/backlog/DR evidence | promotion/evidence 과장 |

## Phase 0. Work 준비

실제 adopter repo를 건드리거나 ownership surface가 둘 이상이면 Work file을 사용한다.
Work에는 아래를 명시한다.

- source repo owner/driver와 red-team reviewer 역할
- target repo path와 branch policy
- 정확한 cross-repo write gate
- 예상되는 product-owned 파일
- verification commands
- migration에 영향을 줄 수 있는 DR 또는 policy gate

권장 cross-agent 패턴:

```text
A writes Work + plan -> B red-team review -> A response -> consensus
-> temp rehearsal -> B result review -> owner final approval
-> real apply -> closeout
```

## Phase 1. Target Probe

먼저 read-only로 target 상태를 확인한다.

```bash
TARGET="<target-repo>"

git -C "${TARGET}" status --short --branch
git -C "${TARGET}" log --oneline -n 12
test -f "${TARGET}/docs/GIT-WORKFLOW.md" && sed -n '1,180p' "${TARGET}/docs/GIT-WORKFLOW.md"
test -f "${TARGET}/.harness/manifest.json" && echo "manifest target" || echo "pre-manifest target"
bash scripts/create-harness.sh --check "${TARGET}" || true
```

기록할 항목:

- target base branch와 current `HEAD`
- `origin/develop`, `origin/main`, local branch 일치 여부
- target branch naming과 PR base policy
- `.harness/manifest.json` 존재 여부
- current `--check` 결과. 단, 아직 proof로 취급하지 않는다

target이 dirty면 멈춘다. owner가 mixed state를 명시 승인하지 않는 한, 무관한 product work 위에서 migration하지 않는다.

## Phase 2. Baseline 선택

사용 가능한 baseline 중 가장 강한 것을 선택한다.

| Baseline 유형 | 사용 시점 | 의미 | 주의 |
| --- | --- | --- | --- |
| 3-way adoption commit | target history에 scaffold adoption commit이 있음 | BASE=adoption, THEIRS=target current, OURS=current source | BASE가 clean scaffold였는지, product edit이 이미 섞였는지 audit 필요 |
| manifest target | target에 `.harness/manifest.json`이 이미 있음 | manifest가 tracked source baseline을 제공 | manifest가 accepted-drift를 표현하지 못할 수 있음 |
| shadow scaffold | pre-manifest 또는 history 신뢰도가 낮음 | 같은 project-name/workflow/profile로 current source scaffold 생성 | 2-way 한정. 과거 adopter intent를 history에서 추론할 수 없음 |

3-way migration 기준:

```text
BASE   = adoption commit or trusted old scaffold state
THEIRS = target current
OURS   = current harness source / generated scaffold
```

pre-manifest migration은 `docs/maintainer/VERIFICATION-COMMANDS.md` Layer T의 shadow baseline 절차를 따른다.

## Phase 3. Base Trust Audit

BASE -> THEIRS를 adopter intent로 신뢰하기 전에, 각 파일이 target에 들어온 방식을 분류한다.

| Audit class | 의미 | 기본 처리 |
| --- | --- | --- |
| net-new framework file | scaffold adoption으로 새로 추가됨 | BASE -> THEIRS가 adopter change일 가능성 높음 |
| modified pre-existing file | scaffold adoption이 기존 product file을 수정함 | low trust. owner sign-off 필요 |
| later framework-alignment commit | target이 나중에 source framework file을 복사/정렬함 | 자동으로 product customization으로 보지 않음 |
| product-local file | target product behavior를 위해 생성됨 | owner가 명시 retire하지 않는 한 preserve |

대표 low-trust files:

- `CLAUDE.md`
- `AGENTS.md`
- `.gitignore`
- `prompts/*session-start.md`
- `tools/git-hooks/*`
- target `docs/STATUS.md`, `docs/PLAN.md`, backlog, Work files, product DRs

## Phase 4. Ownership Classification

temp rehearsal 전에 모든 변경 파일은 아래 분류 중 하나에 들어가야 한다.

| Classification | Action | Example |
| --- | --- | --- |
| `source-retired` | target에서 제거 | source에 더 이상 없는 old command/skill surfaces |
| `framework-add` | current source scaffold file 추가 | 신규 workflow command/skill adapters |
| `framework-update` | current source에서 copy/update | customization 없는 framework docs/hooks |
| `merge` | source update와 target customization을 manual merge | `CLAUDE.md`, `AGENTS.md`, `.gitignore`, session-start prompts |
| `preserve` | target version 유지 | product skills, product docs, product decisions |
| `delete-respect` | adopter delete와 source retire가 일치하면 no-op | 이미 제거된 old prompt files |
| `accepted-drift` | 알려진 divergence를 유지하고 이유 기록 | merge 후 customized entrypoints |
| `blocker` | 멈추고 policy/DR/work 분리 | decision namespace collision, missing index policy |

batch operation은 이 표가 생긴 뒤에만 허용한다. batch는 편의 수단이지 결정이 아니다.

좋은 batch 경계:

- 모든 `source-retired` 제거
- 명확한 `framework-add` 일괄 copy
- non-customized `framework-update` 일괄 update
- 그 다음 `merge` 파일을 하나씩 처리
- 마지막으로 product/index/policy closure 처리

나쁜 batch 경계:

- classification table 없이 "source를 target 위에 복사"

## Phase 5. Temp Rehearsal

절대 direct target write로 시작하지 않는다. 먼저 temp result tree를 만든다.

```bash
TARGET="<target-repo>"
WORK="temp/<work-id>"
TARGET_COPY="${WORK}/target-copy"

mkdir -p "${WORK}"
rsync -a --delete --exclude .git "${TARGET}/" "${TARGET_COPY}/"
```

Phase 2에서 선택한 baseline을 기준으로 `TARGET_COPY`에 classification table을 적용한다.
구체적인 방법은 `cp`, `git diff`/`git apply`, manual editor merge, generated patch 등으로 달라질 수 있다. 중요한 것은 result tree가 재현 가능하고, 모든 변경이 classification에 매핑된다는 점이다.

최소 rehearsal 산출물:

- final action이 포함된 classification table
- 제거한 retired source files 목록
- 추가/갱신한 framework files 목록
- merge files와 보존한 target customizations 목록
- accepted-drift 목록, 정확한 path count, 이유
- rehearsal 중 발견한 blockers

## Phase 6. Verification

real apply 전에 temp tree 대상으로 target verification을 실행한다.

```bash
bash scripts/create-harness.sh --check "${TARGET_COPY}"
bash scripts/tests/check-scaffold-invariants.sh "${TARGET_COPY}"
```

해석 규칙:

- `--check`의 `0 drifted`는 자동 성공이 아니다. customization을 덮어써서 나온 값이 아닌지 확인한다.
- accepted-drift는 모든 path가 이름과 이유를 가진 경우에만 허용한다.
- accepted-drift가 예상되면 `check-scaffold-invariants.sh` `[5]`가 실패할 수 있다. 이때도 `[1]`~`[4]`가 통과할 때만 expected로 기록한다.
- `[3]` decision-index closure failure는 accepted-drift가 아니다. index/namespace blocker로 다룬다.
- product DR 또는 historical ID를 renumber할 때는 live refs와 archive refs를 분리해 검색한다.

유용한 grep patterns:

```bash
# live old decision refs, excluding archive if appropriate
grep -RIn "DR-014\|DR-021\|DR-022\|DR-023" \
  "${TARGET_COPY}/docs" "${TARGET_COPY}/skills" \
  --exclude-dir=archive || true

# product/source name leakage
grep -RIn "ai-workflow-harness" \
  "${TARGET_COPY}/docs" "${TARGET_COPY}/prompts" "${TARGET_COPY}/skills" || true
```

## Phase 7. Blocker Handling

rehearsal에서 policy 또는 ownership blocker가 나오면 real apply를 멈춘다.

blocker 예시:

- framework DR과 product DR이 같은 번호를 공유함
- namespace policy가 없어 `docs/decisions/README.md` closure가 불가능함
- target product files에 승인 범위 밖 renumbering 또는 semantic edit이 필요함
- target branch policy가 계획된 branch name 또는 merge method와 충돌함
- temp result 생성 이후 source가 바뀜

해결 패턴:

```text
record blocker in Work
-> decide whether to downscope or split a follow-up Work
-> do not real-apply partial state unless owner explicitly approves it
```

ai-deck rehearsal은 DR namespace blocker에서 의도적으로 멈췄고, 별도 policy/apply Work에서 high-band product DR allocation을 도입했다.

## Phase 8. Owner Sign-Off

target write 전에 owner에게 compact sign-off table을 제시한다.

| 결정 | 예시 |
| --- | --- |
| branch/base | target `origin/develop`에서 `feature/...` 생성 |
| product-owned preserve | product skills와 product docs 유지 |
| merge files | `CLAUDE.md`, `AGENTS.md`, `.gitignore`, session-start prompts |
| accepted-drift | 정확한 list와 count |
| blocker disposition | resolved / split / consciously deferred |
| verification | `--check`, invariants, grep, `diff --check` |

가치 한계를 숨기지 않는다. 결과가 "regression re-check" 또는 "evidence 1"이면 그렇게 쓰고, "upgrade proven"으로 과장하지 않는다.

## Phase 9. Real Apply

owner sign-off 이후에만 실행한다.

```bash
TARGET="<target-repo>"
BRANCH="feature/<work-id>-harness-upgrade"

git -C "${TARGET}" fetch origin
git -C "${TARGET}" checkout -B "${BRANCH}" origin/develop
git -C "${TARGET}" status --short --branch
```

rehearsal된 결과를 적용한다. temp tree가 의도한 최종 상태임이 확인됐으면 patch 또는 verified temp tree 기준 `rsync`를 선호할 수 있다. actual target branch에서 같은 verification을 다시 실행한다.

필수 actual-target evidence:

- target `--check` 결과
- target scaffold invariants 결과
- renamed/retired refs에 대한 live grep 결과
- `git diff --check`
- commit SHA
- PR URL, base branch, merge commit

target repo의 `docs/GIT-WORKFLOW.md`를 따른다. source repo의 merge policy가 target에도 적용된다고 가정하지 않는다.

## Phase 10. Source Closeout

target PR이 merge된 뒤 source Work를 닫는다.

기록할 항목:

- target PR URL과 merge commit
- 정확한 verification output summary
- accepted-drift count와 path list
- 실제로 남은 residuals, 특히 helper/tooling gaps
- 과장 없는 DR promotion evidence
- backlog candidate removal 또는 residual re-scope

promotion wording은 보수적으로 쓴다.

- 좋음: "actual target migration evidence 1 acquired"
- 나쁨: adopter 1건만 migration했는데 "upgrade logic accepted/proven"이라고 쓰기

## Adopter-Specific Notes

### `ai-deck-compiler`

관측된 패턴:

- usable 3-way BASE: scaffold adoption commit
- 중요한 merge surfaces: `CLAUDE.md`, `AGENTS.md`, `.gitignore`, session-start prompts
- source-retired old command/skill surfaces 제거 필요
- product skills 보존 필요
- product DR namespace collision이 policy 결정 전 real apply를 차단
- final target state는 의도적으로 accepted-drift 유지

### `spring-modular-template`

예상 패턴:

- 최신 scaffold에 가장 가까운 adopter이므로 current scaffold generation을 먼저 검증
- ai-deck보다 retired-surface conflicts가 적을 가능성 높음
- product planning-pack/code-product artifacts가 product-owned preservation decision을 만들 수 있음
- 그래도 target probe와 classification은 실행한다. latest scaffold에 가깝다고 customization이 없다고 가정하지 않는다

### `rfx-hub`

예상 패턴:

- middle-generation adopter로 취급
- architecture/deployment docs는 product-owned 또는 product-informed일 가능성이 높음
- documentation concept alignment와 framework-owned workflow surface migration을 분리
- harness source claim을 product/domain docs로 복사하지 않도록 더 엄격하게 점검

## Minimal Report Template

migration rehearsal 또는 apply를 요약할 때 사용한다.

```md
## 마이그레이션 요약

- target:
- base:
- 방식: 3-way / manifest / shadow scaffold
- temp result:
- real apply: yes/no

## Classification

| 분류 | 개수 | Paths / Notes |
| --- | ---: | --- |
| source-retired | | |
| framework-add/update | | |
| merge | | |
| preserve | | |
| delete-respect | | |
| accepted-drift | | |
| blocker | | |

## 검증

- create-harness --check:
- scaffold invariants:
- live grep:
- diff check:
- CI:

## Owner Decisions (owner 결정)

- 승인:
- 보류:
- residual:

## Evidence Boundary

증명한 것:
증명하지 않은 것:
```
