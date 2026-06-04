# DR-013: Work 파일 기반 작업 단위 체계 도입

Date: 2026-05-18
Status: Accepted

## Question

작업 단위를 어디에 어떤 형식으로 기록해야 STATUS.md 비대화를 막고, 세션 간 이력을 완전히 보존할 수 있는가?

## Decision

Work 파일을 작업의 단일 진실 공급원(Single Source of Truth)으로 도입한다.

- Work 파일은 decomposition criteria를 만족하거나 인계·장기 추적이 필요한 작업에 생성한다.
- 작은 L1 작업은 Quick Mode로 처리할 수 있으며, 이 경우 최종 응답·validation 결과·commit history가 기록 역할을 한다.
- STATUS.md의 Active Work는 Work 파일 경로를 가리키는 포인터만 유지한다.
- 완료된 Work 파일은 `docs/archive/docs/works/{category}/` 로 이동한다 (DR-014 Archive 정책 적용).

### Work 파일 Frontmatter 스펙

```yaml
---
id: {ID}                      # e.g., CHORE-20260527-001, FEAT-20260601-001
priority: {P0|P1|P2|P3}
status: {Active|Done|Archived}
risk: {Low|Medium|High}
scope: {한 줄 범위 설명}
appetite: {1d|3d|1w|2w}       # 시간 예산 (Shape Up 개념)
planned_start: YYYY-MM-DD
planned_end: YYYY-MM-DD
actual_end:                   # 완료 후 기입
related_dr: []                # 관련 Decision Records (e.g., [DR-013])
related_troubleshooting: []   # 관련 troubleshooting 문서 경로
---
```

### Work 파일 운영 규칙

공통 운영 규칙(실제 저장소 상태 우선 원칙 등)은 `docs/HARNESS-PROTOCOL.md` Work File Rules 섹션이 권위 문서다. 개별 Work 파일은 이를 반복하지 않는다.
Quick Mode 정책도 같은 문서가 권위 문서다.

### Work 파일 섹션 구성

```markdown
## Plan
접근 방법. Alternatives 포함 — 왜 이 방법을 선택했는지.

## Done Criteria
- [ ] 사전 정의된 완료 기준 (작업 착수 시 작성)

## Verification
완료 기준 충족을 확인하는 절차 또는 명령어.

## Checkpoints
| CP | Description | Status |
|----|-------------|--------|
| 1  | ...         | Todo   |

실행 중 채워가는 진행 로그. 세션 재개 지점 역할.

## Discovery
계획과 달라진 것, 새로 발견한 것, 다음 작업을 위한 인사이트.
```

### Status Lifecycle

```
Active  →  Done  →  Archived
(착수)    (완료)   (archive/ 이동)
```

- **Active**: Work 파일 생성, STATUS.md Active Work에 포인터 추가.
- **Done**: Done Criteria 전부 충족, Verification 통과. actual_end 기입.
- **Archived**: Work 파일을 `docs/archive/docs/works/{category}/` 로 이동. STATUS.md 포인터 제거.

Backlog의 `Candidate` 항목은 후보 pool이다.
착수 전 분해나 메모는 backlog 항목에 남기고, Work 파일은 착수 승인 후 `Active` 상태로 생성한다.

Done과 Archived는 분리한다. Done 상태의 Work 파일은 리뷰·참조 등의 이유로 `docs/works/{category}/`에 남을 수 있으며, archive 이동은 사용자 명시 승인 또는 `/start`·`/resume` archive trigger 승인 후 수행한다.

### 카테고리 디렉토리

| 경로 | 대상 |
|------|------|
| `docs/works/harness/` | Harness track 작업 (CHORE-*; harness-track FEAT-*/PATCH-*/HOTFIX-*; historical: HRF-*, HRN-*, DOC-*) |
| `docs/works/phase{n}/` | Product track 작업 (product-track FEAT-*/PATCH-*/HOTFIX-*; historical: P{n}-*, PRE-*) |

### 인덱스 파일

각 카테고리 디렉토리에 `README.md` 를 유지한다.
권장 섹션 구조는 `docs/HARNESS-PROTOCOL.md` Index Rules를 따른다.

권장 섹션: Active / Done (archive pending) / Archived

## Options Considered

| 선택지 | 장점 | 단점 |
|--------|------|------|
| Work 파일 도입 (채택) | 이력 완전 보존, STATUS.md 축소, 세션 재개 지점 명확 | 파일 수 증가, 초기 마이그레이션 필요 |
| STATUS.md 확장 유지 | 한 파일에서 모든 정보 | 비대화 불가피, 롤링 윈도우로 이력 소실 |
| GitHub Issues 도입 | 검색·필터 강력 | 오프라인 불가, git repo 외부 이력 |

## Rationale

STATUS.md는 Phase 대시보드 역할에 집중해야 한다. 작업 내용·이력·Checkpoints를 STATUS.md에 누적하면 롤링 윈도우 정책에 의해 소실되거나 파일이 비대해진다. Work 파일을 개별 파일로 관리하면 git 버전 관리 하에 완전한 이력이 보존되고, 아카이브 이동 시에도 내용이 그대로 유지된다. `docs/TODO/` 디렉토리가 존재했으나 활용되지 않아 이를 `docs/works/` 로 재명명하여 Work 파일 체계의 홈으로 삼는다.

## Consequences

- `docs/works/` 디렉토리가 작업 단위의 중심이 된다.
- STATUS.md Active Work는 Work 파일 경로 포인터만 갖는다.
- Checkpoints 섹션은 STATUS.md에서 제거되고 각 Work 파일 내부로 이동한다.
- `docs/backlog/` 의 항목은 Candidate pool이며, 착수 전 분해나 메모는 backlog 항목에 남긴다.
- Work 파일은 착수 승인 후 `Active` 상태로 생성한다.
- 작은 L1 작업은 Work 파일 없이 Quick Mode로 완료할 수 있다.
- harness 프로토콜 문서(`docs/AGENT-WORKFLOW.md`, `docs/HARNESS-PROTOCOL.md` 등) 업데이트 필요.

## Reversal Cost

Medium — Work 파일 구조를 되돌리려면 개별 파일들을 STATUS.md로 재통합해야 하며, 이미 생성된 Work 파일 수에 비례한다.

## Linked Backlog Items

- HRF-002 (Active)
