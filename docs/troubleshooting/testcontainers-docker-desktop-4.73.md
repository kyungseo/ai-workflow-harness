# Testcontainers — Docker Desktop 4.73.0+ 연결 실패

Date: 2026-05-15
Environment: macOS, Docker Desktop 4.73.0 (Docker Engine 29.4.3, API 1.54)
Related: DR-010, P2-006

---

## 증상

`./gradlew test` 실행 시 통합 테스트가 다음 오류로 실패한다.

```
org.testcontainers.containers.ContainerFetchException: Can't get Docker image
  Caused by: java.lang.IllegalStateException: Could not find a valid Docker environment.
  Attempted configurations were:
    EnvironmentAndSystemPropertyClientProviderStrategy: failed with exception
      BadRequestException (Status 400: {"message":"client version 1.32 is too old.
      Minimum supported API version is 1.40, please upgrade your client..."})
    UnixSocketClientProviderStrategy: failed with exception BadRequestException (Status 400: ...)
    DockerDesktopClientProviderStrategy: failed with exception BadRequestException (Status 400: ...)
```

`docker info` 및 `docker run` 명령은 정상 동작한다.

---

## 원인

Docker Desktop 4.73.0은 최소 지원 API 버전을 **1.40**으로 상향했다.

Testcontainers 1.21.0이 내장하는 shaded docker-java(`org.testcontainers.shaded.com.github.dockerjava`)는
기본 API 버전으로 **1.32**를 사용한다. Docker Desktop은 이 버전 요청에 HTTP 400을 반환한다.

추가로 Testcontainers의 리소스 정리 데몬인 Ryuk가 기동 시 Docker socket을 컨테이너 내부에
bind mount하는데, `docker.raw.sock` 경로는 Docker Desktop 4.73.0에서 bind mount가 차단된다.

```
InternalServerErrorException: Status 500:
  {"message":"error while creating mount source path
   '/Users/.../docker.raw.sock': mkdir ... operation not supported"}
```

`/var/run/docker.sock`(Docker Desktop이 제공하는 symlink)은 bind mount가 정상 동작한다.

---

## 조치

두 파일을 생성 또는 수정한다. 이 파일들은 사용자별 로컬 설정이며 git 추적 대상이 아니다.

### 1. `~/.docker-java.properties` (없으면 신규 생성)

```properties
api.version=1.41
```

shaded docker-java가 이 파일을 읽어 API 버전을 재정의한다.

### 2. `~/.testcontainers.properties` (없으면 신규 생성, 있으면 항목 추가)

```properties
docker.host=unix:///var/run/docker.sock
docker.api.version=1.41
testcontainers.ryuk.disabled=true
```

| 항목 | 이유 |
| --- | --- |
| `docker.host` | Testcontainers가 연결할 Docker socket 경로 명시 |
| `docker.api.version` | Testcontainers 자체 설정에서도 API 버전 고정 |
| `testcontainers.ryuk.disabled` | Ryuk bind mount 오류 우회. 컨테이너 자동 정리가 비활성화되지만 테스트 종료 시 JVM shutdown hook이 정리를 처리한다 |

---

## 검증

```bash
./gradlew test
```

전체 테스트가 통과하면 조치 완료.

---

## 관련 문서

- [docs/DEVELOPER-GUIDE.md §4-3](../DEVELOPER-GUIDE.md) — 통합 테스트 패턴 및 로컬 설정 전체 절차
- [docs/decisions/DR-010-integration-test-infra.md](../decisions/DR-010-integration-test-infra.md) — Testcontainers 채택 결정
