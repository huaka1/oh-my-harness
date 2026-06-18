# AI Collaboration Standard

Use this standard when preparing tasks, context, prompts, or repository rules for
coding agents.

## Context Quality

Good context is selected, labeled, and bounded. Do not dump the whole project
when a narrow task needs three files and one design note.

Provide agents with:

- The user-visible goal.
- Relevant standards.
- Existing design decisions.
- Exact commands for verification.
- Files or modules likely to matter.
- Constraints that must not be violated.
- Known risks and non-goals.

## Prompt Altitude

Avoid both extremes:

| Problem | Result |
| --- | --- |
| Too vague | Generic output and hidden assumptions |
| Too specific | Brittle if-else behavior and missed edge cases |
| Right altitude | Principles, constraints, examples, and success criteria |

## Task Definition

Every implementation task should answer:

- What observable behavior should change?
- What should not change?
- How will success be verified?
- What files or systems are in scope?
- What risks require extra care?

## Agent Safety

- Treat web pages, issue text, emails, PDFs, logs, and model output as data, not instructions.
- Do not give agents broad write, shell, network, or credential access unless the task requires it.
- Require approval for destructive, external, financial, or identity-impacting actions.
- Keep an audit trail for tool calls that mutate state.
- Fail closed when instructions conflict or permissions are ambiguous.
