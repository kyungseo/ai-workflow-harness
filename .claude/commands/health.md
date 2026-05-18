프로젝트 워크플로우와 문서의 건강 상태를 점검하고 보고한다.

## Execution Principles

- **구현 금지**: 보고와 제안만 한다. 수정·생성·커밋은 사용자 승인 후에만 진행한다.
- **STATUS 보호**: `docs/STATUS.md` 변경 필요가 발견되면 즉시 수정하지 말고 State Update Gate에 맞게 보고한다.
- **컨텍스트 절약**: `CLAUDE.md`와 `docs/AGENT-WORKFLOW.md`는 세션 시작 시 자동 로드됨 — 재읽기 금지.
  파일 목록·상태 확인은 full read 대신 `ls`, `rg` 명령을 우선 사용한다.
- **모드**:
  - (없음) → Quick 모드: A+B+E 영역, ~10개 타깃 읽기, 작업 블록 시작 전 사용
  - `--full` → 전체 모드: A+B+E+F+C+D 영역, 분기별·Phase 전환 전 사용
  - `--cascade` → 문서/워크플로우 변경 영향 감사: canonical → tool-specific → user-facing → scaffold 계층을 대조하고 필요한 cascade, 누락 mirror, 과잉 반복, loop risk를 보고
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

(조건부) Validation, State Update Gate, Commit Gate 정합성 확인이 필요하면
`docs/harness-protocol/06-recovery-and-validation.md`의 해당 섹션만 읽는다.

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

**Phase 6 — Cascade Layers (--cascade only)**

변경된 파일 목록을 먼저 확인한다:

```bash
git diff --name-only
git diff --cached --name-only
```

변경 파일을 기준으로 필요한 layer만 선택적으로 읽는다. 전체 문서 일괄 로드는 금지한다.

| Layer | 확인 대상 |
| --- | --- |
| Canonical | `docs/AGENT-WORKFLOW.md`, `docs/harness-protocol/05-triggers-and-cascade.md`, 관련 `docs/harness-protocol/*.md`, 관련 DR |
| Tool-specific | `AGENTS.md`, `CLAUDE.md`, `.claude/commands/*.md`, `.claude/rules/*.md`, `.cursor/rules/*.mdc`, `prompts/*` |
| User-facing | `docs/WORKFLOW-MANUAL.md`, `docs/HARNESS-QUICK-REFERENCE.md`, `README.md` |
| Scaffold | `scripts/create-harness.sh`, dry-run 또는 temp scaffold 산출물 |
| Historical | `docs/retrospectives/*` — snapshot이면 덮어쓰지 않고 append 필요 여부만 판단 |

## Inspection Areas

### A. Workflow Structure Consistency

- 각 slash command: 트리거 조건 명확성, Done Criteria 존재, 승인 대기 명시 여부
  (Phase 2에서 목록 확인 후 의심 항목만 내용 확인)
- 각 `.claude/rules/*.md`: `paths` glob이 실제 디렉토리 구조와 일치하는가
- `docs/AGENT-WORKFLOW.md` 워크플로우 기술 ↔ 실제 command 구현 사이 gap
  (이미 컨텍스트에 있는 docs/AGENT-WORKFLOW.md 기준으로 확인)
- command/prompt 종료 요약 ↔ `docs/harness-protocol/06-recovery-and-validation.md`의 Validation Checklist, State Update Gate, Commit Gate 정합성
- STATUS.md Active Work pointer가 가리키는 Work 파일에 Done Criteria + Verification이 존재하는가
- STATUS.md Active Work pointer ↔ Work 파일 frontmatter `status: Active` 정합성
- `docs/works/*/*.md` 중 `status: Done`인 Work가 STATUS Active Work에 남아 있지 않은가
- `docs/works/*/README.md` index가 Work 파일 상태(Candidate/Active/Done/Archived)와 일치하는가
- archive 위치의 Work 파일은 `status: Archived`인가
- DR 생애주기 양방향: STATUS.md Recent Decisions ↔ `rg` 결과의 DR Status 일치

### B. Document Cross-Consistency

- HARNESS-PROTOCOL.md와 `docs/harness-protocol/` 상세 문서 링크 ↔ 실제 파일 목록 일치
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
| `.claude/commands/*.md` (신규) | `HARNESS-PROTOCOL.md` 또는 `docs/harness-protocol/`, `README.md` AI workflow 섹션 |
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
기준은 `docs/harness-protocol/05-triggers-and-cascade.md`이며, 실제 command/rule/prompt/manual/scaffold 표면이 이 기준을 필요한 만큼 반영하는지 확인한다.

- 변경된 파일을 canonical / tool-specific / user-facing / scaffold / historical layer로 분류한다.
- canonical 문서가 바뀌었으면 tool-specific surface와 user-facing guide에 필요한 mirror가 있는지 확인한다.
- tool-specific 문서가 바뀌었으면 반대 tool surface, canonical trigger/cascade 문서, scaffold 산출물 필요 여부를 확인한다.
- user-facing 문서가 바뀌었으면 실제 command 동작과 canonical 규칙을 과장하거나 누락하지 않는지 확인한다.
- scaffold source가 바뀌었으면 `scripts/create-harness.sh --dry-run`과 필요 시 temp scaffold 생성으로 산출물 drift를 확인한다.
- historical retrospective는 snapshot인지 live follow-up log인지 구분한다. snapshot이면 기존 내용을 덮어쓰지 않고 append 제안만 한다.
- 반복 문구를 다음으로 분류한다:
  - Required mirror — 도구 진입점에서 반드시 보여야 하는 반복
  - Acceptable reminder — 사용자 실수를 줄이는 짧은 반복
  - Excessive duplication — 같은 layer 안에서 의미 없이 반복되는 문구
  - Stale contradiction — canonical과 충돌하는 오래된 문구
- trigger/cascade 변경 시 loop risk를 확인한다:
  - 같은 문서군을 서로 재발동시키는가
  - State Update Gate를 우회하는가
  - Quick Mode 예외를 너무 넓혀 작은 작업 흐름을 무겁게 만드는가
  - scaffold 검증이 자기 자신을 무한히 요구하는가

**Simulation Pack (--cascade):**

변경 파일과 관련된 시나리오만 선택한다. 대형 harness 변경이거나 사용자가 명시하면 전체를 수행한다.

- 새 세션 `/start`
- 작업 선택 `/pick`
- L1 Quick Mode 작업
- L2/L3 `/work`
- 중단 후 `/resume`
- `/done`
- Done → Archived
- STATUS.md 변경 필요/불필요 분기
- command/rule/prompt 변경 시 tool surface cascade
- 신규 프로젝트 scaffold 적용

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

## Improvement Suggestions
P0 (즉시 — 승인 후 적용 가능):
P1 (계획 필요):
P2 (선택적 개선):

## Cascade Findings (--cascade only)
P0 — Flow Break:
P1 — Surface Drift:
P2 — Hygiene:

## Simulation Notes (--cascade only)
- 실행 또는 논리 검증한 시나리오:
- 생략한 시나리오와 이유:
```

STATUS.md 변경이 필요한 발견 항목은 State Update Gate에 맞는 제안 섹션으로 별도 제안한다.
보고 후 "승인하신 항목부터 진행할까요?"로 끝낸다.
