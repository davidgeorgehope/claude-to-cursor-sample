#!/usr/bin/env bash
# deny-rm-rf.sh — read hook JSON on stdin; deny destructive rm
# Exit 2 = block (Claude Code and Cursor both treat this as deny).
set -euo pipefail

input=$(cat || true)

# Match common shapes: raw command strings, tool_input.command, or command fields.
# Case-insensitive; covers `rm -rf`, `rm -fr`, `rm --force`, and flag clusters like -rRf.
if printf '%s' "$input" | grep -Eiq \
  '(^|[^[:alnum:]_])rm[[:space:]]+([^[:space:]]*[[:space:]]+)*(-[a-zA-Z]*f[a-zA-Z]*|--force)'; then
  echo "Blocked destructive rm (force-remove). Use a safer path or remove files explicitly." >&2
  exit 2
fi

exit 0
