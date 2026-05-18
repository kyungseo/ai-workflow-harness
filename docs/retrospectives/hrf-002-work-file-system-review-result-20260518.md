# HRF-002 Work 파일 체계 심층 리뷰 결과

작성일: 2026-05-18
상태: 리뷰 결과
대상: `docs/retrospectives/hrf-002-work-file-system-review-request-20260518.md`
검토 범위: Work 파일 SSoT 전환, STATUS.md dashboard 전환, archive 구조, 다중 Work lifecycle, DR-013/014/015/016, Claude/Codex/Cursor 실행 표면

## Executive Summary

HRF-002의 핵심 방향은 타당하다. `STATUS.md`에 Active Work와 checkpoint 이력을 누적하던 구조를 버리고, 작업 단위별 Work 파일을 도입한 결정은 장기 세션 지속성, AI 도구 간 인계, 리뷰 가능한 이력 보존 측면에서 올바른 전환이다. `STATUS.md`는 현재 상태 dashboard와 routing pointer에 집중하고, 작업 세부 이력은 `docs/works/{category}/{ID}-{topic}.md`가 담당하는 구조가 더 안정적이다.

다만 현재 상태는 "완성된 운영 체계"라기보다 "좋은 구조 전환 이후 executable surface 정렬이 아직 남은 상태"다. 특히 DR-015와 DR-016은 Accepted 상태지만, 일부 command/rule/manual은 여전히 이전 규칙을 말한다. 장기간 작업이 지속될 때 시스템을 매끄럽게 유지하려면 decision 문서보다 agent가 실제로 읽는 entrypoint, command, rule, quick reference, scaffold template을 먼저 정합시켜야 한다.

우선순위 결론:

1. HRN-018을 먼저 처리해야 한다. DR-016의 Done / Archived 분리가 `.claude/commands/done.md`, `AGENTS.md`, `.cursor/rules/workflow.mdc`, `/start`, `/resume`, Work index template에 아직 충분히 반영되지 않았다.
2. HRN-017을 이어서 처리해야 한다. DR-015의 State Update Proposal 2계층 gate가 canonical workflow와 tool-specific surface에 적용되어야 한다.
3. DR-013의 Candidate 정의를 보정해야 한다. 현재 DR은 Candidate를 "Work 파일 없음"으로 정의하지만, 실제로는 Candidate 상태의 PRE-C1 Work 파일이 생성되어 있다.
4. `docs/harness-protocol/03-work-items-and-naming.md`의 Work File Rules를 확장해야 한다. 이 섹션이 권위 문서라면 lifecycle, gate, index, STATUS pointer, drift 처리까지 포함해야 한다.

## 검토 방법

다음 파일을 읽고 상호 정합성을 대조했다.

| 영역 | 확인 파일 |
| --- | --- |
| Review request | `docs/retrospectives/hrf-002-work-file-system-review-request-20260518.md` |
| Work spec / archive / gate / archive trigger | `docs/decisions/DR-013-work-file-spec.md`, `DR-014-archive-policy.md`, `DR-015-state-update-proposal-redesign.md`, `DR-016-work-done-archive-trigger.md` |
| Canonical workflow | `docs/AGENT-WORKFLOW.md`, `docs/harness-protocol/03-work-items-and-naming.md`, `docs/WORKFLOW-MANUAL.md` |
| Tool surfaces | `AGENTS.md`, `.claude/commands/work.md`, `.claude/commands/done.md`, `.claude/commands/start.md`, `.claude/commands/resume.md`, `.cursor/rules/workflow.mdc` |
| Live state | `docs/STATUS.md`, `docs/works/harness/README.md`, `docs/works/phase2/README.md`, `docs/backlog/HARNESS.md` |
| Current Work files | `docs/works/harness/HRF-002-work-system-refactor.md`, `docs/works/phase2/PRE-C1-arch-analysis.md` |
| Scaffold | `scripts/create-harness.sh` |

## 판단 기준

장기간 AI workflow는 "문서가 맞다"만으로 유지되지 않는다. 다음 표면이 함께 맞아야 한다.

| Layer | 역할 | Drift 발생 시 증상 |
| --- | --- | --- |
| Decision Records | 왜 이렇게 하는지, reversal cost가 무엇인지 | 설계 의도는 남지만 agent 행동은 바뀌지 않음 |
| Canonical protocol | 모든 도구가 공유하는 운영 규칙 | tool별 surface가 서로 다르게 행동 |
| Tool entrypoints / commands / rules | agent가 실제로 따르는 절차 | 다음 세션에서 곧바로 잘못된 작업 수행 |
| STATUS.md | 현재 dashboard, Active Work single view | 완료 작업이 Active처럼 보이거나 작업 우선순위 왜곡 |
| Work files | 작업 단위 SSoT, checkpoints, discovery | 세션 재개 시 마지막 진행 상태 손실 |
| Work index README | category별 local view | Work 파일은 맞지만 목록이 틀려 탐색 비용 증가 |
| Backlog | Candidate pool, 향후 작업 inventory | Active/Done과 후보 상태 혼재 |
| Scaffold script | 신규 프로젝트 첫 경험 | 새 프로젝트가 처음부터 구버전 workflow로 생성 |

HRF-002 이후에는 변경 영향도를 이 Layer 순서로 추적해야 한다. 특히 command/rule/scaffold는 "문서 cascade"의 보조 대상이 아니라 workflow 구조 변경의 필수 대상이다.

## 시뮬레이션: Phase 안에서 다수 Work 운용

아래는 Phase 2 pre-entry를 기준으로, 여러 Work가 생성되고 일부가 Active로 운용되는 과정을 시뮬레이션한 결과다.

### S0. Phase Dashboard 초기 상태

`STATUS.md`는 다음 역할만 가져야 한다.

- Current phase / focus
- Active Work 포인터 목록
- Phase completion criteria
- Blockers and Open Questions
- Recent Decisions rolling digest
- Next Actions

작업 세부 계획, checkpoint, discovery는 `STATUS.md`에 쓰지 않는다. 이 원칙은 맞다. 다만 현재 `STATUS.md`의 `Current focus`와 `Active plan`은 HRF-002 완료 이후에도 HRF-002를 가리키고 있고, Active Work는 비어 있다. Work 파일 기준으로는 HRF-002가 Done이므로 dashboard와 Work SSoT 사이 drift가 존재한다.

권장 규칙:

- `STATUS.md Current focus`는 "현재 진행 중인 가장 중요한 work" 또는 "현재 phase focus" 중 하나로 의미를 고정해야 한다.
- Active Work가 비어 있는데 `Active plan`이 Done work를 가리키는 상태는 허용하지 않는다.
- 완료된 work는 `Phase completion criteria`와 Recent Decisions에는 남을 수 있지만, `Current focus`와 `Active plan`에서는 제거되어야 한다.

### S1. Candidate Pool 구성

Phase 2 pre-entry 후보:

- PRE-C1: Phase 1 아키텍처 현황 분석
- PRE-B: 개발환경 전략 결정
- PRE-C2: Phase 2 요건 정의 확정
- HRN-017: DR-015 구현
- HRN-018: DR-016 구현

질문은 "Candidate일 때 Work 파일이 존재할 수 있는가"다.

현재 DR-013은 Candidate를 `docs/backlog/`에만 존재하고 Work 파일이 없는 상태로 정의한다. 하지만 현재 repo에는 `docs/works/phase2/PRE-C1-arch-analysis.md`가 `status: Candidate`로 존재한다. 이 사용법은 실무적으로 나쁘지 않다. 오히려 큰 작업은 착수 전에도 Work 파일 초안이 있는 편이 planning 품질이 높다.

따라서 선택지가 필요하다.

| 선택지 | 의미 | 판단 |
| --- | --- | --- |
| A. Candidate는 Work 파일 없음 | backlog가 후보의 유일한 위치 | 단순하지만 큰 작업의 사전 분해를 담기 어렵다 |
| B. Candidate Work 파일 허용 | backlog 항목이 있고, 승인 전 Work 파일 초안도 가능 | 현재 실제 사용과 맞고 planning에 유리하다 |
| C. Draft 상태 추가 | Candidate(backlog only)와 Draft(work file exists)를 분리 | 가장 엄밀하지만 상태가 하나 늘어난다 |

권장안은 B다. 상태 수를 늘리지 않고, DR-013을 "Candidate는 기본적으로 backlog 항목이며, 큰 작업은 착수 전 Candidate Work 파일 초안을 가질 수 있다"로 보정한다. 이 경우 Work index도 Candidate 섹션을 가져야 한다.

### S2. 하나 이상의 Active Work 등록

시나리오:

1. HRN-018을 Active로 올린다.
2. PRE-C1도 병행 준비가 필요해 Active로 올린다.
3. HRN-017은 Candidate로 남긴다.

이때 `STATUS.md Active Work`는 진행 중인 Work의 single view가 된다.

권장 Active Work table:

```markdown
| ID | Priority | Status | Work File |
| --- | --- | --- | --- |
| HRN-018 | P1 | Active | `docs/works/harness/HRN-018-done-archive-trigger.md` |
| PRE-C1 | P0 | Active | `docs/works/phase2/PRE-C1-arch-analysis.md` |
```

현재 STATUS template은 `ID | Status | Work File`만 갖는다. 다중 Active Work에서는 priority가 없으면 작업 순서를 dashboard에서 판단하기 어렵다. DR-015는 "우선순위(P0 > P1 > P2)로 작업 순서 결정"을 말하므로, STATUS Active Work에 Priority 열을 추가하는 편이 더 일관된다.

대신 STATUS에 scope, done criteria, branch, verification을 다시 넣으면 dashboard 축소 목적이 깨진다. Priority만 추가하는 것이 적정선이다.

### S3. Work A 실행 중 Checkpoint 업데이트

예: HRN-018에서 `.claude/commands/done.md` 수정 완료 후 CP1을 Done 처리한다.

DR-015 기준:

- Work 파일 Checkpoint 업데이트: 승인 불필요, 실행 후 보고
- Discovery 추가: 승인 불필요, 실행 후 보고
- STATUS.md 변경: 변경 유형에 따라 gate 적용

이 방향은 실용적이다. 다만 tool surface에 "Work 파일 CP 업데이트는 Layer 1 low-friction update"라는 문장이 아직 충분하지 않다. command와 rule에 반영하지 않으면 agent는 모든 상태 변경을 STATUS Update Proposal로 과하게 묶거나, 반대로 Done 전환까지 무심코 처리할 수 있다.

필요한 보강:

- `.claude/commands/work.md`: 계획 단계에서 Layer 1/2 상태 변경 계획을 명시.
- `.claude/commands/resume.md`: drift 보고 후 Work 파일 CP/Discovery 정정은 Layer 1인지, STATUS 수정은 Layer 2인지 구분.
- `AGENTS.md`: Codex 절차에도 동일한 gate vocabulary 사용.
- `.cursor/rules/workflow.mdc`: Cursor가 Work 파일 변경과 STATUS 변경을 다르게 취급하도록 명시.

### S4. Work A Done 처리

예: HRN-018의 Done Criteria와 Verification이 모두 통과했다.

DR-016 기준 Done 처리:

1. Work 파일 frontmatter `status: Done`, `actual_end` 기입
2. Done Criteria 확인
3. category README에서 Active -> Done 테이블 이동
4. STATUS Active Work 포인터 제거 제안

여기서 Done은 archive가 아니다. 리뷰 대기, 사용자 확인, 외부 참조 등의 이유로 Work 파일은 `docs/works/{category}/`에 남을 수 있다.

현재 문제:

- `.claude/commands/done.md`는 Done 처리와 archive 이동을 한 흐름으로 묶는다.
- `.cursor/rules/workflow.mdc`도 Done→Archive flow를 즉시 git mv로 설명한다.
- `AGENTS.md`도 Codex `/done` mapping에서 git mv를 포함한다.
- `docs/WORKFLOW-MANUAL.md`도 `/done` 시 archive 이동을 즉시 수행한다고 설명한다.

이는 HRF-002 이후 가장 큰 operational hazard다. 다음 agent가 `/done`을 수행하면 사용자가 의도한 "리뷰 후 archive" 정책을 깨고 Work 파일을 archive로 이동시킬 수 있다.

### S5. Done 상태의 Work가 다음 세션에 남아 있음

예: HRF-002는 Done이지만 review 결과 작성 전까지 archive 보류 상태다.

이 상태는 합법적이어야 한다. 다만 다음 세션 시작 시 agent가 이를 감지하고 질문해야 한다.

권장 `/start` 동작:

1. `STATUS.md` current sections 확인
2. `docs/works/*/*.md` 중 `status: Done`이고 archive에 없는 항목이 있는지 가볍게 탐지
3. 발견 시 "archive 대기 Work"로 보고
4. 사용자에게 archive 승인 여부를 묻거나, 리뷰 중이면 보류 사유를 Discovery에 남기도록 제안

권장 `/resume` 동작:

1. 대상 ID가 Done이면 작업 재개 금지
2. 후속 보정이 필요하면 신규 Work로 분리 제안
3. archive 대기 상태라면 archive 제안

현재 `/resume`은 Done 상태 재개 금지를 말하지만, archive 대기 Work를 찾아 archive 제안하는 절차는 부족하다. `/start`에는 Done 항목 탐지 자체가 없다.

### S6. Archive 처리

Archive는 다음 경우에 수행한다.

- 사용자가 명시적으로 archive 승인
- `/start` 또는 `/resume`에서 Done 항목을 발견했고 사용자가 이동 승인
- 2세션 이상 Done 상태로 남아 `/health` 점검 대상이 됨

Archive 처리 순서:

1. archive 대상 Work 파일을 최종 읽는다.
2. `status: Archived`로 바꾸고 Discovery에 archive 이유와 일자를 남긴다.
3. `docs/archive/docs/works/{category}/` 존재 확인.
4. `git mv`로 이동한다.
5. category README에서 Done -> Archived로 이동한다.
6. `STATUS.md`에는 Active pointer가 이미 없어야 한다. 남아 있으면 drift로 보고한다.

주의점: `status: Archived`를 기입한 뒤 `git mv`해야 archive 위치의 파일이 Archived 상태로 남는다. 이 순서가 command에 명시되어야 한다.

### S7. Multi Active Work 중 하나만 Done

예: HRN-018 Done, PRE-C1 Active 유지.

원칙:

- HRN-018 Done 처리는 PRE-C1에 영향을 주지 않는다.
- `STATUS.md Active Work`에서는 HRN-018만 제거된다.
- PRE-C1 Work 파일과 Checkpoints는 그대로 유지된다.
- Next Actions는 필요하면 HRN-017을 승격 후보로 재정렬한다.

DR-015의 "각 Work는 독립 gate" 원칙은 맞다. 다만 실제 table에 priority가 없고, command가 대상 Work ID 명시를 강제하지 않으면 멀티 Work 상황에서 엉뚱한 Work의 README/STATUS 행을 수정할 위험이 있다.

필요한 rule:

- 모든 State Update Proposal은 대상 Work ID를 제목 또는 첫 문장에 포함한다.
- Work index 수정 시 category와 ID를 함께 말한다.
- `STATUS.md Active Work` 제거 제안은 "어느 ID의 어떤 pointer를 제거하는지" 1줄로 명시한다.

### S8. Work 간 의존성

예: HRN-017은 DR-015 구현이고, HRN-018은 DR-016 구현이다. 둘 다 workflow surface를 건드리므로 순서가 중요하다.

현재 Work frontmatter에는 dependencies 필드가 없다. Backlog에는 Dependencies 열이 있지만, Work 파일 자체에는 의존성을 표현할 위치가 없다. 장기 작업에서 Work 파일이 SSoT라면 dependency도 Work 파일에 있어야 한다.

권장:

- DR-013 frontmatter에 `dependencies: []`를 추가하거나, `related_work: []`를 추가한다.
- 최소한 Work 파일 Plan 섹션에 Dependencies subsection을 표준화한다.
- `STATUS.md Active Work`는 dependency를 담지 않는다. dashboard가 다시 비대해지기 때문이다.

## 발견된 주요 문제

### F1. DR-016과 executable surface 불일치

심각도: High

DR-016은 Done과 Archived를 분리했지만, 실제 command/rule/manual은 즉시 archive 이동을 말한다.

영향:

- `/done` 실행 시 사용자가 원한 리뷰 대기 상태를 건너뛸 수 있다.
- Work 파일이 archive로 너무 빨리 이동해 현재 리뷰/후속 보정의 참조성이 떨어진다.
- Cursor/Codex/Claude가 서로 다른 타이밍에 archive할 수 있다.

수정 대상:

- `.claude/commands/done.md`
- `.claude/commands/start.md`
- `.claude/commands/resume.md`
- `AGENTS.md`
- `.cursor/rules/workflow.mdc`
- `docs/WORKFLOW-MANUAL.md`
- `docs/harness-protocol/03-work-items-and-naming.md`
- `docs/works/{category}/README.md` template 및 현재 index 파일

### F2. DR-015 2계층 gate가 canonical workflow에 미반영

심각도: High

DR-015는 State Update Proposal을 Layer 1 / Layer 2로 재설계했지만, `docs/AGENT-WORKFLOW.md`와 여러 command/rule은 여전히 STATUS Update Proposal만 말한다.

영향:

- Work 파일 Checkpoint 업데이트가 과도한 승인 gate에 묶일 수 있다.
- 반대로 `status: Done` 같은 중요한 전환이 단순 checkpoint처럼 처리될 수 있다.
- 멀티 Active Work에서 대상 Work ID 명시가 누락될 수 있다.

수정 대상:

- `docs/AGENT-WORKFLOW.md`
- `docs/HARNESS-PROTOCOL.md`
- `docs/HARNESS-QUICK-REFERENCE.md`
- `docs/harness-protocol/01-session-state-machine.md`
- `docs/harness-protocol/05-triggers-and-cascade.md`
- `docs/harness-protocol/06-recovery-and-validation.md`
- `.claude/commands/work.md`, `resume.md`, `done.md`, `pick.md`, `register.md`, `health.md`
- `AGENTS.md`
- `.cursor/rules/workflow.mdc`, `.cursor/rules/output-format.mdc`, `.cursor/rules/git-commit.mdc`, `.cursor/rules/coding.mdc`
- `prompts/codex-session-start.md`, `prompts/cursor-session-start.md`
- `scripts/create-harness.sh`

### F3. Candidate lifecycle 정의와 실제 사용 불일치

심각도: Medium

DR-013은 Candidate를 Work 파일 없음으로 정의하지만, PRE-C1은 Candidate 상태의 Work 파일로 존재한다.

권장 결정:

- Candidate Work 파일을 허용한다.
- Work index README에 Candidate / Active / Done / Archived 섹션을 둔다.
- `STATUS.md Active Work`에는 Candidate를 올리지 않는다.

대안:

- Draft 상태를 추가한다. 단, 지금 단계에서는 복잡도 증가 대비 이득이 크지 않다.

### F4. Work index README 구조가 DR-016과 맞지 않음

심각도: Medium

현재 `docs/works/harness/README.md`와 `docs/works/phase2/README.md`는 Active와 Done / Archived만 있다. DR-016은 Active / Done / Archived 3단 구조를 제안한다. Candidate Work 파일을 허용한다면 Candidate도 필요하다.

권장 구조:

```markdown
## Candidate

| ID | Title | Priority | Appetite | Work File |
| --- | --- | --- | --- | --- |

## Active

| ID | Title | Priority | Start | Work File |
| --- | --- | --- | --- | --- |

## Done (archive pending)

| ID | Title | actual_end | Hold Reason |
| --- | --- | --- | --- |

## Archived

| ID | Title | actual_end | Archive |
| --- | --- | --- | --- |
```

### F5. Live state drift: HRF-002 Done이 여러 곳에서 Active로 남음

심각도: Medium

확인된 drift:

- `docs/works/harness/HRF-002-work-system-refactor.md`: `status: Done`, `actual_end: 2026-05-18`
- `docs/works/harness/README.md`: HRF-002가 Active 표에 있음
- `docs/backlog/HARNESS.md`: HRF-002가 Active Refactor 표에서 Active
- `docs/STATUS.md`: Active Work는 비었지만 Current focus와 Active plan은 HRF-002를 가리킴

이 drift는 Work 파일 전환 직후 발생하기 쉬운 유형이다. `/health`가 반드시 잡아야 한다.

권장:

- HRN-018에서 Done/Archive 분리와 함께 현재 drift를 정리한다.
- `/health`에 "Work frontmatter status vs Work index vs STATUS Active Work vs backlog status" cross-check를 추가한다.

### F6. `docs/works/README.md` 없음

심각도: Low

G3 시뮬레이션은 scaffold에 `docs/works/README.md`를 생성한다고 설명하지만, 현재 repo에는 root `docs/works/README.md`가 없다. 신규 프로젝트 scaffold와 현재 템플릿 repo의 실제 구조가 다르다.

권장:

- 현재 repo에도 `docs/works/README.md`를 두어 category 안내와 lifecycle 요약을 제공한다.
- `scripts/create-harness.sh`가 생성하는 root README와 동일한 최소 구조를 유지한다.

### F7. `appetite`는 유지하되 사용 규칙이 필요함

심각도: Low

`appetite` 필드는 useful하다. 다만 추정이 어려운 작업에서 형식적으로 채워질 위험이 있다.

권장:

- `appetite`는 estimate가 아니라 "이 이상 커지면 재분해를 고려할 시간 상자"라고 정의한다.
- `/resume` 또는 checkpoint에서 appetite 초과가 보이면 scope split 또는 신규 Work 분리를 제안한다.

## 어디까지 건드려야 하는가

이번 구조 변경은 단일 문서 수정으로 끝나지 않는다. 장기 일관성을 위해 다음 범위까지는 반드시 cascade해야 한다.

### 필수 수정 범위

| 변경 유형 | 반드시 수정할 곳 |
| --- | --- |
| Work lifecycle 변경 | DR, `03-work-items-and-naming.md`, `done.md`, `start.md`, `resume.md`, `AGENTS.md`, `.cursor/rules/workflow.mdc`, `WORKFLOW-MANUAL.md`, Work index template, scaffold |
| STATUS dashboard 역할 변경 | `STATUS.md`, `AGENT-WORKFLOW.md`, `HARNESS-QUICK-REFERENCE.md`, `WORKFLOW-MANUAL.md`, `register/pick/work/resume/done` commands, Codex/Cursor rules |
| State Update gate 변경 | DR-015, `AGENT-WORKFLOW.md`, recovery/validation protocol, command files, Cursor rules, Codex entrypoint, prompts |
| Archive path 변경 | DR-014, document lifecycle protocol, done/archive procedure, scaffold directories, README/manual diagrams |
| Work file spec 변경 | DR-013, Work File Rules, Work index template, `work.md`, scaffold, existing Work files if required |

### 선택 수정 범위

| 변경 유형 | 선택 기준 |
| --- | --- |
| README root 설명 | 사용자 onboarding에 직접 영향이 있을 때 |
| Retrospectives | 설계 평가 또는 반복 리스크를 남길 때 |
| Historical snapshots | 원칙적으로 수정하지 않음. 필요하면 새 addendum 또는 live doc 수정 |
| Legacy Phase1 TODO-BLOCK | 보존 가치가 있으면 migration note만 추가. Work 파일로 강제 변환하지 않음 |

## 권장 To-Be 모델

### STATUS.md

역할: Phase dashboard와 Active Work single view.

포함:

- Current State
- Phase Completion Criteria
- Active Work pointer table
- Blockers / OQ
- Recent Decisions rolling digest
- Next Actions

포함하지 않음:

- Checkpoints
- Done Criteria 상세
- Verification 상세
- Discovery
- Work별 긴 scope 설명

권장 Active Work 열:

```markdown
| ID | Priority | Status | Work File |
| --- | --- | --- | --- |
```

### Work 파일

역할: 하나의 작업 단위 SSoT.

상태 의미:

| Status | 위치 | 의미 |
| --- | --- | --- |
| Candidate | `docs/works/{category}/` 또는 backlog only | 착수 전 후보. 큰 작업은 Work 파일 초안 허용 |
| Active | `docs/works/{category}/` | STATUS Active Work에 pointer 존재 |
| Done | `docs/works/{category}/` | 완료 검증 통과, archive 대기 가능 |
| Archived | `docs/archive/docs/works/{category}/` | 완전 종결 |

권장 frontmatter 추가 후보:

```yaml
dependencies: []
blocked_by: []
```

다만 지금 즉시 추가하지 않아도 된다. HRN-017/018 정렬 후 별도 HRN으로 검토하는 편이 안전하다.

### Work index README

역할: category별 local dashboard.

권장 섹션:

- Candidate
- Active
- Done (archive pending)
- Archived

`STATUS.md`와 중복되는 정보는 최소화한다. STATUS는 전체 Active single view이고, Work index는 category-level inventory다.

### Backlog

역할: 아직 Work 파일로 구체화되지 않았거나, 후보 pool로 남은 작업 목록.

규칙:

- Work 파일이 생성되어도 backlog 항목은 삭제하지 않는다. Status를 Candidate / Active / Done 등으로 맞춘다.
- Active 전환 시 backlog status와 Work status가 달라지면 drift로 본다.
- Work 파일이 SSoT지만 backlog는 phase planning inventory이므로, 둘 사이 링크가 필요하다.

## HRN-018 권장 작업 범위

목표: DR-016을 실행 표면에 반영하고 현재 HRF-002 Done drift를 정리한다.

수정 권장:

1. `.claude/commands/done.md`
   - Done 처리와 Archive 처리를 분리.
   - Done 처리: status/actual_end, Done Criteria, README Active -> Done, STATUS pointer removal proposal.
   - Archive 처리: explicit approval 또는 start/resume trigger 후 git mv.
2. `.claude/commands/start.md`
   - `docs/works/*/*.md` 중 Done but not archived 항목 탐지.
   - archive 제안 안내.
3. `.claude/commands/resume.md`
   - Done 대상은 재개 금지.
   - archive 대기면 archive 제안.
4. `AGENTS.md`
   - Codex `/done`, `/start`, `/resume` mapping을 DR-016과 일치.
5. `.cursor/rules/workflow.mdc`
   - Done과 Archive를 분리.
6. `docs/harness-protocol/03-work-items-and-naming.md`
   - Work File Rules에 lifecycle, Done hold, archive trigger, README/index 규칙 추가.
7. `docs/WORKFLOW-MANUAL.md`
   - 완료 절차 재작성.
8. `docs/works/harness/README.md`, `docs/works/phase2/README.md`
   - Candidate / Active / Done / Archived 구조로 변경.
9. 현재 HRF-002 상태 정리
   - HRF-002를 Done 또는 archive pending으로 index/backlog/status에 일관 반영.

주의: HRF-002 archive 이동 자체는 리뷰 결과 반영이 끝난 뒤 사용자 승인으로 수행하는 편이 맞다.

## HRN-017 권장 작업 범위

목표: DR-015의 State Update Proposal 2계층 gate를 모든 실행 표면에 반영한다.

핵심 문구:

- Layer 1: Work 파일 checkpoint/discovery 업데이트는 실행 후 보고.
- Layer 1 gated: Work `status: Done`, `actual_end`는 사용자 확인 필요.
- Layer 2 light: STATUS Active Work pointer 추가/제거는 대상 ID를 명시한 1줄 제안 후 승인.
- Layer 2 full: phase/focus/completion criteria/recent decisions는 기존 Proposal 수준 유지.
- Multi Active Work: 모든 state update는 대상 Work ID를 명시.

수정 권장:

- `docs/AGENT-WORKFLOW.md`
- `docs/HARNESS-PROTOCOL.md`
- `docs/HARNESS-QUICK-REFERENCE.md`
- `docs/harness-protocol/01-session-state-machine.md`
- `docs/harness-protocol/05-triggers-and-cascade.md`
- `docs/harness-protocol/06-recovery-and-validation.md`
- `.claude/commands/work.md`, `resume.md`, `done.md`, `pick.md`, `register.md`, `health.md`
- `AGENTS.md`
- `.cursor/rules/workflow.mdc`, `output-format.mdc`, `git-commit.mdc`, `coding.mdc`
- `prompts/codex-session-start.md`, `prompts/cursor-session-start.md`
- `scripts/create-harness.sh`

## `/health` 보강 제안

현재 구조에서는 `/health`가 단순 링크/경로 확인을 넘어 state consistency checker 역할을 해야 한다.

권장 check:

1. `docs/STATUS.md Active Work`의 모든 Work File path가 존재하는가.
2. STATUS Active Work의 각 ID가 Work frontmatter `id`와 일치하는가.
3. STATUS Active Work에 있는 Work는 `status: Active`인가.
4. `docs/works/*/*.md` 중 `status: Active`인 Work가 STATUS Active Work에 존재하는가.
5. `status: Done`인 Work가 STATUS Active Work에 남아 있지 않은가.
6. `status: Done`인 Work가 category README Done 섹션에 있는가.
7. archive 위치의 Work는 `status: Archived`인가.
8. backlog status와 Work status가 심하게 충돌하지 않는가.
9. `docs/works/*/README.md`가 Candidate / Active / Done / Archived 구조를 갖는가.
10. `docs/TODO` 구경로 참조가 live surface에 남아 있지 않은가.

이 check는 hard enforcement가 아니라 report-first가 맞다. 수정은 State Update Proposal 또는 해당 Work 계획을 통해 진행한다.

## 최종 의견

HRF-002는 방향이 맞고, 지금 되돌릴 이유는 없다. 오히려 Phase 2가 본격화되기 전에 Work 파일 체계로 전환한 것은 좋은 타이밍이다. 이 구조는 세션이 길어지고, AI 도구가 바뀌고, 작업이 중단/재개될수록 가치가 커진다.

하지만 Work 파일 체계의 성패는 파일 구조 자체보다 lifecycle과 gate를 agent가 일관되게 따르는지에 달려 있다. 현재 가장 위험한 지점은 DR-015/016의 설계가 command/rule/manual/scaffold에 완전히 전파되지 않은 것이다. 다음 작업은 기능 개발로 넘어가기보다 HRN-018과 HRN-017을 먼저 닫아야 한다.

권장 순서:

1. HRN-018: Done / Archived 분리와 archive trigger를 모든 실행 표면에 반영.
2. HRN-017: State Update Proposal 2계층 gate를 모든 실행 표면에 반영.
3. DR-013 보정: Candidate Work 파일 허용 여부 확정.
4. Work index README 구조 개편: Candidate / Active / Done / Archived.
5. `/health` state consistency check 보강.
6. 그 뒤 PRE-C1을 실제 Active Work로 착수하여 첫 product-side Work lifecycle을 검증.

이 순서로 정리하면 `STATUS.md`는 dashboard로 가볍게 유지되고, Work 파일은 장기 작업 이력을 안정적으로 보존하며, Claude/Codex/Cursor가 같은 lifecycle을 따라 움직이는 운영 체계가 된다.

---

## 2026-05-18 후속 조치 및 재시뮬레이션 결과

요청에 따라 위 리뷰 결과의 권고안을 실행 표면에 반영하고, 다중 Work lifecycle 관점에서 다시 시뮬레이션했다.

### 적용한 조치

#### 1. DR-016 Done / Archived 분리 반영

수정 범위:

- `.claude/commands/done.md`
- `.claude/commands/start.md`
- `.claude/commands/resume.md`
- `AGENTS.md`
- `.cursor/rules/workflow.mdc`
- `docs/WORKFLOW-MANUAL.md`
- `docs/harness-protocol/03-work-items-and-naming.md`
- `docs/works/harness/README.md`
- `docs/works/phase2/README.md`

핵심 변경:

- `/done`은 Work 파일을 즉시 archive하지 않는다.
- Done 처리의 범위를 `status: Done`, `actual_end`, Done Criteria 확인, README Active -> Done (archive pending), STATUS pointer 제거 제안으로 제한했다.
- Archive 이동은 사용자 명시 승인 또는 `/start`·`/resume`에서 Done 항목 발견 후 승인된 경우에만 수행하도록 정리했다.
- Archive 수행 시 `status: Archived`를 먼저 기입한 뒤 `git mv docs/works/{category}/{file}.md docs/archive/docs/works/{category}/` 순서로 처리하도록 명시했다.

#### 2. DR-015 State Update Gate 반영

수정 범위:

- `docs/AGENT-WORKFLOW.md`
- `docs/HARNESS-PROTOCOL.md`
- `docs/HARNESS-QUICK-REFERENCE.md`
- `docs/harness-protocol/01-session-state-machine.md`
- `docs/harness-protocol/05-triggers-and-cascade.md`
- `docs/harness-protocol/06-recovery-and-validation.md`
- `.claude/commands/work.md`
- `.claude/commands/resume.md`
- `.claude/commands/done.md`
- `.claude/commands/register.md`
- `.claude/commands/pick.md`
- `.claude/commands/health.md`
- `AGENTS.md`
- `.cursor/rules/*.mdc`
- `prompts/*session-start.md`
- `scripts/create-harness.sh`

핵심 변경:

- Layer 1 Work 파일 checkpoint/discovery 업데이트는 승인 없이 수행 후 보고한다.
- Layer 1 Work Done 처리(`status: Done`, `actual_end`)는 대상 Work ID를 명시하고 사용자 확인 후 수행한다.
- Layer 2 STATUS Active Work pointer 추가/제거는 대상 Work ID를 명시한 1줄 제안 후 승인으로 처리한다.
- Phase completion criteria, Current phase/focus, Recent Decisions는 기존 `STATUS Update Proposal` 수준을 유지한다.
- 멀티 Active Work 환경에서 모든 state update 제안은 대상 Work ID를 명시하도록 정리했다.

#### 3. Candidate Work 파일 모델 정리

수정 범위:

- `docs/decisions/DR-013-work-file-spec.md`
- `docs/harness-protocol/03-work-items-and-naming.md`
- `docs/works/phase2/README.md`
- `docs/works/README.md`

핵심 변경:

- Candidate는 기본적으로 backlog 항목이지만, 큰 작업은 착수 전 Candidate Work 파일 초안을 가질 수 있다고 DR-013을 보정했다.
- `docs/works/{category}/README.md` 권장 구조를 Candidate / Active / Done (archive pending) / Archived로 정리했다.
- PRE-C1은 Candidate Work 파일로 유지하고, STATUS Active Work에는 올리지 않았다.

#### 4. Live state drift 정리

수정 범위:

- `docs/STATUS.md`
- `docs/backlog/HARNESS.md`
- `docs/works/harness/README.md`
- `docs/works/harness/HRF-002-work-system-refactor.md`

핵심 변경:

- HRF-002는 Done 상태로 정리했다.
- `docs/STATUS.md`의 Active Work는 비워 두고, Current focus를 `Phase 2 pre-entry workflow stabilization`으로 정리했다.
- HRF-002는 archive하지 않고 Done (archive pending)으로 유지했다. 리뷰 결과와 후속 검증이 끝난 뒤 archive 가능하다.
- DR-016을 Recent Decisions에 추가했다.

#### 5. HRN-017 / HRN-018 Work 파일 생성 및 Done 처리

신규 Work 파일:

- `docs/works/harness/HRN-017-state-update-gate.md`
- `docs/works/harness/HRN-018-done-archive-trigger.md`

두 Work 모두 이번 후속 정합성 작업으로 Done 처리했다.
아직 archive하지 않고 `docs/works/harness/README.md`의 Done (archive pending) 섹션에 남겼다.

### 재시뮬레이션

#### Scenario A. Phase 내 Candidate Work 파일 존재

상태:

- PRE-C1은 `docs/works/phase2/PRE-C1-arch-analysis.md`에 `status: Candidate`로 존재한다.
- `docs/works/phase2/README.md` Candidate 섹션에 PRE-C1이 등록되어 있다.
- `docs/STATUS.md` Active Work에는 PRE-C1이 없다.

판정: 정상.

Candidate Work 파일 허용 모델과 일치한다. 착수 전 분해는 가능하지만 dashboard에는 올라가지 않는다.

#### Scenario B. 다중 Done Work archive 대기

상태:

- HRF-002: `status: Done`
- HRN-017: `status: Done`
- HRN-018: `status: Done`
- 세 항목 모두 `docs/works/harness/README.md` Done (archive pending) 섹션에 있다.
- `docs/STATUS.md` Active Work에는 없다.

판정: 정상.

Done과 Archived를 분리한 DR-016 모델과 일치한다. 다음 `/start` 또는 `/resume`은 이 항목들을 archive 대기로 보고하고, 사용자 승인 전에는 `git mv`를 실행하지 않아야 한다.

#### Scenario C. `/start`

예상 흐름:

1. `docs/STATUS.md` Current State, Active Work, Blockers/OQ, Next Actions 확인
2. `docs/works/*/*.md` 중 `status: Done`인 archive 대기 Work 파일 확인
3. HRF-002, HRN-017, HRN-018을 archive pending으로 보고
4. 다음 후보로 PRE-C1, PRE-B, PRE-C2 제안

판정: 정상.

`.claude/commands/start.md`에 archive 대기 Work 탐지와 승인 전 `git mv` 금지 문구를 반영했다.

#### Scenario D. `/resume HRN-018`

예상 흐름:

1. HRN-018 Work 파일 확인
2. `status: Done`이므로 재개하지 않음
3. 후속 보정이 필요하면 신규 Work 분리 제안
4. archive 대기 상태로 보고하고 archive 승인 여부 질문

판정: 정상.

`.claude/commands/resume.md`, `AGENTS.md`, `.cursor/rules/workflow.mdc`가 Done Work 재개 금지와 archive 제안을 말한다.

#### Scenario E. `/work PRE-C1`

예상 흐름:

1. `docs/backlog/PHASE2.md`에서 PRE-C1 확인
2. 기존 Candidate Work 파일 `docs/works/phase2/PRE-C1-arch-analysis.md` 로드
3. Plan, Done Criteria, Checkpoints를 반영한 작업 계획 제시
4. 승인 후 PRE-C1을 Active로 전환
5. STATUS Active Work pointer 추가는 대상 Work ID를 명시한 1줄 State Update 제안 후 승인

판정: 정상.

Candidate Work 파일이 실제 착수 전 계획 품질을 높이는 방향으로 작동한다.

#### Scenario F. 멀티 Active Work 중 하나만 Done

가상 상태:

- PRE-C1 Active
- HRN-FUT-X Active
- PRE-C1만 Done 처리

예상 결과:

- PRE-C1 Work 파일만 `status: Done`, `actual_end` 기입
- PRE-C1만 STATUS Active Work에서 제거 제안
- HRN-FUT-X는 변경 없음
- 모든 제안은 대상 Work ID를 명시

판정: 정상.

DR-015의 "각 Work는 독립 gate" 원칙이 canonical workflow와 tool surfaces에 반영됐다.

### 검증 내역

실행한 확인:

```bash
rg -n "^id:|^status:|^actual_end:" docs/works/harness/*.md docs/works/phase2/*.md
rg -n "HRF-002|HRN-017|HRN-018|PRE-C1" docs/STATUS.md docs/works/harness/README.md docs/works/phase2/README.md docs/backlog/HARNESS.md docs/backlog/PHASE2.md
rg -n "State Update Gate|Layer 1|Layer 2|archive 대기|Archive 처리|status: Archived|Done \\(archive pending\\)" docs/AGENT-WORKFLOW.md docs/harness-protocol .claude/commands AGENTS.md .cursor/rules docs/WORKFLOW-MANUAL.md prompts scripts/create-harness.sh
rg -n "docs/TODO|TODO 분해|TODO 파일|Done→Archive|STATUS Update Proposal 필요" AGENTS.md docs/AGENT-WORKFLOW.md docs/HARNESS-PROTOCOL.md docs/HARNESS-QUICK-REFERENCE.md docs/harness-protocol .claude .cursor prompts scripts/create-harness.sh docs/WORKFLOW-MANUAL.md docs/STATUS.md docs/works docs/backlog/HARNESS.md
python3 -m json.tool .claude/settings.json
scripts/create-harness.sh --dry-run --profile generic sample-app /private/tmp/sample-harness-check
```

검증 결과:

- Work frontmatter 상태는 의도와 일치한다.
  - HRF-002, HRN-017, HRN-018: Done
  - PRE-C1: Candidate
- STATUS Active Work는 비어 있고, Done Work는 STATUS Active Work에 남아 있지 않다.
- Harness backlog의 HRF-002, HRN-017, HRN-018은 Done으로 정리됐다.
- Work index는 Candidate / Active / Done (archive pending) / Archived 구조로 정리됐다.
- State Update Gate 문구가 canonical workflow, protocol, command, Codex entrypoint, Cursor rules, prompts, scaffold에 반영됐다.
- 남은 `docs/TODO` 언급은 HRF-002 Work 파일의 migration history와 backlog의 legacy TODO 재분류 후보처럼 역사적 맥락 또는 별도 후보 항목에 한정된다.
- `.claude/settings.json`은 JSON 파싱을 통과했다.
- `scripts/create-harness.sh --dry-run --profile generic`은 신규 scaffold 대상 파일 목록을 정상 출력하고 파일을 쓰지 않고 종료했다.

### 남은 리스크

1. HRF-002, HRN-017, HRN-018은 아직 archive pending이다. 리뷰 결과 확인 후 명시 승인으로 archive 이동하면 된다.
2. `docs/WORKFLOW-MANUAL.md`는 긴 사용자 매뉴얼이라 일부 예시 문맥에 `STATUS Update Proposal` 표현이 남아 있다. 고영향 STATUS 변경 설명에는 여전히 유효하지만, 다음 문서 정리 때 "State Update Gate" 용어로 더 다듬을 수 있다.
3. `/health`는 규칙 문서에 check 항목을 추가했지만 자동 검사 스크립트는 아직 없다. HRN-002 hard enforcement 착수 시 자동화 대상으로 검토하면 된다.

### 최종 상태

HRF-002 후속 정합성 작업은 CHECKPOINT 상태로 볼 수 있다.
Work 파일 체계, STATUS dashboard 역할, State Update Gate, Done/Archived 분리가 주요 실행 표면에 반영됐다.
다음 작업은 PRE-C1 착수 또는 archive pending Work 파일 3개(HRF-002, HRN-017, HRN-018)의 명시적 archive 승인이다.

---

## 2026-05-18 추가 정렬 감사 및 조치

후속 감사에서 `WORKFLOW-MANUAL.md`, root entrypoint, Claude rules, session prompts, `docs/PLAN.md`에 남은 구 프로세스 표현을 확인하고 정리했다.

### 추가 조치

- `docs/WORKFLOW-MANUAL.md`
  - `STATUS.md`를 현재 상태 SSoT로 설명하던 문구를 dashboard로 보정했다.
  - Work 파일을 작업 단위 SSoT로 명확히 설명했다.
  - STATUS 관계 Mermaid에서 Checkpoints를 STATUS 내부에서 제거하고 Work 파일 노드로 이동했다.
  - Full Session Lifecycle Mermaid에 Work File Check, archive pending scan, State Update Gate를 반영했다.
  - context routing Mermaid의 `TODO` 노드를 `WORK`로 변경했다.
  - Slash Commands 표에서 `/register`, `/work`, `/resume`, `/done` 설명을 Work 파일 및 State Update Gate 기준으로 갱신했다.
  - T4 상세 섹션을 `TODO Decomposition`에서 `Work File Decomposition`으로 정리했다.
  - 신규/기존 프로젝트 초기화 예시와 manual checklist에서 `STATUS.md Checkpoints` skeleton을 제거했다.
- `CLAUDE.md`, `.claude/rules/docs-workflow.md`, `.claude/rules/git-workflow.md`
  - `STATUS Update Proposal gate` 중심 표현을 State Update Gate로 정렬했다.
- `prompts/claude-session-start.md`, `prompts/codex-session-start.md`, `prompts/cursor-session-start.md`, `prompts/README.md`
  - startup prompt에서 `STATUS.md Checkpoints` 로드 지시를 제거했다.
  - fallback prompt의 기본 상태 변경 표현을 State Update Gate로 정렬했다.
- `docs/PLAN.md`
  - live 디렉토리 구조에서 `docs/TODO/`를 제거하고 `docs/works/`와 `docs/archive/docs/works/` 구조로 갱신했다.

### 추가 검증

```bash
rg -n "STATUS Update Proposal|TODO Decomposition|TODO 분해|TODO 파일|docs/TODO|Active Work Notes|STATUS.md Active Work Notes" CLAUDE.md AGENTS.md .claude/rules/*.md .claude/commands/*.md .cursor/rules/*.mdc prompts/*.md prompts/README.md README.md docs/WORKFLOW-MANUAL.md docs/AGENT-WORKFLOW.md docs/HARNESS-PROTOCOL.md docs/HARNESS-QUICK-REFERENCE.md docs/harness-protocol/*.md docs/PLAN.md scripts/create-harness.sh
git diff --check
python3 -m json.tool .claude/settings.json
scripts/create-harness.sh --dry-run --profile generic sample-app /private/tmp/sample-harness-check
```

검증 결과:

- `git diff --check` 통과.
- `.claude/settings.json` JSON 파싱 통과.
- `create-harness.sh --dry-run --profile generic` 정상 종료.
- 남은 `STATUS Update Proposal` 표현은 phase/focus/recent decision 같은 고영향 Layer 2 변경 설명에 한정된다.
- 남은 `docs/TODO` 표현은 `docs/PLAN.md`의 legacy Phase 1 note처럼 역사적 참조에 한정된다.
- Mermaid 렌더러(`mmdc`)는 로컬에 없어 실제 이미지 렌더링은 수행하지 못했다. 대신 Mermaid 본문에서 구 프로세스 노드(`TODO`, STATUS 내부 Checkpoints, 단일 STATUS gate)를 현재 모델로 치환했다.

---

## 2026-05-18 재시뮬레이션 및 신규 scaffold 검증

다수의 command/rule/doc 정렬 이후, 리뷰 요청서의 Phase G 시뮬레이션 관점과 신규 프로젝트 적용 관점을 다시 검증했다.

### 검증 범위

1. 현재 repo 상태 기준 `/start`, `/resume`, `/work`, 멀티 Active Work Done 시나리오
2. `scripts/create-harness.sh` 신규 프로젝트 dry-run
3. `scripts/create-harness.sh` 신규 프로젝트 실제 생성 — `generic`, `spring-boot`
4. 기존 프로젝트 overlay 모드 — 기존 파일 overwrite 방지
5. 생성된 scaffold 내부의 Work file lifecycle, State Update Gate, profile 분리 확인

### 시뮬레이션 결과

#### 1. 현재 repo workflow 상태

- `HRF-002`, `HRN-017`, `HRN-018`은 `status: Done`, `actual_end: 2026-05-18`로 확인됐다.
- 세 Work 파일은 `docs/works/harness/README.md`의 Done (archive pending) 섹션에 남아 있고, `docs/STATUS.md` Active Work에는 남아 있지 않다.
- `/start` 시나리오에서는 세 Work 파일을 archive pending으로 보고하고, 사용자 승인 전 `git mv`를 실행하지 않는 흐름이 맞다.
- `/resume HRN-018` 시나리오에서는 Done Work 재개 금지, 후속 보정 신규 Work 분리, archive 승인 여부 질문 흐름이 맞다.
- `/work PRE-C1` 시나리오에서는 기존 Candidate Work 파일을 로드해 Plan/Done Criteria/Checkpoints를 반영하고, 착수 승인 후 Active 전환과 STATUS pointer 제안을 분리하는 흐름이 맞다.
- 멀티 Active Work 중 하나만 Done 되는 시나리오는 State Update Gate의 "각 Work 독립 gate" 원칙과 일치한다.

#### 2. 신규 scaffold 1차 검증에서 발견한 갭

1. `generic` profile에도 Java/Spring 전용 testing rule이 포함됐다.
   - `.claude/rules/testing.md`, `.cursor/rules/testing.mdc`는 Spring/JUnit/Testcontainers 전용이므로 generic 기본값과 충돌했다.
2. 신규 scaffold의 `docs/AGENT-WORKFLOW.md`가 State Update Gate 명칭은 포함했지만, canonical Layer 1/2 gate 표와 Work File Lifecycle 표를 포함하지 않았다.
   - 신규 프로젝트 첫 세션부터 현재 repo와 다른 운영 규칙을 갖게 되는 위험이 있었다.
3. canonical `docs/AGENT-WORKFLOW.md`를 그대로 복사하도록 바꾼 뒤에는 generic scaffold에도 이 repo의 Java/Spring Project Constants가 들어가는 문제가 발견됐다.

#### 3. 조치

- `scripts/create-harness.sh`
  - 신규 scaffold의 `docs/AGENT-WORKFLOW.md`는 canonical 파일을 복사하도록 변경했다.
  - `generic` profile에서는 Project Constants와 Verification Defaults를 placeholder로 후처리하도록 변경했다.
  - Java/Spring testing rules는 `spring-boot` profile에서만 포함되도록 변경했다.
- `docs/HARNESS-QUICK-REFERENCE.md`
  - Work 파일 예시에서 `P2-006-testcontainers.md`를 일반적인 `P1-001-initial-feature.md` 예시로 교체했다.

### 실행한 검증

```bash
rg -n "^id:|^status:|^actual_end:" docs/works/harness/HRF-002-work-system-refactor.md docs/works/harness/HRN-017-state-update-gate.md docs/works/harness/HRN-018-done-archive-trigger.md docs/works/phase2/PRE-C1-arch-analysis.md
rg -n "status: Done|status: Candidate" docs/works/*/*.md
rg -n "Done 상태|archive 대기|승인 전|git mv|status: Done|후속 보정|신규 작업" .claude/commands/start.md .claude/commands/resume.md .claude/commands/done.md AGENTS.md .cursor/rules/workflow.mdc docs/AGENT-WORKFLOW.md docs/harness-protocol/03-work-items-and-naming.md
rg -n "PRE-C1|Active Work|Next Actions|HRN-017|HRN-018|HRF-002" docs/STATUS.md docs/works/harness/README.md docs/works/phase2/README.md docs/backlog/HARNESS.md docs/backlog/PHASE2.md
./scripts/create-harness.sh --dry-run --profile generic sim-generic-c /private/tmp/harness-sim-generic-dry-20260518-C
./scripts/create-harness.sh --profile generic sim-generic-c /private/tmp/harness-sim-generic-20260518-C
./scripts/create-harness.sh --profile spring-boot sim-spring-b /private/tmp/harness-sim-spring-20260518-B
./scripts/create-harness.sh --existing --profile generic sim-existing /private/tmp/harness-sim-existing-20260518-A
find /private/tmp/harness-sim-generic-20260518-C/.claude/rules /private/tmp/harness-sim-generic-20260518-C/.cursor/rules -maxdepth 1 -type f
rg -n "State Update Gate|Layer 1|Layer 2|Work File Lifecycle" /private/tmp/harness-sim-generic-20260518-C/docs/AGENT-WORKFLOW.md
rg -n "Runtime:|Framework:|Build:|Architecture:|Base package|Verification Defaults|Java 21|Spring Boot|Testcontainers|P2-006|externally running Docker|docs/TODO|Active/Done 테이블" /private/tmp/harness-sim-generic-20260518-C/docs/AGENT-WORKFLOW.md /private/tmp/harness-sim-generic-20260518-C/docs/HARNESS-QUICK-REFERENCE.md /private/tmp/harness-sim-generic-20260518-C/.claude/rules /private/tmp/harness-sim-generic-20260518-C/.cursor/rules /private/tmp/harness-sim-generic-20260518-C/prompts
bash -n scripts/create-harness.sh
python3 -m json.tool .claude/settings.json
python3 -m json.tool /private/tmp/harness-sim-generic-20260518-C/.claude/settings.json
python3 -m json.tool /private/tmp/harness-sim-spring-20260518-B/.claude/settings.json
git diff --check
```

### 검증 결과

- `generic` scaffold는 더 이상 `.claude/rules/testing.md`, `.cursor/rules/testing.mdc`, `java-spring`, `role-backend`, Spring Boot 전용 prompt bundle을 포함하지 않는다.
- `spring-boot` scaffold는 Java/Spring rules와 Spring Boot prompt bundle을 포함한다.
- `generic` scaffold의 `docs/AGENT-WORKFLOW.md`는 State Update Gate Layer 1/2 표와 Work File Lifecycle을 포함한다.
- `generic` scaffold의 Project Constants와 Verification Defaults는 placeholder로 생성된다.
- 기존 프로젝트 overlay 모드는 기존 `README.md`를 `skip` 처리했고 overwrite하지 않았다.
- `.claude/settings.json`은 현재 repo, generic scaffold, spring scaffold 모두 JSON 파싱을 통과했다.
- `scripts/create-harness.sh`는 `bash -n`을 통과했다.
- `git diff --check` 통과.
- live surface의 stale phrase 검색 결과, 남은 `docs/TODO` 언급은 `docs/PLAN.md` legacy Phase 1 note와 `HRN-006` 재분류 후보에 한정된다.

### 남은 리스크

1. `scripts/create-harness.sh --help`는 아직 지원하지 않는다. 현재 usage는 unknown flag 오류 메시지와 스크립트 상단 주석으로만 확인된다. 사용성 개선 후보로는 남겨둘 수 있다.
2. `generic` scaffold에도 `prompts/README.md`에는 `--profile spring-boot` 사용 시 포함되는 Spring Boot 섹션이 남아 있다. 이는 profile 안내 문맥이라 허용 가능한 잔류로 판단했다.
3. `docs/WORKFLOW-MANUAL.md`는 scaffold에 그대로 복사되므로, generic 프로젝트에서도 Spring Boot profile 예시 설명은 남는다. 다만 해당 문맥은 "spring-boot profile 사용 시" 안내로 한정된다.

### 추가 제안: State Update 제안 예시 문서화

State Update Gate 자체는 canonical 문서와 tool surface에 반영됐지만, 실제 agent 응답에서 어떤 포맷으로 제안해야 하는지는 아직 예시가 없다.
특히 아래 항목은 포맷에 대한 이견이 있을 수 있으므로, 바로 운영 문서에 고정하기보다 별도 검토 후 반영하는 것이 낫다.

제안:

1. `docs/HARNESS-QUICK-REFERENCE.md`
   - 짧은 "State Update Proposal Examples" 섹션 추가
   - Layer 1 checkpoint/discovery 보고, Layer 1 Done 확인 요청, Layer 2 Active Work pointer 1줄 제안, Layer 2 고영향 STATUS Update Proposal의 최소 예시만 포함
2. `docs/WORKFLOW-MANUAL.md`
   - 더 자세한 예시와 판단 기준 추가
   - "보고형", "확인 요청형", "1줄 승인형", "정식 STATUS Update Proposal"을 구분
   - 멀티 Active Work 환경에서 대상 Work ID를 반드시 명시하는 예시 포함

검토 포인트:

- 예시가 너무 길어져 agent 응답을 장황하게 만들지 않는가?
- Layer 1 checkpoint/discovery 업데이트가 다시 과도한 승인 절차처럼 보이지 않는가?
- Work Done 처리와 STATUS pointer 제거가 하나의 승인으로 오해되지 않는가?
- Archive 제안 예시가 Done 처리와 섞이지 않고 별도 승인 흐름으로 보이는가?
- 한국어/영어 technical term 혼용이 DR-007 Bilingual Rules와 맞는가?

현재 권장 형태는 아래와 같다.

```md
State Update 완료: PRE-C1

- 대상 Work: PRE-C1
- 변경: CP1 Todo → Done, Discovery 1건 추가
- STATUS.md 변경: 없음
```

```md
State Update 제안: PRE-C1

docs/STATUS.md Active Work에 PRE-C1 pointer를 추가하겠습니다:
`PRE-C1 | P0 | Active | docs/works/phase2/PRE-C1-arch-analysis.md`

승인하면 STATUS.md Active Work 행만 수정하겠습니다.
```

```md
STATUS Update Proposal

변경 섹션:
- Current State
- Recent Decisions
- Next Actions

변경 이유:
PRE-C1 분석이 완료되어 Phase 2 진입 전 blocker가 해소됐고, 다음 작업 우선순위를 PRE-C2로 이동해야 합니다.

변경 후 상태:
- Current focus: Phase 2 requirement finalization
- Recent Decisions에 "PRE-C1 분석 결과 Phase 2 진입 가능" 추가
- Next Actions 1순위: PRE-C2

되돌리기 비용:
Low. STATUS.md dashboard 표현만 되돌리면 됩니다.
```

### 추가 제안: Quick Mode와 commit reference 정책 보정

현재 Work 파일 체계는 완결성과 세션 지속성은 크게 높였지만, L1 수준의 작은 작업까지 동일한 Work 파일 절차를 요구하면 생산성이 떨어질 수 있다.
특히 DR-013의 "모든 작업 항목은 Work 파일"이라는 표현은 실제 운영 기준보다 강하게 읽힐 수 있다.

#### 1. L1 작업의 기본 경로

L1 작업은 기본적으로 Work 파일을 만들지 않는 것이 적절하다.

대상 예시:

- 오타·문구 수정
- 단일 파일의 작은 문서 정리
- 명확한 config 한 줄 수정
- 단일 테스트 보강
- 이미 범위가 명확하고 세션을 넘기지 않는 작은 수정

이 경우 기록은 최종 응답, validation 결과, commit history로 충분하다.
STATUS.md와 Work 파일을 모두 건드리지 않는 것이 오히려 drift를 줄인다.

다만 아래 조건 중 하나라도 있으면 L1이어도 Work 파일 생성을 고려한다.

- 세션을 넘길 가능성이 있음
- 상태 변경이 여러 단계임
- 사용자나 agent가 나중에 맥락을 복구해야 함
- 여러 파일·도구·문서 표면에 cascade가 있음
- 사용자가 명시적으로 별도 추적을 요청함

#### 2. Quick Mode 제안

Work 파일 체계 옆에 "Quick Mode"를 명시하는 것이 좋다.

| Mode | 대상 | 기록 위치 |
| --- | --- | --- |
| Quick / 간편 모드 | L1, 단일 파일, 짧은 검증 | 최종 응답 + commit history |
| Standard Work | L2, 여러 파일, 하루 이상, checkpoint 필요 | Work 파일 |
| Full Work | L3, 아키텍처/인프라/정책/장기 작업 | Work 파일 + DR/retrospective 가능 |

Quick Mode closeout 예시:

```md
Quick Work 완료

- Scope: .cursor/rules/testing.mdc stale 문구 정리
- Verification: git diff --check
- State Update: 없음
- Commit: 아직 안 함
```

#### 3. related_commits 정책

Work 파일 frontmatter의 `related_commits`는 유용하지만, 무결성 장치가 아니라 탐색 보조 링크로 정의하는 편이 안전하다.

이유:

- 하나의 commit이 여러 Work의 결과를 함께 담을 수 있다.
- commit hash는 commit 이후에 생기므로 Work Done 처리와 순환 의존이 생길 수 있다.
- docs/workflow 작업은 여러 Work의 후속 정렬을 하나의 commit으로 묶는 일이 자연스럽다.

권장 정책:

- `related_commits`는 best-effort reference다.
- Work의 무결한 이력은 Work 파일 자체의 Plan, Done Criteria, Verification, Checkpoints, Discovery가 담당한다.
- 하나의 commit이 여러 Work를 포함하면 같은 commit id가 여러 Work에 들어갈 수 있다.
- mixed commit이면 Discovery나 closeout summary에 그 사실을 남기면 충분하다.
- 모든 commit 이후에 Work 파일을 다시 열어 `related_commits`를 갱신하는 것을 필수화하지 않는다.

예시:

```yaml
related_commits: [abc1234] # mixed commit: HRN-017, HRN-018, docs alignment
```

또는:

```md
## Discovery

- Commit `abc1234`는 HRN-017, HRN-018, HRF-002 follow-up을 함께 포함하는 mixed docs commit이다.
```

#### 4. 후속 반영 권고

- `docs/decisions/DR-013-work-file-spec.md`
  - "모든 작업 항목은 Work 파일" 표현을 완화한다.
  - Work 파일은 decomposition criteria를 만족하거나 인계·장기 추적이 필요한 작업에 생성한다고 명시한다.
- `docs/harness-protocol/03-work-items-and-naming.md`
  - Quick Mode와 Work 파일 생성 기준을 명시한다.
  - `related_commits`를 best-effort reference로 설명한다.
- `docs/HARNESS-QUICK-REFERENCE.md`
  - L1 Quick Mode closeout 예시를 추가한다.
- `.claude/commands/work.md`, prompts
  - L1 작업은 Work 파일 없이 진행할 수 있음을 계획 단계에서 판단하도록 보강한다.

판단:

Work 파일은 "모든 작업의 의무"가 아니라 "장기 기억 장치"로 두는 것이 좋다.
Quick Mode는 작은 작업의 빠른 통과 차선이며, 현재 체계의 완결성을 해치지 않고 생산성을 보존한다.

---

## 2026-05-18 Cascade/Quick Mode/State Update 예시 반영

앞의 세 가지 추가 제안(Trigger/Cascade 완전성, State Update 제안 예시, Quick Mode와 commit reference 정책)을 실제 운영 문서와 tool surface에 반영했다.

### 반영 내용

1. Trigger/Cascade 확장
   - `docs/harness-protocol/05-triggers-and-cascade.md`에 T11~T13 추가
     - T11: tool surface 변경
     - T12: scaffold source 또는 canonical workflow 변경
     - T13: Quick Mode L1 변경
   - Cascade Action Levels(A~D)와 Tool Surface Cascade Matrix 추가
   - cascade는 자동 수정이 아니라 확인 → 발견 보고 → 승인 후 수정 → 별도 Work/DR 분리 단계로 처리하도록 명시
2. Quick Mode 반영
   - `docs/harness-protocol/03-work-items-and-naming.md`에 Quick Mode 섹션 추가
   - `docs/decisions/DR-013-work-file-spec.md`의 "모든 작업 항목은 Work 파일" 표현을 완화
   - `docs/AGENT-WORKFLOW.md`, `docs/HARNESS-QUICK-REFERENCE.md`, `.claude/commands/work.md`, `.cursor/rules/*.mdc`, session prompts에 실행 모드 판단 기준 반영
3. Commit reference 정책 보정
   - `related_commits`를 best-effort reference로 정의
   - mixed commit은 여러 Work에서 같은 commit id를 참조할 수 있고, 필요하면 Discovery 또는 closeout summary에 남기면 충분하다고 명시
4. State Update 제안 예시 문서화
   - `docs/HARNESS-QUICK-REFERENCE.md`에 짧은 State Update Examples 추가
   - Layer 1 보고형, Layer 2 Active Work pointer 제안, 고영향 STATUS Update Proposal 예시를 포함
5. Manual/scaffold 동기화
   - `docs/WORKFLOW-MANUAL.md`에 Quick Mode, best-effort `related_commits`, T11~T13 trigger index 반영
   - canonical workflow 변경에 따라 temp generic scaffold를 생성해 새 규칙이 scaffold 결과에 들어가는지 확인

### 실행한 검증

```bash
rg -n "Quick Mode|related_commits|best-effort|T11|T12|T13|Tool Surface Cascade Matrix|State Update Examples|execution mode|실행 모드" docs/decisions/DR-013-work-file-spec.md docs/harness-protocol/03-work-items-and-naming.md docs/harness-protocol/05-triggers-and-cascade.md docs/HARNESS-QUICK-REFERENCE.md docs/AGENT-WORKFLOW.md docs/WORKFLOW-MANUAL.md .claude/commands/work.md .cursor/rules prompts
rg -n "모든 작업 항목은 `docs/works|관련 커밋 short hash \\(실행 중 채워감\\)|T1~T9|P2-006-testcontainers|Active/Done 테이블" docs/decisions/DR-013-work-file-spec.md docs/harness-protocol docs/HARNESS-QUICK-REFERENCE.md docs/AGENT-WORKFLOW.md docs/WORKFLOW-MANUAL.md .claude .cursor prompts scripts/create-harness.sh
git diff --check
bash -n scripts/create-harness.sh
./scripts/create-harness.sh --profile generic sim-generic-d /private/tmp/harness-sim-generic-20260518-D
rg -n "Quick Mode|T11|T12|T13|Tool Surface Cascade Matrix|State Update Examples|best-effort|execution mode|실행 모드" /private/tmp/harness-sim-generic-20260518-D/docs /private/tmp/harness-sim-generic-20260518-D/.claude /private/tmp/harness-sim-generic-20260518-D/.cursor /private/tmp/harness-sim-generic-20260518-D/prompts
rg -n "모든 작업 항목은 `docs/works|T1~T9|관련 커밋 short hash \\(실행 중 채워감\\)|P2-006-testcontainers|Active/Done 테이블|Spring Boot 3\\.5|Java 21\\+" /private/tmp/harness-sim-generic-20260518-D/docs /private/tmp/harness-sim-generic-20260518-D/.claude /private/tmp/harness-sim-generic-20260518-D/.cursor /private/tmp/harness-sim-generic-20260518-D/prompts
python3 -m json.tool .claude/settings.json
python3 -m json.tool /private/tmp/harness-sim-generic-20260518-D/.claude/settings.json
```

### 검증 결과

- Quick Mode, T11~T13, Tool Surface Cascade Matrix, State Update Examples, best-effort `related_commits` 문구가 canonical docs와 tool surfaces에 반영됐다.
- stale phrase 검색에서 구형 "모든 작업 항목은 Work 파일", "실행 중 채워감", "T1~T9", `P2-006-testcontainers`, `Active/Done 테이블` 표현은 live/scaffold 표면에서 제거됐다.
- generic scaffold에도 Quick Mode, T11~T13, State Update Examples, best-effort commit reference 정책이 포함됐다.
- generic scaffold에는 Java/Spring Boot identity가 다시 섞이지 않았다.
- `git diff --check`, `bash -n scripts/create-harness.sh`, 현재 repo와 temp scaffold `.claude/settings.json` JSON 파싱이 통과했다.

### 커밋 참조

- Commit `0eef8f8` (`docs: work 파일 기반 하네스 흐름 정렬`)
  - HRF-002 review 결과와 후속 제안 반영을 포함하는 mixed docs/workflow commit이다.
  - 주요 범위: Work 파일 체계, State Update Gate, Done/Archive 절차, Quick Mode, trigger/cascade 확장, scaffold/profile 정렬, Claude/Codex/Cursor tool surface 동기화.
  - 이 commit id는 작업 추적용 best-effort reference이며, Work 단위 무결성 경계가 아니라 여러 workflow follow-up을 함께 묶은 closeout commit으로 본다.

---

## 2026-05-18 `/health --cascade` 개선 반영

문서 정합성/일관성/플로우 검토 요청 패턴을 `/health` 명령에 반영했다.

### 반영 내용

- `.claude/commands/health.md`
  - `--cascade` 모드를 추가해 문서/워크플로우 변경 영향 감사를 별도 모드로 정의했다.
  - canonical → tool-specific → user-facing → scaffold → historical layer 순서로 읽기/판단하도록 Phase 6을 추가했다.
  - Area G `Cascade/Trigger Completeness`를 추가해 필요한 cascade, 누락 mirror, 과잉 반복, stale contradiction, loop risk를 분류하도록 했다.
  - 변경 파일 기반 Simulation Pack을 추가했다.
- `docs/WORKFLOW-MANUAL.md`
  - `/health --cascade`, `/health --full --cascade` 사용 예시와 권장 시점을 추가했다.
- `docs/HARNESS-QUICK-REFERENCE.md`
  - 문서/워크플로우 변경 후 연쇄 영향이 불명확하면 `/health --cascade`를 사용하도록 요약했다.

### 검증

- `rg`로 현재 repo와 temp generic scaffold 모두에서 `--cascade`, Area G, Cascade Findings, Simulation Pack 문구 반영을 확인했다.
- `git diff --check` 통과.
- `./scripts/create-harness.sh --dry-run --profile generic ...` 통과.
- temp generic scaffold 생성 후 `.claude/commands/health.md`, `docs/WORKFLOW-MANUAL.md`, `docs/HARNESS-QUICK-REFERENCE.md`에 `/health --cascade` 개선 내용이 포함됨을 확인했다.

---

## 2026-05-18 HRN-019 `/close` 도입 후 cascade 감사 및 수정

### 변경 개요 (HRN-019)

HRN-019는 `/done`에서 Work Done 처리를 분리하여 `/close` 커맨드를 신규 도입했다.

| 명령 | 역할 |
|------|------|
| `/close` | Work Done 처리 전용 (status: Done, actual_end, README Active→Done, STATUS pointer 제거 제안, 선택적 archive). 세션 계속 |
| `/done` | 세션 요약만. Work Done 처리 없음. pause 시 Active Work Discovery 미기록 확인 포함 |

### HRN-019 1차 수정 대상 (이전 섹션)

- `.claude/commands/close.md` 신규 생성
- `.claude/commands/done.md` items 11-12 제거, pause Discovery 체크 추가
- `AGENTS.md`, `.cursor/rules/workflow.mdc`, `docs/HARNESS-QUICK-REFERENCE.md`, `docs/WORKFLOW-MANUAL.md`, `prompts/`, `scripts/create-harness.sh`, `.claude/settings.json`

### Cascade 감사 결과 (P0×1, P1×11, P2×5)

1차 수정 후 workflow 전반의 cascade 영향을 시뮬레이션 기반으로 감사했다.

**발견한 주요 문제:**

| 우선순위 | 파일 | 문제 |
|---------|------|------|
| P0 | `docs/AGENT-WORKFLOW.md` | Work File Lifecycle에 "`/done`은 Done 처리와 STATUS pointer 제거 제안을 수행한다" 잔류 — 모든 도구 세션 시작 시 로드되므로 AI 동작 불일치 유발 |
| P1 | `.claude/commands/done.md` item 11 | `/close` 실행 후 다시 `/done`을 실행해야 한다는 안내 없음 — 세션 종료 흐름 미완성 |
| P1 | `docs/WORKFLOW-MANUAL.md` | commands 개수 10개 고정, `close.md` Appendix 체크리스트 누락, Mermaid 다이어그램 `/close` 노드 없음, Usage 예시 구형, Appendix B hook 메시지 구형 |
| P1 | `prompts/claude-session-start.md` section 7 | fallback prompt에 Discovery 체크 + `/close` 안내 없음 |
| P1 | `prompts/codex-session-start.md` "AGENTS.md 없음" | Work Done 단계 없음 |
| P1 | `.claude/commands/health.md` | simulation pack에 `/close` 시나리오 없음 |
| P1 | `.claude/commands/start.md` | Done 상태 Work가 `/close`로 완료된 것임을 설명 없음 |
| P2 | `docs/harness-protocol/01-session-state-machine.md` | CHECKPOINT/END 상태 정의에 `/close`/`/done` 역할 구분 없음 |
| P2 | `.claude/commands/resume.md` | `/close` 발견가능성 낮음 |

### 2차 수정 내역

**Canonical:**
- `docs/AGENT-WORKFLOW.md`: Work File Lifecycle에서 `/close`가 Work Done 처리 담당, `/done`은 세션 요약만임을 명시

**Tool-specific:**
- `.claude/commands/done.md` item 11: `/close` 후 다시 `/done` 재실행 안내 추가
- `.claude/commands/health.md`: simulation pack에 `/close`, `/close`→`/done` 시나리오 추가
- `.claude/commands/start.md`: Done 상태 Work의 `/close` 기원 맥락 설명 추가
- `.claude/commands/resume.md`: `/close` 발견가능성 언급 추가
- `docs/harness-protocol/01-session-state-machine.md`: CHECKPOINT/END 상태 정의 보완

**User-facing:**
- `docs/WORKFLOW-MANUAL.md`: HARNESS-QUICK-REFERENCE 설명에 `/close` 추가, commands 11개로 갱신, Full Session Lifecycle Mermaid에 `/close` 노드 추가, Usage 예시 Work 완료/미완료 분기, Appendix B hook 예시 + 체크리스트 갱신
- `prompts/claude-session-start.md` section 7: item 10 (Discovery 체크 + `/close` 안내) 추가
- `prompts/codex-session-start.md` section 10 "AGENTS.md 없음": item 0 (Work Done 처리 단계) 추가

### 검증 내역

```bash
git diff --check                                  # PASS
bash -n scripts/create-harness.sh                 # PASS
python3 -m json.tool .claude/settings.json        # PASS
rg -n "/close" docs/AGENT-WORKFLOW.md .claude/commands/done.md .claude/commands/start.md \
  .claude/commands/resume.md .claude/commands/health.md \
  docs/harness-protocol/01-session-state-machine.md \
  docs/WORKFLOW-MANUAL.md prompts/claude-session-start.md prompts/codex-session-start.md
```

모든 수정 대상 파일에 `/close` 반영 확인 완료.

### 남은 리스크

1. `scripts/create-harness.sh`는 `.claude/commands/*.md` glob으로 복사하므로 `close.md` 자동 포함 확인 — 정상.
2. Mermaid 렌더러 로컬 미설치로 다이어그램 실제 렌더링은 미확인. 노드 추가 문법은 기존 패턴과 동일.
3. `cursor-session-start.md`는 `/close` 관련 내용 없음 — Cursor는 `.cursor/rules/workflow.mdc`가 실행 표면이므로 이미 반영됨. fallback prompt 불필요.
