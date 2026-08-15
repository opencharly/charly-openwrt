#!/usr/bin/env bash
set -e

# Generate an opkg Packages index from a directory of .ipk files.
#
# Mirrors OpenWrt's scripts/ipkg-make-index.sh without the buildroot MKHASH
# dependency: the SHA-256 is computed with sha256sum. The .ipk files produced
# by the charly generate-packages plugin are gzipped tar archives containing
# ./control.tar.gz (with ./control), so the same tar extraction works.
#
# Usage: make-index <package_directory>

pkg_dir=$1

if [ -z "$pkg_dir" ] || [ ! -d "$pkg_dir" ]; then
	echo "Usage: make-index <package_directory>" >&2
	exit 1
fi

empty=1

for pkg in $(find "$pkg_dir" -name '*.ipk' | sort); do
	empty=
	name="${pkg##*/}"
	name="${name%%_*}"
	[ "$name" = "kernel" ] && continue
	[ "$name" = "libc" ] && continue
	echo "Generating index for package $pkg" >&2
	file_size=$(stat -L -c%s "$pkg")
	sha256sum=$(sha256sum "$pkg" | cut -d' ' -f1)
	# The Packages file sits in the same directory as the .ipk files, so the
	# Filename is the basename (opkg resolves it relative to the feed URL).
	filename=$(basename "$pkg")
	tar -xzOf "$pkg" ./control.tar.gz | tar xzOf - ./control | sed -e "s/^Description:/Filename: $filename\\
Size: $file_size\\
SHA256sum: $sha256sum\\
Description:/"
	echo ""
done
[ -n "$empty" ] && echo
exit 0
