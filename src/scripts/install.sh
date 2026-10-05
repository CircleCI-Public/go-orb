#!/usr/bin/env bash

RETRY_ATTEMPTS=3
RETRY_DELAY=5

function retry {
  local attempt=1
  while [ "$attempt" -le "$RETRY_ATTEMPTS" ]; do
    echo "Attempt $attempt of $RETRY_ATTEMPTS: $*" >&2
    if "$@"; then
      return 0
    fi
    echo "Attempt $attempt failed." >&2
    attempt=$((attempt + 1))
    if [ "$attempt" -le "$RETRY_ATTEMPTS" ]; then
      echo "Retrying in ${RETRY_DELAY} seconds..." >&2
      sleep "$RETRY_DELAY"
    fi
  done
  echo "All $RETRY_ATTEMPTS attempts failed." >&2
  return 1
}

function alpine_install {
  cd /opt || exit 200
  rm -rf go
  apk add bash gcc musl-dev go
  retry wget --timeout=300 "https://go.dev/dl/go${ORB_VAL_VERSION}.src.tar.gz"
  tar xzf "go${ORB_VAL_VERSION}.src.tar.gz"
  mv go "go${ORB_VAL_VERSION}"
  cd "go${ORB_VAL_VERSION}/src" || exit 201
  ./make.bash
  apk del go
  ln -sf "/opt/go${ORB_VAL_VERSION}/bin/go" /usr/local/bin/go
  ln -sf "/opt/go${ORB_VAL_VERSION}/bin/gofmt" /usr/local/bin/gofmt
}

function standard_install {
  if command -v go >/dev/null; then
    OSD_FAMILY="$(go env GOHOSTOS)"
    HOSTTYPE="$(go env GOHOSTARCH)"
  fi

  $SUDO rm -rf /usr/local/go

  if [ -x /opt/go/bin/go ] && /opt/go/bin/go version | grep -q -F "go${ORB_VAL_VERSION} "; then
    echo "Go ${ORB_VAL_VERSION} already installed, skipping download."
  else
    $SUDO rm -rf /opt/go
    echo "Installing the requested version of Go."
    retry curl -O --fail --location -sS --connect-timeout 30 --max-time 300 "https://dl.google.com/go/go${ORB_VAL_VERSION}.${OSD_FAMILY}-${HOSTTYPE}.tar.gz"
    $SUDO tar xzf "go${ORB_VAL_VERSION}.${OSD_FAMILY}-${HOSTTYPE}.tar.gz" -C /opt
    $SUDO rm "go${ORB_VAL_VERSION}.${OSD_FAMILY}-${HOSTTYPE}.tar.gz"
    $SUDO chown -R "$(whoami)": /opt/go
  fi

  $SUDO ln -sf /opt/go/bin/go /usr/local/bin/go
  $SUDO ln -sf /opt/go/bin/gofmt /usr/local/bin/gofmt
}

: "${OSD_FAMILY:="linux"}"
: "${HOSTTYPE:="amd64"}"
if [ "${HOSTTYPE}" = "x86_64" ]; then HOSTTYPE="amd64"; fi
if [ "${HOSTTYPE}" = "aarch64" ]; then HOSTTYPE="arm64"; fi
case "${HOSTTYPE}" in *86) HOSTTYPE=i386 ;; esac

if grep alpinelinux /etc/os-release; then
  alpine_install
else
  standard_install
fi
