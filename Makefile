.SILENT:

MAKEFLAGS += --no-print-directory

QMK_USERSPACE := $(patsubst %/,%,$(dir $(shell realpath "$(lastword $(MAKEFILE_LIST))")))
ifeq ($(QMK_USERSPACE),)
    QMK_USERSPACE := $(shell pwd)
endif

# The pinned qmk_firmware tree, exported by the flake's dev shell.
ifeq ($(QMK_FIRMWARE_SRC),)
    $(error QMK_FIRMWARE_SRC is not set; enter the dev shell first (`nix develop` or direnv))
endif

# A writable copy of the pinned tree, so that QMK's incremental build works.
# The marker records which store path the copy came from.
QMK_FIRMWARE_ROOT := $(QMK_USERSPACE)/.firmware
SYNC_MARKER := $(QMK_FIRMWARE_ROOT)/.nix-source

.PHONY: sync
sync:
	if [ "$$(cat $(SYNC_MARKER) 2>/dev/null)" != "$(QMK_FIRMWARE_SRC)" ]; then \
	    echo "Syncing $(QMK_FIRMWARE_ROOT) from $(QMK_FIRMWARE_SRC)"; \
	    rm -rf "$(QMK_FIRMWARE_ROOT)"; \
	    cp -R "$(QMK_FIRMWARE_SRC)" "$(QMK_FIRMWARE_ROOT)"; \
	    chmod -R u+w "$(QMK_FIRMWARE_ROOT)"; \
	    printf '%s' "$(QMK_FIRMWARE_SRC)" > "$(SYNC_MARKER)"; \
	fi

%: sync
	+$(MAKE) -C $(QMK_FIRMWARE_ROOT) $@ QMK_USERSPACE=$(QMK_USERSPACE)
