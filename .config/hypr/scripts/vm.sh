#!/bin/sh

if virsh --connect qemu:///system list --name --state-running | grep -q "^archlinux$"; then
  exec virt-viewer --connect qemu:///system archlinux
else
  notify-send "QEMU/KVM" "Starting the 'archlinux' virtual machine..."
  virsh --connect qemu:///system start archlinux > /dev/null 2>&1
  sleep 5
  exec virt-viewer --connect qemu:///system archlinux
fi
