#!/bin/sh

if virsh --connect qemu:///system list --name --state-running | grep -q "^debian13$"; then
  exec virt-viewer --connect qemu:///system debian13
else
  notify-send "QEMU/KVM" "Starting the 'debian13' virtual machine..."
  virsh --connect qemu:///system start debian13 > /dev/null 2>&1
  sleep 5
  exec virt-viewer --connect qemu:///system debian13
fi
