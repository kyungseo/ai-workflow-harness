# BLOCK 8 — Dockerfile + 전체 스택 통합 테스트 + API 테스트

> 선행 조건: BLOCK 7 완료 + CP-3 통과
> 목적: 컨테이너 이미지 빌드 확인 + E2E API 테스트 파일 완성

---

## 8-1. Dockerfile 작성 (멀티스테이지, 각 서비스 공통 패턴)

- [ ] `gateway/api-gateway/Dockerfile`
- [ ] `services/auth-service/Dockerfile`
- [ ] `services/user-service/Dockerfile`
- [ ] `services/todo-service/Dockerfile`

```dockerfile
# Stage 1: Build
FROM gradle:8-jdk21 AS builder
WORKDIR /app
COPY . .
RUN gradle :{module-path}:bootJar --no-daemon

# Stage 2: Run
FROM eclipse-temurin:21-jre-jammy
WORKDIR /app
COPY --from=builder /app/{module-path}/build/libs/*.jar app.jar
ENTRYPOINT ["java", "-jar", "app.jar"]
```

- [ ] `make run`으로 전체 스택 컨테이너 기동 확인
- [ ] 각 서비스 Actuator health 응답 확인
  ```bash
  curl http://localhost:8099/actuator/health  # 각 서비스별 포트에서
  ```

---

## 8-2. E2E API 테스트 파일 작성 (tests/http/)

> 모든 요청은 Gateway(8090) 경유, `/api/v1/` prefix
> VS Code REST Client 형식 (`.http`)
> 각 파일에 성공/실패 케이스 구분 주석 + curl 등가 명령어 주석 병기

### tests/http/auth.http

- [ ] `### [성공] 로그인 (admin)` — `@name loginAdmin`, 토큰 변수 추출, `deviceId` 포함
- [ ] `### [성공] 로그인 (user)` — `@name loginUser`
- [ ] `### [실패] 로그인 — 잘못된 비밀번호` → `AUTH-0001`
- [ ] `### [성공] 토큰 갱신` — `{{loginAdmin.response.body.data.refreshToken}}` + `deviceId` 활용
- [ ] `### [실패] 토큰 갱신 — 잘못된 Refresh Token` → 401
- [ ] `### [성공] 로그아웃` — `deviceId` 포함
- [ ] `### [실패] 로그아웃된 토큰으로 API 요청` → 401 (Blacklist 확인)

### tests/http/user.http

- [ ] `### [성공] 회원가입`
- [ ] `### [실패] 회원가입 — 중복 이메일` → `USER-0001`
- [ ] `### [실패] 회원가입 — 비밀번호 정책 위반` → `COMMON-0002`
- [ ] `### [성공] 사용자 목록 조회 (ADMIN 토큰)` — `GET /api/v1/users?page=0&size=3` → totalElements=5, totalPages=2, content 3건
- [ ] `### [성공] 사용자 목록 조회 — 2페이지` — `GET /api/v1/users?page=1&size=3` → content 2건
- [ ] `### [실패] 사용자 목록 조회 (USER 토큰)` → 403
- [ ] `### [성공] 사용자 단건 조회 (본인)`
- [ ] `### [성공] 사용자 수정`
- [ ] `### [성공] 사용자 삭제 (ADMIN)`

### tests/http/todo.http

- [ ] `### [성공] 할 일 목록 조회` — `GET /api/v1/todos` (기본값)
- [ ] `### [성공] 할 일 목록 조회 — 페이징 1페이지` — `GET /api/v1/todos?page=0&size=5` → totalElements=8, totalPages=2, content 5건
- [ ] `### [성공] 할 일 목록 조회 — 페이징 2페이지` — `GET /api/v1/todos?page=1&size=5` → content 3건, last=true
- [ ] `### [성공] 할 일 목록 조회 — 완료 필터` — `GET /api/v1/todos?completed=true` → completed=true 항목만 반환 확인
- [ ] `### [성공] 할 일 생성`
- [ ] `### [성공] 할 일 단건 조회`
- [ ] `### [성공] 할 일 수정` — `PUT /api/v1/todos/{id}` (전체 수정)
- [ ] `### [성공] 할 일 완료 토글` — `PATCH /api/v1/todos/{id}/complete`
- [ ] `### [성공] 할 일 삭제`
- [ ] `### [실패] 타인 할 일 수정` → `TODO-0002` (403)
- [ ] `### [실패] 타인 할 일 삭제` → `TODO-0002` (403)
- [ ] `### [실패] 인증 없이 요청` → 401

---

## 8-3. 전체 스택 E2E 동작 확인

- [ ] `auth.http` → `user.http` → `todo.http` 순서로 전체 흐름 실행
- [ ] Swagger UI 접근 확인 (local 프로파일)
  - `http://localhost:8091/swagger-ui.html` (auth)
  - `http://localhost:8092/swagger-ui.html` (user)
  - `http://localhost:8093/swagger-ui.html` (todo)
- [ ] MDC 로그에 `traceId`, `spanId`, `X-Correlation-ID` 출력 확인
- [ ] Rate Limiting 동작 확인 (인증 API 5회 초과 → 429)

---

## 완료 조건

- [ ] 전체 서비스 `make run` 기동 성공
- [ ] `.http` 파일 전체 케이스 실행 완료
- [ ] 실패 케이스 모두 예상 에러 코드 반환 확인

## 다음 단계

BLOCK 8 완료 → **BLOCK 9 (Frontend)** 진행
