#!/usr/bin/env bash
# Ensure a reusable lazyvim pane exists and print its cmux surface ref.
set -euo pipefail
source "$(dirname "$0")/find-cmux.sh"

WS=$(cmux_workspace)
STATE=$(show_code_state_path "$WS")
surf=""

if [ -f "$STATE" ]; then
  s=$(cat "$STATE")
  if surface_alive "$s"; then
    if ! surface_has_nvim "$s"; then
      cmux send --surface "$s" "nvim" >/dev/null
      cmux send-key --surface "$s" Enter >/dev/null
      sleep 2
    fi
    surf="$s"
  fi
fi

if [ -z "$surf" ]; then
  out=$(cmux new-split right --workspace "$WS" --focus false)
  surf=$(parse_surface_ref "$out")
  [ -n "$surf" ] || { echo "spawn-nvim: cannot parse surface from: $out" >&2; exit 1; }
  printf '%s\n' "$surf" > "$STATE"
  cmux send --surface "$surf" "nvim" >/dev/null
  cmux send-key --surface "$surf" Enter >/dev/null
  sleep 2
fi

printf '%s\n' "$surf"
