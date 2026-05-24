---
id: HRN-025
priority: P1
status: Done
risk: Medium
scope: Scaffold bootstrap onboarding, /start condition tightening, command/tool surface alignment
appetite: 0.5d
planned_start: 2026-05-22
planned_end:
actual_end: 2026-05-23
---

# HRN-025: Scaffold bootstrap flow tightening

## Context

HRN-024에서 scaffold 직후 `docs/BOOTSTRAP.md`를 중심으로 project identity,
Product track backlog, Harness track 정비 항목, example pack 점검을 제안하도록 보강했다.

추가 검토 중 bootstrap은 scaffold 직후의 one-time onboarding 절차인데,
`/start`와 일부 prompt/rule surface가 매 세션마다 bootstrap 필요 여부를 확인하는 방식으로 읽힐 수 있음이 드러났다.

이 작업은 bootstrap을 daily session check가 아니라 one-time onboarding/reset flow로 격리하고,
사용자가 이 repository를 product starter로 직접 사용하는 경로는 다루지 않는다.
Product 적용은 `scripts/create-harness.sh`로 scaffold/adoption하는 방식으로 한정한다.

## Goals

- `/start` 기본 흐름에서 bootstrap을 매번 점검하지 않게 한다.
- Bootstrap 실행 조건을 명확히 한다: scaffold 직후 generated `STATUS.md` Next Actions가 bootstrap onboarding을 가리키는 경우.
- Source maintainer flow와 scaffold/adoption flow를 README/manual에서 구분한다.
- 신규 `/bootstrap` command는 도입하지 않고, 기존 `/start` 조건을 좁혀 해결한다.

## Non-Goals

- HRN-024의 전체 문서 정합성 작업을 종료하거나 archive하지 않는다.
- GitHub template repository 설정 변경은 이 Work에서 직접 수행하지 않는다.
- 이 repo를 clone/fork/template으로 받아 product project로 직접 전환하는 starter flow는 다루지 않는다.
- Product starter를 위한 실제 sample product code를 추가하지 않는다.
- 신규 `/bootstrap` command를 추가하지 않는다.
- Historical AWH/HRN 기록을 삭제하지 않는다.

## Plan

### Step 1 - Current bootstrap surface review

- `AGENTS.md`, `CLAUDE.md`, `.claude/commands/start.md`, `.claude/commands/pick.md`,
  `.cursor/rules/*`, `prompts/*session-start.md`, `docs/AGENT-WORKFLOW.md`,
  `docs/HARNESS-PROTOCOL.md`, `docs/HARNESS-QUICK-REFERENCE.md`에서 bootstrap load 조건을 확인한다.
- `scripts/create-harness.sh` generated `STATUS.md`, `BOOTSTRAP.md`, README가 one-time flow로 보이는지 확인한다.

### Step 2 - Flow boundary design

- 사용 경로를 아래 두 가지로 제한한다.
  1. Add harness to an existing repository
  2. Work on ai-workflow-harness itself
- 이 repo를 product starter로 직접 사용하는 경로는 명시적으로 제외한다.
- README/manual은 scaffold/adoption flow와 source maintainer flow만 구분한다.

### Step 3 - Command decision

- 신규 `/bootstrap` command는 만들지 않는다.
- `/start`는 `docs/BOOTSTRAP.md` 존재 여부를 확인하지 않는다.
- `/start`는 `STATUS.md` Next Actions가 scaffold bootstrap/onboarding을 명시할 때만 `docs/BOOTSTRAP.md` 확인을 제안한다.

### Step 4 - Approved edits

- 승인된 방향에 따라 canonical -> tool-specific -> user-facing -> scaffold 순서로 반영한다.
- Bootstrap이 완료된 뒤에는 `STATUS.md` Next Actions에서 bootstrap onboarding 항목을 제거하도록 문서화한다.
- `/start` 기본 출력에는 bootstrap 항목을 고정으로 남기지 않는다.

### Step 5 - Validation

- `git diff --check`
- `bash -n scripts/create-harness.sh`
- generic dry-run
- fresh temp scaffold 생성
- `/start` 시뮬레이션:
  - 현재 ai-workflow-harness repo에서는 bootstrap 항목이 출력되지 않아야 한다.
  - fresh scaffold에서는 `STATUS.md` Next Actions가 bootstrap onboarding을 명시하므로 bootstrap 안내가 가능해야 한다.
  - bootstrap 완료 후에는 daily `/start`에서 bootstrap을 다시 언급하지 않아야 한다.

## Done Criteria

- [x] Bootstrap load 조건이 one-time flow로 정리됨
- [x] `/start` default output에서 bootstrap 필요 여부가 제거되거나 조건부로만 동작함
- [x] Source maintainer flow와 scaffold/adoption flow가 README/manual에 반영됨
- [x] `/bootstrap` command를 도입하지 않는 결정이 tool/user/scaffold surface에 반영됨
- [x] scaffold 산출물에서 bootstrap onboarding -> completion 흐름이 설명됨
- [x] validation command와 fresh scaffold 검증이 통과함
- [x] STATUS/Tracking finalization 필요 여부가 보고됨

## Checkpoints

### CP-1: Work registration

- HRN-025 Work 파일 생성
- Harness Work index 등록
- HRN-024는 현재 상태로 pending 유지
- Status: Done

### CP-2: Design review

- One-time bootstrap 원칙 정리
- Source maintainer flow와 scaffold/adoption flow 차이 정리
- `/bootstrap` command 미도입 결정 정리
- Status: Ready for next session

### CP-3: Alignment patch

- 승인된 문서, command, prompt, scaffold 변경 반영
- Status: Done

### CP-4: Validation and report

- validation command 실행
- fresh scaffold와 `/start` 시뮬레이션 결과 기록
- Status: Done

## Discovery

- 2026-05-22: User feedback으로 bootstrap이 매 `/start`마다 점검되면 안 된다는 문제가 확인됐다. Bootstrap은 scaffold 직후 one-time onboarding flow로 격리해야 한다.
- 2026-05-22: Public 사용자가 이 repo를 clone/fork/template으로 받아 product project를 시작하는 starter flow도 후보로 검토했으나, 2026-05-23에 HRN-025 범위에서 제외했다.
- 2026-05-22: 신규 `/bootstrap` command는 daily `/start` noise를 줄이고 최초 부팅 discoverability를 높일 수 있는 후보였으나, starter flow 제외 후 도입하지 않기로 재판단했다.
- 2026-05-22: 이전에는 `/bootstrap` command 또는 동등한 explicit intent를 검토했으나, 2026-05-23 결정으로 `/start` 조건 tightening으로 대체했다.
- 2026-05-23: User decision으로 clone/fork/template 기반 product starter 시나리오는 HRN-025 범위에서 제외했다. Product 적용은 `scripts/create-harness.sh` scaffold/adoption flow로 한정한다.
- 2026-05-23: Starter flow를 제외하니 신규 `/bootstrap` command 도입 근거가 약해졌다. `/bootstrap`은 도입하지 않고, `/start`가 `STATUS.md` Next Actions의 bootstrap onboarding pointer를 조건부로 해석하도록 좁히는 방향으로 수정한다.
- 2026-05-23: CP-3 alignment patch 완료. `AGENTS.md`, `CLAUDE.md`, `.claude/commands/start.md`, Cursor rules, session prompts, README, manual/summary, scaffold script를 `STATUS.md` Next Actions 기반 bootstrap onboarding으로 정렬했다.
- 2026-05-23: CP-4 validation 완료. `git diff --check`, `bash -n scripts/create-harness.sh`, generic dry-run, fresh scaffold 생성이 통과했다. Fresh scaffold의 `/start` command는 `BOOTSTRAP.md` 존재 여부를 확인하지 않고, generated `STATUS.md` Next Actions의 scaffold bootstrap onboarding pointer를 후속 로드 조건으로 사용한다.
- 2026-05-23: Bootstrap onboarding pointer가 자동 제거되지 않는 구조적 리스크를 보완했다. `docs/SCAFFOLD-BOOTSTRAP.md`, generated `docs/BOOTSTRAP.md`, README, manual에 완료 후 `docs/STATUS.md` Next Actions에서 scaffold bootstrap/onboarding 항목을 제거하거나 다음 실제 작업으로 교체하라는 completion rule을 명시했다.
- 2026-05-23: Session-start fallback prompt의 부정형 반복 문구를 제거했다. `prompts/*session-start.md`는 context priority 또는 핵심 기준에서 bootstrap/onboarding 조건만 짧게 유지하고, 강한 규칙은 `AGENTS.md`, `CLAUDE.md`, `docs/AGENT-WORKFLOW.md`, `.claude/commands/start.md`에 둔다.
- 2026-05-23: Final review follow-up을 반영했다. `docs/SCAFFOLD-BOOTSTRAP.md` First Prompt 사용 조건, fallback Work Selection prompt의 bootstrap pointer 조건, scaffold CLI 출력 wording을 정렬했고 Done Criteria를 충족 상태로 체크했다.

## Next Session Plan

### Accepted Direction

- `/bootstrap` command는 도입하지 않는다.
- `/start`는 `docs/BOOTSTRAP.md` 존재 여부를 매번 확인하지 않는다.
- Bootstrap은 scaffold/adoption 직후 generated `STATUS.md` Next Actions가 bootstrap onboarding을 가리킬 때만 조건부로 확인한다.
- Bootstrap 완료 후에는 `STATUS.md` Next Actions에서 bootstrap onboarding pointer를 제거한다.

### Entry Paths

| Path | 대상 | 첫 진입 | 목적 |
| --- | --- | --- | --- |
| Adoption flow | 기존 repo에 harness를 심는 사용자 | `scripts/create-harness.sh` 후 `/start` | generated `STATUS.md` Next Actions를 따라 scaffold 산출물을 채우고 Product/Harness backlog를 만든다 |
| Source maintainer flow | 이 repo 자체를 개선하는 maintainer | `/start` | HRN/AWH 중심 Harness track 작업을 이어간다 |

### Patch Order

1. Canonical: `docs/AGENT-WORKFLOW.md`, `docs/HARNESS-PROTOCOL.md`, `docs/SCAFFOLD-BOOTSTRAP.md`
2. Tool-specific: `AGENTS.md`, `CLAUDE.md`, `.claude/commands/start.md`, `.cursor/rules/*`, `prompts/*session-start.md`
3. User-facing: `README.md`, `docs/WORKFLOW-MANUAL.md`, summary 문서
4. Scaffold: `scripts/create-harness.sh` generated README/STATUS/BOOTSTRAP

### STATUS.md Proposal For Next Session

`docs/STATUS.md`는 별도 state-change approval 후 아래처럼 정리한다.

- Active Work에 `HRN-025`를 추가한다.
- `HRN-024`는 아직 `Done`이 아니므로 Active에 남기되, 현재 보류 상태임을 `Next Actions` 또는 Work Discovery 기준으로 해석한다.
- `Next Actions`는 HRN-025 CP-3 `/start` bootstrap 감지 조건 tightening과 validation을 가리키도록 교체한다.
- HRN-025 완료 후 HRN-024를 `/close`할지, 남은 문서 정합성 범위를 재개할지 다시 판단한다.
