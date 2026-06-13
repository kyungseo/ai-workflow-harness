---
id: CHORE-20260613-014
priority: P2
status: Archived
risk: L2
scope: `scripts/create-harness.sh`가 default scaffold에서 `.cursor/rules/workflow.mdc`를 temp 파일 경유로 생성할 때 `.harness/manifest.json`의 `src`에 ephemeral temp 경로를 기록하는 결함을 수정한다. manifest 자기일관성(`--check`, tier2 invariant)만 바로잡고, CI parity/F1-F4 follow-up으로 범위를 넓히지 않는다.
appetite: 1d
planned_start: 2026-06-13
planned_end: 2026-06-13
actual_end: 2026-06-13
related_dr: []
related_troubleshooting: []
related_work: [CHORE-20260613-011, CHORE-20260613-013]
---

# CHORE-20260613-014: workflow.mdc Temp-src Manifest Drift Fix

## Top Summary

- **목표:** default scaffold에서 `.cursor/rules/workflow.mdc`가 temp 파일을 거쳐 생성될 때 manifest `src`가 canonical template-relative path를 기록하도록 고친다.
- **문제:** 현재는 `_AWH_WF_TMP` 절대 경로가 `src`에 기록되어 생성 직후에도 `scripts/create-harness.sh --check`가 `source-missing` 1건을 내고, `run-harness-checks.sh --tier2`의 self-consistency invariant가 deterministic하게 FAIL한다.
- **비범위:** `CI inline assertion ↔ invariants SSoT parity`, `Validation Spine residual F1/F3/F4`, runner wiring 재논의는 이번 Work에 포함하지 않는다.
- **시발점:** backlog candidate `scaffold manifest src가 workflow.mdc를 temp 경로로 기록 (tier2 self-consistency FAIL)` 착수.

## Context Manifest

| 순서 | 파일 | 섹션 | 왜 |
| --- | --- | --- | --- |
| 1 | `docs/backlog/HARNESS.md` | `scaffold manifest src가 workflow.mdc를 temp 경로로 기록` | 후보 정의, Done Criteria, Verification 기준 |
| 2 | `scripts/create-harness.sh` | `adapt()` / `workflow.mdc` 분기 / manifest write | 결함 원인과 수정 지점 |
| 3 | `scripts/tests/check-scaffold-invariants.sh` | `[5] manifest + --check 자기일관성` | tier2 FAIL 판정 기준 |
| 4 | `scripts/tests/run-harness-checks.sh` | `--tier2` | 최종 검증 엔트리 |

Trigger: backlog candidate 착수 / session-start 후보 비교에서 유일 deterministic FAIL로 식별.

## Scope

1. `scripts/create-harness.sh`에서 temp 파일 경유 `adapt()` 호출이 manifest에 canonical `src`를 기록하도록 최소 수정한다.
2. 같은 패턴의 temp 경유 manifest 오염이 다른 경로에도 있는지 grep 수준으로 확인한다.
3. fresh scaffold 기준 `--check`와 tier2 self-consistency가 복구되는지 검증한다.

## Done Criteria

- [x] fresh scaffold에서 `scripts/create-harness.sh --check <target>`가 `.cursor/rules/workflow.mdc`를 `source-missing`으로 보고하지 않는다.
- [x] `bash scripts/tests/run-harness-checks.sh --tier2`가 PASS 한다.
- [x] 생성된 `.harness/manifest.json`에서 `workflow.mdc`의 `src`가 temp 경로(`/var/folders`, `tmp.`)를 포함하지 않는다.
- [x] 범위가 `workflow.mdc temp-src` 결함에 머물고, parity/F1-F4 후보는 backlog 분리 상태를 유지한다.

## Verification

```bash
bash -n scripts/create-harness.sh
bash scripts/tests/run-harness-checks.sh --tier2
scripts/create-harness.sh --check <fresh-target>
rg -n 'workflow\.mdc|/var/folders|tmp\.' <fresh-target>/.harness/manifest.json
```

## Checkpoints

| CP | Description | Status |
|----|-------------|--------|
| 1 | Work 파일 생성 + Active pointer 반영 | ✓ |
| 2 | temp-src 원인 고정 + 최소 수정 | ✓ |
| 3 | tier2 / --check 검증 | ✓ |

## Next Actions

- ✓ Work 파일 생성, `docs/works/harness/README.md` / `docs/STATUS.md` Active pointer 추가
- ✓ `scripts/create-harness.sh` 수정으로 stable filtered template 경로를 manifest anchor로 고정
- ✓ tier2 및 fresh scaffold `--check` 검증
- ✓ closeout 범위 및 commit 후보 판단 완료
- → archive 여부는 별도 승인 또는 다음 `/session-start`에서 판단

## Discovery

- 2026-06-13: backlog candidate 착수. branch는 `feature/chore-20260613-011-f2-wiring-decision`, source-gitflow Branch Isolation Check PASS.
- 2026-06-13: 결함 원인 확인 — default scaffold에서 `grep -v "work-doc"` 결과를 `_AWH_WF_TMP`에 쓴 뒤 `adapt "${_AWH_WF_TMP}" ...`를 호출하면서 manifest `src`가 template-relative가 아니라 temp absolute path로 기록된다.
- 2026-06-13: 단순 `src` 문자열 치환은 hash/render baseline을 깨뜨리므로 기각. `scripts/templates/default/.cursor/rules/workflow.mdc` stable filtered template를 추가하고 default scaffold가 이를 직접 adapt하도록 수정.
- 2026-06-13: 검증 결과 — `bash scripts/tests/run-harness-checks.sh --tier2` PASS, fresh scaffold `scripts/create-harness.sh --check /private/tmp/awh-manifest-check-20260613` = `69 tracked, 69 in-sync, 0 drifted`.
- 2026-06-13: fresh scaffold manifest 확인 — `.cursor/rules/workflow.mdc` entry의 `src`가 `scripts/templates/default/.cursor/rules/workflow.mdc`로 기록되어 temp 경로 누출이 제거됨.
- 2026-06-13: 후속 Work CHORE-20260613-015 closeout과 함께 archive 처리. live `docs/works/harness/README.md`의 Done (Archive Pending) row를 제거하고 archive-side index로 이동한다.
