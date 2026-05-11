---
paths:
  - "services/**/src/test/**/*.java"
  - "gateway/**/src/test/**/*.java"
  - "common/**/src/test/**/*.java"
---

# Java Testing Rules

## Test Layer Annotations

| Layer | Annotation | Context |
|-------|-----------|---------|
| Unit | `@ExtendWith(MockitoExtension.class)` + `@MockitoSettings(strictness = Strictness.LENIENT)` | No Spring context |
| Controller slice | `@WebMvcTest` + `@ActiveProfiles("test")` | Spring MVC only |
| MyBatis slice | `@MybatisTest` + `@ActiveProfiles("test")` | MyBatis mapper only |
| Integration | `@SpringBootTest` + `@AutoConfigureMockMvc` + `@ActiveProfiles("test")` | Full Spring context |

## Integration Test Infrastructure

현재 통합 테스트는 외부 실행 중인 Docker 컨테이너에 의존한다 (`application-test.yml` → `localhost:5432`).
Testcontainers 의존성은 `libs.versions.toml`에 선언됐지만 실제 사용하는 테스트가 없다.

MUST NOT: 명시적 승인 없이 `@Testcontainers`, `@Container`, `@ServiceConnection` 어노테이션을 추가하지 않는다.
이 변경은 테스트 실행 모델을 바꾸므로 P2-006 범위에서 별도 결정이 필요하다.

## Assertion and Mocking Style

MUST:

- AssertJ 사용: `assertThat(...)`, `assertThatThrownBy(...)`
- BDD 스타일 선호: `given(mock).willReturn(value)` (Mockito `when/thenReturn` 지양)
- `@MockitoSettings(strictness = Strictness.LENIENT)` — 프로젝트 표준; 이유 없이 제거하지 않는다.

NEVER:

- JUnit5 raw assertions (`assertEquals`, `assertTrue`) — AssertJ로 대체
- `@Data` mock 사용
- 테스트 필드에 `@Autowired` 필드 주입 (인스턴스 주입이 필요하면 생성자 방식 사용)

## Naming Conventions

- 메서드명: `methodName_scenario_expectedBehavior` (영어)
- `@DisplayName`: 한국어 (`"로그인 성공 시 액세스 토큰을 반환한다"`)
- 테스트 클래스명: `{TargetClass}Test`

## Verification Command

- 단위/모듈 변경: `./gradlew :services:{service-name}:test`
- 전체: `./gradlew test`
- 외부 Docker 없이 실행하려면 `@SpringBootTest` 통합 테스트는 제외: `./gradlew test --tests "*UnitTest*"`
