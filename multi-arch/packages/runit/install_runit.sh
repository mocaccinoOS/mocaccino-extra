#!/bin/sh

set -ex
install -d /runit/sbin 
for i in chpst runit runit-init runsv runsvchdir runsvdir sv svlogd utmpset; do
    install -m755 "$i" /runit/sbin/$i || return 1
done
install -d /runit/usr/share/man/man8
cd .. && cp -rf man/* /runit/usr/share/man/man8/
mkdir -p /runit/etc/service
mkdir -p /runit/etc/sv