---
paths:
  - "common/**/*.java"
  - "services/**/*.java"
  - "gateway/**/*.java"
  - "**/build.gradle.kts"
  - "settings.gradle.kts"
  - "gradle/**/*.toml"
---

# Optional Spring Boot Example Rules

These rules are not part of the generic AI Workflow Harness core. They are kept
as an optional example/profile surface for projects that adopt the harness with
Spring Boot backend code.

MUST:

- Follow the Java and Spring conventions already present in the adopted project.
- Keep package names aligned with the adopted project's namespace.
- Use the adopted project's declared build tool and verification commands.
- Use MyBatis `#{}` parameters. Use `${}` only with whitelist validation and an explanatory comment.
- Use Lombok intentionally: prefer `@Getter`, `@Builder`, `@RequiredArgsConstructor`, and `@Slf4j`; do not use `@Data`.
- Keep annotation processor order consistent with the adopted project.
- Keep shared exception and response handling in the adopted project's established shared module.

NEVER:

- Add service-specific domain logic to `common-core`.
- Add default secret values for `JWT_SECRET`, `DB_PASSWORD`, or similar sensitive settings.
- Log full tokens, passwords, or `Authorization` header values.

## Comments

MUST:

- Add class-level Javadoc only for: architecture boundaries, security-sensitive logic, complex state.
  Skip for DTOs, mappers, and standard CRUD controllers.
- Use `// Korean reason — English technical term` for inline comments. Explain WHY, not WHAT.
- Let `@Operation`, `@Schema`, and `@DisplayName` serve as documentation in their contexts.

NEVER:

- Add comments that repeat what the code already expresses.
- Add file headers (no-header policy; LICENSE file covers the project).

Full reference: `docs/HARNESS-MAINTAINER-GUIDE.md`
