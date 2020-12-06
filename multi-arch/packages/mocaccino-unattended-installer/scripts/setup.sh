#!/bin/bash

if [ -n "$HOOK_SCRIPT" ]; then
chroot ${TARGET} /bin/sh <<EOF
    $HOOK_SCRIPT
EOF
fi

rm -rf ${TARGET}/tmp/*
rm -rf ${TARGET}/var/log/*
rm -rf ${TARGET}/var/tmp/*

swapoff ${INSTALL_DEVICE}3
dd if=/dev/zero of=${INSTALL_DEVICE}3
mkswap ${INSTALL_DEVICE}3
