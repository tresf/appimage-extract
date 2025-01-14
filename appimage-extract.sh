#!/usr/bin/env bash
# Extracts an AppImage file
# Copyright (C) 2025 Tres Finocchiaro (tres.finocchiaro@gmail.com)
# Permission to copy and modify is granted under the MIT license
#
# Usage: appimage-extract.sh MyApp.Appimage [destination]
#
# TODO: Port to macOS using objdump -x
set -e
export LC_ALL=C

if [ $# -eq 0 ]
  then
    echo "Please provide the path to a .AppImage file"
    exit 1
fi

if [ $# -gt 1 ]; then
    # second parameter is the destination directory
    dest="$2"
else
    # fallback to adjacent squashfs-root
    dest="$(dirname "$1")/squashfs-root"
fi

# Courtesy Martin Vyskočil / https://superuser.com/a/1690054/443147
header=$(readelf -h "$1")
start=$(echo $header | grep -oP "(?<=Start of section headers: )[0-9]+")
size=$(echo $header | grep -oP "(?<=Size of section headers: )[0-9]+")
count=$(echo $header | grep -oP "(?<=Number of section headers: )[0-9]+")
offset=$(( $start + $size * $count ))

if [ -d "$dest" ]; then
  echo "Desination $dest already exists, exiting."
  exit 1
fi

unsquashfs -o "$offset" -d "$dest" "$1"

find "$(dirname "$dir")/squashfs-root"