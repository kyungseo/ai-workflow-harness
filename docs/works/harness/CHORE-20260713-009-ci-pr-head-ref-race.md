---
id: CHORE-20260713-009
priority: P1
status: Done
risk: L2
scope: GitHub Actions commit-subject backstop의 post-merge/deleted-branch race 보정. PR event head SHA가 checkout에 없을 때 refs/pull/<number>/head를 조건부 fetch하고, 미복구 시 fail-closed를 유지한다.
appetite: 0.25d
planned_start: 2026-07-13
planned_end: 2026-07-13
actual_end: 2026-07-13
related_dr: []
related_work: []
---

# CHORE-20260713-009: CI PR Head Ref Race Hardening

## Top Summary

병합 완료된 PR #265의 CI가 runner queue 중 feature branch 삭제를 만나 commit-subject backstop에서 `Invalid revision range`로 실패했다. 구현 검증 실패가 아니라 event head object 부재이며, GitHub가 보존하는 `refs/pull/<number>/head`를 조건부 fetch해 같은 race를 복구한다.

## Scope

**포함:**

- `.github/workflows/ci.yml` commit-subject backstop에서 event head SHA 존재 여부 확인
- head object 부재 시 해당 PR의 보존 head ref 조건부 fetch
- fetch 후에도 event SHA가 없으면 명시적으로 실패하는 fail-closed 경계 유지
- PR #265 ref를 이용한 deleted-branch 재현 검증

**비포함:**

- 이미 병합된 PR #265의 historical check를 green으로 덮기 위한 branch 재생성·재실행
- commit message 정책, ruleset, merge 정책 변경
- workflow 구조 refactor 또는 별도 script 추출

## Plan

1. PR #265 run metadata와 실패 log로 race 조건 고정
2. missing head object에만 `refs/pull/<number>/head` fetch 추가
3. 실제 deleted branch + retained PR ref로 복구 경로 재현
4. Tier 0·diff 검증 후 `/work-close`와 commit approval gate 진행

## Done Criteria

- [x] checkout에 event head SHA가 있으면 추가 fetch 없이 기존 검사 수행
- [x] event head SHA가 없고 `refs/pull/<number>/head`가 있으면 복구 후 commit range 검사 수행
- [x] event head SHA가 끝내 없으면 CI가 fail-closed
- [x] PR #265 deleted-branch race 재현 검증 PASS
- [x] Tier 0 및 `git diff --check` PASS

## Verification

- PR #265 evidence: run `29254281342`, job `86830490950`, `Invalid revision range 12a5486...5129c93...`
- branch API: `feature/safety-rule-layer` 404, `refs/pull/265/head` = `5129c93a...`
- isolated temp repository에서 develop만 fetch한 상태의 head object 부재 → PR head ref fetch → `git log BASE..HEAD` 성공 확인
- `bash scripts/tests/run-harness-checks.sh --tier0`
- `git diff --check`

## Risk / Reversal Cost

- **Low:** PR event의 보존 ref를 head object 부재 시에만 fetch한다. 정상 path에는 추가 network call이 없다.
- hidden PR ref가 없거나 event SHA와 연결되지 않으면 기존 fail-closed 동작을 유지한다.
- 단일 workflow hunk revert로 원복 가능하다.

## Discovery

- 2026-07-13: PR #265는 `develop`에 squash merge commit `9b2537a`로 정상 반영됐다. 이후 PR #266~#268 CI도 PASS라 substantive regression은 없다.
- run은 13:34:20 생성됐으나 job은 13:39:18 시작했다. 그 사이 PR이 13:34:26 병합되고 feature branch가 삭제돼 checkout이 event head object를 가져오지 못했다.
- GitHub의 `refs/pull/265/head`는 삭제 후에도 event head SHA를 보존한다. historical red check 정리는 비범위이며 recurrence hardening만 수행한다.

## Checkpoints

- 착수: 사용자 승인 후 `feature/ci-pr-head-ref-race` branch 생성. PLAN 영향 없음, 신규 DR 불필요.
- 완료: `.github/workflows/ci.yml`에 missing-head 조건부 fetch와 최종 object check 추가. isolated temp repo에서 develop만 fetch한 상태의 head 부재를 재현하고 `refs/pull/265/head` 복구 후 `BASE..HEAD` log 성공 확인. Tier 0·`git diff --check` PASS.
- Closeout: historical PR #265 red check는 병합 결과에 영향이 없고 cosmetic 재실행을 위해 삭제 branch를 재생성하지 않는다. backlog·Recent Decisions·PLAN 변경 없음, Needs-Triage 없음.
