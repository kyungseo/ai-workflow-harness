# 03. Work Items and Naming

이 문서는 work item 위치와 naming 규칙의 canonical source다.

## Where To Put Items

| Item | Location |
| --- | --- |
| 지금 진행 중인 작업 | `docs/STATUS.md` Active Work |
| 다음 product 후보 | `docs/backlog/PHASE{n}.md` |
| Phase 진입 전 선행 작업 | `docs/backlog/PHASE{n}.md` Preparation Candidates |
| harness/command/rule/hook 개선 | `docs/backlog/HARNESS.md` |
| 큰 작업 내부 계획 | `docs/works/{category}/{ID}-{topic}.md` |
| 기술 결정 | `docs/decisions/DR-*.md` |
| 미결 질문 | `docs/STATUS.md` Blockers/OQ |
| 완료 이력 | `docs/archive/` |

새 항목 등록은 `/register`로 수행한다. 긴급도와 성격에 따라 위 위치 중 적절한 곳으로 라우팅된다.

| 긴급도 / 성격 | 라우팅 대상 |
| --- | --- |
| 지금 바로 착수 | `docs/STATUS.md` Active Work → `/work` 연결 |
| 곧 할 것 | `docs/STATUS.md` Next Actions |
| Product 작업 | `docs/backlog/PHASE{n}.md` |
| Harness 작업 | `docs/backlog/HARNESS.md` |

## ID Prefixes

| Prefix | Meaning | Home |
| --- | --- | --- |
| `P{n}-NNN` | Phase product backlog | `docs/backlog/PHASE{n}.md` |
| `PRE-*` | Phase entry prerequisite | `docs/backlog/PHASE{n}.md` |
| `HRF-*` | Harness refactor | `docs/backlog/HARNESS.md` |
| `HRN-*` | Harness hardening | `docs/backlog/HARNESS.md` |
| `DOC-*` | Documentation task | context-dependent |
| `DR-NNN` | Decision record | `docs/decisions/` |
| `OQ-*` | Open question | `docs/STATUS.md` |

ID를 다른 의미로 재사용하지 않는다.

## File Naming

| Location | Rule | Example |
| --- | --- | --- |
| `docs/` root | UPPERCASE-HYPHENATED | `HARNESS-PROTOCOL.md` |
| `docs/backlog/` | UPPERCASE-HYPHENATED | `PHASE2.md` |
| `docs/decisions/` | `DR-{NNN}-{topic}.md` | `DR-010-integration-test-infra.md` |
| `docs/works/{category}/` | `{ID}-{lowercase-topic}.md` | `HRF-002-work-system-refactor.md` |
| `docs/harness-protocol/` | `{NN}-{lowercase-topic}.md` | `03-work-items-and-naming.md` |
| `docs/archive/` | lowercase-hyphenated | `phase1-status.md` |

## Work File Decomposition

Work 파일은 아래 조건 중 둘 이상 또는 사용자 명시 요청 시 생성을 제안한다.

- 서브태스크 3개 이상
- 3개 이상 파일 또는 2개 이상 서비스/모듈 영향
- 한 세션 안에 완료 불확실
- L3 작업
- Checkpoint 2개 이상 필요
- 다른 Agent/도구로 인계 가능성 있음

Work 파일은 backlog나 STATUS를 대체하지 않는다.
Work 파일 포맷 스펙: `docs/decisions/DR-013-work-file-spec.md`

## Quick Mode

Product surface의 작은 L1 작업은 기본적으로 Work 파일을 만들지 않는다.
범위가 명확하고 한 세션 안에 끝나는 작업은 최종 응답, validation 결과, commit history로 충분하다.

Quick Mode 대상 예시:

- 오타·문구 수정
- 단일 파일의 작은 문서 정리
- 명확한 config 한 줄 수정
- 단일 테스트 보강
- 이미 범위가 명확하고 세션을 넘기지 않는 작은 수정

Quick Mode 비대상:

- harness/workflow surface(`workflow/protocol/command/rule/prompt/scaffold/status`) 변경

Harness/workflow surface를 건드리면 기본 L2로 다룬다.

다만 아래 조건 중 하나라도 있으면 L1이어도 Work 파일 생성을 고려한다.

- 세션을 넘길 가능성이 있음
- 상태 변경이 여러 단계임
- 사용자나 agent가 나중에 맥락을 복구해야 함
- 사용자가 명시적으로 별도 추적을 요청함

## Work File Rules

Work 파일과 실제 저장소 상태가 충돌하면 실제 저장소 상태가 진실이다.
불일치 발견 시 Work 파일을 현행화하고 Discovery 섹션에 기록한다.

### Commit References

Work 파일 frontmatter의 `related_commits`는 best-effort reference다.
무결성 장치가 아니라 나중에 관련 변경을 찾기 위한 탐색 보조 링크로 취급한다.

- Work의 무결한 이력은 Plan, Done Criteria, Verification, Checkpoints, Discovery가 담당한다.
- 하나의 commit이 여러 Work를 포함하면 같은 commit id가 여러 Work에 들어갈 수 있다.
- mixed commit이면 Discovery나 closeout summary에 그 사실을 남기면 충분하다.
- 모든 commit 후 Work 파일을 다시 열어 `related_commits`를 갱신하는 것을 필수화하지 않는다.

### Lifecycle

| Status | Location | Meaning |
| --- | --- | --- |
| Candidate | `docs/works/{category}/` 또는 backlog only | 착수 전 후보. 큰 작업은 Work 파일 초안을 가질 수 있다 |
| Active | `docs/works/{category}/` | `docs/STATUS.md` Active Work에 pointer 존재 |
| Done | `docs/works/{category}/` | Done Criteria와 Verification 통과. 리뷰·참조 때문에 archive 대기 가능 |
| Archived | `docs/archive/docs/works/{category}/` | 완전 종결. 더 이상 active 참조 불필요 |

`Done`과 `Archived`는 분리한다.
Work Done 처리(status: Done, actual_end, README Active→Done, STATUS pointer 제거 제안)와 선택적 archive는 `/close`로 수행한다. `/done`은 세션 요약만 출력하며 Work Done 처리를 포함하지 않는다.
Archive 이동은 사용자 명시 승인 또는 `/start`·`/resume`에서 Done 항목 발견 후 승인된 경우에 수행한다.

### State Update Gate

| Layer | 변경 유형 | Gate |
| --- | --- | --- |
| Layer 1 — Work 파일 | Checkpoint 상태 업데이트, Discovery 추가 | 승인 불필요. 실행 후 대상 Work ID와 변경 내용을 보고 |
| Layer 1 — Work 파일 | Done Criteria 전체 충족 확인, `status: Done`, `actual_end` 기입 | 대상 Work ID를 명시하고 사용자 확인 후 처리 |
| Layer 2 — STATUS.md | Active Work pointer 추가/제거 | 대상 Work ID를 명시한 1줄 제안 후 승인 |
| Layer 2 — STATUS.md | Phase completion criteria, Current phase/focus, Recent Decisions | `STATUS Update Proposal` 유지 |

멀티 Active Work 환경에서는 모든 state update 제안에 대상 Work ID를 포함한다.
각 Work는 독립 gate를 가진다.

### Index Rules

각 `docs/works/{category}/README.md`는 category별 inventory다.
권장 섹션은 Candidate, Active, Done (archive pending), Archived다.

- Candidate Work 파일은 STATUS Active Work에 올리지 않는다.
- Active Work 파일은 STATUS Active Work pointer와 category index Active 섹션에 모두 나타나야 한다.
- Done Work 파일은 STATUS Active Work에서 제거하고 category index Done 섹션에 둔다.
- Archived Work 파일은 `docs/archive/docs/works/{category}/`로 이동하고 category index Archived 섹션에 archive 경로를 남긴다.

이 섹션이 Work 파일 공통 운영 규칙의 권위 문서다. 개별 Work 파일은 이 규칙을 반복하지 않는다.
