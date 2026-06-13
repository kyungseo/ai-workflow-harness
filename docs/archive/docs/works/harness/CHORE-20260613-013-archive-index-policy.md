---
id: CHORE-20260613-013
priority: P2
status: Archived
risk: L2
scope: backlog `Archive 누적 관리 정책`을 종결한다. 누적 실해악을 정량화(≈0, 단 live README hot-path 인덱스 예외)하고 DR-038로 retention=keep-all + archive-side index relocation을 결정한다. works/harness 106행 Archived 인덱스를 archive-side로 이전하고, 이를 전제하는 canonical/protocol/scaffold/rule cascade(DR-016/013 amend 포함)를 일관 정렬한다. prune/rollup/retention은 비범위(기각).
appetite: 1d
planned_start: 2026-06-13
planned_end: 2026-06-13
actual_end: 2026-06-13
related_dr: [DR-013, DR-014, DR-016, DR-031, DR-038]
related_work: [CHORE-20260613-011, CHORE-20260613-012]
---

# CHORE-20260613-013: Archive Accumulation / Index Policy

## Top Summary

- **목표:** backlog `Archive 누적 관리 정책`을 정량 근거로 종결한다. 누적 cost는 ≈0이나 유일 실비용인 **live category README의 hot-path Archived 인덱스**를 archive-side로 이전해 구조 모순을 해소한다.
- **핵심 발견:** archive-side mirrored README는 이미 decisions·retrospectives의 표준 패턴이고, `docs/works/{category}`만 outlier였다. 새 패턴 발명이 아니라 outlier를 기존 패턴에 정합.
- **결정(DR-038):** retention=keep-all(prune/rollup/retention 기각), archive-side index relocation 채택, 전 category 일관 적용, archive-side README는 create-on-first-archive.
- **코웍 구조:** Codex 협업 없음. Claude self red-team 검토를 Round Log에 기록.

## Background / Facts

- 실측: archive works(harness) 105개·전체 150 files/2.1M = cost≈0(자동 로드 안 됨). live `works/harness/README.md` = 130줄 중 106행이 Archived 인덱스, harness work마다 context 로드.
- 3-table live README 패턴 출처: DR-016(56·102), DR-013(권장 섹션 144), HARNESS-PROTOCOL Index Rules(282·286). scaffold가 harness+product README를 동일 3-table로 seed.
- `.claude/rules/docs-workflow.md`는 이미 "add it to the archive index"(별도)를 가정 → DR-016과 내부 불일치.
- DR-031로 product가 harness와 대칭 → 정책은 all {category} 적용.

## Scope / Non-Goals

### Scope

1. DR-038 신규(누적 정량 + B/C/D 기각 + archive-side index 채택).
2. works/harness 106행 Archived 인덱스를 `docs/archive/docs/works/harness/README.md`로 이전, live README는 Active+Done(Pending)+pointer로 trim.
3. cascade 정렬: DR-016 amend, DR-013 amend, HARNESS-PROTOCOL Index Rules/Archive 절차, `/work-close` Archive step, `/work-plan` README 생성 안내, `.claude/rules/docs-workflow.md`, repo-health index 점검.
4. scaffold(`create-harness.sh`): live harness+product README seed를 2-table+pointer로, 완료-이력 pointer(1165), DR-013 seed text(480) 정렬.
5. backlog `Archive 누적 관리 정책` 종결(Summary/Details/Portfolio) + pointer(line 11) + STATUS 갱신.

### Non-Goals

- prune/rollup/retention 구현(DR-038에서 기각).
- 기존 archived 파일 자체 이동/삭제(인덱스만 재배치, 파일은 이미 archive 경로).
- decisions/retrospectives archive README 변경(이미 정합).
- product live works README 신설(이 repo에 없음 — scaffold seed만 정렬).
- Done/Archived 상태 분리, soft 트리거, DR-014 경로 미러링 변경.

## Files

| File | 변경 |
| --- | --- |
| `docs/decisions/DR-038-archive-accumulation-index-policy.md` | 신규 정책 결정 |
| `docs/decisions/DR-016-work-done-archive-trigger.md` | amend — index 위치 |
| `docs/decisions/DR-013-work-file-spec.md` | amend — README 권장 섹션 |
| `docs/decisions/README.md` | DR-038 행 + DR-016/013 status |
| `docs/archive/docs/works/harness/README.md` | 신규 — 106행 이전 |
| `docs/works/harness/README.md` | trim + pointer (+ 013 Active row) |
| `docs/HARNESS-PROTOCOL.md` | Index Rules / Archive 절차 정렬 |
| `skills/workflow/work-close.md` | Archive step → archive-side |
| `skills/workflow/work-plan.md` | README 생성 안내 → 2-table |
| `skills/workflow/repo-health.md` | index 점검 → archive-side 인지 |
| `.claude/rules/docs-workflow.md` | archive index = archive-side 명확화 |
| `scripts/create-harness.sh` | live README seed·pointer·DR-013 seed text |
| `docs/maintainer/VERIFICATION-COMMANDS.md` | J6 Done→Archived 점검 정렬(필요 시) |
| `docs/backlog/HARNESS.md` | 항목 종결 + pointer |
| `docs/STATUS.md` | Recent Decisions + Next Actions (승인 후) |

## Done Criteria

- [x] DR-038이 누적 정량 + B/C/D 기각 + archive-side index 채택을 기록.
- [x] works/harness 106행이 archive-side로 이전, live README trim + pointer.
- [x] DR-016·DR-013 amend, HARNESS-PROTOCOL·work-close·work-plan·repo-health·docs-workflow rule이 archive-side로 정합.
- [x] scaffold가 2-table live README + pointer를 seed(generic 실제 생성 확인).
- [x] scaffold invariant가 live `## Archived` 테이블을 assert하지 않음 확인(미assert — invariant 갱신 불필요).
- [x] backlog 항목 종결 + dangling 0.
- [x] Claude self red-team review가 Round Log에 기록.

## Verification

```bash
git diff --check
bash -n scripts/create-harness.sh
bash scripts/tests/check-shipped-dr-closure.sh
./scripts/create-harness.sh --dry-run --profile generic ci-x /tmp/awh-arch-x   # seed 구조 확인은 실제 생성으로
rg -n "Archived 테이블|3개 테이블|Active/Done/Archived" --glob 'docs/**' --glob 'skills/**' --glob 'scripts/**' --glob '!docs/archive/**' --glob '!docs/works/harness/CHORE-*'
```

- scaffold 실제 생성(temp/) 후 live works README에 `## Archived` 테이블 부재 + pointer 존재 확인.
- `check-scaffold-invariants.sh`가 3-table을 assert하는지 확인.

## Risk / Reversal Cost

| Item | Assessment |
| --- | --- |
| Risk level | L2 — 다중 canonical/protocol/scaffold cascade |
| Reversal cost | Medium. 다중 표면 정합 → 되돌리면 함께 복원. 단 인덱스 행은 무손실 이동 |
| Main risk | half-done이면 canonical이 현실과 모순 → 전 cascade를 한 commit에 묶음 |
| Secondary risk | scaffold invariant가 3-table assert → CI/runner 실패. dry-run+invariant 확인으로 통제 |
| Scope risk | ≈0 harm 대비 cascade가 큼 → 구조 불일치 해소라는 명확한 근거로 한정, prune/rollup으로 번지지 않게 차단 |

## Approval / State

| Item | Status |
| --- | --- |
| 위험도 | L2 |
| 실행 모드 | Full Work |
| Branch Isolation | PASS — `feature/chore-20260613-011-...` (W4 Enforcement & Lifecycle cluster) |
| Tool rule reference | `.claude/rules/docs-workflow.md`, `.claude/rules/git-workflow.md` |
| PLAN 영향 | 없음 |
| STATUS proposal | 승인 완료 — Recent Decisions + Next Actions 갱신 |
| State machine | DONE — Work closed, STATUS 번들 commit |

## Cross-Agent Review And Discussion

Codex 협업 없음. Claude self red-team 검토 기록.

### Round Log

| Round | Reviewer | Type | Findings | Disposition | Status |
| --- | --- | --- | --- | --- | --- |
| R0 | Claude (self red-team) | Direction/Scope Review | (1) ≈0 harm 대비 cascade 큼 → 구조 불일치(works outlier vs decisions/retro 표준) 해소라는 근거로 정당화하되 prune/rollup 비범위로 차단. (2) product 대칭(DR-031) 누락 말 것 → all {category}. (3) scaffold가 outlier를 새 repo에 재생산 → seed 필수. (4) scaffold invariant가 3-table assert 가능 → 검증에 must-check 포함. | 4건 반영: DR-038에 무손실·구조근거, scope에 product+scaffold, verification에 invariant must-check. | Addressed |
| R1 | Claude (self red-team) | Result Review | 전 표면 stale 0, adapter 복제 없음, relocation 106행 무손실, scaffold 실제 생성 시 harness·product pointer-only 확인, tier0 PASS, tier2 invariants [1]-[4] PASS·[5]만 pre-existing cursor manifest-src drift. 테스트 스크립트는 works README 구조 미참조(무영향), repo-health line 109는 cascade에서 이미 정렬, works README는 manifest 미tracked(drift 무유발). closure 위반(shipped 6표면 DR-038 인용)을 mode-a self-describe로 해소. | 모두 통과. cursor manifest-src 버그는 backlog 등록(미수정, surgical). | Approved |

## Discovery

- 2026-06-13: 누적 실측 — archive cost≈0, 유일 실비용은 live README 106행 인덱스. archive-side README가 decisions/retro 표준 패턴이고 works만 outlier임을 확인.
- 2026-06-13: 사용자가 archive-side index relocation 방향 선택 + product/archive-instruction/scaffold 고려 지시.
- 2026-06-13: sweep로 cascade 표면 식별(DR-013/016, HARNESS-PROTOCOL, work-close/plan, repo-health, docs-workflow rule, scaffold ×4, VERIFICATION-COMMANDS, backlog).
- 2026-06-13: 106행 archive-side 이전, live README 130→25줄 trim 완료.
</content>

- 2026-06-13: batch archive (CHORE-20260613-013 DR-038 archive-side flow 실사용 검증). status Done→Archived, live README Done(Pending) 행 제거 후 archive-side Archived 인덱스로 이전.
