#!/bin/bash
set -x
# CONFIGURE: Tweak to suit your needs
# You might want to remove $PULL_REPOSITORY if you don't need to pull for any image

FINAL_REPO=$(echo "$FINAL_REPO" | tr '[:upper:]' '[:lower:]')
PULL_ARGS=
if [ -n "$PULL_REPOSITORY" ]; then
  PULL_ARGS="--pull-repository $PULL_REPOSITORY"
fi

if [ "$BUILDX" == "true" ]; then
  if [ "$PUSH_CACHE" == "true" ]; then
    sudo -E luet build $PULL_ARGS \
            --only-target-package \
            --values values/$ARCH.yaml --backend-args "--platform" --backend-args "linux/$ARCH" --backend-args "--load" \
            --pull --push --image-repository $FINAL_REPO \
            --no-spinner --live-output --tree packages "$1"
  else
    sudo -E luet build $PULL_ARGS \
            --only-target-package \
            --values values/$ARCH.yaml --backend-args "--platform" --backend-args "linux/$ARCH" --backend-args "--load" \
            --pull --image-repository $FINAL_REPO \
            --no-spinner --live-output --tree packages "$1"
  fi
else
  sudo -E luet build $PULL_ARGS \
          --only-target-package \
          --values values/$ARCH.yaml \
          --pull --image-repository $FINAL_REPO \
          --no-spinner --live-output --tree packages "$1"
fi