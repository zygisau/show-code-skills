#!/usr/bin/env bash
# Keyboard controller for an ordered LazyVim code tour.
set -u

SURF=""; TOUR=""; CHECK=0; specs=()
while [ $# -gt 0 ]; do
  case "$1" in
    --pane) SURF="${2:?--pane needs a surface ref}"; shift 2 ;;
    --pane=*) SURF="${1#--pane=}"; shift ;;
    --tour) TOUR="${2:?--tour needs a path}"; shift 2 ;;
    --tour=*) TOUR="${1#--tour=}"; shift ;;
    --check) CHECK=1; shift ;;
    *) specs+=("$1"); shift ;;
  esac
done
if [ -z "$SURF" ] && [ "$CHECK" -eq 0 ]; then
  echo "tour-controller: --pane <surface ref> is required" >&2
  exit 2
fi

files=(); starts=(); ends=(); titles=(); bad=0
add_stop() {
  local f="$1" s="$2" e="$3" t="$4"
  if [ ! -f "$f" ]; then echo "tour-controller: no such file: $f" >&2; bad=1; return; fi
  if [ "$s" -gt "$e" ]; then echo "tour-controller: start > end in $f:$s-$e" >&2; bad=1; return; fi
  files+=("$f"); starts+=("$s"); ends+=("$e"); titles+=("$t")
}
if [ -n "$TOUR" ]; then
  [ -s "$TOUR" ] || { echo "tour-controller: tour file missing or empty: $TOUR" >&2; exit 1; }
  while IFS=$'\t' read -r f s e t; do
    [ -z "$f" ] && continue
    if [ -z "${s:-}" ] || [ -z "${e:-}" ] || [ -z "${t:-}" ]; then
      echo "tour-controller: malformed stop (need file<TAB>start<TAB>end<TAB>title): $f" >&2; bad=1; continue
    fi
    add_stop "$f" "$s" "$e" "$t"
  done < "$TOUR"
fi
for spec in "${specs[@]}"; do
  title=""
  case "$spec" in *=*) title="${spec#*=}"; spec="${spec%%=*}" ;; esac
  if [[ "$spec" =~ ^(.+):([0-9]+)(-([0-9]+))?$ ]]; then
    f="${BASH_REMATCH[1]}"; s="${BASH_REMATCH[2]}"; e="${BASH_REMATCH[4]:-${BASH_REMATCH[2]}}"
  else f="$spec"; s=1; e=1; fi
  case "$f" in /*) ;; *) f="$PWD/$f" ;; esac
  [ -n "$title" ] || title="$(basename "$f"):$s-$e"
  add_stop "$f" "$s" "$e" "$title"
done
[ "$bad" -eq 0 ] || exit 1
n=${#files[@]}
[ "$n" -gt 0 ] || { echo "tour-controller: no stops" >&2; exit 1; }
if [ "$CHECK" -eq 1 ]; then
  for i in "${!files[@]}"; do printf '%s\t%s\t%s\t%s\n' "${files[$i]}" "${starts[$i]}" "${ends[$i]}" "${titles[$i]}"; done
  exit 0
fi

i=0
apply() {
  local f="${files[$i]}" s="${starts[$i]}" e="${ends[$i]}" esc
  esc="${f//\\\\/\\\\\\\\}"; esc="${esc// /\\ }"
  cmux send-key --surface "$SURF" Escape >/dev/null 2>&1
  cmux send --surface "$SURF" ":e! +${s} ${esc}" >/dev/null 2>&1
  cmux send-key --surface "$SURF" Enter >/dev/null 2>&1
  cmux send --surface "$SURF" "V" >/dev/null 2>&1
  [ "$e" = "$s" ] || cmux send --surface "$SURF" "${e}G" >/dev/null 2>&1
  cmux send --surface "$SURF" "zz" >/dev/null 2>&1
}
draw() {
  clear
  printf 'Code tour — stop %d/%d\n\n  %s\n  %s:%s-%s\n\nleft/right (or up/down): navigate    q: quit\n' \
    "$((i + 1))" "$n" "${titles[$i]}" "${files[$i]}" "${starts[$i]}" "${ends[$i]}"
}
draw; apply
while IFS= read -rsn1 key; do
  case "$key" in
    q) break ;;
    $'\e')
      IFS= read -rsn1 _bracket; IFS= read -rsn1 arrow
      case "$arrow" in C|A) [ "$i" -lt $((n - 1)) ] && i=$((i + 1)) || true ;; D|B) [ "$i" -gt 0 ] && i=$((i - 1)) || true ;; esac
      draw; apply ;;
  esac
done
clear
printf 'Tour ended. Re-run from the agent with /show-code-control.\n'
