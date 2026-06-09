# DR-013: Work 파일 기반 작업 단위 체계 도입

Date: 2026-05-18
Status: Accepted (Amended 2026-06-07)

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
risk: {L1|L2|L3}
scope: {한 줄 범위 설명}
appetite: {1d|3d|1w|2w}       # 시간 예산 (Shape Up 개념)
planned_start: YYYY-MM-DD
planned_end: YYYY-MM-DD
actual_end:                   # 완료 후 기입
related_dr: []                # 관련 Decision Records (e.g., [DR-013])
related_troubleshooting: []   # 관련 troubleshooting 문서 경로
related_work: []              # 관련 Work ID (parent/child/sibling). 부모가 있으면 먼저 기재.
---
```

**`related_work` 기재 관례:**

- parent(이 Work를 낳은 Work)가 있으면 첫 번째로 기재한다.
- 이후 직접 연관된 child·sibling Work ID를 나열한다.
- 관계 타입(parent/child/sibling)은 ID만으로 표현하며, 구체적 관계 서술은 Top Summary에서 한다.
- 양방향 필수 아님. 실질적으로 참조가 필요한 쪽에만 기재하면 된다.
- 값이 없으면 `[]` 로 유지한다.

### Work 파일 운영 규칙

공통 운영 규칙(실제 저장소 상태 우선 원칙 등)은 `docs/HARNESS-PROTOCOL.md` Work File Rules 섹션이 권위 문서다. 개별 Work 파일은 이를 반복하지 않는다.
Quick Mode 정책도 같은 문서가 권위 문서다.

### Work 파일 섹션 구성

```markdown
## Top Summary (결론 먼저)
목표, 시발점, 비목표를 3~5줄로 요약한다. 세션 재개 시 가장 먼저 읽는 섹션.
> 참고: 일부 Work 파일에서 "Executive Summary"로 쓰인 경우가 있으나 Top Summary로 통일한다.

## Context Manifest
세션 재개 시 읽어야 할 파일·섹션과 이유를 표로 정리한다.
복잡한 work나 세션 인계 가능성이 있을 때 포함한다. 단순한 work는 생략 가능.

| 순서 | 파일 | 섹션 | 왜 |
|---|---|---|---|
| 1 | `경로` | 섹션명 또는 라인 | 읽어야 하는 이유 |

Trigger Source(시발점)는 Context Manifest 최하단에 한 줄로 기입한다.
예: `Trigger: backlog candidate 착수 / user observation: ... / session discussion: ... / incident: ...`

## Scope (또는 Plan)
접근 방법과 구현 범위. 왜 이 방법을 선택했는지 포함. 섹션 이름은 `Scope`·`Plan` 중 작업 성격에 맞게 선택한다 — 범위 정의가 주면 Scope, 실행 절차가 주면 Plan.

**Slice 체계 (해당되는 경우에만):**
독립 commit 가능한 단위가 2개 이상이고 Checkpoint가 3개 이상이거나 세션 인계 가능성이 있을 때 사용.
아주 간단한 작업, Quick Mode, 단일 세션 완료 확실한 L2 단순 작업에는 불필요.
사용 시 Plan 내 서브섹션으로 자연 삽입한다 — 별도 "Slice" 섹션을 만들지 않는다.

### Slice A — {제목}
### Slice B — {제목}
...

## Done Criteria
- [ ] 사전 정의된 완료 기준 (작업 착수 시 작성)

## Verification
완료 기준 충족을 확인하는 절차 또는 명령어.

## Checkpoints
| CP | Description | Status |
|----|-------------|--------|
| 1  | ...         | → 진행 중 |

실행 중 채워가는 진행 로그. 세션 재개 지점 역할.

## Next Actions
현재 시점에서 다음 실행 목록. Checkpoints와 연동하여 현행화한다.

형식:
- ✓ 완료된 항목
- → 현재 진행 중
- ○ 대기 중

## Discovery
계획과 달라진 것, 새로 발견한 것, 다음 작업을 위한 인사이트.
```

### Backlog Candidate ID-less 정책

feature branch에서 backlog row에 Work ID를 역기입하지 않는다.

- **이유:** 병렬 feature branch에서 NNN이 충돌할 수 있다 (CHORE-20260527-001 참조).
- **대신:** Work 파일 Discovery 섹션에 "backlog의 [항목명] candidate 착수"로 기록한다.
- **backlog row 정리** (제거 또는 Active 표시)는 develop merge 후 tracking-only commit으로 처리한다.

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

Done과 Archived는 분리한다. Done 상태의 Work 파일은 리뷰·참조 등의 이유로 `docs/works/{category}/`에 남을 수 있으며, archive 이동은 사용자 명시 승인 또는 `/session-start`·`/work-resume` archive trigger 승인 후 수행한다.

### 카테고리 디렉토리

| 경로 | 대상 |
|------|------|
| `docs/works/harness/` | Harness track 작업 (CHORE-*; harness-track FEAT-*/PATCH-*/HOTFIX-*; historical: HRF-*, HRN-*, DOC-*) |
| `docs/works/product/` | Product track 작업 (product-track FEAT-*/PATCH-*/HOTFIX-*; historical: P{n}-*, PRE-*). 단계 운영 여부와 무관하게 단일 디렉토리 (DR-031) |

### 인덱스 파일

각 카테고리 디렉토리에 `README.md` 를 유지한다.
권장 섹션 구조는 `docs/HARNESS-PROTOCOL.md` Index Rules를 따른다.

권장 섹션: Active / Done (archive pending) / Archived

## Amendment History

| Date | Change |
|------|--------|
| 2026-05-18 | 최초 결정: Work 파일 체계 도입, 섹션 구성(Plan/Done Criteria/Verification/Checkpoints/Discovery) |
| 2026-06-07 | Top Summary·Next Actions 공식화(기존 관행 → 스펙 반영), Context Manifest·Trigger Source 신규, Slice 기준 명문화, Backlog candidate ID-less 정책 추가 |
| 2026-06-08 | `related_work` 필드 추가 — Work 간 parent/child/sibling 관계 표현. 기재 관례 명문화 |

## Options Considered

| 선택지 | 장점 | 단점 |
|--------|------|------|
| Work 파일 도입 (채택) | 이력 완전 보존, STATUS.md 축소, 세션 재개 지점 명확 | 파일 수 증가, 초기 마이그레이션 필요 |
| STATUS.md 확장 유지 | 한 파일에서 모든 정보 | 비대화 불가피, 롤링 윈도우로 이력 소실 |
| GitHub Issues 도입 | 검색·필터 강력 | 오프라인 불가, git repo 외부 이력 |

## Rationale

STATUS.md는 Phase 대시보드 역할에 집중해야 한다. 작업 내용·이력·Checkpoints를 STATUS.md에 누적하면 롤링 윈도우 정책에 의해 소실되거나 파일이 비대해진다. Work 파일을 개별 파일로 관리하면 git 버전 관리 하에 완전한 이력이 보존되고, 아카이브 이동 시에도 내용이 그대로 유지된다.

Top Summary와 Next Actions는 실제 work 파일들에서 먼저 사용된 후 이번 amendment로 공식화됐다. Context Manifest는 CHORE-20260605-004에서 검증된 패턴으로, 세션 인계 시 컨텍스트 복구 비용을 낮춘다.

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
