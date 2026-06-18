# Code Quality Standard

Use this standard for all production code unless a more specific language
standard overrides it.

## Core Principles

- Make the smallest correct change.
- Prefer clear boundaries over clever abstractions.
- Keep code easy to test without network, time, or global state.
- Make invalid states hard to represent.
- Treat external input, model output, and stored data as untrusted.
- Optimize only after correctness, tests, and observability exist.

## Required Practices

- Names must describe domain intent, not implementation accidents.
- Public interfaces must document inputs, outputs, errors, and side effects.
- Side effects must be isolated behind explicit functions, classes, or tools.
- Errors must be handled at the boundary where they become meaningful.
- Tests must cover behavior, not private implementation details.
- New dependencies require a reason and an owner.
- Configuration must come from explicit files, environment, or dependency injection.
- Secrets must never appear in source, tests, docs examples, logs, prompts, or agent context.

## Avoid

- Generic helper modules that become dumping grounds.
- Silent fallbacks that hide production failures.
- Broad catch-all exceptions without logging or typed recovery.
- Hidden network calls inside constructors or import-time code.
- Global mutable state unless it is explicitly scoped and resettable.
- Premature frameworks for problems a function can solve.

## Quality Gate

Before handoff, code should pass:

- Formatting.
- Linting.
- Type checks where the language supports them.
- Unit tests for changed behavior.
- Integration tests for changed external boundaries.
- Security review for auth, secrets, input handling, file access, network access, or agent tools.
