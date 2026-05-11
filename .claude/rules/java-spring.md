---
paths:
  - "common/**/*.java"
  - "services/**/*.java"
  - "gateway/**/*.java"
  - "**/build.gradle.kts"
  - "settings.gradle.kts"
  - "gradle/**/*.toml"
---

# Java And Spring Rules

MUST:

- Use Java 21+ and Spring Boot 3.5.x conventions already present in the repository.
- Keep packages under `io.kyungseo.msa`.
- Use the Gradle wrapper for build and verification.
- Use MyBatis `#{}` parameters. Use `${}` only with whitelist validation and an explanatory comment.
- Use Lombok intentionally: prefer `@Getter`, `@Builder`, `@RequiredArgsConstructor`, and `@Slf4j`; do not use `@Data`.
- Keep MapStruct annotation processor order as Lombok before MapStruct.
- Keep `common-core` as the single shared handler location for `BusinessException`.

NEVER:

- Add service-specific domain logic to `common-core`.
- Add default secret values for `JWT_SECRET`, `DB_PASSWORD`, or similar sensitive settings.
- Log full tokens, passwords, or `Authorization` header values.
