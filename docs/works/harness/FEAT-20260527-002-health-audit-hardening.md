---
id: FEAT-20260527-002
priority: P1
status: Active
risk: L2
scope: /health mode contract 명확화, Output Contract 추가, Workflow Context Weight 검증 관점, command/skill mirror 정렬, Required Surface/Grep/Simulation Matrix 보강
appetite: 1w
planned_start: 2026-05-27
planned_end: 2026-06-03
actual_end:
related_dr: []
related_commits: []
related_troubleshooting: []
---

# FEAT-20260527-002: Health Audit Hardening

## Plan

### Background

`/health`는 workflow, tool surface, scaffold, tracking 상태를 점검하는 진단 workflow다.
`temp/work-plans/07-health-audit-hardening.md` 기반 작업이며, 다음 harness work인
`05-harness-protocol-context-budget-optimization` 착수 전 안전망으로 보강한다.

현재 `.claude/commands/health.md`와 `.agents/skills/workflow-health/SKILL.md`는
Quick / Full / Cascade 모드를 이미 갖고 있고 Required Surface Matrix, Grep Pack, Simulation Matrix도 포함한다.
그러나 아래 약점이 확인됐다.

1. **Output contract 약함** — Context Budget Notes, Workflow Context Weight, Verification Run 섹션 없음.
2. **Mode boundary 산문 설명** — Required/Conditional/Must Report 열 구분 없이 서술.
3. **최근 반복 케이스 미반영** — source-gitflow marker, Public Clean Baseline Gate, scaffold boundary, STATUS/Tracking Finalization이 Grep/Matrix에 부분적으로만 있음.
4. **Command/Skill mirror drift** — §C 이름이 `health.md`("Claude Code Feature Alignment") ↔ SKILL.md("Codex Feature Alignment")로 불일치.
5. **Workflow Context Weight 관점 부재** — 일상 workflow(startup, /work, /resume, /close, commit/PR, scaffold onboarding)가 불필요하게 heavy docs를 읽도록 변했는지 발견하는 체크 없음.
6. **Required Surface Matrix 누락 행** — `docs/GIT-WORKFLOW.md`, `scripts/templates/**`, command/skill mirror pair, `/health` 자체 변경 행 없음.

### Approach

- report-only 원칙 유지. 자동 수정/state change 없음.
- Quick 모드는 건드리지 않음. 새 체크는 Area H(Workflow Context Weight)로 분리해 Full/Cascade에서만 활성화.
- Mode Contract 표, Output Contract, Area H, Matrix 보강을 health.md에 추가하고 SKILL.md에 mirror.
- user-facing mirror(HARNESS-QUICK-REFERENCE, WORKFLOW-MANUAL)는 semantics 변경이 user-visible인 경우만 최소 업데이트.

### Scope

#### Primary

| Surface | 변경 내용 |
|---|---|
| `.claude/commands/health.md` | Mode Contract 표 추가, Output Contract 섹션 추가, Area H 추가, Required Surface/Grep/Simulation Matrix 보강, §C 이름 정렬 |
| `.agents/skills/workflow-health/SKILL.md` | 동일 (mirror) |

#### Secondary (user-facing)

| Surface | 변경 내용 |
|---|---|
| `docs/HARNESS-QUICK-REFERENCE.md` | `/health` command 행에 Workflow Context Weight 점검 언급 추가 (업데이트 확정) |
| `docs/WORKFLOW-MANUAL.md` | §5 `/health` 설명 셀 업데이트 (업데이트 확정) |
| `README.md` | 영향도 검토 후 변경 여부 결정 |
| `docs/SCAFFOLD-ONBOARDING-GUIDE.md` | 영향도 검토 후 변경 여부 결정 |
| `docs/SCAFFOLD-BOOTSTRAP.md` | 영향도 검토 후 변경 여부 결정 |
| `docs/HARNESS-MAINTAINER-GUIDE.md` | 영향도 검토 후 변경 여부 결정 |
| `scripts/create-harness.sh` | 변경 없음 (adapt 함수가 자동 반영) |

#### Out of Scope

- `docs/HARNESS-PROTOCOL.md` 분리 (05번 작업)
- command/skill 전체 구조 변경 (mirror 정렬과 wording 보강까지만)
- branch policy 또는 pre-commit hook 동작 변경
- 자동화/CI 추가

### Files

| 변경 | 파일 | 비고 |
|---|---|---|
| 수정 | `.claude/commands/health.md` | Primary |
| 수정 | `.agents/skills/workflow-health/SKILL.md` | mirror |
| 수정 | `docs/HARNESS-QUICK-REFERENCE.md` | 업데이트 확정 |
| 수정 | `docs/WORKFLOW-MANUAL.md` | 업데이트 확정 |
| 수정 | `README.md` | §7 `/health` 행 Area H 언급 추가 |
| 검토 | `docs/SCAFFOLD-ONBOARDING-GUIDE.md` | 영향도 검토 후 결정 |
| 검토 | `docs/SCAFFOLD-BOOTSTRAP.md` | 영향도 검토 후 결정 |
| 검토 | `docs/HARNESS-MAINTAINER-GUIDE.md` | 영향도 검토 후 결정 |
| 신규 | `docs/works/harness/FEAT-20260527-002-health-audit-hardening.md` | 이 파일 |
| 수정 | `docs/works/harness/README.md` | Active 행 추가 |
| 수정 | `docs/STATUS.md` | Active Work pointer 추가 |

### Done Criteria

- [x] Mode contract 표가 Quick/Full/Cascade/Full+Cascade별 Required/Conditional/Must Report를 명시
- [x] Output Contract에 Summary, Findings, Surface Coverage, Skipped/NA, Context Budget Notes, Verification Run, Follow-Ups 포함
- [x] Area H (Workflow Context Weight) 추가 — startup, /work, /resume, /close, commit/PR, scaffold onboarding 점검
- [x] Required Surface Matrix에 GIT-WORKFLOW, `scripts/templates/**`, command/skill mirror pair, health self 행 추가
- [x] Required Grep Pack에 STATUS/Tracking Finalization, source-gitflow, Public Clean Baseline Gate, pre-commit 카테고리 추가
- [x] Required Simulation Matrix에 branch isolation, default/source-gitflow scaffold, workflow weight 시나리오 추가
- [x] §C 이름 health.md ↔ SKILL.md 정렬 (→ "Tool Feature Alignment (--full)")
- [x] `docs/HARNESS-QUICK-REFERENCE.md` `/health` 행 업데이트 (확정)
- [x] `docs/WORKFLOW-MANUAL.md` `/health` 설명 업데이트 (확정)
- [x] `README.md`, `docs/SCAFFOLD-ONBOARDING-GUIDE.md`, `docs/SCAFFOLD-BOOTSTRAP.md`, `docs/HARNESS-MAINTAINER-GUIDE.md` 영향도 검토 완료 — 변경 필요 시 반영, 불필요 시 Discovery에 근거 기록
- [x] scaffold dry-run (generic + source-gitflow) 통과 — Codex 환경 검증 완료
- [x] scaffold 실제 생성물 health command/skill에 Output Contract, Workflow Context Weight 반영 확인 — Codex 환경 검증 완료
- [x] report-only 원칙 유지 — 자동 수정/state change 없음 명시
- [x] `git diff --check` 통과

### Verification

```bash
# ── 1. Syntax ─────────────────────────────────────────────────────────────────
bash -n scripts/create-harness.sh

# ── 2. Mirror section 정렬 확인 ────────────────────────────────────────────────
rg -n "^## |^### |^# " .claude/commands/health.md .agents/skills/workflow-health/SKILL.md

# ── 3. 핵심 키워드 반영 확인 ──────────────────────────────────────────────────
rg -n "Output Contract|Workflow Context Weight|Context Budget Notes|source-gitflow|STATUS Finalization|Tracking Finalization|Public Clean Baseline Gate" \
  .claude/commands/health.md .agents/skills/workflow-health/SKILL.md

# ── 4. Scaffold dry-run ───────────────────────────────────────────────────────
scripts/create-harness.sh --dry-run --profile generic health-check /tmp/awh-health-default
scripts/create-harness.sh --dry-run --workflow source-gitflow health-source /tmp/awh-health-source

# ── 5. Scaffold 실제 생성 + rg ────────────────────────────────────────────────
# 기존 경로가 남아 있으면 충돌하므로 먼저 정리하거나 timestamp suffix를 사용한다
# 예: TS=$(date +%H%M%S); TARGET_D=/private/tmp/awh-health-default-${TS}; TARGET_S=/private/tmp/awh-health-source-${TS}
rm -rf /private/tmp/awh-health-default /private/tmp/awh-health-source
bash scripts/create-harness.sh --profile generic health-default /private/tmp/awh-health-default
bash scripts/create-harness.sh --workflow source-gitflow health-source /private/tmp/awh-health-source

rg -n "Output Contract|Workflow Context Weight|Context Budget Notes" \
  /private/tmp/awh-health-default/.claude/commands/health.md \
  /private/tmp/awh-health-default/.agents/skills/workflow-health/SKILL.md \
  /private/tmp/awh-health-source/.claude/commands/health.md \
  /private/tmp/awh-health-source/.agents/skills/workflow-health/SKILL.md

# ── 6. Diff check ────────────────────────────────────────────────────────────
git diff --check
```

### Risk

| 리스크 | 설명 | 대응 |
|---|---|---|
| health.md가 더 무거워져 context-budget 목표와 충돌 | checklist 항목 증가 | Quick 모드 건드리지 않음. Area H는 Full/Cascade에서만 활성화 |
| Workflow Context Weight가 heavy full-read를 유발 | 점검이 결국 문서 전체를 읽게 됨 | listing + rg 기반 점검으로 설계. 파일 전체 read 없이 pattern matching |
| command/skill mirror drift 악화 | 둘 중 하나만 바뀌면 Claude/Codex health 결과 달라짐 | Verification에 section header rg 포함. Done Criteria에 mirror 정렬 명시 |
| default scaffold에 source-gitflow 체크가 항상 활성화 | default scaffold 사용자 혼란 | Surface Matrix의 source-gitflow 행을 조건부로 설계 |

### Reversal Cost: Medium

- health.md/SKILL.md wording 변경은 git revert로 복구 가능
- scaffold 산출물은 다음 create-harness.sh 실행 시 자동 갱신
- branch policy/scaffold behavior 변경 없음

### Open Questions

| ID | Question | Candidate Answer | Status |
|---|---|---|---|
| OQ-1 | health command/skill이 full duplicated text를 유지할지 canonical doc slice를 참조할지? | 지금은 duplicate 유지. 05번에서 protocol split 후 재검토 | Open |
| OQ-2 | `--cascade`에서 scaffold dry-run을 자동 실행할지? | scaffold 파일 변경 시 yes. 그 외 user 요청 시만 | Open |
| OQ-3 | source-gitflow 체크가 모든 health invocation에서 실행될지? | No. full/cascade 또는 branch/scaffold/GIT-WORKFLOW 변경 시만 | Open |
| OQ-4 | Health report에 exact file-read list를 포함할지? | Yes, full/cascade에서 Context Budget Notes에 compact하게. Quick은 요약 | Open |

---

## Checkpoints

### CP-1: Mode Contract + Output Contract 추가

- [x] health.md에 Mode Contract 표 추가
- [x] health.md Output Contract 섹션 추가 (7개 named section)
- [x] SKILL.md mirror 적용

### CP-2: Area H (Workflow Context Weight) 추가

- [x] health.md에 Area H 추가 — 7개 workflow path 점검 (`/health` 자체 포함)
- [x] SKILL.md mirror 적용

### CP-3: Matrix 보강

- [x] Required Surface Matrix 4개 행 추가
- [x] Required Grep Pack 3개 카테고리 추가
- [x] Required Simulation Matrix 4개 시나리오 추가 (Workflow Context Weight 포함)
- [x] SKILL.md mirror 적용

### CP-4: Mirror 정렬 + User-facing 업데이트

- [x] §C 이름 health.md ↔ SKILL.md 통일 → "Tool Feature Alignment (--full)"
- [x] `docs/HARNESS-QUICK-REFERENCE.md` 1행 업데이트
- [x] `docs/WORKFLOW-MANUAL.md` 1셀 업데이트

### CP-5: 전체 Done Criteria 통과

- [x] Done Criteria 전체 체크 — 전체 통과 (scaffold 검증 Codex 환경 완료, Area H 활성 조건 문구 보정 반영)

---

## Discovery

착수 전 사전 검토 (2026-05-27):

- `.claude/commands/health.md` ↔ `.agents/skills/workflow-health/SKILL.md`: 내용 거의 동일. §C 이름만 불일치("Claude Code Feature Alignment" vs "Codex Feature Alignment").
- Output Contract: 현재 Report Format이 있으나 Context Budget Notes, Workflow Context Weight, Verification Run 섹션 없음.
- Required Surface Matrix 누락 행: `docs/GIT-WORKFLOW.md`/branch policy, `scripts/templates/**`, command/skill mirror pair, health self.
- Required Grep Pack 누락: `STATUS Finalization`, `Tracking Finalization`, `source-gitflow`, `policy_type: source-gitflow`, `Public Clean Baseline Gate`, `pre-commit`.
- Required Simulation Matrix 누락: branch isolation, default/source-gitflow scaffold 생성, Workflow Context Weight.
- `docs/HARNESS-QUICK-REFERENCE.md` §8: `/health` cadence 표 있음. Workflow Context Weight 포함 여부 업데이트 필요.
- `docs/WORKFLOW-MANUAL.md` §5: `/health` command 설명 행 있음. output contract 변경 시 업데이트 필요.
- `scripts/create-harness.sh` line 272: `adapt` 함수로 health.md/SKILL.md 그대로 복사. 변경 시 scaffold 자동 반영, dry-run 검증 필요.

구현 완료 결과 (2026-05-27):

- `.claude/commands/health.md`: Mode Contract, Output Contract, Area H, Required Surface Matrix +4행, Grep Pack +3카테고리, Simulation Matrix +4행, §C "Tool Feature Alignment (--full)" 통일, Report Format 7섹션 Output Contract 형식으로 교체.
- `.agents/skills/workflow-health/SKILL.md`: health.md와 섹션 구조 완전 동기화. rg 확인 결과 모든 필수 키워드(Output Contract, Workflow Context Weight, Context Budget Notes, source-gitflow, STATUS Finalization, Tracking Finalization, Public Clean Baseline Gate) 양쪽 파일에 반영.
- `docs/HARNESS-QUICK-REFERENCE.md` §8: Area H (Workflow Context Weight) 1행 추가.
- `docs/WORKFLOW-MANUAL.md` §5: `/health` 셀 — 7섹션 Output Contract, Area H 설명 추가.
- `README.md` §7: `/health` 행 — "Area H: Workflow Context Weight 감지 포함" 추가.

User-facing 영향도 검토:
- `docs/SCAFFOLD-ONBOARDING-GUIDE.md`: `/health` 언급 없음(springboot actuator health만). 변경 불필요.
- `docs/SCAFFOLD-BOOTSTRAP.md`: `/health` 언급 없음. 변경 불필요.
- `docs/HARNESS-MAINTAINER-GUIDE.md`: `/health` 언급 없음. 변경 불필요.

Verification 결과:
- Verification 2 (mirror section rg): health.md ↔ SKILL.md 섹션 구조 완전 일치. PASS.
- Verification 3 (keyword rg): 모든 필수 키워드 양쪽 파일에 존재. PASS.
- Verification 6 (git diff --check): whitespace 오류 없음. PASS.
- Verification 1 (bash -n scripts/create-harness.sh): Codex 환경 PASS.
- Verification 4 (scaffold dry-run generic + source-gitflow): Codex 환경 PASS.
- Verification 5 (scaffold 실제 생성): `/private/tmp/awh-health-default-165456`, `/private/tmp/awh-health-source-165456` 생성. 4개 health 파일에서 Output Contract / Workflow Context Weight / Context Budget Notes 확인 PASS.
- report-only 원칙: Area H 점검 지시 문구가 listing + rg 기반, 파일 전체 read 없이 pattern matching으로 설계. PASS.
- Area H 활성 조건 보정 (2026-05-27): "–full 또는 –cascade" 표현을 정확한 조건으로 수정. `--full` 항상 활성; `--cascade` 변경 surface가 context weight 관련 파일일 때만; 변경 파일 없는 `--cascade`(Quick 모드)는 skip. health.md, SKILL.md, HARNESS-QUICK-REFERENCE.md §8 반영.
- `/health` mode smoke test (Codex, 2026-05-27):
  - Quick: PASS — STATUS Active Work pointer와 Work index가 FEAT-20260527-002로 정합, tool surface listing 정상.
  - `--cascade` current changed files: PASS — 변경 파일이 health command/skill, README, HARNESS-QUICK-REFERENCE, WORKFLOW-MANUAL, tracking surface이므로 cascade 대상 선정 타당. Area H는 context/load-path 관련 변경이므로 활성화 조건에 부합.
  - `--cascade` no-change rule: PASS — 변경 파일 없으면 Quick 모드로 동작하고 Area H skip하도록 문구 정리됨.
  - `--full` / `--full --cascade` selected checks: PASS — stale phrase grep, state/tracking grep, branch/scaffold grep, context/load-path grep 실행. historical title 또는 "필요 시 로드" 문구는 blocking drift로 보지 않음.
  - `git diff --check`: PASS. `bash -n scripts/create-harness.sh`: PASS.
  - residual risk: context/load-path grep은 결과 유무가 아니라 triggerless always-load 여부를 수동 판단해야 함.
