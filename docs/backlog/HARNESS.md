# HARNESS.md

AI Workflow Harness backlog다.

이 파일은 Claude/Codex/Cursor 등 Agent workflow, 문서 상태 관리, command/rule 정합성, hook/CI enforcement 후보를 관리한다.
프로젝트 기능 backlog가 필요한 경우 `docs/backlog/PHASE{n}.md`를 별도로 둔다.

기존 product-template backlog와 Work 기록은 history와 archive에 남아 있지만, 이 repository의 현재 active scope는 AI Workflow Harness다.

## Priority Guide

| Priority | Meaning |
| --- | --- |
| P0 | public-ready migration 또는 harness 운영 전에 처리해야 하는 기반 |
| P1 | 세션 안정성 또는 규칙 준수율을 크게 높이는 항목 |
| P2 | 운영 부채를 줄이는 보완 항목 |
| P3 | 선택적, 실험적, 또는 사용 빈도 확인 후 진행할 항목 |

## Active Refactor

| ID | Priority | Status | Risk | Task | Done Criteria | Verification |
| --- | --- | --- | --- | --- | --- | --- |
| HRF-001 | P0 | Done | L3 | Phase1 이후 하네스를 경량 상태 머신 기반 운영 체계로 재편 | 백업 완료, STATUS 재정의, project/harness backlog 분리, Quick Reference 생성 | `docs/STATUS.md`, `docs/backlog/HARNESS.md`, `docs/HARNESS-QUICK-REFERENCE.md` 확인 |
| HRF-002 | P0 | Done | L3 | Work 파일 기반 운영 체계 도입 — docs/works/ 구조, Archive 정책, STATUS.md 축소, AI 도구 정렬, 시뮬레이션 검증 | DR-013/014 확정, docs/works/ 구조 생성, STATUS.md 포인터 전환, 3개 AI 도구 시뮬레이션 통과, /health 통과 | `docs/works/harness/HRF-002-work-system-refactor.md` + `/health` |

## Backlog

| ID | Priority | Status | Risk | Task | Dependencies | Done Criteria | Verification |
| --- | --- | --- | --- | --- | --- | --- | --- |
| HRN-001 | P0 | Done | L2 | Stop hook 추가 — `/done` 없이 세션 종료 시 reminder 출력 | `settings.json` Stop hooks | 세션 종료 시 `/done` reminder가 출력됨 | `.claude/settings.json` JSON 파싱, hook command 출력 확인 |
| HRN-002 | P1 | Candidate | L2 | Hard enforcement 강화 — git hook + 검증 누락 감지 보강 | Manual protocol 안정화, HRN-001 | git pre-commit hook이 STATUS.md 최근 수정 여부와 validation 누락을 세션 종료 전 감지하는 enforcement chain 설계 | hook 트리거 확인 및 lint/validation 누락 감지 확인 |
| HRN-003 | P2 | Done | L1 | WORKFLOW-MANUAL Quick Reference 카드 분리 | HRF-001 | 일상 참조는 Quick Reference, 상세 참조는 HARNESS-PROTOCOL.md로 경로 명확화 | 문서 리뷰 및 HARNESS-PROTOCOL.md 링크 확인 |
| HRN-004 | P2 | Done | L1 | prompts/ vs commands/ 역할 경계 결정 및 정리 — 역할 기준 문서화 후 중복 정리 실행 (HRN-007 흡수) | command/rule audit, Harness Protocol 안정화 | `prompts/` 파일을 command 승격/유지/archive-delete 후보로 분류하고 전환 기준을 `prompts/README.md`에 반영; slash command로 커버되는 prompt는 portable task value가 있으면 유지하고, repo-local workflow 실행이면 command로 유지한다 | `prompts/README.md`에 Keep as command / Keep as prompt / Session fallback / Promote / Archive 기준 반영; 현행 prompt 전체 유지, promote/archive 후보 없음 확인; `docs/WORKFLOW-MANUAL.md` Appendix A 정렬 |
| HRN-005 | P2 | Done | L2 | 구조 변경 cascade 트리거 보완 — `docs/` 디렉토리 추가·삭제 자동 감지 | T5/T7 trigger review | `docs/` 하위 디렉토리 추가·삭제 시 cascade 대상이 명시적으로 정의됨 | 신규 디렉토리 추가 시 cascade 누락 없이 업데이트됨 확인 |
| HRN-006 | P2 | Done | L2 | `docs/` 정보 구조 재분류 — 사용자 문서, 하네스 프로토콜, 프로젝트 설계 문서, legacy Phase1 TODO 분리 | Harness Protocol 안정화 | `docs/` 하위 문서 성격별 위치 기준을 durable rule로 정리. 이번 migration 판단: 파일 이동 없음; legacy Phase1 TODO는 archive-only 유지; `docs/HARNESS-REFACTOR-PLAN.md`는 retrospective와 `/work` 배경 근거 참조 때문에 reference-only/root 유지; `docs/WORKFLOW-MANUAL-SUMMARY.md`는 사용자-facing condensed guide 및 scaffold baseline으로 root 유지; `docs/reports/` 부재는 현재 구조 오류가 아님 | `docs/HARNESS-PROTOCOL.md` Information Architecture Rules 추가(작업별 migration plan 제외); `docs/WORKFLOW-MANUAL.md` File Classification 보강; `find docs -maxdepth 2`, `rg` 참조 확인 |
| HRN-007 | P2 | Superseded | L1 | `prompts/` vs `.claude/commands/` 역할 경계와 전환 기준 결정 → HRN-004에 흡수 | Harness Protocol 안정화 | HRN-004 참조 | HRN-004 참조 |
| HRN-008 | P1 | Done | L1 | Codex 전용 instruction 구조 도입 — root `AGENTS.md`를 `CLAUDE.md`와 동등한 진입점으로 추가 | Codex 사용 결정 | `AGENTS.md` 생성, `CLAUDE.md`와 대칭 구조 정렬, prompt/README와 공통 규칙 위임 경로 정렬 | 문서 참조 확인, Codex 시작 경로 정렬 확인, `.claude/settings.json` 충돌 없음 |
| HRN-009 | P2 | Done | L1 | `docs/` 파일·디렉토리 naming audit — DR-008 기준 재검토, "harness" 용어 적정성 검토 포함 | `docs/decisions/DR-008-docs-filename-standard.md` | `docs/` 루트, `backlog/`, `decisions/`, `works/`, `archive/`, `retrospectives/`, `presentations/`의 naming 규칙과 예외를 DR-008 audit addendum으로 명시; `VSCode-DevContainer구조.png`는 media 예외로 유지; "harness" 용어는 AI workflow harness 의미로 유지 | `find docs -maxdepth 3`, `rg` 참조 점검, `.DS_Store` ignore/tracked 여부 확인, `docs/HARNESS-PROTOCOL.md` File Naming 표 확장 |
| HRN-016 | P3 | Candidate | L1 | `/exit` → Stop hook gap 추적 — Claude Code process-exit hook 지원 여부 모니터링 (소극적 감시; 지원 확인 전 action 없음) | — | Claude Code 릴리즈 노트에서 process-exit hook 지원 확인 시 `settings.json` 보완 및 문서 갱신 | 릴리즈 노트 확인 후 gap 해소 여부 검증 |
| HRN-017 | P1 | Done | L1 | DR-015 2계층 State Update Proposal 구현 — commands/AGENTS.md/workflow.mdc 반영 | DR-015 확정 | `.claude/commands/` Layer 1(Work 파일 변경) / Layer 2(STATUS.md 변경) 게이트 구분 명시; `AGENTS.md` 동일 반영; `.cursor/rules/workflow.mdc` 동일 반영; 멀티 Active Work ID 명시 규칙 반영 | 각 command·rule에서 Layer 1/2 게이트 분기 확인, `rg "State Update Gate\|Layer 1\|Layer 2" .claude/commands/ AGENTS.md .cursor/rules/workflow.mdc docs/AGENT-WORKFLOW.md` |
| HRN-018 | P1 | Done | L1 | DR-016 구현 — Done→Archived 전환 트리거 규칙 반영 | DR-016 확정 | `done.md` item 11을 Done 즉시 처리(status/actual_end/README Active→Done/STATUS 포인터 제거)와 Archive 이동(git mv/README Done→Archived) 단계로 분리; `docs/HARNESS-PROTOCOL.md` Work File Rules에 Done→Archived 트리거 규칙 추가; `docs/works/{category}/README.md` 템플릿에 Candidate/Active/Done/Archived 4단 테이블 반영; `/resume`·`/start`에 Done 항목 발견 시 archive 제안 안내 추가 | `rg "Archived\|archive 대기|archive trigger|State Update Gate" .claude/commands AGENTS.md .cursor/rules/workflow.mdc docs/HARNESS-PROTOCOL.md` |
| HRN-019 | P2 | Done | L2 | `/done` Work 완료 절차 분리 — `/close` 커맨드 신규 도입 | — | `.claude/commands/close.md` 생성(Work Done 처리: frontmatter/README/STATUS pointer 제거 제안); `done.md`에서 Work Done 단계 제거 후 `/close` 먼저 실행 안내로 대체; AGENTS.md·workflow.mdc·HARNESS-QUICK-REFERENCE·WORKFLOW-MANUAL·prompts·create-harness.sh 반영 | `/close` 실행 시 Work 완료 처리만 수행되고 세션은 계속됨; `/done` 실행 시 Work 완료 절차 없이 세션 요약만 출력됨 확인 |
| HRN-020 | P3 | Done | L1 | Command taxonomy 정리 — slash command를 session lifecycle / work lifecycle / utility·analysis 범주로 분류하고 문서 표기 명확화 | HRN-019 Done 이후 | command rename 없이 `/work`·`/resume`·`/close`는 Work lifecycle, `/start`·`/pick`·`/done`은 Session lifecycle, `/debug`·`/doc`·`/health`·`/record-decision`·`/register`는 Utility/analysis로 분류한다. `WORKFLOW-MANUAL.md`와 Quick Reference에 "무엇을 끝내는 명령인가"를 명확히 반영한다 | 커맨드 목록에서 범주 구분이 명시되고 rename 없이 의미 충돌 없음 확인 |
| HRN-021 | P1 | Done | L2 | AI Workflow simplification series — 복잡도 감량 후보 단계적 실행 (S4→S2→S5→S1→S6→S3) | — | S4: harness/workflow surface 기본 L2 명시, product surface L1 Quick Mode 가능 (Quick Mode 예외 조건 삭제); S2: Scope Approval·State Update Gate·Commit Gate → Approval Matrix 단일 통합 (Work checkpoint/discovery=L1, Work Done 처리=L2, commit 전 승인 별도 행 유지); S5: WORKFLOW-MANUAL.md AI 로드 제외 명시 + cascade 대상 유지 구분; S1: 6개 상세 protocol 문서 → HARNESS-PROTOCOL.md 단일 통합 (AGENT-WORKFLOW.md 비대화 금지); S6: /health --cascade를 changed-surface cascade audit으로 경량화하고 `--full --cascade`를 전체 감사로 분리; S3: Work lifecycle Candidate 상태 제거 — backlog Candidate는 유지하고 Work 파일은 Active부터 생성. 참조: `docs/retrospectives/ai-workflow-complexity-review-20260518.md` Simplification Candidates | retrospective candidate 목록·순서 일치 확인; git diff --check |
| HRN-022 | P2 | Done | L1 | Review-sensitive Work Done Criteria 정책 검토 — 사용자 최종 리뷰를 모든 Work가 아닌 필요한 Work의 Done Criteria로 선택 적용 | HRN-021-S4 사용자 리뷰 조건 실사용 결과 | 전역 강제 대신 `/close`가 Work 파일 Done Criteria에 포함된 사용자 최종 리뷰 조건을 확인하도록 한다. 기본 포함 후보는 harness/workflow/user-facing manual/rule/command 변경, 정책·운영 절차 변경, 사용자가 명시한 "검토 후 Done" Work다. Quick Mode, 단순 오타·링크·기계적 정합성 패치, 테스트·검증으로 닫히는 구현 작업은 기본 제외로 둔다 | `docs/AGENT-WORKFLOW.md`, `.claude/commands/close.md`, `docs/HARNESS-PROTOCOL.md`, `docs/HARNESS-QUICK-REFERENCE.md`, `docs/WORKFLOW-MANUAL.md`, `.cursor/rules/workflow.mdc` 반영; DR-worthy 아님(기존 Work lifecycle 정책의 선택 기준 명확화) |
| HRN-023 | P1 | Done | L2 | 유실된 최상위 전역 행동 원칙 복원 — `docs/BEHAVIOR-PRINCIPLES.md` 신규 생성 + Claude Code / Codex / Cursor 3개 도구 정렬 | HRF-002 "CLAUDE.md 얇게 유지" 과정에서 행동 원칙 유실 | `docs/BEHAVIOR-PRINCIPLES.md` 신규 생성(5개 원칙); `CLAUDE.md` @include 추가; `AGENTS.md` Entry Contract 참조 추가; `.cursor/rules/behavior-principles.mdc` 신규 생성 | `docs/BEHAVIOR-PRINCIPLES.md`, `CLAUDE.md`, `AGENTS.md`, `.cursor/rules/behavior-principles.mdc`, `docs/AGENT-WORKFLOW.md`, `docs/HARNESS-PROTOCOL.md`, `docs/WORKFLOW-MANUAL.md` 반영 확인 |
| DOC-001 | P2 | Done | L1 | git 구성·브랜치 전략·flow 가이드 문서 생성 | git workflow 운영 확립 | `docs/GIT-WORKFLOW.md` 생성, 실제 Gitflow(feature→develop→main) 및 CI trigger·pre-commit hook·post-PR 절차 포함 | 문서 리뷰 |

## Deferred Ideas

| ID | Topic | Decision Point |
| --- | --- | --- |
| HRN-FUT-001 | `.harness/config.json` SSOT 도입 | Manual-first protocol이 1~2회 실제 작업에서 안정화된 후 |
| HRN-FUT-004 | Gitflow vs GitHub Flow 전략 결정 — 현재 Gitflow(feature→develop→main) 유지 여부 | 충분한 논의 후 결정. trade-off: Gitflow는 릴리즈 단위 제어 유리, GitHub Flow는 1인 개발 절차 단순화. 결정 시 `docs/GIT-WORKFLOW.md`와 DR로 반영 |
| HRN-FUT-005 | GitHub Branch protection rule 설정 — main 머지 게이트 강화 | public 전환 전 또는 외부 기여를 받기 전. AS-IS: protection 없음, CI 미통과 상태로 merge 가능. TO-BE: Required status checks 활성화, CI 미통과 시 merge 차단. 설정 방법: GitHub Settings → Branches → Add rule 또는 `gh api` CLI |
| HRN-FUT-002 | `/health` 주간 자동 실행 설정 | 자동화 요청이 명확해지고 notification 경로가 확정된 후 |
| HRN-FUT-003 | Claude/Codex/Cursor handover 문서 자동 생성 | 도구 간 전환이 실제로 반복될 때 |
| HRN-FUT-006 | Work frontmatter `dependencies` / `related_work` 필드 도입 여부 — HRN-017/018 완료로 검토 조건 충족. 도입 시 DR-013, `docs/HARNESS-PROTOCOL.md`, scaffold, 기존 Work 파일 업데이트 필요 | HRN-017/018 Done 이후 (조건 충족) |
| HRN-FUT-007 | Branch Flow SSoT context 효율화 — 현재 AI 도구(Claude/Codex/Cursor)는 merge intent 감지 시 `docs/GIT-WORKFLOW.md` 전체(165줄)를 on-demand 로드하나, §2·§3만 필요. 선택지: A) 현행 유지(실용적, context 여유 충분), B) `docs/GIT-FLOW-STEPS.md` 같은 전용 소형 파일 분리(~20줄, DRY 유지). 결정 기준: Branch Flow 변경 빈도가 높아지거나 context 부담이 실제로 감지될 때 | Branch Flow 변경이 잦아지거나 context 효율 문제가 실측될 때 |
