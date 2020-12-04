#!/bin/bash

chroot /mnt/mocaccino /bin/sh <<'EOF'
echo "set timeout=0" >> /etc/grub.d/40_custom
grub2-install /dev/sda
grub2-mkconfig -o /boot/grub/grub.cfg
EOF
