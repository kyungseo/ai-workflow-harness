---
id: CHORE-20260528-001
priority: P2
status: Done
risk: Medium
scope: 병렬/동시 작업 환경에서 Work ID 충돌·STATUS/index 동시 수정·DR sequence·command/skill mirror·scaffold drift 등 10개 축의 현행 gap을 분석하고 manual-first conflict-resolution rule을 문서화
appetite: 1w
planned_start: 2026-05-28
planned_end: 2026-06-04
actual_end: 2026-05-28
related_dr: [DR-013, DR-016, DR-017, DR-019]
related_commits: []
related_troubleshooting: []
---

# CHORE-20260528-001: 병렬/동시 작업 제어 모델 검토

## Plan

### 배경

CHORE-20260527-001(Work/OQ/Tracker ID Rule)은 `<TYPE>-<YYYYMMDD>-<NNN>` ID 체계, ID-less backlog candidate 정책, branch naming guidance, Tracking Finalization 수동 충돌 확인을 도입했다. 이번 Work는 그 후속으로, 여러 feature branch / agent / scaffold consumer가 병렬 운영될 때 workflow가 충돌을 어떻게 감지하고 복구할지를 10개 검토 축으로 분석한다.

**First slice 범위 (manual-first, L2):** docs/checklist 수준의 conflict-resolution rule 문서화에 집중한다.

**Out of Scope (이번 first slice 제외):**
- Hard enforcement(CI/hook/release automation)
- Helper script, index regeneration automation
- 자동 복구 스크립트

Out of Scope 항목이 실제 pain point가 되면 별도 L3 Work로 등록한다.

### Related Policy Surfaces

DR-016(Work Done/Archive trigger), DR-017(Git merge/branch flow), DR-019(Codex skill naming/mirror)는 검토 과정에서 related policy surfaces로 추적한다.

### 검토 축

#### Axis 1. Work ID `<TYPE>-<YYYYMMDD>-<NNN>` 병렬 환경 충분성

**근거:** `docs/HARNESS-NAMING-RULES.md` — "병렬 branch 병합 시 같은 `<TYPE>-<YYYYMMDD>-<NNN>`이 충돌하면 NNN을 재배정한다. 날짜는 변경하지 않는다."

**Gap:** NNN 재배정 시점·절차·외부 참조(PR description, commit body) 영향 처리가 명시되지 않음.

**검토 질문:** NNN 재배정 후 이미 배포된 외부 참조의 일관성을 어떻게 유지할 것인가?

#### Axis 2. Branch naming과 Work ID 확정 시점 불일치

**근거:** `docs/HARNESS-NAMING-RULES.md` — "착수 전 ID 선점은 병렬 branch 충돌 가능성을 높이므로 하지 않는다."

**Gap:** feature branch는 Work ID 확정 전에 생성될 수 있어 branch rename이 필요해질 수 있음.

**검토 질문:** branch 생성 → Work ID 확정 권장 순서를 명시할 것인가? description slug만 사용하는 옵션을 허용할 것인가?

#### Axis 3. `docs/STATUS.md` Active Work 동시 수정 충돌

**근거:** `docs/AGENT-WORKFLOW.md` STATUS Rules + DR-013 — "Work 파일 SSoT. STATUS.md는 dashboard."

**Gap:** 두 feature branch가 각각 Active Work row를 추가하고 동시에 PR merge 시 STATUS.md conflict. 현재 해소 절차 없음.

**검토 질문:** STATUS.md conflict 발생 시 Work file frontmatter 기준으로 표를 재구성하는 복구 rule을 문서화할 것인가?

#### Axis 4. `docs/works/*/README.md` Work index 동시 수정 충돌

**근거:** DR-013 §인덱스파일 — 각 카테고리 디렉토리에 README.md 유지.

**Gap:** STATUS.md와 동일한 구조적 충돌 위험. Work index는 Active/Done/Archived 테이블을 유지하므로 동시 row 추가 시 conflict 발생. 해소 절차 없음.

**검토 질문:** Work index는 Work file path를 기반으로 수동으로 재구성 가능한가? 충돌 해소를 manual checklist로 처리할 수 있는가?

#### Axis 5. Work frontmatter SSoT 기반 STATUS/index 복구 규칙

**근거:** `docs/AGENT-WORKFLOW.md` — "문서와 실제 파일 상태가 충돌하면 실제 파일 상태를 우선한다."

**Gap:** SSoT 원칙은 명시되어 있으나, conflict 발생 후 복구 절차(어느 파일 기준으로 어떻게 재구성하는지)가 없음.

**검토 질문:** `/health --cascade` 또는 recovery checklist에 "Work frontmatter 기준 STATUS/index 재검증" step을 추가할 것인가?

#### Axis 6. DR-### global sequence 충돌

**근거:** `docs/HARNESS-NAMING-RULES.md` §DR-ID — DR-### 체계 유지.

**Gap:** 병렬로 두 branch가 새 DR을 작성하면 같은 번호를 선점할 수 있음. 병렬 충돌 방지·해소 절차 없음.

**검토 질문:** Accepted 직전 번호 재확인 절차를 `record-decision` command/skill에 추가할 것인가? `DR-DRAFT-{slug}` 임시 식별자 허용을 검토할 것인가?

#### Axis 7. Command/skill mirror atomicity

**근거:** `.claude/commands/` ↔ `.agents/skills/workflow-*/` mirror surface. DR-019(Codex skill naming/mirror).

**현황:** 현재 `.claude/commands/`(11개) ↔ `.agents/skills/workflow-*/`(11개) 완전 일치. `/health --cascade`에 이미 command/skill suffix mapping과 mirror pair check가 있음.

**Gap:** 일반 mirror check는 있으나, 병렬 workflow 변경 시 atomic update를 별도 항목으로 강제하거나 Work/release gate와 연결하는 rule이 얇음. workflow command를 수정할 때 대응 skill을 동시에 포함하도록 강제하는 절차가 없음.

**검토 질문:** `/health --cascade` checklist에 "이번 Work에서 수정한 command와 대응 skill이 모두 반영됐는지" 확인 항목을 추가할 것인가?

#### Axis 8. Scaffold template drift window

**근거:** `scripts/create-harness.sh` + HARNESS.md Deferred Ideas.

**Gap:** template-level policy 변경이 source repo main merge 전까지 downstream consumer에게 전달되지 않는 drift window 존재. release timing guidance 없음.

**검토 질문:** template-facing policy 변경을 소형 maintenance release의 release criteria로 명시할 것인가?

#### Axis 9. Source repo와 scaffolded product repo의 차이

**근거:** `docs/HARNESS-NAMING-RULES.md` branch guidance 주석 — "source repository는 Gitflow. scaffold product repository는 project-specific `docs/GIT-WORKFLOW.md`에서 override 가능."

**Gap:** 이번 검토의 conflict handling rule이 source repo(Gitflow) 기준으로 작성될 경우, GitHub Flow를 사용하는 scaffold product repo에서는 적용이 다를 수 있음.

**검토 질문:** conflict handling 문서에 "source repo(Gitflow) 기준 / product repo는 `docs/GIT-WORKFLOW.md` 우선"을 명시해야 하는가?

#### Axis 10. Release gate에서 충돌을 언제/어떻게 잡을지

**근거:** HARNESS.md HRN-002(Hard enforcement 후보) + CHORE-20260527-001 Tracking Finalization(수동 확인 기준 추가).

**Gap:** release gate에서 잡아야 할 충돌 유형 목록(Work ID 중복, STATUS pointer 불일치, DR 번호 중복, command/skill mirror drift)이 없음.

**검토 질문:** `/health` 또는 PR checklist에 "release gate conflict verification" step을 명시할 것인가?

---

### 접근 방법

Manual-first. 자동화(CI/hook/script)는 Out of Scope.

1. 10개 축 Gap → `docs/HARNESS-PROTOCOL.md`에 Parallel Work Conflict Resolution 섹션 신규 추가
2. NNN 재배정 절차·DR 번호 확인 절차 → `docs/HARNESS-NAMING-RULES.md` 보완
3. DR 번호 재확인 step → `.claude/commands/record-decision.md` + `.agents/skills/workflow-record-decision/SKILL.md` 양쪽 반영
4. command/skill mirror check row → `.claude/commands/health.md` + `.agents/skills/workflow-health/SKILL.md` cascade checklist 양쪽 반영
5. scaffold drift window guidance → 관련 문서 추가 또는 명시적 deferred 처리
6. L3 후보 항목 → `docs/backlog/HARNESS.md` Deferred Ideas 등록

## Done Criteria

- [x] 10개 검토 축 Gap 분석 완료, Discovery 섹션에 기록
- [x] Work ID NNN 재배정 절차 및 외부 참조 영향 처리 rule이 `docs/HARNESS-NAMING-RULES.md`에 반영됨
- [x] STATUS/index conflict 발생 시 Work frontmatter 기준 복구 절차가 `docs/HARNESS-PROTOCOL.md`에 추가됨
- [x] DR-### 번호 확인 절차가 `record-decision` command + `workflow-record-decision` skill 양쪽에 반영됨
- [x] command/skill mirror atomicity check row가 `health` command + `workflow-health` skill cascade checklist 양쪽에 추가됨
- [x] scaffold drift window guidance가 관련 문서에 추가됨 (또는 명시적 deferred 처리)
- [x] hard enforcement 및 자동화가 필요한 항목이 별도 L3 후보로 `docs/backlog/HARNESS.md`에 등록됨
- [x] cascade 영향 문서 점검 완료 (HARNESS-PROTOCOL.md, HARNESS-NAMING-RULES.md, health command/skill, record-decision command/skill)

## Verification

- 두 feature branch가 같은 Work ID를 제안하는 시나리오를 walk-through하여 신규 NNN 재배정 rule로 resolve 가능한지 확인
- STATUS Active Work table conflict → Work frontmatter 기준 재구성 가능한지 확인
- Work index conflict → Work file path 기반 수동 복구 가능한지 확인
- `docs/decisions/` 기준 현재 최신 DR 번호를 작업 시점에 재확인하고, DR 번호 재확인 절차가 신규 rule에 명시되는지 확인
- `.claude/commands/{name}.md` 목록과 `.agents/skills/workflow-{name}/SKILL.md` 목록이 1:1 대응되는지 비교
- health/record-decision 변경 시 대응 command + skill 양쪽이 모두 반영됐는지 확인
- cascade 영향 문서 변경 후 `git diff --check` 통과 확인

## Checkpoints

| CP | Description | Status |
|----|-------------|--------|
| 1  | 10개 검토 축 분석 및 Gap 정리 | Done |
| 2  | HARNESS-NAMING-RULES.md NNN 재배정·DR 번호 확인 절차 추가 | Done |
| 3  | HARNESS-PARALLEL-WORK-CONTROLS.md 신규 생성 + HARNESS-PROTOCOL.md §17 조건부 pointer로 교체 | Done |
| 4  | health command + workflow-health skill cascade checklist에 command/skill mirror atomicity row 추가 | Done |
| 5  | record-decision command + workflow-record-decision skill에 DR 번호 재확인 step 추가 | Done |
| 6  | scaffold drift window guidance 추가 또는 명시적 deferred 처리 | Done |
| 7  | L3 후보 항목 HARNESS.md 등록 | Done |
| 8  | cascade 점검 및 validation | Done |

## Discovery

### CP-1 Cross-check 결과

- **Axis 6 재평가**: record-decision command에 이미 "기존 DR 목록 확인" step이 있었음. Gap은 "감지 없음"이 아니라 "병렬 branch merge 직전 재확인 절차 없음"으로 좁혀짐.
- **Axis 7 재평가**: health cascade에 이미 command/skill suffix mapping과 mirror pair check가 있었음. Codex 검토 의견 확인: gap은 "변경 중 atomic update 강제" rule 부재.
- **Axis 8 (scaffold drift)**: HARNESS.md Deferred Ideas에 이미 등재됨. T12에 release timing guidance 한 줄 추가로 충분, 별도 문서 불필요.
- **Axis 10 (release gate)**: HARNESS-PROTOCOL.md §14 T15·T16·T17에 PR/commit 전 finalization check 존재. gap은 충돌 유형 목록의 부재 → `docs/HARNESS-PARALLEL-WORK-CONTROLS.md`에서 해소.
- **HARNESS.md Deferred Ideas**: CHORE-20260527-001 Discovery로 5개 항목이 이미 등재되어 있었음. CP-7은 신규 등록이 아니라 완료 참조 업데이트로 처리.
- **command/skill 현황**: 11:11 완전 일치. `health` ↔ `workflow-health`, `record-decision` ↔ `workflow-record-decision` 양쪽 동일하게 수정함으로써 mirror drift 없음 확인.
- **최신 DR 번호**: DR-020이 현재 최신. Work 파일 본문에 고정하지 않고 Verification에서 재확인하도록 처리함(Codex 검토 의견 반영).
- **Branch naming vs Work ID 순서**: 이 Work 자체가 branch 먼저 생성 후 Work ID 확정 패턴으로 진행됨. HARNESS-NAMING-RULES.md §Branch Naming과 Work ID 확정 순서에 권장 순서와 예외 처리 추가.

---

## Initial State Registration

`docs/STATUS.md` Active Work와 `docs/works/harness/README.md` Active 테이블에 아래 pointer가 반영됐다.

```
| CHORE-20260528-001 | 병렬/동시 작업 제어 모델 검토 | `docs/works/harness/CHORE-20260528-001-parallel-work-controls.md` |
```
