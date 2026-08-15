# charly-openwrt

The OpenWrt package feed for [charly](https://github.com/opencharly/charly) — the OpenCharly CLI and its composed toolchain, packaged as `.ipk` for `amd64` and `arm64`.

The feed is built by a GitHub Actions workflow (manual dispatch with a charly release CalVer) and published to GitHub Pages. Each build produces the `charly` package plus the named variants `charly-full` and `charly-minimal` (differing in the baked-in plugin set), signs the `Packages` index with usign, and install-tests the result before deploying.

> **Note on functionality:** OpenWrt's repositories do not carry charly's mandatory runtime dependencies (podman, qemu, libvirt), so the package installs and the binary runs (`charly version`), but full VM/container management is not expected on OpenWrt itself.

## Add the feed

```sh
# Install the usign public key, named by its fingerprint (opkg-key requirement)
mkdir -p /etc/opkg/keys
wget -O /tmp/charly.pub https://opencharly.github.io/charly-openwrt/charly.pub
cp /tmp/charly.pub /etc/opkg/keys/$(usign -F -p /tmp/charly.pub)
echo "src/gz charly https://opencharly.github.io/charly-openwrt/amd64" >> /etc/opkg/customfeeds.conf
opkg update
opkg install charly
```

For `arm64` hosts, use `https://opencharly.github.io/charly-openwrt/arm64` in `customfeeds.conf`.

## Direct install

Download the `.ipk` for your architecture and install it with `opkg install`:

- amd64: `https://opencharly.github.io/charly-openwrt/amd64/charly-amd64.ipk`
- arm64: `https://opencharly.github.io/charly-openwrt/arm64/charly-arm64.ipk`

## Variants

| Package | Plugin set |
|---|---|
| `charly` | secrets, feature, vm, doctor, clean, settings, candy |
| `charly-full` | the default set + udev, preempt |
| `charly-minimal` | doctor, clean, settings |

## Triggering a build

The workflow is manual: **Actions → build → Run workflow**, entering the charly release CalVer to package (e.g. `2026.227.1026`). The main repo's release is the source of truth for the binary, the plugins, and the packaging metadata.

## Verification

Each build install-tests the feed from a local `file://` mount of the assembled repository before deploying: it installs `charly` via opkg (with the signature check passing against the usign key), asserts `charly version` equals the packaged release, and confirms the binary is present.
