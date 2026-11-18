# shellcheck shell=bash
# Shared helpers for the show-code skills. Source this file; do not execute it.

cmux_workspace() {
  if [ -n "${CMUX_WORKSPACE_ID:-}" ]; then
    printf '%s\n' "$CMUX_WORKSPACE_ID"
    return 0
  fi
  local ws
  ws=$(cmux identify 2>/dev/null | rg -m1 -o '"workspace_ref" : "[^"]+"' | rg -o 'workspace:[0-9]+|[0-9A-F-]{36}' || true)
  if [ -n "$ws" ]; then
    printf '%s\n' "$ws"
    return 0
  fi
  echo "find-cmux: not in a cmux session (no CMUX_WORKSPACE_ID, identify failed)" >&2
  return 1
}

cmux_caller_pane() {
  cmux identify 2>/dev/null | rg -m1 -o '"pane_ref" : "pane:[0-9]+"' | rg -o 'pane:[0-9]+'
}

show_code_state_path() { printf '/tmp/cmux-show-code-%s\n' "$1"; }
show_control_state_path() { printf '/tmp/cmux-show-code-control-%s\n' "$1"; }
show_tour_path() { printf '/tmp/cmux-show-code-tour-%s.tsv\n' "$1"; }

surface_alive() {
  cmux read-screen --surface "$1" --lines 1 >/dev/null 2>&1
}

surface_has_nvim() {
  cmux read-screen --surface "$1" --lines 2 2>/dev/null \
    | tail -1 | rg -q 'NORMAL|V-LINE|INSERT|COMMAND|VISUAL'
}

parse_surface_ref() {
  printf '%s' "$1" | rg -m1 -o 'surface:[0-9]+'
}

vim_escape_path() {
  local p="$1"
  p="${p//\\\\/\\\\\\\\}"
  p="${p// /\\ }"
  printf '%s\n' "$p"
}
