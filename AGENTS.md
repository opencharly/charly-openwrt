# AGENTS.md — opencharly/charly-openwrt

The OpenWrt package feed for `charly`: the CLI and its composed toolchain
packaged as `.ipk` for `amd64` and `arm64`. A GitHub Actions workflow (manual
dispatch with a charly release CalVer) builds the feed, signs the `Packages`
index with usign, install-tests it, and publishes it to GitHub Pages.

Canonical files:

- `.github/workflows/build.yml` — the manual build: download the charly release
  assets, build the `.ipk` variants, sign the index, install-test, deploy Pages.
- `scripts/make-index.sh` — generates the opkg `Packages` index from a directory
  of `.ipk` files (SHA-256, no buildroot MKHASH).
- `charly.pub` — the usign public key the feed signature verifies against.
- `index.html`, `.nojekyll` — the Pages landing page.
- `CHANGELOG/` — history (one file per CalVer release).
- `README.md` — user overview only; never agent guidance.

## Load these skills first (R0)

- `/charly-internals:repo-setup` — the org landing automation (required workflow,
  native auto-merge, tag-on-merge CalVer) and the new-repo checklist.
- `/charly-tools:charly` — the `charly` release binary + welded plugins the feed
  packages.

## Build / validate / test

- The feed is built by **Actions → build → Run workflow**, entering the charly
  release CalVer to package.
- Each build install-tests the assembled repository from a local `file://` mount:
  it installs `charly` via `opkg` (signature check against `charly.pub`), asserts
  `charly version` equals the packaged release, and confirms the binary is
  present.
- The merge gate is the **org-wide** `charly/pr-validator` (required check
  `validate / validate`, defined in `opencharly/.github`); this repo carries no
  per-repo candy gate.

## Modify this repo

- The main repo's release is the source of truth for the binary, the plugins, and
  the packaging metadata; the feed packages them — do not vendor a binary here.
- OpenWrt's repos do not carry charly's mandatory runtime deps (podman, qemu,
  libvirt), so full VM/container management is not expected on OpenWrt; the
  package installs and `charly version` runs.

## Landing

- PR-only. Every change lands through a pull request; the org-required
  `charly/pr-validator` validates the diff and body and arms native auto-merge on
  PASS. Direct pushes to `main` are blocked.
- History lives in `CHANGELOG/` (written by `tag-on-merge` at merge time); the PR
  body IS the changelog.
- The authoritative rulebook is the umbrella `AGENTS.md` in
  `opencharly/opencharly` and `charly/AGENTS.md` in the charly repo. Do not
  restate its rules here.
