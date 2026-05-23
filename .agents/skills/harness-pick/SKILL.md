---
name: "harness-pick"
description: "backlog에서 우선순위 후보를 비교하고 착수할 작업 1개를 추천한다"
---

# harness-pick

Use this skill when the user asks to invoke the harness workflow `pick`.

## Command Template

docs/STATUS.md를 확인한 뒤, 작업 성격에 맞는 backlog를 선택해 우선순위가 높은 후보 작업을 검토해줘.

- Product track 작업: docs/backlog/PHASE{n}.md
- Harness / workflow 작업: docs/backlog/HARNESS.md
- Scaffold 직후 부팅 작업: docs/STATUS.md Next Actions가 bootstrap/onboarding을 명시할 때 docs/BOOTSTRAP.md
- 성격이 불명확하면 두 backlog의 제목과 우선순위만 비교하고, 불필요한 상세 로드는 하지 마.

Product backlog가 비어 있고 `docs/STATUS.md` Next Actions가 bootstrap/onboarding을 명시하면 `docs/BOOTSTRAP.md`를 기준으로 프로젝트 identity와 production 성격을 확인한 뒤
P1-001~ 후보를 먼저 제안해줘. example pack, role/rule/prompt 정비는 Harness 후보로 분리해줘.

후보 우선순위가 비슷하거나 harness/plan/idea 성격의 작업을 고르는 경우,
`docs/retrospectives/` 목록 또는 `rg` 검색으로 최신/관련 회고 1개만 선택해 참고해줘.
회고는 backlog를 대체하지 않고 우선순위 판단 보조 맥락으로만 사용해줘.

각 후보에 대해 아래 항목을 비교해줘.

- ID
- 우선순위
- 선행 조건
- 기대 효과
- 리스크
- 되돌리기 비용
- 검증 방법

최종적으로 지금 착수할 작업 1개를 추천해줘.
구현은 내가 승인하기 전까지 시작하지 마.

추천 작업을 `docs/STATUS.md` Active Work로 올려야 한다면 즉시 수정하지 말고
대상 Work ID를 명시한 Approval Matrix state-change proposal로 먼저 보고해줘.

Phase completion criteria, Current phase/focus, Recent Decisions 변경이 함께 필요하면
`STATUS Update Proposal`에 아래 항목을 포함해줘.

- 변경 섹션
- 변경 이유
- 변경 후 상태
- 되돌리기 비용

사용자가 명시적으로 승인한 뒤에만 STATUS.md를 수정해줘.

추천 작업에 관련 DR(`docs/decisions/`)이 있으면 해당 DR 번호와 현재 상태(Draft/Accepted)를 함께 표시해줘.
