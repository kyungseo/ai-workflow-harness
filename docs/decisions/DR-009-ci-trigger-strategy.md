# DR-009: CI trigger 분리 전략 — develop push = Checkstyle only, PR to main = 전체 테스트

Date: 2026-05-12
Status: Accepted
Superseded by: DR-018 (부분 — develop push Checkstyle trigger 제거)

## Question

develop 브랜치에 push할 때마다 통합 테스트(PostgreSQL/Redis 기동 포함)를 실행해야 하는가?
아니면 main으로 들어가는 PR에서만 전체 테스트를 실행해도 충분한가?

## Decision

- `push to develop`: Checkstyle(lint)만 실행 (~30초)
- `pull_request to main` 및 `push to main`: Checkstyle + 전체 테스트 실행

```yaml
on:
  pull_request:
    branches: [main]
  push:
    branches: [main, develop]

jobs:
  test:
    if: github.event_name == 'pull_request' || github.ref == 'refs/heads/main'
```

## Options Considered

| 선택지 | 장점 | 단점 |
|--------|------|------|
| 모든 push에서 전체 테스트 실행 | 즉각적인 피드백 | develop push마다 3~5분 대기, 개발 흐름 방해 |
| develop push = Checkstyle, PR to main = 전체 테스트 (채택) | 개발 속도 유지, main 진입 전 검증 보장 | develop에서 테스트 실패를 늦게 발견할 수 있음 |
| PR에서만 전체 테스트 실행, push는 생략 | 가장 빠름 | push to main(머지)에서 미검증 상태 가능 |

## Rationale

- develop push는 로컬에서 이미 테스트를 통과한 코드가 올라오는 경우가 대부분이다.
- 통합 테스트는 PostgreSQL/Redis 서비스 컨테이너 기동과 `@SpringBootTest` 컨텍스트 로딩으로 3~5분 소요된다.
- main 진입 전(PR) 한 번의 전체 검증으로 품질을 보장하는 것이 비용 대비 효과적이다.
- push to main(머지 커밋)에서도 테스트를 실행해 직접 push 케이스를 커버한다.

## Consequences

- develop push 피드백 시간: 3~5분 → ~30초
- main으로 들어가는 PR에서 반드시 전체 테스트 통과 필요
- develop에서 통합 테스트 실패를 PR 단계에서 발견하게 됨

## Reversal Cost

Low — `ci.yml` trigger 조건 수정만으로 롤백 가능. 코드 변경 없음.

## Linked Items

- DR-006: CI job 분리 구조 (기반 구조 — 이 DR이 trigger 전략을 추가 결정)
- DR-010: 통합 테스트 인프라 전략 (테스트 실행 환경 관련)
- P2-006: Testcontainers 도입
