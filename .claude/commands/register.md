---
description: "새 작업 항목을 적절한 backlog 또는 STATUS.md에 등록한다"
argument-hint: "[item-description]"
disable-model-invocation: true
---

docs/STATUS.md와 관련 backlog를 확인한 뒤 $ARGUMENTS 작업 항목을 등록해줘.

## Registration Location

다음 기준으로 등록 위치를 판단해줘.

| 상황 | 등록 위치 |
| --- | --- |
| 지금 바로 착수할 긴급 항목 | `docs/STATUS.md` Active Work (state-change proposal 필요) |
| 곧 할 것 / 다음 세션 후보 | `docs/STATUS.md` Next Actions |
| Product 작업 | `docs/backlog/PHASE{n}.md` |
| Harness / workflow / command / rule 개선 | `docs/backlog/HARNESS.md` |

위치가 명확하지 않으면 두 가지를 물어봐.

1. 긴급도: 지금 바로 착수 / 곧 할 것 / 나중에 검토
2. 성격: product(기능·인프라) / harness(workflow·command·rule·문서 구조)

## TYPE Judgment

등록 전 TYPE을 판단한다. 위치 판단(긴급도·성격)과 함께 수행한다.

| TYPE | 판단 기준 |
| --- | --- |
| `FEAT` | product/user-visible feature (프로젝트 통합 branch 기준 feature branch) |
| `PATCH` | non-emergency correction 또는 release-prep patch |
| `HOTFIX` | urgent main/release-line fix (service outage, security, data integrity) |
| `CHORE` | harness/process/docs/tooling maintenance. user-visible 기능 변화 없음 |

불명확하면 성격·긴급도로 추론하되, 여전히 불명확하면 물어봐.

## Item Structure

등록 항목에는 아래 내용을 포함해줘.

- **Title / slug**: 제목과 짧은 식별 slug (backlog 후보 단계에서는 ID 없음)
- **Priority**: P0 / P1 / P2 / P3
- **Scope**: 한 줄 설명
- **Done Criteria**: 완료 판단 기준
- **Verification**: 검증 방법

backlog 후보에는 Work ID를 선점하지 않는다. Work ID는 `/work`로 착수 승인 후 Work 파일 생성 시 `<TYPE>-<YYYYMMDD>-<NNN>` 형식으로 확정한다. 형식 상세: `docs/HARNESS-NAMING-RULES.md`.

## STATUS.md Change Rules

Active Work 또는 Next Actions에 추가할 경우 즉시 수정하지 말고 Approval Matrix state rules에 맞게 먼저 제안해줘.

Active Work pointer 추가는 대상 Work ID를 명시한 1줄 제안으로 충분하다.
Next Actions나 phase/focus 변경은 `STATUS Update Proposal`로 변경 섹션, 변경 이유, 변경 후 상태, 되돌리기 비용을 포함해줘.
사용자가 명시적으로 승인한 뒤에만 STATUS.md를 수정해줘.

## Urgent Item Handling

Active Work에 등록하는 긴급 항목이면:

1. TYPE 판단 후 `<TYPE>-<YYYYMMDD>-<NNN>` 형식의 Work ID를 제안한다. (형식 상세: `docs/HARNESS-NAMING-RULES.md`)
   - NNN은 현재 branch에서 보이는 `docs/works/` 파일 기준으로 다음 번호를 제안한다.
   - 병렬 branch가 있으면 NNN 충돌 가능성을 안내한다.
2. 등록 완료 후 `/work [ID]`로 바로 이어갈지 물어봐.
