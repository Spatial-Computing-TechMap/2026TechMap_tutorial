#!/bin/bash
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
ASSET_DIR="$REPO_ROOT/SolarSystem.docc/Resources"
ASSET_PATH="$ASSET_DIR/SolarSystem-Assets.zip"
REPOSITORY="$(cat "$REPO_ROOT/repository.txt")"
ASSET_URL="https://github.com/$REPOSITORY/releases/download/assets-v2/SolarSystem-Assets.zip"
EXPECTED_SHA="$(awk '{print $1}' "$REPO_ROOT/assets.sha256")"
TEMP_ASSET=""
trap 'if [[ -n "$TEMP_ASSET" ]]; then rm -f "$TEMP_ASSET"; fi' EXIT

verify_asset() {
    local actual_sha
    actual_sha="$(shasum -a 256 "$1" | awk '{print $1}')"
    if [[ "$actual_sha" != "$EXPECTED_SHA" ]]; then
        printf 'Asset checksum mismatch: %s\n' "$1" >&2
        return 1
    fi
}

if [[ ! -f "$ASSET_PATH" ]]; then
    mkdir -p "$ASSET_DIR"
    TEMP_ASSET="$(mktemp "$ASSET_DIR/.SolarSystem-Assets.XXXXXX")"
    curl --fail --location --retry 3 --output "$TEMP_ASSET" "$ASSET_URL"
    verify_asset "$TEMP_ASSET"
    mv "$TEMP_ASSET" "$ASSET_PATH"
    TEMP_ASSET=""
fi

verify_asset "$ASSET_PATH"
printf 'Assets verified: %s\n' "$ASSET_PATH"
