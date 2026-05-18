# docs/works/

Work 파일 디렉토리다.
큰 작업 단위의 Plan, Done Criteria, Verification, Checkpoints, Discovery를 보존하는 SSoT로 사용한다.
`docs/STATUS.md`는 현재 Active Work pointer를 보여주는 dashboard다.

Work 파일 스펙: `docs/decisions/DR-013-work-file-spec.md`
공통 운영 규칙: `docs/harness-protocol/03-work-items-and-naming.md` Work File Rules

## Categories

| Category | Path | Purpose |
| --- | --- | --- |
| harness | `docs/works/harness/` | Harness, command, rule, workflow 개선 |
| phase1 | `docs/archive/docs/works/phase1/` | Phase 1 legacy work records (archived) |
| phase2 | `docs/works/phase2/` | Phase 2 product and preparation work |

## Lifecycle

| Status | Location | Meaning |
| --- | --- | --- |
| Candidate | `docs/works/{category}/` 또는 backlog only | 착수 전 후보. 큰 작업은 Work 파일 초안을 가질 수 있다 |
| Active | `docs/works/{category}/` | `docs/STATUS.md` Active Work에 pointer 존재 |
| Done | `docs/works/{category}/` | 완료 검증 통과, archive 대기 가능 |
| Archived | `docs/archive/docs/works/{category}/` | 완전 종결 |
