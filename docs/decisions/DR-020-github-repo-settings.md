# DR-020: GitHub Repository Settings Policy

Date: 2026-05-25
Status: Accepted (일부 항목 Deferred)

## Question

Public 전환 시점에 GitHub repository의 ruleset, 보안 설정, 기능 옵션을 어떻게 구성할 것인가? 그리고 어떤 항목은 아직 결정을 보류하는가?

## Decision

### Rulesets (2026-05-25 활성화)

| Ruleset | Enforcement | Rules | Bypass |
|---------|-------------|-------|--------|
| `protect-main` | active | deletion, non_fast_forward, pull_request (approval 0), required_status_checks (validate, strict) | RepositoryRole Admin — always |
| `protect-develop` | active | deletion, non_fast_forward, pull_request (approval 0) | RepositoryRole Admin — always |

- feature 브랜치에서 develop 또는 main으로 직접 push 불가. PR 경유 필수.
- Admin(repo owner)은 긴급 상황에 bypass 가능.
- `protect-develop`에는 status check 미포함 — develop 단계 CI 검증은 현재 선택적.
- 2026-06-06 확인: GitHub `required_status_checks.context`는 workflow job id가 아니라 보고되는 check-run name과 매칭된다. source repo는 `protect-main`의 required check `validate`와 맞추기 위해 `.github/workflows/ci.yml`의 `validate` job에 job-level `name:`을 두지 않는다. source-gitflow scaffold target의 harness-owned required check convention은 `harness-validate`다.
- 2026-06-06 확인: required check로 연결된 workflow에 path filter가 있으면 filter 미일치 PR에서 check가 실행되지 않아 `Expected`/pending 상태로 남을 수 있다. source `.github/workflows/ci.yml`의 `validate`와 source-gitflow target `.github/workflows/harness-validate.yml`은 workflow-level path filter를 두지 않고 항상 실행되도록 한다. Target ruleset은 `protect-main`에만 required check context `harness-validate`를 연결하며, `protect-develop`에는 required status check를 연결하지 않는다.

### 보안 설정 (2026-05-25 활성화)

| 항목 | 상태 |
|------|------|
| Secret scanning | enabled |
| Secret scanning push protection | enabled |
| Vulnerability alerts (Dependabot) | enabled |
| Dependabot automated security fixes | disabled (수동 검토 유지) |

### 기능 및 동작 설정 (2026-05-25 적용)

| 항목 | 값 |
|------|----|
| `delete_branch_on_merge` | true — PR merge 후 원격 브랜치 자동 삭제 |
| `allow_update_branch` | true — PR에서 "Update branch" 버튼 활성화 |
| `has_discussions` | true — public 커뮤니티 피드백 채널 |

### Deferred (미결정)

| 항목 | 현재 상태 | 결정 필요 이유 |
|------|-----------|----------------|
| `sha_pinning_required` | false | 현재 Actions 의존도가 낮아 솔로 운영 기준 과잉. CI action 목록이 늘어날 때 재검토 |

### Resolved (결정 완료)

| 항목 | 결정 | 결정일 | 근거 |
|------|------|--------|------|
| Merge 방식 제한 | ruleset 차단 미적용. DR-017 운영 정책 준수 (Regular merge 기본, Squash 선택적, rebase 비권장) | 2026-05-29 | rebase 차단 시 관리 복잡도 증가 대비 실익이 적음. solo 운영 환경에서 DR-017 운영 정책으로 충분히 제어 가능 |

## Options Considered

### Rulesets

| 선택지 | 장점 | 단점 |
|--------|------|------|
| 두 브랜치 모두 active (채택) | 즉시 보호, PR 흐름 강제 | Admin bypass 없으면 긴급 상황 대응 불가 |
| main만 active | 설정 단순 | develop 직접 push 허용 → 오염 위험 |
| disabled 유지 | 제약 없음 | public repo 신뢰성 저하 |

### Merge 방식 (미결)

| 선택지 | 장점 | 단점 |
|--------|------|------|
| 3개 모두 허용 (현재) | 유연성 최대 | DR-017 방침 외 rebase 사용 가능 |
| merge + squash만 | DR-017 방침 반영 | 기존 rebase 습관 있으면 불편 |
| squash only | 히스토리 일관성 최대 | 개별 커밋 맥락 손실 (DR-017 반대) |

## Rationale

Public 전환 직후 ruleset이 disabled 상태였고 보안 기능도 꺼져 있었다.
Public repo에서 직접 push 허용은 clone 사용자에게 잘못된 workflow 신호를 줄 수 있어 즉시 활성화했다.
Dependabot auto-fix는 PR 생성 자동화가 오히려 노이즈가 될 수 있어 수동 검토 유지.
Merge 방식은 DR-017과의 정합성 검토가 필요해 deferred로 분류했다.

## Consequences

- develop에 직접 push 시도 시 GitHub에서 거절됨 (Admin은 bypass 가능).
- feature 브랜치는 PR을 통해서만 develop에 병합 가능.
- PR merge 후 원격 feature 브랜치 자동 삭제.
- 시크릿이 포함된 커밋은 push 시점에 차단됨.
- Merge 방식 제한: ruleset 차단 없음. DR-017 운영 정책 (Regular merge 기본, Squash 선택적, rebase 비권장)으로 준수.

## Reversal Cost

Low — `gh api --method PUT repos/.../rulesets/{id}` 한 번으로 설정 복구 가능.
보안 설정도 API 또는 GitHub UI에서 즉시 되돌릴 수 있음.

## Linked Backlog Items

- HRN-036: Public Release Clean Baseline Gate (이 DR의 설정 완료가 HRN-036 Discovery에 기록됨)
- DR-017: Git 머지 전략 (Merge 방식 제한 결정 시 DR-017과 정합성 확인 필요)
