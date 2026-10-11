---
summary: Formatting setup — prek hooks running qmkfmt without clang-format, clang-format (Google-based, 4-space), clangd flags for cross-compiled code, and editorconfig.
sources:
  - prek.toml
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

`.clang-format` is based on Google style, with 4-space indents, no tabs,
a 1000-column limit (lines are effectively never wrapped), aligned consecutive
assignments and declarations, and includes left unsorted[^clangformat].

The keymap array in `keymap.c` is wrapped in `// clang-format off` / `on`
so the hand-aligned key grid is preserved[^keymap].

## qmkfmt

`qmkfmt` (v0.3.0, built in [[nix-dev-shell]]) formats QMK keymap arrays into
aligned grids; it was added in commit `9d106ad`[^flake]. It runs as a pre-commit
hook (see below).

## prek hooks

`prek.toml` (commit `aeaa990`) registers pre-commit hooks, run by `prek` from the
[[nix-dev-shell]] and installed with `prek install`[^prek]:

- prek builtins: trailing whitespace, end-of-file, mixed line endings,
  merge conflicts, large files, case conflicts, TOML/YAML syntax, private keys,
  shebangs on executables.
- `reflow` (local) — rewraps markdown.
- `qmkfmt` (local) — formats every staged `keymap.c`.

qmkfmt accepts a single path per call and rewrites it in place, so the hook loops
over files:

```toml
entry = "sh -c 'for f in \"$@\"; do qmkfmt --no-clang-format \"$f\" || exit 1; done' --"
files = "keymap\\.c$"
```

### Why `--no-clang-format`

By default qmkfmt runs clang-format over the whole file before aligning the
keymap grid. On `keymap.c` that removed the `// clang-format off` / `on` markers,
collapsed `enum layers` onto one line, and flattened the hand-aligned `#define` row
macros ([[ferris-keymap]]). This happened in a commit (`f970988`) that was then
reset away. With `--no-clang-format`, qmkfmt leaves the current file byte-for-byte
unchanged[^prek]. clang-format itself is therefore never run by the hooks;
`.clang-format` applies only to manual or editor formatting.

## clangd and `compile_commands.json`

`qmk compile --compiledb` writes `compile_commands.json` and copies it into the
userspace root, where clangd picks it up ([[qmk-build-pipeline]]).

## clangd

`.clangd` makes clangd usable on firmware code: it forces `clang`, drops
MCU-specific GCC flags (`-mmcu=*`, `-mcpu=*`, …) and all warnings, and silences
unknown-attribute warnings[^clangd]. `compile_commands.json` is gitignored.

## editorconfig

4-space indents, UTF-8, LF and tabs for `Makefile` and `*.mk`[^editorconfig].

[^prek]: [prek.toml](../../prek.toml)
[^clangformat]: [.clang-format](../../.clang-format)
[^clangd]: [.clangd](../../.clangd)
[^editorconfig]: [.editorconfig](../../.editorconfig)
[^flake]: [flake.nix](../../flake.nix)
[^keymap]: [keyboards/ferris/keymaps/bdura/keymap.c](../../keyboards/ferris/keymaps/bdura/keymap.c)
