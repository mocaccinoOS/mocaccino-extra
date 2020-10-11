#!/bin/bash

set -x
mottainai-cli -p build webhook edit 1577128430104469230 filter refs/heads/master
mottainai-cli -p build webhook edit 2387426890151640276 filter pull_request
mottainai-cli -p build webhook update 2387426890151640276 task --yaml test-all.yaml
mottainai-cli -p build webhook update 1577128430104469230 task --yaml build-all.yaml

