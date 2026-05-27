# docs/AGENT-WORKFLOW.md

Claude Code, Codex, Cursor의 공통 프로젝트 운영 규칙이다.
루트 `CLAUDE.md`와 `AGENTS.md`는 동등한 도구별 진입점이며, 공유 규칙은 이 파일과 상세 harness protocol 문서가 담당한다.
전역 행동 원칙은 `docs/BEHAVIOR-PRINCIPLES.md`가 우선하며, 이 문서는 그 원칙을 실행 절차로 구체화한다.
상세 레퍼런스는 `docs/HARNESS-PROTOCOL.md`를 따른다.

## Session Startup

Claude Code는 세션 시작 시 `CLAUDE.md`를 통해 이 파일을 로드한다.
Codex는 세션 시작 시 `AGENTS.md`를 통해 이 파일을 참조한다.
Cursor는 session prompt와 `.cursor/rules/`를 통해 이 파일을 참조한다.
세션 시작 시 harness protocol 전체를 읽지 않는다. 필요한 조건이 생길 때만 `docs/HARNESS-PROTOCOL.md`를 로드한다.
세션 시작 시 `.claude/commands/*.md` 전체를 읽지 않는다. slash command가 명시적으로 호출되었거나 해당 workflow가 분명히 필요할 때만 관련 command 파일을 로드한다.

MUST:

1. `docs/STATUS.md`의 현재 섹션만 읽는다.
2. 요청 작업에 필요한 문서만 추가 로드한다.
3. 구현 또는 문서 변경 전 plan을 제시한다.
4. 승인 후 실행한다.
5. 완료 전 validation과 `docs/STATUS.md` 갱신 필요 여부를 확인한다.
6. 파일 수정·commit·PR 생성 전, 현재 branch가 의도한 작업 범위에 맞는지 확인한다. `develop` 또는 `main`에서 protected workflow 파일은 수정하지 않는다. 해당 repo에 `docs/GIT-WORKFLOW.md`가 있으면 §0을 참조한다.

MUST NOT:

- 과거 맥락이 필요하지 않은데 `docs/archive/`, `docs/works/`, `docs/PLAN.md`를 읽지 않는다.
- `docs/BOOTSTRAP.md`가 존재한다는 이유만으로 매 세션 로드하지 않는다.
- 승인 없이 넓은 변경, L3 변경, scope 확장을 실행하지 않는다.

Active Work, Next Actions, archive 대기 Work가 모두 없고 Open Blocker도 없으면 clean idle 상태로 보고한다.
이때 과거 milestone criteria나 archive 이력을 next candidate로 자동 확장하지 않고, `/pick` 또는 `/register`를 다음 진입로로 안내한다.

## Context Routing

## Operating Tracks

이 harness는 적용 대상 repository 안에서 두 개의 작업 트랙을 함께 운영하도록 설계한다.

- **Product track**: 적용 대상 프로젝트의 기능, 문서, 테스트, 인프라, Phase backlog를 관리한다.
- **Harness track**: AI workflow, command/rule, prompt, scaffold, status/process hardening을 관리한다.

이 repository를 harness 자체 개발용 source로 운영하는 경우 Product track이 비어 있을 수 있고 active work는 주로 Harness track에 속할 수 있다.
반면 `scripts/create-harness.sh`로 scaffold한 신규/기존 프로젝트는 Product track과 Harness track을 모두 가진다.

| Need | Load |
| --- | --- |
| 현재 상태 | `docs/STATUS.md` |
| Scaffold 직후 프로젝트 부팅 | `docs/STATUS.md` Next Actions가 bootstrap/onboarding을 명시할 때 `docs/BOOTSTRAP.md` |
| Scaffold source onboarding 기준 확인 | `docs/SCAFFOLD-BOOTSTRAP.md` |
| 세션 실행 규칙 빠른 확인 | `docs/HARNESS-QUICK-REFERENCE.md` |
| Work ID·OQ ID·DR ID 부여·검증, 파일명 규칙 | `docs/HARNESS-NAMING-RULES.md` — `/register`·`/work` Work ID 확정 시, branch/Work ID slug 대응 논의 시에만 로드. `/start`, `/pick`, 일반 status 확인, cascade 검증에서는 로드하지 않는다 |
| failure state 진입, Validation Checklist, Commit Approval 판단, `/health` 조건부 recovery 확인 | `docs/HARNESS-RECOVERY-VALIDATION.md` — `/start`, `/pick`, 일반 `/work`·`/close`·`/done` 흐름에서는 로드하지 않는다. validation failure·recovery·commit approval 판단이 필요한 경우에만 로드한다 |
| Product track 또는 Phase{n} 준비 작업 선택 | `docs/backlog/PHASE{n}.md` |
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
`docs/WORKFLOW-MANUAL.md`는 사용자용 레퍼런스다. 평시 AI 실행 규칙 로드 대상에서 제외하고, 사용자가 매뉴얼 검토를 요청했거나 user-facing workflow 변경/cascade 감사가 필요할 때만 확인한다.

## State Machine

```text
INIT -> PLAN -> APPROVAL -> EXECUTE -> VALIDATE -> CHECKPOINT -> END
                 ^              |
                 |              v
              RECOVER <- FAIL <-+
```

Plan에는 Scope, Files, Verification, Risk, Reversal Cost를 포함한다.
`VALIDATE` 실패 상태에서는 checkpoint 또는 commit을 만들지 않는다.
실행 전 승인, 상태 변경, commit 전 승인은 `Approval Matrix`를 따른다.

## Approval Matrix

Scope approval, state-change approval, commit approval을 하나의 기준으로 판단한다.
작업 시작 전에는 Scope, Files, Verification, Risk, Reversal Cost를 보고하고 승인받는다.

| 변경 유형 | 실행 전 | 상태 변경 | commit 전 |
| --- | --- | --- | --- |
| L1 Product track surface | 간단 plan 승인 후 실행. Work 파일 없이 Quick Mode 가능 | Work checkpoint/discovery는 승인 불필요, 실행 후 대상 Work ID와 변경 보고 | validation 결과, diff summary, 제안 commit message 보고 후 승인 |
| L2 harness/workflow surface 또는 설정 변경 | 상세 plan 승인 후 실행. Work 파일 사용을 기본값으로 둔다 | Work Done과 STATUS Active pointer 변경은 대상 Work ID를 명시하고 승인 후 처리 | validation 결과, diff summary, 제안 commit message 보고 후 승인 |
| L3 아키텍처·인프라·DB schema·보안 구조 | 관련 계획 또는 `docs/PLAN.md` 확인, AS-IS/TO-BE와 rollback 포함 후 승인 | Phase criteria, Current phase/focus, Recent Decisions 변경은 `STATUS Update Proposal` 승인 후 처리 | validation 결과, diff summary, 제안 commit message, rollback 단위 보고 후 승인 |

MUST:

- 승인된 scope 밖의 파일, 문서, 설정으로 변경이 확장되면 먼저 추가 scope, 이유, 검증 방법을 보고하고 승인 대기한다.
- `docs/STATUS.md` 변경은 위 matrix의 상태 변경 규칙에 맞게 먼저 제안하고 승인받는다.
- commit 전 승인은 risk level과 무관하게 항상 별도로 받는다.
- 멀티 Active Work 환경에서는 모든 state-change proposal에 대상 Work ID를 포함한다.

MUST NOT:

- 편의상 관련 문서를 함께 고친다는 이유만으로 승인된 파일 범위를 확장하지 않는다.
- validation 없이 commit하지 않는다.
- diff summary와 commit message 승인 없이 commit하지 않는다.

## Work Item Routing

| Item | Where |
| --- | --- |
| 지금 진행 중인 작업 | `docs/STATUS.md` Active Work |
| 다음 후보 Product track 작업 | `docs/backlog/PHASE{n}.md` |
| 하네스/명령/rule/hook 개선 | `docs/backlog/HARNESS.md` |
| Scaffold bootstrapping checklist | `docs/STATUS.md` Next Actions가 bootstrap/onboarding을 명시할 때 `docs/BOOTSTRAP.md` |
| 한 작업의 세부 분해 | `docs/works/{category}/{ID}-{topic}.md` |
| 결정 근거 | `docs/decisions/DR-*.md` |
| 완료된 과거 상태 | `docs/archive/` |

새 작업 항목 등록은 `/register`로 수행한다. 긴급도와 성격에 따라 TYPE(FEAT/PATCH/HOTFIX/CHORE)을 판단하고 위 위치 중 적절한 곳에 라우팅된다. backlog 후보는 제목/slug만 유지하고, Work ID는 `/work` 착수 승인 후 Work 파일 생성 시 확정한다.

Work ID 형식 상세 기준: `docs/HARNESS-NAMING-RULES.md`

## Risk Levels

| Level | Examples | Gate |
| --- | --- | --- |
| L1 | Product track 문서 소폭 수정, 테스트, 국소 버그 수정 | Approval Matrix L1 |
| L2 | 기능 구현, 설정 변경, hook 추가, harness/workflow surface 변경 | Approval Matrix L2 |
| L3 | 아키텍처, 인증/보안, 인프라, DB schema, harness 구조 | Approval Matrix L3 |

L1 Quick Mode는 Product track의 작고 명확한 변경에 한해 Work 파일 없이 완료할 수 있다.
Harness/workflow surface(`entrypoint/workflow/protocol/command/rule/prompt/scaffold/status`)를 건드리면 기본 L2로 다룬다.

## STATUS Rules

MUST:

- `docs/STATUS.md` 수정 전 최신 내용을 다시 확인한다.
- `docs/STATUS.md` 변경 전 Approval Matrix에 맞는 제안을 먼저 보고하고 사용자 승인을 받는다.
- `docs/STATUS.md` Active Work는 현재 진행 중인 Work 파일의 dashboard pointer로만 유지한다.
- 전체 overwrite를 피하고 관련 섹션만 수정한다.
- 문서와 실제 파일 상태가 충돌하면 실제 파일 상태를 우선한다.
- 불일치 발견 시 먼저 보고하고 수정 제안을 낸다.
- `Done` 상태의 작업은 계속 수정하지 않고, 후속 보정은 신규 작업으로 분리 제안한다.

## State And Closeout Rules

Work 파일은 작업 단위 SSoT이고, `docs/STATUS.md`는 dashboard다.
Work checkpoint/discovery, Work Done, STATUS 변경은 Approval Matrix를 따른다.
멀티 Active Work 환경에서는 모든 state-change proposal에 대상 Work ID를 포함한다.

commit 또는 PR 생성 전에는 반드시 두 가지를 보고한다.

- STATUS Finalization: `docs/STATUS.md` 최종본 반영 필요 여부와 이유
- Tracking Finalization: backlog/Work/DR tracker 최종 상태 반영 필요 여부와 이유

필요한 `docs/STATUS.md` 변경은 사용자 승인 없이 수행하지 않는다.
`docs/STATUS.md` 변경이 확정되면 실질 변경과 **같은 commit**에 포함한다. 실질 변경을 먼저 commit한 뒤 `STATUS.md`를 별도 commit으로 분리하지 않는다.
상세 체크리스트는 `docs/HARNESS-RECOVERY-VALIDATION.md` (Validation Checklist, Commit Approval)와 `docs/HARNESS-PROTOCOL.md` (Triggers, Work File Rules)를 따른다.

Work Done 처리와 선택적 archive는 `/close`로 수행한다. `/close`는 Work Done 처리이며 commit/PR finalization gate를 대체하지 않는다.
`/done`은 세션 요약만 출력하며 Work Done 처리를 포함하지 않는다.
Done Criteria에 사용자 최종 리뷰, final review, 검토 후 Done 등 명시적 리뷰 조건이 있으면 `/close`에서 확인 완료 전 Done 처리하지 않는다.

## Trigger And Naming Pointers

문서, prompt, command, rule, Cursor rule, hook 메시지를 수정할 때는 DR-007 언어 정책을 확인한다.
DR, STATUS/archive, Work decomposition, troubleshooting, tool surface, scaffold 검증 trigger의 상세 기준은 `docs/HARNESS-PROTOCOL.md`를 따른다.
workflow/doc/tool/scaffold/status 표면을 변경할 때는 `docs/HARNESS-PROTOCOL.md`의 trigger/cascade section을 조건부 로드하고, 필요한 surface만 확인한다.

ID prefix와 파일명 상세 기준:

- `docs/decisions/DR-008-docs-filename-standard.md`
- `docs/HARNESS-NAMING-RULES.md`

## Project Constants

- Runtime: Markdown 문서와 shell script. 별도 application runtime 불필요.
- Framework: Manual-first AI Workflow Harness
- Build: core workflow 문서에는 build 없음. scaffold script는 shell 기반.
- Architecture: Entry contract + state/work 추적 + approval gate + tool-surface mirror + scaffold
- Base package/module: 해당 없음
- Active state file: `docs/STATUS.md`

## Verification Defaults

- Documentation-only change: `git diff --check`, 링크와 stale phrase 점검
- Workflow/protocol/tool-surface change: canonical -> tool-specific -> user-facing -> scaffold cascade 점검
- Scaffold change: `scripts/create-harness.sh`가 있으면 `bash -n scripts/create-harness.sh`, generic dry-run, 필요 시 temp 실제 생성. scaffold 적용 repository처럼 script가 없으면 Skipped / Not Applicable로 보고
- Public release prep: secret/private-info scan, stale project identity audit

검증을 실행할 수 없다면 이유와 남은 risk를 보고한다.
