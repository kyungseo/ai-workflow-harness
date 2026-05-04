# BLOCK 3 — 도메인 모델 확정 + schema.sql / data.sql

> 선행 조건: BLOCK 2 완료
> 목적: 서비스 구현(BLOCK 4~6) 전 DB 스키마 확정
> 이 BLOCK이 완료되어야 PostgreSQL을 기동하고 서비스를 로컬에서 실행할 수 있음.

---

## 3-1. 도메인 모델 확정

- [ ] `User` 도메인 필드 확정
  - `id` (BIGSERIAL PK)
  - `username` (VARCHAR 50, UNIQUE, NOT NULL)
  - `email` (VARCHAR 100, UNIQUE, NOT NULL)
  - `password` (VARCHAR 255, NOT NULL — BCrypt 해시)
  - `role` (VARCHAR 20, NOT NULL, DEFAULT 'ROLE_USER')
  - `enabled` (BOOLEAN, NOT NULL, DEFAULT TRUE)
  - `createdAt` (TIMESTAMP, NOT NULL, DEFAULT NOW())
  - `updatedAt` (TIMESTAMP, NOT NULL, DEFAULT NOW())

- [ ] `Todo` 도메인 필드 확정
  - `id` (BIGSERIAL PK)
  - `userId` (BIGINT, NOT NULL — **DB FK 제약 없음, 논리적 참조만**)
  - `title` (VARCHAR 200, NOT NULL)
  - `description` (TEXT, nullable)
  - `completed` (BOOLEAN, NOT NULL, DEFAULT FALSE)
  - `createdAt` (TIMESTAMP, NOT NULL, DEFAULT NOW())
  - `updatedAt` (TIMESTAMP, NOT NULL, DEFAULT NOW())

---

## 3-2. schema.sql 작성 (PostgreSQL 방언)

파일 위치: `infra/docker/init-sql/schema.sql`

- [ ] `users` 테이블 DDL
  ```sql
  CREATE TABLE IF NOT EXISTS users (
    id         BIGSERIAL    PRIMARY KEY,
    username   VARCHAR(50)  NOT NULL UNIQUE,
    email      VARCHAR(100) NOT NULL UNIQUE,
    password   VARCHAR(255) NOT NULL,
    role       VARCHAR(20)  NOT NULL DEFAULT 'ROLE_USER',
    enabled    BOOLEAN      NOT NULL DEFAULT TRUE,
    created_at TIMESTAMP    NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP    NOT NULL DEFAULT NOW()
  );
  ```

- [ ] `todos` 테이블 DDL
  ```sql
  -- todos.user_id는 users.id에 대한 논리적 참조 (DB FK 제약 없음)
  -- 참조 무결성은 todo-service 애플리케이션 레이어에서 보장
  -- 이유: Phase 2 DB per Service 분리 시 스키마 변경 없이 전환 가능
  CREATE TABLE IF NOT EXISTS todos (
    id          BIGSERIAL    PRIMARY KEY,
    user_id     BIGINT       NOT NULL,
    title       VARCHAR(200) NOT NULL,
    description TEXT,
    completed   BOOLEAN      NOT NULL DEFAULT FALSE,
    created_at  TIMESTAMP    NOT NULL DEFAULT NOW(),
    updated_at  TIMESTAMP    NOT NULL DEFAULT NOW()
  );
  ```

- [ ] 인덱스 추가
  ```sql
  CREATE INDEX IF NOT EXISTS idx_todos_user_id ON todos(user_id);
  CREATE INDEX IF NOT EXISTS idx_users_email ON users(email);
  CREATE INDEX IF NOT EXISTS idx_users_username ON users(username);
  ```

- [ ] `updated_at` 자동 갱신 트리거 추가
  > `DEFAULT NOW()`는 INSERT 시에만 적용. UPDATE 시 자동 갱신을 위한 트리거 필수.
  > 없으면 MyBatis UPDATE 쿼리에서 `updated_at = NOW()`를 매번 명시해야 하고 누락 시 정합성 오류 발생.
  ```sql
  -- updated_at 자동 갱신 함수
  CREATE OR REPLACE FUNCTION update_updated_at_column()
  RETURNS TRIGGER AS $$
  BEGIN
      NEW.updated_at = NOW();
      RETURN NEW;
  END;
  $$ LANGUAGE plpgsql;

  -- users 테이블 트리거
  CREATE TRIGGER set_updated_at_users
      BEFORE UPDATE ON users
      FOR EACH ROW
      EXECUTE FUNCTION update_updated_at_column();

  -- todos 테이블 트리거
  CREATE TRIGGER set_updated_at_todos
      BEFORE UPDATE ON todos
      FOR EACH ROW
      EXECUTE FUNCTION update_updated_at_column();
  ```

---

## 3-3. data.sql 작성

파일 위치: `infra/docker/init-sql/data.sql`

> **데이터 설계 근거 (페이지네이션 재현)**
> - `GET /users?page=0&size=3`: 5명 → page=0: 3명, page=1: 2명 (totalPages=2 검증 가능)
> - `GET /todos?page=0&size=5`: user 8건 → page=0: 5건, page=1: 3건 (totalPages=2 검증 가능)
> - `GET /todos?completed=true`: completed=true 항목이 없으면 필터 테스트 불가 → 계정별 일부 completed=true 필수

- [ ] 파일 상단 주석: `-- local/dev 전용 초기 데이터 (stg/prd 미포함)`

- [ ] 테스트 계정 삽입 — **5개 계정**, BCrypt strength 12 해시값으로 직접 작성 (평문 절대 금지)

  | username | 비밀번호 | role       |
  |----------|----------|------------|
  | admin    | admin    | ROLE_ADMIN |
  | user     | user     | ROLE_USER  |
  | user2    | user2    | ROLE_USER  |
  | user3    | user3    | ROLE_USER  |
  | user4    | user4    | ROLE_USER  |

  > BCrypt 해시값 생성:
  > ```java
  > new BCryptPasswordEncoder(12).encode("admin")
  > ```
  > 온라인 BCrypt 생성기 활용 시 strength 12 명시 필수

- [ ] 샘플 Todo 삽입 — **`user_id` 하드코딩 금지, subselect 패턴 사용**

  | 계정   | Todo 건수 | completed=false | completed=true | 목적                         |
  |--------|-----------|-----------------|----------------|------------------------------|
  | admin  | 3건       | 2건             | 1건            | completed 필터 테스트        |
  | user   | 8건       | 5건             | 3건            | 페이지네이션(size=5, 2페이지) |
  | user2  | 2건       | 2건             | 0건            | 소량 데이터 케이스           |
  | user3  | 0건       | —               | —              | 빈 목록 응답 케이스          |
  | user4  | 0건       | —               | —              | 빈 목록 응답 케이스          |

  ```sql
  -- admin: 3건 (completed=false 2건, completed=true 1건)
  INSERT INTO todos (user_id, title, description, completed)
  SELECT id, '관리자 할 일 1', '설명 1', false FROM users WHERE username = 'admin';
  INSERT INTO todos (user_id, title, description, completed)
  SELECT id, '관리자 할 일 2', '설명 2', false FROM users WHERE username = 'admin';
  INSERT INTO todos (user_id, title, description, completed)
  SELECT id, '관리자 완료 항목', '완료된 항목', true FROM users WHERE username = 'admin';

  -- user: 8건 (completed=false 5건, completed=true 3건) → page=0&size=5: 5건, page=1: 3건
  INSERT INTO todos (user_id, title, description, completed)
  SELECT id, '할 일 1', '설명 1', false FROM users WHERE username = 'user';
  INSERT INTO todos (user_id, title, description, completed)
  SELECT id, '할 일 2', '설명 2', false FROM users WHERE username = 'user';
  INSERT INTO todos (user_id, title, description, completed)
  SELECT id, '할 일 3', '설명 3', false FROM users WHERE username = 'user';
  INSERT INTO todos (user_id, title, description, completed)
  SELECT id, '할 일 4', '설명 4', false FROM users WHERE username = 'user';
  INSERT INTO todos (user_id, title, description, completed)
  SELECT id, '할 일 5', '설명 5', false FROM users WHERE username = 'user';
  INSERT INTO todos (user_id, title, description, completed)
  SELECT id, '완료 항목 1', '완료된 항목 1', true FROM users WHERE username = 'user';
  INSERT INTO todos (user_id, title, description, completed)
  SELECT id, '완료 항목 2', '완료된 항목 2', true FROM users WHERE username = 'user';
  INSERT INTO todos (user_id, title, description, completed)
  SELECT id, '완료 항목 3', '완료된 항목 3', true FROM users WHERE username = 'user';

  -- user2: 2건 (completed=false 2건)
  INSERT INTO todos (user_id, title, description, completed)
  SELECT id, 'user2 할 일 1', '설명 1', false FROM users WHERE username = 'user2';
  INSERT INTO todos (user_id, title, description, completed)
  SELECT id, 'user2 할 일 2', '설명 2', false FROM users WHERE username = 'user2';
  ```

---

## 3-4. 체크포인트 CP-1 — Docker Compose 기동 확인

- [ ] `.env` 파일 생성 (`.env.example` 기반으로 실제값 기입, HikariCP 환경변수 포함)
- [ ] `docker compose -f infra/docker/docker-compose.yml up postgres redis -d` 기동
- [ ] init-sql 자동 실행 확인 (컨테이너 로그에서 schema.sql, data.sql 실행 확인)
- [ ] 스키마 확인:
  ```bash
  docker exec -it <postgres_container> psql -U $DB_USERNAME -d $DB_NAME -c "\dt"
  ```
- [ ] 초기 데이터 확인 — 사용자 5명, Todo 계정별 건수 검증:
  ```bash
  # 사용자 5명 확인 (admin/user/user2/user3/user4)
  docker exec -it <postgres_container> psql -U $DB_USERNAME -d $DB_NAME \
    -c "SELECT id, username, role FROM users ORDER BY id;"

  # Todo 계정별 건수 확인 (admin:3, user:8, user2:2)
  docker exec -it <postgres_container> psql -U $DB_USERNAME -d $DB_NAME \
    -c "SELECT u.username, COUNT(t.id) AS todo_count,
               SUM(CASE WHEN t.completed THEN 1 ELSE 0 END) AS completed_count
        FROM users u LEFT JOIN todos t ON u.id = t.user_id
        GROUP BY u.username ORDER BY u.username;"
  ```
- [ ] `application-local.yml` SQL 로깅 활성화 확인 (`org.mybatis: DEBUG`)
- [ ] ✅ **CP-1 통과 확인 후 BLOCK 4~6 진행**

---

## 완료 조건

- [ ] PostgreSQL 기동 후 `users`, `todos` 테이블 생성 확인
- [ ] 인덱스 3개 생성 확인
- [ ] 5개 계정 데이터 확인 (`admin`, `user`, `user2`, `user3`, `user4`)
- [ ] Todo 건수 확인: admin 3건, user 8건, user2 2건, user3/user4 0건
- [ ] completed=true 항목 확인: admin 1건, user 3건

## 다음 단계

CP-1 통과 → **BLOCK 4 (auth-service)**, **BLOCK 5 (user-service)**, **BLOCK 6 (todo-service)** 병렬 진행 가능
