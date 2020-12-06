#!/bin/bash

export LC_ALL=en_US.UTF-8

if ((BASH_VERSINFO[0] >= 4)) && [[ $'\u2388 ' != "\\u2388 " ]]; then
        ARROW_IMG=$'\U27A4 '
        INFO_IMG=$'\U2139 '
        WARN_IMG=$'\U26A0 '
        ERR_IMG=$'\U1F480 '
        OK_IMG=$'\U2705 '
    else
        ARROW_IMG=$'\xE2\x9E\xA4 '
        INFO_IMG=$'\xE2\x84\xB9 '
        WARN_IMG=$'\xE2\x9A\xA0 '
        ERR_IMG=$'\xF0\x9F\x92\x80 '
        OK_IMG=$'\xE2\x9C\x85 '
fi

{
# Reset
Color_Off='\033[0m'       # Text Reset
# Regular Colors
Black='\033[0;30m'        # Black
Red='\033[0;31m'          # Red
Green='\033[0;32m'        # Green
Yellow='\033[0;33m'       # Yellow
Blue='\033[0;34m'         # Blue
Purple='\033[0;35m'       # Purple
Cyan='\033[0;36m'         # Cyan
White='\033[0;37m'        # White

# Bold
BBlack='\033[1;30m'       # Black
BRed='\033[1;31m'         # Red
BGreen='\033[1;32m'       # Green
BYellow='\033[1;33m'      # Yellow
BBlue='\033[1;34m'        # Blue
BPurple='\033[1;35m'      # Purple
BCyan='\033[1;36m'        # Cyan
BWhite='\033[1;37m'       # White

# Underline
UBlack='\033[4;30m'       # Black
URed='\033[4;31m'         # Red
UGreen='\033[4;32m'       # Green
UYellow='\033[4;33m'      # Yellow
UBlue='\033[4;34m'        # Blue
UPurple='\033[4;35m'      # Purple
UCyan='\033[4;36m'        # Cyan
UWhite='\033[4;37m'       # White

# Background
On_Black='\033[40m'       # Black
On_Red='\033[41m'         # Red
On_Green='\033[42m'       # Green
On_Yellow='\033[43m'      # Yellow
On_Blue='\033[44m'        # Blue
On_Purple='\033[45m'      # Purple
On_Cyan='\033[46m'        # Cyan
On_White='\033[47m'       # White

# High Intensity
IBlack='\033[0;90m'       # Black
IRed='\033[0;91m'         # Red
IGreen='\033[0;92m'       # Green
IYellow='\033[0;93m'      # Yellow
IBlue='\033[0;94m'        # Blue
IPurple='\033[0;95m'      # Purple
ICyan='\033[0;96m'        # Cyan
IWhite='\033[0;97m'       # White

# Bold High Intensity
BIBlack='\033[1;90m'      # Black
BIRed='\033[1;91m'        # Red
BIGreen='\033[1;92m'      # Green
BIYellow='\033[1;93m'     # Yellow
BIBlue='\033[1;94m'       # Blue
BIPurple='\033[1;95m'     # Purple
BICyan='\033[1;96m'       # Cyan
BIWhite='\033[1;97m'      # White

# High Intensity backgrounds
On_IBlack='\033[0;100m'   # Black
On_IRed='\033[0;101m'     # Red
On_IGreen='\033[0;102m'   # Green
On_IYellow='\033[0;103m'  # Yellow
On_IBlue='\033[0;104m'    # Blue
On_IPurple='\033[0;105m'  # Purple
On_ICyan='\033[0;106m'    # Cyan
On_IWhite='\033[0;107m'   # White
}

function info {
    local message="$*"

    printf "${BBlue}${INFO_IMG} ${BWhite}${On_Black}$message$Color_Off\n"
}

function ok {
    local message="$*"
    printf "${BGreen}${OK_IMG} ${BWhite}${On_Black}$message$Color_Off\n"
}

load_vars() {
  local file=$1
  export ROOTFS_PACKAGES="${ROOTFS_PACKAGES:-$(yq r -j $file 'packages.rootfs' | jq -r '.[]' | xargs echo)}"
  export INITRAMFS_PACKAGES="${INITRAMFS_PACKAGES:-$(yq r -j $file 'packages.initramfs' | jq -r '.[]' | xargs echo)}"
  export LUET_CONFIG="${LUET_CONFIG:-$(yq r -j $file 'luet_config')}"
  export TARGET="${TARGET:-$(yq r -j $file 'target')}"
  export INSTALL_DEVICE="${INSTALL_DEVICE:-$(yq r -j $file 'install_device')}"
}

luet_install() {
  local rootfs=$1
  local packages="$2"

  ## Initial rootfs
  pushd "$rootfs"

  mkdir -p var/lock
  mkdir -p run/lock
  mkdir -p var/cache/luet
  mkdir -p var/luet
  mkdir -p etc/luet

  mkdir -p dev
  mkdir -p sys
  mkdir -p proc
  mkdir -p tmp
  mkdir -p dev/pts
  cp -rfv "${LUET_CONFIG}" etc/luet/luet.yaml
  cp -rfv "${LUET_BIN}" luet

  # Required to connect to remote repositories
  if [ ! -f "etc/resolv.conf" ]; then
    echo "nameserver 8.8.8.8" > etc/resolv.conf
  fi
  if [ ! -f "etc/ssl/certs/ca-certificates.crt" ]; then
    mkdir -p etc/ssl/certs
    cp -rfv "${CA_CERTIFICATES}" etc/ssl/certs
  fi

  if [ "${LUET_REPOS}" != "" ] ; then
    ${SUDO} chroot . /luet install -y ${LUET_REPOS}
  fi

  ${SUDO} chroot . /luet config
  ${SUDO} chroot . /luet install -y ${packages}
  ${SUDO} chroot . /luet cleanup

  # Cleanup/umount
  umount_rootfs $rootfs || true

  ${SUDO} rm -rf luet
  popd
}

### Main script

export INSTALL_DEVICE="${INSTALL_DEVICE:-/dev/sda}"
export TARGET="${TARGET:-/mnt/mocaccino}"

# Try to grab current kernel package name, excluding modules
CURRENT_KERNEL_PACKAGE_NAME=$(luet search --installed kernel --output json | jq -r '.packages[] | select( .category == "kernel" ) | select( .name | test("modules") | not).name')
MINIMAL_NAME="${CURRENT_KERNEL_PACKAGE_NAME/full/minimal}"

export INITRAMFS_PACKAGES="${INITRAMFS_PACKAGES:-utils/busybox kernel/$MINIMAL_NAME system/mocaccino-init system/mocaccino-live-boot init/mocaccino-skel utils/yip utils/yip-integration}"

if [[ -z $SCRIPTS ]]
then
  SCRIPTS=/usr/share/installer
fi

if [ -n "$1" ]; then
  if [ "$1" == "help" ]; then
cat <<EOF
  mocaccino-unattended-installer takes no argument by default, and install the current booting system in $INSTALL_DEVICE.
  You can set a different device by setting INSTALL_DEVICE, or provide a different set of packages for the initramfs with
  INITRAMFS_PACKAGES.

  If ROOTFS_PACKAGES is set, it will create an installation with those packages instead of the live system.

  Optionally, mocaccino-unattended-installer takes a yaml file like the following:

packages:
  rootfs:
  - foo/bar
  - foo/baz
  initramfs:
  - init/foo
  - kernels/blah

install_device: /dev/sda
luet_config: /etc/luet/luet.yaml

---------
Note, you don't need to set any 'packages.rootfs'. If set, the installer will install these packages instead of the current running system.
EOF
  exit 0
  else
    load_vars "$1"
  fi
fi


cat <<'EOF'
          _ _
     _(,_/ \ \____________
     |`. \_@_@   `.     ,'
     |\ \ .        `-,-'
     || |  `-.____,-'
     || /  /
     |/ |  |
`..     /   \
  \\   /    |
  ||  |      \
   \\ /-.    |
   ||/  /_   |
   \(_____)-'_)
  Welcome to the MocaccinoOS unattended installer!

This script will erase all your drive content and install MocaccinoOS without any further prompt.
Be warned, by going forward, you will loose all your data, and consider yourself warned.
EOF

if [ -z "$AUTOMATED_INSTALL" ]; then
    read -p "I'm not going to ask you any other questions, are you sure you want to continue? [y/N] : " -n 1 -r
    if [[ ! $REPLY =~ ^[Yy]$ ]]
    then
        [[ "$0" = "$BASH_SOURCE" ]] && exit 1 || return 1 # handle exits from shell or function but don't exit interactive shell
    fi
    info "If you don't want me to ask any question anymore, set AUTOMATED_INSTALL=true next time!"
fi

echo
echo "########"
echo "Bundling the following packages in ${BWhite}${On_Black}initramfs$Color_Off: "
echo "$INITRAMFS_PACKAGES"
echo "########"

if [ -n "$ROOTFS_PACKAGES" ]; then
  echo "########"
  echo "Bundling the following packages in ${BWhite}${On_Black}rootfs$Color_Off: "
  echo "$ROOTFS_PACKAGES"
  echo "########"
else
  echo "########"
  echo "Copying packages from Live system"
  echo "########"
fi

chmod +x $SCRIPTS/scripts/*.sh

for script in \
  partition   \
  mounts      \
  copy        \
  fstab       \
  grub        \
  setup
do
  "$SCRIPTS/scripts/$script.sh"
done

ok "Done"
