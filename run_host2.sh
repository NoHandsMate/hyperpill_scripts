#!bin/bash

echo "Clean mytpm1"
rm -rf /tmp/mytpm1; mkdir /tmp/mytpm1
echo "Killing swtpm"
pkill swtpm
swtpm socket --tpmstate dir=/tmp/mytpm1 \
  --ctrl type=unixio,path=/tmp/mytpm1/swtpm-sock \
  --tpm2 \
  --log level=20 \
  --daemon

echo "swtpm started"
echo "Wanna start qemu?"
read -n 1 -p "Press a key to continue"

qemu-9.0.0/build/qemu-system-x86_64 -machine q35 -accel kvm -m 1G \
    -device ac97,audiodev=snd0 -audiodev none,id=snd0 \
    -device cs4231a,audiodev=snd1 -audiodev none,id=snd1 \
    -device intel-hda,id=hda0 -device hda-output,bus=hda0.0 -device hda-micro,bus=hda0.0 -device hda-duplex,bus=hda0.0 \
    -device sb16,audiodev=snd2 -audiodev none,id=snd2 \
    -drive file=null-co://,if=none,format=raw,id=disk0 -drive file=null-co://,if=none,format=raw,id=disk1 \
    -drive file=null-co://,if=none,format=raw,id=disk2 -drive file=null-co://,if=none,format=raw,id=disk3 \
    -drive file=null-co://,if=none,format=raw,id=disk4 -drive file=null-co://,if=none,format=raw,id=disk5 \
    -drive file=null-co://,if=none,format=raw,id=disk6 -drive file=null-co://,if=none,format=raw,id=disk7 \
    -drive file=null-co://,if=none,format=raw,id=disk8 -drive file=null-co://,if=none,format=raw,id=disk9 \
    -blockdev driver=null-co,read-zeroes=on,node-name=null0 \
    -device ide-cd,drive=disk1 \
    -device isa-fdc,id=floppy0 \
    -device qemu-xhci,id=xhci \
    -device usb-tablet,bus=xhci.0 -device usb-bot -device usb-storage,drive=disk3 \
    -chardev null,id=cd0 -chardev null,id=cd1 -device usb-braille,chardev=cd0 -device usb-serial,chardev=cd1 \
    -device usb-ccid -device usb-ccid -device usb-kbd -device usb-mouse \
    -device usb-tablet -device usb-wacom-tablet -device usb-audio \
    -device ich9-usb-ehci1,bus=pcie.0,addr=1d.7,multifunction=on,id=ich9-ehci-1 \
    -device ich9-usb-uhci1,bus=pcie.0,addr=1d.0,multifunction=on,masterbus=ich9-ehci-1.0,firstport=0 \
    -device ich9-usb-uhci2,bus=pcie.0,addr=1d.1,multifunction=on,masterbus=ich9-ehci-1.0,firstport=2 \
    -device ich9-usb-uhci3,bus=pcie.0,addr=1d.2,multifunction=on,masterbus=ich9-ehci-1.0,firstport=4 \
    -device usb-tablet,bus=ich9-ehci-1.0,port=1,usb_version=1 \
    -drive if=none,id=usbcdrom,media=cdrom -device usb-storage,bus=ich9-ehci-1.0,port=2,drive=usbcdrom \
    -device pci-ohci -device usb-kbd \
    -device megasas \
    -drive if=none,index=30,file=null-co://,format=raw,id=mydrive \
    -device scsi-cd,drive=null0 -device sdhci-pci,sd-spec-version=3 -device sd-card,drive=mydrive \
    -device virtio-blk,drive=disk4 -device virtio-scsi,num_queues=8 -device scsi-hd,drive=disk5 \
    -device e1000,netdev=net0 -netdev user,id=net0 \
    -device e1000e,netdev=net1 -netdev user,id=net1 \
    -device igb,netdev=net2 -netdev user,id=net2 \
    -device i82550,netdev=net3 -netdev user,id=net3 \
    -device ne2k_pci,netdev=net4 -netdev user,id=net4 \
    -device pcnet,netdev=net5 -netdev user,id=net5 \
    -device rtl8139,netdev=net6 -netdev user,id=net6 \
    -device vmxnet3,netdev=net7 -netdev user,id=net7 \
    -device ati-vga -device cirrus-vga -device virtio-gpu \
    -chardev socket,id=chrtpm,path=/tmp/mytpm1/swtpm-sock \
    -tpmdev emulator,id=tpm0,chardev=chrtpm -device tpm-tis,tpmdev=tpm0 \
    -object cryptodev-backend-builtin,id=cryptodev0 -device virtio-crypto-pci,id=crypto0,cryptodev=cryptodev0 \
    -drive file=null-co://,if=none,id=nvm -device nvme,serial=deadbeef,drive=nvm \
    -monitor stdio -append console=ttyS0 -kernel bzImage -initrd rootfs.cpio.gz
