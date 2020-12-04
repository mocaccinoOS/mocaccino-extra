#!/bin/bash

set -e 

rsync -aqz --exclude='mnt' --exclude='proc' --exclude='sys' --exclude='dev' --exclude='tmp' / /mnt/mocaccino || die
