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

## 초기 조치 기록

당시에는 아래 두 사용자별 로컬 설정 파일을 생성 또는 수정하여 해결했다.
이 파일들은 git 추적 대상이 아니다.
아래 이유는 당시 판단이며, 2026-05-17 재검증 정정 사항은 addendum을 따른다.

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

| 항목 | 당시 판단 |
| --- | --- |
| `docker.host` | Testcontainers가 연결할 Docker socket 경로 명시 |
| `docker.api.version` | Testcontainers 자체 설정에서도 API 버전 고정 |
| `testcontainers.ryuk.disabled` | Ryuk bind mount 오류 우회. 컨테이너 자동 정리가 비활성화되지만 테스트 종료 시 JVM shutdown hook이 정리를 처리한다 |

---

## Addendum: 2026-05-17 재검증

전역 홈 설정 파일 생성은 동작하는 우회였지만 필수 조치는 아니었다.
같은 문제는 실행 단위 환경변수와 JVM option으로 좁혀서 해결할 수 있다.

```bash
JAVA_TOOL_OPTIONS="-Dapi.version=1.41" \
DOCKER_HOST=unix:///var/run/docker.sock \
TESTCONTAINERS_DOCKER_SOCKET_OVERRIDE=/var/run/docker.sock \
./gradlew test
```

검증 시에는 전역 홈 설정 파일을 회피하기 위해 빈 임시 home을 지정하고, 위 설정을
per-command로만 부여했다.

```bash
JAVA_TOOL_OPTIONS="-Duser.home=/private/tmp/tc-home-empty -Dapi.version=1.41" \
DOCKER_HOST=unix:///var/run/docker.sock \
TESTCONTAINERS_DOCKER_SOCKET_OVERRIDE=/var/run/docker.sock \
TESTCONTAINERS_RYUK_DISABLED=false \
./gradlew --no-daemon test --rerun-tasks
```

결과: 전체 테스트 통과.

정정 사항:

- `~/.docker-java.properties`의 `api.version=1.41`은 shaded docker-java API version mismatch를 우회하는 데 유효하다.
- `~/.testcontainers.properties`의 `docker.host=unix:///var/run/docker.sock`은 Docker socket 경로를 명시하는 데 유효하다.
- `docker.api.version=1.41`은 Testcontainers Java 1.21.0 소스에서 직접 확인되는 핵심 설정이 아니었다.
- `testcontainers.ryuk.disabled=true`는 Testcontainers Java 1.21.0에서 Ryuk disable 설정으로 읽히지 않는다. 실제 disable은 `TESTCONTAINERS_RYUK_DISABLED` 환경변수를 통해 동작한다.
- 재검증에서는 `TESTCONTAINERS_RYUK_DISABLED=false`로도 통과했으므로 Ryuk disable은 필수 조치가 아니었다.

권장 순서:

1. 먼저 실행 단위 설정(Gradle command, IDE run configuration, CI env)으로 범위를 좁힌다.
2. 반복 실행 편의가 필요할 때만 사용자 home 설정 파일을 선택적으로 사용한다.
3. Ryuk 오류는 disable보다 `TESTCONTAINERS_DOCKER_SOCKET_OVERRIDE=/var/run/docker.sock` 우선으로 대응한다.

후속 변경 완료 (2026-05-17):

- `build.gradle.kts` `tasks.withType<Test>` 블록에 `-Dapi.version=1.41`, `DOCKER_HOST`, `TESTCONTAINERS_DOCKER_SOCKET_OVERRIDE` 추가 — 개발자별 홈 설정 파일 불필요
- P2-006 당시 생성한 `~/.docker-java.properties`, `~/.testcontainers.properties` 삭제 확인
- `docs/DEVELOPER-GUIDE.md` §4-3, `README.md` Testing 섹션: 별도 로컬 설정 불필요로 현행화
- `./gradlew test` 전체 통과 검증 완료

---

## 검증

```bash
./gradlew test
```

전체 테스트가 통과하면 조치 완료.
Docker Desktop 4.73.0+에서 실패하면 먼저 addendum의 실행 단위 설정으로 재검증한다.

---

## 관련 문서

- [docs/DEVELOPER-GUIDE.md §4-3](../DEVELOPER-GUIDE.md) — 통합 테스트 패턴 및 로컬 설정 전체 절차
- [docs/decisions/DR-010-integration-test-infra.md](../decisions/DR-010-integration-test-infra.md) — Testcontainers 채택 결정
