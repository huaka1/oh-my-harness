# Implementer Subagent Prompt Template

Use this template when dispatching an implementer subagent.

```text
Subagent:
  description: "Implement Task N: [task name]"
  model: [MODEL if supported]
  prompt: |
    You are implementing Task N: [task name].

    ## Task Description

    Read your task brief first: [BRIEF_FILE]
    It contains the full task text from the plan.

    ## Context

    [Scene-setting: where this fits, dependencies, architectural context]

    Global constraints that bind this task:
    [GLOBAL_CONSTRAINTS]

    ## Before You Begin

    If requirements, acceptance criteria, dependencies, or interfaces are
    unclear, ask before editing. Do not guess.

    ## Your Job

    1. Implement exactly what the task specifies.
    2. Write tests and follow TDD when the task requires it.
    3. Verify the focused tests for your change.
    4. Self-review.
    5. Write your report to [REPORT_FILE].

    Work from: [directory]

    Never run `git add`, `git commit`, or `git push`. Do not write git history
    or index state. The user manages git manually.

    ## Code Organization

    - Follow the file structure and interfaces from the plan.
    - Each file should have one clear responsibility.
    - If the task needs architecture decisions not in the plan, stop and report
      NEEDS_CONTEXT or BLOCKED.
    - Improve code you touch when it directly supports the task, but do not
      restructure unrelated code.

    ## Self-Review

    Check:
    - Did I implement every requirement and no extras?
    - Are names clear and interfaces consistent with the plan?
    - Are tests behavior-focused, not mock-focused?
    - Is output clean with no unexpected warnings?
    - Did I avoid overbuilding?

    Fix self-review issues before reporting.

    ## Report Format

    Write the detailed report to [REPORT_FILE]:
    - What changed
    - Files changed
    - Tests run and exact results
    - TDD evidence when applicable:
      - RED: command, failing output, why expected
      - GREEN: command, passing output
    - Self-review findings and fixes
    - Concerns, if any

    Return only:
    - Status: DONE | DONE_WITH_CONCERNS | BLOCKED | NEEDS_CONTEXT
    - One-line test summary
    - Report file path
    - Concerns, if any
```
