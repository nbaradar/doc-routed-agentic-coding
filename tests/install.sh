#!/usr/bin/env bash
# Isolated integration checks; unavailable symlink checks are reported as skipped.
set -euo pipefail
repo="$(cd "$(dirname "$0")/.." && pwd)"
tmp="$(mktemp -d)"
trap 'rm -rf -- "$tmp"' EXIT
mkdir -p "$tmp/source clone"
cp "$repo/install.sh" "$tmp/source clone/"
cp -R "$repo/skills" "$tmp/source clone/"
installer="$tmp/source clone/install.sh"
export CLAUDE_SKILLS_DIR="$tmp/claude skills"
export CODEX_SKILLS_DIR="$tmp/codex skills"
checks=0
modes=(copy link)
links=true
if ! ln -s "$tmp/source clone" "$tmp/link-probe" 2>/dev/null || [ ! -L "$tmp/link-probe" ]; then
  echo 'SKIP: real symlinks are unavailable; link checks will not run.'
  modes=(copy)
  links=false
fi
expect() {
  local wanted="$1" actual=0
  shift
  "$@" >"$tmp/output" 2>&1 || actual=$?
  if [ "$actual" -ne "$wanted" ]; then
    cat "$tmp/output"
    echo "Expected exit $wanted, got $actual: $*" >&2
    exit 1
  fi
  checks=$((checks + 1))
}
cd "$tmp"
for tool in claude codex both; do
  for mode in "${modes[@]}"; do
    export CLAUDE_SKILLS_DIR="$tmp/$tool-$mode/claude skills"
    export CODEX_SKILLS_DIR="$tmp/$tool-$mode/codex skills"
    args=("$tool")
    if [ "$mode" = link ]; then args+=(--link); fi
    expect 0 bash "$installer" "${args[@]}"
    for selected in claude codex; do
      if [ "$selected" = claude ]; then dest="$CLAUDE_SKILLS_DIR"; else dest="$CODEX_SKILLS_DIR"; fi
      if [ "$tool" != both ] && [ "$tool" != "$selected" ]; then
        [ ! -e "$dest" ]
        continue
      fi
      count=0
      for source in "$tmp/source clone/skills"/*; do
        target="$dest/$(basename "$source")"
        diff -r "$source" "$target"
        if [ "$mode" = link ]; then [ -L "$target" ]; else [ ! -L "$target" ]; fi
        count=$((count + 1))
      done
      [ "$count" -eq 4 ]
    done
    if [ "$mode" = link ]; then
      expect 0 bash "$installer" "${args[@]}"
    else
      expect 1 bash "$installer" "${args[@]}"
    fi
  done
done
# An edit to the source must be visible through both installed links.
if [ "$links" = true ]; then
  echo 'link update probe' >> "$tmp/source clone/skills/plan-unit/SKILL.md"
  for dest in "$CLAUDE_SKILLS_DIR" "$CODEX_SKILLS_DIR"; do
    grep -q 'link update probe' "$dest/plan-unit/SKILL.md"
  done
fi
export CLAUDE_SKILLS_DIR="$tmp/conflicts/claude"
export CODEX_SKILLS_DIR="$tmp/conflicts/codex"
mkdir -p "$CLAUDE_SKILLS_DIR"
echo 'preserve me' > "$CLAUDE_SKILLS_DIR/plan-unit"
if [ "$links" = true ]; then ln -s "$tmp/missing" "$CLAUDE_SKILLS_DIR/project-status"; fi
expect 1 bash "$installer" both
grep -q 'preserve me' "$CLAUDE_SKILLS_DIR/plan-unit"
if [ "$links" = true ]; then [ "$(readlink "$CLAUDE_SKILLS_DIR/project-status")" = "$tmp/missing" ]; fi
[ -f "$CODEX_SKILLS_DIR/plan-unit/SKILL.md" ]
# A destination creation error must not stop the other selected tool.
export CLAUDE_SKILLS_DIR="$tmp/conflicts/claude/plan-unit/child"
export CODEX_SKILLS_DIR="$tmp/after-error"
expect 1 bash "$installer" both
[ -f "$CODEX_SKILLS_DIR/plan-unit/SKILL.md" ]
export CLAUDE_SKILLS_DIR="$tmp/untouched-claude"
export CODEX_SKILLS_DIR="$tmp/untouched-codex"
expect 2 bash "$installer" </dev/null
expect 2 bash "$installer" --link </dev/null
expect 2 bash "$installer" invalid
expect 2 bash "$installer" claude codex
expect 2 bash "$installer" both --unknown
expect 0 bash "$installer" --help
[ ! -e "$CLAUDE_SKILLS_DIR" ] && [ ! -e "$CODEX_SKILLS_DIR" ]
# Verify documented defaults against a temporary home.
expect 0 env -u CLAUDE_SKILLS_DIR -u CODEX_SKILLS_DIR HOME="$tmp/home" bash "$installer" both
[ -f "$tmp/home/.claude/skills/plan-unit/SKILL.md" ]
[ -f "$tmp/home/.agents/skills/plan-unit/SKILL.md" ]
echo "Passed $checks installer invocations plus content, isolation, and preservation checks (symlink checks enabled: $links)."
