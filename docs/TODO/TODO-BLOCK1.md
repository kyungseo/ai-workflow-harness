# BLOCK 1 — 프로젝트 골격

> 선행 조건: 없음 (최초 시작 블록)
> 목적: 이후 모든 작업의 기반 구조 확립
> 주의: schema.sql / data.sql은 이 단계에서 **빈 파일만** 생성. 내용 확정은 BLOCK 3.

---

## 1-1. Gradle 멀티모듈 초기화

- [x] 루트 `build.gradle.kts` 작성 (공통 플러그인, Java 21, Kotlin DSL)
- [x] `gradle/libs.versions.toml` 작성 (전체 의존성 버전 중앙 관리)
  - Spring Boot 3.5.x, Spring Cloud, JJWT 0.12.x, MyBatis 3.x, springdoc 2.x, **Lombok 1.18.x**, **MapStruct 1.6.x**, **Caffeine 3.x** 등
- [x] 각 모듈 `build.gradle.kts` 생성 시 annotation processor 순서 준수
  ```kotlin
  // build.gradle.kts (서비스 공통)
  // Lombok → MapStruct 순서 필수. 순서 바뀌면 컴파일 오류 발생
  annotationProcessor(libs.lombok)
  annotationProcessor(libs.mapstruct.processor)
  ```
- [x] `settings.gradle.kts` 작성 (전체 모듈 선언)
  ```
  include("common:common-core")
  include("gateway:api-gateway")
  include("services:auth-service")
  include("services:user-service")
  include("services:todo-service")
  ```
- [x] 각 모듈 `build.gradle.kts` 생성 (의존성은 버전 카탈로그 참조)
  - `common/common-core/build.gradle.kts`
  - `gateway/api-gateway/build.gradle.kts`
  - `services/auth-service/build.gradle.kts`
  - `services/user-service/build.gradle.kts`
  - `services/todo-service/build.gradle.kts`
- [x] Gradle Wrapper 설정 (`gradlew`, `gradlew.bat`, `gradle/wrapper/gradle-wrapper.properties`)
- [x] 루트 `.gitignore` 작성 (`.env`, `build/`, `.gradle/`, `*.class`, `*.jar` 등)

---

## 1-2. 환경변수 및 설정 파일 뼈대

- [x] `.env.example` 작성 (전체 필요 환경변수 목록, 값 없음 — 온보딩 가이드 역할)
  ```
  SPRING_PROFILES_ACTIVE=local
  JWT_SECRET=
  JWT_ACCESS_EXPIRY=900
  JWT_REFRESH_EXPIRY=604800
  DB_URL=jdbc:postgresql://localhost:5432/msa_db
  DB_USERNAME=
  DB_PASSWORD=
  DB_NAME=msa_db
  REDIS_HOST=localhost
  REDIS_PORT=6379
  ALLOWED_ORIGINS=http://localhost:3000
  BLACKLIST_FAIL_POLICY=fail-close
  AUTH_SERVICE_URL=http://localhost:8091
  USER_SERVICE_URL=http://localhost:8092
  TODO_SERVICE_URL=http://localhost:8093
  ```
- [x] 각 서비스 `application.yml` 뼈대 작성 (환경변수 바인딩)
  - 민감 항목(`JWT_SECRET`, `DB_PASSWORD` 등) 기본값 없이 선언 (기본값 절대 금지)
  - Virtual Threads 활성화: `spring.threads.virtual.enabled=true`
  - HikariCP 설정: `maximum-pool-size`, `minimum-idle`, `connection-timeout` 환경변수 바인딩
  - Actuator management port 8099 분리
  - Graceful Shutdown 설정 (`server.shutdown: graceful`, timeout 30s)
- [x] 각 서비스 `application-local.yml` (PostgreSQL localhost, DEBUG 로그, 콘솔 패턴, Swagger 활성)
- [x] 각 서비스 `application-dev.yml` (DevContainer 환경, DEBUG 로그, 콘솔 패턴, Swagger 활성)
- [x] 각 서비스 `application-stg.yml` (외부 DB, INFO 로그, JSON 구조화, Swagger 비활성)
- [x] 각 서비스 `application-prd.yml` (외부 DB, WARN 로그, JSON 구조화, Swagger 비활성)

---

## 1-3. Docker Compose 인프라

- [x] `infra/docker/docker-compose.yml` 작성
  - PostgreSQL 16-alpine
    - healthcheck: `pg_isready`
    - `./init-sql:/docker-entrypoint-initdb.d` 마운트
    - named volume: `postgres_data`
  - Redis **`redis:7-alpine`** (버전 명시 필수 — `latest` 사용 금지, 빌드 재현성 보장)
    - healthcheck: `redis-cli ping`
  - 각 서비스 컨테이너 (depends_on: postgres/redis `service_healthy`)
  - `.env` 파일 참조 (`env_file: ../../.env`)
- [x] `.devcontainer/docker-compose.devcontainer.yml` 작성
  - PostgreSQL + Redis만 기동 (서비스는 VS Code에서 직접 실행)
- [x] `infra/docker/init-sql/schema.sql` 생성 (빈 파일 — BLOCK 3에서 작성)
- [x] `infra/docker/init-sql/data.sql` 생성 (빈 파일 — BLOCK 3에서 작성)

---

## 1-4. DevContainer 설정

- [x] `.devcontainer/devcontainer.json` 작성
  - Base image: `mcr.microsoft.com/devcontainers/java:1-21-bookworm`
  - Features: `ghcr.io/devcontainers/features/docker-in-docker`, `ghcr.io/devcontainers/features/github-cli`
  - `dockerComposeFile`: `docker-compose.devcontainer.yml`
  - `service`: 애플리케이션 컨테이너 (Java 환경)
  - VS Code extensions:
    - `vscjava.vscode-java-pack` (Java Extension Pack)
    - `vmware.vscode-spring-boot` (Spring Boot Dashboard)
    - `humao.rest-client` (REST Client)
    - `eamodio.gitlens` (GitLens)
    - `gradle.vscode-gradle`
  - `postCreateCommand`: `./gradlew build -x test`
  - `forwardPorts`: [8090, 8091, 8092, 8093, 5432, 6379]

---

## 1-5. 빈 디렉토리 구조 생성

> Phase 2 대비 구조만 생성. `.gitkeep` 파일로 Git 추적.

- [x] `infra/k8s/base/gateway/.gitkeep`
- [x] `infra/k8s/base/auth-service/.gitkeep`
- [x] `infra/k8s/base/user-service/.gitkeep`
- [x] `infra/k8s/base/todo-service/.gitkeep`
- [x] `infra/k8s/overlays/dev/.gitkeep`
- [x] `infra/k8s/overlays/stg/.gitkeep`
- [x] `infra/k8s/overlays/prd/.gitkeep`
- [x] `infra/prometheus/.gitkeep`
- [x] `infra/grafana/.gitkeep`
- [x] `tests/http/.gitkeep`

---

## 1-6. 자동화 스크립트

- [x] `scripts/Makefile` 작성
  ```makefile
  make build           # 전체 Gradle 빌드
  make run             # 전체 Docker Compose 스택 기동
  make run-local       # 로컬 직접 실행 (SPRING_PROFILES_ACTIVE=local)
  make test            # 전체 테스트 실행
  make clean           # 빌드 산출물 정리
  make logs            # Docker Compose 로그 확인
  make ps              # 실행 중인 컨테이너 상태 확인
  make create-service  # 새 서비스 스캐폴딩
  ```
- [x] `scripts/create-service.sh` 작성
  - 서비스명 입력 프롬프트
  - `services/{name}/src/main/java/io/kyungseo/msa/{name}/` 패키지 구조 생성
  - `build.gradle.kts`, `application.yml`, `Dockerfile` 템플릿 복사
  - `settings.gradle.kts` 자동 등록 (중복 체크 필수 — 스크립트 재실행 시 중복 등록 방지)
  ```bash
  # 중복 방지: grep으로 존재 확인 후 추가
  if ! grep -q "include(\"services:${SERVICE_NAME}\")" settings.gradle.kts; then
    echo "include(\"services:${SERVICE_NAME}\")" >> settings.gradle.kts
  fi
  ```

---

## 완료 조건

- [x] `./gradlew build -x test` 성공 (전체 모듈 컴파일 통과)
- [x] `docker compose -f infra/docker/docker-compose.yml up postgres redis` 기동 성공
- [x] 디렉토리 구조가 `docs/PLAN.md` §4와 일치

## 다음 단계

BLOCK 1 완료 → **BLOCK 2 (common-core)** 진행
