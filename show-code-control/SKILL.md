---
name: show-code-control
description: Use when the user says /show-code-control, "walk me through this", "give me a tour", or "presentation mode" — opens a keyboard-controlled cmux tour that moves the lazyvim highlight through ordered code stops.
---

# Show Code Control

Use this companion to `show-code` for a multi-stop, user-paced explanation. The user navigates a `V-LINE` highlight through LazyVim with arrow keys from a focused control pane.

Run either an inline tour:

```bash
~/.codex/skills/show-code-control/scripts/tour.sh \
  path/to/file.ts:26-32="why this pipeline consumes sources" \
  path/to/other.ts:120 \
  path/to/third.ts
```

or a TSV tour file:

```bash
~/.codex/skills/show-code-control/scripts/tour.sh [stops.tsv]
```

A stop is `<path>[:<start>[-<end>]][=<title>]`. Relative paths are resolved against the current working directory. A TSV row is `<absolute path><TAB><start><TAB><end><TAB><title>`; the default path is `/tmp/cmux-show-code-tour-${CMUX_WORKSPACE_ID}.tsv`.

After launching, report: `Tour ready — N stops; the bottom strip has focus, ←/→ step through, q quits.`

If needed, verify the control surface with `cmux read-screen`; it should include `stop i/N`. Verify the lazyvim surface separately for `V-LINE`. Do not claim visual confirmation.

## Operational notes

- `tour.sh` validates every stop before creating or focusing panes.
- It kills a stale controller before launching a new one. Do not edit `tour-controller.sh` while it runs.
- Stop a controller with Ctrl-C, not `q`; a bare Escape can leave macOS Bash waiting for arrow-key bytes.
- If Neovim is left operator-pending or recording a macro, press Escape in its pane, then navigate again.
