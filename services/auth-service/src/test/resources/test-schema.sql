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

-- 통합 테스트용 계정 (BCrypt strength 12, 평문: user/user)
INSERT INTO users (username, email, password, role) VALUES
    ('user', 'user@example.com', '$2a$12$NW/D1g7XsE.ex5YVnzqlpeqzLtFU/jOLkYiOOYMVXF.SwWQhSsyt6', 'ROLE_USER');
