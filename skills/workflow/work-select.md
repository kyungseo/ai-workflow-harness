# work-select

Canonical workflow procedure for `/work-select`.

이 파일은 workflow 상세 절차의 SSoT다. Tool-specific surface는 아래 adapter만 가진다.

| Tool | Adapter |
| --- | --- |
| Claude Code | `.claude/commands/work-select.md` |
| Codex | `.agents/skills/workflow-work-select/SKILL.md` |
| Cursor | `.cursor/rules/workflow.mdc` |

Adapter는 Step 0, hard-stop 요약, entry mechanism, fallback만 보유한다. 상세 절차, checklist, cascade 판단은 이 canonical 파일을 따른다.

## Procedure

docs/STATUS.md를 확인한 뒤, 작업 성격에 맞는 backlog를 선택해 우선순위가 높은 후보 작업을 검토해줘.

- Product track 작업: docs/backlog/PRODUCT.md
- Harness / workflow 작업: docs/backlog/HARNESS.md
- Scaffold 직후 부팅 작업: docs/STATUS.md Next Actions가 bootstrap/onboarding을 명시할 때 docs/BOOTSTRAP.md
- 성격이 불명확하면 두 backlog의 제목과 우선순위만 비교하고, 불필요한 상세 로드는 하지 마.

Product backlog가 비어 있고 `docs/STATUS.md` Next Actions가 bootstrap/onboarding을 명시하면 `docs/BOOTSTRAP.md`를 기준으로 프로젝트 identity와 production 성격을 확인한 뒤
`docs/PLAN-SUMMARY.md` Implementation Baseline을 확인해줘. baseline이 비어 있으면 feature 후보 대신 Project Initialization을 첫 후보로 제안하고,
baseline이 완료된 뒤에만 feature 후보를 제안해줘. example pack, role/rule/prompt 정비는 Harness 후보로 분리해줘.
backlog 후보는 Work ID 없이 제목/slug로 관리하고, Work ID는 /work-plan 착수 승인 시 확정됨을 명시해줘.

후보 우선순위가 비슷하거나 harness/plan/idea 성격의 작업을 고르는 경우,
`docs/retrospectives/` 또는 `docs/briefs/` 목록 / `rg` 검색으로 최신/관련 문서 1개만 선택해 참고해줘.
회고는 반복 리스크와 학습 근거, brief는 방향 비교와 포지션 근거로만 사용하고 backlog를 대체하지 않게 해줘.

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
Work ID가 아직 없는 backlog 후보라면 제목/slug를 임시 식별자로 사용하고, Work ID는 `/work-plan [title-or-slug]` 착수 시 확정됨을 명시해줘.

Current phase/focus, Recent Decisions 변경이 함께 필요하면
`STATUS Update Proposal`에 아래 항목을 포함해줘.

- 변경 섹션
- 변경 이유
- 변경 후 상태
- 되돌리기 비용

사용자가 명시적으로 승인한 뒤에만 STATUS.md를 수정해줘.

추천 작업에 관련 DR(`docs/decisions/`)이 있으면 해당 DR 번호와 현재 상태(Draft/Accepted)를 함께 표시해줘.
