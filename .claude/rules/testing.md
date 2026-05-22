---
paths:
  - "services/**/src/test/**/*.java"
  - "gateway/**/src/test/**/*.java"
  - "common/**/src/test/**/*.java"
---

# Optional Spring Boot Testing Rules

These rules are not part of the generic AI Workflow Harness core. They are kept
as an optional example/profile surface for projects that adopt the harness with
Spring Boot backend tests.

## Test Layer Annotations

| Layer | Annotation | Context |
|-------|-----------|---------|
| Unit | `@ExtendWith(MockitoExtension.class)` + `@MockitoSettings(strictness = Strictness.LENIENT)` | No Spring context |
| Controller slice | `@WebMvcTest` + `@ActiveProfiles("test")` | Spring MVC only |
| MyBatis slice | `@MybatisTest` + `@ActiveProfiles("test")` | MyBatis mapper only |
| Integration | `@SpringBootTest` + `@AutoConfigureMockMvc` + `@ActiveProfiles("test")` | Full Spring context |

## Integration Test Infrastructure

Prefer the adopted project's established integration-test infrastructure.

MUST:

- Keep integration-test environment settings in shared test configuration, not per-test ad hoc system properties.
- Reuse the established integration-test infrastructure pattern in existing service tests.
- Record infrastructure changes through the adopted project's decision process.

NEVER:

- Reintroduce local-only test overrides without an explicit decision.
- Depend on separately running local services for integration tests unless the adopted project documents that requirement.

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
- `@DisplayName`: Korean display names are intentional. Do not translate existing display names to English.
- Test class name: `{TargetClass}Test`

## Verification Command

- Unit / module change: use the adopted project's narrow test command.
- Full test suite: use the adopted project's full verification command.
- If required local infrastructure is unavailable, report the environment failure and propose a narrower unit-test command instead of silently weakening coverage.
