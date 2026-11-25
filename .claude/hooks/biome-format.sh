#!/usr/bin/env bash
# PostToolUse hook: format/fix the file Claude just edited with Biome.
# Never blocks: formatting problems are left for `pnpm lint` to report.
file=$(jq -r '.tool_input.file_path // empty')
[ -z "$file" ] && exit 0
case "$file" in
  "$CLAUDE_PROJECT_DIR"/*) ;;
  *) exit 0 ;; # outside the repo
esac
[ -f "$file" ] || exit 0
"$CLAUDE_PROJECT_DIR/node_modules/.bin/biome" check --write \
  --no-errors-on-unmatched --files-ignore-unknown=true "$file" >/dev/null 2>&1
exit 0
