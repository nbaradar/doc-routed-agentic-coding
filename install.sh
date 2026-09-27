#!/usr/bin/env bash
# Install shared skills without overwriting existing destinations.
set -euo pipefail
usage() {
  cat <<'EOF'
Usage: ./install.sh [claude|codex|both] [--link]
Without a tool, prompts interactively (no default). Copy is the default mode.
  --link  Symlink skills back to this clone instead of copying.
  --help  Show help.
Destination overrides: CLAUDE_SKILLS_DIR (~/.claude/skills),
                       CODEX_SKILLS_DIR (~/.agents/skills).
Existing entries are left untouched; remove conflicts before reinstalling.
EOF
}
tool=""
mode=copy
help=false
for arg in "$@"; do
  case "$arg" in
    claude|codex|both)
      if [ -n "$tool" ]; then
        echo 'Choose exactly one tool: claude, codex, or both.' >&2
        exit 2
      fi
      tool="$arg" ;;
    --link) mode=link ;;
    --help|-h) help=true ;;
    *) echo "Unknown argument: $arg" >&2; usage >&2; exit 2 ;;
  esac
done
if [ "$help" = true ]; then usage; exit 0; fi
if [ -z "$tool" ]; then
  if [ ! -t 0 ]; then
    echo 'A tool argument is required when input is not interactive.' >&2
    usage >&2
    exit 2
  fi
  while [ -z "$tool" ]; do
    printf 'Install skills for:\n  1) Claude Code\n  2) Codex\n  3) Both\nChoose [1-3] (q to cancel): '
    if ! IFS= read -r choice; then
      echo 'Installation cancelled.'
      exit 1
    fi
    case "$choice" in
      1|claude) tool=claude ;;
      2|codex) tool=codex ;;
      3|both) tool=both ;;
      q|Q) echo 'Installation cancelled.'; exit 1 ;;
      *) echo 'Enter 1, 2, or 3 (or q to cancel).' ;;
    esac
  done
fi
# Git Bash may otherwise silently emulate ln -s by copying directories.
case "${OSTYPE:-}" in
  msys*) export MSYS="${MSYS:+$MSYS }winsymlinks:nativestrict" ;;
esac
repo_dir="$(cd "$(dirname "$0")" && pwd)"
result=0
install_for() {
  local label="$1" target_root="$2"
  local installed=0 skipped=0 linked=0 failed=0 source_dir name target
  echo "$label: $target_root ($mode)"
  if ! mkdir -p "$target_root"; then
    echo "$label: cannot create destination: $target_root" >&2
    result=1
    return
  fi
  for source_dir in "$repo_dir"/skills/*/; do
    [ -f "$source_dir/SKILL.md" ] || continue
    name="$(basename "$source_dir")"
    source_dir="${source_dir%/}"
    target="$target_root/$name"
    if [ -e "$target" ] || [ -L "$target" ]; then
      if [ -L "$target" ] && [ "$(readlink "$target")" = "$source_dir" ]; then
        echo "Already linked: $name"
        linked=$((linked + 1))
      else
        echo "Skipped (already exists, remove it to reinstall): $target"
        skipped=$((skipped + 1))
      fi
      continue
    fi
    if [ "$mode" = link ]; then
      if ln -s "$source_dir" "$target" && [ -L "$target" ]; then
        echo "Linked: $target -> $source_dir"
      else
        echo "Failed to create a symbolic link: $target. Check symlink support and permissions." >&2
        failed=$((failed + 1))
        continue
      fi
    else
      if cp -R "$source_dir" "$target"; then
        echo "Installed: $name"
      else
        echo "Failed to copy: $target" >&2
        failed=$((failed + 1))
        continue
      fi
    fi
    installed=$((installed + 1))
  done
  echo "$label: $installed installed, $linked already linked, $skipped skipped, $failed failed."
  if [ "$skipped" -ne 0 ] || [ "$failed" -ne 0 ]; then result=1; fi
}
if [ "$tool" = claude ] || [ "$tool" = both ]; then
  install_for 'Claude Code' "${CLAUDE_SKILLS_DIR:-$HOME/.claude/skills}"
  echo 'Start a new Claude Code session to pick up installed skills.'
fi
if [ "$tool" = codex ] || [ "$tool" = both ]; then
  install_for 'Codex' "${CODEX_SKILLS_DIR:-$HOME/.agents/skills}"
  echo 'If installed skills do not appear in Codex, restart it.'
fi
exit "$result"
