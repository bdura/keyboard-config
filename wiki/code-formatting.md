---
summary: Formatting setup — clang-format (Google-based, 4-space), qmkfmt for keymap grids, clangd flags for cross-compiled code, and editorconfig.
sources:
  - .clang-format
  - .clangd
  - .editorconfig
  - flake.nix
  - keyboards/ferris/keymaps/bdura/keymap.c
tags:
  - tooling
  - formatting
---

# Code formatting

## clang-format

`.clang-format` is based on Google style, with 4-space indents, no tabs, a
1000-column limit (lines are effectively never wrapped), aligned consecutive
assignments and declarations, and includes left unsorted[^clangformat].

The keymap array in `keymap.c` is wrapped in `// clang-format off` / `on` so
the hand-aligned key grid is preserved[^keymap].

## qmkfmt

`qmkfmt` (v0.2.0, built in [[nix-dev-shell]]) formats QMK keymap arrays into
aligned grids; it was added in commit `9d106ad`[^flake]. How it is invoked
(manually, editor, hook) is not recorded — _needs verification_.

## clangd

`.clangd` makes clangd usable on firmware code: it forces `clang`, drops
MCU-specific GCC flags (`-mmcu=*`, `-mcpu=*`, …) and all warnings, and silences
unknown-attribute warnings[^clangd]. `compile_commands.json` is gitignored.

## editorconfig

4-space indents, UTF-8, LF and tabs for `Makefile` and `*.mk`[^editorconfig].

[^clangformat]: [.clang-format](../../.clang-format)
[^clangd]: [.clangd](../../.clangd)
[^editorconfig]: [.editorconfig](../../.editorconfig)
[^flake]: [flake.nix](../../flake.nix)
[^keymap]: [keyboards/ferris/keymaps/bdura/keymap.c](../../keyboards/ferris/keymaps/bdura/keymap.c)
