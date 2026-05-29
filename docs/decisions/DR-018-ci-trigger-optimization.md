# DR-018: CI 트리거 최적화 — Docs/Scaffold Path Filter, develop Push 제거

Date: 2026-05-20
Status: Accepted
Updated: 2026-05-29 (AWH-001 public migration 이후 Java/Gradle runtime 제거 → Docs and Scaffold Validation 전용 CI로 재설계. 현행화)
Supersedes:
- DR-006 (부분 — CI job 실행 조건 및 트리거 범위)
- DR-009 (부분 — develop push trigger 제거)

## Question

GitHub Actions CI 트리거 범위와 job 실행 구조를 어떻게 최적화하여 무관한 변경에서 CI를 스킵하고 docs/scaffold 검증 범위를 명확히 할 것인가?

## Decision

1. **Path filter 추가**: docs, prompts, tool surface, scaffold, root entrypoint 변경 시에만 CI 실행. 무관한 변경은 CI 스킵.
2. **develop push 트리거 제거**: develop push 시 CI 미실행. PR 이벤트와 main push에서만 CI 실행.
3. **단일 Docs and Scaffold Validation job**: git diff-tree whitespace check, shell syntax check, scaffold dry-run, source-only phrase 검사, broken artifact reference 검사, stale runtime identity 검사를 단일 job에서 순차 실행.

**Path filter 대상:** `docs/**`, `prompts/**`, `.claude/**`, `.cursor/**`, `scripts/**`, `tools/git-hooks/**`, `.github/workflows/**`, `AGENTS.md`, `CLAUDE.md`, `README.md`

**트리거:**

| 이벤트 | 브랜치 | 조건 |
|--------|--------|------|
| `push` | `main` | path filter 매칭 |
| `pull_request` | `main`, `develop` | path filter 매칭 |

## Options Considered

| 선택지 | 장점 | 단점 |
|--------|------|------|
| Path filter + PR/main push 한정 + develop push 제거 (채택) | 무관 변경 CI 스킵, 명확한 검증 범위, develop 중복 제거 | path filter 비대상 변경은 CI 미실행 |
| 모든 push와 PR에 CI | 완전 커버 | docs 무관 변경에도 매번 CI 실행 |
| CI 없음 | 설정 불필요 | 검증 자동화 없음 |

## Rationale

docs, prompts, tool surface, scaffold, entrypoint 변경이 전체 커밋의 대부분을 차지한다. 이 경로에서만 CI를 실행하면 무관한 변경(메모, 외부 설정 등)에서 CI를 스킵할 수 있다.

application runtime이 없으므로 lint/test job이 불필요하다. 단일 validation job으로 scaffold 및 docs 정합성 검사를 충분히 수행할 수 있다.

develop push CI는 develop→main PR에서 동일하게 실행되므로 중복이다.

## Consequences

- `.github/workflows/ci.yml` — path filter 추가, push trigger는 main만, PR trigger는 main/develop
- feature→develop PR에서도 path filter 대상 변경이 있으면 CI 실행됨
- develop push 시 CI 미실행 — PR과 main push에서 검증 수행
- 단일 validation job으로 git whitespace, shell syntax, scaffold dry-run, phrase/artifact/identity 검사 수행
- `docs/GIT-WORKFLOW.md` §4 CI Trigger 섹션 반영 완료

## Reversal Cost

Low — `ci.yml` 수정만으로 롤백 가능. 코드 변경 없음.

## Linked Backlog Items

- DR-006: CI job 분리 구조 및 Gradle 공식 캐시 액션 채택 (부분 Supersedes — Java CI 시절 결정)
- DR-009: CI trigger 분리 전략 (develop push trigger 제거 — Java Checkstyle 시절 결정)
- HRN-FUT-005: GitHub Branch protection rule 설정 (CI 미통과 시 develop merge 차단 — 향후 연계)
