---
id: HRN-035
priority: P1
status: Archived
risk: Medium
scope: Public clone first-start cleanup for STATUS baseline and /start idle-state guidance
appetite: 0.5d
planned_start: 2026-05-25
planned_end: 2026-05-25
actual_end: 2026-05-25
related_dr: []
related_commits: []
related_troubleshooting: []
---

# HRN-035: Public Clone First-Start Cleanup

## Context

`ai-workflow-harness`를 공개한 뒤 사용자가 repository를 clone하고 Claude Code에서 `/start`를 실행하면,
현재 출력은 maintainer 내부 hardening milestone과 `AWH-OQ-001`을 다음 작업 후보처럼 보여준다.

공개 repository의 첫 진입 경험에서는 다음 상태가 더 자연스럽다.

- 이 repository는 public baseline 상태다.
- Active Work가 없으면 깨끗한 idle 상태로 보고한다.
- harness 자체를 개선하려면 `/pick`으로 Harness backlog를 본다.
- 새 프로젝트에 적용하려면 README `10. New Project Adoption` 또는 scaffold flow를 따른다.
- scaffold된 프로젝트에서는 `docs/STATUS.md` Next Actions의 bootstrap/onboarding pointer가 있을 때만 `docs/BOOTSTRAP.md`를 사용한다.

현재 `/start`가 `Next Actions` 공백을 보고 `Current Milestone Criteria`를 후보 작업으로 끌어올리면,
clone 사용자는 maintainer 내부 backlog와 adoption flow를 혼동할 수 있다.

## Risk And Mode

- 위험도: L2
- 실행 모드: Standard Work
- 이유: `docs/STATUS.md`, `/start` command/skill, public-facing README/quick reference에 영향을 주는 harness/workflow surface 변경이다.

## Scope

### In Scope

- Public clone 사용자의 첫 `/start` 경험을 기준으로 `docs/STATUS.md` baseline 상태 정리.
- `Current Milestone Criteria`가 완료된 maintainer checklist인지, ongoing phase criteria인지 판단하고 public baseline에 맞게 축소 또는 제거.
- `AWH-OQ-001`을 유지할지, backlog/deferred idea로 내릴지, 닫을지 판단.
- `.claude/commands/start.md`와 `.agents/skills/workflow-start/SKILL.md`가 Active Work와 Next Actions가 모두 없을 때 과도한 후보 추론을 하지 않도록 idle-state 안내 추가.
- README `10. New Project Adoption` 또는 maintainer entry 안내와 `/start` idle-state 문구 정렬.
- `docs/HARNESS-QUICK-REFERENCE.md` Session Start 섹션에 public baseline idle-state를 짧게 반영할지 검토.
- HRN-035 자체가 완료 후 `/start` first-start 출력에 archive pending Work로 남지 않도록 `/close`와 archive 처리까지 완료한다.

### Out Of Scope

- `scripts/create-harness.sh`의 generated `docs/STATUS.md` skeleton 대규모 재설계.
- Windows 지원 확장. OS별 first-start 검증은 HRN-032에서 다룬다.
- 자동화 hook 또는 hard enforcement 추가. HRN-002에서 다룬다.
- GitHub profile/social announcement 정리.

## Current Observations

- `docs/STATUS.md` Current phase는 `Workflow hardening`, Current focus는 문서 현행화/scaffold 정합성/tool surface alignment다.
- `Current Milestone Criteria` 5개가 모두 unchecked로 남아 있다.
- `Active Work`와 `Next Actions`는 비어 있다.
- `Blockers And Open Questions`에 `AWH-OQ-001`이 Open으로 남아 있다.
- `/start` command/skill은 STATUS 현재 섹션과 Done 미archive Work를 보고 다음 후보를 제안하도록 되어 있다.
- clone 사용자의 첫 `/start`는 repository maintainer의 남은 milestone보다 public baseline/adoption entrypoint를 먼저 보여주는 편이 낫다.

## Problem Statement

현재 첫 `/start` 출력은 아래처럼 해석될 수 있다.

1. Active Work 없음.
2. Next Actions 없음.
3. 그러나 Current Milestone Criteria가 모두 미완료로 보이므로, 내부 hardening 작업이 아직 남아 있는 것처럼 보임.
4. `AWH-OQ-001` 때문에 archive 기준 결정을 먼저 해야 할 것처럼 보임.
5. 신규 사용자가 이 repository를 적용해보려는 경우 README Section 10 또는 scaffold adoption flow로 자연스럽게 이어지지 않음.

원하는 출력은 아래에 가깝다.

```text
Active Work 없음.
Next Actions 없음.
이 repository는 public baseline 상태입니다.

- 이 harness 자체를 개선하려면 /pick으로 Harness backlog를 선택하세요.
- 새 프로젝트에 적용하려면 README Section 10 New Project Adoption을 참고하세요.
- scaffold된 프로젝트에서는 STATUS.md Next Actions의 bootstrap/onboarding pointer를 따라 docs/BOOTSTRAP.md를 사용하세요.
```

## Plan

### Step 1 - STATUS Baseline Design

- `docs/STATUS.md`를 public baseline 관점으로 재해석한다.
- `Current phase` 후보:
  - `Public baseline / Maintenance`
  - `Public baseline`
  - `Maintenance`
- `Current focus` 후보:
  - `Public repository maintenance, adoption support, and focused workflow hardening`
  - `Public baseline 유지보수와 adoption support`
- `Current Milestone Criteria` 처리: **B안 확정** — public baseline에서 제거하고 backlog/Work 이력으로 이동. 항목이 unchecked로 남아 있으면 첫 `/start` 경험이 흐려진다. 이력은 HRN-035 Work와 필요 시 `docs/backlog/HARNESS.md` Deferred Ideas에 보존한다.
- `AWH-OQ-001` 처리: **B안 확정** — Blockers에서 제거. archive policy가 필요한 시점에 신규 Work로 재등록한다. 추적성 보존을 위해 HRN-035 Discovery에 제거 근거를 기록한다.

### Step 2 - /start Idle-State Rule

`.claude/commands/start.md`와 `.agents/skills/workflow-start/SKILL.md`에 아래 분기를 추가한다.

- **Open Blocker 우선 분기 (신규):** Open Blocker가 존재하면 idle-state 안내보다 먼저 노출한다. Blocker가 없는 경우에만 아래 idle-state 흐름으로 진행한다.
- Active Work 없음 + Next Actions 없음 + archive 대기 Work 없음 + Open Blocker 없음:
  - repository가 clean idle 상태임을 먼저 보고한다.
  - `Current Milestone Criteria`를 자동으로 next candidate로 확장하지 않는다.
  - 다음 entrypoint를 세 가지로 안내한다:
    - maintainer 개선: `/pick` -> `docs/backlog/HARNESS.md`
    - 새 프로젝트 adoption: README Section 10
    - scaffold된 프로젝트 bootstrap: STATUS Next Actions가 bootstrap/onboarding을 명시할 때만 `docs/BOOTSTRAP.md`

### Step 3 - User-Facing Alignment

- README `10. New Project Adoption`과 `/start` idle-state 안내가 서로 충돌하지 않는지 확인한다.
- `docs/HARNESS-QUICK-REFERENCE.md` Session Start에 public baseline idle 상태의 기대 동작을 짧게 추가할지 검토한다.
- `docs/WORKFLOW-MANUAL.md`는 user-facing workflow 변경이므로 관련 섹션만 확인하고, 실제 수정 필요 여부를 판단한다.

### Step 4 - Scenario Simulation

- 공개 repo clone 후 `/start`.
- Maintainer가 새 harness 작업을 시작하려는 경우 `/start` -> `/pick`.
- 신규 사용자가 자기 프로젝트에 harness를 적용하려는 경우 `/start` -> README Section 10 -> `scripts/create-harness.sh`.
- scaffold된 프로젝트에서 `STATUS.md` Next Actions가 bootstrap/onboarding을 가리키는 경우 `/start` -> `docs/BOOTSTRAP.md` 안내.
- Active Work가 있는 경우 기존 `/start` 요약 동작 유지.
- Done Work가 `docs/works/{category}/`에 남아 있는 경우 archive 제안 동작 유지.

### Step 5 - Validation

- `git diff --check`
- `/start` 출력 시뮬레이션: `docs/STATUS.md`, `.claude/commands/start.md`, `.agents/skills/workflow-start/SKILL.md` 기준으로 문서상 결과 확인
- `rg`로 `Current Milestone Criteria`, `AWH-OQ-001`, `New Project Adoption`, `bootstrap/onboarding` 참조 확인
- 필요 시 `bash -n scripts/create-harness.sh`
- 변경이 scaffold source까지 이어지면 generic dry-run 또는 temp scaffold 생성 확인

### Step 6 - Self Closeout And Archive

- HRN-035 완료 후 `/close` 절차로 Work Done 처리, Work index 이동, `docs/STATUS.md` Active Work pointer 제거 제안을 수행한다.
- public clone first-start가 깨끗해야 하므로, 사용자 승인 후 HRN-035 Work 파일을 즉시 archive한다.
- archive 후 `docs/works/harness/README.md`에는 HRN-035가 Archived 테이블에만 남아야 한다.
- 최종 `/start` 시뮬레이션에서 HRN-035가 Active Work 또는 archive pending Work로 노출되지 않는지 확인한다.

## Proposed Change Surface

| Surface | Change Need | Notes |
| --- | --- | --- |
| `docs/STATUS.md` | Likely | public baseline/maintenance 상태로 정리. Active Work pointer 변경은 별도 승인 필요 |
| `.claude/commands/start.md` | Likely | idle-state rule 추가 |
| `.agents/skills/workflow-start/SKILL.md` | Likely | Claude command와 mirror 정렬 |
| `docs/HARNESS-QUICK-REFERENCE.md` | **Likely** | Session Start 기대 동작이 바뀌면 사용자-facing 실행 카드로서 반드시 정렬 |
| `README.md` | Possible | maintainer mode vs adoption mode 안내가 충분한지 확인 |
| `docs/WORKFLOW-MANUAL.md` | Possible — 범위 제한 | 관련 섹션 확인 후 필요한 경우만 수정. 0.5d appetite 유지를 위해 과도한 수정 금지 |
| `docs/backlog/HARNESS.md` | Possible | `AWH-OQ-001` 또는 public baseline cleanup follow-up 이동 여부 |
| `scripts/create-harness.sh` | Unlikely | generated scaffold first-start는 이미 bootstrap pointer 중심. 변경 전 확인 필요 |

## Done Criteria

- [x] 공개 repository clone 후 `/start`가 maintainer 내부 milestone을 과도하게 다음 후보로 제안하지 않는다.
- [x] Active Work/Next Actions가 없는 상태는 public baseline idle-state로 설명된다.
- [x] `/start`가 maintainer 개선, new project adoption, scaffold bootstrap 세 진입로를 구분한다.
- [x] `docs/STATUS.md`가 공개 후 baseline/maintenance 상태를 명확히 표현한다.
- [x] `AWH-OQ-001`이 `/start` 첫 출력에서 blocking work처럼 보이지 않도록 정리된다.
- [x] Claude command와 Codex skill이 같은 idle-state 기준을 가진다.
- [x] README/Quick Reference/Manual 중 사용자-facing 설명이 필요한 범위만 정렬된다.
- [x] validation 결과와 남은 리스크를 Work Discovery 또는 final report에 반영한다.
- [x] HRN-035 자체가 `/close` 처리되고 archive까지 완료되어 public clone `/start` 출력에 Active/Done pending Work로 남지 않는다.

## Verification

```bash
git diff --check
rg -n "Current Milestone Criteria|AWH-OQ-001|New Project Adoption|bootstrap/onboarding|public baseline|idle" \
  docs/STATUS.md .claude/commands/start.md .agents/skills/workflow-start/SKILL.md README.md docs/HARNESS-QUICK-REFERENCE.md docs/WORKFLOW-MANUAL.md
rg -n "Workflow hardening|AWH-OQ-001|BOOTSTRAP.md" \
  docs/HARNESS-QUICK-REFERENCE.md docs/WORKFLOW-MANUAL.md
bash -n scripts/create-harness.sh
```

- `docs/HARNESS-PROTOCOL.md` cascade trigger 확인: `.claude/commands/start.md`와 `.agents/skills/workflow-start/SKILL.md` 변경이 canonical → tool-specific → user-facing cascade 대상인지 Step 5에서 명시적으로 체크한다.

## Checkpoints

| CP | Description | Status |
| --- | --- | --- |
| CP-1 | HRN-035 backlog 등록 및 Work plan 작성 | Done |
| CP-2 | STATUS baseline 정리안 확정 | Done |
| CP-3 | `/start` idle-state command/skill 정렬 | Done |
| CP-4 | user-facing docs 영향 확인 및 필요한 범위 보완 | Done |
| CP-5 | 시뮬레이션과 검증 완료 | Done |
| CP-6 | HRN-035 `/close` 및 archive 처리 완료 | Done |

## Discovery

- 2026-05-25: 공개 repo clone 후 `/start` 출력이 maintainer 내부 milestone과 `AWH-OQ-001`을 후보처럼 보여 first-start experience가 흐려질 수 있음을 확인했다.
- 2026-05-25: `docs/works/harness/README.md` 기준 현재 Active Work는 없고, 이전 HRN Work들은 Archived 테이블로 정리되어 있다.
- 2026-05-25: 이 작업 자체도 완료 후 archive pending 상태로 남으면 `/start` first-start 출력이 다시 지저분해지므로, HRN-035는 `/close` 후 즉시 archive까지 처리하는 것을 Done Criteria에 포함한다.
- 2026-05-25: AWH-OQ-001을 `docs/STATUS.md` Blockers에서 제거하기로 확정(B안). public baseline 상태에서 Open Blocker로 유지하면 "미완" 인상을 주고 `/start` 출력을 오염시킨다. historical product docs archive 기준이 실제로 필요해지는 시점에 신규 Work로 재등록한다.
- 2026-05-25: P1 발견 — idle-state 출력 문구에 source repo 전용 표현("이 repository는 public baseline 상태입니다", "README Section 10 New Project Adoption" 직접 안내)이 포함됐었음. 이 파일들은 scaffold 결과에도 복사되므로, bootstrap 완료 후 clean idle 상태에서 어색한 안내가 노출될 수 있었다. generic 문구("clean idle 상태입니다 / /pick / /register / source repo 작업이라면 Section 10 참고")로 교체해서 해결.
- 2026-05-25: P2 발견 — Recent Decisions rolling window 초과(11 → 8). 2026-05-21 항목 3개(repository naming, repo 분리, private 유지)는 모두 실행 완료된 one-time 결정이며 별도 DR 없음. trim 처리.

## Review

_2026-05-25 검토_

### 잘 된 점

- **Problem Statement → Desired Output** 흐름이 명확하다. 이상 상태와 목표 상태를 구체적인 출력 텍스트로 대비시킨 것이 실행 기준으로 쓰기 좋다.
- **Self Closeout(Step 6)** 을 Done Criteria에 명시해 HRN-035 자체가 `/start` 출력을 오염시키지 않도록 닫은 구조가 맞다.
- Scenario Simulation(Step 4) 5개가 실제 사용자 진입 경로를 고르게 커버한다.

### 수정 권고 (실행 전 결정 필요)

**1. `Current Milestone Criteria` 처리 — A/B/C 중 실행 전 하나를 확정해야 한다.**

현재 계획은 세 가지 후보를 나열하고 결정을 Step 1 실행 시점으로 미뤘다. 그러나 이 선택이 STATUS.md 수정 범위와 cascade 대상에 직접 영향을 주므로, 승인 전에 결정해야 한다.

권고: **B안** (항목 제거 + backlog/Work 이력으로 이동).
- 5개 항목이 모두 unchecked인 이유는 "완료됐지만 체크 안 한 것"이 아니라 "maintainer hardening 체크리스트가 public baseline에서 계속 보일 필요가 없어진 것"이다.
- A안(체크 처리 후 유지)은 사실과 다른 완료 표시 리스크가 있다. C안(Maintenance Criteria로 축소)은 여전히 internal 뉘앙스를 남긴다.
- 제거 후 `docs/backlog/HARNESS.md` Deferred Ideas에 한 줄 pointer만 남기면 이력이 사라지지 않는다.

**2. `AWH-OQ-001` 처리 — 마찬가지로 실행 전 확정 필요.**

권고: **B안** (Blockers에서 제거, 필요 시 신규 Work로).
- C안(Open 유지 + command/skill 조정)은 두 곳을 동시에 고쳐야 하는 부담이 생긴다.
- public baseline에서 "해결되지 않은 open blocker"가 존재하면 후속 유지보수 세션에서 다시 surface된다.

**3. `/start` idle-state 트리거 조건에 `Blockers And Open Questions` 처리 명시가 빠져 있다.**

Step 2의 트리거 조건은 "Active Work 없음 + Next Actions 없음 + archive 대기 Work 없음"이다. AWH-OQ-001을 B안으로 닫는다면 상관없지만, Open Blocker가 남을 경우 idle-state 안내와 충돌한다. Step 2 조건에 "Open Blocker 존재 시 먼저 노출한다"는 우선순위 분기를 한 줄 추가해야 한다.

**4. `docs/HARNESS-QUICK-REFERENCE.md`는 Possible이 아니라 Likely다.**

Session Start 동작이 바뀌면 Quick Reference는 그 변경을 반영해야 하는 문서다. "검토 후 판단"이 아니라 "변경 확인 후 반드시 정렬" 기준으로 올려야 한다.

**5. Appetite 재확인 필요.**

0.5d appetite로 6개 surface(STATUS, start.md, SKILL.md, QUICK-REFERENCE, README, WORKFLOW-MANUAL) + 5개 시뮬레이션 + self-archive를 커버하는 일정이 빠듯하다. Step 3(User-Facing Alignment)의 `docs/WORKFLOW-MANUAL.md`를 "필요 여부 확인만" 수준으로 명시적으로 제한하면 0.5d 범위를 지킬 수 있다.

### 검증 보강 권고

Verification `rg` 명령에 아래 패턴을 추가하는 것을 권고한다.

```bash
rg -n "Workflow hardening|AWH-OQ-001|BOOTSTRAP.md" \
  docs/HARNESS-QUICK-REFERENCE.md docs/WORKFLOW-MANUAL.md
```

또한 `/start` command/skill 변경이 `docs/HARNESS-PROTOCOL.md` cascade 섹션 확인 트리거에 해당하는지 Step 5에서 명시적으로 체크해야 한다(현재 누락).

### 실행 전 결정 요청 사항

| 항목 | 후보 | 권고 |
| --- | --- | --- |
| `Current Milestone Criteria` | A / B / C | **B안** (제거 + Deferred) |
| `AWH-OQ-001` | A / B / C | **B안** (Blockers 제거) |
| `HARNESS-QUICK-REFERENCE.md` 변경 | Possible / Likely | **Likely로 상향** |
| `docs/WORKFLOW-MANUAL.md` | Possible / Skip | **확인만, 수정은 최소화** |
