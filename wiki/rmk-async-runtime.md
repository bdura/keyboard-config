---
summary: RMK runs on Embassy async Rust — every component is a Runnable joined into one static future, wired by typed pub/sub channels whose sizes are compile-time constants.
sources:
  - .agent-workspace/.repos/rmk/rmk/src/input_device/mod.rs
  - .agent-workspace/.repos/rmk/docs/docs/main/docs/features/event.md
  - .agent-workspace/.repos/rmk/docs/docs/main/docs/features/matrix.md
  - .agent-workspace/.repos/rmk/CLAUDE.md
tags:
  - rmk
  - architecture
---

# RMK async runtime and event bus

Part of [[rmk-firmware]]. This is the main architectural contrast with QMK's
single polling main loop ([[qmk-firmware]]).

## Decision: Rust + Embassy, one joined future

Every component (matrix, keyboard, storage, transport, processors) is a
`Runnable`. `run_all!` combines their `.run()` futures with `join_all!`[^run],
so the whole firmware is one statically composed future rather than a set of
spawned tasks (inferred). The FAQ calls the old "task arena is full" error obsolete
since v0.7[^faq].

**Why:**

- **Battery life.** With `async_matrix`, the matrix sleeps until a pin interrupt
  instead of polling. That is what makes months of BLE battery life possible[^matrix].
- **Portability.** Embassy gives one HAL abstraction across vendors.
- **Pure-Rust BLE.** BLE comes from `trouble-host`/`bt-hci`, a Rust BLE host,
  rather than a vendor SDK.
- **Latency.** The README claims about 2 ms wired and 10 ms wireless.

**Limits:**

- Rust has no AVR support here, so RMK cannot run on the ATmega32u4
  ([[rmk-hardware-support]]).
- The toolchain is heavy: Rust plus targets, `flip-link`, `cargo-make` and
  `probe-rs`. nRF also needs ARM GCC.
- Compiling `rmk-types` can overflow rustc's stack, which needs
  `RUST_MIN_STACK=67108864`[^faq].

## Decision: a typed pub/sub event bus

Data flows like this[^claude]:

```text
Matrix / input devices → events (channels) → processors / Keyboard
  → KEYBOARD_REPORT_CHANNEL → HidWriter (USB or BLE) → host
```

`#[event(channel_size, subs, pubs)]` picks a Channel (one consumer) or a PubSub
(broadcast)[^event]. Capacities are compile-time constants, read from `[event]`
in `keyboard.toml` ([[rmk-keyboard-toml]]).

**Why:** decoupling. A custom processor (an LED, a layer tracker…) subscribes
without touching the core.

**Limits:**

- Capacities are static. Adding a subscriber means raising `[event.<name>].subs`,
  or the build fails or the firmware panics at startup.
- Publishing to a full Channel drops the event[^event].

[^run]: [rmk/src/input_device/mod.rs](../.repos/rmk/rmk/src/input_device/mod.rs),
        l.79–89
[^faq]: [docs/getting_started/faq.md](../.repos/rmk/docs/docs/main/docs/getting_started/faq.md),
        l.221–225, l.256–269
[^matrix]: [docs/features/matrix.md](../.repos/rmk/docs/docs/main/docs/features/matrix.md),
           l.31–39
[^claude]: [CLAUDE.md](../.repos/rmk/CLAUDE.md)
[^event]: [docs/features/event.md](../.repos/rmk/docs/docs/main/docs/features/event.md),
          l.134
