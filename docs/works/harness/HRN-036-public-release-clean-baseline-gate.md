---
id: HRN-036
priority: P1
status: Active
risk: Medium
scope: Public release clean baseline gate and develop-to-main release policy
appetite: 0.5d
planned_start: 2026-05-25
planned_end: 2026-05-26
actual_end:
related_dr: []
related_commits: []
related_troubleshooting: []
---

# HRN-036: Public Release Clean Baseline Gate

## Context

`ai-workflow-harness`는 public baseline 상태로 정리되었다.
현재 `develop` 기준 public clone 첫 `/start`는 Active Work, Blockers, Next Actions, archive pending Work 없이 clean idle 상태를 보여야 한다.

직전 public clean 작업의 상세 근거는 `docs/archive/docs/works/harness/HRN-035-public-clone-first-start-cleanup.md`에 보존되어 있다.
HRN-036은 HRN-035에서 만든 public baseline을 release마다 재검증하는 운영 gate로 확장한다.

앞으로는 feature 작업이 누적될 때마다 `main`에 바로 PR을 올리면 안 된다.
`main`은 일반 통합 브랜치가 아니라 public release snapshot이어야 하며, develop -> main PR 전에 public clean 상태를 명시적으로 점검해야 한다.

## Risk And Mode

- 위험도: L2
- 실행 모드: Standard Work
- 이유: Git flow, release gate, public-facing documentation, `/start` first-run experience에 영향을 주는 workflow hardening이다.

## Problem Statement

현재 Gitflow는 feature -> develop -> main 구조를 설명하지만, develop -> main PR 전에 어떤 public clean 조건을 반드시 확인해야 하는지는 충분히 명문화되어 있지 않다.

그 결과 다음 문제가 생길 수 있다.

1. feature 작업이 끝날 때마다 관성적으로 main PR을 생성한다.
2. `docs/STATUS.md`에 Active Work, Blockers, Next Actions, 내부 milestone 흔적이 남은 상태로 public release가 된다.
3. Done Work가 archive pending 상태로 남아 `/start` first-run 출력에 노출된다.
4. README, onboarding, scaffold 경로가 release 시점의 public 사용자 흐름과 어긋난다.
5. `develop`은 정상이어도 `main`이 release-ready snapshot이라는 의미를 잃는다.

## Goal

develop -> main release PR 전에 수행할 **Public Clean Baseline Gate**와 **Main Merge Gate**를 정의한다.

이 gate는 자동화 엔진이 아니라 manual-first checklist로 시작한다.
필요하면 후속 HRN에서 GitHub branch protection 또는 CI hardening으로 승격한다.

## Scope

### In Scope

- public release 직전 clean baseline checklist 정의.
- develop -> main PR 생성 조건과 금지 조건 명문화.
- `/start` clean idle 시뮬레이션을 release gate에 포함.
- `docs/STATUS.md`, Work lifecycle, archive pending, README/onboarding/scaffold 경로 점검 항목 정의.
- `docs/GIT-WORKFLOW.md` Release Cycle과 README Git Flow 설명 정렬.
- 필요 시 `docs/HARNESS-QUICK-REFERENCE.md`, `docs/HARNESS-PROTOCOL.md`, `docs/WORKFLOW-MANUAL.md` 중 release gate를 참조해야 하는 user-facing/canonical surface 보완.
- release gate가 필요한 변경 시 cascade 범위와 validation commands 정의.

### Out Of Scope

- GitHub branch protection 실제 설정 변경.
- CI workflow 대규모 재설계.
- release automation 또는 tag automation 구현.
- Gitflow vs GitHub Flow 전략 변경. 이 결정은 `HRN-FUT-004` 범위다.
- Windows 지원 검증. 이는 `HRN-032` 범위다.

## Proposed Operating Model

### Public Clean Baseline Gate

develop -> main PR을 만들기 전에 아래 항목을 확인한다.

| Area | Clean Condition | Evidence |
| --- | --- | --- |
| Working tree | release branch 또는 develop working tree가 clean | `git status --short --branch` |
| STATUS Active Work | `docs/STATUS.md` Active Work 비어 있음 | file inspection |
| STATUS Blockers/OQ | Open Blocker/OQ 없음. 남길 경우 public 사용자에게 보여도 되는 이유 기록 | file inspection |
| STATUS Next Actions | 비어 있거나 public release 후 사용자가 따라도 되는 항목만 존재 | file inspection |
| Work lifecycle | `docs/works/*/*.md`에 `status: Done` archive pending 없음 | `rg -n "^status: Done" docs/works` |
| Work active leakage | release 대상에 internal Active Work가 남지 않음 | `rg -n "^status: Active" docs/works` |
| Archive state | archived Work는 `docs/archive/docs/works/**` 아래에서 `status: Archived` | `rg -n "^status:" docs/archive/docs/works` |
| `/start` output | public clone 첫 `/start`가 clean idle 또는 의도한 release 상태로 시뮬레이션됨 | command/skill + STATUS 기준 문서 시뮬레이션 |
| Adoption path | README Section 10 -> `docs/SCAFFOLD-ONBOARDING-GUIDE.md` -> scaffold bootstrap 흐름 정합 | link/path inspection |
| Scaffold | generic scaffold dry-run 또는 temp scaffold 생성 결과가 bootstrap pointer를 유지 | `scripts/create-harness.sh --dry-run ...`, 필요 시 temp scaffold |
| Docs cascade | release gate 변경 surface와 canonical/tool/user-facing/scaffold 정렬 | targeted cascade check |
| Validation | docs/scaffold validation 통과 | `git diff --check`, `bash -n scripts/create-harness.sh` |

### Main Merge Gate

`main` PR은 아래 조건을 만족할 때만 생성한다.

- feature 작업은 먼저 feature -> develop PR로 병합한다.
- develop에 여러 feature가 누적되더라도 main PR은 release-ready snapshot일 때만 생성한다.
- main PR 전 Public Clean Baseline Gate 결과를 PR 본문 또는 release note에 남긴다.
- main PR은 `develop` -> `main` 방향만 허용한다.
- main PR merge 후 `main`을 pull하고 `develop`에 `origin/main`을 merge한 뒤 push하여 동기화한다.

### Main PR 금지 조건

- Active Work가 남아 있는 상태.
- Done archive pending Work가 남아 있는 상태.
- Open Blocker/OQ가 release 사용자에게 혼란을 줄 수 있는 상태.
- onboarding/scaffold 경로가 깨졌거나 README가 stale한 상태.
- `/start` 시뮬레이션이 maintainer 내부 작업 후보를 public 사용자에게 노출하는 상태.
- feature branch에서 직접 main으로 PR을 열려는 상태.

## Proposed Change Surface

| Surface | Change Need | Notes |
| --- | --- | --- |
| `docs/GIT-WORKFLOW.md` | Likely | Release Cycle에 Public Clean Baseline Gate와 Main Merge Gate 추가 |
| `README.md` | Likely | Git Flow 또는 Validation 근처에 main release snapshot 원칙 요약 |
| `docs/HARNESS-QUICK-REFERENCE.md` | Possible | release 전 빠른 checklist 또는 load condition 추가 여부 검토 |
| `docs/HARNESS-PROTOCOL.md` | Possible | release gate를 workflow validation/checkpoint 규칙으로 둘지 판단 |
| `docs/WORKFLOW-MANUAL.md` | Possible | user-facing Git Flow/Release 설명 정렬 필요 시 최소 보완 |
| `.github/workflows/ci.yml` | Unlikely | 이번 Work에서는 정책 문서화 우선. CI hardening은 후속으로 분리 |
| `docs/backlog/HARNESS.md` | Already | HRN-036 등록 및 상태 업데이트 |

## Plan

### Step 1 - Surface Audit

- `docs/GIT-WORKFLOW.md` Release Cycle 현재 문구 확인.
- README Git Flow / Validation / New Project Adoption과 release gate 연관 확인.
- `docs/HARNESS-QUICK-REFERENCE.md`, `docs/HARNESS-PROTOCOL.md`, `docs/WORKFLOW-MANUAL.md`에서 release/main PR 관련 문구 검색.
- `docs/STATUS.md` public baseline과 HRN-035 결과를 기준으로 release clean condition 추출.

### Step 2 - Gate Design

- Public Clean Baseline Gate checklist 확정.
- Main Merge Gate 조건과 금지 조건 확정.
- feature -> develop 작업과 develop -> main release의 차이를 명확히 정의.
- gate 결과를 어디에 남길지 결정:
  - PR body
  - release note
  - `/done` session summary
  - Work Discovery 또는 Checkpoint

### Step 3 - Documentation Patch

- `docs/GIT-WORKFLOW.md` §3 Release Cycle 보완.
- README에 release snapshot 원칙을 짧게 반영.
- 필요 시 Quick Reference 또는 Protocol에 release gate를 최소 문구로 추가.
- user-facing manual은 중복이 과하면 링크/요약만 추가한다.

### Step 4 - Simulation

아래 시나리오를 문서 기준으로 따라간다.

1. feature -> develop PR은 정상 merge되지만 main PR은 아직 만들지 않는 경우.
2. develop에 Active Work가 남은 상태에서 main PR을 만들려는 경우.
3. Done archive pending Work가 남은 상태에서 main PR을 만들려는 경우.
4. public clean 상태에서 develop -> main release PR을 만드는 경우.
5. main PR merge 후 develop sync를 수행하는 경우.
6. release 직후 public clone 사용자가 `/start`를 실행하는 경우.

### Step 5 - Validation

필수:

```bash
git diff --check
rg -n "release|main PR|develop|Public Clean|clean baseline|archive pending|/start" \
  README.md docs/GIT-WORKFLOW.md docs/HARNESS-QUICK-REFERENCE.md docs/HARNESS-PROTOCOL.md docs/WORKFLOW-MANUAL.md
rg -n "^status: Done|^status: Active" docs/works docs/archive/docs/works
bash -n scripts/create-harness.sh
```

조건부:

```bash
scripts/create-harness.sh --dry-run release-gate-smoke /private/tmp/release-gate-smoke
scripts/create-harness.sh --profile generic release-gate-smoke /private/tmp/release-gate-smoke
```

## Done Criteria

- [ ] develop -> main PR 전 Public Clean Baseline Gate가 문서화된다.
- [ ] main PR은 release-ready snapshot일 때만 생성한다는 원칙이 명확해진다.
- [ ] feature -> develop 작업과 develop -> main release가 혼동되지 않는다.
- [ ] `docs/STATUS.md`, Work archive pending, README/onboarding/scaffold, `/start` 시뮬레이션이 release gate 항목에 포함된다.
- [ ] main PR 금지 조건이 문서화된다.
- [ ] main PR merge 후 develop sync 절차가 유지된다.
- [ ] 필요한 canonical/tool/user-facing 문서 cascade가 최소 범위로 정렬된다.
- [ ] validation 결과와 남은 리스크가 Work Discovery 또는 final report에 기록된다.

## Open Questions

| ID | Question | Decision Needed |
| --- | --- | --- |
| HRN-036-OQ-001 | ~~Public Clean Baseline Gate 결과를 PR body에 필수로 남길 것인가, `/done` summary로 충분한가?~~ **Decided (2026-05-25): PR body 필수.** `/done` summary는 휘발성이라 release 기록으로 부적합. main merge PR body에 gate 결과를 남긴다. | ~~Step 2~~ Done |
| HRN-036-OQ-002 | ~~`docs/HARNESS-PROTOCOL.md`에 gate를 canonical rule로 추가할 것인가, `docs/GIT-WORKFLOW.md`에만 둘 것인가?~~ **Decided (2026-05-25): `docs/GIT-WORKFLOW.md` 주관, `docs/HARNESS-PROTOCOL.md`에 pointer만.** Gate는 release 정책이지 agent 실행 규칙이 아니므로 PROTOCOL에는 참조 링크만 추가. | ~~Step 2~~ Done |
| HRN-036-OQ-003 | ~~`main` PR 전 temp scaffold 생성까지 필수로 할 것인가, dry-run만 필수로 할 것인가?~~ **Decided (2026-05-25): dry-run 필수, temp scaffold는 scaffold 파일 변경 시에만.** 매번 temp 생성은 과잉. | ~~Step 2~~ Done |
| HRN-036-OQ-004 | Release 주기를 어떻게 정할 것인가? feature 작업이 끝날 때마다 release 하는가, 여러 feature를 묶어서 release 하는가? 최소 release 단위 기준이 있는가? | Step 2 |

## Checkpoints

| CP | Description | Status |
| --- | --- | --- |
| CP-1 | HRN-036 backlog 등록 및 Work plan 작성 | In Progress |
| CP-2 | release/main merge surface audit | Pending |
| CP-3 | Public Clean Baseline Gate 설계 확정 | Pending |
| CP-4 | 문서 patch 및 cascade 정렬 | Pending |
| CP-5 | release 시나리오 시뮬레이션과 검증 | Pending |

## Discovery

- 2026-05-25: HRN-035 이후 `develop`은 public clean baseline 상태다. Active Work, Blockers, Next Actions, archive pending Work가 없는 상태를 release 기준으로 보존해야 한다.
- 2026-05-25: 직전 public clean baseline 정리 근거와 `/start` first-run 시뮬레이션은 `docs/archive/docs/works/harness/HRN-035-public-clone-first-start-cleanup.md`를 참조한다.
- 2026-05-25: main은 일반 작업 누적 브랜치가 아니라 public release snapshot으로 다뤄야 한다. feature 작업이 끝났다는 이유만으로 main PR을 만들면 public clean 상태가 깨질 수 있다.
- 2026-05-25: release gate는 자동화보다 manual-first checklist로 먼저 정의하는 것이 현재 harness 철학과 맞다. CI/branch protection hardening은 후속 작업으로 분리 가능하다.
- 2026-05-25: GitHub ruleset 및 보안 설정 완료 (DR-020 참조). `protect-main`과 `protect-develop` 모두 active 전환. pull_request rule 추가, Admin bypass, secret scanning, vulnerability alerts 활성화. Out of Scope로 분리했던 branch protection 실제 설정이 이 시점에 완료되어 Gate의 Git 레벨 강제 조건이 갖춰졌다. 미결: merge 방식 제한(DR-017 정합성 검토 필요), sha_pinning.
