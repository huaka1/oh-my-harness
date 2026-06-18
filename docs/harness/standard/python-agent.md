# Python Agent Application Standard

Use this standard in addition to `python.md` when building Python LLM, RAG,
MCP, workflow, or autonomous agent applications.

## Runtime Boundaries

- Keep model clients behind a small factory or adapter.
- Keep tools as typed, testable functions or classes.
- Keep prompts, schemas, and eval cases versioned with the code.
- Keep side effects outside prompt construction and model parsing.
- Treat every model response as untrusted until validated.

## LLM Client Configuration

Every LLM client wrapper should expose:

- Model name.
- Timeout.
- Retry policy.
- Rate-limit behavior.
- Cost or token accounting hook.
- Structured logging hook.
- Test double or fake implementation.

Do not scatter provider-specific client creation throughout business logic.

## Tool Design

- Tool inputs and outputs must be typed.
- Tool schemas must reject unknown or malformed fields.
- Tool descriptions must state when not to use the tool.
- Tools that mutate state must declare side effects.
- Non-idempotent tools need idempotency keys or explicit no-retry policy.
- Tool results should be bounded, summarized, or paginated.

## Prompt And Context Management

- Separate system instructions, developer instructions, user requests, retrieved data, and tool observations.
- Label untrusted retrieved content as data, not instruction.
- Do not put secrets in prompts or retrieved context.
- Preserve objective, constraints, approvals, active plan, and artifacts across compaction.
- Keep prompts reviewable in source control when they affect production behavior.

## Output Validation

- Validate structured model output with Pydantic or equivalent schemas.
- Reject partial or malformed outputs at the boundary.
- Keep repair loops bounded.
- Never execute model-generated code in the main process.
- Sanitize model-generated paths, URLs, SQL, shell commands, and API calls before use.

## Retrieval And RAG

- Store source ids and metadata with chunks.
- Use consistent chunking and embedding configuration.
- Cache embeddings when inputs are stable.
- Keep retrieval results bounded.
- Cite or persist the source of important retrieved facts.
- Evaluate retrieval quality separately from generation quality.

## Agent Loop

- Enforce step, time, token, cost, and tool-call budgets.
- Return one structured observation for every tool call.
- Convert errors, denials, and timeouts into observations.
- Require approval for destructive, external, financial, or identity-impacting actions.
- Persist enough run state to debug interrupted or failed runs.

## Evals

- Keep golden cases next to prompts or agent definitions.
- Add eval cases for known failures and regressions.
- Include adversarial prompt-injection cases.
- Use deterministic graders where possible.
- Use rubric-based LLM judges only when deterministic checks are insufficient.
- Run a fast eval suite before changing prompts, tools, retrieval, or model versions.

## Observability

Log or trace:

- Run id and turn id.
- Model and prompt version.
- Tool calls and result status.
- Latency and retry count.
- Token usage and estimated cost.
- Stop reason.
- Error class.

Redact prompts, tool arguments, and outputs when they may contain secrets or PII.

## Testing

- Unit test prompt assembly, schema validation, and tool behavior without real model calls.
- Use fake model clients for deterministic behavior.
- Integration test provider clients behind explicit markers or separate CI jobs.
- Test failure modes: timeout, malformed output, tool denial, rate limit, empty retrieval, and prompt injection.
- Do not make ordinary unit tests depend on paid APIs.

## Deployment Readiness Checklist

- [ ] Provider clients have timeout, retry, and rate-limit policy.
- [ ] Tools are typed, scoped, and permissioned.
- [ ] Model outputs are validated before use.
- [ ] Prompt and retrieval inputs are trust-labeled.
- [ ] Eval suite covers happy paths, regressions, and adversarial cases.
- [ ] Logs/traces include run ids and redact sensitive data.
- [ ] Failure state is persisted for diagnosis.
- [ ] Human approval exists for high-risk side effects.
