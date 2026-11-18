#!/usr/bin/env bash
set -euo pipefail
source "$HOME/.codex/skills/show-code/scripts/find-cmux.sh"

WS=$(cmux_workspace)
CONTROLLER="$HOME/.codex/skills/show-code-control/tour-controller.sh"
controller_args=()
if [ $# -eq 0 ]; then
  TSV=$(show_tour_path "$WS")
  [ -s "$TSV" ] || { echo "tour: no stops given and default tour file missing: $TSV" >&2; exit 1; }
  controller_args=(--tour "$TSV")
elif [ $# -eq 1 ] && [[ "$1" == *.tsv ]]; then
  [ -s "$1" ] || { echo "tour: tour file missing or empty: $1" >&2; exit 1; }
  controller_args=(--tour "$1")
else
  for spec in "$@"; do
    s="$spec"
    case "$s" in *=*) title="${s#*=}"; s="${s%%=*}" ;; *) title="" ;; esac
    if [[ "$s" =~ ^(.+):([0-9]+)(-[0-9]+)?$ ]]; then
      f="${BASH_REMATCH[1]}"; range=":${BASH_REMATCH[2]}${BASH_REMATCH[3]:-}"
    else f="$s"; range=""; fi
    case "$f" in /*) ;; *) f="$PWD/$f" ;; esac
    if [ -n "$title" ]; then controller_args+=("${f}${range}=${title}"); else controller_args+=("${f}${range}"); fi
  done
fi

bash "$CONTROLLER" --check "${controller_args[@]}"
nvim_surf=$("$HOME/.codex/skills/show-code/scripts/spawn-nvim.sh" | tail -1)
ctrl_surf=$("$(dirname "$0")/spawn-control.sh" | tail -1)
[ -n "$ctrl_surf" ] || { echo "tour: control pane failed to spawn" >&2; exit 1; }
cmd="bash $(printf '%q' "$CONTROLLER") --pane $(printf '%q' "$nvim_surf")"
for a in "${controller_args[@]}"; do cmd="$cmd $(printf '%q' "$a")"; done
cmux send --surface "$ctrl_surf" "$cmd" >/dev/null
cmux send-key --surface "$ctrl_surf" Enter >/dev/null
printf 'tour launched: %s stop(s), nvim=%s control=%s\n' "$(bash "$CONTROLLER" --check "${controller_args[@]}" | wc -l | tr -d ' ')" "$nvim_surf" "$ctrl_surf"
