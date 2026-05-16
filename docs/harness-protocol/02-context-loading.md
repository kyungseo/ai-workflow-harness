# 02. Context Loading

이 문서는 context loading 규칙의 canonical source다.

## Default Rule

항상 `docs/STATUS.md`에서 시작한다.
추가 문서는 조건이 충족될 때만 읽는다.

## Load Map

| Need | Load |
| --- | --- |
| 현재 상태 | `docs/STATUS.md` |
| 실행 규칙 빠른 확인 | `docs/HARNESS-QUICK-REFERENCE.md` |
| product/Phase{n} 후보 | `docs/backlog/PHASE{n}.md` |
| harness 후보 | `docs/backlog/HARNESS.md` |
| 아키텍처 요약 | `docs/PLAN-SUMMARY.md` |
| L3 또는 상세 근거 | `docs/PLAN.md` |
| 관련 결정 | `docs/decisions/DR-*.md` |
| 큰 작업 세부 분해 | `docs/TODO/PHASE{n}/*.md` |
| 작업 우선순위·아이디어·반복 리스크 검토 | `docs/retrospectives/` |
| 과거 이력 | `docs/archive/` |

## Anti-Patterns

- 모든 문서를 먼저 읽지 않는다.
- 모든 회고를 먼저 읽지 않는다.
- 과거 이력이 필요하지 않은데 archive를 열지 않는다.
- PLAN-SUMMARY로 충분한데 PLAN 전체를 읽지 않는다.
- 동일 문서를 반복해서 읽지 않는다.

## Retrospective Loading

회고는 backlog를 대체하지 않고 의사결정 보조 맥락으로만 사용한다.

읽는 조건:

- 후보 작업 우선순위가 비슷하다.
- harness/workflow 작업을 고른다.
- Phase 전환, 큰 계획, 아이디어 도출을 요청받았다.
- 같은 문제가 반복되는지 확인해야 한다.
- `HRN-*`, `PRE-*`, `DOC-*`처럼 운영·계획 성격이 강한 작업이다.

읽는 방식:

- 먼저 `docs/retrospectives/` 목록 또는 `rg` 키워드 검색으로 후보를 좁힌다.
- 최신 1개 또는 관련 키워드가 있는 1개만 선택한다.
- product 구현, 단순 버그 수정, 테스트 추가에는 기본적으로 읽지 않는다.
