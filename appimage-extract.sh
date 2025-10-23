#!/usr/bin/env bash
# Extracts an AppImage file
# Copyright (C) 2025 Tres Finocchiaro (tres.finocchiaro@gmail.com)
# Permission to copy and modify is granted under the MIT license
#
# Usage: appimage-extract.sh MyApp.Appimage [destination]
#
set -e
export LC_ALL=C

if [ $# -eq 0 ]
  then
    echo "Aborting.  Please provide the path to a .AppImage file."
    exit 1
fi

if [ $# -gt 1 ]; then
    # second parameter is the destination directory
    dest="$2"
else
    # fallback to adjacent squashfs-root
    dest="$(dirname "$1")/squashfs-root"
fi

if command -v python3 2>&1 >/dev/null; then
  # Courtesy Fravadona / https://unix.stackexchange.com/a/789710/190347
  echo "Using python..."
  offset=$(python3 -c '
import os, struct;
elfHeader = os.read(0, 64);
(bitness,endianness) = struct.unpack("4x B B 58x", elfHeader);
(shoff,shentsize,shnum) = struct.unpack(
    (">" if endianness == 2 else "<") +
    ("40x Q 10x H H 2x" if bitness == 2 else "32x L 10x H H 14x"),
    elfHeader
);
print(shoff + shentsize * shnum)
' < "$1")
elif command -v readelf 2>&1 >/dev/null; then
  echo "Using readelf..."
  # Courtesy Martin Vyskočil / https://superuser.com/a/1690054/443147
  header=$(readelf -h "$1")
  start=$(echo "$header" | grep -oP "(?<=Start of section headers: )[0-9]+")
  size=$(echo "$header" | grep -oP "(?<=Size of section headers: )[0-9]+")
  count=$(echo "$header" | grep -oP "(?<=Number of section headers: )[0-9]+")
  offset=$(( $start + $size * $count ))
else
  echo "Aborting. Could not find either python3 or readelf for determining header offset."
  exit 1
fi

if [ -d "$dest" ]; then
  echo "Desination $dest already exists, exiting."
  exit 1
fi

# Conditionally use unsquashfs or dwarfsextract
if unsquashfs -o "$offset" -d "$dest" "$1" 2>/dev/null; then
  # TODO: add better messaging around non-"superblock" errors
  echo # no-op
else
  # fallback to dwarfs
  echo "Using dwarfsextract..."
  dest="$(dirname "$dest")/dwarfs-root"
  mkdir "$dest"
  dwarfsextract -O "$offset" -o "$dest" -i "$1"
fi

find "$dest"