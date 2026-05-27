# Claude Code Session Start Prompt

이 문서는 Claude Code slash command를 사용할 수 없는 환경에서 복사해 쓰는 fallback prompt 모음이다.
Claude Code 안에서는 `.claude/commands/`의 `/start`, `/pick`, `/work`, `/close`, `/done`을 우선 사용한다.

핵심 기준:

- `CLAUDE.md`, `docs/BEHAVIOR-PRINCIPLES.md`, `docs/AGENT-WORKFLOW.md`를 먼저 따른다.
- 현재 상태는 `docs/STATUS.md`를 기준으로 해석한다.
- 상세 하네스 규칙은 필요한 경우 `docs/HARNESS-PROTOCOL.md`만 읽는다.
- Product track 또는 project 작업은 `docs/backlog/PHASE{n}.md`, harness 작업은 `docs/backlog/HARNESS.md`로 분기한다.
- Bootstrap/onboarding은 `docs/STATUS.md` Next Actions가 명시할 때만 후속으로 다룬다.
- AI workflow 자체의 개선 항목과 example pack 정비 항목은 Harness track backlog로 분리한다.
- 구현 전에는 plan, verification, risk, reversal cost를 보고하고 승인 대기한다.

---

## 1. Basic Session Start

```text
CLAUDE.md, docs/BEHAVIOR-PRINCIPLES.md, docs/AGENT-WORKFLOW.md를 읽어줘.
그다음 docs/STATUS.md의 Current State, Active Work, Blockers And Open Questions, Next Actions만 확인해줘.

아래 형식으로 현재 상태를 요약해줘.

1. 결론
2. 현재 Active Work
3. 다음 후보 작업
4. 추가로 필요한 문서
5. 리스크와 확인 질문

아직 구현은 시작하지 말고, 진행할 작업을 먼저 제안해줘.
```

---

## 2. Work Selection

```text
CLAUDE.md, docs/BEHAVIOR-PRINCIPLES.md, docs/AGENT-WORKFLOW.md, docs/STATUS.md를 확인해줘.
작업 성격에 따라 다음 backlog 중 하나를 선택해 검토해줘.

- Product track 또는 Phase 준비 작업: docs/backlog/PHASE{n}.md
- harness, command/rule, workflow hardening: docs/backlog/HARNESS.md

Product backlog가 아직 비어 있으면 제품 목표, 사용자, Phase 1 범위를 기준으로 초기 작업 후보를 먼저 제안해줘 (backlog 후보에는 Work ID를 선점하지 않고, Work ID는 /work 착수 승인 시 확정됨).
단, `docs/PLAN-SUMMARY.md` Implementation Baseline이 비어 있으면 feature 후보 대신 Project Initialization을 첫 후보로 제안해줘.
example pack이나 role/rule/prompt 정비가 필요하면 Harness 후보로 분리해줘.

후보 우선순위가 비슷하거나 harness/plan/idea 성격의 작업을 고르는 경우,
docs/retrospectives/ 목록 또는 rg 검색으로 최신/관련 회고 1개만 선택해 참고해줘.
회고는 backlog를 대체하지 않고 우선순위 판단 보조 맥락으로만 사용해줘.

각 후보에 대해 아래 항목을 비교해줘.

- ID
- 우선순위
- 선행 조건
- 기대 효과
- 리스크
- 되돌리기 비용
- 검증 방법

최종적으로 지금 착수할 작업 1개를 추천해줘.
구현은 내가 승인하기 전까지 시작하지 마.
docs/STATUS.md에 Active Work로 올려야 한다면 즉시 수정하지 말고 Approval Matrix state rules에 맞게 먼저 보고해줘.
```

---

## 3. Specific Work Execution

```text
CLAUDE.md, docs/BEHAVIOR-PRINCIPLES.md, docs/AGENT-WORKFLOW.md, docs/STATUS.md를 확인해줘.
[Work ID 또는 제목/slug]를 진행하려고 해.

Work ID 또는 제목/slug에 따라 product backlog 또는 harness backlog를 선택해 해당 항목을 읽고 계획을 세워줘.
legacy HRN-*/PRE-*/DOC-* 또는 계획·아이디어 성격이 강한 작업이면 docs/retrospectives/에서 최신/관련 회고 1개만 선택해 반복 리스크와 우선순위 근거를 확인해줘.

계획에는 반드시 아래 내용을 포함해줘.

1. Scope
2. 변경 예정 파일
3. Done Criteria
4. Verification
5. 리스크와 되돌리기 비용
6. 실행 모드: Quick Mode / Standard Work / Full Work
7. docs/STATUS.md 반영 필요 여부
8. DR/Work 파일/문서 cascade 필요 여부

Product track surface의 L1 Quick Mode에 해당하면 Work 파일 없이 final summary + validation + commit history로 닫을 수 있어.
entrypoint/workflow/protocol/command/rule/prompt/scaffold/status 파일을 건드리면 harness/workflow surface 변경으로 보고 기본 L2로 다뤄줘.

계획을 보고한 뒤 "진행할까요?"로 끝내고 승인 대기해줘.
STATUS.md 변경은 바로 수행하지 말고 Approval Matrix state rules에 맞게 먼저 보고해줘.
```

---

## 4. Resume Existing Work

```text
CLAUDE.md, docs/BEHAVIOR-PRINCIPLES.md, docs/AGENT-WORKFLOW.md, docs/STATUS.md를 읽어줘.
Active Work 중 [Work ID 또는 작업명]을 이어서 진행하려고 해.

현재 내가 알고 있는 상태는 다음과 같아.

- 완료된 것: [내용]
- 남은 것: [내용]
- 막힌 점: [내용]

먼저 실제 파일 상태와 docs/STATUS.md가 일치하는지 확인하고,
불일치가 있으면 바로 수정하지 말고 보고해줘.
대상 작업이 Done이면 재개하지 말고 후속 보정 작업을 신규 작업으로 분리할지 제안해줘.
STATUS.md 변경이 필요하면 Approval Matrix state rules에 맞게 먼저 보고하고 승인 대기해줘.
그다음 남은 작업 계획과 검증 방법을 제안해줘.
```

---

## 5. New Project Initialization

```text
이 저장소의 Claude 운영 구조를 참고해서 새 프로젝트용 AI 작업 문서 구조를 설계해줘.

새 프로젝트 정보:

- 목표: [한 문장]
- 기술 스택: [언어, 프레임워크, DB, 배포 환경]
- 제약 조건: [성능, 보안, 호환성, 일정 등]
- 우선순위: [가장 중요한 것]
- 초기 범위: [Phase 1에서 만들 것]

다음 파일 구조를 기준으로 초안을 제안해줘.

- CLAUDE.md (루트, 영어)
- docs/AGENT-WORKFLOW.md (한국어, 공통 운영 규칙)
- docs/STATUS.md (Current State, Active Work, OQ, Next Actions)
- docs/HARNESS-PROTOCOL.md (상태 머신, 문서 지도, trigger/cascade 상세 protocol)
- docs/HARNESS-QUICK-REFERENCE.md (세션 실행 규칙 요약)
- docs/PLAN-SUMMARY.md (프로젝트 요약, 핵심 구조, 검증 기본값)
- docs/PLAN.md (전체 기술 근거, 필요 시만 로드)
- docs/backlog/PHASE1.md (제품 목표에서 도출한 Product track 후보 작업)
- docs/backlog/HARNESS.md (harness, command/rule, automation 후보 작업)
- docs/decisions/ (DECISION-TEMPLATE.md 포함)
- docs/archive/ (빈 폴더)
- docs/WORKFLOW-MANUAL.md (선택, 사용자 매뉴얼)
- .claude/settings.json (defaultMode=plan, 금지 명령 목록, 필요 시 hook)
- .claude/rules/ (docs-workflow, git-workflow, infra, [언어]-[프레임워크], testing)
- .claude/commands/ (start, pick, work, resume, debug, close, done, record-decision, health)
- prompts/ (세션 fallback + 재사용 task prompt)

구현이나 파일 생성은 내가 승인한 뒤 진행해줘.
```

---

## 6. Refactoring Or Debugging Start

```text
CLAUDE.md, docs/BEHAVIOR-PRINCIPLES.md, docs/AGENT-WORKFLOW.md, docs/STATUS.md를 확인해줘.

작업 상황:

- 대상: [파일/모듈/기능]
- 문제: [현재 증상 또는 개선 필요성]
- 목표: [기대하는 상태]
- 금지 범위: [건드리면 안 되는 파일/동작]

먼저 관련 코드와 테스트를 읽고,
추측이 아니라 실제 코드/로그/테스트 근거로 원인 또는 개선 지점을 좁혀줘.

그다음 최소 변경 계획, 검증 방법, 리스크, 되돌리기 비용을 보고해줘.
승인 전에는 수정하지 마.
```

---

## 7. Session Closeout Summary

```text
이번 세션에서 진행한 내용을 다음 형식으로 요약해줘.

1. 완료한 작업
2. 변경된 파일
3. 실행한 검증
4. 남은 리스크
5. 다음 세션에서 먼저 볼 파일
6. docs/STATUS.md 업데이트 필요 여부
   - 필요하면 즉시 수정하지 말고 Approval Matrix state rules에 맞게 제안해.
   - phase/focus/recent decision 변경은 STATUS Update Proposal로 변경 섹션, 변경 이유, 변경 후 상태, 되돌리기 비용을 제시해.
   - 사용자가 명시적으로 승인한 뒤에만 STATUS.md를 수정해.
7. 의사결정 기록 필요 여부
   - 이번 작업에서 DR-worthy 결정이 확정되었으면 목록화하고 기록 여부를 물어봐.
   - 계획·검토 중 발견된 미결 의사결정이 있으면 STATUS.md OQ 추가 및 DR Draft 생성을 제안해.
8. Commit 상태
   - commit 수행 여부
   - commit하지 않았다면 이유와 남은 risk
9. 상태 머신 종료 상태
   - VALIDATE 결과
   - CHECKPOINT, END, 또는 FAIL/RECOVER 필요 여부
10. Active Work Discovery 확인 (Work가 미완료인 경우)
   - Active Work가 있으면 Discovery에 현재 진행 상황이 기록되어 있는지 확인해.
   - 미기록이면 기록할 내용을 제안하고 기록 여부를 물어봐.
   - Work를 완료하고 싶다면 이 fallback prompt를 닫고 `/close`를 먼저 실행한 뒤 다시 이 프롬프트를 실행해.

다음 세션의 시작 프롬프트로 바로 사용할 수 있는 짧은 문장도 마지막에 작성해줘.
```
