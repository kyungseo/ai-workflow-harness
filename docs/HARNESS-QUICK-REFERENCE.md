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

## 2. State Machine

```text
INIT -> PLAN -> APPROVAL -> EXECUTE -> VALIDATE -> CHECKPOINT -> END
                 ^              |
                 |              v
              RECOVER <- FAIL <-+
```

- **CHECKPOINT** = 검증 결과, Work 파일 checkpoint/discovery, STATUS state-change 필요 여부를 보고하는 재개 지점.
- **END (`/done`)** = 세션 종료 시에만 실행. 작업마다 호출하지 않는다. Work Done 처리는 포함하지 않는다 — Work를 완료하려면 `/close`를 먼저 실행한다.
- **`/close`** = Work Done 처리 전용. 세션 종료 없이 Work 완료 처리(Done Criteria 확인 → status/actual_end 기입 → README Active→Done → STATUS pointer 제거 제안 → 선택적 archive). commit/PR이 이어지면 별도 commit gate에서 STATUS/Tracking Finalization을 보고한다. 실행 후 세션 계속.
- Review-sensitive Work는 사용자 최종 리뷰를 Done Criteria에 선택 포함한다. `/close`는 전역 리뷰를 강제하지 않지만, Done Criteria에 명시된 리뷰 조건은 Done 처리 전 반드시 확인한다.

### Command Taxonomy

| 범주 | 명령 | 끝내는 것 |
| --- | --- | --- |
| Session lifecycle | `/start`, `/pick`, `/done` | 세션 상태 파악, 다음 작업 선택, 세션 요약 |
| Work lifecycle | `/work`, `/resume`, `/close` | Work 착수, Work 재개, Work Done 처리 |
| Utility / Analysis | `/register`, `/debug`, `/doc`, `/record-decision`, `/health` | 항목 등록, 문제 분석, 산출물 생성, 결정 기록, 상태 점검 |

## 3. Work Item Registration

새 작업 항목이 생기면 `/register`로 등록한다.

| 긴급도 / 성격 | 등록 위치 |
| --- | --- |
| 지금 바로 착수 (긴급 패치 등) | `docs/STATUS.md` Active Work → `/work`로 연결 |
| 곧 할 것 | `docs/STATUS.md` Next Actions |
| Product track / Phase{n} 작업 | `docs/backlog/PHASE{n}.md` |
| Harness / workflow / rule 개선 | `docs/backlog/HARNESS.md` |

STATUS.md 변경이 포함되면 Approval Matrix의 상태 변경 규칙에 따라 먼저 제안하고 승인받는다.

## 4. Execution Gate

구현 또는 문서 변경 전 plan을 먼저 제시한다.

Plan에는 다음 항목을 포함한다:

- Scope
- Files
- Verification
- Risk
- Reversal cost

승인 없이 구현하지 않는다.

### Approval Matrix

Work 파일은 작업 SSoT이고 `docs/STATUS.md`는 dashboard다.
실행 전 승인, 상태 변경, commit 전 승인을 같은 표로 판단한다.

| 변경 유형 | 실행 전 | 상태 변경 | commit 전 |
| --- | --- | --- | --- |
| L1 Product track surface | 간단 plan 승인 후 실행. Quick Mode 가능 | Work checkpoint/discovery는 승인 불필요. 실행 후 대상 Work ID와 변경 보고 | validation 결과, diff summary, 제안 commit message 보고 후 승인 |
| L2 harness/workflow surface 또는 설정 변경 | 상세 plan 승인 후 실행. Work 파일 기본 | Work Done과 STATUS Active pointer 변경은 대상 Work ID를 명시하고 승인 후 처리 | validation 결과, diff summary, 제안 commit message 보고 후 승인 |
| L3 구조 변경 | AS-IS/TO-BE, rollback 포함 후 승인 | Phase/focus/criteria/Recent Decisions는 `STATUS Update Proposal` 승인 후 처리 | validation 결과, diff summary, 제안 commit message, rollback 단위 보고 후 승인 |

- 사용자가 명시적으로 승인한 뒤에만 `docs/STATUS.md`를 수정한다.
- 이미 승인된 plan에 구체적인 `STATUS.md` 변경 범위가 포함되어 있으면 그 승인으로 갈음할 수 있다.
- 작업 중 예상 밖의 `STATUS.md` 변경 필요가 생기면 다시 승인받는다.
- Recent Decisions는 최근 8개 rolling window만 유지하고, 후속 행동을 바꾸는 운영/기술 판단만 둔다.
- Recent Decisions 초과분 제거 전 DR-worthy 항목이면 대응 DR 존재 여부를 확인한다.

`Done` 상태의 작업은 다시 수정하지 않는다. 완료 후 보정이 필요하면 신규 작업으로 분리한다.
`Done` Work 파일은 archive 승인 전까지 `docs/works/{category}/`에 남을 수 있다.

## 5. Risk Level

| Level | Examples | Rule |
| --- | --- | --- |
| L1 Safe | Product track 문서 소폭 수정, 테스트, 국소 버그 수정 | Approval Matrix L1 |
| L2 Normal | 기능 구현, 설정 변경, hook 추가, harness/workflow surface 변경 | Approval Matrix L2 |
| L3 Critical | 아키텍처, 보안, 인프라, DB schema, harness 구조 | Approval Matrix L3 |

### Quick Mode

Product track surface의 작은 L1 작업은 기본적으로 Work 파일 없이 처리한다.
최종 응답, validation 결과, commit history가 기록 역할을 한다.

Quick Mode는 아래 조건에서 적합하다.

- 단일 파일 또는 매우 좁은 범위
- 한 세션 안에 완료 가능
- 별도 checkpoint나 인계 필요 없음
- STATUS.md 변경 없음
- harness/workflow surface 변경 없음

Harness/workflow surface(`entrypoint/workflow/protocol/command/rule/prompt/scaffold/status`)를 건드리면 기본 L2로 다룬다.

## 6. Validation

완료 전 확인:

- STATUS 최신성
- 변경 파일 범위
- Verification 실행 또는 미실행 사유
- 문서 링크 정합성
- DR 필요 여부
- Approval Matrix에 따른 STATUS state-change 필요 여부
- commit/PR 전 STATUS 최종본 반영 필요 여부
- commit/PR 전 backlog/Work/DR tracker 최종 상태 반영 필요 여부

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

## 7. Failure Rules

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

## 8. Cascade And Tracking

문서/워크플로우 변경 후 연쇄 영향이 불명확하면 `/health --cascade`로 변경 파일 유형에 맞는 canonical → tool-specific → user-facing → scaffold layer를 점검한다.
변경 파일이 없으면 `/health --cascade`는 Quick 모드와 동일하게 동작한다.
전체 표면 감사가 필요하면 `/health --full --cascade`를 사용한다.

핵심 trigger:

- DR-worthy accepted decision: `docs/decisions/` 기록 제안.
- commit/PR 전: STATUS Finalization(T15)과 Tracking Finalization(T16) 판정.
- structure/development flow 변경: `HARNESS-STRUCTURE` 또는 `HARNESS-MAINTAINER-GUIDE` 영향 확인.
- workflow/tool/scaffold 변경: 관련 command/rule/prompt/`.agents/skills/`/`.codex/hooks.json`/manual/scaffold 정렬 확인.
- scaffold 또는 canonical workflow 변경: `create-harness.sh --dry-run`과 필요 시 temp scaffold 검증.
- non-trivial issue resolved: `docs/troubleshooting/` 기록 제안.
- presentation/report artifact 생성: source traceability와 output path 확인.
- phase complete 또는 Work complete: STATUS/archive/tracker 정합성 확인.

## 9. Work File Decomposition

Work 파일은 큰 작업 하나의 실행 SSoT다. backlog나 STATUS를 대체하지 않는다.

아래 조건 중 둘 이상이거나 사용자가 요청하면 Work 파일 생성을 제안한다:

- 서브태스크 3개 이상
- 3개 이상 파일 또는 2개 이상 서비스/모듈 영향
- 한 세션 안에 완료 불확실
- L3 작업 또는 checkpoint 2개 이상 필요
- 다른 Agent/도구로 인계 가능성 있음

파일명은 `docs/works/{category}/{ID}-{lowercase-topic}.md`를 사용한다.
Work 파일은 착수 승인 후 `Active`로 생성하며, `Done`은 archive 승인 전까지 live work directory에 남을 수 있다.
archive 승인 후에는 `docs/archive/docs/works/{category}/`로 이동한다.

## 10. Naming

ID prefix와 file naming 기준은 `docs/HARNESS-PROTOCOL.md`와 `docs/decisions/DR-008-docs-filename-standard.md`를 따른다.

## 11. Never

- 전체 repo를 먼저 스캔하지 않는다.
- 모든 문서를 한 번에 읽지 않는다.
- 파일 전체 overwrite를 기본값으로 삼지 않는다.
- 기능 추가와 리팩터링을 섞지 않는다.
- 관련 없는 최적화를 같이 하지 않는다.
