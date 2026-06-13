# Harness Protocol

이 문서는 AI Workflow Harness의 단일 상세 프로토콜이다.
전역 행동 원칙은 `docs/BEHAVIOR-PRINCIPLES.md`를 따른다.
세션 중 빠른 실행 규칙은 `docs/HARNESS-QUICK-REFERENCE.md`, 공통 운영 규칙은 `docs/AGENT-WORKFLOW.md`, 상세 판단은 이 문서를 따른다.

Agent 실행 규칙의 원본은 `docs/BEHAVIOR-PRINCIPLES.md`, `docs/AGENT-WORKFLOW.md`, 이 문서다.
사용자가 읽는 설명 문서는 실행 규칙을 재서술하지 않고 필요한 지점에서 canonical 문서로 단방향 위임한다.

> **Optional pack 참조 주의:** `docs/HARNESS-ARCHITECTURE.md`, `docs/HARNESS-MAINTAINER-GUIDE.md`는 Optional source pack이라 minimal scaffold에는 존재하지 않을 수 있다. 이 문서가 이 둘을 가리키는 참조 항목은 해당 문서가 없으면 N/A로 처리하고, 필요하면 `scripts/create-harness.sh --with-optional`로 재생성하거나 source repo 문서를 참조한다.

## 1. Purpose

하네스의 목적은 자유로운 탐색이 아니라 상태 기반, 통제된 실행이다.

핵심 목표:

- 결정적 실행: 같은 상태에서 같은 절차로 재개
- 상태 기반 workflow: `docs/STATUS.md` 중심으로 현재 상태 유지
- Work SSoT: 작업 세부 이력은 Work 파일에 보존하고 `docs/STATUS.md`는 dashboard로 유지
- 통제된 실행: Plan -> Approval -> Execute -> Validate
- 실패 우선 설계: 실패와 복구 경로 명시
- 되돌릴 수 있는 변경: 백업, checkpoint, rollback 비용 고려

## 2. Quick Start

1. `docs/STATUS.md`의 현재 섹션을 확인한다.
2. 작업 성격에 따라 product backlog 또는 harness backlog를 선택한다.
3. 필요한 문서만 추가 로드한다.
4. Plan을 작성하고 승인을 받는다.
5. 실행 후 가장 좁은 검증을 수행한다.
6. Work 파일, `STATUS.md`, DR, archive, 문서 cascade 필요 여부를 확인한다.
7. 상태 변경이 필요하면 Approval Matrix state rules에 맞는 제안을 먼저 보고하고 사용자 승인 후 수정한다.

## 3. Document Map

| 문서 | 역할 |
| --- | --- |
| `CLAUDE.md` | Claude Code 진입점, 자동 로드 |
| `AGENTS.md` | Codex 진입점 |
| `docs/BEHAVIOR-PRINCIPLES.md` | 전역 행동 원칙 |
| `docs/AGENT-WORKFLOW.md` | 도구 공통 운영 규칙 |
| `docs/STATUS.md` | 현재 상태 live board |
| `docs/BOOTSTRAP.md` | `STATUS.md` Next Actions가 scaffold bootstrap/onboarding을 명시할 때 사용하는 project identity, production 성격, backlog, example pack setup checklist |
| `docs/SCAFFOLD-BOOTSTRAP.md` | source repository의 scaffold onboarding 설계 기준 |
| `docs/HARNESS-QUICK-REFERENCE.md` | 일상 실행 카드 |
| `docs/HARNESS-PROTOCOL.md` | Agent 실행 상세 프로토콜 |
| `docs/backlog/PRODUCT.md` | Product track 후보 작업 |
| `docs/backlog/HARNESS.md` | harness, command/rule, automation 후보 |
| `docs/PLAN.md` | WHY, Phase/아키텍처 근거 |
| `docs/HARNESS-ARCHITECTURE.md` | WHAT, 현재 아키텍처 |
| `docs/HARNESS-MAINTAINER-GUIDE.md` | HOW, 유지보수 절차 |
| `docs/decisions/` | 결정 기록 |
| `docs/reports/` | 보고서, review package, decision brief |
| `docs/presentations/` | 발표자료, deck, slide source |
| `docs/works/{category}/` | 큰 작업 단위 Work 파일 (DR-013) |
| `docs/troubleshooting/` | 증상 -> 원인 -> 조치 기록 |
| `docs/archive/` | 완료된 과거 상태 |

## 4. Session State Machine

```text
INIT -> PLAN -> APPROVAL -> EXECUTE -> VALIDATE -> CHECKPOINT -> END
                 ^              |
                 |              v
              RECOVER <- FAIL <-+
```

### State Definitions

| 상태 | 의미 | 필수 출력 |
| --- | --- | --- |
| INIT | 현재 상태 확인 | current phase, active work, blockers |
| PLAN | 작업 범위와 검증 정의 | scope, files, verification, risk, reversal cost |
| APPROVAL | 사용자 승인 대기 | "진행할까요?" |
| EXECUTE | 승인된 범위만 수행 | minimal diff |
| VALIDATE | 결과 확인 | command/result 또는 미실행 사유 |
| CHECKPOINT | 재개 가능한 저장점. Work Done 처리(`/work-close`)도 이 단계에서 수행 | approved STATUS update, commit decision |
| END | 세션 종료(`/session-summary`). Work Done 처리 없음 — Done 처리는 CHECKPOINT에서 `/work-close`로 수행 | summary, next files, residual risk |
| FAIL | 규칙 위반 또는 검증 실패 | failure type, root cause |
| RECOVER | 복구 경로 선택 | options, recommended path |

### Hard Rules

- 승인 없이 EXECUTE로 넘어가지 않는다.
- 상태 변경은 Approval Matrix의 상태 변경 규칙을 따른다.
- VALIDATE 실패 상태에서는 CHECKPOINT 또는 commit을 만들지 않는다.
- 작업 범위가 넓어지면 PLAN으로 돌아간다.
- 동일 오류가 2회 반복되면 FAIL을 보고한다.
- `Done` 상태의 작업을 계속 수정하지 않는다. 완료 후 보정은 신규 작업으로 분리한다.

## 5. Approval Matrix

| 변경 유형 | 실행 전 | 상태 변경 | commit 전 |
| --- | --- | --- | --- |
| L1 Product track surface | 간단 plan 승인 후 실행. Quick Mode 가능 | Work checkpoint/discovery는 승인 불필요. 실행 후 대상 Work ID와 변경 보고 | validation 결과, diff summary, 제안 commit message 보고 후 승인 |
| L2 harness/workflow surface 또는 설정 변경 | 상세 plan 승인 후 실행. Work 파일 사용을 기본값으로 둔다 | Work Done과 STATUS Active pointer 변경은 대상 Work ID를 명시하고 승인 후 처리 | validation 결과, diff summary, 제안 commit message 보고 후 승인 |
| L3 아키텍처·인프라·DB schema·보안 구조 | 관련 계획 또는 `docs/PLAN.md` 확인, AS-IS/TO-BE와 rollback 포함 후 승인 | Current phase/focus, Recent Decisions는 `STATUS Update Proposal` 승인 후 처리 | validation 결과, diff summary, 제안 commit message, rollback 단위 보고 후 승인 |

이 표는 `docs/AGENT-WORKFLOW.md` Approval Matrix의 상세 참조다. 변경 유형 기준이 달라지면 `docs/AGENT-WORKFLOW.md`의 compact execution gate를 먼저 맞춘다.

멀티 Active Work 환경에서는 모든 state-change proposal에 대상 Work ID를 포함한다.
각 Work는 독립 gate를 가진다.

### Approval Matrix State Detail

| 변경 대상 | 변경 유형 | Gate |
| --- | --- | --- |
| Work 파일 | Checkpoint 상태 업데이트, Discovery 추가 | 승인 불필요. 실행 후 대상 Work ID와 변경 내용을 보고 |
| Work 파일 | Done Criteria 전체 충족 확인, `status: Done`, `actual_end` 기입 | 대상 Work ID를 명시하고 사용자 확인 후 처리 |
| `docs/STATUS.md` | Active Work pointer 추가/제거 | 대상 Work ID를 명시한 1줄 제안 후 승인 |
| `docs/STATUS.md` | Current phase/focus, Recent Decisions | `STATUS Update Proposal` 승인 후 처리 |

`docs/STATUS.md`의 고영향 변경이 필요하면 파일을 수정하기 전에 아래 항목을 먼저 보고한다.

- 변경 섹션
- 변경 이유
- 변경 후 상태
- 되돌리기 비용
- 승인 요청

승인 전에는 `docs/STATUS.md`를 수정하지 않는다.

## 6. Checkpoint Rules

CHECKPOINT는 다음 세션이 재개할 수 있는 저장점이다.

필수:

- 검증 결과 또는 미실행 사유를 보고한다.
- `docs/STATUS.md` 변경 필요 여부를 판단한다.
- Work 파일 checkpoint/discovery 변경은 실행 후 대상 Work ID와 함께 보고한다.
- `docs/STATUS.md` 변경이 필요하면 Approval Matrix에 맞는 제안을 제시하고 승인받는다.

Commit:

- 작업 단위가 완료되고 사용자가 승인하면 commit 가능한 상태로 정리한다.
- commit을 수행하지 않는 경우에는 이유와 남은 risk를 종료 요약에 남긴다.
- commit 전 승인은 risk level과 무관하게 항상 별도로 받는다.

## 7. Context Loading

항상 `docs/STATUS.md`에서 시작한다.
추가 문서는 조건이 충족될 때만 읽는다.

### Operating Tracks

Product/Harness track 정의와 source repo 예외는 `docs/AGENT-WORKFLOW.md`의 `Operating Tracks`를 따른다. 이 문서는 상세 protocol 판단이 필요할 때만 조건부로 로드한다.

### Load Map

일반 세션/작업 선택 load map은 `docs/AGENT-WORKFLOW.md`의 `Context Routing`을 따른다. 이 문서는 상세 protocol 판단이 필요할 때 해당 섹션만 조건부로 로드한다.

### Anti-Patterns

- 모든 문서를 먼저 읽지 않는다.
- 모든 회고를 먼저 읽지 않는다.
- 과거 이력이 필요하지 않은데 archive를 열지 않는다.
- PLAN-SUMMARY로 충분한데 PLAN 전체를 읽지 않는다.
- 동일 문서를 반복해서 읽지 않는다.

### Retrospective Loading

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

## 8. Item Location Reference

| 발생한 아이템 | 기록 위치 |
| --- | --- |
| 지금 진행 중인 작업 | `docs/STATUS.md` Active Work |
| 다음에 할 Product track 후보 | `docs/backlog/PRODUCT.md` |
| Product track 선행/준비 작업 | `docs/backlog/PRODUCT.md` Preparation Candidates |
| 하네스/명령/rule/hook 개선 | `docs/backlog/HARNESS.md` |
| 한 작업의 세부 실행 계획 | `docs/works/{category}/{ID}-{topic}.md` |
| 확정된 기술 결정 | `docs/decisions/DR-*.md` |
| 발표/보고 산출물 | `docs/presentations/` 또는 `docs/reports/` |
| 미결 질문 | `docs/STATUS.md` Blockers/OQ |
| 현재 시스템 구조 | `docs/HARNESS-ARCHITECTURE.md` |
| 유지보수 절차 | `docs/HARNESS-MAINTAINER-GUIDE.md` |
| 완료된 Phase 이력 | `docs/archive/` |

새 항목 등록은 `/work-register`로 수행한다. 긴급도와 성격에 따라 위 위치 중 적절한 곳으로 라우팅된다.

| 긴급도 / 성격 | 라우팅 대상 |
| --- | --- |
| 지금 바로 착수 | `docs/STATUS.md` Active Work -> `/work-plan` 연결 |
| 곧 할 것 | `docs/STATUS.md` Next Actions |
| Product track 작업 | `docs/backlog/PRODUCT.md` |
| Harness 작업 | `docs/backlog/HARNESS.md` |

## 9. Naming Rules

Work ID, OQ ID, DR ID 형식, File Naming, Historical Prefix 상세 기준은 `docs/HARNESS-NAMING-RULES.md`를 따른다.
Work ID, OQ ID, DR ID 부여·검증, 파일명 규칙 확인이 필요할 때만 로드한다. `/session-start`, `/work-select`, 일반 status 확인에서는 로드하지 않는다.

## 10. Work File Decomposition

Work 파일은 아래 조건 중 둘 이상 또는 사용자 명시 요청 시 생성을 제안한다.

- 서브태스크 3개 이상
- 3개 이상 파일 또는 2개 이상 서비스/모듈 영향
- 한 세션 안에 완료 불확실
- L3 작업
- Checkpoint 2개 이상 필요
- 다른 Agent/도구로 인계 가능성 있음

Work 파일은 backlog나 STATUS를 대체하지 않는다.
Work 파일 포맷 스펙: `docs/decisions/DR-013-work-file-spec.md`

**Work Done과 phase 경계.** Work Done이 진실 단위다. Work 분해는 신규 Work ID(`<TYPE>-<YYYYMMDD>-<NNN>`)로 수행하며 `Current phase` 라벨과 무관하다. Work가 phase 경계를 가로질러도 정상이며 별도 정렬·보정 절차를 두지 않는다. phase는 descriptive optional 라벨이고 전환은 결정으로 기록한다(T3).

## 11. Quick Mode

Product track surface의 작은 L1 작업은 기본적으로 Work 파일을 만들지 않는다.
범위가 명확하고 한 세션 안에 끝나는 작업은 최종 응답, validation 결과, commit history로 충분하다.

Quick Mode 대상 예시:

- 오타·문구 수정
- 단일 파일의 작은 문서 정리
- 명확한 config 한 줄 수정
- 단일 테스트 보강
- 이미 범위가 명확하고 세션을 넘기지 않는 작은 수정

Quick Mode 비대상:

- harness/workflow surface(`entrypoint/workflow/protocol/command/rule/prompt/scaffold/status`) 변경

Harness/workflow surface를 건드리면 기본 L2로 다룬다.

다만 아래 조건 중 하나라도 있으면 L1이어도 Work 파일 생성을 고려한다.

- 세션을 넘길 가능성이 있음
- 상태 변경이 여러 단계임
- 사용자나 agent가 나중에 맥락을 복구해야 함
- 사용자가 명시적으로 별도 추적을 요청함

## 12. Work File Rules

Work 파일과 실제 저장소 상태가 충돌하면 실제 저장소 상태가 진실이다.
불일치 발견 시 Work 파일을 현행화하고 Discovery 섹션에 기록한다.

### Lifecycle

| Status | Location | Meaning |
| --- | --- | --- |
| Active | `docs/works/{category}/` | `docs/STATUS.md` Active Work에 pointer 존재 |
| Done | `docs/works/{category}/` | Done Criteria와 Verification 통과. 리뷰·참조 때문에 archive 대기 가능 |
| Archived | `docs/archive/docs/works/{category}/` | 완전 종결. 더 이상 active 참조 불필요 |

Backlog의 `Candidate` 항목은 후보 pool이다.
착수 전 분해, 조사 메모, Work 파일 필요성 판단은 backlog 항목이나 계획 제안에 남긴다.
Work 파일은 착수 승인 후 `Active` 상태로 생성한다.
`Done`과 `Archived`는 분리한다.
Work Done 처리(status: Done, actual_end, README Active->Done, STATUS pointer 제거 제안)와 선택적 archive는 `/work-close`로 수행한다.
`/work-close`는 Work Done 처리만 수행한다. commit/PR이 이어지면 별도 commit gate에서 STATUS Finalization과 Tracking Finalization을 보고한다.
`/session-summary`은 세션 요약만 출력하며 Work Done 처리를 포함하지 않는다.
Archive 이동은 사용자 명시 승인 또는 `/session-start`·`/work-resume`에서 Done 항목 발견 후 승인된 경우에 수행한다.

Review-sensitive Work는 사용자 최종 리뷰를 Done Criteria에 선택적으로 포함한다.
`/work-close`는 모든 Work에 사용자 리뷰를 강제하지 않는다. 그러나 Done Criteria에 사용자 최종 리뷰, final review, 검토 후 Done 같은 명시적 리뷰 조건이 있으면 그 조건을 충족하기 전 `status: Done`으로 전환하지 않는다.
기본 포함 후보는 harness/workflow surface, user-facing docs, rule/command, policy/operational procedure 변경이다.
Quick Mode, 단순 오타·링크·기계적 정합성 패치, 테스트·검증으로 닫히는 구현 작업은 기본 제외다.

### Index Rules

각 `docs/works/{category}/README.md`는 category별 inventory다.
권장 섹션은 Active, Done (Archive Pending), Archived다.

- Active Work 파일은 STATUS Active Work pointer와 category index Active 섹션에 모두 나타나야 한다.
- Done Work 파일은 STATUS Active Work에서 제거하고 category index Done 섹션에 둔다.
- Archived Work 파일은 `docs/archive/docs/works/{category}/`로 이동하고 category index Archived 섹션에 archive 경로를 남긴다.

이 섹션이 Work 파일 공통 운영 규칙의 권위 문서다.
개별 Work 파일은 이 규칙을 반복하지 않는다.

## 13. Document Lifecycle

```text
CREATE -> UPDATE -> LINK -> VALIDATE -> ARCHIVE
```

### Document Roles

| Document | Role |
| --- | --- |
| `docs/STATUS.md` | 현재 상태 |
| `docs/backlog/PRODUCT.md` | Product track 후보 작업 |
| `docs/backlog/HARNESS.md` | Harness 후보 작업 |
| `docs/works/{category}/` | 큰 작업 단위 Work 파일 (DR-013) |
| `docs/decisions/` | 결정 근거 |
| `docs/reports/` | 보고서, review package, decision brief |
| `docs/presentations/` | 발표자료, deck, slide source |
| `docs/HARNESS-PROTOCOL.md` | Agent 실행 상세 프로토콜 |
| `docs/PLAN.md` | WHY |
| `docs/HARNESS-ARCHITECTURE.md` | WHAT |
| `docs/HARNESS-MAINTAINER-GUIDE.md` | HOW |
| `docs/GIT-WORKFLOW.md` | Git 브랜치 전략, release gate, commit format (source repo) |
| `docs/archive/` | 완료된 이력 |
| `docs/troubleshooting/` | 증상 -> 원인 -> 조치 기록 |

### Document Role Distinction

유사해 보이는 세 파일 유형은 역할이 다르다.

| 유형 | 역할 | 기록 대상 |
| --- | --- | --- |
| `docs/decisions/DR-*.md` | 결정 근거 | 아키텍처·전략 선택의 WHY |
| `docs/retrospectives/` | 회고 | 개발 방식 자체의 평가와 개선 방향. 파일 spec: DR-027 |
| `docs/troubleshooting/` | 증상 -> 원인 -> 조치 | 원인 불명의 이슈의 재현·원인·해결 내역. 파일 spec: DR-027 |
| `docs/reports/`, `docs/presentations/` | 산출물 | 발표·보고·리뷰·의사결정 지원 자료 |

### Information Architecture Rules

`docs/`는 파일 위치보다 역할 경계가 먼저다. 이동은 참조 비용과 자동 로드 영향을 함께 검토한다.

| 분류 | 위치 | 기준 |
| --- | --- | --- |
| Canonical AI operations | `docs/BEHAVIOR-PRINCIPLES.md`, `docs/AGENT-WORKFLOW.md`, `docs/HARNESS-PROTOCOL.md`, `docs/HARNESS-QUICK-REFERENCE.md` | Agent 실행 규칙의 현재 기준 |
| Live state and trackers | `docs/STATUS.md`, `docs/backlog/`, `docs/works/`, `docs/decisions/` | 현재 상태, 후보, Work SSoT, 결정 근거 |
| Project and architecture docs | `docs/PLAN-SUMMARY.md`, `docs/PLAN.md`, `docs/HARNESS-ARCHITECTURE.md`, `docs/HARNESS-MAINTAINER-GUIDE.md`, `docs/GIT-WORKFLOW.md` (source repo only) | project/harness 구조와 유지보수 지식 |
| Historical and evaluation docs | `docs/archive/`, `docs/retrospectives/`, reference-only plans | 완료 이력, snapshot, 시점별 평가, 완료된 계획의 참조 기록 |
| Troubleshooting docs | `docs/troubleshooting/` | 증상 -> 원인 -> 조치 패턴의 재사용 가능한 incident record |
| Artifacts | `docs/reports/`, `docs/presentations/` | `/work-doc` 산출물. source traceability와 version naming 유지 |
| Media assets | root 또는 관련 문서 인접 위치 | 기존 asset은 참조 안정성을 우선하고, 신규 asset은 관련 문서 옆에 둔다 |

### Update Rules

- 현재 상태가 바뀌면 `STATUS.md` 갱신 여부를 확인한다.
- 구조가 바뀌면 `HARNESS-ARCHITECTURE.md` 업데이트를 제안한다.
- 유지보수 절차가 바뀌면 `HARNESS-MAINTAINER-GUIDE.md` 업데이트를 제안한다.
- 결정 근거가 생기면 DR 생성을 제안한다.
- 완료된 Phase 상세는 archive로 이동한다.
- 원인 불명의 이슈(환경 문제, 불명확한 원인)가 해결되면 `docs/troubleshooting/`에 기록을 제안한다.
- 회고가 필요한 시점(세션 마무리, Phase 완료, 인시던트 해결 후)에는 `docs/retrospectives/`에 기록을 제안한다.
- 발표/보고 산출물을 만들 때는 목적, audience, source, format, 검증 기준을 먼저 확정한다.

### Pruning and Archive Policies

#### Backlog Items

backlog 항목의 Status가 Done 또는 Superseded가 되면 다음 기준으로 제거한다.

| 조건 | 처리 |
| --- | --- |
| Done — Work Done 처리 완료 (→ `/work-close` Step 5) | backlog 파일에서 해당 행 삭제 |
| Done — Work 파일 없음 (Quick Mode) | Phase 완료 또는 다음 harness review 시 삭제 |
| Superseded | 즉시 삭제 가능 |

삭제된 항목의 상세는 git history와 Work 파일(archive)에 남는다. backlog에 별도 archive를 만들지 않는다.

삭제된 항목을 찾으려면:
- Work 파일이 있는 항목 → `docs/works/harness/README.md` Archived 테이블 → `docs/archive/docs/works/harness/`
- Work 파일이 없는 항목 (Quick Mode 완료) → `git log --grep="{ID}"`

#### Decision Records (DR)

| 상태 | 처리 |
| --- | --- |
| Accepted | `docs/decisions/`에 유지 |
| Superseded / Deprecated | `docs/archive/docs/decisions/`로 `git mv` |

cascade 감사 시 `docs/decisions/README.md` 인덱스의 Accepted DR만 확인한다. archive로 이동된 DR은 감사 대상에서 제외한다.

#### Retrospectives

| 조건 | 처리 |
| --- | --- |
| 연관 Work/Phase가 archive되고 insights가 canonical 문서에 반영됨 | `docs/archive/docs/retrospectives/`로 `git mv` (사용자 승인 후) |
| 활성 작업 또는 미결 OQ와 연관 있음 | live 유지 |

cascade 감사 시 `docs/retrospectives/README.md` 인덱스를 참조하여 최신 1개 또는 해당 topic 관련 1개만 확인한다. 전체 목록 스캔은 하지 않는다.

#### Index Pairing Rule

`README.md` 인덱스가 있는 디렉토리에 파일을 추가하거나 이동할 때는 해당 인덱스를 함께 갱신한다.
대상 디렉토리: `docs/decisions/`, `docs/retrospectives/`, `docs/troubleshooting/`, `docs/works/{category}/` 등 `README.md`가 존재하는 모든 디렉토리.
archive 이동 시에는 원본 인덱스에서 행을 제거하고, archive 디렉토리 인덱스(`docs/archive/docs/*/README.md`)에 추가한다.

### Validation

- 새 문서는 `STATUS.md`, harness protocol, 또는 관련 backlog에서 참조되어야 한다.
- 같은 설명을 자동 로드 문서와 상세 문서에 길게 중복하지 않는다.
- 문서와 실제 파일이 충돌하면 실제 파일을 우선한다.
- 발표/보고 산출물은 source traceability, audience fit, narrative, slide/page count, render/preview 가능 여부를 확인한다.
- 문서 신규 작성 또는 섹션 추가 시 DR-007 Bilingual Rules를 적용한다.

## 14. Triggers and Cascade

### Trigger Family Quick Reference

| Family | Trigger IDs | 용도 |
| --- | --- | --- |
| Decision | T1, T2 | DR 생성·정리 |
| Planning | T3, T4, T5 | phase 전환·작업 분해·PLAN 영향 |
| Surface | T6, T7, T11, T12, T13, T14 | 문서·구조·command·tool·scaffold 변경 |
| Record | T8, T8b, T9 | troubleshooting·회고·산출물 |
| Lifecycle | T10 | Work Done 상태 발견 |
| Finalization | T15, T16, T17 | commit/PR 전 STATUS·tracker·/work-close |

### Trigger Summary

| ID | Trigger | Result |
| --- | --- | --- |
| T1 | DR-worthy decision accepted | DR 생성 제안 |
| T2 | DR 삭제/통합/Superseded | STATUS/backlog/summary 참조 정리 |
| T3 | phase/milestone 전환 선언 (de-formalized) | STATUS Recent Decisions 기록 + (해당 시) STATUS/PLAN archive drain + T5 PLAN 영향 확인 |
| T4 | 큰 작업 분해 필요 | Work 파일 생성 제안 (§10 기준). 분해는 신규 Work ID — phase와 무관 |
| T5 | PLAN 영향 결정 | PLAN/summary/rules 관련 문서 확인 |
| T6 | 구조/흐름 구현 변경 | HARNESS-ARCHITECTURE/HARNESS-MAINTAINER-GUIDE 확인 |
| T7 | workflow rule/command 변경 | `docs/HARNESS-PROTOCOL.md` 업데이트 |
| T8 | 원인 불명의 이슈 해결 | `docs/troubleshooting/` 기록 제안. DR-027 frontmatter 스펙 적용 |
| T8b | 세션·Phase·이슈 회고 필요 | `docs/retrospectives/` 기록 제안. DR-027 frontmatter 스펙 적용 |
| T9 | 발표/보고 산출물 생성 | source traceability, output path, STATUS/backlog 참조 필요 여부 확인 |
| T10 | Work 파일 Done 상태 발견 | archive 승인 여부 제안 |
| T11 | tool surface 변경 | Claude(`.claude/commands/`, `.claude/rules/`)/Codex(`.agents/skills/`, `.codex/hooks.json`)/Cursor(`.cursor/rules/`)/`prompts/`/README/scaffold 정렬 확인 |
| T12 | scaffold source 또는 canonical workflow 변경 | `scripts/create-harness.sh`가 있으면 dry-run + temp scaffold 검증, 없으면 source scaffold 검증 제외. template-level policy 변경은 소형 maintenance release 후보로 취급한다 — main merge 전까지 downstream consumer에게 drift window가 발생하므로 변경 범위와 release timing을 함께 판단한다. |
| T13 | Product track surface Quick Mode L1 변경 | no Work/no STATUS 기본 |
| T14 | Harness/workflow surface 변경 | 기본 L2로 scope/cascade 확인 |
| T15 | commit 또는 PR 생성 전 | `docs/STATUS.md` 최종본 반영 필요 여부 판정 |
| T16 | commit 또는 PR 생성 전 | backlog/Work/DR tracker 최종 상태 반영 필요 여부 판정 |
| T17 | commit 또는 PR 생성 전, Active Work의 Done Criteria 전 항목 `[x]` 확인 | `/work-close` 선제 제안 — 상태 변경(Work Done, Work Index, STATUS pointer)을 같은 commit에 번들하기 위함 |

### Loop Safety

- T4는 STATUS 참조만 갱신하고 다른 trigger를 발동하지 않는다.
- T7 결과는 다시 T7을 발동하지 않는다.
- T9 결과물은 source 문서를 수정하지 않는다. source 변경이 필요하면 별도 작업으로 분리한다.
- T5와 T6가 같은 문서를 건드릴 때는 한쪽은 수정, 다른 쪽은 확인만 한다.
- DR Draft는 Accepted 전까지 PLAN cascade를 발동하지 않는다.
- T8/T8b는 기록 제안만 수행한다. 원인 분석이나 해결을 자동으로 시작하지 않는다.
- T10은 archive 제안만 수행한다. 사용자 승인 전 `git mv`를 실행하지 않는다.
- T11은 관련 tool surface를 확인 대상으로 추가하지만 자동 수정하지 않는다. 발견 -> 제안 -> 승인 순서를 따른다.
- T12는 `scripts/create-harness.sh`가 있는 source repository에서만 temp target 검증을 수행하고 생성물을 live tree로 복사하지 않는다. scaffold 적용 repository처럼 script가 없으면 Skipped / Not Applicable로 보고한다.
- T13은 Product track surface의 작은 작업을 빠르게 닫기 위한 규칙이다.
- T14는 entrypoint/workflow/protocol/command/rule/prompt/scaffold/status 변경을 기본 L2로 다루며, 관련 tool surface를 확인한다.
- T15는 자동 STATUS 수정을 허용하지 않는다. Active Work pointer, Current phase/focus, Blockers/OQ, Next Actions, Recent Decisions, Active Work Discovery 최신성을 확인한다. 필요하면 Approval Matrix에 맞는 state-change proposal 또는 `STATUS Update Proposal`을 먼저 제안하고, 불필요하면 commit/PR 전 summary에 이유를 남긴다.
- T16은 backlog/Work/DR tracker를 실제 완료 상태와 맞추는 gate다. 연결된 backlog 항목의 Status/Done Criteria/Verification, Work 파일 frontmatter/status/Checkpoints/Discovery, Work index README 위치, 관련 DR의 Status/Supersedes/Linked Backlog Items, 완료된 Quick Mode 작업이 backlog Candidate로 남아 있는지 여부를 확인한다.
- T17은 `/work-close` 제안만 수행한다. 사용자가 거부하거나 분리를 원하면 기존 commit 흐름대로 진행한다.
- T15/T16/T17(commit/PR 전 finalization)과 T3(phase transition), `/work-close`(Work closeout), `/work-plan`(착수), `/record-decision`(DR 등록)은 **T5(PLAN 영향 판단)**를 함께 확인한다. PLAN 영향이 있으면 Approval Matrix proposal, 없으면 보고만 한다. PLAN 작성 완료를 hard-stop으로 강제하지 않는다(recommended/warning). PLAN 변경이 있으면 `docs/PLAN-SUMMARY.md` stale 여부도 함께 판정한다(PLAN-SUMMARY는 derived summary — 자체 이력 누적 않음). PLAN lifecycle/archive-drain 규칙의 SSoT는 `docs/PLAN.md`의 Roadmap Lifecycle 규칙이며, 여기서는 trigger pointer만 둔다.
- **누적 드리프트 경고:** archive 대기 Done Work가 5개 이상일 때, `/session-start`와 `/work-close`는 개별 T5 판정과 별개로 PLAN 누적 드리프트 가능성을 soft warning으로 보고한다. 각 Work의 T5가 "영향 없음"이어도 여러 완료가 쌓이면 PLAN이 현실과 멀어질 수 있다(이벤트 단위 T5의 구조적 한계).

### Cascade Rule

Cascade는 자동 실행이 아니라 제안과 검증 대상이다.
파일 수정은 사용자 승인 또는 명시 요청 후 진행한다.
`/repo-health --cascade`는 changed-surface cascade audit으로 사용한다.
감사 범위는 변경 파일 유형에 맞는 canonical -> tool-specific -> user-facing -> scaffold 계층으로 제한하되, 선택된 계층의 required surface, grep, simulation은 생략하지 않는다. 전체 표면 감사가 필요하면 `/repo-health --full --cascade`를 사용한다.
변경 파일이 없으면 `/repo-health --cascade`는 Quick health mode와 동일하게 동작한다.
`--cascade` 대상이 workflow context/load path 관련 파일이면 Area H (Workflow Context Weight)도 활성화한다.

**Shipped DR reference closure.** core canonical 문서·shipped DR seed 파일·adapter/rule/prompt에 `DR-NNN` 인용을 추가·변경하면, 그 DR이 scaffold seed(`scripts/create-harness.sh` 기본 adapt 블록)에 닫혀 있는지 확인한다. seed 밖이면 canonical 문서는 self-describe(번호 없이 서술), DR 파일 lineage는 `Linked DRs:` frontmatter에만 둔다. `bash scripts/tests/check-shipped-dr-closure.sh`로 검증한다(정책 상세는 `docs/HARNESS-RECOVERY-VALIDATION.md` 및 source-only `docs/maintainer/VERIFICATION-COMMANDS.md`. source repo 전용 — adopter repo에는 N/A).

| Level | Action | Meaning |
| --- | --- | --- |
| A | 확인만 | 관련 문서를 읽거나 검색해 영향 없음 확인 |
| B | 발견 보고 | drift 또는 누락을 보고하고 수정 필요 여부 제안 |
| C | 승인 후 수정 | 사용자가 승인한 범위에서 관련 파일 수정 |
| D | 별도 Work/DR 분리 | 범위가 커지거나 reversal cost가 Medium 이상이면 별도 추적 |

### Tool Surface Cascade Matrix

| 변경 대상 | 반드시 확인할 표면 |
| --- | --- |
| `docs/AGENT-WORKFLOW.md`, `docs/HARNESS-PROTOCOL.md` | `skills/workflow/`, `AGENTS.md`, `CLAUDE.md`, `.claude/commands/`, `.claude/rules/`, `.cursor/rules/`, `.agents/skills/`, `.codex/hooks.json`, `prompts/`, `scripts/create-harness.sh`가 있으면 scaffold source |
| `skills/workflow/*.md` | `.claude/commands/` adapter, `.agents/skills/workflow-{name}/SKILL.md` adapter, `.cursor/rules/workflow.mdc`, `prompts/*session-start.md`, `docs/HARNESS-QUICK-REFERENCE.md`, `scripts/create-harness.sh`가 있으면 scaffold source |
| `.claude/commands/*.md` | `skills/workflow/{name}.md`, `AGENTS.md` skill routing pointer, `.agents/skills/workflow-{name}/SKILL.md`, `.cursor/rules/workflow.mdc`, `prompts/*session-start.md`, `docs/HARNESS-QUICK-REFERENCE.md` |
| `.agents/skills/*/SKILL.md` | `skills/workflow/{name}.md`, `.claude/commands/` 대응 파일, `AGENTS.md` skill routing pointer |
| `.claude/rules/*.md` 또는 `.cursor/rules/*.mdc` | 반대 tool rule, `docs/AGENT-WORKFLOW.md`, `docs/HARNESS-PROTOCOL.md` |
| `.codex/hooks.json` | `AGENTS.md`, `docs/HARNESS-PROTOCOL.md` hook 관련 섹션 |
| `prompts/*session-start.md` | `prompts/README.md`, `AGENTS.md`, `CLAUDE.md`, relevant command/rule |
| `scripts/create-harness.sh`가 존재할 때 | `docs/SCAFFOLD-BOOTSTRAP.md`와 Boot Sequence·Completion Rule 동기화 확인, generic/spring-boot dry-run, temp scaffold 생성 결과, scaffold 내부 stale phrase 검색 |
| `docs/SCAFFOLD-BOOTSTRAP.md` | `scripts/create-harness.sh`가 있으면 생성 BOOTSTRAP.md 템플릿과 Boot Sequence·Completion Rule 정합성 확인, 없으면 source repo 전용 기준으로 표시 |
| `docs/decisions/DR-*.md` Accepted | `docs/STATUS.md` Recent Decisions 필요 여부 필수 판정, 관련 backlog/Work 파일, PLAN 영향 여부 |
| maintainer-facing docs (`README.md`, `HARNESS-MAINTAINER-GUIDE.md`) | 실제 config/script/source와 기술 내용 대조 |
| `docs/` 하위 디렉토리 신규 추가 또는 삭제 | T5(PLAN 영향 여부), T7(harness protocol 업데이트 필요 여부), Context Routing 갱신 여부, `scripts/create-harness.sh`가 있으면 scaffold 동기화 여부 확인 |

### STATUS.md Section Deletion Cascade Checklist

STATUS.md 항목 삭제 또는 이동 전 해당 섹션의 체크리스트를 확인한다.
모든 STATUS.md 변경은 Approval Matrix state rules에 맞는 제안 -> 사용자 승인 후 수행한다.

| 섹션 | 삭제/이동 전 확인 사항 |
| --- | --- |
| Active Work | 연결된 Work 파일과 backlog 항목(`PRODUCT.md` 또는 `HARNESS.md`) 상태 업데이트 필요 여부 확인 |
| Work files | Work archive는 개별 Work Done 기준(`/work-close`)으로 처리하며 phase 경계와 무관하다. phase/milestone 전환을 선언할 때(T3) 닫힌 milestone 관련 PLAN 상세 drain은 `docs/PLAN.md`의 Roadmap Lifecycle 규칙을 따른다 |
| Blockers / Open Questions | Closed OQ에 연결된 DR이 있으면 DR Status -> Accepted 처리 여부 확인 |
| Next Actions | 연결된 backlog 항목이 있으면 항목 완료 상태 일치 여부 확인 |
| Recent Decisions | **삭제 금지** — 최근 8개 rolling window 유지. 초과분 제거 전 DR-worthy 항목이면 대응 DR 존재 여부 확인. 단순 완료 사실은 Active Work pointer, Work 파일 Checkpoints, commit history에 둔다. |

## 15. Failure And Recovery

Failure Conditions, Recovery Flow, Validation Checklist, Commit Approval, CI/Manual/Hook 책임 경계는 `docs/HARNESS-RECOVERY-VALIDATION.md`를 따른다.
failure state 진입, validation failure 판단, commit approval 확인 시에만 로드한다.

## 16. Operating Principles

- 자동 로드 문서는 작고 실행 중심으로 유지한다.
- 상세 레퍼런스는 필요 시 로드한다.
- backlog, Work 파일, STATUS, DR의 역할을 섞지 않는다.
- `STATUS.md`는 Agent 메모장이 아니라 승인된 현재 dashboard다.
- Work 파일은 작업 단위의 Top Summary, Context Manifest, Scope/Plan, Done Criteria, Verification, Checkpoints, Next Actions, Discovery를 보존하는 SSoT다. 섹션 스펙: `docs/decisions/DR-013-work-file-spec.md`.
- hook/CI 자동화는 manual-first 규칙이 안정화된 뒤 도입한다.
- 조건부로만 실행되는 상세 절차·체크리스트가 core 문서에 축적되면 slice 파일로 분리하고 조건부 pointer로 교체한다.

## 17. Parallel Work Conflict Resolution

병렬 branch/agent 운영 중 충돌이 실제 발생하거나 충돌 위험이 감지될 때만 로드하는 조건부 runbook이다.
Work ID, STATUS/index, DR sequence, command/skill mirror, scaffold release-timing 충돌 상황에서만 `docs/HARNESS-PARALLEL-WORK-CONTROLS.md`를 로드한다.
