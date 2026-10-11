---
summary: How a QMK split keyboard decides which half is left/right and which is master, and what that means for this keymap (USB must go in the left half unless EE_HANDS is used).
sources:
  - .agent-workspace/.repos/qmk_firmware/quantum/split_common/split_util.c
  - .agent-workspace/.repos/qmk_firmware/docs/features/split_keyboard.md
  - keyboards/ferris/keymaps/bdura/config.h
tags:
  - qmk
  - split
  - hardware
---

# Split handedness and master detection

Part of [[qmk-firmware]]. Applies to [[ferris-hardware]] (Sweep).

## Handedness

`split_util.c` decides which half is which, in this priority order[^splitutil]:

1. `SPLIT_HAND_PIN`;
2. `SPLIT_HAND_MATRIX_GRID`;
3. `EE_HANDS`, a flag stored in EEPROM;
4. `MASTER_RIGHT`;
5. otherwise the default `MASTER_LEFT`: the USB-connected half is the left[^docs].

## Master detection

The master is the USB-connected half.

- **Without `SPLIT_USB_DETECT`:** VBUS is read directly.
- **With it:** the half polls for an actual USB connection for up to
  `SPLIT_USB_TIMEOUT` ms (default 2000)[^docs].

The docs give the reasons. Pro Micros can sense VBUS out of the box, so the
option is optional on them. Many ARM boards cannot sense VBUS, so ChibiOS targets
turn it on automatically. It also makes a half that is powered for charging only,
not by a host, act as slave[^docs].

## For this keymap

`config.h` sets `SPLIT_USB_DETECT` with `SPLIT_USB_TIMEOUT 2500`[^config]
([[keymap-config]]). On a Pro Micro Sweep this is optional but harmless.

Neither the keyboard nor the keymap sets a handedness option, so `MASTER_LEFT`
applies: **plug USB into the left half**.

To plug in either side instead:

1. add `#define EE_HANDS`;
2. flash each half once with `-bl avrdude-split-left` and `-bl avrdude-split-right`
   respectively ([[qmk-flashing]]).

## See also

RMK has no runtime handedness or master election: roles are fixed by which binary
each half gets ([[rmk-split]]).

[^splitutil]: [quantum/split_common/split_util.c](../.repos/qmk_firmware/quantum/split_common/split_util.c),
              l.141–191
[^docs]: [docs/features/split_keyboard.md](../.repos/qmk_firmware/docs/features/split_keyboard.md),
         l.142–173, l.199, l.447–482
[^config]: [keyboards/ferris/keymaps/bdura/config.h](../../keyboards/ferris/keymaps/bdura/config.h)
