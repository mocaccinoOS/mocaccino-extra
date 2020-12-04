#!/bin/bash

chroot /mnt/mocaccino /bin/sh <<'EOF'
echo "set timeout=0" >> /etc/grub.d/40_custom
grub-install /dev/sda
grub-mkconfig -o /boot/grub/grub.cfg
EOF
