# STATUS.md

Claude Code를 위한 현재 프로젝트 상태 문서다.
이 파일은 짧게 유지하고, 완료된 Phase의 상세 이력은 `docs/archive/`로 옮긴다.

Last updated: 2026-05-19 (HRN-021-S5 완료 — WORKFLOW-MANUAL.md load boundary 정리)

## Current State

| Field | Value |
| --- | --- |
| Current phase | Phase 2 pre-entry |
| Current focus | Phase 2 pre-entry workflow stabilization |
| Phase 1 | Complete |
| Product backlog | `docs/backlog/PHASE2.md` |
| Harness backlog | `docs/backlog/HARNESS.md` |
| Quick reference | `docs/HARNESS-QUICK-REFERENCE.md` |
| Harness protocol | `docs/HARNESS-PROTOCOL.md` |
| User workflow manual | `docs/WORKFLOW-MANUAL.md` |
| Pre-refactor backup | `docs/archive/snapshots/harness-refactor-20260514/` |
| HRF-001 completion | `docs/archive/snapshots/hrf-001-completion/` |

## Work Context Rule

이 파일은 현재 작업 상태의 단일 기준이다.
세션 시작 시에는 `Current State`, `Active Work`, `Blockers And Open Questions`, `Next Actions`만 확인한다.
실행 흐름 상세: `docs/AGENT-WORKFLOW.md`

## Phase 2 Pre-Entry Completion Criteria

- [x] HRF-002 완료: Work 파일 체계 + Archive 정책 + STATUS 전환 + AI 도구 정렬 + 시뮬레이션 통과 + `/health` 통과
- [ ] PRE-B: 개발환경 전략 결정
- [x] PRE-C1: Phase 1 아키텍처 현황 분석
- [ ] PRE-C2: Phase 2 요건 정의 확정

## Active Work

| ID | Priority | Status | Work File |
| --- | --- | --- | --- |
| PRE-B | P0 | Active | `docs/works/phase2/PRE-B-env-strategy.md` |

## Blockers And Open Questions

| ID | Status | Question | Decision Needed |
| --- | --- | --- | --- |
| HRF-OQ-003 | Open | `.harness/config.json` 같은 SSOT config를 지금 도입할 것인가? | Manual-first 안정화 후 재검토 |

## Recent Decisions

| Date | Decision | Reason | Reversal Cost |
| --- | --- | --- | --- |
| 2026-05-17 | Scope And Commit Approval 명확화: L1 변경은 빠르게 진행, scope 확장과 commit 전에는 사용자 승인 gate 명시 | scope drift 재발 방지 | Low |
| 2026-05-17 | Testcontainers Docker 환경 설정을 `build.gradle.kts`로 이관 — 개발자별 홈 파일 설정 불필요 | P2-006 회피 조치 정정, 신규 개발자 수동 설정 제거 | Low |
| 2026-05-18 | DR-013: Work 파일 기반 작업 단위 체계 도입 — `docs/works/` 구조, frontmatter 스펙, Candidate→Active→Done→Archived lifecycle | STATUS.md 비대화 방지, 세션 간 이력 완전 보존 | Medium |
| 2026-05-18 | DR-014: Archive 구조 정책 — `docs/archive/` 하위 경로 미러링, `-v{N}` / `-{YYYYMMDD}` 접미사 규칙 | 어느 파일이든 아카이빙 가능, 원본 위치 추적 직관적 | Low |
| 2026-05-18 | DR-015: State Update Proposal 2계층 게이트 재설계 — Work 파일 변경(Layer 1)은 저마찰, STATUS.md 변경(Layer 2)은 차등 게이트 | Work 파일 SSoT 전환 이후 게이트 비용이 실질 위험과 역전된 구조 해소 | Low |
| 2026-05-18 | DR-016: Work Done과 Archived 상태 분리 — `/close`는 Done 처리, `/done`은 세션 요약 전용; archive는 명시 승인 또는 start/resume trigger로 수행 (HRN-019로 역할 변경) | 리뷰 대기·외부 참조 유지 중 Work 파일 조기 이동 방지 | Low |

## Next Actions

1. PRE-B: 개발환경 전략 결정
2. PRE-C2: Phase 2 요건 정의 확정 (PRE-B + PRE-C1 완료 후)
3. HRN-021: 다음 simplification step으로 S1 protocol 통합 검토/착수
