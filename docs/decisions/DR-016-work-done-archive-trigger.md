# DR-016: Work 파일 Done→Archived 전환 트리거 규칙

Status: Accepted (Amended by DR-038 — archived 인덱스를 live README가 아니라 archive-side mirrored README에 둔다)

Date: 2026-05-18
Status: Accepted

> **현재 기준**: 본문 하단 Addendum 참조 — HRN-019 이후 /done의 Work Done 처리 역할은 /close로 이관됨.

## Question

당시 DR-013이 Work 파일 lifecycle을 네 단계로 정의했으나,
Done과 Archived 사이의 전환 시점과 트리거가 명시되지 않았다.
`/done` 명령이 Done 처리와 Archive 이동을 한 스텝으로 묶고 있어,
리뷰 대기·외부 참조 유지 등의 이유로 Archive 시점을 미뤄야 할 때 규칙이 없다.

## Context

HRF-002 완료 시 발견한 실제 케이스:

- `done.md` item 11: `status: Done` 기입과 `git mv`(Archive 이동)를 같은 흐름으로 처리
- 사용자가 "리뷰 후에 archive"를 원해 Done은 처리했으나 git mv는 보류
- Done 상태 파일이 `docs/works/`에 남아 있는 상황에 대한 규칙 없음
- Done 항목이 `docs/works/`에 누적될 경우 Active 항목과 구분이 어려워짐

## Decision

Done과 Archived를 **명시적으로 분리**하고, 각 상태의 의미와 Archive 트리거를 정의한다.

### 상태 정의

| 상태 | 파일 위치 | 의미 |
|------|-----------|------|
| Done | `docs/works/{category}/` 유지 | 완료 기준 충족. 리뷰·참조 등 이유로 아직 이동 안 함 |
| Archived | `docs/archive/docs/works/{category}/` | 완전 종결. 더 이상 active 참조 불필요 |

### Done 처리 (즉시)

`/done` 실행 시 Work 파일에 대해 즉시 수행:

1. `status: Done`, `actual_end: YYYY-MM-DD` 기입
2. Done Criteria 전부 체크 확인
3. `docs/works/{category}/README.md`: Active → Done 테이블로 행 이동
4. STATUS Update Proposal: Active Work 포인터 제거

### Archive 처리 (트리거 시점에)

아래 트리거 중 하나가 충족되면 Archive 이동 수행:

| 트리거 | 설명 |
|--------|------|
| **명시적 확인** | 리뷰·검토 완료 후 사용자가 명시적으로 archive 승인 |
| **다음 세션 시작** | `/resume` 또는 `/start` 시 `docs/works/`에 Done 항목 발견 → archive 제안 |

Archive 이동 절차:
1. `docs/archive/docs/works/{category}/` 디렉토리 확인 (`mkdir -p`)
2. `git mv docs/works/{category}/{ID}-{topic}.md docs/archive/docs/works/{category}/`
3. live `docs/works/{category}/README.md`에서 Done 행을 제거하고, **archive-side `docs/archive/docs/works/{category}/README.md`의 Archived 테이블에 추가**한다 (DR-038). archive-side README가 없으면 이때 생성한다.
4. `status: Archived` 기입 (archive 위치의 파일)

### README 인덱스 구조 (DR-038 amended)

archived 인덱스는 hot-path live README에 누적하지 않고 archive-side mirrored README에 둔다.

live `docs/works/{category}/README.md` — 현행만:

```markdown
## Active

| ID | Status | Scope |
| -- | ------ | ----- |

## Done (Archive Pending)

| ID | actual_end | Scope |
| -- | ---------- | ----- |

## Archived

완전 종결 Work는 archive-side 인덱스 참조: `docs/archive/docs/works/{category}/README.md`
```

archive-side `docs/archive/docs/works/{category}/README.md` — Archived 인덱스:

```markdown
## Archived

| ID | actual_end | Archive 경로 |
| -- | ---------- | ------------ |
```

### 소프트 규칙

- Done 항목은 **같은 세션 또는 다음 세션** 안에 archive 처리를 목표로 한다.
- Done 항목이 2세션 이상 `docs/works/`에 잔류하면 `/health` 점검 대상이 된다.
- Archive 보류 이유(리뷰 대기 등)는 Work 파일 Discovery 섹션에 기록한다.

## Options Considered

| 선택지 | 장점 | 단점 |
|--------|------|------|
| Done = Archive 즉시 (현행 done.md) | 단순 | 리뷰 대기 등 유예 케이스 수용 불가 |
| Done / Archived 분리 + 소프트 트리거 (채택) | 유예 케이스 수용, 누적 방지 규칙 유지 | 2단계 절차로 복잡도 소폭 증가 |
| 별도 `/archive` 명령 | 명시적 | 명령 하나 추가, 사용 마찰 증가 |

## Rationale

리뷰 대기·외부 참조 등의 이유로 Done 이후 Archive 시점이 달라지는 케이스가 실제로 발생했다.
Done과 Archived를 분리하면 두 상태를 구분해 처리할 수 있고,
소프트 규칙(2세션 이내 archive)으로 Done 항목 누적을 방지할 수 있다.

## Consequences

- `done.md` item 11을 Done 즉시 처리 항목과 Archive 트리거 항목으로 분리한다.
- `docs/HARNESS-PROTOCOL.md` Work File Rules에 Done→Archived 트리거 추가한다.
- live `docs/works/{category}/README.md`는 Active / Done (Archive Pending) 테이블 + archive-side pointer를 둔다. Archived 인덱스는 archive-side README가 보유한다 (DR-038 amend; 최초 결정의 3-table live 구조를 대체).
- `/resume`, `/start` 명령에 Done 항목 발견 시 archive 제안 안내를 추가한다 (별도 HRN으로 추적).
- 갱신은 별도 HRN 항목으로 추적한다.

## Reversal Cost

Low — 트리거 규칙은 문서 변경만으로 원복 가능.

## Linked Backlog Items

- HRN-017 (DR-015 구현) — 게이트 규칙 정비와 연계 검토
- 신규 HRN: done.md 분리, README 템플릿 갱신, /resume·/start 안내 추가

## Addendum (2026-05-18 — HRN-019)

HRN-019 도입으로 이 DR에 명시된 `/done` 역할이 `/close`로 이관되었다.

- **이전**: `/done` item 11이 Done 즉시 처리(status/actual_end/README/STATUS pointer)와 archive 트리거를 담당
- **이후**: `/close`가 Work Done 처리와 선택적 archive를 전담, `/done`은 세션 요약만 출력

이 DR Consequences 항목 중 `done.md` item 11 분리는 HRN-019에서 `/close` 신규 도입으로 완료되었다.
