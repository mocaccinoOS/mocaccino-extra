#!/bin/bash
rm -rf /mnt/mocaccino/tmp/*
rm -rf /mnt/mocaccino/var/log/*
rm -rf /mnt/mocaccino/var/tmp/*

swapoff /dev/sda3
dd if=/dev/zero of=/dev/sda3
mkswap /dev/sda3
