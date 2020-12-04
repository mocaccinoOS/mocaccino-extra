#!/bin/sh

if [ ! -e "/etc/fstab" ]; then
	touch /etc/fstab
fi

if [ ! -e "/etc/passwd" ]; then
	cp -rfv /etc/skel/etc/passwd /etc/passwd
	entities apply -f /etc/passwd /etc/skel/entities/root_passwd.yaml
fi

if [ ! -e "/etc/shadow" ]; then
	cp -rfv /etc/skel/etc/shadow /etc/shadow
	entities apply -f /etc/shadow /etc/skel/entities/root_shadow.yaml
fi

if [ ! -e "/etc/hosts" ]; then
	cp -rfv /etc/skel/etc/hosts /etc/hosts
fi

if [ ! -e "/etc/group" ]; then
	cp -rfv /etc/skel/etc/group /etc/group
fi

if [ ! -e "/etc/hostname" ]; then
	cp -rfv /etc/skel/etc/hostname /etc/hostname
fi

if [ ! -e "/etc/profile" ]; then
	cp -rfv /etc/skel/etc/profile /etc/profile
fi

if [ ! -e "/etc/issue" ]; then
cat > /etc/issue << "MOCHA"
        ..
      ..  ..
            ..
             ..
            ..
           ..
         ..
##       ..    ####
##.............##  ##
##.............##   ##
##.............## ##
##.............###
 ##...........##
  #############
  #############
#################
MOCHA

cat >> /etc/issue << "EOF"
Welcome to MocaccinoOS (login with user: root, password: mocaccino)
EOF

fi

if [ ! -d "/root" ]; then
	mkdir /root
fi

if [ ! -d "/run/vsysctl.d" ]; then
	mkdir -p /run/vsysctl.d
fi

# Required on boot
if [ ! -e "/etc/sysctl.conf" ]; then
	touch /etc/sysctl.conf
fi

if [ ! -d "/var/tmp" ]; then
	mkdir -p /var/tmp
fi

