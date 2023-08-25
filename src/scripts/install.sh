#!/usr/bin/env bash

: "${OSD_FAMILY:="linux"}"
: "${HOSTTYPE:="amd64"}"
if [ "${HOSTTYPE}" = "x86_64" ]; then HOSTTYPE="amd64"; fi
if [ "${HOSTTYPE}" = "aarch64" ]; then HOSTTYPE="arm64"; fi
case "${HOSTTYPE}" in *86 ) HOSTTYPE=i386 ;; esac

if command -v go >/dev/null; then
    if go version | grep -q -F "go<< parameters.version >> "; then
    echo "Binary already exists, skipping download."
    exit 0
    fi

    echo "Found a different version of Go."
    OSD_FAMILY="$(go env GOHOSTOS)"
    HOSTTYPE="$(go env GOHOSTARCH)"

    $SUDO rm -rf /usr/local/go
    $SUDO install --owner="${USER}" -d /usr/local/go
fi

echo "Installing the requested version of Go."

curl --fail --location -sS "https://dl.google.com/go/go${ORB_VAL_VERSION}.${OSD_FAMILY}-${HOSTTYPE}.tar.gz" \
| $SUDO tar --no-same-owner --strip-components=1 --gunzip -x -C /usr/local/go/

#shellcheck disable=SC2016
echo 'export PATH=$PATH:/usr/local/go/bin' >> "$BASH_ENV"
$SUDO chown -R "$(whoami)": /usr/local/go

