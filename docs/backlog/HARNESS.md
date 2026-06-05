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
| HRN-002 | P1 | Candidate | L2 | Hard enforcement 강화 — git hook + 검증 누락 감지 보강 | Manual protocol 안정화 | git pre-commit hook이 STATUS.md 최근 수정 여부와 validation 누락을 세션 종료 전 감지하는 enforcement chain 설계 | hook 트리거 확인 및 lint/validation 누락 감지 확인 |
| HRN-030 | P1 | Candidate | L2 | Phase lifecycle 관리 기준 정립 — Current Milestone Criteria, phase transition trigger, Work Done Criteria 관계 명확화 | HRN-029 이후 공개 준비 상태 정리 | `STATUS.md`의 Current Milestone Criteria가 phase/milestone 단위 기준임을 명확히 하고, criteria 완료 시 phase 전환/새 milestone/maintenance 전환 중 어떤 절차를 따를지 protocol과 manual에 반영 | phase 완료 시나리오, milestone 교체 시나리오, Work Done과 phase criteria가 다른 시나리오를 문서 기준으로 시뮬레이션 |
| HRN-032 | P2 | Candidate | L2 | Windows 지원 확장 — macOS 기준 workflow/scaffold 검증을 Windows/WSL/Git Bash까지 정렬 | HRN-031 이후 scaffold smoke test | `/start`와 scaffold 후 첫 세션이 Windows native, WSL, Git Bash 환경에서 어떤 명령·hook·경로 전제를 갖는지 정리하고, 필요한 문서/스크립트 보완안을 반영 | Windows/WSL/Git Bash별 `/start` 시뮬레이션, `create-harness.sh` 실행 경로, `python3` Stop hook, `/tmp` 검증 경로 대체안 확인 |
| HRN-016 | P3 | Candidate | L1 | `/exit` → Stop hook gap 추적 — Claude Code process-exit hook 지원 여부 모니터링 (소극적 감시; 지원 확인 전 action 없음) | — | Claude Code 릴리즈 노트에서 process-exit hook 지원 확인 시 `settings.json` 보완 및 문서 갱신 | 릴리즈 노트 확인 후 gap 해소 여부 검증 |
| — | P2 | Candidate | L2 | Pre-commit / commit-msg hook 검토·정비 및 설치 — `tools/git-hooks/pre-commit` 정확성 검토, commit-msg hook 필요 여부 판단, hard block 전환(HRN-039 OQ-2) 결정, 설치 절차 정비 및 실제 설치 | — | pre-commit hook 내용 검토 완료, hard block 정책 결정, 설치 확인(`ls .git/hooks/pre-commit`), GIT-WORKFLOW.md §6 설치 안내 현행화 | hook 설치 후 protect 대상 파일 staged 상태에서 경고(또는 hard block) 동작 확인 |
| — | P1 | Candidate | L2 | 외부화 실패모드 통합 설계 원칙 명문화 — AI 맥락 외부화의 3대 실패모드(① 라우팅 누락 ② 비대화 ③ 선언-실행 괴리)와 각 보완(manifest·canonical / archive drain·SSoT 단일화 / test·hard-stop)을 Phase 2 slice 0 방향 결정의 상위 프레임으로 채택 | CHORE-20260604-001 (Done), slice 0 | 3대 실패모드와 보완 매핑을 Phase 2 설계 원칙으로 문서화하고, 기존 §5·§7·§8·§9 결정이 이 프레임에 정합하는지 확인 | slice 0 방향 결정 문서/DR에서 세 실패모드가 각각 어느 보완으로 닫히는지 추적 가능 |
| — | P1 | Candidate | L2 | Work 파일 계층화 규칙 도입 (DR-013 개선) — 긴 Work에 상단 결론 요약(N줄)과 context manifest(재개 시 읽을 파일·섹션 목록) 추가. 외부화 ① 라우팅 누락·② 비대화 동시 완화 | DR-013, CHORE-20260604-001(1046줄이 직접 근거) | DR-013 Work spec에 top-summary와 context manifest 규칙 추가, 적용 임계 길이 기준 정의, scaffold Work 템플릿 반영 | 긴 Work 재개 시 manifest만으로 진입 가능한지 시뮬레이션, scaffold dry-run에서 템플릿 반영 확인 |
| — | P2 | Candidate | L2 | Scaffold adopter upgrade/migration caution note (slug: `scaffold-target-maintenance-note`) — 이 repo를 clone해서 `scripts/create-harness.sh`로 scaffold한 사용자가 upgrade/migration 관점에서 주의해야 할 점을 README에 노출한다. framework-owned(직접 수정 비권장, `--check`가 `locally-modified`로 감지, source 업데이트 시 충돌 가능) vs project-owned(채워야 할 것) 경계, `--check` 사용법, `--upgrade` 미제공·수동 selective migration 주의를 환기. **배치 A**: generated target README에 "Framework Files & Updating" 짧은 섹션(`create-harness.sh`) + source README §10 한 줄 pointer. 내용은 target-safe 문서만 참조하고 MIGRATION note 같은 source-only는 prose로만 안내. 관련 HRN-FUT-008(upgrade 메커니즘, deferred)과 구분 — 이건 도구 없이 지금 가능한 awareness 문서 | CHORE-20260606-003 merge 후 | generated target README(default+`--with-optional`)에 framework/project 경계 + update 주의 섹션 생성, source README §10 pointer, source-only 문서 relative-link 0 | fresh scaffold 양쪽 모드에서 섹션 생성·target-safe pointer 확인, `--check` 안내와 정합 |

## Deferred Ideas

| ID | Topic | Decision Point |
| --- | --- | --- |
| HRN-FUT-001 | `.harness/config.json` SSOT 도입 | Manual-first protocol이 1~2회 실제 작업에서 안정화된 후 |
| HRN-FUT-004 | Gitflow vs GitHub Flow 전략 결정 — 현재 Gitflow(feature→develop→main) 유지 여부 | 충분한 논의 후 결정. trade-off: Gitflow는 릴리즈 단위 제어 유리, GitHub Flow는 1인 개발 절차 단순화. 결정 시 `docs/GIT-WORKFLOW.md`와 DR로 반영 |
| HRN-FUT-002 | `/health` 주간 자동 실행 설정 | 자동화 요청이 명확해지고 notification 경로가 확정된 후 |
| HRN-FUT-003 | Claude/Codex/Cursor handover 문서 자동 생성 | 도구 간 전환이 실제로 반복될 때 |
| HRN-FUT-006 | Work frontmatter `dependencies` / `related_work` 필드 도입 여부 — HRN-017/018 완료로 검토 조건 충족. 도입 시 DR-013, `docs/HARNESS-PROTOCOL.md`, scaffold, 기존 Work 파일 업데이트 필요 | HRN-017/018 Done 이후 (조건 충족) |
| HRN-FUT-007 | Branch Flow SSoT context 효율화 — 현재 AI 도구(Claude/Codex/Cursor)는 merge intent 감지 시 `docs/GIT-WORKFLOW.md` 전체(165줄)를 on-demand 로드하나, §2·§3만 필요. 선택지: A) 현행 유지(실용적, context 여유 충분), B) `docs/GIT-FLOW-STEPS.md` 같은 전용 소형 파일 분리(~20줄, DRY 유지). 결정 기준: Branch Flow 변경 빈도가 높아지거나 context 부담이 실제로 감지될 때 | Branch Flow 변경이 잦아지거나 context 효율 문제가 실측될 때 |
| HRN-FUT-008 | Harness Upgrade / Refresh Guide — `--existing`은 기존 프로젝트에 하네스를 신규 overlay하는 용도이며, 이미 하네스가 적용된 프로젝트를 최신 template로 갱신하는 기능이 아님. 필요 시 `--upgrade`, `--refresh`, 또는 수동 update guide 설계 | 외부/내부 적용 프로젝트가 늘어나고, 기존 scaffold 프로젝트에 upstream harness 변경을 안전하게 반영해야 하는 요구가 반복될 때. 결정 시 overwrite/merge 정책, drift detection, backup strategy, version marker 필요 여부 검토 |
| AWH-OQ-001 | historical product docs를 `docs/archive/`에 얼마나 남길 것인가 — 현재 guidance와 혼동되지 않는 legacy 기준 결정 | archive policy가 실제로 필요해지는 시점(외부 기여 증가 또는 docs 혼동 발생 시). HRN-035 CP-2에서 public baseline Open Blocker 해소를 위해 Blockers에서 제거 |
| — | Work ID collision 자동화 — NNN 재배정 절차는 HARNESS-NAMING-RULES.md에 문서화 완료(CHORE-20260528-001). 병렬 feature에서 실제 collision이 반복되면 helper script로 `docs/works/**` 중복 Work ID 검사를 자동화 (L3) | collision이 실제 발생하거나 병렬 Active Work가 3개 이상 반복될 때 |
| — | External tracker override 적용 가이드 — escape hatch는 문서화 완료. Jira/Linear/GitHub Issues 등 external tracker를 실제 사용하는 product repo가 생기면 project-specific tracker policy와 Work ID 매핑 가이드 작성 | external tracker를 사용하는 product repo 운영 시점 |
| — | STATUS/Work README merge conflict 자동 복구 — manual-first conflict-resolution rule은 `docs/HARNESS-PARALLEL-WORK-CONTROLS.md`에 문서화하고 `docs/HARNESS-PROTOCOL.md`에는 조건부 pointer만 남김(CHORE-20260528-001). index regeneration automation이 필요해지면 L3 Work로 등록 | 병렬 feature PR merge 시 conflict가 반복될 때 |
| — | DR-### global sequence 충돌 처리 자동화 — Accepted 직전 번호 재확인 절차는 record-decision command/skill에 추가 완료(CHORE-20260528-001). `DR-DRAFT-{slug}` 임시 식별자 또는 번호 lock 자동화가 필요해지면 L3 Work로 등록 | 동시 진행 DR이 실제로 충돌하는 시점 |
| — | Command/skill mirror atomicity 강화 — Work CP 단위 atomicity rule은 `docs/HARNESS-PARALLEL-WORK-CONTROLS.md`와 health command/skill에 반영됨(CHORE-20260528-001). drift 자동 감지(CI/hook)가 필요해지면 L3 Work로 등록 | command/skill mirror drift가 실제 운영 버그로 이어질 때 |
| — | Scaffold template drift window 관리 — release timing guidance는 HARNESS-PROTOCOL.md §14 T12에 추가 완료(CHORE-20260528-001). 외부 적용 프로젝트가 늘고 drift 비용이 명확해지면 `--upgrade` 가이드 또는 별도 release criteria 문서로 분리 | 외부 적용 프로젝트가 늘어나고 drift 비용이 명확해질 때 |
