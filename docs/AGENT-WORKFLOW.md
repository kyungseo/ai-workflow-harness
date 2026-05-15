# docs/AGENT-WORKFLOW.md

Claude Code, Codex, Cursor의 공통 프로젝트 운영 규칙이다.
루트 `CLAUDE.md`와 `AGENTS.md`는 동등한 도구별 진입점이며, 공유 규칙은 이 파일과 상세 harness protocol 문서가 담당한다.
상세 레퍼런스는 `docs/HARNESS-PROTOCOL.md`를 따른다.

## Session Startup

Claude Code는 세션 시작 시 `CLAUDE.md`를 통해 이 파일을 로드한다.
Codex는 세션 시작 시 `AGENTS.md`를 통해 이 파일을 참조한다.
Cursor는 session prompt와 `.cursor/rules/`를 통해 이 파일을 참조한다.
세션 시작 시 harness protocol 전체를 읽지 않는다. 필요한 조건이 생길 때만 `docs/HARNESS-PROTOCOL.md` 또는 상세 문서를 로드한다.

MUST:

1. `docs/STATUS.md`의 현재 섹션만 읽는다.
2. 요청 작업에 필요한 문서만 추가 로드한다.
3. 구현 또는 문서 변경 전 plan을 제시한다.
4. 승인 후 실행한다.
5. 완료 전 validation과 `docs/STATUS.md` 갱신 필요 여부를 확인한다.

MUST NOT:

- 과거 맥락이 필요하지 않은데 `docs/archive/`, `docs/TODO/`, `docs/PLAN.md`를 읽지 않는다.
- 승인 없이 넓은 변경, L3 변경, scope 확장을 실행하지 않는다.

## Context Routing

| Need | Load |
| --- | --- |
| 현재 상태 | `docs/STATUS.md` |
| 세션 실행 규칙 빠른 확인 | `docs/HARNESS-QUICK-REFERENCE.md` |
| product 또는 Phase2 준비 작업 선택 | `docs/backlog/PHASE2.md` |
| harness, command/rule, workflow 작업 선택 | `docs/backlog/HARNESS.md` |
| 아키텍처 요약 | `docs/PLAN-SUMMARY.md` |
| L3 변경, Phase 계획, 상세 근거 | `docs/PLAN.md` |
| 관련 기술 결정 | `docs/decisions/DR-*.md` |
| 큰 작업의 내부 실행 계획 | `docs/TODO/PHASE{n}/*.md` |
| 회고 기반 우선순위·개선 방향 확인 | `docs/retrospectives/` |
| 이슈 해결 내역 확인 | `docs/troubleshooting/` |
| 과거 Phase 맥락 | `docs/archive/` |

조건이 없으면 추가 문서를 로드하지 않는다.
회고는 backlog를 대체하지 않는다. 작업 선택, 계획 수립, 아이디어 도출, 반복 리스크 확인이 필요할 때 최신 또는 관련 회고 1개만 선택적으로 확인한다.

## State Machine

```text
INIT -> PLAN -> APPROVAL -> EXECUTE -> VALIDATE -> CHECKPOINT -> END
                 ^              |
                 |              v
              RECOVER <- FAIL <-+
```

Plan에는 Scope, Files, Verification, Risk, Reversal Cost를 포함한다.
`VALIDATE` 실패 상태에서는 checkpoint 또는 commit을 만들지 않는다.
`docs/STATUS.md` 변경은 `STATUS Update Proposal` 보고와 사용자 승인 후에만 수행한다.

## Work Item Routing

| Item | Where |
| --- | --- |
| 지금 진행 중인 작업 | `docs/STATUS.md` Active Work |
| 다음 후보 product 작업 | `docs/backlog/PHASE2.md` |
| 하네스/명령/rule/hook 개선 | `docs/backlog/HARNESS.md` |
| 한 작업의 세부 분해 | `docs/TODO/PHASE{n}/{BACKLOG-ID}-{topic}.md` |
| 결정 근거 | `docs/decisions/DR-*.md` |
| 완료된 과거 상태 | `docs/archive/` |

상세 기준: `docs/harness-protocol/03-work-items-and-naming.md`

## Risk Gate

| Level | Examples | Gate |
| --- | --- | --- |
| L1 | 문서 소폭 수정, 테스트, 국소 버그 수정 | 간단 plan 후 승인 |
| L2 | 기능 구현, 설정 변경, hook 추가 | 상세 plan 후 승인 |
| L3 | 아키텍처, 인증/보안, 인프라, DB schema, harness 구조 | `docs/PLAN.md` 또는 관련 계획 확인, AS-IS/TO-BE와 rollback 포함 |

## STATUS Rules

MUST:

- `docs/STATUS.md` 수정 전 최신 내용을 다시 확인한다.
- `docs/STATUS.md` 변경 전 `STATUS Update Proposal`을 먼저 보고하고 사용자 승인을 받는다.
- 전체 overwrite를 피하고 관련 섹션만 수정한다.
- 문서와 실제 파일 상태가 충돌하면 실제 파일 상태를 우선한다.
- 불일치 발견 시 먼저 보고하고 수정 제안을 낸다.
- `Done` 상태의 작업은 계속 수정하지 않고, 후속 보정은 신규 작업으로 분리 제안한다.

## Documentation Triggers

| Trigger | Action |
| --- | --- |
| DR-worthy decision accepted | `docs/decisions/` 기록 제안 |
| 구조 변경 | `docs/ARCHITECTURE.md` 업데이트 제안 |
| 개발 절차 변경 | `docs/DEVELOPER-GUIDE.md` 업데이트 제안 |
| workflow rule/command 변경 | `docs/HARNESS-PROTOCOL.md` 또는 `docs/harness-protocol/` 업데이트 |
| Phase 완료 또는 새 Phase 시작 | STATUS/archive 재편 제안 |
| 큰 작업 조건 충족 | TODO 분해 제안 |
| 비자명 이슈 해결 | `docs/troubleshooting/` 기록 제안 |

문서, prompt, command, rule, Cursor rule, hook 메시지를 수정할 때는 `docs/decisions/DR-007-language-policy.md`의 언어 정책을 확인한다.

상세 기준:

- `docs/harness-protocol/04-document-lifecycle.md`
- `docs/harness-protocol/05-triggers-and-cascade.md`

## Naming Summary

| Prefix | Meaning |
| --- | --- |
| `P{n}-NNN` | Phase product backlog |
| `PRE-*` | Phase entry prerequisite |
| `HRF-*` | Harness refactor |
| `HRN-*` | Harness hardening |
| `DOC-*` | Documentation task |
| `DR-NNN` | Decision record |
| `OQ-*` | Open question |

ID를 다른 의미로 재사용하지 않는다.

파일명 상세 기준:

- `docs/decisions/DR-008-docs-filename-standard.md`
- `docs/harness-protocol/03-work-items-and-naming.md`

## Project Constants

- Runtime: Java 21+
- Framework: Spring Boot 3.5.x
- Build: Gradle wrapper
- Architecture: Spring Boot microservices template
- Base package: `io.kyungseo.msa`
- Active state file: `docs/STATUS.md`

## Verification Defaults

- Java unit/module change: `./gradlew test`
- Build/config change: `./gradlew build`
- Gateway 또는 integration flow: 관련 checkpoint에 정의된 검증
- Documentation-only change: diff와 링크 확인

검증을 실행할 수 없다면 이유와 남은 risk를 보고한다.
