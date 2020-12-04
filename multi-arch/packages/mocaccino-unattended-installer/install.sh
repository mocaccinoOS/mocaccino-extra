#!/bin/bash

export LC_ALL=en_US.UTF-8
export INSTALL_DEVICE="${INSTALL_DEVICE:-/dev/sda}"
export INITRAMFS_PACKAGES="${INITRAMFS_PACKAGES:-utils/busybox kernel/sabayon-minimal system/mocaccino-init system/mocaccino-live-boot init/mocaccino-skel utils/yip utils/yip-integration}"
if [[ -z $SCRIPTS ]]
then
  SCRIPTS=/usr/share/installer
fi

chmod +x $SCRIPTS/scripts/*.sh

for script in \
  partition   \
  mounts      \
  copy        \
  fstab       \
  grub        \
  setup
do
  "$SCRIPTS/scripts/$script.sh"
done

echo "All done."
