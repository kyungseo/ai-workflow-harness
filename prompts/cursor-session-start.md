# Cursor 세션 시작 프롬프트

이 문서는 Cursor에서 새 세션을 시작할 때 복사해서 쓰는 부트스트랩 프롬프트다.
현재 프로젝트는 `CLAUDE.md`, `docs/CLAUDE.md`, `docs/STATUS.md`, `docs/backlog/*.md`, `.cursor/rules/*.mdc`를 기준으로 작업한다.
이 문서들은 작업 컨텍스트와 상태를 관리하기 위한 기준이며, 실제 작업은 `계획 수립 -> 승인 -> 구현 -> 검증 -> STATUS 갱신` 순서로 진행한다.
`docs/TODO/PHASE1/TODO-BLOCK*.md`는 Phase 1 상세 작업 분해 문서이며, Phase 1 구현 맥락이 필요할 때만 참고한다.

컨텍스트 참조 우선순위:
1. `CLAUDE.md` — 공통 작업 계약
2. `docs/CLAUDE.md` — 프로젝트 운영 규칙
3. `docs/STATUS.md` — 현재 작업 상태
4. `docs/PLAN-SUMMARY.md` — 기술 스택·포트·아키텍처 요약 (기본 참조용, `docs/PLAN.md`는 상세 필요시만)
5. `docs/backlog/*.md` — 후보 작업
6. `.cursor/rules/*.mdc` — 도구별 규칙

Cursor는 `.cursor/rules/*.mdc`를 함께 참고하되, 충돌 시 아래 우선순위를 따른다.

1. `CLAUDE.md`
2. `docs/CLAUDE.md`
3. `docs/STATUS.md`
4. `.cursor/rules/*.mdc`

---

## 1. 기본 세션 시작

```
CLAUDE.md와 docs/CLAUDE.md를 읽어줘.
그다음 docs/STATUS.md의 Current State, Active Work, Checkpoints, Next Actions만 확인해줘.
아키텍처나 기술 스택 정보가 필요하면 docs/PLAN-SUMMARY.md를 읽어줘 (docs/PLAN.md는 상세 검토 시에만).
Phase 1 구현 상세가 필요한 경우에만 docs/TODO/PHASE1/TODO-BLOCK*.md를 추가로 참고해줘.

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

```
CLAUDE.md, docs/CLAUDE.md, docs/STATUS.md, .cursor/rules/*.mdc를 확인해줘.
Active Work의 [작업 ID 또는 작업명]을 진행하려고 해.

먼저 아래 항목을 보고해줘.

- 작업 범위
- 확인해야 할 파일
- 변경 예정 파일
- Done Criteria
- Verification
- 리스크
- 되돌리기 비용

내가 승인하기 전에는 구현하지 마.
```

---

## 3. Backlog Item 선정

```
CLAUDE.md, docs/CLAUDE.md, docs/STATUS.md를 읽어줘.
docs/backlog/PHASE2.md에서 다음에 진행할 작업 후보를 우선순위 순서로 검토해줘.

각 후보에 대해 아래 항목을 비교해줘.

- ID
- 우선순위
- 선행 조건
- 구현 난이도
- 운영 리스크
- 검증 방법

가장 먼저 진행할 작업 1개를 추천하고,
docs/STATUS.md에 Active Work로 올릴 때 필요한 내용을 제안해줘.
```

---

## 4. 구현 시작

```
이전에 합의한 계획에 따라 [작업 ID 또는 작업명] 구현을 시작해줘.

원칙:

- 변경은 최소 범위로 제한
- 무관한 리팩토링 금지
- 새 의존성 추가 전 근거 보고
- secrets, .env, 토큰, 비밀번호 노출 금지
- 파괴적/권한 상승/인프라 변경 명령은 실행 전 승인 요청

구현 후에는 검증을 실행하고,
docs/STATUS.md 업데이트가 필요한지 제안해줘.
```

---

## 5. 디버깅 시작

```
CLAUDE.md, docs/CLAUDE.md, docs/STATUS.md, .cursor/rules/debugging.mdc를 확인해줘.

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

## 6. 문서 전용 작업

```
CLAUDE.md, docs/CLAUDE.md, docs/STATUS.md, .cursor/rules/output-format.mdc를 확인해줘.

문서 작업:

- 대상 문서: [파일]
- 목적: [무엇을 개선하려는지]
- 유지할 내용: [보존해야 할 내용]
- 변경할 내용: [바꿔야 할 내용]

긴 기록은 docs/STATUS.md에 넣지 말고,
완료된 상세 이력은 docs/archive/로 분리하는 원칙을 지켜줘.
수정 전 변경 계획을 먼저 제안해줘.
```

---

## 7. 세션 종료 요약

```
이번 Cursor 세션을 다음 형식으로 요약해줘.

1. 완료한 작업
2. 변경된 파일
3. 실행한 검증
4. 남은 리스크
5. docs/STATUS.md 업데이트 필요 여부
6. 의사결정 기록 필요 여부
   - 이번 작업에서 DR-worthy 결정이 확정되었으면 목록화하고 기록 여부를 물어봐.
   - 계획·검토 중 발견된 미결 의사결정이 있으면 STATUS.md OQ 추가 및 DR Draft 생성을 제안해.
7. 다음 세션에서 이어갈 프롬프트
```
