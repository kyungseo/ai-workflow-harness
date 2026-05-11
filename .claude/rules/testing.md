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

Integration tests depend on externally running Docker containers (`application-test.yml` → `localhost:5432`).
Testcontainers dependency is declared in `libs.versions.toml` but no tests use it yet.

MUST NOT add `@Testcontainers`, `@Container`, or `@ServiceConnection` without explicit approval.
This changes the test execution model and requires a separate decision under P2-006.

## Assertion and Mocking Style

MUST:

- Use AssertJ: `assertThat(...)`, `assertThatThrownBy(...)`
- Prefer BDD style: `given(mock).willReturn(value)` over Mockito `when/thenReturn`
- Keep `@MockitoSettings(strictness = Strictness.LENIENT)` — project standard; do not remove without reason.

NEVER:

- Use JUnit 5 raw assertions (`assertEquals`, `assertTrue`) — replace with AssertJ
- Use `@Data` on mock objects
- Use `@Autowired` field injection in test classes — use constructor injection if needed

## Naming Conventions

- Method name: `methodName_scenario_expectedBehavior` (English)
- `@DisplayName`: Korean (e.g. `"로그인 성공 시 액세스 토큰을 반환한다"`) — Korean display names are intentional
- Test class name: `{TargetClass}Test`

## Verification Command

- Unit / module change: `./gradlew :services:{service-name}:test`
- Full test suite: `./gradlew test`
- Exclude `@SpringBootTest` integration tests when no external Docker is running: `./gradlew test --tests "*UnitTest*"`
