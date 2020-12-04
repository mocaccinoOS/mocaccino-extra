#!/bin/bash

export LC_ALL=en_US.UTF-8

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
