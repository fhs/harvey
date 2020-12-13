#!/bin/sh

set -e

export GOBIN=$(pwd)/$(go env GOHOSTOS)_$(go env GOHOSTARCH)/bin
echo GOBIN is now $GOBIN

echo Fetching u-root and building it...
GO111MODULE=on go get github.com/u-root/u-root@c370a343c8b0b01faac358c1dafb409e5576ae1a
# Download u-root sources into $GOPATH because that's what u-root expects.
# See https://github.com/u-root/u-root/issues/805
# and https://github.com/u-root/u-root/issues/583
GO111MODULE=off go get -d github.com/u-root/u-root

# this will make booting a VM easier
mkdir -p tmp

cat <<EOF

# We support RISC-V, but the default is x86_64 (which we call amd64 for historical reasons):
export ARCH=amd64
# You also need to export your C compiler flavor (gcc, clang, gcc-7...)
export CC=gcc
# Create an alias for the build command:
alias build="env GO111MODULE=on go run github.com/Harvey-OS/harvey/util/src/harvey/cmd/build"
# And build:
build
# See \`build -h' for more information on the build tool.

To enable access to files, create a harvey and none user:
sudo useradd harvey
sudo useradd none

none is only required for drawterm/cpu access

Also:
export HARVEY=$(pwd)
add $GOBIN to your path
EOF
