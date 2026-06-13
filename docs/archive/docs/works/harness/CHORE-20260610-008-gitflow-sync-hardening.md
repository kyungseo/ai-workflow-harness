---
id: CHORE-20260610-008
priority: P1
status: Archived
risk: L2
scope: GIT-WORKFLOW.md에 feature↔develop sync 지침과 hotfix cycle 등 일반 gitflow 공백을 보강한다. 5항목 — §2-3(신설) Sync With Develop, 충돌 해소, force-push 정책, §3-5(신설) Hotfix Cycle + develop 역병합, cascade(template + .claude rule pointer). repo본 docs/GIT-WORKFLOW.md와 scaffold 배포 template 동시 반영. 신규 DR 없이 DR-017(merge strategy) 운영 연장으로 본문 참조.
appetite: 0.5d
planned_start: 2026-06-10
planned_end: 2026-06-10
actual_end: 2026-06-10
related_dr: [DR-017]
related_troubleshooting: []
related_work: []
---

# CHORE-20260610-008: Gitflow sync/hotfix 공백 보강

## Top Summary

- **목표:** feature 작업 중 develop이 앞서 나갔을 때의 sync 지침이 §2에 전혀 없던 공백을 메우고, 일반 gitflow 필수 요소(hotfix→main 후 develop 역병합, force-push 정책)를 보강한다.
- **핵심 관점(사용자):** rebase 메커닉이 아니라 **commit/push 직전 develop 최신 변경을 끌어와 미리 반영하는 습관** 자체가 본질. 당연하지만 누락되기 쉬운 routine을 문서로 고정.
- **이 repo 특수성:** feature→develop은 **squash merge**(DR-017 Amended)라 rebase vs merge가 결과 history에 무차이 → merge를 안전 기본값으로, rebase는 push 전 로컬 전용 커밋 한정 선택지로 문서화. 관례(정기 sync)는 수용.

## Scope / Plan (5항목)

| # | 보강 | 위치 | 파일 |
| --- | --- | --- | --- |
| 1 | §2-3(신설) Sync With Develop — 언제/어떻게(merge 기본·rebase 한정) | §2 (기존 2-3→2-4, 2-4→2-5 시프트) | GIT-WORKFLOW.md + template |
| 2 | 충돌 해소 — sync 시 + PR 단계 | §2-3 내 | 동상 |
| 3 | force-push 정책 — `--force-with-lease`는 본인 feature 한정 | §2-3 내 | 동상 |
| 4 | §3-5(신설) Hotfix Cycle — hotfix→main PR 후 develop 역병합 | §3 | 동상 |
| 5 | cascade — `.claude/rules/git-workflow.md` Branch Flow에 sync pointer 1줄 | rule | .claude/rules/git-workflow.md |

제외: 장기/abandon 브랜치, stash·cherry-pick·bisect 일반 git, 병렬 feature(=HARNESS-PARALLEL-WORK-CONTROLS.md cross-link만).

## Done Criteria

- [x] repo본 `docs/GIT-WORKFLOW.md`에 §2-3 Sync, §3-5 Hotfix Cycle 반영 + 후속 §번호 시프트 정합 (2-3→2-4→2-5, 3-5 신설)
- [x] template `scripts/templates/source-gitflow/docs/GIT-WORKFLOW.md` 동일 §2/§3 반영 (env/CI/hook 고유 diff 보존)
- [x] `.claude/rules/git-workflow.md` Branch Flow에 Sync Before PR pointer + §2-4→§2-5 stale 참조 수정
- [x] (cascade parity) `AGENTS.md` Codex 어댑터에 동일 sync 미러 + §2-4→§2-5 수정
- [x] repo본↔template본 §2/§3 sync 의미 정합 diff 확인 (병렬작업 1줄만 의도적 차이)
- [x] `git diff --check` clean, DR-007 점검, `bash -n scripts/create-harness.sh`, shipped DR closure check green

## Verification

- repo본/template본 §2·§3 헤더 시퀀스 grep으로 번호 정합 확인
- `diff docs/GIT-WORKFLOW.md scripts/templates/source-gitflow/docs/GIT-WORKFLOW.md` — 신규 sync/hotfix 의미가 양쪽 동일, 기존 환경 고유 diff만 잔존
- `git diff --check`
- `bash -n scripts/create-harness.sh`

## Risk / Reversal

- 리스크: Low (문서 한정, 런타임 영향 없음). §번호 시프트가 cross-reference를 깰 위험 → §2-3/§2-4 참조처 grep 확인으로 완화.
- 되돌리기: Low. 단일 PR revert. branch 단위.

## Verification 결과

- repo/template §2·§3 헤더 시퀀스: 2-1·2-2·2-3(Sync)·2-4(PR)·2-5(Cleanup), 3-1~3-4·3-5(Hotfix) 양쪽 평행.
- 잔존 `§2-4` 참조 2건은 PR Creation 정참조(squash merge 기술 위치) — stale 아님.
- repo↔template §2-3 diff: 병렬작업 pointer 1줄만 의도 차이(source-only doc vs generic), §3-5 동일.
- `bash -n scripts/create-harness.sh` OK, shipped DR closure check green(§2-3 인용 DR-017 seed 닫힘), `git diff --check` clean.

## Checkpoints

- (착수) 2026-06-10 branch `feature/chore-20260610-008-gitflow-sync-hardening` + Work 파일.
- 2026-06-10 실행 완료 — repo/template GIT-WORKFLOW §2-3 Sync·§3-5 Hotfix 신설, §2-4→§2-5 시프트, .claude rule + AGENTS.md sync pointer·참조 수정. cascade parity 검증 통과.

## Next Actions

- GIT-WORKFLOW.md repo본 §2-3/§3-5 → template 동일 반영 → rule pointer → cascade diff/검증 → `/work-close`.
