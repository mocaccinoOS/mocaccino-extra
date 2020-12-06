#!/bin/bash

cd /
mkdir ${TARGET}/proc
mkdir ${TARGET}/boot
mkdir ${TARGET}/dev
mkdir ${TARGET}/sys
mkdir ${TARGET}/tmp

mount -t ext2 ${INSTALL_DEVICE}1 ${TARGET}/boot
mount -t proc proc ${TARGET}/proc
mount --rbind /dev ${TARGET}/dev
mount --rbind /sys ${TARGET}/sys
