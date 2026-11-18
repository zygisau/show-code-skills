---
name: show-code
description: Use when the user says /show-code, "show me in vim/lazyvim/nvim", "open this in vim", or "highlight this code" — opens lazyvim in a reused cmux split at the file and line being discussed, with the lines visually selected.
---

# Show Code in lazyvim (cmux)

Run:

```bash
~/.codex/skills/show-code/scripts/show.sh <file> [start] [end]
```

- `<file>` may be absolute or relative to the current repository. `start` defaults to 1; `end` defaults to `start`.
- The first call creates an unfocused lazyvim split on the right. Later calls reuse it with `:e!`.
- The command prints its cmux surface ref; retain it when verification is needed.

Then report the file and selected range in one line, for example: `lazyvim shows file.ts:26-32`.

If verification is needed, run `cmux read-screen --surface <ref> --lines 3`. Expect `V-LINE` and the file path in the statusline. Do not claim visual confirmation: the agent cannot see the cmux pane.

For multiple user-paced stops, use `show-code-control` instead.

## Operational notes

- Paths are escaped for Vim command-line semantics, not shell-quoted.
- The scripts send Escape before `:e!` to clear leftover selections or input modes.
- If a user leaves Neovim in macro-recording or operator-pending state, rerun `show.sh` once to recover.
- State is stored at `/tmp/cmux-show-code-<workspace>`; deleting it recovers from a manually closed pane.
