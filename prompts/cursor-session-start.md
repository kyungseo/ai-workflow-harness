# Cursor 세션 시작 프롬프트

이 문서는 Cursor에서 새 세션을 시작할 때 복사해서 쓰는 bootstrap prompt다.
Cursor는 `.cursor/rules/*.mdc`를 함께 적용하되, 전역 행동 원칙은 `docs/BEHAVIOR-PRINCIPLES.md`, 프로젝트 상태와 하네스 기준은 `CLAUDE.md`, `docs/AGENT-WORKFLOW.md`, `docs/STATUS.md`, `docs/HARNESS-PROTOCOL.md`를 따른다.

컨텍스트 참조 우선순위:

1. `CLAUDE.md` — 공통 작업 계약
2. `docs/BEHAVIOR-PRINCIPLES.md` — 전역 행동 원칙
3. `docs/AGENT-WORKFLOW.md` — 공통 운영 규칙
4. `docs/STATUS.md` — 현재 작업 상태
5. `docs/BOOTSTRAP.md` — `docs/STATUS.md` Next Actions가 scaffold bootstrap/onboarding을 명시할 때
6. `.cursor/rules/*.mdc` — Cursor 실행 규칙
7. `docs/HARNESS-PROTOCOL.md` — workflow/harness 상세 기준이 필요할 때
8. `docs/PLAN-SUMMARY.md` — 아키텍처 요약이 필요할 때

작업 선택 기준:

- Product track 또는 Phase 준비 작업: `docs/backlog/PHASE{n}.md`
- Harness, command/rule, workflow hardening: `docs/backlog/HARNESS.md`
- 큰 작업 Work 파일: `docs/works/{category}/{ID}-{topic}.md` (spec: DR-013)

`docs/STATUS.md` Next Actions가 scaffold bootstrap/onboarding을 명시하면 제품 목표와 Phase 범위를 먼저 정리한다.
`docs/PLAN-SUMMARY.md` Implementation Baseline이 비어 있으면 feature 후보 대신 Project Initialization을 첫 candidate로 제안하고,
baseline이 완료된 뒤에 그 결과를 `docs/backlog/PHASE1.md`의 Product track 후보로 등록한다.
AI workflow 자체의 개선 항목과 example pack 정비 항목은 `docs/backlog/HARNESS.md`로 분리한다.

---

## 1. 기본 세션 시작

```text
CLAUDE.md, docs/BEHAVIOR-PRINCIPLES.md, docs/AGENT-WORKFLOW.md를 읽어줘.
그다음 docs/STATUS.md의 Current State, Active Work, Blockers And Open Questions, Next Actions만 확인해줘.
.cursor/rules/*.mdc도 적용해줘.

아래 형식으로 보고해줘.

1. 결론
2. 현재 진행 상태
3. 다음 작업 후보
4. 필요한 추가 문서
5. 리스크와 확인 질문

아직 파일 수정은 하지 말고, 먼저 진행 계획을 제안해줘.
```

---

## 2. Active Work 진행

```text
CLAUDE.md, docs/BEHAVIOR-PRINCIPLES.md, docs/AGENT-WORKFLOW.md, docs/STATUS.md, .cursor/rules/*.mdc를 확인해줘.
Active Work의 [작업 ID 또는 작업명]을 진행하려고 해.

먼저 아래 항목을 보고해줘.

- Scope
- 확인해야 할 파일
- 변경 예정 파일
- Done Criteria
- Verification
- 리스크
- 되돌리기 비용
- state-change proposal/DR/Work 파일/문서 cascade 필요 여부

내가 승인하기 전에는 구현하지 마.
```

---

## 3. Backlog Item 선정

```text
CLAUDE.md, docs/BEHAVIOR-PRINCIPLES.md, docs/AGENT-WORKFLOW.md, docs/STATUS.md를 읽어줘.
작업 성격에 따라 product backlog 또는 harness backlog를 선택해 다음 후보를 검토해줘.

- Product track 또는 Phase 준비 작업: docs/backlog/PHASE{n}.md
- harness, command/rule, workflow hardening: docs/backlog/HARNESS.md

docs/STATUS.md Next Actions가 scaffold bootstrap/onboarding을 명시하면 먼저 그 흐름을 따라줘.
Product backlog가 아직 비어 있으면 제품 목표, 사용자, Phase 1 범위를 기준으로 초기 작업 후보를 먼저 제안해줘 (backlog 후보는 Work ID 없이 제목/slug로 관리하고, Work ID는 /work 착수 승인 시 확정됨).
단, `docs/PLAN-SUMMARY.md` Implementation Baseline이 비어 있으면 feature 후보 대신 Project Initialization을 첫 candidate로 제안해줘.
example pack이나 role/rule/prompt 정비가 필요하면 Harness 후보로 분리해줘.

각 후보에 대해 아래 항목을 비교해줘.

- ID
- 우선순위
- 선행 조건
- 구현 난이도
- 운영 리스크
- 검증 방법

가장 먼저 진행할 작업 1개를 추천하고,
docs/STATUS.md에 Active Work로 올릴 때 필요한 내용을 제안해줘.
STATUS.md는 바로 수정하지 말고, 변경이 필요하면 Approval Matrix state rules에 맞게 먼저 보고해줘.
```

---

## 4. 구현 시작

```text
이전에 합의한 계획에 따라 [작업 ID 또는 작업명] 구현을 시작해줘.

원칙:

- 변경은 최소 범위로 제한
- 무관한 리팩토링 금지
- 새 의존성 추가 전 근거 보고
- secrets, .env, 토큰, 비밀번호 노출 금지
- 파괴적/권한 상승/인프라 변경 명령은 실행 전 승인 요청

구현 후에는 검증을 실행하고,
docs/STATUS.md 업데이트와 DR/Work 파일/문서 cascade가 필요한지 제안해줘.
STATUS.md 변경이 필요하면 즉시 수정하지 말고 Approval Matrix state rules에 맞게 먼저 보고해줘.
Product track surface의 L1 Quick Mode에 해당하면 Work 파일 없이 final summary + validation + commit history로 닫을 수 있어.
entrypoint/workflow/protocol/command/rule/prompt/scaffold/status 파일을 건드리면 harness/workflow surface 변경으로 보고 기본 L2로 다뤄줘.
```

---

## 5. 디버깅 시작

```text
CLAUDE.md, docs/BEHAVIOR-PRINCIPLES.md, docs/AGENT-WORKFLOW.md, docs/STATUS.md, .cursor/rules/debugging.mdc를 확인해줘.

문제 상황:

- 증상: [에러 메시지 또는 동작]
- 재현 방법: [명령/화면/API]
- 기대 결과: [정상 동작]
- 실제 결과: [현재 동작]
- 금지 범위: [건드리면 안 되는 것]

먼저 재현 조건과 관련 파일을 확인하고,
추측 없이 실제 코드/로그/테스트 근거로 원인 후보를 좁혀줘.
수정 전에는 계획과 검증 방법을 보고해줘.
```

---

## 6. 발표/보고 자료 생성

```text
CLAUDE.md, docs/BEHAVIOR-PRINCIPLES.md, docs/AGENT-WORKFLOW.md, docs/STATUS.md, .cursor/rules/workflow.mdc, .cursor/rules/output-format.mdc를 확인해줘.

고품질 발표/보고 자료를 만들고 싶어.

- 목적: [발표/보고/의사결정/리뷰/교육]
- Audience: [경영진/기술 리더/개발팀/외부 리뷰어]
- Format: [pptx/slide outline/markdown/docx/pdf-ready]
- Source: [STATUS/backlog/DR/diff/retrospective/메모]
- Length: [slide/page 수 또는 발표 시간]
- Tone: [executive/technical/reviewer-facing/tutorial]

먼저 brief, source loading plan, outline, 사용할 수 있는 도구와 fallback, output path, verification 기준을 제안해줘.
승인 전에는 최종 파일을 만들지 마.
STATUS.md 변경이 필요하면 변경 섹션, 변경 이유, 변경 후 상태, 되돌리기 비용을 먼저 보고하고 승인 대기해줘.
```

---

## 7. 문서 전용 작업

발표자료, 보고서, review package, decision brief, 외부 공유용 문서 산출물처럼 품질 높은 문서 생성 문맥이면 이 섹션 대신 `/doc` 절차를 사용한다.
기존 문서 일부 편집, 오탈자 수정, README 갱신처럼 source 문서 자체를 고치는 작업이면 아래 절차를 사용한다.

```text
CLAUDE.md, docs/BEHAVIOR-PRINCIPLES.md, docs/AGENT-WORKFLOW.md, docs/STATUS.md, .cursor/rules/output-format.mdc를 확인해줘.

문서 작업:

- 대상 문서: [파일]
- 목적: [무엇을 개선하려는지]
- 유지할 내용: [보존해야 할 내용]
- 변경할 내용: [바꿔야 할 내용]

긴 기록은 docs/STATUS.md에 넣지 말고,
완료된 상세 이력은 docs/archive/로 분리하는 원칙을 지켜줘.
수정 전 변경 계획을 먼저 제안해줘.
STATUS.md 변경이 필요하면 변경 섹션, 변경 이유, 변경 후 상태, 되돌리기 비용을 먼저 보고하고 승인 대기해줘.
```

---

## 8. 세션 종료 요약

```text
이번 Cursor 세션을 다음 형식으로 요약해줘.

1. 완료한 작업
2. 변경된 파일
3. 실행한 검증
4. 남은 리스크
5. docs/STATUS.md 업데이트 필요 여부
   - 필요하면 즉시 수정하지 말고 Approval Matrix state rules에 맞게 제안해.
   - phase/focus/recent decision 변경은 STATUS Update Proposal로 변경 섹션, 변경 이유, 변경 후 상태, 되돌리기 비용을 제시해.
   - 사용자가 명시적으로 승인한 뒤에만 STATUS.md를 수정해.
6. 의사결정 기록 필요 여부
   - 이번 작업에서 DR-worthy 결정이 확정되었으면 목록화하고 기록 여부를 물어봐.
   - 계획·검토 중 발견된 미결 의사결정이 있으면 STATUS.md OQ 추가 및 DR Draft 생성을 제안해.
7. 상태 머신 종료 상태
   - VALIDATE 결과
   - CHECKPOINT, END, 또는 FAIL/RECOVER 필요 여부
8. Commit 상태
   - commit 수행 여부
   - commit하지 않았다면 이유와 남은 risk
9. 다음 세션에서 이어갈 프롬프트
```
