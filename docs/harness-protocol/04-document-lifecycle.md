# 04. Document Lifecycle

이 문서는 document lifecycle과 문서 역할 구분의 canonical source다.

## Lifecycle

```text
CREATE -> UPDATE -> LINK -> VALIDATE -> ARCHIVE
```

## Document Roles

| Document | Role |
| --- | --- |
| `docs/STATUS.md` | 현재 상태 |
| `docs/backlog/PHASE{n}.md` | Product 후보 작업 |
| `docs/backlog/HARNESS.md` | Harness 후보 작업 |
| `docs/TODO/PHASE{n}/` | 대형 작업 내부 계획 |
| `docs/decisions/` | 결정 근거 |
| `docs/reports/` | 보고서, review package, decision brief |
| `docs/presentations/` | 발표자료, deck, slide source |
| `docs/HARNESS-PROTOCOL.md` | Agent 실행 프로토콜 허브 |
| `docs/harness-protocol/` | Agent 실행 프로토콜 상세 |
| `docs/WORKFLOW-MANUAL.md` | 사용자용 워크플로우 매뉴얼 |
| `docs/PLAN.md` | WHY |
| `docs/ARCHITECTURE.md` | WHAT |
| `docs/DEVELOPER-GUIDE.md` | HOW |
| `docs/archive/` | 완료된 이력 |
| `docs/troubleshooting/` | 증상 → 원인 → 조치 기록 |

## Document Role Distinction

유사해 보이는 세 파일 유형은 역할이 다르다.

| 유형 | 역할 | 기록 대상 |
| --- | --- | --- |
| `docs/decisions/DR-*.md` | 결정 근거 | 아키텍처·전략 선택의 WHY |
| `docs/retrospectives/` | 회고 | 개발 방식 자체의 평가와 개선 방향 |
| `docs/troubleshooting/` | 증상 → 원인 → 조치 | 비자명 이슈의 재현·원인·해결 내역 |
| `docs/reports/`, `docs/presentations/` | 산출물 | 발표·보고·리뷰·의사결정 지원 자료 |

## Update Rules

- 현재 상태가 바뀌면 `STATUS.md` 갱신 여부를 확인한다.
- 구조가 바뀌면 `ARCHITECTURE.md` 업데이트를 제안한다.
- 개발 절차가 바뀌면 `DEVELOPER-GUIDE.md` 업데이트를 제안한다.
- 결정 근거가 생기면 DR 생성을 제안한다.
- 완료된 Phase 상세는 archive로 이동한다.
- 비자명 이슈(환경 문제, 비직관적 원인)가 해결되면 `docs/troubleshooting/`에 기록을 제안한다.
- 발표/보고 산출물을 만들 때는 목적, audience, source, format, 검증 기준을 먼저 확정한다.

## Validation

- 새 문서는 `STATUS.md`, harness protocol, 또는 관련 backlog에서 참조되어야 한다.
- 같은 설명을 자동 로드 문서와 상세 문서에 길게 중복하지 않는다.
- 문서와 실제 파일이 충돌하면 실제 파일을 우선한다.
- 발표/보고 산출물은 source traceability, audience fit, narrative, slide/page count, render/preview 가능 여부를 확인한다.
- 문서 신규 작성 또는 섹션 추가 시 DR-007 Bilingual Rules를 적용한다.
