#!/bin/bash

chroot /mnt/mocaccino /bin/sh <<EOF
echo "set timeout=0" >> /etc/grub.d/40_custom
echo "GRUB_CMDLINE_LINUX_DEFAULT=\"root=${INSTALL_DEVICE}4\"" >> /etc/default/grub
grub-install ${INSTALL_DEVICE}
grub-mkconfig -o /boot/grub/grub.cfg
EOF

if [[ -L "/mnt/mocaccino/boot/Initrd" ]]; then
   INITRAMFS=$(readlink -f "/mnt/mocaccino/boot/Initrd") luet geninitramfs "${INITRAMFS_PACKAGES}"
else
   INITRAMFS=/mnt/mocaccino/boot/Initrd luet geninitramfs "${INITRAMFS_PACKAGES}"
fi