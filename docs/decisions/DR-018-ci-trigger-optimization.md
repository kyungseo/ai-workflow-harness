# DR-018: CI 트리거 최적화 — Path Filter, 병렬화, develop Push 제거

Date: 2026-05-20
Status: Accepted
Supersedes: DR-006 (부분 — CI job 실행 조건 및 트리거 범위)

## Question

GitHub Actions CI 트리거 범위와 job 실행 구조를 어떻게 최적화하여 불필요한 CI 실행 시간을 줄일 것인가?

## Decision

1. **Path filter 추가**: Java/Gradle/`.github` 파일 변경 시에만 CI 실행. docs, `.claude` 등 무관 변경은 CI 스킵.
2. **lint/test 병렬화**: `needs: lint` 제거 → lint와 test 동시 실행. 전체 시간 = max(lint, test).
3. **develop push 트리거 제거**: develop push 시 CI 불실행. feature 변경 검증은 develop→main PR 단계에서만 수행.

## Options Considered

| 선택지 | 장점 | 단점 |
|--------|------|------|
| Path filter + 병렬화 + develop 트리거 제거 (채택) | 무관 변경 CI 스킵, 총 시간 단축, develop 중복 제거 | feature→develop PR에서 CI 미실행 |
| Path filter만 적용 | 구조 변경 최소 | lint→test 순차 실행 유지 |
| 현행 유지 | 변경 없음 | 문서·설정 변경에도 매번 5~12분 소요 |

**Path filter 대상:** `**/*.java`, `**/build.gradle*`, `**/settings.gradle*`, `**/gradle.properties`, `gradle/**`, `.github/workflows/**`

## Rationale

docs, `.claude`, memory 등 Java/Gradle 무관 변경이 전체 커밋의 상당 비율을 차지하며, 이 경우 CI가 실행되어도 검증 가치가 없다. Path filter로 이를 스킵하면 가장 큰 시간 절감 효과를 얻는다.

lint와 test는 의존 관계가 없으므로 병렬 실행이 가능하다. 기존 `needs: lint`는 lint 실패 시 test 스킵을 위한 것이었으나, 두 job 모두 실패 리포트를 독립적으로 확인하는 것이 더 유용하다.

develop push CI는 develop→main PR에서 동일하게 실행되므로 중복이다.

## Consequences

- `.github/workflows/ci.yml` — path filter 추가, `needs: lint` 제거, push trigger에서 `develop` 제거
- feature→develop PR에서는 CI 미실행 → 검증 책임이 develop→main PR로 집중
- lint 실패와 test 실패를 동시에 확인 가능 (병렬화 효과)
- `docs/GIT-WORKFLOW.md` §4 CI Trigger 섹션 업데이트 반영

## Reversal Cost

Low — `ci.yml` 수정만으로 롤백 가능. 코드 변경 없음.

## Linked Backlog Items

- DR-006: CI job 분리 구조 및 Gradle 공식 캐시 액션 채택 (부분 Supersedes)
- HRN-FUT-005: GitHub Branch protection rule 설정 (CI 미통과 시 merge 차단 — 향후 연계)
