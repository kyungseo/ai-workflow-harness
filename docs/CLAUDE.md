# CLAUDE.md — base-msa-template Claude Code 가이드

> 이 파일은 루트 `CLAUDE.md`를 읽은 **직후** 확인하는 프로젝트 운영 진입점이다.

---

## ⚠️ 운영 규칙 (절대 준수)

1. **파일을 읽은 후 즉시 구현하지 않는다.**
2. 항상 다음 순서를 따른다:
   - (a) 현재 상태 파악 및 요약 보고
   - (b) 수행할 작업 목록과 접근 방식 제안
   - (c) `"진행할까요?"` 로 끝내고 **사용자 승인 대기**
   - (d) 승인 확인 후에만 구현 시작
3. **한 번의 승인 = 명시적으로 합의된 범위만 구현**
   추가 작업은 반드시 재승인 요청.
4. 구현 완료 후 `STATUS.md` 업데이트 내용을 **제안만** 하고,
   실제 반영은 사용자 확인 후 진행.
5. 블록 경계에서 반드시 멈추고 체크포인트 통과 여부를 사용자에게 확인한다.

---

## 세션 시작 절차 (2단계 로딩)

```
1. root `CLAUDE.md` 읽기  ← 전역 원칙 확인
2. docs/CLAUDE.md 읽기   ← 지금 이 파일
3. docs/STATUS.md 읽기   ← 현재 진행 블록/체크포인트 확인
4. 현재 블록 번호 확인 → docs/TODO/TODO-BLOCK{n}.md 읽기
5. 현재 상태 요약 보고 후 사용자 승인 대기

[2단계: 필요 시 확장 로딩]
- 설계 결정/기술 원칙이 필요한 경우에만 `docs/PLAN.md`의 해당 섹션 읽기
- 아키텍처 흐름 확인이 필요한 경우에만 `docs/ARCHITECTURE.md` 읽기
```

---

## 절대 원칙 (코드 작성 시 항상 준수)

| 원칙 | 내용 |
|------|------|
| MyBatis 파라미터 | `#{}` 강제. `${}` 사용 시 반드시 화이트리스트 검증 + 주석 |
| DB FK | DB 레벨 FK 제약 미사용. `todos.user_id`는 논리적 참조만 |
| 민감정보 | 환경변수만. 기본값 절대 금지 (`JWT_SECRET`, `DB_PASSWORD` 등) |
| **기본 패키지** | `io.kyungseo.msa` — 서비스별: `io.kyungseo.msa.{auth\|user\|todo\|gateway\|common}` |
| Lombok | `@Data` 사용 금지. `@Getter` + `@Builder` + `@RequiredArgsConstructor` 조합 사용. 로거는 `@Slf4j` 선언 |
| MapStruct | DTO ↔ 도메인 변환에 사용. `build.gradle.kts`에서 `annotationProcessor` 순서 반드시 `lombok` → `mapstruct` 순으로 선언 |
| GlobalExceptionHandler | `common-core`의 단일 핸들러가 모든 `BusinessException` 처리 (옵션 A). 각 서비스는 별도 핸들러 생성 금지 |
| Caffeine 캐시 | JVM 로컬 캐시 — Pod 간 공유 불가 (설계상 허용). 민감 데이터(토큰, 비밀번호) 캐싱 금지. TTL 짧게 유지 필수. 캐시 무효화가 필요한 데이터는 Redis 사용 |
| SQL 로깅 | `local`/`dev`에서만 활성화. `stg`/`prd`는 `org.mybatis` 로그 레벨 `OFF` 강제 |
| 공개 경로 외 | 모든 API는 JWT 인증 필수 |
| Actuator | management port 8099 분리. 외부 노출 차단 |
| Swagger UI | `local` / `dev` 프로파일에서만 활성화 |
| 로그 | `Authorization` 헤더, 비밀번호, 토큰 전체값 출력 금지 |
| Header Spoofing | `UserContextFilter`에서 `X-User-Id`, `X-User-Role` 강제 제거 후 서버 값 주입 |
| Blacklist fail 정책 | `BLACKLIST_FAIL_POLICY` 환경변수로 제어 (`fail-close` 기본값) |

---

## 서비스 포트 맵

| 서비스 | 포트 | 역할 |
|--------|------|------|
| api-gateway | 8090 | 단일 진입점, 라우팅, 인증/인가 |
| auth-service | 8091 | JWT 발급/갱신/블랙리스트 |
| user-service | 8092 | 회원가입, 사용자 CRUD, RBAC |
| todo-service | 8093 | 할 일 CRUD (가이드 샘플) |
| PostgreSQL | 5432 | 공유 DB (Phase 1) |
| Redis | 6379 | Refresh Token, Blacklist, Rate Limiting |
| Actuator (전 서비스) | 8099 | management port 분리 |
| Frontend | 3000 | Vanilla JS 독립 서빙 |

---

## 참조 맵 (작업별 추가로 읽을 파일)

| 작업 상황 | 추가로 읽을 파일 |
|-----------|-----------------|
| 현재 블록 태스크 확인 | `docs/STATUS.md` → `docs/TODO/TODO-BLOCK{n}.md` |
| 기술 스택 / 의존성 버전 확인 | `docs/PLAN.md` §2 기술 스택 |
| 인증/보안 구현 | `docs/PLAN.md` §8 인증/인가, §16 보안 체크리스트 |
| DB 스키마 / 전략 | `docs/PLAN.md` §7 DB 전략 |
| API 응답 형식 / 에러 코드 | `docs/PLAN.md` §11 에러 코드 |
| 로깅 / 트레이싱 설정 | `docs/PLAN.md` §10 Logging & Tracing |
| 아키텍처 흐름 / 다이어그램 | `docs/ARCHITECTURE.md` |
| Phase 2 백로그 | `docs/decisions/PHASE2-BACKLOG.md` |

---

## 블록 의존 관계 (선행 조건 요약)

```
BLOCK 1 → BLOCK 2 → BLOCK 3
                         ├→ BLOCK 4 (auth)   ┐
                         ├→ BLOCK 5 (user)   ├ 병렬 가능
                         └→ BLOCK 6 (todo)   ┘
                                   └→ BLOCK 7 (gateway)
                                              └→ BLOCK 8 (Docker + E2E)
                                                         └→ BLOCK 9 (Frontend)
                                                                    └→ BLOCK 10 (마무리)
```

**체크포인트**
- CP-1: BLOCK 3 완료 → `docker compose up postgres` + psql 스키마 확인
- CP-2: BLOCK 4/5/6 각 완료 → 해당 서비스 단독 기동 + API 1개 응답 확인
- CP-3: BLOCK 7 완료 → 전체 스택 기동 + Gateway 경유 E2E 1개 흐름 확인

---

*현재 진행 상태는 항상 `docs/STATUS.md`를 기준으로 한다.*
