---
summary: QMK's external userspace mechanism — how a directory with qmk.json is detected and overlaid on the firmware tree, the build_targets manifest, and keymap precedence.
sources:
  - .agent-workspace/.repos/qmk_firmware/lib/python/qmk/userspace.py
  - .agent-workspace/.repos/qmk_firmware/lib/python/qmk/keymap.py
  - .agent-workspace/.repos/qmk_firmware/lib/python/qmk/path.py
  - .agent-workspace/.repos/qmk_firmware/builddefs/locate_keymap.mk
  - .agent-workspace/.repos/qmk_firmware/builddefs/build_keyboard.mk
  - .agent-workspace/.repos/qmk_firmware/builddefs/common_rules.mk
  - .agent-workspace/.repos/qmk_firmware/Makefile
  - .agent-workspace/.repos/qmk_firmware/docs/newbs_external_userspace.md
tags:
  - qmk
  - userspace
  - build
---

# QMK external userspace

Part of [[qmk-firmware]]. How this repo uses it: [[qmk-userspace]].

## Why it exists

The docs say it lets users "maintain their own keymaps without having to fork,
modify, and maintain a copy of QMK Firmware themselves"[^docs]. The userspace
uses the same layout as the firmware tree (`keyboards/…/keymaps/…`, `layouts/`,
`users/`), so a keymap can move in or out of the tree without edits.

## Detection

The Python side collects candidate directories in this order and uses the first
one whose `qmk.json` validates[^userspace]:

1. any ancestor of the directory where `qmk` was invoked (`$ORIG_CWD`)
   that contains a `qmk.json`;
2. the `$QMK_USERSPACE` environment variable;
3. the `qmk config user.overlay_dir` setting.

To validate, `qmk.json` must have at least `userspace_version` and then match
schema v1.1 or v1.

On the make side, the top-level `Makefile` fills `QMK_USERSPACE` from
`user.overlay_dir` when it is not already set[^makefile]. This repo's `Makefile`
sets it explicitly on the command line instead.

## How the overlay is used

- **Keymaps:** `locate_keymap.mk` adds `$(QMK_USERSPACE)/keyboards/<kb path>/keymaps/<km>`
  to the search list, and `$(QMK_USERSPACE)/layouts` for community layouts[^locate].
- **`users/<name>`:** the userspace copy wins over the in-tree one, and
  `QMK_USERSPACE` is added to `VPATH`[^buildkb].
- **Output:** after a build, the firmware is copied to the `qmk_firmware` root
  *and* to `$(QMK_USERSPACE)/<target>.<fmt>`[^commonrules]. That is why this repo
  gitignores `*.hex`, `*.bin` and `*.uf2`.
- **Cleanup:** `make distclean` also deletes firmware files from the userspace
  root[^makefile].
- **Modules:** community modules are also looked up in `$QMK_USERSPACE/modules`.

## `build_targets` manifest

`qmk.json` can list build targets in three forms[^userspace]:

- `[keyboard, keymap]` (v1);
- `[keyboard, keymap, {env}]` (v1.1, extra make variables);
- a path to a standalone `keymap.json`.

Commands that use the list:

- `qmk userspace-add -kb K -km M` appends a target. If the keymap does not exist
  yet, it creates it first.
- `qmk userspace-compile` builds every listed target.
- `save()` rewrites the file as version 1.1.

The manifest exists mainly so that the GitHub Actions in the userspace template
can build all targets on push and publish a release[^docs]. With an empty list,
`userspace-compile` builds nothing. `qmk compile` and `make kb:km` do not need
the list.

## Keymap precedence (contradiction)

When a userspace keymap and an in-tree keymap have the same name, the code
contradicts itself:

- **Python lookup:** a comment in `qmk.keymap.locate_keymap` says userspace
  is searched last "as we want them to override anything in the main repo".
  However, the `return` sits inside the loop over search directories, so an
  in-tree match returns first[^keymap]. Inferred from code, not run.
- **Make search:** `locate_keymap.mk` also checks in-tree locations first and
  keeps the first match[^locate].
- **Path helpers:** `qmk.path.keymap()` / `keymaps()` list userspace first[^path].

This doesn't affect this repo: the in-tree `keyboards/ferris/keymaps/` has only
`default` and `test`, so `bdura` cannot collide.

## Limits

- **Local checkout required:** building still needs a local `qmk_firmware` checkout.
  The docs call the feature new and possibly buggy[^docs].
- **Keymaps only:** only keymaps, layouts, users and modules can be overlaid.
  Keyboard definitions must live in the firmware tree[^path].

[^docs]: [docs/newbs_external_userspace.md](../.repos/qmk_firmware/docs/newbs_external_userspace.md)
[^userspace]: [lib/python/qmk/userspace.py](../.repos/qmk_firmware/lib/python/qmk/userspace.py)
[^makefile]: [Makefile](../.repos/qmk_firmware/Makefile), l.41–44 and l.441–448
[^locate]: [builddefs/locate_keymap.mk](../.repos/qmk_firmware/builddefs/locate_keymap.mk)
[^buildkb]: [builddefs/build_keyboard.mk](../.repos/qmk_firmware/builddefs/build_keyboard.mk),
            l.417–426
[^commonrules]: [builddefs/common_rules.mk](../.repos/qmk_firmware/builddefs/common_rules.mk),
                l.192–199
[^keymap]: [lib/python/qmk/keymap.py](../.repos/qmk_firmware/lib/python/qmk/keymap.py),
           l.330–363
[^path]: [lib/python/qmk/path.py](../.repos/qmk_firmware/lib/python/qmk/path.py)
