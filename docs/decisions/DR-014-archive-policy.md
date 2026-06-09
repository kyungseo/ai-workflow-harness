# DR-014: Archive 구조 정책 — 경로 미러링 및 버전 관리

Date: 2026-05-18
Status: Accepted

## Question

프로젝트 내 어느 파일이든 아카이빙할 수 있는 일관된 구조와 네이밍 규칙은 무엇인가?

## Decision

`docs/archive/` 하위에 **원본 경로를 미러링**하여 아카이빙한다.

### 구조

```
docs/archive/
├── docs/                        ← docs/ 하위 파일 아카이빙
│   ├── works/
│   │   ├── harness/             ← 완료된 harness Work 파일
│   │   └── phase2/              ← 완료된 phase2 Work 파일
│   ├── WORKFLOW-MANUAL-v1.md    ← 버전업 전 백업
│   └── HARNESS-PROTOCOL-v1.md
├── prompts/                     ← prompts/ 파일 아카이빙
├── scripts/                     ← scripts/ 파일 아카이빙 (필요 시)
└── snapshots/                   ← 시점 단위 전체 스냅샷 (기존 방식 유지)
    └── harness-refactor-20260514/
```

### 파일명 규칙

| 대상 | 규칙 | 예시 |
|------|------|------|
| 버전 문서 백업 | `{원본명}-v{N}.{ext}` | `WORKFLOW-MANUAL-v1.md` |
| 날짜 기반 백업 | `{원본명}-{YYYYMMDD}.{ext}` | `claude-session-start-20260501.md` |
| 완료된 Work 파일 | 원본 파일명 유지 (경로만 변경) | `HRF-002-work-system-refactor.md` |
| 스냅샷 디렉토리 | `{topic}-{YYYYMMDD}/` | `harness-refactor-20260514/` |

### 아카이빙 경로 규칙

- **경로 미러링**: `docs/archive/{원본-상대경로}/{파일명}`
  - 예: `docs/WORKFLOW-MANUAL.md` v1 백업 → `docs/archive/docs/WORKFLOW-MANUAL-v1.md`
  - 예: `prompts/claude-session-start.md` 백업 → `docs/archive/prompts/claude-session-start-20260501.md`
- **Work 파일 완료**: `docs/works/harness/HRF-002-*.md` → `docs/archive/docs/works/harness/HRF-002-*.md`
- **대상 범위**: 프로젝트 루트 하위 어느 파일이든 아카이빙 가능. `docs/` 한정 아님.

### 아카이빙 트리거

| 상황 | 동작 |
|------|------|
| Work 파일 Done | `docs/works/` → `docs/archive/docs/works/` 로 이동 |
| 문서 버전업 | 구 버전을 `-v{N}` 접미사로 백업 후 원본 수정 |
| Product track work 완료/마일스톤 | `docs/works/product/` → `docs/archive/docs/works/product/` 이동 (DR-031) |
| 대규모 리팩토링 | `snapshots/` 하위에 디렉토리 단위 스냅샷 |

### 기존 스냅샷 처리

`docs/archive/harness-refactor-20260514/` 등 기존 방식의 스냅샷은 현행 유지한다.
신규 아카이빙은 경로 미러링 방식을 따른다.

## Options Considered

| 선택지 | 장점 | 단점 |
|--------|------|------|
| 경로 미러링 (채택) | 원본 위치 추적 직관적, grep으로 아카이브 탐색 가능 | 경로가 다소 깊어짐 |
| 카테고리 기반 플랫 구조 | 단순 | 동일 이름 파일 충돌, 원본 위치 추적 어려움 |
| 날짜 디렉토리 | 시점별 정리 용이 | 특정 파일의 이력 추적 어려움 |

## Rationale

경로 미러링은 "이 파일의 이전 버전이 archive에 있는가?"를 경로만으로 직관적으로 파악할 수 있게 한다. `docs/archive/docs/WORKFLOW-MANUAL-v1.md` 를 보면 원본이 `docs/WORKFLOW-MANUAL.md` 임을 즉시 알 수 있다. Work 파일은 완료 후 이동이므로 파일명을 유지하고 경로만 바꾸면 git mv로 이력이 추적된다.

## Consequences

- `docs/archive/` 하위 구조가 프로젝트 디렉토리 구조를 반영한다.
- 기존 스냅샷(`harness-refactor-20260514/` 등)은 `snapshots/` 하위로 이동하여 정리한다.
- harness 프로토콜 문서(`docs/HARNESS-PROTOCOL.md`)에 아카이빙 트리거 반영 필요.
- Work 파일 완료 절차에 archive 이동 단계가 포함된다.

## Reversal Cost

Low — 파일 이동이므로 git mv로 추적되며 복원 가능하다.

## Linked Backlog Items

- HRF-002 (Active)
