---
id: CHORE-20260621-004
priority: P1
status: Done
risk: L2
scope: adopter/product DR namespace 정책을 high-band(800-999)으로 결정·DR 기록하고, ai-deck product DR 4개 renumber cascade + decision-index 생성 + CHORE-003 rehearsal result 기반 실제 ai-deck apply/PR까지 수행한다. real apply로 DR-034 "실제 target migration" condition evidence 확보 판단. 장기 PDR-/4자리 전환은 비범위(별도 Work, tool cascade).
appetite: 2-3d
planned_start: 2026-06-21
planned_end:
actual_end: 2026-06-21
related_dr: [DR-034, DR-042]
related_troubleshooting: []
related_work: [CHORE-20260621-003, CHORE-20260621-002]
---

# CHORE-20260621-004: Adopter DR Namespace Policy + ai-deck Real Apply

## Top Summary

CHORE-20260621-003 rehearsal이 ai-deck migration body를 검증하고, real-apply blocker로 **adopter product DR namespace 충돌**을 발견했다(framework `DR-014-archive` seed가 adopter `DR-014-ppt`와 충돌; product `DR-021/022/023`도 framework 번호공간과 시한폭탄 충돌). 이 Work는 그 blocker를 **정책으로 닫고 실제 ai-deck apply까지 완료**한다.

두 phase로 진행한다:
1. **harness 정책** (DR-worthy): adopter/product DR을 **high-band**(`DR-8xx`~`DR-9xx` = 800-999, 200슬롯)으로 분리하는 정책을 결정·DR로 기록한다. 기존 `DR-[0-9]{3}` 전제 도구(`check-scaffold-invariants`/`check-shipped-dr-closure`/`VERIFICATION-COMMANDS`)와 호환되므로 단기 안전안이다. 장기 `PDR-`/4자리는 도구 cascade가 선행돼야 하므로 **이 Work 비범위**(별도 Work).
2. **ai-deck 실행** (cross-repo): product DR 4개 renumber cascade + decision-index 생성 + CHORE-003 temp result 기반 실제 apply/PR.

이 Work의 **real apply가 DR-034 "실제 target migration" condition을 충족하는 1번째 evidence**다. 단 그 자체로 Accepted 승격은 아니며, 승격은 별도 owner-approved decision(Slice E 판단표).

## Collaboration Workflow

**Role swap 유지(CHORE-003과 동일):**

| Role | Agent | Responsibility |
| --- | --- | --- |
| A | Claude | author/driver. Work 파일, plan, 정책 결정/DR, ai-deck 실행/검증, Codex review response |
| B | Codex | red team reviewer. 정책 band 선택·도구 호환, renumber cascade 완전성, real apply가 rehearsal과 일치하는지, DR-034 승격 과속 의심 |
| Owner | User | 방향 승인, 정책 승인, product scope(ai-deck DR renumber) 승인, cross-repo write·commit·PR·merge 승인, 최종 승인, `/work-close` |

절차: 사용자 지시 → Claude A plan → Codex B R1 red-team → 합의 → A 정책 DR + ai-deck 실행 → Codex B 결과 검토 → owner 최종 승인 → close. ai-deck 변경은 그 repo `docs/GIT-WORKFLOW.md`(source-gitflow) + owner 승인.

## Cross-Repo Execution Boundary

| repo | 변경 대상 | 비고 |
| --- | --- | --- |
| `ai-workflow-harness` (source) | DR namespace 정책 DR(신규), 이 Work 파일, STATUS/Work Index | 정책 결정 + tracking |
| `ai-deck-compiler` (target) | product DR 4개 renumber + 참조 cascade, `docs/decisions/README.md`, framework surface real apply | **실제 write는 여기서만**. `feature/*` branch·PR(base develop)·owner 승인 |

## Context Manifest

| 순서 | 파일 | 왜 |
| --- | --- | --- |
| 1 | `docs/works/harness/CHORE-20260621-003-...md` (Rehearsal Result, accepted-drift 13, source-retired 20) | real apply의 base가 되는 검증된 migration body |
| 2 | `temp/chore-20260621-003/ai-deck-copy` | rehearsal result tree (real apply base) |
| 3 | `docs/decisions/DR-034-...md` | promotion condition |
| 4 | `scripts/tests/check-shipped-dr-closure.sh`, `scripts/tests/check-scaffold-invariants.sh`, `docs/maintainer/VERIFICATION-COMMANDS.md` | `DR-[0-9]{3}` 전제 도구 — reserved-band 호환 확인 대상 |
| 5 | `docs/decisions/DECISION-TEMPLATE.md`, `docs/decisions/README.md` 규칙 | product DR 분류/index 규칙 |
| 6 | ai-deck `docs/GIT-WORKFLOW.md` | target branch/PR/merge 정책 |

## Scope

### Slice A — DR Namespace Policy Decision (harness, DR-worthy) ★ HARD GATE
- **exact allocation 명문화(F1):** framework/source DR=`DR-001`~`DR-799`, product/adopter-local DR=`DR-800`~`DR-999`(200슬롯, 별도 reserved 없음). "현재 낮으니 안전"이 아니라 **enforceable allocation rule**. `DR-1000+`/`PDR-`는 도구 cascade 별도 Work(product-local이 `DR-950` 도달 또는 200개 초과 시 trigger).
- **정확히 3자리 `DR-NNN`만(F3):** 현행 `DR-[0-9]{3}` regex는 boundary-less라 `PDR-014`를 내부 `DR-014`로, `DR-1000`을 `DR-100`으로 오인식(실측). 따라서 `PDR-`·4자리 ID는 **tool cascade(regex boundary 포함) 전 금지**. 장기 PDR은 그 trade-off만 DR에 기록(비범위).
- **ID 발급 SSoT 갱신(F1):** `docs/HARNESS-NAMING-RULES.md` §DR ID에 위 allocation을 추가. `DECISION-TEMPLATE.md`/`docs/decisions/README.md`에 product/adopter DR 분류 note 필요 여부 판단.
- 도구 호환 확인: `DR-801` 샘플로 `check-scaffold-invariants`/`check-shipped-dr-closure`/`VERIFICATION-COMMANDS` regex 통과 실측(3자리라 통과).
- 결과를 `/record-decision`으로 **DR로 기록**.
- **★ HARD GATE(F2/direction):** 이 Slice A 정책 DR이 **accepted + owner sign-off** 되기 전에는 ai-deck write(Slice B~D)를 시작하지 않는다.

### Slice B — ai-deck Product DR Renumber Cascade (product scope, owner sign-off) — Slice A 이후
- **exact mapping table(F4):** `DR-014-ppt-language-policy`→`DR-801`, `DR-021-preset-default-policy`→`DR-802`, `DR-022-results-pptx-git-tracking`→`DR-803`, `DR-023-generate-blueprint-consolidation`→`DR-804`(번호는 Slice A 정책 확정 후 fix).
- **live cascade list(F4)** — 각 항목 전수 갱신: ① 파일명 rename ② h1/title ③ frontmatter `id` ④ live 참조(ai-deck `docs/STATUS.md`, `docs/PLAN.md`, `skills/create-deck.md`, 기타 live docs) ⑤ `docs/decisions/README.md` index.
- **archive historical 참조는 renumber하지 않음**(old-ID 보존). 검증 시 **live grep ↔ archive grep 분리**해 archive old-ID를 broken ref로 오판하지 않게 한다.
- framework `DR-014-archive`/`021`/`022`/`023`과 더 이상 충돌 없음 확인(live grep).
- **product 파일 수정이므로 owner sign-off** 필요.

### Slice C — Decision-Index Closure
- `docs/decisions/README.md` 생성: framework DR + renumbered product DR 전체 index.
- `check-scaffold-invariants.sh` `[3]` index closure PASS 확인.

### Slice D — Real Apply to ai-deck
- **★ Pre-Real-Apply Drift Guard(F6):** apply 직전 ① source `develop`/feature diff 확인, ② `temp/chore-20260621-003/ai-deck-copy` `--check` 재실행(78/65/13 재현 확인), ③ ai-deck base `7941585 == origin/develop` 확인, ④ **Slice A 정책 DR이 `create-harness.sh` adapt block에 들어가지 않아 shadow manifest(78 tracked)가 불변임을 확인**(실측: adapt block은 DR을 이름으로 명시 adapt → 신규 정책 DR 미shipped). 불일치 시 temp result 재생성.
- ai-deck clean base(`7941585`)에서 `feature/*` branch 생성(ai-deck §Branch Types).
- CHORE-003 temp result tree + Slice B/C 반영을 실제 적용. customized accepted-drift 13 보존 확인.
- `--check`(framework in-sync + customized accepted-drift), invariant(`[3]` PASS, `[5]` accepted-drift documented) 결과 기록.
- ai-deck PR(base develop), owner 승인 하 merge.

### Slice E — DR-034 Judgment (F7)
- real apply 성공 시 DR-034 **"실제 target migration" condition evidence 1건 확보**(condition 충족을 단독 확정하지 않음 — 같은 ai-deck 계열 1건).
- 판단표: Accepted 승격 가능 / **Draft 유지+2nd adopter 필요** / **helper 필요**(30블록 수동 병합 + namespace policy Work signal)를 진지한 옵션으로. DR-034 상태 변경은 **별도 owner-approved decision**.

## Scope Guard
- 장기 `PDR-` prefix 전환은 비범위(별도 Work, tool/schema cascade).
- ai-deck product feature/code(렌더링·compiler 로직)는 비범위. DR renumber 참조 cascade만.
- harness source에 새 helper(`manifest-init` 등) 추가 비범위(DR-034 §6).
- archive historical DR 참조는 renumber하지 않는다(현행 live 참조만 정합).
- DR-034 상태 변경(Draft→Accepted)은 이 Work에서 단독 확정하지 않고 판단표 + owner 승인.

## Risk

| Risk | Level | Mitigation |
| --- | --- | --- |
| high-band이 미래 framework DR과 재충돌 | Low | framework DR=799 이하로 정책화, 800-999는 product/adopter 전용 대역으로 DR에 명문화(DR-042) |
| `DR-8xx`가 기존 `DR-[0-9]{3}` 도구에서 누락/오작동 | Medium | Slice A에서 3개 도구 실측 호환 확인. 깨지면 정책 보류 후 재검토 |
| product 참조 cascade 누락(broken ref) | Medium | grep 전수 + renumber 후 재검색, ai-deck invariant 확인 |
| real apply가 CHORE-003 temp와 drift | Medium | temp result tree를 base로 재현, Slice B/C delta만 추가, re-check |
| cross-repo write 사고 | Medium | clean base 전용 branch, owner 승인 전 PR/merge 금지 |
| DR-034 과대 승격 | Medium | Slice E 판단표만, 상태 변경 별도 owner-approved |
| scope sprawl into ai-deck product code | Medium | Scope Guard 고정(DR 참조 cascade만) |

## Done Criteria
- [x] Codex B R1 red-team review + Claude A response와 consensus가 기록된다.
- [x] DR namespace 정책이 **DR로 결정·기록**된다: DR-042 Accepted(framework 799↓ / product·adopter 800-999) + `DR-[0-9]{3}` 도구 호환 실측 + 장기 PDR/4자리 비범위 명시. HARNESS-NAMING-RULES §DR ID SSoT 갱신.
- [x] ai-deck product DR 4개가 high-band(`DR-801~804`)으로 renumber되고 참조 cascade가 정합된다(grep clean, owner sign-off).
- [x] `docs/decisions/README.md` 생성으로 invariant `[3]` index closure PASS.
- [x] 실제 ai-deck `feature/*` branch에 apply + PR(base develop). `--check`=framework in-sync + customized accepted-drift, invariant 결과 기록.
- [x] DR-034 "실제 target migration" evidence 1건 확보 + 승격 판단이 기록된다: DR-034는 Draft 유지, Accepted 승격은 2nd adopter/helper signal 판단 후 별도 owner-approved decision.
- [x] Result review/takeover 기록이 남고, ai-deck PR 결과가 기록된다.
- [x] 사용자 최종 승인 후 `/work-close` 가능한 상태가 된다.

## Verification (F5 — source/target 분리)
- **source policy change:** 정책 DR 기록 후 `bash scripts/tests/check-shipped-dr-closure.sh`(source shipped DR closure 전용), `git diff --check`. 도구 호환: `DR-801` 3자리 샘플로 regex 통과 확인.
- **target product DR renumber:** `scripts/tests/check-scaffold-invariants.sh <ai-deck branch>` `[1]`(no-dangling) `[3]`(index closure) PASS + `docs/decisions/README.md` diff + **live grep으로 old-ID(`DR-014/021/022/023`) 0**(archive grep은 별도, old-ID 허용). `check-shipped-dr-closure`를 product DR 호환 증거로 쓰지 않는다.
- **real apply:** `scripts/create-harness.sh --check <ai-deck branch>`=framework in-sync + customized accepted-drift, pre-apply drift guard 4항목 기록.
- scope self-check: PDR 전환·4자리 ID·product code 변경·harness helper 추가 없음

## Cross-Agent Review

### Cross-Agent Review And Discussion

Codex B는 red team reviewer로서 아래를 검토한다.

- **정책 band 타당성:** reserved high-band(`DR-8xx/9xx`)가 옳은 단기안인가? `DR-[0-9]{3}` 도구가 실제로 8xx를 깨지 않나? framework가 8xx를 절대 안 쓴다는 보장은 어떻게 명문화하나?
- **PDR 비범위 경계:** 장기 PDR을 이 Work에서 빼는 게 맞나, 아니면 정책 DR이 PDR 경로까지 함께 못박아야 하나?
- **renumber cascade 완전성:** product 참조 전수(특히 archive·manifest)를 어디까지 고치고 어디까지 두나? broken ref 위험.
- **real apply ↔ rehearsal 일치:** CHORE-003 temp result를 real apply에 그대로 쓰는 게 안전한가? 그 사이 source drift?
- **DR-034 승격:** real apply 1건으로 condition 충족이라 적는 게 맞나? Accepted까지 가면 과속 아닌가?

Expected output: P1/P2/P3 findings + direction-level concern 최소 1개(또는 없음) + 각 finding별 accept/defend/revise.

#### R1 Review Result — Codex B

**최종 판정: Request changes before execution.** 방향 자체는 맞다. CHORE-003이 실제 apply 직전 rehearsal에서 migration body를 defend 가능하게 만들었고, blocker가 product/adopter DR namespace임을 좁혔으므로 reserved high-band 정책 + ai-deck real apply를 다음 Work로 여는 것은 합리적이다. 다만 현재 plan은 "DR-8xx/9xx가 regex에 잡힌다"와 "framework가 앞으로 그 band를 쓰지 않는다"를 같은 것으로 취급할 위험이 있고, renumber cascade와 DR-034 판단도 실행 전 더 정확히 잠가야 한다.

**Direction-level concern:** 정책(harness)과 ai-deck cross-repo 실행을 한 Work에 묶는 것은 가능하지만, Slice A 정책 DR이 review/owner sign-off로 먼저 닫히지 않은 상태에서 Slice B~D를 진행하면 product repo renumber가 아직 안정화되지 않은 namespace 결정을 따라가게 된다. 이 Work 안에서 묶어도 되지만, **Slice A 완료 + owner 승인**을 hard gate로 두고 그 뒤에만 ai-deck write를 열어야 한다.

| ID | Severity | Finding | Basis | Recommendation | A 선택지 |
| --- | --- | --- | --- | --- | --- |
| F1 | P1 | reserved high-band 정책이 "도구 호환"은 되지만 "미래 framework 비사용" 보장은 아직 약하다 | `check-scaffold-invariants.sh`와 `check-shipped-dr-closure.sh`는 `DR-[0-9]{3}`를 grep하므로 `DR-801`/`DR-999`는 잡힌다. 그러나 Work의 "framework DR은 저번호 순차(현재 ~DR-041)이므로 8xx/9xx와 영구 비충돌"은 현재 상태 설명이지 미래 금지 규칙이 아니다. `scripts/create-harness.sh`의 shipped DR seed도 현재 `DR-007/008/013/014/027/029`만 default adapt한다. | 정책 DR에 exact allocation을 못박는다: framework/source DR은 `DR-001`~`DR-799`, adopter/product-local DR은 `DR-800`~`DR-899`, `DR-900`~`DR-999`는 future/reserved 등. 또한 `docs/HARNESS-NAMING-RULES.md`, DR registration/README/template 중 어디가 ID 발급 SSoT인지 명시하거나 업데이트 대상에 넣는다. 단순 "현재 낮으니 안전"으로 닫으면 같은 문제를 뒤로 미룬다. | revise 필수 |
| F2 | P1 | Slice A 정책 결정 없이 ai-deck renumber/apply까지 한 Work에서 밀면 scope gate가 흐려진다 | Work는 source 정책 DR 생성, ai-deck product DR 4개 renumber, decision-index 생성, real apply/PR을 한 흐름으로 둔다. 이 자체는 가능하지만, policy choice가 틀리면 product file rename과 archive/reference cascade를 되돌리는 비용이 커진다. | Slice A를 hard gate로 격상한다. 정책 DR 초안 + source-side validation + owner sign-off가 끝나기 전에는 ai-deck write 금지. Round Log/Checkpoints에도 "Slice A accepted before cross-repo write"를 명시한다. | revise |
| F3 | P2 | `DR-[0-9]{3}` 호환은 high-band에 유리하지만, regex가 boundary-less라 4자리 ID를 오인식한다 | 실측: `printf 'DR-014 PDR-014 DR-801 DR-999 DR-1000 DR-80' \| grep -oE 'DR-[0-9]{3}'`가 `DR-014`, `DR-014`, `DR-801`, `DR-999`, `DR-100`을 출력한다. 즉 `PDR-014`도 내부 `DR-014`로 잡히고, `DR-1000`도 `DR-100`으로 잘린다. | reserved-band 정책은 **정확히 3자리 `DR-NNN`만 허용**한다고 명시한다. 장기 PDR은 regex boundary/tool cascade 없이는 금지라는 RF2 결론을 유지하고, `DR-1000+`도 현행 도구 기준 금지한다. | revise |
| F4 | P2 | renumber cascade 대상이 Work보다 넓다 | temp/actual ai-deck grep에서 live 참조는 `skills/create-deck.md:404`, `docs/PLAN.md:431`, `docs/STATUS.md:34-36`, decision 파일명/제목/frontmatter(`DR-014/021/022/023`)에 있다. archive에도 다수 참조가 있으나 Work는 archive historical 참조를 renumber하지 않는다고만 두고, `STATUS.md`와 decision frontmatter/id cascade는 명시가 약하다. `.harness/manifest.json`에는 framework `DR-014-archive-policy.md`가 tracked path로 남는다. | Slice B에 exact mapping table(`DR-014→DR-801` 등)과 live cascade list를 추가한다: filenames, h1/title, frontmatter `id`, live docs (`PLAN`, `STATUS`, `skills/create-deck`), decisions README. Archive는 historical preserve로 두되, "archive dangling/old token 허용"을 명시하고 live grep과 archive grep을 분리해 검증한다. | revise |
| F5 | P2 | `check-shipped-dr-closure.sh`는 source shipped DR closure 검사이지 adopter product DR-8xx 검증기가 아니다 | 스크립트는 `scripts/create-harness.sh`의 default `adapt ... docs/decisions/DR-[0-9]{3}` seed를 뽑고, source shipped docs가 seed 밖 DR을 참조하면 실패시킨다. ai-deck product `DR-8xx`가 target `docs/decisions`에 존재하는지는 `check-scaffold-invariants.sh` `[1]/[3]`와 target grep/index로 봐야 한다. | Verification을 분리한다: source policy change는 `check-shipped-dr-closure.sh`; target product DR renumber는 `check-scaffold-invariants.sh <ai-deck>` `[1]/[3]` + `docs/decisions/README.md` diff + live grep. `check-shipped-dr-closure`를 product DR 호환 증거로 쓰지 않는다. | revise |
| F6 | P2 | CHORE-003 temp result를 base로 쓰는 것은 defend 가능하지만, 재현/drift guard가 hard gate가 아니다 | 현재 실측으로 `temp/.../ai-deck-copy`는 `--check` `78 tracked, 65 in-sync, 13 drifted`를 재현했고, ai-deck `HEAD`, `origin/develop`, `origin/main`은 모두 `7941585`다. 그러나 source branch가 CHORE-004에서 정책 DR을 추가하면 source side가 바뀌며, temp result의 manifest baseline과 real apply baseline이 달라질 수 있다. | real apply 직전 gate를 추가한다: source `develop`/feature diff 확인, temp result 재생성 또는 최소 `--check` 재실행, ai-deck base `7941585 == origin/develop` 확인, Slice A 정책 DR이 scaffold seed/default manifest에 들어가지 않는지 확인. policy DR을 source에 추가하더라도 target real apply manifest와 충돌하지 않는다는 기록이 필요하다. | revise |
| F7 | P3 | DR-034 문구는 "condition 충족"과 "Accepted 승격"을 더 분리하면 안전하다 | DR-034는 Draft이고 promotion condition은 "두 번째 adopter 또는 실제 target migration"이다. CHORE-004 real apply가 성공하면 첫 actual target migration evidence는 생기지만, 같은 ai-deck 계열 1건이며 helper 필요성(30블록 수동 병합, namespace policy Work)도 signal로 남는다. | "DR-034 실제 target migration condition 충족"보다는 "condition evidence 1건 확보"로 쓰고, Accepted 판단표에서는 Draft 유지+2nd adopter 필요 / helper 필요를 진지한 옵션으로 둔다. 상태 변경은 별도 owner-approved decision 유지. | revise lightly |

**정합성 확인(defend 가능):**
- reserved high-band는 단기안으로 defend 가능하다. 현행 `DR-[0-9]{3}` 기반 도구는 `DR-801`을 인식하며, `PDR-`처럼 도구 cascade를 즉시 요구하지 않는다.
- PDR 구현 비범위는 맞다. 다만 정책 DR에는 장기 옵션과 현행 금지 이유(`PDR-014`가 `DR-014`로 오인식될 수 있음)를 남겨야 한다.
- archive historical 참조를 일괄 renumber하지 않는 방향은 defend 가능하다. 단 live grep과 archive grep을 분리하고, archive는 historical old-ID 허용이라고 기록해야 reviewer가 broken ref로 오판하지 않는다.
- real apply를 CHORE-003 temp result에서 시작하는 것은 현재 기준 defend 가능하다. ai-deck base가 `7941585`로 고정돼 있고 temp result도 동일 검증 결과를 재현했다. 다만 F6 drift guard 없이는 시간이 지나며 evidence가 stale해진다.

#### R1 A Response — Claude A

Codex B의 **Request changes를 7건 전면 accept**한다. 방향(reserved-band 단기 + PDR 별도)은 유지되나, B가 "도구가 8xx를 인식한다 ≠ framework가 8xx를 안 쓴다"를 정확히 분리했고, F3 regex boundary는 직접 grep으로 실측한 핵심 catch다. 3건을 내가 재확인했다.

**실측 재확인:**
- **F3**: `printf 'DR-014 PDR-014 DR-801 DR-999 DR-1000 DR-80' | grep -oE 'DR-[0-9]{3}'` → `DR-014 DR-014 DR-801 DR-999 DR-100`. `PDR-014`가 내부 `DR-014`로, `DR-1000`이 `DR-100`으로 오인식. **정책은 정확히 3자리 `DR-NNN`만 허용, 4자리·PDR은 tool cascade 전 금지.** `DR-800~899`(3자리)는 안전.
- **F1 SSoT**: `docs/HARNESS-NAMING-RULES.md` §DR ID(L65~69)가 DR ID SSoT인데 **allocation band가 없다.** 정책 DR이 이 SSoT를 갱신한다.
- **F6 scaffold seed**: `create-harness.sh` adapt block은 framework DR을 **이름으로 명시** adapt한다(DR-007/008/013/...). 신규 정책 DR은 adapt block에 넣지 않으므로 **adopter에 shipped되지 않고 shadow manifest(78 tracked)도 불변** → real apply baseline 안전.

| Finding | A 판정 | 반영 |
| --- | --- | --- |
| F1 (P1) reserved-band enforcement | **Accept** | 정책 DR에 **exact allocation** 못박음: framework/source DR=`DR-001~799`, product/adopter-local DR=`DR-800~899`, `DR-900~999`=future/reserved. ID 발급 SSoT=`docs/HARNESS-NAMING-RULES.md §DR ID` 갱신(+ DECISION-TEMPLATE/README 분류 note). "현재 낮으니 안전" 문구 제거. |
| F2 (P1) Slice A hard gate | **Accept** | Slice A(정책 DR accepted + owner sign-off)를 **cross-repo write의 hard gate**로 격상. Checkpoints/Round Log에 "Slice A accepted before any ai-deck write" 명시. |
| F3 (P2) regex boundary | **Accept** | 정책에 **정확히 3자리 `DR-NNN`만** 명문화. `PDR-`(내부 `DR-NNN` 오인식)와 `DR-1000+`(truncate)는 현행 도구 기준 금지, 장기 PDR은 regex boundary + tool cascade 별도 Work. |
| F4 (P2) cascade completeness | **Accept** | Slice B에 **exact mapping table**(`DR-014→DR-801`…) + **live cascade list**: filenames, h1/title, frontmatter `id`, live docs(ai-deck `STATUS.md`/`PLAN.md`/`skills/create-deck.md`), `docs/decisions/README.md`. archive=historical preserve(old-ID 허용), **live grep ↔ archive grep 분리 검증**. |
| F5 (P2) verification split | **Accept** | source policy change=`check-shipped-dr-closure.sh`; target product DR=`check-scaffold-invariants.sh <ai-deck>` `[1]/[3]` + `README.md` diff + live grep. `check-shipped-dr-closure`를 product DR 호환 증거로 쓰지 않음. |
| F6 (P2) real apply drift guard | **Accept** | Slice D 앞에 **pre-real-apply gate**: source `develop`/feature diff, temp result `--check` 재실행, ai-deck base `7941585==origin/develop` 확인, **정책 DR이 adapt block/shadow manifest에 들어가지 않음 확인**(위 실측 — 안 들어감). |
| F7 (P3) DR-034 wording | **Accept** | "condition 충족" → **"condition evidence 1건 확보"**. 판단표에 Draft 유지+2nd adopter 필요 / helper 필요를 진지한 옵션으로. 상태 변경은 owner-approved 유지. |

**Direction concern 수용:** 정책+실행 한 Work 유지하되 **Slice A 완료+owner 승인을 hard gate**로 두고 그 뒤에만 ai-deck write. consensus 도달.

### Round Log

| Round | Reviewer | Status | Request | Result | A Response |
| --- | --- | --- | --- | --- | --- |
| R1 | Codex B | A responded (consensus) | Work file + policy/real-apply plan red-team review | Request changes before execution. high-band enforcement, Slice A hard gate, regex boundary, renumber cascade, verification 분리, temp/source drift guard, DR-034 wording | 7건 전면 accept. exact allocation(001-799/800-899/900-999) + HARNESS-NAMING-RULES SSoT, Slice A hard gate, 3자리 DR-NNN only, mapping table+live/archive 분리, verification split, pre-apply drift guard(정책 DR 미shipped 실측), DR-034 evidence 1건 wording |
| Result | Codex B takeover | Completed | Claude A Bash classifier outage 후 closeout/real apply 이어받기 | temp 최종 `--check` 78/65/13 재확인, ai-deck actual apply/PR #51 merge 완료, harness closeout 기록 | 승인된 mapping/정책 범위 내에서 real apply 완료. DR-034는 actual target migration evidence 1건만 기록하고 Draft 유지 |

### Consensus Log

| Item | Status | Consensus / Remaining Disagreement |
| --- | --- | --- |
| R1 Direction: policy + real apply in one Work | Consensus | 한 Work 유지 + Slice A(정책 DR accepted + owner sign-off)를 cross-repo write hard gate로. A accept |
| F1 reserved-band enforcement | Consensus (owner amended) | exact allocation + `HARNESS-NAMING-RULES §DR ID` SSoT 갱신. **owner 조정**: product-adopter band를 800-899→**800-999(200슬롯)**로 확장, 900-999 별도 reserved 제거. `DR-1000+`/PDR은 비범위(`DR-950`/200개 trigger 시 expansion Work) |
| F2 Slice A hard gate | Consensus | 정책 DR accepted 전 ai-deck write 금지. Checkpoints/Round Log 명시 |
| F3 regex boundary | Consensus | 정확히 3자리 `DR-NNN`만. `PDR-`/`DR-1000+`는 tool cascade 전 금지(실측: `PDR-014`→`DR-014`, `DR-1000`→`DR-100`) |
| F4 renumber cascade completeness | Consensus | exact mapping table + live cascade list(ai-deck STATUS/PLAN/create-deck/decision id·title/README). archive historical preserve, live↔archive grep 분리 |
| F5 verification split | Consensus | source=`check-shipped-dr-closure`, target=`check-scaffold-invariants <ai-deck>` `[1]/[3]`+README diff+live grep |
| F6 real apply drift guard | Consensus | pre-apply gate(source diff/temp re-check/ai-deck base). 정책 DR은 adapt block 미추가→shadow manifest 불변(실측) |
| F7 DR-034 wording | Consensus | "condition evidence 1건 확보", Draft+2nd adopter/helper 옵션 유지, 상태 변경 owner-approved |
| Result evidence | Consensus | ai-deck real apply 완료(PR #51 merged). `--check` 78 tracked / 65 in-sync / 13 accepted-drift, invariant [1]~[4] PASS, [5] expected fail. DR-034 Accepted 승격은 보류 |

## Checkpoints

| CP | Description | Status |
| --- | --- | --- |
| 1 | Work 파일 + Active pointer + cross-agent frame (Claude A / Codex B) | 완료 |
| 2 | Codex B R1 red-team review + A response + consensus | 완료 (7건 accept) |
| 3 | Slice A DR namespace 정책 결정 + DR 기록 (allocation/3자리 rule/SSoT) ★ HARD GATE | 완료 (DR-042 **Accepted** owner sign-off 2026-06-21, 검사 PASS — gate 통과, ai-deck write 가능) |
| 4 | ai-deck product DR renumber cascade + decision-index (owner sign-off) — Slice A accepted 후에만 | 완료 (temp + actual ai-deck: renumber DR-801~804 + index, invariant [1][2][3][4] PASS) |
| 5 | real apply to ai-deck + PR + DR-034 판단 | 완료 (ai-deck PR #51 merged, DR-034 evidence 1건 확보/Draft 유지) |
| 6 | Codex B result review + owner 승인 + `/work-close` | 완료 |

## Next Actions
- ✓ CHORE-003 rehearsal close에서 후속 후보로 re-scope
- ✓ feature branch `feature/chore-20260621-004-adopter-dr-namespace-apply` 생성
- ✓ Work 파일 + cross-agent frame 작성 (role swap: Claude A / Codex B)
- ✓ Codex B R1 red-team review 기록 (Request changes: F1/F2 P1, F3-F6 P2, F7 P3)
- ✓ Claude A R1 response + consensus (7건 accept: exact allocation·SSoT, Slice A hard gate, 3자리 rule, mapping table, verification split, drift guard, DR-034 wording)
- ✓ Slice A 정책 결정·DR 기록 (★ hard gate — ai-deck write 전 필수)
- ✓ Slice A accepted 후 B(renumber)/C(index)/D(real apply)/E(DR-034) 실행
- ✓ result review/takeover, owner 승인, ai-deck PR, `/work-close`

## Discovery
- 이 Work는 CHORE-003 rehearsal의 real-apply blocker(DR namespace)를 정책으로 닫고 실제 apply까지 완료하는 후속이다. real apply base = CHORE-003 temp result tree(검증 완료).
- 정책 핵심 trade-off: 단기 reserved-band(`DR-8xx`, 도구 호환·낮은 risk) vs 장기 `PDR-`(의미 선명하나 `DR-[0-9]{3}` 도구 cascade 선행). 이 Work는 단기 채택 + 장기 trade-off만 DR에 기록하고 PDR 구현은 분리(Codex RF2 합의).

## Slice A Output (정책 결정 — ★ HARD GATE 통과)

**DR-042 Accepted (owner sign-off 2026-06-21). gate 통과 → Slice B(ai-deck write) 진행 가능.** 단 Slice B는 product/cross-repo write라 별도 owner 승인.

### 산출물
- **정책 DR**: `docs/decisions/DR-042-adopter-dr-namespace-allocation.md` (Status: **Accepted**, owner sign-off 2026-06-21). high-band allocation(framework 799↓ / product·adopter 800-999, 200슬롯) + 3자리 rule + PDR/4자리 비범위 + 장기 trade-off.
- **SSoT 갱신**: `docs/HARNESS-NAMING-RULES.md` §DR ID에 allocation 표 추가(framework 799 이하 / product·adopter **800–999** `DR-8xx`~`DR-9xx`). shipped 문서이므로 리터럴 3자리 DR 토큰 없이 self-describe(shipped-DR-closure 준수).
- **decisions index**: `docs/decisions/README.md`에 DR-042(Accepted) row 등록.

### 도구 호환 실측 (F1/F3 확정)
- 다음 free framework DR = `DR-042`(현재 최고 DR-041).
- `DR-800`~`DR-999`(3자리)는 `DR-[0-9]{3}` 도구에서 정확히 매칭, truncate·숫자 상한 가정 없음 → **도구 무변경 적용 가능**.
- `check-shipped-dr-closure.sh`는 source seed 기준이라 adopter product DR-8xx와 무관(F5 split 확인). HARNESS-NAMING-RULES 갱신 후 closure **OK**, scaffold invariants **PASS**.

### 검증
- `bash scripts/tests/check-shipped-dr-closure.sh` → OK
- `bash scripts/tests/check-scaffold-invariants.sh` → PASS
- `git diff --check` → clean

### Owner Sign-off (2026-06-21 — DR-042 Accepted)
- DR-042 정책 승인됨(owner 조정: product band 800-999 200슬롯). gate 통과.

## Slice B+C Output (shadow/patch — ai-deck 무수정, temp result tree)

**`temp/chore-20260621-003/ai-deck-copy`에 반영. 실제 ai-deck repo write 없음(owner 승인 후 real apply).**

### Renumber mapping (실행 완료, temp)
| old (product) | new | 처리 |
| --- | --- | --- |
| `DR-014-ppt-language-policy` | `DR-801` | 파일 rename + h1. **framework `DR-014-archive`는 보존** |
| `DR-021-preset-default-policy` | `DR-802` | rename + h1 |
| `DR-022-results-pptx-git-tracking` | `DR-803` | rename + h1 |
| `DR-023-generate-blueprint-consolidation` | `DR-804` | rename + h1 + frontmatter `id` |

### Live cascade (전수, temp)
- ai-deck `docs/STATUS.md`: DR-021/022/023 → 802/803/804
- ai-deck `docs/PLAN.md`: DR-014(PPT 언어) → DR-801
- ai-deck `skills/create-deck.md`: DR-014(언어 규칙) → DR-801
- **framework DR-014 refs 보존**: `DR-008`(archive mirror), `DR-013`(Archive 정책), `DR-014-archive` 파일 — 미변경
- archive historical 참조: 미변경(old-ID 보존, live↔archive grep 분리)

### Decision-Index (Slice C, temp)
- `docs/decisions/README.md` 생성: framework DR(007/008/013/014/027/029) + product DR(801~804) 분리 표기. band 설명은 리터럴 3자리 DR 토큰 없이 self-describe(invariant 통과).

### 검증 (F5 split)
- **target invariant** `check-scaffold-invariants.sh <ai-deck-copy>`: `[1]` no-dangling **PASS**, `[2]` leak **PASS**, `[3]` index closure **PASS**, `[4]` **PASS**. `[5]` 0-drift만 FAIL = F1 accepted-drift(expected).
- **live grep**: product `DR-021/022/023` 0, product `DR-014` 0(framework archive refs만 잔존). 새 `DR-801~804` 파일 h1 정합.
- **drift**: F6 drift guard 발동 — Slice A가 source `HARNESS-NAMING-RULES`를 갱신해 temp(Slice A 이전 생성)와 어긋남. current source로 sync + **shadow manifest 재생성(post-Slice-A)** → 13 accepted-drift(CHORE-003 set)로 복귀. DR-042는 adapt block 미추가 → manifest 78 불변(F6 ④ 충족).
  - Codex takeover 후 최종 재확인: `bash scripts/create-harness.sh --check temp/chore-20260621-003/ai-deck-copy` → `78 tracked, 65 in-sync, 13 drifted`.

### Owner Sign-off
- renumber mapping 승인됨: `DR-014-ppt/021/022/023` → `DR-801~804`.
- cross-repo write 승인 후 Slice D actual apply 진행 완료.

## Slice D Output (actual ai-deck apply + PR)

**Actual target:** `/Users/kyungseo/dev-home/vibe/ai-deck-compiler`

### Branch / Commit / PR
- ai-deck base 확인: `HEAD == origin/develop == origin/main == 7941585`(apply 전 clean base).
- branch: `feature/chore-20260621-004-harness-upgrade`
- commit: `ade61c6 chore: harness 1.3.0 마이그레이션 및 DR namespace 정렬`
- PR: <https://github.com/kyungseo/ai-deck-compiler/pull/51> (base `develop`)
- merge: 2026-06-21T08:23:08Z, merge commit `5a863fa88a6189d2511637737f098f4f2017ecda`

### Actual Verification
- `bash scripts/create-harness.sh --check /Users/kyungseo/dev-home/vibe/ai-deck-compiler` → `78 tracked, 65 in-sync, 13 drifted`(CHORE-003 accepted-drift set).
- `bash scripts/tests/check-scaffold-invariants.sh /Users/kyungseo/dev-home/vibe/ai-deck-compiler` → `[1]` no dangling refs PASS, `[2]` leak PASS, `[3]` decision-index closure PASS, `[4]` PASS, `[5]` 0-drift FAIL expected(accepted-drift).
- live grep: product old IDs `DR-021/022/023` 0, product `DR-014` 0. 남은 `DR-014`는 framework/archive policy 참조(`DR-014-archive`, `DR-008`, `DR-013`, decisions README)뿐.
- `git -C /Users/kyungseo/dev-home/vibe/ai-deck-compiler diff --check` → clean.
- GitHub check: ai-deck PR #51 `harness-validate` PASS.

## Slice E Output (DR-034 판단)

- 이번 real apply는 DR-034의 "actual target migration"에 해당하는 **evidence 1건**을 확보했다.
- 단, evidence는 같은 ai-deck 계열에서 이어진 1건이고, 13 accepted-drift/수동 보존 판단/namespace 정책 Work가 필요했다는 helper signal이 남는다.
- 따라서 **DR-034는 Draft 유지**한다. Accepted 승격은 2nd adopter 또는 helper 경로 정리 후 별도 owner-approved decision으로 판단한다.
