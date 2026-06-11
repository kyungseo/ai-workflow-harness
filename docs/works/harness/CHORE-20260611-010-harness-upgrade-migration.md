---
id: CHORE-20260611-010
priority: P1
status: Done
risk: L3
scope: 실 adopter가 pre-manifest target임을 기준으로, 기존 harness 적용 repo를 현재 source로 올리기 위한 inventory-first upgrade/migration 정책과 검증 경로를 정립한다. 첫 slice는 실측, Draft DR 정책 결정, pre-manifest manifest baseline 획득 방식, pre-manifest baseline migration note, Layer T concrete 검증에 한정한다. user-facing docs rewrite, product starter planning pack, full `--upgrade` apply 구현은 범위 밖.
appetite: 1.5d
planned_start: 2026-06-11
planned_end: 2026-06-12
actual_end: 2026-06-11
related_dr: [DR-021, DR-028]
related_work: [CHORE-20260605-006, CHORE-20260611-005, CHORE-20260611-009]
---

# CHORE-20260611-010: Harness Upgrade / Migration Mechanism

## Top Summary

- **목표:** W2 Adopter Transition의 첫 작업으로, 기존 adopter repo가 harness source 변경을 안전하게 따라올 수 있는 upgrade/migration 경로를 만든다. 핵심 대상은 `ai-deck-compiler` 같은 이미 harness가 적용된 repo다.
- **선택 이유:** `STATUS.md`와 `PLAN.md` 모두 AWH-004의 현재 초점을 "실 adopter upgrade/migration"으로 둔다. W1 Validation Spine이 끝났고, `VERIFICATION-COMMANDS.md` Layer T는 upgrade/migration placeholder로 남아 있었기 때문에 다음으로 닫을 gap이 명확했다.
- **R0 반영 핵심:** 실 adopter인 `/Users/kyungseo/dev-home/vibe/ai-deck-compiler`에는 `.harness/manifest.json`이 없다. `scripts/create-harness.sh --check /Users/kyungseo/dev-home/vibe/ai-deck-compiler`도 exit 3으로 pre-manifest target을 보고한다. 따라서 이 Work의 주 경로는 "manifest가 있는 target의 `--check` drift 해석"이 아니라 **pre-manifest adopter inventory-first migration**이다.
- **중요한 경계:** `--existing`은 신규 overlay 경로이지 이미 harnessed target의 upgrade 경로가 아니다. manifest가 없는 실 adopter에는 `--check`만으로 Detect 단계가 성립하지 않으므로, command/skill/rule inventory와 정책 결정이 먼저다.
- **R0a 신규 핵심:** pre-manifest target은 manifest가 없으므로 `--check` 세계로 들어오기 위한 **manifest baseline 획득 방식**이 필요하다. 이번 기본안은 신규 `manifest-init` 스크립트를 만들지 않고, 같은 project/workflow/profile 옵션의 fresh shadow scaffold에서 현재 source 기준 manifest를 얻어 selective migration 후 target에 심는 방식이다. 이 방식은 자동 apply가 아니라 baseline seeding 절차다.
- **과잉 구현 방지:** full `--upgrade` apply 구현은 하지 않는다. 대신 실제 pre-manifest case 측정, Draft DR 정책 결정, manifest baseline 획득 방식, 과거->현재 selective migration 실측 1회, Layer T 검증 승격을 이번 slice의 성공 기준으로 둔다.
- **문서 경계:** 일반 upgrade 절차는 per-change migration note가 아니라 `docs/maintainer/SOURCE-REPO-OPERATIONS.md`의 source-only runbook 확장 후보로 둔다. `docs/maintainer/migrations/`에는 특정 framework 변경을 target이 수용하는 per-change note만 둔다.

## Candidate Selection Review

| 후보 | 판단 | 이유 |
| --- | --- | --- |
| Harness upgrade/migration 메커니즘 | **선택** | AWH-004 목표와 직접 일치. 기존 `--check`, manifest, Layer T placeholder가 있어 작은 시작점이 있다. |
| Product starter planning pack + feedback import loop | 보류 | upgrade 경로가 없어 scaffold repo에 산출물을 주입/회수하는 운영이 먼저 흔들릴 수 있다. Layer U는 criteria까지만 준비됨. |
| User-facing docs rewrite | 보류 | upgrade 정책 없이 manual을 먼저 고치면 user-facing 문서가 곧 다시 흔들린다. |
| Scaffold multi-user clone verification | 보류 | clone 검증은 upgrade/migration 결과를 검증하는 하위 scenario로 흡수될 가능성이 높다. |

## Background / Facts

- `scripts/create-harness.sh --check <target-dir>`는 현재 report-only drift diagnostic이다. manifest가 있는 target에 대해 `in-sync`, `source-updated`, `locally-modified`, `source-missing`, `target-missing`을 보고하지만 적용은 하지 않는다.
- **실 adopter 측정(2026-06-11):** `/Users/kyungseo/dev-home/vibe/ai-deck-compiler/.harness/manifest.json` 없음. `--check` 결과는 `untracked target / pre-manifest scaffold`이며 "command/skill/rule inventory를 먼저 작성"하라고 안내한다. 따라서 pre-manifest 경로가 예외가 아니라 이번 Work의 주 경로다.
- manifest는 scaffold 생성 시 `scripts/create-harness.sh`가 `.harness/manifest.json`을 `write_text`로 생성한다. 현재 기존 target에 manifest만 안전하게 주입하는 별도 command는 없다. 따라서 pre-manifest migration은 "manifest를 어떻게 획득해 baseline으로 심을지"를 정책으로 먼저 닫아야 한다.
- `scripts/create-harness.sh`의 scaffolded `BOOTSTRAP.md` 문구는 "현재 자동 upgrade 기능은 제공하지 않는다"와 "필요한 파일만 수동 selective migration"을 이미 말한다. 이번 Work는 그 수동 경로를 source repo에서 감사 가능한 mechanism으로 만든다.
- `docs/maintainer/VERIFICATION-COMMANDS.md` Layer T는 upgrade/migration 구현 후 채우는 placeholder다.
- `docs/maintainer/migrations/README.md`는 "source repo의 framework surface 변경을 이미 scaffold된 target repo가 수용할 때 참고하는 migration note 인덱스"다. 기존 파일도 canonical rename, product-track rename처럼 per-change note다. 일반 절차 guide를 이 디렉터리에 넣으면 index 정의와 충돌한다.
- `docs/retrospectives/harness-distribution-plugin-model-20260608.md` 결론은 plugin/npm 전환보다 shell 기반 upgrade/migration 로직을 먼저 구현하라는 방향이다.
- W1의 `docs/maintainer/SOURCE-REPO-OPERATIONS.md`는 source repo maintainer / AI driver용 runbook이며, `--tier1 <target-dir>`를 source workflow/tool-surface 변경의 기본 검증으로 쓰면 안 된다는 합의를 남겼다.

## Scope / Plan

> 합의 전 구현 금지. 아래는 Claude R0 plan review 대상이다.

### Scope

1. **실 adopter inventory-first 측정**
   - `ai-deck-compiler`를 읽기 전용으로 측정한다: manifest 유무, `--check` 결과, command/skill/rule/prompt/doc 주요 surface 존재 여부.
   - 측정 결과를 Work `Discovery`와 산출 문서에 fact로 남긴다. 지금 확인된 결론은 pre-manifest 주 경로다.
2. **upgrade ownership policy 결정**
   - 최소 결정 범위: framework-owned file 자동 overwrite 금지/허용 경계, project-owned/customized 파일 보존 원칙, manifest가 없는 target의 지원 수준, `VERSION`/manifest baseline을 migration 후 어떤 상태로 둘지.
   - **manifest baseline 획득 방식(M5):** 기본 제안은 신규 script 없이 **shadow scaffold baseline**을 쓴다. 같은 project/workflow/profile 옵션으로 fresh scaffold를 만들고, 그 manifest를 현재 source 기준 baseline으로 사용한다. target에는 inventory + selective migration 후 `.harness/manifest.json`을 심는다. 이후 `--check`는 "현재 source와 target이 같은 baseline에서 시작한다"는 상태를 추적한다.
   - 산출: Draft DR 후보(예: `DR-034-harness-upgrade-ownership-policy.md`). 단일 adopter 1건에 과적합하지 않도록 Accepted가 아니라 Draft로 시작하고, 두 번째 adopter 또는 실제 apply 후 Accepted 승격을 검토한다.
3. **pre-manifest baseline migration note**
   - `docs/maintainer/migrations/`에는 일반 절차 guide가 아니라 특정 변경 수용 note만 둔다.
   - 후보: `docs/maintainer/migrations/manifest-check-baseline.md` — CHORE-20260605-006으로 도입된 manifest/`--check` baseline을 pre-manifest target이 수용하는 per-change note.
4. **source operations runbook에 일반 절차 pointer 추가**
   - 일반 Detect -> Inventory -> Policy -> Apply -> Verify 절차는 `docs/maintainer/SOURCE-REPO-OPERATIONS.md`의 source-only runbook에 짧게 추가하거나 pointer만 둔다.
   - 기준/명령은 복제하지 않고 DR + Layer T + per-change note로 위임한다.
5. **Layer T concrete 검증으로 승격**
   - `docs/maintainer/VERIFICATION-COMMANDS.md` Layer T placeholder를 실제 실행형 검증으로 보강한다.
   - 핵심은 과거/pre-manifest target -> inventory -> selective migration -> shadow scaffold manifest baseline 심기 -> `--check` drift 0 또는 accepted drift에 도달하는지 temp에서 1회 확인하는 경로다.

### Non-goals

- full `--upgrade` 또는 `--refresh` apply 구현.
- target 파일을 자동 overwrite/merge하는 helper 작성.
- 신규 `manifest-init`/`--upgrade-plan`/`--upgrade` CLI 구현. 이번 slice는 shadow scaffold baseline 절차로 닫는다.
- npm/package/plugin 배포 모델 도입.
- `docs/WORKFLOW-MANUAL.md`, `docs/HARNESS-MAINTAINER-GUIDE.md`, README 등 user/adopter-facing docs rewrite.
- Product starter planning pack, feedback import loop, MSA option-pack 설계.
- `ai-deck-compiler` repo 직접 수정. 이 Work는 read-only 측정만 하고 실제 적용은 temp copy 또는 과거 scaffold sample에서 수행한다.
- `docs/STATUS.md` Active pointer 변경. R0 합의/승인 전에는 변경하지 않는다.

### Files

| 파일 | 변경 | 비고 |
| --- | --- | --- |
| `docs/decisions/DR-034-harness-upgrade-ownership-policy.md` | 후보 | Draft 우선. 번호는 착수 시 충돌 재확인 |
| `docs/decisions/README.md` | 후보 | DR index |
| `docs/maintainer/SOURCE-REPO-OPERATIONS.md` | 후보 | 일반 upgrade/migration entry pointer, source-only |
| `docs/maintainer/migrations/manifest-check-baseline.md` | 후보 | pre-manifest target이 manifest/`--check` baseline을 수용하는 per-change note |
| `docs/maintainer/migrations/README.md` | 후보 | per-change note index |
| `docs/maintainer/VERIFICATION-COMMANDS.md` | Layer T concrete화 | source-only maintainer catalog |
| `scripts/create-harness.sh` | 기본 제외 | 신규 manifest-init/upgrade 기능 없음. report wording도 R0b에서 필요할 때만 |
| `docs/works/harness/README.md` | Active 등록 | 이 Work 착수 tracking |
| `docs/STATUS.md` | 변경 없음 | R0 합의/승인 후 별도 state-change proposal |

## Verification

1. `git diff --check`.
2. `bash -n scripts/create-harness.sh` — 스크립트를 건드린 경우 필수.
3. 실 adopter read-only check:
   - `/Users/kyungseo/dev-home/vibe/ai-deck-compiler/.harness/manifest.json` 유무.
   - `bash scripts/create-harness.sh --check /Users/kyungseo/dev-home/vibe/ai-deck-compiler` 결과와 exit code.
4. 실제 upgrade simulation 1회:
   - `temp/` 아래에 target copy를 만든다. 우선순위 A: `ai-deck-compiler`의 read-only copy를 `temp/`에 복제해 pre-manifest sample로 사용. 우선순위 B: CHORE-20260605-006 이전 커밋의 scaffold script로 temp target 생성.
   - 같은 project/workflow/profile 옵션의 fresh shadow scaffold를 `temp/`에 생성하고 `.harness/manifest.json`을 baseline source로 쓴다.
   - 현재 source 기준으로 inventory -> selective migration -> shadow scaffold manifest baseline 심기 -> verification을 실제 파일에 적용한다.
   - 결과가 `--check` drift 0에 도달하거나, 수동 보존 때문에 accepted drift로 남는 항목을 명시한다.
5. Layer T executable check:
   - fresh target drift 0은 보조 smoke로만 둔다.
   - 핵심 판정은 "drift/pre-manifest target을 현재 source로 올릴 수 있는가"다.
6. source vs scaffolded project boundary grep:
   - source-only migration material이 scaffold default/optional output에 배포되지 않는지 확인.
   - user-facing manual rewrite 문구가 이번 diff에 섞이지 않았는지 확인.
7. stale phrase 점검:
   - "`--existing` = upgrade"처럼 오해를 만드는 표현이 새로 생기지 않았는지 확인.
   - "`--tier1 <target-dir>`를 source 변경 기본 검증으로 쓰는 문구"가 생기지 않았는지 확인.

## Risk / Reversal Cost

- **Risk:** L3. upgrade/migration은 source/target ownership 정책과 adopter 운영 경로를 정하는 구조 변경이다. R0 반영 후 이번 slice는 문서 작성보다 실측과 정책 결정에 무게를 둔다.
- **주요 리스크 1:** 자동 apply를 너무 일찍 만들면 project-owned customization을 훼손할 수 있다. 그래서 이번 기본안은 manual/selective migration mechanism이다.
- **주요 리스크 2:** 실 adopter가 pre-manifest이므로 manifest 기반 `--check`만으로는 주 경로가 성립하지 않는다. 그래서 inventory-first를 주 경로로 승격한다.
- **주요 리스크 3:** Layer T가 실제 명령 없이 checklist만 남으면 W1 검증 척추와 연결되지 않는다. 그래서 최소 temp target walkthrough와 `--check` smoke를 verification에 포함한다.
- **주요 리스크 4:** 일반 절차 guide를 `migrations/`에 두면 per-change note index와 충돌한다. 그래서 일반 절차는 `SOURCE-REPO-OPERATIONS.md`/DR/Layer T로 분산하고, `migrations/`는 per-change note만 둔다.
- **주요 리스크 5:** shadow scaffold baseline은 "현재 source와 target을 같은 baseline으로 간주"하는 정책이다. inventory가 부실하면 target customization을 framework 상태로 오인할 수 있다. Draft DR과 Layer T에서 inventory-first 및 accepted drift 기록을 필수로 둔다.
- **Reversal Cost:** Medium. DR/Draft DR, source-only runbook, migration note, Layer T 변경은 되돌릴 수 있지만, 정책 결정은 후속 adopter 작업의 기준이 되므로 단순 문서 삭제보다 비용이 높다. 스크립트 변경은 기본 제외하므로 tooling reversal은 낮게 유지한다.

## Open Questions

| ID | Question | 기본 제안 |
| --- | --- | --- |
| OQ-1 | 이번 slice에서 full `--upgrade` apply를 구현할 것인가? | 아니오. 자동 apply는 후속. 이번에는 실측 + 정책 + selective migration 검증. |
| OQ-2 | 일반 upgrade 절차를 어디에 둘 것인가? | `SOURCE-REPO-OPERATIONS.md` 확장 또는 pointer. `migrations/`에는 두지 않는다. |
| OQ-3 | `write_text` 계열 project-owned/config 파일은 upgrade에서 어떻게 다룰 것인가? | 자동 overwrite 금지 정책을 DR/Draft DR로 기록. |
| OQ-4 | pre-manifest target은 지원할 것인가? | 예. 실 adopter가 pre-manifest이므로 주 경로로 승격한다. |
| OQ-5 | `--check`에 새 옵션(`--upgrade-plan`)을 추가할 것인가? | 이번에는 보류. 반복 사용 후 별도 Work 또는 R0 명시 승인 시만 검토한다. |
| OQ-6 | 정책 결정은 Accepted DR인가 Draft DR인가? | Draft DR 우선. 단일 adopter 표본 1건으로 Accepted 고정하지 않는다. |
| OQ-7 | pre-manifest target의 manifest baseline은 어떻게 획득하는가? | 신규 script 없이 shadow scaffold baseline으로 획득한다. `manifest-init`은 후속 필요 확인 전까지 만들지 않는다. |

## State / Approval

- **위험도:** L3.
- **실행 모드:** Full Work.
- **현재 상태 머신:** PLAN -> APPROVAL 대기.
- **Tool Rule Reference:** `.claude/rules/docs-workflow.md`, `.claude/rules/git-workflow.md` 적용. DR-007 적용: docs는 한국어 주 언어 + Bilingual Rules.
- **PLAN 영향:** AWH-004 방향과 일치. 다만 실 adopter가 pre-manifest임이 확인되어 upgrade/migration의 첫 slice 정의가 바뀐다. closeout 시 `docs/PLAN.md` 변경 필요 여부를 재확인한다.
- **STATUS Update Proposal:** R0 합의/사용자 승인 후에만 `CHORE-20260611-010` Active pointer 추가를 제안한다. 현재는 변경하지 않는다.

## Cross-Agent Review And Discussion

> 이번 세션 역할: Codex = author/driver, Claude = reviewer. 리뷰/결과 정리는 한국어 중심으로 누적한다.

### Review Request

Claude R0b plan confirmation 요청: CHORE-20260611-010 Harness Upgrade / Migration Mechanism

검토 초점:

- M5 반영: pre-manifest manifest baseline 획득 방식을 shadow scaffold baseline으로 정한 것이 충분한가?
- N1 반영: temp target 위치를 `temp/`로 통일한 것이 충분한가?
- N2 반영: DR-034는 source-only 표면에만 인용하고 shipped surface 토큰 인용을 피하는 계획이 충분한가?
- N3 반영: DR-034를 Draft 우선으로 둔 것이 적절한가?
- 신규 `manifest-init` 없이 착수해도 되는가?

### Round Log

| Round | 주체 | 유형 | 요약 | Required Changes / Decision | Status |
| --- | --- | --- | --- | --- | --- |
| R0 | Claude | Plan Review | 방향 부분 타당(auto apply 미루기·source-only 경계)하나 첫 slice 무게중심 오설정. ① 실 adopter(`ai-deck-compiler`) manifest 유무 미측정 — pre-manifest면 `--check` 기반 주 경로가 실 driver에 무력(scope 1순위로 실측 필요). ② Verification이 "갓 생성 target drift 0" freshness 동어반복, 백로그가 요구한 "과거→현재 selective migration 후 drift 0" 실측 부재. ③ L3인데 핵심 정책(overwrite/merge·보존·version marker) 결정 비움 — DR 결정하거나 L2 재라벨. ④ `migrations/`는 per-change note 인덱스인데 일반 절차 guide는 정의 충돌(`SOURCE-REPO-OPERATIONS` 확장 검토). | Must-fix 4건(M1 실측 우선·M2 실제 upgrade 1회 실측·M3 정책결정 or L2재라벨·M4 migrations 경계) 반영 후 R0a 재요청. | Changes Requested |
| R0a | Codex | Plan Fix | M1 실측 수행: `ai-deck-compiler` manifest 없음, `--check` exit 3 pre-manifest. 계획을 pre-manifest inventory-first 주 경로로 재작성. M2는 temp target 실제 selective migration 검증으로 승격. M3는 L3 유지 + DR/Draft DR 정책 결정으로 반영. M4는 일반 절차를 `SOURCE-REPO-OPERATIONS`/DR/Layer T로 이동하고 `migrations/`는 per-change note만 두도록 수정. | Claude R0a re-review 요청. | Reviewed |
| R0a-rev | Claude | Plan Re-review | M1~M4 반영 우수. 방향 무게중심은 해소됨. 단 신규 공백 M5: pre-manifest adopter의 manifest 획득 경로가 plan에 없음. `--check`는 manifest를 읽기만 하고, manifest는 scaffold 시에만 생성되므로, `ai-deck-compiler` copy는 manifest가 없어 다시 exit 3이 된다. DR-034에 pre-manifest manifest 획득 방식을 1급 결정으로 포함하고, 신규 script 필요 여부와 "스크립트 변경 기본 제외" 전제의 충돌을 해소해야 함. Nice: `/private/tmp` 대신 `temp/`, DR-034는 source-only 인용만, Draft DR 우선. | M5 반영(+N1~N3) 후 R0b 또는 착수. | Conditional Approval |
| R0b | Codex | Plan Fix | M5 반영: 신규 `manifest-init` 없이 shadow scaffold baseline 방식 선택. 같은 project/workflow/profile 옵션의 fresh scaffold에서 현재 source 기준 manifest를 얻어 selective migration 후 target에 심고 `--check`를 시작한다. N1: temp/로 통일. N2: DR-034는 source-only 표면에서만 인용, shipped surface 토큰 인용 금지. N3: Draft DR 우선으로 수정. | Claude R0b confirmation 요청. | Reviewed |
| R0b-confirm | Claude | Plan Confirmation | M5(shadow scaffold baseline)·N1~N3 반영 확인. shadow scaffold가 신규 script 없이 manifest를 획득해 "스크립트 변경 제외" 전제와의 충돌을 해소. 리스크 5(source=target 간주)를 author가 자체 식별·완화한 점 우수. plan 승인. R1에서 확인할 구현 주의 3건(비차단): ① shadow는 adopter와 동일 project-name이어야 hash 정합(adapt name-sed), ② 첫 `--check`는 drift 분포가 정상(drift 0 강요 아님), ③ inventory-first 분류를 Layer T에 명시 기록. | 승인. 구현 착수 가능. R1(result review)는 simulation 실측 결과·구현 주의 3건 중심. | Approved |
| R1 | Claude | Result Review | DR-034 정책·산출물 골격 우수, 구현 주의 1·3 및 N1~N3 반영. 그러나 핵심 결함: Layer T T3가 "selective migration" 제목과 달리 manifest 76개 path를 조건 없이 전량 copy(framework 전량 overwrite) → T4 `--check` "76 in-sync 0 drifted"는 freshness 동어반복(R0 DC-2 재발), 실제 drift 분포 미측정. DR-034 D3/D5·Layer T T4 주석·note의 "drift 분포 정상" 선언과 실행이 정반대(외부화 실패모드 ③ 선언-실행 괴리). 구현 주의 2가 문서엔 적혔으나 simulation에서 죽음. locally-modified 유실 위험(MR-2). | MR-1(절차를 manifest만 심기→drift 분포 관측→framework selective 반영→재check로 교정하고 0 아닌 실측 재수행)·MR-2(반영 전 diff/분류) 반영 후 R1a 재요청. NR-1(DR-021~023 product 오표기)·NR-2(note 결과 갱신). | Changes Requested |
| R1a | Codex | Result Fix | Layer T, migration note, DR-034를 manifest-only baseline → drift 관측 → target-missing selective copy → locally-modified diff/manual-merge 분류 → final verify 순서로 교정. temp 재실측: manifest-only 첫 `--check`는 `76 tracked, 9 in-sync, 67 drifted`(`target-missing` 37, `locally-modified` 30). 신규 framework 37개만 1차 copy, hard invariant-breaking framework docs 3개를 2차 반영, target-local decision index 보강, remaining 27개 locally-modified를 manual-merge/copy candidates로 기록 후 temp에서 current framework baseline으로 반영. 최종 `--check` 76 in-sync 0 drifted, invariant PASS. DR-021~023은 product가 아니라 target-local accepted DR로 정정. | Claude R1a result re-review 요청. | Reviewed |
| R1a-review | Claude | Result Re-review | MR-1·MR-2·NR-1 실질 반영 확인. T3가 "manifest만 심기→drift 분포 관측"으로 재배치되어 전량 copy 제거, T4가 target-missing 자동 copy/locally-modified diff 분류로 분리. 재실측이 9 in-sync/67 drifted(target-missing 37+locally-modified 30)의 실제 분포를 내고 49→76 in-sync로 단계적 수렴, 산수 일관. 선언-실행 괴리 해소, simulation이 진짜 upgrade를 증명. NR-1 DR-021~023 target-local accepted DR로 정정. | 승인. 비차단 권고: locally-modified는 과거 baseline 부재로 3-way merge 불가·2-way diff 한정이라는 한계를 DR-034 Consequences/Layer T에 1줄 기록. work-close 진행 가능. | Approved |

### R1 Result Review Focus

- shadow scaffold는 adopter와 동일 project-name을 사용한다. `adapt()`가 project-name을 치환하므로 이름 불일치는 대량 false `locally-modified`를 만들 수 있다.
- baseline 심기 후 첫 `--check`는 drift 분포가 나오는 것이 정상이다. drift 0 강요가 아니라 drift/accepted drift의 분류와 근거를 기록한다.
- Layer T walkthrough에 inventory-first 분류(framework-owned vs project-owned/customized)를 명시 기록한다.

### Result Re-review Request

Claude R1a result re-review 요청: CHORE-20260611-010 Harness Upgrade / Migration Mechanism

검토 초점:

- MR-1: Layer T와 simulation이 manifest만 심기 → drift 분포 관측 → selective 반영 순서로 고쳐졌는가?
- MR-2: locally-modified를 덮기 전에 diff/manual-merge 후보로 분류하도록 문서화됐는가?
- 실제 drift 분포(`76 tracked, 9 in-sync, 67 drifted`)가 기록됐는가?
- `DR-021~023` 오표기가 `target-local accepted DR`로 정정됐는가?
- 최종 `--check`와 invariant PASS가 정책을 배신하지 않는 순서로 도달했는가?

### Consensus Log

| Topic | Consensus | Source Round | Status |
| --- | --- | --- | --- |
| Work 선택 | W2 첫 후보로 Harness upgrade/migration 메커니즘 착수 | Codex plan | Done |
| 구현 깊이 | full auto apply보다 실측 + 정책 결정 + selective migration 검증 우선 | R0a | Accepted |
| 실 adopter 상태 | `ai-deck-compiler`는 pre-manifest target. pre-manifest inventory-first가 주 경로 | R0a | Accepted |
| 문서 경계 | 일반 절차는 `migrations/`에 두지 않음. `migrations/`는 per-change note만 | R0a | Accepted |
| manifest baseline 획득 | 신규 script 없이 shadow scaffold baseline으로 획득 | R0b | Accepted |
| DR 상태 | DR-034는 Draft 우선, Accepted 승격은 후속 signal 이후 | R0b | Accepted |

## Done Criteria

- [x] 실 adopter(`ai-deck-compiler`) pre-manifest 상태와 surface inventory가 기록됨.
- [x] framework-owned vs project-owned/customized 파일 보존 경계가 DR 또는 Draft DR로 기록됨.
- [x] pre-manifest target의 manifest baseline 획득 방식이 Draft DR과 Layer T에 기록됨.
- [x] pre-manifest target이 manifest/`--check` baseline을 수용하는 per-change migration note가 정의됨.
- [x] 과거/pre-manifest target -> 현재 source selective migration -> shadow scaffold manifest baseline 심기를 `temp/`에서 1회 실제 수행하고 결과가 기록됨.
- [x] Layer T가 placeholder에서 실제 실행형 검증 walkthrough로 승격됨.
- [x] full auto apply를 하지 않는 이유와 후속 전환 조건이 기록됨.
- [x] user-facing docs rewrite, product starter pack, scaffold clone verification과 충돌/중복하지 않음.
- [x] Cross-Agent R0 plan review와 result review가 이 섹션에 누적됨.

## Discovery

- 2026-06-11 session start: `develop` == `origin/develop`, Active Work 없음, archive pending 없음.
- 최신 커밋: `a686c42` — W1 Validation Spine 마무리 및 007/008/009 archive 완료. 009는 develop에 반영됨.
- `docs/STATUS.md` Next Actions는 W1 완료, W2 Adopter Transition 후보 4개를 제시한다.
- `docs/PLAN.md` AWH-004 milestone이 실 adopter upgrade/migration 경로 제공을 목표로 명시한다.
- memory/retrospective 근거: `--existing`은 upgrade가 아니며, plugin/npm 배포 전환보다 shell 기반 upgrade/migration 로직을 먼저 닫는 방향이 기존 판단이다.
- R0 실측: `/Users/kyungseo/dev-home/vibe/ai-deck-compiler/.harness/manifest.json` 없음. `bash scripts/create-harness.sh --check /Users/kyungseo/dev-home/vibe/ai-deck-compiler`는 exit 3과 함께 `untracked target / pre-manifest scaffold`를 보고한다. 따라서 pre-manifest 경로가 예외가 아니라 주 경로다.
- R0b 결정 후보: pre-manifest manifest 획득은 신규 script 없이 shadow scaffold baseline 방식으로 검증한다. `manifest-init` 또는 `--upgrade-plan`은 이번 Work scope 밖이다.
- 구현: `docs/decisions/DR-034-harness-upgrade-ownership-policy.md` Draft 신설. pre-manifest inventory-first, shadow scaffold baseline, project-owned/customized 보존, 첫 `--check` drift 분포 허용, 신규 CLI 보류를 Draft 정책으로 기록.
- 구현: `docs/maintainer/migrations/manifest-check-baseline.md` 신설. `migrations/`에는 일반 절차가 아니라 CHORE-20260605-006 manifest/`--check` baseline 수용 per-change note만 둠.
- 구현: `docs/maintainer/SOURCE-REPO-OPERATIONS.md` B matrix와 G절에 adopter upgrade/migration entry 추가. 일반 절차는 source-only runbook에서 pointer로만 연결.
- 구현: `docs/maintainer/VERIFICATION-COMMANDS.md` Layer T placeholder를 실행형 검증으로 승격. target probe, inventory-first 분류, shadow scaffold baseline, selective migration, baseline verify, accepted drift 기록 포함.
- temp simulation: `ai-deck-compiler` read-only copy를 `temp/chore-20260611-010/ai-deck-copy`에 만들고, shadow scaffold는 동일 project-name `ai-deck-compiler`, `--workflow source-gitflow`, `--profile generic`으로 `temp/chore-20260611-010/ai-deck-shadow`에 생성.
- R1 재실측: fresh temp copy `temp/chore-20260611-010-r1a/ai-deck-copy`, shadow `temp/chore-20260611-010-r1a/ai-deck-shadow`.
- R1 재실측 1: shadow scaffold는 동일 project-name `ai-deck-compiler`, `--workflow source-gitflow`, `--profile generic`으로 생성.
- R1 재실측 2: manifest만 target copy에 심은 첫 `--check` 결과 `76 tracked, 9 in-sync, 67 drifted` (`target-missing` 37, `locally-modified` 30). 이것이 실제 pre-manifest drift 분포다.
- R1 재실측 3: 1차 selective 반영은 `target-missing` 37개 신규 framework 파일만 copy. 중간 `--check` 결과 `76 tracked, 46 in-sync, 30 drifted`.
- R1 재실측 4: hard invariant를 깨는 locally-modified 3개(`docs/HARNESS-NAMING-RULES.md`, `docs/AGENT-WORKFLOW.md`, `docs/HARNESS-PROTOCOL.md`)와 project-owned `docs/decisions/README.md` index를 보강. 중간 `--check` 결과 `76 tracked, 49 in-sync, 27 drifted`.
- R1 재실측 5: 남은 27개는 manifest-tracked locally-modified manual-merge/copy candidates로 기록. temp simulation에서는 current framework baseline으로 반영해 최종 `--check` 결과 `76 tracked, 76 in-sync, 0 drifted`.
- R1 재실측 6: `bash scripts/tests/check-scaffold-invariants.sh temp/chore-20260611-010-r1a/ai-deck-copy` PASS. DR-021~023은 product DR이 아니라 target-local accepted DR로 index에 기록.
- R1a 승인 후 비차단 권고 반영: pre-manifest target에는 과거 baseline이 없어 `locally-modified` 판단이 3-way merge가 아니라 current source vs adopter 2-way diff 한정임을 DR-034 Consequences와 Layer T에 기록.
- 검증: `git diff --check` PASS, `bash -n scripts/create-harness.sh` PASS, `bash scripts/tests/check-shipped-dr-closure.sh` PASS, `bash scripts/tests/run-harness-checks.sh --tier0` PASS, `bash scripts/tests/run-harness-checks.sh --all` PASS.
- DR-034 closure: `rg "DR-034"` 확인 결과 Work 파일, source decisions README, Draft DR에만 존재. shipped closure check도 PASS.
- Done 처리: 2026-06-11. R1a 승인 및 비차단 권고 반영 후 Work index는 Archive Pending으로 이동, STATUS Active pointer 제거, backlog candidate 제거.
