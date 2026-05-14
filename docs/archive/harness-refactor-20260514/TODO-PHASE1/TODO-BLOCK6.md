# BLOCK 6 — todo-service

> 선행 조건: BLOCK 3 완료 + CP-1 통과
> 목적: 할 일 CRUD 구현 — 개발자 가이드 샘플 역할
> 병렬 가능: BLOCK 4 (auth-service), BLOCK 5 (user-service)
> 기본 패키지: `io.kyungseo.msa.todo`
> 참조: `docs/PLAN.md` §11 에러 코드 TODO-*

---

## 6-1. MyBatis 및 DB 연동

- [ ] MyBatis 설정 (`@MapperScan("io.kyungseo.msa.todo.mapper")`, `DataSource`, `SqlSessionFactory`)
- [ ] `TodoMapper` 인터페이스 + `TodoMapper.xml` 작성
  - `findAllByUserId(userId, page, size, completed)` — 본인 목록 조회 (LIMIT/OFFSET 페이징, completed null이면 전체)
  - `countByUserId(userId, completed)` — 전체 건수 (PageResponse totalElements용)
  - `findById(id)` — 단건 조회
  - `insert(todo)` — 생성
  - `update(todo)` — 전체 수정 (PUT)
  - `updateCompleted(id, completed)` — 완료 상태만 변경 (PATCH)
  - `deleteById(id)` — 삭제
  - XML 상단 주석: `<!-- #{} 파라미터 바인딩 사용. ${} 절대 사용 금지 (SQL Injection 방어) -->`
- [ ] **MyBatis 슬라이스 테스트** (`@MybatisTest` + Testcontainers PostgreSQL)
  - `insert` + `findById` 검증
  - `findAllByUserId` 결과 필터링 검증 (userId 기준)

---

## 6-2. 할 일 API 구현

- [ ] `todo-service` 전용 `ErrorCode` 정의
  - `TODO-0001`: 할 일 없음 (404)
  - `TODO-0002`: 본인 소유 아님 (403)

- [ ] `GET /api/v1/todos` (본인 목록 — 인증 필요)
  - 쿼리 파라미터: `?page=0&size=20&completed=` (completed 생략 시 전체)
  - `X-User-Id` 헤더에서 userId 추출 → `findAllByUserId(userId, page, size, completed)`
  - 응답: `ApiResponse<PageResponse<TodoResponse>>`

- [ ] `POST /api/v1/todos` (생성 — 인증 필요)
  - `X-User-Id` 헤더에서 userId 추출
  - userId 존재 확인: `users` 테이블 직접 조회 (user-service 호출 없이)
    → 애플리케이션 레벨 참조 무결성 보장 (FK 미사용 설계 대응)
  - Bean Validation: `@NotBlank` title

- [ ] `GET /api/v1/todos/{id}` (단건 조회 — 본인 소유 확인)
  - 존재하지 않으면 `TODO-0001`
  - 본인 소유 아니면 `TODO-0002`

- [ ] `PUT /api/v1/todos/{id}` (전체 수정 — 본인 소유 확인)
  - 본인 소유 아니면 `TODO-0002`

- [ ] `PATCH /api/v1/todos/{id}/complete` (완료 상태 토글 — 본인 소유 확인)
  - 기존 `completed` 값을 반전 (`true` → `false`, `false` → `true`)
  - `updateCompleted(id, !todo.getCompleted())` 호출
  - 본인 소유 아니면 `TODO-0002`

- [ ] `DELETE /api/v1/todos/{id}` (삭제 — 본인 소유 확인)
  - 본인 소유 아니면 `TODO-0002`

- [ ] Spring Security 설정
  - 모든 엔드포인트 → `authenticated()`
  - `X-User-Id` / `X-User-Role` 헤더 기반 인증 컨텍스트 설정 필터

- [ ] 본인 소유 검증 로직 — `TodoService` 내 공통 메서드
  ```java
  private void validateOwnership(Todo todo, Long requestUserId) {
      if (!todo.getUserId().equals(requestUserId)) {
          throw new BusinessException(TodoErrorCode.TODO_NOT_OWNED);
      }
  }
  ```

- [ ] **`TodoService` 단위 테스트** (Mockito)
  - 생성/조회/수정/삭제 정상 케이스
  - 완료 토글 정상 케이스 (`false` → `true`, `true` → `false`)
  - 본인 소유 검증: 타인 접근 → `TODO-0002` (수정/토글/삭제 모두 검증)
  - 존재하지 않는 Todo 조회 → `TODO-0001`

- [ ] **`TodoController` 슬라이스 테스트** (`@WebMvcTest` + Security)
  - 인증 없는 요청 → 401
  - 유효성 검증 실패 → `COMMON-0002`

---

## 6-3. 공통 설정

- [ ] springdoc-openapi JWT Bearer 인증 설정
- [ ] MDC + Micrometer Tracing 설정 (로그 패턴: `[todo-service,...]`)
- [ ] Actuator health probes 설정 (management port: 8099)

---

## 6-4. 통합 테스트

- [ ] `@SpringBootTest` + Testcontainers PostgreSQL
  - 생성 → 조회 → 수정 → 삭제 전체 흐름 검증
  - 타인 소유 할 일 수정/삭제 차단 확인 (`TODO-0002`)

---

## 6-5. 체크포인트 CP-2 (todo-service)

- [ ] todo-service 단독 기동 (`SPRING_PROFILES_ACTIVE=local`)
- [ ] Swagger UI(`http://localhost:8093/swagger-ui.html`) 접근 확인
- [ ] Todo 생성 API 응답 확인 (Swagger 또는 `.http`)
- [ ] ✅ **CP-2 통과 기록 후 BLOCK 7 진행 허용 (BLOCK 4, 5도 완료 시)**

---

## 완료 조건

- [ ] `./gradlew :services:todo-service:test` 전체 통과
- [ ] 생성 → 조회 → 수정 → 삭제 E2E 흐름 동작 확인

## 다음 단계

CP-2 (todo) 통과 → BLOCK 7 진행 조건 중 하나 충족
