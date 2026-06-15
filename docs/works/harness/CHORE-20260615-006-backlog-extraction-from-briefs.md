---
id: CHORE-20260615-006
priority: P1
status: Done
risk: L2
scope: readiness retrospective 1건과 briefs 3건에서 다음 backlog 후보를 추출해 `docs/backlog/HARNESS.md`에 통폐합 중심으로 반영한다. 기존 후보와 겹치면 detail을 잃지 않고 합치고, 우선순위와 gate를 명시한다.
appetite: 0.25d
planned_start: 2026-06-15
planned_end: 2026-06-15
actual_end: 2026-06-15
related_dr: [DR-007, DR-013, DR-021, DR-023, DR-034]
related_troubleshooting: []
related_work: [CHORE-20260611-010, CHORE-20260612-001, CHORE-20260612-002, CHORE-20260615-004, CHORE-20260615-005]
---

# CHORE-20260615-006: Brief/Retrospective Follow-up Backlog Extraction

## Top Summary

- **목표:** 아래 4개 문서의 후속 action을 backlog 후보로 추출하고, 기존 `docs/backlog/HARNESS.md`와 겹치는 항목은 통폐합해 더 읽기 쉽고 체계적인 portfolio view로 정리한다.
  - `docs/retrospectives/harness-v1-2-readiness-retrospective-20260615.md`
  - `docs/briefs/harness-internal-managed-upgrade-20260615.md`
  - `docs/briefs/harness-identity-policy-first-20260608.md`
  - `docs/briefs/harness-distribution-plugin-model-20260608.md`
- **왜 지금:** 관련 문서의 핵심 후속이 일부 backlog에 이미 흡수돼 있지만, 순서·gate·정책 경계가 충분히 드러나지 않는다. 특히 `ai-deck-compiler` walkthrough, internal managed mode, happy path, sub-agent autonomy, packaging revisit가 흩어져 있다.
- **역할:** Codex = author / driver, Claude = red team reviewer.
- **핵심 경계:** `docs/STATUS.md`는 건드리지 않는다. backlog는 실행 계획이 아니라 portfolio view이므로, implementation 설계나 DR 작성은 후보 수준까지만 정리한다.

## Context Manifest

| 순서 | 파일 | 왜 |
| --- | --- | --- |
| 1 | `docs/backlog/HARNESS.md` | 현재 후보와 중복·통폐합 기준 확인 |
| 2 | `docs/retrospectives/harness-v1-2-readiness-retrospective-20260615.md` | 다음 단계, happy path, first walkthrough, fleet mode gate 추출 |
| 3 | `docs/briefs/harness-internal-managed-upgrade-20260615.md` | Candidate A/B/C와 internal managed guardrail 추출 |
| 4 | `docs/briefs/harness-identity-policy-first-20260608.md` | sub-agent autonomy policy와 policy/mechanism 경계 추출 |
| 5 | `docs/briefs/harness-distribution-plugin-model-20260608.md` | packaging/distribution revisit gate와 upgrade logic 우선순위 추출 |

## Scope

1. 기존 backlog 항목 중 아래를 우선 재평가한다.
   - `ai-deck-compiler` actual upgrade walkthrough + DR-034 acceptance judgment
   - Happy path / onboarding compression
   - First concrete product planning-pack exercise + import candidate review
   - Project-state template pack 검토
   - Scaffold CLI naming audit
2. 문서 4건에서 나온 follow-up을 아래 3분류로 나눈다.
   - 기존 항목에 detail로 흡수
   - 새 후보로 등록
   - gate 미충족 future note로만 유지
3. backlog Summary와 Details를 함께 갱신한다.
4. Claude red-team review를 위한 검토 포인트와 disposition 자리를 Work 파일에 남긴다.

## Non-Goals

- 실제 walkthrough 구현이나 internal managed mode 설계 착수
- `docs/STATUS.md` Active/Next Actions 갱신
- DR 본문 수정
- archive-side 문서 재분류

## Candidate Classification

| Source Insight | 처리 방침 |
| --- | --- |
| `ai-deck-compiler` first real walkthrough가 선행 gate | 기존 walkthrough 후보에 흡수 강화 |
| internal managed mode는 walkthrough 이후 opt-in | 별도 gated candidate로 등록 |
| happy path + glossary + daily operator layering | 기존 onboarding compression 후보에 흡수 확장 |
| sub-agent autonomy policy | 신규 후보 등록 |
| packaging/distribution revisit는 shell logic proof 이후 | 신규 future candidate 등록 |
| framework-owned 보호, product/harness commit boundary | internal managed candidate의 guardrail detail로 흡수 |

## Done Criteria

- [x] `docs/works/harness/README.md` Active row와 Work 파일이 생성된다.
- [x] backlog 기존 후보와 중복되는 follow-up이 통폐합된다.
- [x] walkthrough / internal managed / happy path / sub-agent autonomy / packaging revisit의 우선순위와 gate가 명시된다.
- [x] 새로 등록되는 후보는 Summary와 Details가 함께 추가된다.
- [x] Claude red-team review focus와 round log가 Work 파일에 남는다.
- [x] `git diff --check` 통과

## Verification

```bash
git diff --check
rg -n "ai-deck-compiler|Happy path|sub-agent|packaging|distribution|internal managed|walkthrough" docs/backlog/HARNESS.md
```

## Risk / Reversal Cost

| Item | Assessment |
| --- | --- |
| Risk level | L2 — backlog / work tracking surface |
| Reversal cost | Low. tracker 문구 재정렬이 중심이지만, 잘못 통합하면 후속 의사결정 힌트가 사라질 수 있다 |
| Main risk | 겹치는 후보를 하나로 합치면서 문서가 준 gate와 dependency를 잃는 것 |
| Control | Summary row와 Details block을 같이 수정하고, source 문서 근거를 dependencies에 남긴다 |

## Review Focus

1. walkthrough / internal managed의 순서가 readiness retrospective와 internal managed brief의 gate를 충실히 반영하는가
2. 기존 후보와 새 후보를 나누는 기준이 과소/과대하지 않은가
3. sub-agent autonomy와 packaging revisit를 지금 backlog에 올리는 것이 적절한가
4. detail 손실 없이 읽기 쉬워졌는가

## Claude Review Packet

- **리뷰 대상 파일:** `docs/backlog/HARNESS.md`, `docs/works/harness/CHORE-20260615-006-backlog-extraction-from-briefs.md`, `docs/works/harness/README.md`
- **이번 라운드의 실질 변경점:**
  - W2 portfolio view에 `ai-deck-compiler` first walkthrough → internal managed gate 순서를 명시
  - 기존 onboarding 후보를 `Happy path / glossary / operator layering compression`으로 확장
  - 신규 후보 3건 추가: internal managed guardrails, sub-agent autonomy policy, packaging/distribution revisit
  - 기존 `Scaffold CLI naming audit` 성격의 질문은 별도 항목으로 유지하지 않고 packaging/distribution 후보에 흡수
- **의도적 검토 포인트:**
  - internal managed 후보가 readiness retrospective의 gate를 어기지 않는지
  - policy/guardrail 후보와 mechanism/design 후보의 경계가 흐려지지 않는지
  - 기존 후보를 통합하면서 source 문서의 nuance가 손실되지 않았는지
  - 우선순위(P1/P2/P3)와 Cluster(W2/W5)가 과대/과소 배정되지 않았는지
- **비대상 / 참고:** `docs/briefs/harness-internal-managed-upgrade-20260615.md`의 현재 수정분은 본 작업 이전에 존재하던 별도 문서 변경이다. 이번 backlog extraction 라운드의 primary review 대상은 아니다.

## Cross-Agent Review And Discussion

| Round | Reviewer | Type | Findings | Codex Disposition | Status |
| --- | --- | --- | --- | --- | --- |
| R0 | Claude | Review packet | backlog extraction, 통폐합 기준, 우선순위와 gate 배정 검토를 위한 review packet 준비 | N/A | Recorded |
| R1 | Claude | Red-team review | Approved. Low 3건: internal-managed 3단 staging(Candidate C) 표면화, Spring Boot pack ↔ packaging revisit naming dependency inversion 완화, sub-agent autonomy priority/dormant posture 정직화 | Addressed | Closed |

## Review Outcome

- **Verdict:** Approved
- **반영한 Low findings:**
  - internal managed 후보에 Candidate C(runner/mechanism)가 B 이후 별도 downstream gate임을 명시
  - Spring Boot pack의 최소 naming 결정은 ad hoc 가능, broader naming/distribution cleanup만 별도 후보로 유지
  - sub-agent autonomy 후보를 dormant future candidate로 명시하고 backlog priority를 P3로 정직화

## Discovery

- user note에 따라 `ai-deck-compiler` first walkthrough는 External Adopter Mode를 먼저 보고, Internal Managed Mode는 그 결과를 바탕으로 여는 순차 gate가 필요하다.
- user note의 "framework-owned 파일은 중앙 PR 외 변경 금지"와 "target에서는 product code와 harness를 같이 묶어 커밋하지 않기"는 internal managed mode candidate의 핵심 guardrail로 보인다.
- readiness retrospective는 fleet mode 자체보다 first real walkthrough와 happy path를 먼저 요구한다.
- `docs/STATUS.md`에는 이 Work의 Active pointer가 없어, 이번 closeout에서는 STATUS update가 필요하지 않았다.
