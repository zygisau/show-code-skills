# show-code skills

Two coding-agent skills (Claude Code / Codex) that let an agent show you code in
LazyVim inside a [cmux](https://cmux.dev) split.

- **`show-code`** — opens a reused LazyVim split at a file and line range, with the
  lines visually selected.
- **`show-code-control`** — a keyboard-paced tour: a bottom control strip moves the
  highlight through ordered code stops with ←/→.

`show-code-control` depends on `show-code`'s scripts.

## Requirements

- cmux, `nvim` (LazyVim), `rg`, bash

## Install

The scripts reference `~/.codex/skills/<name>/...`, so link both skills there (and
into `~/.claude/skills` for Claude Code):

```bash
git clone git@github.com:zygisau/show-code-skills.git
for d in ~/.codex/skills ~/.claude/skills; do
  mkdir -p "$d"
  ln -s "$PWD/show-code-skills/show-code" "$d/show-code"
  ln -s "$PWD/show-code-skills/show-code-control" "$d/show-code-control"
done
```

See each `SKILL.md` for usage.
