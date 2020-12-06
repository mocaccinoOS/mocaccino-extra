#!/bin/bash

set -e 


cat <<'EOF'
  /~\
 C oo
 _( ^)
/   ~\

EOF

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

export LUET_YES=true

if [ -n "$ROOTFS_PACKAGES" ]; then
    echo "Installing packages ${ROOTFS_PACKAGES}"
    luet_install "${TARGET}" "$ROOTFS_PACKAGES"
else
    echo "Rsyncing / to ${TARGET}"
    rsync -aqz --exclude='mnt' --exclude='proc' --exclude='sys' --exclude='dev' --exclude='tmp' / ${TARGET}
fi

if [ -n "$TO_REMOVE" ]; then

    chroot ${TARGET} /bin/sh /usr/bin/luet uninstall -y "$TO_REMOVE"

fi
