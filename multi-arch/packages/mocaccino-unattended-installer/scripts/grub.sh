#!/bin/bash


export ROOTFS=/mnt/mocaccino

CURRENT_KERNEL=$(ls $ROOTFS/boot/kernel-*)
export INITRAMFS=${CURRENT_KERNEL/kernel/initramfs}

luet geninitramfs "${INITRAMFS_PACKAGES}"
pushd $ROOTFS/boot/
rm -rf Initrd
ln -s initramfs* Initrd
popd

chroot /mnt/mocaccino /bin/sh <<EOF
echo "set timeout=0" >> /etc/grub.d/40_custom
echo "GRUB_CMDLINE_LINUX_DEFAULT=\"root=${INSTALL_DEVICE}4\"" >> /etc/default/grub
grub-install ${INSTALL_DEVICE}
grub-mkconfig -o /boot/grub/grub.cfg
EOF

