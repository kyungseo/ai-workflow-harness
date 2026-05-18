# docs/AGENT-WORKFLOW.md

Claude Code, Codex, Cursor의 공통 프로젝트 운영 규칙이다.
루트 `CLAUDE.md`와 `AGENTS.md`는 동등한 도구별 진입점이며, 공유 규칙은 이 파일과 상세 harness protocol 문서가 담당한다.
상세 레퍼런스는 `docs/HARNESS-PROTOCOL.md`를 따른다.

## Session Startup

Claude Code는 세션 시작 시 `CLAUDE.md`를 통해 이 파일을 로드한다.
Codex는 세션 시작 시 `AGENTS.md`를 통해 이 파일을 참조한다.
Cursor는 session prompt와 `.cursor/rules/`를 통해 이 파일을 참조한다.
세션 시작 시 harness protocol 전체를 읽지 않는다. 필요한 조건이 생길 때만 `docs/HARNESS-PROTOCOL.md` 또는 상세 문서를 로드한다.
세션 시작 시 `.claude/commands/*.md` 전체를 읽지 않는다. slash command가 명시적으로 호출되었거나 해당 workflow가 분명히 필요할 때만 관련 command 파일을 로드한다.

MUST:

1. `docs/STATUS.md`의 현재 섹션만 읽는다.
2. 요청 작업에 필요한 문서만 추가 로드한다.
3. 구현 또는 문서 변경 전 plan을 제시한다.
4. 승인 후 실행한다.
5. 완료 전 validation과 `docs/STATUS.md` 갱신 필요 여부를 확인한다.

MUST NOT:

- 과거 맥락이 필요하지 않은데 `docs/archive/`, `docs/works/`, `docs/PLAN.md`를 읽지 않는다.
- 승인 없이 넓은 변경, L3 변경, scope 확장을 실행하지 않는다.

## Context Routing

| Need | Load |
| --- | --- |
| 현재 상태 | `docs/STATUS.md` |
| 세션 실행 규칙 빠른 확인 | `docs/HARNESS-QUICK-REFERENCE.md` |
| product 또는 Phase{n} 준비 작업 선택 | `docs/backlog/PHASE{n}.md` |
| harness, command/rule, workflow 작업 선택 | `docs/backlog/HARNESS.md` |
| 아키텍처 요약 | `docs/PLAN-SUMMARY.md` |
| L3 변경, Phase 계획, 상세 근거 | `docs/PLAN.md` |
| 관련 기술 결정 | `docs/decisions/DR-*.md` |
| 큰 작업의 내부 실행 계획 | `docs/works/{category}/{ID}-{topic}.md` |
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
상태 변경은 `State Update Gate`를 따른다.

## Scope And Commit Approval

작은 L1 변경은 대상 파일과 scope가 명확하고 사용자가 진행을 승인했다면 승인된 scope 안에서 빠르게 편집할 수 있다.

MUST:

- 승인된 scope 밖의 파일, 문서, 설정으로 변경이 확장되면 먼저 추가 scope, 이유, 검증 방법을 보고하고 승인 대기한다.
- 특히 `README.md`, `docs/STATUS.md`, workflow 문서, command, prompt, rule, developer-facing 문서로 확장되면 승인 없이 수정하지 않는다.
- commit 전에는 validation 결과, diff summary, 제안 commit message를 보고하고 승인 대기한다.

MUST NOT:

- 편의상 관련 문서를 함께 고친다는 이유만으로 승인된 파일 범위를 확장하지 않는다.
- validation 없이 commit하지 않는다.
- diff summary와 commit message 승인 없이 commit하지 않는다.

## Work Item Routing

| Item | Where |
| --- | --- |
| 지금 진행 중인 작업 | `docs/STATUS.md` Active Work |
| 다음 후보 product 작업 | `docs/backlog/PHASE{n}.md` |
| 하네스/명령/rule/hook 개선 | `docs/backlog/HARNESS.md` |
| 한 작업의 세부 분해 | `docs/works/{category}/{ID}-{topic}.md` |
| 결정 근거 | `docs/decisions/DR-*.md` |
| 완료된 과거 상태 | `docs/archive/` |

새 작업 항목 등록은 `/register`로 수행한다. 긴급도와 성격에 따라 위 위치 중 적절한 곳에 라우팅된다.

상세 기준: `docs/harness-protocol/03-work-items-and-naming.md`

## Risk Gate

| Level | Examples | Gate |
| --- | --- | --- |
| L1 | 문서 소폭 수정, 테스트, 국소 버그 수정 | 간단 plan 후 승인 |
| L2 | 기능 구현, 설정 변경, hook 추가 | 상세 plan 후 승인 |
| L3 | 아키텍처, 인증/보안, 인프라, DB schema, harness 구조 | `docs/PLAN.md` 또는 관련 계획 확인, AS-IS/TO-BE와 rollback 포함 |

L1 Quick Mode는 Work 파일 없이 완료할 수 있다.
단, workflow/protocol/command/rule/prompt/scaffold/status 파일을 건드리면 cascade check를 수행한다.

## STATUS Rules

MUST:

- `docs/STATUS.md` 수정 전 최신 내용을 다시 확인한다.
- `docs/STATUS.md` 변경 전 State Update Gate에 맞는 제안을 먼저 보고하고 사용자 승인을 받는다.
- `docs/STATUS.md` Active Work는 현재 진행 중인 Work 파일의 dashboard pointer로만 유지한다.
- 전체 overwrite를 피하고 관련 섹션만 수정한다.
- 문서와 실제 파일 상태가 충돌하면 실제 파일 상태를 우선한다.
- 불일치 발견 시 먼저 보고하고 수정 제안을 낸다.
- `Done` 상태의 작업은 계속 수정하지 않고, 후속 보정은 신규 작업으로 분리 제안한다.

## State Update Gate

Work 파일이 작업 단위의 SSoT이고, `docs/STATUS.md`는 dashboard다.
상태 변경은 위험도와 대상에 따라 아래 gate를 적용한다.

| Layer | 변경 유형 | Gate |
| --- | --- | --- |
| Layer 1 — Work 파일 | Checkpoint 상태 업데이트, Discovery 추가 | 승인 불필요. 실행 후 대상 Work ID와 변경 내용을 보고 |
| Layer 1 — Work 파일 | Done Criteria 전체 충족 확인, `status: Done`, `actual_end` 기입 | 대상 Work ID를 명시하고 사용자 확인 후 처리 |
| Layer 2 — STATUS.md | Active Work pointer 추가/제거 | 대상 Work ID를 명시한 1줄 제안 후 승인 |
| Layer 2 — STATUS.md | Phase completion criteria, Current phase/focus, Recent Decisions | 기존 `STATUS Update Proposal` 유지 |

멀티 Active Work 환경에서는 모든 state update 제안에 대상 Work ID를 포함한다.
각 Work는 독립 gate를 가진다. Work A의 Done/Archive 처리가 Work B의 상태를 자동 변경하지 않는다.

## Work File Lifecycle

| Status | Location | Meaning |
| --- | --- | --- |
| Candidate | `docs/works/{category}/` 또는 backlog only | 착수 전 후보. 큰 작업은 Work 파일 초안을 가질 수 있다 |
| Active | `docs/works/{category}/` | `docs/STATUS.md` Active Work에 pointer 존재 |
| Done | `docs/works/{category}/` | 완료 기준과 검증 통과. 리뷰·참조 때문에 archive 대기 가능 |
| Archived | `docs/archive/docs/works/{category}/` | 완전 종결. 더 이상 active 참조 불필요 |

Done과 Archived는 분리한다.
Work Done 처리(status: Done, actual_end, README Active→Done, STATUS pointer 제거 제안)와 선택적 archive는 `/close`로 수행한다. `/done`은 세션 요약만 출력하며 Work Done 처리를 포함하지 않는다.
Archive 이동은 사용자 명시 승인 또는 `/start`·`/resume`에서 Done 항목 발견 후 승인된 경우에만 수행한다.

## Documentation Triggers

| Trigger | Action |
| --- | --- |
| DR-worthy decision accepted | `docs/decisions/` 기록 제안 |
| 구조 변경 | `docs/ARCHITECTURE.md` 업데이트 제안 |
| 개발 절차 변경 | `docs/DEVELOPER-GUIDE.md` 업데이트 제안 |
| workflow rule/command 변경 | `docs/HARNESS-PROTOCOL.md` 또는 `docs/harness-protocol/` 업데이트 |
| 발표/보고 산출물 생성 | 목적, audience, source, format, output path, 품질 검증 기준 확인 |
| Phase 완료 또는 새 Phase 시작 | STATUS/archive 재편 제안 |
| 큰 작업 조건 충족 | Work 파일 분해 제안 |
| 비자명 이슈 해결 | `docs/troubleshooting/` 기록 제안 |
| tool surface 변경 | Claude/Codex/Cursor/prompts/scaffold 정렬 확인 |
| scaffold 또는 canonical workflow 변경 | dry-run과 temp scaffold 검증 |
| Quick Mode L1 변경 | no Work/no STATUS 기본, cascade-sensitive file 예외 확인 |

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
