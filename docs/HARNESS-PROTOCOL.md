# Harness Protocol

이 문서는 AI Workflow Harness의 메인 허브다.
세션 중 빠른 실행 규칙은 `docs/HARNESS-QUICK-REFERENCE.md`, 상세 규칙은 `docs/harness-protocol/` 하위 문서를 따른다.
상세 규칙의 canonical source는 `docs/harness-protocol/*.md`다. 이 문서는 문서 지도와 진입점 역할을 한다.

`docs/WORKFLOW-MANUAL.md`는 사람이 읽는 사용자 매뉴얼이며, Agent 실행 규칙의 원본은 이 문서와 상세 프로토콜 문서다.

## 1. 목적

하네스의 목적은 자유로운 탐색이 아니라 상태 기반, 통제된 실행이다.

핵심 목표:

- Deterministic Execution: 같은 상태에서 같은 절차로 재개
- Stateful Workflow: `docs/STATUS.md` 중심으로 현재 상태 유지
- Controlled Execution: Plan -> Approval -> Execute -> Validate
- Failure-first Design: 실패와 복구 경로 명시
- Reversibility: 백업, checkpoint, rollback 비용 고려

## 2. 빠른 시작

1. `docs/STATUS.md`의 현재 섹션을 확인한다.
2. 작업 성격에 따라 product backlog 또는 harness backlog를 선택한다.
3. 필요한 문서만 추가 로드한다.
4. Plan을 작성하고 승인을 받는다.
5. 실행 후 가장 좁은 검증을 수행한다.
6. `STATUS.md` 갱신 필요 여부와 DR/TODO/문서 cascade를 확인한다.
7. `STATUS.md` 변경이 필요하면 `STATUS Update Proposal`을 먼저 보고하고 사용자 승인 후 수정한다.

## 3. 상태 머신

```text
INIT -> PLAN -> APPROVAL -> EXECUTE -> VALIDATE -> CHECKPOINT -> END
                 ^              |
                 |              v
              RECOVER <- FAIL <-+
```

상세: `docs/harness-protocol/01-session-state-machine.md`

## 4. 문서 지도

| 문서 | 역할 |
| --- | --- |
| `CLAUDE.md` | Claude Code 진입점, 자동 로드 |
| `AGENTS.md` | Codex 진입점 |
| `docs/AGENT-WORKFLOW.md` | 도구 공통 운영 규칙 |
| `docs/STATUS.md` | 현재 상태 live board |
| `docs/HARNESS-QUICK-REFERENCE.md` | 일상 실행 카드 |
| `docs/backlog/PHASE{n}.md` | product/Phase{n} 후보 작업 |
| `docs/backlog/HARNESS.md` | harness, command/rule, automation 후보 |
| `docs/PLAN.md` | WHY, Phase/아키텍처 근거 |
| `docs/ARCHITECTURE.md` | WHAT, 현재 구조 |
| `docs/DEVELOPER-GUIDE.md` | HOW, 개발 절차 |
| `docs/decisions/` | 결정 기록 |
| `docs/reports/` | 보고서, review package, decision brief |
| `docs/presentations/` | 발표자료, deck, slide source |
| `docs/TODO/PHASE{n}/` | 큰 작업 하나의 내부 실행 계획 |
| `docs/archive/` | 완료된 과거 상태 |

## 5. 아이템 위치 결정표

| 발생한 아이템 | 기록 위치 |
| --- | --- |
| 지금 진행 중인 작업 | `docs/STATUS.md` Active Work |
| 다음에 할 product 후보 | `docs/backlog/PHASE{n}.md` |
| Phase 진입 전 선행 작업 | `docs/backlog/PHASE{n}.md` Preparation Candidates |
| 하네스/명령/rule/hook 개선 | `docs/backlog/HARNESS.md` |
| 한 작업의 세부 실행 계획 | `docs/TODO/PHASE{n}/{BACKLOG-ID}-{topic}.md` |
| 확정된 기술 결정 | `docs/decisions/DR-*.md` |
| 발표/보고 산출물 | `docs/presentations/` 또는 `docs/reports/` |
| 미결 질문 | `docs/STATUS.md` Blockers/OQ |
| 현재 시스템 구조 | `docs/ARCHITECTURE.md` |
| 개발 절차 | `docs/DEVELOPER-GUIDE.md` |
| 완료된 Phase 이력 | `docs/archive/` |

상세: `docs/harness-protocol/03-work-items-and-naming.md`

## 6. Context Loading

항상 `STATUS.md`에서 시작하고, 작업 조건이 충족될 때만 추가 문서를 읽는다.

상세: `docs/harness-protocol/02-context-loading.md`

## 7. 문서 생명주기

문서는 CREATE -> UPDATE -> LINK -> VALIDATE -> ARCHIVE 흐름으로 관리한다.
문서가 많아질수록 고립 문서와 중복 설명을 피한다.

상세: `docs/harness-protocol/04-document-lifecycle.md`

## 8. 트리거와 Cascade

DR, archive, TODO, PLAN/ARCHITECTURE/DEVELOPER-GUIDE, workflow rule 변경은 각각 cascade 대상이 다르다.
루프 안전을 위해 trigger 결과가 같은 trigger를 즉시 재발동하지 않도록 한다.

상세: `docs/harness-protocol/05-triggers-and-cascade.md`

## 9. 복구와 검증

검증 실패, 상태 불일치, 컨텍스트 손실은 실패 상태로 보고하고 `RECOVER -> PLAN`으로 되돌린다.

상세: `docs/harness-protocol/06-recovery-and-validation.md`

## 10. 운영 원칙

- 자동 로드 문서는 작고 실행 중심으로 유지한다.
- 상세 레퍼런스는 필요 시 로드한다.
- backlog, TODO, STATUS, DR의 역할을 섞지 않는다.
- `STATUS.md`는 Agent 메모장이 아니라 승인된 현재 상태 기록이다.
- hook/CI 자동화는 manual-first 규칙이 안정화된 뒤 도입한다.
