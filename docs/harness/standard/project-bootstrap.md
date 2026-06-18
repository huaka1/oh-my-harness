# Project Bootstrap Standard

Use this standard when creating a new repository or making an existing project
ready for agent-assisted development.

## Required Project Assets

Every project should provide these entry points:

| Asset | Purpose |
| --- | --- |
| `README.md` | What the project does, how to run it, how to test it |
| `AGENTS.md` or equivalent | Agent-specific working rules and local constraints |
| `docs/harness/standard/` | Portable engineering standards used by agents |
| `docs/harness/design/` | Durable design notes and ADRs |
| `docs/harness/knowledge/` | Lessons learned and project-specific patterns |
| Test command | One documented command that verifies behavior |
| Format/lint command | One documented command that checks code health |
| CI workflow | Runs the same verification commands used locally |

## Default Repository Shape

Prefer a small, discoverable structure:

```text
README.md
AGENTS.md
docs/
  harness/
    standard/
    design/
    knowledge/
src/ or app/
tests/
scripts/ or justfile
```

Do not create directories without a clear first use. Empty architecture is not
architecture.

## Agent-Friendly Requirements

- Document the install, run, test, lint, type-check, and build commands.
- Keep commands copy-pasteable and non-interactive.
- Prefer one command per task over long prose instructions.
- Pin or lock dependencies when reproducibility matters.
- Keep generated files, secrets, caches, and local state out of version control.
- Add a short design note before large architectural changes.
- Keep project-specific rules in the project; keep general reusable rules in standards.

## New Project Checklist

- [ ] Choose the relevant standards from `docs/harness/standard/`.
- [ ] Create minimal source and test layout.
- [ ] Add dependency and runtime version files.
- [ ] Add format, lint, type-check, and test commands.
- [ ] Add CI using the same commands.
- [ ] Add README quickstart.
- [ ] Add agent instructions and local constraints.
- [ ] Add a first design note if the architecture is not obvious.
