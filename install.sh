#!/usr/bin/env bash
# Install this repository's skills as personal Claude Code skills.
#   ./install.sh          copy each skill into ~/.claude/skills
#   ./install.sh --link   symlink each skill instead, so edits and `git pull`
#                         take effect everywhere without reinstalling
# Existing skills with the same name are left untouched; remove them first
# to reinstall. Override the target with CLAUDE_SKILLS_DIR.
set -euo pipefail

repo_dir="$(cd "$(dirname "$0")" && pwd)"
target_root="${CLAUDE_SKILLS_DIR:-$HOME/.claude/skills}"
mode="${1:-copy}"
if [ "$mode" != "copy" ] && [ "$mode" != "--link" ]; then
  echo "Usage: ./install.sh [--link]" >&2
  exit 2
fi

mkdir -p "$target_root"
installed=0
skipped=0
for source_dir in "$repo_dir"/skills/*/; do
  name="$(basename "$source_dir")"
  source_dir="${source_dir%/}"
  target="$target_root/$name"
  if [ -e "$target" ] || [ -L "$target" ]; then
    if [ -L "$target" ] && [ "$(readlink "$target")" = "$source_dir" ]; then
      echo "Already linked: $name"
    else
      echo "Skipped (already exists, remove it to reinstall): $target"
      skipped=$((skipped + 1))
    fi
    continue
  fi
  if [ "$mode" = "--link" ]; then
    ln -s "$source_dir" "$target"
    echo "Linked:    $name -> $source_dir"
  else
    cp -R "$source_dir" "$target"
    echo "Installed: $name"
  fi
  installed=$((installed + 1))
done

echo "$installed installed, $skipped skipped. Start a new Claude Code session to pick up new skills."
[ "$skipped" -eq 0 ]
