# BLOCK 9 — Frontend (Vanilla JS)

> 선행 조건: BLOCK 8 완료
> 목적: 백엔드 API 연동 가이드 샘플. 빌드 도구 없음.
> 서빙: `python3 -m http.server 3000` 또는 `npx serve`
> 참조: `docs/PLAN.md` §17 Frontend

---

## 파일 구성

```
frontend/web-app/
├── login.html
├── index.html       (대시보드 — 사용자 정보, 로그아웃)
├── todo.html
└── js/
    ├── api.js       (fetch 래퍼, JWT 자동 첨부, 401 처리)
    ├── auth.js      (로그인/로그아웃, 토큰 관리, deviceId)
    └── todo.js      (할 일 CRUD UI)
```

---

## 구현 태스크

### js/auth.js

- [ ] `getOrCreateDeviceId()` — 최초 접속 시 UUID 생성, `localStorage`에 영구 보관
- [ ] `login(username, password)` — deviceId 자동 포함하여 POST 요청
- [ ] `logout()` — deviceId 포함하여 POST 요청 + localStorage 토큰 삭제
- [ ] `getAccessToken()`, `getRefreshToken()`
- [ ] `setTokens(accessToken, refreshToken)`, `clearTokens()`

### js/api.js

- [ ] `fetchWithAuth(url, options)` — `Authorization: Bearer {accessToken}` 자동 첨부
- [ ] 401 응답 시 Refresh Token으로 자동 갱신 후 원래 요청 재시도
- [ ] 갱신 실패 시 `clearTokens()` + `login.html` 리다이렉트
- [ ] deviceId 갱신 요청 시 자동 포함

### login.html

- [ ] 로그인 폼 (username, password) — Bootstrap CDN
- [ ] 로그인 성공 시 `todo.html` 리다이렉트
- [ ] 오류 메시지 표시

### index.html (대시보드)

- [ ] 로그인 상태 확인 (토큰 없으면 `login.html` 리다이렉트)
- [ ] 현재 사용자 정보 표시
- [ ] 로그아웃 버튼

### todo.html

- [ ] 할 일 목록 표시 (`loadTodos()`)
- [ ] 할 일 추가 폼
- [ ] 완료 토글 (`updateTodo()`)
- [ ] 삭제 버튼 (`deleteTodo()`)

### js/todo.js

- [ ] `loadTodos(page, completed)` — `GET /api/v1/todos?page={page}&size=20[&completed={completed}]`
- [ ] `createTodo(title, description)` — `POST /api/v1/todos`
- [ ] `updateTodo(id, data)` — `PUT /api/v1/todos/{id}` (전체 수정)
- [ ] `toggleComplete(id)` — `PATCH /api/v1/todos/{id}/complete` (완료 상태 토글)
  > PUT 전체 수정 대신 전용 PATCH 엔드포인트 사용. 완료 버튼 클릭 시 이 함수 호출.
- [ ] `deleteTodo(id)` — `DELETE /api/v1/todos/{id}`

---

## 수동 확인 항목

- [ ] 브라우저에서 `http://localhost:3000/login.html` 접근
- [ ] admin 로그인 → `todo.html` 리다이렉트 확인
- [ ] 할 일 생성/수정/삭제 전체 흐름 확인
- [ ] 로그아웃 후 재접근 시 `login.html` 리다이렉트 확인
- [ ] Access Token 만료 시 자동 갱신 후 재요청 확인

---

## 완료 조건

- [ ] 로그인 → 할 일 CRUD → 로그아웃 전체 흐름 브라우저에서 수동 확인 완료

## 다음 단계

BLOCK 9 완료 → **BLOCK 10 (문서화 및 마무리)** 진행
