---
id: HRN-023
priority: P1
status: Active
risk: Low
scope: 유실된 최상위 전역 행동 원칙 복원 — docs/BEHAVIOR-PRINCIPLES.md 신규 생성 + Claude/Codex/Cursor 3개 도구 정렬
appetite: 1d
planned_start: 2026-05-19
planned_end:
actual_end:
---

# HRN-023: 유실된 최상위 전역 행동 원칙 복원

## Context

HRF-002(워크플로우 체계화) 과정에서 "CLAUDE.md는 얇게 유지, 상세는 docs로" 방향 채택 이후
원본 CLAUDE.md의 5개 전역 행동 원칙이 이전 대상에서 빠져 사실상 유실되었다.

유실된 원칙: 코딩 전 사고 / 단순함 우선 / 정밀한 변경 / 목표 중심 실행 / 응답 형식
유일하게 살아남은 개념: Reversal Cost (DR 템플릿 및 Approval Matrix에 흡수됨)

현재 AI는 "어떤 절차를 따를지"는 알지만 "어떤 태도로 사고하고 응답할지"는
모델 기본값에만 의존하며, 프로젝트 문서로서의 명시적 약속이 없는 상태다.

## Plan

### Step 1 — 원칙 SSoT 생성
- `docs/BEHAVIOR-PRINCIPLES.md` 신규 생성 — 5개 전역 행동 원칙 + 우선순위 체계 선언

### Step 2 — Claude Code 정렬
- `CLAUDE.md`에 `@docs/BEHAVIOR-PRINCIPLES.md` 참조 1줄 추가 (세션 시작 시 자동 로드)

### Step 3 — Codex 정렬
- `AGENTS.md` Entry Contract에 `docs/BEHAVIOR-PRINCIPLES.md` 참조 추가

### Step 4 — Cursor 정렬
- Cursor는 docs/ @include 불가 → `.cursor/rules/behavior-principles.mdc` 신규 생성
- 기존 `output-format.mdc`·`role-backend.mdc`와 중복 최소화: 겹치는 항목은 기존 파일 참조로 처리하고 누락된 원칙(특히 원칙 1 코딩 전 사고)을 보강
- `alwaysApply: true` 설정

### Step 5 — cascade 확인 + 등록
- cascade 확인: AGENT-WORKFLOW.md, HARNESS-PROTOCOL.md, WORKFLOW-MANUAL.md 충돌 여부
- `docs/backlog/HARNESS.md`에 HRN-023 등록

## Done Criteria

- [x] `docs/BEHAVIOR-PRINCIPLES.md` 생성 완료 — 5개 원칙 모두 현재 워크플로우 맥락에 맞게 기술
- [x] `CLAUDE.md`에 `@docs/BEHAVIOR-PRINCIPLES.md` 참조 추가 — 세션 시작 시 자동 로드 경로 확보
- [x] `AGENTS.md` Entry Contract에 `docs/BEHAVIOR-PRINCIPLES.md` 참조 추가
- [x] `.cursor/rules/behavior-principles.mdc` 신규 생성 (alwaysApply: true) — 기존 output-format/role-backend와 중복 없이 누락 원칙 보강
- [x] 우선순위 체계 선언이 현행 구조로 현행화 (`docs/CLAUDE.md` → `docs/AGENT-WORKFLOW.md`)
- [x] cascade 확인 완료: AGENT-WORKFLOW.md, HARNESS-PROTOCOL.md, WORKFLOW-MANUAL.md 충돌 없음
- [x] `docs/backlog/HARNESS.md` HRN-023 항목 등록
- [ ] diff 확인 후 commit 승인

## Checkpoints

### CP-1: BEHAVIOR-PRINCIPLES.md 초안 완성
- 5개 원칙 내용 작성 + 우선순위 체계 선언 현행화
- 사용자 리뷰 후 확정

### CP-2: Claude Code + Codex 정렬
- `CLAUDE.md` @include 추가
- `AGENTS.md` Entry Contract 참조 추가

### CP-3: Cursor 정렬
- `.cursor/rules/behavior-principles.mdc` 생성
- 기존 output-format.mdc / role-backend.mdc와 중복 검토
- alwaysApply: true 확인

### CP-4: cascade 확인 + 등록 + diff 검토
- AGENT-WORKFLOW.md / HARNESS-PROTOCOL.md / WORKFLOW-MANUAL.md 충돌 없음 확인
- docs/backlog/HARNESS.md HRN-023 등록
- diff 전체 검토 후 commit 승인 요청

## Discovery

- 유실 경로 분석: HRF-002 "CLAUDE.md 얇게 유지" 방향에서 행동 원칙이 이전 대상 누락
- Reversal Cost 개념만 Approval Matrix에 흡수되어 유일하게 생존
- 원본 `docs/CLAUDE.md` 우선순위 참조는 현재 구조에 없는 파일 — `docs/AGENT-WORKFLOW.md`로 대체 필요
- 5개 원칙 모두 현행 워크플로우 규칙과 충돌 없음 (표현 조율 불필요)
- Cursor `output-format.mdc`·`role-backend.mdc`가 원칙 2·3·4·5 일부를 이미 커버 — `behavior-principles.mdc`에서 누락분만 보강, 중복 최소화
- cascade 확인 결과: AGENT-WORKFLOW.md / HARNESS-PROTOCOL.md / WORKFLOW-MANUAL.md 모두 충돌 없음

### CP 진행 현황
- [x] CP-1: BEHAVIOR-PRINCIPLES.md 초안 완성 (2026-05-19)
- [x] CP-2: CLAUDE.md @include 추가 + AGENTS.md Entry Contract 참조 추가 (2026-05-19)
- [x] CP-3: .cursor/rules/behavior-principles.mdc 신규 생성 (2026-05-19)
- [x] CP-4: cascade 확인 완료 / backlog 등록 완료 (2026-05-19)
- [ ] commit 승인 대기
