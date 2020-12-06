#!/bin/bash

cat <<'EOF'
   .       . 
 +  :      .
           :       _
       .   !   '  (_)
          ,|.' 
-  -- ---(-O-`--- --  -
         ,`|'`.
       ,   !    .
           :       :  " 
           .     --+--
 .:        .       !
EOF

echo "Generating initramfs and grub setup"

BOOTDIR=$TARGET/boot

CURRENT_KERNEL=$(ls $BOOTDIR/kernel-*)
export KERNEL_GRUB=${CURRENT_KERNEL/${BOOTDIR}/}
export INITRAMFS=${CURRENT_KERNEL/kernel/initramfs}
export INITRAMFS_GRUB=${INITRAMFS/${BOOTDIR}/}

luet geninitramfs "${INITRAMFS_PACKAGES}"
pushd $TARGET/boot/
rm -rf Initrd
ln -s initramfs* Initrd
popd

mkdir -p ${TARGET}/boot/grub
cat > ${TARGET}/boot/grub/grub.cfg << EOF
set default=0
set timeout=10
set gfxmode=auto
set gfxpayload=keep
insmod all_video
insmod gfxterm
menuentry "MocaccinoOS" {
  linux /$KERNEL_GRUB root=${INSTALL_DEVICE}4
  initrd /$INITRAMFS_GRUB
}
EOF

# grub-mkconfig -o /boot/grub/grub.cfg

chroot ${TARGET} /bin/sh <<EOF
echo "GRUB_CMDLINE_LINUX_DEFAULT=\"root=${INSTALL_DEVICE}4\"" >> /etc/default/grub
grub-install ${INSTALL_DEVICE}
EOF

