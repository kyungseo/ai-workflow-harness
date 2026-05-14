# STATUS.md

Claude Code를 위한 현재 프로젝트 상태 문서다.
이 파일은 짧게 유지하고, 완료된 Phase의 상세 이력은 `docs/archive/`로 옮긴다.

Last updated: 2026-05-15 (하네스 리팩터링 리뷰 패키지 작성 및 세션 종료 준비)

## Current State

| Field | Value |
| --- | --- |
| Current phase | Phase 2 pre-entry |
| Current focus | Phase2 pre-entry planning |
| Phase 1 | Complete |
| Active plan | `docs/HARNESS-REFACTOR-PLAN.md` |
| Product backlog | `docs/backlog/PHASE2.md` |
| Harness backlog | `docs/backlog/HARNESS.md` |
| Quick reference | `docs/HARNESS-QUICK-REFERENCE.md` |
| Harness protocol | `docs/HARNESS-PROTOCOL.md` |
| User workflow manual | `docs/WORKFLOW-MANUAL.md` |
| Pre-refactor backup | `docs/archive/harness-refactor-20260514/` |
| Phase 1 status archive | `docs/archive/phase1-status.md` |
| Phase 1 plan archive | `docs/archive/phase1-plan.md` |

## Work Context Rule

이 파일은 현재 작업 상태의 단일 기준이다. 단, 문서와 실제 파일 상태가 충돌하면 실제 파일 상태를 우선한다.

실행 흐름:

```text
INIT -> PLAN -> APPROVAL -> EXECUTE -> VALIDATE -> CHECKPOINT -> END
                 ^              |
                 |              v
              RECOVER <- FAIL <-+
```

세션 시작 시에는 이 파일의 `Current State`, `Active Work`, `Checkpoints`, `Blockers And Open Questions`, `Next Actions`만 확인한다.
Phase1 또는 Phase2 이전 계획의 상세 맥락은 필요할 때만 백업과 archive에서 확인한다.

## Active Work

| ID | Priority | Status | Risk | Scope | Done Criteria | Verification |
| --- | --- | --- | --- | --- | --- | --- |
| HRF-001 | P0 | Done | L3 | Phase1 이후 하네스를 경량 상태 머신 기반 운영 체계로 재편 | 백업 완료, STATUS 재정의, product/harness backlog 분리, Quick Reference 생성 | 문서 링크 확인, backlog 분리 확인, orphan 문서 없음 |

## Checkpoints

| Checkpoint | Purpose | Status | Verification |
| --- | --- | --- | --- |
| CP-HRF-1 | 기존 상태 백업 | Done | `docs/archive/harness-refactor-20260514/MANIFEST.md` 및 snapshot 파일 확인 |
| CP-HRF-2 | 현재 운영 상태 재정의 | Done | `docs/STATUS.md`가 현재 focus, active work, next action만 담는지 확인 |
| CP-HRF-3 | Product backlog와 Harness backlog 분리 | Done | `docs/backlog/PHASE2.md`, `docs/backlog/HARNESS.md` 확인 |
| CP-HRF-4 | 일상 실행 규칙 Quick Reference 생성 | Done | `docs/HARNESS-QUICK-REFERENCE.md` 확인 |
| CP-HRF-5 | Harness protocol 연결 | Done | `docs/HARNESS-PROTOCOL.md`와 `docs/harness-protocol/` 링크 확인 |
| CP-HRF-6 | WORKFLOW-MANUAL.md 사용자 매뉴얼 역할 현행화 | Done | manual/protocol 역할 분리, T7 cascade 대상, context load 기준 확인 |
| CP-HRF-7 | WORKFLOW-MANUAL.md Mermaid 다이어그램 현행화 | Done | 디렉토리 구조, 문서 생태계, 세션 생애주기, 실행 흐름, context load, DR lifecycle 다이어그램 확인 |
| CP-HRF-8 | WORKFLOW-MANUAL.md 신규 프로젝트 초기화 절차 현행화 | Done | protocol/quick reference/detail docs, product/harness backlog, command 목록, 초기 검증 흐름 확인 |
| CP-HRF-9 | README/prompts/product docs 정합성 현행화 | Done | README 링크 허브화, prompts routing 현행화, product docs의 CI/Testcontainers/Dockerfile/라이선스 표현 확인 |
| CP-HRF-10 | 하네스 리팩토링 자체 평가 회고 기록 | Done | `docs/retrospectives/harness-evaluation-20260514.md` 생성 |
| CP-HRF-11 | Codex 세션 시작 프롬프트 추가 | Done | `prompts/codex-session-start.md` 생성, `prompts/README.md`와 `docs/backlog/HARNESS.md` 참조 반영 |
| CP-HRF-12 | 반복 세션 시뮬레이션 정합성 보정 | Done | product/harness routing, legacy TODO 표기, document lifecycle 역할 표기 확인 |
| CP-HRF-13 | STATUS Update Approval Gate 반영 | Done | `docs/CLAUDE.md`, `docs/HARNESS-QUICK-REFERENCE.md`, `docs/harness-protocol/`, commands/prompts/rules에 STATUS Update Proposal 규칙 확인 |
| CP-HRF-14 | Claude command/rule flow 정합성 보정 | Done | `.claude/commands/`, `.claude/rules/`, Cursor rules의 plan/approval/validation/status/commit gate 확인 |
| CP-HRF-15 | ignore/permission 정합성 보정 | Done | `.claudignore` → `.claudeignore` rename, `.cursorignore`, `.claude/settings.json` permissions.deny 확인 |
| CP-HRF-16 | protocol routing과 canonical source 보정 | Done | `docs/CLAUDE.md`, `docs/HARNESS-PROTOCOL.md`, `docs/HARNESS-QUICK-REFERENCE.md`, `docs/harness-protocol/*.md` 역할 확인 |
| CP-HRF-17 | retrospective conditional loading 반영 | Done | `/pick`, `/work`, `docs/CLAUDE.md`, `docs/harness-protocol/02-context-loading.md`에 회고 조건부 로드 규칙 확인 |
| CP-HRF-18 | 최종 반복 세션·다중 Agent 시뮬레이션 | Done | Claude/Codex/Cursor 시작·선택·계획·검증·종료·재개 흐름과 residual risk 확인 |
| CP-HRF-19 | 하네스 리팩터링 리뷰 패키지 작성 | Done | `docs/retrospectives/harness-refactor-review-request-20260515.md` 생성 및 `git diff --check` 확인 |

## Blockers And Open Questions

| ID | Status | Question | Decision Needed |
| --- | --- | --- | --- |
| HRF-OQ-001 | Closed | 기존 Phase2 작업, 체크포인트, DR을 백업하고 백지 재편할 것인가? | 백업 후 재편하기로 결정 |
| HRF-OQ-002 | Closed | `HRN-*`을 Phase2 product backlog에서 분리할 것인가? | `docs/backlog/HARNESS.md`로 분리 |
| HRF-OQ-003 | Open | `.harness/config.json` 같은 SSOT config를 지금 도입할 것인가? | Manual-first 안정화 후 재검토 |
| HRF-OQ-004 | Closed | `docs/CLAUDE.md`, `.claude/commands`, `.claude/rules`를 1차 재편에서 수정할 것인가? | product/harness backlog 분리와 상태 머신 게이트를 최소 반영 |
| HRF-OQ-005 | Open | 한국어 문서에서 섹션명·하네스 용어·기술 용어를 어느 정도 영어로 유지할 것인가? | 리뷰 문서와 DR-007 언어 정책을 함께 보며 후속 정리 |

## Recent Decisions

| Date | Decision | Reason | Reversal Cost |
| --- | --- | --- | --- |
| 2026-05-14 | Phase1 이후 현재 작업·예정 작업·체크포인트·DR을 백업하고 하네스 상태를 백지 재편 | Phase2 기능 개발과 Harness 개선 상태가 섞여 있어 재개 기준이 흐려짐 | Low |
| 2026-05-14 | `STATUS.md`를 Harness Refactor 중심의 live board로 축소 | 세션 시작 시 현재 focus와 next action을 빠르게 복원하기 위함 | Low |
| 2026-05-14 | `HRN-*` 항목을 `docs/backlog/HARNESS.md`로 분리 | Product backlog와 Harness lifecycle이 다름 | Low |
| 2026-05-14 | `docs/CLAUDE.md`, `.claude/commands`, `.claude/rules/docs-workflow.md`에 상태 머신과 backlog 분리 규칙 반영 | 실제 Agent 실행 규칙이 새 하네스 구조를 따르도록 정렬 | Low |
| 2026-05-14 | `.cursor/rules`에 상태 머신, backlog 분리, verification fail 처리 규칙 반영 | Cursor 작업도 Claude와 같은 하네스 상태 모델을 따르도록 정렬 | Low |
| 2026-05-14 | Claude/Cursor dry-run에서 product/harness backlog 선택 흐름 확인 | 다음 작업 선택 기준이 `PHASE2.md`와 `HARNESS.md`로 명확히 분리됨 | Low |
| 2026-05-14 | 대형 작업 TODO 분해 조건과 ID/file naming 규칙 정리 | TODO 남발을 막고 backlog·STATUS·TODO 간 추적성을 유지 | Low |
| 2026-05-14 | `docs/CLAUDE.md` 슬림화와 `HARNESS-PROTOCOL.md` 허브 구조 도입 | 자동 로드 컨텍스트를 줄이고 상세 레퍼런스를 필요 시 로드하도록 분리 | Low |
| 2026-05-14 | `WORKFLOW-MANUAL-V2.md`를 `HARNESS-PROTOCOL.md`로 명명 변경 | 사용자 매뉴얼이 아니라 하네스 운영 프로토콜임을 명확히 하기 위함 | Low |
| 2026-05-14 | `prompts/`와 `.claude/commands/` 역할 경계 결정 작업을 HRN-007로 등록 | prompt library와 반복 실행 command의 중복·혼선을 별도 기준으로 정리하기 위함 | Low |
| 2026-05-14 | `WORKFLOW-MANUAL.md`를 사용자 매뉴얼로 현행화하고 protocol 문서와 역할 분리 | 사용자용 설명과 Agent 실행 규칙 원본이 섞이지 않도록 하기 위함 | Low |
| 2026-05-14 | `WORKFLOW-MANUAL.md`의 Mermaid 다이어그램을 상태 머신과 product/harness 분리 구조에 맞춰 현행화 | 텍스트와 시각 자료가 서로 다른 운영 모델을 안내하지 않도록 하기 위함 | Low |
| 2026-05-14 | `WORKFLOW-MANUAL.md`의 신규 프로젝트 초기화 절차를 현재 harness protocol 구조에 맞춰 현행화 | 새 프로젝트에 옛 manual-first 구조가 복사되는 것을 방지하기 위함 | Low |
| 2026-05-14 | `README.md`, `prompts/`, 주요 product docs를 현재 harness/product 문서 구조와 맞춰 현행화 | GitHub 첫 화면 중복을 줄이고 구식 prompt·CI·Testcontainers·라이선스 표현을 제거하기 위함 | Low |
| 2026-05-14 | 하네스 리팩토링 결과를 “Lightweight Manual-first AI Workflow Harness v1”로 자체 평가 | 문서 현행화 이상의 개선점과 자동화 부족이라는 한계를 다음 hardening 기준으로 남기기 위함 | Low |
| 2026-05-14 | Codex용 세션 bootstrap prompt를 추가하고 `AGENTS.md` 도입 여부를 HRN-008로 등록 | Codex는 `.claude/commands`를 직접 실행하지 않으므로 같은 하네스 절차를 수동으로 복원할 진입점이 필요함 | Low |
| 2026-05-15 | `STATUS.md` 변경은 STATUS Update Proposal과 사용자 승인 후에만 수행 | `STATUS.md`가 Agent 메모장이 아니라 승인된 현재 상태 기록으로 남아야 함 | Low |
| 2026-05-15 | 상세 하네스 규칙의 canonical source를 `docs/harness-protocol/*.md`로 명확화 | 자동 로드 문서와 quick reference의 중복 drift를 줄이기 위함 | Low |
| 2026-05-15 | 작업 선택·계획·아이디어 도출 시 회고를 조건부 의사결정 보조 맥락으로 사용 | backlog만으로 놓칠 수 있는 반복 리스크와 이전 평가 내용을 반영하기 위함 | Low |
| 2026-05-15 | ignore/permission 정책을 `.claudeignore`, `.cursorignore`, `.claude/settings.json` 기준으로 정렬 | AI 컨텍스트 비용과 민감 파일 접근 위험을 줄이기 위함 | Low |
| 2026-05-15 | Claude/Cursor/Codex 반복 세션 시뮬레이션 결과 현재 구조를 manual-first harness v1로 최종 정리 | 자동 강제는 약하지만 시작·선택·계획·검증·종료·재개 흐름은 일관됨 | Low |
| 2026-05-15 | 하네스 리팩터링 결과를 외부 리뷰 요청 문서로 정리 | 기존 대비 변경점, 잔여 리스크, 리뷰 체크리스트를 한 문서에서 검토하기 위함 | Low |

## Next Actions

1. `docs/retrospectives/harness-refactor-review-request-20260515.md`의 언어 스타일을 리뷰 관점에서 재검토.
2. Phase2 본계획 수립을 위해 `docs/backlog/PHASE2.md`의 `Phase 2 Preparation Candidates`부터 검토.
3. Manual-first 운영이 안정화되면 `docs/backlog/HARNESS.md`의 HRN-001 또는 HRN-002 착수 여부 결정.
4. `docs/` 정보 구조 재분류는 HRN-006에서 별도 계획으로 검토.
5. `prompts/`와 `.claude/commands/` 역할 경계는 HRN-007에서 별도 기준 수립.
6. Codex 사용 빈도가 늘어나면 HRN-008에서 `AGENTS.md` 도입 여부 결정.
7. `docs/` 파일·디렉토리 naming audit은 HRN-009에서 DR-008 기준으로 검토.
