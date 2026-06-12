---
id: CHORE-20260612-005
priority: P1
status: Done
risk: L2
scope: Backlog row 제거/정리 시점이 `HARNESS-PROTOCOL.md`, `skills/workflow/work-plan.md`, `skills/workflow/work-close.md`, `DR-013`에서 서로 다르게 설명되는 lifecycle drift를 정리한다. 단일 시점은 "Work Done 처리 시 동일 commit에 포함"을 기준으로 검토하며, archive 정책 자체와 W3 canonical restructure는 범위 밖이다.
appetite: 0.5d
planned_start: 2026-06-12
planned_end: 2026-06-12
actual_end: 2026-06-12
related_dr: [DR-013]
related_work: [CHORE-20260607-002, CHORE-20260611-005]
---

# CHORE-20260612-005: Backlog Row Lifecycle SSoT 정비

## Top Summary

- **목표:** backlog row lifecycle의 제거/정리 시점을 한 기준으로 정렬해 `/work-close` 때마다 수동 해석이 필요한 마찰을 없앤다.
- **왜 지금:** W2는 완료됐고, W3 구조 작업으로 들어가기 전에 작은 lifecycle hygiene를 먼저 닫을 수 있다. 현재 drift는 실제 파일에 남아 있어 다음 closeout에서 다시 재현될 가능성이 높다.
- **핵심 경계:** tracking hygiene답게 작게 자른다. archive pending 정리, archive 누적 정책, README/MANUAL/GUIDE readability rewrite, W3 canonical/context-routing restructure는 이 Work에 포함하지 않는다.
- **역할 분리:** Codex는 author/driver, Claude는 red team reviewer다. Claude review 결과와 Round Log는 이 파일의 `Cross-Agent Review And Discussion`에 누적한다.

## Candidate Comparison

| 후보 | 지금 먼저 필요한가? | 운영 마찰 | 판단 |
| --- | --- | --- | --- |
| Backlog row lifecycle SSoT 정비 | 높음. 이미 세 문서와 DR 문구가 서로 다른 타이밍을 말한다 | `/work-close`마다 backlog row를 언제 지워야 하는지 수동 판정해야 한다 | **착수**. 작고 명확한 W4 hygiene로 먼저 닫는다 |
| Archive 누적 관리 정책 | 중간. archive pending 5개로 soft warning 대상이지만 archive 자체는 사용자 명시 없이는 범위 확장 금지 | context load 비용은 낮고, 실해악 정의가 먼저 필요하다 | 이번 Work에서는 제외. 별도 후보로 유지 |
| Canonical 개념 계층화 + context-routing restructure | 중요하지만 L3 구조 작업 | 큰 범위의 IA 재배열이며 trigger/context routing까지 확장된다 | W3로 남긴다. 작은 hygiene 완료 후 착수하는 편이 안전 |

**결론:** closeout / STATUS / backlog row 타이밍 불일치는 실제 운영 마찰이다. 다만 W3 restructure로 끌고 갈 만큼 큰 구조 문제가 아니라, `Backlog row lifecycle SSoT 정비`를 작은 hygiene Work로 먼저 닫는 것이 맞다.

## Background / Facts

- `skills/workflow/work-close.md` Step 5는 backlog row 제거를 "Work Done 처리와 동일 commit"으로 정의한다.
- `skills/workflow/work-plan.md`의 Backlog candidate 착수 연결은 "develop merge 후 tracking-only commit"을 말한다.
- `docs/HARNESS-PROTOCOL.md` Pruning Policy는 "연관 Work 파일이 archived"일 때 backlog 행 삭제로 설명한다.
- `docs/decisions/DR-013-work-file-spec.md`의 Backlog Candidate ID-less 정책도 "develop merge 후 tracking-only commit" 문구를 포함한다.
- `work-plan.md`와 `DR-013`의 동일 문장은 사실 두 연산을 섞고 있다: `Active 표시`는 backlog row에 Work ID를 역기입하는 경로이고, `제거`는 완료된 row를 backlog에서 지우는 경로다. 두 경로를 분리하지 않으면 "develop merge 후"가 제거 정책에도 잘못 전파된다.
- `docs/HARNESS-PROTOCOL.md` Pruning Policy의 Quick Mode 행은 별도 경로다: `Done — Work 파일 없음 (Quick Mode) | Phase 완료 또는 다음 harness review 시 삭제`. 이번 Work의 직접 수정 대상은 Work 파일이 있는 첫 행뿐이며, Quick Mode 행은 유지해야 한다.
- backlog 항목의 2026-06-11 메모는 DR-013 문구가 원래 "ID-less candidate에 Work ID를 역기입하지 않는다"는 맥락인데 완료 row 제거 일반 규칙으로 오독될 수 있다고 지적한다.
- backlog 기준으로 W3는 `docs/HARNESS-PROTOCOL.md`의 trigger family 재구성 가능성을 포함하지만, 현재 candidate 설명에는 `skills/workflow/work-plan.md`가 직접 편집 대상으로 등장하지 않는다. 따라서 이번 Work는 `HARNESS-PROTOCOL.md` 안에서도 Pruning Policy 국소 정합화로만 제한하고, trigger family/IA 재배열은 건드리지 않는다.
- `docs/works/harness/README.md` 기준 archive pending Work가 5개다. 이는 session-start soft warning 대상이지만, 사용자가 이번 Work 범위에 archive 처리를 넣지 말라고 명시했으므로 이 Work의 실행 범위에는 포함하지 않는다.

## Scope / Non-Goals

### Scope

- backlog row 제거 시점을 한 기준으로 통일한다.
- `work-plan.md`와 `DR-013`에서 `제거`와 `Active 표시`를 별도 문장으로 분리한다.
- `Active 표시` 경로에는 `develop merge 후 tracking-only commit`을 유지하고, `제거` 경로에서는 해당 문구를 제거한다.
- `HARNESS-PROTOCOL.md` Pruning Policy의 첫 행만 `Work Done closeout` 기준으로 조정한다. Quick Mode 행은 그대로 유지한다.
- `DR-013`의 Backlog Candidate ID-less 정책 문구를 `ID backfill 금지` 맥락으로 한정하고, row 제거 일반 규칙은 canonical closeout 흐름으로 위임한다.
- Work 파일에 Claude R0/R1 review 결과를 누적한다.

### Non-Goals

- archive pending Work 이동 또는 archive index 정리.
- archive 누적 관리 정책 결정.
- W3 canonical/context-routing restructure.
- `docs/STATUS.md` Active pointer 변경. R0 합의 전에는 변경하지 않는다.
- README/MANUAL/GUIDE류 readability rewrite.
- hook/CI hard-gate 구현.

## Files

| 파일 | 계획 |
| --- | --- |
| `skills/workflow/work-close.md` | 기준 문서로 유지. 필요 시 Step 5 문구를 더 명확히 해 "backlog에서 착수된 항목"의 제거 조건과 skip 조건을 정리 |
| `skills/workflow/work-plan.md` | 혼합 문장을 분리 편집. `Active 표시`는 develop merge 후 tracking-only, `제거`는 `/work-close` 기준으로 분리 |
| `docs/HARNESS-PROTOCOL.md` | Pruning Policy 첫 행만 Work Done closeout 기준으로 정렬. Quick Mode 행과 trigger family는 건드리지 않음 |
| `docs/decisions/DR-013-work-file-spec.md` | `work-plan.md`와 같은 방식으로 혼합 문장을 분리. ID-less candidate 정책은 `ID backfill 금지` 경로만 남기고 row 제거는 `/work-close`로 위임 |
| `docs/backlog/HARNESS.md` | Work 완료 시 해당 candidate row 제거 대상. R0 이후 구현 범위에 포함할지 closeout 시점에 재확인 |
| `docs/works/harness/README.md` | 이 Work를 Active에 등록. Done/Archive 처리는 `/work-close`에서 처리 |
| 이 Work 파일 | plan, findings, Claude review Round Log SSoT |

## Plan

1. **R0 Plan Review 요청** — Claude가 방향·범위·타이밍 기준을 red team으로 검토한다.
2. **W3 scope check 반영** — backlog candidate 기준으로 `HARNESS-PROTOCOL.md`는 W3 trigger family simplification과 잠재 overlap이 있음을 기록하고, 이번 Work는 Pruning Policy 국소 정합화만 수행한다고 범위를 고정한다. `work-plan.md`는 현재 W3 candidate 직접 편집 대상이 아님을 기록한다.
3. **용어 기준 확정** — `ID backfill`, `Active 표시`, `backlog row removal`, `Work Done`, `Archive`를 분리해 문구 기준을 정한다.
4. **before/after 문안 확정** — `work-plan.md`와 `DR-013`의 혼합 문장을 둘로 나눈다:
   - before: `backlog row 정리 (제거 또는 Active 표시)는 develop merge 후 tracking-only commit으로 처리한다.`
   - after A: `backlog row의 Active 표시는 develop merge 후 tracking-only commit으로 처리한다.`
   - after B: `완료된 backlog row 제거는 /work-close의 Work Done 처리 흐름에서 수행한다.`
5. **문서 수정** — `work-plan`, `work-close`, `HARNESS-PROTOCOL`, `DR-013`의 충돌 문구를 최소 수정한다.
6. **Targeted simulation** — `ID-less Candidate → Work Active → Work Done → backlog row 제거 → archive 보류` 흐름을 문서상으로 추적한다.
7. **검증** — grep 기반으로 stale timing phrase를 확인하고, 문서-only validation을 수행한다.
8. **R1 Result Review 요청** — Claude가 결과 문구와 누락 surface를 검토한다.
9. **Closeout** — 승인 후 `/work-close`로 Work Done 처리, backlog row 제거, STATUS pointer 필요 여부 확인.

## Done Criteria

- [x] `work-plan.md`, `work-close.md`, `HARNESS-PROTOCOL.md`, `DR-013`의 backlog row 제거 시점이 서로 충돌하지 않는다.
- [x] `ID-less candidate에 Work ID를 역기입하지 않는다`는 착수 정책과 `완료된 backlog row 제거` 정책이 문서상 분리된다.
- [x] `Active 표시`와 `제거`가 `work-plan.md`와 `DR-013`에서 별도 문장으로 분리된다.
- [x] archive는 선택적 hygiene로 남고, backlog row 제거가 archive 이동에 종속되지 않는다.
- [x] `HARNESS-PROTOCOL.md` Pruning Policy의 Quick Mode 행은 유지되고, Work 파일이 있는 첫 행만 closeout 기준으로 정렬된다.
- [x] `Backlog row lifecycle SSoT 정비` candidate가 closeout 시 제거될지 여부가 명확하다.
- [x] Claude R0 plan review와 R1 result review가 `Cross-Agent Review And Discussion`에 기록된다.
- [x] `docs/STATUS.md` Active pointer는 R0 합의 전 변경하지 않는다.

## Verification

- `rg -n "develop merge 후 tracking-only|Work Done 처리와 동일 commit|Work 파일이 archived|backlog row|ID-less|역기입|Active 표시" skills/workflow/work-plan.md skills/workflow/work-close.md docs/HARNESS-PROTOCOL.md docs/decisions/DR-013-work-file-spec.md docs/backlog/HARNESS.md`
- `rg -n "trigger family simplification|Canonical 개념 계층화|work-plan\\.md|HARNESS-PROTOCOL\\.md" docs/backlog/HARNESS.md`
- `git diff --check`
- 문서상 work-close 시뮬레이션:
  - ID 없는 backlog Candidate 착수
  - backlog row에 Work ID를 즉시 적지 않음
  - Work 파일 Active 생성
  - Active 표시는 develop merge 후 tracking-only 경로로 남음
  - STATUS pointer는 승인 후에만 추가
  - Work Done 처리 시 backlog Summary/Details 제거
  - archive는 별도 승인 전 보류
- 필요 시 `bash -n scripts/create-harness.sh`는 N/A로 보고한다. scaffold script 변경이 없으면 실행하지 않는다.

## Risk / Reversal Cost

- **Risk:** lifecycle 문구를 과도하게 단순화하면 Quick Mode 완료 row, Superseded row, archive policy의 별도 의미가 흐려질 수 있다.
- **Risk:** `work-plan.md`의 tracking-only 문구를 제거하면서 "feature branch에서 backlog row에 Work ID를 역기입하지 않는다"는 병렬 충돌 방지 정책까지 약화할 수 있다.
- **Risk:** `HARNESS-PROTOCOL.md` Pruning Policy를 바꾸면 과거 archive 중심 설명과 현재 `/work-close` 중심 실행 절차의 관계를 다시 설명해야 한다.
- **Risk:** `HARNESS-PROTOCOL.md`는 W3 trigger family simplification의 잠재 편집 대상이므로, 이번 Work가 Pruning Policy 국소 수정 이상으로 번지면 W3와 충돌할 수 있다.
- **Reversal Cost:** Low to Medium. 문서-only 변경이지만 workflow canonical과 DR 문구를 건드리므로 잘못 정렬하면 다음 closeout 절차에 반복 혼선을 만든다.

## Open Questions

| ID | Question | Default Assumption |
| --- | --- | --- |
| OQ-1 | backlog row 제거의 SSoT를 `work-close.md` Step 5로 두고, `HARNESS-PROTOCOL.md`는 policy pointer로 낮추는가? | Yes |
| OQ-2 | `DR-013`은 Accepted DR이지만 실행 절차 문구를 현행 canonical에 맞게 amend할 수 있는가? | Yes, 변경 이력에 amended note를 추가 |
| OQ-3 | 이번 Work 자신의 backlog row는 구현 closeout 때 제거할 것인가? | Yes, 이 Work가 backlog candidate에서 착수됐으므로 `/work-close` Step 5 대상 |
| OQ-4 | archive pending 5개 soft warning을 이번 Work의 Done Criteria에 넣을 것인가? | No, 별도 archive 정책 후보로 유지 |
| OQ-5 | `HARNESS-PROTOCOL.md` W3 overlap 때문에 이번 Work를 미뤄야 하는가? | No. trigger family 재구성은 범위 밖이고, Pruning Policy 국소 정합화는 독립 수행 가능 |

## Claude R0 Plan Review Request

Claude R0 plan review 요청: CHORE-20260612-005 Backlog Row Lifecycle SSoT 정비

검토 포인트:

- 이 Work를 W3 restructure 전에 작은 W4 hygiene로 먼저 닫는 판단이 타당한가?
- 단일 기준을 "Work Done 처리 시 동일 commit"으로 두는 것이 현재 `work-close.md`와 실제 운영 마찰을 가장 잘 닫는가?
- `work-plan.md`/`DR-013`의 "develop merge 후 tracking-only commit" 문구를 `ID backfill 금지` 맥락으로 한정하는 방향이 맞는가?
- `HARNESS-PROTOCOL.md` Pruning Policy를 archive 기준에서 Work Done closeout 기준으로 바꿀 때 놓칠 위험이 있는가?
- Scope가 archive policy나 W3 canonical restructure로 번지지 않도록 충분히 작게 잘렸는가?

## Cross-Agent Review And Discussion

### Round Log

| Round | Reviewer | Status | Summary | Follow-Up |
| --- | --- | --- | --- | --- |
| R0 | Claude | Approved | `제거`와 `Active 표시` 분리, Quick Mode 행 보존, W3 overlap 인지 후 구현 승인 | 구현 진행 |
| R1 | Claude | Approved | blocking finding 없음. 착수 절차 안의 closeout 전방 참조는 약간 이질적이지만 현재 범위에서는 수용 가능 | Done 처리 진행 |

### R0 — Plan Review (Claude, 2026-06-12)

**Approval:** Approved

**Finding**

- `work-plan.md`/`DR-013`의 동일 문장은 `제거`와 `Active 표시`를 하나로 묶고 있어, `ID backfill 금지 맥락으로 한정`만으로는 오독 위험이 남는다. 문장 자체를 분리해야 한다.
- `HARNESS-PROTOCOL.md` Pruning Policy는 Quick Mode 행이 별도 경로인데, plan에 이 행을 유지한다는 구분이 없어서 구현 중 과잉 수정 위험이 있다.
- W3 candidate가 `HARNESS-PROTOCOL.md`를 건드릴 수 있으므로, W4-before-W3 판단에는 overlap 확인이 필요하다.

**Must-fix**

1. `work-plan.md`/`DR-013`은 맥락 주석이 아니라 분리 편집으로 처리한다.
2. Pruning Policy 변경 상세에 Quick Mode 행 보존을 명시한다.
3. backlog 기준 W3 scope를 확인하고, 이번 Work가 그 범위를 덮어쓰지 않도록 제한을 명시한다.

**Nice-to-have**

- `work-plan.md`의 `Active 표시` 경로를 독립 문장으로 만들면 이후 재오독 여지가 줄어든다.
- Pruning Policy 첫 행의 trigger를 `Done — /work-close 완료` 또는 `Done — Work Done 처리 시`처럼 명확히 쓰면 `/work-close`와 연결이 더 선명해진다.

**Codex 반영 계획**

- `work-plan.md`와 `DR-013`의 before/after 문안을 plan에 명시했다.
- `HARNESS-PROTOCOL.md`는 첫 행만 바꾸고 Quick Mode 행은 유지한다고 Scope/Done Criteria에 반영했다.
- backlog 확인 결과 W3는 `HARNESS-PROTOCOL.md` trigger family를 잠재 편집 대상으로 포함하지만, `work-plan.md`는 현재 W3 candidate 직접 대상이 아니다. 이번 Work는 Pruning Policy 국소 정합화로만 제한한다.

**승인 후 메모**

- Pruning Policy 첫 행은 tool 이름 고정보다 상태 trigger를 앞세운 문구가 적절하므로 `Done — Work Done 처리 완료 (→ /work-close Step 5)` 방향으로 구현한다.

### R1 — Result Review (Claude, 2026-06-12)

**Approval:** Approved

**Observation**

- `work-plan.md` 3a는 착수 연결 맥락인데, `완료된 backlog row 제거는 /work-close 흐름에서 수행한다`는 closeout 전방 참조가 함께 들어가 있어 배치가 약간 이질적이다.
- 다만 독자에게 lifecycle 전체를 한 곳에서 보여준다는 의도라면 수용 가능하다. 별도 Work로 재배치할 수는 있지만 이번 Work 범위에서 추가 수정할 이유는 없다.

**Conclusion**

- Blocking finding 없음. 현재 변경으로 closeout 진행 가능.

## Discovery

- 2026-06-12: `session-start` 확인 결과 Active Work 없음, Open Blocker 없음. Done archive pending Work 5개가 있어 PLAN 누적 드리프트 soft warning 대상이나, archive 처리는 이번 Work 범위에서 제외.
- 2026-06-12: Branch isolation check 결과 `develop` + `policy_type: source-gitflow`이므로 `feature/chore-20260612-005-backlog-row-lifecycle-ssot` branch에서 plan 작성.
- 2026-06-12: Tool rule reference: `.claude/rules/docs-workflow.md`와 `.claude/rules/git-workflow.md`가 대상 경로와 매칭됨. Codex에서 수동 확인 후 적용.
- 2026-06-12: Claude R1 결과 기준 blocking finding 없음. `work-plan.md` 3a의 closeout 전방 참조는 non-blocking observation으로만 남기고 이번 Work에서는 재배치하지 않음.
