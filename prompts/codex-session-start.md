# Codex 세션 프롬프트

이 문서는 Codex에서 새 세션을 시작할 때 복사해서 쓰는 bootstrap prompt다.
repo root의 `AGENTS.md`가 Codex 기본 진입점이다.

각 섹션은 두 케이스로 제공된다.

- **AGENTS.md 있음** — 짧은 트리거 한 줄. `AGENTS.md`가 이미 상세 절차를 담고 있으므로 참조만 하면 된다.
- **AGENTS.md 없음** — 전체 fallback 프롬프트. 절차를 모두 포함한다.

컨텍스트 참조 우선순위:

1. `AGENTS.md` — Codex 진입점
2. `docs/AGENT-WORKFLOW.md` — 공통 운영 규칙
3. `docs/STATUS.md` — 현재 작업 상태
4. `docs/HARNESS-PROTOCOL.md` — workflow/harness 상세 기준이 필요할 때
5. `docs/HARNESS-QUICK-REFERENCE.md` — 빠른 실행 규칙 확인
6. `docs/PLAN-SUMMARY.md` — product 아키텍처 요약이 필요할 때

작업 선택 기준:

- Product 또는 Phase 준비 작업: `docs/backlog/PHASE{n}.md`
- Harness, command/rule, workflow hardening: `docs/backlog/HARNESS.md`
- 큰 작업 Work 파일: `docs/works/{category}/{ID}-{topic}.md` (spec: DR-013)

---

## 1. 기본 세션 시작

**AGENTS.md 있음:**

```text
AGENTS.md Codex Command Mapping의 /start 절차에 따라 세션을 시작하고 현재 상태를 요약해줘.
```

**AGENTS.md 없음:**

```text
AGENTS.md와 docs/AGENT-WORKFLOW.md를 읽어줘.
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

## 2. 작업 선택

**AGENTS.md 있음:**

```text
AGENTS.md Codex Command Mapping의 /pick 절차에 따라 다음 작업을 선택해줘.
```

**AGENTS.md 없음:**

```text
AGENTS.md, docs/AGENT-WORKFLOW.md, docs/STATUS.md를 확인해줘.
작업 성격에 따라 product backlog 또는 harness backlog를 선택해 다음 후보를 검토해줘.

- product 또는 Phase 준비 작업: docs/backlog/PHASE{n}.md
- harness, command/rule, workflow hardening: docs/backlog/HARNESS.md

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
STATUS.md는 바로 수정하지 말고, 변경이 필요하면 State Update Gate에 맞게 먼저 보고해줘.
```

---

## 3. 새 작업 항목 등록

**AGENTS.md 있음:**

```text
AGENTS.md Codex Command Mapping의 /register 절차에 따라 새 작업 항목을 등록해줘.
```

**AGENTS.md 없음:**

```text
AGENTS.md, docs/AGENT-WORKFLOW.md, docs/STATUS.md를 확인해줘.
새 작업 항목을 등록하려고 해.

항목 설명: [한 줄]
긴급도: 지금 바로 착수 / 곧 할 것 / 나중에 검토
성격: product(기능·인프라) / harness(workflow·command·rule·문서 구조)

긴급도와 성격에 따라 아래 위치 중 적절한 곳에 등록해줘.

- 지금 바로 착수: docs/STATUS.md Active Work
- 곧 할 것: docs/STATUS.md Next Actions
- Product 작업: docs/backlog/PHASE{n}.md
- Harness 작업: docs/backlog/HARNESS.md

등록 항목에는 ID(prefix 포함), Priority, Scope, Done Criteria, Verification을 포함해줘.
STATUS.md 변경이 필요하면 State Update Gate에 맞게 먼저 보고하고 승인 대기해줘.
긴급 항목이면 등록 후 /work로 이어갈지 물어봐.
```

---

## 4. 특정 작업 진행

**AGENTS.md 있음:**

```text
AGENTS.md Codex Command Mapping의 /work [ID] 절차에 따라 계획을 세워줘.
```

**AGENTS.md 없음:**

```text
AGENTS.md, docs/AGENT-WORKFLOW.md, docs/STATUS.md를 확인해줘.
[작업 ID]를 진행하려고 해.

작업 ID에 따라 product backlog 또는 harness backlog를 선택해 해당 항목을 읽고 계획을 세워줘.

계획에는 반드시 아래 내용을 포함해줘.

1. Scope
2. 변경 예정 파일
3. Done Criteria
4. Verification
5. 리스크와 되돌리기 비용
6. 실행 모드: Quick Mode / Standard Work / Full Work
7. State Update 필요 여부
8. DR/Work 파일/문서 cascade 필요 여부

L1 Quick Mode에 해당하면 Work 파일 없이 final summary + validation + commit history로 닫을 수 있어.
단 workflow/protocol/command/rule/prompt/scaffold/status 파일을 건드리면 cascade check는 수행해.

계획을 보고한 뒤 "진행할까요?"로 끝내고 승인 대기해줘.
STATUS.md 변경은 사용자가 명시적으로 승인한 뒤에만 수행해줘.
```

---

## 5. 기존 작업 재개

**AGENTS.md 있음:**

```text
AGENTS.md Codex Command Mapping의 /resume [ID] 절차에 따라 작업을 재개해줘.
```

**AGENTS.md 없음:**

```text
AGENTS.md, docs/AGENT-WORKFLOW.md, docs/STATUS.md를 확인해줘.
Active Work 중 [작업 ID 또는 작업명]을 이어서 진행하려고 해.

현재 내가 알고 있는 상태는 다음과 같아.

- 완료된 것: [내용]
- 남은 것: [내용]
- 막힌 점: [내용]

먼저 실제 파일 상태와 docs/STATUS.md가 일치하는지 확인하고,
불일치가 있으면 바로 수정하지 말고 보고해줘.
대상 작업이 Done이면 재개하지 말고 후속 보정 작업을 신규 작업으로 분리할지 제안해줘.
STATUS.md 변경이 필요하면 State Update Gate에 맞게 먼저 보고하고 승인 대기해줘.
그다음 남은 작업 계획과 검증 방법을 제안해줘.
```

---

## 6. 구현 시작

**AGENTS.md 있음:**

```text
합의된 계획대로 [ID] 구현을 시작해줘. State Update 제안이 필요하면 먼저 보고해줘.
```

**AGENTS.md 없음:**

```text
이전에 합의한 계획에 따라 [작업 ID 또는 작업명] 구현을 시작해줘.

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
STATUS.md 변경이 필요하면 즉시 수정하지 말고 State Update Gate에 맞게 먼저 보고해줘.
```

---

## 7. 디버깅 또는 리팩토링 시작

**AGENTS.md 있음:**

```text
[대상]의 [문제]를 최소 변경 원칙으로 [디버깅/리팩토링]해줘. 계획 먼저 보고하고 승인 대기해줘.
```

**AGENTS.md 없음:**

```text
AGENTS.md, docs/AGENT-WORKFLOW.md, docs/STATUS.md를 확인해줘.

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

## 8. 발표/보고 자료 생성

**AGENTS.md 있음:**

```text
AGENTS.md Codex Command Mapping의 /doc 절차에 따라 발표/보고 자료를 준비해줘.

요청:
- 목적: [발표/보고/의사결정/리뷰/교육]
- Audience: [경영진/기술 리더/개발팀/외부 리뷰어]
- Format: [pptx/slide outline/markdown/docx/pdf-ready]
- Source: [STATUS/backlog/DR/diff/retrospective/메모]
- Length: [slide/page 수 또는 발표 시간]

먼저 brief와 outline을 제안하고, 승인 전에는 최종 파일을 만들지 마.
STATUS.md 변경이 필요하면 State Update Gate에 맞게 먼저 보고해줘.
```

**AGENTS.md 없음:**

```text
docs/AGENT-WORKFLOW.md와 docs/STATUS.md를 확인해줘.

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
STATUS.md 변경이 필요하면 State Update Gate에 맞게 먼저 보고해줘.
```

---

## 9. 문서 전용 작업

발표자료, 보고서, review package, decision brief, 외부 공유용 문서 산출물처럼 품질 높은 문서 생성 문맥이면 이 섹션 대신 `/doc` 절차를 사용한다.
기존 문서 일부 편집, 오탈자 수정, README 갱신처럼 source 문서 자체를 고치는 작업이면 아래 절차를 사용한다.

**AGENTS.md 있음:**

```text
[파일] 문서 작업을 진행해줘. State Update 제안이 필요하면 먼저 보고해줘.
```

**AGENTS.md 없음:**

```text
AGENTS.md, docs/AGENT-WORKFLOW.md, docs/STATUS.md를 확인해줘.

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

## 10. 세션 종료 요약

**AGENTS.md 있음:**

```text
AGENTS.md Codex Command Mapping의 /done 절차에 따라 세션을 마무리해줘.
```

**AGENTS.md 없음:**

```text
이번 Codex 세션을 다음 형식으로 요약해줘.

1. 완료한 작업
2. 변경된 파일
3. 실행한 검증
4. 남은 리스크
5. docs/STATUS.md 업데이트 필요 여부
   - 필요하면 즉시 수정하지 말고 State Update Gate에 맞게 제안해.
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
10. 다음 세션에서 이어갈 프롬프트
```

---

## 11. 실패/복구

**AGENTS.md 있음:**

```text
AGENTS.md Failure And Recovery 절차에 따라 FAIL 처리해줘.
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
상세 기준은 docs/harness-protocol/06-recovery-and-validation.md를 따라줘.
```
