docs/STATUS.md와 관련 backlog를 확인한 뒤 $ARGUMENTS 작업 항목을 등록해줘.

## 등록 위치 결정

다음 기준으로 등록 위치를 판단해줘.

| 상황 | 등록 위치 |
| --- | --- |
| 지금 바로 착수할 긴급 항목 | `docs/STATUS.md` Active Work (STATUS Update Proposal 필요) |
| 곧 할 것 / 다음 세션 후보 | `docs/STATUS.md` Next Actions |
| Product 작업 | `docs/backlog/PHASE{n}.md` |
| Harness / workflow / command / rule 개선 | `docs/backlog/HARNESS.md` |

위치가 명확하지 않으면 두 가지를 물어봐.

1. 긴급도: 지금 바로 착수 / 곧 할 것 / 나중에 검토
2. 성격: product(기능·인프라) / harness(workflow·command·rule·문서 구조)

## 항목 구성

등록 항목에는 아래 내용을 포함해줘.

- **ID**: 위치에 맞는 prefix로 제안 (`P2-*`, `HRN-*`, `DOC-*` 등)
- **Priority**: P0 / P1 / P2 / P3
- **Scope**: 한 줄 설명
- **Done Criteria**: 완료 판단 기준
- **Verification**: 검증 방법

ID가 이미 있으면 그대로 사용하고, 없으면 해당 backlog의 마지막 번호를 확인해 다음 번호를 제안해줘.

## STATUS.md 변경 규칙

Active Work 또는 Next Actions에 추가할 경우 즉시 수정하지 말고 `STATUS Update Proposal`을 먼저 보고해줘.

Proposal에는 변경 섹션, 변경 이유, 변경 후 상태, 되돌리기 비용을 포함해줘.
사용자가 명시적으로 승인한 뒤에만 STATUS.md를 수정해줘.

## 긴급 항목 처리

Active Work에 등록하는 긴급 항목이면 등록 완료 후 `/work [ID]`로 바로 이어갈지 물어봐.
