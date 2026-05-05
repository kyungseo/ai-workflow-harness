# STATUS.md — 진행 상태 트래킹

> 마지막 업데이트: 2026-05-05
> 이 파일은 구현 진행에 따라 지속적으로 업데이트된다.
> Claude Code는 각 태스크 완료 후 이 파일의 해당 항목을 업데이트할 것을 **제안**하고,
> 사용자 확인 후 반영한다.

---

## 현재 진행 블록

**▶ BLOCK 4 / 5 / 6 — auth-service / user-service / todo-service** (병렬 진행 가능)

---

## 블록별 상태 요약

| 블록 | 이름 | 상태 | 완료율 |
|------|------|------|--------|
| BLOCK 1 | 프로젝트 골격 | ✅ 완료 | 100% |
| BLOCK 2 | common-core | ✅ 완료 | 100% |
| BLOCK 3 | 도메인 모델 + schema.sql | ✅ 완료 | 100% |
| BLOCK 4 | auth-service | 🔵 시작 전 | 0% |
| BLOCK 5 | user-service | 🔵 시작 전 | 0% |
| BLOCK 6 | todo-service | 🔵 시작 전 | 0% |
| BLOCK 7 | api-gateway | ⏸ 대기 | - |
| BLOCK 8 | Dockerfile + 통합 테스트 | ⏸ 대기 | - |
| BLOCK 9 | Frontend | ⏸ 대기 | - |
| BLOCK 10 | 문서화 및 마무리 | ⏸ 대기 | - |

**상태 아이콘**: 🔵 시작 전 / 🟡 진행 중 / ✅ 완료 / ⏸ 대기 / ⚠️ 블로킹 이슈

---

## BLOCK 1 세부 진행 (완료)

> 상세 태스크는 `docs/TODO/TODO-BLOCK1.md` 참조

### 1-1. Gradle 멀티모듈 초기화
- [x] 루트 `build.gradle.kts`
- [x] `gradle/libs.versions.toml`
- [x] `settings.gradle.kts`
- [x] 각 모듈 `build.gradle.kts` (5개)
- [x] Gradle Wrapper
- [x] 루트 `.gitignore`

### 1-2. 환경변수 및 설정 파일 뼈대
- [x] `.env.example`
- [x] 각 서비스 `application.yml` (4개)
- [x] 각 서비스 `application-local.yml` (4개)
- [x] 각 서비스 `application-dev.yml` (4개)
- [x] 각 서비스 `application-stg.yml` (4개)
- [x] 각 서비스 `application-prd.yml` (4개)

### 1-3. Docker Compose 인프라
- [x] `infra/docker/docker-compose.yml`
- [x] `.devcontainer/docker-compose.devcontainer.yml`
- [x] `infra/docker/init-sql/01-schema.sql` (BLOCK 3에서 작성 완료 — 파일명 변경)
- [x] `infra/docker/init-sql/02-data.sql` (BLOCK 3에서 작성 완료 — 파일명 변경)

### 1-4. DevContainer 설정
- [x] `.devcontainer/devcontainer.json`

### 1-5. 빈 디렉토리 구조
- [x] `infra/k8s/` 하위 구조 + `.gitkeep`
- [x] `infra/prometheus/`, `infra/grafana/` `.gitkeep`
- [x] `tests/http/` `.gitkeep`

### 1-6. 자동화 스크립트
- [x] `scripts/Makefile`
- [x] `scripts/create-service.sh`

---

## BLOCK 2 세부 진행 (완료)

> 상세 태스크는 `docs/TODO/TODO-BLOCK2.md` 참조

### response/
- [x] `ApiResponse<T>`
- [x] `ErrorResponse`
- [x] `PageResponse<T>`

### exception/
- [x] `BusinessException`
- [x] `ErrorCode` enum
- [x] `GlobalExceptionHandler`

### logging/
- [x] `MdcFilter`
- [x] `LoggingConstants`

### security/
- [x] `JwtProperties`

### mybatis/
- [x] `SlowQueryInterceptor`

### util/
- [x] `DateTimeUtils`

### 테스트
- [x] `ApiResponseTest`
- [x] `ErrorCodeTest`
- [x] `BusinessExceptionTest`
- [x] `MdcFilterTest`
- [x] `GlobalExceptionHandlerTest`

---

## BLOCK 3 세부 진행 (완료)

> 상세 태스크는 `docs/TODO/TODO-BLOCK3.md` 참조

### 3-1. 도메인 모델 확정

- [x] `User` 필드 확정 (id, username, email, password, role, enabled, created_at, updated_at)
- [x] `Todo` 필드 확정 (id, user_id, title, description, completed, created_at, updated_at)

### 3-2. 01-schema.sql 작성

- [x] `users` 테이블 DDL
- [x] `todos` 테이블 DDL (DB FK 없음, 논리적 참조)
- [x] 인덱스 3개 (`idx_todos_user_id`, `idx_users_email`, `idx_users_username`)
- [x] `updated_at` 자동 갱신 트리거 함수 + `users`/`todos` 트리거

### 3-3. 02-data.sql 작성

- [x] 테스트 계정 5개 (BCrypt strength 12 해시, 평문 없음)
- [x] 샘플 Todo 13건 (subselect 패턴, user_id 하드코딩 없음)

### 3-4. CP-1 통과

- [x] `.env` 생성 (JWT_SECRET 256-bit 랜덤 생성)
- [x] `docker compose up postgres redis -d` 기동
- [x] 스키마 확인: `users`, `todos` 테이블 + 인덱스 3개 + 트리거 2개
- [x] 데이터 확인: 계정 5명, Todo admin 3건 / user 8건 / user2 2건

> **파일명 변경**: PostgreSQL init 스크립트는 알파벳 순 실행 → `data.sql`(d)이 `schema.sql`(s)보다 먼저 실행되어 오류 발생.
> `01-schema.sql` / `02-data.sql` 로 변경하여 해결.

---

## 체크포인트 상태

| CP | 조건 | 상태 |
|----|------|------|
| CP-1 | BLOCK 3 완료 → `docker compose up postgres` + psql 스키마/데이터 확인 | ✅ 통과 |
| CP-2 (auth) | auth-service 단독 기동 → 로그인 API 응답 확인 | ⏸ 대기 |
| CP-2 (user) | user-service 단독 기동 → 회원가입 API 응답 확인 | ⏸ 대기 |
| CP-2 (todo) | todo-service 단독 기동 → Todo 생성 API 응답 확인 | ⏸ 대기 |
| CP-3 | 전체 스택 기동 → 로그인 → Todo 생성 E2E Gateway 경유 확인 | ⏸ 대기 |

---

## 이슈 / 블로킹 사항

> 현재 없음

---

## 변경 이력

| 날짜 | 블록 | 변경 내용 |
|------|------|-----------|
| 2026-05-03 | - | 초기 STATUS.md 생성 |
| 2026-05-04 | BLOCK 1 | BLOCK 1 전체 완료 (.gitignore 추가, create-service.sh 실행권한 부여 포함) |
| 2026-05-04 | BLOCK 2 | BLOCK 2 전체 완료 (common-core 구현 + 단위 테스트 18개 통과) |
| 2026-05-05 | BLOCK 3 | BLOCK 3 전체 완료 (01-schema.sql/02-data.sql 작성, CP-1 통과 — init 스크립트 실행 순서 보장을 위해 파일명에 숫자 접두사 추가) |
