# STATUS.md

Claude Code를 위한 현재 프로젝트 상태 문서다.
이 파일은 짧게 유지하고, 완료된 Phase의 상세 이력은 `docs/archive/`로 옮긴다.

Last updated: 2026-05-12 (PRE-A2+A3 통합 완료: 코드 컨벤션, Checkstyle, CI 기반 구축)

## Current State

| Field | Value |
| --- | --- |
| Current phase | Phase 2 planning |
| Phase 1 | Complete |
| Active plan | `docs/PLAN.md` |
| Active backlog | `docs/backlog/PHASE2.md` |
| Phase 1 task details | `docs/TODO/PHASE1/TODO-BLOCK*.md` |
| Phase 1 status archive | `docs/archive/phase1-status.md` |
| Phase 1 plan archive | `docs/archive/phase1-plan.md` |

## Work Context Rule

이 파일은 작업 상태를 관리하기 위한 문서이며, planning, implementation, testing을 대체하지 않는다.
작업 흐름 상세: `docs/CLAUDE.md` → Work Management Model 참조.

실행 흐름 요약: `backlog 선택 → plan → approval → implementation → verification → status update`

## Active Work

> PRE-A/B/C 항목의 상세 맥락(이슈 원인, 트레이드오프, 진행 방법)은 작업 시작 전 반드시 참조:
> `~/.claude/plans/claude-md-docs-claude-md-streamed-starlight.md`

| ID | Priority | Status | Scope | Done Criteria | Verification |
| --- | --- | --- | --- | --- | --- |
| P2-PLAN-001 | P0 | Done | Claude Code context와 Phase 2 작업관리 구조 정리 | `CLAUDE.md`, `docs/CLAUDE.md`, `docs/STATUS.md`, Phase 2 backlog가 context-efficient하고 재사용 가능함 | Documentation diff inspection |
| P2-PLAN-002 | P0 | Done | AI workflow 점검 및 개선 (Vibe Coding best practice 기준) | `.claude/commands/` 6개, `.claude/rules/testing.md`, `docs/decisions/` 구조, `docs/PLAN-SUMMARY.md`, `settings.json` 수정 완료 | 파일 존재 확인 및 `/start` slash command 동작 확인 |
| P2-PLAN-003 | P0 | Done | AI workflow 정비 심화 + Cursor 정렬 | 언어 원칙 정의, rules 정합성·token 효율 개선, prompts 라이브러리 Spring Boot 특화, Cursor rules Claude와 정렬 완료 | 파일 존재 확인 및 git log 검토 |
| PRE-A1 | P0 | Done | Makefile `-p base-msa-template` 추가 (container/network 이름 고정) | `-p` 추가 후 `make run` 정상 동작, container_name 충돌 없음 | `curl http://localhost:8090/api/v1/auth/login` 정상 응답 |
| PRE-A2+A3 | P0 | Done | 코드 컨벤션 SSOT, Checkstyle, CI 기반 구축 (파일 헤더 없음 정책, DR-004~006) | `./gradlew checkstyleMain checkstyleTest` 0 위반, `.editorconfig`·`ci.yml`·`tools/git-hooks/`·`docs/CODING-CONVENTIONS.md` 생성 완료 | `./gradlew check` 통과 확인 |
| PRE-B | P0 | Candidate | 개발환경 전략 결정 (로컬 실행 구조, Windows 지원, devcontainer, mono-repo) | B-1~B-4 결정 사항 decision record 또는 STATUS 반영 완료 | 결정 문서 리뷰 |
| PRE-C1 | P0 | Candidate | Phase 1 아키텍처 현황 분석 (레이어 일관성, common-core, gateway, 테스트 커버리지) | 분석 결과와 개선 필요 항목 목록 작성 | docs/backlog 또는 STATUS 반영 |
| PRE-C2 | P0 | Candidate | Phase 2 요건 정의 확정 (Session B 결정 반영, DR-001/002 완료) | backlog PHASE2.md 업데이트, DR-001 결정 완료 | backlog + decision review |
| PRE-C3 | P1 | Candidate | Dockerfile 개선 (Gradle 캐시 레이어, JAVA_OPTS 외부화, HEALTHCHECK) | 각 서비스 Dockerfile 개선 적용, 재빌드 성공 | `make rebuild` 후 서비스 정상 기동 |

## Phase 2 Checkpoints

| Checkpoint | Purpose | Status | Verification |
| --- | --- | --- | --- |
| CP-P2-0 | Phase 2 계획과 backlog 구조화 | Done | `docs/STATUS.md`, `docs/backlog/PHASE2.md` 검토 |
| CP-P2-1 | token/session 관련 보안 의사결정 완료 | Not started | Decision records and targeted tests |
| CP-P2-2 | gateway/proxy 동작을 운영 환경 기준으로 보정 | Not started | Rate limiting and trusted proxy tests |
| CP-P2-3 | infrastructure 방향 결정 | Not started | K8s/CI decision records and dry-run validation |
| CP-P2-4 | observability baseline 구현 | Not started | Metrics/tracing/logging validation |

## Blockers And Open Questions

| ID | Status | Question | Decision Needed |
| --- | --- | --- | --- |
| OQ-001 | Closed | Phase 2는 infrastructure 확장보다 security hardening을 먼저 해야 하는가? | DR-003 참조: Security first 결정. P2-001→002→003→004 순서 |
| OQ-002 | Open | K8s 배포 도구는 Helm과 Kustomize 중 무엇을 쓸 것인가? | manifests 작성 전 결정 |
| OQ-003 | Open | token storage를 localStorage에서 HttpOnly Cookie로 전환할 것인가? | frontend/auth 변경 전 결정 |
| OQ-004 | Closed | `.claude/claude.json`은 legacy custom harness config였는가? | 삭제 완료. 공식 Claude Code config는 `.claude/settings.json` |

## Recent Decisions

| Date | Decision | Reason | Reversal Cost |
| --- | --- | --- | --- |
| 2026-05-11 | active state는 `docs/STATUS.md`에 유지하고 Phase 1 상세는 archive로 이동 | Phase 2에서 Claude context load 감소 | Low |
| 2026-05-11 | root `CLAUDE.md`를 재사용 가능하게 만들고 `docs/CLAUDE.md`를 명시 import | instruction loading 개선 및 cross-project reuse | Low |
| 2026-05-11 | 공식 `.claude/settings.json`과 path-scoped `.claude/rules/` 추가 | 중복 prompt context 감소 및 Claude Code 설정 정렬 | Low |
| 2026-05-11 | legacy `.claude/claude.json` 삭제 | 사용자 확인 후 obsolete custom harness configuration 제거 | Low |
| 2026-05-11 | AI workflow 개선: `.claude/commands/` 6개, `testing.md` rule, `PLAN-SUMMARY.md`, `decisions/` DR 초안 3개, `settings.json` 수정 | Phase 2 착수 전 workflow 마찰 최소화, Vibe Coding best practice 정렬 | Low |
| 2026-05-11 | 언어 원칙 정의: `.claude/rules/*.md`·루트 `CLAUDE.md` → 영어, `docs/*.md`·`prompts/*.md` → 한국어+기술용어 영어 유지 | token 효율 및 instruction 준수율 향상 | Low |
| 2026-05-11 | `git-workflow.md` rule 신규 추가: 커밋 전 `git status → add → status → diff --cached` 프로세스 강제 | 커밋 누락 방지 (unstaged/untracked 미확인 문제) | Low |
| 2026-05-11 | Cursor rules를 Claude rules와 정렬: `java-spring.mdc`, `testing.mdc` 신규, `git-commit.mdc` 프로세스 추가, `.cursorignore` 업데이트 | Claude/Cursor 간 규칙 정합성 확보 | Low |
| 2026-05-11 | prompts 라이브러리 Spring Boot 특화: `21-create-layer`, `22-minimal-diff` 신규, 기존 5개 개선 (minimal patch, API contract 불변, Spring 안티패턴 체크) | AI 작업 품질 및 범위 제어 향상 | Low |
| 2026-05-12 | 파일 헤더 없음 정책 (DR-004): LICENSE 파일로 충분, AI 컨텍스트 낭비 없음 | 코드 파일당 헤더 주석 제거 | Low |
| 2026-05-12 | Checkstyle 채택 (DR-005): Google Java Style 기반 + LineLength=120/Indentation=4 오버라이드, Javadoc 비활성 | 코드 품질 자동 검증 도입 | Medium |
| 2026-05-12 | CI job 분리 구조 (DR-006): lint→test 체인 + 확장 포인트 주석 명시, `gradle/actions/setup-gradle@v3` | CI/CD 점진적 확장 가능 구조 | Low |
| 2026-05-12 | 기술 결정 기록 워크플로우 도입: `/record-decision` command, `docs/CLAUDE.md` Decision Records 섹션, `/done` 7번 단계 추가 | 세션 중 확정 결정의 체계적 DR 보존 | Low |
| 2026-05-11 | 파일 유형별 언어 원칙 확정 (DR-007): `.claude/rules/`·루트 CLAUDE.md → 영어, `docs/`·commands → 한국어+기술용어 영어 | token 효율 및 instruction 준수율 향상, 문서 가독성 보존 | Medium |

## Next Actions

1. DR-004~006 기록 (`/record-decision` — 이번 세션 확정 결정 3건).
2. PRE-B: 개발환경 전략 4개 결정 (B-1~B-4) — PRE-C2 전 선행 필요.
3. PRE-C1: Phase 1 아키텍처 분석 → PRE-C2 backlog 업데이트.
4. PRE-C2: DR-001 완료 + Phase 2 backlog 최종 확정.
5. PRE-C3: Dockerfile 개선 (P1, C2 이후 병행 가능).
6. P2-001 착수 (PRE-C2 완료 후).
