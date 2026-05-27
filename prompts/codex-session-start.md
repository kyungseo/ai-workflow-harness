# Codex Session Prompt

이 문서는 Codex에서 새 세션을 시작할 때 복사해서 쓰는 bootstrap prompt다.
repo root의 `AGENTS.md`가 Codex 기본 진입점이다.

각 섹션은 두 케이스로 제공된다.

- **AGENTS.md 있음** — 짧은 트리거 한 줄. `AGENTS.md`가 이미 상세 절차를 담고 있으므로 참조만 하면 된다.
- **AGENTS.md 없음** — 전체 fallback 프롬프트. 절차를 모두 포함한다.

컨텍스트 참조 우선순위:

1. `AGENTS.md` — Codex 진입점
2. `docs/BEHAVIOR-PRINCIPLES.md` — 전역 행동 원칙
3. `docs/AGENT-WORKFLOW.md` — 공통 운영 규칙
4. `docs/STATUS.md` — 현재 작업 상태
5. `docs/BOOTSTRAP.md` — `docs/STATUS.md` Next Actions가 scaffold bootstrap/onboarding을 명시할 때
6. `docs/HARNESS-PROTOCOL.md` — workflow/harness 상세 기준이 필요할 때
7. `docs/HARNESS-QUICK-REFERENCE.md` — 빠른 실행 규칙 확인
8. `docs/PLAN-SUMMARY.md` — project / harness architecture 요약이 필요할 때

작업 선택 기준:

- Product track 또는 Phase 준비 작업: `docs/backlog/PHASE{n}.md`
- Harness, command/rule, workflow hardening: `docs/backlog/HARNESS.md`
- 큰 작업 Work 파일: `docs/works/{category}/{ID}-{topic}.md` (spec: DR-013)

`docs/STATUS.md` Next Actions가 scaffold bootstrap/onboarding을 명시하면 제품 목표와 Phase 범위를 먼저 정리한다.
`docs/PLAN-SUMMARY.md` Implementation Baseline이 비어 있으면 feature 후보 대신 Project Initialization을 첫 후보로 제안하고,
baseline이 완료된 뒤에 그 결과를 `docs/backlog/PHASE1.md`의 Product track 후보로 등록한다.
AI workflow 자체의 개선 항목과 example pack 정비 항목은 `docs/backlog/HARNESS.md`로 분리한다.

---

## 1. Basic Session Start

**AGENTS.md 있음:**

```text
AGENTS.md Codex Skill Routing에 따라 /start에 대응하는 workflow skill을 로드하고 절차를 수행해줘.
```

**AGENTS.md 없음:**

```text
AGENTS.md, docs/BEHAVIOR-PRINCIPLES.md, docs/AGENT-WORKFLOW.md를 읽어줘.
그다음 docs/STATUS.md의 Current State, Active Work, Blockers And Open Questions, Next Actions만 확인해줘.

Codex에서는 .claude/commands를 직접 실행하지 말고, 동일한 절차를 수동으로 수행해줘.

아래 형식으로 보고해줘.

1. 결론
2. 현재 진행 상태
3. 다음 작업 후보
4. 필요한 추가 문서
5. 리스크와 확인 질문

아직 파일 수정은 하지 말고, 먼저 진행 계획을 제안해줘.
```

---

## 2. Work Selection

**AGENTS.md 있음:**

```text
AGENTS.md Codex Skill Routing에 따라 /pick에 대응하는 workflow skill을 로드하고 절차를 수행해줘.
```

**AGENTS.md 없음:**

```text
AGENTS.md, docs/BEHAVIOR-PRINCIPLES.md, docs/AGENT-WORKFLOW.md, docs/STATUS.md를 확인해줘.
작업 성격에 따라 product backlog 또는 harness backlog를 선택해 다음 후보를 검토해줘.

- Product track 또는 Phase 준비 작업: docs/backlog/PHASE{n}.md
- harness, command/rule, workflow hardening: docs/backlog/HARNESS.md

docs/STATUS.md Next Actions가 scaffold bootstrap/onboarding을 명시하면 먼저 그 흐름을 따라줘.
만약 product backlog가 아직 비어 있으면 먼저 제품 목표, 사용자, Phase 1 범위를 기준으로 초기 작업 후보를 만들 수 있는지 검토해줘 (backlog 후보는 Work ID 없이 제목/slug로 관리하고, Work ID는 /work 착수 승인 시 확정됨).
단, `docs/PLAN-SUMMARY.md` Implementation Baseline이 비어 있으면 feature 후보 대신 Project Initialization을 첫 후보로 제안해줘.
example pack이나 role/rule/prompt 정비가 필요하면 Harness 후보로 분리해줘.

각 후보에 대해 아래 항목을 비교해줘.

- ID
- 우선순위
- 선행 조건
- 구현 난이도
- 운영 리스크
- 검증 방법
- 되돌리기 비용

가장 먼저 진행할 작업 1개를 추천하고,
docs/STATUS.md에 Active Work로 올릴 때 필요한 내용을 제안해줘.
STATUS.md는 바로 수정하지 말고, 변경이 필요하면 Approval Matrix state rules에 맞게 먼저 보고해줘.
```

---

## 3. Register New Work Item

**AGENTS.md 있음:**

```text
AGENTS.md Codex Skill Routing에 따라 /register에 대응하는 workflow skill을 로드하고 절차를 수행해줘.
```

**AGENTS.md 없음:**

```text
AGENTS.md, docs/BEHAVIOR-PRINCIPLES.md, docs/AGENT-WORKFLOW.md, docs/STATUS.md를 확인해줘.
새 작업 항목을 등록하려고 해.

항목 설명: [한 줄]
긴급도: 지금 바로 착수 / 곧 할 것 / 나중에 검토
성격: product(기능·인프라) / harness(workflow·command·rule·문서 구조)

긴급도와 성격에 따라 아래 위치 중 적절한 곳에 등록해줘.

- 지금 바로 착수: docs/STATUS.md Active Work
- 곧 할 것: docs/STATUS.md Next Actions
- Product track 작업: docs/backlog/PHASE{n}.md
- Harness 작업: docs/backlog/HARNESS.md

backlog 후보는 Work ID를 선점하지 말고 제목/slug, Priority, Scope, Done Criteria, Verification을 포함해줘.
Work ID는 /work 착수 승인 후 Work 파일 생성 시 확정해줘.
STATUS.md 변경이 필요하면 Approval Matrix state rules에 맞게 먼저 보고하고 승인 대기해줘.
긴급 항목이면 등록 후 /work로 이어갈지 물어봐.
```

---

## 4. Specific Work Execution

**AGENTS.md 있음:**

```text
AGENTS.md Codex Skill Routing에 따라 /work에 대응하는 workflow skill을 로드하고 계획을 세워줘.
```

**AGENTS.md 없음:**

```text
AGENTS.md, docs/BEHAVIOR-PRINCIPLES.md, docs/AGENT-WORKFLOW.md, docs/STATUS.md를 확인해줘.
[Work ID 또는 제목/slug]를 진행하려고 해.

Work ID 또는 제목/slug에 따라 product backlog 또는 harness backlog를 선택해 해당 항목을 읽고 계획을 세워줘.

계획에는 반드시 아래 내용을 포함해줘.

1. Scope
2. 변경 예정 파일
3. Done Criteria
4. Verification
5. 리스크와 되돌리기 비용
6. 실행 모드: Quick Mode / Standard Work / Full Work
7. state-change proposal 필요 여부
8. DR/Work 파일/문서 cascade 필요 여부

Product track surface의 L1 Quick Mode에 해당하면 Work 파일 없이 final summary + validation + commit history로 닫을 수 있어.
entrypoint/workflow/protocol/command/rule/prompt/scaffold/status 파일을 건드리면 harness/workflow surface 변경으로 보고 기본 L2로 다뤄줘.

계획을 보고한 뒤 "진행할까요?"로 끝내고 승인 대기해줘.
STATUS.md 변경은 사용자가 명시적으로 승인한 뒤에만 수행해줘.
```

---

## 5. Resume Existing Work

**AGENTS.md 있음:**

```text
AGENTS.md Codex Skill Routing에 따라 /resume에 대응하는 workflow skill을 로드하고 작업을 재개해줘.
```

**AGENTS.md 없음:**

```text
AGENTS.md, docs/BEHAVIOR-PRINCIPLES.md, docs/AGENT-WORKFLOW.md, docs/STATUS.md를 확인해줘.
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

## 6. Implementation Start

**AGENTS.md 있음:**

```text
합의된 계획대로 [ID] 구현을 시작해줘. state-change proposal이 필요하면 먼저 보고해줘.
```

**AGENTS.md 없음:**

```text
이전에 합의한 계획에 따라 [Work ID 또는 작업명] 구현을 시작해줘.

원칙:

- 변경은 최소 범위로 제한
- 무관한 리팩토링 금지
- 승인된 scope 밖의 파일, 문서, 설정으로 변경이 확장되면 추가 scope, 이유, 검증 방법을 먼저 보고하고 승인 대기
- 새 의존성 추가 전 근거 보고
- secrets, .env, 토큰, 비밀번호 노출 금지
- 파괴적/권한 상승/인프라 변경 명령은 실행 전 승인 요청
- 사용자 변경을 되돌리지 말고, 충돌 시 보고
- commit 전에는 validation 결과, diff summary, 제안 commit message를 보고하고 승인 대기

구현 후에는 검증을 실행하고,
docs/STATUS.md 업데이트와 DR/Work 파일/문서 cascade가 필요한지 제안해줘.
STATUS.md 변경이 필요하면 즉시 수정하지 말고 Approval Matrix state rules에 맞게 먼저 보고해줘.
```

---

## 7. Debugging Or Refactoring Start

**AGENTS.md 있음:**

```text
[대상]의 [문제]를 최소 변경 원칙으로 [디버깅/리팩토링]해줘. 계획 먼저 보고하고 승인 대기해줘.
```

**AGENTS.md 없음:**

```text
AGENTS.md, docs/BEHAVIOR-PRINCIPLES.md, docs/AGENT-WORKFLOW.md, docs/STATUS.md를 확인해줘.

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

## 8. Presentation And Report Generation

**AGENTS.md 있음:**

```text
AGENTS.md Codex Skill Routing에 따라 /doc에 대응하는 workflow skill을 로드하고 발표/보고 자료를 준비해줘.

요청:
- 목적: [발표/보고/의사결정/리뷰/교육]
- Audience: [경영진/기술 리더/개발팀/외부 리뷰어]
- Format: [pptx/slide outline/markdown/docx/pdf-ready]
- Source: [STATUS/backlog/DR/diff/retrospective/메모]
- Length: [slide/page 수 또는 발표 시간]

먼저 brief와 outline을 제안하고, 승인 전에는 최종 파일을 만들지 마.
STATUS.md 변경이 필요하면 Approval Matrix state rules에 맞게 먼저 보고해줘.
```

**AGENTS.md 없음:**

```text
docs/BEHAVIOR-PRINCIPLES.md, docs/AGENT-WORKFLOW.md, docs/STATUS.md를 확인해줘.

고품질 발표/보고 자료를 만들고 싶어.

- 목적: [발표/보고/의사결정/리뷰/교육]
- Audience: [경영진/기술 리더/개발팀/외부 리뷰어]
- Format: [pptx/slide outline/markdown/docx/pdf-ready]
- Source: [STATUS/backlog/DR/diff/retrospective/메모]
- Length: [slide/page 수 또는 발표 시간]
- Tone: [executive/technical/reviewer-facing/tutorial]

먼저 아래를 제안해줘:
1. Brief
2. Source loading plan
3. Outline 또는 slide/page 구조
4. 사용할 수 있는 presentation/document 도구와 fallback
5. Output path (`docs/presentations/` 또는 `docs/reports/`)
6. Verification 기준

승인 전에는 최종 파일을 만들지 마.
STATUS.md 변경이 필요하면 Approval Matrix state rules에 맞게 먼저 보고해줘.
```

---

## 9. Documentation Only Work

발표자료, 보고서, review package, decision brief, 외부 공유용 문서 산출물처럼 품질 높은 문서 생성 문맥이면 이 섹션 대신 `/doc` 절차를 사용한다.
기존 문서 일부 편집, 오탈자 수정, README 갱신처럼 source 문서 자체를 고치는 작업이면 아래 절차를 사용한다.

**AGENTS.md 있음:**

```text
[파일] 문서 작업을 진행해줘. state-change proposal이 필요하면 먼저 보고해줘.
```

**AGENTS.md 없음:**

```text
AGENTS.md, docs/BEHAVIOR-PRINCIPLES.md, docs/AGENT-WORKFLOW.md, docs/STATUS.md를 확인해줘.

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

## 10. Session Closeout Summary

**AGENTS.md 있음:**

```text
Work가 완료됐다면 AGENTS.md Codex Skill Routing에 따라 /close에 대응하는 workflow skill을 로드하고 Work Done 처리를 먼저 수행해줘. 그다음 /done에 대응하는 workflow skill을 로드하고 세션을 마무리해줘.
```

**AGENTS.md 없음:**

```text
이번 Codex 세션을 다음 형식으로 요약해줘.

0. Work Done 처리 (Active Work가 완료된 경우)
   - Done Criteria 전부 충족 확인
   - Work 파일 frontmatter: status: Done, actual_end: 오늘 기입
   - docs/works/{category}/README.md: Active → Done (archive pending) 이동
   - docs/STATUS.md Active Work pointer 제거 제안 (승인 후 처리)
   - archive 여부 선택 (지금 또는 다음 세션으로 보류)
   - Work가 미완료라면 이 단계를 건너뛰고 아래 10번에서 Discovery를 확인해.
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
7. troubleshooting 기록 필요 여부
   - 이번 작업에서 비자명 이슈(환경 설정 문제, 재현 어려운 오류, 비직관적 원인)를 해결했으면 `docs/troubleshooting/`에 기록 여부를 물어봐.
   - 이미 관련 파일이 있으면 업데이트 필요 여부를 확인해.
8. 상태 머신 종료 상태
   - VALIDATE 결과
   - CHECKPOINT, END, 또는 FAIL/RECOVER 필요 여부
9. Commit 상태
   - commit 수행 여부
   - commit하지 않았다면 이유와 남은 risk
10. Active Work Discovery 확인 (Work가 미완료인 경우)
   - Active Work가 있으면 Discovery에 현재 진행 상황이 기록되어 있는지 확인해.
   - 미기록이면 기록할 내용을 제안하고 기록 여부를 물어봐.
11. 다음 세션에서 이어갈 프롬프트
```

---

## 11. Failure And Recovery

**AGENTS.md 있음:**

```text
docs/HARNESS-PROTOCOL.md의 Failure And Recovery 절차에 따라 FAIL 처리해줘.
```

**AGENTS.md 없음:**

```text
VALIDATE 실패, STATUS drift, scope drift, 정보 부족을 발견하면 FAIL로 전환해줘.

아래 항목을 보고해줘.

1. Failure type
2. Root cause
3. Affected files/state
4. Recovery options
5. Recommended path

그다음 사용자 결정을 받은 뒤 PLAN으로 돌아가줘.
상세 기준은 docs/HARNESS-PROTOCOL.md의 Failure And Recovery와 Validation Checklist를 따라줘.
```
