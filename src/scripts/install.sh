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
TAR_OPTIONS=(--no-same-owner --strip-components)1 --gunzip -x -C)
if [[ $(grep '^NAME=' /etc/os-release | cut -d'=' -f2) = "Alpine Linux" ]]; then
  TAR_OPTIONS=(-o --strip-components=1 -z -x -C)
fi

echo "Installing the requested version of Go."
curl --fail --location -sS "https://dl.google.com/go/go${ORB_VAL_VERSION}.${OSD_FAMILY}-${HOSTTYPE}.tar.gz" |
  $SUDO tar "${TAR_OPTIONS[@]}" /usr/local/go/

#shellcheck disable=SC2016
echo 'export PATH=$PATH:/usr/local/go/bin' >>"$BASH_ENV"
$SUDO chown -R "$(whoami)": /usr/local/go
