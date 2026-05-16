# AGENTS.example.md

> 이 파일은 AGENTS.example.md로 저장된 설계 초안이다.
> 현재 실제 Codex 진입점은 repo root의 `AGENTS.md`다.
> 이 파일은 초기 설계 참고용으로만 유지한다.

Codex가 repo root에서 자동으로 읽는 project-level instruction이다.
CLAUDE.md와 대칭 관계이며, 공통 운영 규칙은 `docs/AGENT-WORKFLOW.md`와 `docs/harness-protocol/`에 있다.

## 1. 필수 읽기 순서 (세션 시작)

1. `CLAUDE.md` — 공통 작업 계약
2. `docs/AGENT-WORKFLOW.md` — 최소 운영 규칙 (context routing table 포함)
3. `docs/STATUS.md` — 현재 작업 상태 (Current State, Active Work, Checkpoints, Blockers And Open Questions, Next Actions 섹션만)
4. (조건부) `docs/backlog/PHASE2.md` 또는 `docs/backlog/HARNESS.md`

조건부 로드 기준은 `docs/AGENT-WORKFLOW.md`의 Context Routing 표를 따른다.

## 2. 상태 머신

```text
INIT -> PLAN -> APPROVAL -> EXECUTE -> VALIDATE -> CHECKPOINT -> END
                 ^              |
                 |              v
              RECOVER <- FAIL <-+
```

상세: `docs/harness-protocol/01-session-state-machine.md`

## 3. 수동 명령 절차

Codex는 `.claude/commands/*.md`를 직접 실행하지 않는다.
아래 절차를 수동으로 수행한다.

| Claude 명령 | Codex 수동 절차 |
| --- | --- |
| `/start` | §1 읽기 순서를 따르고 결론/현재 진행 상태/다음 작업 후보/필요한 추가 문서/리스크 형식으로 요약 보고 |
| `/pick` | STATUS.md 확인 → 작업 성격에 따라 PHASE2.md 또는 HARNESS.md 선택 → 우선순위 높은 후보 1개 추천 |
| `/work <ID>` | backlog에서 ID 확인 → L1/L2/L3 리스크 선언 → scope/files/verification/risk 포함한 plan 보고 → "진행할까요?"로 승인 대기 |
| `/done` | §4 세션 종료 체크리스트 수행 |
| `/resume <ID>` | STATUS.md 확인 → 실제 파일 상태와 불일치 점검 → 불일치 보고 후 승인받아 수정 |

## 4. 세션 종료 체크리스트

1. 완료한 작업
2. 변경된 파일
3. 실행한 검증
4. 남은 리스크
5. `docs/STATUS.md` 업데이트 필요 여부 — 필요하면 STATUS Update Proposal로 먼저 보고하고 승인 후 수정
6. DR-worthy 결정 여부 — 확정된 결정이 있으면 목록화하고 기록 여부 질문
7. 상태 머신 종료 상태 — VALIDATE 결과, CHECKPOINT 또는 FAIL/RECOVER 필요 여부
8. Commit 상태 — 미커밋이면 이유와 잔여 리스크 명시
9. 다음 세션 시작 문장

## 5. 실패와 복구

검증 실패, 상태 불일치, 컨텍스트 손실은 즉시 FAIL로 보고한다.

보고 항목:
- 실패 유형
- 근본 원인
- 영향받은 파일/상태
- 복구 옵션
- 권장 경로

복구 흐름: `FAIL -> report -> options -> user decision -> PLAN`

상세: `docs/harness-protocol/06-recovery-and-validation.md`

## 6. STATUS 보호 규칙

`docs/STATUS.md`는 승인 없이 직접 수정하지 않는다.

변경이 필요하면 먼저 아래 항목을 보고한다:
- 변경 섹션
- 변경 이유
- 변경 후 상태
- 되돌리기 비용

사용자가 명시적으로 승인한 뒤에만 수정한다.

## 7. 금지 사항

- 승인 없이 구현 시작 금지
- 검증 실패 상태에서 commit 금지
- `Done` 상태의 작업을 직접 재개 금지 — 후속 보정은 신규 작업으로 분리
- `.env`, `secrets/**`, `*.key`, `*.pem`, `.claude/settings.local.json` 읽기 금지
- `sudo`, `rm -rf`, `kubectl`, `terraform` 실행 금지
