---
id: HRN-024
priority: P1
status: Active
risk: Medium
scope: AI Workflow Harness 문서 현행화, 정합성 점검, 내용 보완
appetite: 1-2d
planned_start: 2026-05-22
planned_end:
actual_end:
---

# HRN-024: Document consistency alignment

## Context

AI Workflow Harness public-ready migration 이후 repository identity, 문서 이름, scaffold 산출물,
tool-specific rule, prompt example pack이 빠르게 재정렬되었다.

이 작업은 현재 문서들이 최신 상태를 반영하는지 확인하고, canonical 문서와 실제 scaffold 산출물,
tool-specific mirror, user-facing manual 사이의 불일치를 찾아 정렬한다. 단순 stale term scan만이 아니라
실제 AI 작업 흐름을 시뮬레이션하여 start, pick, work, resume, close/done, archive, quick mode,
state update, cascade/trigger, 신규 프로젝트 scaffold 진입이 자연스럽게 이어지는지 검토한다.

## Plan

### Step 1 - Current surface map

- live 문서를 canonical / tool-specific / user-facing / scaffold / historical-reference 계층으로 분류한다.
- 각 계층의 SSoT와 mirror 역할을 다시 확인한다.
- archive/retrospective에 남은 old term은 historical로 허용할지 live guidance로 오해될지 구분한다.

### Step 2 - Workflow simulation

- `/start`, `/pick`, `/work`, `/resume`, `/close`, `/done`, archive, Quick Mode, State Update, cascade/trigger를 시뮬레이션한다.
- Product track / Harness track 모델이 source repository와 scaffolded project 양쪽에서 자연스럽게 동작하는지 확인한다.
- Gitflow, CI, scaffold validation 흐름이 최신 branch/prompt/tool surface와 맞는지 확인한다.

### Step 3 - Findings and alignment proposal

- 발견사항을 P0/P1/P2로 분류한다.
- 누락, 불일치, 과잉반복, 불필요복잡성, 사용자생산성저하 관점으로 평가한다.
- 수정 범위를 canonical -> tool-specific -> user-facing -> scaffold 순서로 제안한다.

### Step 4 - Approved edits

- 승인된 범위만 수정한다.
- live docs와 scaffold 산출물이 같은 내용을 말하도록 정렬한다.
- historical snapshot은 필요 시 reference-only 주석 또는 retrospective addendum으로만 보정한다.

### Step 5 - Validation

- `git diff --check`
- `bash -n scripts/create-harness.sh`
- generic scaffold dry-run
- fresh temp path 실제 scaffold 생성
- stale term / renamed file / removed path scan

## Done Criteria

- [ ] 문서 계층별 surface map이 정리됨
- [ ] workflow simulation 결과가 기록됨
- [ ] P0/P1 findings가 수정 또는 명시적으로 defer됨
- [ ] canonical, tool-specific, user-facing, scaffold 산출물이 같은 current model을 설명함
- [ ] fresh scaffold 생성 결과가 검증됨
- [ ] validation command가 통과함
- [ ] commit 전 STATUS/Tracking finalization 필요 여부가 보고됨

## Checkpoints

### CP-1: Work registration

- AWH-001 Done 전환 후 HRN-024 Active Work로 등록
- STATUS dashboard pointer 전환
- Harness Work index Active table 등록

### CP-2: Review report

- 계층별 findings와 수정 제안 작성
- Status: Done

### CP-3: Alignment patch

- 승인된 P0/P1 수정 반영
- Status: Done

### CP-4: Final validation

- scaffold와 stale scan까지 포함한 검증 수행
- Status: Done

## Discovery

- 2026-05-22: AWH-001 사용자 최종 리뷰 완료 후 후속 문서 정합성 작업으로 등록.
- 2026-05-22: CP-1 완료. AWH-001은 Done 처리했고, HRN-024를 STATUS Active Work와 harness Work index에 등록했다.
- 2026-05-22: CP-2 초기 검토에서 `docs/PLAN-SUMMARY.md`, `docs/PLAN.md`, `docs/GIT-WORKFLOW.md`가 현재 migration 이후 상태와 불일치하는 후보로 확인됐다.
- 2026-05-22: `docs/STATUS.md` Blockers/OQ 중 Spring Boot optional profile과 README positioning은 최근 결정/현재 README와 중복되는 stale 후보로 확인됐다.
- 2026-05-22: AWH-001 이후 상위 phase를 `Workflow hardening`으로 확정. 이후 작업은 문서 현행화, scaffold 정합성, tool surface alignment 강화 단계에 귀속한다.
- 2026-05-22: CP-2 review 결과 P0 없음, P1은 언어 규칙 적용 범위, `/health --cascade` runtime-era surface, scaffold first-session Product backlog 진입 약화로 정리했다.
- 2026-05-22: CP-3 alignment patch 적용. Canonical 문서의 영어 본문 표기를 한국어 primary로 정렬하고, `/health` implementation sync 대상을 workflow/tool/scaffold surface로 전환했다.
- 2026-05-22: Scaffold README/STATUS/PHASE1 skeleton과 session prompts가 제품 목표에서 Product track backlog를 만들고 AI workflow 개선은 Harness track으로 분리하도록 보강했다.
- 2026-05-22: CP-4 검증 완료. `git diff --check`, `bash -n scripts/create-harness.sh`, generic dry-run, fresh generic scaffold 생성이 통과했다. Fresh scaffold stale scan에서 runtime-era `health`/Checkstyle/MSA 보조 규칙 표현은 검출되지 않았다. Source stale scan의 residual은 optional Spring Boot example rule glob과 infra rule 예시뿐이며, historical archive/AWH-001 기록은 의도된 보존 대상으로 분류했다.
- 2026-05-22: 추가 hardening으로 scaffold 산출물에 `docs/BOOTSTRAP.md`를 생성하도록 했다. 이 checklist는 project identity, production 성격, Product/Harness track 분리, core 문서 작성 순서, example pack/role/rule/prompt 정비 항목을 첫 세션에서 점검하게 한다.
- 2026-05-22: Source guide `docs/SCAFFOLD-BOOTSTRAP.md`와 `docs/BOOTSTRAP.md` entry note를 추가하고, README/manual/summary/session prompt/Claude command/Cursor rule surface에 bootstrap routing을 반영했다.
- 2026-05-22: 추가 검토에서 entrypoint 직접 경로가 약한 점을 보완했다. `AGENTS.md`/`CLAUDE.md`에 bootstrap 조건을 추가하고, scaffold `BOOTSTRAP.md`가 README/PLAN-SUMMARY/entrypoint/rule/prompt identity 보정 필요 여부를 Harness 후보로 제안하도록 강화했다.
- 2026-05-22: Starter repo 진입로와 one-time bootstrap flow는 HRN-025로 분리했다. HRN-024는 현재 상태에서 보류하고, HRN-025 완료 후 남은 문서 정합성 범위를 다시 판단한다.
