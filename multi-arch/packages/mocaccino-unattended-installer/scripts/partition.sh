#!/bin/bash

cat <<'EOF'
   .
  .
 . .
  ...
\~~~~~/
 \   /
  \ /
   V
   |
   |
  ---
EOF

echo "Partitioning ${INSTALL_DEVICE}"

sgdisk \
  -n 1:0:+128M -t 1:8300 -c 1:"linux-boot" \
  -n 2:0:+32M  -t 2:ef02 -c 2:"bios-boot"  \
  -n 3:0:+1G   -t 3:8200 -c 3:"swap"       \
  -n 4:0:0     -t 4:8300 -c 4:"linux-root" \
  -p ${INSTALL_DEVICE}

sync

mkfs.ext2 ${INSTALL_DEVICE}1
mkfs.ext4 ${INSTALL_DEVICE}4

mkswap ${INSTALL_DEVICE}3 && swapon ${INSTALL_DEVICE}3

mkdir ${TARGET}
mount -t ext4 ${INSTALL_DEVICE}4 ${TARGET}
