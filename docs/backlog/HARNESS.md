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

## Backlog

| ID | Priority | Status | Risk | Task | Dependencies | Done Criteria | Verification |
| --- | --- | --- | --- | --- | --- | --- | --- |
| HRN-002 | P1 | Candidate | L2 | Hard enforcement 강화 — git hook + 검증 누락 감지 보강 | Manual protocol 안정화 | git pre-commit hook이 STATUS.md 최근 수정 여부와 validation 누락을 세션 종료 전 감지하는 enforcement chain 설계 | hook 트리거 확인 및 lint/validation 누락 감지 확인 |
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
