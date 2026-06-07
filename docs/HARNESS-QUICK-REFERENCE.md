# Harness Quick Reference

AI Workflow Harness의 일상 실행 규칙이다.
전역 행동 원칙은 `docs/BEHAVIOR-PRINCIPLES.md`를 따른다.
상세 설명은 `docs/HARNESS-PROTOCOL.md`를 따른다.
이 문서는 세션 중 빠르게 확인하는 요약이다. 충돌하거나 상세 판단이 필요하면 `docs/HARNESS-PROTOCOL.md`를 우선한다.

## 1. Session Start

항상 먼저 `docs/STATUS.md`의 현재 섹션만 확인한다.

이 harness는 적용 대상 repository에서 두 트랙을 운영한다.

- Product track: 실제 제품/서비스/콘텐츠 work와 Phase backlog.
- Harness track: AI workflow, command/rule, prompt, scaffold, status/process hardening.

이 repository를 harness 자체 개발용 source로 운영하는 경우 Product track이 비어 있을 수 있다.
scaffold된 신규/기존 프로젝트는 Product track과 Harness track을 함께 가진다.

확인 항목:

- Current State
- Active Work
- Blockers And Open Questions
- Next Actions

`docs/works/*/*.md`에 `status: Done`인 archive 대기 Work가 있으면 보고하고 archive 승인 여부를 제안한다.

**Idle-State (Active Work 없음 + Next Actions 없음 + archive 대기 Work 없음):**

- Open Blocker가 있으면 idle-state 안내보다 먼저 노출한다.
- Open Blocker도 없으면 clean idle 상태로 보고하고 아래 내용을 안내한다. `Current Milestone Criteria` 미완료 항목을 next candidate로 자동 확장하지 않는다.
  - 다음 작업을 고르려면: `/work-select`
  - 새 작업을 등록하려면: `/work-register`
  - 다른 프로젝트에 harness를 적용하려는 source repo 작업이라면 README Section 10 New Project Adoption을 참고하세요.

추가 문서 로드 조건:

| 필요 상황 | 로드할 문서 |
| --- | --- |
| Scaffold 직후 프로젝트 부팅 | `docs/STATUS.md` Next Actions가 bootstrap/onboarding을 명시할 때 `docs/BOOTSTRAP.md` |
| Product track 작업 선택 | `docs/backlog/PHASE{n}.md` |
| Harness track 작업 선택 | `docs/backlog/HARNESS.md` |
| Architecture 요약 | `docs/PLAN-SUMMARY.md` |
| L3 변경 또는 planning 근거 | `docs/PLAN.md` |
| 우선순위 동률, planning, 아이디어 도출, 반복 risk 확인 | 최신 또는 관련 `docs/retrospectives/` |
| 단순하지 않은 이슈 해결 이력 | `docs/troubleshooting/` |
| 과거 Phase 1 세부 맥락 | `docs/archive/snapshots/harness-refactor-20260514/` 또는 `docs/archive/` |

### Command Taxonomy

상세 절차는 `skills/workflow/{name}.md`가 canonical SSoT다.
`.claude/commands/`, `.agents/skills/workflow-*`, `.cursor/rules/workflow.mdc`는 tool-specific adapter다.

| 범주 | 명령 | 역할 |
| --- | --- | --- |
| Session lifecycle | `/session-start`, `/work-select`, `/session-summary` | 세션 상태 파악, 다음 작업 선택, 세션 요약 |
| Work lifecycle | `/work-plan`, `/work-resume`, `/work-close` | Work 착수, Work 재개, Work Done 처리 |
| Utility / Analysis | `/work-register`, `/work-debug`, `/work-doc`, `/repo-decision`, `/repo-health` | 항목 등록, 문제 분석, 산출물 생성, 결정 기록, 상태 점검 |

## 2. Validation

완료 전 확인:

- STATUS 최신성
- 변경 파일 범위
- Verification 실행 또는 미실행 사유
- 문서 링크 정합성
- DR 필요 여부
- Approval Matrix에 따른 STATUS state-change 필요 여부
- commit/PR 전 STATUS 최종본 반영 필요 여부
- commit/PR 전 backlog/Work/DR tracker 최종 상태 반영 필요 여부
- develop → main PR이면: source repo는 `docs/GIT-WORKFLOW.md` §3 release gate 수행; scaffold product repo는 project-specific release criteria 적용

COMMIT 전 확인:

- `git status`
- `git add <files>`
- `git status`
- `git diff --cached`
- STATUS Finalization: `docs/STATUS.md` update needed yes/no, 이유, 필요 시 Approval Matrix proposal
  - `STATUS.md` 변경이 확정되면 실질 변경과 **같은 commit**에 포함. 별도 follow-up commit 금지.
- Tracking Finalization: backlog/Work/DR update needed yes/no, 이유
- validation 결과, diff summary, 제안 commit message 보고
- 사용자 승인

L3 이상 작업은 논리 단계별 commit을 기본값으로 한다. 한 commit에는 하나의 검증 가능한 목적을 담고, rollback plan은 commit 또는 단계 단위로 설명한다.

### State-Change Shortcuts

- Work checkpoint/discovery: 승인 없이 반영 후 대상 Work ID와 변경 내용을 보고한다.
- STATUS Active Work pointer: 대상 Work ID를 명시한 one-line proposal 후 승인받는다.
- Current phase/focus, Phase criteria, Recent Decisions: `STATUS Update Proposal`로 변경 섹션, 이유, 결과, 되돌리기 비용을 보고하고 승인받는다.

Proposal shape:

- 대상: Work ID 또는 STATUS section
- 변경: 무엇을 바꾸는지 한 문장
- 이유: 지금 반영해야 하는 이유
- 결과: 변경 후 상태 (`STATUS Update Proposal`에만)
- 되돌리기 비용: Low/Medium/High (`STATUS Update Proposal`에만)
- 승인 요청: 승인 후 수정 범위

## 3. Failure Rules

다음은 실패 상태다.

- STATUS 불일치를 보고하지 않음
- Plan 없이 구현
- Validation 없이 commit
- 작업 범위가 승인된 plan 밖으로 확장됨
- 동일 오류 2회 반복

실패 시:

1. 작업 중단
2. Failure type과 root cause 보고
3. Recovery options 제시
4. 사용자 승인 후 재계획

상세 기준: `docs/HARNESS-RECOVERY-VALIDATION.md`

## 4. Cascade And Tracking

문서/워크플로우 변경 후 연쇄 영향이 불명확하면 `/repo-health --cascade`로 변경 파일 유형에 맞는 canonical → tool-specific → user-facing → scaffold layer를 점검한다.
변경 파일이 없으면 `/repo-health --cascade`는 Quick 모드와 동일하게 동작한다.
전체 표면 감사가 필요하면 `/repo-health --full --cascade`를 사용한다.
`--full`에서는 **Area H (Workflow Context Weight)**가 항상 활성화한다. `--cascade`에서는 변경 surface가 workflow context/load path와 관련될 때만 활성화하며, 변경 파일 없는 `--cascade`(= Quick 모드)에서는 skip한다. Area H는 일상 workflow path(startup, /work-plan, /work-resume, /work-close, commit/PR, scaffold onboarding)가 불필요하게 heavy docs를 로드하도록 변했는지 감지한다.

핵심 trigger:

- DR-worthy accepted decision: `docs/decisions/` 기록 제안.
- commit/PR 전: STATUS Finalization(T15)과 Tracking Finalization(T16) 판정.
- structure/development flow 변경: `HARNESS-ARCHITECTURE` 또는 `HARNESS-MAINTAINER-GUIDE` 영향 확인 (optional pack — minimal scaffold에 없으면 N/A, 필요 시 `--with-optional`).
- workflow/tool/scaffold 변경: 관련 canonical workflow, adapter, rule, prompt, `.codex/hooks.json`, user-facing docs, scaffold 정렬 확인.
- scaffold 또는 canonical workflow 변경: `scripts/create-harness.sh`가 있으면 dry-run과 필요 시 temp scaffold 검증. scaffold 적용 repository처럼 script가 없으면 Skipped / Not Applicable로 보고.
- non-trivial issue resolved: `docs/troubleshooting/` 기록 제안.
- presentation/report artifact 생성: source traceability와 output path 확인.
- phase complete 또는 Work complete: STATUS/archive/tracker 정합성 확인.

## 5. Work File Decomposition

Work 파일은 큰 작업 하나의 실행 SSoT다. backlog나 STATUS를 대체하지 않는다.

아래 조건 중 둘 이상이거나 사용자가 요청하면 Work 파일 생성을 제안한다:

- 서브태스크 3개 이상
- 3개 이상 파일 또는 2개 이상 서비스/모듈 영향
- 한 세션 안에 완료 불확실
- L3 작업 또는 checkpoint 2개 이상 필요
- 다른 Agent/도구로 인계 가능성 있음

**Work 파일 섹션:** Top Summary · Context Manifest · Scope/Plan · Done Criteria · Verification · Checkpoints · Next Actions · Discovery. 상세 스펙: `docs/decisions/DR-013-work-file-spec.md`.

파일명은 `docs/works/{category}/{ID}-{lowercase-topic}.md`를 사용한다. Work ID 형식은 `<TYPE>-<YYYYMMDD>-<NNN>` (예: `CHORE-20260527-001`).
Work ID는 착수 승인 시 확정하며, backlog 후보 단계에서는 선점하지 않는다.
Work 파일은 착수 승인 후 `Active`로 생성하며, `Done`은 archive 승인 전까지 live work directory에 남을 수 있다.
archive 승인 후에는 `docs/archive/docs/works/{category}/`로 이동한다.

## 6. Naming

ID prefix와 file naming 기준은 `docs/HARNESS-NAMING-RULES.md`와 `docs/decisions/DR-008-docs-filename-standard.md`를 따른다.

## 7. Never

- 전체 repo를 먼저 스캔하지 않는다.
- 모든 문서를 한 번에 읽지 않는다.
- 파일 전체 overwrite를 기본값으로 삼지 않는다.
- 기능 추가와 리팩터링을 섞지 않는다.
- 관련 없는 최적화를 같이 하지 않는다.
