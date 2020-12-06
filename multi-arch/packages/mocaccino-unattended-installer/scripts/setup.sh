#!/bin/bash
rm -rf ${TARGET}/tmp/*
rm -rf ${TARGET}/var/log/*
rm -rf ${TARGET}/var/tmp/*

swapoff ${INSTALL_DEVICE}3
dd if=/dev/zero of=${INSTALL_DEVICE}3
mkswap ${INSTALL_DEVICE}3
