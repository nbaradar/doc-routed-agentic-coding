#!/usr/bin/env bash
# Install the adopt-routed-workflow skill as a personal Claude Code skill.
#   ./install.sh          copy the skill into ~/.claude/skills
#   ./install.sh --link   symlink it instead, so `git pull` updates it
set -euo pipefail

source_dir="$(cd "$(dirname "$0")" && pwd)/skills/adopt-routed-workflow"
target_dir="${CLAUDE_SKILLS_DIR:-$HOME/.claude/skills}/adopt-routed-workflow"

mkdir -p "$(dirname "$target_dir")"
if [ -e "$target_dir" ] || [ -L "$target_dir" ]; then
  echo "Already exists: $target_dir"
  echo "Remove it first to reinstall."
  exit 1
fi

if [ "${1:-}" = "--link" ]; then
  ln -s "$source_dir" "$target_dir"
  echo "Linked $target_dir -> $source_dir"
else
  cp -R "$source_dir" "$target_dir"
  echo "Installed $target_dir"
fi
echo "Restart Claude Code, then run /adopt-routed-workflow in a repository."
