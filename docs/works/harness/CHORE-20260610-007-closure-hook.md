---
id: CHORE-20260610-007
priority: P1
status: Done
risk: L2
scope: shipped DR reference closure(DR-033) static check를 pre-commit hook으로 하드 게이트화한다. soft(AI 재량) → hard(자동 차단). scaffold 고려: 배포되는 pre-commit에 closure 블록을 넣되 check 스크립트 존재 가드로 source repo만 실행, target은 no-op(scaffold가 scripts/tests 미복사). DR-033 enforcement이므로 신규 DR 없이 DR-033 amend.
appetite: 0.5d
planned_start: 2026-06-10
planned_end: 2026-06-10
actual_end: 2026-06-10
related_dr: [DR-033, DR-025]
related_troubleshooting: []
related_work: [CHORE-20260610-005]
---

# CHORE-20260610-007: Shipped DR closure check pre-commit hook 게이트화

## Top Summary

- **목표:** DR-033 closure check를 pre-commit hook으로 자동 강제. A+B(soft, AI 재량)가 이번 세션에 실제로 뚫린(규약 저자가 직후 위반) 근거로 hard gate 추가.
- **scaffold 고려 (사용자 명시):** pre-commit은 source-gitflow target에 배포(기존 배선 `create-harness.sh:558`). check 스크립트 `scripts/tests/check-shipped-dr-closure.sh`는 scaffold 미배포 → 배포된 hook에 **존재 가드**를 두어 target에선 자동 no-op.

## 설계

- `tools/git-hooks/pre-commit`(POSIX sh, `set -eu`)에 블록 추가:
  - 가드 `[ -f "$ROOT/scripts/tests/check-shipped-dr-closure.sh" ]` → source repo만.
  - 성공 출력 억제(`OUT=$(... 2>&1)`), 실패 시만 위반 표시 + `exit 1`.
  - 매 commit 실행(스크립트가 전체 repo 스캔이라 staged 무관 — drift 차단 단순·확실).
- DR-033 Consequences에 hook enforcement 1줄.
- docs-workflow rule + VERIFICATION-COMMANDS: soft→hard("source repo pre-commit이 자동 강제") 갱신.

## Scope / Plan

| 파일 | 작업 |
| --- | --- |
| `tools/git-hooks/pre-commit` | 가드된 closure 블록 |
| `docs/decisions/DR-033-shipped-dr-reference-closure.md` | Consequences에 hook enforcement |
| `.claude/rules/docs-workflow.md` | "pre-commit이 자동 강제" 명시 |
| `docs/maintainer/VERIFICATION-COMMANDS.md` Layer I | hook 자동 실행 명시 |

## Done Criteria

- [x] pre-commit에 가드된 closure 블록, `sh -n` OK (설치 hook은 symlink → 즉시 live)
- [x] 의도적 위반(DR-997) 주입 시 commit **차단** 확인(exit 1, HEAD 불변), 정상 시 통과(성공 출력 억제)
- [x] scaffold(`--workflow source-gitflow`) target pre-commit에 블록 존재 + 스크립트 부재 → 가드 **no-op** 확인
- [x] DR-033 Consequences amend + docs-workflow/VERIFICATION-COMMANDS soft→hard 갱신
- [x] closure check green, `git diff --check` clean

## Verification 결과

- inject-revert: shipped 문서에 `DR-997` body 주입 → `git commit` 차단(VIOLATION + ERROR + exit 1, HEAD `3b03337` 불변) → revert clean.
- scaffold target: `tools/git-hooks/pre-commit`에 closure 블록 1건 존재, `scripts/tests/check-shipped-dr-closure.sh` 부재 → 가드 false → no-op.
- `sh -n tools/git-hooks/pre-commit` OK, closure check green.

## Verification

- `sh -n tools/git-hooks/pre-commit`
- inject-revert: shipped 문서에 비-seed DR 주입 → `git commit` 차단(exit 1) 확인 → revert
- scaffold 생성(temp/) → `temp/<t>/tools/git-hooks/pre-commit`에 블록 있으나 `temp/<t>/scripts/tests/...` 없음 → no-op
- `git diff --check`

## Risk / Reversal

- 리스크: hook이 매 commit 실행 → 성능. ~0.1s source-only라 무시 가능. 오탐 시 commit 막힘 → 가드/출력 명확화로 완화.
- 되돌리기: Low. pre-commit 블록 제거. branch 단위.

## Discovery

- backlog closure guard 후속 — A+B soft enforcement가 세션 내 실제로 뚫린(규약 저자 직후 위반) 근거로 C(hook) 추가 결정. 사용자 승인 + scaffold 고려 명시.

## Checkpoints

- (착수) 2026-06-10 branch + Work 파일.
- 2026-06-10 실행 완료 — pre-commit 가드 블록 + DR-033 amend + docs-workflow/VERIFICATION-COMMANDS soft→hard. 검증: inject-revert로 commit 차단 확인, scaffold target no-op 확인.

## Next Actions

- pre-commit 블록 → DR-033/rule/VERIFICATION 갱신 → inject-revert 검증 + scaffold no-op 검증 → `/work-close`.
