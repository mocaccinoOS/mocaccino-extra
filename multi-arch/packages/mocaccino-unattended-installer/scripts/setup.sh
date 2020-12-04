#!/bin/bash
rm -rf /mnt/mocaccino/tmp/*
rm -rf /mnt/mocaccino/var/log/*
rm -rf /mnt/mocaccino/var/tmp/*

swapoff ${INSTALL_DEVICE}3
dd if=/dev/zero of=${INSTALL_DEVICE}3
mkswap ${INSTALL_DEVICE}3
