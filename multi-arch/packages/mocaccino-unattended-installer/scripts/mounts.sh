#!/bin/bash

cd /
mkdir /mnt/mocaccino/proc
mkdir /mnt/mocaccino/boot
mkdir /mnt/mocaccino/dev
mkdir /mnt/mocaccino/sys
mkdir /mnt/mocaccino/tmp

mount -t ext2 /dev/sda1 /mnt/mocaccino/boot
mount -t proc proc /mnt/mocaccino/proc
mount --rbind /dev /mnt/mocaccino/dev
mount --rbind /sys /mnt/mocaccino/sys
