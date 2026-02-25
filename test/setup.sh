#!/usr/bin/env bash
set -eu -o pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
LIB_DIR="$SCRIPT_DIR/test_libs"

BATS_CORE_VERSION="v1.11.1"
BATS_SUPPORT_VERSION="v0.3.0"
BATS_ASSERT_VERSION="v2.1.0"

clone_if_missing() {
  local name="$1" repo="$2" version="$3"
  local dest="$LIB_DIR/$name"
  if [[ ! -d "$dest" ]]; then
    echo "Downloading $name $version..."
    git clone --depth 1 --branch "$version" "$repo" "$dest"
  fi
}

mkdir -p "$LIB_DIR"
clone_if_missing bats-core https://github.com/bats-core/bats-core.git "$BATS_CORE_VERSION"
clone_if_missing bats-support https://github.com/bats-core/bats-support.git "$BATS_SUPPORT_VERSION"
clone_if_missing bats-assert https://github.com/bats-core/bats-assert.git "$BATS_ASSERT_VERSION"

echo "Test libraries ready."
