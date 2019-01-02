#!/bin/bash
set -e

# Go through the patches
PATCHES="/usr/local/etc/ghost/patches/*.patch"
for patch in $PATCHES
do
  echo Applying "$patch"
  envsubst < "$patch" > /tmp/patch.patch
  patch -p0 < /tmp/patch.patch
  rm -f /tmp/patch.patch
  rm -f "$patch"
done
