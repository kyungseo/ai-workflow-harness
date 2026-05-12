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

-- 통합 테스트용 계정 (BCrypt strength 12)
-- user/user, user2/user2 — 해시 출처: infra/docker/init-sql/02-data.sql
INSERT INTO users (username, email, password, role) VALUES
    ('user',  'user@example.com',  '$2a$12$NW/D1g7XsE.ex5YVnzqlpeqzLtFU/jOLkYiOOYMVXF.SwWQhSsyt6', 'ROLE_USER'),
    ('user2', 'user2@example.com', '$2a$12$ZyNGRWFG9uS64brz2PGqseYTGuwwvQixTXXx21Mg5B191/65goO8m', 'ROLE_USER')
ON CONFLICT DO NOTHING;
