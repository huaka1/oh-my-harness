#!/usr/bin/env bash

sp_die() {
  echo "ERROR: $*" >&2
  return 1
}

sp_home() {
  printf '%s\n' "${SP_HOME:-$HOME}"
}

sp_project_dir() {
  if [[ -n "${SP_PROJECT_DIR:-}" ]]; then
    printf '%s\n' "$SP_PROJECT_DIR"
  else
    pwd
  fi
}

sp_repo_root() {
  if [[ -n "${SP_REPO_ROOT:-}" ]]; then
    printf '%s\n' "$SP_REPO_ROOT"
    return 0
  fi

  local script_dir
  script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
  cd "$script_dir/../.." && pwd
}

sp_validate_harness() {
  case "$1" in
    claude-code|codex|opencode|all) return 0 ;;
    *) sp_die "unsupported harness '$1'" ;;
  esac
}

sp_validate_scope() {
  case "$1" in
    global|project) return 0 ;;
    *) sp_die "unsupported scope '$1'" ;;
  esac
}

sp_targets_for() {
  local harness="$1"
  sp_validate_harness "$harness" || return 1

  if [[ "$harness" == "all" ]]; then
    printf '%s\n' claude-code codex opencode
  else
    printf '%s\n' "$harness"
  fi
}

sp_skill_base() {
  local harness="$1"
  local scope="$2"
  local home project

  sp_validate_scope "$scope" || return 1
  home="$(sp_home)"
  project="$(sp_project_dir)"

  case "$harness:$scope" in
    claude-code:global) printf '%s\n' "$home/.claude/skills" ;;
    claude-code:project) printf '%s\n' "$project/.claude/skills" ;;
    codex:global) printf '%s\n' "$home/.agents/skills" ;;
    codex:project) printf '%s\n' "$project/.codex/skills" ;;
    opencode:global) printf '%s\n' "${OPENCODE_SKILLS_DIR:-$home/.config/opencode/skills}" ;;
    opencode:project) printf '%s\n' "$project/.opencode/skills" ;;
    *) sp_die "harness '$harness' does not install directly to a skill base" ;;
  esac
}

sp_state_base() {
  local scope="$1"
  local home project

  sp_validate_scope "$scope" || return 1

  if [[ -n "${SP_STATE_DIR:-}" ]]; then
    printf '%s\n' "$SP_STATE_DIR"
    return 0
  fi

  home="$(sp_home)"
  project="$(sp_project_dir)"

  case "$scope" in
    global) printf '%s\n' "$home/.local/state/oh-my-harness/superpowers-installer" ;;
    project) printf '%s\n' "$project/.oh-my-harness/superpowers-installer" ;;
  esac
}

sp_manifest_path() {
  local harness="$1"
  local scope="$2"
  local state

  sp_validate_harness "$harness" || return 1
  sp_validate_scope "$scope" || return 1
  [[ "$harness" != "all" ]] || sp_die "manifest path requires a concrete harness" || return 1

  state="$(sp_state_base "$scope")" || return 1
  printf '%s\n' "$state/$harness-$scope.manifest"
}

sp_source_revision() {
  local repo
  repo="$(sp_repo_root)"
  git -C "$repo" rev-parse --short HEAD 2>/dev/null || printf '%s\n' "unknown"
}

sp_skill_names() {
  local repo
  repo="$(sp_repo_root)"
  find "$repo/skills" -mindepth 1 -maxdepth 1 -type d -exec sh -c '
    for dir do
      if [ -f "$dir/SKILL.md" ]; then
        basename "$dir"
      fi
    done
  ' sh {} + | sort
}

sp_copy_dir_contents() {
  local source="$1"
  local dest="$2"

  mkdir -p "$dest"
  if command -v rsync >/dev/null 2>&1; then
    rsync -a --delete "$source/" "$dest/"
  else
    rm -rf "$dest"
    mkdir -p "$dest"
    cp -R "$source/." "$dest/"
  fi
}

sp_stage_distribution() {
  local harness="$1"
  local stage="$2"
  local repo

  sp_validate_harness "$harness" || return 1
  [[ "$harness" != "all" ]] || sp_die "stage distribution requires a concrete harness" || return 1

  repo="$(sp_repo_root)"
  [[ -d "$repo/skills" ]] || sp_die "missing skills directory at $repo/skills" || return 1

  rm -rf "$stage"
  mkdir -p "$stage"

  cp -R "$repo/skills" "$stage/skills"
  if [[ -d "$repo/assets" ]]; then
    cp -R "$repo/assets" "$stage/assets"
  fi

  return 0
}

sp_manifest_has_path() {
  local manifest="$1"
  local path="$2"

  [[ -f "$manifest" ]] || return 1
  grep -Fxq "installed_path=$path" "$manifest"
}

sp_write_manifest() {
  local harness="$1"
  local scope="$2"
  local manifest="$3"
  shift 3

  mkdir -p "$(dirname "$manifest")"
  {
    printf 'harness=%s\n' "$harness"
    printf 'scope=%s\n' "$scope"
    printf 'source_root=%s\n' "$(sp_repo_root)"
    printf 'source_revision=%s\n' "$(sp_source_revision)"
    printf 'installed_at=%s\n' "$(date -u '+%Y-%m-%dT%H:%M:%SZ')"
    local path
    for path in "$@"; do
      printf 'installed_path=%s\n' "$path"
    done
  } > "$manifest"
}

sp_installed_paths_from_manifest() {
  local manifest="$1"
  [[ -f "$manifest" ]] || return 0
  sed -n 's/^installed_path=//p' "$manifest"
}

sp_confirm() {
  local message="$1"
  local yes="${2:-no}"
  local answer

  if [[ "$yes" == "yes" ]]; then
    return 0
  fi

  read -r -p "$message [y/N] " answer
  [[ "$answer" == "y" || "$answer" == "Y" ]]
}

sp_assert_no_unmanaged_skill_conflicts() {
  local harness="$1"
  local scope="$2"
  local stage="$3"
  local base manifest skill name dest

  base="$(sp_skill_base "$harness" "$scope")" || return 1
  manifest="$(sp_manifest_path "$harness" "$scope")" || return 1

  while IFS= read -r skill; do
    name="$(basename "$skill")"
    dest="$base/$name"
    if [[ -e "$dest" ]] && ! sp_manifest_has_path "$manifest" "$dest"; then
      echo "Will replace existing skill directory: $dest"
    fi
  done < <(find "$stage/skills" -mindepth 1 -maxdepth 1 -type d | sort)
}

sp_install_skills_target() {
  local harness="$1"
  local scope="$2"
  local yes="$3"
  local base stage manifest skill name dest
  local -a installed_paths

  base="$(sp_skill_base "$harness" "$scope")" || return 1
  manifest="$(sp_manifest_path "$harness" "$scope")" || return 1
  stage="$(mktemp -d)"
  installed_paths=()

  sp_stage_distribution "$harness" "$stage/package" || return 1
  sp_assert_no_unmanaged_skill_conflicts "$harness" "$scope" "$stage/package" || return 1

  echo "Install target: $base"
  sp_confirm "Install Superpowers skills for $harness ($scope)?" "$yes" || return 1

  mkdir -p "$base"
  while IFS= read -r skill; do
    name="$(basename "$skill")"
    dest="$base/$name"
    rm -rf "$dest"
    cp -R "$skill" "$dest"
    installed_paths+=("$dest")
  done < <(find "$stage/package/skills" -mindepth 1 -maxdepth 1 -type d | sort)

  sp_write_manifest "$harness" "$scope" "$manifest" "${installed_paths[@]}"
  rm -rf "$stage"
  echo "Installed $harness ($scope)"
}

sp_install_one_target() {
  local harness="$1"
  local scope="$2"
  local yes="${3:-no}"

  case "$harness" in
    claude-code|codex|opencode) sp_install_skills_target "$harness" "$scope" "$yes" ;;
    *) sp_die "unsupported concrete harness '$harness'" ;;
  esac
}

sp_install_target() {
  local harness="$1"
  local scope="$2"
  local yes="${3:-no}"
  local target

  sp_validate_harness "$harness" || return 1
  sp_validate_scope "$scope" || return 1

  while IFS= read -r target; do
    sp_install_one_target "$target" "$scope" "$yes"
  done < <(sp_targets_for "$harness")
}

sp_uninstall_one_target() {
  local harness="$1"
  local scope="$2"
  local yes="${3:-no}"
  local manifest path

  manifest="$(sp_manifest_path "$harness" "$scope")" || return 1
  if [[ ! -f "$manifest" ]]; then
    echo "Not installed: $harness ($scope)"
    return 0
  fi

  echo "Manifest: $manifest"
  sp_installed_paths_from_manifest "$manifest" | sed 's/^/Remove:   /'
  sp_confirm "Uninstall Superpowers for $harness ($scope)?" "$yes" || return 1

  while IFS= read -r path; do
    [[ -n "$path" ]] || continue
    if [[ -L "$path" || -f "$path" ]]; then
      rm -f "$path"
    elif [[ -d "$path" ]]; then
      rm -rf "$path"
    fi
  done < <(sp_installed_paths_from_manifest "$manifest")

  rm -f "$manifest"
  echo "Uninstalled $harness ($scope)"
}

sp_uninstall_target() {
  local harness="$1"
  local scope="$2"
  local yes="${3:-no}"
  local target

  sp_validate_harness "$harness" || return 1
  sp_validate_scope "$scope" || return 1

  while IFS= read -r target; do
    sp_uninstall_one_target "$target" "$scope" "$yes"
  done < <(sp_targets_for "$harness")
}

sp_reinstall_target() {
  local harness="$1"
  local scope="$2"
  local yes="${3:-no}"

  sp_uninstall_target "$harness" "$scope" "$yes" || return 1
  sp_install_target "$harness" "$scope" "$yes"
}

sp_status_one_target() {
  local harness="$1"
  local scope="$2"
  local manifest

  manifest="$(sp_manifest_path "$harness" "$scope")" || return 1
  if [[ -f "$manifest" ]]; then
    echo "$harness ($scope): installed"
    sed -n 's/^source_revision=/  revision: /p;s/^installed_at=/  installed: /p;s/^installed_path=/  path: /p' "$manifest"
  else
    echo "$harness ($scope): not installed"
  fi
}

sp_print_status() {
  local harness="$1"
  local scope="$2"
  local target

  sp_validate_harness "$harness" || return 1
  sp_validate_scope "$scope" || return 1

  while IFS= read -r target; do
    sp_status_one_target "$target" "$scope"
  done < <(sp_targets_for "$harness")
}

sp_run_action() {
  local action="$1"
  local harness="$2"
  local scope="$3"
  local yes="${4:-no}"

  case "$action" in
    install) sp_install_target "$harness" "$scope" "$yes" ;;
    uninstall) sp_uninstall_target "$harness" "$scope" "$yes" ;;
    reinstall) sp_reinstall_target "$harness" "$scope" "$yes" ;;
    status) sp_print_status "$harness" "$scope" ;;
    *) sp_die "unsupported action '$action'" ;;
  esac
}
