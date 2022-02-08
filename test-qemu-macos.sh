#!/usr/bin/env bash

set -e
set -x

_ISO_FILE_PATH="./output/my-project_focal-live-server-amd64_autoinstall.iso"
# _ISO_FILE_PATH="./output/my-project_ubuntu-20.04.3-live-server-amd64_autoinstall.iso"

rm -rf test
mkdir -p test
qemu-img create -f qcow2 test/ubuntu.qcow2 10G
qemu-system-x86_64 \
    -m 4G \
    -display default,show-cursor=on \
    -usb \
    -device usb-tablet \
    -machine type=q35,accel=hvf \
    -smp 2 \
    -cdrom "${_ISO_FILE_PATH}" \
    -drive file=test/ubuntu.qcow2,if=virtio \
    -cpu host

# Use the following flag for VGA display (for performance)
# -vga virtio \
