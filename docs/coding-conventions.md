# 코딩 컨벤션

> 이 문서는 base-msa-template의 코딩 컨벤션 SSOT(Single Source of Truth)다.
> AI rules(`.claude/rules/`, `.cursor/rules/`)는 여기서 파생된 imperative 형태다. 중복 작성하지 않는다.
>
> 최종 업데이트: 2026-05-12

---

## 1. 패키지 구조

```
io.kyungseo.msa.{service}.{layer}
```

레이어 목록:

| 레이어 | 역할 |
|--------|------|
| `controller` | HTTP 요청 처리, 입력 검증 |
| `service` | 비즈니스 로직 |
| `domain` | 도메인 모델 (Entity) |
| `dto` | 요청/응답 데이터 전달 객체 |
| `mapper` | MyBatis 인터페이스 |
| `filter` | Servlet/WebFlux 필터 |
| `config` | Spring 설정 |
| `exception` | 예외 코드 (ErrorCode Enum) |

공통 모듈: `io.kyungseo.msa.common.*`
- `common-core`는 **서비스 간 공유 가능한** 코드만 포함한다 (ApiResponse, BusinessException, GlobalExceptionHandler, MdcFilter, JwtProperties).
- 서비스 도메인 로직은 절대 `common-core`에 추가하지 않는다.

---

## 2. 아키텍처 레이어 의존성

```
Controller → Service → Mapper(Repository)
                    ↘ Domain
```

- 단방향 의존성. 역방향 참조 금지.
- `Controller`는 비즈니스 로직을 포함하지 않는다.
- `Service`는 다른 `Service`를 직접 호출하지 않는다 (MSA 경계).

---

## 3. 네이밍 컨벤션

| 대상 | 형식 | 예시 |
|------|------|------|
| 클래스 | PascalCase | `AuthService`, `LoginRequest` |
| 인터페이스 | PascalCase | `UserMapper`, `ErrorCode` |
| 메서드 | lowerCamelCase 동사 | `findByUsername`, `issueAccessToken` |
| 필드 | lowerCamelCase | `jwtTokenProvider`, `passwordEncoder` |
| 상수 | UPPER_SNAKE_CASE | `HEADER_USER_ID`, `DEFAULT_PAGE_SIZE` |
| 패키지 | 소문자 | `io.kyungseo.msa.auth.service` |
| 테스트 메서드 | `메서드_시나리오_기대행동` (영어) | `login_withInvalidPassword_throwsException` |

---

## 4. 주석 규칙

### 파일 헤더

없음. `LICENSE` 파일이 전체 프로젝트의 라이선스를 커버한다. (DR-004 참조)

### 클래스 Javadoc

아래 조건에 해당할 때만 작성한다:
- 아키텍처 경계 또는 보안 책임이 있는 클래스 (예: `JwtAuthFilter`, `UserContextFilter`)
- 복잡한 상태 머신이나 비직관적인 설계 결정이 있는 클래스
- 일반 CRUD Controller, Service, Mapper — **작성하지 않는다**

```java
// 예시: 아키텍처 경계가 있는 클래스
/**
 * Gateway가 주입한 X-User-Id / X-User-Role 헤더로 SecurityContext를 구성한다.
 *
 * [Header Spoofing 설계 범위]
 * Phase 1: Gateway 경유만 허용한다고 가정 (네트워크 레벨 격리).
 * Phase 2: K8s NetworkPolicy로 강제.
 */
```

### 인라인 주석

형식: `// 한국어 이유 — 영어 기술 용어` (WHY만 설명, WHAT 설명 금지)

```java
// 사용자 없음과 비밀번호 불일치 동일 메시지 — 정보 노출 방지
throw new BusinessException(AuthErrorCode.LOGIN_FAILED);

// type == "refresh" 검증 — Access Token으로 갱신 시도 차단 (token confusion 방어)
jwtTokenProvider.validateRefreshToken(request.getRefreshToken());
```

금지 패턴:
```java
// 이 메서드는 사용자를 저장합니다  ← WHAT 설명. 코드가 이미 말함.
userMapper.insert(user);
```

### 어노테이션 기반 문서화

Swagger `@Operation`, `@Schema`, 검증 `@NotBlank(message)`, 테스트 `@DisplayName`이 각 컨텍스트에서 문서 역할을 한다. 이들이 있으면 별도 Javadoc 불필요.

---

## 5. Lombok 사용 기준

| 어노테이션 | 사용 여부 | 이유 |
|-----------|-----------|------|
| `@Getter` | ✅ 권장 | 불변 필드 접근 |
| `@Builder` | ✅ 권장 | 가독성 높은 객체 생성 |
| `@RequiredArgsConstructor` | ✅ 권장 | 생성자 주입 (Spring DI 표준) |
| `@Slf4j` | ✅ 권장 | 로거 자동 생성 |
| `@Value` | ✅ 허용 | 불변 DTO (record 대안) |
| `@Data` | ❌ 금지 | equals/hashCode 의도치 않은 override 위험 |
| `@Setter` | ❌ 지양 | 가변성 증가, 불변 설계 위반 |

**MapStruct와 함께 사용 시**: annotation processor 순서를 Lombok → MapStruct로 유지한다. `build.gradle.kts`에 이미 설정됨.

---

## 6. MyBatis 규칙

- 파라미터: 항상 `#{}` 사용.
- `${}` 사용 조건: whitelist 검증 + 인라인 주석 필수.

```xml
<!-- 허용: 정렬 컬럼이 whitelist로 검증된 경우 -->
ORDER BY ${validatedColumn}  <!-- whitelist: created_at | updated_at -->
```

- Mapper XML 위치: `src/main/resources/mapper/{service}/*.xml`
- 결과 매핑: `useGeneratedKeys="true"`, `keyProperty="id"` 패턴 사용.

---

## 7. 테스트 컨벤션

### 레이어별 어노테이션

| 레이어 | 어노테이션 | 특징 |
|--------|-----------|------|
| 유닛 | `@ExtendWith(MockitoExtension.class)` | Spring 컨텍스트 없음 |
| Controller | `@WebMvcTest` + `@ActiveProfiles("test")` | Spring MVC만 |
| MyBatis | `@MybatisTest` + `@ActiveProfiles("test")` | Mapper만 |
| 통합 | `@SpringBootTest` + `@AutoConfigureMockMvc` | 전체 Spring 컨텍스트 |

### 스타일 규칙

- Assertion: AssertJ (`assertThat(...)`, `assertThatThrownBy(...)`) — JUnit raw assertion 금지
- Mocking: BDD 스타일 (`given(mock).willReturn(value)`) 우선
- `@MockitoSettings(strictness = Strictness.LENIENT)` — 프로젝트 표준, 임의 제거 금지
- `@DisplayName`: 한국어 (`"로그인 성공 시 액세스 토큰을 반환한다"`)

### 현재 제약

통합 테스트는 외부 Docker 컨테이너에 의존한다 (`application-test.yml` → `localhost:5432`).
Testcontainers는 선언되었으나 미사용. P2-006 결정 후 활성화 예정.

---

## 8. Checkstyle 규칙

설정 파일: `config/checkstyle/checkstyle.xml` (Google Java Style 기반, 프로젝트 오버라이드)

| 항목 | 프로젝트 설정 | Google 기본값 |
|------|-------------|--------------|
| 최대 줄 길이 | 120자 | 100자 |
| 들여쓰기 | 4 spaces | 2 spaces |
| Javadoc 강제 | 없음 | 있음 |

주요 적용 규칙:
- 탭 문자 금지 (spaces only)
- star import 금지 (`import java.util.*`)
- 미사용 import 금지
- 모든 블록에 중괄호 필수 (`NeedBraces`)
- 파일명과 외부 클래스명 일치 (`OuterTypeFilename`)
- `finalize()` 메서드 금지

suppressions: `config/checkstyle/suppressions.xml` (테스트 파일 일부 규칙 완화)

실행: `./gradlew checkstyleMain` (소스), `./gradlew checkstyleTest` (테스트), `./gradlew check` (전체)

---

## 9. 개발 환경 설정

### EditorConfig (`.editorconfig`)

프로젝트 루트에 존재. EditorConfig 플러그인이 설치된 IDE에서 자동 적용된다.
- IntelliJ: 기본 내장
- VS Code: `EditorConfig for VS Code` 확장 설치 필요

### IntelliJ 권장 설정

**Checkstyle 플러그인 설치:**
- Settings → Plugins → `CheckStyle-IDEA` 설치
- Settings → Tools → Checkstyle → `+` 버튼 → `config/checkstyle/checkstyle.xml` 등록

**클래스 주석 자동 생성 (선택):**
- Settings → Editor → File and Code Templates → Includes → `File Header` 탭
- 프로젝트 정책: 파일 헤더 없음. 클래스 Javadoc은 필요 시 수동 추가.

### Git Hooks

`sh tools/git-hooks/install.sh` 실행으로 설치.

| Hook | 동작 | 속도 |
|------|------|------|
| `commit-msg` | Conventional Commits 형식 검증 | <1ms |
| `pre-commit` | `./gradlew checkstyleMain` 실행 | ~5s (daemon warm) |

---

## 10. 반패턴 (Anti-patterns)

| 패턴 | 이유 |
|------|------|
| `common-core`에 서비스 도메인 로직 추가 | 서비스 간 강결합, 변경 파급 위험 |
| `@Data` 사용 | `equals`/`hashCode` 의도치 않은 override — 컬렉션/JPA에서 버그 유발 |
| `@Autowired` 필드 주입 | 테스트 불가, 순환 의존성 감지 어려움 |
| JUnit raw assertion (`assertEquals`) | 실패 메시지 빈약, AssertJ로 대체 |
| JWT/password 로깅 | 보안 사고 위험 |
| `${}` MyBatis 파라미터 (검증 없이) | SQL Injection 취약점 |
| Controller에 비즈니스 로직 | 레이어 책임 위반, 테스트 어려움 |
| 과도한 추상화 | 3개 미만 사례에는 추상화 불필요 |
