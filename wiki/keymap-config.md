---
summary: The remaining config.h settings — mouse-key tuning, split USB detection and RGB underglow effects — largely inherited from the upstream Ferris default keymap.
sources:
  - keyboards/ferris/keymaps/bdura/config.h
  - keyboards/ferris/keymaps/bdura/rules.mk
tags:
  - keymap
  - config
---

# Keymap config (config.h)

`config.h` carries Pierre Chevalier's 2020 copyright header, the author of
the Ferris; the file was started from the upstream Ferris keymap[^config].
Tap-hold timing is covered in [[home-row-mods]]. The rest:

## Mouse keys

Tuned for a ≥60 Hz screen[^config]: `MOUSEKEY_INTERVAL 16` (default
50), `MOUSEKEY_TIME_TO_MAX 40`, `MOUSEKEY_DELAY 100`, and wheel
settings `MOUSEKEY_WHEEL_DELAY 100`, `MOUSEKEY_WHEEL_INTERVAL 50`,
`MOUSEKEY_WHEEL_TIME_TO_MAX 100`.

No mouse keycodes appear in the keymap and `rules.mk` does not enable
`MOUSEKEY_ENABLE`[^rules]. The `ferris/sweep` keyboard definition enables `mousekey`
itself ([[ferris-hardware]]), so mouse keys and these settings are compiled in.
They have no effect, though, because no mouse keycode is mapped.

## Split USB detection

`SPLIT_USB_DETECT` with `SPLIT_USB_TIMEOUT 2500`, following a Reddit r/olkb thread
linked in the source[^config]. This helps each half decide whether it is the
USB-connected master. On Pro Micros it is optional. With no handedness setting,
USB must go into the left half ([[split-handedness]]).

## RGB underglow

A block of `RGBLIGHT_EFFECT_*` defines and hue/sat/val steps, guarded by
`#ifdef RGBLIGHT_ENABLE`[^config]. `RGBLIGHT_ENABLE` is not set in `rules.mk`[^rules],
and `ferris/sweep` does not enable `rgblight` either ([[ferris-hardware]]),
so this block is inert.

[^config]: [keyboards/ferris/keymaps/bdura/config.h](../../keyboards/ferris/keymaps/bdura/config.h)
[^rules]: [keyboards/ferris/keymaps/bdura/rules.mk](../../keyboards/ferris/keymaps/bdura/rules.mk)
