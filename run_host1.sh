#!/bin/bash

# Va utilizzato il QEMU patchato!
qemu/build/qemu-system-x86_64 -machine q35 -accel kvm -m 8G \
    -cpu host,-pku,-xsaves,-kvmclock,-kvm-pv-unhalt \
    -netdev user,id=u1,hostfwd=tcp::2222-:22 \
    -device virtio-net,netdev=u1 -smp 1 -serial stdio \
    -hda debian-12-nocloud-amd64-daily-20240827-1852.qcow2 \
    -monitor telnet:127.0.0.1:55556,server,nowait