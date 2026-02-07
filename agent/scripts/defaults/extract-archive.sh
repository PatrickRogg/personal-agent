#!/usr/bin/env bash
# Extract an archive file
# Usage: extract-archive.sh <archive_file> [target_directory]
# Output: Lists extracted files to stdout
# Supports: .zip, .tar.gz, .tgz, .tar.bz2, .tar.xz, .tar, .7z, .rar
set -euo pipefail

if [ $# -lt 1 ] || [ ! -f "$1" ]; then
  echo "Usage: extract-archive.sh <archive_file> [target_directory]" >&2
  exit 1
fi

FILE="$1"
BASENAME="$(basename "$FILE")"
TARGET="${2:-$(dirname "$FILE")/${BASENAME%.*}_extracted}"

mkdir -p "$TARGET"

case "$FILE" in
  *.zip)           unzip -o "$FILE" -d "$TARGET" ;;
  *.tar.gz|*.tgz)  tar xzf "$FILE" -C "$TARGET" ;;
  *.tar.bz2)       tar xjf "$FILE" -C "$TARGET" ;;
  *.tar.xz)        tar xJf "$FILE" -C "$TARGET" ;;
  *.tar)           tar xf "$FILE" -C "$TARGET" ;;
  *.7z)            7z x -o"$TARGET" -y "$FILE" ;;
  *.rar)           7z x -o"$TARGET" -y "$FILE" ;;
  *)
    echo "Unsupported archive format: $FILE" >&2
    exit 1
    ;;
esac

echo "Extracted to: $TARGET"
echo "Contents:"
ls -la "$TARGET"
