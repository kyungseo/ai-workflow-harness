# DR-001: Token Storage 전략 — localStorage vs HttpOnly Cookie

Date: 2026-05-11
Status: Superseded

## Question

현재 프론트엔드가 Access Token을 localStorage에 저장하는 방식을 HttpOnly Cookie로 전환해야 하는가?

## Decision

(결정 후 작성)

## Options Considered

| 선택지 | 장점 | 단점 |
|--------|------|------|
| **localStorage 유지** | 구현 단순, `fetch/api.js` 변경 없음, CORS 설정 그대로 | XSS 공격으로 토큰 탈취 가능 |
| **HttpOnly Cookie 전환** | XSS로 JS 접근 불가, 토큰 탈취 위험 제거 | CSRF 방어 추가 필요 (SameSite=Strict/Lax), Gateway WebFlux에서 Cookie 파싱 변경, `frontend/js/auth.js` + `api.js` 수정 필요 |

## Rationale

(결정 후 작성)

## Consequences

- **localStorage 유지**: `auth.js`, `api.js` 변경 없음. 보안 강화는 CSP 헤더로 보완.
- **HttpOnly Cookie 전환**: `api-gateway` 인증 필터, `auth-service` 응답 형식, `frontend/js/auth.js`, `frontend/js/api.js` 네 레이어 변경 필요.

## Reversal Cost

Medium — 전환 후 되돌리면 auth-service/gateway/frontend 세 레이어 모두 재수정.

## Linked Backlog Items

- P2-001 (token storage 전략 재검토)
