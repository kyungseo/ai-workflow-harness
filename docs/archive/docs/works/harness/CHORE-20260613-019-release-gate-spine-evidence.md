---
id: CHORE-20260613-019
priority: P2
status: Archived
risk: L2
scope: release 검증 두 체계의 연결 gap만 닫는다. 루트 `docs/GIT-WORKFLOW.md` §3-1 Public Clean Baseline Gate에 deterministic spine(`run-harness-checks.sh --all`)·Release Full Sweep 통과 evidence row를 추가하고, §3-1 ↔ `VERIFICATION-COMMANDS.md` Release Full Sweep 상호 pointer를 건다. scaffold 템플릿(`scripts/templates/source-gitflow/docs/GIT-WORKFLOW.md`) 미변경, CI/pre-commit 배선 없음(DR-036 유지), 새 스크립트 없음.
appetite: 0.25d
planned_start: 2026-06-13
planned_end: 2026-06-13
actual_end: 2026-06-13
related_dr: [DR-036]
related_troubleshooting: []
related_work: [CHORE-20260613-018, CHORE-20260611-005, CHORE-20260611-009]
---

# CHORE-20260613-019: Release gate ↔ validation spine evidence 연결

## Top Summary

- **목표:** release 직전 검증의 두 체계 — `GIT-WORKFLOW.md §3-1 Public Clean Baseline Gate`(state cleanliness)와 `VERIFICATION-COMMANDS.md Release Full Sweep`(surface 전수 + repo-health umbrella) — 가 서로를 명시하지 않아 끊겨 있는 gap을 닫는다.
- **왜 지금:** CHORE-20260613-018에서 mirror parity가 `run-harness-checks.sh --all`에 자동 편입됐으나, release gate(§3-1)는 spine 전수 통과를 evidence row로 요구하지 않는다. release 직전에 "검증 스크립트가 통과했다"는 증거가 gate 체크리스트에 없다.
- **핵심 경계:** 루트 운영 문서(`GIT-WORKFLOW.md` §3-1)와 source-only catalog(`VERIFICATION-COMMANDS.md`)만 수정. 둘 다 leak-scan 무관. scaffold 템플릿은 의도적으로 분리 유지(adopter §3-1은 source-only 도구 미참조 generic). 최소 연결만 — §3-1을 sweep 전체로 부풀리지 않는다.
- **역할:** Claude author + self red-team(plan + result).

## Red Team — 착수 전 자기검토

| # | 공격 | 판정 |
| --- | --- | --- |
| RT1 | `GIT-WORKFLOW.md`가 source-gitflow scaffold shipped라면 source-only 토큰(`run-harness-checks.sh`, `Release Full Sweep`) 삽입 시 leak-scan FAIL | **무위험.** scaffold는 별도 템플릿(`scripts/templates/source-gitflow/docs/GIT-WORKFLOW.md`)을 ship한다(create-harness.sh:559). 루트 `docs/GIT-WORKFLOW.md`는 source repo 운영 문서로 scaffold 출력이 아니며 leak-scan 대상이 아니다. 실측으로 확인 |
| RT2 | 정례화 프레임을 새로 만드는 중복 작업? | 아니다. Release Full Sweep preset + repo-health Layer K umbrella는 이미 존재. 이 Work는 §3-1 gate가 그것을 evidence로 명시하지 않는 연결 gap만 닫는다 |
| RT3 | F2/DR-036(runner 무배선)과 충돌? | 충돌 없음. release 직전 수동 정례 실행은 taxonomy가 이미 권장(§4 실행 기준). CI/pre-commit 자동 배선이 아니다 |
| RT4 | §3-1을 Release Full Sweep 전체로 확장하면 중복·비대 | evidence row 2개 + 상호 pointer라는 최소 연결에 그친다. sweep 상세는 VERIFICATION-COMMANDS가 SSoT |

## Scope / Non-Goals

### Scope

1. 루트 `docs/GIT-WORKFLOW.md` §3-1 표에 evidence row 2개 추가:
   - Validation spine — `bash scripts/tests/run-harness-checks.sh --all` OVERALL PASS
   - Surface sweep — Release Full Sweep 출하표면 P0/P1 = 0
2. §3-1 ↔ `VERIFICATION-COMMANDS.md` Release Full Sweep 상호 pointer.

### Non-Goals

- scaffold 템플릿(`scripts/templates/source-gitflow/docs/GIT-WORKFLOW.md`) 변경 — 의도적 분리 유지
- §3-1을 Release Full Sweep 전체로 확장
- `run-harness-checks.sh`를 CI/pre-commit에 배선(DR-036 무배선 유지)
- 새 스크립트·새 검증 항목 추가

## Files

| File | Plan |
| --- | --- |
| `docs/GIT-WORKFLOW.md` | §3-1 evidence row 2개 + Release Full Sweep 상호 pointer |
| `docs/maintainer/VERIFICATION-COMMANDS.md` | Release Full Sweep → §3-1 역pointer |
| `docs/works/harness/CHORE-20260613-019-release-gate-spine-evidence.md` | Work SSoT |

## Done Criteria

- [x] §3-1에 Validation spine / Surface sweep evidence row 2개 추가
- [x] §3-1 ↔ Release Full Sweep 상호 pointer 정합
- [x] 템플릿 GIT-WORKFLOW.md 미변경 확인(`git status`에 `scripts/templates/**` 없음)
- [x] `run-harness-checks.sh --all` OVERALL PASS (leak-scan [2] 3모드 green — 루트 문서 변경이 spine/scaffold 출력에 영향 없음)
- [x] mirror parity가 `--all`에 이미 편입돼 별도 추가 불필요함을 evidence row 괄호에 반영
- [x] result self red-team

## Verification

- `bash scripts/tests/run-harness-checks.sh --all` → OVERALL PASS (leak-scan [2] default/optional/source-gitflow 3모드 green)
- `git diff --check` clean
- 변경 파일 `scripts/templates/**` 미포함 → 템플릿 무변경 확정

## Checkpoints

| CP | 내용 | 상태 |
| --- | --- | --- |
| CP0 | branch + Work 파일 (STATUS Active pointer는 단일세션 시작-완료라 생략, README에 Done으로 직접 등재) | 완료 |
| CP1 | §3-1 evidence row 2개 + §3-1↔sweep 상호 pointer + sweep spine 자동화 안내 | 완료 |
| CP2 | --all 검증 + result red-team | 완료 |

## Result Red Team (구현 후 자기검토)

| # | 공격 | 판정 |
| --- | --- | --- |
| RR1 | 루트 GIT-WORKFLOW 변경이 leak-scan/scaffold 출력에 영향? | **무위험 실측.** `--all` leak-scan [2] 3모드 PASS. 루트는 scaffold 출력 아님 |
| RR2 | §3-1↔sweep 상호 pointer가 순환 참조로 혼란? | 역할 분리 명확 — §3-1=state cleanliness, sweep=surface 전수(SSoT). 순환 아닌 상보 |
| RR3 | scaffold 적용 repo가 §3-1의 `run-harness-checks.sh --all`을 못 돌림? | evidence row는 **루트(source) §3-1에만** 추가. 템플릿 §3-1 미변경(source-only 도구 미참조), 도입부에 "source repo 기준, scaffold repo 자체 결정" 명시 |
| RR4 | §3-1을 sweep 전체로 부풀림? | evidence row 2개 + pointer만. sweep 상세 SSoT는 VERIFICATION-COMMANDS 유지 |

**종합:** release 검증 두 체계(state gate ↔ surface sweep)의 연결 gap을 최소 변경으로 닫음. adopter 분리·DR-036 무배선 기조 보존.

## Discovery

- 검토 1(릴리즈 검증 정례화) 사용자 승인 착수. 검토 단계에서 leak-scan 제약(RT1)을 실측해 루트/템플릿 분리를 확인, 루트 문서만 수정하는 최소 경로로 확정.

## Next Actions

1. §3-1 evidence row + 상호 pointer 구현.
2. 검증 후 result red-team, work-close.
