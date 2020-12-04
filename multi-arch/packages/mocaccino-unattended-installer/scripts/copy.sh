#!/bin/bash

set -e 

#echo 3 | equo i rsync
rsync -aqz --exclude='mnt' --exclude='proc' --exclude='sys' --exclude='dev' --exclude='tmp' / /mnt/mocaccino || die
