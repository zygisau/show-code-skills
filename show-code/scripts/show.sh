#!/usr/bin/env bash
# show.sh <file> [start] [end]: open and highlight a file range in lazyvim.
set -euo pipefail
source "$(dirname "$0")/find-cmux.sh"

file="${1:?usage: show.sh <file> [start] [end]}"
start="${2:-1}"
end="${3:-$start}"
case "$file" in /*) ;; *) file="$PWD/$file" ;; esac
[ -f "$file" ] || { echo "show: no such file: $file" >&2; exit 1; }

surf=$("$(dirname "$0")/spawn-nvim.sh" | tail -1)
esc=$(vim_escape_path "$file")
cmux send-key --surface "$surf" Escape >/dev/null
cmux send --surface "$surf" ":e! +${start} ${esc}" >/dev/null
cmux send-key --surface "$surf" Enter >/dev/null
cmux send --surface "$surf" "V" >/dev/null
if [ "$end" != "$start" ]; then cmux send --surface "$surf" "${end}G" >/dev/null; fi
cmux send --surface "$surf" "zz" >/dev/null
printf '%s\n' "$surf"
