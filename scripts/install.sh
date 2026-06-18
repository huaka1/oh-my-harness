#!/usr/bin/env bash
set -euo pipefail

DEFAULT_REPO="huaka1/oh-my-harness"
DEFAULT_REF="main"

SCRIPT_PATH="${BASH_SOURCE[0]:-$0}"
SCRIPT_DIR="$(cd "$(dirname "$SCRIPT_PATH")" 2>/dev/null && pwd || true)"

run_from_checkout() {
  local action="$1"
  shift
  local installer="$SCRIPT_DIR/superpowers-installer.sh"

  if [[ -n "$SCRIPT_DIR" && -f "$installer" && -d "$SCRIPT_DIR/../skills" ]]; then
    bash "$installer" --action "$action" "$@"
    return 0
  fi

  return 1
}

download_and_run() {
  local action="$1"
  shift
  local repo="${OH_MY_HARNESS_REPO:-$DEFAULT_REPO}"
  local ref="${OH_MY_HARNESS_REF:-$DEFAULT_REF}"
  local tmp archive root

  command -v curl >/dev/null 2>&1 || {
    echo "ERROR: curl not found" >&2
    return 1
  }
  command -v tar >/dev/null 2>&1 || {
    echo "ERROR: tar not found" >&2
    return 1
  }

  tmp="$(mktemp -d)"
  trap 'rm -rf "$tmp"' EXIT
  archive="$tmp/source.tar.gz"

  curl -fsSL "https://codeload.github.com/$repo/tar.gz/$ref" -o "$archive"
  tar -xzf "$archive" -C "$tmp"
  root="$(find "$tmp" -mindepth 1 -maxdepth 1 -type d | head -n 1)"

  if [[ -z "$root" || ! -f "$root/scripts/superpowers-installer.sh" ]]; then
    echo "ERROR: downloaded archive does not contain scripts/superpowers-installer.sh" >&2
    return 1
  fi

  bash "$root/scripts/superpowers-installer.sh" --action "$action" "$@"
}

main() {
  if run_from_checkout install "$@"; then
    return 0
  fi

  download_and_run install "$@"
}

main "$@"
