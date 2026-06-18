# Cross-Harness Superpowers Installer

## Problem

This fork should be easier to install and remove across Claude Code, Codex, and
OpenCode without asking users to clone the repository first. The repository is
skills-first, but it does not provide one TUI installer that can deploy or fully
remove the customized skill distribution for a selected harness.

The user wants to keep the core workflow close to upstream while preserving two
local policies:

- Agents should inspect `docs/harness/standard/`, `docs/harness/design/`, and
  `docs/harness/knowledge/` when those files are relevant to design, planning,
  or implementation.
- Agents must not automatically run `git add`, `git commit`, or `git push`;
  git history remains user-controlled.

## Goals

- Provide a TUI-first installer that can be launched by `curl | bash`.
- Support Claude Code, Codex, OpenCode, and an all-harness option.
- Support global and project installation scopes.
- Treat install and uninstall as whole-product operations for this
  Superpowers distribution, not partial override management.
- Keep the implementation dependency-light and shell-friendly.
- Preserve the current skills-first repository structure while adding an
  install/uninstall layer.

## Non-Goals

- Do not submit this as an upstream PR.
- Do not delete user-owned skills or unrelated harness config.
- Do not implement multi-version coexistence in the first pass.
- Do not rely on hidden harness state that the installer cannot record or
  remove later.
- Do not rewrite all skills in this pass.

## Product Semantics

### Install

An install deploys this repository's Superpowers distribution for the selected
harness and scope. The installer writes a manifest that records the installed
skill directories so uninstall can remove the same product cleanly.
If same-name Superpowers skill directories already exist, install replaces them
as part of taking over the selected product. Unrelated sibling skills remain
untouched.

### Uninstall

An uninstall removes the entire Superpowers installation deployed by this
installer for the selected harness and scope. It removes the installed skills
and the installer manifest. It does not remove unrelated user skills or
unrelated harness configuration.

### Reinstall

A reinstall runs uninstall for the selected target, then install.

### Status

Status reports whether each selected target has an installer manifest, where
the product is installed, and which source revision/version was installed.

## Harness Targets

The installer supports:

- `claude-code`
- `codex`
- `opencode`
- `all`

Each harness supports:

- `global`
- `project`

Global defaults:

- Claude Code skills: each managed skill directory under `~/.claude/skills/`
- Codex skills: each managed skill directory under `~/.agents/skills/`
- OpenCode skills: each managed skill directory under `~/.config/opencode/skills/`

Project defaults:

- Claude Code skills: each managed skill directory under `.claude/skills/`
- Codex skills: each managed skill directory under `.codex/skills/`
- OpenCode skills: each managed skill directory under `.opencode/skills/`

## TUI Flow

Running the remote installer without arguments enters an interactive TUI:

1. Select action: install, uninstall, reinstall, status.
2. Select harness: Claude Code, Codex, OpenCode, or all.
3. Select scope: global or project.
4. Show target paths and ask for confirmation before writes or deletes.
5. Execute the selected action.

Non-interactive flags are allowed for tests and automation, but the README entry
points should default to the TUI.

## README Entrypoints

The README should expose one-command entry points:

```bash
curl -fsSL https://raw.githubusercontent.com/huaka1/oh-my-harness/main/scripts/install.sh | bash
```

```bash
curl -fsSL https://raw.githubusercontent.com/huaka1/oh-my-harness/main/scripts/uninstall.sh | bash
```

Both scripts should enter the same TUI. `install.sh` defaults the action to
install when the user accepts defaults; `uninstall.sh` defaults the action to
uninstall.

## Upstream Alignment

Upstream `obra/superpowers` is currently at `v6.0.2` on `upstream/main` in this
checkout. The notable workflow divergence for this fork is local
`subagent-driven-development`, which still uses an older two-reviewer flow while
upstream v6 uses a single task reviewer that returns spec and quality verdicts.

The installer work should not depend on completing that skill migration, but the
distribution model must leave room for a later upstream-aligned skill sync.

## Main Path Acceptance

### User Path

User opens README -> copies a `curl | bash` command -> enters TUI -> selects
harness and scope -> confirms install or uninstall -> sees a success message and
status manifest.

### Must Pass

- The TUI can run from a cloned checkout.
- The remote-style scripts can run from a temporary downloaded copy without the
  user cloning the repo first.
- Install writes the complete managed skill set for the selected harness and
  scope.
- Uninstall removes the complete installer-managed skill set for the selected
  harness and scope.
- Status reports installed and missing targets accurately.
- README documents install and uninstall commands.

### Blocking Failures

- The installer removes unrelated user skills or config.
- Uninstall leaves a half-installed Superpowers distribution for a selected
  target.
- The TUI cannot be used without passing flags.
- The README command requires a prior `git clone`.
- The installer silently commits, stages, or pushes git changes.
