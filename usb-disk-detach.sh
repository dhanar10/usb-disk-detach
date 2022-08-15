#!/usr/bin/env bash

set -e
set -o pipefail

find_disk_by_id()
{
        find /dev/disk/by-id/ -type l -exec sh -c "[ '{}' -ef '$1' ] && echo '{}'" \;
}

find_sys_bus_usb()
{
        find /sys/bus/usb/devices/*/*-*/ -type f -name serial -exec sh -c "case '$1' in *\$(cat '{}')*) dirname '{}';; esac;" \;
}

if [ -z "$1" ]; then
        echo "Usage: $(basename "$0") /dev/sdX"
        exit 1
fi

DISK="$(echo "$1" | sed 's/[0-9]\+$//')"

if [ ! -e "$DISK" ]; then
        echo "Disk not found: $DISK"
        exit 1
fi

DISK_BY_ID="$(find_disk_by_id "$DISK")"
SYS_BUS_USB="$(find_sys_bus_usb "$DISK_BY_ID")"

sync
umount "$DISK"?*
echo 1 > "$SYS_BUS_USB/remove"
