---
id: CHORE-20260614-001
priority: P2
status: Archived
risk: L2
scope: release 후 "절차를 따랐는지"가 아니라 "결과가 실제 맞는지"를 검증하는 최소 1줄씩을 기존 절차에 흡수한다. (1) develop↔main sync 결과 검증(`develop..main` empty)은 **generic**이므로 루트 `docs/GIT-WORKFLOW.md` §3-4 + scaffold 템플릿 `scripts/templates/source-gitflow/docs/GIT-WORKFLOW.md` §3-4 양쪽에 범용문으로 추가. (2) release tag 정합(`ai-workflow-v{VERSION}`)은 source-only이므로 `docs/maintainer/VERSIONING.md` §3 step5에만 추가(템플릿 제외). 독립 post-release 절차 블록 신설은 비범위.
appetite: 0.1d
planned_start: 2026-06-14
planned_end: 2026-06-14
actual_end: 2026-06-14
related_dr: []
related_troubleshooting: []
related_work: [CHORE-20260613-019]
---

# CHORE-20260614-001: Post-release 결과 검증 최소 보완

## Top Summary

- **목표:** v1.2.0 release 직후 수동으로 한 post-release 점검(develop sync 결과, tag 정합)을 절차에 흡수한다. 단 독립 블록이 아니라 기존 §3-4/VERSIONING에 verification 1줄씩.
- **왜:** §3-4는 develop sync를 `git status`(약한 신호)로만 확인하고, tag는 VERSIONING이 생성만 명시한다. "절차 수행" ≠ "결과 정합"이라 결과 검증 step이 빠져 있었다(develop sync 누락은 GIT-WORKFLOW가 `NEVER`로 경고하는 알려진 실수 지점).
- **Red Team:** 독립 §3-6 신설은 §3-4/§2-5/VERSIONING과 중복이라 과잉. 실질 gap은 결과 검증 2줄뿐. SSoT 분리 — sync는 §3-4(branch flow), tag는 VERSIONING(version).

## Scope / Non-Goals

### Scope
1. 루트 `docs/GIT-WORKFLOW.md` §3-4 + 템플릿 §3-4: develop sync 결과 검증 `git log origin/develop..origin/main`(empty) 범용문. (generic 절차라 템플릿 동반 — `develop..main`은 source-only 토큰 아님)
2. `docs/maintainer/VERSIONING.md` §3 step5: `ai-workflow-v{VERSION}` tag 정합 확인 추가(source-only, 템플릿 제외).

### Non-Goals
- 독립 post-release 점검 절차 블록 신설
- 템플릿 §3-4에 `ai-workflow-v` tag / VERSIONING pointer 삽입(source-only — adopter는 자체 tag 정책)
- §2-5 cleanup / §3-4 sync 액션 자체 재작성
- release-prep §3-0 재작성(이미 루트/템플릿 정합·leak-safe 확인)

## Done Criteria

- [x] §3-4에 `develop..main` empty 검증 1줄 추가 — **루트 + 템플릿 양쪽**(generic 절차)
- [x] VERSIONING §3 step5에 `ai-workflow-v{VERSION}` tag 정합 확인 추가(source-only, 템플릿 제외)
- [x] `run-harness-checks.sh --all` OVERALL PASS, leak-scan [2] 3모드 green (템플릿 §3-4 추가가 source-only 토큰 아님 실측)
- [x] release-prep §3-0 루트/템플릿 정합·leak-safe 재확인(추가 작업 불필요)
- [x] result self red-team

## Verification

- `bash scripts/tests/run-harness-checks.sh --all` → OVERALL PASS (leak-scan green), `git diff --check` clean
- 템플릿 §3-4에 `develop..main` 추가, `ai-workflow-v`/VERSIONING pointer는 미삽입 확인

## Checkpoints

| CP | 내용 | 상태 |
| --- | --- | --- |
| CP0 | branch + Work 파일 | 완료 |
| CP1 | 루트 §3-4 + 템플릿 §3-4 + VERSIONING 보완 | 완료 |
| CP2 | --all 검증(leak-scan) + result red-team | 완료 |

## Result Red Team (구현 후 자기검토)

| # | 공격 | 판정 |
| --- | --- | --- |
| RR1 | 템플릿 §3-4에 verification 추가 → leak-scan FAIL? | **무위험 실측.** `develop..main`은 generic(source-only 토큰 아님). `--all` leak-scan [2] 3모드 PASS |
| RR2 | sync 검증을 generic으로 본 게 맞나(템플릿 동반 정당)? | ✓. adopter도 develop→main flow면 동일 적용. CHORE-019 §3-1(`run-harness-checks` source 도구)과 성격이 다름 |
| RR3 | 루트 §3-4(VERSIONING pointer 포함) vs 템플릿(제외) 차이 | 의도적 — tag 정합은 source-only이므로 루트만 pointer. 일관 |
| RR4 | release-prep §3-0가 템플릿에 leak되진 않았나 | 검토: 템플릿 §3-0는 범용문(project-specific version/build·test)으로 이미 들어가 있고 source-only 토큰 0 → leak-safe. 추가 작업 불필요 |

## Discovery

- v1.2.0 release 직후 post-release 정합을 수동 점검하며 "결과 검증 step 부재"를 발견. 사용자와 "독립 절차는 과잉, 최소 보완" 합의.
- 사용자 지적으로 scope 보정: sync 검증은 generic → 템플릿 동반, tag 정합은 source-only → VERSIONING만. release-prep §3-0 템플릿 반영도 함께 검토(정합·leak-safe).
- 2026-06-15 archive: Done 상태로 archive 대기 중이던 항목을 CHORE-20260615-001(Recent Decisions rolling-trim) 작업 중 drain.
