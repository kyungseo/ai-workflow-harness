# DR-006: CI job 분리 구조 및 Gradle 공식 캐시 액션 채택

Date: 2026-05-12
Status: Accepted

## Question

GitHub Actions CI 파이프라인을 어떤 구조로 설계하고, Gradle 의존성 캐싱을 어떻게 처리할 것인가?

## Decision

단일 `ci.yml`에 job을 분리하여 정의한다 (`lint` → `test`).
향후 확장 포인트(build, docker, deploy, security-scan)를 주석으로 명시한다.
Gradle 캐싱은 `gradle/actions/setup-gradle@v3`로 처리한다.

## Options Considered

| 선택지 | 장점 | 단점 |
|--------|------|------|
| 단일 `ci.yml` + job 분리 (채택) | 점진적 확장, job 단위 독립 실행/스킵 가능 | 파일 하나에 모든 stage 집중 |
| 워크플로우 파일 분리 (`lint.yml`, `test.yml`...) | 각 파일 독립 관리 | 파일 수 증가, job 의존성 관리 분산 |
| 단일 step으로 모든 작업 | 설정 단순 | lint 실패 시 test도 실행, 피드백 느림 |
| Reusable workflows (`workflow_call`) | 재사용성 최대 | 현 단계에서 오버엔지니어링 |

**Gradle 캐싱:**

| 선택지 | 장점 | 단점 |
|--------|------|------|
| `gradle/actions/setup-gradle@v3` (채택) | Gradle 공식 지원, wrapper + dependency + build cache 자동 | 버전 pinning 필요 |
| `actions/cache` 수동 설정 | 세밀한 제어 | 캐시 키 관리 복잡, Gradle 특수 경로 수동 지정 필요 |
| 캐시 없음 | 설정 불필요 | CI 실행 시마다 의존성 재다운로드 (멀티모듈 프로젝트에서 수분 소요) |

## Rationale

- `needs:` 체인으로 job을 연결하면 lint 실패 시 test가 스킵되어 리소스를 절약한다.
- 확장 포인트 주석(build → docker → deploy-staging → deploy-prod, security-scan)을 미리 명시하면 팀이 위치를 알고 점진적으로 확장할 수 있다.
- `gradle/actions/setup-gradle@v3`는 Gradle 8.x와 공식 호환되며 수동 cache key 관리 불필요.
- 단일 파일 구조는 현재 단계(lint + test만)에서는 충분하며 오버엔지니어링을 피한다.

## Consequences

- `.github/workflows/ci.yml`: PR + main/develop push 트리거, lint → test 2-job 구조
- test 실패 시 테스트 리포트를 artifact로 자동 업로드 (7일 보존)
- CI 확장 순서: `build` → `docker` → `deploy-staging` → `deploy-prod` (GitHub Environment + 수동 승인)
- `security-scan` (OWASP Dependency-Check)은 독립 job으로 추가 가능

## Reversal Cost

Low — `ci.yml` 수정 또는 삭제만으로 롤백 가능. 코드 변경 없음.

## Linked Backlog Items

- PRE-A2+A3 (통합 완료)
- CP-P2-3: infrastructure 방향 결정 (K8s 배포 job 추가 시 연계)
- OQ-002: K8s 배포 도구 결정 (deploy job 구체화 전 필요)
