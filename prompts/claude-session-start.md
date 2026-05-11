# Claude Code 세션 시작 프롬프트

이 문서는 새 Claude Code 세션을 시작할 때 복사해서 쓰는 부트스트랩 프롬프트 모음이다.
현재 프로젝트의 작업 컨텍스트는 `docs/STATUS.md`, `docs/PLAN.md`, `docs/backlog/`, `docs/archive/`로 관리한다.
실제 작업은 `계획 수립 -> 승인 -> 구현 -> 검증 -> STATUS 갱신 -> 필요 시 archive 정리` 순서로 진행한다.

핵심 원칙:

- `CLAUDE.md`와 `docs/CLAUDE.md`를 먼저 따른다.
- `docs/STATUS.md`를 현재 작업 상태의 기준으로 삼는다.
- 긴 문서는 처음부터 전부 읽지 말고, 필요한 섹션만 읽는다.
- Phase 1 상세 맥락이 필요할 때만 `docs/TODO/PHASE1/TODO-BLOCK*.md`를 참고한다.
- 구현 전에는 계획, 검증 방법, 리스크를 먼저 보고한다.
- 작업 상태가 바뀌면 `docs/STATUS.md` 업데이트 필요 여부를 제안한다.

---

## 1. 기본 세션 시작

```
CLAUDE.md와 docs/CLAUDE.md를 읽어줘.
그다음 docs/STATUS.md의 Current State, Active Work, Checkpoints, Next Actions만 확인해줘.
Phase 1 구현 상세가 필요한 경우에만 docs/TODO/PHASE1/TODO-BLOCK*.md를 추가로 참고해줘.

아래 형식으로 현재 상태를 요약해줘.

1. 결론
2. 현재 Active Work
3. 다음으로 진행할 후보 작업
4. 필요한 추가 문서
5. 리스크와 확인 질문

아직 구현은 시작하지 말고, 진행할 작업을 먼저 제안해줘.
```

---

## 2. Phase 2 작업 선택

```
CLAUDE.md, docs/CLAUDE.md, docs/STATUS.md를 확인해줘.
그리고 docs/backlog/PHASE2.md에서 우선순위가 높은 후보 작업을 검토해줘.

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
```

---

## 3. 특정 Backlog Item 진행

```
CLAUDE.md, docs/CLAUDE.md, docs/STATUS.md를 확인해줘.
docs/backlog/PHASE2.md에서 [작업 ID] 항목을 읽고 진행 계획을 세워줘.

계획에는 반드시 아래 내용을 포함해줘.

1. 현재 코드/문서에서 확인해야 할 파일
2. 구현 또는 문서 변경 범위
3. Done Criteria
4. Verification
5. 리스크와 되돌리기 비용
6. docs/STATUS.md에 반영해야 할 상태 변경

계획을 보고한 뒤 "진행할까요?"로 끝내고 승인 대기해줘.
```

---

## 4. 기존 작업 재개

```
CLAUDE.md, docs/CLAUDE.md, docs/STATUS.md를 읽어줘.
Active Work 중 [작업 ID 또는 작업명]을 이어서 진행하려고 해.

현재 내가 알고 있는 상태는 다음과 같아.

- 완료된 것: [내용]
- 남은 것: [내용]
- 막힌 점: [내용]

먼저 실제 파일 상태와 docs/STATUS.md가 일치하는지 확인하고,
불일치가 있으면 바로 수정하지 말고 보고해줘.
그다음 남은 작업 계획과 검증 방법을 제안해줘.
```

---

## 5. 신규 프로젝트 초기화

```
이 저장소의 Claude 운영 구조를 참고해서 새 프로젝트용 AI 작업 문서 구조를 설계해줘.

새 프로젝트 정보:

- 목표: [한 문장]
- 기술 스택: [언어, 프레임워크, DB, 배포 환경]
- 제약 조건: [성능, 보안, 호환성, 일정 등]
- 우선순위: [가장 중요한 것]
- 초기 범위: [Phase 1에서 만들 것]

다음 파일 구조를 기준으로 초안을 제안해줘.

- CLAUDE.md
- docs/CLAUDE.md
- docs/STATUS.md
- docs/PLAN.md
- docs/backlog/PHASE1.md
- docs/archive/
- .claude/settings.json
- .claude/rules/

구현이나 파일 생성은 내가 승인한 뒤 진행해줘.
```

---

## 6. 리팩토링 또는 디버깅 시작

```
CLAUDE.md, docs/CLAUDE.md, docs/STATUS.md를 확인해줘.

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

## 7. 세션 종료 요약

```
이번 세션에서 진행한 내용을 다음 형식으로 요약해줘.

1. 완료한 작업
2. 변경된 파일
3. 실행한 검증
4. 남은 리스크
5. 다음 세션에서 먼저 볼 파일
6. docs/STATUS.md 업데이트 필요 여부

다음 세션의 시작 프롬프트로 바로 사용할 수 있는 짧은 문장도 마지막에 작성해줘.
```
