# DR-037: Doc-only Rule Enforcement Landscape — Closure

Date: 2026-06-13
Status: Accepted
Track: harness
Linked DRs: DR-024, DR-025, DR-033, DR-035, DR-036

## Question

backlog 테마 `문서-only 규칙 강제화 (CI/hook/hard-gate)`는 "문서로만 기술된 규칙 중 강제화할 주요 요소를 검토하고 구현"하는 broad 테마였다. branch isolation 강제화(DR-035 + CHORE-20260613-008/010/011)로 그 테마를 종결할 수 있는가? 다른 doc-only 규칙들은 강제화 후보로 남아 있는가?

## Context

이 테마의 Done Criteria #1은 "강제화 후보 규칙 **목록** + 수단(CI/hook/hard-gate) 매핑 결정"을 요구했다. 그러나 실제 구현(008/010/011)은 전부 branch-isolation 한 곳으로 수렴했고, doc-only 규칙 전반을 검토한 후보 목록은 별도 산출물로 남은 적이 없다. 이 DR이 그 landscape를 명시 기록해 criterion #1을 충족하고 테마를 닫는다.

## Decision

doc-only 규칙 전반을 아래 landscape로 검토한 결과, **(a) 구체적 위반-피해 + (b) 기계 강제 가능 + (c) gate 부재**를 동시에 만족한 규칙은 **branch isolation이 유일**했고, 이 테마가 강제화했다. 나머지는 **이미 강제됨** 또는 **본질상 AI-behavioral(hard-gate 부적합)**이다. 따라서 테마 `문서-only 규칙 강제화`는 종결한다.

### Enforcement Landscape

| Doc-only 규칙 | 현재 강제 수단 | Hard-gate 가능? | 판정 |
| --- | --- | --- | --- |
| Branch isolation (protected surface on `develop`/`main`) | pre-commit (DR-035 hardened) + GitHub ruleset | Yes | ✅ **이 테마가 강제화 (008/010/011)** |
| Commit message format (Conventional + bilingual) | commit-msg hook + CI advisory | Yes (format) | ✅ 기존 강제 |
| Finalization bundling (T15/T16) | commit-msg gate (DR-025) | Partial (heuristic + trailer) | ✅ 기존 강제 |
| Shipped DR reference closure | pre-commit hard gate (DR-033) | Yes | ✅ 기존 강제 |
| Whitespace / shell syntax | pre-commit + CI | Yes | ✅ 기존 강제 |
| Scaffold invariants | CI inline + runner | Yes | ✅ 기존 강제 (CI↔invariants SSoT parity는 별도 candidate) |
| Approval Matrix (scope/state/commit 승인) | doc-only | **No** (human-in-loop 판단 필요) | ⛔ 본질상 behavioral |
| STATUS update 승인 gate | doc-only | No | ⛔ behavioral |
| PLAN load triggers / context routing | doc-only | No | ⛔ behavioral |
| Language policy (DR-007 Korean primary) | doc-only (+ commit format 일부) | 사실상 No (NLP) | ⛔ behavioral |
| Cascade 정합 (canonical→adapter→scaffold) | repo-health (manual) + CI scaffold checks | Partial | ~ F4 / parity candidate로 추적 |

## Rationale

- 강제화 우선순위 기준은 테마가 명시한 "위반 빈도·실피해가 큰 규칙부터"다. 이 기준에서 branch isolation은 (a) 실제 위반 시 protected workflow 파일이 `develop`/`main`에 직접 들어가는 구체적 피해가 있고, (b) path-set 기반으로 pre-commit 시점에 기계 판정이 가능하며, (c) 강화 전에는 warning-only로 gate가 사실상 비어 있었다. 세 조건을 동시에 만족하는 유일한 후보였다.
- commit format / finalization / shipped DR closure / whitespace / scaffold invariants는 **이미 hook 또는 CI로 강제**되고 있어 추가 작업이 불필요하다.
- Approval Matrix / STATUS 승인 / PLAN trigger / language policy는 **human-in-loop 판단 또는 자연어 해석**이 본질이라 hard-gate가 부적합하다. 이들은 `SOURCE-REPO-OPERATIONS.md`가 명시하듯 "수동 점검이 곧 gate"인 영역으로 유지한다.
- 따라서 broad 테마의 실질 목표(고위험 doc-only 규칙의 기계 강제화)는 branch isolation 강제화로 달성됐다.

## Consequences

- backlog `문서-only 규칙 강제화 (CI/hook/hard-gate)`를 종결하고 Summary/Details/Portfolio에서 제거한다.
- 잔여 enforcement-인접 작업은 별도 항목으로 계속 추적한다:
  - `CI inline assertion ↔ invariants SSoT parity` (CHORE-20260613-011 Discovery, 신규 candidate)
  - `Validation Spine residual follow-ups`의 F4 (runner → `/repo-health` surface)
- behavioral 규칙(Approval Matrix / STATUS 승인 / PLAN trigger / language policy)은 의도적으로 doc-only로 유지한다. 향후 "이들도 hard-gate하자"는 제안이 나오면 이 DR의 결론(human-in-loop·NLP 영역은 hard-gate 부적합)을 먼저 참조한다.
- `HARNESS-TEST-TAXONOMY.md`(F2 pointer)와 `SOURCE-REPO-OPERATIONS.md`(machine-enforcement 후보 pointer)는 제거된 backlog 항목 대신 DR-036/DR-037을 가리키도록 정렬한다.

## Reversal Cost

Low — 코드 변경 없는 결정/정리이며, landscape는 현재 enforcement 상태의 스냅샷이다. 향후 새 doc-only 규칙이 고위험·기계강제 가능 후보로 등장하면 별도 backlog 항목으로 다시 열면 되고, 이 DR을 superseding 결정으로 갱신한다.

## Linked Work

- CHORE-20260613-012
</content>
