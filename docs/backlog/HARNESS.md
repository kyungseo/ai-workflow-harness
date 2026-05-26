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
| HRN-037 | P2 | Candidate | L2 | `/close` 번들 기본값 개선 — feature branch에서 PR 전 /close 시 close 상태 변경을 별도 commit 대신 마지막 work commit에 번들 | HRN-036 완료 후 관찰된 패턴 | feature branch에서 아직 develop에 merge되지 않은 상태로 /close 실행 시, close state 변경(Work Done, Work Index, STATUS pointer)을 별도 close commit 대신 마지막 work commit과 번들하는 것을 기본값으로 안내하도록 `.claude/commands/close.md` 개선. cascade: `.agents/skills/` 대응 skill 정렬 확인 | `/close` 시나리오 시뮬레이션 — feature branch pre-PR, feature branch post-merge, develop 직접 작업 세 경우 모두 올바른 안내 확인 |
| HRN-032 | P2 | Candidate | L2 | Windows 지원 확장 — macOS 기준 workflow/scaffold 검증을 Windows/WSL/Git Bash까지 정렬 | HRN-031 이후 scaffold smoke test | `/start`와 scaffold 후 첫 세션이 Windows native, WSL, Git Bash 환경에서 어떤 명령·hook·경로 전제를 갖는지 정리하고, 필요한 문서/스크립트 보완안을 반영 | Windows/WSL/Git Bash별 `/start` 시뮬레이션, `create-harness.sh` 실행 경로, `python3` Stop hook, `/tmp` 검증 경로 대체안 확인 |
| HRN-016 | P3 | Candidate | L1 | `/exit` → Stop hook gap 추적 — Claude Code process-exit hook 지원 여부 모니터링 (소극적 감시; 지원 확인 전 action 없음) | — | Claude Code 릴리즈 노트에서 process-exit hook 지원 확인 시 `settings.json` 보완 및 문서 갱신 | 릴리즈 노트 확인 후 gap 해소 여부 검증 |

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
| HRN-FUT-008 | Harness Upgrade / Refresh Guide — `--existing`은 기존 프로젝트에 하네스를 신규 overlay하는 용도이며, 이미 하네스가 적용된 프로젝트를 최신 template로 갱신하는 기능이 아님. 필요 시 `--upgrade`, `--refresh`, 또는 수동 update guide 설계 | 외부/내부 적용 프로젝트가 늘어나고, 기존 scaffold 프로젝트에 upstream harness 변경을 안전하게 반영해야 하는 요구가 반복될 때. 결정 시 overwrite/merge 정책, drift detection, backup strategy, version marker 필요 여부 검토 |
| AWH-OQ-001 | historical product docs를 `docs/archive/`에 얼마나 남길 것인가 — 현재 guidance와 혼동되지 않는 legacy 기준 결정 | archive policy가 실제로 필요해지는 시점(외부 기여 증가 또는 docs 혼동 발생 시). HRN-035 CP-2에서 public baseline Open Blocker 해소를 위해 Blockers에서 제거 |
