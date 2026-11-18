#!/usr/bin/env bash
# Ensure a focused bottom control strip and print its surface ref.
set -euo pipefail
source "$HOME/.codex/skills/show-code/scripts/find-cmux.sh"

WS=$(cmux_workspace)
STATE=$(show_control_state_path "$WS")
pattern="tour-controller.sh .*${WS}"
LC_ALL=C pkill -f "$pattern" 2>/dev/null || true
for _ in 1 2 3 4; do LC_ALL=C pgrep -f "$pattern" >/dev/null || break; sleep 0.5; done
if LC_ALL=C pgrep -f "$pattern" >/dev/null; then
  echo "spawn-control: stale controller survived pkill ($pattern)" >&2
  exit 1
fi

surf=""
if [ -f "$STATE" ]; then
  s=$(cat "$STATE")
  if surface_alive "$s"; then
    surf="$s"
    cmux send-key --surface "$surf" ctrl+c >/dev/null
  fi
fi

if [ -z "$surf" ]; then
  out=$(cmux new-split down --workspace "$WS" --focus true 2>/dev/null)
  surf=$(parse_surface_ref "$out")
  [ -n "$surf" ] || { echo "spawn-control: cannot parse surface from: $out" >&2; exit 1; }
  printf '%s\n' "$surf" > "$STATE"
  above=$(cmux_caller_pane)
  ctrl_pane=$(cmux tree --workspace "$WS" 2>/dev/null | awk -v s="surface ${surf} " '
    /pane pane:[0-9]+/ { match($0, /pane:[0-9]+/); p = substr($0, RSTART, RLENGTH) }
    index($0, s) { print p; exit }')
  wait_for_prompt() {
    for _ in $(seq 1 20); do
      cmux read-screen --surface "$surf" --lines 3 2>/dev/null | rg -q '[%$#] *$' && return 0
      sleep 0.5
    done
    return 0
  }
  measure() {
    wait_for_prompt
    cmux send --surface "$surf" 'echo CMUXROWS=$LINES' >/dev/null
    cmux send-key --surface "$surf" Enter >/dev/null
    sleep 0.5
    cmux read-screen --surface "$surf" --lines 4 2>/dev/null | rg -o 'CMUXROWS=[0-9]+' | tail -1 | cut -d= -f2 || true
  }
  [ -n "$above" ] && cmux resize-pane --pane "$above" -D --amount 300 >/dev/null 2>&1 || true
  rows=$(measure); i=0
  while [ "${rows:-0}" -gt 13 ] && [ "$i" -lt 5 ]; do
    [ -n "$above" ] && cmux resize-pane --pane "$above" -D --amount 120 >/dev/null 2>&1 || true
    rows=$(measure); i=$((i + 1))
  done
  i=0
  while [ "${rows:-0}" -lt 9 ] && [ "$i" -lt 5 ]; do
    [ -n "$ctrl_pane" ] && cmux resize-pane --pane "$ctrl_pane" -U --amount 60 >/dev/null 2>&1 || true
    rows=$(measure); i=$((i + 1))
  done
fi
printf '%s\n' "$surf"
