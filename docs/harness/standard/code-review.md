# Code Review Standard

Use this standard when reviewing code before merge, handoff, release, or a large
agent-generated change.

## Review Priorities

| Priority | Blocks merge? | Examples |
| --- | --- | --- |
| Critical | Yes | Security vulnerability, data loss, auth bypass, broken core behavior |
| Important | Usually | Missing tests, unclear ownership, performance regression, brittle design |
| Suggestion | No | Naming, readability, small simplification, optional docs polish |

## Required Review Areas

- Correctness: Does the code implement the intended behavior?
- Tests: Would tests fail if the behavior regressed?
- Security: Are inputs, secrets, auth, permissions, and outputs handled safely?
- Maintainability: Is the change understandable and local?
- Architecture: Does dependency direction stay clean?
- Performance: Are there obvious N+1, unbounded loops, memory leaks, or blocking calls?
- Operations: Are errors, logs, metrics, and rollback behavior adequate?
- Documentation: Can a fresh reader use or maintain the changed behavior?

## Comment Format

Use this format for actionable findings:

```markdown
**[Priority] Category: brief title**

What is wrong and where it matters.

Why this matters: concrete failure mode.

Suggested fix: specific change or direction.
```

## Agent Review Rules

- Findings come before praise or summaries.
- Do not claim a problem without evidence.
- Do not request broad rewrites when a local fix is enough.
- Do not review generated code more leniently than human code.
- If no findings are found, state residual risks and what was not tested.
