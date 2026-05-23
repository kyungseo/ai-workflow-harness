---
id: AWH-001
priority: P0
status: Archived
risk: High
scope: base-msa-template에서 분리된 repository를 AI Workflow Harness 전용 public-ready project로 전환
appetite: 3-5d
planned_start: 2026-05-22
planned_end:
actual_end: 2026-05-22
---

# AWH-001: AI Workflow Harness public repo migration

## Context

`kyungseo/ai-workflow-harness`는 `kyungseo/base-msa-template`의 Git history와
branch/tag refs를 보존한 독립 repository로 생성되었다.

사용자의 목표는 기존 history를 유지하되 현재 tree를 Spring Boot MSA template이 아닌
AI Workflow Harness 전용 project로 정리한 뒤 public repository로 공개하는 것이다.

현재 repository는 아직 원본 project의 상태 문서, Spring Boot MSA plan, runtime code,
Java/Spring validation defaults를 포함한다. 따라서 바로 public 전환하지 않고,
private repository 상태에서 identity reset, tree cleanup, public documentation,
secret/private-info review를 순서대로 진행한다.

## Plan

### Step 1 - Project identity bootstrap
- `docs/PLAN.md`를 장기 AI Workflow Harness project plan으로 교체한다.
- `docs/STATUS.md`를 계속 유지될 dashboard 구조로 재작성하되, current milestone만 public-ready migration으로 둔다.
- `docs/works/harness/README.md` Active table에 AWH-001을 등록한다.

### Step 2 - Inventory and classification
- 현재 tree를 core / review / remove / legacy 후보로 분류한다.
- stale identity terms를 검색한다: `base-msa-template`, `Spring Boot`, `MSA`, `io.kyungseo.msa`.
- public-risk content를 검색한다: secret, private URL, internal-only note, local path.

### Step 3 - Product surface cleanup
- Spring Boot application source, Gradle build, Docker/K8s/DB runtime infra, service scaffold를 제거하거나 legacy로 격리한다.
- Java/Spring-specific rules and prompts를 generic harness core와 분리한다.
- `scripts/create-harness.sh`의 `spring-boot` profile 유지 여부를 결정한다.

### Step 4 - Public-facing docs rewrite
- `README.md`를 public landing page로 재작성한다.
- `docs/WORKFLOW-MANUAL-SUMMARY-PUBLIC.md`, quick reference, protocol entry docs의 naming을 정렬한다.
- origin note를 추가한다: 이 project는 `base-msa-template`에서 분리되었으며 현재는 AI Workflow Harness에 집중한다.

### Step 5 - Validation and release prep
- docs diff, stale-term audit, generic scaffold check, secret scan을 수행한다.
- feature branch PR을 통해 `develop`에 병합한다.
- cleanup review 후 GitHub repository visibility를 public으로 전환한다.

## Done Criteria

- [x] `docs/PLAN.md`가 AI Workflow Harness 장기 project plan으로 교체됨
- [x] `docs/STATUS.md`가 AWH-001 Active Work를 가리키되 migration 이후에도 유지 가능한 dashboard 구조를 가짐
- [x] current tree inventory가 core / review / remove / legacy로 정리됨
- [x] Spring Boot MSA production surfaces가 현재 project identity에서 제거 또는 legacy-isolate됨
- [x] public README와 summary docs가 AI Workflow Harness 중심으로 정렬됨
- [x] stale identity term audit 완료
- [x] secret/private-info audit 완료
- [x] generic scaffold validation 완료
- [x] public 전환 전 review 완료

## Checkpoints

### CP-1: Project identity bootstrap
- `docs/PLAN.md`, `docs/STATUS.md`, harness Work index 정렬
- 새 repo 목적과 현재 Active Work를 명확히 함

### CP-2: Inventory report
- 파일/디렉터리 classification 작성
- Spring Boot/MSA 잔여 surface와 public risk 목록 도출

### CP-3: Cleanup patch set
- 제거/보존/legacy-isolate 결정을 반영
- harness core가 계속 작동하는지 검증

### CP-4: Public docs patch set
- README와 public summary 정렬
- origin/history note와 limitation 정리

### CP-5: Release readiness
- validation 통과
- PR/merge 준비
- public visibility 전환 후보 상태 보고

## Inventory Classification Draft

### Keep As Core

- Entry and workflow core: `AGENTS.md`, `CLAUDE.md`, `docs/BEHAVIOR-PRINCIPLES.md`, `docs/AGENT-WORKFLOW.md`, `docs/HARNESS-PROTOCOL.md`, `docs/HARNESS-QUICK-REFERENCE.md`, `docs/GIT-WORKFLOW.md`
- State and planning core: `docs/STATUS.md`, `docs/PLAN.md`, `docs/PLAN-SUMMARY.md`, `docs/works/**`, `docs/backlog/HARNESS.md`
- Public/user-facing harness docs: `docs/WORKFLOW-MANUAL.md`, `docs/WORKFLOW-MANUAL-SUMMARY-PUBLIC.md`
- Tool surfaces: `.claude/commands/**`, generic `.claude/rules/**`, generic `.cursor/rules/**`
- Reusable prompts and scaffold: generic `prompts/**`, `prompts/*session-start.md`, `scripts/create-harness.sh`
- Harness decisions and retrospectives: `DR-011` 이후 workflow/harness decisions, harness/ai-workflow retrospectives

### Review Before Keeping

- `docs/ARCHITECTURE.md`: remove Spring Boot architecture content or rewrite as harness architecture.
- `docs/DEVELOPER-GUIDE.md`: remove application onboarding content or rewrite as harness adoption guide.
- `docs/CODING-CONVENTIONS.md`: remove Java coding convention content or rewrite as documentation/workflow convention.
- `docs/DOCKERFILE-GUIDE.md`: likely product-specific; confirm delete vs historical move.
- `.claude/rules/infra.md`, `.claude/rules/java-spring.md`, `.claude/rules/testing.md`
- `.cursor/rules/execution.mdc`, `.cursor/rules/java-spring.mdc`, `.cursor/rules/role-backend.mdc`, `.cursor/rules/testing.mdc`
- Spring Boot-specific prompts as optional example pack: `02`, `04`, `08`, `10`, `11`, `12`, `13`, `14`, `18`, `21`
- `scripts/create-harness.sh` `spring-boot` profile as optional example profile
- `docs/troubleshooting/**`, `docs/presentations/**`, `docs/archive/**`, `LICENSE.txt`

### Remove Or Legacy-Isolate

- Runtime/build surfaces: `build.gradle.kts`, `settings.gradle.kts`, `gradle/**`, `gradlew`, `gradlew.bat`, `.gradle/**`, `build/**`
- Product code: `common/**`, `gateway/**`, `services/**`, `frontend/**`, `tests/**`
- Product infra/config: `.devcontainer/**`, `infra/**`, `config/checkstyle/**`, `.dockerignore`, `.env.example`
- Product helper scripts: `scripts/create-service.sh`, `scripts/Makefile`, `scripts/mcp-postgres.sh`, `scripts/serve-frontend.sh`
- Product backlog/work: `docs/backlog/PHASE2.md`, `docs/works/phase2/**`
- Product decisions: `DR-001` through `DR-010`, unless moved or clearly marked historical.

### Public-Risk Follow-Up

- Remove generated build output before public release.
- Re-scan after product surface cleanup because many current keyword hits live in code expected to be removed.
- Confirm whether test passwords and JWT test secrets remain only in historical docs or removed runtime code.
- Check `.claude/settings.json`, `.mcp.json`, and prompt files for local path or private workflow leakage after cleanup.

## Discovery

- 2026-05-21: `kyungseo/ai-workflow-harness`는 private 빈 repository로 생성된 뒤,
  `kyungseo/base-msa-template`에서 mirror push 방식으로 branch/tag/history를 복제했다.
- 2026-05-21: GitHub는 `refs/pull/*` hidden ref push를 거부했지만,
  `main`, `develop`, tags는 원본과 동일한 SHA로 복제됨을 확인했다.
- 2026-05-21: 새 working copy를 생성했고,
  `feature/ai-workflow-harness-migration` branch에서 전환 작업을 시작했다.
- 2026-05-22: `PLAN.md`와 `STATUS.md`는 migration 완료 후 archive할 임시 문서가 아니라,
  migration 이후에도 계속 유지될 project plan과 dashboard로 작성해야 함을 확인했다.
- 2026-05-22: CP-2 read-only inventory 초안 확인. 현재 tree에는 Spring Boot MSA runtime surface가
  여전히 넓게 남아 있다: `build.gradle.kts`, `settings.gradle.kts`, `gradle/`, `common/`,
  `gateway/`, `services/`, `frontend/`, `infra/`, `tests/`, `config/checkstyle/`,
  `.devcontainer/`, Java/Spring-specific `.claude/rules` and `.cursor/rules`, Spring Boot prompt bundle.
- 2026-05-22: stale term scan에서 current live docs와 code에 `base-msa-template`, `Spring Boot`,
  `MSA`, `io.kyungseo.msa`, `Testcontainers`, `PostgreSQL`, `Redis`가 다수 남아 있음을 확인했다.
  `docs/archive/**`와 presentation draft는 이번 1차 scan에서 제외했다.
- 2026-05-22: public-risk keyword scan은 test password, env placeholder, JWT/test token sample,
  `.claude/settings.json` deny pattern, `scripts/mcp-postgres.sh`의 env-based connection string을 주로 검출했다.
  실제 secret 여부는 cleanup 후 별도 final audit이 필요하다.
- 2026-05-22: `docs/PLAN-SUMMARY.md`는 Context Routing에 걸린 core surface로 확인했다.
  삭제 대상이 아니라 AI Workflow Harness project summary로 재작성해야 한다.
- 2026-05-22: `docs/AGENT-WORKFLOW.md` Project Constants / Verification Defaults가 Spring Boot 값을 담고 있어
  harness project 기준으로 전환했다.
- 2026-05-22: CP-3 cleanup 1차 적용. Spring Boot MSA runtime/build/infra tracked surface 제거:
  Gradle build files, wrapper, common/gateway/services/frontend/tests, Docker/K8s/DB infra,
  devcontainer, Checkstyle config, product helper scripts, Phase2 backlog/work, Dockerfile guide.
- 2026-05-22: Gradle 제거 후 CI가 깨지지 않도록 `.github/workflows/ci.yml`을 docs/scaffold validation 중심으로 전환했고,
  `.cursor/rules/execution.mdc`도 harness verification command로 정렬했다.
- 2026-05-22: `README.md`를 AI Workflow Harness public landing page로 1차 재작성했고,
  `tools/git-hooks/pre-commit`을 Checkstyle 대신 diff/shell syntax check로 전환했다.
- 2026-05-22: Spring Boot-specific prompt bundle은 fallback/example value가 있어 제거하지 않고
  optional example pack으로 유지하기로 방향을 조정했다.
- 2026-05-22: `scripts/create-harness.sh` generic scaffold 안내에서 old runtime constants 치환식과
  `phase2/` Work category 예시를 제거했다. Generic dry-run은 계속 통과한다.
- 2026-05-22: `docs/ARCHITECTURE.md`, `docs/DEVELOPER-GUIDE.md`, `docs/CODING-CONVENTIONS.md`,
  `docs/works/README.md`를 AI Workflow Harness live surface로 전환했다.
  archived product Work category 경로는 active Work index에서 노출하지 않도록 정리했다.
- 2026-05-22: public-risk scan에서 실제 credential은 확인되지 않았다.
  깨진 로컬 MCP 설정(`.mcp.json`)은 제거했고, active docs/retrospective의 로컬 절대경로 노출은 정리했다.
- 2026-05-22: DR-007 언어 규정 준수 전수 검토 수행. 위반 발견 및 수정:
  `AGENTS.md` Branch Flow 한국어 예시 제거, `.claude/commands/close.md` 섹션 헤더 3개 영문 Title Case 전환,
  `prompts/codex-session-start.md` / `prompts/claude-session-start.md` 전체 섹션 헤더 영문 Title Case 전환,
  `README.md` 본문 Korean primary 전환(섹션 헤더 English Title Case 유지).
- 2026-05-22: `.cursor/config.json`이 Cursor 비동작 파일임을 확인하고 양쪽 레포(`ai-workflow-harness`, `base-msa-template`)에서 삭제.
  `scripts/create-harness.sh`에서 해당 파일 `adapt` 라인도 제거.
- 2026-05-22: Codex / Cursor가 문서 편집 시 DR-007 Bilingual Rules를 적용하지 않는 구조적 결함 발견.
  `.claude/rules/docs-workflow.md`의 path-scoped 자동 로딩과 달리 `AGENTS.md`는 DR-007을 commit message 맥락에만
  언급하고 문서 편집 trigger가 없었음. `AGENTS.md`와 `.cursor/rules/workflow.mdc`에 Document Language Policy 섹션 추가.
  scaffold 전파는 `adapt` 직접 복사 방식으로 자동 적용됨.
- 2026-05-22: `.cursor/rules/role-backend.mdc` 파일명/내용 불일치 발견.
  내용은 이미 Harness Maintainer Role로 교체되었으나 파일명은 Spring Boot 시절 이름을 유지하고 있었음.
  `role-harness-maintainer.mdc`로 rename하고 scaffold 배치도 spring-boot 조건 블록에서 generic 루프로 이동.
  `base-msa-template`의 동명 파일은 내용이 Spring Boot Backend Role 원본 그대로여서 소급 불필요.
- 2026-05-22: `.vscode/settings.json`이 VS Code 비동작 파일임을 확인하고 양쪽 레포에서 삭제.
  permissions 블록은 Claude Code 포맷으로 VS Code가 읽지 않으며, Spring Boot 잔재와 개인 임시 설정 포함.
  양쪽 레포 `.gitignore`에서 `.vscode/*` + 예외 패턴을 `.vscode/` 전체 ignore로 단순화.

### CP 진행 현황
- [x] CP-1 시작: Work file 생성 (2026-05-22)
- [x] CP-1 완료: STATUS/PLAN/index 정렬, `git diff --check` 통과 (2026-05-22)
- [x] CP-2 시작: read-only inventory scan 수행 (2026-05-22)
- [x] CP-2 완료: classification draft 작성 (2026-05-22)
- [x] CP-3 시작: product runtime/build/infra surface cleanup 1차 적용 (2026-05-22)
- [x] CP-3 완료: runtime/build cleanup, prompt example-pack 보존, core docs live surface 정렬 (2026-05-22)
- [x] CP-4 시작: README와 public-facing core docs 1차 정렬 (2026-05-22)
- [x] CP-4 완료: workflow manual/public summary/backlog residual stale surface 정리 (2026-05-22)
- [x] CP-5 시작: validation, stale scan, public-risk scan 수행 (2026-05-22)
- [x] CP-5 완료: PR/merge/public visibility 전환 준비 보고

### Closeout

- 2026-05-22: 사용자 최종 리뷰 완료 확인.
- 2026-05-22: `/close` 절차에 따라 Work status를 Done으로 전환. Archive는 별도 승인 전까지 대기.

## Retrospective

- [awh-001-migration-review-20260522.md](../../retrospectives/awh-001-migration-review-20260522.md) — Codex 중간 리뷰. P0/P1 항목 수정 완료, R-06~R-09는 후속 개선 후보로 이관
