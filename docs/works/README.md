# docs/works/

Work 파일 디렉토리다.
큰 작업 단위의 Plan, Done Criteria, Verification, Checkpoints, Discovery를 보존하는 SSoT로 사용한다.
`docs/STATUS.md`는 현재 Active Work pointer를 보여주는 dashboard다.

Work 파일 스펙: `docs/decisions/DR-013-work-file-spec.md`
공통 운영 규칙: `docs/HARNESS-PROTOCOL.md` Work File Rules

## Categories

| Category | Path | Purpose |
| --- | --- | --- |
| harness | `docs/works/harness/` | Harness, command, rule, workflow, public-readiness 작업 |

새 category가 필요하면 Work 파일 생성 전에 `docs/STATUS.md`와 `docs/HARNESS-PROTOCOL.md` 영향 여부를 확인한다.

## Lifecycle

| Status | Location | Meaning |
| --- | --- | --- |
| Active | `docs/works/{category}/` | `docs/STATUS.md` Active Work에 pointer 존재 |
| Done | `docs/works/{category}/` | 완료 검증 통과, archive 대기 가능 |
| Archived | `docs/archive/docs/works/{category}/` | 완전 종결 |

Backlog `Candidate`는 후보 pool이다. Work 파일은 착수 승인 후 `Active` 상태로 생성한다.
