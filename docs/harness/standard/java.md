# Java Engineering Standard

Use this standard for Java libraries, services, CLIs, and agent integrations.

## Default Choices

- Prefer current LTS Java for new projects.
- Use Maven or Gradle consistently; do not mix them without a migration plan.
- Use JUnit 5 for tests.
- Use a formatter and static analysis in CI.
- Use structured logging and explicit configuration.

## Project Structure

Use conventional Java layout unless the framework requires otherwise:

```text
src/main/java/
src/main/resources/
src/test/java/
src/test/resources/
pom.xml or build.gradle
README.md
```

Keep packages aligned with domain boundaries. Do not create technical layers that
force every feature to spread across many files without a reason.

## Build And Dependencies

- Pin plugin versions.
- Keep dependency scopes correct.
- Avoid unnecessary annotation processors.
- Use dependency analysis to remove unused dependencies.
- Use a BOM when the framework ecosystem provides one.
- Do not introduce framework starters for one class of functionality.

## Code Style And Static Analysis

- Use a formatter such as Spotless or the team's existing formatter.
- Use static analysis such as Checkstyle, PMD, SpotBugs, or Error Prone where appropriate.
- Treat generated code as generated; do not hand-edit it.
- Keep nullability explicit through annotations, Optional, validation, or framework contracts.

## Testing

- Use JUnit 5.
- Prefer fast unit tests for domain logic.
- Use integration tests for database, messaging, HTTP, and framework wiring.
- Avoid sleeps in async tests; wait on conditions or events.
- Use Testcontainers when external infrastructure behavior matters.
- Keep tests independent and order-insensitive.

## Error Handling

- Use domain exceptions for domain failures.
- Convert infrastructure exceptions at boundaries.
- Do not swallow interrupted exceptions; restore interrupt status when appropriate.
- Return meaningful HTTP errors for service APIs.
- Log failures once at the right boundary.

## Configuration And Secrets

- Use typed configuration where the framework supports it.
- Keep secrets in environment variables or secret managers.
- Do not commit local config with real credentials.
- Keep defaults safe for local development.

## Services

- Keep controllers thin.
- Put business behavior in testable services or domain objects.
- Validate inputs at API boundaries.
- Use health checks for deployed services.
- Include correlation ids in logs.
- Make migrations explicit and reversible where possible.

## Agent Integrations

- Keep MCP or tool schemas typed and versioned.
- Separate model/client code from domain logic.
- Validate model outputs before side effects.
- Use reactive streams only when backpressure or streaming is required.
- Add eval or contract tests for tool behavior.

## CI Checklist

- [ ] Compile.
- [ ] Format check.
- [ ] Static analysis.
- [ ] Unit tests.
- [ ] Integration tests where relevant.
- [ ] Dependency vulnerability scan.
- [ ] Package build.
