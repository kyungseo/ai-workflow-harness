# 03. Work Items and Naming

이 문서는 work item 위치와 naming 규칙의 canonical source다.

## Where To Put Items

| Item | Location |
| --- | --- |
| 지금 진행 중인 작업 | `docs/STATUS.md` Active Work |
| 다음 product 후보 | `docs/backlog/PHASE{n}.md` |
| Phase 진입 전 선행 작업 | `docs/backlog/PHASE{n}.md` Preparation Candidates |
| harness/command/rule/hook 개선 | `docs/backlog/HARNESS.md` |
| 큰 작업 내부 계획 | `docs/TODO/PHASE{n}/{BACKLOG-ID}-{topic}.md` |
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
| `docs/TODO/PHASE{n}/` | `{BACKLOG-ID}-{topic}.md` | `P2-006-testcontainers.md` |
| `docs/harness-protocol/` | `{NN}-{lowercase-topic}.md` | `03-work-items-and-naming.md` |
| `docs/archive/` | lowercase-hyphenated | `phase1-status.md` |

## TODO Decomposition

TODO 파일은 아래 조건 중 둘 이상 또는 사용자 명시 요청 시 제안한다.

- 서브태스크 3개 이상
- 3개 이상 파일 또는 2개 이상 서비스/모듈 영향
- 한 세션 안에 완료 불확실
- L3 작업
- checkpoint 2개 이상 필요
- 다른 Agent/도구로 인계 가능성 있음

TODO는 backlog나 STATUS를 대체하지 않는다.
