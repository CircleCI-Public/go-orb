#!/usr/bin/env bash

set -euo pipefail

function alpine_install_curl() {
  apk add curl
}

function get_os() {
  local os
  os=$(uname -o)
  case "$os" in
    GNU/Linux) echo "Linux" ;;
    Linux)     echo "Linux" ;;
    Msys)      echo "Windows" ;;
    Darwin)    echo "Darwin" ;;
    *)         echo "Unsupported OS: $os" ; exit 1;;
  esac
}

function get_architecture() {
  local arch
  arch=$(uname -m)
  case "$arch" in
    aarch64) echo "arm64" ;;
    arm64)   echo "arm64" ;;
    x86_64)  echo "x86_64" ;;
    *)       echo "Unsupported architecture: $arch" ; exit 1;;
  esac
}

download_goreleaser() {
  echo "Downloading goreleaser for ${architecture}..."
  if ! which curl &>/dev/null; then
    echo "curl is not installed. Please install curl and try again."
    exit 1
  fi
  if [ -z "${GO_STR_VERSION:-}" ]; then
    # Taken from https://goreleaser.com/install/#bash-script
    GO_STR_VERSION="$(curl -sf https://goreleaser.com/static/latest)"
  fi
  URL="https://github.com/goreleaser/goreleaser/releases/download/${GO_STR_VERSION}/goreleaser_${os}_${architecture}.${file_extension}"
  echo "Downloading goreleaser from ${URL}"
  if ! curl --location "${URL}" --output "${TMP_FILE}" &>/dev/null; then
    echo "Failed to download goreleaser"
    exit 1
  fi
}

extract_goreleaser_win() {
  echo "Running on Windows, using unzip to extract..."
  mkdir --parent "${HOME}/go/bin"
  if ! unzip -n /tmp/goreleaser.zip -d "${HOME}/go/bin" goreleaser.exe; then
    echo "Failed to extract goreleaser"
    exit 1
  fi
}

extract_goreleaser_nix() {
  echo "Running on Linux, Attempting to extract to /usr/local/bin..."
  if ! tar -xvzf "${TMP_FILE}" -C /usr/local/bin goreleaser ; then
    echo "Failed to extract goreleaser to /usr/local/bin with normal privileges, trying with sudo..."
    if ! sudo tar -xvzf "${TMP_FILE}" -C /usr/local/bin goreleaser; then
      echo "Failed to extract goreleaser"
      exit 1
    fi
  fi
}

extract_goreleaser() {
  architecture="$(get_architecture)"
  os="$(get_os)"
  if [[ "${os}" == "Windows" ]]; then
    extract_goreleaser_win
  else
    extract_goreleaser_nix
  fi
}

if grep alpinelinux /etc/os-release; then
  alpine_install_curl
fi

if ! which goreleaser &>/dev/null; then
  echo "Installing goreleaser..."
  architecture="$(get_architecture)"
  os="$(get_os)"
  if [[ "${os}" == "Windows" ]]; then
    file_extension="zip"
  else
    file_extension="tar.gz"
  fi
  TMP_FILE="/tmp/goreleaser.${file_extension}"
  download_goreleaser
  extract_goreleaser
else
  echo "goreleaser is already installed. Exiting..."
  exit 0
fi

goreleaser --version
