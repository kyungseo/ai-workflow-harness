-- ============================================================
-- base-msa-template data.sql
-- local/dev 전용 초기 데이터 (stg/prd 미포함)
-- 비밀번호: BCrypt strength 12 해시 (평문 절대 금지)
-- ============================================================

-- ============================================================
-- 테스트 계정 (5개)
-- admin / admin  → ROLE_ADMIN
-- user  / user   → ROLE_USER  (페이지네이션·필터 테스트 메인)
-- user2 / user2  → ROLE_USER  (타인 소유권 테스트)
-- user3 / user3  → ROLE_USER  (사용자 페이징 더미)
-- user4 / user4  → ROLE_USER  (사용자 페이징 더미)
-- ============================================================
INSERT INTO users (username, email, password, role) VALUES
    ('admin', 'admin@example.com', '$2a$12$kNDHsmJehH8Xyw3jxCC9Au9qXLxJzuFZwSucPi.8URDoPFQuOi7dC', 'ROLE_ADMIN'),
    ('user',  'user@example.com',  '$2a$12$NW/D1g7XsE.ex5YVnzqlpeqzLtFU/jOLkYiOOYMVXF.SwWQhSsyt6', 'ROLE_USER'),
    ('user2', 'user2@example.com', '$2a$12$ZyNGRWFG9uS64brz2PGqseYTGuwwvQixTXXx21Mg5B191/65goO8m', 'ROLE_USER'),
    ('user3', 'user3@example.com', '$2a$12$B6F4u2GzEDKqfbTFkmUM4.Tupj3LO1n4Kd5xRco/q5B5XYHE3wy/m', 'ROLE_USER'),
    ('user4', 'user4@example.com', '$2a$12$4TKKaOYK1uXzIKjMBu9Hi.ka1UAgXjoiS2eKFm5603LVgLNz4ur5u', 'ROLE_USER');

-- ============================================================
-- 샘플 Todo
-- user_id 하드코딩 금지 → subselect 패턴으로 username 기반 참조
--
-- admin  : 3건 (false 2, true 1)  → completed 필터 테스트
-- user   : 8건 (false 5, true 3)  → 페이지네이션 size=5 → 2페이지 검증
-- user2  : 2건 (false 2, true 0)  → 타인 소유권 테스트
-- user3  : 0건                    → 빈 목록 응답 케이스
-- user4  : 0건                    → 빈 목록 응답 케이스
-- ============================================================

-- admin: 3건
INSERT INTO todos (user_id, title, description, completed)
SELECT id, '관리자 할 일 1', '관리자 첫 번째 할 일입니다.', false FROM users WHERE username = 'admin';
INSERT INTO todos (user_id, title, description, completed)
SELECT id, '관리자 할 일 2', '관리자 두 번째 할 일입니다.', false FROM users WHERE username = 'admin';
INSERT INTO todos (user_id, title, description, completed)
SELECT id, '관리자 완료 항목', '이미 완료된 항목입니다.', true FROM users WHERE username = 'admin';

-- user: 8건 (페이지네이션 page=0&size=5 → 5건, page=1 → 3건 검증용)
INSERT INTO todos (user_id, title, description, completed)
SELECT id, '할 일 1', '첫 번째 할 일입니다.', false FROM users WHERE username = 'user';
INSERT INTO todos (user_id, title, description, completed)
SELECT id, '할 일 2', '두 번째 할 일입니다.', false FROM users WHERE username = 'user';
INSERT INTO todos (user_id, title, description, completed)
SELECT id, '할 일 3', '세 번째 할 일입니다.', false FROM users WHERE username = 'user';
INSERT INTO todos (user_id, title, description, completed)
SELECT id, '할 일 4', '네 번째 할 일입니다.', false FROM users WHERE username = 'user';
INSERT INTO todos (user_id, title, description, completed)
SELECT id, '할 일 5', '다섯 번째 할 일입니다.', false FROM users WHERE username = 'user';
INSERT INTO todos (user_id, title, description, completed)
SELECT id, '완료 항목 1', '첫 번째 완료된 항목입니다.', true FROM users WHERE username = 'user';
INSERT INTO todos (user_id, title, description, completed)
SELECT id, '완료 항목 2', '두 번째 완료된 항목입니다.', true FROM users WHERE username = 'user';
INSERT INTO todos (user_id, title, description, completed)
SELECT id, '완료 항목 3', '세 번째 완료된 항목입니다.', true FROM users WHERE username = 'user';

-- user2: 2건 (타인 소유권 테스트용)
INSERT INTO todos (user_id, title, description, completed)
SELECT id, 'user2 할 일 1', 'user2의 첫 번째 할 일입니다.', false FROM users WHERE username = 'user2';
INSERT INTO todos (user_id, title, description, completed)
SELECT id, 'user2 할 일 2', 'user2의 두 번째 할 일입니다.', false FROM users WHERE username = 'user2';
