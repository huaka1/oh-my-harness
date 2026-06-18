#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
export SP_REPO_ROOT="${SP_REPO_ROOT:-$REPO_ROOT}"

# shellcheck source=scripts/lib/superpowers-installer.sh
source "$REPO_ROOT/scripts/lib/superpowers-installer.sh"

usage() {
  cat <<'EOF'
Usage:
  scripts/superpowers-installer.sh [options]

Options:
  --action install|uninstall|reinstall|status
  --harness claude-code|codex|opencode|all
  --scope global|project
  --yes
  -h, --help

No-argument usage enters the interactive TUI.
EOF
}

choose_menu() {
  local prompt="$1"
  shift
  local options=("$@")
  local choice
  local idx

  echo "$prompt" >&2
  for idx in "${!options[@]}"; do
    printf '  %s. %s\n' "$((idx + 1))" "${options[$idx]}" >&2
  done

  while true; do
    read -r -p "Select 1-${#options[@]}: " choice
    if [[ "$choice" =~ ^[0-9]+$ ]] && (( choice >= 1 && choice <= ${#options[@]} )); then
      printf '%s\n' "${options[$((choice - 1))]}"
      return 0
    fi
    echo "Invalid selection: $choice" >&2
  done
}

normalize_action() {
  case "$1" in
    "Install Superpowers") printf '%s\n' install ;;
    "Uninstall Superpowers") printf '%s\n' uninstall ;;
    "Reinstall Superpowers") printf '%s\n' reinstall ;;
    "Show Installation Status") printf '%s\n' status ;;
    *) printf '%s\n' "$1" ;;
  esac
}

normalize_harness() {
  case "$1" in
    "Claude Code") printf '%s\n' claude-code ;;
    "Codex") printf '%s\n' codex ;;
    "OpenCode") printf '%s\n' opencode ;;
    "All") printf '%s\n' all ;;
    *) printf '%s\n' "$1" ;;
  esac
}

normalize_scope() {
  case "$1" in
    "Global") printf '%s\n' global ;;
    "Project") printf '%s\n' project ;;
    *) printf '%s\n' "$1" ;;
  esac
}

ACTION="${SP_DEFAULT_ACTION:-}"
HARNESS=""
SCOPE=""
YES="no"

while [[ $# -gt 0 ]]; do
  case "$1" in
    --action)
      ACTION="$2"
      shift 2
      ;;
    --harness)
      HARNESS="$2"
      shift 2
      ;;
    --scope)
      SCOPE="$2"
      shift 2
      ;;
    --yes|-y)
      YES="yes"
      shift
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      echo "Unknown option: $1" >&2
      usage >&2
      exit 2
      ;;
  esac
done

if [[ -z "$ACTION" ]]; then
  ACTION="$(choose_menu "Select action:" \
    "Install Superpowers" \
    "Uninstall Superpowers" \
    "Reinstall Superpowers" \
    "Show Installation Status")"
fi
ACTION="$(normalize_action "$ACTION")"

if [[ -z "$HARNESS" ]]; then
  HARNESS="$(choose_menu "Select harness:" "Claude Code" "Codex" "OpenCode" "All")"
fi
HARNESS="$(normalize_harness "$HARNESS")"

if [[ -z "$SCOPE" ]]; then
  SCOPE="$(choose_menu "Select scope:" "Global" "Project")"
fi
SCOPE="$(normalize_scope "$SCOPE")"

sp_validate_harness "$HARNESS"
sp_validate_scope "$SCOPE"

echo "Action:  $ACTION"
echo "Harness: $HARNESS"
echo "Scope:   $SCOPE"

sp_run_action "$ACTION" "$HARNESS" "$SCOPE" "$YES"
