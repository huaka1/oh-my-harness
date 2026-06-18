---
name: writing-plans
description: Use when you have a spec or requirements for a multi-step task, before touching code
---

# Writing Plans

## Overview

Write implementation plans for an engineer with zero repository context and
questionable judgment. The plan must say which files to touch, what interfaces
each task consumes and produces, how to test each step, and what evidence proves
the work is done. DRY. YAGNI. TDD.

**Announce at start:** "I'm using the writing-plans skill to create the implementation plan."

**Save plans to:** `docs/harness/plan/YYYY-MM-DD-<feature-name>-plan.md`
- User preferences for plan location override this default.

**Before planning, read when present:**
- `docs/harness/standard/` for engineering standards
- `docs/harness/design/` for durable architecture decisions
- `docs/harness/knowledge/` for lessons and cached project knowledge

**Git policy:** Do not add commit steps. Do not instruct agents to run
`git add`, `git commit`, or `git push`. The user manages git history manually.

## Scope Check

If the spec covers multiple independent subsystems, suggest separate plans.
Each plan should produce independently working, testable software.

## File Structure

Before defining tasks, map the files that will be created or modified and each
file's responsibility. Use this to lock task boundaries.

- Prefer small files with clear responsibilities and interfaces.
- Keep files that change together near each other.
- Follow existing project patterns.
- Include focused cleanup only when it directly supports the task.

## Task Right-Sizing

A task is the smallest unit that carries its own test cycle and is worth a fresh
review gate. Fold setup, configuration, and docs into the task that needs them.
Split only where a reviewer could approve one task while rejecting another.

## Plan Header

Every plan must start with:

```markdown
# [Feature Name] Implementation Plan

> **For agentic workers:** Use subagent-driven-development (recommended) or executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking. Do not run `git add`, `git commit`, or `git push`; the user manages git history manually.

**Goal:** [One sentence describing what this builds]

**Architecture:** [2-3 sentences about the approach]

**Tech Stack:** [Key technologies/libraries]

**Main Path Acceptance:** [User entry -> key action -> success result; if not user-visible, state why it is not applicable.]

## Global Constraints

[Project-wide requirements copied from the spec: version floors, dependency
limits, naming, paths, platform support, user-visible acceptance rules. Every
task implicitly includes this section.]

---
```

## Task Structure

````markdown
### Task N: [Component Name]

**Files:**
- Create: `exact/path/to/file.py`
- Modify: `exact/path/to/existing.py:123`
- Test: `tests/exact/path/to/test.py`

**Interfaces:**
- Consumes: [what this task uses from earlier tasks: exact names/signatures]
- Produces: [what later tasks rely on: exact names/signatures/return types]

- [ ] **Step 1: Write the failing test**

```python
def test_specific_behavior():
    result = function(input)
    assert result == expected
```

- [ ] **Step 2: Run test to verify it fails**

Run: `pytest tests/path/test.py::test_name -v`
Expected: FAIL with "function not defined"

- [ ] **Step 3: Write minimal implementation**

```python
def function(input):
    return expected
```

- [ ] **Step 4: Run test to verify it passes**

Run: `pytest tests/path/test.py::test_name -v`
Expected: PASS
````

## No Placeholders

Never write:
- `TBD`, `TODO`, `implement later`, or "fill in details"
- "Add appropriate error handling" without exact behavior
- "Write tests for the above" without test code
- "Similar to Task N"
- Steps that describe code changes without showing the code
- Types, functions, or methods not defined in the plan

## Main Path Acceptance

If the spec changes user-visible behavior, include a final acceptance task that
proves the main path works. If not applicable, state why in the plan header or
final task.

## Self-Review

After writing the plan, check it yourself:

- Spec coverage: every requirement maps to a task.
- Placeholder scan: no forbidden placeholder patterns remain.
- Type consistency: later task signatures match earlier task outputs.
- Main path: user-visible behavior has a concrete acceptance path.
- Git policy: no task asks an agent to stage, commit, or push.

Fix issues inline before handing off.

## Execution Handoff

After saving the plan, offer:

**"Plan complete and saved to `docs/harness/plan/<filename>.md`. Two execution options:**

**1. Subagent-Driven (recommended)** - Fresh subagent per task with task review.

**2. Inline Execution** - Execute tasks in this session with checkpoints.

**Which approach?"**

If Subagent-Driven is chosen, use `subagent-driven-development`. If Inline
Execution is chosen, use `executing-plans`.
