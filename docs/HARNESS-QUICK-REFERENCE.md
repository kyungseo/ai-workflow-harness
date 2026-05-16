# Harness Quick Reference

AI Workflow Harness의 일상 실행 규칙이다.
상세 설명은 `docs/HARNESS-PROTOCOL.md`를 따른다.
이 문서는 세션 중 빠르게 확인하는 요약이다. 충돌하거나 상세 판단이 필요하면 `docs/harness-protocol/*.md`를 우선한다.

## 1. Session Start

항상 먼저 `docs/STATUS.md`의 현재 섹션만 확인한다.

확인 항목:

- Current State
- Active Work
- Checkpoints
- Blockers And Open Questions
- Next Actions

추가 문서 로드 조건:

| Need | Load |
| --- | --- |
| Product task 선택 | `docs/backlog/PHASE{n}.md` |
| Harness task 선택 | `docs/backlog/HARNESS.md` |
| Architecture summary | `docs/PLAN-SUMMARY.md` |
| L3 change or planning basis | `docs/PLAN.md` |
| Priority tie, planning, idea generation, repeated risk | latest or relevant `docs/retrospectives/` |
| Non-trivial issue resolution history | `docs/troubleshooting/` |
| Past Phase1 detail | `docs/archive/harness-refactor-20260514/` or `docs/archive/` |

## 2. State Machine

```text
INIT -> PLAN -> APPROVAL -> EXECUTE -> VALIDATE -> CHECKPOINT -> END
                 ^              |
                 |              v
              RECOVER <- FAIL <-+
```

- **CHECKPOINT** = 작업 완료 후 커밋 + STATUS 업데이트. 다음 작업을 바로 이어갈 수 있다.
- **END (`/done`)** = 세션 종료 시에만 실행. 작업마다 호출하지 않는다.

## 3. Work Item Registration

새 작업 항목이 생기면 `/register`로 등록한다.

| 긴급도 / 성격 | 등록 위치 |
| --- | --- |
| 지금 바로 착수 (긴급 패치 등) | `docs/STATUS.md` Active Work → `/work`로 연결 |
| 곧 할 것 | `docs/STATUS.md` Next Actions |
| Product / Phase{n} 작업 | `docs/backlog/PHASE{n}.md` |
| Harness / workflow / rule 개선 | `docs/backlog/HARNESS.md` |

STATUS.md 변경이 포함되면 STATUS Update Proposal → 승인 순서를 따른다.

## 4. Execution Gate

구현 또는 문서 변경 전 plan을 먼저 제시한다.

Plan must include:

- Scope
- Files
- Verification
- Risk
- Reversal cost

승인 없이 구현하지 않는다.

### STATUS Update Gate

`docs/STATUS.md` 변경은 항상 사용자 승인 후에만 수행한다.

원칙:

- Agent는 먼저 `STATUS Update Proposal`을 보고한다.
- Proposal에는 변경 섹션, 변경 이유, 변경 후 상태, 되돌리기 비용을 포함한다.
- 사용자가 명시적으로 승인한 뒤에만 `docs/STATUS.md`를 수정한다.
- 이미 승인된 plan에 구체적인 `STATUS.md` 변경 범위가 포함되어 있으면 그 승인으로 갈음할 수 있다.
- 작업 중 예상 밖의 `STATUS.md` 변경 필요가 생기면 다시 승인받는다.
- Recent Decisions는 최근 8개 rolling window만 유지하고, 후속 행동을 바꾸는 운영/기술 판단만 둔다.
- Recent Decisions 초과분 제거 전 DR-worthy 항목이면 대응 DR 존재 여부를 확인한다.

`Done` 상태의 작업은 다시 수정하지 않는다. 완료 후 보정이 필요하면 신규 작업으로 분리한다.

## 5. Risk Level

| Level | Examples | Rule |
| --- | --- | --- |
| L1 Safe | 문서 소폭 수정, 테스트, 국소 버그 수정 | 간단 plan 후 승인 |
| L2 Normal | 기능 구현, 설정 변경, hook 추가 | 상세 plan 후 승인 |
| L3 Critical | 아키텍처, 보안, 인프라, DB schema, harness 구조 | AS-IS/TO-BE와 rollback 포함 |

## 6. Validation

완료 전 확인:

- STATUS 최신성
- 변경 파일 범위
- Verification 실행 또는 미실행 사유
- 문서 링크 정합성
- DR 필요 여부
- STATUS Update Proposal 필요 여부

COMMIT 전 확인:

- `git status`
- `git add <files>`
- `git status`
- `git diff --cached`

L3 이상 작업은 논리 단계별 commit을 기본값으로 한다. 한 commit에는 하나의 검증 가능한 목적을 담고, rollback plan은 commit 또는 단계 단위로 설명한다.

## 7. Failure Rules

다음은 실패 상태다.

- STATUS 불일치를 보고하지 않음
- Plan 없이 구현
- Validation 없이 commit
- 작업 범위가 승인된 plan 밖으로 확장됨
- 동일 오류 2회 반복

실패 시:

1. 작업 중단
2. Failure type과 root cause 보고
3. Recovery options 제시
4. 사용자 승인 후 재계획

## 8. Documentation Triggers

| Trigger | Action |
| --- | --- |
| DR-worthy decision accepted | `docs/decisions/` 기록 제안 |
| Structure change | `docs/ARCHITECTURE.md` 업데이트 제안 |
| Development flow change | `docs/DEVELOPER-GUIDE.md` 업데이트 제안 |
| Workflow rule/command change | `docs/HARNESS-PROTOCOL.md` 또는 `docs/harness-protocol/` 업데이트 |
| Phase complete | STATUS archive 제안 |
| Non-trivial issue resolved | `docs/troubleshooting/` 기록 제안 |
| Presentation/report artifact created | source traceability, output path, STATUS/backlog 참조 필요 여부 확인 |
| 문서/command/rule 신규 작성 또는 섹션 추가 | DR-007 Bilingual Rules 적용 확인 |

## 9. TODO Decomposition

TODO 파일은 큰 작업 하나의 내부 실행 계획이다. backlog나 STATUS를 대체하지 않는다.

생성 제안 조건:

- 아래 조건 중 둘 이상 해당
- 또는 사용자가 명시적으로 요청

조건:

- 서브태스크 3개 이상
- 3개 이상 파일 또는 2개 이상 서비스/모듈 영향
- 한 세션 안에 완료 불확실
- L3 작업
- checkpoint 2개 이상 필요
- 다른 Agent/도구로 인계 가능성 있음

파일명:

```text
docs/TODO/PHASE{n}/{BACKLOG-ID}-{lowercase-topic}.md
```

예시:

- `docs/TODO/PHASE2/P2-006-testcontainers.md`
- `docs/TODO/PHASE2/PRE-C1-architecture-audit.md`

## 10. Naming

| Prefix | Meaning |
| --- | --- |
| `P{n}-NNN` | Phase product backlog |
| `PRE-*` | Phase entry prerequisite |
| `HRF-*` | Harness refactor |
| `HRN-*` | Harness hardening |
| `DOC-*` | Documentation task |
| `DR-NNN` | Decision record |
| `OQ-*` | Open question |

ID를 다른 의미로 재사용하지 않는다.

## 11. Never

- 전체 repo를 먼저 스캔하지 않는다.
- 모든 문서를 한 번에 읽지 않는다.
- 파일 전체 overwrite를 기본값으로 삼지 않는다.
- 기능 추가와 리팩터링을 섞지 않는다.
- 관련 없는 최적화를 같이 하지 않는다.
