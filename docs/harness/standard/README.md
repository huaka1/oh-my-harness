# Harness Standards

These standards are portable project defaults for agent-assisted development.
Copy this directory into a new project when you want agents to create, review,
or maintain code with consistent engineering expectations.

## How To Use

1. Read this file first.
2. Read `project-bootstrap.md` before creating a new project.
3. Read `code-quality.md`, `code-review.md`, and `ai-collaboration.md` for every project.
4. Read the language or domain standard that matches the project, such as `python.md`, `python-agent.md`, `agent.md`, or `java.md`.
5. If standards conflict, prefer the more specific standard.
6. If the project has an explicit local standard, prefer the local standard and record the exception.

## Standard Layers

| File | Use when |
| --- | --- |
| `project-bootstrap.md` | Starting or restructuring a project for agent-friendly work |
| `code-quality.md` | Writing or modifying production code |
| `code-review.md` | Reviewing code before merge or handoff |
| `ai-collaboration.md` | Preparing context, prompts, and tasks for coding agents |
| `agent.md` | Building agent runtimes, harnesses, tools, memory, or evals |
| `python.md` | Building Python libraries, services, CLIs, or scripts |
| `python-agent.md` | Building Python LLM, RAG, MCP, or agent applications |
| `java.md` | Building Java services, libraries, or agent integrations |

## Project Creation Rule

When creating a project, the agent must select the relevant standards before
choosing libraries, file layout, or implementation details. Standards are not
retroactive cleanup notes; they shape the first commit.

## Exception Rule

Exceptions are allowed when there is a concrete reason: framework constraints,
legacy compatibility, deployment target, team policy, or measured performance.
Record the exception near the decision, preferably in an ADR.
