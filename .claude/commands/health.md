---
description: "프로젝트 워크플로우와 문서 건강 상태를 점검하고 보고한다. 옵션: --full, --cascade"
argument-hint: "[--full] [--cascade]"
disable-model-invocation: true
---

프로젝트 워크플로우와 문서의 건강 상태를 점검하고 보고한다.

## Execution Principles

- **구현 금지**: 보고와 제안만 한다. 수정·생성·커밋은 사용자 승인 후에만 진행한다.
- **STATUS 보호**: `docs/STATUS.md` 변경 필요가 발견되면 즉시 수정하지 말고 Approval Matrix state rules에 맞게 보고한다.
- **컨텍스트 절약**: `CLAUDE.md`와 `docs/AGENT-WORKFLOW.md`는 세션 시작 시 자동 로드됨 — 재읽기 금지.
  파일 목록·상태 확인은 full read 대신 `ls`, `rg` 명령을 우선 사용한다.
- **모드**:
  - (없음) → Quick 모드: A+B+E 영역, ~10개 타깃 읽기, 작업 블록 시작 전 사용
  - `--full` → 전체 모드: A+B+E+F+C+D 영역, 분기별·Phase 전환 전 사용
  - `--cascade` → coverage-preserving checklist runner: canonical → tool-specific → user-facing → scaffold 계층을 유지하고, 변경 파일 유형별 필수 surface/grep/simulation으로 drift를 발견·보고
  - `--full --cascade` → Phase 전환 전 또는 대형 harness 변경 후 전체 구조와 cascade를 함께 감사

## File Reading Order

**Phase 1 — Current State (1 file)**
`docs/STATUS.md` — CLAUDE.md·docs/AGENT-WORKFLOW.md는 이미 컨텍스트에 있으므로 스킵.

**Phase 2 — Workflow Structure (listing first)**
```bash
ls .claude/commands/    # 파일 수·이름 확인
ls .claude/rules/       # 파일 수·이름 확인
```
목록 이상 시에만 해당 파일 내용 확인. 정상이면 전체 로드하지 않는다.

**Phase 3 — Document Overview (section-level)**
`docs/HARNESS-PROTOCOL.md` (문서 지도·아이템 위치 결정표만) → `README.md` (구조 블록·AI workflow 섹션만)
→ `docs/PLAN-SUMMARY.md` (기술 스택 테이블만)

(조건부) Validation, Approval Matrix, Commit Approval 정합성 확인이 필요하면
`docs/HARNESS-PROTOCOL.md`의 Recovery And Validation 섹션만 읽는다.

**Phase 4 — Alignment Check (--full only)**
`.cursor/rules/*.mdc` (frontmatter paths만) → `prompts/README.md` (인덱스만, 개별 파일 금지)

**Phase 5 — Implementation Sync (--full, Area F only)**
```bash
# 최근 30일 변경된 구현 파일 목록
git log --since="30 days ago" --name-only --format="" | sort -u | rg "\.(java|kts|yml|xml|sh)$"
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

`--cascade`는 감사 범위를 줄이지 않는다. AI가 즉흥적으로 판단하는 대신, 변경 파일 유형별 필수 확인 항목을 실행하고 누락·불일치·과잉반복·불필요복잡성·사용자생산성저하를 P0/P1/P2로 보고한다.

### Required Surface Matrix

| 변경 파일 유형 | Canonical | Tool-specific | User-facing | Scaffold | Historical |
| --- | --- | --- | --- | --- | --- |
| `docs/AGENT-WORKFLOW.md`, `docs/HARNESS-PROTOCOL.md` | 두 파일 모두 | `AGENTS.md`, `CLAUDE.md`, `.claude/commands/`, `.claude/rules/`, `.cursor/rules/`, `prompts/*` | `docs/HARNESS-QUICK-REFERENCE.md`, 관련 `docs/WORKFLOW-MANUAL.md` 섹션, `README.md` | `scripts/create-harness.sh`, dry-run 또는 temp scaffold | 관련 retrospective는 snapshot 여부만 확인 |
| `.claude/commands/*.md` | `docs/HARNESS-PROTOCOL.md`, `docs/AGENT-WORKFLOW.md` | `AGENTS.md`, `.cursor/rules/workflow.mdc`, `prompts/*session-start.md` | `docs/HARNESS-QUICK-REFERENCE.md`, 관련 `docs/WORKFLOW-MANUAL.md` command 섹션 | command 복사 산출물 | 필요 시 관련 Work/retrospective |
| `.claude/rules/*.md`, `.cursor/rules/*.mdc` | `docs/HARNESS-PROTOCOL.md`, `docs/AGENT-WORKFLOW.md` | 반대 tool rule, prompts | 필요 시 manual/rules 설명 | rule 복사 산출물 | 필요 시 관련 Work/retrospective |
| `prompts/*` | `docs/AGENT-WORKFLOW.md`, 필요 시 `docs/HARNESS-PROTOCOL.md` | `AGENTS.md`, `CLAUDE.md`, command/rule | `prompts/README.md`, 필요 시 manual prompt 섹션 | prompt 복사 산출물 | 필요 시 관련 Work/retrospective |
| `docs/WORKFLOW-MANUAL.md`, `README.md`, `docs/HARNESS-QUICK-REFERENCE.md` | `docs/AGENT-WORKFLOW.md`, `docs/HARNESS-PROTOCOL.md` | 관련 command/rule/prompt | 변경된 user-facing 문서 상호 참조 | 필요 시 scaffold README/manual 산출물 | snapshot 덮어쓰기 금지 |
| `scripts/create-harness.sh` | `docs/AGENT-WORKFLOW.md`, `docs/HARNESS-PROTOCOL.md` | commands/rules/prompts source | generated README/manual expectations | dry-run + temp scaffold + stale phrase search | 필요 시 related Work |
| `docs/STATUS.md`, `docs/works/**`, `docs/backlog/**`, `docs/decisions/**` | `docs/HARNESS-PROTOCOL.md`, `docs/AGENT-WORKFLOW.md` | start/resume/close/done/record-decision commands | quick reference/manual state sections | work/index scaffold templates | 관련 Work/DR/retrospective |

### Required Grep Pack

변경 파일 유형에 맞는 키워드를 골라 실행하고, 결과가 없으면 "no matches"로 보고한다.
기본 grep 대상은 live surface로 제한한다. `docs/archive/`, `docs/retrospectives/`, `docs/presentations/`, 과거 계획 snapshot은 변경 파일에 포함되었거나 사용자가 historical review를 요청한 경우에만 별도 검색한다.

```bash
# Live target set
LIVE_TARGETS=(
  AGENTS.md CLAUDE.md README.md
  docs/AGENT-WORKFLOW.md docs/HARNESS-PROTOCOL.md docs/HARNESS-QUICK-REFERENCE.md docs/WORKFLOW-MANUAL.md docs/STATUS.md
  docs/backlog docs/decisions docs/works
  .claude .cursor prompts scripts
)

# Common stale path / old term check
rg -n "State Update Gate|Commit Gate|Scope And Commit Approval|docs/harness-protocol|harness-protocol/" \
  "${LIVE_TARGETS[@]}"

# Command / rule / prompt alignment
rg -n "Approval Matrix|Quick Mode|Active Work|Done|Archived|/close|/done|/health|--cascade" \
  "${LIVE_TARGETS[@]}"

# User-facing drift
rg -n "/start|/pick|/work|/resume|/close|/done|/health|Quick Mode|Approval Matrix|cascade|scaffold" \
  docs/WORKFLOW-MANUAL.md docs/HARNESS-QUICK-REFERENCE.md README.md

# Scaffold drift
rg -n "HARNESS-PROTOCOL|AGENT-WORKFLOW|WORKFLOW-MANUAL|Quick Mode|Approval Matrix|/health|--cascade" \
  scripts/create-harness.sh
```

Historical matches are not automatically drift. Report them separately as snapshot references unless they appear in live execution, guide, or scaffold surfaces.

### Required Simulation Matrix

| 변경 파일 유형 | 반드시 시뮬레이션할 흐름 |
| --- | --- |
| Canonical workflow/protocol | `/start`, `/pick`, `/work`, `/resume`, `/close`, `/done`, archive trigger, state update, quick mode, scaffold |
| Command/rule/prompt | 해당 command 흐름, `/work`, `/resume`, `/done`, state update, tool surface cascade, scaffold |
| User-facing manual/quick reference/README | 사용자 설명과 실제 command/canonical 흐름 대조, quick mode, close/done, scaffold |
| Scaffold source | 신규 프로젝트 scaffold, 기존 프로젝트 adoption, generated command/rule/prompt/manual 경로 검색 |
| Work/status/backlog/DR | `/start`, `/pick`, `/work`, `/resume`, `/close`, archive trigger, STATUS update gate |

선택하지 않은 시나리오는 `Skipped / Not Applicable`에 이유를 적는다.

## Inspection Areas

### A. Workflow Structure Consistency

- 각 slash command: 트리거 조건 명확성, Done Criteria 존재, 승인 대기 명시 여부
  (Phase 2에서 목록 확인 후 의심 항목만 내용 확인)
- 각 `.claude/rules/*.md`: `paths` glob이 실제 디렉토리 구조와 일치하는가
- `docs/AGENT-WORKFLOW.md` 워크플로우 기술 ↔ 실제 command 구현 사이 gap
  (이미 컨텍스트에 있는 docs/AGENT-WORKFLOW.md 기준으로 확인)
- command/prompt 종료 요약 ↔ `docs/HARNESS-PROTOCOL.md`의 Validation Checklist, Approval Matrix, Commit Approval 정합성
- STATUS.md Active Work pointer가 가리키는 Work 파일에 Done Criteria + Verification이 존재하는가
- STATUS.md Active Work pointer ↔ Work 파일 frontmatter `status: Active` 정합성
- `docs/works/*/*.md` 중 `status: Done`인 Work가 STATUS Active Work에 남아 있지 않은가
- `docs/works/*/README.md` index가 Work 파일 상태(Active/Done/Archived)와 일치하는가
- archive 위치의 Work 파일은 `status: Archived`인가
- DR 생애주기 양방향: STATUS.md Recent Decisions ↔ `rg` 결과의 DR Status 일치

### B. Document Cross-Consistency

- HARNESS-PROTOCOL.md 단일 상세 protocol 구조 ↔ 실제 파일 목록 일치
- README.md 프로젝트 구조 블록 ↔ 실제 디렉토리 구조
  ```bash
  ls -d */ .github .claude .cursor .devcontainer 2>/dev/null
  ```
- `.claude/rules/*.md` ↔ `.cursor/rules/*.mdc` 정렬 (DR-007 준수 여부)
  (파일 수·파일명 비교로 1차 확인, 내용 비교는 불일치 시에만)
- Language Rules 위반 (DR-007):
  - `docs/*.md`가 영어 작성, `.claude/rules/*.md`가 한국어 작성된 경우
  - Bilingual Rules 위반: `docs/*.md`, `.claude/commands/*.md`에서 섹션 타이틀 한국어 표기, 기술 용어 음차, 성능 지표 한글화
- STATUS.md Next Actions 순서 ↔ Active Work Priority/Status 논리 일관성
- **Embedded Diagram 참조 유효성** (Mermaid 등):
  ```bash
  rg -l '```mermaid' docs/ README.md 2>/dev/null
  ```
  발견된 파일별로 다이어그램 노드·라벨·경로가 현재 프로젝트 상태와 일치하는지 확인한다.
  - `docs/AGENT-WORKFLOW.md` state machine — `INIT→PLAN→APPROVAL→EXECUTE→VALIDATE→CHECKPOINT→END` 순서와 RECOVER/FAIL 분기가 `.claude/commands/` 구현 및 `docs/HARNESS-PROTOCOL.md`와 일치하는가
  - 노드 라벨이 실제 존재하지 않는 파일 경로·서비스명·상태를 참조하면 drift로 보고
  - 렌더링 없이 구문 유효성(syntax)을 확인할 수 없는 항목은 "수동 검토 권고"로 보고

### C. Claude Code Feature Alignment (--full)

- `.claude/settings.json`: `defaultMode`, `permissions.deny` 목록 현행성, hooks 설정
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
- `docs/backlog/PHASE{n}.md`: product/preparation 항목 중 선행 조건이 이미 충족된 항목, 범위·우선순위 재검토 필요 항목
  ```bash
  # 상태 확인 예시 — alternation은 | 사용 (\| 아님)
  rg "Candidate|In Progress" docs/backlog/PHASE*.md
  ```
- `docs/backlog/HARNESS.md`: harness 항목 중 완료되었거나 새 상태 머신과 충돌하는 항목, hard enforcement 후보
- DR 상태 확인 (Phase 5 `rg` 결과 재사용):
  - Draft 상태이나 결정이 실질적으로 완료된 DR → Accepted 처리 필요
  - STATUS.md Blockers/OQ 중 이미 해소되었으나 Closed 처리 누락
  - DR ↔ backlog 연결: `Linked Backlog Items` 섹션 누락·오기
- **DR 삭제/통합/Superseded 후보 식별**:
  - *1단계 (파일명 기반)*: DR 파일명에서 주제 키워드 추출 → 유사 주제 후보 그루핑
  - *2단계 (내용 확인)*: 1단계에서 의심되는 쌍에 한해서만 내용 비교
  - 삭제 후보: Draft 장기 유지 + 연결 backlog 없음 + 관련 OQ Closed
  - 통합 후보: 동일·유사 주제 복수 DR (1단계 필터 후 확인)
  - Superseded 후보: 이후 결정으로 실질적으로 대체되었으나 Accepted 유지
  - 후보 발견 시, cascade 업데이트 대상을 함께 제시:
    `docs/STATUS.md` / 관련 backlog(`PHASE{n}.md` 또는 `HARNESS.md`) DR 참조 항목 /
    `docs/PLAN-SUMMARY.md` DR 범위 / 연관 DR 파일

### F. Implementation Sync (--full)

Phase 5의 git log 결과를 기준으로, 변경된 구현 파일 유형별로 관련 문서만 선택 확인한다.

| 변경 파일 유형 | 확인 대상 문서 |
|---------------|---------------|
| `*.java`, `*.kts` (새 모듈·레이어) | `README.md` 기술 스택, `PLAN-SUMMARY.md` |
| `Dockerfile`, `docker-compose.yml` | `DOCKERFILE-GUIDE.md`, `README.md` 셋업 |
| `.github/workflows/*.yml` | `README.md` CI 항목, `DEVELOPER-GUIDE.md` CI 섹션 |
| `.claude/commands/*.md` (신규) | `HARNESS-PROTOCOL.md`, `README.md` AI workflow 섹션 |
| `config/checkstyle/**`, `.editorconfig` | `DEVELOPER-GUIDE.md` 코드 컨벤션 섹션 |
| `docs/decisions/DR-*.md` (신규 Accepted) | STATUS.md Recent Decisions, 연관 backlog Done Criteria |
| `docs/*.md` (신규 개발자 문서) | 참조하는 config·yml 파일과 기술 내용 대조 (예: ci.yml ↔ CI trigger 설명, checkstyle.xml ↔ 컨벤션 설명) |

STATUS.md Recent Decisions는 **최근 8개 rolling window**, 항목 품질(후속 행동을 바꾸는 판단만), DR-worthy 항목의 대응 DR 존재 여부를 점검한다.
전체 이력 점검은 명시적 요청 시에만 진행한다.

`docs/DEVELOPER-GUIDE.md`는 아래 변경이 감지될 때만 읽는다:
- 새 도구 도입 (git hooks, Checkstyle 등)
- API 추가 절차 또는 코드 컨벤션 정책 변경

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
- scaffold source가 바뀌었으면 `scripts/create-harness.sh --dry-run`과 필요 시 temp scaffold 생성으로 산출물 drift를 확인한다.
- historical retrospective는 snapshot인지 live follow-up log인지 구분한다. snapshot이면 기존 내용을 덮어쓰지 않고 append 제안만 한다.
- 반복 문구를 다음으로 분류한다:
  - Required mirror — 도구 진입점에서 반드시 보여야 하는 반복
  - Acceptable reminder — 사용자 실수를 줄이는 짧은 반복
  - Excessive duplication — 같은 layer 안에서 의미 없이 반복되는 문구
  - Stale contradiction — canonical과 충돌하는 오래된 문구
- trigger/cascade 변경 시 loop risk를 확인한다:
  - 같은 문서군을 서로 재발동시키는가
  - Approval Matrix state rules를 우회하는가
  - product surface Quick Mode와 harness/workflow surface 기본 L2 경계를 흐리게 만드는가
  - scaffold 검증이 자기 자신을 무한히 요구하는가

Coverage rule:

- 범위를 임의로 줄이지 않는다.
- 선택하지 않은 surface, grep, simulation은 반드시 `Skipped / Not Applicable`에 이유를 남긴다.
- 판단이 애매하면 통과 처리하지 말고 `Requires manual judgment`로 보고한다.

## Report Format

```
## Overall Status: [🟢 Good / 🟡 Needs Attention / 🔴 Action Required]

## Area Summary
| Area | Status | Items Found |
|------|--------|-------------|
| A. Structure Consistency   | 🟢/🟡/🔴 | n건 |
| B. Document Consistency    | 🟢/🟡/🔴 | n건 |
| E. Backlog/DR Hygiene      | 🟢/🟡/🔴 | n건 |
| (F. Implementation Sync)   | 🟢/🟡/🔴 | n건 |
| (G. Cascade Completeness)  | 🟢/🟡/🔴 | n건 |

## Detailed Findings

### [Area Name]
- [✓ / ⚠ / ✗] 항목명: 세부 내용

## P0/P1/P2 Findings
- P0 — flow break / state corruption / scaffold unusable:
- P1 — surface drift / missing mirror / productivity regression:
- P2 — over-duplication / wording hygiene / optional simplification:

## Checked Surfaces (--cascade only)
- Canonical:
- Tool-specific:
- User-facing:
- Scaffold:
- Historical:

## Required Grep Results (--cascade only)
- Command:
- Result summary:

## Simulation Notes (--cascade only)
- Executed / reasoned:
- Skipped / Not Applicable:
- Requires manual judgment:

## Suggested Fixes
- Fix now:
- Split into separate Work/DR:
- No action:
```

STATUS.md 변경이 필요한 발견 항목은 Approval Matrix state rules에 맞는 제안 섹션으로 별도 제안한다.
보고 후 "승인하신 항목부터 진행할까요?"로 끝낸다.
