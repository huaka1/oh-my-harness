# Agent Engineering Standard

Use this standard when building agent runtimes, harnesses, MCP servers, tools,
memory systems, evals, or AI-assisted workflows.

## Loop Invariants

An agent loop must enforce:

- Every tool call receives exactly one structured result.
- Tool arguments are validated before execution.
- Permission is checked before every side effect.
- Step, time, token, cost, and tool-call budgets are explicit.
- Errors, denials, and timeouts become observations, not crashes.
- The harness executes actions; the model proposes actions.

## Tool Contract

Every tool must define:

- Name and purpose.
- Input schema and output schema.
- Risk class and side-effect class.
- Resource scope.
- Permission policy.
- Timeout.
- Result-size limit.
- When not to use the tool.

Prefer narrow, typed, domain tools over broad tools such as `execute_anything`.

## Permissions

- Reads may be allowlisted by default.
- Writes require scoped permission.
- External communication, destructive actions, financial actions, and identity access require explicit approval.
- Draft and commit must be separate for high-risk side effects.
- Non-idempotent operations must not be retried without idempotency keys.

## Context And Memory

- Separate conversation state, session state, and long-term memory.
- Label context as trusted, semi-trusted, or untrusted.
- Never store secrets in prompts, memory, traces, or tool arguments.
- Compaction must preserve objective, constraints, active plan, approvals, inspected resources, artifacts, errors, and pending tasks.

## Evals And Launch Gates

- Maintain a version-controlled golden set for expected behavior.
- Add regression cases for every production incident or serious bug.
- Include adversarial cases for prompt injection and unsafe tool use.
- Run a fast eval suite on every meaningful change.
- Use a rubric for LLM-as-judge, preferably with a different model family.

## Observability

- Propagate a turn, run, or session id through logs and traces.
- Record model, prompt version, tool calls, duration, cost, status, and stop reason.
- Redact PII and secrets before logs leave the process.
- Persist failure state so the next agent can diagnose without rerunning everything.

## Anti-Patterns

- Multi-agent orchestration before a single-agent loop has measurable limits.
- Prompt advice for failures that should become validation, policy, or evals.
- Unbounded tool results dumped into context.
- Tools with hidden side effects.
- Guardrails implemented only in the same model that performs the task.
