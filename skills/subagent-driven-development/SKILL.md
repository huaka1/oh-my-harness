---
name: subagent-driven-development
description: Use when executing implementation plans with independent tasks in the current session
---

# Subagent-Driven Development

Execute an implementation plan by dispatching a fresh implementer subagent per
task, then one task reviewer that checks both spec compliance and code quality.
Run a broad final review after all tasks complete.

**Core principle:** fresh implementer per task + single task reviewer (spec and
quality) + broad final review = faster iteration with less reviewer overhead.

**Git policy:** Do not ask subagents to run `git add`, `git commit`, or
`git push`. The user manages git history manually. Use working-tree review
packages instead of commit-based task gates in this fork.

**Continuous execution:** Do not pause between tasks to ask whether to continue.
Stop only for an unresolvable blocker, true ambiguity, or completion.

## When To Use

Use this when:
- You have an implementation plan.
- Tasks are mostly independent.
- The work should stay coordinated from the current session.

Use `executing-plans` instead when tasks are tightly coupled or should be run in
the current context with human checkpoints.

## Process

1. Read the plan once.
2. Read relevant `docs/harness/standard/`, `docs/harness/design/`, and
   `docs/harness/knowledge/` files when present.
3. Note Global Constraints and task interfaces from the plan.
4. Create todos for all tasks.
5. For each task:
   - Generate a task brief with `scripts/task-brief PLAN_FILE N`.
   - Dispatch one implementer using `implementer-prompt.md`.
   - Ask the implementer to write its detailed report to the report file.
   - Generate a review package with `scripts/review-package BASE WORKTREE`.
   - Dispatch one task reviewer using `task-reviewer-prompt.md`.
   - If Critical or Important findings appear, dispatch one fix subagent,
     append fix evidence to the report, regenerate the review package, and
     re-review.
   - Mark the task complete only after spec compliance passes and task quality
     is approved.
6. After all tasks, dispatch a broad final code review with
   `requesting-code-review/code-reviewer.md`.
7. Use `finishing-a-development-branch` for final handoff options.

## Pre-Flight Plan Review

Before Task 1, scan the plan for contradictions:
- Task text contradicts Global Constraints.
- A task mandates something the review rubric treats as a defect.
- Interfaces are missing or inconsistent.
- The plan asks any agent to stage, commit, or push.

Batch any findings into one question before execution. If clean, proceed.

## Model Selection

Use the least powerful model that can do the job reliably.

- Mechanical single-file tasks: cheaper/faster model.
- Multi-file integration or debugging: standard model.
- Architecture, subtle reviews, final whole-branch review: strongest available
  model.

Always specify the model when dispatching a subagent if the harness supports
model selection. An omitted model often inherits the session's most expensive
model.

## Handling Implementer Status

Implementers report one status:

- **DONE:** Generate the review package and dispatch the task reviewer.
- **DONE_WITH_CONCERNS:** Read concerns first; address correctness or scope
  concerns before review.
- **NEEDS_CONTEXT:** Provide missing context and re-dispatch.
- **BLOCKED:** Change something before retrying: provide context, use a stronger
  model, split the task, or escalate a bad plan.

Never ignore an escalation or repeat the same dispatch unchanged.

## File Handoffs

Do not paste long task text, reports, or diffs into the controller context.
Hand artifacts over as files:

- **Task brief:** `scripts/task-brief PLAN_FILE N` writes a task-only brief.
- **Report file:** name it beside the brief, e.g. `task-N-report.md`.
- **Review package:** `scripts/review-package BASE WORKTREE` writes a diff
  package for the reviewer. `BASE` is usually the commit at the start of the
  current execution wave. `WORKTREE` means review the current working tree
  without requiring commits.
- **Reviewer inputs:** pass the brief file, report file, review package, and
  Global Constraints.

## Durable Progress

Track progress in a ledger, not only in conversation memory:

```bash
cat "$(git rev-parse --git-path sdd)/progress.md" 2>/dev/null || true
```

Append one line after each approved task:

```text
Task N: complete (review clean, report <path>)
```

After compaction, trust the ledger and the working tree over recollection.

## Prompt Templates

- `implementer-prompt.md` - Dispatch implementer subagent.
- `task-reviewer-prompt.md` - Dispatch one task reviewer for spec compliance and
  code quality.
- Final whole-branch review: use `requesting-code-review/code-reviewer.md`.

## Reviewer Findings

- Critical or Important findings block the task.
- Minor findings can be recorded in the ledger and revisited in the final
  review.
- If a finding conflicts with the plan, present the finding and the plan text to
  the user. Do not silently override either.
- Dispatch one fix subagent with all findings for that task, not one fixer per
  finding.

## Red Flags

Never:
- Skip the task review.
- Continue with unresolved Critical or Important findings.
- Dispatch multiple implementers that edit the same working tree concurrently.
- Ask subagents to stage, commit, or push.
- Let the implementer self-review replace task review.
- Paste large diffs into the main context.
- Lose track of progress outside the conversation.
