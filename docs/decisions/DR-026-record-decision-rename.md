# DR-026: `/repo-decision` → `/record-decision` Rename

Date: 2026-06-07
Status: Accepted
Track: harness
Supersedes:

## Question

`/repo-decision` 이라는 명령 이름이 product decision 기록을 막는 인지 장벽이 되고 있는가? 개명이 필요한가?

## Decision

`/repo-decision`을 `/record-decision`으로 개명한다. 원래 이름(`record-decision`)으로 복원이며, 이번에 no-alias 정책 유지(alias 없이 clean cut).

## Options Considered

| 선택지 | 장점 | 단점 |
|--------|------|------|
| `/record-decision` (복원) | 중립적 동사형. product/harness 양쪽 포괄. 원래 이름. | cascade Medium — 11개 live 파일 수정 필요 |
| `/repo-decision` (유지) | 변경 없음 | "repo" = source repo/harness 전용으로 오해. product decision 누락 구조적 위험 |
| `/log-decision` | 중립적 | 수동적 뉘앙스. record보다 약함 |

## Rationale

`repo`는 "repository에 관한 결정" 즉 harness/workflow 결정으로 협소하게 읽힌다. product repo에서 ORM 선택, API 설계 방향, 외부 서비스 연동 같은 결정을 기록하려는 사람이 `/repo-decision`을 보고 "이건 내 제품 결정인데 왜 repo decision이지?"라고 건너뛸 수 있다.

원래 이름 `record-decision`은 동사형으로 track-agnostic하다. `bc5ace9`(CHORE-20260606-001)에서 `repo-health`와 prefix 통일을 위해 개명됐으나, 그 통일의 이득보다 coverage 오해의 손실이 더 크다.

## Consequences

- `/record-decision`으로 product/harness 양쪽 decision 명시적 포괄
- skills/workflow/, .claude/commands/, .agents/skills/, 문서 11개 cascade 수정 (CHORE-20260607-006)
- alias 없음 — 이전 `/repo-decision` 호출은 작동하지 않음 (no-alias 정책 유지)
- `repo-health`는 이름 유지 — 해당 명령은 repo 자체 상태 점검이 맞아 ambiguity 없음

## Reversal Cost

Medium — rename revert 시 동일 cascade 재수행 필요.

## Linked Backlog Items

- HARNESS.md: "Decision workflow product coverage + DR lifecycle 정리" (P1 Candidate) → CHORE-20260607-006
