# STATUS.md

Claude Code를 위한 현재 프로젝트 상태 문서다.
이 파일은 짧게 유지하고, 완료된 Phase의 상세 이력은 `docs/archive/`로 옮긴다.

Last updated: 2026-05-18 (HRF-002 Phase B — STATUS 구조 전환, Work 파일 체계 도입)

## Current State

| Field | Value |
| --- | --- |
| Current phase | Phase 2 pre-entry |
| Current focus | HRF-002: Work 파일 기반 운영 체계 도입 |
| Phase 1 | Complete |
| Active plan | HRF-002 (`docs/works/harness/HRF-002-work-system-refactor.md`) |
| Product backlog | `docs/backlog/PHASE2.md` |
| Harness backlog | `docs/backlog/HARNESS.md` |
| Quick reference | `docs/HARNESS-QUICK-REFERENCE.md` |
| Harness protocol | `docs/HARNESS-PROTOCOL.md` |
| User workflow manual | `docs/WORKFLOW-MANUAL.md` |
| Pre-refactor backup | `docs/archive/harness-refactor-20260514/` |
| HRF-001 completion | `docs/archive/snapshots/hrf-001-completion/` |

## Work Context Rule

이 파일은 현재 작업 상태의 단일 기준이다. 단, 문서와 실제 파일 상태가 충돌하면 실제 파일 상태를 우선한다.

실행 흐름:

```text
INIT -> PLAN -> APPROVAL -> EXECUTE -> VALIDATE -> CHECKPOINT -> END
                 ^              |
                 |              v
              RECOVER <- FAIL <-+
```

세션 시작 시에는 이 파일의 `Current State`, `Active Work`, `Blockers And Open Questions`, `Next Actions`만 확인한다.
Phase1 또는 이전 계획의 상세 맥락은 필요할 때만 archive에서 확인한다.

## Phase 2 Pre-Entry Completion Criteria

- [ ] HRF-002 완료: Work 파일 체계 + Archive 정책 + STATUS 전환 + AI 도구 정렬 + 시뮬레이션 통과 + `/health` 통과
- [ ] PRE-B: 개발환경 전략 결정
- [ ] PRE-C1: Phase 1 아키텍처 현황 분석
- [ ] PRE-C2: Phase 2 요건 정의 확정

## Active Work

| ID | Status | Work File |
| --- | --- | --- |
| HRF-002 | Active | `docs/works/harness/HRF-002-work-system-refactor.md` |

## Blockers And Open Questions

| ID | Status | Question | Decision Needed |
| --- | --- | --- | --- |
| HRF-OQ-003 | Open | `.harness/config.json` 같은 SSOT config를 지금 도입할 것인가? | Manual-first 안정화 후 재검토 |

## Recent Decisions

| Date | Decision | Reason | Reversal Cost |
| --- | --- | --- | --- |
| 2026-05-15 | PHASE{n} 일반화: template-level routing은 PHASE{n}, 구체적 example path는 PHASE2 유지 | 하네스 문서가 특정 Phase에 종속되지 않도록 | Low |
| 2026-05-15 | `create-harness.sh`: `--existing` 플래그로 기존 프로젝트 overlay 지원, 기존 파일 덮어쓰기 없음 | 신규/기존 두 케이스를 하나의 스크립트로 처리 | Low |
| 2026-05-15 | `create-harness.sh` 기본값은 범용 `generic`, Spring Boot 보조 규칙은 `--profile spring-boot`에서만 포함 | 재사용 가능한 Harness가 기술 스택을 잘못 가정하지 않도록 | Medium |
| 2026-05-16 | DR-007 Amended: Bilingual Rules 공식화 — 섹션 타이틀 영문 Title Case, 기술 용어 영문 유지 원칙 전체 harness 적용 | 세 도구 공통 언어 정책을 DR로 명문화 | Medium |
| 2026-05-17 | Scope And Commit Approval 명확화: L1 변경은 빠르게 진행, scope 확장과 commit 전에는 사용자 승인 gate 명시 | scope drift 재발 방지 | Low |
| 2026-05-17 | Testcontainers Docker 환경 설정을 `build.gradle.kts`로 이관 — 개발자별 홈 파일 설정 불필요 | P2-006 회피 조치 정정, 신규 개발자 수동 설정 제거 | Low |
| 2026-05-18 | DR-013: Work 파일 기반 작업 단위 체계 도입 — `docs/works/` 구조, frontmatter 스펙, Candidate→Active→Done→Archived lifecycle | STATUS.md 비대화 방지, 세션 간 이력 완전 보존 | Medium |
| 2026-05-18 | DR-014: Archive 구조 정책 — `docs/archive/` 하위 경로 미러링, `-v{N}` / `-{YYYYMMDD}` 접미사 규칙 | 어느 파일이든 아카이빙 가능, 원본 위치 추적 직관적 | Low |

## Next Actions

1. HRF-002 Phase D: STATUS.md 리팩토링 완료 확인
2. HRF-002 Phase E: AI 도구 정렬 (Claude commands/rules, Codex, Cursor, prompts)
