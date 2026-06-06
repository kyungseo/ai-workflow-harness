# HARNESS.md

AI Workflow Harness backlog다.

이 파일은 Claude/Codex/Cursor 등 Agent workflow, 문서 상태 관리, command/rule 정합성, hook/CI enforcement 후보를 관리한다.
프로젝트 기능 backlog가 필요한 경우 `docs/backlog/PHASE{n}.md`를 별도로 둔다.

기존 product-template backlog와 Work 기록은 history와 archive에 남아 있지만, 이 repository의 현재 active scope는 AI Workflow Harness다.

> Done/Superseded 항목은 이 파일에서 제거된다.
> 완료 이력: Work 파일이 있는 항목은 `docs/works/harness/README.md` Archived 테이블, Work 파일이 없는 항목(Quick Mode)은 `git log --grep="{ID}"`로 확인한다.

## Priority Guide

| Priority | Meaning |
| --- | --- |
| P0 | public-ready migration 또는 harness 운영 전에 처리해야 하는 기반 |
| P1 | 세션 안정성 또는 규칙 준수율을 크게 높이는 항목 |
| P2 | 운영 부채를 줄이는 보완 항목 |
| P3 | 선택적, 실험적, 또는 사용 빈도 확인 후 진행할 항목 |

## Backlog

| ID | Priority | Status | Risk | Task | Dependencies | Done Criteria | Verification |
| --- | --- | --- | --- | --- | --- | --- | --- |
| — | P1 | Candidate | L3 | `gate-enforcement-runtime-and-env` 남은 sub-slice — Done: (a) source hook runtime(CHORE-20260606-006), (b) shared gate-list SSoT(CHORE-20260606-007), (c1) source-gitflow opt-in hook 배포(CHORE-20260606-008), (c2-A) source CI hardening(CHORE-20260606-009). 남은 범위: (c2-B) target CI 템플릿(scaffold가 `.github/workflows` 배포) + CI job의 ruleset required-status-check 연결(DR-020 후속, c2-A에서 분리), (c3) hook-less/generic target documented advisory + manifest 기반 check, (c4) product-adaptive gate logic(target 고유 protected/finalization list 자동 조정), (d) source-gitflow environment bootstrap(git init→main→develop→origin→branch protection per DR-020). **단일 PR 아님 — 각 sub-slice 별도 착수** | DR-025, DR-024, DR-021, DR-020; 선행 (a)/(b)/(c1) Done | sub-slice별 착수 단위 분해, 각 enforcement/bootstrap을 fresh scaffold/real repo에서 검증 | sub-slice별 동작(CI/advisory/manifest/adaptive list/bootstrap) 확인, source-vs-target 경계 누수 없음 |
| HRN-030 | P2 | Candidate | L2 | Phase transition 기준 정립 — phase transition trigger와 Work Done Criteria의 관계 명확화 (`Current Milestone Criteria`는 2026-05-25 제거됨 — 그 전제는 무효, baseline/maintenance 전환 이력은 STATUS Recent Decisions 참조) | 없음 | phase 완료 시 phase 전환/새 milestone/maintenance 전환 중 어떤 절차를 따를지, Work Done과 phase 경계가 어긋나는 경우 처리를 protocol/manual에 반영 | phase 완료 시나리오, Work Done과 phase 경계가 다른 시나리오를 문서 기준으로 시뮬레이션 |
| HRN-032 | P2 | Candidate | L2 | Windows 지원 확장 — macOS 기준 workflow/scaffold 검증을 Windows/WSL/Git Bash까지 정렬 | HRN-031 이후 scaffold smoke test | `/start`와 scaffold 후 첫 세션이 Windows native, WSL, Git Bash 환경에서 어떤 명령·hook·경로 전제를 갖는지 정리하고, 필요한 문서/스크립트 보완안을 반영 | Windows/WSL/Git Bash별 `/start` 시뮬레이션, `create-harness.sh` 실행 경로, `python3` Stop hook, `/tmp` 검증 경로 대체안 확인 |
| HRN-016 | P3 | Candidate | L1 | `/exit` → Stop hook gap 추적 — Claude Code process-exit hook 지원 여부 모니터링 (소극적 감시; 지원 확인 전 action 없음) | — | Claude Code 릴리즈 노트에서 process-exit hook 지원 확인 시 `settings.json` 보완 및 문서 갱신 | 릴리즈 노트 확인 후 gap 해소 여부 검증 |
| — | P1 | Candidate | L2 | 외부화 실패모드 통합 설계 원칙 명문화 — AI 맥락 외부화의 3대 실패모드(① 라우팅 누락 ② 비대화 ③ 선언-실행 괴리)와 각 보완(manifest·canonical / archive drain·SSoT 단일화 / test·hard-stop)을 Phase 2 slice 0 방향 결정의 상위 프레임으로 채택 | CHORE-20260604-001 (Done), slice 0 | 3대 실패모드와 보완 매핑을 Phase 2 설계 원칙으로 문서화하고, 기존 §5·§7·§8·§9 결정이 이 프레임에 정합하는지 확인 | slice 0 방향 결정 문서/DR에서 세 실패모드가 각각 어느 보완으로 닫히는지 추적 가능 |
| — | P1 | Candidate | L2 | Work 파일 계층화 규칙 도입 (DR-013 개선) — 긴 Work에 상단 결론 요약(N줄)과 context manifest(재개 시 읽을 파일·섹션 목록) 추가. 외부화 ① 라우팅 누락·② 비대화 동시 완화 | DR-013, CHORE-20260604-001(1046줄이 직접 근거) | DR-013 Work spec에 top-summary와 context manifest 규칙 추가, 적용 임계 길이 기준 정의, scaffold Work 템플릿 반영 | 긴 Work 재개 시 manifest만으로 진입 가능한지 시뮬레이션, scaffold dry-run에서 템플릿 반영 확인 |

## Deferred Ideas

| ID | Topic | Decision Point |
| --- | --- | --- |
| HRN-FUT-004 | Gitflow vs GitHub Flow 전략 결정 — 현재 Gitflow(feature→develop→main) 유지 여부 | 충분한 논의 후 결정. trade-off: Gitflow는 릴리즈 단위 제어 유리, GitHub Flow는 1인 개발 절차 단순화. 결정 시 `docs/GIT-WORKFLOW.md`와 DR로 반영 |
| HRN-FUT-002 | `/health` 주간 자동 실행 설정 | 자동화 요청이 명확해지고 notification 경로가 확정된 후 |
| HRN-FUT-006 | Work frontmatter work↔work `related_work` 필드 도입 여부 — `related_dr`·`related_troubleshooting`는 DR-013에 이미 정의·사용 중(Work 006~009 보유). work 간 의존 표현(`related_work`)만 미도입. 도입 시 DR-013·scaffold·기존 Work 파일 업데이트 필요 | work 간 의존 추적이 실제로 반복 필요해질 때 |
| HRN-FUT-007 | Branch Flow SSoT context 효율화 — 현재 AI 도구(Claude/Codex/Cursor)는 merge intent 감지 시 `docs/GIT-WORKFLOW.md` 전체(165줄)를 on-demand 로드하나, §2·§3만 필요. 선택지: A) 현행 유지(실용적, context 여유 충분), B) `docs/GIT-FLOW-STEPS.md` 같은 전용 소형 파일 분리(~20줄, DRY 유지). 결정 기준: Branch Flow 변경 빈도가 높아지거나 context 부담이 실제로 감지될 때 | Branch Flow 변경이 잦아지거나 context 효율 문제가 실측될 때 |
| HRN-FUT-008 | Harness Upgrade / Refresh Guide — `--existing`은 기존 프로젝트에 하네스를 신규 overlay하는 용도이며, 이미 하네스가 적용된 프로젝트를 최신 template로 갱신하는 기능이 아님. 필요 시 `--upgrade`, `--refresh`, 또는 수동 update guide 설계 | 외부/내부 적용 프로젝트가 늘어나고, 기존 scaffold 프로젝트에 upstream harness 변경을 안전하게 반영해야 하는 요구가 반복될 때. 결정 시 overwrite/merge 정책, drift detection, backup strategy, version marker 필요 여부 검토 |
| AWH-OQ-001 | historical product docs를 `docs/archive/`에 얼마나 남길 것인가 — 현재 guidance와 혼동되지 않는 legacy 기준 결정 | archive policy가 실제로 필요해지는 시점(외부 기여 증가 또는 docs 혼동 발생 시). HRN-035 CP-2에서 public baseline Open Blocker 해소를 위해 Blockers에서 제거 |
| — | Work ID collision 자동화 — NNN 재배정 절차는 HARNESS-NAMING-RULES.md에 문서화 완료(CHORE-20260528-001). 병렬 feature에서 실제 collision이 반복되면 helper script로 `docs/works/**` 중복 Work ID 검사를 자동화 (L3) | collision이 실제 발생하거나 병렬 Active Work가 3개 이상 반복될 때 |
| — | External tracker override 적용 가이드 — escape hatch는 문서화 완료. Jira/Linear/GitHub Issues 등 external tracker를 실제 사용하는 product repo가 생기면 project-specific tracker policy와 Work ID 매핑 가이드 작성 | external tracker를 사용하는 product repo 운영 시점 |
| — | STATUS/Work README merge conflict 자동 복구 — manual-first conflict-resolution rule은 `docs/HARNESS-PARALLEL-WORK-CONTROLS.md`에 문서화하고 `docs/HARNESS-PROTOCOL.md`에는 조건부 pointer만 남김(CHORE-20260528-001). index regeneration automation이 필요해지면 L3 Work로 등록 | 병렬 feature PR merge 시 conflict가 반복될 때 |
| — | DR-### global sequence 충돌 처리 자동화 — Accepted 직전 번호 재확인 절차는 record-decision command/skill에 추가 완료(CHORE-20260528-001). `DR-DRAFT-{slug}` 임시 식별자 또는 번호 lock 자동화가 필요해지면 L3 Work로 등록 | 동시 진행 DR이 실제로 충돌하는 시점 |
| — | Command/skill mirror atomicity 강화 — Work CP 단위 atomicity rule은 `docs/HARNESS-PARALLEL-WORK-CONTROLS.md`와 health command/skill에 반영됨(CHORE-20260528-001). drift 자동 감지(CI/hook)가 필요해지면 L3 Work로 등록 | command/skill mirror drift가 실제 운영 버그로 이어질 때 |
| — | Scaffold template drift window 관리 — release timing guidance는 HARNESS-PROTOCOL.md §14 T12에 추가 완료(CHORE-20260528-001). 외부 적용 프로젝트가 늘고 drift 비용이 명확해지면 `--upgrade` 가이드 또는 별도 release criteria 문서로 분리 | 외부 적용 프로젝트가 늘어나고 drift 비용이 명확해질 때 |
