# HARNESS.md

AI Workflow Harness backlog다.

이 파일은 Claude/Codex/Cursor 등 Agent workflow, 문서 상태 관리, command/rule 정합성, hook/CI enforcement 후보를 관리한다.
Spring Boot MSA template의 product backlog는 `docs/backlog/PHASE2.md`에서 관리한다.

Phase1 종료 직후 백업본은 `docs/archive/harness-refactor-20260514/PHASE2-backlog-before-refactor.md`에 보존되어 있다.

## Priority Guide

| Priority | Meaning |
| --- | --- |
| P0 | Phase2 본격 착수 전에 처리해야 하는 운영 기반 |
| P1 | 세션 안정성 또는 규칙 준수율을 크게 높이는 항목 |
| P2 | 운영 부채를 줄이는 보완 항목 |
| P3 | 선택적, 실험적, 또는 사용 빈도 확인 후 진행할 항목 |

## Active Refactor

| ID | Priority | Status | Risk | Task | Done Criteria | Verification |
| --- | --- | --- | --- | --- | --- | --- |
| HRF-001 | P0 | Done | L3 | Phase1 이후 하네스를 경량 상태 머신 기반 운영 체계로 재편 | 백업 완료, STATUS 재정의, product/harness backlog 분리, Quick Reference 생성 | `docs/STATUS.md`, `docs/backlog/PHASE2.md`, `docs/backlog/HARNESS.md`, `docs/HARNESS-QUICK-REFERENCE.md` 확인 |

## Backlog

| ID | Priority | Status | Risk | Task | Dependencies | Done Criteria | Verification |
| --- | --- | --- | --- | --- | --- | --- | --- |
| HRN-001 | P0 | Done | L2 | Stop hook 추가 — `/done` 없이 세션 종료 시 reminder 출력 | `settings.json` Stop hooks | 세션 종료 시 `/done` reminder가 출력됨 | `.claude/settings.json` JSON 파싱, hook command 출력 확인 |
| HRN-002 | P1 | Candidate | L2 | Hard enforcement 강화 — git hook + 검증 누락 감지 보강 | Manual protocol 안정화, HRN-001 | git pre-commit hook이 STATUS.md 최근 수정 여부를 체크; Java 파일 변경 후 검증 누락을 세션 종료 전 감지하는 enforcement chain 설계 | hook 트리거 확인 및 lint/validation 누락 감지 확인 |
| HRN-003 | P2 | Done | L1 | WORKFLOW-MANUAL Quick Reference 카드 분리 | HRF-001 | 일상 참조는 Quick Reference, 상세 참조는 HARNESS-PROTOCOL.md와 `docs/harness-protocol/`로 경로 명확화 | 문서 리뷰 및 HARNESS-PROTOCOL.md 링크 확인 |
| HRN-004 | P3 | Candidate | L1 | prompts/ vs commands/ 중복 정리 — 역할 경계 명확화 | command/rule audit | slash command로 커버되는 prompts 항목 정리; 각 경로의 사용 목적 구분 문서화 | `prompts/README.md` 업데이트 및 파일 목록 확인 |
| HRN-005 | P2 | Candidate | L2 | 구조 변경 cascade 트리거 보완 — `docs/` 디렉토리 추가·삭제 자동 감지 | T5/T7 trigger review | `docs/` 하위 디렉토리 추가·삭제 시 cascade 대상이 명시적으로 정의됨 | 신규 디렉토리 추가 시 cascade 누락 없이 업데이트됨 확인 |
| HRN-006 | P2 | Candidate | L2 | `docs/` 정보 구조 재분류 — 사용자 문서, 하네스 프로토콜, 프로젝트 설계 문서, legacy Phase1 TODO 분리 | Harness Protocol 안정화 | `docs/` 하위 문서 성격별 위치 기준과 migration plan 작성, live `docs/TODO/PHASE1/TODO-BLOCK*.md` archive/migration 방침 결정, 자동 로드/참조 문서 영향도 확인 | 문서 링크 점검 및 `rg` 참조 확인 |
| HRN-007 | P2 | Candidate | L1 | `prompts/` vs `.claude/commands/` 역할 경계와 전환 기준 결정 | Harness Protocol 안정화 | `prompts/` 파일을 command 승격/유지/archive-delete 후보로 분류하고, 전환 기준을 `prompts/README.md` 또는 harness protocol에 반영 | 파일 목록 점검, 중복 command/prompt 쌍 식별 |
| HRN-008 | P1 | Done | L1 | Codex 전용 instruction 구조 도입 — root `AGENTS.md`를 `CLAUDE.md`와 동등한 진입점으로 추가 | Codex 사용 결정 | `AGENTS.md` 생성, `CLAUDE.md`와 대칭 구조 정렬, prompt/README와 공통 규칙 위임 경로 정렬 | 문서 참조 확인, Codex 시작 경로 정렬 확인, `.claude/settings.json` 충돌 없음 |
| HRN-009 | P2 | Candidate | L1 | `docs/` 파일·디렉토리 naming audit — DR-008 기준 재검토, "harness" 용어 적정성 검토 포함 | `docs/decisions/DR-008-docs-filename-standard.md` | `docs/` 루트, `backlog/`, `decisions/`, `TODO/`, `harness-protocol/`, `archive/`, `retrospectives/`의 대소문자·hyphen 규칙을 재정의하거나 DR-008 예외를 명시; `VSCode-DevContainer구조.png`, legacy `TODO-BLOCK*.md`, archive snapshot 파일명 처리 방침 결정; "harness" 용어가 이 시스템의 lightweight 성격에 적합한지 검토하고 유지·변경·완화(modifier 추가) 중 방향을 결정하여 기록 | `find docs -maxdepth 3`, `rg` 참조 점검, case-only rename 필요 시 git-safe 절차 확인 |
| DOC-001 | P2 | Candidate | L1 | git 구성·브랜치 전략·flow 가이드 문서 생성 | git workflow 운영 확립 | `docs/GIT-WORKFLOW.md` 생성, feature→develop→PR to main 전략 및 CI trigger 연계 설명 포함 | 문서 리뷰 |

## Deferred Ideas

| ID | Topic | Decision Point |
| --- | --- | --- |
| HRN-FUT-001 | `.harness/config.json` SSOT 도입 | Manual-first protocol이 1~2회 실제 작업에서 안정화된 후 |
| HRN-FUT-002 | `/health` 주간 자동 실행 설정 | 자동화 요청이 명확해지고 notification 경로가 확정된 후 |
| HRN-FUT-003 | Claude/Codex/Cursor handover 문서 자동 생성 | 도구 간 전환이 실제로 반복될 때 |
