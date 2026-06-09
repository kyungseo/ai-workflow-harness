# repo-health

Canonical workflow procedure for `/repo-health`.

이 파일은 workflow 상세 절차의 SSoT다. Tool-specific surface는 아래 adapter만 가진다.

| Tool | Adapter |
| --- | --- |
| Claude Code | `.claude/commands/repo-health.md` |
| Codex | `.agents/skills/workflow-repo-health/SKILL.md` |
| Cursor | `.cursor/rules/workflow.mdc` |

Adapter는 Step 0, hard-stop 요약, entry mechanism, fallback만 보유한다. 상세 절차, checklist, cascade 판단은 이 canonical 파일을 따른다.

## Procedure

프로젝트 워크플로우와 문서의 건강 상태를 점검하고 보고한다.

## Execution Principles

- **구현 금지**: 보고와 제안만 한다. 수정·생성·커밋은 사용자 승인 후에만 진행한다.
- **STATUS 보호**: `docs/STATUS.md` 변경 필요가 발견되면 즉시 수정하지 말고 Approval Matrix state rules에 맞게 보고한다.
- **컨텍스트 절약**: 현재 tool entrypoint(`AGENTS.md` 또는 `CLAUDE.md`)와 `docs/AGENT-WORKFLOW.md`는 세션 시작 시 로드됨 — 재읽기 금지.
  파일 목록·상태 확인은 full read 대신 `ls`, `rg` 명령을 우선 사용한다.
- **모드**:
  - (없음) → Quick 모드: A+B+E 영역, ~10개 타깃 읽기, 작업 블록 시작 전 사용
  - `--full` → 전체 모드: A+B+E+F+C+D 영역, 분기별·Phase 전환 전 사용
  - `--cascade` → changed-surface cascade audit: 변경 파일 유형에 맞는 canonical → tool-specific → user-facing → scaffold 계층을 선택하고, 해당 계층의 필수 surface/grep/simulation으로 drift를 발견·보고
  - `--full --cascade` → Phase 전환 전 또는 대형 harness 변경 후 전체 surface와 cascade를 함께 감사
  - `--cascade`에서 변경 파일이 없으면 Quick 모드(A+B+E)로 동작하고, 전체 cascade 감사가 필요하면 `--full --cascade`를 사용

## Mode Contract

| Mode | Required | Conditional | Must Report |
|---|---|---|---|
| Quick | STATUS current sections + tool surface listing (Phase 1-2) + A·B·E 영역 | suspicious mismatch 파일만 full read | current state, findings, skipped checks with reason |
| `--full` | Quick + Phase 3-5 + A·B·C·D·E·F·H 영역 | 최근 변경 surface 기반 selected docs | findings by severity, Context Budget Notes |
| `--cascade` | changed files → Required Surface Matrix → grep/simulation | user-facing·scaffold·historical은 선택된 유형에만 | selected surfaces, omitted surfaces with reason |
| `--full --cascade` | full health + G 영역 cascade completeness | release/phase 전환, 대형 harness 변경 | blocking findings, residual risk, follow-up plan |

Quick 모드는 가벼워야 한다. Area H(Workflow Context Weight) 활성 조건: `--full`에서 항상 활성화; `--cascade`에서는 변경 surface가 workflow context/load path와 관련될 때만 활성화; 변경 파일 없는 `--cascade`는 Quick 모드이므로 Area H skip.

## Output Contract

`/repo-health` 결과는 아래 7개 섹션 순서로 보고한다.

1. **Summary** — overall status (🟢/🟡/🔴) + 한 줄 결론
2. **Findings (P0/P1/P2)** — P0: flow break/state corruption/scaffold unusable · P1: surface drift/missing mirror/productivity regression · P2: wording hygiene/optional simplification
3. **Surface Coverage** — 확인한 파일 유형과 계층 목록
4. **Skipped / Not Applicable** — 실행하지 않은 체크와 이유 (조용히 생략 금지)
5. **Context Budget Notes** — (full/cascade) 읽은 파일 목록 요약, 의도적으로 읽지 않은 파일과 이유
6. **Verification Run** — 실행한 rg/bash/simulation 명령 요약
7. **Recommended Follow-Ups** — Scope/Files/Verification/Risk/Reversal Cost 포함 제안. state change는 제안만, 직접 수정 금지

Findings가 없으면 "No blocking findings"를 명시한다.
STATUS 변경이 필요한 항목은 Approval Matrix state rules에 맞는 제안 섹션으로 별도 제안한다.

## File Reading Order

**Phase 1 — Current State (1 file)**
`docs/STATUS.md` — tool entrypoint와 `docs/AGENT-WORKFLOW.md`는 이미 컨텍스트에 있으므로 스킵.

**Phase 2 — Workflow Structure (listing first)**
```bash
ls .agents/skills/     # Codex skill 수·이름 확인
ls .claude/commands/   # 대응 Claude command 수·이름 확인
ls .claude/rules/      # Claude rule 수·이름 확인
ls .cursor/rules/      # Cursor rule 수·이름 확인
ls .codex/             # Codex hook/config 파일 확인
ls tools/git-hooks/    # commit gate hook 파일 확인 (있는 경우만)
```
목록 이상 시에만 해당 파일 내용 확인. 정상이면 전체 로드하지 않는다.

**Phase 3 — Document Overview (section-level)**
`docs/HARNESS-PROTOCOL.md` (문서 지도·아이템 위치 결정표만) → `README.md` (구조 블록·AI workflow 섹션만)
→ `docs/PLAN-SUMMARY.md` (Project Summary, Core Files, Validation Defaults만)

(조건부) Validation, Approval Matrix, Commit Approval 정합성 확인이 필요하면
`docs/HARNESS-RECOVERY-VALIDATION.md`를 읽는다.

**Phase 4 — Alignment Check (--full only)**
`.cursor/rules/*.mdc` (frontmatter paths만) → `prompts/README.md` (인덱스만, 개별 파일 금지)

**Phase 5 — Implementation Sync (--full, Area F only)**
```bash
# 최근 30일 변경된 workflow/tool/scaffold 파일 목록
git log --since="30 days ago" --name-only --format="" | sort -u | rg "^(AGENTS.md|CLAUDE.md|README.md|docs/|prompts/|scripts/|\\.agents/|\\.codex/|\\.claude/|\\.cursor/|\\.github/)"
```
변경 파일 목록을 기반으로 관련 문서만 선택적 확인.
`docs/decisions/DR-*.md` 상태 확인:
```bash
rg -n "^# |^Status:" docs/decisions
```
제목과 Status 필드만 추출. 내용 읽기는 통합 후보로 의심되는 쌍에만 한정.

**Phase 6 — Cascade Checklist (--cascade only)**

변경된 파일 목록을 먼저 확인한다:

```bash
git diff --name-only
git diff --cached --name-only
```

변경 파일을 기준으로 필요한 layer만 선택적으로 읽는다. 전체 문서 일괄 로드는 금지한다.
`docs/WORKFLOW-MANUAL.md`는 평시 AI 실행 규칙 로드 대상이 아니며, `--cascade`에서 user-facing workflow drift를 확인할 때만 필요한 섹션을 읽는다.
예: slash command 설명, trigger reference, 사용자-visible workflow, scaffold 안내가 바뀐 경우.

> **Optional pack 참조 주의:** 아래 Required Surface Matrix·Grep Pack이 가리키는 `docs/WORKFLOW-MANUAL.md`, `docs/HARNESS-ARCHITECTURE.md`, `docs/HARNESS-MAINTAINER-GUIDE.md`는 Optional source pack이라 minimal scaffold에는 없을 수 있다. 해당 파일이 없으면 그 surface/grep 항목은 N/A로 처리하고, 필요하면 `scripts/create-harness.sh --with-optional`로 재생성하거나 source repo 문서를 참조한다.

`--cascade`는 변경 파일 기준으로 감사 대상을 좁힌다. 단, 선택된 파일 유형의 required surface, grep, simulation은 생략하지 않고, 누락·불일치·과잉반복·불필요복잡성·사용자생산성저하를 P0/P1/P2로 보고한다.
변경 파일이 없으면 Quick 모드(A+B+E)와 동일하게 동작한다.
전체 surface를 모두 훑어야 하면 `--full --cascade`를 사용한다.

> **검증 명령 카탈로그:** 아래 Surface Matrix·Grep Pack의 구체 grep 명령과 scaffold/onboarding 시뮬레이션 상세는 `docs/VERIFICATION-COMMANDS.md`(source repo 전용 maintainer 문서)에 Layer별로 정리되어 있다. 릴리즈 직전 전수 점검은 동 문서 "Release Full Sweep" 프리셋을 사용한다.

### Required Surface Matrix

| 변경 파일 유형 | Canonical | Tool-specific | User-facing | Scaffold | Historical |
| --- | --- | --- | --- | --- | --- |
| `docs/AGENT-WORKFLOW.md`, `docs/HARNESS-PROTOCOL.md` | 두 파일 모두 | `AGENTS.md`, `CLAUDE.md`, `.claude/commands/`, `.claude/rules/`, `.agents/skills/`, `.codex/hooks.json`, `.cursor/rules/`, `prompts/*` | `docs/HARNESS-QUICK-REFERENCE.md`, 관련 `docs/WORKFLOW-MANUAL.md` 섹션, `README.md` | `scripts/create-harness.sh`가 있으면 dry-run 또는 temp scaffold, 없으면 scaffold source 검증 제외 | 관련 retrospective는 snapshot 여부만 확인 |
| `.claude/commands/*.md` 또는 `.agents/skills/*/SKILL.md` | `docs/HARNESS-PROTOCOL.md`, `docs/AGENT-WORKFLOW.md` | 대응 `.agents/skills/workflow-{name}/SKILL.md` 또는 `.claude/commands/{name}.md` (suffix mapping: `.claude/commands/{name}.md` ↔ `.agents/skills/workflow-{name}/SKILL.md`), `AGENTS.md`, `.cursor/rules/workflow.mdc`, `prompts/*session-start.md` | `docs/HARNESS-QUICK-REFERENCE.md`, 관련 `docs/WORKFLOW-MANUAL.md` command 섹션 | command/skill 복사 산출물 | 필요 시 관련 Work/retrospective |
| `.claude/rules/*.md`, `.cursor/rules/*.mdc`, `.codex/hooks.json` | `docs/HARNESS-PROTOCOL.md`, `docs/AGENT-WORKFLOW.md` | 반대 tool rule, hook, prompts | 필요 시 manual/rules 설명 | rule/hook 복사 산출물 | 필요 시 관련 Work/retrospective |
| `prompts/*` | `docs/AGENT-WORKFLOW.md`, 필요 시 `docs/HARNESS-PROTOCOL.md` | `AGENTS.md`, `CLAUDE.md`, command/skill/rule/hook | `prompts/README.md`, 필요 시 manual prompt 섹션 | prompt 복사 산출물 | 필요 시 관련 Work/retrospective |
| `docs/WORKFLOW-MANUAL.md`, `README.md`, `docs/HARNESS-QUICK-REFERENCE.md` | `docs/AGENT-WORKFLOW.md`, `docs/HARNESS-PROTOCOL.md` | 관련 command/rule/prompt | 변경된 user-facing 문서 상호 참조 | 필요 시 scaffold README/manual 산출물 | snapshot 덮어쓰기 금지 |
| `scripts/create-harness.sh`가 존재할 때 | `docs/AGENT-WORKFLOW.md`, `docs/HARNESS-PROTOCOL.md`, `docs/SCAFFOLD-BOOTSTRAP.md` | commands/rules/prompts source | generated README/manual expectations | dry-run + temp scaffold + stale phrase search | 필요 시 related Work |
| `docs/SCAFFOLD-BOOTSTRAP.md` | `docs/HARNESS-PROTOCOL.md` | — | — | `scripts/create-harness.sh`가 있으면 생성 BOOTSTRAP.md 템플릿과 Boot Sequence·Completion Rule 동기화, 없으면 source repo 전용 기준으로 표시 | — |
| `docs/STATUS.md`, `docs/works/**`, `docs/backlog/**`, `docs/decisions/**` | `docs/HARNESS-PROTOCOL.md`, `docs/AGENT-WORKFLOW.md` | session-start/work-resume/work-close/session-summary/record-decision commands | quick reference/manual state sections | work/index scaffold templates | 관련 Work/DR/retrospective |
| `docs/GIT-WORKFLOW.md`, branch/release policy 변경 | `docs/AGENT-WORKFLOW.md` | `.claude/commands/work-plan.md`, `work-close.md`, 대응 SKILL mirror | `docs/WORKFLOW-MANUAL.md` branch 섹션, `docs/HARNESS-QUICK-REFERENCE.md` | `scripts/templates/source-gitflow/docs/GIT-WORKFLOW.md`, generated work-plan/work-close command | 관련 Work |
| `scripts/templates/**` 변경 | `docs/SCAFFOLD-BOOTSTRAP.md`, `docs/AGENT-WORKFLOW.md` | `scripts/create-harness.sh` | `docs/WORKFLOW-MANUAL.md` scaffold 섹션, `README.md` §10 | dry-run + fresh generation, generated command/skill/rule | 관련 Work |
| `.claude/commands/{x}.md` ↔ `.agents/skills/workflow-{x}/SKILL.md` mirror pair 변경 | `docs/HARNESS-PROTOCOL.md`, `docs/AGENT-WORKFLOW.md` | 대응 pair 전체 | `docs/HARNESS-QUICK-REFERENCE.md`, 관련 `docs/WORKFLOW-MANUAL.md` 섹션 | scaffold 복사 산출물 | 관련 Work/retrospective |
| `.claude/commands/repo-health.md` 또는 `.agents/skills/workflow-repo-health/SKILL.md` 변경 | `docs/AGENT-WORKFLOW.md` | SKILL mirror (또는 command mirror) | `docs/HARNESS-QUICK-REFERENCE.md` `/repo-health` 행, `docs/WORKFLOW-MANUAL.md` §5 `/repo-health` 셀 | scaffold 복사 산출물 health command/skill | — |
| `tools/git-hooks/**` 변경 | `docs/HARNESS-PROTOCOL.md` hook trigger section, `docs/AGENT-WORKFLOW.md` commit approval | `tools/git-hooks/install.sh` (설치 script), `tools/git-hooks/lib/gate-lists.sh` (protected 목록), `.harness/gate-config` | `docs/WORKFLOW-MANUAL.md` hook section, `docs/HARNESS-QUICK-REFERENCE.md` | `scripts/create-harness.sh` hook installation block | 관련 Work |

### Required Grep Pack

변경 파일 유형에 맞는 키워드를 골라 실행하고, 결과가 없으면 "no matches"로 보고한다.
기본 grep 대상은 live surface로 제한한다. `docs/archive/`, `docs/retrospectives/`, `docs/presentations/`, 과거 계획 snapshot은 변경 파일에 포함되었거나 사용자가 historical review를 요청한 경우에만 별도 검색한다.

```bash
# Live target set
LIVE_TARGETS=(
  AGENTS.md CLAUDE.md README.md
  docs/AGENT-WORKFLOW.md docs/HARNESS-PROTOCOL.md docs/HARNESS-QUICK-REFERENCE.md docs/WORKFLOW-MANUAL.md docs/STATUS.md
  docs/migrations/canonical-adapter-rename.md
  docs/backlog docs/decisions docs/works
  .agents .codex .claude .cursor prompts scripts tools
)

# Common stale path / old term check
rg -n "State Update Gate|Commit Gate|Scope And Commit Approval|docs/harness-protocol|harness-protocol/" \
  "${LIVE_TARGETS[@]}"

# Command / rule / prompt alignment
rg -n "Approval Matrix|Quick Mode|Active Work|Done|Archived|/work-close|/session-summary|/repo-health|/record-decision|--cascade" \
  "${LIVE_TARGETS[@]}"

# User-facing drift
rg -n "/session-start|/work-select|/work-plan|/work-resume|/work-close|/session-summary|/repo-health|/record-decision|Quick Mode|Approval Matrix|cascade|scaffold" \
  docs/WORKFLOW-MANUAL.md docs/HARNESS-QUICK-REFERENCE.md README.md

# Scaffold drift
if test -f scripts/create-harness.sh; then
  rg -n "HARNESS-PROTOCOL|AGENT-WORKFLOW|WORKFLOW-MANUAL|Quick Mode|Approval Matrix|/repo-health|/record-decision|--cascade" \
    scripts/create-harness.sh
else
  echo "skip: scripts/create-harness.sh not present in this repository"
fi

# State / tracking finalization
rg -n "STATUS Finalization|Tracking Finalization|Active Work|status: Done|status: Active" \
  "${LIVE_TARGETS[@]}"

# Branch / scaffold policy
# source-gitflow 체크는 GIT-WORKFLOW.md 또는 scripts/templates/** 변경 시, 또는 --full/--cascade 실행 시 적용한다.
# default scaffold 기준 점검에서는 이 결과가 guarded implementation surface(commands/skills/rules)에
# 나타나는 것은 정상이며, user-facing policy 문서에 누출되는지만 확인한다.
rg -n "source-gitflow|policy_type: source-gitflow|Public Clean Baseline Gate|pre-commit" \
  docs/STATUS.md docs/BOOTSTRAP.md docs/PLAN-SUMMARY.md \
  docs/WORKFLOW-MANUAL.md docs/HARNESS-QUICK-REFERENCE.md README.md 2>/dev/null \
  && echo "WARN: check whether above are policy leakage or expected references" \
  || echo "no matches in user-facing policy docs"

# Context / load path — workflow context weight 점검
# command/skill/prompt이 trigger 없이 heavy docs를 상시 로드하도록 지시하지 않는지 확인한다.
rg -n "HARNESS-PROTOCOL|WORKFLOW-MANUAL|항상.*읽|전체.*로드|기본.*로드|always.*load" \
  .claude/commands/ .agents/skills/ prompts/ 2>/dev/null
```

Historical matches are not automatically drift. Report them separately as snapshot references unless they appear in live execution, guide, or scaffold surfaces.

### Required Simulation Matrix

| 변경 파일 유형 | 반드시 시뮬레이션할 흐름 |
| --- | --- |
| Canonical workflow/protocol | `/session-start`, `/work-select`, `/work-plan`, `/work-resume`, `/work-close`, `/session-summary`, archive trigger, state-change proposal, quick mode, scaffold |
| Command/rule/prompt | 해당 command 흐름, `/work-plan`, `/work-resume`, `/session-summary`, state-change proposal, tool surface cascade, scaffold |
| User-facing manual/quick reference/README | 사용자 설명과 실제 command/canonical 흐름 대조, quick mode, close/session-summary, scaffold |
| Scaffold source | 신규 프로젝트 scaffold, 기존 프로젝트 adoption, generated command/rule/prompt/manual 경로 검색 |
| Work/status/backlog/DR | `/session-start`, `/work-select`, `/work-plan`, `/work-resume`, `/work-close`, archive trigger, STATUS update gate |
| `docs/GIT-WORKFLOW.md` 또는 branch policy 변경 | source repo `develop`에서 Branch Isolation FAIL, `feature/*`에서 PASS; default scaffold에서 marker 없음 → gate 비활성화 |
| `scripts/create-harness.sh` 또는 `scripts/templates/**` 변경 | default scaffold 생성 — `docs/GIT-WORKFLOW.md` 미생성·source-gitflow marker 없음; source-gitflow scaffold 생성 — marker 있음·source-repo-only 참조 없음 |
| Workflow Context Weight (--full / --cascade) | session startup clean idle → STATUS current만 읽고 archive/history 미확장; `/work-plan` backlog candidate → Work ID 확정 필요 정보만; `/work-resume` → Work/STATUS/file state 우선, unrelated backlog·manual 기본 로드 없음; `/work-close` feature branch → Done 처리와 commit strategy 분리, release gate detail 불필요 시 skip; commit/PR finalization → STATUS/Tracking finalization 수행, 전체 protocol 반복 로드 없음; scaffold onboarding → STATUS Next Actions pointer 없이 BOOTSTRAP.md 자동 로드 없음 |

선택하지 않은 시나리오는 `Skipped / Not Applicable`에 이유를 적는다.

## Inspection Areas

### A. Workflow Structure Consistency

- 각 slash command: 트리거 조건 명확성, Done Criteria 존재, 승인 대기 명시 여부
  (Phase 2에서 목록 확인 후 의심 항목만 내용 확인)
- 각 `.claude/rules/*.md`, `.cursor/rules/*.mdc`: `paths` glob이 실제 디렉토리 구조와 일치하는가
- 각 `.agents/skills/*/SKILL.md`: 대응 `.claude/commands/*.md`와 의미상 정렬되는가
- `.codex/hooks.json`: hook reminder가 `/work-close`/`/session-summary` 분리와 STATUS/Tracking Finalization을 반영하는가
- `docs/AGENT-WORKFLOW.md` 워크플로우 기술 ↔ 실제 command 구현 사이 gap
  (이미 컨텍스트에 있는 docs/AGENT-WORKFLOW.md 기준으로 확인)
- command/prompt 종료 요약 ↔ `docs/HARNESS-RECOVERY-VALIDATION.md`의 Validation Checklist/Commit Approval 및 `docs/AGENT-WORKFLOW.md`의 Approval Matrix 정합성
- STATUS.md Active Work pointer가 가리키는 Work 파일에 Done Criteria + Verification이 존재하는가
- STATUS.md Active Work pointer ↔ Work 파일 frontmatter `status: Active` 정합성
- `docs/works/*/*.md` 중 `status: Done`인 Work가 STATUS Active Work에 남아 있지 않은가
- `docs/works/*/README.md` index가 Work 파일 상태(Active/Done/Archived)와 일치하는가
- `docs/decisions/README.md` index가 `docs/decisions/DR-*.md` 실제 파일 목록과 일치하는가
- `docs/retrospectives/README.md` index가 `docs/retrospectives/` 실제 파일 목록과 일치하는가
- archive 위치의 Work 파일은 `status: Archived`인가
- DR 생애주기 양방향: STATUS.md Recent Decisions ↔ `rg` 결과의 DR Status 일치
- workflow command 또는 skill을 수정한 Active Work의 CP/commit: `.claude/commands/{name}.md`와 `.agents/skills/workflow-{name}/SKILL.md`가 같은 CP/commit에 함께 반영됐는지 확인 (docs/HARNESS-PARALLEL-WORK-CONTROLS.md §Command/Skill Mirror Atomicity)

### B. Document Cross-Consistency

- HARNESS-PROTOCOL.md 단일 상세 protocol 구조 ↔ 실제 파일 목록 일치
- README.md 프로젝트 구조 블록 ↔ 실제 디렉토리 구조
  ```bash
  ls -d */ .github .agents .codex .claude .cursor .devcontainer 2>/dev/null
  ```
- `.claude/rules/*.md` ↔ `.cursor/rules/*.mdc` 정렬 (DR-007 준수 여부)
  (파일 수·파일명 비교로 1차 확인, 내용 비교는 불일치 시에만)
- `.claude/commands/{name}.md` ↔ `.agents/skills/workflow-{name}/SKILL.md` 정렬 (suffix mapping 기준)
  (파일 수·파일명 비교 후, 의심 항목만 내용 비교)
- Language Rules 위반 (DR-007):
  - `docs/*.md`가 영어 작성, `.claude/rules/*.md` 또는 `.cursor/rules/*.mdc`가 한국어 작성된 경우
  - Bilingual Rules 위반: `docs/*.md`, `.claude/commands/*.md`, `.agents/skills/*/SKILL.md`에서 섹션 타이틀 한국어 표기, 기술 용어 음차, 성능 지표 한글화
- STATUS.md Next Actions 순서 ↔ Active Work pointer / Work file frontmatter 논리 일관성
- **Embedded Diagram 참조 유효성** (Mermaid 등):
  ```bash
  rg -l '```mermaid' docs/ README.md 2>/dev/null
  ```
  발견된 파일별로 다이어그램 노드·라벨·경로가 현재 프로젝트 상태와 일치하는지 확인한다.
  - `docs/AGENT-WORKFLOW.md` state machine — `INIT→PLAN→APPROVAL→EXECUTE→VALIDATE→CHECKPOINT→END` 순서와 RECOVER/FAIL 분기가 `.claude/commands/`, `.agents/skills/` 구현 및 `docs/HARNESS-PROTOCOL.md`와 일치하는가
  - 노드 라벨이 실제 존재하지 않는 파일 경로·서비스명·상태를 참조하면 drift로 보고
  - 렌더링 없이 구문 유효성(syntax)을 확인할 수 없는 항목은 "수동 검토 권고"로 보고

### C. Tool Feature Alignment (--full)

- `.claude/settings.json`: `defaultMode`, `permissions.deny` 목록 현행성, hooks 설정
- `.agents/skills/`: Codex command skill frontmatter와 대응 command coverage
- `.codex/hooks.json`: Codex hook 설정 현행성
- MCP 서버 설정 상태 및 실제 활용 가능성
- Phase 2에서 읽은 rule/command 기반으로 중복 instruction·비효율 탐지
  (추가 파일 로드 없이 이미 확인한 내용에서 판단)

### D. Vibe Coding / Prompt Engineering (--full)

- plan→approve→implement 3단계가 모든 command에 명시적으로 강제되는가
  (Phase 2 목록 확인 시 의심 항목만 내용 확인)
- 트리거 조건이 "상황에 따라"처럼 모호하게 기술된 항목
- 각 command의 출력 형식이 명시되어 있는가
- `prompts/README.md` 인덱스 기준으로 Phase 2 대비 누락 유형 확인
  (개별 prompt 파일은 로드하지 않는다)

### E. Backlog/DR Hygiene

- Work 파일: Verification 완료되었으나 Done 처리가 지연된 Active 항목
- Work 파일: `status: Done`인데 archive 대기 상태로 2세션 이상 남은 항목
- `docs/backlog/PRODUCT.md`: product/preparation 항목 중 선행 조건이 이미 충족된 항목, 범위·우선순위 재검토 필요 항목
  ```bash
  # 상태 확인 예시 — alternation은 | 사용 (\| 아님)
  rg "Candidate|In Progress" docs/backlog/PRODUCT*.md
  ```
- `docs/backlog/HARNESS.md`: harness 항목 중 완료되었거나 새 상태 머신과 충돌하는 항목, hard enforcement 후보
- DR 상태 확인 (Phase 5 `rg` 결과 재사용):
  - **Draft DR hygiene surfacing (DR-029)**: 모든 `Status: Draft` DR을 나열하고 각 age(Date 기준)와 함께 promote / supersede / drop 중 어느 처리가 필요한지 soft하게 안내한다. hard gate(만료 강제) 아님. Draft 내용 자체는 cascade 감사 대상이 아니다(감사는 Accepted-only).
  - Draft 상태이나 결정이 실질적으로 완료된 DR → Accepted 승격 제안 (승격 절차: `record-decision.md §Draft DR`)
  - STATUS.md Blockers/OQ 중 이미 해소되었으나 Closed 처리 누락
  - DR ↔ backlog 연결: `Linked Backlog Items` 섹션 누락·오기
- **DR 삭제/통합/Superseded 후보 식별**:
  - *1단계 (파일명 기반)*: DR 파일명에서 주제 키워드 추출 → 유사 주제 후보 그루핑
  - *2단계 (내용 확인)*: 1단계에서 의심되는 쌍에 한해서만 내용 비교
  - 폐기 후보: Draft 장기 유지 + 연결 backlog 없음 + 관련 OQ Closed → `Draft (Dropped)` 처리 제안(DR-029)
  - 통합 후보: 동일·유사 주제 복수 DR (1단계 필터 후 확인)
  - Superseded 후보: 이후 결정으로 실질적으로 대체되었으나 Accepted 유지
  - 후보 발견 시, cascade 업데이트 대상을 함께 제시:
    `docs/STATUS.md` / 관련 backlog(`PRODUCT.md` 또는 `HARNESS.md`) DR 참조 항목 /
    `docs/PLAN-SUMMARY.md` DR 범위 / 연관 DR 파일

### F. Implementation Sync (--full)

Phase 5의 git log 결과를 기준으로, 변경된 구현 파일 유형별로 관련 문서만 선택 확인한다.

| 변경 파일 유형 | 확인 대상 문서 |
|---------------|---------------|
| `AGENTS.md`, `CLAUDE.md` | `docs/AGENT-WORKFLOW.md`, `docs/HARNESS-PROTOCOL.md`, 관련 session prompt |
| `docs/AGENT-WORKFLOW.md`, `docs/HARNESS-PROTOCOL.md`, `docs/HARNESS-QUICK-REFERENCE.md` | `.claude/commands/*.md`, `.claude/rules/*.md`, `.agents/skills/*/SKILL.md`, `.codex/hooks.json`, `.cursor/rules/*.mdc`, `prompts/*session-start.md` |
| `docs/STATUS.md`, `docs/PLAN.md`, `docs/PLAN-SUMMARY.md` | Active Work 파일, `docs/works/*/README.md`, 관련 backlog |
| `.github/workflows/*.yml` | `docs/GIT-WORKFLOW.md`, `.cursor/rules/execution.mdc`, `README.md` CI 항목 |
| `.claude/commands/*.md`, `.agents/skills/*/SKILL.md`, `.claude/rules/*.md`, `.codex/hooks.json` | `docs/HARNESS-PROTOCOL.md`, `docs/HARNESS-QUICK-REFERENCE.md`, 대응 `.agents/skills/` 또는 `.claude/commands/`, 대응 `.cursor/rules/*.mdc` |
| `.cursor/rules/*.mdc` | `docs/AGENT-WORKFLOW.md`, 대응 `.claude/rules/*.md`, 관련 session prompt |
| `scripts/create-harness.sh`가 존재할 때 | `README.md`, `docs/WORKFLOW-MANUAL.md`, fresh scaffold 산출물 |
| `prompts/*.md` | `prompts/README.md`, `docs/AGENT-WORKFLOW.md` context routing, scaffold profile 포함 여부 |
| `docs/decisions/DR-*.md` (신규 Accepted) | `docs/STATUS.md` Recent Decisions, 연관 backlog Done Criteria |
| `docs/*.md` (신규 사용자/운영 문서) | 해당 문서가 참조하는 command/rule/script/CI 파일과 실제 내용 대조 |

STATUS.md Recent Decisions는 **최근 8개 rolling window**, 항목 품질(후속 행동을 바꾸는 판단만), DR-worthy 항목의 대응 DR 존재 여부를 점검한다.
전체 이력 점검은 명시적 요청 시에만 진행한다.

`docs/HARNESS-MAINTAINER-GUIDE.md`는 아래 변경이 감지될 때만 읽는다:
- 새 도구 도입 (git hooks 등)
- scaffold 절차 또는 convention 정책 변경

`docs/PLAN.md`는 제목·섹션 헤더 수준만 확인한다:
```bash
rg -n "^## |^### " docs/PLAN.md
```

### G. Cascade/Trigger Completeness (--cascade)

문서를 하나 고쳤을 때 어디까지 같이 봐야 하는지 점검한다.
기준은 `docs/HARNESS-PROTOCOL.md`이며, 실제 command/rule/prompt/manual/scaffold 표면이 이 기준을 필요한 만큼 반영하는지 확인한다.

- 변경된 파일을 Required Surface Matrix의 파일 유형으로 분류한다.
- 해당 행의 canonical / tool-specific / user-facing / scaffold / historical surface를 확인한다.
- Required Grep Pack에서 관련 명령을 실행하거나, 실행하지 않은 이유를 기록한다.
- Required Simulation Matrix에서 관련 흐름을 선택해 논리 시뮬레이션한다.
- scaffold source가 있고 그 파일이 바뀌었으면 `scripts/create-harness.sh --dry-run`과 필요 시 temp scaffold 생성으로 산출물 drift를 확인한다. scaffold source가 없는 적용 repository에서는 이 항목을 Skipped / Not Applicable로 보고한다.
- historical retrospective는 snapshot인지 live follow-up log인지 구분한다. snapshot이면 기존 내용을 덮어쓰지 않고 append 제안만 한다.
- 반복 문구를 다음으로 분류한다:
  - Required mirror — 도구 진입점에서 반드시 보여야 하는 반복
  - Acceptable reminder — 사용자 실수를 줄이는 짧은 반복
  - Excessive duplication — 같은 layer 안에서 의미 없이 반복되는 문구
  - Stale contradiction — canonical과 충돌하는 오래된 문구
- trigger/cascade 변경 시 loop risk를 확인한다:
  - 같은 문서군을 서로 재발동시키는가
  - Approval Matrix state rules를 우회하는가
  - Product track Quick Mode와 harness/workflow surface 기본 L2 경계를 흐리게 만드는가
  - scaffold 검증이 자기 자신을 무한히 요구하는가

Coverage rule:

- `--cascade`는 changed-surface 기준으로 범위를 줄일 수 있지만, 선택한 파일 유형의 layer coverage는 유지한다.
- `--full --cascade`는 전체 surface 감사이며 범위를 임의로 줄이지 않는다.
- 선택하지 않은 surface, grep, simulation은 반드시 `Skipped / Not Applicable`에 이유를 남긴다.
- 판단이 애매하면 통과 처리하지 말고 `Requires manual judgment`로 보고한다.

### H. Workflow Context Weight (--full / --cascade)

활성 조건: `--full`에서 항상 실행. `--cascade`에서는 변경 surface가 command/skill/prompt 로드 지시, workflow load path, `AGENT-WORKFLOW` 등 context weight와 관련된 파일을 포함할 때만 실행. 변경 파일 없는 `--cascade`는 Quick 모드이므로 Area H skip.

`/repo-health` 자체의 token 사용량보다 더 중요한 목적은 **일상 workflow operating model이 시간이 지나며 불필요하게 무거워지는 현상을 감지**하는 것이다.
각 workflow path가 필요한 표면만 읽고 있는지 점검한다. report-only — 자동 수정 없음.

점검 방법: `CLAUDE.md`, `docs/AGENT-WORKFLOW.md`, 각 command/skill 파일의 로드 지시 문구를 listing + rg로 확인한다. 파일 전체 read 없이 pattern matching으로 판단한다.

| Workflow path | 점검 질문 |
|---|---|
| Session startup / `/session-start` | `BEHAVIOR-PRINCIPLES`, `AGENT-WORKFLOW`, `STATUS` current sections를 넘어 archive/history/manual을 기본 로드하도록 지시하지 않는가 |
| `/work-plan` | Work ID 확정 및 계획 수립에 필요한 정보만 로드하는가. naming detail 전체, branch policy 전체를 trigger 없이 상시 읽지 않는가 |
| `/work-resume` | Work/STATUS/file state를 우선하고, 무관한 backlog/manual/retrospective를 기본 로드하지 않는가 |
| `/work-close` | Work Done 처리와 commit strategy를 분리하는가. release gate detail은 branch context가 필요할 때만 확인하는가 |
| Commit/PR finalization | STATUS/Tracking finalization을 수행하되, 전체 protocol/manual을 반복 로드하지 않는가 |
| Scaffold onboarding | `STATUS.md` Next Actions pointer 없이 `BOOTSTRAP.md`를 자동 로드하도록 지시하지 않는가 |
| `/repo-health` 자체 | Quick 모드가 Area H를 실행하지 않는가. command가 report-only를 유지하고 state change를 발생시키지 않는가 |

finding category: **"Workflow Context Weight"** — 일상 workflow가 heavy해진 지점을 P1로 보고한다.
heavy doc 기준: `HARNESS-PROTOCOL.md` 전체, `WORKFLOW-MANUAL.md`, archive/retrospectives/PLAN, session-start 없이 자동 로드 지시.

## Report Format

```
## 1. Summary
Overall Status: [🟢 Good / 🟡 Needs Attention / 🔴 Action Required]
한 줄 결론.

## 2. Findings (P0/P1/P2)

### Area Summary
| Area | Status | Items Found |
|------|--------|-------------|
| A. Structure Consistency        | 🟢/🟡/🔴 | n건 |
| B. Document Consistency         | 🟢/🟡/🔴 | n건 |
| E. Backlog/DR Hygiene           | 🟢/🟡/🔴 | n건 |
| (F. Implementation Sync)        | 🟢/🟡/🔴 | n건 |
| (G. Cascade Completeness)       | 🟢/🟡/🔴 | n건 |
| (H. Workflow Context Weight)    | 🟢/🟡/🔴 | n건 |

### Detailed Findings
- [✓ / ⚠ / ✗] 항목명: 세부 내용

### P0/P1/P2
- P0 — flow break / state corruption / scaffold unusable:
- P1 — surface drift / missing mirror / productivity regression / Workflow Context Weight heavy:
- P2 — over-duplication / wording hygiene / optional simplification:

Findings가 없으면 "No blocking findings"를 명시한다.

## 3. Surface Coverage
- 확인한 파일 유형과 계층 목록

## 4. Skipped / Not Applicable
- 항목명: 이유 (조용히 생략 금지)

## 5. Context Budget Notes (--full / --cascade)
- 읽은 파일 목록 (요약)
- 의도적으로 읽지 않은 파일과 이유

## 6. Verification Run
- 실행한 rg / bash / simulation 명령 요약

## 7. Recommended Follow-Ups
- Fix now: [Scope / Files / Verification / Risk / Reversal Cost 포함]
- Split into separate Work/DR:
- No action:
```

STATUS.md 변경이 필요한 발견 항목은 Approval Matrix state rules에 맞는 제안 섹션으로 별도 제안한다.
보고 후 "승인하신 항목부터 진행할까요?"로 끝낸다.
