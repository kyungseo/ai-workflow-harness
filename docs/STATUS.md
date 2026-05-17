# STATUS.md

Claude Code를 위한 현재 프로젝트 상태 문서다.
이 파일은 짧게 유지하고, 완료된 Phase의 상세 이력은 `docs/archive/`로 옮긴다.

Last updated: 2026-05-17 (pre-commit hook Checkstyle 조건부 실행 추가)

## Current State

| Field | Value |
| --- | --- |
| Current phase | Phase 2 pre-entry |
| Current focus | Harness refactor follow-up hardening |
| Phase 1 | Complete |
| Active plan | None |
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
| HRN-001 | P0 | Done | L2 | Stop hook 추가 — `/done` 없이 세션 종료 시 reminder 출력 | 세션 종료 시 validation, STATUS Update Proposal, DR-worthy decision, commit 상태 reminder 출력 | `.claude/settings.json` JSON 파싱, hook command 출력 확인 |
| HRN-008 | P1 | Done | L1 | Codex 전용 instruction 구조 도입 — `AGENTS.md`를 `CLAUDE.md`와 동등한 진입점으로 추가 | `AGENTS.md` 생성, 공통 규칙은 `docs/AGENT-WORKFLOW.md`로 위임, prompt/README 정렬 | 링크/참조 확인, Codex 시작 경로 정렬 확인 |
| P2-006 | P1 | Done | L2 | 통합 테스트 Testcontainers 마이그레이션, CI yml services 블록 제거, troubleshooting 기록 | 3개 통합 테스트 클래스·yml 마이그레이션 완료, ci.yml services 블록 없음, `docs/troubleshooting/` 생성 | `./gradlew test` 전체 통과 |
| HRN-010 | P1 | Done | L1 | harness 전체 PHASE2 → PHASE{n} 일반화 (20파일) | 라우팅 참조 모두 PHASE{n}, example path 보존 | rg grep 검증 |
| HRN-011 | P1 | Done | L2 | `/register` 명령어 추가 + 3-tool command intent recognition | `register.md` 생성, `docs-workflow`/`AGENTS.md`/`workflow.mdc` 반영 | 3-tool 시뮬레이션 |
| HRN-012 | P1 | Done | L2 | troubleshooting workflow T8 트리거 10개 파일 통합 | T8 trigger, context routing, done/work/Cursor/Codex 반영 | `/done` 흐름 확인 |
| HRN-013 | P1 | Done | L2 | `create-harness.sh` 범용 스캐폴딩 스크립트 + `WORKFLOW-MANUAL.md §8` 재구성 | 신규/기존 케이스, `--dry-run`/`--existing`, `--profile generic|spring-boot`, 첫 세션 가이드, profile별 포함 파일 정렬 | `bash -n`, `git diff --check`, generic/spring-boot actual 생성, existing dry-run skip 확인, JSON 파싱, Claude/Codex/Cursor workflow 시뮬레이션 |
| HRN-014 | P1 | Done | L2 | `/doc` 발표·보고 산출물 workflow + 3-tool natural language intent mapping | `doc.md` 생성, Codex/Cursor mapping, T9 trigger, `docs/reports/`·`docs/presentations/` 산출물 위치, `create-harness.sh` 포함 | rg mapping 검증, `bash -n`, JSON parse, create-harness dry-run/actual 생성, `/doc` 시뮬레이션, `git diff --check` |
| HRN-015 | P1 | Done | L1 | DR-011 Recent Decisions 정책을 command/cascade 실행 표면에 반영 | `/done`, `/record-decision`, `/health`, cascade checklist, quick reference가 Recent Decisions rolling window·항목 품질·DR 확인 기준을 직접 안내 | `rg` 정합성 확인, `git diff --check` |
| DOC-001 | P2 | In Progress | L1 | git 구성·브랜치 전략·flow 가이드 문서 생성 | git workflow 운영 확립 | `docs/GIT-WORKFLOW.md` 생성, 실제 Gitflow(feature→develop→main) 및 CI trigger·pre-commit hook·post-PR 절차 포함 | 문서 리뷰, `git diff --check` |

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
| CP-HRF-13 | STATUS Update Approval Gate 반영 | Done | `docs/AGENT-WORKFLOW.md`, `docs/HARNESS-QUICK-REFERENCE.md`, `docs/harness-protocol/`, commands/prompts/rules에 STATUS Update Proposal 규칙 확인 |
| CP-HRF-14 | Claude command/rule flow 정합성 보정 | Done | `.claude/commands/`, `.claude/rules/`, Cursor rules의 plan/approval/validation/status/commit gate 확인 |
| CP-HRF-15 | ignore/permission 정합성 보정 | Done | `.claudignore` → `.claudeignore` rename, `.cursorignore`, `.claude/settings.json` permissions.deny 확인 |
| CP-HRF-16 | protocol routing과 canonical source 보정 | Done | `docs/AGENT-WORKFLOW.md`, `docs/HARNESS-PROTOCOL.md`, `docs/HARNESS-QUICK-REFERENCE.md`, `docs/harness-protocol/*.md` 역할 확인 |
| CP-HRF-17 | retrospective conditional loading 반영 | Done | `/pick`, `/work`, `docs/AGENT-WORKFLOW.md`, `docs/harness-protocol/02-context-loading.md`에 회고 조건부 로드 규칙 확인 |
| CP-HRF-18 | 최종 반복 세션·다중 Agent 시뮬레이션 | Done | Claude/Codex/Cursor 시작·선택·계획·검증·종료·재개 흐름과 residual risk 확인 |
| CP-HRF-19 | 하네스 리팩터링 리뷰 패키지 작성 | Done | `docs/retrospectives/harness-refactor-review-request-20260515.md` 생성 및 `git diff --check` 확인 |

## Blockers And Open Questions

| ID | Status | Question | Decision Needed |
| --- | --- | --- | --- |
| HRF-OQ-001 | Closed | 기존 Phase2 작업, 체크포인트, DR을 백업하고 백지 재편할 것인가? | 백업 후 재편하기로 결정 |
| HRF-OQ-002 | Closed | `HRN-*`을 Phase2 product backlog에서 분리할 것인가? | `docs/backlog/HARNESS.md`로 분리 |
| HRF-OQ-003 | Open | `.harness/config.json` 같은 SSOT config를 지금 도입할 것인가? | Manual-first 안정화 후 재검토 |
| HRF-OQ-004 | Closed | `docs/AGENT-WORKFLOW.md`, `.claude/commands`, `.claude/rules`를 1차 재편에서 수정할 것인가? | product/harness backlog 분리와 상태 머신 게이트를 최소 반영 |
| HRF-OQ-005 | Closed | 한국어 문서에서 섹션명·하네스 용어·기술 용어를 어느 정도 영어로 유지할 것인가? | DR-007 Bilingual Rules 정책으로 결정 — 섹션명·기술 용어 영문 유지, 본문은 한국어 주체 |

## Recent Decisions

| Date | Decision | Reason | Reversal Cost |
| --- | --- | --- | --- |
| 2026-05-15 | docs/troubleshooting/ 디렉토리와 T8 트리거를 harness workflow 전체(AGENT-WORKFLOW, commands, Cursor rules, Codex prompt, WORKFLOW-MANUAL)에 통합 | 비자명 이슈 해결 내역을 세 도구에서 일관되게 기록하기 위함 | Low |
| 2026-05-15 | PHASE{n} 일반화: template-level routing은 PHASE{n}, 구체적 example path(HARNESS-QUICK-REFERENCE.md §9)는 PHASE2 유지 | 하네스 문서가 특정 Phase에 종속되지 않도록 | Low |
| 2026-05-15 | `create-harness.sh`: `--existing` 플래그로 기존 프로젝트 overlay 지원, 기존 파일 덮어쓰기 없음 | 신규/기존 두 케이스를 하나의 스크립트로 처리 | Low |
| 2026-05-15 | `create-harness.sh` 기본값은 범용 `generic`, Spring Boot/MSA 보조 규칙과 prompts는 `--profile spring-boot`에서만 포함 | 재사용 가능한 AI Workflow Harness가 새 프로젝트의 기술 스택을 잘못 가정하지 않도록 | Medium |
| 2026-05-16 | DR-007 Amended: Bilingual Rules 공식화 — 섹션 타이틀 영문 Title Case, 기술 용어·지표 영문 유지 원칙 전체 harness에 적용 | 세 도구 공통 언어 정책을 DR로 명문화하여 문서·커밋 메시지 일관성 확보 | Medium |
| 2026-05-17 | Scope And Commit Approval 명확화: 승인된 scope 내 L1 변경은 빠르게 진행하되, scope 확장과 commit 전에는 사용자 승인 gate 명시 | Claude/Codex/Cursor 간 승인·커밋 절차 불일치와 scope drift 재발 방지 | Low |
| 2026-05-17 | Testcontainers Docker 환경 설정을 `build.gradle.kts` `tasks.withType<Test>`로 이관 — 개발자별 홈 파일 설정 불필요 | P2-006 회피 조치(홈 파일 생성) 정정, 신규 개발자 수동 설정 제거 | Low |
| 2026-05-17 | pre-commit hook: docs-only 커밋 시 Checkstyle skip — Java/Kotlin/Gradle staged 시에만 실행 | 문서 전용 커밋에서 불필요한 Gradle 기동 제거 | Low |
| 2026-05-17 | `WORKFLOW-MANUAL.md` 제목·구조 재편 및 현행 운영 흐름 보정 — 'Lightweight Manual-First AI Workflow Harness v1' 명칭 적용, §7 Trigger Reference 본문 승격, Appendix 재배치, Key Notation 신설, STATUS Update Proposal gate·Codex entry flow·context load·trigger cascade 설명 정렬 | 사용자 매뉴얼 가독성 개선, harness 명칭 통일, 실제 실행 규칙과 Mermaid/Appendix 설명의 정합성 확보 | Low |

## Next Actions

1. Phase 2 본계획 수립을 위해 `docs/backlog/PHASE2.md`의 `Phase 2 Preparation Candidates`부터 검토.
2. `docs/retrospectives/harness-refactor-review-request-20260515.md`의 언어 스타일을 리뷰 관점에서 재검토.
3. `docs/` 정보 구조 재분류는 HRN-006에서 별도 계획으로 검토.
4. `docs/` 파일·디렉토리 naming audit은 HRN-009에서 DR-008 기준으로 검토.
