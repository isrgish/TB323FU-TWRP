# Licensing and third-party material

This repository is a **mixed-origin device tree**. No blanket license applies
to every file.

Core files carrying `SPDX-License-Identifier: Apache-2.0` remain under
Apache License 2.0; see `LICENSES/Apache-2.0.txt`. Files with their own
notices retain those terms, and patches remain subject to their upstream
project licenses.

## Proprietary Lenovo / Qualcomm files

Lenovo/Qualcomm proprietary binaries, firmware, services, and libraries are
**not included in Git history**. `proprietary-files.tsv` records the exact
private-development target paths/hashes used by the validated fix3b build.
Builders must obtain required proprietary files from a source they are legally
entitled to use.

## Third-party recovery shell tools

The six utilities in `prebuilt-tools.tsv` (curl, fastfetch, git, wget, zsh,
zstd) are intentionally included as third-party binary prebuilts. Versions,
hashes, source provenance and notices are documented in
`docs/THIRD_PARTY_TOOLS.md` and `LICENSES/third-party-tools/`.

Accompanying source/provenance bundle: `TB323FU-TWRP-third-party-corresponding-source-fix3b.tar.xz`

SHA-256: `49eaaf833512753260320cdc0c7263a3de16fb0ac3a9159a0815146307f6b79d`

The normal TWRP build does not rebuild these utilities.

No blanket license is asserted for files lacking an explicit license or clear
upstream origin. This document is practical project documentation, not legal advice.
