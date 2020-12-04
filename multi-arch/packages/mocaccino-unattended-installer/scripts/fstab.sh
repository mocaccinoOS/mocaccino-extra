#!/bin/bash

chroot /mnt/mocaccino /bin/sh <<EOF
cat > /etc/fstab <<'DATA'
# <fs>		<mount>	<type>	<opts>		<dump/pass>
${INSTALL_DEVICE}1	/boot	ext2	noatime	1 2
${INSTALL_DEVICE}4	/	ext4	noatime		0 1
${INSTALL_DEVICE}3	none	swap	sw		0 0
DATA
EOF
