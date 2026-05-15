#!/bin/sh

set -e

BIN_DIR="${HOME}/.local/bin"
BINARY="${BIN_DIR}/chezmoi_modify_manager"
TMP_DIR=$(mktemp -d)

cleanup() {
    rm -rf "${TMP_DIR}"
}
trap cleanup EXIT

if [[ -f $BINARY ]]; then
  exit 0
fi

LATEST=$(curl -sSL -H "Accept: application/vnd.github.v3+json" \
    https://api.github.com/repos/VorpalBlade/chezmoi_modify_manager/releases/latest \
    | grep '"tag_name":' | sed -E 's/.*"([^"]+)".*/\1/')

if [ -z "$LATEST" ]; then
    echo "Failed to fetch latest version" >&2
    exit 1
fi

ASSET="chezmoi_modify_manager-${LATEST}-x86_64-unknown-linux-gnu.tar.gz"
URL="https://github.com/VorpalBlade/chezmoi_modify_manager/releases/download/${LATEST}/${ASSET}"
curl -L -o "${TMP_DIR}/${ASSET}" "${URL}"

tar -xzf "${TMP_DIR}/${ASSET}" -C "${TMP_DIR}"

mkdir -p "${BIN_DIR}"
install -m 755 "${TMP_DIR}/chezmoi_modify_manager" "${BINARY}"

echo "chezmoi_modify_manager ${LATEST} installed to ${BINARY}"
