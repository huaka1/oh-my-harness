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

assert_contains() {
  local haystack="$1"
  local needle="$2"
  local description="$3"

  if printf '%s' "$haystack" | grep -Fq "$needle"; then
    pass "$description"
  else
    fail "$description"
    echo "    expected output to contain: $needle"
    printf '%s\n' "$haystack" | sed 's/^/    /'
  fi
}

assert_not_contains() {
  local haystack="$1"
  local needle="$2"
  local description="$3"

  if printf '%s' "$haystack" | grep -Fq "$needle"; then
    fail "$description"
    echo "    expected output not to contain: $needle"
    printf '%s\n' "$haystack" | sed 's/^/    /'
  else
    pass "$description"
  fi
}

run_with_deadline() {
  local seconds="$1"
  local output_file="$2"
  shift 2

  (
    "$@" </dev/null
  ) >"$output_file" 2>&1 &

  local pid="$!"
  local elapsed=0
  local limit=$((seconds * 10))

  while kill -0 "$pid" 2>/dev/null; do
    if (( elapsed >= limit )); then
      kill "$pid" 2>/dev/null || true
      wait "$pid" 2>/dev/null || true
      return 124
    fi

    sleep 0.1
    elapsed=$((elapsed + 1))
  done

  wait "$pid"
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

  echo "=== non-terminal safety ==="
  local no_tty_output no_tty_status no_tty_file
  no_tty_file="$TEST_ROOT/no-tty-menu.out"
  set +e
  run_with_deadline 2 "$no_tty_file" bash "$REPO_ROOT/scripts/superpowers-installer.sh" --action install
  no_tty_status=$?
  set -e
  no_tty_output="$(sed -n '1,80p' "$no_tty_file")"
  if [[ "$no_tty_status" -ne 0 && "$no_tty_status" -ne 124 ]]; then
    pass "missing TUI input exits quickly without a terminal"
  else
    fail "missing TUI input exits quickly without a terminal"
    echo "    status: $no_tty_status"
    printf '%s\n' "$no_tty_output" | sed 's/^/    /'
  fi
  assert_contains "$no_tty_output" "interactive TUI requires a terminal" "missing TUI input explains terminal requirement"
  assert_not_contains "$no_tty_output" "Invalid selection" "missing TUI input does not loop through invalid selections"

  no_tty_file="$TEST_ROOT/no-tty-confirm.out"
  set +e
  run_with_deadline 2 "$no_tty_file" bash "$REPO_ROOT/scripts/superpowers-installer.sh" --action install --harness codex --scope project
  no_tty_status=$?
  set -e
  no_tty_output="$(sed -n '1,80p' "$no_tty_file")"
  if [[ "$no_tty_status" -ne 0 && "$no_tty_status" -ne 124 ]]; then
    pass "missing confirmation input exits quickly without a terminal"
  else
    fail "missing confirmation input exits quickly without a terminal"
    echo "    status: $no_tty_status"
    printf '%s\n' "$no_tty_output" | sed 's/^/    /'
  fi
  assert_contains "$no_tty_output" "confirmation requires a terminal" "missing confirmation input explains terminal requirement"
}

run_tests

if [[ "$FAILURES" -gt 0 ]]; then
  echo ""
  echo "$FAILURES test(s) failed"
  exit 1
fi

echo ""
echo "All installer tests passed"
