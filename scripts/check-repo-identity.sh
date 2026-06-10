#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$repo_root"

required_readme_text=(
  "# ohMyHarness"
  "npx skills add huaka1/oh-my-harness"
  "Codex"
  "Claude Code"
  "OpenCode"
  "来源与许可"
)

for text in "${required_readme_text[@]}"; do
  if ! grep -Fq "$text" README.md; then
    echo "README.md 缺少必要内容: $text" >&2
    exit 1
  fi
done

for path in \
  .claude-plugin \
  .codex-plugin \
  .cursor-plugin \
  .opencode \
  hooks \
  gemini-extension.json \
  package.json \
  RELEASE-NOTES.md \
  scripts/sync-to-codex-plugin.sh \
  tests/claude-code \
  tests/codex-plugin-sync \
  tests/explicit-skill-requests \
  tests/opencode \
  tests/skill-triggering \
  tests/subagent-driven-dev; do
  if [[ -e "$path" ]]; then
    echo "发现不应保留的 Superpowers 发布残留: $path" >&2
    exit 1
  fi
done

skill_count="$(find skills -mindepth 2 -maxdepth 2 -name SKILL.md | wc -l | tr -d ' ')"
if [[ "$skill_count" != "15" ]]; then
  echo "预期 15 个 skills，实际为 $skill_count" >&2
  exit 1
fi

test -f skills/brainstorming/visual-companion.md

echo "仓库定位检查通过"
