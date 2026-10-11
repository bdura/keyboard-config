---
task-id: 03
blocked-by:
  - 02-makefile-sync
---

# 03: Documentation and bookkeeping

## Changes

- `README.md`: replace the `qmk setup` instructions with the three workflows:
  iterate (`make ferris/sweep:bdura`), release (`nix build`, `nix build --rebuild`),
  flash (`nix run .`). Mention `nix flake update qmk-firmware`.
- `ARCHITECTURE.md`: create from the architecture template.
- Wiki: update `nix-dev-shell`, `qmk-userspace`, `qmk-firmware-checkout`,
  `repo-lifecycle`, `tooling`, `qmk-build-pipeline` (the `-Werror` section)
  to the new workflow.
- Close `issues/firmware-build-fails-lufa-werror.md` (`design.md §4`).

## Tests

- Every command in the README runs as written.
