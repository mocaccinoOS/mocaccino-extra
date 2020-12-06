#!/bin/bash

set -e 


cat <<'EOF'
  /~\
 C oo
 _( ^)
/   ~\

EOF

export LUET_YES=true

if [ -n "$ROOTFS_PACKAGES" ]; then
    echo "Installing packages ${ROOTFS_PACKAGES}"
    luet_install "${TARGET}" "$ROOTFS_PACKAGES"
else
    echo "Rsyncing / to ${TARGET}"
    rsync -aqz --exclude='mnt' --exclude='proc' --exclude='sys' --exclude='dev' --exclude='tmp' / ${TARGET}
fi