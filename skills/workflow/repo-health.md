# repo-health

Canonical workflow procedure for `/repo-health`.

이 파일은 workflow 상세 절차의 SSoT다. Tool-specific surface는 아래 adapter만 가진다.

| Tool | Adapter |
| --- | --- |
| Claude Code | `.claude/commands/repo-health.md` |
| Codex | `.agents/skills/workflow-repo-health/SKILL.md` |
| Cursor | `.cursor/rules/workflow.mdc` |

Adapter는 Step 0, hard-stop 요약, entry mechanism, fallback만 보유한다. 상세 절차, checklist, cascade 판단은 이 canonical 파일을 따른다.

Mode-specific detail은 조건부 slice를 로드한다.

| Need | Slice |
| --- | --- |
| `--full` 전용 reading order, Inspection Areas C/D/F | `skills/workflow/repo-health-full.md` |
| `--cascade` 전용 surface matrix, grep pack, simulation matrix, Area G | `skills/workflow/repo-health-cascade.md` |

## Procedure

프로젝트 워크플로우와 문서의 건강 상태를 점검하고 보고한다.

## Execution Principles

- **구현 금지**: 보고와 제안만 한다. 수정·생성·커밋은 사용자 승인 후에만 진행한다.
- **STATUS 보호**: `docs/STATUS.md` 변경 필요가 발견되면 즉시 수정하지 말고 Approval Matrix state rules에 맞게 보고한다.
- **컨텍스트 절약**: 현재 tool entrypoint(`AGENTS.md` 또는 `CLAUDE.md`)와 `docs/AGENT-WORKFLOW.md`는 세션 시작 시 로드됨 — 재읽기 금지.
  파일 목록·상태 확인은 full read 대신 `ls`, `rg` 명령을 우선 사용한다.
- **Validation Spine runner surface**: deterministic 검증은 직접 재구현하지 않고 `scripts/tests/run-harness-checks.sh`(있으면)를 호출·해석해 Findings로 옮긴다. Quick 모드는 `--tier0`(+ 필요 시 `--tier1 <target>`, **생성 없음**)만 호출해 경량성을 유지하고, `--full`에서만 `--all`(tier2 scaffold 실생성 포함)을 권장한다. runner/helper 결과를 해석하되 불변식은 재구현하지 않는다(taxonomy §1 경계). runner 부재(adopter) 시 Skipped/N/A로 보고한다.
- **모드**:
  - (없음) → Quick 모드: A+B+E 영역, ~10개 타깃 읽기, 작업 블록 시작 전 사용
  - `--full` → 전체 모드: A+B+E+F+C+D 영역, 분기별·Phase 전환 전 사용. `repo-health-full.md`를 조건부 로드한다
  - `--cascade` → changed-surface cascade audit: 변경 파일 유형에 맞는 canonical → tool-specific → user-facing → scaffold 계층을 선택하고, 해당 계층의 필수 surface/grep/simulation으로 drift를 발견·보고. `repo-health-cascade.md`를 조건부 로드한다
  - `--full --cascade` → Phase 전환 전 또는 대형 harness 변경 후 전체 surface와 cascade를 함께 감사. 두 slice를 모두 조건부 로드한다
  - `--cascade`에서 변경 파일이 없으면 Quick 모드(A+B+E)로 동작하고, 전체 cascade 감사가 필요하면 `--full --cascade`를 사용

## Mode Contract

| Mode | Required | Conditional | Must Report |
|---|---|---|---|
| Quick | STATUS current sections + tool surface listing (Phase 1-2) + A·B·E 영역 | suspicious mismatch 파일만 full read | current state, findings, skipped checks with reason |
| `--full` | Quick + `repo-health-full.md` + A·B·C·D·E·F·H 영역 | 최근 변경 surface 기반 selected docs | findings by severity, Context Budget Notes |
| `--cascade` | changed files → `repo-health-cascade.md` Required Surface Matrix → grep/simulation | user-facing·scaffold·historical은 선택된 유형에만 | selected surfaces, omitted surfaces with reason |
| `--full --cascade` | full health + `repo-health-cascade.md` Area G cascade completeness | release/phase 전환, 대형 harness 변경 | blocking findings, residual risk, follow-up plan |

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

**Phase 4-5 — Full mode only**
`--full`이면 `skills/workflow/repo-health-full.md`를 로드한다.

**Phase 6 — Cascade mode only**
`--cascade`이면 변경 파일을 확인한 뒤 `skills/workflow/repo-health-cascade.md`를 로드한다.

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
- live `docs/works/*/README.md` index가 Active/Done(Pending) Work 상태와 일치하고, Archived 인덱스는 archive-side `docs/archive/docs/works/*/README.md`와 일치하는가
- `docs/decisions/README.md` index가 `docs/decisions/DR-*.md` 실제 파일 목록과 일치하는가
- `docs/retrospectives/README.md` index가 `docs/retrospectives/` 실제 파일 목록과 일치하는가
- `docs/briefs/README.md` index가 `docs/briefs/` 실제 파일 목록과 일치하는가
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

### E. Backlog/DR Hygiene

- Work 파일: Verification 완료되었으나 Done 처리가 지연된 Active 항목
- Work 파일: `status: Done`인데 archive 대기 상태로 2세션 이상 남은 항목
- `docs/backlog/PRODUCT.md`: product/preparation 항목 중 선행 조건이 이미 충족된 항목, 범위·우선순위 재검토 필요 항목
  ```bash
  # 상태 확인 예시 — alternation은 | 사용 (\| 아님)
  rg "Candidate|In Progress" docs/backlog/PRODUCT*.md
  ```
- `docs/backlog/HARNESS.md`: harness 항목 중 완료되었거나 새 상태 머신과 충돌하는 항목, hard enforcement 후보
- DR 상태 확인 (`--full` Phase 5 `rg` 결과가 있으면 재사용):
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

### H. Workflow Context Weight (--full / --cascade)

활성 조건: `--full`에서 항상 실행. `--cascade`에서는 변경 surface가 command/skill/prompt 로드 지시, workflow load path, `AGENT-WORKFLOW` 등 context weight와 관련된 파일을 포함할 때만 실행. 변경 파일 없는 `--cascade`는 Quick 모드이므로 Area H skip.

`/repo-health` 자체의 token 사용량보다 더 중요한 목적은 **일상 workflow operating model이 시간이 지나며 불필요하게 무거워지는 현상을 감지**하는 것이다.
각 workflow path가 필요한 표면만 읽고 있는지 점검한다. report-only — 자동 수정 없음.

점검 방법: `CLAUDE.md`, `docs/AGENT-WORKFLOW.md`, 각 command/skill 파일의 로드 지시 문구를 listing + rg로 확인한다. 파일 전체 read 없이 pattern matching으로 판단한다.

| Workflow path | 점검 질문 |
|---|---|
| Session startup / `/session-start` | `BEHAVIOR-PRINCIPLES`, `AGENT-WORKFLOW`, `STATUS` current sections를 넘어 archive/history/manual을 기본 로드하도록 지시하지 않는가 |
| `/work-plan` | Work ID 확정 및 계획 수립에 필요한 정보만 로드하는가. naming detail 전체, branch policy 전체를 trigger 없이 상시 읽지 않는가 |
| `/work-resume` | Work/STATUS/file state를 우선하고, 무관한 backlog/manual/retrospective/brief를 기본 로드하지 않는가 |
| `/work-close` | Work Done 처리와 commit strategy를 분리하는가. release gate detail은 branch context가 필요할 때만 확인하는가 |
| Commit/PR finalization | STATUS/Tracking finalization을 수행하되, 전체 protocol/manual을 반복 로드하지 않는가 |
| Scaffold onboarding | `STATUS.md` Next Actions pointer 없이 `BOOTSTRAP.md`를 자동 로드하도록 지시하지 않는가 |
| `/repo-health` 자체 | Quick 모드가 Area H를 실행하지 않는가. command가 report-only를 유지하고 state change를 발생시키지 않는가 |

finding category: **"Workflow Context Weight"** — 일상 workflow가 heavy해진 지점을 P1로 보고한다.
heavy doc 기준: `HARNESS-PROTOCOL.md` 전체, `WORKFLOW-MANUAL.md`, archive/retrospectives/briefs/PLAN, session-start 없이 자동 로드 지시.

## Report Format

Output Contract의 7개 섹션 순서를 그대로 사용한다.

- Area Summary에는 A/B/E를 기본으로 두고, mode에 따라 F/G/H를 추가한다.
- Findings는 P0/P1/P2로 분리한다.
- Findings가 없으면 "No blocking findings"를 명시한다.
- STATUS.md 변경이 필요한 발견 항목은 Approval Matrix state rules에 맞는 제안 섹션으로 별도 제안한다.
- 보고 후 "승인하신 항목부터 진행할까요?"로 끝낸다.
