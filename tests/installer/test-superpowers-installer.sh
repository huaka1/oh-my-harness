#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
LIB="$REPO_ROOT/scripts/lib/superpowers-installer.sh"

FAILURES=0
TEST_ROOT=""

pass() {
  echo "  [PASS] $1"
}

fail() {
  echo "  [FAIL] $1"
  FAILURES=$((FAILURES + 1))
}

assert_equals() {
  local actual="$1"
  local expected="$2"
  local description="$3"

  if [[ "$actual" == "$expected" ]]; then
    pass "$description"
  else
    fail "$description"
    echo "    expected: $expected"
    echo "    actual:   $actual"
  fi
}

assert_file_exists() {
  local path="$1"
  local description="$2"

  if [[ -f "$path" ]]; then
    pass "$description"
  else
    fail "$description"
    echo "    missing file: $path"
  fi
}

assert_dir_exists() {
  local path="$1"
  local description="$2"

  if [[ -d "$path" ]]; then
    pass "$description"
  else
    fail "$description"
    echo "    missing directory: $path"
  fi
}

assert_path_absent() {
  local path="$1"
  local description="$2"

  if [[ ! -e "$path" ]]; then
    pass "$description"
  else
    fail "$description"
    echo "    expected absent: $path"
  fi
}

cleanup() {
  if [[ -n "$TEST_ROOT" && -d "$TEST_ROOT" ]]; then
    rm -rf "$TEST_ROOT"
  fi
}
trap cleanup EXIT

setup_env() {
  TEST_ROOT="$(mktemp -d)"
  export SP_HOME="$TEST_ROOT/home"
  export SP_PROJECT_DIR="$TEST_ROOT/project"
  export SP_STATE_DIR="$TEST_ROOT/state"
  export SP_REPO_ROOT="$REPO_ROOT"
  mkdir -p "$SP_HOME" "$SP_PROJECT_DIR" "$SP_STATE_DIR"
}

run_tests() {
  setup_env
  if [[ ! -f "$LIB" ]]; then
    fail "installer library exists"
    echo "    missing file: $LIB"
    return 1
  fi
  # shellcheck source=/dev/null
  source "$LIB"

  echo "=== installer target resolution ==="
  assert_equals "$(sp_skill_base claude-code global)" "$SP_HOME/.claude/skills" "Claude Code global skill base"
  assert_equals "$(sp_skill_base claude-code project)" "$SP_PROJECT_DIR/.claude/skills" "Claude Code project skill base"
  assert_equals "$(sp_skill_base codex global)" "$SP_HOME/.agents/skills" "Codex global skill base"
  assert_equals "$(sp_skill_base codex project)" "$SP_PROJECT_DIR/.codex/skills" "Codex project skill base"
  assert_equals "$(sp_skill_base opencode global)" "$SP_HOME/.config/opencode/skills" "OpenCode global skill base"
  assert_equals "$(sp_skill_base opencode project)" "$SP_PROJECT_DIR/.opencode/skills" "OpenCode project skill base"

  echo "=== distribution staging ==="
  local stage="$TEST_ROOT/stage"
  sp_stage_distribution codex "$stage/codex"
  assert_file_exists "$stage/codex/skills/using-superpowers/SKILL.md" "stages using-superpowers skill"
  assert_file_exists "$stage/codex/skills/writing-plans/SKILL.md" "stages writing-plans skill"

  sp_stage_distribution opencode "$stage/opencode"
  assert_file_exists "$stage/opencode/skills/using-superpowers/SKILL.md" "stages OpenCode skills"

  echo "=== codex install and uninstall ==="
  mkdir -p "$SP_PROJECT_DIR/.codex/skills/unrelated"
  printf 'keep\n' > "$SP_PROJECT_DIR/.codex/skills/unrelated/SKILL.md"
  mkdir -p "$SP_PROJECT_DIR/.codex/skills/using-superpowers"
  printf 'old superpowers install\n' > "$SP_PROJECT_DIR/.codex/skills/using-superpowers/SKILL.md"

  sp_install_target codex project yes
  assert_file_exists "$SP_PROJECT_DIR/.codex/skills/using-superpowers/SKILL.md" "installs Codex skill directory"
  if grep -Fq "old superpowers install" "$SP_PROJECT_DIR/.codex/skills/using-superpowers/SKILL.md"; then
    fail "replaces existing same-name Superpowers skill"
  else
    pass "replaces existing same-name Superpowers skill"
  fi
  assert_file_exists "$(sp_manifest_path codex project)" "writes Codex manifest"
  assert_file_exists "$SP_PROJECT_DIR/.codex/skills/unrelated/SKILL.md" "preserves unrelated skill during install"

  sp_uninstall_target codex project yes
  assert_path_absent "$SP_PROJECT_DIR/.codex/skills/using-superpowers" "uninstalls managed Codex skill"
  assert_path_absent "$(sp_manifest_path codex project)" "removes Codex manifest"
  assert_file_exists "$SP_PROJECT_DIR/.codex/skills/unrelated/SKILL.md" "preserves unrelated skill during uninstall"

  echo "=== opencode install and uninstall ==="
  mkdir -p "$SP_PROJECT_DIR/.opencode/skills/unrelated"
  printf 'keep\n' > "$SP_PROJECT_DIR/.opencode/skills/unrelated/SKILL.md"

  sp_install_target opencode project yes
  assert_file_exists "$SP_PROJECT_DIR/.opencode/skills/using-superpowers/SKILL.md" "installs OpenCode project skills"
  assert_file_exists "$(sp_manifest_path opencode project)" "writes OpenCode manifest"

  sp_uninstall_target opencode project yes
  assert_path_absent "$SP_PROJECT_DIR/.opencode/skills/using-superpowers" "uninstalls managed OpenCode skill"
  assert_path_absent "$(sp_manifest_path opencode project)" "removes OpenCode manifest"
  assert_file_exists "$SP_PROJECT_DIR/.opencode/skills/unrelated/SKILL.md" "preserves unrelated OpenCode skill"

  echo "=== entry scripts ==="
  bash "$REPO_ROOT/scripts/superpowers-installer.sh" --action install --harness claude-code --scope project --yes >/dev/null
  assert_file_exists "$SP_PROJECT_DIR/.claude/skills/using-superpowers/SKILL.md" "CLI installs Claude Code project skills"
  bash "$REPO_ROOT/scripts/superpowers-installer.sh" --action uninstall --harness claude-code --scope project --yes >/dev/null
  assert_path_absent "$SP_PROJECT_DIR/.claude/skills/using-superpowers" "CLI uninstalls Claude Code project skills"

  bash "$REPO_ROOT/scripts/install.sh" --harness codex --scope project --yes >/dev/null
  assert_file_exists "$SP_PROJECT_DIR/.codex/skills/using-superpowers/SKILL.md" "install wrapper installs Codex project skills"
  bash "$REPO_ROOT/scripts/uninstall.sh" --harness codex --scope project --yes >/dev/null
  assert_path_absent "$SP_PROJECT_DIR/.codex/skills/using-superpowers" "uninstall wrapper removes Codex project skills"

  local tui_output
  tui_output="$(printf '4\n4\n2\n' | bash "$REPO_ROOT/scripts/superpowers-installer.sh")"
  if printf '%s' "$tui_output" | grep -Fq "opencode (project): not installed"; then
    pass "no-argument TUI can run status for all project targets"
  else
    fail "no-argument TUI can run status for all project targets"
    echo "$tui_output" | sed 's/^/    /'
  fi
}

run_tests

if [[ "$FAILURES" -gt 0 ]]; then
  echo ""
  echo "$FAILURES test(s) failed"
  exit 1
fi

echo ""
echo "All installer tests passed"
