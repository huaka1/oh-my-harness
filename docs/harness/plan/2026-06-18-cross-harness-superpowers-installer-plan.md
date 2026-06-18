# Cross-Harness Superpowers Installer Implementation Plan

> **For agentic workers:** Use subagent-driven-development or executing-plans to
> implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for
> tracking. Do not run `git add`, `git commit`, or `git push`; the user manages
> git history manually.

**Goal:** Build a TUI-first installer that deploys and fully removes this
Superpowers distribution across Claude Code, Codex, and OpenCode.

**Architecture:** Use a small Bash installer library for target resolution,
manifest handling, distribution staging, install, uninstall, and status. Thin
entry scripts (`install.sh`, `uninstall.sh`, `superpowers-installer.sh`) call the
same library. Tests run the library against temporary HOME/project directories
without touching real harness installs.

**Tech Stack:** Bash, POSIX utilities, `rsync` or `cp`, `mktemp`, existing shell
test style.

## Global Constraints

- Preserve existing user changes in `README.md` and `docs/harness/standard/*`.
- Install and uninstall are whole-product operations for this installer-managed
  Superpowers distribution.
- Uninstall must not remove unrelated user skills or harness config.
- The default no-argument remote entry path must enter a TUI.
- README must include `curl -fsSL ... | bash` install and uninstall commands.
- Do not run `git add`, `git commit`, or `git push`.

---

## Files

- Create: `scripts/lib/superpowers-installer.sh`
  - Shared installer implementation: target resolution, staging, install,
    uninstall, status, TUI helpers, and argument parsing helpers.
- Create: `scripts/superpowers-installer.sh`
  - Main TUI and CLI entry point.
- Create: `scripts/install.sh`
  - Remote-friendly wrapper that downloads the repository when needed and enters
    the installer with default action `install`.
- Create: `scripts/uninstall.sh`
  - Remote-friendly wrapper that downloads the repository when needed and enters
    the installer with default action `uninstall`.
- Create: `tests/installer/test-superpowers-installer.sh`
  - Temp-directory tests for install, uninstall, reinstall, status, and path
    isolation.
- Modify: `README.md`
  - Add the one-command install/uninstall section without removing existing user
    edits.

## Task 1: Installer Library Skeleton

**Files:**
- Create: `scripts/lib/superpowers-installer.sh`
- Create: `tests/installer/test-superpowers-installer.sh`

**Interfaces:**
- Produces: `sp_repo_root`, `sp_targets_for`, `sp_target_root`,
  `sp_manifest_path`, `sp_status`.
- Consumes: `SP_HOME`, `SP_PROJECT_DIR`, `SP_STATE_DIR` test overrides.

- [ ] **Step 1: Write failing tests for target resolution**

Add tests that source the library from a temporary fixture and assert:

```bash
SP_HOME="$tmp/home" SP_PROJECT_DIR="$tmp/project" sp_skill_base claude-code global
# expected: $tmp/home/.claude/skills

SP_HOME="$tmp/home" SP_PROJECT_DIR="$tmp/project" sp_skill_base codex project
# expected: $tmp/project/.codex/skills

SP_HOME="$tmp/home" SP_PROJECT_DIR="$tmp/project" sp_skill_base opencode global
# expected: $tmp/home/.config/opencode/skills
```

- [ ] **Step 2: Run the test and verify failure**

Run:

```bash
bash tests/installer/test-superpowers-installer.sh
```

Expected: failure because the library does not exist.

- [ ] **Step 3: Implement library skeleton and target resolution**

Implement target resolution for `claude-code`, `codex`, `opencode`, and `all`.
Keep functions side-effect-free until install/uninstall functions are added.

- [ ] **Step 4: Run the test and verify pass**

Run:

```bash
bash tests/installer/test-superpowers-installer.sh
```

Expected: target resolution tests pass.

## Task 2: Distribution Staging

**Files:**
- Modify: `scripts/lib/superpowers-installer.sh`
- Modify: `tests/installer/test-superpowers-installer.sh`

**Interfaces:**
- Produces: `sp_stage_distribution <harness> <stage_dir>`.
- Consumes: repository files: `skills/`.

- [ ] **Step 1: Write failing tests for staged content**

Assert that staging creates:

```text
skills/using-superpowers/SKILL.md
skills/writing-plans/SKILL.md
```

- [ ] **Step 2: Run tests and verify failure**

Run:

```bash
bash tests/installer/test-superpowers-installer.sh
```

Expected: failure because staging is not implemented.

- [ ] **Step 3: Implement staging**

Copy the required `skills/` tree into a temporary stage directory. Exclude
`.git`, tests, docs, local state, and installer manifests from installed roots.
Use `rsync` when available and `cp -R` fallback when not.

- [ ] **Step 4: Run tests and verify pass**

Run:

```bash
bash tests/installer/test-superpowers-installer.sh
```

Expected: staging tests pass.

## Task 3: Install, Uninstall, Reinstall, and Status

**Files:**
- Modify: `scripts/lib/superpowers-installer.sh`
- Modify: `tests/installer/test-superpowers-installer.sh`

**Interfaces:**
- Produces: `sp_install_target`, `sp_uninstall_target`,
  `sp_reinstall_target`, `sp_print_status`.
- Manifest fields: harness, scope, target_root, installed_at, source_root,
  source_revision.

- [ ] **Step 1: Write failing install/uninstall tests**

Assert:

```bash
sp_install_target codex project
test -f "$tmp/project/.codex/skills/superpowers/skills/using-superpowers/SKILL.md"
test -f "$(sp_manifest_path codex project)"

sp_uninstall_target codex project
test ! -e "$tmp/project/.codex/skills/superpowers"
test ! -e "$(sp_manifest_path codex project)"
```

Also create an unrelated sibling file and assert uninstall does not remove it.

- [ ] **Step 2: Run tests and verify failure**

Run:

```bash
bash tests/installer/test-superpowers-installer.sh
```

Expected: failure because install/uninstall are not implemented.

- [ ] **Step 3: Implement install/uninstall/reinstall/status**

Install by staging to a temp directory, replacing only the installer-managed
target root, and writing a manifest under the installer state directory.
Uninstall reads the manifest when present and removes only the recorded target
root and manifest.

- [ ] **Step 4: Run tests and verify pass**

Run:

```bash
bash tests/installer/test-superpowers-installer.sh
```

Expected: install, uninstall, reinstall, and status tests pass.

## Task 4: TUI and Remote Wrappers

**Files:**
- Create: `scripts/superpowers-installer.sh`
- Create: `scripts/install.sh`
- Create: `scripts/uninstall.sh`
- Modify: `tests/installer/test-superpowers-installer.sh`

**Interfaces:**
- Produces CLI flags: `--action`, `--harness`, `--scope`, `--yes`,
  `--repo-url`, `--ref`.
- TUI prompts for action, harness, scope, and confirmation when missing.

- [ ] **Step 1: Write non-interactive wrapper tests**

Test `scripts/superpowers-installer.sh --action install --harness codex --scope project --yes`
with temp overrides and assert files are installed.

- [ ] **Step 2: Run tests and verify failure**

Run:

```bash
bash tests/installer/test-superpowers-installer.sh
```

Expected: failure because entry scripts do not exist.

- [ ] **Step 3: Implement CLI/TUI entry point**

The no-argument command enters TUI. Non-interactive flags bypass prompts for
tests. The entry point prints target paths before mutating state.

- [ ] **Step 4: Implement remote wrappers**

When `install.sh` or `uninstall.sh` runs inside a checkout, call the local
installer. When streamed over `curl | bash`, download the repository archive to a
temporary directory and call the installer from there.

- [ ] **Step 5: Run tests and verify pass**

Run:

```bash
bash tests/installer/test-superpowers-installer.sh
```

Expected: entry script tests pass.

## Task 5: README Entrypoints

**Files:**
- Modify: `README.md`

**Interfaces:**
- Consumes: existing README install section.
- Produces: install and uninstall commands using raw GitHub URLs.

- [ ] **Step 1: Add README section**

Add a short section near installation:

```bash
curl -fsSL https://raw.githubusercontent.com/huaka1/oh-my-harness/main/scripts/install.sh | bash
curl -fsSL https://raw.githubusercontent.com/huaka1/oh-my-harness/main/scripts/uninstall.sh | bash
```

- [ ] **Step 2: Verify docs mention TUI and full uninstall**

Search:

```bash
rg -n "curl -fsSL|full uninstall|TUI|Claude Code|Codex|OpenCode" README.md
```

Expected: README contains both commands and explains the interactive flow.

## Task 6: Final Verification

**Files:**
- Test: `tests/installer/test-superpowers-installer.sh`
- Test: existing smoke tests as feasible.

- [ ] **Step 1: Run installer tests**

```bash
bash tests/installer/test-superpowers-installer.sh
```

Expected: all tests pass.

- [ ] **Step 2: Run shell syntax checks**

```bash
bash -n scripts/lib/superpowers-installer.sh scripts/superpowers-installer.sh scripts/install.sh scripts/uninstall.sh tests/installer/test-superpowers-installer.sh
```

Expected: no syntax errors.

- [ ] **Step 3: Inspect git diff**

```bash
git diff --stat
git diff -- README.md scripts tests docs/harness/feature docs/harness/plan
```

Expected: only intended files changed; no generated temp state is tracked.
