# BLOCK 5 — user-service

> 선행 조건: BLOCK 3 완료 + CP-1 통과
> 목적: 회원가입, 사용자 CRUD, RBAC 구현
> 병렬 가능: BLOCK 4 (auth-service), BLOCK 6 (todo-service)
> 기본 패키지: `io.kyungseo.msa.user`
> 참조: `docs/PLAN.md` §8 RBAC, §11 에러 코드 USER-*

---

## 5-1. MyBatis 및 DB 연동

- [ ] MyBatis 설정 (`@MapperScan("io.kyungseo.msa.user.mapper")`, `DataSource`, `SqlSessionFactory`)
- [ ] `UserMapper` 인터페이스 + `UserMapper.xml` 작성
  - `findAll(page, size)` — 전체 목록 (ADMIN 전용, LIMIT/OFFSET 페이징)
  - `count()` — 전체 건수 (PageResponse totalElements용)
  - `findById(id)` — 단건 조회
  - `findByEmail(email)` — 중복 이메일 확인용
  - `insert(user)` — 회원가입
  - `update(user)` — 정보 수정
  - `deleteById(id)` — 삭제
  - `existsByEmail(email)` → boolean
  - XML 상단 주석: `<!-- #{} 파라미터 바인딩 사용. ${} 절대 사용 금지 (SQL Injection 방어) -->`
- [ ] **MyBatis 슬라이스 테스트** (`@MybatisTest` + Testcontainers PostgreSQL)
  - `insert` + `findById` 검증
  - `existsByEmail` 중복 케이스 검증
  - `findAll` 결과 개수 검증

---

## 5-2. 사용자 API 구현

- [ ] `user-service` 전용 `ErrorCode` 정의
  - `USER-0001`: 이미 존재하는 이메일 (409)
  - `USER-0002`: 사용자 없음 (404)
  - `USER-0003`: 비밀번호 정책 불일치 (400)

- [ ] `BCryptPasswordEncoder` Bean 설정 (strength 12)

- [ ] `POST /api/v1/users` (회원가입 — **공개 경로**)
  - 이메일 중복 확인 → `USER-0001`
  - 비밀번호 BCrypt 인코딩 후 저장
  - Bean Validation:
    - `@Email` 이메일 형식
    - `@Pattern` 비밀번호: 최소 8자, 영문+숫자 조합 필수
    - `@NotBlank` username, email, password

- [ ] `GET /api/v1/users` (목록 조회 — `ROLE_ADMIN` 전용)
  - 쿼리 파라미터: `?page=0&size=20`
  - `@PreAuthorize("hasRole('ADMIN')")`
  - 응답: `ApiResponse<PageResponse<UserResponse>>`

- [ ] `GET /api/v1/users/{id}` (단건 조회 — 본인 또는 ADMIN)
  - `X-User-Id` 헤더값과 `{id}` 비교 또는 ADMIN 역할 확인

- [ ] `PUT /api/v1/users/{id}` (수정 — 본인 또는 ADMIN)
  - 비밀번호 변경 시 재인코딩

- [ ] `DELETE /api/v1/users/{id}` (삭제 — ADMIN 전용)
  - `@PreAuthorize("hasRole('ADMIN')")`

- [ ] Spring Security 설정
  - `POST /api/v1/users` → `permitAll()`
  - 나머지 → `X-User-Id` / `X-User-Role` 헤더 기반 인증 컨텍스트 구성
    (Gateway에서 주입한 헤더를 `SecurityContext`에 설정하는 필터 구현)
  - `@PreAuthorize` 활성화: `@EnableMethodSecurity`

- [ ] **`UserService` 단위 테스트** (Mockito)
  - 회원가입 성공 / 이메일 중복 → `USER-0001`
  - `GET /users/{id}` 본인 접근 / ADMIN 접근 / 타인 접근 → 403
  - `DELETE` ADMIN 접근 성공 / USER 접근 → 403

- [ ] **`UserController` 슬라이스 테스트** (`@WebMvcTest` + Security)
  - 비밀번호 정책 위반 → `COMMON-0002`
  - ADMIN 전용 엔드포인트 USER 접근 → `COMMON-0004`

---

## 5-3. 공통 설정

- [ ] springdoc-openapi JWT Bearer 인증 설정
- [ ] MDC + Micrometer Tracing 설정 (로그 패턴: `[user-service,...]`)
- [ ] Actuator health probes 설정 (management port: 8099)

---

## 5-4. 통합 테스트

- [ ] `@SpringBootTest` + Testcontainers PostgreSQL
  - 회원가입 → 조회 → 수정 → 삭제 전체 흐름 검증
  - 이메일 중복 가입 차단 확인

---

## 5-5. 체크포인트 CP-2 (user-service)

- [ ] user-service 단독 기동 (`SPRING_PROFILES_ACTIVE=local`)
- [ ] Swagger UI(`http://localhost:8092/swagger-ui.html`) 접근 확인
- [ ] 회원가입 API 응답 확인 (Swagger 또는 `.http`)
- [ ] ✅ **CP-2 통과 기록 후 BLOCK 7 진행 허용 (BLOCK 4, 6도 완료 시)**

---

## 완료 조건

- [ ] `./gradlew :services:user-service:test` 전체 통과
- [ ] 회원가입 → 조회 → 수정 → 삭제 E2E 흐름 동작 확인

## 다음 단계

CP-2 (user) 통과 → BLOCK 7 진행 조건 중 하나 충족
