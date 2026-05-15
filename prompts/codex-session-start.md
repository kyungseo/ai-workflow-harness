# Codex 세션 시작 프롬프트

이 문서는 Codex에서 새 세션을 시작할 때 복사해서 쓰는 bootstrap prompt다.
repo root의 `AGENTS.md`가 Codex 기본 진입점이다.
이 prompt는 `AGENTS.md`를 사용할 수 없거나 수동 bootstrap이 필요한 환경에서 `docs/AGENT-WORKFLOW.md`, `docs/STATUS.md`, `docs/HARNESS-PROTOCOL.md`를 명시적으로 확인하도록 돕는 fallback이다.

Codex 운영 기준:

- `.claude/commands/*`는 Claude Code용 slash command 정의이므로 Codex에서 직접 실행하지 않는다.
- `.cursor/rules/*.mdc`는 Cursor용 rule이다. Codex는 필요 시 참고할 수 있지만 자동 적용 기준으로 보지 않는다.
- Codex 전용 프로젝트 instruction은 repo root의 `AGENTS.md`를 기준으로 한다.
- 작업 상태와 기록 기준은 현재 하네스와 동일하게 `docs/STATUS.md`, product/harness backlog, DR/TODO/document cascade를 따른다.

컨텍스트 참조 우선순위:

1. `AGENTS.md` — Codex 진입점
2. `docs/AGENT-WORKFLOW.md` — 공통 운영 규칙
3. `docs/STATUS.md` — 현재 작업 상태
4. `docs/HARNESS-PROTOCOL.md` — workflow/harness 상세 기준이 필요할 때
5. `docs/HARNESS-QUICK-REFERENCE.md` — 빠른 실행 규칙 확인
6. `docs/PLAN-SUMMARY.md` — product 아키텍처 요약이 필요할 때

작업 선택 기준:

- Product 또는 Phase 준비 작업: `docs/backlog/PHASE2.md`
- Harness, command/rule, workflow hardening: `docs/backlog/HARNESS.md`
- 큰 작업의 세부 계획: `docs/TODO/PHASE{n}/{BACKLOG-ID}-{topic}.md`

---

## 1. 기본 세션 시작

```text
AGENTS.md와 docs/AGENT-WORKFLOW.md를 읽어줘.
그다음 docs/STATUS.md의 Current State, Active Work, Checkpoints, Blockers And Open Questions, Next Actions만 확인해줘.

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

```text
AGENTS.md, docs/AGENT-WORKFLOW.md, docs/STATUS.md를 확인해줘.
작업 성격에 따라 product backlog 또는 harness backlog를 선택해 다음 후보를 검토해줘.

- product 또는 Phase 준비 작업: docs/backlog/PHASE2.md
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
STATUS.md는 바로 수정하지 말고, 변경이 필요하면 STATUS Update Proposal로 먼저 보고해줘.
```

---

## 3. 특정 작업 진행

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
6. docs/STATUS.md 반영 필요 여부와 STATUS Update Proposal
7. DR/TODO/문서 cascade 필요 여부

계획을 보고한 뒤 "진행할까요?"로 끝내고 승인 대기해줘.
STATUS.md 변경은 사용자가 명시적으로 승인한 뒤에만 수행해줘.
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
- 사용자 변경을 되돌리지 말고, 충돌 시 보고

구현 후에는 검증을 실행하고,
docs/STATUS.md 업데이트와 DR/TODO/문서 cascade가 필요한지 제안해줘.
STATUS.md 변경이 필요하면 즉시 수정하지 말고 STATUS Update Proposal을 먼저 보고해줘.
```

---

## 5. 디버깅 또는 리팩토링 시작

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

## 6. 문서 전용 작업

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

## 7. 세션 종료 요약

```text
이번 Codex 세션을 다음 형식으로 요약해줘.

1. 완료한 작업
2. 변경된 파일
3. 실행한 검증
4. 남은 리스크
5. docs/STATUS.md 업데이트 필요 여부
   - 필요하면 즉시 수정하지 말고 STATUS Update Proposal로 변경 섹션, 변경 이유, 변경 후 상태, 되돌리기 비용을 제시해.
   - 사용자가 명시적으로 승인한 뒤에만 STATUS.md를 수정해.
6. 의사결정 기록 필요 여부
   - 이번 작업에서 DR-worthy 결정이 확정되었으면 목록화하고 기록 여부를 물어봐.
   - 계획·검토 중 발견된 미결 의사결정이 있으면 STATUS.md OQ 추가 및 DR Draft 생성을 제안해.
7. 상태 머신 종료 상태
   - VALIDATE 결과
   - CHECKPOINT, END, 또는 FAIL/RECOVER 필요 여부
8. 다음 세션에서 이어갈 프롬프트
```

---

## 8. 실패/복구

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
