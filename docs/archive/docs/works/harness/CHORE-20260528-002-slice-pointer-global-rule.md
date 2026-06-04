---
id: CHORE-20260528-002
priority: P2
status: Archived
risk: Medium
scope: slice & pointer 판단 기준을 전역/도구 공통 룰(BEHAVIOR-PRINCIPLES.md, behavior-principles.mdc, AGENT-WORKFLOW.md, HARNESS-PROTOCOL.md §16, .claude/rules/docs-workflow.md, .cursor/rules/workflow.mdc) 6개 surface에 추가하여 core 문서 runbook 축적을 방지
appetite: 0.5d
planned_start: 2026-05-28
planned_end: 2026-05-28
actual_end: 2026-05-28
related_dr: []
related_commits: []
related_troubleshooting: []
---

# CHORE-20260528-002: Slice & Pointer 전역 룰 추가

## Plan

### 배경

CHORE-20260528-001에서 HARNESS-PROTOCOL.md §17 runbook을 `docs/HARNESS-PARALLEL-WORK-CONTROLS.md` slice 파일로 분리하고 조건부 pointer로 교체했다. 이 "slice & pointer" 패턴은 core 문서를 날씬하게 유지하는 핵심 구조 원칙이지만, 어떤 경우에 분리하고 어떤 경우에 inline으로 남길지 판단 기준이 명문화되어 있지 않다. 판단 기준이 없으면 향후 core 문서에 runbook이 다시 축적될 수 있다.

이번 Work는 slice & pointer 판단 기준을 전역 행동 원칙 및 도구 공통 룰에 명문화한다.

### 판단 기준 (추가할 Rule 내용)

**Slice 파일 분리 조건 (→ 별도 파일 생성 후 조건부 pointer로 교체):**
- 조건부로만 실행되는 상세 절차 또는 체크리스트가 core 문서에 직접 포함될 경우
- 해당 절차가 특정 상황(충돌 발생, 특정 workflow 진입)에서만 필요할 경우

**Inline 유지 기준:**
- 모든 세션에서 참조되는 3줄 이내 정책·판단 기준
- pointer 자체가 절차보다 길어지는 경우

**Pointer 형식 (core 문서에 남기는 1~3줄):**
```
Load `docs/{slice-file}.md` only when {condition}.
```

### 변경 대상 Surface

| # | 파일 | 변경 내용 | 언어 정책 |
|---|---|---|---|
| 1 | `docs/BEHAVIOR-PRINCIPLES.md` | §2 Simplicity First에 bullet 1줄 추가 | Korean primary |
| 1' | `.cursor/rules/behavior-principles.mdc` | §2에 대응 bullet 추가 (CP-2 mirror pair) | English Only |
| 2 | `docs/AGENT-WORKFLOW.md` | Context Routing 표 하단 note 또는 별도 paragraph 추가 | Korean primary |
| 3 | `docs/HARNESS-PROTOCOL.md §16` | Operating Principles에 bullet 1줄 추가 | Korean primary |
| 4 | `.claude/rules/docs-workflow.md` | MUST 섹션에 rule 추가 | English Only |
| 4' | `.cursor/rules/workflow.mdc` | Document Structure 섹션 신규 추가 (CP-5 mirror pair) | English Only |

CP-2에서 1번과 1'번을 같은 CP/commit에 반영한다 (BEHAVIOR-PRINCIPLES.md ↔ behavior-principles.mdc mirror pair).
CP-5에서 4번과 4'번을 같은 CP/commit에 반영한다 (docs-workflow.md ↔ workflow.mdc mirror pair).

### 접근 방법

각 surface에 판단 기준을 최소 표현으로 추가한다. 상세 예시·사례는 이미 HARNESS-PARALLEL-WORK-CONTROLS.md와 HARNESS-PROTOCOL.md §17 pointer에 존재하므로 중복 서술하지 않는다.

**Out of Scope:**
- `AGENTS.md`, `CLAUDE.md`: entry contract, behavioral rule surface 아님
- CI/hook enforcement: manual-first 원칙에 따라 이번 slice 제외

## Done Criteria

- [x] `docs/BEHAVIOR-PRINCIPLES.md` §2에 검토형 원칙 bullet이 추가됨 (전역 원칙, 약한 표현)
- [x] `.cursor/rules/behavior-principles.mdc` §2에 대응 bullet이 추가됨 (English Only mirror)
- [x] `docs/AGENT-WORKFLOW.md`에 slice & pointer 판단 기준이 추가됨
- [x] `docs/HARNESS-PROTOCOL.md §16` Operating Principles에 bullet이 추가됨
- [x] `.claude/rules/docs-workflow.md` MUST에 rule이 추가됨 (English Only)
- [x] `.cursor/rules/workflow.mdc`에 Document Structure 섹션이 추가됨 (English Only)
- [x] 6개 surface 판단 기준이 적용 강도에 맞게 일관됨 (전역 원칙: 검토형, workflow/protocol surface: 명확형)
- [x] cascade 영향 문서 점검 완료
- [x] STATUS Active pointer 및 Work index Active row 반영됨

## Verification

- 6개 surface에 판단 기준이 반영됐는지 확인
- 적용 강도 확인: `BEHAVIOR-PRINCIPLES.md`·`behavior-principles.mdc`는 검토형, 나머지 4개는 명확형
- `.claude/rules/docs-workflow.md`, `.cursor/rules/behavior-principles.mdc`, `.cursor/rules/workflow.mdc`가 English Only로 작성됐는지 확인
- `git diff --check` 통과

## Checkpoints

| CP | Description | Status |
|----|-------------|--------|
| 1  | Work 파일 생성, STATUS/index pointer 추가 | Done |
| 2  | `docs/BEHAVIOR-PRINCIPLES.md` §2 bullet 추가 + `.cursor/rules/behavior-principles.mdc` §2 대응 bullet 추가 (mirror pair) | Done |
| 3  | `docs/AGENT-WORKFLOW.md` 판단 기준 추가 | Done |
| 4  | `docs/HARNESS-PROTOCOL.md §16` bullet 추가 | Done |
| 5  | `.claude/rules/docs-workflow.md` MUST rule 추가 + `.cursor/rules/workflow.mdc` Document Structure 섹션 추가 (mirror pair) | Done |
| 6  | Validation + STATUS Finalization + Tracking Finalization | Done |

## Discovery

### CP-2~5 구현 결과

적용 강도를 surface별로 달리함 (전역 원칙은 검토형, workflow/protocol surface는 명확형).

- **BEHAVIOR-PRINCIPLES.md §2**: "긴 조건부 절차나 체크리스트를 core 문서에 추가하기 전, 특정 상황에서만 필요한 내용인지 먼저 판단하고, 그렇다면 별도 문서와 pointer 구조를 우선 검토한다." 추가 (검토형).
- **behavior-principles.mdc §2**: "Before adding a long conditional procedure or checklist to a core document, judge whether it is only needed in specific situations; if so, consider a separate document with a conditional pointer instead." 추가 (English Only mirror, consider형).
- **AGENT-WORKFLOW.md**: Context Routing 표 하단 1문장 추가 (명확형).
- **HARNESS-PROTOCOL.md §16**: Operating Principles 마지막 bullet으로 추가 (명확형).
- **docs-workflow.md**: MUST 마지막 항목으로 추가 (English Only, extract형).
- **workflow.mdc**: Branch Flow 앞에 `## Document Structure` 섹션 신규 추가 (English Only, extract형).

### CP-6 Validation

- `git diff --check` 통과 (whitespace error 없음).
- STATUS Finalization: STATUS Active Work에 CHORE-20260528-001/002 pointer 정상 유지. `/close` 전까지 변경 불필요.
- Tracking Finalization: Work index Active row 반영됨. scaffold script 변경 없음 → `bash -n scripts/create-harness.sh` Not Applicable.
