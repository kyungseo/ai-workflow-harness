---
id: CHORE-20260613-007
priority: P1
status: Archived
risk: L2
scope: `문서-only 규칙 강제화 (CI/hook/hard-gate)` 전체 구현에 앞서, protected workflow surface direct-develop handling의 예외 클래스(상태 파일 vs 구조 파일 vs project-owned custom protected path), warning-only vs hard-block 판정 기준, override/trailer 허용 범위를 decision-only DR slice로 고정한다. hook/CI 구현, runner 배선, repo-health 통합은 범위 밖이다.
appetite: 0.5d
planned_start: 2026-06-13
planned_end: 2026-06-13
actual_end: 2026-06-13
related_dr: [DR-024, DR-025]
related_work: [CHORE-20260606-016, CHORE-20260611-008, CHORE-20260612-005]
---

# CHORE-20260613-007: Protected Workflow Enforcement Exception-Class DR

## Top Summary

- **목표:** `문서-only 규칙 강제화`를 바로 구현으로 열기 전에, protected workflow surface direct-develop handling의 예외 클래스와 enforcement/override 경계를 DR로 먼저 고정한다.
- **왜 지금:** backlog 메모가 이미 "hook 강화보다 예외 클래스 설계 DR 선행"을 요구한다. direct develop push incident는 우선순위를 높였지만, 아직 hard-gate 구현 범위를 바로 닫을 수 있을 만큼 결정이 고정돼 있지 않다.
- **핵심 경계:** 이번 Work는 decision-only slice다. hook exit(1), CI required check, trailer parser 변경, `run-harness-checks.sh` 배선은 구현하지 않는다.
- **결정 산출물:** open-ended 검토가 아니라, 최종 산출물을 **`exception class × enforcement mode × override mechanism` 테이블**로 고정한다.
- **코웍 구조:** Codex = author/driver, Claude = red team reviewer. R0 review 합의 전에는 DR/implementation surface를 수정하지 않는다.

## Candidate Comparison

| 후보 | 판단 | 이유 |
| --- | --- | --- |
| A. `문서-only 규칙 강제화`를 그대로 구현 Work로 착수 | 비추천 | backlog 메모 안에 미결 결정이 4축(상태 파일, 구조 파일, Quick Mode/product track, override/trailer)으로 남아 있다. 지금 구현에 들어가면 scope가 넓어진다. |
| B. 예외 클래스 설계 DR / warning-vs-hard-block / override 범위 decision slice 선행 | **추천** | backlog 메모와 가장 직접 정합이다. direct develop incident를 근거로 우선순위는 유지하되, 구현 전제 결정을 작게 고정할 수 있다. |
| C. W4를 미루고 W5 또는 다른 optional 후보 착수 | 비추천 | `문서-only 규칙 강제화`와 F2/runner 배선은 같은 정책 결정을 기다린다. 지금 다른 optional 후보로 가면 blocker를 남긴 채 우회하는 셈이다. |

## Background / Facts

- `docs/backlog/HARNESS.md`의 `문서-only 규칙 강제화` 메모는 pre-commit warning-only 신호와 `git-workflow` 인지 규칙 사이의 불일치를 이미 문제로 기록했다.
- 같은 메모는 hook exit(1) 강화를 바로 구현하지 않은 이유를 네 가지 예외 클래스 미정으로 설명한다.
  1. `docs/STATUS.md` 같은 상태 파일의 tracking-only commit
  2. Product track L1 Quick Mode
  3. repo별 custom protected path 확장
  4. `commands/**`, `rules/**`, `scripts/create-harness.sh` 같은 구조 파일
- DR-025와 CHORE-20260606-016은 **finalization-only gate**의 tracking-only override convention을 정리했지만, 그것이 protected workflow surface direct-develop handling 전체의 예외 클래스 정의를 대신하지는 않는다.
- CHORE-20260611-008은 이 항목을 "hook exit(1) enforcement" 후속으로 분리하면서, 구현 전에 예외 클래스 DR을 먼저 고정해야 한다고 명시했다.
- 따라서 direct develop push incident는 이 항목의 **우선순위**를 올리는 근거는 되지만, 곧바로 hook/CI hardening을 시작해도 된다는 근거는 아니다.
- `git-workflow.md`에는 `.git/MERGE_HEAD`가 있으면 branch isolation check를 skip하는 기존 merge commit exception이 이미 있다. 이번 DR은 이 예외를 삭제/변경하지 않고, **inherited exception**으로 유지할지 명시해야 한다.

## Scope / Non-Goals

### Scope

1. protected workflow surface direct-develop handling에 필요한 **예외 클래스 taxonomy**를 정의한다.
   - 상태/추적 파일
   - 구조/정책 파일
   - project-owned custom protected path
   - inherited merge commit exception
2. 각 클래스에 대해 **enforcement mode matrix**를 정한다.
   - warning-only
   - hard-block
   - report-only
   - no-override
3. **override / trailer boundary**를 정한다.
   - 기존 trailer 재사용 가능 범위
   - trailer 허용 불가 클래스
   - tracking-only와 구조 파일의 분리 원칙
4. **Quick Mode / product track applicability**를 고정한다.
   - product track L1 Quick Mode가 실제 예외 클래스인지, 아니면 protected list 밖의 **non-exception**인지 분리 판정한다
   - source repo와 scaffold target에서 같은 규칙을 유지할지
5. 후속 implementation slice를 1~2개로 재분해한다.
   - source hook exit(1) 강화 + cascade 범위(`gate-lists`/rule/doc) 명시
   - CI/runner 배선 여부(F2와의 중복 해소)
   - 필요 시 Class ④ 차별 override 로직 별도 slice

### Non-Goals

- `tools/git-hooks/**`, `.github/workflows/**`, `scripts/tests/run-harness-checks.sh` 구현 변경
- `docs/AGENT-WORKFLOW.md`, `docs/HARNESS-PROTOCOL.md`, `.claude/rules/git-workflow.md`의 enforcement 문구 수정
- `문서-only 규칙 강제화` 전체 backlog 항목 closeout
- F2 runner 배선 결정의 실제 구현
- `docs/STATUS.md` Active pointer 추가. R0 합의 전에는 변경하지 않는다.

## Files

### Plan / Tracking

| File | Plan |
| --- | --- |
| `docs/works/harness/CHORE-20260613-007-enforcement-exception-classes.md` | Work SSoT |
| `docs/works/harness/README.md` | Active Work index row only |
| `docs/STATUS.md` | R0 합의 후에만 Active pointer 제안 |

### Decision Surfaces

| File | Plan |
| --- | --- |
| `docs/decisions/DR-035-protected-workflow-enforcement-exception-classes.md` | 신규 Accepted DR. branch-isolation / protected-surface 예외 클래스 정책 고정 |
| `docs/decisions/README.md` | DR-035 index 등록 |
| `docs/backlog/HARNESS.md` | 이번 turn에서는 read-only. closeout 시 후속 implementation candidate wording 정리 여부 검토 |
| `docs/AGENT-WORKFLOW.md` | read-only. decision 반영 대상인지 R0 이후 판단 |
| `docs/HARNESS-PROTOCOL.md` | read-only. decision 반영 대상인지 R0 이후 판단 |
| `.claude/rules/git-workflow.md` | read-only. decision 반영 대상인지 R0 이후 판단 |
| `tools/git-hooks/**`, `.github/workflows/**`, `scripts/tests/run-harness-checks.sh` | read-only. 이번 Work 구현 범위 밖 |

## Plan

### Phase 0 — R0 Review Package

1. Work file과 Work index Active row만 생성한다.
2. `docs/STATUS.md` Active pointer는 건드리지 않는다.
3. Claude에게 R0 review를 요청한다.
4. R0 합의 전에는 DR 파일, hook, CI, rule surface를 수정하지 않는다.

### Phase 1 — Decision Framing

1. backlog 메모, DR-025, CHORE-20260606-016, CHORE-20260611-008에서 이미 고정된 것과 미고정된 것을 분리한다.
2. direct-develop handling을 최소 4분류로 정리한다.
   - 상태/추적 파일
   - 구조/정책 파일
   - project-owned protected extension
   - inherited merge commit exception
3. Class ①(상태/추적)와 Class ②(Quick Mode/product track)의 overlap을 해소한다.
   - Quick Mode가 protected workflow surface 예외인지
   - 또는 이미 protected list 밖이라 **non-exception**인지
4. 각 클래스별로 허용 가능한 enforcement mode를 표로 정리한다.
5. override/trailer 허용 범위를 표로 정리한다.
6. DR-025 `AWH-Gate-Override` trailer를 branch isolation gate에서도 인식하는지, 아니면 다른 메커니즘/금지 정책을 둘지 교차점을 명시한다.
7. 구조/정책 파일(Class ④)의 구체 범위를 누가 관리하는지 결정한다.

### Phase 2 — Decision Slice (R0 승인 후)

1. 신규 DR 작성 또는 DR-025 amend 여부를 결정한다.
2. 결정 문서에 아래 4가지를 명시한다.
   - exception class taxonomy
   - enforcement mode matrix
   - override/trailer boundary
   - implementation follow-up split
3. 후속 implementation slice의 진입 조건을 적는다.
4. 산출물은 반드시 1개 이상의 결정 표로 남긴다.
   - `exception class × enforcement mode × override mechanism`
   - 필요 시 `class × owned path examples × policy owner`

### Phase 3 — Closeout / Next Slice

1. 이번 Work는 decision-only로 닫는다.
2. 구현이 필요하면 후속 Work를 별도로 연다.
3. `문서-only 규칙 강제화` backlog 항목을 그대로 유지할지, decision/implementation으로 쪼갤지 closeout 때 제안한다.

## Done Criteria

- [x] protected workflow surface direct-develop handling의 예외 클래스 taxonomy가 고정된다.
- [x] DR 산출물이 `exception class × enforcement mode × override mechanism` 테이블로 명시된다.
- [x] 각 클래스의 warning-only / hard-block / report-only / no-override 경계가 고정된다.
- [x] override/trailer 허용 범위와 금지 범위가 고정된다.
- [x] Quick Mode/product track L1이 실제 예외인지, non-exception인지 명시된다.
- [x] merge commit exception이 inherited exception으로 유지되는지 명시된다.
- [x] Class ④(구조/정책 파일)의 구체 범위와 관리 주체가 명시된다.
- [x] direct develop push incident가 "우선순위 상승" 근거인지, "즉시 구현" 근거가 아닌지 DR에 명시된다.
- [x] DR-025 trailer와 branch isolation gate의 교차점이 명시된다.
- [x] 후속 implementation slice가 cascade/F2/Class ④ 복잡도를 반영해 다시 분해된다.
- [x] Claude R0/R1 review와 disposition이 Round Log에 누적된다.

## Verification

Planned commands:

```bash
rg -n "문서-only 규칙 강제화|hook exit\\(1\\)|Quick Mode|tracking-only|override|trailer|protected" \
  docs/backlog/HARNESS.md \
  docs/decisions/DR-025-commit-gate-runtime-enforcement.md \
  docs/archive/docs/works/harness/CHORE-20260606-016-product-adaptive-gate-logic.md \
  docs/archive/docs/works/harness/CHORE-20260611-008-repo-health-gate-alignment.md
git diff --check
```

Review checks:

- backlog 메모의 네 가지 예외 클래스가 decision 범위에 빠짐없이 들어갔는가?
- Class ①(상태/추적)와 Class ②(Quick Mode/product track)의 overlap이 해소됐는가?
- merge commit inherited exception이 누락되지 않았는가?
- DR-025 tracking-only override convention을 branch-isolation 예외 클래스와 혼동하지 않았는가?
- branch isolation gate가 DR-025 trailer를 인식하는지 여부가 downstream이 아니라 이번 DR에서 답해졌는가?
- 이번 slice에 hook/CI/runtime 구현이 침투하지 않았는가?
- 후속 implementation split이 broad하지 않고 검증 단위로 닫히는가?

## Risk / Reversal Cost

| Item | Assessment |
| --- | --- |
| Risk level | L2 — harness/workflow policy surface |
| Reversal cost | Low to Medium. decision 문서만 되돌리면 되지만, 후속 enforcement 설계의 기준점이 되므로 잘못 고정하면 하류 slice가 흔들린다 |
| Main risk | DR-025(finalization-only gate)와 branch-isolation protected-surface 정책을 한 문서에 과도하게 섞어 scope가 커질 수 있다 |
| Secondary risk | Quick Mode/product track 예외를 과하게 넓혀 protected workflow surface의 feature-branch 원칙을 다시 약화할 수 있다 |
| Control | decision-only 유지, hook/CI 구현 금지, 예외 클래스 3종과 override 범위 1표로 한정 |

## Open Questions

| ID | Question | Default Assumption |
| --- | --- | --- |
| OQ-1 | 이번 정책은 DR-025 amend보다 신규 DR이 더 적절한가? | Yes. DR-025는 finalization-only gate이고, 이번 slice는 protected workflow surface direct-develop handling이 중심이다 |
| OQ-2 | `docs/STATUS.md` 같은 상태 파일의 direct-develop 예외는 trailer 허용까지 포함하는가? | tracking-only일 때만 제한적으로 논의. 구조 파일과 동일 취급하지 않는다 |
| OQ-3 | 구조/정책 파일은 trailer override가 금지돼야 하는가? | Yes. 기본 가정은 no-override |
| OQ-4 | Product track L1 Quick Mode는 protected workflow surface 원칙의 예외 근거가 되는가? | 우선 No. protected list 밖이면 non-exception으로 본다. protected surface에서만 별도 논의 |
| OQ-5 | repo별 custom protected path는 구조 파일 클래스에 가까운가? | 기본은 project-owned protected extension. 구조 파일과 동일 hardening 여부는 별도 판정 필요 |
| OQ-6 | merge commit exception은 신규 예외 클래스인가, inherited exception인가? | inherited exception으로 유지하는 쪽이 기본 가정 |
| OQ-7 | branch isolation gate가 DR-025 `AWH-Gate-Override` trailer를 인식하는가? | 이번 DR에서 명시적으로 결정해야 하며 downstream 위임 금지 |

## Approval / State

| Item | Status |
| --- | --- |
| 위험도 | L2 |
| 실행 모드 | Standard Work |
| Branch Isolation | PASS — `feature/chore-20260613-007-enforcement-exception-classes` |
| Tool rule reference | `.claude/rules/docs-workflow.md`, `.claude/rules/git-workflow.md` 수동 적용 |
| PLAN 영향 | 없음. W4 후보의 선행 decision slice이며 roadmap 방향 변경이 아니라 구현 전제 고정이다 |
| STATUS proposal | `docs/STATUS.md` Active pointer가 없으므로 변경 없음. Recent Decisions / Next Actions는 구현 slice closeout 때 함께 판단 |
| State machine | END — Work Done 처리 완료. 후속 implementation split 제안 가능 |

> **approval gating note:** 사용자 지시에 따라 Work file과 Work index만 먼저 생성했다. frontmatter `status: Active`와 Work index Active row는 R0 review-ready 추적용이며, `docs/STATUS.md` Active pointer 추가와 실제 decision execution은 별도 승인 게이트로 유지한다.

## Cross-Agent Review And Discussion

### Claude R0 Review Request

Claude R0 plan review 요청: CHORE-20260613-007 Protected Workflow Enforcement Exception-Class DR

검토 포인트:

1. `문서-only 규칙 강제화`를 바로 구현 Work로 열지 않고 decision-only slice로 자른 판단이 타당한가?
2. backlog 메모의 네 가지 예외 클래스가 이 Scope에 충분히 반영됐는가?
3. direct develop push incident는 우선순위 상승 근거로만 다루고, 즉시 hook hardening 근거로는 다루지 않는 선이 맞는가?
4. DR-025의 tracking-only override convention과 이번 protected-surface 정책을 분리해서 다루는 방향이 맞는가?
5. 후속 implementation slice를 "source hook exit(1) 강화"와 "CI/runner 배선 여부" 정도로 분리하는 것이 충분히 작은가?

### Round Log

| Round | Reviewer | Type | Findings | Codex Disposition | Status |
| --- | --- | --- | --- | --- | --- |
| R0 | Claude | Plan Review | Approved with must-fix framing. F1: DR deliverable을 `exception class × override mechanism` 테이블로 고정할 것. F2: Class ①/② overlap 해소 필요. F3: merge commit inherited exception 명시 필요. F4: Class ④ 구조 파일 범위/관리주체 확정 필요. F5: DR-025 trailer와 branch isolation gate의 교차점 명시 필요. F6: implementation split에 cascade 범위, F2 중복, Class ④ 복잡도 반영 필요 | 반영. Top Summary/Plan/Done Criteria/Verification/OQ를 테이블 deliverable, Class ①/② 경계, merge commit inherited exception, Class ④ 범위, DR-025 교차점, implementation split 보강 방향으로 수정 | Addressed |
| R1 | Claude | Result Review | Approved. `docs/decisions/** -> S1` 판단과 Quick Mode non-exception 처리는 타당. Non-blocking 2건: archive move는 feature branch 전제임을 1줄 명시 권고, DR-025 trailer non-reuse 근거 문구를 pre-commit/commit-msg 분리 비용 중심으로 정밀화 권고. Slice 3와 F2 관계는 implementation Work 시점에 명시 권고 | 반영. DR-035에 archive move feature-branch 가정 1줄 추가, trailer non-reuse 근거를 분리 집행/복잡도 중심으로 정밀화, Slice 3에 F2 흡수 여부 명시 요구를 추가 | Approved |

### Claude R1 Review Request

Claude R1 result review 요청: DR-035 Protected Workflow Enforcement Exception Classes

구현/결정 결과 요약:

1. 신규 Accepted DR `docs/decisions/DR-035-protected-workflow-enforcement-exception-classes.md` 추가
2. branch isolation gate를 `I0 inherited-merge` / `T1 tracking-state-only` / `S1 structural-policy` / `P1/P2 project extension`으로 분리
3. Quick Mode/product L1은 독립 예외 클래스가 아니라 non-exception으로 고정
4. DR-025 `AWH-Gate-Override: finalization-split` trailer는 branch isolation gate에서 인식하지 않는다고 명시
5. 후속 implementation을 framework default hardening / project extension classification / F2 wiring 3개 slice로 재분해
6. `docs/decisions/README.md`에 DR-035 index 추가

검토 포인트:

1. `T1 tracking-state-only` 범위가 너무 넓거나 좁지 않은가? 특히 `docs/decisions/**`를 `S1 structural-policy`로 올린 판단이 타당한가?
2. Quick Mode/product L1을 non-exception으로 처리한 것이 Class ①/② overlap을 충분히 닫는가?
3. DR-025 trailer를 branch isolation에서 재사용하지 않겠다는 결정이 pre-commit 제약과 의미 분리를 모두 만족하는가?
4. `P1/P2 project extension`을 default-safe hard-stop으로 둔 것이 이후 repo-specific 확장에 무리가 없는가?
5. follow-up split 3개가 broad한 implementation을 충분히 막는가?

## Discovery

- 2026-06-13: session start 기준 `develop...origin/develop` clean 확인. source-gitflow marker가 있으므로 branch isolation rule상 `develop`에서 protected workflow 문서 편집은 금지된다.
- 2026-06-13: `docs/backlog/HARNESS.md`의 `문서-only 규칙 강제화` 메모를 재확인한 결과, hook 강화보다 예외 클래스 설계 DR 선행이 backlog 자체의 현재 결론임을 확인했다.
- 2026-06-13: direct develop push incident는 enforcement 후보 우선순위를 올리는 근거이지만, backlog 메모가 남긴 미정 결정축 때문에 implementation first는 broad하다고 판단했다.
- 2026-06-13: Work 시작 전 `feature/chore-20260613-007-enforcement-exception-classes` branch 생성.
- 2026-06-13: Claude R0 review 반영. decision-only 선행 판단은 승인됐지만, DR output을 open-ended 검토가 아니라 `exception class × enforcement mode × override mechanism` 테이블로 고정해야 한다는 조건을 수용했다.
- 2026-06-13: Claude R0 review 반영. Class ①(상태/추적)와 Class ②(Quick Mode/product track)의 overlap, merge commit inherited exception, Class ④ 구조 파일 범위, DR-025 trailer 교차점이 이번 DR에서 명시돼야 한다는 finding을 Scope/Plan/OQ에 반영했다.
- 2026-06-13: 사용자 승인 후 Phase 2 실행. 신규 Accepted DR `DR-035`를 작성하고, `decisions/README`에 index를 추가했다.
- 2026-06-13: 결정 내용은 `I0`/`T1`/`S1`/`P1`/`P2` class split, Quick Mode non-exception, DR-025 trailer non-reuse, implementation 3-slice split으로 고정했다.
- 2026-06-13: 검증 완료. `git diff --check` PASS, `bash scripts/tests/check-shipped-dr-closure.sh` PASS, decisions README ↔ DR file closure PASS.
- 2026-06-13: Claude R1 Approved. blocking finding 없음. non-blocking observation 2건을 즉시 반영했다: archive move는 feature branch 전제 명시, DR-025 trailer non-reuse 근거 문구 정밀화. Slice 3와 F2 관계는 후속 implementation Work에서 명시하도록 DR follow-up split에 메모했다.
- 2026-06-13: `/work-close` 처리. decision slice 자체는 Done으로 닫고 archive는 보류한다. backlog의 `문서-only 규칙 강제화` candidate는 제거하지 않고, DR-035 선행 결정 완료 사실과 남은 implementation scope를 계속 추적한다.

- 2026-06-13: batch archive (CHORE-20260613-013 DR-038 archive-side flow 실사용 검증). status Done→Archived, live README Done(Pending) 행 제거 후 archive-side Archived 인덱스로 이전.
