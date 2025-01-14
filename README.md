# Extracts an AppImage file using unsquashfs

## Dependencies:
`readelf`, `unsquashfs`

## Usage
```bash
./appimage-extract.sh MyApp.AppImage [destination]
```
If `destination` is not provided, it will place extracted files in `squashfs-root` adjacent to the `.AppImage`.
