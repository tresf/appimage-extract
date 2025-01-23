# Extracts an AppImage file using unsquashfs

## Description

Calculate and provide the byte offset value required for `unsquashfs` to extract the contents of an AppImage file.

Inspired by SuperUser question "How can I extract files from an AppImage?" https://superuser.com/q/1301583/443147.

## Dependencies:
`readelf` (or) `python`, `unsquashfs`

## Usage
```bash
./appimage-extract.sh MyApp.AppImage [destination]
```
If `destination` is not provided, it will place extracted files in `squashfs-root` adjacent to the `.AppImage`.
