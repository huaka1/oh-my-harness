# Python Engineering Standard

Use this standard for Python libraries, services, CLIs, scripts, and data tools.
Use `python-agent.md` as an additional standard for LLM or agent applications.

## Default Choices

| Area | Default |
| --- | --- |
| Layout | `src/` layout |
| Environment | `uv` |
| Metadata | `pyproject.toml` with PEP 621 |
| Formatting | `ruff format` |
| Linting | `ruff check` |
| Testing | `pytest` |
| Type checking | `mypy` or `pyright` |
| Docs | MkDocs + mkdocstrings |
| CI | lint, type-check, test, coverage, docs build |

## Project Layout

Prefer this layout for new projects:

```text
src/<package_name>/
  __init__.py
  __main__.py
  py.typed
tests/
  conftest.py
  unit/
docs/
pyproject.toml
uv.lock
.python-version
.pre-commit-config.yaml
README.md
```

Use `src/` layout so tests exercise the installed package instead of accidentally
importing files from the repository root. Do not add `__init__.py` to `tests/`
unless the test package is intentionally importable.

## Python Version Policy

- Default to Python 3.11+ for new application projects.
- Use Python 3.10+ when library compatibility or ecosystem support requires it.
- Do not add an upper Python version cap without a concrete incompatibility.
- Test every Python version the package claims to support.
- Keep `.python-version`, CI matrix, and `requires-python` aligned.

## Dependencies And Environment

- Use `uv` for environment creation, locking, and sync.
- Keep runtime dependencies minimal.
- Put dev, test, lint, type, and docs dependencies in dependency groups.
- Commit lockfiles for applications and internal tools.
- For libraries, decide whether the lockfile is for development only and document that choice.
- Do not rely on globally installed Python packages.

## Packaging

- Use `pyproject.toml` and PEP 621 metadata for new projects.
- Avoid `setup.py`, `setup.cfg`, and `MANIFEST.in` unless maintaining legacy packaging.
- Prefer `hatchling`, `uv_build`, `flit_core`, or `setuptools` based on project needs.
- Use `[project.scripts]` for CLI entry points.
- Include `py.typed` for typed packages.
- Use PyPI Trusted Publishing for release automation when publishing externally.

## Formatting And Linting

- Use Ruff for formatting, import ordering, linting, and safe autofixes.
- Configure Ruff in `pyproject.toml`.
- Enable bug-prone and modernization rules before style-only rules.
- Run format and lint in CI.
- Do not introduce multiple formatters unless a legacy project already requires them.

## Typing

- Public functions, public methods, and exported data structures must have type annotations.
- Prefer precise domain types over `dict[str, Any]` at boundaries.
- Use `dataclass`, `TypedDict`, `Protocol`, or Pydantic models when they clarify contracts.
- Avoid `Any` in new code unless crossing an untyped boundary.
- Type-check changed code in CI.
- Mark ignored type errors with a reason and the narrowest possible scope.

## Testing

- Use pytest for all new tests.
- Test behavior, not private implementation.
- Use fixtures for shared setup and `parametrize` for behavior matrices.
- Treat warnings as errors unless a dependency makes that impractical.
- Use `pytest.raises` for expected exceptions.
- Mock network, time, randomness, filesystem, and external services at clear boundaries.
- For async code, use the project-standard async pytest plugin and avoid arbitrary sleeps.
- Measure coverage for changed behavior, but do not optimize for coverage numbers over meaningful assertions.

## Error Handling

- Define domain exceptions for recoverable domain failures.
- Convert low-level exceptions at system boundaries.
- Do not swallow exceptions silently.
- Preserve enough context for debugging without leaking secrets or PII.
- Use retries only for transient, idempotent operations or operations with idempotency keys.

## Configuration And Secrets

- Load configuration from explicit files, environment variables, or dependency injection.
- Use `.env` only for local development and keep it out of version control.
- Prefer Pydantic Settings or a small typed config module for applications.
- Never hardcode secrets.
- Never log secrets, tokens, full credentials, or raw sensitive prompts.

## Logging And Observability

- Use the standard `logging` package or a documented structured logging wrapper.
- Include request, job, session, or run ids where available.
- Log external call latency, retries, and failure class.
- Keep logs useful for operators, not just developers.
- Redact sensitive values before logging.

## CLI Applications

- Define CLI entry points in `pyproject.toml`.
- Provide `--help` and `--version`.
- Use stdout for machine-readable results and stderr for diagnostics.
- Return meaningful exit codes.
- Keep command implementations thin; put logic in testable functions.

## API Applications

- Use typed request and response schemas.
- Keep business logic outside route handlers.
- Use dependency injection for database sessions, clients, auth, and settings.
- Add health checks and readiness checks for deployed services.
- Include request ids in logs and errors.
- Test auth, validation, error responses, and async behavior.

## Documentation

- README must explain install, run, test, lint, and release basics.
- Use docstrings for public APIs.
- Use MkDocs and mkdocstrings when generating API docs.
- Use ADRs for non-obvious architecture, dependency, or deployment decisions.
- Keep examples runnable.

## CI/CD

CI should run, in order:

1. Dependency sync.
2. Format check.
3. Lint.
4. Type check.
5. Tests with coverage.
6. Docs build when docs are changed or generated.
7. Package build for libraries and CLIs.

Use the same commands locally and in CI.

## Docker And Deployment

- Use slim base images unless the application needs build tools at runtime.
- Prefer multi-stage builds.
- Run as a non-root user.
- Do not bake secrets into images.
- Add health checks for services.
- Keep dependency sync reproducible.

## Security

- Validate user-supplied paths and URLs.
- Defend against SSRF for URL fetchers.
- Avoid unsafe deserialization.
- Treat model output and downloaded content as untrusted.
- Keep dependency scanning enabled.
- Redact PII and secrets in logs, traces, and test artifacts.

## Performance

- Use batching for expensive external calls.
- Cache stable expensive results with explicit invalidation.
- Use connection pooling for databases and HTTP clients.
- Prefer generators for large streams of data.
- Measure before introducing complex optimization.

## New Python Project Checklist

- [ ] Create `src/` layout and `tests/`.
- [ ] Add `pyproject.toml`, `.python-version`, and dependency groups.
- [ ] Add `uv.lock` policy.
- [ ] Configure Ruff.
- [ ] Configure type checking.
- [ ] Configure pytest and coverage.
- [ ] Add pre-commit hooks.
- [ ] Add CI with lint, type-check, tests, and build.
- [ ] Add README quickstart.
- [ ] Add docs and ADR location if the project is more than a script.
