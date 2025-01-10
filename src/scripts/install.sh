#!/usr/bin/env bash

: "${OSD_FAMILY:="linux"}"
: "${HOSTTYPE:="amd64"}"
if [ "${HOSTTYPE}" = "x86_64" ]; then HOSTTYPE="amd64"; fi
if [ "${HOSTTYPE}" = "aarch64" ]; then HOSTTYPE="arm64"; fi
case "${HOSTTYPE}" in *86) HOSTTYPE=i386 ;; esac

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

# Checking if Alpine is being used to update the tar options
echo "Installing the requested version of Go."
curl -O --fail --location -sS "https://dl.google.com/go/go${ORB_VAL_VERSION}.${OSD_FAMILY}-${HOSTTYPE}.tar.gz"
$SUDO tar xzf "go${ORB_VAL_VERSION}.${OSD_FAMILY}-${HOSTTYPE}.tar.gz" -C /opt
rm "go${ORB_VAL_VERSION}.${OSD_FAMILY}-${HOSTTYPE}.tar.gz"
ln -s /opt/go/bin/go /usr/local/bin/go
ln -s /opt/go/bin/gofmt /usr/local/bin/gofmt

#shellcheck disable=SC2016
$SUDO chown -R "$(whoami)": /usr/local/bin/go /usr/local/bin/gofmt
